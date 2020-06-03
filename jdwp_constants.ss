(module jdwp_constants mzscheme
  (provide (all-defined))
  
  (define event-kind-vm-disconnected 100)
  (define event-kind-single-step 1)
  (define event-kind-breakpoint 2)
  (define event-kind-frame-pop 3)
  (define event-kind-exception 4)
  (define event-kind-user-defined 5)
  (define event-kind-thread-start 6)
  (define event-kind-thread-end 7)
  (define event-kind-class-prepare 8)
  (define event-kind-class-unload 9)
  (define event-kind-class-load 10)
  (define event-kind-field-access 20)
  (define event-kind-field-modification 21)
  (define event-kind-exception-catch 30)
  (define event-kind-method-entry 40)
  (define event-kind-method-exit 41)
  (define event-kind-vm-init 90)
  (define event-kind-vm-death 99)
  (define event-kind-vm-start event-kind-vm-init)
  (define event-kind-thread-death event-kind-thread-end)
  
  (define suspend-policy-none 0) ;; Suspend no threads when this event is encountered.  
  (define suspend-policy-event-thread 1) ;; Suspend the event thread when this event is encountered. ;
  (define suspend-policy-all 2) ;;Suspend all threads when this event is encountered.  
  
  (define error-constants
    (make-immutable-hash-table
     '((0 NONE "No error has occurred.")
       (10 INVALID_THREAD "Passed thread is not a valid thread or has exited.")
       (11 INVALID_THREAD_GROUP "Thread group invalid.")
       (12 INVALID_PRIORITY "Invalid priority.")
       (13 THREAD_NOT_SUSPENDED "If the specified thread has not been suspended by an event.")
       (14 THREAD_SUSPENDED "Thread already suspended.")
       (20 INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
       (21 INVALID_CLASS "Invalid class.")
       (22 CLASS_NOT_PREPARED "Class has been loaded but not yet prepared.")
       (23 INVALID_METHODID "Invalid method.")
       (24 INVALID_LOCATION "Invalid location.")
       (25 INVALID_FIELDID "Invalid field.")
       (30 INVALID_FRAMEID "Invalid jframeID.")
       (31 NO_MORE_FRAMES "There are no more Java or JNI frames on the call stack.")
       (32 OPAQUE_FRAME "Information about the frame is not available.")
       (33 NOT_CURRENT_FRAME "Operation can only be performed on current frame.")
       (34 TYPE_MISMATCH "The variable is not an appropriate type for the function used.")
       (35 INVALID_SLOT "Invalid slot.")
       (40 DUPLICATE "Item already set.")
       (41 NOT_FOUND "Desired element not found.")
       (50 INVALID_MONITOR "Invalid monitor.")
       (51 NOT_MONITOR_OWNER "This thread doesn't own the monitor.")
       (52 INTERRUPT "The call has been interrupted before completion.")
       (60 INVALID_CLASS_FORMAT "The virtual machine attempted to read a class file and determined that the file is malformed or otherwise cannot be interpreted as a class file.")
       (61 CIRCULAR_CLASS_DEFINITION "A circularity has been detected while initializing a class.")
       (62 FAILS_VERIFICATION "The verifier detected that a class file, though well formed, contained some sort of internal inconsistency or security problem.")
       (63 ADD_METHOD_NOT_IMPLEMENTED "Adding methods has not been implemented.")
       (64 SCHEMA_CHANGE_NOT_IMPLEMENTED "Schema change has not been implemented.")
       (65 INVALID_TYPESTATE "The state of the thread has been modified, and is now inconsistent.")
       (66 HIERARCHY_CHANGE_NOT_IMPLEMENTED "A direct superclass is different for the new class version, or the set of directly implemented interfaces is different and canUnrestrictedlyRedefineClasses is false.")
       (67 DELETE_METHOD_NOT_IMPLEMENTED "The new class version does not declare a method declared in the old class version and canUnrestrictedlyRedefineClasses is false.")
       (68 UNSUPPORTED_VERSION "A class file has a version number not supported by this VM.")
       (69 NAMES_DONT_MATCH "The class name defined in the new class file is different from the name in the old class object.")
       (70 CLASS_MODIFIERS_CHANGE_NOT_IMPLEMENTED "The new class version has different modifiers and and canUnrestrictedlyRedefineClasses is false.")
       (71 METHOD_MODIFIERS_CHANGE_NOT_IMPLEMENTED "A method in the new class version has different modifiers than its counterpart in the old class version and and canUnrestrictedlyRedefineClasses is false.")
       (99 NOT_IMPLEMENTED "The functionality is not implemented in this virtual machine.")
       (100 NULL_POINTER "Invalid pointer.")
       (101 ABSENT_INFORMATION "Desired information is not available.")
       (102 INVALID_EVENT_TYPE "The specified event type id is not recognized.")
       (103 ILLEGAL_ARGUMENT "Illegal argument.")
       (110 OUT_OF_MEMORY "The function needed to allocate memory and no more memory was available for allocation.")
       (111 ACCESS_DENIED "Debugging has not been enabled in this virtual machine. JVMDI cannot be used.")
       (112 VM_DEAD "The virtual machine is not running.")
       (113 INTERNAL "An unexpected internal error has occurred.")
       (115 UNATTACHED_THREAD "The thread being used to call this function is not attached to the virtual machine. Calls must be made from attached threads.")
       (500 INVALID_TAG "object type id or class tag.")
       (502 ALREADY_INVOKING "Previous invoke not complete.")
       (503 INVALID_INDEX "Index is invalid.")
       (504 INVALID_LENGTH "The length is invalid.")
       (506 INVALID_STRING "The string is invalid.")
       (507 INVALID_CLASS_LOADER "The class loader is invalid.")
       (508 INVALID_ARRAY "The array is invalid.")
       (509 TRANSPORT_LOAD "Unable to load the transport.")
       (510 TRANSPORT_INIT "Unable to initialize the transport.")
       (511 NATIVE_METHOD "Native method.")
       (512 INVALID_COUNT "The count is invalid."))))

  (define access-public #x0001) ;; Declared public, may be accessed from outside its package.
  (define access-private #x0002) ;; Declared private, usable only within the defining class.
  (define access-protected #x0004) ;; Declared protected, may be accessed within subclasses.
  (define access-static #x0008) ;; Declared static.
  (define access-final #x0010)  ;; Declared final, no further assignment after initialization.
  (define access-volatile #x0040) ;; Declared volatile, cannot be cached.
  (define access-transient #x0080) ;; Declared transient, not written or read by a persistent object manager.
  
  (define type-tag2size
    (make-immutable-hash-table
     '((91 ARRAY objectID) ;; - an array object (objectID size).  
       (66 BYTE 1) ;; - a byte value (1 byte).  
       (67 CHAR 2) ;; - a character value (2 bytes).  
       (76 OBJECT objectID) ;; - an object (objectID size).  
       (70 FLOAT 4) ;; - a float value (4 bytes).  
       (68 DOUBLE 8) ;; - a double value (8 bytes).  
       (73 INT 4) ;; - an int value (4 bytes).  
       (74 LONG 8) ;; - a long value (8 bytes).  
       (83 SHORT 2) ;; - a short value (2 bytes).  
       (86 VOID 0) ;; - a void value (no bytes).  
       (90 BOOLEAN 1) ;; - a boolean value (1 byte).  
       (115 STRING objectID) ;; - a String object (objectID size).  
       (116 THREAD objectID) ;; - a Thread object (objectID size).  
       (103 THREAD_GROUP objectID) ;; - a ThreadGroup object (objectID size).  
       (108 CLASS_LOADER objectID) ;; - a ClassLoader object (objectID size).  
       (99 CLASS_OBJECT objectID))))  ;; - a class object object (objectID size).  

  (define class-type-tag 1);; ReferenceType is a class.  
  (define interface-type-tag 2);; ReferenceType is an interface.  
  (define array-type-tag 3);; ReferenceType is an array.  
  )
