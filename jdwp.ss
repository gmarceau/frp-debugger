(module jdwp mzscheme
  (require "jdwp_spec3.ss"
           "jdwp_constants.ss"
           "codec.ss"
           (lib "async-channel.ss")
           (lib "class.ss")
           (lib "contract.ss")
           (lib "plt-match.ss")
           (lib "pretty.ss")
           "base-gm.ss")
  
  (define (query client cmd)
    (match cmd
           [(struct encoded-cmd (packet-id set-id cmd-id cmd-buf))
            (let ([p (query/encoded client cmd)])
              (match p
                     [(struct packet ((struct reply-header (_ _ _ error-symb error-text)) reply-buf))
                      (unless (eq? error-symb 'none)
                        (raise (make-exn:jdwp (format "JDWP error: ~a" error-text)
                                              (current-continuation-marks)
                                              error-symb p)))
                      (let* ([decode-fn (hash-get (hash-get command-ids-hash set-id) cmd-id)])
                        (decode-fn client reply-buf))]))]))
  
  
  (define-struct (exn:jdwp exn) (error-symb packet))

  (define (pretty-debug . args)
    (methodid-equal?)
    (for-each
     (lambda (item)
       (pretty-print (struct->list/deep item))
       (display " "))
     args)
    (newline))

  (define (event-request&thread-id event)
    (match event
           [(list 'vmstart (struct event--composite--events--vmstart 
                                   (requestid thread)))
            (values requestid thread)]
           [(list 'singlestep (struct event--composite--events--singlestep 
                                      (requestid thread location)))
            (values requestid thread)]
           [(list 'breakpoint (struct event--composite--events--breakpoint 
                                      (requestid thread location)))
            (values requestid thread)]
           [(list 'methodentry (struct event--composite--events--methodentry 
                                       (requestid thread location)))
            (values requestid thread)]
           [(list 'methodexit (struct event--composite--events--methodexit 
                                      (requestid thread location)))
            (values requestid thread)]
           [(list 'exception (struct event--composite--events--exception 
                                     (requestid thread location exception catchlocation)))
            (values requestid thread)]
           [(list 'threadstart (struct event--composite--events--threadstart 
                                       (requestid thread)))
            (values requestid thread)]
           [(list 'threaddeath (struct event--composite--events--threaddeath 
                                       (requestid thread)))
            (values requestid thread)]
           [(list 'classprepare (struct event--composite--events--classprepare 
                                        (requestid thread reftypetag typeid signature status)))
            (values requestid thread)]
           [(list 'classunload (struct event--composite--events--classunload 
                                       (requestid signature)))
            (values requestid false)]
           [(list 'fieldaccess (struct event--composite--events--fieldaccess 
                                       (requestid thread location reftypetag typeid fieldid object)))
            (values requestid thread)]
           [(list 'fieldmodification 
                  (struct event--composite--events--fieldmodification 
                          (requestid thread location reftypetag typeid fieldid object valuetobe)))
            (values requestid thread)]
           [(list 'vmdeath exitcode) (values 0 false)]))
 
  (define (event-request-id event)
    (let-values ([(requestid threadid) (event-request&thread-id event)])
      requestid))

  (define (event-thread-id event)
    (let-values ([(requestid threadid) (event-request&thread-id event)])
      threadid))

  (define (partition fn lst)
    (let ([trues (filter fn lst)]
          [falses (filter (lambda (i) (not (fn i))) lst)])
      (values trues falses)))
  
  (define (resume-vm-after-event client packet)
    (match packet
           [(struct event--composite (0 (list event tail ...)))
            (void)]
           
           [(struct event--composite (1 (list event tail ...)))
            (query client (encode-threadreference-resume (event-thread-id event)))]
           
           [(struct event--composite (2 _))
            (query client (encode-virtualmachine-resume))]))

  (define per-request-dispatcher%
    (class object%
      (init-field client)
      (init-field in-channel)
      (init spontaneous-event-callback)

      (define event-requests (make-hash))
      (define unrequested empty)

      (define sem (make-semaphore 1))

      (define/public (flush-unrequested)
        (with-semaphore
         sem
         (lambda ()
           (let ([result unrequested])
             (set! unrequested empty)
             result))))

      (define/public (add-request-channel eventkind suspendpolicy modifiers)
        (let ([chn (make-channel)])
          (add-request eventkind suspendpolicy modifiers (lambda (e) (channel-put chn e)))
          chn))

      (define/public (add-request eventkind suspendpolicy modifiers callback)
        (let ([id (query client (encode-eventrequest-set eventkind suspendpolicy modifiers))])
          (with-semaphore
           sem
           (lambda () 
             (hash-put! event-requests id callback)
             (let-values ([(now-pending still-unrequested)
                           (partition
                            (lambda (event) (= (event-request-id event) id))
                            unrequested)])
               (set! unrequested still-unrequested)
               (for-each (lambda (event) (callback event)) now-pending))))
          id))

      (define/public (clear-request eventkind eventid)
        (query client (encode-eventrequest-clear eventkind eventid))

        (with-semaphore
         sem
         (lambda () (hash-remove! event-requests eventid))))

      (define (dispatch-event event)
        (let* ([id (event-request-id event)]
               [callback (with-semaphore sem (lambda () (hash-get event-requests id (lambda () false))))])
          (if callback
              (callback event)
              (with-semaphore sem (lambda () (set! unrequested (cons event unrequested)))))))

      (thread 
       (lambda ()
         (let loop ()
           (let* ([p (async-channel-get in-channel)])
             (if (not (packet? p))
                 (dispatch-event p)
                 (let* ([decoded (decode-event-composite client (packet-buf p))]
                        [events (event--composite-events decoded)])
                   (for-each dispatch-event events)
                   (resume-vm-after-event client decoded))))
           (loop))))
             
      (hash-put! event-requests 0 spontaneous-event-callback)
      (super-new)))

  (define (make-per-request-dispatcher client async-channel spontaneous-event-callback)
    (make-object per-request-dispatcher% client async-channel spontaneous-event-callback))

  (provide
   (all-from "jdwp_spec3.ss")
   (all-from "jdwp_constants.ss")
   (all-from-except "codec.ss" encode decode query/encoded)
   query)
   
  (provide/contract
   ;(query (client? encoded-cmd? . -> . any))
   (exn:jdwp? (any? . -> . boolean?))
   (pretty-debug (() any? . ->* . (void?)))
   (make-per-request-dispatcher
    (client? async-channel? procedure? 
             . -> .
             (object-contract
              (flush-unrequested (-> list?))
              (add-request-channel (number? number? any? . -> . channel?))
              (add-request (number? number? any? procedure? . -> . number?))
              (clear-request (number? number? . -> . void?))))))
  )  