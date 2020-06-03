(require (lib "etc.ss"))
(require (lib "match.ss"))
;;(require (lib "animation.ss" "frtime"))
(require "../jdb.ss")
(read-case-sensitive true)

;(define-connect-vm c "localhost" 8002)
(define-start-vm c "MinHeap")

(list 'Heap
      (collect-b (changes (or (catcher-exn-b (jclass c Heap))
                              (catcher-val-b (jclass c Heap))))
                 empty cons))
      

;(current-recorder (create-recorder))

(define heap (jclass c Heap))

(define pushed 
  (trace ((heap . jdot . add) . jloc . entry)
         (jlambda () () 'push)))

(define poped
  (trace ((heap . jdot . extractMin) . jloc . exit)
         (jlambda (stack) (result) (result . jdot . weight))))
  
(define violations
  (collect-b
   (filter-e
    (match-lambda 
     [('push _) false]
     [(_ 'push) false]
     [(previous current) (> previous current)])
    (history-e (merge-e pushed poped) 2))
   empty cons))

(list 'client c)
(list 'violation violations)
(list 'pushes (count-e pushed))
(list 'pops (count-e poped))
;(set-trigger! (and (empty? violations)))
;                   (not (so-many-seconds-have-passed 100000))))
#;
(define exit-test
  (map-e
   (match-lambda [('vmdeath 0) (exit)] [_ false])
   (client-unrequested-events c)))

(set-trigger! ((count-e pushed) . < . 10))
;(yield (make-semaphore))

