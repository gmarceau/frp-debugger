(module start-stop mzscheme
  (require "../jdwp.ss"
           (lib "async-channel.ss"))
  
  (define-values (c e-chn) (connect "localhost" 8002))
  (query c (encode-virtualmachine-resume))

  (let loop ([i 0])
    (let ([len (packet-header-length (packet-h (async-channel-get e-chn)))])
      (cond [(= len 21)
             (printf "events ~a~n" i)
             (exit)]
            [else (loop (add1 i))]))))
