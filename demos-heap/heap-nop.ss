(module heap-nop mzscheme
  (require "../jdwp.ss"
           (lib "list.ss")
           (lib "class.ss")
           "../jdi-symbol-table.ss"
           (lib "async-channel.ss"))
  (read-case-sensitive #t)
  (define-values (c e-chn) (connect "localhost" 8002))
  
  (query c (encode-eventrequest-set
            event-kind-class-prepare suspend-policy-all
            (list (list 'classmatch "Heap"))))

  (query c (encode-virtualmachine-resume))
  (printf "~a~n" (async-channel-get e-chn))
  (printf "~a~n" (async-channel-get e-chn))

  (define add-locID (loc->locationID (make-location "Heap" "add" 25 c)))
  (define pop-locID (loc->locationID (make-location "Heap" "extractMin" 102 c)))

  (define with-breakpoints #t)

  (when with-breakpoints
    (query c (encode-eventrequest-set
              event-kind-breakpoint suspend-policy-event-thread
              (list (list 'locationonly add-locID))))
    (query c (encode-eventrequest-set
              event-kind-breakpoint suspend-policy-event-thread
              (list (list 'locationonly pop-locID)))))

  (query c (encode-virtualmachine-resume))

  (let loop ([i 0])
    (let ([len (packet-header-length (packet-h (async-channel-get e-chn)))])
      (cond [(= len 50)
             (query c (encode-virtualmachine-resume))
             (loop (add1 i))]
            [else (printf "breaks ~a~n" i)
                  (exit)]))))


