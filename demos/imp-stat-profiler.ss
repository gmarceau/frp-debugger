
(require (lib "match.ss"))
(require "../jdb.ss")
(require "../base-gm.ss")

(define c (start-vm "Foobar" 100))

(define (client-has-exited? c) false)

(define profile (make-hash))
(define (update-profile! location)
  (printf "> ~a~n" location))

(let loop ()
  (set-running! c true)  
  (sleep 1)
  (set-running! c false)
  (if (client-has-exited? c)
      (hash-keys profile)
      (begin (update-profile! (get-value here)) 
             (loop))))
