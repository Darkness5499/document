### Java Garbage Collection

It automatically removes the objects that are no longer in use

##

### Difference between JDK, JRE, and JVM?

- JVM: A virtual machine that runs file .class, Convert bytecode into machine code for your OS/CPU in runtime
- JRE: A package that contains the JVM + libraries + other files needed to run Java programs.
- JDK: Java development kit, A complete package for Java development. allows developer run java application

### Explain the 4 main principles of OOP
- Encapsulation: 
  - Bundling data (fields) and behavior (methods) together inside a class, and restricting direct access to the data.
  - Hide implementation details, expose only what’s necessary.

- Inheritance
  - Mechanism that allows one class (child) to inherit properties and behavior from another class (parent).
  - Code reusability and logical hierarchy.
- Polymorphism
  - Ability of an object to take many forms; same method name can behave differently depending on context.
  - Compile-time (Overloading) → same method name, different parameter list.
  - Runtime (Overriding) → child class redefines parent’s method.
- Abstraction
  - Hiding implementation details and showing only essential features.
  - Focus on what an object does, not how it does it.


### What is the difference between this and super keyword
- this: A reference to the current object
- super: A reference to the immediate parent class object.
### Difference between checked and unchecked exceptions.
- Checked exception: Exceptions that the compiler checks at compile time.
- Unchecked exception: Exceptions that the compiler does NOT check at compile time, they are subclass of RuntimeException

### What is the difference between throw and throws?

- throw: uses inside method body
- throws: uses when declare a mothod can throws certain exceptions

### Difference between interface and abstract class?

- Interface: When you want to define a contract that can be applied to unrelated classes.
- Abstract Class: When you want to share code + abstract methods in a related class hierarchy.

##

### explain these keywords: synchronized, transient, volatile, static, final
- synchronized: 
  - Ensures that only one thread can access a method/block at a time.
  - Prevents race conditions in multi-threading.
- transient: 
  - Used in serialization.
  - Marks a variable that should not be saved when the object is serialized.
- volatile:
  - Guarantees visibility of changes to variables across threads.
  - Prevents threads from caching the variable → always reads from main memory.
  - Does not guarantee atomicity (use synchronized or AtomicInteger for that).
- static:
    - Belongs to the class, not to instances.
    - Can be used for variables, methods, inner classes, and blocks.
- final: 
  - value cannot be changed, method cannot be overridden, class can not be inherited 

### overriding vs overloading


### stack and heap in Java
    - stack: 
            Part of RAM reserved for method execution. 
            Stores Local variables, Primitive data types, References to objects
    - heap: 
        Shared pool of memory where objects are stored. 
        Accessed via references (stored in stack). 
        Managed by Garbage Collector (GC). 
        Shared across all threads → needs synchronization if multiple threads access same object.



### Shallow copy vs deep copy


### Advanced Java Features
- java generic

- Java reflection


- Java stream


# Situational question

