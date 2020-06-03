(module mangle3 mzscheme
  (require-for-syntax "mangle2.ss")

  (provide (all-defined))

  (define-syntax (define-jdwp stx)
    (do-define-jdwp stx)))