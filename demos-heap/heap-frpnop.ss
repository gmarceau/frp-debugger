(require (lib "etc.ss"))
(require (lib "match.ss"))
;;(require (lib "animation.ss" "frtime"))
(require "../jdb.ss")
(read-case-sensitive true)

(define-connect-vm c "localhost" 8002)

(define heap (jclass c Heap))

(define pushed 
  (trace ((heap . jdot . add) . jloc . entry)
         (jlambda () () false)))

(define poped
  (trace ((heap . jdot . extractMin) . jloc . exit)
         (jlambda () () false)))

(define exit-test
  (map-e
   (match-lambda [('vmdeath 0) 
                  (exit)] [_ false])
   (client-unrequested-events c)))

(set-trigger! true)
(yield (make-semaphore))

