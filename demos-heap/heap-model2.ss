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

(define (insert-in-model item)
  (lambda (model)
    (let loop ([model model])
      (cond [(empty? model) (list item)]
            [(< item (first model)) (cons item model)]
            [else (cons (first model) (loop (rest model)))]))))

(define (remove-from-model item)
  (lambda (model)
    (let loop ([model model])
      (cond [(empty? model) empty]
            [(equal? item (first model)) (rest model)]
            [else (cons (first model) (loop (rest model)))]))))

(define (convert-queue-to-list q)
  (map (lambda (node) (node . jdot . weight))
       (v (q . jdot . data))))
  
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
(wait c)
(sleep 1)

(define inserters
  (inserts . ==> . (lambda (v) (insert-in-model v))))
(define removers
  (removes . ==> . (lambda (v) (remove-from-model v))))

(define model-changes
  (accum-e (merge-e inserters removers) 
           (convert-queue-to-list (here . jval . q))))


(define model (hold false model-changes))
(list 'model model)
(monitor 'model model)
