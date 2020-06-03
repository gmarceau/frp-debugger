(require "../jdb.ss")
(require (lib "animation.ss" "frtime"))
(require (lib "1.ss" "srfi"))
(read-case-sensitive true)
;(define-connect-vm c "localhost" 8002)
(define-start-vm c "Sorter" 5 200)
(define sorter (jclass c Sorter$WorkerThread))
(monitor c)
(define colors '("blue" "black" "red" "green" "yellow" "orange"))

(define work-e
  (trace ((sorter . jdot . processWork) . jloc . 43)
         (jlambda () (this work) 
                  (list (this . jdot . id)
                        (work . jdot . l)
                        (work . jdot . r)))))

(define model-e
  (collect-e
   work-e
   empty
   (match-lambda* 
       [((id left right) model)
        (let ([clr (list-ref colors (modulo id (length colors)))])
          (cons 
           (list id left right clr)
           (filter
            (lambda (t) (not (= id (first t))))
            model)))])))

(define model (hold empty model-e))

(define v-scale (new-cell 5))

(define rectangle-e
  (map-e
   (lambda (m)
     (map
      (match-lambda
          [(_ left right clr)
           (make-rect (make-posn (* (get-value v-scale) left) 50) 
                      (* (get-value v-scale) (- right left)) 10 clr)])
      m))
   model-e))

(define max-length (new-cell 20))

(define translate-rect
  (match-lambda*
   [(($ rect ul w h clr) dx dy)
    (make-rect (posn+ ul (make-posn dx dy))
               w h clr)]))

(define viz
  (collect-b
   rectangle-e
   empty
   (lambda (rects history)
     (let* ([truncated
             (if (>= (length history) (get-value max-length))
                 (rest history)
                 history)]
            [lower (map 
                    (lambda (model) (map (lambda (rect) (translate-rect rect 0 10)) model))
                    truncated)])
       (append lower (list rects))))))

(display-shapes (apply append viz))

(monitor (catcher-exn-b (apply append viz)))

(define (count-e e) (accum-b (e . -=> . add1) 0))

(list 'model (length model) model)
(list 'count (count-e work-e))
(resume)
