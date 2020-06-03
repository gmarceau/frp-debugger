;;;
;;; This file was semi-manually generated from jdwpspec.rb using emacs macros.
;;;
(module jdwp_spec1 mzscheme
  (define-syntax (command-set stx) #'(void))
  (command-set VirtualMachine 1
               (command Version 1 
                        (description "Returns the JDWP version implemented by the target VM. 
      The version string format is implementation dependent.")
                        (reply-data string vm-description "Text information on the VM version")
                        (reply-data int jdwpMajor "Major JDWP Version number")
                        (reply-data int jdwpMinor "Minor JDWP Version number")
                        (reply-data string vmVersion "Target VM JRE version as in the java.version property")
                        (reply-data string vmName "Target VM name as in the java.vm.name property")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command ClassesBySignature 2 
                        (description "Returns reference types for all the classes loaded by the target VM which 
      match the given signature. Multple reference types will be returned if two or more 
      class loaders have loaded a class of the same name. The search is confined to loaded 
      classes only; no attempt is made to load a class of the given signature.")
                        (out-data string signature "JNI signature of the class to find 
      (for example Ljava/lang/String;).")
                        (reply-data int classes "Number of reference types that follow.")
                        (repeat classes
                                (reply-data byte refTypeTag "Kind of following reference type.")
                                (reply-data referenceTypeID typeID "Matching loaded reference type")
                                (reply-data int status "The current class status.")
                                )
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command AllClasses 3 
                        (description "Returns reference types for all classes currently loaded by the target VM.")
                        (reply-data int classes "Number of reference types that follow.")
                        (repeat classes
                                (reply-data byte refTypeTag "Kind of following reference type.")
                                (reply-data referenceTypeID typeID "Loaded reference type")
                                (reply-data string signature "The JNI signature of the loaded reference type")
                                (reply-data int status "The current class status.")
                                )
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command AllThreads 4 
                        (description "Returns all threads currently running in the target VM . The returned list 
      contains threads created through java.lang.Thread all native threads attached to the target 
      VM through JNI and system threads created by the target VM. Threads that have not yet been 
      started and threads that have completed their execution are not included in the returned list.")
                        (reply-data int threads "Number of threads to follow")
                        (repeat threads
                                (reply-data threadID thread "A running thread")
                                )
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command TopLevelThreadGroups 5 
                        (description "Returns all thread groups that do not have a parent. This command may be used 
      as the first step in building a tree (or trees) of the existing thread groups.")
                        (reply-data int groups "Number of thread groups that follow.")
                        (repeat groups
                                (reply-data threadGroupID group "A top level thread group")
                                )
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command Dispose 6 
                        (description "Invalidates this virtual machine mirror. The communication channel to the target 
      VM is closed and the target VM prepares to accept another subsequent connection from this debugger
      or another debugger including the following tasks: (1) All event requests are cancelled. (2) All 
      threads suspended by the thread-level resume command or the VM-level resume command are resumed 
      as many times as necessary for them to run. (3) Garbage collection is re-enabled in all cases where 
      it was disabled. -- Any current method invocations executing in the target VM are continued after 
      the disconnection. Upon completion of any such method invocation the invoking thread continues 
      from the location where it was originally stopped. Resources originating in this VirtualMachine 
      (ObjectReferences ReferenceTypes etc.) will become invalid. ")
                        )
               
               (command IDSizes 7 
                        (description "Returns the sizes of variably-sized data types in the target VM.The returned
      values indicate the number of bytes used by the identifiers in command and reply packets.")
                        (reply-data int fieldIDSize "fieldID size in bytes")
                        (reply-data int methodIDSize "methodID size in bytes")
                        (reply-data int objectIDSize "objectID size in bytes")
                        (reply-data int referenceTypeIDSize "referenceTypeID size in bytes")
                        (reply-data int frameIDSize "frameID size in bytes")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command Suspend 8 
                        (description "Suspends the execution of the application running in the target VM. All 
      Java threads currently running will be suspended. Unlike java.lang.Thread.suspend suspends of 
      both the virtual machine and individual threads are counted. Before a thread will run again it 
      must be resumed through the VM-level resume command or the thread-level resume command the same 
      number of times it has been suspended.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command Resume 9 
                        (description "Resumes execution of the application after the suspend command or an 
      event has stopped it. Suspensions of the Virtual Machine and individual threads are counted. 
      If a particular thread is suspended n times it must resumed n times before it will continue.")
                        )
               
               (command Exit 10 
                        (description "Terminates the target VM with the given exit code. All ids previously 
      returned from the target VM become invalid. Threads running in the VM are abruptly terminated. 
      A thread death exception is not thrown and finally blocks are not run. ")
                        )
               
               (command CreateString 11 
                        (description "Creates a new string object in the target VM and returns its id.")
                        (out-data string utf "UTF-8 characters to use in the created string.")
                        (reply-data stringID stringObject "Created string (instance of java.lang.String)")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command Capabilities 12
                        (description "Retrieve this VMs capabilities. The capabilities are returned as 
      booleans each indicating the presence or absence of a capability. The commands associated 
      with each capability will return the NOT_IMPLEMENTED error if the cabability is not available. ")
                        (reply-data boolean canWatchFieldModification "Can the VM watch field modification and 
      therefore can it send the Modification Watchpoint Event?")
                        (reply-data boolean canWatchFieldAccess "Can the VM watch field access and therefore 
      can it send the Access Watchpoint Event?")
                        (reply-data boolean canGetBytecodes "Can the VM get the bytecodes of a given method?")
                        (reply-data boolean canGetSyntheticAttribute "Can the VM determine whether a field 
      or method is synthetic? (that is can the VM determine if the method or the field was 
      invented by the compiler?)")
                        (reply-data boolean canGetOwnedMonitorInfo "Can the VM get the owned monitors infornation 
      for a thread?")
                        (reply-data boolean canGetCurrentContendedMonitor "Can the VM get the current contended 
      monitor of a thread?")
                        (reply-data boolean canGetMonitorInfo "Can the VM get the monitor information for a 
      given object?")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command ClassPaths 13
                        (description "Retrieve the classpath and bootclasspath of the target VM. If the classpath 
      is not defined returns an empty list. If the bootclasspath is not defined returns an empty list.")
                        (reply-data string baseDir "Base directory used to resolve relative paths in either 
      of the following lists.")
                        (reply-data int classpaths "Number of paths in classpath.")
                        (repeat classpaths
                                (reply-data string path "One component of classpath")
                                )
                        (reply-data int bootclasspaths "Number of paths in bootclasspath.")
                        (repeat bootclasspaths
                                (reply-data string path "One component of bootclasspath")
                                )
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command DisposeObjects 14
                        (description "Releases a list of object IDs. For each object in the list the following 
      applies. The count of references held by the back-) (the reference count) will be decremented 
      by refCnt. If thereafter the reference count is less than or equal to zero the ID is freed. Any 
      back-) resources associated with the freed ID may be freed and if garbage collection was disabled 
      for the object it will be re-enabled. The sender of this command promises that no further commands 
      will be sent referencing a freed ID.  Use of this command is not required. If it is not sent 
      resources associated with each ID will be freed by the back-) at some time after the corresponding 
      object is garbage collected. It is most useful to use this command to reduce the load on the back-) 
      if avery large number of objects has been retrieved from the back-) (a large array for example) 
      but may not be garbage collected any time soon. IDs may be re-used by the back-) after they have 
      been freed with this command.This description assumes reference counting a back-) may use any 
      implementation which operates equivalently.")
                        (out-data int requests "Number of object dispose requests that follow")
                        (repeat requests
                                (out-data objectID object "The object ID")
                                (out-data int refCnt "The number of times this object ID has been part of a packet received 
        from the back-). An accurate count prevents the object ID from being freed on the back-) if 
        it is part of an incoming packet not yet handled by the front-).")
                                )
                        )
               
               (command HoldEvents 15
                        (description "Tells the target VM to stop sending events. Events are not discarded; they are held 
      until a subsequent ReleaseEvents command is sent. This command is useful to control the number of 
      events sent to the debugger VM in situations where very large numbers of events are generated. 
      While events are held by the debugger back-) application execution may be frozen by the debugger 
      back-) to prevent buffer overflows on the back ). Responses to commands are never held and are 
      not affected by this command. If events are already being held this command is ignored.")
                        )
               
               (command ReleaseEvents 16
                        (description "Tells the target VM to continue sending events. This command is used to restore 
      normal activity after a HoldEvents command. If there is no current HoldEvents command in effect 
      this command is ignored")
                        )
               
               (command CapabilitiesNew 17
                        (description "Retrieve all of this VMs capabilities. The capabilities are returned as booleans 
      each indicating the presence or absence of a capability. The commands associated with each capability 
      will return the NOT_IMPLEMENTED error if the cabability is not available.Since JDWP version 1.4.")
                        (reply-data boolean canWatchFieldModification "Can the VM watch field modification and 
      therefore can it send the Modification Watchpoint Event?")
                        (reply-data boolean canWatchFieldAccess "Can the VM watch field access and therefore can it 
      send the Access Watchpoint Event?")
                        (reply-data boolean canGetBytecodes "Can the VM get the bytecodes of a given method?")
                        (reply-data boolean canGetSyntheticAttribute "Can the VM determine whether a field or method 
      is synthetic? (that is can the VM determine if the method or the field was invented by the compiler?)")
                        (reply-data boolean canGetOwnedMonitorInfo "Can the VM get the owned monitors infornation for a thread?")
                        (reply-data boolean canGetCurrentContendedMonitor "Can the VM get the current contended 
      monitor of a thread?")
                        (reply-data boolean canGetMonitorInfo "Can the VM get the monitor information for a given object?")
                        (reply-data boolean canRedefineClasses "Can the VM redefine classes?")
                        (reply-data boolean canAddMethod "Can the VM add methods when redefining classes?")
                        (reply-data boolean canUnrestrictedlyRedefineClasses "Can the VM redefine classesin arbitrary ways?")
                        (reply-data boolean canPopFrames "Can the VM pop stack frames?")
                        (reply-data boolean canUseInstanceFilters "Can the VM filter events by specific object?")
                        (reply-data boolean canGetSourceDebugExtension "Can the VM get the source debug extension?")
                        (reply-data boolean canRequestVMDeathEvent "Can the VM request VM death events?")
                        (reply-data boolean canSetDefaultStratum "Can the VM set a default stratum?")
                        (reply-data boolean reserved16 "Reserved for future capability")
                        (reply-data boolean reserved17 "Reserved for future capability")
                        (reply-data boolean reserved18 "Reserved for future capability")
                        (reply-data boolean reserved19 "Reserved for future capability")
                        (reply-data boolean reserved20 "Reserved for future capability")
                        (reply-data boolean reserved21 "Reserved for future capability")
                        (reply-data boolean reserved22 "Reserved for future capability")
                        (reply-data boolean reserved23 "Reserved for future capability")
                        (reply-data boolean reserved24 "Reserved for future capability")
                        (reply-data boolean reserved25 "Reserved for future capability")
                        (reply-data boolean reserved26 "Reserved for future capability")
                        (reply-data boolean reserved27 "Reserved for future capability")
                        (reply-data boolean reserved28 "Reserved for future capability")
                        (reply-data boolean reserved29 "Reserved for future capability")
                        (reply-data boolean reserved30 "Reserved for future capability")
                        (reply-data boolean reserved31 "Reserved for future capability")
                        (reply-data boolean reserved32 "Reserved for future capability")
                        (reply-data boolean reserved33 "Reserved for future capability")
                        
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command RedefineClasses 18
                        (description "Installs new class definitions.")
                        (out-data int classes "Number of reference types that follow.")
                        (repeat classes
                                (out-data referenceTypeID refType "The reference type.")
                                (out-data int classfile "Class file byte count")
                                (repeat classfile
                                        (out-data byte classbyte "byte in JVM class file format.")
                                        )
                                )
                        (error-data INVALID_CLASS "One of the refType is not the ID of a reference type.Ê")
                        (error-data INVALID_OBJECT "One of the refType is not a known ID.")
                        (error-data UNSUPPORTED_VERSION "A class file has a version number not supported by this VM.Ê")
                        (error-data INVALID_CLASS_FORMAT "The virtual machine attempted to read a class file and determined 
      that the file is malformed or otherwise cannot be interpreted as a class file.Ê")
                        (error-data CIRCULAR_CLASS_DEFINITION "A circularity has been detected while initializing a class.Ê")
                        (error-data FAILS_VERIFICATION "The verifier detected that a class file though well formed contained 
      some sort of internal inconsistency or security problem.Ê")
                        (error-data NAMES_DONT_MATCH "The class name defined in the new class file is different from the name 
      in the old class object.")
                        (error-data NOT_IMPLEMENTED "No aspect of this functionality is implemented 
      (CapabilitiesNew.canRedefineClasses is false)Ê")
                        (error-data ADD_METHOD_NOT_IMPLEMENTED "Adding methods has not been implemented.")
                        (error-data SCHEMA_CHANGE_NOT_IMPLEMENTED "Schema change has not been implemented.")
                        (error-data HIERARCHY_CHANGE_NOT_IMPLEMENTED "A direct superclass is different for the new class 
      version or the set of directly implemented interfaces is different and canUnrestrictedlyRedefineClasses 
      is false.")
                        (error-data DELETE_METHOD_NOT_IMPLEMENTED "The new class version does not declare a method declared 
      in the old class version and canUnrestrictedlyRedefineClasses is false.Ê")
                        (error-data CLASS_MODIFIERS_CHANGE_NOT_IMPLEMENTED "The new class version has different modifiers 
      and canUnrestrictedlyRedefineClasses is false")
                        (error-data METHOD_MODIFIERS_CHANGE_NOT_IMPLEMENTED "A method in the new class version has different 
      modifiers than its counterpart in the old class version and and canUnrestrictedlyRedefineClasses is false.Ê")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command SetDefaultStratum 19
                        (description "Set the default stratum.")
                        (out-data string stratumID "default stratum or empty string to use reference type default.")
                        (error-data NOT_IMPLEMENTED "The functionality is not implemented in this virtual machine.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               ) 

  (command-set ReferenceType 2
               (command Signature 1
                        (description "Returns the JNI signature of a reference type. JNI signature formats are described 
      in the Java Native Inteface Specification  For primitive classes the returned signature is the signature 
      of the corresponding primitive type; for example I is returned as the signature of the class 
      represented by java.lang.Integer.TYPE. ")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data string signature "The JNI signature for the reference type.")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command ClassLoader 2
                        (description "Returns the instance of java.lang.ClassLoader which loaded a given reference type. If 
      the reference type was loaded by the system class loader the returned object ID is null.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data classLoaderID classLoader "The class loader for the reference type.")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command Modifiers 3
                        (description " Returns the modifiers (also known as access flags) for a reference type. The returned 
      bit mask contains information on the declaration of the reference type. If the reference type is an 
      array or a primitive class (for example java.lang.Integer.TYPE) the value of the returned bit mask is 
      undefined.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data int modBits "Modifier bits as defined in the VM Specification")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command Fields 4
                        (description " Returns information for each field in a reference type. Inherited fields are not 
      included. The field list will include any synthetic fields created by the compiler. Fields are returned 
      in the order they occur in the class file.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data int declared "Number of declared fields.")
                        (repeat declared
                                (reply-data fieldID fieldID "Field ID")
                                (reply-data string name "Name of field")
                                (reply-data string signature "JNI Signature of field")
                                (reply-data int modBits "The modifier bit flags (also known as access flags) which provide 
        additional information on the  field declaration. Individual flag values are defined in the VM 
        Specification.In addition The 0xf0000000 bit identifies the field as synthetic if the synthetic 
        attribute capability is available.")
                                )
                        (error-data CLASS_NOT_PREPARED "Class has been loaded but not yet prepared.")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command Methods 5
                        (description " Returns information for each method in a reference type. Inherited methodss 
      are not included. The list of methods will include constructors (identified with the name 
      <init>) the initialization method (identified with the name <clinit>) if present and any 
      synthetic methods created by the compiler. Methods are returned in the order they occur in the 
      class file.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data int declared "Number of declared methods.")
                        (repeat declared
                                (reply-data methodID methodID "Method ID")
                                (reply-data string name "Name of method")
                                (reply-data string signature "JNI Signature of method")
                                (reply-data int modBits "The modifier bit flags (also known as access flags) which 
        provide additional information on the  method declaration. Individual flag values are 
        defined in the VM Specification.In addition The 0xf0000000 bit identifies the method as 
        synthetic if the synthetic attribute capability is available.")
                                )
                        (error-data CLASS_NOT_PREPARED "Class has been loaded but not yet prepared.")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               (command GetValues 6
                        (description " Returns the value of one or more static fields of the reference type. 
      Each field must be member of the reference type or one of its superclasses superinterfaces 
      or implemented interfaces. Access control is not enforced; for example the values of 
      private fields can be obtained.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (out-data int fields "The number of values to get")
                        (repeat fields
                                (out-data fieldID fieldID "A field to get")
                                )
                        (reply-data int values "The number of values returned")
                        (repeat values
                                (reply-data value value "The field name")
                                )
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data INVALID_FIELDID "Invalid field")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command SourceFile 7
                        (description "Returns the name of source file in which a reference type was declared.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data string sourceFile "The source file name. No path information for the file is included")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command NestedTypes 8
                        (description "Returns the classes and interfaces directly nested within this type. Types further 
      nested within those types are not included.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data int classes "The number of nested classes and interfaces")
                        (repeat classes
                                (reply-data byte refTypeTag "Kind of following reference type.")
                                (reply-data referenceTypeID typeID "The nested class or interface ID.")
                                )
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command Status  9
                        (description "Returns the current status of the reference type. The status indicates the extent 
      to which the reference type has been initialized as described in the VM specification. The returned 
      status bits are undefined for array types and for primitive classes (such as java.lang.Integer.TYPE).")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data int status "Status bits:See JDWP.ClassStatus")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command Interfaces 10
                        (description "Returns the interfaces declared as implemented by this class. Interfaces indirectly 
      implemented (extended by the implemented interface or implemented by a superclass) are not included.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data int interfaces "The number of implemented interfaces")
                        (repeat interfaces
                                (reply-data interfaceID interfaceType "implemented interface.")
                                )
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command ClassObject 11
                        (description "Returns the class object corresponding to this type.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data classObjectID classObject "class object.")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command SourceDebugExtension 12
                        (description "Returns the value of the SourceDebugExtension attribute. Since JDWP version 1.4.")
                        (out-data referenceTypeID refType "The reference type ID.")
                        (reply-data string extension "extension attribute")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data ABSENT_INFORMATION "If the extension is not specified.")
                        (error-data NOT_IMPLEMENTED "The functionality is not implemented in this virtual machine.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               ) 


  (command-set ClassType 3
               (command Superclass 1
                        (description "Returns the immediate superclass of a class.")
                        (out-data classID clazz "The class type ID")
                        (reply-data classID superclass "The superclass (null if the class ID for java.lang.Object is 
      specified).")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command SetValues 2
                        (description "Sets the value of one or more static fields. Each field must be member of the 
      class type or one of its superclasses superinterfaces or implemented interfaces. Access control 
      is not enforced; for example the values of private fields can be set. Final fields cannot be set. 
      For primitive values the values type must match the fields type exactly. For object values 
      there must exist a widening reference conversion from the values type to the fields type and the 
      fields type must be loaded.")
                        (out-data classID clazz "The class type ID")
                        (out-data int values "The number of fields to set.")
                        (repeat values
                                (out-data fieldID fieldID "Field to set")
                                (out-data untagged_value value "Value to put in the field.")
                                )
                        (error-data INVALID_CLASS "clazz is not the ID of a class.")
                        (error-data CLASS_NOT_PREPARED "Class has been loaded but not yet prepared.")
                        (error-data INVALID_OBJECT "clazz is not a known ID or a value of an object parameter is not 
      a known ID.")
                        (error-data INVALID_FIELDID "Invalid field.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command InvokeMethod 3
                        (description "Invokes a static method. The method must be member of the class type or one of 
      its superclasses superinterfaces or implemented interfaces. Access control is not enforced; for 
      example private methods can be invoked. The method invocation will occur in the specified thread. 
      Method invocation can occur only if the specified thread has been suspended by an event. Method 
      invocation is not supported when the target VM has been suspended by the front-). The specified 
      method is invoked with the arguments in the specified argument list. The method invocation is 
      synchronous; the reply packet is not sent until the invoked method returns in the target VM. 
      The return value (possibly the void value) is included in the reply packet. If the invoked method 
      throws an exception the exception object ID is set in the reply packet; otherwise the exception 
      object ID is null. For primitive arguments the argument values type must match the arguments 
      type exactly. For object arguments there must exist a widening reference conversion from the 
      argument values type to the arguments type and the arguments type must be loaded. By default 
      all threads in the target VM are resumed while the method is being invoked if they were previously 
      suspended by an event or by command. This is done to prevent the deadlocks that will occur if any 
      of the threads own monitors that will be needed by the invoked method. It is possible that 
      breakpoints or other events might occur during the invocation. Note however that this implicit
      resume acts exactly like the ThreadReference resume command so if the threads suspend count is 
      greater than 1 it will remain in a suspended state during the invocation. By default when the 
      invocation completes all threads in the target VM are suspended regardless their state before 
      the invocation. The resumption of other threads during the invoke can be prevented by specifying 
      the INVOKE_SINGLE_THREADED bit flag in the options field; however there is no protection against 
      or recovery from the deadlocks described above so this option should be used with great caution.
      Only the specified thread will be resumed (as described for all threads above). Upon completion of 
      a single threaded invoke the invoking thread will be suspended once again. Note that any threads
      started during the single threaded invocation will not be suspended when the invocation completes. 
      If the target VM is disconnected during the invoke (for example through the VirtualMachine dispose 
      command) the method invocation continues.")
                        (out-data classID clazz "The class type ID.")
                        (out-data threadID thread "The thread in which to invoke.")
                        (out-data methodID methodID "The method to invoke.")
                        (out-data int arguments "The number of arguments")
                        (repeat arguments
                                (out-data value arg "The argument value")
                                )
                        (out-data int options "Invocation options.")
                        (reply-data value returnValue "The return value.")
                        (reply-data tagged_objectID exception "The thrown exception.")
                        (error-data INVALID_CLASS "clazz is not the ID of a class.")
                        (error-data INVALID_OBJECT "clazz is not a known ID or a value of an object parameter is not 
      a known ID.")
                        (error-data INVALID_METHODID "methodID is not the ID of a method.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data THREAD_NOT_SUSPENDED "If the specified thread has not been suspended by an event.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command NewInstance 4
                        (description "Creates a new object of this type invoking the specified constructor. The 
      constructor method ID must be a member of the class type.Instance creation will occur in the 
      specified thread. Instance creation can occur only if the specified thread has been suspended 
      by an event. Method invocation is not supported when the target VM has been suspended by the 
      front-). The specified constructor is invoked with the arguments in the specified argument 
      list. The constructor invocation is synchronous; the reply packet is not sent until the invoked 
      method returns in the target VM. The return value (possibly the void value) is included in the 
      reply packet. If the constructor throws an exception the exception object ID is set in the 
      reply packet; otherwise the exception object ID is null. For primitive arguments the argument 
      values type must match the arguments type exactly. For object arguments there must exist a 
      widening reference conversion from the argument values type to the arguments type and the 
      arguments type must be loaded. By default all threads in the target VM are resumed while the 
      method is being invoked if they were previously suspended by an event or by command. This is 
      done to prevent the deadlocks that will occur if any of the threads own monitors that will be 
      needed by the invoked method. It is possible that breakpoints or other events might occur during 
      the invocation. Note however that this implicit resume acts exactly like the ThreadReference 
      resume command so if the threads suspend count is greater than 1 it will remain in a 
      suspended state during the invocation. By default when the invocation completes all threads 
      in the target VM are suspended regardless their state before the invocation. The resumption of 
      other threads during the invoke can be prevented by specifying the INVOKE_SINGLE_THREADED bit 
      flag in the options field; however there is no protection against or recovery from the 
      deadlocks described above so this option should be used with great caution. Only the specified 
      thread will be resumed (as described for all threads above). Upon completion of a single 
      threaded invoke the invoking thread will be suspended once again. Note that any threads started 
      during the single threaded invocation will not be suspended when the invocation completes. If 
      the target VM is disconnected during the invoke (for example through the VirtualMachine dispose 
      command) the method invocation continues.")
                        (out-data classID clazz "The class type ID.")
                        (out-data threadID thread "The thread in which to invoke the constructor.")
                        (out-data methodID methodID "The method to invoke.")
                        (out-data int arguments "The number of arguments")
                        (repeat arguments
                                (out-data value arg "The argument value")
                                )
                        (out-data int options "Constructor invocation options.")
                        (reply-data tagged_objectID newObject "The newly created object or null if the constructor 
      threw an exception")
                        (reply-data tagged_objectID exception "The thrown exception if any; otherwise null.")
                        (error-data INVALID_CLASS "clazz is not the ID of a class.")
                        (error-data INVALID_OBJECT "clazz is not a known ID or a value of an object parameter is not 
      a known ID.")
                        (error-data INVALID_METHODID "methodID is not the ID of a method.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data THREAD_NOT_SUSPENDED "If the specified thread has not been suspended by an event.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               ) 

  (command-set ArrayType 4
               (command NewInstance 1
                        (description "Creates a new array object of this type with a given length.")
                        (out-data arrayTypeID arrType "The array type of the new instance.")
                        (out-data int length "The length of the array.")
                        (reply-data tagged_objectID newArray "The newly created array object.")
                        (error-data INVALID_ARRAY "The array is invalid.Ê")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               ) 

  (command-set InterfaceType 5)

  (command-set Method 6
               (command LineTable  1
                        (description " Returns line number information for the method. The line table maps source 
      line numbers to the initial code index of the line. The line table is ordered by code index 
      (from lowest to highest).")
                        (out-data referenceTypeID refType "The class.")
                        (out-data methodID methodID "The method.")
                        (reply-data long start "Lowest valid code index for the method.")
                        (reply-data long end "Highest valid code index for the method.")
                        (reply-data int lines "The number of lines.")
                        (repeat lines
                                (reply-data long lineCodeIndex "Initial code index of the line (unsigned).")
                                (reply-data int lineNumber "Line number.")
                                )
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data INVALID_METHODID "methodID is not the ID of a method.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command VariableTable 2
                        (description "Returns variable information for the method. The variable table includes 
      arguments and locals declared within the method. For instance methods the this reference 
      is included in the table. Also synthetic variables may be present.  ")
                        (out-data referenceTypeID refType "The class.")
                        (out-data methodID methodID "The method.")
                        (reply-data int argCnt "The number of words in the frame used by arguments. Eight-byte 
      arguments use two words; all others use one.")
                        (reply-data int slots "The number of variables.")
                        (repeat slots
                                (reply-data long codeIndex "First code index at which the variable is visible (unsigned). 
        Used in conjunction with length. The variable can be get or set only when the current codeIndex 
        <= current frame code index < codeIndex + length")
                                (reply-data string name "The variables name.")
                                (reply-data string signature "The variable types JNI signature.")
                                (reply-data int length "Unsigned value used in conjunction with codeIndex. The variable can 
        be get or set only when the current codeIndex <= current frame code index < code index + length")
                                (reply-data int slot "The local variables index in its frame")
                                )
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data INVALID_METHODID "methodID is not the ID of a method.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command ByteCodes 3
                        (description "Retrieve the methods bytecodes as defined in the JVM Specification.")
                        (out-data referenceTypeID refType "The class.")
                        (out-data methodID methodID "The method.")
                        (reply-data int bytes "The number of bytes")
                        (repeat bytes
                                (reply-data byte bytecode "The Java bytecode.")
                                )
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data INVALID_METHODID "methodID is not the ID of a method.")
                        (error-data NOT_IMPLEMENTED "If the target virtual machine does not support the retrieval of 
      bytecodes.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command IsObsolete 4
                        (description "Determine if this method is obsolete.")
                        (out-data referenceTypeID refType "The class.")
                        (out-data methodID methodID "The method.")
                        (reply-data boolean isObsolete "true if this method has been replacedby a non-equivalent 
      method usingthe RedefineClasses command")
                        (error-data INVALID_CLASS "refType is not the ID of a reference type.")
                        (error-data INVALID_OBJECT "refType is not a known ID.")
                        (error-data INVALID_METHODID "methodID is not the ID of a method.")
                        (error-data NOT_IMPLEMENTED "If the target virtual machine does not support this query")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               ) 

  (command-set Field 8)

  (command-set ObjectReference 9
               (command ReferenceType 1
                        (description "Returns the runtime type of the object. The runtime type will be a class or 
      an array.")
                        (out-data objectID object "The object ID")
                        (reply-data byte refTypeTag "Kind of following reference type.")
                        (reply-data referenceTypeID typeID "The runtime reference type.")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command GetValues 2
                        (description "Returns the value of one or more instance fields. Each field must be member of 
      the objects type or one of its superclasses superinterfaces or implemented interfaces. Access 
      control is not enforced; for example the values of private fields can be obtained.")
                        (out-data objectID object "The object ID")
                        (out-data int fields "The number of fields to get")
                        (repeat fields
                                (out-data fieldID fieldID "Field to get")
                                )
                        (reply-data int values "The number of values returned")
                        (repeat values
                                (reply-data value value "The field value")
                                )
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data INVALID_FIELDID "Invalid field")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command SetValues 3
                        (description "Sets the value of one or more instance fields. Each field must be member of the 
      objects type or one of its superclasses superinterfaces or implemented interfaces. Access 
      control is not enforced; for example the values of private fields can be set. For primitive 
      values the values type must match the fields type exactly. For object values there must be a 
      widening reference conversion from the values type to the fields type and the fields type 
      must be loaded.")
                        (out-data objectID object "The object ID")
                        (out-data int values "The number of fields to set.")
                        (repeat values
                                (out-data fieldID fieldID "Field to set.")
                                (out-data untagged_value value "Value to put in the field.")
                                )
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data INVALID_FIELDID "Invalid field")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command MonitorInfo 4
                        (description "Returns monitor information for an object. All threads int the VM must be 
      suspended.")
                        (out-data objectID object "The object ID")
                        (reply-data threadID owner "The monitor owner or null if it is not currently owned.")
                        (reply-data int entryCount "The number of times the monitor has been entered.")
                        (reply-data int waiters "The number of threads that are waiting for the monitor 0 if there 
      is no current owner")
                        (repeat waiters
                                (reply-data threadID thread "A thread waiting for this monitor.")
                                )
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data NOT_IMPLEMENTED "The functionality is not implemented in this virtual machine.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command InvokeMethod 5
                        (description "Invokes a instance method. The method must be member of the objects type or one 
      of its superclasses superinterfaces or implemented interfaces. Access control is not enforced; 
      for example private methods can be invoked. The method invocation will occur in the specified 
      thread. Method invocation can occur only if the specified thread has been suspended by an event.
      Method invocation is not supported when the target VM has been suspended by the front-). The 
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
      (for example through the VirtualMachine dispose command) the method invocation continues.")
                        (out-data objectID object "The object ID")
                        (out-data threadID thread "The thread in which to invoke.")
                        (out-data classID clazz "The class type.")
                        (out-data methodID methodID "The method to invoke")
                        (out-data int arguments "The number of arguments")
                        (repeat arguments
                                (out-data value arg "The argument value")
                                )
                        (out-data int options "Invocation options")
                        (reply-data value returnType "The returned value or null if an exception is thrown.")
                        (reply-data tagged_objectID exception "The thrown exception if any.")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data INVALID_CLASS "clazz is not the ID of a reference type.")
                        (error-data INVALID_METHODID "methodID is not the ID of a method.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data THREAD_NOT_SUSPENDED "If the specified thread has not been suspended by an event.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command DisableCollection 6
                        (description  "Prevents garbage collection for the given object. By default all objects in 
      back-) replies may be collected at any time the target VM is running. A call to this command 
      guarantees that the object will not be collected. The EnableCollection command can be used to 
      allow collection once again. Note that while the target VM is suspended no garbage collection 
      will occur because all threads are suspended. The typical examination of variables fields and 
      arrays during the suspension is safe without explicitly disabling garbage collection. This method 
      should be used sparingly as it alters the pattern of garbage collection in the target VM and 
      consequently may result in application behavior under the debugger that differs from its 
      non-debugged behavior.")
                        (out-data objectID object "The object ID")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command EnableCollection 7
                        (description  "Permits garbage collection for this object. By default all objects returned by 
      the JDWP may be collected at any time the target VM is running. A call to this command is necessary 
      only if garbage collection was previously disabled with the DisableCollection command.  ")
                        (out-data objectID object "The object ID")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               
               (command IsCollected 8
                        (description "Determines whether an object has been garbage collected in the target VM.")
                        (out-data objectID object "The object ID")
                        (reply-data boolean isCollected "true if the object has been collected; false otherwise")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               ) 

  (command-set StringReference 10
               (command Value 1
                        (description "Returns the characters contained in the string.")
                        (out-data objectID object "The string object ID")
                        (reply-data string stringValue "The value of the String.")
                        (error-data INVALID_STRING "The string is invalid.")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               ) 

  (command-set ThreadReference 11
               (command Name 1
                        (description "Returns the thread name.")
                        (out-data threadID thread "The thread object ID.")
                        (reply-data string threadName "The thread name.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command Suspend 2
                        (description "Suspends the thread. Unlike java.lang.Thread.suspend() suspends of both the 
      virtual machine and individual threads are counted. Before a thread will run again it must be 
      resumed the same number of times it has been suspended. Suspending single threads with command 
      has the same dangers java.lang.Thread.suspend(). If the suspended thread holds a monitor needed 
      by another running thread deadlock is possible in the target VM (at least until the suspended 
      thread is resumed again). The suspended thread is guaranteed to remain suspended until resumed 
      through one of the JDI resume methods mentioned above; the application in the target VM cannot 
      resume the suspended thread through {@link java.lang.Thread#resume}. Note that this doesnt 
      change the status of the thread (see the ThreadStatus command.) For example if it was Running 
      it will still appear running to other threads.  ")
                        (out-data threadID thread "The thread object ID.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command Resume 3
                        (description "Resumes the execution of a given thread. If this thread was not previously 
      suspended by the front-) calling this command has no effect. Otherwise the count of pending 
      suspends on this thread is decremented. If it is decremented to 0 the thread will continue to 
      execute.")
                        (out-data threadID thread "The thread object ID.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command Status 4
                        (description "Returns the current status of a thread. The thread status reply indicates the 
      thread status the last time it was running. the suspend status provides information on the 
      threads suspension if any.")
                        (out-data threadID thread "The thread object ID.")
                        (reply-data int threadStatus "One of the thread status codes See JDWP.ThreadStatus")
                        (reply-data int suspendStatus "One of the suspend status codes See JDWP.SuspendStatus")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command ThreadGroup 5
                        (description "Returns the thread group that contains a given thread.")
                        (out-data threadID thread "The thread object ID.")
                        (reply-data threadGroupID group "The thread group of this thread.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command Frames 6
                        (description "Returns the current call stack of a suspended thread. The sequence of frames 
      starts with the currently executing frame followed by its caller and so on. The thread must 
      be suspended and the returned frameID is valid only while the thread is suspended.")
                        (out-data threadID thread "The thread object ID.")
                        (out-data int startFrame "The index of the first frame to retrieve.")
                        (out-data int length "The count of frames to retrieve (-1 means all remaining).")
                        (reply-data int frames "The number of frames retreived")
                        (repeat frames
                                (reply-data frameID frameID "The ID of this frame.")
                                (reply-data location location "The current location of this frame")
                                )
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command FrameCount 7
                        (description " Returns the count of frames on this threads stack. The thread must be 
      suspended and the returned count is valid only while the thread is suspended. Returns 
      JDWP.Error.errorThreadNotSuspended if not suspended.")
                        (out-data threadID thread "The thread object ID.")
                        (reply-data int framecount "The count of frames on this threads stack.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command OwnedMonitors 8
                        (description "Returns the objects whose monitors have been entered by this thread. The 
      thread must be suspended and the returned information is relevant only while the thread is 
      suspended.")
                        (out-data threadID thread "The thread object ID.")
                        (reply-data int owned "The number of owned monitors")
                        (repeat owned
                                (reply-data tagged_objectID monitor "The owned monitor")
                                )
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data NOT_IMPLEMENTED "The functionality is not implemented in this virtual machine.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command CurrentContendedMonitor 9
                        (description "Returns the object if any for which this thread is waiting for monitor entry 
      or with java.lang.Object.wait. The thread must be suspended and the returned information is 
      relevant only while the thread is suspended.")
                        (out-data threadID thread "The thread object ID.")
                        (reply-data tagged_objectID monitor "The contended monitor or null if there is no current 
      contended monitor.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data NOT_IMPLEMENTED "The functionality is not implemented in this virtual machine.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command Stop 10
                        (description "Stops the thread with an asynchronous exception as if done by java.lang.Thread.stop")
                        (out-data threadID thread "The thread object ID.")
                        (out-data objectID throwable "Asynchronous exception. This object must be an instance of 
      java.lang.Throwable or a subclass")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "If thread is not a known ID or the asynchronous exception has been 
      garbage collected.Ê")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command Interrupt 11
                        (description "Interrupt the thread as if done by java.lang.Thread.interrupt")
                        (out-data threadID thread "The thread object ID.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               (command SuspendCount 12
                        (description " Get the suspend count for this thread. The suspend count is the  number of times 
      the thread has been suspended through the thread-level or VM-level suspend commands without a 
      corresponding resume")
                        (out-data threadID thread "The thread object ID.")
                        (reply-data int suspendCount "The number of outstanding suspends of this thread.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )    
               ) 


  (command-set ThreadGroupReference 12
               (command Name 1
                        (description "Returns the thread group name.")
                        (out-data threadGroupID group "The thread group object ID.")
                        (reply-data string threadName "The thread group name.")
                        (error-data INVALID_THREAD_GROUP "Thread group invalid.")
                        (error-data INVALID_OBJECT "group is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command Parent 2
                        (description "Returns the thread group if any which contains a given thread group.")
                        (out-data threadGroupID group "The thread group object ID.")
                        (reply-data threadGroupID parentGroup "The parent thread group object or null if the given 
      thread group is a top-level thread group.")
                        (error-data INVALID_THREAD_GROUP "Thread group invalid.")
                        (error-data INVALID_OBJECT "group is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command Children 3
                        (description "Returns the threads and thread groups directly contained in this thread group. 
      Threads and thread groups in child thread groups are not included.")
                        (out-data threadGroupID group "The thread group object ID.")
                        (reply-data int childThreads "The number of child threads.")
                        (repeat childThreads
                                (reply-data threadID childThread "A direct child thread ID.")
                                )
                        (reply-data int childGroups "The number of child thread groups.")
                        (repeat childGroups
                                (reply-data threadGroupID childGroup "A direct child thread group ID.")
                                )
                        (error-data INVALID_THREAD_GROUP "Thread group invalid.")
                        (error-data INVALID_OBJECT "group is not a known ID.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               ) 

  (command-set ArrayReference 13
               (command Length 1
                        (description "Returns the number of components in a given array.")
                        (out-data arrayID arrayObject "The array object ID.")
                        (reply-data int arrayLength "The length of the array.")
                        (error-data INVALID_OBJECT "arrayObject is not a known ID.")
                        (error-data INVALID_ARRAY "The array is invalid.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command GetValues 2
                        (description "Returns a range of array components. The specified range must be within the 
      bounds of the array.")
                        (out-data arrayID arrayObject "The array object ID.")
                        (out-data int firstIndex "The first index to retrieve")
                        (out-data int length "The number of components to retrieve.")
                        (reply-data arrayregion values "The retrieved values. If the values are objects they are 
      tagged-values; otherwise they are untagged-values")
                        (error-data INVALID_LENGTH "If index is beyond the ) of this array.")
                        (error-data INVALID_OBJECT "arrayObject is not a known ID.")
                        (error-data INVALID_ARRAY "The array is invalid.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command SetValues 3
                        (description " Sets a range of array components. The specified range must be within the bounds 
      of the array. For primitive values each values type must match the array component type exactly. 
      For object values there must be a widening reference conversion from the values type to the 
      array component type and the array component type must be loaded.")
                        (out-data arrayID arrayObject "The array object ID.")
                        (out-data int firstIndex "The first index to set.")
                        (out-data int values "The number of values to set.")
                        (repeat values
                                (out-data untagged_value value "A value to set.")
                                )
                        (error-data INVALID_LENGTH "If index is beyond the ) of this array.")
                        (error-data INVALID_OBJECT "arrayObject is not a known ID.")
                        (error-data INVALID_ARRAY "The array is invalid.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               ) 

  (command-set ClassLoaderReference 14
               (command VisibleClasses 1
                        (description "Returns a list of all classes which this class loader has been requested to load. 
      This class loader is considered to be an initiating class loader for each class in the returned 
      list. The list contains each reference type defined by this loader and any types for which loading 
      was delegated by this class loader to another class loader. The visible class list has useful 
      properties with respect to the type namespace. A particular type name will occur at most once in 
      the list. Each field or variable declared with that type name in a class defined by this class 
      loader must be resolved to that single type. No ordering of the returned list is guaranteed.")
                        (out-data classLoaderID classLoaderObject "The class loader object ID.")
                        (reply-data int classes "The number of visible classes.")
                        (repeat classes
                                (reply-data byte refTypeTag "Kind of following reference type.")
                                (reply-data referenceTypeID typeID "A class visible to this class loader.")
                                )
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data INVALID_CLASS_LOADER "The class loader is invalid.")
                        (error-data VM_DEAD "The virtual machine is not running.")
                        )
               ) 

  (command-set EventRequest 15
               (command Set 1
                        (description "Set an event request. When the event described by this request occurs an event 
      is sent from the target VM.")
                        (out-data byte eventKind "Event kind to request. See JDWP.EventKind for a complete list of 
      events that can be requested.")
                        (out-data byte suspendPolicy "What threads are suspended when this event occurs? Note that 
      the order of events and command replies accurately reflects the order in which threads are suspended 
      and resumed. For example if a VM-wide resume is processed before an event occurs which suspends 
      the VM the reply to the resume command will be written to the transport before the suspending event.")
                        (out-data int modifiers "Constraints used to control the number of generated events. Modifiers 
      specify additional tests that an event must satisfy before it is placed in the event queue. Events 
      are filtered by applying each modifier to an event in the order they are specified in this collection 
      Only events that satisfy all modifiers are reported. Filtering can improve debugger performance 
      dramatically by reducing the amount of event traffic sent from the target VM to the debugger VM.")
                        (repeat modifiers
                                (out-data byte modKind "Modifier kind")
                                (cases modKind
                                       (when Count 1 "Limit the requested event to be reported at most once after a given number 
          of occurrences.  The event is not reported the first count - 1 times this filter is reached. 
          To request a one-off event call this method with a count of 1. Once the count reaches 0 any 
          subsequent filters in this request are applied. If none of those filters cause the event to be 
          suppressed the event is reported. Otherwise the event is not reported. In either case 
          subsequent events are never reported for this request. This modifier can be used with any 
          event kind."
                                             (out-data int count "Count before event. One for one-off."))
                                       (when Conditional 2 "Conditional on expression"
                                             (out-data int exprID "For the future"))
                                       (when ThreadOnly 3 "Restricts reported events to those in the given thread. This modifier 
          can be used with any event kind except for class unload."
                                             (out-data threadID thread "Required thread"))
                                       (when ClassOnly 4 "For class prepare events restricts the events generated by this request 
          to be the preparation of the given reference type and any subtypes. For other events restricts 
          the events generated by this request to those whose location is in the given reference type or 
          any of its subtypes. An event will be generated for any location in a reference type that can 
          be safely cast to the given reference type. This modifier can be used with any event kind except 
          class unload thread start and thread )."
                                             (out-data referenceTypeID clazz "Required class"))
                                       (when ClassMatch 5 "Restricts reported events to those for classes whose name matches the 
          given restricted regular expression. For class prepare events the prepared class name is matched. 
          For class unload events the unloaded class name is matched. For other events the class name of 
          the events location is matched. This modifier can be used with any event kind except thread start 
          and thread )."
                                             (out-data string classPattern "Required class pattern. Matches are limited to exact matches 
            of the given class pattern and matches of patterns that begin or ) with *; for example 
            *.Foo or java.*."))
                                       (when ClassExclude 6 "Restricts reported events to those for classes whose name does not match 
          the given restricted regular expression. For class prepare events the prepared class name is 
          matched. For class unload events the unloaded class name is matched. For other events the class 
          name of the events location is matched. This modifier can be used with any event kind except 
          thread start and thread )."
                                             (out-data string classPattern "Disallowed class pattern. Matches are limited to exact matches 
            of the given class pattern and matches of patterns that begin or ) with *; for example 
            *.Foo or java.*."))
                                       (when LocationOnly 7 "Restricts reported events to those that occur at the given location. 
          This modifier can be used with breakpoint field access field modification step and exception 
          event kinds."
                                             (out-data location loc "Required location"))
                                       (when ExceptionOnly 8 "Restricts reported exceptions by their class and whether they are 
          caught or uncaught. This modifier can be used with exception event kinds only."
                                             (out-data referenceTypeID exceptionOrNull "Exception to report. Null (0) means report 
            exceptions of all types. A non-null type restricts the reported exception events to exceptions 
            of the given type or any of its subtypes.")
                                             (out-data boolean caught "Report caught exceptions")
                                             (out-data boolean uncaught "Report uncaught exceptions. Note that it is not always possible 
            to determine whether an exception is caught or uncaught at the time it is thrown. See the 
            exception event catch location under composite events for more information."))
                                       (when FieldOnly 9 "Restricts reported events to those that occur for a given field. This 
          modifier can be used with field access and field modification event kinds only."
                                             (out-data referenceTypeID declaring "Type in which field is declared.")
                                             (out-data fieldID fieldID "Required field"))
                                       (when Step 10 "Restricts reported step events to those which satisfy depth and size 
          constraints. This modifier can be used with step event kinds only."
                                             (out-data threadID thread "Thread in which to step")
                                             (out-data int size "size of each step. See JDWP.StepSize")
                                             (out-data int depth "relative call stack limit. See JDWP.StepDepth"))
                                       (when InstanceOnly 11 "Restricts reported events to those whose active this object is the 
          given object. Match value is the null object for static methods. This modifier can be used with 
          any event kind except class prepare class unload thread start and thread ). Introduced in 
          JDWP version 1.4."
                                             (out-data objectID instance "Required this object")
                                             ))
                                )
                        (reply-data int requestID "ID of created request")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_CLASS "Invalid class.")
                        (error-data INVALID_STRING "The string is invalid.")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data INVALID_COUNT "The count is invalid.")
                        (error-data INVALID_FIELDID "Invalid field.")
                        (error-data INVALID_METHODID "Invalid method.")
                        (error-data INVALID_LOCATION "Invalid location.")
                        (error-data INVALID_EVENT_TYPE "The specified event type id is not recognized.")
                        (error-data NOT_IMPLEMENTED "The functionality is not implemented in this virtual machine.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command Clear 2
                        (description "Clear an event request.")
                        (out-data byte event "Event type to clear")
                        (out-data int requestID "ID of request to clear")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               (command ClearAllBreakpoints 3
                        (description "Removes all set breakpoints.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               ) 

  (command-set StackFrame 16
               (command GetValues 1
                        (description "Returns the value of one or more local variables in a given frame. Each variable 
      must be visible at the frames code index. Even if local variable information is not available 
      values can be retrieved if the front-) is able to determine the correct local variable index. 
      (Typically this index can be determined for method arguments from the method signature without 
      access to the local variable table information.)")
                        (out-data threadID thread "The frames thread.")
                        (out-data frameID frame "The frame ID.")
                        (out-data int slots "The number of values to get.")
                        (repeat slots
                                (out-data int slot "The local variables index in the frame.")
                                (out-data byte sigbyte "A tag identifying the type of the variable")
                                )
                        (reply-data int values "The number of values retrieved.")
                        (repeat values
                                (reply-data value slotValue "The value of the local variable.")
                                )
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data INVALID_FRAMEID "Invalid jframeID")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command SetValues 2
                        (description "Sets the value of one or more local variables. Each variable must be visible 
      at the current frame code index. For primitive values the values type must match the variables 
      type exactly. For object values there must be a widening reference conversion from the values 
      type to the variables type and the variables type must be loaded. Even if local variable 
      information is not available values can be set if the front-) is able to determine the 
      correct local variable index. (Typically this index can be determined for method arguments from 
      the method signature without access to the local variable table information.)")
                        (out-data threadID thread "The frames thread.")
                        (out-data frameID frame "The frame ID.")
                        (out-data int slotValues "The number of values to set.")
                        (repeat slotValues
                                (out-data int slot "The slot ID.")
                                (out-data value slotValue "The value of to set.")
                                )
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data INVALID_FRAMEID "Invalid jframeID")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command ThisObject 3
                        (description " Returns the value of the this reference for this frame. If the frames method 
      is static or native the reply will contain the null object reference.")
                        (out-data threadID thread "The frames thread.")
                        (out-data frameID frame "The frame ID.")
                        (reply-data tagged_objectID objectThis "The this object for this frame.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data INVALID_FRAMEID "Invalid jframeID")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               
               (command PopFrames 4
                        (description "Pop stack frames thru and including frame.Since JDWP version 1.4.")
                        (out-data threadID thread "The frames thread.")
                        (out-data frameID frame "The frame ID.")
                        (error-data INVALID_THREAD "Passed thread is not a valid thread or has exited.")
                        (error-data INVALID_OBJECT "thread is not a known ID.")
                        (error-data INVALID_FRAMEID "Invalid jframeID")
                        (error-data JVMDI_ERROR_THREAD_NOT_SUSPENDED "TODO")
                        (error-data JVMDI_ERROR_NO_MORE_FRAMES "TODO")
                        (error-data NOT_IMPLEMENTED "The functionality is not implemented in this virtual machine.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               ) 

  (command-set ClassObjectReference 17
               (command ReflectedType 1
                        (description "Returns the reference type reflected by this class object.")
                        (out-data classObjectID classObject "The class object.")
                        (reply-data byte refTypeTag "Kind of following reference type.")
                        (reply-data referenceTypeID typeID "reflected reference type")
                        (error-data INVALID_OBJECT "If this reference type has been unloaded and garbage collected.")
                        (error-data VM_DEAD "The virtual machine is not running.")    
                        )
               ) 

  (command-set Event 64
               (command Composite 100
                        (description "Several events may occur at a given time in the target VM. For example there 
      may be more than one breakpoint request for a given location or you might single step to the same 
      location as a breakpoint request.  These events are delivered together as a composite event.  For 
      uniformity a composite event is always used to deliver events even if there is only one event 
      to report. The events that are grouped in a composite event are restricted in the following ways 
      -- Always singleton composite events(VM Start Event VM Death Event) -- Only with other thread 
      start events for the same thread(Thread Start Event) -- Only with other thread death events for 
      the same thread(Thread Death Event) -- Only with other class prepare events for the same 
      class(Class Prepare Event) -- Only with other class unload events for the same 
      class(Class Unload Event) -- Only with other access watchpoint events for the same field 
      access(Access Watchpoint Event) -- Only with other modification watchpoint events for the same 
      field modification(Modification Watchpoint Event) -- Only with other ExceptionEvents for the 
      same exception occurrence(ExceptionEvent) -- Only with other members of this group at the same 
      location and in the same thread(Breakpoint Event Step Event Method Entry Event Method Exit Event)")
                        (reply-data byte suspendPolicy "Which threads where suspended by this composite event?")
                        (reply-data int events "Events to set.")
                        (repeat events
                                (reply-data byte eventKind "Event kind selector")
                                (cases eventKind
                                       (when VMStart EventKind::VM_START "Notification of initialization of a target VM.  This 
          event is received before the main thread is started and before any application code has been 
          executed. Before this event occurs a significant amount of system code has executed and a number 
          of system classes have been loaded. This event is always generated by the target VM even if 
          not explicitly requested."
                                             (reply-data int requestID "Request that generated event (or 0 if this event is 
            automatically generated")
                                             (reply-data threadID thread "Initial thread"))
                                       (when SingleStep EventKind::SINGLE_STEP "Notification of step completion in the target VM. 
          The step event is generated before the code at its location is executed."
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Stepped thread")
                                             (reply-data location location "Location stepped to"))
                                       (when Breakpoint EventKind::BREAKPOINT "Notification of a breakpoint in the target VM. 
          The breakpoint event is generated before the code at its location is executed."
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Thread which hit breakpoint")
                                             (reply-data location location "Location hit"))
                                       (when MethodEntry EventKind::METHOD_ENTRY "Notification of a method invocation in the 
          target VM. This event is generated before any code in the invoked method has executed. Method 
          entry events are generated for both native and non-native methods. In some VMs method entry 
          events can occur for a particular thread before its thread start event occurs if methods are 
          called as part of the threads initialization. "
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Thread which entered method")
                                             (reply-data location location "Location of entry"))
                                       (when MethodExit EventKind::METHOD_EXIT "Notification of a method return in the target 
          VM. This event is generated after all code in the method has executed but the location of 
          this event is the last executed location in the method. Method exit events are generated for 
          both native and non-native methods. Method exit events are not generated if the method 
          terminates with a thrown exception."
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Thread which exited method")
                                             (reply-data location location "Location of exit"))
                                       (when Exception EventKind::EXCEPTION "Notification of an exception in the target VM. 
          If the exception is thrown from a non-native method the exception event is generated at the 
          location where the exception is thrown. If the exception is thrown from a native method the 
          exception event is generated at the first non-native location reached after the exception is 
          thrown."
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Thread with exception")
                                             (reply-data location location "Location of exception throw (or first non-native 
            location after throw if thrown from a native method)")
                                             (reply-data tagged_objectID exception "Thrown exception")
                                             (reply-data location catchLocation "Location of catch or 0 if not caught. An exception 
            is considered to be caught if at the point of the throw the current location is dynamically 
            enclosed in a try statement that handles the exception. (See the JVM specification for 
            details). If there is such a try statement the catch location is the first location in the 
            appropriate catch clause. If there are native methods in the call stack at the time of the 
            exception there are important restrictions to note about the returned catch location. In 
            such cases it is not possible to predict whether an exception will be handled by some native 
            method on the call stack. Thus it is possible that exceptions considered uncaught here will 
            in fact be handled by a native method and not cause termination of the target VM. 
            Furthermore it cannot be assumed that the catch location returned here will ever be reached 
            by the throwing thread. If there is a native frame between the current location and the catch 
            location the exception might be handled and cleared in that native method instead. Note that 
            compilers can generate try-catch blocks in some cases where they are not explicit in the 
            source code; for example the code generated for synchronized and finally blocks can contain 
            implicit try-catch blocks. If such an implicitly generated try-catch is present on the call 
            stack at the time of the throw the exception will be considered caught even though it appears 
            to be uncaught from examination of the source code."))
                                       (when ThreadStart EventKind::THREAD_START "Notification of a new running thread in the 
          target VM. The new thread can be the result of a call to java.lang.Thread.start or the result 
          of attaching a new thread to the VM though JNI. The notification is generated by the new thread 
          some time before its execution starts. Because of this timing it is possible to receive other 
          events for the thread before this event is received. (Notably Method Entry Events and Method 
          Exit Events might occur during thread initialization. It is also possible for the VirtualMachine 
          AllThreads command to return a thread before its thread start event is received. Note that this 
          event gives no information about the creation of the thread object which may have happened much 
          earlier depending on the VM being debugged."
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Started thread"))
                                       (when ThreadDeath EventKind::THREAD_DEATH "Notification of a completed thread in the target 
          VM. The notification is generated by the dying thread before it terminates. Because of this 
          timing it is possible for {@link VirtualMachine#allThreads} to return this thread after this 
          event is received. Note that this event gives no information about the lifetime of the thread 
          object. It may or may not be collected soon depending on what references exist in the target VM."
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Ending thread"))
                                       (when ClassPrepare EventKind::CLASS_PREPARE "Notification of a class prepare in the target 
          VM. See the JVM specification for a definition of class preparation. Class prepare events are not 
          generated for primtiive classes (for example java.lang.Integer.TYPE)."
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Preparing thread. In rare cases this event may occur in a 
            debugger system thread within the target VM. Debugger threads take precautions to prevent these 
            events but they cannot be avoided under some conditions especially for some subclasses of 
            java.lang.Error. If the event was generated by a debugger system thread the value returned 
            by this method is null and if the requested  suspend policy for the event was EVENT_THREAD 
            all threads will be suspended instead and the composite events suspend policy will reflect 
            this change. Note that the discussion above does not apply to system threads created by the 
            target VM during its normal (non-debug) operation.")
                                             (reply-data byte refTypeTag "Kind of reference type. See JDWP::TypeTag")
                                             (reply-data referenceTypeID typeID "Type being prepared")
                                             (reply-data string signature "Type signature")
                                             (reply-data int status "Status of type. See JDWP::ClassStatus"))
                                       (when ClassUnload EventKind::CLASS_UNLOAD "Notification of a class unload in the target 
          VM. There are severe constraints on the debugger back-) during garbage collection so unload 
          information is greatly limited. "
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data string signature "Type signature"))
                                       (when FieldAccess EventKind::FIELD_ACCESS " JDWP.EventKind.FIELD_ACCESS: Notification of a 
          field access in the target VM. Field modifications are not considered field accesses. "
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Accessing thread")
                                             (reply-data location location "Location of access")
                                             (reply-data byte refTypeTag "Kind of reference type. See JDWP::TypeTag")
                                             (reply-data referenceTypeID typeID "Type of the field")
                                             (reply-data fieldID fieldID "Field being accessed")
                                             (reply-data tagged_objectID object "Object being accessed (null=0 for statics)"))
                                       (when FieldModification EventKind::FIELD_MODIFICATION "Notification of a field modification 
          in the target VM. "
                                             (reply-data int requestID "Request that generated event")
                                             (reply-data threadID thread "Accessing thread")
                                             (reply-data location location "Location of access")
                                             (reply-data byte refTypeTag "Kind of reference type. See JDWP::TypeTag")
                                             (reply-data referenceTypeID typeID "Type of the field")
                                             (reply-data fieldID fieldID "Field being modified")
                                             (reply-data tagged_objectID object "Object being modified (null=0 for statics)")
                                             (reply-data value valueToBe "Value to be assigned"))
                                       (when VMDeath EventKind::VM_DEATH "JVM shutting down"
                                             (reply-data int requestID "Request that generated event")
                                             ))))))

