(module mangle1 mzscheme
  
  (require "base-gm.ss"
           (lib "pretty.ss")
           (lib "match.ss"))
  
  ;;    Target grammar:
  
  ;;    COMMANDSET ::=
  
  ;;    (command-set NAME ID
  ;;                 (command NAME ID
  ;;                          (description D)
  ;;                          (out-data MAY_TYPE)
  ;;                          (reply-data MAY_TYPE)
  ;;                          (error-data (NAME D) ...))
  ;;                 ...)
  ;;    MAY_TYPE ::=
  ;;        void
  ;;        TYPE
  ;;
  ;;    TYPE ::=
  ;;        BASE_TYPE
  ;;        (D BASE_TYPE)
  ;;        (struct (NAME D TYPE) ...)
  ;;        (list (BASIC_TYPE D) TYPE)
  ;;        (cases (BASIC_TYPE D) (NAME ID D TYPE) ...)

  ;; coding shapes:
  ;;
  ;; MAY_SHAPE ::=
  ;;   void
  ;;   SHAPE
  ;;
  ;; SHAPE ::=
  ;;   basic
  ;;   (struct MAKE-FN SHAPE ...)
  ;;   (list basic SHAPE)
  ;;   (cases basic (NAME ID SHAPE) ...)
  ;;
  ;;



  (define (read-tles source-file)
    (let ([source-port (open-input-file source-file)])
      (port-count-lines! source-port)
      (reverse
       (let loop ([result empty])
         (let ([cur (read-syntax source-file source-port (list 0 0 0))])
           (if (eof-object? cur) result
               (loop (cons cur result))))))))
  
  (define (mangle-to-cases-type basic-type d items)
    (append
     `(cases (,basic-type ,d))
     (let loop ([items items])
       (syntax-case items ()
         [() empty]
         [((_ name id case-d sub-type ...) 
           tail ...)
          (cons #`(name id case-d #,(mangle-to-struct-type #'(sub-type ...)))
                (loop #'(tail ...)))]))))
  
  (define (mangle-to-struct-type items)
    (let ([result
           (let loop ([items items])
             (syntax-case items (repeat cases)
               [() empty]
               [((_ type name-a d) 
                 (repeat name-b sub-struct ...)
                 tail ...)
                (begin
                  (assert (eq? (syntax-e #'name-a) (syntax-e #'name-b)))
                  (assert (symbol? (syntax-e #'type)))
                  (cons #`(name-a "" (list (type d) #,(mangle-to-struct-type #'(sub-struct ...))))
                        (loop #'(tail ...))))]
               [((_ type name-a d)
                 (cases name-b all-cases ...)
                 tail ...)
                (begin
                  (assert (eq? (syntax-e #'name-a) (syntax-e #'name-b)))
                  (assert (symbol? (syntax-e #'type)))
                  (cons #`(name-a "" #,(mangle-to-cases-type #'type #'d #'(all-cases ...)))
                        (loop #'(tail ...))))]
               [((_ type name d) tail ...) 
                (cons #'(name d type)
                      (loop #'(tail ...)))]))])

      (syntax-case result ()
        [() 'void]
        [((name d type))
         (if (symbol? (syntax-e #'type)) #'(d type) #'type)]
        [else (cons 'struct result)])))
  
  (define (mangle-error-items items)
    (map (lambda (stx) 
           (syntax-case stx (error-data)
             [(error-data name d) #'(name d)]))
         items))
  
  (define (mangle-items stx) ;; stx -> (values type type (list (name:symbol d:string)))
    (let loop ([stxs (syntax->list stx)]
               [out-items empty]
               [reply-items empty]
               [error-items empty]
               [context 'out])
      
      (if (empty? stxs)
          (values
           (mangle-to-struct-type (reverse out-items))
           (mangle-to-struct-type (reverse reply-items))
           (mangle-error-items (reverse error-items)))
          
          (let ([head (first stxs)]
                [tail (rest stxs)])
            (syntax-case head (out-data reply-data error-data)
              [(out-data type name d)
               (begin
                 (assert (eq? context 'out))
                 (loop tail
                       (cons head out-items)
                       reply-items
                       error-items
                       'out))]
              [(reply-data type name d)
               (begin
                 (assert (or (eq? context 'out) (eq? context 'reply)))
                 (loop tail
                       out-items
                       (cons head reply-items)
                       error-items
                       'reply))]
              [(error-data name d)
               (loop tail
                     out-items
                     reply-items
                     (cons head error-items)
                     'error)]
              [(repeat name sub ...)
               (cond [(eq? context 'out)
                      (loop tail
                            (cons head out-items)
                            reply-items
                            error-items
                            'out)]
                     [(eq? context 'reply)
                      (loop tail
                            out-items
                            (cons head reply-items)
                            error-items
                            'reply)]
                     [else (assert false)])]
              [(cases name sub ...)
               (cond [(eq? context 'out)
                      (loop tail
                            (cons head out-items)
                            reply-items
                            error-items
                            'out)]
                     [(eq? context 'reply)
                      (loop tail
                            out-items
                            (cons head reply-items)
                            error-items
                            'reply)]
                     [else (assert false)])])))))
  
  (define (mangle-command stx)
    (syntax-case stx (command description quote)
      [(command command-name id (description d) items ...)
       (let-values ([(out reply error) (mangle-items #'(items ...))])
         #`(command command-name id (description d) 
                    (out-data #,out)
                    (reply-data #,reply)
                    (error-data #,@error)))]))
  
  (define (mangle-command-set stx)
    (syntax-case stx (command-set quote)
      [(command-set set-name set-id commands ...)
       #`(command-set set-name set-id
                      #,@(map mangle-command (syntax->list #'(commands ...))))]))
  
  (define new-specs (map mangle-command-set (read-tles "jdwp_spec1.ss")))
  (let ([filename "jdwp_spec2.ss"])
    (when (file-exists? filename) (delete-file filename))
    (call-with-output-file filename
      (lambda (port)
        (display ";;; This file was generated using mangle1.ss\n;;;\n;;;\n" port)
        (pretty-print-columns 100)
        (pretty-print (map syntax-object->datum new-specs) port)))))
    