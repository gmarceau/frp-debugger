(require (lib "etc.ss"))
(require (lib "match.ss"))
(require "../jdb.ss")

(define (not-in-order e)
  (filter-e
   (match-lambda 
     [('reset _) false]
     [(_ 'reset) false]
     [(previous current) (> previous current)])
   (history-e e 2)))

(define c (start-vm "DijkstraTest"))
(define queue (jclass c PriorityQueue))

(define inserts
  (trace ((queue . jdot . add) . jloc . entry)
         (bind (item) (item . jdot . weight))))
(define removes
  (trace ((queue . jdot . extractMin) . jloc . exit)
         (bind (result) (result . jdot . weight))))

(define violation
  (hold false (not-in-order
               (merge-e removes (inserts . -=> . 'reset)))))

(list 'violation violation)
(monitor 'violation violation)
(set-trigger! c (not violation))
