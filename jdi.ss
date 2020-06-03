(module jdi mzscheme
  ;;
  ;; Run along side with :
  ;;
  ;; java -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8001 Foobar 10 
  ;;
  (require "jdwp.ss"
           "jdi-symbol-table.ss"
           (prefix frp: (lib "frp.ss" "frtime"))
           (lib "process.ss")
           (lib "async-channel.ss")
           (lib "contract.ss")
           (lib "class.ss")
           (lib "plt-match.ss")
           "base-gm.ss")
  
  (require-for-syntax
   (rename (lib "stx.ss" "syntax") stx-list? stx-list?)
   "util.ss"
   (lib "list.ss"))
  
  ;; ------------------------------------------------------
  
  (define-struct breakpoint (locs              ;; (list loc)
                             implemented-locs  ;; (hash loc requestid)
                             enabled?          ;; bool
                             event-body))      ;; (client threadid stack ... -> void)
  
  (define-struct client-info (breakpoints run-trigger dispatcher classload-event unrequested-events stop-locs))
  (define *client2info* (make-hash 'weak))
  (define *client2trigger-proc* (make-hash 'weak))
  
  (define (client-breakpoints client) (client-info-breakpoints (hash-get *client2info* client)))
  (define (client-run-trigger client) (client-info-run-trigger (hash-get *client2info* client)))
  (define (client-dispatcher client) (client-info-dispatcher (hash-get *client2info* client)))
  (define (client-classload-event client) (client-info-classload-event (hash-get *client2info* client)))
  (define (client-unrequested-events client) (client-info-unrequested-events (hash-get *client2info* client)))
  (define (client-stop-locs client) (client-info-stop-locs (hash-get *client2info* client)))
  
  (define *breakpoint-will-executor* (make-will-executor))
  (define *beh2breakpoint* (make-hash 'weak))
  (define *breakpoint2trigger* (make-hash 'weak))
  ;; beh2breakpoint ensure that the breakpoints are collected
  ;; only when the frp object is collected.
  
  (define (with-wait-for-frp-idle thunk)
    (let* ([sem (make-semaphore 0)])
      (frp:add-idle-callback (lambda () (semaphore-post sem)))
      (thunk)
      (semaphore-wait sem)))
  
  (define (send-synchronous-frp-event receiver v)
    (with-wait-for-frp-idle
     (lambda () (frp:send-sync-event receiver v))))
  
  (define (get-stop-locations client)
    (let* ([threads (query client (encode-virtualmachine-allthreads))])
      (map
       (lambda (threadID)
         (list threadID
               (map
                (match-lambda 
                 [(struct threadreference--frames (frameID locID))
                  (locID->dyn-locID client locID threadID frameID)])
                (query client (encode-threadreference-frames threadID 0 -1)))))
       threads)))
  
  (define (server-on-free-port start tries)
    (and (> tries 0) 
         (with-handlers
             ([(lambda (exn) true)
               (lambda (exn) (server-on-free-port (add1 start) (- tries 1)))])
           (let ([port (tcp-listen start)])
             (values port start)))))
  
  (define (jdi:start-vm . args)
    (let*-values
        ([(server-port port-num) (server-on-free-port 8001 20)]
         [(base-cmd) "xterm -e java -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=n,suspend=y,address="]
         [(str-args) (apply string-append (map (lambda (arg) (format "~a " arg)) args))]
         [(cmd) (format "~a~a ~a &" base-cmd port-num str-args)]
         [(_) (debug cmd)]
         [(_) (process cmd)]
         [(in out) (tcp-accept server-port)]
         [(c chn) (connect/ports in out)])
      (create-client c chn)))
  
  (define (jdi:connect-vm host port)
    (let-values ([(c chn) (connect host port)])
      (create-client c chn)))

  (define (disconnect-vm c)
    (query c (encode-virtualmachine-dispose)))
  
  (define here (frp:new-cell false))
  
  (define (create-client c chn)
    (let* ([classload-event (frp:event-receiver)]
           [unrequested-events (frp:event-receiver)]
           [trigger-cell (frp:new-cell false)]
           [stop-locs (frp:event-receiver)]
           [dispatcher
            (make-per-request-dispatcher 
             c chn
             (lambda (event)
               (match event
                      ;; Hold the virtual machine at startup:
                      [(list 'vmstart (struct event--composite--events--vmstart (_ _)))
                       (query c (encode-virtualmachine-suspend))]
                      [_ (void)])
               ;; Publishes unrequested events:
               (send-synchronous-frp-event unrequested-events event)))])
      
      ;; Enable breakpoints as their classes are being loaded, and publishes class-load events:
      (send dispatcher add-request
            event-kind-class-prepare
            suspend-policy-all
            '((classexclude "java.*") (classexclude "sun.*"))
            (match-lambda 
             [(list 'classprepare
                    (struct event--composite--events--classprepare 
                            (requestid thread reftypetag typeid signature status)))
              (implement-breakpoints-of-reftypeid c typeid)
              (send-synchronous-frp-event 
               classload-event 
               (list (vmClassSig->javaClassSig signature)
                     (make-class-jref c (downcast-to-classid typeid))))]))
      
      ;; Respond to the run-trigger cell:
      (let* ([current-run-trigger false]
             [trigger-proc
              (frp:proc->signal
               #f
               (lambda ()
                 (let ([new-t (frp:get-value trigger-cell)])
                   (cond [(and (not current-run-trigger) new-t)
                          (query c (encode-virtualmachine-resume))]
                         [(and current-run-trigger (not new-t))
                          (query c (encode-virtualmachine-suspend))
                          (let ([locs (get-stop-locations c)])
                            ;;(frp:set-cell! here (first (find-main-stack locs)))
                            (set! here (first (find-main-stack locs)))
                            (debug "Stopping..." here) ;; TODO
                            (frp:send-sync-event stop-locs locs))])
                   (set! current-run-trigger new-t)))
               trigger-cell)])
        (hash-put! *client2trigger-proc* c trigger-proc))
      
      (hash-put! *client2info* c (make-client-info (make-hash)
                                                   trigger-cell
                                                   dispatcher
                                                   classload-event
                                                   unrequested-events
                                                   stop-locs))
      
      c))
  
  (define (create-breakpoint enabled? locs body)
    (let* ([locs (if (list? locs) locs (list locs))]
           [result (make-breakpoint locs (make-hash 'equal) enabled? body)])
      
      (will-register *breakpoint-will-executor* result (lambda (brk) (breakpoint-delete brk)))
      (for-each
       (lambda (loc)
         (let ([client (location-client loc)])
           (hash-put! (client-breakpoints client) result true)
           (when (and enabled? (class-loaded? client (location-clazz loc)))
             (implement result loc))))
       locs)
      result))
  
  (define (breakpoint-delete brk)
    (for-each
     (lambda (loc)
       (let ([client (location-client loc)])
         (hash-remove! (client-breakpoints client) brk)
         (when (breakpoint-impl? brk loc)
           (unimplement brk loc))))
     (breakpoint-locs brk))
    ;; [Will-try-execute] calls [breakpoint-delete], and returns whatever
    ;; [breakpoint-delete] returns. Also, [will-try-execute] returns false
    ;; when there is no will to run.  So, let just make sure we never return
    ;; false ourself:
    true)
  
  (define (all-breakpoints client) (hash-keys (client-breakpoints client)))
  
  (define (breakpoint-enable brk)
    (for-each
     (lambda (loc)
       (when (and (not (breakpoint-impl? brk loc))
                  (class-loaded? (location-client loc) (location-clazz loc)))
         (implement brk loc)))
     (breakpoint-locs brk))
    (set-breakpoint-enabled?! brk true))
  
  (define (breakpoint-disable brk)
    (for-each
     (lambda (loc)
       (when (breakpoint-impl? brk loc)
         (unimplement brk loc)))
     (breakpoint-locs brk))
    (set-breakpoint-enabled?! brk false))
  
  (define (implement-breakpoints-of-reftypeid client reftypeid)
    (for-each
     (lambda (brk)
       (when (breakpoint-enabled? brk)
         (for-each
          (lambda (loc) 
            (with-handlers
                ([exn:not-found?
                  (lambda (exn) (void))])
              (let ([locID (loc->locationID loc)])
                (when (and (locationID-classid locID)
                           (referenceTypeID-equal? (locationID-classid locID) reftypeid)
                           (not (breakpoint-impl? brk loc)))
                  (implement brk loc)))))
          (breakpoint-locs brk))))
     (all-breakpoints client)))
  
  (define-struct jlambda-proc (with-stack with-thread args fn))
  
  (define-syntax bind 
    (syntax-rules ()
      [(_ (arg ...) body ...) (jlambda () (arg ...) body ...)]))

  (define-syntax jlambda
    (syntax-rules ()
      [(_ () (arg ...) body ...) (make-jlambda-proc false false '(arg ...) (lambda (arg ...) body ...))]
      [(_ (stack) (arg ...) body ...) (make-jlambda-proc true false '(arg ...) (lambda (stack arg ...) body ...))]
      [(_ (stack thread) (arg ...) body ...) (make-jlambda-proc true true '(arg ...) (lambda (stack thread arg ...) body ...))]))
  
  (define (call-jlambda/stack dyn-locID stack jproc)
    (match dyn-locID
           [(struct dyn-locationID (type-tag classid methodid offset client threadid frameid))
            (let* ([thread-arg (if (jlambda-proc-with-thread jproc)
                                   (list threadid) empty)]
                   [stack-arg (if (jlambda-proc-with-stack jproc) 
                                  (list (map (lambda (frame) (threadreference-frames->dyn-locID client threadid frame)) stack)) empty)]
                   [val-args (map (lambda (name) (jval* dyn-locID name))
                                  (map symbol->string (jlambda-proc-args jproc)))])
              (apply (jlambda-proc-fn jproc) (append stack-arg thread-arg val-args)))]))
  
  
  (define (call-jlambda dyn-locID jproc)
    (if (jlambda-proc-with-stack jproc)
        
        (call-jlambda/stack
         dyn-locID
         (query (dyn-locationID-client dyn-locID)
                (encode-threadreference-frames (dyn-locationID-threadID dyn-locID) 0 -1))
         jproc)
        
        (call-jlambda/stack
         dyn-locID
         false
         jproc)))
  
  (define-struct recorder-entry (timestamp receiver val))
  (define-struct recorder (sem data))
  (define (create-recorder) (make-recorder (make-semaphore 1) empty))
  (define current-recorder (make-parameter false))
  
  (define (recorder-add rec receiver val)
    (with-semaphore (recorder-sem rec)
                    (lambda ()
                      (set-recorder-data!
                       rec
                       (cons (make-recorder-entry (current-milliseconds) receiver val)
                             (recorder-data rec))))))
  
  
  (define (recorder-grab-data rec thunk)
    (with-semaphore (recorder-sem rec)
                    (lambda ()
                      (let ([data (recorder-data rec)])
                        (set-recorder-data! rec empty)
                        (thunk data)))))
  
  (define (recorder-clear rec) (recorder-grab-data rec (lambda (data) (void))))
  
  (define (recorder-playback-fast rec)
    (recorder-grab-data rec
                        (lambda (data)
                          (thread
                           (lambda ()
                             (for-each
                              (match-lambda
                               [(struct recorder-entry (timestamp receiver val))
                                (frp:send-event receiver val)
                                (sleep 0.1)
                                ])
                              (reverse data)))))))
    
    (define (recorder-playback-realtime rec)
      (recorder-grab-data rec
                          (lambda (data)
                            (thread
                           (lambda ()
                             (let loop ([lst (reverse data)])
                               (match 
                                lst
                                [(list) (void)]
                                [(list (struct recorder-entry (timestamp receiver val)))
                                 (frp:send-event receiver val)]
                                [(list (struct recorder-entry (timestamp receiver val)) rest ...)
                                 (frp:send-event receiver val)
                                 (sleep (/ (- (recorder-entry-timestamp (first rest)) timestamp) 1000))
                                 (loop rest)])))))))
  
  (define trace (frp:lambda (loc jlambda) (trace/enabled true loc jlambda)))
  
  (define (trigger-trace receiver jlambda client threadid stack)
    (let ([v (call-jlambda/stack
              (threadreference-frames->dyn-locID client threadid (first stack))
              stack jlambda)])
      (send-synchronous-frp-event receiver v)
      v))

  (define trace/enabled
    (frp:lambda (enabled? loc jlambda)
                (let* ([receiver (frp:event-receiver)]
                       [recorder (current-recorder)]
                       [brk-callback
                        (lambda (client threadid stack) 
                          (let ([v (trigger-trace receiver jlambda client threadid stack)])
                            (when recorder
                              (recorder-add recorder receiver v))))]
                       [brk false]
                       [trigger
                        ;; respond to changes in the value of the behaviors 'enabled?' and 'loc'
                        (frp:proc->signal
                         #f
                         (lambda () 
                           (unless brk ;; The breakpoint gets created on the first update without raised-exn's
                             (set! brk
                                   (create-breakpoint (frp:get-value enabled?) (frp:get-value loc) brk-callback)))
                           (cond [(not (equal? (frp:get-value loc) (first (breakpoint-locs brk))))
                                  (breakpoint-delete brk)
                                  (set! brk (create-breakpoint
                                             (frp:get-value enabled?) (frp:get-value loc) 
                                             brk-callback))]
                                 [(not (eq? (frp:get-value enabled?) (breakpoint-enabled? brk)))
                                  (if (frp:get-value enabled?)
                                      (breakpoint-enable brk)
                                      (breakpoint-disable brk))]))
                         enabled?
                         loc)])
      
                  ;; Gc-sensitive hashes:
                  (hash-put! *beh2breakpoint* receiver brk)
                  (hash-put! *breakpoint2trigger* brk trigger)
      
                  receiver)))
  
  (define (lst-last ls)
    (cond
     ((empty? ls) (error "took a last but it was empty"))
     ((empty? (rest ls)) (first ls))
     (else (lst-last (rest ls)))))

  (define (find-main-thread stop-locs)
    (match (filter
            (match-lambda
             [(list threadID (list)) false]
             [(list threadID (list dyn-locIDs ...))
              (let ([top-loc (lst-last dyn-locIDs)])
                (equal? "main"
                        (methodID->methodName 
                         (dyn-locationID-client top-loc)
                         (locationID-classid top-loc)
                         (locationID-methodid top-loc))))])
            stop-locs)
           [(list) (raise 'not-found)]
           [(list entry) entry]))

  (define (find-main-threadid stop-locs)
    (first (find-main-thread stop-locs)))

  (define (find-main-stack stop-locs)
    (second (find-main-thread stop-locs)))

  (define (class-loaded? client clazz)
    (if (referenceTypeID? clazz) ;; TODO
        true 
        (let ([cmd (encode-virtualmachine-classesbysignature (javaClassSig->vmClassSig clazz))])
          (not (empty? (query client cmd))))))
  
  (define (breakpoint-impl? breakpoint loc)
    (hash-mem? (breakpoint-implemented-locs breakpoint) loc))
  
  (define (threadreference-frames->dyn-locID client threadid frame)
    (match frame
           [(struct threadreference--frames (frameid locID))
            (locID->dyn-locID client locID threadid frameid)]))
  
  (define (call-breakpoint client breakpoint event)
    (match event
           [(list 'breakpoint
                  (struct event--composite--events--breakpoint (requestid threadid locationID)))
            (let ([stack (query client (encode-threadreference-frames threadid 0 -1))])
              ((breakpoint-event-body breakpoint) client threadid stack))]))
  
  (define (signature->type-tag sig)
    (char->integer (string-ref sig 0)))
  
  (define (implement breakpoint loc)
    ;; (debug "implement" breakpoint loc)
    (let* ([client (location-client loc)]
           [dispatcher (client-dispatcher client)]
           [locID (if (locationID? loc) loc (loc->locationID loc))]
           [requestid 
            (send
             dispatcher
             add-request
             event-kind-breakpoint
             suspend-policy-event-thread  ; suspend-policy-all 
             (list (list 'locationonly locID))
             (lambda (event) (call-breakpoint client breakpoint event)))])
      (hash-put! (breakpoint-implemented-locs breakpoint) loc requestid)))
  
  (define (unimplement breakpoint loc)
    (let* ([client (location-client loc)]
           [dispatcher (client-dispatcher client)]
           [hash (breakpoint-implemented-locs breakpoint)])
      (send dispatcher clear-request event-kind-breakpoint (hash-get hash loc))
      (hash-remove! hash loc)))
  
  (define (wait c) 
    (let ([sem (make-semaphore 0)])
      (frp:proc->signal
       false (lambda () (semaphore-post sem))
       (client-run-trigger c))
      (semaphore-wait sem)))

  (provide (all-from-except "jdwp.ss" connect)
           make-location
           location?
           location-clazz
           location-method
           location-line
           location-client
           trace
           trace/enabled
           jval*
           jdot*
           &jdot*
           jcall*
           v
           jloc*
           idx
           here
           wait

           dyn-locationID->dyn-loc
           
           bind
           jlambda
           (rename make-jlambda-proc jlambda*)
           call-jlambda

           find-main-thread
           find-main-threadid
           find-main-stack
           
           create-recorder
           current-recorder
           recorder-data
           recorder-entry-timestamp
           recorder-playback-fast
           recorder-playback-realtime
           
           client-run-trigger 
           client-classload-event 
           client-unrequested-events
           client-stop-locs
           (rename jdi:connect-vm connect-vm)
           (rename jdi:start-vm start-vm)
           disconnect-vm
           create-breakpoint)
  
  )
