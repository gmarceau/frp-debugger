(module heap-decode mzscheme
  (require "../jdwp.ss"
           (lib "list.ss")
           (lib "class.ss")
           "../jdi-symbol-table.ss"
           (lib "async-channel.ss"))
  (read-case-sensitive #t)
  (define-values (c e-chn) (connect "localhost" 8002))
  
  (define events (make-channel))
  (define (forward e) (channel-put events e))

  (define dis (make-per-request-dispatcher c e-chn (lambda (e) (channel-put events e))))

  (define (identity x) x)

  (send dis add-request
        event-kind-class-prepare suspend-policy-all
        (list (list 'classmatch "Heap")) 
        (lambda (e) (query c (encode-virtualmachine-suspend)) (forward e)))

  (query c (encode-virtualmachine-resume))
  (printf "~a~n" (channel-get events))
  (printf "~a~n" (channel-get events))

  (define add-locID (loc->locationID (make-location "Heap" "add" 25 c)))
  (define pop-locID (loc->locationID (make-location "Heap" "extractMin" 102 c)))

  (define with-breakpoints #t)

  (when with-breakpoints
    (send dis add-request  
          event-kind-breakpoint suspend-policy-event-thread
          (list (list 'locationonly add-locID)) 
          forward)
    (send dis add-request 
          event-kind-breakpoint suspend-policy-event-thread
          (list (list 'locationonly pop-locID)) 
          forward))

  (query c (encode-virtualmachine-resume))

  (let loop ([i 0])
    (let ([e (channel-get events)])
      (cond [(eq? 'breakpoint (first e))
             (loop (add1 i))]
            [(eq? 'vmdeath (first e))
             (printf "breaks ~a~n" i)
             (exit)]))))


