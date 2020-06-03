(require (lib "match.ss"))
(require "../jdb.ss")
(require "../base-gm.ss")

(define client (start-vm "Foobar" 100))

(define stoped-locs (client-stop-locs client))

(define stoped-methods
  (catcher-exn-e
   ((stoped-locs . ==> . find-main-thread)
    . ==> . 
    (match-lambda 
        [#f "no main thread"]
      [() "nowhere"]
      [(top tail ...)
       (location-method (dyn-locationID->dyn-loc top))]))))

(define profile-hash (make-hash 'equal))

(define profile
  (hold empty
        (stoped-methods
         . ==> .
         (lambda (method)
           (let ([cnt (add1 (hash-get profile-hash method (lambda () 0)))])
             (hash-put! profile-hash method cnt)
             (hash-pairs profile-hash))))))

(define profile-str
  (apply
   string-append
   (map
    (match-lambda [(name . cnt) (format "~a ~a~n" name cnt)])
    profile)))

(define run 
  (hold true (merge-e ((changes (delay-by profile 100)) . -=> . false)
                      ((changes profile) . -=> . true))))

(monitor "run" run)
(monitor "stoped-methods" stoped-methods)
(list 'profile profile-str)

(set-cell! (client-run-trigger client) run)
