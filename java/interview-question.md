
# Java Interview Questions

## 1. Các tính chất của OOP
- Đóng gói, Kế thừa, Đa hình, Trừu tượng
- Đa hình: override (ghi đè), overload (nạp chồng)
- Trừu tượng: Abstract class và Interface
  - Abstract: cho phép phương thức có thân và phương thức abstract.
  - Interface: quy định phương thức (lưu ý: Java 8+ có default/static methods).
  - Ý nghĩa: Interface quy định input/output, tách rời việc implement.


- đóng gói: gói các thuộc tính và phương thức vào 1 đơn vị gọi là 1 class
- mục đích: che giấu thông tin với các lớp bên ngoài, kiểm soát truy cập
- muốn truy cập phải vượt qua các rule của getter và setter, áp dụng validation ở getter setter
- tại sao phải dùng getter setter cho private trong khi getter setter chả có condition nào?
- trả lời: sẽ ra sao nếu 1 ngày đẹp trời muốn thay đổi logic cho setter cho hàng trăm nơi đều set chẳng hạn amount > 0?
- hoặc muốn log ở setter để xem ai set giá trị này 
- hoặc chỉ muốn cho đọc thì chỉ viết getter không viết setter
- các framework khác như jackson hay jpa đều get set giá trị từ DB thông qua getter setter, không có thì value sẽ bị null


Kế thừa: Cho phép lớp con kế thừa thuộc tính và phương thức của lớp cha
->>>>
Code Reusability
Extensibility
Polimorphism: Cho phép lớp con ghi đè lại phương thức override và phát triển theo cách của riêng nó
chỉ cho phép đơn kế thừa vì đa kế thừa có thể bị chồng chéo khi lớp cha có cùng 1 hàm dẫn đến xung đột
Tight Coupling -> kế thừa dẫn đến liên kết chặt chẽ giữa các lớp, lớp này phụ thuộc lớp khác? do đó IOC hay Spring inject ra đời, thay vì extend thì
giờ tiêm 1 thuộc tính vào lớp để giảm sự phụ thuộc

Đa hình: Polymorphism -> một đối tượng hoặc phương thức có thể thực hiện nhiều hình thái khác nhau tuỳ thuộc vào ngữ cảnh thời điểm hiện tại

Method overloading: nạp chồng -> xảy ra lúc biên dịch, trình biên dịch sẽ nhìn vào tham số truyển vào để xác định rõ hàm nào sẽ được gọi lúc java biên dịch mã code
Method overriding: ghi đè phương thức -> xảy ra lúc chạy, kết hợp với kế thừa và inter
Method overriding không ghi đè thuộc tính, ví dụ Animal animal = new Cat(), thuộc tính được xác định lúc biên dịch
Hàm con extend thì phải có quyền bằng hoặc lớn hơn, ví dụ protected thì hàm con phải protected hoặc
Override -> chỉ mục của phương thức sẽ trỏ đến địa chỉ của phương thức của lớp con
Class sẽ tạo 1 bảng virtual table chứa danh sách là các địa chỉ trỏ đến phương thức mà class đó sở hữu -> con sẽ trỏ đến mothod của con
"Tại thời điểm biên dịch, Compiler chỉ sinh ra lệnh invokevirtual kèm theo vị trí chỉ mục của hàm trong bảng phương thức ảo.
Khi chạy (Runtime), JVM sẽ kiểm tra kiểu dữ liệu thực tế của đối tượng nằm trên bộ nhớ Heap, sau đó truy cập vào bảng vtable (Virtual Method Table) của chính Class đó tại vùng nhớ Metaspace.
Nếu Class con đã ghi đè phương thức, con trỏ tại vị trí chỉ mục trong vtable sẽ trỏ đến địa chỉ vùng nhớ mới của Class con, giúp JVM kích hoạt chính xác logic đã được ghi đè."

Trừu tượng ->> Đơn giản hoá sự phức tạp, tập trung vào What to do not How to do
Interface: trừu tượng tuyệt đối, bộ chuẩn hành vi, một cái hợp đồng input output
Abstract: Trừu tượng 1 phần
Khi thiết kế hệ thống, em dùng Interface để tạo ra các điểm nối (Extension Points) giúp các Module giao tiếp với nhau mà không bị phụ thuộc vào code chi tiết của nhau (Decoupling). >
Điều này giúp hệ thống cực kỳ dễ test (dễ Mocking) và có thể thay đổi, nâng cấp toàn bộ phần lõi công nghệ phía sau mà không làm ảnh hưởng đến các thành phần đang gọi bên ngoài."



## 2. Sự khác nhau giữa Interface và Abstract
- Interface: quy ước lập trình, chỉ định API (input/output).
- Abstract class: có thể chứa trạng thái và implement mặc định; bắt buộc subclass implement abstract methods.

## 3. LinkedList vs ArrayList (cơ chế CRUD)
- LinkedList: dùng node với con trỏ, các phần tử là node; chèn/xóa nhanh ở giữa/đầu/cuối.
- ArrayList: mảng động; khi vượt quá capacity sẽ copy sang mảng mới (thường tăng ~1.5x); default capacity = 10; truy xuất ngẫu nhiên nhanh O(1).
- đã hiểu bản chất thực sự chưa? khi nó copy sang mảng mới trên ram thì thế nào? nó có phải tìm 1 mảnh đất mới không? hay nối thêm vào đấy?
- có thực sự hiểu việc cấp phát biến, list trong java hoạt động thế nào khi tương tác với ram không?

## 4. Cấu trúc Map/HashMap/TreeMap/Set
- HashMap/HashSet: triển khai bằng mảng các bucket (mỗi bucket là linked list hoặc tree khi collision nhiều).
- Sau khi hash, các giá trị cùng bucket được so sánh bằng equals để tránh duplicate (với Set).
- TreeMap: triển khai bằng cây (ví dụ Red-Black tree) — sắp xếp theo key.

## 5. Luồng (Threads) và concurrency
Đa nhiệm: Multitasking chạy nhiều nhiệm vụ, quay vòng các task để có cảm giác liên tục song
ĐA xử lý: tầm phần cứng, Multiprocessing, Các core các thread chạy song song thựcsong
Đa luồng: thread là đơn vị nhỏ nhất CPU quản lý, Mỗi process như 1 ứng  gồm nhiều thread con, chạy các thread đấy song song

Các ứng dụng sẽ được HĐH cấp phát một bộ nhớ RAM riêng biệt để không xung đột với nhau
Trong java, được tách ra làm 2 vùng là stack và heap, stack sẽ lưu các biến local của thread để không va chạm với nhau, như các API khác nhau sẽ nằm ở stack khác nhau

biến static sẽ nằm ở metaspace, trỏ đến object trong

- Thread, Runnable -> ExecutorService -> Future/Callable -> CompletableFuture (Java 8+)
- ThreadPool: pool quản lý số lượng thread (maxPoolSize...)
- Sử dụng CompletableFuture cho xử lý bất đồng bộ.

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


## 8. String pool, StringBuffer
- String pool lưu interned strings để tiết kiệm bộ nhớ.
- StringBuffer synchronized; StringBuilder không synchronized (khuyên dùng khi không đa luồng).

## 9. Stack và Heap
- Stack: lưu biến cục bộ, frame hàm; Heap: lưu object, garbage-collected.

## 10. Streams
- Stream cung cấp API xử lý tập hợp theo phong cách functional (map/filter/reduce).
- Hiệu năng tùy tình huống; parallelStream có thể đem lại lợi ích nhưng cần cân nhắc overhead.

5 câu nhớ nhanh khi đi phỏng vấn Senior:
Stream không chứa dữ liệu, nó chỉ mô tả cách xử lý dữ liệu.
Intermediate operation lazy, chỉ chạy khi có terminal operation.
Stream xử lý theo pipeline, mỗi element đi qua toàn bộ pipeline.
Stream không làm code chạy nhanh hơn mặc định, đôi khi còn chậm hơn loop.
Parallel stream chỉ dùng khi workload lớn + độc lập + CPU bound, không dùng tùy tiện.

Với góc nhìn Senior: đừng dùng Stream để mutate biến bên ngoài. Stream nên được dùng theo kiểu:

- Input → transform → output
- thay vì:
- Input → thay đổi state bên ngoài.


- Nếu e khai báo 1 biến là int count = 0
Thì dùng stream.foreach count++ thì giá trị count có tăng lên không
--> không tăng, lỗi vì không cho phép thay đổi reference bên trong
6. Tóm lại cực ngắn
✔ for: bạn muốn đổi reference hay value đều được
❌ stream/lambda: không cho đổi local variable reference
✔ lý do: lambda có cơ chế closure + có thể async/parallel
✔ stream muốn state → phải dùng collector hoặc mutable object được share có kiểm soát

## 11. equals() và hashCode(), cách Set hoạt động
- equals(): so sánh nội dung object.
- hashCode(): trả về mã băm; hợp đồng equals/hashCode quyết định behavior trong Hash-based collections.
- Set sử dụng hashCode để định bucket, equals để kiểm tra trùng lặp.

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