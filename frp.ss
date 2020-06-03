; To do:
; generalize and improve notion of time
;  (e.g., combine seconds & milliseconds,
;  give user general "timer : number -> signal (event?)"
;  'loose' timers that don't exactly measure real time
;   (e.g., during garbage-collection)
; completely restructure:
;  eliminate alarms, give processes timeouts
;  make special constructor signals (?)
;   (have tried and achieved unencouraging results)
;  separate signal and event structures (?)
;    - could make event a substructure of signal,
;      but this could be problematic for letrec
;    - better option seems to be explicit tag
; partial-order based evaluation:
;  - add a 'depth' field to signal structure (DONE)
;  - make 'register' responsible for maintaining consistency
;  - 'switch' can result in cycle, in which case consistent
;    depths cannot be assigned
;  - should perhaps tag delay, integral nodes
; selective evaluation (?)
; replace #%app macro with #%top macro, define macros,
;   hash-table; make signals applicable as functions
;   (have tried and achieved unencouraging results)
; remove #%app, lambda, and define macros; lift all
;   primitives, redefine higher-order procedures
;   macro to automate definition of lifted primitives
;   make signals directly applicable
; consider adding placeholders again, this time as part
;   of the FRP system
;   (probably not necessary, since signals can serve
;    in this role)
; consider whether any other syntax should be translated
;   (e.g. 'begin')
; consider 'strict structure'
;
; Done:
; mutual dependencies between signals (sort of ...)
; fix delay bug
; allow delay to take a time signal (sort of ...)
; events:
;   use signal structs where value is tail of stream
;   interface with other libraries (e.g. graphics), other threads
;   hold : event * val -> signal
;   changes : signal -> event
;   map-e : event[a] * (a -> b) -> event[b]
;   merge-e : event[a1] * event[a2] * ... -> event[a1 U a2 U ...]
;   filter-e : event[a] * (a -> bool) -> event[a]
;   accum : event[a] * b * (a -> b -> b) -> event[b]
; modify graphics library to send messages for events
; signal manager's priority queue should
;   - maintain weak boxes
;   - check stale flag before enqueuing for update
; delete dead weak references
; fix letrec-b macro to use switch
; - allow fn signals
; eliminate letrec-b, make appropriate letrec macro
;  ('undefined' value) (probably)
; rewrite lift
; - provide specialized lift for 0-3 (?) arguments
; fix subtle concurrency issue between
;  signal creation outside manager thread
;  and activities of manager, particularly
;  involving registration/deregistration
;  (solution: send reg/unreg requests to manager if necessary)
; make separate library for graphics
;

(module frp mzscheme
  
  (require (lib "list.ss")
           (lib "etc.ss")
           (lib "class.ss")
           (all-except (lib "mred.ss" "mred") send-event)
           (lib "string.ss")
           "erl.ss"
           (lib "pretty.ss")
           (lib "errortrace.ss" "errortrace")
           (lib "match.ss")
           "heap.ss")

  (define verbose-manager false)
  (define verbose-lift false)
  
  ;; also models events, where 'value' is all the events that
  ;; haven't yet occurred (more specifically, an event-cons cell whose
  ;; tail is *undefined*)
  (define-struct signal (value parents dependents catcher? stale? thunk depth) (make-inspector))
  (define-struct event-cons (head tail) (make-inspector))
  
  (define econs make-event-cons)
  (define efirst event-cons-head)
  (define erest event-cons-tail)
  (define econs? event-cons?)
  (define set-efirst! set-event-cons-head!)
  (define set-erest! set-event-cons-tail!)
  
  (define (event-source? v)
    (and (signal? v) (econs? (signal-value v))))
  
  (define (behavior? v)
    (and (signal? v) (not (econs? (signal-value v)))))
  
  (define-struct raised-exn (data))
  
  (define (safe-signal-depth v)
    (if (signal? v)
        (signal-depth v)
        0))
  
  (define (safe-eval catcher? thunk parents . args)
    (define (eval)
      (with-handlers ([(lambda (exn) #t) 
                       (lambda (exn) (make-raised-exn exn))])
        (apply thunk args)))
    (if catcher?
        (eval)
        (or (ormap get-exn-value parents)
            (eval))))
  
  (define (safe-eval-signal beh . args)
    (apply safe-eval
           (signal-catcher? beh)
           (signal-thunk beh)
           (signal-parents beh)
           args))
  
  (define (set-beh-parents&register! beh new-parents)
    (for-each
     (lambda (p)
       (when (not (member p new-parents))
         (unregister beh p)))
     (signal-parents beh))
    (for-each
     (lambda (p)
       (when (not (member p (signal-parents beh)))
         (register beh p)))
     new-parents)
    (set-signal-parents! beh new-parents))
  
  (define (proc->signal catcher? thunk . parents)
    (let* ([beh-parents (filter signal? parents)]
           [beh (make-signal undefined beh-parents
                               empty catcher? #f thunk
                               (add1 (apply max 0 (map signal-depth beh-parents))))])
      (register beh beh-parents)
      (set-signal-value! beh (safe-eval-signal beh))
      beh))
  
                                        ; messages for signal manager; we now ensure that
                                        ; only the manager manipulates the dependency graph
  (define-struct reg (inf sup ret) (make-inspector))
  (define-struct unreg (inf sup) (make-inspector))
  
                                        ; an external event; val is passed to recip's thunk
  (define-struct event (val recip) (make-inspector))
  (define-struct sync-event (val recip ret) (make-inspector))
                                        ; update the given signal at the given time
  (define-struct alarm (time signal))
  
  (define-values (struct:signal-proc
                  make-signal-proc
                  signal-proc?
                  bp-ref
                  bp-set!)
    (make-struct-type 'signal-proc #f 1 0 #f null #f 0))
  
  (define-syntax frp:lambda
    (syntax-rules ()
      [(_ formals expr ...) (make-signal-proc
                             (lambda formals expr ...))]))
  
  (define-syntax frp:case-lambda
    (syntax-rules ()
      [(_ (formals expr ...) ...) (make-signal-proc
                                   (case-lambda (formals expr ...) ...))]))
  
  (define-syntax frp:define
    (syntax-rules ()
      [(_ (fn . args) expr ...) (define fn
                                  (frp:lambda args expr ...))]
      [(_ var expr ...) (define var expr ...)]))
  ;;(set-cell! var (begin expr ...)))]))
  
  
  (define switch-helper 
    (frp:lambda (init)
                (let ([cur-beh init])
                  (rec ret (proc->signal
                            #f
                            (case-lambda 
                              [() (get-value cur-beh)]
                              [(new-beh)
                               (set! cur-beh new-beh)
                               (set-beh-parents&register! ret (list cur-beh))
                               (get-value cur-beh)])
                            cur-beh)))))
  
  
  ;; switch : signal[a] event[signal[a]] -> signal[a]
  (define switch
    (frp:lambda (init e)
                (let ([s (switch-helper init)]
                      [cur-e (signal-value e)])
                  (proc->signal
                   #t
                   (lambda () 
                     (cond [(get-exn-value e)
                            (get-exn-value e)]
                           [(not (eq? cur-e (signal-value e)))
                            (update s (efirst (signal-value e)))
                            (set! cur-e (signal-value e))])
                     (get-value s))
                   s e))))
  
  (define (frp:if-helper test if-fun)
    (if (signal? test)
        (switch
         (if-fun (get-value test))
         ((changes test) . ==> . if-fun))
        (if-fun test)))
  
  (define-syntax frp:if
    (syntax-rules ()
      [(_ test then) (frp:if-helper test
                                    (lambda (b)
                                      (if b
                                          then
                                          (void))))]
      [(_ test then else) (frp:if-helper test
                                         (lambda (b)
                                           (if b
                                               then
                                               else)))]))
  (define-syntax frp:cond
    (syntax-rules (else =>)
      [(_ [else result1 result2 ...])
       (begin result1 result2 ...)]
      [(_ [test => result])
       (let ([temp test])
         (frp:if temp (result temp)))]
      [(_ [test => result] clause1 clause2 ...)
       (let ([temp test])
         (frp:if temp
                 (result temp)
                 (frp:cond clause1 clause2 ...)))]
      [(_ [test]) test]
      [(_ [test] clause1 clause2 ...)
       (let ((temp test))
         (frp:if temp
                 temp
                 (frp:cond clause1 clause2 ...)))]
      [(_ [test result1 result2 ...])
       (frp:if test (begin result1 result2 ...))]
      [(_ [test result1 result2 ...]
          clause1 clause2 ...)
       (frp:if test
               (begin result1 result2 ...)
               (frp:cond clause1 clause2 ...))]))
  
  (define-syntax frp:and
    (syntax-rules ()
      [(_) true]
      [(_ exp) exp]
      [(_ exp exps ...) (frp:if exp
                                (frp:and exps ...)
                                false)]))
  
  (define-syntax frp:or
    (syntax-rules ()
      [(_) false]
      [(_ exp) exp]
      [(_ exp exps ...) (let ([v exp])
                          (frp:if v
                                  v
                                  (frp:or exps ...)))]))
  
  ;; get-value : signal[a] -> a
  (define get-value
    (frp:lambda (val)
                (cond [(event-source? val) (error "event-sources do not have a current value")]
                      [(not (signal? val)) val]
                      [else (signal-value val)])))

  (define get-exn-value
    (frp:lambda (val)
                (cond [(event-source? val) false]
                      [(raised-exn? (get-value val))
                       (get-value val)]
                      [else false])))
  
  ;; *** will have to change significantly to support depth-guided recomputation ***
  ;; Basically, I'll have to check that I'm not introducing a cycle.
  ;; If there is no cycle, then I simply ensure that inf's depth is at least one more than
  ;; sup's.  If this requires an increase to inf's depth, then I need to propagate the
  ;; new depth to inf's dependents.  Since there are no cycles, this step is guaranteed to
  ;; terminate.  When checking for cycles, I should of course stop when I detect a pre-existing
  ;; cycle.
  ;; If there is a cycle, then 'inf' has (and retains) a lower depth than 'sup' (?), which
  ;; indicates the cycle.  Importantly, 'propagate' uses the external message queue whenever
  ;; a dependency crosses an inversion of depth.

  (define register
    (frp:lambda (inf sup)
                (if (eq? (self) man)
                    (match sup
                           [(and (? signal?)
                                 (= signal-dependents dependents))
                            (set-signal-dependents!
                             sup
                             (cons (make-weak-box inf) dependents))]
                           [(? list?) (for-each (lambda (sup1) (register inf sup1)) sup)]
                           [_ (void)])
                    (begin
                      (! man (make-reg inf sup (self)))
                      (receive [(? (lambda (v) (eq? v man))) (void)])))
                inf))

  (define (remove-by p l)
    (match l
           [() empty]
           [(a . d) (if (p a)
                        (remove-by p d)
                        (cons a (remove-by p d)))]))
  
  (define unregister
    (frp:lambda (inf sup)
                (if (eq? (self) man)
                    (match sup
                           [(and (? signal?)
                                 (= signal-dependents dependents))
                            (set-signal-dependents!
                             sup
                             (remove-by (lambda (a)
                                          (let ([v (weak-box-value a)])
                                            (or (eq? v inf)
                                                (eq? v #f))))
                                        dependents))]
                           [_ (void)])
                    (! man (make-unreg inf sup)))))
  
  (define-struct *undefined* ())
  (define undefined (make-*undefined*))
  ;;(string->uninterned-symbol "*undefined*"))
  (define (undefined? x)
    (eq? x undefined))
  
  ;; could use special treatment for constructors
  ;; to avoid making lots of garbage (?)
  (define create-thunk
    (frp:case-lambda
     [(fn) fn]
     [(fn arg1) (lambda () (fn (get-value arg1)))]
     [(fn arg1 arg2) (lambda () (fn (get-value arg1) (get-value arg2)))]
     [(fn arg1 arg2 arg3) (lambda () (fn (get-value arg1)
                                    (get-value arg2)
                                    (get-value arg3)))]
     [(fn . args) (lambda () (apply fn (map get-value args)))]))
  
  (define lift/v
    (frp:lambda (sym fn . args)
                (when verbose-lift (printf "lift      ~a : ~a ~a\n" sym fn args))
                (apply lift fn args)))
  
  (define lift
    (frp:lambda (fn . args)
                (print-struct true)
                ;;(when verbose-lift (printf "lift      ~a ~a\n" fn args))
                (cond
                 
                 [(behavior? fn)
                  ;; The callee function can change over time:
                  (when verbose-lift (printf "lift b-fn ~a ~a\n" fn args))
                  (unregister #f fn)    ; clear out stale dependencies from previous apps
                  (let* ([cur-fn (get-value fn)]
                         [cur-app (safe-eval #f (lambda () (apply lift cur-fn args)) args)]
                         [ret (proc->signal #f void fn cur-app)]
                         [eval-fn (lambda ()
                                    (when (not (eq? cur-fn (get-value fn)))
                                      (set! cur-fn (get-value fn))
                                      (set! cur-app (safe-eval #f (lambda () (apply lift cur-fn args)) args))
                                      (set-beh-parents&register! ret (list fn cur-app)))
                                    (get-value cur-app))])
                    (set-signal-thunk! ret eval-fn)
                    (set-signal-value! ret (safe-eval #f eval-fn (list fn cur-app)))
                    ret)]
                 
                 [(signal-proc? fn)
                  ;; Frp-graph constructor proc:
                  (when verbose-lift (printf "lift proc  ~a ~a\n" fn args))
                  (apply fn args)]

                 ;; --- Primitive function ---

                 ;; ;; Constant primitive with constant raised-exn:
                 [(ormap raised-exn? args)
                  (first (filter raised-exn? args))]

                 [(and (ormap behavior? args)
                       (not (member fn signal-consumers)))
                  ;; Primitive function with some time-varying arguments:
                  (when verbose-lift (printf "lift prim  ~a ~a\n" fn args))
                  (let* ([thunk (apply create-thunk fn args)])
                    (apply
                     proc->signal
                     #f
                     thunk
                     args))]
                 #;
                 ;; TODO : This would make things lighter:
                 [(and (signal-proc? fn)
                       (andmap (lambda (b) (not (signal? args))) args))
                  ;; Frp-graph constructor proc with constant arguments:
                  (when verbose-lift (printf "lift cons-proc  ~a ~a\n" fn args))
                  (let ([beh (apply fn args)])
                    (if (not (heap-contains alarms beh))
                        (get-value beh)
                        beh))]

                 [else
                  ;; Constant primitive with constant arguments:
                  (when verbose-lift (printf "lift cons-prim ~a ~a\n" fn args))
                  (safe-eval #f (lambda () (apply fn args)) args)])))
  
  (define (last)
    (let ([prev #f])
      (lambda (v)
        (let ([ret (if prev prev v)])
          (set! prev v)
          ret))))
  
  (define (extract k evs)
    (if (cons? evs)
        (let ([ev (first evs)])
          (if (or (eq? ev undefined) (undefined? (erest ev)))
              (extract k (rest evs))
              (begin
                (let ([val (efirst (erest ev))])
                  (set-first! evs (erest ev))
                  (k val)))))))
  
  ;; until : behavior behavior -> behavior
  (frp:define (b1 . until . b2)
              (proc->signal
               #f
               (lambda () (if (or (undefined? (get-value b2))
                             (not (get-value b2))) ;; FIXED : I'm not sure how 'until' should behave
                         (get-value b1)
                         (get-value b2)))
               ;; deps
               b1 b2))
  
  (define (fix-streams streams args)
    (if (empty? streams)
        empty
        (cons
         (if (undefined? (first streams))
             (let ([stream (signal-value (first args))])
               (if (undefined? stream)
                   stream
                   (if (equal? stream (econs undefined undefined))
                       stream
                       (econs undefined stream))))
             (first streams))
         (fix-streams (rest streams) (rest args)))))

  (define event-filter* 
    (frp:lambda 
     (catcher? fn deps)
     (let* ([out (econs undefined undefined)]
            [emit (lambda (val)
                    (set-erest! out (econs val undefined))
                    (set! out (erest out)))]
            [streams (map (lambda (d) (if (signal? d) (signal-value d) d)) deps)]
            [thunk (lambda ()
                     (let ([exn (ormap 
                                 (lambda (v) (and (raised-exn? v) v))
                                 streams)])
                       (if exn 
                           (fn emit exn)
                           (begin
                             (when (ormap undefined? streams)
                               (printf "had an undefined stream~n")
                               (set! streams (fix-streams streams deps)))
                             (let loop ()
                               (extract (lambda (the-event) (fn emit the-event) (loop))
                                        streams)))))
                     out)])
       (apply proc->signal catcher? thunk deps))))
    
  (define-syntax (event-filter stx)
    (syntax-case stx ()
      [(src-event-filter proc dep ...)
       (with-syntax ([emit (datum->syntax-object (syntax src-event-filter) 'emit)]
                     [the-event (datum->syntax-object (syntax src-event-filter) 'the-event)])
       #'(event-filter* #f (lambda (emit the-event) proc) (list dep ...)))]))


  (define-syntax (event-producer stx)
    (syntax-case stx ()
      [(src-event-producer? (parent ...) expr ...) #'(src-event-producer? #f (parent ...) expr ...)]
      [(src-event-producer catcher? (parent ...) expr ...)
       (with-syntax ([emit (datum->syntax-object (syntax src-event-producer) 'emit)]
                     [the-args (datum->syntax-object
                                (syntax src-event-producer) 'the-args)])
         (syntax (let* ([out (econs undefined undefined)]
                        [emit (lambda (val)
                                (set-erest! out (econs val undefined))
                                (set! out (erest out)))])
                   (proc->signal catcher? (lambda the-args expr ... out) parent ...))))]))
  
  ;; event* -> event
  (define merge-e
    (frp:lambda args
                (event-filter*
                 #f
                 (lambda (emit the-event) (emit the-event))
                 args)))

  (define merge-lst-e
    (frp:lambda (args)
                (event-filter*
                 #f
                 (lambda (emit the-event) (emit the-event))
                 args)))
  
  (define once-e
    (frp:lambda (e)
                (let ([b true])
                  (event-filter
                   (when b
                     (set! b false)
                     (emit the-event))
                   e))))
  
  ;; behavior[a] -> event[a]
  (define changes
    (frp:lambda (b)
                (event-producer
                 (b)
                 (emit (get-value b)))))
  
  (define (event-forwarder sym e f+l)
    (event-filter
     (for-each (lambda (tid) (! tid (list 'remote-evt sym the-event))) (rest f+l))
     e))
  
  ;; event-receiver : () -> event
  (define (event-receiver)
    (event-producer
     ()
     (when (not (empty? the-args))
       (emit (first the-args)))))
  
  ;; when-e : signal[bool] -> event
  (define when-e
    (frp:lambda (b)
                (let* ([last (get-value b)])
                  (event-producer
                   (b)
                   (let ([current (get-value b)])
                     (when (and (not last) current)
                       (emit current))
                     (set! last current))))))
  
  ;; ==> : event[a] (a -> b) -> event[b]
  (define ==>
    (frp:lambda (e f)
                (event-filter
                 (emit ((get-value f) the-event))
                 e)))
  
  ;; -=> : event[a] b -> event[b]
  (define -=>
    (frp:lambda (e v)
                (e . ==> . (lambda (_) v))))
  
  ;; =#> : event[a] (a -> bool) -> event[a]
  (define =#>
    (frp:lambda (e p)
                (event-filter
                 (when (p the-event)
                   (emit the-event))
                 e)))
  
  (define-syntax emit
    (syntax-rules ()
      [(_ ([receiver val] ...)
          result)
       (emit* (list (list receiver val) ...)
              result)]))

  (define (emit* connects result)
    (for-each
     (match-lambda [(receiver val) (send-event receiver val)])
     connects)
    result)

  (define nothing (string->uninterned-symbol "nothing"))
  
  ;; =#=> : event[a] (a -> b U nothing) -> event[b]
  (define =#=>
    (frp:lambda (e f)
                (event-filter
                 (let ([x ((get-value f) the-event)])
                   (when (not (eq? x nothing))
                     (emit x)))
                 e)))
  
  (define apply-e
    (frp:lambda (fn e)
                (event-filter
                 (emit (apply (get-value fn) the-event))
                 e)))

  (define map-e (frp:lambda (fn e) (e . ==> . fn)))
  (define map-const-e (frp:lambda (val e) (e . -=> . val)))
  (define filter-e (frp:lambda (fn e) (e . =#> . fn)))
  (define filter-map-e (frp:lambda (fn e) (e . =#=> . fn)))
  
  ;; event[a] b (a b -> b) -> event[b]
  (define collect-e
    (frp:lambda (e init trans)
                (event-filter
                 (let ([ret (trans the-event init)])
                   (set! init ret)
                   (emit ret))
                 e)))
  
  ;; event[(a -> a)] a -> event[a]
  (define accum-e
    (frp:lambda (e init)
                (event-filter
                 (let ([ret (the-event init)])
                   (set! init ret)
                   (emit ret))
                 e)))


  ;; TODO : snapshot-e should have a lower depth than the signals

  ;; event[a] signal[b]* -> event[(list a b*)]
  (define snapshot-e
    (frp:lambda (e . bs)
                (event-filter
                 (emit (cons the-event (map get-value bs)))
                 e)))
  
  ;; (a b* -> c) event[a] signal[b]* -> event[c]
  (define snapshot-map-e
    (frp:lambda (fn e . bs)
                (event-filter
                 (emit (apply fn the-event (map get-value bs)))
                 e)))
  
  ;; event[a] b (a b -> b) -> signal[b]
  (define collect-b
    (frp:lambda (ev init trans)
                (hold init (collect-e ev init trans))))
  
  ;; event[(a -> a)] a -> signal[a]
  (define accum-b
    (frp:lambda (ev init)
                (hold init (accum-e ev init))))
  
  ;; hold : a event[a] -> signal[a]
  (define hold
    (frp:lambda (v e)
                (proc->signal
                 #f
                 (let ([b true])
                   (lambda ()
                     (if b
                         (begin (set! b false)
                                (get-value v))
                         (efirst (signal-value e)))))
                 e)))
  
  (define catcher-exn-b
    (frp:lambda (b)
                (proc->signal
                 #t
                 (lambda () 
                   (if (raised-exn? (get-value b))
                       (raised-exn-data (get-value b))
                       false)) 
                 b)))

  (define catcher-val-b
    (frp:lambda (b)
                (proc->signal
                 #t
                 (lambda () 
                   (if (raised-exn? (get-value b))
                       false
                       (get-value b)))
                 b)))
  
  (define catcher-b
    (frp:lambda (b)
                (proc->signal
                 #t
                 (lambda ()
                   (if (raised-exn? (get-value b))
                       (raised-exn-data (get-value b))
                       (get-value b))))))

  (define catcher-val-e
    (frp:lambda (e)
                (event-filter*
                 #t
                 (lambda (emit the-event)
                   (unless (raised-exn? the-event)
                     (emit the-event)))
                 (list e))))
  
  (define catcher-exn-e
    (frp:lambda (b)
                (event-filter*
                 #t
                 (lambda (emit the-event)
                   (when (raised-exn? the-event)
                     (emit (raised-exn-data the-event))))
                 (list b))))
  
  (define pairs
    (frp:lambda (e)
                (let ([has-prev false]
                      [prev false])
                  (event-filter
                   (cond [has-prev
                          (emit (list prev the-event))
                          (set! has-prev false)
                          (set! prev false)]
                         [else
                          (set! has-prev true)
                          (set! prev the-event)])
                   e))))
  
  (define (with-semaphore sem proc)
    (semaphore-wait sem)
    (let ([result (proc)])
      (semaphore-post sem)
      result))
  
  (define-values (iq-enqueue iq-dequeue iq-empty?)
    (let ([heap (make-heap (lambda (a b) (< (signal-depth a) (signal-depth b))) eq?)]
          [heap-sem (make-semaphore 1)])
      (values (lambda (b) (with-semaphore heap-sem (lambda () (heap-insert heap b))))
              (lambda () (with-semaphore heap-sem (lambda () (heap-pop heap))))
              (lambda () (with-semaphore heap-sem (lambda () (heap-empty? heap)))))))
  
  ;;  (define-values (iq-enqueue iq-dequeue iq-empty?)
  ;;    (let* ([treap (make-treap -)]
  ;;           [put (treap 'put!)]
  ;;           [get (treap 'get)])
  ;;      (values
  ;;       (let ([cell (cons #f empty)])
  ;;         (lambda (b)
  ;;           (let ([depth (signal-depth b)])
  ;;             (put depth (cons b (rest (get depth (lambda () cell))))))))
  ;;       (lambda ()
  ;;         (let* ([depth&bhvrs (treap 'get-min)]
  ;;                [bhvrs (rest depth&bhvrs)])
  ;;           (if (empty? (rest bhvrs))
  ;;               (treap 'delete-min!)
  ;;               (put (first depth&bhvrs) (rest bhvrs)))
  ;;           (first bhvrs)))
  ;;       (lambda ()
  ;;         (treap 'empty?)))))
  
  ;; *** will have to change ... ***
  (define (propagate b)
    (let ([empty-boxes 0]
          [dependents (signal-dependents b)]
          [depth (signal-depth b)])
      (for-each
       (lambda (wb)
         (match (weak-box-value wb)
                [(and dep (? signal?) (= signal-stale? #f))
                 (set-signal-stale?! dep #t)
                 ;; If I'm crossing a "back" edge (one potentially causing a cycle),
                 ;; then I send a message.  Otherwise, I add to the internal
                 ;; priority queue.
                 (if (< depth (signal-depth dep))
                     (iq-enqueue dep)
                     (begin
                       ;(begin
                       ;  (printf "cross edge ~a ~a\n" depth (signal-depth dep))
                       ;  (pretty-display b)
                       ;  (newline)
                       ;  (pretty-display dep)
                       ;  (newline))
                       (! man dep)))
                 ]
                [_
                 (set! empty-boxes (add1 empty-boxes))]))
       dependents)
      (when (> empty-boxes 9)
        (set-signal-dependents!
         b
         (filter weak-box-value dependents)))))
  
  (define (update b . args)
    (match b
           [(and (? signal?)
                 (= signal-value value)
                 (= signal-thunk thunk))
            (set-signal-stale?! b #f)
            (let ([new-value (apply safe-eval-signal b args)])
              ;; consider modifying this test in order to support, e.g., mutable structs
              (when (not (equal? value new-value))
                (set-signal-value! b new-value)
                (propagate b)))]
           [_ (void)]))
  
  (define (undef b)
    (match b
           [(and (? signal?)
                 (= signal-value value))
            (set-signal-stale?! b #f)
            (when (not (eq? value undefined))
              (set-signal-value! b undefined)
              (propagate b))]
           [_ (void)]))
  
  (define named-dependents (make-hash-table))
  
  (frp:define (frp-bind sym evt)
              (! man (list 'bind sym evt))
              evt)
  
  (define (remote-reg tid sym)
    (hash-table-get named-dependents sym
                    (lambda ()
                      (let ([ret (event-receiver)])
                        (hash-table-put! named-dependents sym ret)
                        (! tid (list 'remote-reg man sym))
                        ret))))
  
  ;; idle callbacks are called only once, right before the next wait for alarms.
  (define idle-timeout 1)
  (define idle-callbacks empty)
  (define (add-idle-callback fn) (set! idle-callbacks (cons fn idle-callbacks)))

  (define (done-constructing) (set! idle-timeout 1))

  (define-values (alarms-enqueue alarms-dequeue-beh alarms-peak-ms alarms-empty?)
    (let ([heap (make-heap (lambda (a b) (< (first a) (first  b))) eq?)])
      (values (lambda (ms beh) (heap-insert heap (list ms beh)))
              (lambda () (match (heap-pop heap) [(ms beh) beh]))
              (lambda () (match (heap-peak heap) [(ms beh) ms]))
              (lambda () (heap-empty? heap)))))

  ;; the manager of all signals and event streams

  (define man
    (spawn/name
     'frp-man
     (let ([named-providers (make-hash-table)]
           [cur-beh #f])
       (let outer ()
         (let loop ([can-idle #t])
           ;; should rewrite this entire block:
           ;; (1) extract messages until none waiting (or N ms elapse?)
           ;; (2) extract alarms
           ;; (3) process internal queue until empty
               
           (define (do-update b . args)
             (when verbose-manager (printf "do-update\n"))
             (set! cur-beh b)
             (apply update b args)
             (set! cur-beh #f))
               
           (define (process-msg v)
             (when verbose-manager (printf "process-msg ~a\n" v))
             (match 
              v
              [(? signal? b) (do-update b)]
              [($ event val recip)
               ;; should this really be here?
               (do-update recip val)]
              [($ sync-event val recip ret)
               (do-update recip val)
               (! ret man)]
              [($ alarm ms beh)
               (when (> ms 1073741824)
                 (set! ms (- ms 2147483647)))
               (alarms-enqueue ms (make-weak-box beh))]
              [($ reg inf sup ret)
               (register inf sup)
               (! ret man)]
              [($ unreg inf sup)
               (unregister inf sup)]
              [('bind sym evt)
               (let ([forwarder+listeners (cons #f empty)])
                 (set-car! forwarder+listeners
                           (event-forwarder sym evt forwarder+listeners))
                 (hash-table-put! named-providers sym forwarder+listeners))]
              [('remote-reg tid sym)
               (let ([f+l (hash-table-get named-providers sym)])
                 (when (not (member tid (rest f+l)))
                   (set-rest! f+l (cons tid (rest f+l)))))]
              [('remote-evt sym val)    ; should probably set cur-beh here too (?)
               (do-update (hash-table-get named-dependents sym (lambda () dummy)) val)]
              [x (fprintf (current-error-port) "msg not understood: ~a~n" x)]))
               
           (define (is-timer-ready?)
             (and (not (alarms-empty?))
                  (>= (current-milliseconds) 
                      (alarms-peak-ms))))
               
           (define (process-timers)
             (when verbose-manager (printf "process-timers\n"))
             (let inner ()
               (when (is-timer-ready?)
                 (let ([beh (weak-box-value (alarms-dequeue-beh))])
                   (when (and beh (not (signal-stale? beh)))
                     (set-signal-stale?! beh #t)
                     (iq-enqueue beh)))
                 (inner))))
               
           (cond [(not (iq-empty?))
                  ;; internal updates
                  (print-struct true)
                  (do-update (iq-dequeue))
                  (loop can-idle)]
                 [(is-timer-ready?)
                  ;; timers
                  (process-timers)
                  (loop can-idle)]
                 [else
                  (let ([pending (receive [after idle-timeout #f] [v v])])
                    (cond [pending
                           (process-msg pending)
                           (loop can-idle)]
                          [else
                           (when verbose-manager (printf "idle-callbacks\n"))
                           (let ([fns idle-callbacks])
                             (set! idle-callbacks empty)
                             (for-each (lambda (fn) (fn)) fns))
                           (when verbose-manager (printf "now waiting\n"))
                           (let ([timeout 
                                  (if (alarms-empty?) #f
                                      (- (alarms-peak-ms)
                                         (current-milliseconds)))])
                             (receive
                                 [after timeout (process-timers)]
                                 [v (process-msg v)]))
                           (loop #t)]))]))))))

  (define dummy
    (proc->signal #f void))
  
  (define (silly)
    (letrec ([res (proc->signal
                   #f
                   (let ([x 0]
                         [init (current-milliseconds)])
                     (lambda ()
                       (if (< x 400000)
                           (begin
                             (set! x (+ x 1)))
                           (begin
                             (printf "time = ~a~n" (- (current-milliseconds) init))
                             (set-signal-dependents! res empty)))
                       x)))])
      (set-signal-dependents! res (cons (make-weak-box res) empty))
      (! man res)
      res))
  
  (define (simple-b fn)
    (let ([ret (proc->signal #f void)])
      (set-signal-thunk! ret (fn ret))
      (set-signal-value! ret ((signal-thunk ret)))
      ret))
  
  (define (make-time-b ms)
    (let ([ret (proc->signal #f void)])
      (set-signal-thunk! ret
                           (lambda ()
                             (let ([t (current-milliseconds)])
                               (! man (make-alarm (+ ms t) ret))
                               t)))
      (set-signal-value! ret ((signal-thunk ret)))
      ret))
  
  (define (make-milliseconds) (make-time-b 20))
;  (define milliseconds (make-milliseconds))
;  (define time-b milliseconds)
  
  (define (make-seconds)
    (let ([ret (proc->signal #f void)])
      (set-signal-thunk! ret
                           (lambda ()
                             (let ([s (current-seconds)]
                                   [t (current-milliseconds)])
                               (! man (make-alarm (* 1000 (add1 (floor (/ t 1000)))) ret))
                               s)))
      (set-signal-value! ret ((signal-thunk ret)))
      ret))

  (define seconds (make-seconds))
  
  ;; general efficiency fix for delay
  ;; signal[a] signal[num] -> signal[a]
  (define delay-by
    (frp:lambda (beh ms-b)
                (if (and (number? ms-b) (<= ms-b 0))
                    beh
                    (let* ([last (cons (cons undefined
                                             (current-milliseconds))
                                       empty)]
                           [head last]
                           [ret (proc->signal #f void)]
                           [thunk (lambda () (let* ([now (current-milliseconds)]
                                               [new (get-value beh)]
                                               [ms (get-value ms-b)])
                                          (when (not (equal? new (caar last)))
                                            (set-rest! last (cons (cons new now)
                                                                  empty))
                                            (set! last (rest last))
                                            (! man (make-alarm
                                                    (+ now ms) ret)))
                                          (let loop ()
                                            (if (or (empty? (rest head))
                                                    (< now (+ ms (cdadr head))))
                                                (caar head)
                                                (begin
                                                  (set! head (rest head))
                                                  (loop))))))])
                      (set-signal-thunk! ret thunk)
                      (set-signal-value! ret (thunk))
                      (register ret (list beh ms-b))))))


  (define delay-e
    (frp:lambda 
     (e n)
     (map-e first (history-e e (add1 n)))))

  (define history-e
    (frp:lambda (e n)
                (when (signal? n)
                  (raise "history-e: n should be constant"))
                (let* ([head (list undefined)]
                       [tail head])
                  (event-filter
                   (begin
                     (set-cdr! tail (list the-event))
                     (set! tail (rest tail))
                     (when (> (length head) n)
                       (emit (rest head))
                       (set-first! head undefined)
                       (set! head (rest head))))
                   e))))
  
          
  ;; fix to take arbitrary monotonically increasing number
  ;; (instead of milliseconds)
  ;; integral : signal[num] signal[num] -> signal[num]
  (define integral
    (frp:case-lambda
     [(b) (integral b 20)]
     [(b ms-b) (let* ([accum 0]
                      [last-time (current-milliseconds)]
                      [last-val (get-value b)]
                      [ret (proc->signal #f void)]
                      [last-alarm 0]
                      [thunk (lambda ()
                               (let ([now (current-milliseconds)])
                                 (if (> now (+ last-time 10))
                                     (begin
                                       (when (not (number? last-val))
                                         (set! last-val 0))
                                       (set! accum (+ accum
                                                      (* last-val
                                                         (- now last-time))))
                                       (set! last-time now)
                                       (set! last-val (get-value b))
                                       (when (get-value ms-b)
                                         (! man (make-alarm
                                                 (+ last-time (get-value ms-b))
                                                 ret))))
                                     (when (or (>= now last-alarm)
                                               (and (< now 0)
                                                    (>= last-alarm 0)))
                                       (set! last-alarm (+ now 20))
                                       (! man (make-alarm last-alarm ret))))
                                 accum))])
                 (set-signal-thunk! ret thunk)
                 (set-signal-value! ret (thunk))
                 (register ret (list b ms-b)))]))
  
  ;; fix for accuracy
  ;; derivative : signal[num] -> signal[num]
  (define derivative
    (frp:lambda (b)
                (let* ([last-value (get-value b)]
                       [last-time (current-milliseconds)]
                       [thunk (lambda ()
                                (let* ([new-value (get-value b)]
                                       [new-time (current-milliseconds)]
                                       [result (if (or (= new-value last-value)
                                                       (= new-time last-time)
                                                       (> new-time
                                                          (+ 500 last-time))
                                                       (not (number? last-value))
                                                       (not (number? new-value)))
                                                   0
                                                   (/ (- new-value last-value)
                                                      (- new-time last-time)))])
                                  (set! last-value new-value)
                                  (set! last-time new-time)
                                  result))])
                  (proc->signal #f thunk b))))
  
  ;; new-cell : a -> signal[a] (cell)
  (frp:define (new-cell init)
              (switch-helper init))
  
  ;; set-cell! : cell[a] a -> void
  (frp:define (set-cell! ref beh)
              (! man (make-event beh ref)))
  
  (frp:define (send-event rcvr evt)
              (! man (make-event evt rcvr)))

  (frp:define (send-sync-event rcvr evt)
              (! man (make-sync-event evt rcvr (self)))
              (receive [(? (lambda (v) (eq? v man))) (void)]))
  
  (define c-v get-value)
  
  (define cur-vals
    (frp:lambda args
                (apply values (map get-value args))))
  
  (define signal-consumers (list signal?
                                   signal-dependents
                                   signal-depth
                                   make-unreg
                                   values))
  
  (define (curried-apply fn)
    (lambda (lis) (apply fn lis)))
  
  (define-syntax frp:module-begin
    (syntax-rules ()
      [(_ body ...)
       (#%module-begin body ...)]))

  (define-syntax frp:app
    (syntax-rules ()
      [(_ fn arg ...) (lift/v 'fn fn arg ...)]))
  
  (define-syntax frp:letrec
    (syntax-rules ()
      [(_ ([id val] ...) expr ...)
       (let ([id (new-cell undefined)] ...)
         (set-cell! id val) ...
         expr ...)]))
  
  (define-syntax frp:rec
    (syntax-rules ()
      [(_ name value-expr)
       (frp:letrec ([name value-expr]) name)]))
  
  (define-syntax match-b
    (syntax-rules ()
      [(_ expr clause ...) (lift (match-lambda clause ...) expr)]))

  (define (geometric)
    (- (log (/ (random 2147483647) 2147483647.0))))
  
  (define (make-geometric mean)
    (simple-b (lambda (ret)
                (let ([cur 0])
                  (lambda ()
                    (! man (make-alarm (+ (current-milliseconds)
                                          (inexact->exact (ceiling (* mean (geometric)))))
                                       ret))
                    (set! cur (- 1 cur))
                    cur)))))
  
  (define (make-constant ms)
    (simple-b (lambda (ret)
                (let ([cur 0])
                  (lambda ()
                    (! man (make-alarm (+ (current-milliseconds) ms)
                                       ret))
                    (set! cur (- 1 cur))
                    cur)))))
#|
  (define value-snip-copy%
    (class string-snip%
      (init-field current parent)
      (inherit get-admin)
      (define/public (set-current c)
        (set! current c)
        (let ([admin (get-admin)])
          (when admin
            (send admin needs-update this 0 0 1000 100))))
      (define/override (draw dc x y left top right bottom dx dy draw-caret)
        (send current draw dc x y left top right bottom dx dy draw-caret))
      (super-instantiate (" "))))
  
  (define (make-snip bhvr)
    (make-object string-snip%
      (let ([tmp (get-value bhvr)])
        (cond
          [(econs? tmp) (format "#<event (last: ~a)>" (efirst tmp))]
          [(undefined? tmp) "#<undefined>"]
          [else (expr->string tmp)]))))
  
  (define value-snip%
    (class string-snip%
      (init-field bhvr)
      (field [copies empty]
             [loc-bhvr (proc->signal (lambda () (update)) bhvr)]
             [current (make-snip bhvr)])
      
      (rename [std-copy copy])
      (define/override (copy)
        (let ([ret (make-object value-snip-copy% current this)])
          (set! copies (cons ret copies))
          ret))
      
      (define/public (update)
        (set! current (make-snip bhvr))
        (for-each (lambda (copy) (send copy set-current current)) copies))
      
      (super-instantiate (" "))))
  
  (frp:define (watch beh)
    (cond
      [(undefined? beh)
       (make-object string-snip% "#<undefined>")]
      [(signal? beh) (make-object value-snip% beh)]
      [else beh]))

|#  


  (define value-snip-copy%
    (class string-snip%
      (init-field current parent)
      (inherit get-admin)
      (define/public (set-current c)
        (set! current c)
        (let ([admin (get-admin)])
          (when admin
            (send admin needs-update this 0 0 1000 100))))
      (define/override (draw dc x y left top right bottom dx dy draw-caret)
        (send current draw dc x y left top right bottom dx dy draw-caret))
      (super-instantiate (" "))))
  
  (define (make-snip bhvr)
    (make-object string-snip%
                 (let ([tmp (get-value bhvr)])
                   (cond
                    [(raised-exn? tmp)
                     (format "#<raised exn: ~a>" (raised-exn-data tmp))]
                    [(undefined? tmp) "#<undefined>"]
                    [(econs? tmp) "#<event>"]
                    [else (expr->string tmp)]))))
  
  (define value-snip%
    (class string-snip%
      (init-field bhvr)
      (field [copies empty]
             [loc-bhvr (proc->signal #t (lambda () (update)) bhvr)]
             [current (make-snip bhvr)])
      
      (rename [std-copy copy])
      (define/override (copy)
        (let ([ret (make-object value-snip-copy% current this)])
          (set! copies (cons ret copies))
          ret))
      
      (define/public (update)
        (set! current (make-snip bhvr))
        (for-each (lambda (copy) (send copy set-current current)) copies))
      
      (super-instantiate (" "))))

  (frp:define (watch beh)
              (cond
               [(not (signal? beh)) beh]
               [(event-source? beh)
                (make-object string-snip% "#<event>")]
               [else (make-object value-snip% beh)]))

  (define all-monitors empty) ;; to prevent gc

  (define monitor-exn-traces true)

  (frp:define (monitor . args)

              (define (thunk)
                (parameterize ([print-struct true])
                  (let ([print-args
                         (map (lambda (v)
                                (cond [(not (signal? v)) v]
                                      [(event-source? v) (efirst (signal-value v))]
                                      [else (signal-value v)]))
                              args)])
                    (printf "monitor: ")
                    (for-each (lambda (v) (printf "~a " v)) print-args)
                    (newline)
                    (for-each 
                     (match-lambda
                      [($ raised-exn (? exn? e))
                       (printf "monitor exn: ~a~n" (exn-message e))
                       (when monitor-exn-traces 
                         (print-error-trace (current-output-port) e))]
                      [($ raised-exn d)
                       (printf "monitor raised: ~a~n" d)]
                      [_ #f])
                     print-args)))
                undefined)

              (let ([result
                     (apply
                      proc->signal
                      #t
                      thunk
                      args)])
                (set! all-monitors (cons result all-monitors))
                (thunk)
                (void)))

  (provide (rename #%app app-prim)
           (rename if if-prim)
           (rename cond cond-prim)
           (rename and and-prim)
           (rename or or-prim)
           (rename lambda lambda-prim)
           (rename case-lambda case-lambda-prim)
           (rename define define-prim)
           (rename letrec letrec-prim)
           (rename rec rec-prim)

           (rename #%module-begin #%module-begin)
           (rename frp:app #%app)
           (rename frp:if if)
           (rename frp:cond cond)
           (rename frp:and and)
           (rename frp:or or)
           (rename frp:lambda lambda)
           (rename frp:case-lambda case-lambda)
           (rename frp:define define)
           (rename frp:letrec letrec)
           (rename frp:rec rec)
           (rename match-b match)
           (rename get-value cur-val)

           make-tid
           (all-defined-except)
           (all-from-except (lib "list.ss"))
           (all-from-except (lib "etc.ss") rec)
           (all-from-except (lib "match.ss") match)
           (all-from-except (lib "string.ss"))
           (all-from-except mzscheme define if #%module-begin #%app lambda case-lambda letrec and or cond)))
