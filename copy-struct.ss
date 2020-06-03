#|

SYNTAX

_copy-struct_
> (copy-struct STRUCT-NAME E_1 (ACCESSOR-NAME_i E_i) ...)

Makes a new copy the source structure given as the first expression, which must be an instance of 
the structure type named. If any accessor-name/expression pairs are provided, the resulting
structure will contain the values of those expressions for the appropriate fields rather than
the value in the corresponding field of the source structure.

This form always produces immediate instances of the named structure type, even when the
source structure is an instance of a subtype of the named structure type. 

|#
(module copy-struct mzscheme
  (require-for-syntax (lib "match.ss"))

  (provide copy-struct)

  (define-syntax (copy-struct stx)
    (syntax-case stx ()
      [(_ info structure (accessor-name new-val) ...)
     
       (unless (and (identifier? #'info)
                    (let ((q (gensym)))
                      (not (eq? q (syntax-local-value #'info (lambda () q))))))
         (raise-syntax-error #f "Not a valid structure identifier" stx #'info))
     
                                        ; new-binding-for : syntax[field-name] -> (union syntax[expression] #f)
       (let ((new-binding-for 
              (lambda (f)
                (ormap (lambda (x) 
                         (if (eq? (syntax-object->datum (car (syntax-e x))) (syntax-object->datum f)) 
                             (cadr (syntax-e x)) 
                             #f))
                       (syntax-e #'((accessor-name new-val) ...))))))
       
         (match-let ([(_ construct pred accessors _ _) (syntax-local-value #'info)])
         
                                        ; detect various errors
                    (when (or (not construct) (not pred) (ormap (lambda (x) (eq? x #f)) accessors))
                      (raise-syntax-error #f "Current context has too little information about structure type " stx #'info))
         
                    (for-each 
                     (lambda (field)
                       (unless (ormap (lambda (f2) (eq? (syntax-object->datum f2) (syntax-object->datum field))) accessors)
                         (raise-syntax-error #f "Not a valid field name" stx field)))
                     (syntax-e #'(accessor-name ...)))
         
                    (let ((dupe (check-duplicate-identifier (syntax-e #'(accessor-name ...)))))
                      (when dupe (raise-syntax-error #f "Duplicate field assignment" stx dupe)))
         
                                        ; the actual result
                    #`(let ((the-struct structure))
                        (if (#,pred the-struct)
                            (#,construct
                             #,@(map 
                                 (lambda (field) (or (new-binding-for field) #`(#,field the-struct)))
                                 (reverse accessors)))
                            (raise-mismatch-error '_ 
                                                  #,(format "Incorrect structure type (not a ~a structure): " 
                                                            (syntax-object->datum #'info))
                                                  the-struct)))))]))

  
  
  ;; ============================================================
  ;; TESTS
  (define (test)
    (define-struct test (a b c) (make-inspector))
    (define-struct toast (b c d))
    
    (let ((x (make-test 1 2 3)))
      (equal? (copy-struct test x) x))
    
    (let ((x (make-test 1 2 3)))
      (not (eq? (copy-struct test x) x)))
    
    (let ((x (copy-struct test (make-test 1 2 3))))
      (and (= (test-a x) 1)
           (= (test-b x) 2)
           (= (test-c x) 3)))
    (let ((x (copy-struct test (make-test 1 2 3) (test-a 'hello))))
      (and (eq? (test-a x) 'hello)
           (eq? (test-b x) 2)
           (eq? (test-c x) 3)))
    (with-handlers ([exn:syntax? (lambda (e) #t)])
      (expand #'(copy-struct test (make-test 1 2 3) (test-z 'q)))
      #f)
    (with-handlers ([exn:syntax? (lambda (e) #t)])
      (expand #'(copy-struct test (make-test 1 2 3) (test-a 1) (test-a 2)))
      #f)
    (let ((get test-a)
          (test-a 8))
      (let ((x (copy-struct test (make-test 1 2 3) (test-a 'yay))))
        (and
         (eq? (get x) 'yay)
         (eq? (test-b x) 2)
         (eq? (test-c x) 3))))
    (with-handlers ([exn:application:mismatch? (lambda (e) #t)])
      (copy-struct test (make-toast 1 2 3) (test-a 4))
      #f)
    (let ((x (make-test 1 2 3)))
      (let ((y (copy-struct test x)))
        (set-test-a! y 'yay)
        (eq? (test-a x) 1)))
    
    (let ()
     (define-struct super (a b))
     (define-struct (sub super) (c d))
     (let ((x (copy-struct sub (make-sub 1 2 3 4) (super-a 'yay))))
       (and 
        (eq? (super-a x) 'yay)
        (eq? (super-b x) 2)
        (eq? (sub-c x) 3)
        (eq? (sub-d x) 4)))
     (let ((x (copy-struct super (make-sub 1 2 3 4)))) (not (sub? x)))))

  ;; (test)
  )