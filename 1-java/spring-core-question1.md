
## 1. Nền tảng Tư duy Thiết kế (Design Principles)

Trước khi đụng vào code của Spring, bạn phải hiểu tại sao người ta lại tạo ra nó. Spring sinh ra để giải quyết bài toán quản lý sự phụ thuộc và giảm độ kết dính (decoupling) trong các hệ thống lớn.

-   **OOP & Clean Code:** Hiểu sâu về tính đóng gói, đa hình, và đặc biệt là tư duy _Coding to Interfaces_ (lập trình dựa trên interface thay vì class cụ thể).

-   **SOLID Principles:** Đặc biệt là chữ **D (Dependency Inversion Principle)** - các module cấp cao không nên phụ thuộc vào module cấp thấp, cả hai nên phụ thuộc vào trừu tượng (abstraction).

-   **Design Patterns căn bản:** Nắm chắc cách hoạt động của **Singleton Pattern**, **Factory Pattern**, và **Proxy Pattern** (đây là 3 pattern nền móng để Spring xây dựng IoC và AOP).


## 2. Cơ chế cốt lõi của Spring Container (IoC & DI)

Đây là trái tim của Spring Core. Bạn cần hiểu cách Spring quản lý vòng đời của các đối tượng trong ứng dụng.

-   **Inversion of Control (IoC) & Dependency Injection (DI):** Bản chất của việc "đảo ngược quyền điều khiển" là gì? Phân biệt rõ 3 cách inject: Constructor, Setter, và Field Injection (và tại sao Constructor Injection luôn được khuyến khích tốt nhất).

-   **Spring Bean Lifecycle:** Nắm trọn vẹn các giai đoạn từ khi một Bean được định nghĩa (BeanDefinition), khởi tạo instance, inject dependency, qua các bộ lọc `BeanPostProcessor`, chạy hàm Init (`@PostConstruct`), cho đến khi bị hủy (`@PreDestroy`).

-   **Bean Scopes & Concurrency:** Hiểu rõ sự khác biệt giữa `Singleton`, `Prototype`, `Request`, `Session`. Đặc biệt phải nắm được **vấn đề đa luồng (Thread-safety)** khi nhiều request cùng truy cập vào một Singleton Bean (tư duy stateless vs stateful).

-   **Advanced DI Scenario:** Cách giải quyết bài toán **Circular Dependency** (Phụ thuộc vòng) bằng cơ chế 3-level cache của Spring, và cách xử lý lỗi **Scoped Proxy** khi inject một Prototype Bean vào một Singleton Bean.


## 3. Lập trình hướng khía cạnh (Spring AOP)

AOP giúp bạn tách biệt các tính năng mang tính hệ thống (cross-cutting concerns) ra khỏi logic nghiệp vụ chính của dự án.

-   **Khái niệm core của AOP:** Phân biệt rõ ràng các thuật ngữ: _Aspect, Join Point, Pointcut, Advice (Before, After, Around),_ và _Target Object_.

-   **Cơ chế Proxy ngầm (Under the hood):** Hiểu cách Spring tạo ra đối tượng bọc ngoài (Proxy) để cài cắm code AOP. Phân biệt được khi nào Spring dùng **JDK Dynamic Proxy** (dựa trên interface) và khi nào dùng **CGLIB Proxy** (dựa trên kế thừa subclass).

-   **Lỗi Self-invocation:** Biết tại sao khi một hàm tự gọi một hàm khác trong cùng một class thì các tính năng như `@Transactional` hay `@Cacheable` đột ngột bị vô hiệu hóa (do lời gọi không đi qua lớp Proxy).


## 4. Cơ chế Xử lý Sự kiện & Tài nguyên (ApplicationContext Utilities)

Spring Core không chỉ có DI và AOP, nó còn là một bộ framework cung cấp rất nhiều tiện ích hạ tầng cho ứng dụng.

-   **Resource Loader:** Cách Spring quản lý và đọc các file cấu hình, tài nguyên từ các nguồn khác nhau (classpath, file system, URL) thông qua giao diện `Resource`.

-   **Spring Expression Language (SpEl):** Cách sử dụng cú pháp SpEL để cấu hình động hoặc tính toán giá trị trực tiếp ngay trong các annotation như `@Value("#{...}")`.

-   **Spring Events (Event-Driven):** Cơ chế Publish-Subscribe nội bộ trong Spring Container bằng cách sử dụng `ApplicationEventPublisher` và `@EventListener`. Đây là nền tảng rất tốt để viết code tách biệt nghiệp vụ (decoupled modules).


Khi bạn đã tự tin trả lời được câu hỏi _"Tại sao hệ thống lại chạy như vậy?"_ ở cả 4 tầng kiến thức này, bạn sẽ không còn sợ bất kỳ câu hỏi phỏng vấn Spring Core nâng cao nào, đồng thời việc tiếp cận các module mở rộng như Spring Boot, Spring Security, hay Spring Cloud sẽ trở nên cực kỳ dễ dàng.


### 1. Spring Bean Scopes & Thread-Safety (Vấn đề Đa luồng trong Bean)

-   **Câu hỏi:** _Default scope của Spring Bean là gì? Singleton Bean có Thread-safe không? Làm sao để xử lý vấn đề Thread-safety trong Spring Core?_

-   **Góc nhìn chuyên gia:** Câu hỏi này đánh giá khả năng kết hợp giữa Spring Core và tư duy Concurrency (Đa luồng) của ứng viên.

-   **Cách trả lời chuẩn:**

    -   Default scope là **Singleton** (chỉ có 1 instance duy nhất được tạo ra trong mỗi IoC container).

    -   Singleton Bean **KHÔNG thread-safe** vì tất cả các request/thread đều dùng chung một instance này.

    -   **Giải pháp:** Để đảm bảo an toàn, Singleton Bean phải là **Stateless** (không giữ trạng thái, không dùng các biến instance variable để lưu dữ liệu thay đổi). Nếu bắt buộc phải lưu trạng thái, phải dùng `ThreadLocal`, các biến `Atomic` (như đã phân tích ở phần CAS), hoặc chuyển scope của Bean đó sang `Prototype` (tạo instance mới cho mỗi lần gọi) hoặc `Request/Session` scope.


### 2. Spring Bean Lifecycle & Customization (Vòng đời của Bean)

-   **Câu hỏi:** _Hãy giải thích Bean Lifecycle trong Spring. Sự khác biệt giữa `BeanFactoryPostProcessor` và `BeanPostProcessor` là gì?_

-   **Góc nhìn chuyên gia:** Câu này dùng để phân loại xem ứng viên thực sự hiểu cách Spring Container vận hành hay chỉ biết dùng các annotation cơ bản.

-   **Cách trả lời chuẩn:**

    -   Vòng đời cơ bản: Instantiation (Tạo instance) $\rightarrow$ Populate Properties (Inject dependency) $\rightarrow$ Bean Name/Factory Aware $\rightarrow$ Pre-Initialization (`BeanPostProcessor`) $\rightarrow$ Initialization (`@PostConstruct` hoặc `afterPropertiesSet`) $\rightarrow$ Post-Initialization $\rightarrow$ Ready for use $\rightarrow$ Destroy.

    -   **Khác biệt cốt lõi:**

        -   `BeanFactoryPostProcessor`: Thao tác trên **Bean Definition** (metadata của bean) _trước khi_ bất kỳ instance nào được tạo ra. Dùng để thay đổi cấu hình cấu trúc (ví dụ: đọc file properties để thay thế placeholder).

        -   `BeanPostProcessor`: Thao tác trực tiếp trên **Bean Instance** (đối tượng đã được tạo ra). Nó can thiệp vào giai đoạn trước và sau khi khởi tạo (Init), thường dùng để tạo Proxy (cho AOP, `@Transactional`).


### 3. Circular Dependency (Lỗi phụ thuộc vòng)

-   **Câu hỏi:** _Circular Dependency là gì? Spring giải quyết nó như thế nào và tại sao Constructor Injection lại bị lỗi này trong khi Setter/Field Injection thì không?_

-   **Góc nhìn chuyên gia:** Kiểm tra kinh nghiệm thực tế khi giải quyết các xung đột kiến trúc và hiểu sâu về cơ chế khởi tạo cache của Spring.

-   **Cách trả lời chuẩn:**

    -   Circular Dependency xảy ra khi Bean A cần Bean B, và Bean B lại cần Bean A.

    -   Spring giải quyết bài toán này bằng cơ chế **3-level Cache (chỉ áp dụng cho Singleton bean)** để phơi bày một instance "chưa khởi tạo xong hoàn toàn" (early reference) ra ngoài trước khi inject.

    -   **Constructor Injection bị lỗi** vì Spring bắt buộc phải gọi Constructor để tạo instance trước rồi mới bỏ vào cache được. Nếu cả hai dùng Constructor, Spring sẽ bị kẹt trong vòng lặp vô hạn và ném ra `BeanCurrentlyInCreationException`.

    -   **Setter/Field Injection không bị** vì Spring có thể gọi Constructor rỗng để tạo instance thô của Bean A trước, đưa vào cache tầng 3, sau đó mới inject Bean B vào sau.


### 4. Advanced Dependency Injection: `@Autowired` vs Proxy Switching

-   **Câu hỏi:** _Điều gì xảy ra khi bạn inject một `Prototype` Bean vào trong một `Singleton` Bean? Làm sao để Singleton luôn nhận được instance mới của Prototype mỗi khi gọi?_

-   **Góc nhìn chuyên gia:** Một lỗi kinh điển trong thiết kế hệ thống lớn khiến Prototype Bean bị "chết chìm" (scoped proxy issue) thành Singleton.

-   **Cách trả lời chuẩn:**

    -   Do Singleton Bean chỉ được khởi tạo **một lần duy nhất**, nên Prototype Bean cũng chỉ được inject đúng một lần tại thời điểm đó. Các lần gọi sau, Singleton Bean sẽ dùng lại chính instance cũ đó $\rightarrow$ tính chất Prototype bị mất hoàn toàn.

    -   **Giải pháp:** Dùng **Method Injection** bằng annotation `@Lookup`, hoặc cấu hình `@Scope(value = ConfigurableBeanFactory.SCOPE_PROTOTYPE, proxyMode = ScopedProxyMode.TARGET_CLASS)`. Lúc này Spring sẽ inject một Proxy object, mỗi lần gọi phương thức, Proxy sẽ chủ động hỏi IoC Container để tạo ra một instance Prototype mới.


### 5. Spring AOP & Proxy Mechanisms (Cơ chế Proxy ngầm)

-   **Câu hỏi:** _Spring AOP hoạt động dựa trên cơ chế nào? Phân biệt JDK Dynamic Proxy và CGLIB Proxy. Tại sao một phương thức không có `@Transactional` gọi một phương thức có `@Transactional` trong cùng một Class thì Transaction lại không hoạt động (Self-invocation issue)?_

-   **Góc nhìn chuyên gia:** Đánh giá cực cao vì đụng đến bản chất của việc xử lý Transactions, Security, Logging trong các dự án thực tế.

-   **Cách trả lời chuẩn:**

    -   Spring AOP chạy dựa trên **Proxy (Ủy quyền)**.

    -   **JDK Dynamic Proxy:** Được dùng khi Target Class có triển khai _Interface_. Nó tạo proxy động dựa trên Interface đó.

    -   **CGLIB Proxy:** Được dùng khi Target Class _không có Interface_. Nó sử dụng kỹ thuật bytecode để sinh ra một subclass kế thừa từ Target Class (Spring Boot mặc định dùng CGLIB).

    -   **Lỗi Self-invocation:** Khi gọi phương thức nội bộ trong cùng một class (`this.method()`), lời gọi này **bỏ qua lớp Proxy** bên ngoài mà chạy thẳng vào code gốc. Vì không đi qua Proxy, các đoạn code tiền xử lý và hậu xử lý (như mở/đóng Transaction) sẽ không được kích hoạt. Để sửa, phải tách class hoặc inject chính class đó vào chính nó (Self-injection).




### Basic Concepts

**1. What is the Spring Framework and what problems does it solve?**

Spring is an enterprise ecosystem that simplifies Java development by eliminating boilerplate code. It solves the issue of tight coupling between application components through non-invasive configuration.

**2. Explain the concept of Inversion of Control (IoC) and how Spring implements it.**

IoC shifts the responsibility of object creation and lifecycle management from the developer to the framework. Spring implements this using an IoC Container that acts as a centralized registry for all application components.

**3. What is Dependency Injection (DI) in Spring and what are its different types?**

DI is the concrete design pattern used to realize IoC by injecting dependent objects into a class. Its primary types are Constructor Injection (recommended), Setter Injection, and Field Injection.

**4. Explain the role of the ApplicationContext in Spring.**

`ApplicationContext` is the advanced IoC container responsible for bean lifecycle management and dependency wiring. It extends `BeanFactory` by adding enterprise features like AOP integration, event publishing, and internationalization (i18n).

**5. What are Spring Beans and how are they managed?**

Spring Beans are standard Java objects instantiated, assembled, and managed entirely by the Spring IoC Container. They are controlled using configuration metadata provided via annotations, Java code, or XML.

### Bean Scopes & Lifecycle

**6. List and explain the different bean scopes in Spring.**

There are 6 scopes: `singleton` (default—one instance per container), `prototype` (a new instance per request), and 4 web-aware scopes: `request`, `session`, `application`, and `websocket`.

**7. Explain the Spring Bean lifecycle.**

Instantiation $\rightarrow$ Populate Properties (DI) $\rightarrow$ Aware Interfaces $\rightarrow$ `BeanPostProcessor` (Before) $\rightarrow$ `@PostConstruct` / Init $\rightarrow$ `BeanPostProcessor` (After) $\rightarrow$ Ready for Use $\rightarrow$ `@PreDestroy` $\rightarrow$ Destruction.

**8. How do you define and configure a bean in XML vs using annotations?**

XML uses the explicit `<bean id="..." class="..." />` tag in a configuration file. Annotations rely on `@ComponentScan` to automatically discover and register classes decorated with `@Component` stereotypes.

**9. What is the difference between `@Component`, `@Service`, `@Repository`, and `@Controller` annotations?**

`@Component` is the generic root annotation; the others are specialized stereotypes for architectural layers: `@Service` for business logic, `@Repository` for data access (with automatic exception translation), and `@Controller` for handling web requests.

**10. How do you create a lazy-initialized bean in Spring?**

Annotate the class or the `@Bean` method with `@Lazy`. This instructs Spring to skip instantiation during application startup and only create the bean in memory when it is first requested by the application.

### Configuration & Annotations

**11. Explain the difference between `@Bean` and `@Component`.**

`@Component` is a class-level annotation for auto-detection (used on code you own). `@Bean` is a method-level annotation inside a configuration class used to manually instantiate and return objects (typically for third-party libraries).

**12. How does Spring handle Java-based configuration vs XML configuration?**

Java configuration uses classes marked with `@Configuration` and `@Bean` to achieve type-safe, refactorable dependency wiring. XML relies on tag structures, which become cumbersome and difficult to maintain as applications scale.

**13. What is the difference between `@Configuration` and `@Component`?**

`@Configuration` classes are proxied using CGLIB to ensure that internal calls to `@Bean` methods always intercept the container and return the exact same singleton instance; `@Component` classes do not undergo this proxying behavior.

**14. Explain the purpose of `@Autowired`, `@Qualifier`, and `@Primary`.**

`@Autowired` triggers automatic dependency matching by type. If multiple candidate beans exist, `@Primary` designates the default preferred bean, while `@Qualifier("name")` targets a specific bean explicitly by its name.

**15. How does Spring handle circular dependencies?**

Spring utilizes a **Three-level Cache** mechanism within its singleton bean creation pipeline to expose a partially constructed, unpopulated instance early, breaking the infinite instantiation loop during field/setter injection.

### Advanced Concepts

**16. What is Spring AOP and what are its main use cases?**

Spring AOP (Aspect-Oriented Programming) decouples cross-cutting concerns from core business logic. Its primary use cases include Transaction Management, Logging, Auditing, and Security checks.

**17. Explain the different types of advice in Spring AOP.**

Advice types include: `@Before` (runs before target method), `@After` (runs after regardless of outcome), `@AfterReturning` (runs after successful execution), `@AfterThrowing` (runs on exception), and `@Around` (wraps the method completely).

**18. How does proxy creation work in Spring (JDK dynamic proxies vs CGLIB)?**

If the target class implements an **Interface**, Spring defaults to a **JDK Dynamic Proxy** via Reflection. If it does not implement an interface, Spring uses **CGLIB** to dynamically generate a subclass by modifying bytecode.

**19. What is the difference between `BeanFactory` and `ApplicationContext`?**

`BeanFactory` provides lazy-loading bean initialization to optimize memory footprints. `ApplicationContext` extends it by eagerly initializing singleton beans at startup and providing built-in support for enterprise features like AOP and Events.

**20. How does Spring handle events and listeners?**

Spring implements the Observer pattern: an component publishes a message via `ApplicationEventPublisher.publishEvent()`, and any component with a method marked `@EventListener` automatically intercepts and processes it asynchronously or synchronously.

### Transaction Management

**21. How does Spring manage transactions?**

Spring uses a generic abstraction layer through the `PlatformTransactionManager` interface, which unifies transaction workflows across diverse database frameworks (JPA, JDBC, Hibernate) using runtime AOP proxies.

**22. Difference between declarative and programmatic transaction management in Spring.**

Declarative management uses the `@Transactional` annotation to let AOP automatically manage boundaries (cleaner code). Programmatic management uses `TransactionTemplate` to explicitly control transaction blocks via code.

**23. What is the role of `@Transactional` annotation?**

It instructs Spring to wrap the execution block in a transactional proxy, opening a database connection upon entry, committing upon successful exit, and automatically initiating a rollback if a `RuntimeException` occurs.

**24. How does Spring handle transaction propagation levels?**

It dictates how a transaction behaves when methods call each other (e.g., `REQUIRED` joins the existing parent transaction and rolls back everything on error; `REQUIRES_NEW` suspends the parent to open an isolated, independent transaction).

**25. What are isolation levels in Spring transactions?**

They control the visibility of concurrent modifications to prevent data anomalies, ranging from `READ_UNCOMMITTED`, `READ_COMMITTED` (prevents dirty reads), `REPEATABLE_READ` (prevents non-repeatable reads), to `SERIALIZABLE` (strict locking).

**💡 Scenario Question: Nested Transactions & Physical Connections**

-   **The Reality:** The `@Transactional` annotation does not create a database connection on its own; it borrows a physical connection from the Connection Pool (e.g., HikariCP) and binds it to the executing thread using `ThreadLocal`.

-   **Nested Scenarios:**

    -   Under `REQUIRED` (default), **only 1 physical connection** is shared. If the inner method throws an unhandled exception, it marks the single transaction as rollback-only, forcing the outer method to roll back as well.

    -   Under `REQUIRES_NEW`, the inner method **borrows a 2nd physical connection** from the pool. The current thread holds two connections simultaneously, which can lead to pool exhaustion deadlocks if the maximum pool size is set too low.


### Performance & Optimization

**26. How to optimize memory usage in a Spring application?**

Avoid scope `prototype` abuse, selectively apply `@Lazy` to heavy beans, tune thread pool and queue capacities accurately, and enforce rigorous cache eviction policies to prevent RAM memory leaks.

**27. How to debug bean creation issues in Spring?**

Analyze the root cause of the `BeanCreationException` trace, launch the application with the `--debug` flag, or set the logging profile `logging.level.org.springframework=DEBUG` while setting breakpoints inside `BeanPostProcessor` implementations.

**28. What are common pitfalls in Spring configuration?**

Self-invocation (calling a local method within the same class), which bypasses the AOP proxy and breaks annotations like `@Transactional` or `@Async`; ambiguous duplicate bean declarations; and leaving database auto-commit active when processing Kafka streams.

**29. How to handle multithreading and concurrency in Spring?**

Spring provides `@Async` to offload processing to an independent `ThreadPoolTaskExecutor`. Because Spring Beans are **Singletons** by default, multiple threads access the same instance concurrently; therefore, bean fields must remain stateless to be thread-safe.

**30. Explain how Spring integrates with caching mechanisms.**

Spring abstracts cache management via the `CacheManager` interface, allowing developers to seamlessly plug in providers like Redis or Caffeine and drive caching behavior declaratively using annotations such as `@Cacheable`, `@CachePut`, and `@CacheEvict`.


# Situational question

### 1. Cơ chế Auto-Configuration (Tự động cấu hình ngầm)

Đây là câu hỏi xuất hiện trong 90% các bài viết chuyên sâu của JavaTechie: _Spring Boot tự động cấu hình các Bean như thế nào?_

-   **Bản chất:** Khi bạn dùng `@SpringBootApplication`, annotation này bọc 3 annotation khác là `@SpringBootConfiguration`, `@ComponentScan`, và `@EnableAutoConfiguration`.

-   **Cơ chế chạy ngầm:** `@EnableAutoConfiguration` sẽ kích hoạt `AutoConfigurationImportSelector`. Lớp này sẽ quét file `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` (ở các bản Spring Boot mới) để load lên danh sách các class cấu hình có sẵn.

-   **Điều kiện lọc:** Các cấu hình này chỉ được kích hoạt nhờ vào các annotation điều kiện như `@ConditionalOnClass` (nếu có thư viện trong classpath), `@ConditionalOnMissingBean` (nếu lập trình viên chưa tự định nghĩa Bean đó). Điều này giúp Spring Boot cực kỳ linh hoạt.


### 2. Quá trình Khởi động ứng dụng (Spring Boot Bootstrap Process)

_Câu hỏi: Điều gì thực sự xảy ra khi bạn bấm chạy hàm `SpringApplication.run(Application.class, args);`?_

-   **Các bước cốt lõi:**

    1.  **Khởi tạo `SpringApplication` object:** Xác định kiểu ứng dụng (Web reactive, Web servlet, hoặc Non-web) và tìm các bộ lắng nghe sự kiện (ApplicationContextInitializer, ApplicationListener) trong file cấu hình.

    2.  **Chuẩn bị Environment:** Load các cấu hình hệ thống, file `application.properties`/`yml`.

    3.  **Tạo ApplicationContext:** Khởi tạo container phù hợp (ví dụ: `AnnotationConfigServletWebServerApplicationContext`).

    4.  **Refresh Context:** Đây là bước nặng nhất, nơi Spring thực hiện quét component (`@ComponentScan`), khởi tạo toàn bộ các Singleton Beans, và **nhúng + khởi động Web Server** (như Tomcat) ngầm định.

    5.  **Chạy Runners:** Gọi các Bean triển khai `CommandLineRunner` hoặc `ApplicationRunner` nếu có.


### 3. Nhúng và tùy biến Embedded Web Server

_Câu hỏi: Spring Boot nhúng Tomcat như thế nào? Làm sao để đổi sang Jetty/Undertow hoặc đổi cổng chạy động?_

-   **Cơ chế nhúng:** Spring Boot sử dụng interface `WebServerFactory` (ví dụ: `TomcatServletWebServerFactory`). Khi Context được refresh, Spring Boot sẽ tự động gọi thư viện Tomcat core chạy ngay trong tiến trình JVM của ứng dụng thay vì phải build file `.war` để deploy ra ngoài như Spring MVC cũ.

-   **Thay đổi server:** Chỉ cần loại bỏ (exclude) starter `spring-boot-starter-tomcat` trong file `pom.xml` / `build.gradle` và thêm starter của server khác vào (như `spring-boot-starter-jetty`).


### 4. Quản lý cấu hình nâng cao: `@Value` vs `@ConfigurationProperties`

_Câu hỏi: Khi nào nên dùng `@Value` và khi nào nên dùng `@ConfigurationProperties`? Cơ chế Relaxed Binding là gì?_

-   **So sánh:**

    -   `@Value` thích hợp cho việc inject các cấu hình đơn lẻ, hỗ trợ cú pháp SpEL phức tạp nhưng không hỗ trợ kiểm thử ràng buộc dữ liệu (Validation).

    -   `@ConfigurationProperties` hỗ trợ gom nhóm cấu hình thành một Object cụ thể, hỗ trợ Type-safety, Hierarchical properties (cấu hình phân cấp), và tích hợp được với Bean Validation (`@Validated`).

-   **Relaxed Binding:** Spring Boot cực kỳ thông minh khi map tên biến. Ví dụ: biến trong Java là `databaseUrl` (camelCase) thì trong file yml bạn có thể viết là `database-url` (kebab-case) hoặc `DATABASE_URL` (dạng biến môi trường Unix), Spring Boot vẫn tự động nhận diện và map chính xác.


### 5. Giám sát hệ thống với Spring Boot Actuator

_Câu hỏi: Làm sao để giám sát sức khỏe của ứng dụng trong môi trường Production? Actuator hoạt động như thế nào?_

-   Actuator cung cấp các **Endpoints** có sẵn (như `/health`, `/metrics`, `/info`, `/threaddump`) để kiểm tra tình trạng kết nối Database, Disk space, hay Memory.

-   Trong các bài viết chuyên sâu, JavaTechie thường nhấn mạnh việc tạo **Custom HealthIndicator** (viết code tự định nghĩa logic kiểm tra sức khỏe của một dịch vụ bên thứ 3) và cách cấu hình bảo mật để không bị lộ các endpoint nhạy cảm ra ngoài thông qua Spring Security.


## REFERENCE
Spring Boot Interview Mastery SERIES, JAVA TECHIE: https://www.youtube.com/watch?v=IdTdgTBXlFw
