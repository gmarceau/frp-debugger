(module jdi-test2 mzscheme
  (require "jdi.ss"
           "base-gm.ss"
           (lib "plt-match.ss")
           (lib "class.ss"))

  (define-values (c c-event-chn) (connect "canuk" 8001))
  (create-breakpoint (make-location "Foobar" "bar" 1 c)
                     '(this i)
                     (lambda (stack location this i) 
                       (debug "breakpoint:" (v (jdot (v this)  "xField")) (v i))))
#;                     
  (define c-dispatcher 
    (make-per-request-dispatcher 
     c c-event-chn
     (lambda (event)
       (debug "o-of-the-b event:" event))))
  
  ;(pretty-debug (query c (encode-virtualmachine-allclasses)))
#;  
  (send c-dispatcher add-request
        event-kind-class-prepare
        suspend-policy-all
        '((classmatch "Foobar"))
        (lambda (e)
          
          (define-values (foobar-typetag foobar-reftypeid)
            (match (query c (encode-virtualmachine-classesbysignature "LFoobar;"))
                   [(list (struct virtualmachine--classesbysignature (reftypetag typeid status)))
                    (values reftypetag typeid)]))
          
          (define bar-methodid
            (let loop ([cur (query c (encode-referencetype-methods foobar-reftypeid))])
              (match cur
                     [(list (struct referencetype--methods (methodid name signature modbits)) tail ...)
                      (if (equal? name "bar") 
                          methodid
                          (loop tail))])))
          
          (define bar-linetable
            (query c (encode-method-linetable foobar-reftypeid bar-methodid)))
          
          (debug "bar-linetable:" bar-linetable)
          (send 
           c-dispatcher
           add-request
           event-kind-breakpoint
           suspend-policy-all
           (list (list 'locationonly 
                       (make-locationID 
                        foobar-typetag
                        foobar-reftypeid
                        bar-methodid
                        (method--linetable-start bar-linetable))))
           
           (lambda (event)
             (match event
                    [(list 'breakpoint
                           (struct event--composite--events--breakpoint (requestid threadid location)))
                     (match (query c (encode-threadreference-frames threadid 0 1))
                            [(list (struct threadreference--frames (frameid location)))
                             (debug "value i:" (tagged-value-val 
                                                (first
                                                 (query c (encode-stackframe-getvalues threadid frameid '((0 73)))))))])]
                    
                    [_ (pretty-debug "not-matched" event)])))))
  (query c (encode-virtualmachine-resume))
  (thread-suspend (current-thread))
  )
  
