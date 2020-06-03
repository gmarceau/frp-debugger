(module jdb (lib "frp.ss" "frtime")

  (require "jdi.ss"
           (all-except (lib "match.ss") match)
           "jdi-symbol-table.ss")

  (define-syntax (define-client stx)
    (syntax-case stx ()
      [(def name client)
       (with-syntax ([(stoped-locs kill stack desired-stack-pos effective-stack-pos
                                   here up down stop trigger set-trigger! 
                                   breakpoints break delete-bp clear-all-bps resume)
                      (map (lambda (s) (datum->syntax-object #'name s))
                           '(stoped-locs kill stack desired-stack-pos effective-stack-pos
                                         here up down stop trigger set-trigger! 
                                         breakpoints break delete-bp clear-all-bps resume))])
         #'(begin
             (define name client)
             (define (kill) (query name (encode-virtualmachine-dispose)))
             (define stoped-locs (hold empty (client-stop-locs name)))
             (define stack (find-main-stack stoped-locs))
             (define desired-stack-pos (new-cell 0))
             (define effective-stack-pos (max 0 (min desired-stack-pos (sub1 (length stack)))))
             (define here (list-ref stack effective-stack-pos))
             (define (up) (set-cell! desired-stack-pos (add1 (get-value effective-stack-pos))))
             (define (down) (set-cell! desired-stack-pos (sub1 (get-value effective-stack-pos))))
             (define (stop) (set-cell! (client-run-trigger name) false))
             (define trigger (client-run-trigger name))
             (define set-trigger! 
               (case-lambda [(beh) (set-trigger! name beh)]
                            [(c beh) (set-cell! (client-run-trigger c) beh)]))

             (define-values (breakpoints break delete-bp clear-all-bps)
               (let* ([rcvr (event-receiver)])
                 (values 

                  (switch empty (accum-e rcvr empty))
                  
                  (lambda (loc)
                    (send-event 
                     rcvr
                     (lambda (prev) (cons 
                                (list loc (accum-b (trace loc (jlambda () () add1)) 0))
                                prev))))

                  (lambda (loc)
                    (send-event
                     rcvr          
                     (lambda (prev)
                       (filter (lambda (bp) (not (equal? loc (first bp))))
                               prev))))

                  (lambda ()
                    (send-event rcvr (lambda (prev) empty))))))
             
             (define (resume) 
               (set-cell! (client-run-trigger name) 
                          (hold true
                                ((changes (map second breakpoints))
                                 . -=> . false))))))]))
  
  (define (set-trigger! c beh) (set-cell! (client-run-trigger c) beh))
  (define set-running! set-trigger!)
  
  (define-syntax jdb:define-connect-vm
    (syntax-rules ()
      [(_ name host port) (define-client name (connect-vm host port))]))

  (define-syntax jdb:define-start-vm
    (syntax-rules ()
      [(_ name arg ...) (define-client name (start-vm arg ...))]))
  
  ;; classload-event (e (tuple string jref))
  ;; first-class-load: (b (may jref))
  (define-syntax jclassload-event/name 
    (syntax-rules () [(_ c name) (jclassload-event/name* c (symbol->string 'name))]))

  (define (jclassload-event/name* c name)
    ((client-classload-event c)
     . =#=> .
     (lambda (name-jref)
       (if (equal? (first name-jref) name)
           (cur-val (second name-jref))
           nothing))))

  (define-syntax jdot
    (syntax-rules () [(_ val name) (jdot* val (symbol->string 'name))]))

  (define-syntax &jdot
    (syntax-rules () [(_ val name) (&jdot* val (symbol->string 'name))]))

  (define-syntax jloc
    (syntax-rules () [(_ val name) (jloc* val 'name)]))

  (define-syntax jval
    (syntax-rules () [(_ dyn-loc name) (jval* dyn-loc (symbol->string 'name))]))

  (define-syntax &jval
    (syntax-rules () [(_ dyn-loc name) (&jval* dyn-loc (symbol->string 'name))]))

  (define-syntax jclass 
    (syntax-rules () [(_ c name) (jclass* c (symbol->string 'name))]))

  (define-syntax jcall
    (syntax-rules ()
      [(_ dynloc target-jref method arg ...)
       (jcall* dynloc target-jref (symbol->string 'method) arg ...)]))
  
  (define (jclass* c name)
    (or (catcher-val-b
         (make-class-jref c (javaClassSig->classID c name)))
        (hold false (once-e (jclassload-event/name* c name)))
        (raise 'not-loaded)))

  (define (entry&exit enabled? method jproc)
    (merge-e
     (trace enabled?
            (jloc method 'entry)
            jproc)
     
     (trace enabled?
            (jloc method 'exit)
            jproc)))

  (define (size&time-trace enabled? method args)
    (let ([e (entry&exit 
              enabled? 
              method 
              (jlambda*
               false false args 
               (lambda args (cons (current-milliseconds) (map v args)))))])
      
      (map-e (match-lambda
              [((start-time size) (end-time _))
               (list size (- end-time start-time))])
             (pairs e))))

  (define (count-e e) (accum-b (e . -=> . add1) 0))
#;
  (define (so-many-seconds-have-passed secs)
    (let ([start (current-seconds)])
      ((seconds . - . start) . > . secs)))
  
  (provide (all-from-except "jdi.ss")
           (all-from (lib "match.ss"))
           (rename jdb:define-connect-vm define-connect-vm)
           (rename jdb:define-start-vm define-start-vm)
           set-trigger!
           set-running!
           jclass
           jdot
           &jdot
           jloc
           jval
           size&time-trace
           jclassload-event/name
           jclassload-event/name*
           ;;so-many-seconds-have-passed
           count-e
           )

  )
