(module jdi-symbol-table mzscheme

  (require "jdwp.ss"
           "base-gm.ss"
           (lib "string.ss")
           (lib "pregexp.ss")
           (lib "contract.ss")
           (lib "plt-match.ss"))
  
  (define-struct linetable (start-offset start-lineno end-lineno no->offset offset->no) (make-inspector))
  (define-struct location (clazz method line client) (make-inspector))
  (define-struct (dyn-location location) (threadid frameid) (make-inspector))
  (define-struct (dyn-locationID locationID) (client threadid frameid) (make-inspector))
  
  (define *client2cache* (make-hash 'weak))
  (define *client2linetable* (make-hash 'weak)) ;; (hash client -> (hash (pair classid methodid) -> linetable))
  
  (define-struct (exn:not-found exn) ())
  
  (define jref-inspector (current-inspector))
  (define-struct jref (client) jref-inspector)
  (define-struct (variable-jref jref) (threadid frameid signature slot) jref-inspector)
  (define-struct (object-jref jref) (objectid) jref-inspector)
  (define-struct (field-jref jref) (objectid fieldid) jref-inspector)
  (define-struct (static-field-jref jref) (classid fieldid) jref-inspector)
  (define-struct (method-jref jref) (classid objectid methodid signature) jref-inspector)
  (define-struct (static-method-jref jref) (classid methodid signature) jref-inspector)
  (define-struct (class-jref jref) (classid) jref-inspector)
  (define-struct (package-jref jref) (name) jref-inspector)
  
  (define (raise-not-found . msgs)
    (raise (make-exn:not-found (list "jdi-symbol-table: item not found:" msgs)
                               (current-continuation-marks))))
  
  
  (define (jloc* jref line)
    (let*-values
        ([(client classid methodid)
          (match jref
                 [(struct static-method-jref (client classid methodid signature))
                  (values client classid methodid)]
                 [(struct method-jref (client classid objectid methodid signature))
                  (values client classid methodid)])]
         [(line-no)
          (match line
                 ['entry 1]
                 ['exit 
                  (sub1
                   (linetable-end-lineno
                    (get-linetable client classid methodid)))]
                 [_ line])])
      (make-location classid methodid line-no client)))
  
  (define (call-memoize fn client . args)
    (hash-gad!
     (hash-gad!
      (hash-gad! 
       *client2cache*
       client (lambda () (make-hash)))
      fn (lambda () (make-hash 'equal)))
     args (lambda () (apply fn (cons client args)))))
  
  (define (signature->type-tag sig) (char->integer (string-ref sig 0)))
  
  (define (javaClassSig->vmClassSig vmClassSig)
    (format "L~a;"
            (regexp-replace* #rx"[.]" vmClassSig "/")))
  
  (define (vmClassSig->javaClassSig javaClassSig)
    (regexp-replace* #rx"[/]" (substring javaClassSig 1 (- (string-length javaClassSig) 1)) "."))
  
  (define (vmClassSig->classID/slow client vmClassSig)
    (match (query client (encode-virtualmachine-classesbysignature vmClassSig))
           [(list (struct virtualmachine--classesbysignature (reftypetag reftypeid status)))
            (assert (classid? reftypeid) reftypeid)
            reftypeid]
           [(list) (raise-not-found vmClassSig)]))
  
  (define (classID->vmClassSig/slow client classID)
    (let ([result (query client (encode-referencetype-signature classID))])
      (if (not result) 
          (raise-not-found classID)
          result)))
  
  (define (javaClassSig->classID/slow client javaClassSig)
    (vmClassSig->classID/slow client (javaClassSig->vmClassSig javaClassSig)))
  
  (define (classID->javaClassSig/slow client classID)
    (vmClassSig->javaClassSig (classID->vmClassSig/slow client classID)))
  
  (define (methodName->methodID/slow client classID method)
    (let loop ([cur (query client (encode-referencetype-methods classID))])
      (match cur
             [(list (struct referencetype--methods (methodid name signature modbits)) tail ...)
              (if (equal? name method)
                  methodid
                  (loop tail))]
             [(list) (raise-not-found classID method)])))
  
  (define (methodID->methodName/slow client classID target-methodID)
    (let loop ([methods (query client (encode-referencetype-methods classID))])
      (match methods
             [(list (struct referencetype--methods (methodid name signature modbits)) tail ...)
              (if (methodid-equal? methodID target-methodID)
                  name
                  (loop tail))]
             [(list) (raise-not-found classID target-methodID)])))
  
  (define (get-linetable/slow client classid methodid)
    (match (query client (encode-method-linetable classid methodid))
           [(struct method--linetable (start-offset end-offset lines))
            (let* ([no->offset
                    (make-immutable-hash-table
                     (map (lambda (item) (cons (method--linetable--lines-linenumber item)
                                          (method--linetable--lines-linecodeindex item)))
                          lines))]
                   [offset->no
                    (make-immutable-hash-table
                     (map (lambda (item) (cons (method--linetable--lines-linecodeindex item)
                                          (method--linetable--lines-linenumber item)))
                          lines))]
                   [linenumbers (map method--linetable--lines-linenumber lines)]
                   [start-lineno (foldl min (first linenumbers) (rest linenumbers))]
                   [end-lineno (foldl max (first linenumbers) (rest linenumbers))])
              (make-linetable start-offset start-lineno end-lineno no->offset offset->no))]))
  
  (define (sort-variabletable variabletable)
    (make-method--variabletable
     (method--variabletable-argcnt variabletable)
     (mergesort 
      (method--variabletable-slots variabletable)
      (lambda (a b) (< (method--variabletable--slots-length a)
                  (method--variabletable--slots-length b))))))
  
  (define (get-variabletable/slow client classid methodid)
    (sort-variabletable (query client (encode-method-variabletable classid methodid))))
  
  (define (get-class-fields/slow client classid)
    (query client (encode-referencetype-fields classid)))
  
  (define (get-class-methods/slow client classid)
    (query client (encode-referencetype-methods classid)))
  
  (define (get-class-method/names client javaClassSig)
    (map
     (match-lambda 
      [(struct referencetype--methods (methodid name signature modbits)) name])
     (let ([classid (javaClassSig->classID client javaClassSig)])
       (get-class-methods client classid))))
  
  (define (get-superclass/slow client classid)
    (let ([result (query client (encode-classtype-superclass classid))])
      (if (referenceTypeID-null? result) false result)))
  
;;;;;;;;;;;;;;;;;;
  
  (define (javaClassSig->classID client javaClassSig)
    (call-memoize javaClassSig->classID/slow client javaClassSig))
  (define (classID->javaClassSig client classID)
    (call-memoize classID->javaClassSig/slow client classID))
  (define (methodName->methodID client classID method)
    (call-memoize methodName->methodID/slow client classID method))
  (define (methodID->methodName client classID target-methodID)
    (call-memoize methodID->methodName/slow client classID target-methodID))
  (define (get-linetable client classid methodid)
    (call-memoize get-linetable/slow client classid methodid))
  (define (get-variabletable client classid methodid)
    (call-memoize get-variabletable/slow client classid methodid))
  (define (get-class-fields client classid)
    (call-memoize get-class-fields/slow client classid))
  (define (get-class-methods client classid)
    (call-memoize get-class-methods/slow client classid))
  (define (get-superclass client classid)
    (call-memoize get-superclass/slow client classid))
  
;;;;;;;;;;;;;;;;;;
  
  (define (lineno->offset client classid methodid lineno)
    (match (get-linetable client classid methodid)
           [(struct linetable (start-offset start-lineno end-lineno no->offset offset->no))
            (let loop ([lineno lineno])
              (if (> lineno end-lineno) 
                  (raise-not-found classid methodid lineno)
                  (hash-get no->offset lineno (lambda () (loop (add1 lineno))))))]))
  
  (define (offset->lineno client classid methodid offset)
    (match (get-linetable client classid methodid)
           [(struct linetable (start-offset start-lineno end-lineno no->offset offset->no))
            (let loop ([offset offset])
              (if (< offset start-offset) 
                  (raise-not-found classid methodid offset)
                  (hash-get offset->no offset (lambda () (loop (- offset 1))))))]))
  
  (define (loc->locationID loc)
    (if (referenceTypeID? (location-clazz loc)) 
        (let* ([client (location-client loc)]
               [classid (location-clazz loc)]
               [methodid (location-method loc)]
               [offset (lineno->offset client classid methodid (location-line loc))])
          (make-locationID class-type-tag classid methodid offset))
        (let* ([client (location-client loc)]
               [classid (javaClassSig->classID client (location-clazz loc))]
               [methodid (methodName->methodID client classid (location-method loc))]
               [offset (lineno->offset client classid methodid (location-line loc))])
          (make-locationID class-type-tag classid methodid offset))))
  
  (define (dyn-loc->dyn-locationID dyn-loc)
    (let* ([client (location-client dyn-loc)]
           [classid (javaClassSig->classID client (location-clazz dyn-loc))]
           [methodid (methodName->methodID client classid (location-method dyn-loc))]
           [offset (lineno->offset client classid methodid (location-line dyn-loc))]
           [threadid (dyn-location-threadid dyn-loc)]
           [frameid (dyn-location-frameid dyn-loc)])
      (assert (client? client))
      (make-dyn-locationID class-type-tag classid methodid offset client threadid frameid)))
  
  (define (dyn-locationID->dyn-loc dyn-loc)
    (match dyn-loc
           [(struct dyn-locationID (type-tag classid methodid offset client threadid frameid))
            (let* ([clazz (classID->javaClassSig client classid)]
                   [method (methodID->methodName client classid methodid)]
                   [line (offset->lineno client classid methodid offset)])
              
              (make-dyn-location clazz method line client threadid frameid))]))
  
  (define (locationID->loc client locID)
    (let* ([classid (locationID-classid locID)]
           [methodid (locationID-methodid locID)]
           [clazz (classID->javaClassSig client classid)]
           [method (methodID->methodName client classid methodid)]
           [lineno (offset->lineno client classid methodid (locationID-offset locID))])
      (make-location clazz method lineno client)))
  
  (define (loc->dyn-loc loc threadid frameid)
    (match loc
           [(struct location (client clazz method line))
            (make-dyn-location clazz method line client threadid frameid)]))
  
  (define (locID->dyn-locID client locID threadid frameid)
    (assert (client? client))
    (match locID
           [(struct locationID (type-tag classid methodid offset))
            (make-dyn-locationID type-tag classid methodid offset client threadid frameid)]))
  
;;;;;;;;;;;;;;;;;;;
  
  (define (jref-local-variable sorted-variabletable dyn-locID name)
    (let ([offset (locationID-offset dyn-locID)])
      (ormap (match-lambda
              [(struct method--variabletable--slots
                       (codeindex entry-name signature length slot))
               (if (and (codeindex . <= . offset)
                        (offset . < . (+ codeindex length))
                        (equal? name entry-name))
                   (make-variable-jref (dyn-locationID-client dyn-locID)
                                       (dyn-locationID-threadid dyn-locID)
                                       (dyn-locationID-frameid dyn-locID)
                                       signature
                                       slot)
                   false)])
             (method--variabletable-slots sorted-variabletable))))
  
  (define (modbits-is-static? bits) (not (= 0 (bitwise-and bits access-static))))
  (define (modbits-is-public? bits) (not (= 0 ((bitwise-and bits access-public)))))
  (define (modbits-is-protected? bits) (not (= 0 (bitwise-and bits access-protected))))
  (define (modbits-is-private? bits) (not (= 0 (bitwise-and bits access-private))))
  
  (define (jref-non-inherited-class-member client classid name include-privates objectid-or-static)
    (let ([is-static (eq? objectid-or-static 'static)])
      (or
       (ormap 
        (match-lambda
         [(struct referencetype--fields (fieldid fname signature modbits))
          (if (and (equal? fname name)
                   (eq? is-static (modbits-is-static? modbits))
                   (or include-privates
                       (not (modbits-is-private? modbits))))
              (if is-static
                  (make-static-field-jref client classid fieldid)
                  (make-field-jref client objectid-or-static fieldid))
              false)])
        (get-class-fields client classid))
       (ormap
        (match-lambda
         [(struct referencetype--methods (methodid m-name signature modbits))
          (if (and (equal? m-name name)
                   (eq? is-static (modbits-is-static? modbits))
                   (or include-privates
                       (not (modbits-is-private? modbits))))
              (if is-static
                  (make-static-method-jref client classid methodid signature)
                  (make-method-jref client classid objectid-or-static methodid signature))
              false)])
        (get-class-methods client classid)))))
  
  (define (jref-class-member client classid name include-privates objectid-or-static)
    (or (jref-non-inherited-class-member client classid name include-privates objectid-or-static)
        (let ([super (get-superclass client classid)])
          (and super
               (jref-class-member client super name false objectid-or-static)))))
  
  (define (get-all-classes client)
    (query client (encode-virtualmachine-allclasses)))
  
  (define (jref-global-name client name)
    (with-handlers
        ([exn:not-found? 
          (lambda (exn) 
            (let ([r (regexp (format "^L~a/" (regexp-quote name)))])
              (ormap
               (match-lambda 
                [(struct virtualmachine--allclasses (reftypetag typeid signature status))
                 (and (regexp-match r signature)
                      (make-package-jref name))])
               (get-all-classes client))))])
      (make-class-jref (javaClassSig->classID client name))))
  
  (define (jval* client-or-dynloc name)
    (may-eval-jref (&jval* client-or-dynloc name)))
  
  (define (&jval* client-or-dynloc name)
    (if (dyn-locationID? client-or-dynloc)
        
        (match client-or-dynloc
               [(struct dyn-locationID (type-tag classid methodid offset client threadid frameid))
                (or (jref-local-variable (get-variabletable client (downcast-to-classid classid) methodid)
                                         client-or-dynloc
                                         name)
                    (jref-class-member client (downcast-to-classid classid) name true 'static)
                    (jval* client name))])
        
        (or (jref-global-name client-or-dynloc name)
            (raise-not-found name))))
  
  (define (wrap-vm-value client vm-val)
    (match vm-val
           [(struct tagged-value ((? tag-is-primitive?) val)) val]
           [(struct tagged-value (tag val)) (make-object-jref client val)]
           [(? objectID?) (make-object-jref client vm-val)]
           [(vector items ...) (list->vector (map (lambda (i) (wrap-vm-value client i)) items))]
           [_ (assert false "wrap-vm-value" vm-val)]))
  
  (define (eval-variable-jref val) 
    (match val
           [(struct variable-jref (client threadid frameid signature slot))
            (wrap-vm-value 
             client
             (first (query client (encode-stackframe-getvalues 
                                   threadid frameid (list (list slot (signature->type-tag signature)))))))]
           [_ (assert false "eval-variable-jref" val)]))
  
  (define (eval-field-jref val) 
    (match val
           [(struct field-jref (client objectid fieldid))
            (wrap-vm-value
             client
             (first (query client (encode-objectreference-getvalues
                                   objectid (list fieldid)))))]
           [_ (assert false "eval-field-jref" val)]))
  
  (define (may-eval-jref val)
    (match val
           [(or (struct object-jref (_ objectid))
                (struct variable-jref (_ _ _ _ _)) 
                (struct field-jref (_ _ _))
                (struct static-field-jref (_ _ _)))
            (eval-jref val)]
           [_ val]))
  
  (define (eval-jref val)
    (match val
           [(struct object-jref (_ objectid)) objectid]
           [(struct variable-jref (_ _ _ _ _)) (eval-variable-jref val)]
           [(struct field-jref (_ _ _)) (eval-field-jref val)]
           [(struct static-field-jref (_ _ _)) (eval-static-field-jref val)]
           [_ (assert false "eval-jref" val)]))
  
  (define (eval-static-field-jref val) 
    (match val
           [(struct static-field-jref (client classid fieldid))
            (wrap-vm-value
             client
             (first (query client (encode-referencetype-getvalues 
                                   classid (list fieldid)))))]
           [_ (assert false "eval-static-field-jref" val)]))
  
  (define (class-jdot val name)
    (assert (class-jref? val))
    (or
     (jref-class-member (jref-client val) (class-jref-classid val) name true 'static)
     (jref-class-member (jref-client val) (class-jref-classid val) name true false)))
  
  (define (object-jdot val name) 
    (match val
           [(struct object-jref (client objectid))
            (let ([classid 
                   (downcast-to-classid 
                    (objectreference--referencetype-typeid
                     (query client (encode-objectreference-referencetype objectid))))])
              (jref-class-member client classid name true objectid))]
           [_ (assert false "object-jdot" val name)]))
  
  (define (array-length client arr)
    (query client (encode-arrayreference-length arr)))
        
  (define (idx arr i)
    (match arr
           [(struct object-jref (client arr))
            (unless (< i (array-length client arr))
              (raise 'array-index-out-of-bounds))
            (wrap-vm-value client (vector-ref (query client (encode-arrayreference-getvalues arr i 1)) 0))]))
  
  (define (jdot* val name) (may-eval-jref (&jdot* val name)))
  
  (define (&jdot* val name)
    (match val
           [(or (struct variable-jref (_ _ _ _ _))
                (struct field-jref (_ _ _))
                (struct static-field-jref (_ _ _)))
            (object-jdot (eval-jref val) name)]
           [(struct object-jref (client (? arrayID? arr)))
            (assert (equal? name "length"))
            (array-length client arr)]
           [(struct object-jref (_ _))
            (object-jdot val name)]
           [(struct method-jref (client classid objectid methodid signature))
            (assert false val name)]
           [(struct static-method-jref (client classid methodid signature))
            (assert false val name)]
           [(struct class-jref (client classid))
            (class-jdot val name)]
           [(struct package-jref (client pname))
            (make-package-jref client (string-append name "/" (symbol->string pname)))]
           [_ (assert false "jdot" val name)]))
  
  (define (jcall* dynloc target-jref method . args)
    (let ([threadid (dyn-locationID-threadid dynloc)])
      (let-values ([(client tag result exn)
                    (match (jdot* target-jref method) 
                           [(struct method-jref (client classid objectid methodid signature))
                            (match
                             (query client
                                    (encode-objectreference-invokemethod
                                     objectid threadid classid methodid args 0))
                             [(struct objectreference--invokemethod ((struct tagged-value (tag return-val)) exception))
                              (values client tag return-val exception)])]
                                 
                           [(struct static-method-jref (client classid methodid signature))
                            (match
                             (query client (encode-classtype-invokemethod classid threadid methodid args 0))
                             [(struct classtype--invokemethod ((struct tagged-value (tag return-val)) exception))
                              (values client tag return-val exception)])])])
      
        (debug "A" tag result exn)
        (wrap-vm-value client (if (= tag 0) exn result)))))

  (provide make-class-jref
           make-location
           location?
           location-clazz
           location-method
           location-line
           location-client

           dyn-locationID
           dyn-locationID?
           dyn-locationID-client
           dyn-locationID-threadid
           dyn-locationID-frameid

           object-jref-objectid
           class-jref-classid

           loc->locationID
           idx
           jdot*
           &jdot*
           jval*
           &jval*
           jloc*
           jcall*
           (rename eval-jref v)

           linetable
           linetable?
           linetable-start-offset
           linetable-start-lineno
           linetable-end-lineno
           linetable-no->offset
           linetable-offset->no
           
           exn:not-found?
           vmClassSig->javaClassSig
           javaClassSig->vmClassSig
           javaClassSig->classID
           classID->javaClassSig
           methodName->methodID
           methodID->methodName
           lineno->offset
           offset->lineno
           locationID->loc
           locID->dyn-locID
           dyn-locationID->dyn-loc
           get-linetable
           get-class-method/names
           get-class-methods
           wrap-vm-value
           )

#;
  (provide/contract
   (struct location ((clazz string?) (method string?) (line number?) (client client?)))
   (struct (dyn-locationID locationID) ((client client?) (threadid threadID?) (frameid frameID?)))
   (struct linetable ((start-offset number?) (start-lineno number?) (end-lineno number?) 
                      (no->offset hash?) (offset->no hash?)))
                       
   (exn:not-found? (any? . -> . boolean?))
   (vmClassSig->javaClassSig (string? . -> . string?))
   (javaClassSig->vmClassSig (string? . -> . string?))
   (javaClassSig->classID (client? string? . -> . referenceTypeID?))
   (classID->javaClassSig (client? referenceTypeID? . -> . string?))
   (methodName->methodID (client? string? . -> . methodID?))
   (methodID->methodName (client? referenceTypeID? methodID? . -> . string?))
   (lineno->offset (client? referenceTypeID? methodID? number? . -> . number?))
   (offset->lineno (client? referenceTypeID? methodID? number? . -> . number?))
   (locationID->loc (client? locationID? . -> . location?))
   (locID->dyn-locID (client? locationID? threadid? frameid? . -> . dyn-locationID?))
   (dyn-locationID->dyn-loc (dyn-locationID? . -> . dyn-location?))
   (get-linetable (client? referenceTypeID? methodID? . -> . any))
   (struct jref ((client client?)))
   (get-class-method-names (client? string? . -> . (listof string?)))
   )
  
  )
  
 