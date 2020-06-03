(module util mzscheme
  (require (lib "list.ss")
           (lib "etc.ss")
           "base-gm.ss"
           )
  (provide (all-defined))
  
  (define (assert-all-symbol orig stx)
    (for-each
     (lambda (b) (unless (symbol? (syntax-e b))
              (raise-syntax-error false "expected an identifier for the binding" orig stx)))
     (syntax->list stx))))
  
