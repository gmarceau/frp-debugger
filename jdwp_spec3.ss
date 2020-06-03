;;; This file was generated using mangle2.ss
;;;
;;;
(module jdwp_spec3 mzscheme
  (require "codec.ss")
  (provide (all-defined))
  (begin
   (begin
     (define-struct
       virtualmachine--version
       (vm-description jdwpmajor jdwpminor vmversion vmname)
       (make-inspector))
     (define (encode-virtualmachine-version) (encode 1 1 () `()))
     (define (decode-virtualmachine-version c str)
       (decode c str `(struct ,make-virtualmachine--version (string int int string string)))))
   (begin
     (define-struct virtualmachine--classesbysignature (reftypetag typeid status) (make-inspector))
     (define (encode-virtualmachine-classesbysignature arg) (encode 1 2 arg `string))
     (define (decode-virtualmachine-classesbysignature c str)
       (decode
         c
         str
         `(list int (struct ,make-virtualmachine--classesbysignature (byte classid int))))))
   (begin
     (define-struct
       virtualmachine--allclasses
       (reftypetag typeid signature status)
       (make-inspector))
     (define (encode-virtualmachine-allclasses) (encode 1 3 () `()))
     (define (decode-virtualmachine-allclasses c str)
       (decode
         c
         str
         `(list int (struct ,make-virtualmachine--allclasses (byte referencetypeid string int))))))
   (begin
     (define (encode-virtualmachine-allthreads) (encode 1 4 () `()))
     (define (decode-virtualmachine-allthreads c str) (decode c str `(list int threadid))))
   (begin
     (define (encode-virtualmachine-toplevelthreadgroups) (encode 1 5 () `()))
     (define (decode-virtualmachine-toplevelthreadgroups c str)
       (decode c str `(list int threadgroupid))))
   (begin
     (define (encode-virtualmachine-dispose) (encode 1 6 () `()))
     (define (decode-virtualmachine-dispose c str) (decode c str `())))
   (begin
     (define-struct
       virtualmachine--idsizes
       (fieldidsize methodidsize objectidsize referencetypeidsize frameidsize)
       (make-inspector))
     (define (encode-virtualmachine-idsizes) (encode 1 7 () `()))
     (define (decode-virtualmachine-idsizes c str)
       (decode c str `(struct ,make-virtualmachine--idsizes (int int int int int)))))
   (begin
     (define (encode-virtualmachine-suspend) (encode 1 8 () `()))
     (define (decode-virtualmachine-suspend c str) (decode c str `())))
   (begin
     (define (encode-virtualmachine-resume) (encode 1 9 () `()))
     (define (decode-virtualmachine-resume c str) (decode c str `())))
   (begin
     (define (encode-virtualmachine-exit) (encode 1 10 () `()))
     (define (decode-virtualmachine-exit c str) (decode c str `())))
   (begin
     (define (encode-virtualmachine-createstring arg) (encode 1 11 arg `string))
     (define (decode-virtualmachine-createstring c str) (decode c str `stringid)))
   (begin
     (define-struct
       virtualmachine--capabilities
       (canwatchfieldmodification
         canwatchfieldaccess
         cangetbytecodes
         cangetsyntheticattribute
         cangetownedmonitorinfo
         cangetcurrentcontendedmonitor
         cangetmonitorinfo)
       (make-inspector))
     (define (encode-virtualmachine-capabilities) (encode 1 12 () `()))
     (define (decode-virtualmachine-capabilities c str)
       (decode
         c
         str
         `(struct
            ,make-virtualmachine--capabilities
            (boolean boolean boolean boolean boolean boolean boolean)))))
   (begin
     (define-struct virtualmachine--classpaths (basedir classpaths bootclasspaths) (make-inspector))
     (define (encode-virtualmachine-classpaths) (encode 1 13 () `()))
     (define (decode-virtualmachine-classpaths c str)
       (decode
         c
         str
         `(struct ,make-virtualmachine--classpaths (string (list int string) (list int string))))))
   (begin
     (define (encode-virtualmachine-disposeobjects arg)
       (encode 1 14 arg `(list int (struct 'not-defined (objectid int)))))
     (define (decode-virtualmachine-disposeobjects c str) (decode c str `())))
   (begin
     (define (encode-virtualmachine-holdevents) (encode 1 15 () `()))
     (define (decode-virtualmachine-holdevents c str) (decode c str `())))
   (begin
     (define (encode-virtualmachine-releaseevents) (encode 1 16 () `()))
     (define (decode-virtualmachine-releaseevents c str) (decode c str `())))
   (begin
     (define-struct
       virtualmachine--capabilitiesnew
       (canwatchfieldmodification
         canwatchfieldaccess
         cangetbytecodes
         cangetsyntheticattribute
         cangetownedmonitorinfo
         cangetcurrentcontendedmonitor
         cangetmonitorinfo
         canredefineclasses
         canaddmethod
         canunrestrictedlyredefineclasses
         canpopframes
         canuseinstancefilters
         cangetsourcedebugextension
         canrequestvmdeathevent
         cansetdefaultstratum
         reserved16
         reserved17
         reserved18
         reserved19
         reserved20
         reserved21
         reserved22
         reserved23
         reserved24
         reserved25
         reserved26
         reserved27
         reserved28
         reserved29
         reserved30
         reserved31
         reserved32)
       (make-inspector))
     (define (encode-virtualmachine-capabilitiesnew) (encode 1 17 () `()))
     (define (decode-virtualmachine-capabilitiesnew c str)
       (decode
         c
         str
         `(struct
            ,make-virtualmachine--capabilitiesnew
            (boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean
              boolean)))))
   (begin
     (define (encode-virtualmachine-redefineclasses arg)
       (encode 1 18 arg `(list int (struct 'not-defined (referencetypeid (list int byte))))))
     (define (decode-virtualmachine-redefineclasses c str) (decode c str `())))
   (begin
     (define (encode-virtualmachine-setdefaultstratum arg) (encode 1 19 arg `string))
     (define (decode-virtualmachine-setdefaultstratum c str) (decode c str `())))
   (begin
     (define (encode-referencetype-signature arg) (encode 2 1 arg `referencetypeid))
     (define (decode-referencetype-signature c str) (decode c str `string)))
   (begin
     (define (encode-referencetype-classloader arg) (encode 2 2 arg `referencetypeid))
     (define (decode-referencetype-classloader c str) (decode c str `classloaderid)))
   (begin
     (define (encode-referencetype-modifiers arg) (encode 2 3 arg `referencetypeid))
     (define (decode-referencetype-modifiers c str) (decode c str `int)))
   (begin
     (define-struct referencetype--fields (fieldid name signature modbits) (make-inspector))
     (define (encode-referencetype-fields arg) (encode 2 4 arg `referencetypeid))
     (define (decode-referencetype-fields c str)
       (decode c str `(list int (struct ,make-referencetype--fields (fieldid string string int))))))
   (begin
     (define-struct referencetype--methods (methodid name signature modbits) (make-inspector))
     (define (encode-referencetype-methods arg) (encode 2 5 arg `referencetypeid))
     (define (decode-referencetype-methods c str)
       (decode
         c
         str
         `(list int (struct ,make-referencetype--methods (methodid string string int))))))
   (begin
     (define (encode-referencetype-getvalues reftype fields)
       (encode
         2
         6
         (list reftype fields)
         `(struct 'not-defined (referencetypeid (list int fieldid)))))
     (define (decode-referencetype-getvalues c str) (decode c str `(list int value))))
   (begin
     (define (encode-referencetype-sourcefile arg) (encode 2 7 arg `referencetypeid))
     (define (decode-referencetype-sourcefile c str) (decode c str `string)))
   (begin
     (define-struct referencetype--nestedtypes (reftypetag typeid) (make-inspector))
     (define (encode-referencetype-nestedtypes arg) (encode 2 8 arg `referencetypeid))
     (define (decode-referencetype-nestedtypes c str)
       (decode c str `(list int (struct ,make-referencetype--nestedtypes (byte referencetypeid))))))
   (begin
     (define (encode-referencetype-status arg) (encode 2 9 arg `referencetypeid))
     (define (decode-referencetype-status c str) (decode c str `int)))
   (begin
     (define (encode-referencetype-interfaces arg) (encode 2 10 arg `referencetypeid))
     (define (decode-referencetype-interfaces c str) (decode c str `(list int interfaceid))))
   (begin
     (define (encode-referencetype-classobject arg) (encode 2 11 arg `referencetypeid))
     (define (decode-referencetype-classobject c str) (decode c str `classobjectid)))
   (begin
     (define (encode-referencetype-sourcedebugextension arg) (encode 2 12 arg `referencetypeid))
     (define (decode-referencetype-sourcedebugextension c str) (decode c str `string)))
   (begin
     (define (encode-classtype-superclass arg) (encode 3 1 arg `classid))
     (define (decode-classtype-superclass c str) (decode c str `classid)))
   (begin
     (define (encode-classtype-setvalues clazz values)
       (encode
         3
         2
         (list clazz values)
         `(struct
            'not-defined
            (classid (list int (struct 'not-defined (fieldid untagged_value)))))))
     (define (decode-classtype-setvalues c str) (decode c str `())))
   (begin
     (define-struct classtype--invokemethod (returnvalue exception) (make-inspector))
     (define (encode-classtype-invokemethod clazz thread methodid arguments options)
       (encode
         3
         3
         (list clazz thread methodid arguments options)
         `(struct 'not-defined (classid threadid methodid (list int value) int))))
     (define (decode-classtype-invokemethod c str)
       (decode c str `(struct ,make-classtype--invokemethod (value tagged_objectid)))))
   (begin
     (define-struct classtype--newinstance (newobject exception) (make-inspector))
     (define (encode-classtype-newinstance clazz thread methodid arguments options)
       (encode
         3
         4
         (list clazz thread methodid arguments options)
         `(struct 'not-defined (classid threadid methodid (list int value) int))))
     (define (decode-classtype-newinstance c str)
       (decode c str `(struct ,make-classtype--newinstance (tagged_objectid tagged_objectid)))))
   (begin
     (define (encode-arraytype-newinstance arrtype length)
       (encode 4 1 (list arrtype length) `(struct 'not-defined (arraytypeid int))))
     (define (decode-arraytype-newinstance c str) (decode c str `tagged_objectid)))
   (begin
     (define-struct method--linetable (start end lines) (make-inspector))
     (define-struct method--linetable--lines (linecodeindex linenumber) (make-inspector))
     (define (encode-method-linetable reftype methodid)
       (encode 6 1 (list reftype methodid) `(struct 'not-defined (referencetypeid methodid))))
     (define (decode-method-linetable c str)
       (decode
         c
         str
         `(struct
            ,make-method--linetable
            (long long (list int (struct ,make-method--linetable--lines (long int))))))))
   (begin
     (define-struct method--variabletable (argcnt slots) (make-inspector))
     (define-struct
       method--variabletable--slots
       (codeindex name signature length slot)
       (make-inspector))
     (define (encode-method-variabletable reftype methodid)
       (encode 6 2 (list reftype methodid) `(struct 'not-defined (referencetypeid methodid))))
     (define (decode-method-variabletable c str)
       (decode
         c
         str
         `(struct
            ,make-method--variabletable
            (int
             (list
              int
              (struct ,make-method--variabletable--slots (long string string int int))))))))
   (begin
     (define (encode-method-bytecodes reftype methodid)
       (encode 6 3 (list reftype methodid) `(struct 'not-defined (referencetypeid methodid))))
     (define (decode-method-bytecodes c str) (decode c str `(list int byte))))
   (begin
     (define (encode-method-isobsolete reftype methodid)
       (encode 6 4 (list reftype methodid) `(struct 'not-defined (referencetypeid methodid))))
     (define (decode-method-isobsolete c str) (decode c str `boolean)))
   (begin
     (define-struct objectreference--referencetype (reftypetag typeid) (make-inspector))
     (define (encode-objectreference-referencetype arg) (encode 9 1 arg `objectid))
     (define (decode-objectreference-referencetype c str)
       (decode c str `(struct ,make-objectreference--referencetype (byte referencetypeid)))))
   (begin
     (define (encode-objectreference-getvalues object fields)
       (encode 9 2 (list object fields) `(struct 'not-defined (objectid (list int fieldid)))))
     (define (decode-objectreference-getvalues c str) (decode c str `(list int value))))
   (begin
     (define (encode-objectreference-setvalues object values)
       (encode
         9
         3
         (list object values)
         `(struct
            'not-defined
            (objectid (list int (struct 'not-defined (fieldid untagged_value)))))))
     (define (decode-objectreference-setvalues c str) (decode c str `())))
   (begin
     (define-struct objectreference--monitorinfo (owner entrycount waiters) (make-inspector))
     (define (encode-objectreference-monitorinfo arg) (encode 9 4 arg `objectid))
     (define (decode-objectreference-monitorinfo c str)
       (decode
         c
         str
         `(struct ,make-objectreference--monitorinfo (threadid int (list int threadid))))))
   (begin
     (define-struct objectreference--invokemethod (returntype exception) (make-inspector))
     (define (encode-objectreference-invokemethod object thread clazz methodid arguments options)
       (encode
         9
         5
         (list object thread clazz methodid arguments options)
         `(struct 'not-defined (objectid threadid classid methodid (list int value) int))))
     (define (decode-objectreference-invokemethod c str)
       (decode c str `(struct ,make-objectreference--invokemethod (value tagged_objectid)))))
   (begin
     (define (encode-objectreference-disablecollection arg) (encode 9 6 arg `objectid))
     (define (decode-objectreference-disablecollection c str) (decode c str `())))
   (begin
     (define (encode-objectreference-enablecollection arg) (encode 9 7 arg `objectid))
     (define (decode-objectreference-enablecollection c str) (decode c str `())))
   (begin
     (define (encode-objectreference-iscollected arg) (encode 9 8 arg `objectid))
     (define (decode-objectreference-iscollected c str) (decode c str `boolean)))
   (begin
     (define (encode-stringreference-value arg) (encode 10 1 arg `objectid))
     (define (decode-stringreference-value c str) (decode c str `string)))
   (begin
     (define (encode-threadreference-name arg) (encode 11 1 arg `threadid))
     (define (decode-threadreference-name c str) (decode c str `string)))
   (begin
     (define (encode-threadreference-suspend arg) (encode 11 2 arg `threadid))
     (define (decode-threadreference-suspend c str) (decode c str `())))
   (begin
     (define (encode-threadreference-resume arg) (encode 11 3 arg `threadid))
     (define (decode-threadreference-resume c str) (decode c str `())))
   (begin
     (define-struct threadreference--status (threadstatus suspendstatus) (make-inspector))
     (define (encode-threadreference-status arg) (encode 11 4 arg `threadid))
     (define (decode-threadreference-status c str)
       (decode c str `(struct ,make-threadreference--status (int int)))))
   (begin
     (define (encode-threadreference-threadgroup arg) (encode 11 5 arg `threadid))
     (define (decode-threadreference-threadgroup c str) (decode c str `threadgroupid)))
   (begin
     (define-struct threadreference--frames (frameid location) (make-inspector))
     (define (encode-threadreference-frames thread startframe length)
       (encode 11 6 (list thread startframe length) `(struct 'not-defined (threadid int int))))
     (define (decode-threadreference-frames c str)
       (decode c str `(list int (struct ,make-threadreference--frames (frameid location))))))
   (begin
     (define (encode-threadreference-framecount arg) (encode 11 7 arg `threadid))
     (define (decode-threadreference-framecount c str) (decode c str `int)))
   (begin
     (define (encode-threadreference-ownedmonitors arg) (encode 11 8 arg `threadid))
     (define (decode-threadreference-ownedmonitors c str)
       (decode c str `(list int tagged_objectid))))
   (begin
     (define (encode-threadreference-currentcontendedmonitor arg) (encode 11 9 arg `threadid))
     (define (decode-threadreference-currentcontendedmonitor c str)
       (decode c str `tagged_objectid)))
   (begin
     (define (encode-threadreference-stop thread throwable)
       (encode 11 10 (list thread throwable) `(struct 'not-defined (threadid objectid))))
     (define (decode-threadreference-stop c str) (decode c str `())))
   (begin
     (define (encode-threadreference-interrupt arg) (encode 11 11 arg `threadid))
     (define (decode-threadreference-interrupt c str) (decode c str `())))
   (begin
     (define (encode-threadreference-suspendcount arg) (encode 11 12 arg `threadid))
     (define (decode-threadreference-suspendcount c str) (decode c str `int)))
   (begin
     (define (encode-threadgroupreference-name arg) (encode 12 1 arg `threadgroupid))
     (define (decode-threadgroupreference-name c str) (decode c str `string)))
   (begin
     (define (encode-threadgroupreference-parent arg) (encode 12 2 arg `threadgroupid))
     (define (decode-threadgroupreference-parent c str) (decode c str `threadgroupid)))
   (begin
     (define-struct threadgroupreference--children (childthreads childgroups) (make-inspector))
     (define (encode-threadgroupreference-children arg) (encode 12 3 arg `threadgroupid))
     (define (decode-threadgroupreference-children c str)
       (decode
         c
         str
         `(struct
            ,make-threadgroupreference--children
            ((list int threadid) (list int threadgroupid))))))
   (begin
     (define (encode-arrayreference-length arg) (encode 13 1 arg `arrayid))
     (define (decode-arrayreference-length c str) (decode c str `int)))
   (begin
     (define (encode-arrayreference-getvalues arrayobject firstindex length)
       (encode 13 2 (list arrayobject firstindex length) `(struct 'not-defined (arrayid int int))))
     (define (decode-arrayreference-getvalues c str) (decode c str `arrayregion)))
   (begin
     (define (encode-arrayreference-setvalues arrayobject firstindex values)
       (encode
         13
         3
         (list arrayobject firstindex values)
         `(struct 'not-defined (arrayid int (list int untagged_value)))))
     (define (decode-arrayreference-setvalues c str) (decode c str `())))
   (begin
     (define-struct classloaderreference--visibleclasses (reftypetag typeid) (make-inspector))
     (define (encode-classloaderreference-visibleclasses arg) (encode 14 1 arg `classloaderid))
     (define (decode-classloaderreference-visibleclasses c str)
       (decode
         c
         str
         `(list int (struct ,make-classloaderreference--visibleclasses (byte referencetypeid))))))
   (begin
     (define (encode-eventrequest-set eventkind suspendpolicy modifiers)
       (encode
         15
         1
         (list eventkind suspendpolicy modifiers)
         `(struct
            'not-defined
            (byte
             byte
             (list
              int
              (cases
               byte
               (count 1 int)
               (conditional 2 int)
               (threadonly 3 threadid)
               (classonly 4 referencetypeid)
               (classmatch 5 string)
               (classexclude 6 string)
               (locationonly 7 location)
               (exceptiononly 8 (struct 'not-defined (referencetypeid boolean boolean)))
               (fieldonly 9 (struct 'not-defined (referencetypeid fieldid)))
               (step 10 (struct 'not-defined (threadid int int)))
               (instanceonly 11 objectid)))))))
     (define (decode-eventrequest-set c str) (decode c str `int)))
   (begin
     (define (encode-eventrequest-clear event requestid)
       (encode 15 2 (list event requestid) `(struct 'not-defined (byte int))))
     (define (decode-eventrequest-clear c str) (decode c str `())))
   (begin
     (define (encode-eventrequest-clearallbreakpoints) (encode 15 3 () `()))
     (define (decode-eventrequest-clearallbreakpoints c str) (decode c str `())))
   (begin
     (define (encode-stackframe-getvalues thread frame slots)
       (encode
         16
         1
         (list thread frame slots)
         `(struct 'not-defined (threadid frameid (list int (struct 'not-defined (int byte)))))))
     (define (decode-stackframe-getvalues c str) (decode c str `(list int value))))
   (begin
     (define (encode-stackframe-setvalues thread frame slotvalues)
       (encode
         16
         2
         (list thread frame slotvalues)
         `(struct 'not-defined (threadid frameid (list int (struct 'not-defined (int value)))))))
     (define (decode-stackframe-setvalues c str) (decode c str `())))
   (begin
     (define (encode-stackframe-thisobject thread frame)
       (encode 16 3 (list thread frame) `(struct 'not-defined (threadid frameid))))
     (define (decode-stackframe-thisobject c str) (decode c str `tagged_objectid)))
   (begin
     (define (encode-stackframe-popframes thread frame)
       (encode 16 4 (list thread frame) `(struct 'not-defined (threadid frameid))))
     (define (decode-stackframe-popframes c str) (decode c str `())))
   (begin
     (define-struct classobjectreference--reflectedtype (reftypetag typeid) (make-inspector))
     (define (encode-classobjectreference-reflectedtype arg) (encode 17 1 arg `classobjectid))
     (define (decode-classobjectreference-reflectedtype c str)
       (decode c str `(struct ,make-classobjectreference--reflectedtype (byte referencetypeid)))))
   (begin
     (define-struct event--composite (suspendpolicy events) (make-inspector))
     (define-struct event--composite--events--vmstart (requestid thread) (make-inspector))
     (define-struct
       event--composite--events--singlestep
       (requestid thread location)
       (make-inspector))
     (define-struct
       event--composite--events--breakpoint
       (requestid thread location)
       (make-inspector))
     (define-struct
       event--composite--events--methodentry
       (requestid thread location)
       (make-inspector))
     (define-struct
       event--composite--events--methodexit
       (requestid thread location)
       (make-inspector))
     (define-struct
       event--composite--events--exception
       (requestid thread location exception catchlocation)
       (make-inspector))
     (define-struct event--composite--events--threadstart (requestid thread) (make-inspector))
     (define-struct event--composite--events--threaddeath (requestid thread) (make-inspector))
     (define-struct
       event--composite--events--classprepare
       (requestid thread reftypetag typeid signature status)
       (make-inspector))
     (define-struct event--composite--events--classunload (requestid signature) (make-inspector))
     (define-struct
       event--composite--events--fieldaccess
       (requestid thread location reftypetag typeid fieldid object)
       (make-inspector))
     (define-struct
       event--composite--events--fieldmodification
       (requestid thread location reftypetag typeid fieldid object valuetobe)
       (make-inspector))
     (define (encode-event-composite) (encode 64 100 () `()))
     (define (decode-event-composite c str)
       (decode
         c
         str
         `(struct
            ,make-event--composite
            (byte
             (list
              int
              (cases
               byte
               (vmstart 90 (struct ,make-event--composite--events--vmstart (int threadid)))
               (singlestep
                 1
                 (struct ,make-event--composite--events--singlestep (int threadid location)))
               (breakpoint
                 2
                 (struct ,make-event--composite--events--breakpoint (int threadid location)))
               (methodentry
                 40
                 (struct ,make-event--composite--events--methodentry (int threadid location)))
               (methodexit
                 41
                 (struct ,make-event--composite--events--methodexit (int threadid location)))
               (exception
                 30
                 (struct
                   ,make-event--composite--events--exception
                   (int threadid location tagged_objectid location)))
               (threadstart 6 (struct ,make-event--composite--events--threadstart (int threadid)))
               (threaddeath 7 (struct ,make-event--composite--events--threaddeath (int threadid)))
               (classprepare
                 8
                 (struct
                   ,make-event--composite--events--classprepare
                   (int threadid byte referencetypeid string int)))
               (classunload 9 (struct ,make-event--composite--events--classunload (int string)))
               (fieldaccess
                 20
                 (struct
                   ,make-event--composite--events--fieldaccess
                   (int threadid location byte referencetypeid fieldid tagged_objectid)))
               (fieldmodification
                 21
                 (struct
                   ,make-event--composite--events--fieldmodification
                   (int threadid location byte referencetypeid fieldid tagged_objectid value)))
               (vmdeath 99 int))))))))
   (define command-ids-hash
     (make-immutable-hash-table
       (list
        (cons
         1
         (make-immutable-hash-table
           (list
            (cons 1 decode-virtualmachine-version)
            (cons 2 decode-virtualmachine-classesbysignature)
            (cons 3 decode-virtualmachine-allclasses)
            (cons 4 decode-virtualmachine-allthreads)
            (cons 5 decode-virtualmachine-toplevelthreadgroups)
            (cons 6 decode-virtualmachine-dispose)
            (cons 7 decode-virtualmachine-idsizes)
            (cons 8 decode-virtualmachine-suspend)
            (cons 9 decode-virtualmachine-resume)
            (cons 10 decode-virtualmachine-exit)
            (cons 11 decode-virtualmachine-createstring)
            (cons 12 decode-virtualmachine-capabilities)
            (cons 13 decode-virtualmachine-classpaths)
            (cons 14 decode-virtualmachine-disposeobjects)
            (cons 15 decode-virtualmachine-holdevents)
            (cons 16 decode-virtualmachine-releaseevents)
            (cons 17 decode-virtualmachine-capabilitiesnew)
            (cons 18 decode-virtualmachine-redefineclasses)
            (cons 19 decode-virtualmachine-setdefaultstratum))))
        (cons
         2
         (make-immutable-hash-table
           (list
            (cons 1 decode-referencetype-signature)
            (cons 2 decode-referencetype-classloader)
            (cons 3 decode-referencetype-modifiers)
            (cons 4 decode-referencetype-fields)
            (cons 5 decode-referencetype-methods)
            (cons 6 decode-referencetype-getvalues)
            (cons 7 decode-referencetype-sourcefile)
            (cons 8 decode-referencetype-nestedtypes)
            (cons 9 decode-referencetype-status)
            (cons 10 decode-referencetype-interfaces)
            (cons 11 decode-referencetype-classobject)
            (cons 12 decode-referencetype-sourcedebugextension))))
        (cons
         3
         (make-immutable-hash-table
           (list
            (cons 1 decode-classtype-superclass)
            (cons 2 decode-classtype-setvalues)
            (cons 3 decode-classtype-invokemethod)
            (cons 4 decode-classtype-newinstance))))
        (cons 4 (make-immutable-hash-table (list (cons 1 decode-arraytype-newinstance))))
        (cons 5 (make-immutable-hash-table (list)))
        (cons
         6
         (make-immutable-hash-table
           (list
            (cons 1 decode-method-linetable)
            (cons 2 decode-method-variabletable)
            (cons 3 decode-method-bytecodes)
            (cons 4 decode-method-isobsolete))))
        (cons 8 (make-immutable-hash-table (list)))
        (cons
         9
         (make-immutable-hash-table
           (list
            (cons 1 decode-objectreference-referencetype)
            (cons 2 decode-objectreference-getvalues)
            (cons 3 decode-objectreference-setvalues)
            (cons 4 decode-objectreference-monitorinfo)
            (cons 5 decode-objectreference-invokemethod)
            (cons 6 decode-objectreference-disablecollection)
            (cons 7 decode-objectreference-enablecollection)
            (cons 8 decode-objectreference-iscollected))))
        (cons 10 (make-immutable-hash-table (list (cons 1 decode-stringreference-value))))
        (cons
         11
         (make-immutable-hash-table
           (list
            (cons 1 decode-threadreference-name)
            (cons 2 decode-threadreference-suspend)
            (cons 3 decode-threadreference-resume)
            (cons 4 decode-threadreference-status)
            (cons 5 decode-threadreference-threadgroup)
            (cons 6 decode-threadreference-frames)
            (cons 7 decode-threadreference-framecount)
            (cons 8 decode-threadreference-ownedmonitors)
            (cons 9 decode-threadreference-currentcontendedmonitor)
            (cons 10 decode-threadreference-stop)
            (cons 11 decode-threadreference-interrupt)
            (cons 12 decode-threadreference-suspendcount))))
        (cons
         12
         (make-immutable-hash-table
           (list
            (cons 1 decode-threadgroupreference-name)
            (cons 2 decode-threadgroupreference-parent)
            (cons 3 decode-threadgroupreference-children))))
        (cons
         13
         (make-immutable-hash-table
           (list
            (cons 1 decode-arrayreference-length)
            (cons 2 decode-arrayreference-getvalues)
            (cons 3 decode-arrayreference-setvalues))))
        (cons
         14
         (make-immutable-hash-table (list (cons 1 decode-classloaderreference-visibleclasses))))
        (cons
         15
         (make-immutable-hash-table
           (list
            (cons 1 decode-eventrequest-set)
            (cons 2 decode-eventrequest-clear)
            (cons 3 decode-eventrequest-clearallbreakpoints))))
        (cons
         16
         (make-immutable-hash-table
           (list
            (cons 1 decode-stackframe-getvalues)
            (cons 2 decode-stackframe-setvalues)
            (cons 3 decode-stackframe-thisobject)
            (cons 4 decode-stackframe-popframes))))
        (cons
         17
         (make-immutable-hash-table (list (cons 1 decode-classobjectreference-reflectedtype))))
        (cons 64 (make-immutable-hash-table (list (cons 100 decode-event-composite)))))))))
