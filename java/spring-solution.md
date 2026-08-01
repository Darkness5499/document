
### Tình huống 1: Trì trệ hệ thống do lỗi Async Executor Configuration

-   **Tình huống:** Bạn sử dụng `@Async` để xử lý các tác vụ ngầm như gửi webhook cho đối tác. Vào giờ cao điểm, hệ thống bỗng nhiên phản hồi cực kỳ chậm, các request chính bị timeout. Kiểm tra log thì thấy các luồng xử lý `@Async` bị tràn và block luôn luồng chính. Tại sao và xử lý thế nào?

-   **Giải pháp:**

    -   _Nguyên nhân:_ Mặc định nếu không cấu hình, Spring sẽ sử dụng `SimpleAsyncTaskExecutor`, cơ chế của nó là **tạo mới một Thread cho mỗi request** (không giới hạn), dẫn đến cạn kiệt tài nguyên CPU/RAM, hoặc nó dùng `ThreadPoolTaskExecutor` với hàng đợi vô hạn (`LinkedBlockingQueue` không set capacity).

    -   _Xử lý:_ Tạo một cấu hình `Executor` tường minh với kích thước pool giới hạn và chiến lược xử lý khi pool đầy (`RejectedExecutionHandler`).


    Java
    
    ```
    @Configuration
    @EnableAsync
    public class AsyncConfig {
        @Bean(name = "webhookExecutor")
        public Executor webhookExecutor() {
            ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
            executor.setCorePoolSize(10);
            executor.setMaxPoolSize(50);
            executor.setQueueCapacity(1000); // Tránh queue vô hạn gây OOM
            executor.setThreadNamePrefix("WebhookThread-");
            executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy()); // Thread chính tự xử lý nếu pool đầy để giảm tốc độ request đầu vào
            executor.initialize();
            return executor;
        }
    }
    
    ```


### Tình huống 2: Mất tính nhất quán dữ liệu do Self-Invocation trong `@Transactional`

-   **Tình huống:** Trong cùng một class `OrderService`, bạn có hàm `createOrder()` (không có `@Transactional`) gọi đến hàm `saveToDb()` (có `@Transactional`). Khi hàm `saveToDb()` bị bắn ra `RuntimeException`, dữ liệu vẫn ghi xuống DB chứ không hề Rollback. Tại sao và sửa thế nào?

-   **Giải pháp:**

    -   _Nguyên nhân:_ Lỗi **Self-invocation** (Tự gọi nội bộ) mà chúng ta đã thảo luận ở phần Spring AOP. Khi gọi phương thức trong cùng một class bằng từ khóa `this`, lời gọi sẽ đi thẳng vào code gốc, bỏ qua lớp Proxy bọc ngoài, khiến `@Transactional` hoàn toàn vô hiệu.

    -   _Xử lý:_

        -   Cách 1: Tách hàm `saveToDb()` sang một class Component khác (ví dụ: `OrderRepositoryWrapper`).

        -   Cách 2: Inject chính `OrderService` vào trong nó (Self-injection) bằng `@Autowired` hoặc `@Lazy` để gọi qua Proxy: `orderService.saveToDb()`.


### Tình huống 3: Lỗi N+1 Queries kinh điển trong Spring Data JPA

-   **Tình huống:** Bạn có thực thể `User` quan hệ `@OneToMany` với `Order`. Khi gọi hàm `userRepository.findAll()` để lấy danh sách 1000 user, kiểm tra Hibernate log thấy hệ thống bắn ra tới 1001 câu lệnh SQL xuống DB, làm sập hiệu năng mạng. Xử lý thế nào?

-   **Giải pháp:**

    -   _Nguyên nhân:_ Mặc định Spring Data JPA thực hiện câu lệnh lấy danh sách User trước (1 lệnh), sau đó với mỗi User, nó lại chạy thêm một lệnh SQL riêng lẻ để lấy danh sách `Order` của User đó (N lệnh).

    -   _Xử lý:_ Sử dụng **`JOIN FETCH`** trong câu lệnh `@Query` hoặc sử dụng `@EntityGraph` để ép JPA thực hiện phép JOIN ngay từ câu lệnh đầu tiên.


    Java
    
    ```
    @Query("SELECT u FROM User u JOIN FETCH u.orders")
    List<User> findAllWithOrders();
    
    ```


### Tình huống 4: Rò rỉ bộ nhớ (Memory Leak) do dùng sai Singleton Bean

-   **Tình huống:** Bạn viết một Singleton Bean tên là `ReportService` để export dữ liệu. Lập trình viên thiết kế một biến instance variable dạng `private List<Data> cache = new ArrayList<>()` để lưu dữ liệu tạm thời trong hàm. Sau vài ngày chạy Production, ứng dụng bị crash do lỗi `java.lang.OutOfMemoryError: Java heap space`.

-   **Giải pháp:**

    -   _Nguyên nhân:_ `ReportService` là Singleton (chỉ có 1 instance tồn tại suốt vòng đời ứng dụng). Việc lưu dữ liệu của các request vào biến instance variable (Stateful) khiến danh sách `cache` phình to liên tục và GC (Garbage Collector) không bao giờ dọn dẹp được.

    -   _Xử lý:_ Thiết kế lại Singleton Bean thành **Stateless**. Chuyển biến `List<Data> cache` thành biến cục bộ (Local variable) bên trong phương thức xử lý, hoặc sử dụng `ThreadLocal` nếu cần chia sẻ dữ liệu giữa các hàm trong cùng một thread.


### Tình huống 5: Xung đột Transaction Propagation (Lỗi `UnexpectedRollbackException`)

-   **Tình huống:** `ServiceA` gọi `ServiceB`. Cả hai đều được đánh dấu `@Transactional`. Khi `ServiceB` xảy ra lỗi, `ServiceA` đã chủ động dùng khối `try-catch` bọc quanh lời gọi `ServiceB` để bắt ngoại lệ nhằm tiếp tục xử lý việc khác. Tuy nhiên, khi kết thúc, hệ thống vẫn báo lỗi `UnexpectedRollbackException` và rollback toàn bộ. Tại sao?

-   **Giải pháp:**

    -   _Nguyên nhân:_ Mặc định `@Transactional` sử dụng cơ chế `Propagation.REQUIRED`. Nghĩa là `ServiceB` sẽ dùng chung Transaction với `ServiceA`. Khi `ServiceB` ném ra lỗi, nó đã đánh dấu Transaction chung đó là **Rollback-Only**. Cho dù `ServiceA` có catch lỗi, Spring vẫn buộc phải rollback khi kết thúc transaction chung.

    -   _Xử lý:_ Nếu muốn lỗi của `ServiceB` độc lập và không ảnh hưởng đến `ServiceA`, hãy cấu hình `ServiceB` chạy một transaction hoàn toàn mới: `@Transactional(propagation = Propagation.REQUIRES_NEW)`.


### Tình huống 6: Nghẽn cổ chai hệ thống do thiết lập Connection Pool sai cách

-   **Tình huống:** Ứng dụng Spring Boot của bạn kết nối với DB qua HikariCP (mặc định). Khi traffic tăng đột biến, toàn bộ hệ thống bị treo, log báo lỗi: `HikariPool-1 - Connection is not available, request timed out after 30000ms`. Bạn có nên tăng ngay kích thước `maximum-pool-size` lên 500 không?

-   **Giải pháp:**

    -   _Nguyên nhân:_ Có thể do các transaction chạy quá lâu (Long-running transaction) giữ connection quá lâu, hoặc do số lượng luồng xử lý của Web Server (Tomcat threads) vượt quá khả năng đáp ứng của DB.

    -   _Xử lý:_ Không tăng bừa bãi pool-size lên 500 vì sẽ làm sập CPU của DB do chi phí context switch. Áp dụng công thức tính toán tối ưu của Hikari (`connections = ((core_count * 2) + effective_spindle_count)`). Đồng thời tối ưu mã nguồn: tách các tác vụ không liên quan đến DB (như gọi API bên thứ ba) ra khỏi khối `@Transactional` để giải phóng connection càng nhanh càng tốt.


### Tình huống 7: Lỗi rò rỉ ThreadLocal khi sử dụng `@RequestScope` hoặc Thread Pool

-   **Tình huống:** Bạn sử dụng `SecurityContextHolder` của Spring Security (bản chất lưu dữ liệu trong `ThreadLocal`) để lưu thông tin User đăng nhập. Hệ thống sử dụng một Thread Pool để tái sử dụng luồng. Đột nhiên, User A đăng nhập vào hệ thống lại nhìn thấy thông tin cá nhân của User B ở một request trước đó.

-   **Giải pháp:**

    -   _Nguyên nhân:_ Khi một Thread xử lý xong request của User B, nó quay trở lại Thread Pool nhưng dữ liệu trong `ThreadLocal` **chưa được xóa**. Khi Thread đó được bốc ra để xử lý request cho User A, User A vô tình đọc được dữ liệu cũ của User B.

    -   _Xử lý:_ Sử dụng cơ chế `Interceptor` hoặc `Filter` để luôn luôn dọn sạch vùng nhớ `ThreadLocal` tại giai đoạn hậu xử lý request (`afterCompletion`):


    Java
    
    ```
    SecurityContextHolder.clearContext();
    
    ```


### Tình huống 8: Lỗi Deadlock khi chạy batch update song song bằng `@Transactional`

-   **Tình huống:** Bạn viết một API nhận vào danh sách các mã sản phẩm để cập nhật số lượng tồn kho. Khi nhiều luồng cùng gọi API này đồng thời, DB lập tức báo lỗi `Deadlock detected`.

-   **Giải pháp:**

    -   _Nguyên nhân:_ Luồng 1 nhận danh sách gồm Sản phẩm X và Sản phẩm Y, thực hiện update X trước, Y sau. Luồng 2 nhận danh sách gồm Sản phẩm Y và Sản phẩm X, thực hiện update Y trước, X sau. Hai luồng giữ khóa chéo nhau tạo ra Deadlock.

    -   _Xử lý:_ Trước khi thực hiện lệnh Update hoặc `SELECT ... FOR UPDATE` xuống DB, bắt buộc phải **sắp xếp danh sách đầu vào theo một thứ tự cố định** (Ví dụ: sắp xếp tăng dần theo ID sản phẩm). Khi cả hai luồng đều ăn khóa theo đúng thứ tự (X rồi đến Y), luồng đến sau sẽ phải xếp hàng chờ một cách tuần tự, triệt tiêu hoàn toàn Deadlock.


### Tình huống 9: Tràn bộ nhớ Metaspace do cấu hình Dynamic Proxy sai cách trong AOP/CGLIB

-   **Tình huống:** Bạn tự viết một cơ chế AOP tùy biến để quản lý log cho ứng dụng. Hệ thống chạy một thời gian dài thì crash với lỗi `java.lang.OutOfMemoryError: Metaspace`.

-   **Giải pháp:**

    -   _Nguyên nhân:_ Vùng nhớ Metaspace dùng để lưu trữ metadata của Class. Nếu cấu hình Spring AOP hoặc thư viện sinh mã bytecode (như CGLIB) sai cách, khiến mỗi khi có request đến, Spring lại sinh ra một lớp Proxy Class động mới hoàn toàn thay vì tái sử dụng lớp Proxy cũ, Metaspace sẽ bị lấp đầy và không thể giải phóng.

    -   _Xử lý:_ Đảm bảo các Aspect và Proxy được quản lý dưới dạng Singleton Bean trong Spring Context. Tránh việc tự ý gọi các hàm sinh proxy thủ công (`Enhancer` của CGLIB) ở tầng request-scope mà không có cơ chế cache class.


### Tình huống 10: Spring Boot Actuator rò rỉ thông tin nhạy cảm (Security Risk)

-   **Tình huống:** Đội ngũ Dev bật Spring Boot Actuator để phục vụ giám sát hệ thống (Metrics). Một ngày, hacker quét được endpoint `/actuator/env` hoặc `/actuator/heapdump` và lấy được toàn bộ mật khẩu Database, khóa bí mật AWS S3 dạng plain-text. Bạn giải quyết lỗ hổng này như thế nào mà vẫn giữ được tính năng giám sát?

-   **Giải pháp:**

    -   _Xử lý 3 tầng bảo vệ:_

        1.  **Ẩn endpoint:** Chỉ mở các endpoint thực sự cần thiết (`/health`, `/info`) trong file `application.yml`:

            YAML

            ```
            management:
              endpoints:
                web:
                  exposure:
                    include: "health,info" # Cấm dùng "*"
            
            ```

        2.  **Bảo mật bằng Spring Security:** Cấu hình phân quyền, chỉ cho phép tài khoản có Role `ADMIN` mới được truy cập vào các endpoint nhạy cảm thông qua một cổng (port) nội bộ riêng biệt.

        3.  **Mã hóa dữ liệu nhạy cảm:** Sử dụng các công cụ như **Jasypt** để mã hóa các password trong file cấu hình thành dạng cipher-text (ví dụ: `ENC(xyz123...)`), khiến hacker dù có đọc được file cấu hình hay dump được bộ nhớ cũng không lấy được mật khẩu gốc.