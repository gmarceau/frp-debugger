(require "../jdb.ss")
(require (lib "animation.ss" "frtime"))
;(require (lib "1.ss" "srfi"))
(read-case-sensitive true)
(define-connect-vm c "localhost" 8002)
(define tsp (jclass c Tsp))

(define (last-n n lst)
  (if (>= n (length lst))
      lst
      (last-n n (rest lst))))

(define (take n lst)
  (if ((zero? n) . or . (empty? lst))
      empty
      (cons (first lst) (take (sub1 n) (rest lst)))))

(define coords-e
  (trace ((tsp . jdot . main) . jloc . 164)
         (jlambda () (x y)
                  (make-posn x y))))

(define-values (min-x max-x min-y max-y)
  (values
   (accum-b (coords-e . ==> . (lambda (p) (lambda (x) (min x (posn-x p))))) 10000)
   (accum-b (coords-e . ==> . (lambda (p) (lambda (x) (max x (posn-x p))))) -10000)
   (accum-b (coords-e . ==> . (lambda (p) (lambda (y) (min y (posn-y p))))) 10000)
   (accum-b (coords-e . ==> . (lambda (p) (lambda (y) (max y (posn-y p))))) -10000)))

(define coords
  (collect-b
   coords-e
   empty
   (lambda (a d) (append d (list a)))))

(define explore-e
  (trace ((tsp . jdot . bnb) . jloc . 101)
         (jlambda () (nVertices v)
                  (lambda (path) (cons v (last-n (sub1 nVertices) path))))))

(define path-done-e
  (trace ((tsp . jdot . bnb) . jloc . 103)
         (jlambda () (lastNode)
                  (lambda (path) (cons (first (last-pair path)) (cons lastNode path))))))

(define vertices-b
  (accum-b (merge-e explore-e path-done-e) empty))

#|
(define start-tree-e
  (trace ((tsp . jdot . mst) . jloc . 65)
         (jlambda () ()
                  (lambda (_) empty))))

(define tree-edge-e
  (trace ((tsp . jdot . mst) . jloc . 74)
         (jlambda () (e)
                  (lambda (prev)
                    (cons
                     (list (e . jdot . v1)
                           (e . jdot . v2))
                     prev)))))

(define tree-done-e
  (trace ((tsp . jdot . mst) . jloc . 68)
         (jlambda () () false)))

(define tree
  (accum-b (merge-e start-tree-e tree-edge-e) empty))
|#

(define tree empty)

(define-values (width height margin)
  (values 800 600 50))

(fresh-anim)
(fresh-anim (+ width (* 2 margin)) (+ height (* 2 margin)) "TSP")

(define scale
  (max (- max-x min-x)
       (- max-y min-y)))

(define (->screen p)
  (make-posn (+ margin (/ (* width (- (posn-x p) min-x)) scale))
             (+ margin (/ (* height (- (posn-y p) min-y)) scale))))

(define show-tree?
  (accum-b ((key #\t) . -=> . not) false))
  
(define shapes
  (append (map (lambda (p) (make-circle (->screen p) 2 "blue")) coords)
          (if show-tree?
              (map (lambda (e) (make-line (->screen (list-ref coords (first e)))
                                          (->screen (list-ref coords (second e))) "gray")) tree)
              empty)
          (map (lambda (p1 p2) (make-line (->screen (list-ref coords p1))
                                          (->screen (list-ref coords p2)) "purple"))
               vertices-b (rest vertices-b))))

#|
(build-list
                   n
                   (lambda (i)
                     (cons (xcoords . idx . i)
                           (ycoords . idx . i))))
|#                

(display-shapes shapes)

;vertices-b

;coords

;min-x max-x min-y max-y

(resume)

(set-trigger! (hold true (merge-e (path-done-e . -=> . false) (key-strokes . -=> . true))))

#|
(define work-e
  (trace ((tsp . jdot . bnb) . jloc . 97)
         (jlambda () (vertices nVertices) 
                  (list vertices nVertices))))

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

(define v-scale (new-cell 1))

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
|#
