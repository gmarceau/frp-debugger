#|
real    3m3.530s
user    0m0.130s
sys     0m0.050s
|#

(require (lib "etc.ss"))
(require "../jdb.ss")
(read-case-sensitive true)

(define (kill) (custodian-shutdown-all (current-custodian)))

(define (insert item lst fn)
  (cond [(empty? lst) (list item)]
        [(fn item (first lst)) (cons item lst)]
        [else (cons (first lst) (insert item (rest lst) fn))]))

(define (remove item lst)
  (cond [(empty? lst) empty]
        [(equal? item (first lst)) (rest lst)]
        [else (cons (first lst) (remove item (rest lst)))]))


(define-connect-vm c "localhost" 8002)

(define heap (jclass c Heap))

(define pushed 
  (trace ((heap . jdot . add) . jloc . entry)
         (jlambda () (item) (item . jdot . weight))))

(define poped
  (trace ((heap . jdot . extractMin) . jloc . exit)
         (jlambda () (result) (result . jdot . weight))))

(define violation-e (event-receiver))

(define model-changes
  (accum-e 
   (merge-e
    (pushed
     . ==> . 
     (lambda (pushed) 
       (lambda (model) (insert pushed model <))))
    
    (poped
     . ==> .
     (lambda (poped)
       (lambda (model) 
         (if (not (= poped (first model)))
             (emit ([violation-e (list poped model)])
                   (remove poped model))
             (rest model))))))
   empty))

(define model (hold false model-changes))
(define violations (collect-b violation-e empty cons))

;(list 'model model))
(monitor (list 'violations violations))
;(set-trigger! (empty? violations))
;(list 'trigger trigger))
(monitor (client-unrequested-events c))
(define exit-test
  (map-e
   (match-lambda [('vmdeath 0) (exit)] [_ _])
   (client-unrequested-events c)))

(set-trigger! true)
(yield (make-semaphore))
