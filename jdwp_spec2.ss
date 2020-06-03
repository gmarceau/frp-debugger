;;; This file was originally generated using mangle1.ss.
;;; It has been manually modified since.
;;;
(module jdwp_spec2 mzscheme
  
  (provide (all-defined))
  
  (require "mangle2.ss"
           "base-gm.ss")

  (define-jdwp-to-file
    command-ids-hash
    (command-set
     virtualmachine
     1
     
     (command version 1
              (description
               "Returns the JDWP version implemented by the target VM. \n      The version string format is implementation dependent.")
              (out-data void)
              (reply-data
               (struct
                (vm-description "Text information on the VM version" string)
                (jdwpmajor "Major JDWP Version number" int)
                (jdwpminor "Minor JDWP Version number" int)
                (vmversion "Target VM JRE version as in the java.version property" string)
                (vmname "Target VM name as in the java.vm.name property" string)))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command classesbysignature 2
              (description
               "Returns reference types for all the classes loaded by the target VM which \n      match the given signature. Multple reference types will be returned if two or more \n      class loaders have loaded a class of the same name. The search is confined to loaded \n      classes only; no attempt is made to load a class of the given signature.")
              (out-data
               ("JNI signature of the class to find \n      (for example Ljava/lang/String;)." string))
              (reply-data
               (list
                (int "Number of reference types that follow.")
                (struct
                 (reftypetag "Kind of following reference type." byte)
                 (typeid "Matching loaded reference type" classid) ;; TODO was : referencetypeid
                 (status "The current class status." int))))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command allclasses 3
              (description "Returns reference types for all classes currently loaded by the target VM.")
              (out-data void)
              (reply-data
               (list
                (int "Number of reference types that follow.")
                (struct
                 (reftypetag "Kind of following reference type." byte)
                 (typeid "Loaded reference type" referencetypeid)
                 (signature "The JNI signature of the loaded reference type" string)
                 (status "The current class status." int))))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command allthreads 4
              (description
               "Returns all threads currently running in the target VM . The returned list \n      contains threads created through java.lang.Thread all native threads attached to the target \n      VM through JNI and system threads created by the target VM. Threads that have not yet been \n      started and threads that have completed their execution are not included in the returned list.")
              (out-data void)
              (reply-data (list (int "Number of threads to follow") ("A running thread" threadid)))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command toplevelthreadgroups 5
              (description
               "Returns all thread groups that do not have a parent. This command may be used \n      as the first step in building a tree (or trees) of the existing thread groups.")
              (out-data void)
              (reply-data
               (list
                (int "Number of thread groups that follow.")
                ("A top level thread group" threadgroupid)))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command dispose 6
              (description
               "Invalidates this virtual machine mirror. The communication channel to the target \n      VM is closed and the target VM prepares to accept another subsequent connection from this debugger\n      or another debugger including the following tasks: (1) All event requests are cancelled. (2) All \n      threads suspended by the thread-level resume command or the VM-level resume command are resumed \n      as many times as necessary for them to run. (3) Garbage collection is re-enabled in all cases where \n      it was disabled. -- Any current method invocations executing in the target VM are continued after \n      the disconnection. Upon completion of any such method invocation the invoking thread continues \n      from the location where it was originally stopped. Resources originating in this VirtualMachine \n      (ObjectReferences ReferenceTypes etc.) will become invalid. ")
              (out-data void)
              (reply-data void)
              (error-data))

     (command idsizes 7
              (description
               "Returns the sizes of variably-sized data types in the target VM.The returned\n      values indicate the number of bytes used by the identifiers in command and reply packets.")
              (out-data void)
              (reply-data
               (struct
                (fieldidsize "fieldID size in bytes" int)
                (methodidsize "methodID size in bytes" int)
                (objectidsize "objectID size in bytes" int)
                (referencetypeidsize "referenceTypeID size in bytes" int)
                (frameidsize "frameID size in bytes" int)))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command suspend 8
              (description
               "Suspends the execution of the application running in the target VM. All \n      Java threads currently running will be suspended. Unlike java.lang.Thread.suspend suspends of \n      both the virtual machine and individual threads are counted. Before a thread will run again it \n      must be resumed through the VM-level resume command or the thread-level resume command the same \n      number of times it has been suspended.")
              (out-data void)
              (reply-data void)
              (error-data (vm_dead "The virtual machine is not running.")))

     (command resume 9
              (description
               "Resumes execution of the application after the suspend command or an \n      event has stopped it. Suspensions of the Virtual Machine and individual threads are counted. \n      If a particular thread is suspended n times it must resumed n times before it will continue.")
              (out-data void)
              (reply-data void)
              (error-data))

     (command exit 10
              (description
               "Terminates the target VM with the given exit code. All ids previously \n      returned from the target VM become invalid. Threads running in the VM are abruptly terminated. \n      A thread death exception is not thrown and finally blocks are not run. ")
              (out-data void)
              (reply-data void)
              (error-data))

     (command createstring 11
              (description "Creates a new string object in the target VM and returns its id.")
              (out-data ("UTF-8 characters to use in the created string." string))
              (reply-data ("Created string (instance of java.lang.String)" stringid))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command capabilities 12
              (description
               "Retrieve this VMs capabilities. The capabilities are returned as \n      booleans each indicating the presence or absence of a capability. The commands associated \n      with each capability will return the NOT_IMPLEMENTED error if the cabability is not available. ")
              (out-data void)
              (reply-data
               (struct
                (canwatchfieldmodification
                 "Can the VM watch field modification and \n      therefore can it send the Modification Watchpoint Event?"
                 boolean)
                (canwatchfieldaccess
                 "Can the VM watch field access and therefore \n      can it send the Access Watchpoint Event?"
                 boolean)
                (cangetbytecodes "Can the VM get the bytecodes of a given method?" boolean)
                (cangetsyntheticattribute
                 "Can the VM determine whether a field \n      or method is synthetic? (that is can the VM determine if the method or the field was \n      invented by the compiler?)"
                 boolean)
                (cangetownedmonitorinfo
                 "Can the VM get the owned monitors infornation \n      for a thread?"
                 boolean)
                (cangetcurrentcontendedmonitor
                 "Can the VM get the current contended \n      monitor of a thread?"
                 boolean)
                (cangetmonitorinfo
                 "Can the VM get the monitor information for a \n      given object?"
                 boolean)))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command classpaths 13
              (description
               "Retrieve the classpath and bootclasspath of the target VM. If the classpath \n      is not defined returns an empty list. If the bootclasspath is not defined returns an empty list.")
              (out-data void)
              (reply-data
               (struct
                (basedir
                 "Base directory used to resolve relative paths in either \n      of the following lists."
                 string)
                (classpaths
                 ""
                 (list (int "Number of paths in classpath.") ("One component of classpath" string)))
                (bootclasspaths
                 ""
                 (list
                  (int "Number of paths in bootclasspath.")
                  ("One component of bootclasspath" string)))))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command disposeobjects 14
              (description
               "Releases a list of object IDs. For each object in the list the following \n      applies. The count of references held by the end (the reference count) will be decremented \n      by refCnt. If thereafter the reference count is less than or equal to zero the ID is freed. Any \n      end resources associated with the freed ID may be freed and if garbage collection was disabled \n      for the object it will be re-enabled. The sender of this command promises that no further commands \n      will be sent referencing a freed ID.  Use of this command is not required. If it is not sent \n      resources associated with each ID will be freed by the end at some time after the corresponding \n      object is garbage collected. It is most useful to use this command to reduce the load on the end \n      if avery large number of objects has been retrieved from the end (a large array for example) \n      but may not be garbage collected any time soon. IDs may be re-used by the end after they have \n      been freed with this command.This description assumes reference counting a end may use any \n      implementation which operates equivalently.")
              (out-data
               (list
                (int "Number of object dispose requests that follow")
                (struct
                 (object "The object ID" objectid)
                 (refcnt
                  "The number of times this object ID has been part of a packet received \n        from the end. An accurate count prevents the object ID from being freed on the end if \n        it is part of an incoming packet not yet handled by the front-end."
                  int))))
              (reply-data void)
              (error-data))

     (command holdevents 15
              (description
               "Tells the target VM to stop sending events. Events are not discarded; they are held \n      until a subsequent ReleaseEvents command is sent. This command is useful to control the number of \n      events sent to the debugger VM in situations where very large numbers of events are generated. \n      While events are held by the debugger end application execution may be frozen by the debugger \n      end to prevent buffer overflows on the back ). Responses to commands are never held and are \n      not affected by this command. If events are already being held this command is ignored.")
              (out-data void)
              (reply-data void)
              (error-data))

     (command releaseevents 16
              (description
               "Tells the target VM to continue sending events. This command is used to restore \n      normal activity after a HoldEvents command. If there is no current HoldEvents command in effect \n      this command is ignored")
              (out-data void)
              (reply-data void)
              (error-data))

     (command capabilitiesnew 17
              (description
               "Retrieve all of this VMs capabilities. The capabilities are returned as booleans \n      each indicating the presence or absence of a capability. The commands associated with each capability \n      will return the NOT_IMPLEMENTED error if the cabability is not available.Since JDWP version 1.4.")
              (out-data void)
              (reply-data
               (struct
                (canwatchfieldmodification
                 "Can the VM watch field modification and \n      therefore can it send the Modification Watchpoint Event?"
                 boolean)
                (canwatchfieldaccess
                 "Can the VM watch field access and therefore can it \n      send the Access Watchpoint Event?"
                 boolean)
                (cangetbytecodes "Can the VM get the bytecodes of a given method?" boolean)
                (cangetsyntheticattribute
                 "Can the VM determine whether a field or method \n      is synthetic? (that is can the VM determine if the method or the field was invented by the compiler?)"
                 boolean)
                (cangetownedmonitorinfo
                 "Can the VM get the owned monitors infornation for a thread?"
                 boolean)
                (cangetcurrentcontendedmonitor
                 "Can the VM get the current contended \n      monitor of a thread?"
                 boolean)
                (cangetmonitorinfo "Can the VM get the monitor information for a given object?" boolean)
                (canredefineclasses "Can the VM redefine classes?" boolean)
                (canaddmethod "Can the VM add methods when redefining classes?" boolean)
                (canunrestrictedlyredefineclasses "Can the VM redefine classesin arbitrary ways?" boolean)
                (canpopframes "Can the VM pop stack frames?" boolean)
                (canuseinstancefilters "Can the VM filter events by specific object?" boolean)
                (cangetsourcedebugextension "Can the VM get the source debug extension?" boolean)
                (canrequestvmdeathevent "Can the VM request VM death events?" boolean)
                (cansetdefaultstratum "Can the VM set a default stratum?" boolean)
                (reserved16 "Reserved for future capability" boolean)
                (reserved17 "Reserved for future capability" boolean)
                (reserved18 "Reserved for future capability" boolean)
                (reserved19 "Reserved for future capability" boolean)
                (reserved20 "Reserved for future capability" boolean)
                (reserved21 "Reserved for future capability" boolean)
                (reserved22 "Reserved for future capability" boolean)
                (reserved23 "Reserved for future capability" boolean)
                (reserved24 "Reserved for future capability" boolean)
                (reserved25 "Reserved for future capability" boolean)
                (reserved26 "Reserved for future capability" boolean)
                (reserved27 "Reserved for future capability" boolean)
                (reserved28 "Reserved for future capability" boolean)
                (reserved29 "Reserved for future capability" boolean)
                (reserved30 "Reserved for future capability" boolean)
                (reserved31 "Reserved for future capability" boolean)
                (reserved32 "Reserved for future capability" boolean)))
              (error-data (vm_dead "The virtual machine is not running.")))

     (command redefineclasses 18
              (description "Installs new class definitions.")
              (out-data
               (list
                (int "Number of reference types that follow.")
                (struct
                 (reftype "The reference type." referencetypeid)
                 (classfile
                  ""
                  (list (int "Class file byte count") ("byte in JVM class file format." byte))))))
              (reply-data void)
              (error-data
               (invalid_class "One of the refType is not the ID of a reference type.\312")
               (invalid_object "One of the refType is not a known ID.")
               (unsupported_version "A class file has a version number not supported by this VM.\312")
               (invalid_class_format
                "The virtual machine attempted to read a class file and determined \n      that the file is malformed or otherwise cannot be interpreted as a class file.\312")
               (circular_class_definition "A circularity has been detected while initializing a class.\312")
               (fails_verification
                "The verifier detected that a class file though well formed contained \n      some sort of internal inconsistency or security problem.\312")
               (names_dont_match
                "The class name defined in the new class file is different from the name \n      in the old class object.")
               (not_implemented
                "No aspect of this functionality is implemented \n      (CapabilitiesNew.canRedefineClasses is false)\312")
               (add_method_not_implemented "Adding methods has not been implemented.")
               (schema_change_not_implemented "Schema change has not been implemented.")
               (hierarchy_change_not_implemented
                "A direct superclass is different for the new class \n      version or the set of directly implemented interfaces is different and canUnrestrictedlyRedefineClasses \n      is false.")
               (delete_method_not_implemented
                "The new class version does not declare a method declared \n      in the old class version and canUnrestrictedlyRedefineClasses is false.\312")
               (class_modifiers_change_not_implemented
                "The new class version has different modifiers \n      and canUnrestrictedlyRedefineClasses is false")
               (method_modifiers_change_not_implemented
                "A method in the new class version has different \n      modifiers than its counterpart in the old class version and and canUnrestrictedlyRedefineClasses is false.\312")
               (vm_dead "The virtual machine is not running.")))

     (command setdefaultstratum 19
              (description "Set the default stratum.")
              (out-data ("default stratum or empty string to use reference type default." string))
              (reply-data void)
              (error-data
               (not_implemented "The functionality is not implemented in this virtual machine.")
               (vm_dead "The virtual machine is not running."))))
  


    (command-set
     referencetype
     2

     (command signature 1
              (description
               "Returns the JNI signature of a reference type. JNI signature formats are described \n      in the Java Native Inteface Specification  For primitive classes the returned signature is the signature \n      of the corresponding primitive type; for example I is returned as the signature of the class \n      represented by java.lang.Integer.TYPE. ")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data ("The JNI signature for the reference type." string))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command classloader 2
              (description
               "Returns the instance of java.lang.ClassLoader which loaded a given reference type. If \n      the reference type was loaded by the system class loader the returned object ID is null.")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data ("The class loader for the reference type." classloaderid))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command modifiers 3
              (description
               " Returns the modifiers (also known as access flags) for a reference type. The returned \n      bit mask contains information on the declaration of the reference type. If the reference type is an \n      array or a primitive class (for example java.lang.Integer.TYPE) the value of the returned bit mask is \n      undefined.")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data ("Modifier bits as defined in the VM Specification" int))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command fields 4
              (description
               " Returns information for each field in a reference type. Inherited fields are not \n      included. The field list will include any synthetic fields created by the compiler. Fields are returned \n      in the order they occur in the class file.")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data
               (list
                (int "Number of declared fields.")
                (struct
                 (fieldid "Field ID" fieldid)
                 (name "Name of field" string)
                 (signature "JNI Signature of field" string)
                 (modbits
                  "The modifier bit flags (also known as access flags) which provide \n        additional information on the  field declaration. Individual flag values are defined in the VM \n        Specification.In addition The 0xf0000000 bit identifies the field as synthetic if the synthetic \n        attribute capability is available."
                  int))))
              (error-data
               (class_not_prepared "Class has been loaded but not yet prepared.")
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command methods 5
              (description
               " Returns information for each method in a reference type. Inherited methodss \n      are not included. The list of methods will include constructors (identified with the name \n      <init>) the initialization method (identified with the name <clinit>) if present and any \n      synthetic methods created by the compiler. Methods are returned in the order they occur in the \n      class file.")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data
               (list
                (int "Number of declared methods.")
                (struct
                 (methodid "Method ID" methodid)
                 (name "Name of method" string)
                 (signature "JNI Signature of method" string)
                 (modbits
                  "The modifier bit flags (also known as access flags) which \n        provide additional information on the  method declaration. Individual flag values are \n        defined in the VM Specification.In addition The 0xf0000000 bit identifies the method as \n        synthetic if the synthetic attribute capability is available."
                  int))))
              (error-data
               (class_not_prepared "Class has been loaded but not yet prepared.")
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command getvalues 6
              (description
               " Returns the value of one or more static fields of the reference type. \n      Each field must be member of the reference type or one of its superclasses superinterfaces \n      or implemented interfaces. Access control is not enforced; for example the values of \n      private fields can be obtained.")
              (out-data
               (struct
                (reftype "The reference type ID." referencetypeid)
                (fields "" (list (int "The number of values to get") ("A field to get" fieldid)))))
              (reply-data (list (int "The number of values returned") ("The field name" value)))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (invalid_fieldid "Invalid field")
               (vm_dead "The virtual machine is not running.")))

     (command sourcefile 7
              (description "Returns the name of source file in which a reference type was declared.")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data ("The source file name. No path information for the file is included" string))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command nestedtypes 8
              (description
               "Returns the classes and interfaces directly nested within this type. Types further \n      nested within those types are not included.")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data
               (list
                (int "The number of nested classes and interfaces")
                (struct
                 (reftypetag "Kind of following reference type." byte)
                 (typeid "The nested class or interface ID." referencetypeid))))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command status 9
              (description
               "Returns the current status of the reference type. The status indicates the extent \n      to which the reference type has been initialized as described in the VM specification. The returned \n      status bits are undefined for array types and for primitive classes (such as java.lang.Integer.TYPE).")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data ("Status bits:See JDWP.ClassStatus" int))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command interfaces 10
              (description
               "Returns the interfaces declared as implemented by this class. Interfaces indirectly \n      implemented (extended by the implemented interface or implemented by a superclass) are not included.")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data
               (list (int "The number of implemented interfaces") ("implemented interface." interfaceid)))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command classobject 11
              (description "Returns the class object corresponding to this type.")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data ("class object." classobjectid))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command sourcedebugextension 12
              (description
               "Returns the value of the SourceDebugExtension attribute. Since JDWP version 1.4.")
              (out-data ("The reference type ID." referencetypeid))
              (reply-data ("extension attribute" string))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (absent_information "If the extension is not specified.")
               (not_implemented "The functionality is not implemented in this virtual machine.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     classtype
     3

     (command superclass 1
              (description "Returns the immediate superclass of a class.")
              (out-data ("The class type ID" classid))
              (reply-data
               ("The superclass (null if the class ID for java.lang.Object is \n      specified)." classid))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command setvalues 2
              (description
               "Sets the value of one or more static fields. Each field must be member of the \n      class type or one of its superclasses superinterfaces or implemented interfaces. Access control \n      is not enforced; for example the values of private fields can be set. Final fields cannot be set. \n      For primitive values the values type must match the fields type exactly. For object values \n      there must exist a widening reference conversion from the values type to the fields type and the \n      fields type must be loaded.")
              (out-data
               (struct
                (clazz "The class type ID" classid)
                (values
                 ""
                 (list
                  (int "The number of fields to set.")
                  (struct
                   (fieldid "Field to set" fieldid)
                   (value "Value to put in the field." untagged_value))))))
              (reply-data void)
              (error-data
               (invalid_class "clazz is not the ID of a class.")
               (class_not_prepared "Class has been loaded but not yet prepared.")
               (invalid_object
                "clazz is not a known ID or a value of an object parameter is not \n      a known ID.")
               (invalid_fieldid "Invalid field.")
               (vm_dead "The virtual machine is not running.")))

     (command invokemethod 3
              (description
               "Invokes a static method. The method must be member of the class type or one of \n      its superclasses superinterfaces or implemented interfaces. Access control is not enforced; for \n      example private methods can be invoked. The method invocation will occur in the specified thread. \n      Method invocation can occur only if the specified thread has been suspended by an event. Method \n      invocation is not supported when the target VM has been suspended by the front-end. The specified \n      method is invoked with the arguments in the specified argument list. The method invocation is \n      synchronous; the reply packet is not sent until the invoked method returns in the target VM. \n      The return value (possibly the void value) is included in the reply packet. If the invoked method \n      throws an exception the exception object ID is set in the reply packet; otherwise the exception \n      object ID is null. For primitive arguments the argument values type must match the arguments \n      type exactly. For object arguments there must exist a widening reference conversion from the \n      argument values type to the arguments type and the arguments type must be loaded. By default \n      all threads in the target VM are resumed while the method is being invoked if they were previously \n      suspended by an event or by command. This is done to prevent the deadlocks that will occur if any \n      of the threads own monitors that will be needed by the invoked method. It is possible that \n      breakpoints or other events might occur during the invocation. Note however that this implicit\n      resume acts exactly like the ThreadReference resume command so if the threads suspend count is \n      greater than 1 it will remain in a suspended state during the invocation. By default when the \n      invocation completes all threads in the target VM are suspended regardless their state before \n      the invocation. The resumption of other threads during the invoke can be prevented by specifying \n      the INVOKE_SINGLE_THREADED bit flag in the options field; however there is no protection against \n      or recovery from the deadlocks described above so this option should be used with great caution.\n      Only the specified thread will be resumed (as described for all threads above). Upon completion of \n      a single threaded invoke the invoking thread will be suspended once again. Note that any threads\n      started during the single threaded invocation will not be suspended when the invocation completes. \n      If the target VM is disconnected during the invoke (for example through the VirtualMachine dispose \n      command) the method invocation continues.")
              (out-data
               (struct
                (clazz "The class type ID." classid)
                (thread "The thread in which to invoke." threadid)
                (methodid "The method to invoke." methodid)
                (arguments "" (list (int "The number of arguments") ("The argument value" value)))
                (options "Invocation options." int)))
              (reply-data
               (struct
                (returnvalue "The return value." value)
                (exception "The thrown exception." tagged_objectid)))
              (error-data
               (invalid_class "clazz is not the ID of a class.")
               (invalid_object
                "clazz is not a known ID or a value of an object parameter is not \n      a known ID.")
               (invalid_methodid "methodID is not the ID of a method.")
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (thread_not_suspended "If the specified thread has not been suspended by an event.")
               (vm_dead "The virtual machine is not running.")))

     (command newinstance 4
              (description
               "Creates a new object of this type invoking the specified constructor. The \n      constructor method ID must be a member of the class type.Instance creation will occur in the \n      specified thread. Instance creation can occur only if the specified thread has been suspended \n      by an event. Method invocation is not supported when the target VM has been suspended by the \n      front-end. The specified constructor is invoked with the arguments in the specified argument \n      list. The constructor invocation is synchronous; the reply packet is not sent until the invoked \n      method returns in the target VM. The return value (possibly the void value) is included in the \n      reply packet. If the constructor throws an exception the exception object ID is set in the \n      reply packet; otherwise the exception object ID is null. For primitive arguments the argument \n      values type must match the arguments type exactly. For object arguments there must exist a \n      widening reference conversion from the argument values type to the arguments type and the \n      arguments type must be loaded. By default all threads in the target VM are resumed while the \n      method is being invoked if they were previously suspended by an event or by command. This is \n      done to prevent the deadlocks that will occur if any of the threads own monitors that will be \n      needed by the invoked method. It is possible that breakpoints or other events might occur during \n      the invocation. Note however that this implicit resume acts exactly like the ThreadReference \n      resume command so if the threads suspend count is greater than 1 it will remain in a \n      suspended state during the invocation. By default when the invocation completes all threads \n      in the target VM are suspended regardless their state before the invocation. The resumption of \n      other threads during the invoke can be prevented by specifying the INVOKE_SINGLE_THREADED bit \n      flag in the options field; however there is no protection against or recovery from the \n      deadlocks described above so this option should be used with great caution. Only the specified \n      thread will be resumed (as described for all threads above). Upon completion of a single \n      threaded invoke the invoking thread will be suspended once again. Note that any threads started \n      during the single threaded invocation will not be suspended when the invocation completes. If \n      the target VM is disconnected during the invoke (for example through the VirtualMachine dispose \n      command) the method invocation continues.")
              (out-data
               (struct
                (clazz "The class type ID." classid)
                (thread "The thread in which to invoke the constructor." threadid)
                (methodid "The method to invoke." methodid)
                (arguments "" (list (int "The number of arguments") ("The argument value" value)))
                (options "Constructor invocation options." int)))
              (reply-data
               (struct
                (newobject
                 "The newly created object or null if the constructor \n      threw an exception"
                 tagged_objectid)
                (exception "The thrown exception if any; otherwise null." tagged_objectid)))
              (error-data
               (invalid_class "clazz is not the ID of a class.")
               (invalid_object
                "clazz is not a known ID or a value of an object parameter is not \n      a known ID.")
               (invalid_methodid "methodID is not the ID of a method.")
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (thread_not_suspended "If the specified thread has not been suspended by an event.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     arraytype
     4

     (command newinstance 1
              (description "Creates a new array object of this type with a given length.")
              (out-data
               (struct
                (arrtype "The array type of the new instance." arraytypeid)
                (length "The length of the array." int)))
              (reply-data ("The newly created array object." tagged_objectid))
              (error-data
               (invalid_array "The array is invalid.\312")
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (vm_dead "The virtual machine is not running."))))



    (command-set interfacetype 5)



    (command-set
     method
     6

     (command linetable 1
              (description
               " Returns line number information for the method. The line table maps source \n      line numbers to the initial code index of the line. The line table is ordered by code index \n      (from lowest to highest).")
              (out-data (struct (reftype "The class." referencetypeid) (methodid "The method." methodid)))
              (reply-data
               (struct
                (start "Lowest valid code index for the method." long)
                (end "Highest valid code index for the method." long)
                (lines
                 ""
                 (list
                  (int "The number of lines.")
                  (struct
                   (linecodeindex "Initial code index of the line (unsigned)." long)
                   (linenumber "Line number." int))))))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (invalid_methodid "methodID is not the ID of a method.")
               (vm_dead "The virtual machine is not running.")))

     (command variabletable 2
              (description
               "Returns variable information for the method. The variable table includes \n      arguments and locals declared within the method. For instance methods the this reference \n      is included in the table. Also synthetic variables may be present.  ")
              (out-data (struct (reftype "The class." referencetypeid)
                                (methodid "The method." methodid)))
              (reply-data
               (struct
                (argcnt
                 "The number of words in the frame used by arguments. Eight-byte \n      arguments use two words; all others use one."
                 int)
                (slots
                 ""
                 (list
                  (int "The number of variables.")
                  (struct
                   (codeindex
                    "First code index at which the variable is visible (unsigned). \n        Used in conjunction with length. The variable can be get or set only when the current codeIndex \n        <= current frame code index < codeIndex + length"
                    long)
                   (name "The variables name." string)
                   (signature "The variable types JNI signature." string)
                   (length
                    "Unsigned value used in conjunction with codeIndex. The variable can \n        be get or set only when the current codeIndex <= current frame code index < code index + length"
                    int)
                   (slot "The local variables index in its frame" int))))))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (invalid_methodid "methodID is not the ID of a method.")
               (vm_dead "The virtual machine is not running.")))

     (command bytecodes 3
              (description "Retrieve the methods bytecodes as defined in the JVM Specification.")
              (out-data (struct (reftype "The class." referencetypeid) (methodid "The method." methodid)))
              (reply-data (list (int "The number of bytes") ("The Java bytecode." byte)))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (invalid_methodid "methodID is not the ID of a method.")
               (not_implemented
                "If the target virtual machine does not support the retrieval of \n      bytecodes.")
               (vm_dead "The virtual machine is not running.")))

     (command isobsolete 4
              (description "Determine if this method is obsolete.")
              (out-data (struct (reftype "The class." referencetypeid) (methodid "The method." methodid)))
              (reply-data
               ("true if this method has been replacedby a non-equivalent \n      method usingthe RedefineClasses command"
                boolean))
              (error-data
               (invalid_class "refType is not the ID of a reference type.")
               (invalid_object "refType is not a known ID.")
               (invalid_methodid "methodID is not the ID of a method.")
               (not_implemented "If the target virtual machine does not support this query")
               (vm_dead "The virtual machine is not running."))))



    (command-set field 8)



    (command-set
     objectreference
     9

     (command referencetype 1
              (description
               "Returns the runtime type of the object. The runtime type will be a class or \n      an array.")
              (out-data ("The object ID" objectid))
              (reply-data
               (struct
                (reftypetag "Kind of following reference type." byte)
                (typeid "The runtime reference type." referencetypeid)))
              (error-data
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (vm_dead "The virtual machine is not running.")))

     (command getvalues 2
              (description
               "Returns the value of one or more instance fields. Each field must be member of \n      the objects type or one of its superclasses superinterfaces or implemented interfaces. Access \n      control is not enforced; for example the values of private fields can be obtained.")
              (out-data
               (struct
                (object "The object ID" objectid)
                (fields "" (list (int "The number of fields to get") ("Field to get" fieldid)))))
              (reply-data (list (int "The number of values returned") ("The field value" value)))
              (error-data
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (invalid_fieldid "Invalid field")
               (vm_dead "The virtual machine is not running.")))

     (command setvalues 3
              (description
               "Sets the value of one or more instance fields. Each field must be member of the \n      objects type or one of its superclasses superinterfaces or implemented interfaces. Access \n      control is not enforced; for example the values of private fields can be set. For primitive \n      values the values type must match the fields type exactly. For object values there must be a \n      widening reference conversion from the values type to the fields type and the fields type \n      must be loaded.")
              (out-data
               (struct
                (object "The object ID" objectid)
                (values
                 ""
                 (list
                  (int "The number of fields to set.")
                  (struct
                   (fieldid "Field to set." fieldid)
                   (value "Value to put in the field." untagged_value))))))
              (reply-data void)
              (error-data
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (invalid_fieldid "Invalid field")
               (vm_dead "The virtual machine is not running.")))

     (command monitorinfo 4
              (description
               "Returns monitor information for an object. All threads int the VM must be \n      suspended.")
              (out-data ("The object ID" objectid))
              (reply-data
               (struct
                (owner "The monitor owner or null if it is not currently owned." threadid)
                (entrycount "The number of times the monitor has been entered." int)
                (waiters
                 ""
                 (list
                  (int
                   "The number of threads that are waiting for the monitor 0 if there \n      is no current owner")
                  ("A thread waiting for this monitor." threadid)))))
              (error-data
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (not_implemented "The functionality is not implemented in this virtual machine.")
               (vm_dead "The virtual machine is not running.")))

     (command invokemethod 5
              (description
               "Invokes a instance method. The method must be member of the objects type or one
of its superclasses superinterfaces or implemented interfaces. Access control is not enforced;
for example private methods can be invoked. The method invocation will occur in the specified
thread. Method invocation can occur only if the specified thread has been suspended by an event.
Method invocation is not supported when the target VM has been suspended by the front-end. The
specified method is invoked with the arguments in the specified argument list. The method invocation
is synchronous; the reply packet is not sent until the invoked method returns in the target VM. The
return value (possibly the void value) is included in the reply packet. If the invoked method throws
an exception the exception object ID is set in the reply packet; otherwise the exception object ID
is null. For primitive arguments the argument values type must match the arguments type exactly.
For object arguments there must be a widening reference conversion from the argument values type
to the arguments type and the arguments type must be loaded. By default all threads in the target
VM are resumed while the method is being invoked if they were previously suspended by an event or by
command. This is done to prevent the deadlocks that will occur if any of the threads own monitors
that will be needed by the invoked method. It is possible that breakpoints or other events might
occur during the invocation. Note however that this implicit resume acts exactly like the
ThreadReference resume command so if the threads suspend count is greater than 1 it will remain
in a suspended state during the invocation. By default when the invocation completes all threads
in the target VM are suspended regardless their state before the invocation. The resumption of other
threads during the invoke can be prevented by specifying the INVOKE_SINGLE_THREADED bit flag in the
options field; however there is no protection against or recovery from the deadlocks described above
so this option should be used with great caution. Only the specified thread will be resumed (as
described for all threads above). Upon completion of a single threaded invoke the invoking thread
will be suspended once again. Note that any threads started during the single threaded invocation will
not be suspended when the invocation completes. If the target VM is disconnected during the invoke
(for example through the VirtualMachine dispose command) the method invocation continues.");"
              (out-data
               (struct
                (object "The object ID" objectid)
                (thread "The thread in which to invoke." threadid)
                (clazz "The class type." classid)
                (methodid "The method to invoke" methodid)
                (arguments "" (list (int "The number of arguments") ("The argument value" value)))
                (options "Invocation options" int)))
              (reply-data
               (struct
                (returntype "The returned value or null if an exception is thrown." value)
                (exception "The thrown exception if any." tagged_objectid)))
              (error-data
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (invalid_class "clazz is not the ID of a reference type.")
               (invalid_methodid "methodID is not the ID of a method.")
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (thread_not_suspended "If the specified thread has not been suspended by an event.")
               (vm_dead "The virtual machine is not running.")))

     (command disablecollection 6
              (description
               "Prevents garbage collection for the given object. By default all objects in \n      end replies may be collected at any time the target VM is running. A call to this command \n      guarantees that the object will not be collected. The EnableCollection command can be used to \n      allow collection once again. Note that while the target VM is suspended no garbage collection \n      will occur because all threads are suspended. The typical examination of variables fields and \n      arrays during the suspension is safe without explicitly disabling garbage collection. This method \n      should be used sparingly as it alters the pattern of garbage collection in the target VM and \n      consequently may result in application behavior under the debugger that differs from its \n      non-debugged behavior.")
              (out-data ("The object ID" objectid))
              (reply-data void)
              (error-data
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (vm_dead "The virtual machine is not running.")))

     (command enablecollection 7
              (description
               "Permits garbage collection for this object. By default all objects returned by \n      the JDWP may be collected at any time the target VM is running. A call to this command is necessary \n      only if garbage collection was previously disabled with the DisableCollection command.  ")
              (out-data ("The object ID" objectid))
              (reply-data void)
              (error-data (vm_dead "The virtual machine is not running.")))

     (command iscollected 8
              (description "Determines whether an object has been garbage collected in the target VM.")
              (out-data ("The object ID" objectid))
              (reply-data ("true if the object has been collected; false otherwise" boolean))
              (error-data
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     stringreference
     10

     (command value 1
              (description "Returns the characters contained in the string.")
              (out-data ("The string object ID" objectid))
              (reply-data ("The value of the String." string))
              (error-data
               (invalid_string "The string is invalid.")
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     threadreference
     11

     (command name 1
              (description "Returns the thread name.")
              (out-data ("The thread object ID." threadid))
              (reply-data ("The thread name." string))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command suspend 2
              (description
               "Suspends the thread. Unlike java.lang.Thread.suspend() suspends of both the \n      virtual machine and individual threads are counted. Before a thread will run again it must be \n      resumed the same number of times it has been suspended. Suspending single threads with command \n      has the same dangers java.lang.Thread.suspend(). If the suspended thread holds a monitor needed \n      by another running thread deadlock is possible in the target VM (at least until the suspended \n      thread is resumed again). The suspended thread is guaranteed to remain suspended until resumed \n      through one of the JDI resume methods mentioned above; the application in the target VM cannot \n      resume the suspended thread through {@link java.lang.Thread#resume}. Note that this doesnt \n      change the status of the thread (see the ThreadStatus command.) For example if it was Running \n      it will still appear running to other threads.  ")
              (out-data ("The thread object ID." threadid))
              (reply-data void)
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command resume 3
              (description
               "Resumes the execution of a given thread. If this thread was not previously \n      suspended by the front-end calling this command has no effect. Otherwise the count of pending \n      suspends on this thread is decremented. If it is decremented to 0 the thread will continue to \n      execute.")
              (out-data ("The thread object ID." threadid))
              (reply-data void)
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command status 4
              (description
               "Returns the current status of a thread. The thread status reply indicates the \n      thread status the last time it was running. the suspend status provides information on the \n      threads suspension if any.")
              (out-data ("The thread object ID." threadid))
              (reply-data
               (struct
                (threadstatus "One of the thread status codes See JDWP.ThreadStatus" int)
                (suspendstatus "One of the suspend status codes See JDWP.SuspendStatus" int)))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command threadgroup 5
              (description "Returns the thread group that contains a given thread.")
              (out-data ("The thread object ID." threadid))
              (reply-data ("The thread group of this thread." threadgroupid))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command frames 6
              (description
               "Returns the current call stack of a suspended thread. The sequence of frames \n      starts with the currently executing frame followed by its caller and so on. The thread must \n      be suspended and the returned frameID is valid only while the thread is suspended.")
              (out-data
               (struct
                (thread "The thread object ID." threadid)
                (startframe "The index of the first frame to retrieve." int)
                (length "The count of frames to retrieve (-1 means all remaining)." int)))
              (reply-data
               (list
                (int "The number of frames retreived")
                (struct
                 (frameid "The ID of this frame." frameid)
                 (location "The current location of this frame" location))))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command framecount 7
              (description
               " Returns the count of frames on this threads stack. The thread must be \n      suspended and the returned count is valid only while the thread is suspended. Returns \n      JDWP.Error.errorThreadNotSuspended if not suspended.")
              (out-data ("The thread object ID." threadid))
              (reply-data ("The count of frames on this threads stack." int))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command ownedmonitors 8
              (description
               "Returns the objects whose monitors have been entered by this thread. The \n      thread must be suspended and the returned information is relevant only while the thread is \n      suspended.")
              (out-data ("The thread object ID." threadid))
              (reply-data (list (int "The number of owned monitors") ("The owned monitor" tagged_objectid)))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (not_implemented "The functionality is not implemented in this virtual machine.")
               (vm_dead "The virtual machine is not running.")))

     (command currentcontendedmonitor 9
              (description
               "Returns the object if any for which this thread is waiting for monitor entry \n      or with java.lang.Object.wait. The thread must be suspended and the returned information is \n      relevant only while the thread is suspended.")
              (out-data ("The thread object ID." threadid))
              (reply-data
               ("The contended monitor or null if there is no current \n      contended monitor."
                tagged_objectid))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (not_implemented "The functionality is not implemented in this virtual machine.")
               (vm_dead "The virtual machine is not running.")))

     (command stop 10
              (description
               "Stops the thread with an asynchronous exception as if done by java.lang.Thread.stop")
              (out-data
               (struct
                (thread "The thread object ID." threadid)
                (throwable
                 "Asynchronous exception. This object must be an instance of \n      java.lang.Throwable or a subclass"
                 objectid)))
              (reply-data void)
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object
                "If thread is not a known ID or the asynchronous exception has been \n      garbage collected.\312")
               (vm_dead "The virtual machine is not running.")))

     (command interrupt 11
              (description "Interrupt the thread as if done by java.lang.Thread.interrupt")
              (out-data ("The thread object ID." threadid))
              (reply-data void)
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command suspendcount 12
              (description
               " Get the suspend count for this thread. The suspend count is the  number of times \n      the thread has been suspended through the thread-level or VM-level suspend commands without a \n      corresponding resume")
              (out-data ("The thread object ID." threadid))
              (reply-data ("The number of outstanding suspends of this thread." int))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     threadgroupreference
     12

     (command name 1
              (description "Returns the thread group name.")
              (out-data ("The thread group object ID." threadgroupid))
              (reply-data ("The thread group name." string))
              (error-data
               (invalid_thread_group "Thread group invalid.")
               (invalid_object "group is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command parent 2
              (description "Returns the thread group if any which contains a given thread group.")
              (out-data ("The thread group object ID." threadgroupid))
              (reply-data
               ("The parent thread group object or null if the given \n      thread group is a top-level thread group."
                threadgroupid))
              (error-data
               (invalid_thread_group "Thread group invalid.")
               (invalid_object "group is not a known ID.")
               (vm_dead "The virtual machine is not running.")))

     (command children 3
              (description
               "Returns the threads and thread groups directly contained in this thread group. \n      Threads and thread groups in child thread groups are not included.")
              (out-data ("The thread group object ID." threadgroupid))
              (reply-data
               (struct
                (childthreads
                 ""
                 (list (int "The number of child threads.") ("A direct child thread ID." threadid)))
                (childgroups
                 ""
                 (list
                  (int "The number of child thread groups.")
                  ("A direct child thread group ID." threadgroupid)))))
              (error-data
               (invalid_thread_group "Thread group invalid.")
               (invalid_object "group is not a known ID.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     arrayreference
     13

     (command length 1
              (description "Returns the number of components in a given array.")
              (out-data ("The array object ID." arrayid))
              (reply-data ("The length of the array." int))
              (error-data
               (invalid_object "arrayObject is not a known ID.")
               (invalid_array "The array is invalid.")
               (vm_dead "The virtual machine is not running.")))

     (command getvalues 2
              (description
               "Returns a range of array components. The specified range must be within the \n      bounds of the array.")
              (out-data
               (struct
                (arrayobject "The array object ID." arrayid)
                (firstindex "The first index to retrieve" int)
                (length "The number of components to retrieve." int)))
              (reply-data
               ("The retrieved values. If the values are objects they are \n      tagged-values; otherwise they are untagged-values"
                arrayregion))
              (error-data
               (invalid_length "If index is beyond the end of this array.")
               (invalid_object "arrayObject is not a known ID.")
               (invalid_array "The array is invalid.")
               (vm_dead "The virtual machine is not running.")))

     (command setvalues 3
              (description
               " Sets a range of array components. The specified range must be within the bounds \n      of the array. For primitive values each values type must match the array component type exactly. \n      For object values there must be a widening reference conversion from the values type to the \n      array component type and the array component type must be loaded.")
              (out-data
               (struct
                (arrayobject "The array object ID." arrayid)
                (firstindex "The first index to set." int)
                (values
                 ""
                 (list (int "The number of values to set.") ("A value to set." untagged_value)))))
              (reply-data void)
              (error-data
               (invalid_length "If index is beyond the end of this array.")
               (invalid_object "arrayObject is not a known ID.")
               (invalid_array "The array is invalid.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     classloaderreference
     14

     (command visibleclasses 1
              (description
               "Returns a list of all classes which this class loader has been requested to load. \n      This class loader is considered to be an initiating class loader for each class in the returned \n      list. The list contains each reference type defined by this loader and any types for which loading \n      was delegated by this class loader to another class loader. The visible class list has useful \n      properties with respect to the type namespace. A particular type name will occur at most once in \n      the list. Each field or variable declared with that type name in a class defined by this class \n      loader must be resolved to that single type. No ordering of the returned list is guaranteed.")
              (out-data ("The class loader object ID." classloaderid))
              (reply-data
               (list
                (int "The number of visible classes.")
                (struct
                 (reftypetag "Kind of following reference type." byte)
                 (typeid "A class visible to this class loader." referencetypeid))))
              (error-data
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (invalid_class_loader "The class loader is invalid.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     eventrequest
     15

     (command set 1
              (description
               "Set an event request. When the event described by this request occurs an event \n      is sent from the target VM.")
              (out-data
               (struct
                (eventkind
                 "Event kind to request. See JDWP.EventKind for a complete list of \n      events that can be requested."
                 byte)
                (suspendpolicy
                 "What threads are suspended when this event occurs? Note that \n      the order of events and command replies accurately reflects the order in which threads are suspended \n      and resumed. For example if a VM-wide resume is processed before an event occurs which suspends \n      the VM the reply to the resume command will be written to the transport before the suspending event."
                 byte)
                (modifiers
                 ""
                 (list
                  (int
                   "Constraints used to control the number of generated events. Modifiers \n      specify additional tests that an event must satisfy before it is placed in the event queue. Events \n      are filtered by applying each modifier to an event in the order they are specified in this collection \n      Only events that satisfy all modifiers are reported. Filtering can improve debugger performance \n      dramatically by reducing the amount of event traffic sent from the target VM to the debugger VM.")
                  (cases
                   (byte "Modifier kind")
                   (count
                    1
                    "Limit the requested event to be reported at most once after a given number \n          of occurrences.  The event is not reported the first count - 1 times this filter is reached. \n          To request a one-off event call this method with a count of 1. Once the count reaches 0 any \n          subsequent filters in this request are applied. If none of those filters cause the event to be \n          suppressed the event is reported. Otherwise the event is not reported. In either case \n          subsequent events are never reported for this request. This modifier can be used with any \n          event kind."
                    ("Count before event. One for one-off." int))
                   (conditional 2 "Conditional on expression" ("For the future" int))
                   (threadonly
                    3
                    "Restricts reported events to those in the given thread. This modifier \n          can be used with any event kind except for class unload."
                    ("Required thread" threadid))
                   (classonly
                    4
                    "For class prepare events restricts the events generated by this request \n          to be the preparation of the given reference type and any subtypes. For other events restricts \n          the events generated by this request to those whose location is in the given reference type or \n          any of its subtypes. An event will be generated for any location in a reference type that can \n          be safely cast to the given reference type. This modifier can be used with any event kind except \n          class unload thread start and thread )."
                    ("Required class" referencetypeid))
                   (classmatch
                    5
                    "Restricts reported events to those for classes whose name matches the \n          given restricted regular expression. For class prepare events the prepared class name is matched. \n          For class unload events the unloaded class name is matched. For other events the class name of \n          the events location is matched. This modifier can be used with any event kind except thread start \n          and thread )."
                    ("Required class pattern. Matches are limited to exact matches \n            of the given class pattern and matches of patterns that begin or ) with *; for example \n            *.Foo or java.*."
                     string))
                   (classexclude
                    6
                    "Restricts reported events to those for classes whose name does not match \n          the given restricted regular expression. For class prepare events the prepared class name is \n          matched. For class unload events the unloaded class name is matched. For other events the class \n          name of the events location is matched. This modifier can be used with any event kind except \n          thread start and thread )."
                    ("Disallowed class pattern. Matches are limited to exact matches \n            of the given class pattern and matches of patterns that begin or end with *; for example \n            *.Foo or java.*."
                     string))
                   (locationonly
                    7
                    "Restricts reported events to those that occur at the given location. \n          This modifier can be used with breakpoint field access field modification step and exception \n          event kinds."
                    ("Required location" location))
                   (exceptiononly
                    8
                    "Restricts reported exceptions by their class and whether they are \n          caught or uncaught. This modifier can be used with exception event kinds only."
                    (struct
                     (exceptionornull
                      "Exception to report. Null (0) means report \n            exceptions of all types. A non-null type restricts the reported exception events to exceptions \n            of the given type or any of its subtypes."
                      referencetypeid)
                     (caught "Report caught exceptions" boolean)
                     (uncaught
                      "Report uncaught exceptions. Note that it is not always possible \n            to determine whether an exception is caught or uncaught at the time it is thrown. See the \n            exception event catch location under composite events for more information."
                      boolean)))
                   (fieldonly
                    9
                    "Restricts reported events to those that occur for a given field. This \n          modifier can be used with field access and field modification event kinds only."
                    (struct
                     (declaring "Type in which field is declared." referencetypeid)
                     (fieldid "Required field" fieldid)))
                   (step
                    10
                    "Restricts reported step events to those which satisfy depth and size \n          constraints. This modifier can be used with step event kinds only."
                    (struct
                     (thread "Thread in which to step" threadid)
                     (size "size of each step. See JDWP.StepSize" int)
                     (depth "relative call stack limit. See JDWP.StepDepth" int)))
                   (instanceonly
                    11
                    "Restricts reported events to those whose active this object is the \n          given object. Match value is the null object for static methods. This modifier can be used with \n          any event kind except class prepare class unload thread start and thread ). Introduced in \n          JDWP version 1.4."
                    ("Required this object" objectid)))))))
              (reply-data ("ID of created request" int))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_class "Invalid class.")
               (invalid_string "The string is invalid.")
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (invalid_count "The count is invalid.")
               (invalid_fieldid "Invalid field.")
               (invalid_methodid "Invalid method.")
               (invalid_location "Invalid location.")
               (invalid_event_type "The specified event type id is not recognized.")
               (not_implemented "The functionality is not implemented in this virtual machine.")
               (vm_dead "The virtual machine is not running.")))

     (command clear 2
              (description "Clear an event request.")
              (out-data (struct (event "Event type to clear" byte)
                                (requestid "ID of request to clear" int)))
              (reply-data void)
              (error-data (vm_dead "The virtual machine is not running.")))

     (command clearallbreakpoints 3
              (description "Removes all set breakpoints.")
              (out-data void)
              (reply-data void)
              (error-data (vm_dead "The virtual machine is not running."))))



    (command-set
     stackframe
     16

     (command getvalues 1
              (description
               "Returns the value of one or more local variables in a given frame. Each variable \n      must be visible at the frames code index. Even if local variable information is not available \n      values can be retrieved if the front-end is able to determine the correct local variable index. \n      (Typically this index can be determined for method arguments from the method signature without \n      access to the local variable table information.)")
              (out-data
               (struct
                (thread "The frames thread." threadid)
                (frame "The frame ID." frameid)
                (slots
                 ""
                 (list
                  (int "The number of values to get.")
                  (struct
                   (slot "The local variables index in the frame." int)
                   (sigbyte "A tag identifying the type of the variable" byte))))))
              (reply-data
               (list (int "The number of values retrieved.") ("The value of the local variable." value)))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (invalid_frameid "Invalid jframeID")
               (vm_dead "The virtual machine is not running.")))

     (command setvalues 2
              (description
               "Sets the value of one or more local variables. Each variable must be visible \n      at the current frame code index. For primitive values the values type must match the variables \n      type exactly. For object values there must be a widening reference conversion from the values \n      type to the variables type and the variables type must be loaded. Even if local variable \n      information is not available values can be set if the front-end is able to determine the \n      correct local variable index. (Typically this index can be determined for method arguments from \n      the method signature without access to the local variable table information.)")
              (out-data
               (struct
                (thread "The frames thread." threadid)
                (frame "The frame ID." frameid)
                (slotvalues
                 ""
                 (list
                  (int "The number of values to set.")
                  (struct (slot "The slot ID." int) (slotvalue "The value of to set." value))))))
              (reply-data void)
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (invalid_frameid "Invalid jframeID")
               (vm_dead "The virtual machine is not running.")))

     (command thisobject 3
              (description
               " Returns the value of the this reference for this frame. If the frames method \n      is static or native the reply will contain the null object reference.")
              (out-data (struct (thread "The frames thread." threadid) (frame "The frame ID." frameid)))
              (reply-data ("The this object for this frame." tagged_objectid))
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (invalid_frameid "Invalid jframeID")
               (vm_dead "The virtual machine is not running.")))

     (command popframes 4
              (description "Pop stack frames thru and including frame.Since JDWP version 1.4.")
              (out-data (struct (thread "The frames thread." threadid) (frame "The frame ID." frameid)))
              (reply-data void)
              (error-data
               (invalid_thread "Passed thread is not a valid thread or has exited.")
               (invalid_object "thread is not a known ID.")
               (invalid_frameid "Invalid jframeID")
               (jvmdi_error_thread_not_suspended "TODO")
               (jvmdi_error_no_more_frames "TODO")
               (not_implemented "The functionality is not implemented in this virtual machine.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     classobjectreference
     17

     (command reflectedtype 1
              (description "Returns the reference type reflected by this class object.")
              (out-data ("The class object." classobjectid))
              (reply-data
               (struct
                (reftypetag "Kind of following reference type." byte)
                (typeid "reflected reference type" referencetypeid)))
              (error-data
               (invalid_object "If this reference type has been unloaded and garbage collected.")
               (vm_dead "The virtual machine is not running."))))



    (command-set
     event
     64

     (command composite 100
              (description
               "Several events may occur at a given time in the target VM. For example there \n      may be more than one breakpoint request for a given location or you might single step to the same \n      location as a breakpoint request.  These events are delivered together as a composite event.  For \n      uniformity a composite event is always used to deliver events even if there is only one event \n      to report. The events that are grouped in a composite event are restricted in the following ways \n      -- Always singleton composite events(VM Start Event VM Death Event) -- Only with other thread \n      start events for the same thread(Thread Start Event) -- Only with other thread death events for \n      the same thread(Thread Death Event) -- Only with other class prepare events for the same \n      class(Class Prepare Event) -- Only with other class unload events for the same \n      class(Class Unload Event) -- Only with other access watchpoint events for the same field \n      access(Access Watchpoint Event) -- Only with other modification watchpoint events for the same \n      field modification(Modification Watchpoint Event) -- Only with other ExceptionEvents for the \n      same exception occurrence(ExceptionEvent) -- Only with other members of this group at the same \n      location and in the same thread(Breakpoint Event Step Event Method Entry Event Method Exit Event)")
              (out-data void)
              (reply-data
               (struct
                (suspendpolicy "Which threads where suspended by this composite event?" byte)
                (events
                 ""
                 (list
                  (int "Events to set.")
                  (cases
                   (byte "Event kind selector")
                   (vmstart
                    90
                    "Notification of initialization of a target VM.  This \n          event is received before the main thread is started and before any application code has been \n          executed. Before this event occurs a significant amount of system code has executed and a number \n          of system classes have been loaded. This event is always generated by the target VM even if \n          not explicitly requested."
                    (struct
                     (requestid
                      "Request that generated event (or 0 if this event is \n            automatically generated"
                      int)
                     (thread "Initial thread" threadid)))
                   (singlestep
                    1
                    "Notification of step completion in the target VM. \n          The step event is generated before the code at its location is executed."
                    (struct
                     (requestid "Request that generated event" int)
                     (thread "Stepped thread" threadid)
                     (location "Location stepped to" location)))
                   (breakpoint
                    2
                    "Notification of a breakpoint in the target VM. \n          The breakpoint event is generated before the code at its location is executed."
                    (struct
                     (requestid "Request that generated event" int)
                     (thread "Thread which hit breakpoint" threadid)
                     (location "Location hit" location)))
                   (methodentry
                    40
                    "Notification of a method invocation in the \n          target VM. This event is generated before any code in the invoked method has executed. Method \n          entry events are generated for both native and non-native methods. In some VMs method entry \n          events can occur for a particular thread before its thread start event occurs if methods are \n          called as part of the threads initialization. "
                    (struct
                     (requestid "Request that generated event" int)
                     (thread "Thread which entered method" threadid)
                     (location "Location of entry" location)))
                   (methodexit
                    41
                    "Notification of a method return in the target \n          VM. This event is generated after all code in the method has executed but the location of \n          this event is the last executed location in the method. Method exit events are generated for \n          both native and non-native methods. Method exit events are not generated if the method \n          terminates with a thrown exception."
                    (struct
                     (requestid "Request that generated event" int)
                     (thread "Thread which exited method" threadid)
                     (location "Location of exit" location)))
                   (exception
                    30
                    "Notification of an exception in the target VM. \n          If the exception is thrown from a non-native method the exception event is generated at the \n          location where the exception is thrown. If the exception is thrown from a native method the \n          exception event is generated at the first non-native location reached after the exception is \n          thrown."
                    (struct
                     (requestid "Request that generated event" int)
                     (thread "Thread with exception" threadid)
                     (location
                      "Location of exception throw (or first non-native \n            location after throw if thrown from a native method)"
                      location)
                     (exception "Thrown exception" tagged_objectid)
                     (catchlocation
                      "Location of catch or 0 if not caught. An exception \n            is considered to be caught if at the point of the throw the current location is dynamically \n            enclosed in a try statement that handles the exception. (See the JVM specification for \n            details). If there is such a try statement the catch location is the first location in the \n            appropriate catch clause. If there are native methods in the call stack at the time of the \n            exception there are important restrictions to note about the returned catch location. In \n            such cases it is not possible to predict whether an exception will be handled by some native \n            method on the call stack. Thus it is possible that exceptions considered uncaught here will \n            in fact be handled by a native method and not cause termination of the target VM. \n            Furthermore it cannot be assumed that the catch location returned here will ever be reached \n            by the throwing thread. If there is a native frame between the current location and the catch \n            location the exception might be handled and cleared in that native method instead. Note that \n            compilers can generate try-catch blocks in some cases where they are not explicit in the \n            source code; for example the code generated for synchronized and finally blocks can contain \n            implicit try-catch blocks. If such an implicitly generated try-catch is present on the call \n            stack at the time of the throw the exception will be considered caught even though it appears \n            to be uncaught from examination of the source code."
                      location)))
                   (threadstart
                    6
                    "Notification of a new running thread in the \n          target VM. The new thread can be the result of a call to java.lang.Thread.start or the result \n          of attaching a new thread to the VM though JNI. The notification is generated by the new thread \n          some time before its execution starts. Because of this timing it is possible to receive other \n          events for the thread before this event is received. (Notably Method Entry Events and Method \n          Exit Events might occur during thread initialization. It is also possible for the VirtualMachine \n          AllThreads command to return a thread before its thread start event is received. Note that this \n          event gives no information about the creation of the thread object which may have happened much \n          earlier depending on the VM being debugged."
                    (struct
                     (requestid "Request that generated event" int)
                     (thread "Started thread" threadid)))
                   (threaddeath
                    7
                    "Notification of a completed thread in the target \n          VM. The notification is generated by the dying thread before it terminates. Because of this \n          timing it is possible for {@link VirtualMachine#allThreads} to return this thread after this \n          event is received. Note that this event gives no information about the lifetime of the thread \n          object. It may or may not be collected soon depending on what references exist in the target VM."
                    (struct
                     (requestid "Request that generated event" int)
                     (thread "Ending thread" threadid)))
                   (classprepare
                    8
                    "Notification of a class prepare in the target \n          VM. See the JVM specification for a definition of class preparation. Class prepare events are not \n          generated for primtiive classes (for example java.lang.Integer.TYPE)."
                    (struct
                     (requestid "Request that generated event" int)
                     (thread
                      "Preparing thread. In rare cases this event may occur in a \n            debugger system thread within the target VM. Debugger threads take precautions to prevent these \n            events but they cannot be avoided under some conditions especially for some subclasses of \n            java.lang.Error. If the event was generated by a debugger system thread the value returned \n            by this method is null and if the requested  suspend policy for the event was EVENT_THREAD \n            all threads will be suspended instead and the composite events suspend policy will reflect \n            this change. Note that the discussion above does not apply to system threads created by the \n            target VM during its normal (non-debug) operation."
                      threadid)
                     (reftypetag "Kind of reference type. See JDWP::TypeTag" byte)
                     (typeid "Type being prepared" referencetypeid)
                     (signature "Type signature" string)
                     (status "Status of type. See JDWP::ClassStatus" int)))
                   (classunload
                    9
                    "Notification of a class unload in the target \n          VM. There are severe constraints on the debugger end during garbage collection so unload \n          information is greatly limited. "
                    (struct
                     (requestid "Request that generated event" int)
                     (signature "Type signature" string)))
                   (fieldaccess
                    20
                    " JDWP.EventKind.FIELD_ACCESS: Notification of a \n          field access in the target VM. Field modifications are not considered field accesses. "
                    (struct
                     (requestid "Request that generated event" int)
                     (thread "Accessing thread" threadid)
                     (location "Location of access" location)
                     (reftypetag "Kind of reference type. See JDWP::TypeTag" byte)
                     (typeid "Type of the field" referencetypeid)
                     (fieldid "Field being accessed" fieldid)
                     (object "Object being accessed (null=0 for statics)" tagged_objectid)))
                   (fieldmodification
                    21
                    "Notification of a field modification \n          in the target VM. "
                    (struct
                     (requestid "Request that generated event" int)
                     (thread "Accessing thread" threadid)
                     (location "Location of access" location)
                     (reftypetag "Kind of reference type. See JDWP::TypeTag" byte)
                     (typeid "Type of the field" referencetypeid)
                     (fieldid "Field being modified" fieldid)
                     (object "Object being modified (null=0 for statics)" tagged_objectid)
                     (valuetobe "Value to be assigned" value)))
                   (vmdeath
                    99
                    "JVM shutting down"
                    ("Request that generated event" int)))))))
              (error-data))))

  ;(encode-virtualmachine-allclasses)
  )
  