
# Java Interview Questions

## 1. Four Principles of Object-Oriented Programming (OOP)

- Encapsulation
- Inheritance
- Polymorphism
- Abstraction

### Polymorphism

Polymorphism allows the same interface or method call to exhibit different behaviors depending on the object's actual type.

There are two forms in Java:

- **Method Overloading (Compile-time Polymorphism):** Multiple methods have the same name but different parameter lists.
- **Method Overriding (Runtime Polymorphism):** A subclass provides its own implementation of a method defined in its superclass or interface.

### Abstraction

Abstraction focuses on exposing **what an object does** while hiding **how it does it**.

Java provides two primary ways to achieve abstraction:

#### Abstract Class

- Cannot be instantiated.
- Can contain both **abstract methods** and **concrete methods**.
- Can have fields, constructors, and method implementations.
- Suitable when classes share common state and behavior.

#### Interface

- Defines a contract that implementing classes must follow.
- Since Java 8, interfaces can also contain **default** and **static** methods.
- Since Java 9, interfaces can also contain **private** methods for code reuse within the interface.
- Supports multiple inheritance of type (`implements` multiple interfaces).

#### Purpose of an Interface

- Defines a contract (API) that implementing classes must follow.
- Promotes loose coupling by separating the interface (what) from the implementation (how).
- Allows different implementations to be used interchangeably through the same interface.


## Encapsulation

- Encapsulation is the practice of bundling data (fields) and the methods that operate on that data into a single unit while restricting direct access to the object's internal state.
- **Purpose:** Hide implementation details, protect object integrity, and control access to an object's state.
- External code should interact with an object's state through its public API, which often includes getters and setters when appropriate. Validation and business rules can be enforced there.

### Why use getters and setters if they don't contain any logic?

Although getters and setters may initially appear to be simple field accessors, they provide flexibility for future changes without affecting existing code.

For example:

- If you later need to validate that `amount > 0`, you only need to update the setter instead of modifying every place that assigns the field.
- You can add logging, auditing, or event publishing whenever the value changes.
- You can make a property read-only by exposing only a getter.
- Frameworks such as Jackson and JPA/Hibernate often use getters and setters for property access, although many also support direct field access depending on their configuration.

------------------
# Inheritance

Inheritance allows a subclass to inherit the fields and methods of its superclass.

## Benefits

- **Code Reusability** – Reuse existing code instead of rewriting common functionality.
- **Extensibility** – Extend or customize the behavior of a superclass without modifying it.
- **Enables Runtime Polymorphism** – A subclass can override inherited methods, allowing different implementations to be invoked through the same superclass or interface reference.

## Why does Java support only single inheritance?

Java allows a class to extend only one superclass to avoid the **Diamond Problem**, where multiple parent classes may provide conflicting implementations of the same method.

To support code reuse without this ambiguity:

- A class can extend only one superclass.
- A class can implement multiple interfaces.

## Drawbacks of Inheritance

- Creates **tight coupling** between a subclass and its superclass.
- Changes in the superclass may unintentionally affect subclasses.
- Deep inheritance hierarchies are harder to maintain.

Therefore, object-oriented design generally follows the principle:

> **Favor composition over inheritance.**

Frameworks such as Spring encourage this approach through **Dependency Injection (DI)**, where objects receive their dependencies instead of inheriting behavior, resulting in lower coupling, greater flexibility, and easier testing.
------------------------
# Polymorphism

Polymorphism means that an object or method can take multiple forms depending on the context.

It allows the same method call to behave differently based on the actual type of the object at runtime.

Java supports two types of polymorphism:

- **Compile-time Polymorphism** → Method Overloading
- **Runtime Polymorphism** → Method Overriding

---

## Method Overloading (Compile-time Polymorphism)

Method overloading allows multiple methods in the same class to have the same name but different parameter lists.

The compiler determines which method should be invoked based on:

- Method name
- Number of parameters
- Parameter types
- Parameter order

The decision is made at compile time.

Note:
- Return type alone cannot be used to overload a method.

---

## Method Overriding (Runtime Polymorphism)

Method overriding occurs when a subclass provides its own implementation of a method defined in its superclass or interface.

Characteristics:

- Requires inheritance (`extends`) or interface implementation (`implements`).
- The method resolution happens at runtime.
- JVM determines the actual object type and invokes the corresponding overridden method.

Example concept:

```java
Animal animal = new Cat();
animal.sound();
```

Although the reference type is `Animal`, the runtime object type is `Cat`, so the JVM calls `Cat.sound()`.

---

## Field Hiding vs Method Overriding

Java supports method overriding but does not support field overriding.

Fields are resolved based on the reference type at compile time.

Therefore:

- Methods → Runtime polymorphism
- Fields → Compile-time binding

---

## Method Overriding Rules

When overriding a method:

- The child method cannot reduce the access level of the parent method.
- The return type must be compatible (covariant return types are supported).
- The method signature must be the same.

Access modifier rule:

- `public` → must remain `public`
- `protected` → `protected` or `public`
- `default` → `default`, `protected`, or `public`
- `private` → cannot be overridden

---

## How JVM Resolves Overridden Methods

At compile time, the compiler generates bytecode instructions for method invocation.

At runtime:

- JVM checks the actual object type stored in memory.
- JVM uses internal method dispatch mechanisms (such as vtable/itable in HotSpot JVM) to locate the correct overridden method implementation.
- If the subclass overrides the method, the JVM invokes the subclass implementation.

This mechanism enables runtime polymorphism.


----------------
# Abstraction

Abstraction is the process of hiding unnecessary implementation details and exposing only essential behavior.

It simplifies complexity by focusing on:

> **What to do, not How to do.**

The goal of abstraction is to define clear responsibilities and reduce dependency on implementation details.

---

## Interface

An interface defines a contract that specifies what a class can do without defining how it does it.

Characteristics:

- Defines a contract between the caller and the implementation.
- Promotes loose coupling by separating abstraction from implementation.
- Allows multiple implementations of the same behavior.
- Since Java 8, interfaces can contain `default` and `static` methods.
- Since Java 9, interfaces can contain `private` methods.

---

## Abstract Class

An abstract class provides partial abstraction.

Characteristics:

- Can contain both abstract methods and concrete methods.
- Can have fields, constructors, and shared implementations.
- Useful when related classes share common state and behavior.

---

## Interface in System Design

In system design, interfaces are often used to create **extension points** that allow modules to communicate through contracts instead of depending on concrete implementations.

Benefits:

- Reduces coupling between modules (**Decoupling**).
- Makes the system easier to test by allowing dependencies to be mocked.
- Allows replacing or upgrading internal implementations without affecting external components.
- Supports flexible and maintainable architecture.



## 2. Interface vs Abstract
An interface defines a contract and focuses on what a class can do, while an abstract class provides a common base with shared state and implementation. 
I use interfaces for loose coupling and flexibility, and abstract classes when related classes share common behavior



## 6. Volatile, Synchronized và static
- synchronized: cho phép 1 thread truy cập khối code cùng lúc (đồng bộ hóa). các object nằm trên ram vùng nhớ heap đều có 1 cái khoá, thằng nào có khoá thì chạy, các bước: tranh chấp -> chiếm hữu owner -> chặn luồng block -> giải phóng
- vậy nên chỉ lock khi cần thiết hoặc lock biến nào cần thiết, không lock cả hàm
- vấn đề sinh ra -> Dead lock
- giải pháp: dùng reentrantlock để set được thời gian chờ lock tối đa thay vì bị deadlock khi không chờ được tài nguyên, hoặc Atomic Number dựa trên cơ chế CAS compare and swap cực nhanh trên CPU
-


- volatile: đảm bảo visibility giữa các thread (đọc/ghi biến ngay lập tức từ main memory).
- dữ liệu bắt buộc được đọc trên ram -> các thread có thể nhìn thấy data, chứ không phải từ cache l1 L2 trên CPU
- vậy nên đa luồng cùng sửa vẫn có thể cho ra giá trị sai bởi vì nó không lock, kết quả sau 100 luồng + 1 chưa chắc = 100
- dùng làm cờ hiệu hệ thống bật tắt, các luồng cùng thấy 1 giá

- static: thuộc về class, không phải instance. nằm ở metaspace chứ không phải heap như object, Hãy tưởng tượng object là 1 bảng trong đó mỗi dòng trỏ đến các phương thức và biến, thì static sẽ được tạo chung và tất cả quyển sách đều nhìn được biến , được tạo khi JVM load class đó vào bộ nhớ, trước cả khi hàm main chạy, vì là static nên GC sẽ không dọn, cẩn trọng khi dùng, cẩn trọng trong thread-safe vì có thể sai


### 1. Synchronized

-   **Concept:** Ensures mutual exclusion by allowing only one thread to access a code block at a time using an Intrinsic/Monitor Lock attached to every object.

-   **Workflow:** Contention $\rightarrow$ Ownership $\rightarrow$ Thread Blocked (if locked) $\rightarrow$ Release.

-   **Best Practice:** Lock only critical code blocks, not entire methods, to avoid performance bottlenecks.

-   **Risk:** Can lead to **Deadlock**.

-   **Solutions:** Use `ReentrantLock` for time-bound lock attempts (`tryLock`), or use **Atomic Variables** which leverage hardware-level, non-blocking **CAS (Compare-And-Swap)** for maximum speed.


### 2. Volatile

-   **Concept:** Guarantees **Visibility** and **Ordering** (prevents instruction reordering) across threads.

-   **Mechanism:** Forces hardware cache coherency (flushing store buffers/invalidating CPU caches) so threads always see the latest value, avoiding stale data. It does not always mean a slow, direct physical RAM read.

-   **Limitation:** Does **not** guarantee atomicity. Concurrent modifications (like `count++`) can still cause race conditions and incorrect results.

-   **Best Use Case:** Used as state flags (e.g., `volatile boolean isRunning`) where multiple threads need to see a single status change instantly.


### 3. Static

-   **Concept:** Belongs to the Class itself, not to individual instances.

-   **Memory:** Stored in **Metaspace**, unlike objects which reside in the Heap.

-   **Lifecycle:** Initialized when the JVM loads and initializes the class. Since it persists for the application's entire lifecycle, it is not garbage collected normally.

-   **Risks:** High risk of **Memory Leaks** if global collections are misused, and requires strict care for **Thread-Safety** because the exact same memory address is shared by all threads.

## 7. SOLID
- (Liệt kê topic để ôn: Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion)

| Vi phạm nguyên lý SOLID                                                                                                                                                                        | Cách giải quyết                                                                                                                                                                          |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **S - Single Responsibility Principle (SRP)**: Một class làm quá nhiều việc. Ví dụ `UserService` vừa tạo user, gửi email, lưu database, tạo report. Khi sửa email có thể ảnh hưởng logic user. | Tách class theo **một trách nhiệm duy nhất**. Ví dụ: `UserService` chỉ xử lý nghiệp vụ user, `EmailService` gửi mail, `UserRepository` lưu database, `ReportService` tạo report.         |
| **S - SRP**: Một method quá dài, chứa nhiều bước xử lý khác nhau.                                                                                                                              | Chia nhỏ method theo chức năng. Ví dụ tách `validateUser()`, `saveUser()`, `sendEmail()` thay vì một method `createUser()` 200 dòng.                                                     |
| **O - Open/Closed Principle (OCP)**: Mỗi lần thêm tính năng phải sửa code cũ. Ví dụ thêm loại thanh toán mới phải sửa `PaymentService` với nhiều `if-else`.                                    | Dùng abstraction (interface/abstract class) để mở rộng bằng cách thêm class mới. Ví dụ `Payment` interface, tạo thêm `PaypalPayment`, `CreditCardPayment` mà không sửa `PaymentService`. |
| **O - OCP**: Code phụ thuộc vào implementation cụ thể. Ví dụ `OrderService` tạo trực tiếp `new MySQLRepository()`.                                                                             | Dependency Injection. Inject interface thay vì tạo object trực tiếp. Ví dụ `OrderRepository repository`.                                                                                 |
| **L - Liskov Substitution Principle (LSP)**: Class con thay thế class cha nhưng làm sai behavior. Ví dụ `Bird` có method `fly()`, class `Penguin extends Bird` nhưng không thể bay.            | Thiết kế lại abstraction. Không tạo quan hệ kế thừa sai. Ví dụ tách `Bird` và `FlyingBird`. Chỉ những loài bay được mới implement `Flyable`.                                             |
| **L - LSP**: Override method nhưng thay đổi ý nghĩa hoặc phá contract của class cha.                                                                                                           | Class con phải giữ đúng kỳ vọng của class cha. Nếu class con cần behavior khác → tạo abstraction mới.                                                                                    |
| **I - Interface Segregation Principle (ISP)**: Interface quá lớn, class phải implement những method không dùng. Ví dụ `Worker` có `work()`, `eat()`, robot cũng phải implement `eat()`.        | Chia interface lớn thành nhiều interface nhỏ. Ví dụ `Workable`, `Eatable`. Robot chỉ implement `Workable`.                                                                               |
| **I - ISP**: Client phụ thuộc vào những chức năng không cần thiết.                                                                                                                             | Thiết kế interface theo nhu cầu của client. Ví dụ `Printer` tách `Print`, `Scan`, `Fax` thay vì một interface quá lớn.                                                                   |
| **D - Dependency Inversion Principle (DIP)**: High-level module phụ thuộc trực tiếp low-level module. Ví dụ `OrderService` phụ thuộc `MySQLDatabase`.                                          | High-level phụ thuộc abstraction. Ví dụ `OrderService` phụ thuộc `DatabaseRepository` interface, còn `MySQLRepository` implement interface đó.                                           |
| **D - DIP**: Code tạo dependency bằng `new` bên trong class khiến khó test.                                                                                                                    | Dùng Dependency Injection (Spring `@Autowired`, constructor injection). Inject dependency từ bên ngoài.                                                                                  |




## 9. Stack and Heap
### Stack
- Stores method call frames, local variables, and execution information.
- Each thread has its own Stack.
- Local variables are stored in the Stack, while object references point to objects in the Heap.
### Heap
- Stores objects and instance data.
- Shared between threads.
- Managed by the Garbage Collector (GC), which automatically removes unreachable objects.

## 11. equals() and hashCode(), How Set Works

- **equals():** Compares the logical equality of two objects based on their content.
- **hashCode():** Returns an integer hash value representing the object. The `equals()` and `hashCode()` contract determines the behavior of hash-based collections.
- **Set:** Uses `hashCode()` to locate the appropriate bucket and uses `equals()` to check for duplicate objects.

## 12. Bao nhiêu thread là đủ?
- Không phải nhiều thread luôn nhanh hơn; số thread tối ưu phụ thuộc CPU-bound vs I/O-bound và tài nguyên hệ thống.

1 thread ≈ 1MB stack memory
CPU-bound → threads ≈ cores
I/O-bound → threads >> cores
Tomcat default ≈ 200 threads
DB pool thường ≈ 10–50 connections
context switch ≈ microseconds
quá nhiều thread → context switching + memory blowup
thread pool luôn phải tune theo workload







## Tham khảo
- https://github.com/in28minutes/JavaInterviewQuestionsAndAnswers

## Các câu hỏi thêm
- Nếu khai báo `int count = 0` rồi dùng `stream.forEach(count++)`, giá trị `count` có tăng lên không?
  - Lưu ý: Java không cho phép sửa biến cục bộ không final trong lambda; cần dùng AtomicInteger hoặc biến mutable khác.

- Biết về B-tree? So sánh B-tree index và hash index.

- Không sử dụng @Query, không dùng StringBuilder — làm sao viết 1 câu search trên 3 trường?

# Situational question


https://topdev.vn/blog/tranh-loi-concurrentmodificationexception-trong-java-nhu-the-nao/?utm_source=google&utm_medium=cpc&gad_source=1&gad_campaignid=22868613541&gbraid=0AAAAADDtBSD37UU_YrBvxixC3lEDz8OoP&gclid=Cj0KCQjw9JLHBhC-ARIsAK4PhcoCTVFusyzxusomCGu0PsQuSMStEcIzxf1c03ooks8awsAw_QZXSvsaAtd7EALw_wcB


## REFERENCE
Core Java Interview Questions & Answers: https://www.youtube.com/watch?v=FFfJeb8Ec6Y
github: https://github.com/Devinterview-io/java-interview-questions
github: https://github.com/a11exe/java-interview?tab=readme-ov-file
github: https://github.com/mertsaner/java-interview-questions/blob/master/collections-questions.md
200 question about java core: https://www.geeksforgeeks.org/java/java-interview-questions/