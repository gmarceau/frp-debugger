(module jdi-test-profile (lib "animation.ss" "frtime")

  (require "../jdb.ss")

  (define client (start-vm "Foobar" 10))
  
  (define foobar-class (jclass client Foobarr))
  
  (define spin-method (foobar-class . jdot . spin))
  
  (define trace-data (size&time-trace true spin-method))
  
  (monitor "trace-data:" trace-data)
  
  (display-shapes
   (collect-b
    (trace-data
     . ==> .
     (match-lambda 
         [(size time)
          (make-circle
           (make-posn (* size 30) (- 400 (/ time 5)))
           5 "blue")]))
     empty cons))

  (define run
    (let ([start (current-seconds)])
      ((seconds . - . start) . < . 3)))
  
  (set-cell! (client-run-trigger client) run)
  (provide (all-defined))
  )
(require jdi-test-profile)
(require "../jdi.ss")
(require "../jdi-symbol-table.ss")
(define stack (find-stack-of-main-thread (hold false (client-stop-locs client))))
(define desired-stack-pos (new-cell 0))
(define effective-stack-pos (min desired-stack-pos (sub1 (length stack))))
(define here (list-ref stack effective-stack-pos))
(define (up) (set-cell! desired-stack-pos (add1 (get-value effective-stack-pos))))
(define (down) (set-cell! desired-stack-pos (sub1 (get-value effective-stack-pos))))

         
  
  