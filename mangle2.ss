(module mangle2 mzscheme
  (require (lib "etc.ss")
           (lib "pretty.ss")
           (lib "list.ss")
           "base-gm.ss")

  (require-for-syntax (lib "etc.ss")
                      "base-gm.ss"
                      (lib "list.ss"))

  (provide (all-defined))

  (define (make-constructor-name basename tail)
    (format "~a--~a" basename tail))

  (define (make-coding-shape with-constructors base-name stx) 
    ;;(debug "make-coding-shape" base-name)
    (with-syntax ([base-name-stx (string->symbol (format "make-~a" base-name))])
      (syntax-case stx (void struct list  cases)
        [void empty]
        
        [(struct (name d type) ...) 
         (with-syntax ([(coding-shape ...)
                        (map 
                         (lambda (n t) 
                           (make-coding-shape with-constructors
                            (make-constructor-name base-name (syntax-e n)) 
                            t))
                         (syntax->list #'(name ...))
                         (syntax->list #'(type ...)))])
           (if with-constructors
               #`(struct ,base-name-stx (coding-shape ...))
               #`(struct 'not-defined (coding-shape ...))))]
        
        [(list (size-type d) type)
         #`(list size-type #,(make-coding-shape with-constructors base-name #'type))]
        
        [(cases (tag-type d) (case-name case-id case-d case-type) ...)
         (with-syntax ([(coding-shape ...)
                        (map 
                         (lambda (n t)
                           (make-coding-shape 
                            with-constructors
                            (make-constructor-name base-name (syntax-e n))
                            t))
                         (syntax->list #'(case-name ...))
                         (syntax->list #'(case-type ...)))])
           #`(cases tag-type (case-name case-id coding-shape) ...))]
        [(d type)
         (and (string? (syntax-e #'d))
              (symbol? (syntax-e #'type)))
         #'type]
        [type  (symbol? (syntax-e #'type)) #'type])))
        
  (define (find-all-structures base-name stx) 

    (syntax-case stx (void struct list cases)
      [void empty]
      [(struct (name d type) ...) 
       (cons
        (list (string->symbol base-name) #'(name ...))        
        (apply append 
               (map (lambda (n t) (find-all-structures (make-constructor-name base-name (syntax-e n)) t))
                    (syntax->list #'(name ...))
                    (syntax->list #'(type ...)))))]
      [(list (size d) type)
       (find-all-structures base-name #'type)]
      [(cases (tag d) (case-name case-id case-d case-type) ...)
       (apply append
              (map (lambda (n t) (find-all-structures (make-constructor-name base-name (syntax-e n)) t))
                   (syntax->list #'(case-name ...))
                   (syntax->list #'(case-type ...))))]
      [(d type)
       (and (string? (syntax-e #'d))
            (symbol? (syntax-e #'type)))
       empty]
      [type (symbol? (syntax-e #'type)) empty]))


  (define (process-command cs-id base-name cmd-id out-may-type-stx reply-may-type-stx encode-fn decode-fn)
    ;;(debug "process-command" (syntax-e base-name))
    (with-syntax 
        ([encode-shape (make-coding-shape false (syntax-e base-name) out-may-type-stx)]
         [decode-shape (make-coding-shape true (syntax-e base-name) reply-may-type-stx)]
         [((struct-name (struct-field-name ...)) ...)
          (find-all-structures (syntax-e base-name) reply-may-type-stx)]
         [encode-fn-stx encode-fn]
         [decode-fn-stx decode-fn]
         [cs-id-stx cs-id]
         [cmd-id-stx cmd-id])
 
      (syntax-case out-may-type-stx (void arg)
        [(struct (name d type) ...)
         #'(begin
             (define-struct struct-name (struct-field-name ...) (make-inspector)) ...
             (define (encode-fn-stx name ...)
               (encode cs-id-stx cmd-id-stx (list name ...) `encode-shape))
             (define (decode-fn-stx c str) (decode c str `decode-shape)))]
        [void
         #'(begin
             (define-struct struct-name (struct-field-name ...) (make-inspector)) ...
             (define (encode-fn-stx)
               (encode cs-id-stx cmd-id-stx () `encode-shape))
             (define (decode-fn-stx c str) (decode c str `decode-shape)))]
        [_
         #'(begin
             (define-struct struct-name (struct-field-name ...) (make-inspector)) ...
             (define (encode-fn-stx arg)
               (encode cs-id-stx cmd-id-stx arg `encode-shape))
             (define (decode-fn-stx c str) (decode c str `decode-shape)))])))


  (define (do-define-jdwp stx)
    (syntax-case stx (command-set command description out-data reply-data error-data)
      [(_
        hash-name
        (command-set
         cs-name cs-id
         (command 
          cmd-name cmd-id
          (description cmd-d)
          (out-data out-may-type)
          (reply-data reply-may-type)
          (error-data (err-name err-d) ...)) ...) ...)

       (symbol? (syntax-e #'hash-name))

       (with-syntax 
           ([(((base-name encode-fn decode-fn) ...) ...)
             (map (lambda (cs-name cmd-ns)
                    (map (lambda (cmd-n)
                           (list
                            (make-constructor-name (syntax-e cs-name) (syntax-e cmd-n))
                            (datum->syntax-object
                             #'hash-name
                             (string->symbol (format "encode-~a-~a" 
                                                     (syntax-e cs-name)
                                                     (syntax-e cmd-n))))
                            (datum->syntax-object
                             #'hash-name
                             (string->symbol (format "decode-~a-~a" 
                                                     (syntax-e cs-name)
                                                     (syntax-e cmd-n))))))
                         (syntax->list cmd-ns)))
                  (syntax->list #'(cs-name ...))
                  (syntax->list #'((cmd-name ...) ...)))])
         
         (with-syntax
             ([(command-def ...)
               (apply
                append
                (map 
                 (lambda (one-cs-id many-args)
                   (map
                    (lambda (args) (apply process-command (cons one-cs-id (syntax->list args))))
                    (syntax->list many-args)))
                 (syntax->list #'(cs-id ...))
                 (syntax->list #'(((base-name cmd-id out-may-type reply-may-type encode-fn decode-fn) ...) ...))))])
         
         #'(begin 
             command-def ...
             (define hash-name 
               (make-immutable-hash-table
                (list 
                 (cons cs-id
                       (make-immutable-hash-table
                        (list 
                         (cons cmd-id decode-fn) ...))) ...))))))]))
  
  (define-syntax (define-jdwp-to-file stx)
    (with-syntax ([stx stx])
      #'(let* ([expanded (syntax-object->datum (do-define-jdwp #'stx))]
               [expanded-wrapped `(module jdwp_spec3 mzscheme 
                                    (require "codec.ss")
                                    (provide (all-defined))
                                    ,expanded)]
               [filename "jdwp_spec3.ss"])
          (when (file-exists? filename) (delete-file filename))
          (call-with-output-file filename
            (lambda (port)
              (display ";;; This file was generated using mangle2.ss\n;;;\n;;;\n" port)
              (pretty-print-columns 100)
              (pretty-print expanded-wrapped port)))))))
  