(module codec mzscheme
  (require (lib "contract.ss")
           (lib "plt-match.ss")
           (lib "async-channel.ss")
           (lib "list.ss")
           (lib "etc.ss")
           "base-gm.ss"
           "jdwp_constants.ss")
  
  (define (shape? item) (or (list? item) (symbol? item)))
  
  (define-struct encoded-cmd (packet-id set-id cmd-id buf) (make-inspector))
  (define-struct objectID (id))
  (define-struct (threadID objectID) ())
  (define-struct (threadGroupID objectID) ())
  (define-struct (stringID objectID) ())
  (define-struct (classLoaderID objectID) ())
  (define-struct (classObjectID objectID) ())
  (define-struct (arrayID objectID) ())
  
  (define-struct referenceTypeID (id) (make-inspector))
  (define-struct (classID referenceTypeID) () (make-inspector))
  (define-struct (interfaceID referenceTypeID) ())
  (define-struct (arrayTypeID referenceTypeID) ())
  
  (define-struct methodID (id))
  (define-struct fieldID (id))
  (define-struct frameID (id))
  (define-struct locationID (type-tag classid methodid offset))
  (define-struct tagged-value (type-tag val))
  
  (define (referenceTypeID-equal? a b)
    (equal? (referenceTypeID-id a) (referenceTypeID-id b)))
  
  (define (referenceTypeID-null? ref)
    (= (integer-byte-string->integer (referenceTypeID-id ref) #t #t) 0))

  (define (objectID-equal? a b)
    (equal? (objectID-id a) (objectID-id b)))

  (define (objectID-null? ref)
    (= (integer-byte-string->integer (objectID-id ref) #t #t) 0))
  
  (define (methodid-equal? a b)
    (equal? (methodID-id a) (methodID-id b)))

  (define (threadid-equal? a b)
    (equal? (objectID-id a) (objectID-id b)))
  
  (define gen-packet-id
    (let ([last-id 6])
      (lambda ()
        (set! last-id (add1 last-id))
        last-id)))
  
  (define (safe-read-string len port)
    (let ([r (read-string len port)])
      (if (or (eof-object? r)
              (not (= (string-length r) len)))
          (raise r)
          r)))
  
  (define (encode set-id cmd-id data shape)
    (let* ([packet-id (gen-packet-id)]
           [header (make-cmd-header 0 ; placeholder for packet size
                                    packet-id
                                    0
                                    set-id
                                    cmd-id)]
           [content-buf (content->string (encode-data data shape))])
      (match header
             [(struct cmd-header (size packet-id flags set cmd))
              (make-encoded-cmd
               packet-id
               set-id
               cmd-id
               (string-append
                (header->string
                 (make-cmd-header
                  (+ header-length (string-length content-buf))
                  packet-id flags set cmd))
                content-buf))])))
  
  (define (encode-data data shape)
    (match 
     shape
     ['() ""]
     ['byte (enc-byte data)]
     ['char (enc-char data)]
     ['boolean (enc-bool data)]
     ['int (enc-int data)]
     ['long (enc-long data)]
     
     ['tagged_objectID (enc-tagged-objectID data)]
     
     ['objectID (objectID-id data)]
     ['threadID (assert (threadID? data) data) (objectID-id data)]
     ['threadGroupID (assert (threadGroupID? data)) (objectID-id data)]
     ['stringID (assert (stringID? data)) (objectID-id data)]
     ['classLoaderID (assert (classLoaderID? data)) (objectID-id data)]
     ['classObjectID (assert (classObjectID? data)) (objectID-id data)]
     ['arrayID (assert (arrayID? data)) (objectID-id data)]
     
     ['referenceTypeID (referenceTypeID-id data)]
     ['classID (assert (classID? data) data) (referenceTypeID-id data)]
     ['interfaceID (assert (interfaceID? data) (referenceTypeID-id data))]
     ['arrayTypeID (assert (arrayTypeID? data)) (referenceTypeID-id data)]
     
     ['methodID (methodID-id data)]
     ['fieldID (fieldID-id data)]
     ['frameID (frameID-id data)]
     ['location (enc-locationID data)]
     
     ['string (enc-string data)] 
     ['value (enc-value data)] 
     ['untagged-value (enc-untagged-value data)] 
     ['arrayregion (enc-arrayregion data)]
     
     [(list 'list size-shape list-shape) (enc-list data size-shape list-shape)]
     [(list 'struct constructor (list field-shapes ...))
      (enc-struct (map encode-data
                       data ;; assume struct data passed as list
                       field-shapes))]
     [(list 'cases tag-id-shape name-id-shape-alist ...) (enc-cases data tag-id-shape name-id-shape-alist)]))
  
  ;; a Header is a:
  ;;   (list Integer Integer Byte Byte Byte)
  
  ;; a Content is one of:
  ;;   string
  ;;   (listof Content)
  
  ;; a ReplyHeader is a:
  ;; (make-reply-header Integer Integer Byte TwoBytes)
  
  (define-struct packet-header (length id flags) (make-inspector)) 
  (define-struct (cmd-header packet-header) (set-id cmd-id) (make-inspector))
  (define-struct (reply-header packet-header) (error-symb error-text) (make-inspector))
  
  (define header-length 11)
  
  (define (header->string header)
    (match header
           [(struct cmd-header (packet-size packet-id flags set-id cmd-id))
            (let ([result
                   (format "~a~a~a~a~a"
                           (enc-int packet-size)
                           (enc-int packet-id)
                           (enc-byte flags)
                           (enc-byte set-id)
                           (enc-byte cmd-id))])
              (assert (= (string-length result) header-length))
              result)]))
  
  (define (content->string content)
    (if (string? content)
        content
        (apply string-append (map content->string content))))

  (define (enc-char c)
    (list->string (list c)))
  
  (define (enc-byte n) 
    (list->string (list (integer->char n))))
  
  (define (enc-bool b) 
    (if b (enc-byte 1) (enc-byte 0)))
  
  (define (enc-2byte n)
    (integer->integer-byte-string n 2 false true))
  
  (define (enc-int n)
    (integer->integer-byte-string n 4 true true))
  
  (define (enc-long n)
    (integer->integer-byte-string n 8 true true))
  
  (define (enc-float n)
    (real->floating-point-byte-string n 4 true))
  
  (define (enc-double n)
    (real->floating-point-byte-string n 8 true))
  
  (define (enc-tagged-objectID data)
    (assert (objectID? data))
    (enc-value data))
  
  (define (enc-value data)
    (let-values ([(tag buf) (enc-value/tag data)])
      (string-append (enc-byte tag) buf)))
  
  (define (enc-value/tag data)
    (let loop ([cur value-tag-alist])
      (match cur
             [(list (list id pred-fn dec-fn enc-fn) tail ...)
              (cond [(and (tagged-value? data)
                          (= id (tagged-value-type-tag data)))
                     (values id (enc-fn (tagged-value-val data)))]
                    [(and (not (tagged-value? data))
                          (pred-fn data))
                     (values id (enc-fn data))]
                    [else (loop tail)])])))
  
  (define (enc-untagged-value val)
    (let-values ([(tag buf) (enc-value/tag val)]) buf))
  
  (define (enc-locationID data)
    (string-append
     (enc-byte (locationID-type-tag data))
     (referenceTypeID-id (locationID-classid data))
     (methodID-id (locationID-methodid data))
     (enc-long (locationID-offset data))))
  
  (define (enc-string str)
    (string-append (enc-int (string-length str)) str))
  
  (define (enc-arrayregion val) (assert false)) ;; TODO
  
  (define (enc-list data size-shape shape)
    (apply
     string-append
     (cons (encode-data (length data) size-shape)
           (map (lambda (value)
                  (encode-data value shape))
                data))))
  
  (define (enc-struct encoded-fields)
    (apply
     string-append
     encoded-fields))
  
  (define (enc-cases data tag-id-shape name-id-shape-alist)
    (let* ([tag (first data)]
           [content (second data)]
           [entry (assq tag name-id-shape-alist)])
      (match entry
             [(list name id shape) 
              (string-append (encode-data id tag-id-shape)
                             (encode-data content shape))]
             [#f
              (debug "no such case:" tag name-id-shape-alist)
              (assert false)]
             )))
  
  ;; -----------------------------------------------------------------------
  
  (define (decode-header str)
    (let ([len (v1 (dec-int (substring str 0 4)))]
          [id (v1 (dec-int (substring str 4 8)))]
          [flags (v1 (dec-byte (substring str 8 9)))])
      (if (= (bitwise-and #x080 flags) 0)
          ;; Command packet
          (make-cmd-header len id flags
                           (v1 (dec-byte (substring str 9 10)))
                           (v1 (dec-byte (substring str 10 11))))
          ;; Reply packet
          (let ([error-code (v1 (dec-2byte (substring str 9 11)))])
            (match (hash-get error-constants error-code)
                   [(list symb text)
                    (make-reply-header len id flags symb text)])))))
  
  (define-syntax (v1 stx)
    (syntax-case stx ()
      [(v1 values-sxp) #'(call-with-values (lambda () values-sxp)
                           (lambda args (car args)))]))
  
  (define (decode c str shape)
    (let-values ([(r len) (decode/size c str shape)])
      (assert (= len (string-length str)))
      r))
  
  (define (decode/size c str shape)
    ;;(debug "decode/size" shape)
    (match 
     shape
     ['() (values (void) 0)]
     ['byte (dec-byte str)]
     ['char (dec-char str)]
     ['boolean (dec-bool str)]
     ['int (dec-int str)]
     ['long (dec-long str)]
     
     ['tagged_objectID (dec-tagged-objectID c str)]
     
     ['objectID (dec-objectID/constructor c make-objectID str)]
     ['threadID (dec-objectID/constructor c make-threadID str)]
     ['threadGroupID (dec-objectID/constructor c make-threadGroupID str)]
     ['stringID (dec-objectID/constructor c make-stringID str)]
     ['classLoaderID (dec-objectID/constructor c make-classLoaderID str)]
     ['classObjectID (dec-objectID/constructor c make-classObjectID str)]
     ['arrayID (dec-objectID/constructor c make-arrayID str)]
     
     ['referenceTypeID (dec-referenceTypeID/constructor c make-referenceTypeID str)]
     ['classID (dec-referenceTypeID/constructor c make-classID str)]
     ['interfaceID (dec-referenceTypeID/constructor c make-interfaceID str)]
     ['arrayTypeID (dec-referenceTypeID/constructor c make-arrayTypeID str)]
     
     ['methodID (dec-methodID c str)]
     ['fieldID  (dec-fieldID c str)]
     ['frameID (dec-frameID c str)]
     ['location (dec-locationID c str)]
     
     ['string (dec-string str)]
     ['value (dec-value c str)]
     ['untagged-value (error "Cannot decode untagged values")]
     ['arrayregion (dec-arrayregion c str)]
     
     [(list 'struct ctor struct-shapes) (dec-struct c ctor struct-shapes str)]
     [(list 'list count-shape list-item-shape) (dec-sized-list c str count-shape list-item-shape)]
     [(list 'cases tag-id-shape name-id-shape-alist ...) (dec-cases c str tag-id-shape name-id-shape-alist)]
     ))
  
  (define (dec-byte buf)
    (values (integer-byte-string->integer
             (string-append "\0" (substring buf 0 1))
             #t #t)
            1))

  (define (dec-char buf)
    (let-values ([(v len) (dec-2byte buf)])
      (values (integer->char v) len)))
  
  (define (dec-2byte buf)
    (values (integer-byte-string->integer (substring buf 0 2) #f #t) 2))
  
  (define (dec-bool buf)
    (values (not (zero? (char->integer (string-ref buf 0)))) 1))
  
  (define (dec-int str)
    (values (integer-byte-string->integer (substring str 0 4) #t #t) 4))
  
  (define (dec-long str)
    (values (integer-byte-string->integer (substring str 0 8) #t #t) 8))
  
  (define (dec-objectID/constructor c constructor str)
    (values (constructor (substring str 0 (client-objectidsize c)))
            (client-objectidsize c)))
  
  (define (dec-referenceTypeID/constructor c constructor str)
    (values (constructor (substring str 0 (client-referencetypeidsize c)))
            (client-referencetypeidsize c)))
  
  (define (dec-objectID c str) (dec-objectID/constructor c make-objectID str))
  
  (define (dec-classObjectID c str) (dec-objectID/constructor c make-classObjectID str))
  
  (define (dec-arrayID c str) (dec-objectID/constructor c make-arrayID str))
  
  (define (dec-threadGroupID c str) (dec-objectID/constructor c make-threadID str))
  
  (define (dec-classLoaderID c str) (dec-objectID/constructor c make-classLoaderID str))
  
  (define (dec-stringID c str) (dec-objectID/constructor c make-stringID str))
  
  (define (dec-threadID c str) (dec-objectID/constructor c make-threadId str))
  
  (define (dec-methodID c str)
    (values (make-methodID (substring str 0 (client-methodidsize c)))
            (client-methodidsize c)))
  
  (define (dec-fieldID c str)
    (values (make-fieldID (substring str 0 (client-fieldidsize c)))
            (client-fieldidsize c)))
  
  (define (dec-frameID c str)
    (values (make-frameID (substring str 0 (client-frameidsize c)))
            (client-frameidsize c)))
  
  (define (dec-locationID c str)
    (let-values ([(items len) (dec-list c str '(byte referencetypeid methodid long))])
      (values (apply make-locationID items) len)))
  
  (define (dec-string buf)
    (let-values ([(str-len tag-len) (dec-int buf)])
      (values (substring buf tag-len (+ tag-len str-len)) (+ tag-len str-len))))
  
  (define (dec-float buf) (values (floating-point-byte-string->real 
                                   (substring buf 0 4) #t) 4))
  
  (define (dec-double buf) (values (floating-point-byte-string->real 
                                    (substring buf 0 8) #t) 8))
  
  (define (dec-tagged-objectID c str) 
    (let-values ([(v v-len) (dec-value c str)])
      (values (tagged-value-val v) v-len)))
  
  (define (dec-value c buf) 
    (let-values ([(tag tag-len) (dec-byte buf)])
      ;;(debug "dec-value" (client-objectidsize c) tag tag-len (string-length buf) buf)
      (let-values ([(v v-len)
                    (dec-untagged-value 
                     c tag 
                     (substring buf tag-len (string-length buf)))])
        (values (make-tagged-value tag v) (+ tag-len v-len)))))
  
  (define (dec-untagged-value c tag str)
    (let* ([decoder
            (let loop ([cur value-tag-alist])
              (match cur
                     [(list (list id pred-fn dec-fn enc-fn) tail ...)
                      (if (= tag id) dec-fn (loop tail))]))])
      (decoder c str)))
  
  (define (dec-arrayregion c buf) 
    (letrec-values
     ([(tag tag-len) (dec-byte buf)]
      [(size size-len) (dec-int (substring buf tag-len (string-length buf)))]
      [(result) (make-vector size)]
      [(is-primitive-tag) (tag-is-primitive? tag)]
      [(total-size)
       (let loop ([i 0] [offset (+ tag-len size-len)])
         (if (< i size)
             (letrec-values ([(sub) (substring buf offset (string-length buf))]
                             [(v v-len)
                              (if is-primitive-tag
                                  (dec-untagged-value c tag sub)
                                  (dec-value c sub))])
                            (vector-set! result i v)
                            (loop (add1 i) (+ offset v-len)))
             offset))])
     (values result total-size)))
  
  (define (dec-struct c ctor struct-shapes str)
    (let-values ([(items len) (dec-list c str struct-shapes)])
      (values (apply ctor items) len)))
  
  (define (dec-list c str shapes)
    ;;(debug "dec-list" shapes)
    (cond
     [(empty? shapes) (values empty 0)]
     [else  (let-values ([(first-data first-len) (decode/size c str (first shapes))])
              (let-values ([(rest-data rest-len)
                            (dec-list c (substring str first-len (string-length str))
                                      (rest shapes))])
                (values (cons first-data rest-data)
                        (+ first-len rest-len))))]))
  
  (define (dec-sized-list c str count-shape list-item-shape)
    (let-values ([(count count-len) (decode/size c str count-shape)])
      (let-values ([(list-value decoded-list-data-size)
                    (dec-sized-list-items c (substring str count-len (string-length str))
                                          count
                                          list-item-shape)])
        (values list-value (+ count-len decoded-list-data-size)))))
  
  
  (define (dec-sized-list-items c str count list-item-shape)
    ;;(debug "dec-sized-list-items. count:" count "str: '" str"'")
    (cond
     [(zero? count) (values empty 0)]
     [else (let-values ([(first-data first-len) (decode/size c str list-item-shape)])
             (let-values ([(rest-data rest-len)
                           (dec-sized-list-items c (substring str first-len (string-length str))
                                                 (sub1 count)
                                                 list-item-shape)])
               (values (cons first-data rest-data)
                       (begin ;(debug "dec-sized-list-items: current sum is" (+ first-len rest-len))
                         (+ first-len rest-len)))))]))
  
  (define (dec-cases c str tag-id-shape name-id-shape-alist)
    (let-values ([(tag tag-len) (decode/size c str tag-id-shape)])
      (let-values ([(name shape)
                    (let loop ([cur name-id-shape-alist])
                      (match cur
                             [(list (list name id shape) tail ...)
                              (if (= tag id) 
                                  (values name shape)
                                  (loop tail))]))])
        (let-values ([(body body-len) 
                      (decode/size c (substring str tag-len (string-length str)) shape)])
          (values (list name body) (+ tag-len body-len))))))
  
  
  ;; -----------------------------------------------------------------------
  
  ;; a Reply is:
  ;; (make-packet ReplyHeader string-buffer)
  
  (define-struct packet (h buf) (make-inspector))
  
  (define (read-packet in)
    (let* ([header-buf (safe-read-string 11 in)]
           [header (decode-header header-buf)]
           [data-buf (safe-read-string (- (packet-header-length header) 11) in)])
      (make-packet header data-buf)))
  
  (define (handshake in out)
    (display "JDWP-Handshake" out)
    (flush-output out)
    (let ([r (safe-read-string 14 in)])
      (assert (equal? r "JDWP-Handshake"))
      r))
  
  (define (get-id-sizes in out)
    (let ([e-cmd (encode 1 7 () `())])
      (display (encoded-cmd-buf e-cmd) out)
      (flush-output out)
      (let loop ([r (read-packet in)]
                 [pending-packets empty])
        (if (and (reply-header? (packet-h r))
                 (= (packet-header-id (packet-h r))
                    (encoded-cmd-packet-id e-cmd)))
            (values (v1 (decode/size 'dummy (packet-buf r) `(struct ,list (int int int int int))))
                    (reverse pending-packets))
            (loop (read-packet in)
                  (cons r pending-packets))))))
  
  (define-struct client (in out 
                            channels
                            event-channel
                            fieldidsize
                            methodidsize
                            objectidsize
                            referencetypeidsize
                            frameidsize))
  
  ;; [event-classifier-fn] takes a cmd packet and returns a event-class for that
  ;; packet. Event classes are be any datum. They are compared internally with
  ;; equal? Event classes are used by [event-request/classifier] to route similar events
  ;; accross a particular channel.
  (define (connect host port)
    (let-values ([(in out) (tcp-connect host port)])
      (connect/ports in out)))
  
  (define (connect/ports in out)
    (handshake in out)
    (let-values ([(sizes pending-packets) (get-id-sizes in out)])
      (match sizes
             [(list fieldidsize methodidsize objectidsize referencetypeidsize frameidsize)
              (let ([client (make-client in out 
                                         (make-hash)
                                         (make-async-channel)
                                         fieldidsize
                                         methodidsize
                                         objectidsize
                                         referencetypeidsize
                                         frameidsize)])
                (start-listening client pending-packets)
                (values client (client-event-channel client)))])))

  
  (define (start-listening client pending-packets)
    (thread
     (lambda ()
       (for-each (lambda (p) (dispatch-cmd client p))
                 pending-packets)
       
       (with-handlers
           ([eof-object? (lambda (exn) (void))])
         
         (let loop ()
           (dispatch-packet client (read-packet (client-in client)))
           (loop))))))
  
  (define (dispatch-packet client p) 
    (match (packet-h p)
           [(struct reply-header (_ _ _ _ _)) (dispatch-reply client p)]
           [(struct cmd-header (_ _ _ _ _)) (dispatch-cmd client p)]))
  
  (define (dispatch-cmd client p)
    (async-channel-put (client-event-channel client) p))
  
  (define (dispatch-reply client p)
    (match p
           [(struct packet ((struct reply-header (_ id _ _ _)) buf))
            (let ([channel (hash-get (client-channels client) id (lambda () #f))])
              (cond [channel
                     (hash-remove! (client-channels client) id)
                     (channel-put channel p)]
                    [else (debug "Unrequested VM message:" id p)]))]))
  
  (define (query/encoded client encoded)
    (let ([channel (make-channel)])
      (hash-put! (client-channels client) 
                 (encoded-cmd-packet-id encoded) 
                 channel)
      (display (encoded-cmd-buf encoded) (client-out client))
      (flush-output (client-out client))
      (channel-get channel)))
  
  (define (downcast-to-classid refid)
    (make-classID (referenceTypeId-id refid)))
  
  (define (todo? v) false)

  (define (tag-is-primitive? tag)
    (match tag
           [(or 66 67 68 70 73 74 83 86 9) true]
           [_ false]))

  (define value-tag-alist
    (list 
     ;; tag pred-fn dec-fn enc-fn
     (list 66 todo? (lambda (_ v) (dec-byte v)) enc-byte)
     (list 67 char? (lambda (_ v) (dec-char v)) enc-char)
     (list 68 real? (lambda (_ v) (dec-double v)) enc-double)
     (list 70 todo? (lambda (_ v) (dec-float v)) enc-float)
     (list 73 integer? (lambda (_ v) (dec-int v)) enc-int)
     (list 74 todo? (lambda (_ v) (dec-long v)) enc-long)
     (list 83 todo? (lambda (_ v) (dec-2byte v)) enc-2byte)
     
     (list 86 void? (lambda (_ v) (void)) (lambda (_) ""))
     (list 90 boolean? (lambda (_ v) (dec-bool v)) objectID-id)
     
     (list 91 arrayID? dec-arrayID objectID-id)
     (list 99 classObjectID? dec-classObjectID objectID-id)
     (list 103 threadGroupID? dec-threadGroupID objectID-id)
     (list 108 classLoaderID? dec-classLoaderID objectID-id)
     (list 115 stringID? dec-stringID objectID-id)
     (list 116 threadID? dec-threadID objectID-id)
     
     (list 0 
           (lambda (v) (and (objectID? v) (objectID-null? v))) 
           (lambda (c v) (values (make-objectID (make-string 8 (integer->char 0))) 7))
           (lambda (_) (assert false)))
     (list 76 objectID? dec-objectID objectID-id)))
  
  (provide methodid-equal?
           threadid-equal?
           locationID
           locationID?
           make-locationID
           locationID-type-tag
           locationID-classid
           locationID-methodid
           locationID-offset
           )
  
  
  (provide/contract (connect (string? number? . -> . (values client? async-channel?)))
                    (connect/ports (port? port? . -> . (values client? async-channel?)))
                    (client? (any? . -> . boolean?))
                    
                    (encode (number? number? any? shape? . -> . encoded-cmd?))
                    (decode (client? string? shape? . -> . any))
                    
                    (query/encoded
                     (client? encoded-cmd? . -> . any))
                    
                    (struct encoded-cmd
                            ((packet-id number?)
                             (set-id number?)
                             (cmd-id number?)
                             (buf string?)))
                    
                    (struct packet
                            ((h packet-header?) 
                             (buf string?)))
                    
                    (struct packet-header 
                            ((length number?)
                             (id number?)
                             (flags number?)))
                    
                    (struct cmd-header 
                            ((set-id number?)
                             (cmd-id number?)))
                    
                    (struct reply-header
                            ((error-symb symbol?)
                             (error-text string?)))
                    #;
                    (struct locationID
                            ((type-tag number?)
                             (classid referenceTypeID?)
                             (methodid methodID?)
                             (offset number?)))
                    
                    (struct tagged-value
                            ((type-tag number?)
                             (val any?)))
                    
                    (objectID? (any? . -> . boolean?))
                    (threadID? (any? . -> . boolean?))
                    (threadGroupID? (any? . -> . boolean?))
                    (stringID? (any? . -> . boolean?))
                    (classLoaderID? (any? . -> . boolean?))
                    (classObjectID? (any? . -> . boolean?))
                    (arrayID? (any? . -> . boolean?))
                    (referenceTypeID? (any? . -> . boolean?))
                    (classID? (any? . -> . boolean?))
                    (interfaceID? (any? . -> . boolean?))
                    (arrayTypeID? (any? . -> . boolean?))
                    (methodID? (any? . -> . boolean?))
                    (fieldID? (any? . -> . boolean?))
                    (frameID? (any? . -> . boolean?))
                    
                    (referenceTypeID-equal? (referenceTypeID? referenceTypeID? . -> . boolean?))
                    (referenceTypeID-null? (referenceTypeID? . -> . boolean?))
                    (objectID-equal? (objectID? objectID? . -> . boolean?))
                    (objectID-null? (objectID? . -> . boolean?))
                                        ;                    (methodID-equal? (methodID? methodID? . -> . boolean?))
                    (downcast-to-classid (referenceTypeID? . -> . classID?))
                    (tag-is-primitive? (number? . -> . boolean?))
                    )
  
  )
