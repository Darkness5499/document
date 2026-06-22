
## 💬 Tình huống 1: Bẫy rò rỉ kết nối (Connection Pool Starvation) do `@Transactional` kết hợp `@Async` hoặc gọi API ngoài

> **"Hệ thống của em dạo này thỉnh thoảng bị treo cứng, các API khác chọc vào đều báo lỗi Timeout. Khi check log, em thấy hàng trăm thread Tomcat đang xếp hàng chờ mượn Connection từ HikariCP (`App-Connection-Pool is not available`). Cấu hình hàm xử lý của em như sau: Hàm dính `@Transactional`, bên trong có log dữ liệu, có chọc DB và cuối cùng là gọi một API REST sang một Microservice bên thứ ba (mất khoảng 3-5 giây để phản hồi). Lỗi kiến trúc nằm ở đâu và sửa thế nào?"**

### ⚙️ Bản chất cơ học tầng sâu của Senior:

Đây là lỗi **Cạn kiệt Connection Pool (Starvation)** kinh điển.

1.  Khi một luồng chạy vào hàm có `@Transactional`, Spring Data sẽ lập tức xuống HikariCP để mượn **ngay lập tức 1 kết nối vật lý (Connection)** từ DB để chuẩn bị mở Transaction.

2.  Khi code chạy đến đoạn gọi API REST bên thứ ba (mất 3-5 giây), cái Thread đó sẽ đứng im chờ đợi (Block I/O). Điều chí mạng là: **Nó vẫn ôm chặt lấy cái kết nối DB vật lý kia mà không thả ra**, mặc dù trong 3-5 giây đó nó không hề chọc gì xuống DB nữa.

3.  Khi có 100 request cùng lao vào, 100 kết nối của HikariCP bị chiếm giữ sạch bách chỉ để... đứng chờ API ngoài phản hồi. Hệ thống hết sạch kết nối, các API khác lao vào dính lỗi nghẽn mạch ngay lập tức.


### 🛠️ Cách sửa chuẩn Kiến trúc:

-   **Quy tắc tối thượng:** Tuyệt đối không được thực hiện các tác vụ I/O mạng block lâu (như gọi API ngoài, đọc file lớn, gửi mail) **bên trong** một vùng `@Transactional`.

-   **Refactor code:** Tách hàm gọi API ngoài ra khỏi vùng quản lý giao dịch. Chỉ bọc `@Transactional` đúng vào đoạn code thực sự tương tác với DB (áp dụng nguyên lý Single Responsibility - SRP).


## 💬 Tình huống 2: Lỗi mất mát dữ liệu do luồng chạy bất đồng bộ (Async vs Transaction Lifecycles)

> **"Anh có một hàm `@Transactional`. Dòng 1: Anh lưu một Entity xuống DB (`repository.save(entity)`). Dòng 2: Anh gọi một hàm xử lý ngầm được đánh dấu `@Async` và truyền cái Entity vừa lưu đó vào làm tham số. Tại sao trong môi trường chịu tải cao, hàm `@Async` kia rất hay bị nổ lỗi `EntityNotFoundException` (không tìm thấy dữ liệu trong DB), mặc dù dòng 1 đã chạy thành công không có lỗi?"**

### ⚙️ Bản chất cơ học tầng sâu của Senior:

Đây là cuộc đua luồng chéo giữa **Vòng đời Transaction** và **Vòng đời Async Thread**.

1.  Như anh em mình đã mổ xẻ ở phần Bulk Insert, khi dòng 1 `.save()` chạy, Hibernate chỉ đưa Object vào First-level Cache trên RAM chứ **chưa bắn lệnh INSERT vật lý xuống DB** (Vì Transaction chưa kết thúc, chưa `flush` và `commit`).

2.  Dòng 2 gọi hàm `@Async`, Spring lập tức cắt một Thread khác từ Pool ra để chạy song song.

3.  Thread Async này lao vào DB và thực hiện lệnh `SELECT` để tìm cái Entity kia. Nhưng tại thời điểm miligiây đó, cái Thread chính (Tomcat Thread) vẫn đang mải chạy nốt phần cuối của hàm và **chưa hề thực hiện hành động Commit Transaction**.

4.  Vì DB chạy cơ chế cách ly giao dịch mặc định (Read Committed), Thread Async hoàn toàn không thể nhìn thấy dữ liệu chưa được commit của Thread chính. Lỗi `EntityNotFoundException` lập tức nổ ra.


### 🛠️ Cách sửa chuẩn Kiến trúc:

Không được kích hoạt tác vụ bất đồng bộ khi giao dịch chưa hoàn tất. Hãy sử dụng bộ lắng nghe vòng đời transaction của Spring:

Java

```
repository.save(entity);

// Chỉ kích hoạt Thread Async SAU KHI Thread chính đã commit thành công xuống DB vật lý
TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
    @Override
    public void afterCommit() {
        asyncService.processParallel(entity.getId());
    }
});

```

## 💬 Tình huống 3: Lỗi rò rỉ bộ nhớ ngầm (Memory Leak) do sử dụng `ThreadLocal`

> **"Trong hệ thống Microservices, để không phải truyền thông tin `UserContext` (userId, token) qua tham số của từng hàm, em sử dụng `ThreadLocal` (hoặc `RequestContextHolder` của Spring) để lưu trữ toàn cục. Ứng dụng chạy vài tuần thì RAM Heap tăng dần không giảm và nổ lỗi `OutOfMemoryError`. Tại sao bộ dọn rác GC không thể dọn dẹp các Object trong `ThreadLocal` này khi request đã kết thúc?"**

### ⚙️ Bản chất cơ học tầng sâu của Senior:

-   **Cơ chế của ThreadLocal:** Dữ liệu được lưu trong `ThreadLocal` thực chất được giữ bởi một bản đồ bám chặt vào **vòng đời của chính cái Thread đang chạy**.

-   **Bẫy Thread Pool vật lý:** Trong ứng dụng Web, Tomcat sử dụng một **Thread Pool** cố định để tái sử dụng các luồng. Khi Request A kết thúc, Thread Tomcat không hề chết đi mà nó quay trở lại Pool để nằm chờ Request B.

-   Do Thread không chết, nên cái bản đồ dữ liệu nằm trong `ThreadLocal` gắn với Thread đó **mãi mãi kết nối với mạch GC Roots**. Bộ dọn rác GC nhìn vào thấy nó vẫn có thực thể quản lý nên tuyệt đối không bao giờ dám xóa. Khi hàng vạn request đi qua, các Object cũ tích tụ lại trên các Thread của Pool làm tràn RAM Heap vật lý.


### 🛠️ Cách sửa chuẩn Kiến trúc:

Bắt buộc phải dọn dẹp bãi chiến trường ngay trước khi Thread rời đi bằng cách bọc trong khối `try-finally`:

Java

```
try {
    UserContext.set(currentUser);
    filterChain.doFilter(request, response);
} finally {
    UserContext.clear(); // 🎯 Từ khóa sinh tử để giải phóng RAM cho GC hốt
}
```

### câu hỏi 3: 50k bản ghi lưu db kiểu gì

Đây là một câu hỏi mang tính thực chiến cực kỳ cao. Khi xử lý đến con số 50,000 bản ghi, nếu anh dùng cách thông thường, hệ thống sẽ bị nghẽn mạng, tràn bộ nhớ RAM Heap và chạy mất hàng phút.

Để giải quyết bài toán này một cách tối ưu nhất, chúng ta cần bóc tách cơ chế ngầm của hàm `.saveAll()` và cấu hình kỹ thuật **Batch Insert** (Chèn dữ liệu hàng loạt).

## 1. Hàm `.saveAll()` có nhét tất cả vào 1 Transaction duy nhất không?

Câu trả lời ngắn gọn là: **CÓ**, nếu hàm gọi `.saveAll()` của anh đang nằm trong một Transaction có sẵn, hoặc bản thân hàm `.saveAll()` của Spring Data sẽ tự mở ra **duy nhất một Transaction** để bọc lấy toàn bộ quá trình lưu.

### ⚙️ Xem mã nguồn ngầm của Spring (`SimpleJpaRepository`):

Java

```
@Transactional
public <S extends T> List<S> saveAll(Iterable<S> entities) {
    List<S> result = new ArrayList<>();
    for (S entity : entities) {
        result.add(save(entity)); // Vẫn chạy vòng lặp for từng thằng!
    }
    return result;
}

```

### 🚨 Nhưng tại sao `.saveAll()` mặc định vẫn RẤT CHẬM với 50,000 bản ghi?

Mặc dù chạy chung **một** Transaction (chỉ commit 1 lần ở cuối), nhưng ở tầng hạ cứng, Spring vẫn chạy vòng lặp `for` và bắn **50,000 câu lệnh SQL riêng biệt** xuống Database qua mạng mạng TCP/IP:

SQL

```
INSERT INTO task (id, name) VALUES (1, 'Task 1');
INSERT INTO task (id, name) VALUES (2, 'Task 2');
... (bắn 50,000 lần)

```

Việc này gây ra chi phí I/O mạng cực kỳ khủng khiếp. Ngoài ra, như anh em mình đã bàn, 50,000 Object này dính chặt vào First-level Cache của Hibernate làm RAM Heap phình to dữ dội.

## 2. Giải pháp giải quyết: Cách lưu 50,000 bản ghi xuống DB nhanh nhất

Để đưa tốc độ từ vài phút xuống **vài giây**, anh Alex cần áp dụng giải pháp **Batch Insert (Gom nhóm câu lệnh)** kết hợp với **Giải phóng RAM chủ động**.

### Bước 1: Cấu hình Spring Boot gom lệnh (Gom 50,000 lệnh thành các cụm nhỏ)

Anh thêm 3 dòng cấu hình này vào file `application.yml` để bắt Hibernate gom các lệnh `INSERT` đơn lẻ thành các câu lệnh gộp đại trà:

YAML

```
spring:
  jpa:
    properties:
      hibernate:
        jdbc:
          batch_size: 1000 # Gom 1000 lệnh INSERT thành 1 lần bắn xuống DB
        order_inserts: true # Sắp xếp lại lệnh để tối ưu hóa việc gộp batch
        order_updates: true

```

Lúc này, thay vì bắn 50,000 lần, hệ thống chỉ bắn 50 lần qua mạng, mỗi lần chứa một câu lệnh gộp dạng:

SQL

```
INSERT INTO task (id, name) VALUES (1, 'Task 1'), (2, 'Task 2'), ... (đủ 1000 thằng)

```

### Bước 2: Viết code Custom Batch Repository để giải phóng RAM chủ động

Nếu anh cứ nhét cả 50,000 thằng vào một List rồi gọi `.saveAll()`, RAM vẫn sẽ bị nghẹn do First-level Cache giữ chặt Object. Anh cần viết một hàm custom để **cứ chèn xong 1000 thằng thì xóa sạch bộ nhớ đệm RAM 1 lần**:

Java

```
@Repository
public class TaskBatchRepository {

    @PersistenceContext
    private EntityManager entityManager;

    @Transactional
    public void saveAllInBatch(List<Task> tasks) {
        int batchSize = 1000; // Khớp với cấu hình trong file yml

        for (int i = 0; i < tasks.size(); i++) {
            entityManager.persist(tasks.get(i));

            // Cứ đủ 1000 phần tử thì ép ghi xuống DB và dọn sạch RAM Heap
            if (i > 0 && i % batchSize == 0) {
                entityManager.flush(); // Ép bắn cụm 1000 lệnh SQL xuống DB
                entityManager.clear(); // Xóa sạch bộ nhớ đệm First-level Cache trên RAM
            }
        }

        // Flush và clear nốt những phần tử dư thừa cuối cùng
        entityManager.flush();
        entityManager.clear();
    }
}

```

## ⚠️ 2 Lưu ý "Chí mạng" tầng Senior để Batch Insert hoạt động

Có rất nhiều lập trình viên cấu hình `batch_size` đầy đủ nhưng hệ thống vẫn chạy chậm như rùa bò. Lý do là vì họ dính vào 2 bẫy sau:

### 1. Bẫy Chiến lược sinh ID (`@GeneratedValue`)

Nếu Class Entity của anh đang cấu hình khóa chính dạng `GenerationType.IDENTITY` (tự động tăng tịnh tiến của MySQL):

Java

```
@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
private Long id;

```

👉 **Hibernate sẽ tự động VÔ HIỆU HÓA tính năng Batch Insert.** * _Lý do cơ học:_ Để đưa Object vào First-level Cache, Hibernate bắt buộc phải biết cái ID của Object đó là gì. Nhưng với cơ chế `IDENTITY`, phải ghi hẳn lệnh xuống DB thì DB mới sinh ra ID. Do đó, nó buộc phải quay lại cách chạy từng lệnh một để lấy ID về.

-   _Cách sửa chuẩn Senior:_ Chuyển sang dùng chiến lược **`GenerationType.SEQUENCE`** (nếu dùng PostgreSQL, Oracle) hoặc tự sinh ID ở tầng ứng dụng dưới dạng **UUID String** trước khi gọi lưu.


### 2. URL kết nối Database thiếu tham số tối ưu (Dành riêng cho MySQL)

Nếu dùng MySQL, anh bắt buộc phải bổ sung tham số `rewriteBatchedStatements=true` vào trong chuỗi URL kết nối JDBC:

Properties

```
spring.datasource.url=jdbc:mysql://localhost:3306/bpm?rewriteBatchedStatements=true

```

Nếu thiếu thuộc tính này, Driver JDBC của MySQL sẽ từ chối việc gộp các câu lệnh `INSERT` thành cú pháp gộp dòng, làm mất hoàn toàn tác dụng của `batch_size`.

## 📊 Bảng so sánh tốc độ xử lý 50,000 bản ghi

**Phương pháp**

**Cơ chế vật lý trên mạng/RAM**

**Tốc độ ước tính**

**Đánh giá an toàn bộ nhớ**

**Vòng lặp `for` gọi `.save()`**

50,000 Transaction $\rightarrow$ 50,000 kết nối DB mạng.

~ 2 - 5 phút

**Cực kỳ nguy hiểm** (Treo kết nối Pool).

**Dùng `.saveAll()` mặc định**

1 Transaction $\rightarrow$ 50,000 lệnh SQL đơn lẻ trên mạng.

~ 30 - 60 giây

**Rủi ro cao** (Dễ dính tràn RAM Heap do Cache giữ Object).

**Batch Insert + `clear()` RAM**

1 Transaction $\rightarrow$ 50 câu lệnh gộp gãy gọn, RAM được giải phóng cuốn chiếu sau mỗi 1000 thằng.

**~ 2 - 4 giây**

**Tuyệt đối an toàn** và tối ưu hiệu năng.

### 💬 Câu hỏi 4:

> _"Khi anh cần viết một hàm Update dữ liệu lớn (Bulk Update) cho khoảng 50,000 dòng dữ liệu trong DB, anh có nên kéo 50,000 Entity lên RAM rồi dùng vòng lặp `for` sửa từng thằng và gọi `.save()` không? Tại sao và giải pháp thay thế là gì?"_

-   **Phân tích bản chất của Senior:** **Tuyệt đối không!** Nếu làm vậy, RAM Heap sẽ bị quá tải vì phải duy trì 50,000 Object thô kèm theo 50,000 Object bản sao trong First-level Cache phục vụ cho cơ chế _Dirty Checking_ của Hibernate. CPU sẽ tăng vọt 100% để chạy Minor/Full GC liên tục, tệ hơn là dính lỗi `OutOfMemoryError`.

-   **Giải pháp thay thế:** Sử dụng annotation **`@Modifying`** kết hợp với câu lệnh `@Query` cập nhật trực tiếp (Native SQL hoặc JPQL):


Java

```
@Modifying
@Query("UPDATE Task t SET t.status = :status WHERE t.createdAt < :date")
void bulkUpdateStatus(@Param("status") String status, @Param("date") LocalDateTime date);

```

-   **Cơ chế ngầm:** Lệnh này sẽ được ném thẳng xuống DB để xử lý thô ở tầng ổ cứng của hệ quản trị cơ sở dữ liệu. Nó đi xuyên thẳng, không nạp bất kỳ một Entity nào lên bộ nhớ RAM Heap của JVM, bảo vệ RAM tuyệt đối và tốc độ xử lý nhanh gấp hàng trăm lần.


## 3. Quản lý Giao dịch & Khóa (Concurrency & Locking)

### 💬 Câu hỏi 5:

> _"Hãy phân biệt cơ chế hoạt động ngầm và kịch bản áp dụng thực tế giữa Khóa lạc quan (Optimistic Locking) và Khóa bi quan (Pessimistic Locking) trong Spring Data JPA?"_

-   **Phân tích bản chất của Senior:**

    -   **Optimistic Locking (Khóa lạc quan):** Không hề khóa luồng ở DB. Nó sử dụng một trường **`@Version`** (kiểu int hoặc timestamp) lưu trong Entity. Khi Thread A và Thread B cùng đọc một bản ghi có `version = 1`. Thread A sửa xong trước, ghi xuống DB $\rightarrow$ DB kiểm tra thấy `version` vẫn là 1 $\rightarrow$ Cho phép ghi và tăng `version = 2`. Thread B sửa xong sau, ghi xuống DB, DB check thấy `version` hiện tại đã là 2 (khác với con số 1 lúc Thread B đọc lên) $\rightarrow$ DB từ chối và Spring ném ra lỗi `OptimisticLockException`.

        -   _Phù hợp:_ Hệ thống có lượng Request Đọc nhiều, Ghi ít, ít khi bị sửa trùng nhau.

    -   **Pessimistic Locking (Khóa bi quan):** Khóa vật lý ngay ở tầng DB. Khi Thread A gọi hàm tìm kiếm dính khóa này, Spring Data sẽ bắn câu lệnh `SELECT ... FOR UPDATE` xuống DB. DB sẽ **khóa chặt cái dòng (Row) dữ liệu đó lại**. Thread B lao tới muốn đọc hay sửa dòng đó đều bị chặn (Blocked) ở tầng DB, phải xếp hàng chờ Thread A chạy xong Transaction.

        -   _Phù hợp:_ Các hệ thống nhạy cảm về tiền bạc, kho hàng, đặt vé máy bay... nơi dữ liệu tuyệt đối không được phép sai lệch và chấp nhận hy sinh hiệu năng giảm tốc độ để đổi lấy an toàn dữ liệu.

# Spring Data, Spring JPA, and Hibernate Interview Questions

## **Theoretical Questions**
1. What is the difference between JPA, Hibernate, and Spring Data JPA?
2. Can you explain the architecture of Hibernate?
3. What is the role of the `EntityManager` in JPA?
4. How does the Spring Data JPA `Repository` abstraction work?
5. What are the benefits of using Spring Data JPA over plain Hibernate?
6. Can you explain the concept of "lazy loading" and "eager loading" in Hibernate?
7. What are the differences between `getOne()` and `findById()` in Spring Data JPA?
8. What is the difference between `save()` and `saveAndFlush()` in Spring Data JPA?
9. How does Hibernate manage caching? Explain the difference between first-level and second-level cache.
10. Can you explain the concept of the persistence context in JPA?
11. What is the difference between `merge()` and `persist()` in JPA?
12. How are transactions managed in Spring Data JPA?
13. What are entity lifecycle callbacks in JPA?
14. Can you explain the N+1 select problem in Hibernate? How can it be solved?
15. What is the difference between `@OneToOne`, `@OneToMany`, and `@ManyToMany` mappings in JPA?

## **Scenario-Based Questions**
1. You notice that Hibernate is generating too many queries (N+1 problem). How would you optimize it?
2. Your application is facing performance issues due to unnecessary database calls. How would you leverage caching in Hibernate to fix it?
3. You need to fetch data from multiple tables with complex joins. How would you approach it in Spring Data JPA?
4. A query is taking too long to execute. How would you debug and improve it in a Spring Data JPA context?
5. You have to migrate from native Hibernate APIs to Spring Data JPA. What steps would you take and what challenges might you face?
6. You need partial updates for entities instead of updating the whole row. How would you achieve this in JPA?
7. A service method is throwing `LazyInitializationException`. How would you resolve it?
8. You need to perform batch inserts or updates using Spring Data JPA. How would you configure it?
9. You want to implement auditing (created date, updated date, created by, updated by) in all entities. How would you do it in Spring Data JPA?
10. You need to execute a stored procedure from Spring Data JPA. How would you handle it?


## REFERENCE
SPRING TRANSACTION JAVA TECHIE: https://www.youtube.com/watch?v=eWl8G7NDKqo&list=PLVz2XdJiJQxxj_zMhm6zCPO6zhtOcq-wl
JDBC: https://techmaster.vn/posts/36899/100-cau-hoi-phong-van-java-phan-3-jdbc


