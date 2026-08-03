https://docs.google.com/spreadsheets/d/1-7YUq2pn5oXadHHH5AGm9KgBqWI42N0g-FzXLRWgbqc/edit?gid=706181798#gid=706181798
# 1 & 3. Các thành phần của Kafka: Ý nghĩa và Cách sử dụng từng thành phần

Hệ sinh thái Kafka vận hành giống như một **Hệ thống logistics (vận chuyển hàng hóa) siêu tốc**. Mỗi thành phần đóng một vai trò cơ học riêng biệt:

### A. Producer (Người phát tin / Phía gửi dữ liệu)

-   **Ý nghĩa:** Là ứng dụng đẩy dữ liệu/event vào hệ thống Kafka (ví dụ: Microservice khởi tạo hồ sơ vay của bên anh).

-   **Cách sử dụng:** Anh cấu hình `KafkaTemplate` trong Spring Boot để bắn các gói tin JSON hoặc Avro kèm theo một cái **Key** (ví dụ: `customerId` hoặc `taskId`). Key này rất quan trọng vì Kafka sẽ dựa vào đó để băm (Hash) và quyết định tin nhắn sẽ đi vào phân vùng vật lý nào.


### B. Broker (Máy chủ Kafka / Trạm trung chuyển)

-   **Ý nghĩa:** Là một server vật lý chạy tiến trình Kafka. Một cụm Kafka (Cluster) thường gồm nhiều Broker phối hợp với nhau để chia tải và làm bản sao dự phòng.

-   **Cách sử dụng:** Broker không xử lý logic nghiệp vụ. Nhiệm vụ duy nhất của nó là nhận tin từ Producer, **ghi tuần tự xuống ổ đĩa**, sao lưu sang các Broker khác (Replicas) và đợi Consumer đến kéo dữ liệu về.


### C. Topic (Chủ đề / Đường cao tốc dữ liệu)

-   **Ý nghĩa:** Là một cái tên logic dùng để phân loại tin nhắn (ví dụ: topic `mb.credit.lending.bpm.events`).

-   **Cách sử dụng:** Anh tạo ra các Topic khác nhau cho các nghiệp vụ khác nhau. Phía gửi và phía nhận chỉ cần đăng ký đúng tên Topic là có thể thông tin được với nhau mà không cần biết đối phương là ai.


### D. Partition (Phân vùng vật lý - Trái tim của tốc độ)

-   **Ý nghĩa:** Bản chất một Topic là một khái niệm trừu tượng, còn **Partition mới là các file log vật lý thực sự nằm dưới ổ đĩa** của Broker. Một Topic sẽ được chặt nhỏ thành nhiều Partition.

-   **Cách sử dụng:** Khi cấu hình Topic, anh cần chỉ định số lượng Partition (ví dụ: 8 hoặc 16). Việc chia nhỏ này giúp nhiều Thread Consumer có thể lao vào hút dữ liệu song song từ nhiều file khác nhau, phá vỡ giới hạn băng thông của một server đơn lẻ.


### E. Consumer & Consumer Group (Người nhận tin / Nhóm tiêu thụ)

-   **Ý nghĩa:**

    -   **Consumer:** Là ứng dụng chủ động kéo (pull) tin nhắn từ Kafka về để xử lý (chính là hàm `@KafkaListener` trong lõi BPM của anh).

    -   **Consumer Group:** Tập hợp các Consumer có cùng một `groupId`. Kafka dùng cơ chế nhóm này để tự động chia đều các Partition cho các máy chủ Java, đảm bảo một tin nhắn chỉ bị nuốt bởi duy nhất 1 Node trong nhóm (tránh xử lý trùng).

-   **Cách sử dụng:** Anh cắm nhiều Node chạy cùng code Java Backend, cấu hình chung một `groupId`. Khi tải tăng đột biến, Kafka sẽ tự động điều tiết chia việc cho các máy chủ chạy song song.


### F. Offset (Số thứ tự tin nhắn / Con trỏ vị trí)

-   **Ý nghĩa:** Là một số nguyên tăng dần, định danh vị trí của từng tin nhắn bên trong một Partition.

-   **Cách sử dụng:** Giống như số trang sách. Khi Consumer đọc xong tin nhắn số `#10`, nó sẽ **Commit Offset** `#10` về cho Broker. Nếu hệ thống bị crash, khi bật lại, Consumer chỉ cần nhìn vào Offset gần nhất được commit để đọc tiếp trang số `#11`, không bao giờ bị mất dấu dữ liệu.


## 2. Khi nào nên sử dụng Kafka?

Anh nên đưa Kafka vào kiến trúc hệ thống khi gặp các bài toán thực chiến sau:

1.  **Khi cần Khử ghép nối (Decoupling) giữa các dịch vụ:** Phía gửi tin (Core Banking) chỉ cần ném Event vào Kafka rồi đi làm việc khác, không cần biết phía nhận (BPM Engine) có đang bận, đang sập hay đang bảo trì hay không. Hệ thống thượng nguồn không bao giờ bị ảnh hưởng bởi hệ thống hạ nguồn.

2.  **Khi hệ thống cần Giảm tải & Hứng tải (Buffering / Load Leveling):** Vào các khung giờ cao điểm, lượng hồ sơ vay đổ về tăng đột biến gấp 10 lần bình thường. Thay vì để DB chịu trận trực tiếp và sập nguồn, Kafka sẽ đóng vai trò là cái đập thủy điện hứng toàn bộ dòng lũ message đó trên ổ đĩa tuần tự, cho phép các ứng dụng Java thong thả kéo tin về xử lý theo đúng năng lực của DB.

3.  **Khi cần xử lý dữ liệu luồng với hiệu năng siêu cao (High Throughput & Low Latency):** Như anh em mình đã mổ xẻ, khi hệ thống yêu cầu gánh hàng nghìn transaction/giây (TPS) với cơ chế xử lý bất đồng bộ (`@Async`), ghi đĩa tuần tự của Kafka là lựa chọn tối ưu nhất so với các hệ thống Message Queue truyền thống (như RabbitMQ vốn tốn tài nguyên cho việc quản lý RAM và routing phức tạp).

4.  **Khi làm kiến trúc hướng sự kiện (Event-Driven Architecture) và lưu vết lịch sử (Event Sourcing):** Kafka lưu trữ dữ liệu an toàn trên đĩa cứng trong nhiều ngày. Anh có thể tận dụng điều này để dựng lại toàn bộ lịch sử các bước đi của một hồ sơ vay từ quá khứ đến hiện tại khi cần audit hệ thống.

# 1. Làm sao để kafka xử lý hàng triệu message trên ngày  ?

## 1. Thiết kế Ghi đĩa tuần tự (Sequential I/O) - Nhanh như RAM

Nhiều người nghĩ ghi dữ liệu xuống ổ đĩa (HDD/SSD) sẽ rất chậm so với RAM. Nhưng Kafka đã lợi dụng một đặc tính vật lý của ổ cứng: Ghi tuần tự (Sequential Access) nhanh hơn ghi ngẫu nhiên (Random Access) gấp hàng vạn lần.

- Cơ học: Bảng tin (Topic) của Kafka thực chất là một File Log nối dài. Khi có message mới, Kafka chỉ việc "gõ" dữ liệu nối tiếp vào cuối file (Append-only). Con trỏ ổ đĩa không phải nhảy đi nhảy lại để tìm không gian trống (như cách Database tìm Page/Block).

- Tốc độ ghi tuần tự này tiệm cận với tốc độ ghi trên RAM, giúp Kafka nuốt trọn hàng triệu tin nhắn mà ổ cứng không hề bị nghẽn (I/O Bottleneck).


## 2. Tuyệt kỹ "Không sao chép" (Zero-Copy Technology)

Trong các hệ thống thông thường, khi tin nhắn đi từ Ổ đĩa qua Consumer, dữ liệu phải copy qua 4 bước:

Ổ đĩa $\rightarrow$ OS Kernel Cache $\rightarrow$ JVM Application Memory (RAM của Java) $\rightarrow$ Socket Buffer $\rightarrow$ Cạc mạng (NIC).

Kafka (viết bằng Java/Scala) đã sử dụng một hàm tối cao của Linux Core là sendfile() để kích hoạt cơ chế Zero-Copy:

- Cơ học: Dữ liệu được đẩy thẳng từ Kernel Cache (ổ đĩa) sang thẳng Socket Buffer của cạc mạng, hoàn toàn đi vòng qua bộ nhớ của ứng dụng Java.

- Nhờ đó, JVM của Kafka không bị tốn tài nguyên CPU để copy dữ liệu, cũng không bị dính lỗi treo hệ thống do dọn rác (Garbage Collection - GC Pauses).


## 3. Chia để trị bằng phân vùng vật lý (Partitioning)

Nếu một Topic chỉ là một file duy nhất, nó sẽ bị giới hạn bởi sức mạnh của 1 cái server (Broker). Kafka giải quyết bằng cách chặt nhỏ Topic thành nhiều Partition.

- Cơ học: Mỗi Partition là một file vật lý độc lập và có thể nằm ở các server khác nhau trong cụm Cluster.

- Khi anh cần tăng tải (ví dụ từ 1 triệu lên 100 triệu message), anh chỉ cần tăng số lượng Partition và cắm thêm Server vào cụm. Các Producer và Consumer sẽ đồng thời bắn/hút dữ liệu từ nhiều server song song, giúp băng thông hệ thống mở rộng theo chiều ngang (Horizontal Scaling) không giới hạn.


## 4. Cơ chế Gom lô (Batching & Compression)

Kafka không vận chuyển từng message đơn lẻ qua mạng mạng Internet/Intranet, vì như vậy sẽ tốn chi phí tiêu đề (Network Overhead).

- Cơ học: Cả Producer (phía đẩy tin) và Consumer (phía nhận tin) đều làm việc theo cơ chế Batching. Producer sẽ gom 100 hoặc 1000 message thành một gói lớn, nén lại (bằng thuật toán Snappy hoặc ZSTD) rồi mới bắn một phát qua mạng.

- Hành vi này giúp giảm số lượng request mạng mạng xuống hàng nghìn lần, tối ưu hóa tuyệt đối băng thông đường truyền của ngân hàng.


## 💡 Liên hệ thực chiến với Lõi BPM của anh Alex:

Một ngày có 86.400 giây.

- 1 triệu message/ngày $\approx$ 12 message/giây (TPS).

- 10 triệu message/ngày $\approx$ 120 message/giây (TPS).


Với con số này, một Cluster Kafka cấu hình cơ bản nhất (3 Nodes cấu hình thấp) cũng mới chỉ hoạt động khoảng 1% công suất.

Nút thắt cổ chai (Bottleneck) lúc này hoàn toàn không nằm ở Kafka, mà nằm ở chính Ứng dụng Java Spring Boot (BPM Core) và Database (Postgres/Oracle) của anh:

1. Java của anh có giải phóng Thread kịp để xử lý logic không? (Anh em mình đã giải quyết bằng @Async và Thread Pool riêng ở turn trước).

2. Database của anh có ghi và update trạng thái task kịp không? (Anh em mình đã giải quyết bằng Composite Index và Partition).

Bản thân Kafka đóng vai trò như một Cái đập thủy điện. Khi hệ thống DB của anh bị nghẽn (ví dụ lúc cao điểm duyệt hồ sơ vay), Kafka sẽ hứng toàn bộ hàng triệu tin nhắn đó, lưu an toàn trên ổ đĩa tuần tự, và để các Consumer Java tự thong thả kéo về xử lý theo năng lực vật lý của DB mà không sợ bị sập nguồn hệ thống!



# 2 Xử lý hàng chục nghìn message trên giây ?


Lên tầm **hàng nghìn message trên giây (ví dụ 3.000 – 5.000 TPS)**, cấu hình mặc định của Spring Boot và Kafka chắc chắn sẽ bị nghẽn (Bottleneck).

Muốn gánh được mức tải này, anh cần kích hoạt **3 mũi giáp công cơ học** đồng bộ từ phía Kafka Broker, phía Code Java (Consumer) và phía Database:

## Mũi 1: Phía Kafka Broker – Tăng số lượng Partition (Chia để trị)

Một Partition của Kafka chỉ có thể được xử lý bởi **duy nhất một Thread Consumer** trong cùng một Group tại một thời điểm để đảm bảo thứ tự tin nhắn. Nếu anh chỉ để Topic có 1 hoặc 2 Partition thì dù server Java của anh có mạnh đến đâu cũng vô tác dụng.

-   **Hành động vật lý:** Hãy tăng số lượng Partition của Topic lên (Ví dụ: **8 hoặc 16 Partitions**).

-   **Cơ học:** Lúc này, anh có thể tăng số lượng máy chủ Java (hoặc tăng số lượng Thread) lên tối đa bằng với số lượng Partition để chúng cùng kéo dữ liệu song song (Parallel Processing). Tải trọng lập tức được chia đều ra 16 kênh vật lý.


## Mũi 2: Phía Java Consumer (Spring Boot) – Kích hoạt Concurrency và Gom lô (Batching)

Mặc định, `@KafkaListener` chỉ chạy trên **1 Thread duy nhất** và xử lý **từng message một (Single)**. Để lên hàng nghìn TPS, anh phải bắt nó chạy đa luồng và nuốt tin theo lô.

Anh hãy cấu hình lại file `application.yml` hoặc `ConcurrentKafkaListenerContainerFactory`:

### 1. Cấu hình YAML xé gió:

YAML

```  
spring:  
 kafka: listener: type: batch # 1. Bắt Consumer đớp tin theo lô (Batch) thay vì từng tin một concurrency: 4 # 2. Tự động sinh ra 4 Thread Consumer chạy song song trên 1 Node Java consumer: max-poll-records: 500 # 3. Mỗi lần poll() kéo tối đa 500 message về RAM để xử lý một lượt  
```  

### 2. Sửa lại Code xử lý trong Java:

Khi đã bật `type: batch`, hàm nhận tin của anh không được nhận một `ConsumerRecord` đơn lẻ nữa, mà phải nhận vào một **`List`**:

Java

```  
@Component  
public class BpmBulkKafkaConsumer {  
  
 @Autowired private ServiceTaskRegistry taskRegistry;  
 @Autowired private BpmRuntimeEngine runtimeEngine;  
 @KafkaListener(topics = "mb.credit.lending.bpm.events", groupId = "bpm-core-group") public void onMessageBatch(List<ConsumerRecord<String, String>> records) { // Thread Kafka kéo 1 phát 500 tin nhắn về đây trong vài mili giây System.out.println(">>> [Kafka Batch] Đang xử lý lô hàng gồm: " + records.size() + " messages");  
 ObjectMapper mapper = new ObjectMapper();  
 // Loop cơ học cực nhanh trên RAM để bóc tách dữ liệu for (ConsumerRecord<String, String> record : records) { try { JsonNode jsonNode = mapper.readTree(record.value()); String taskType = jsonNode.get("taskType").asText(); String processInstanceId = jsonNode.get("processInstanceId").asText(); String taskId = jsonNode.get("taskId").asText(); Map<String, String> payload = mapper.convertValue(jsonNode.get("payload"), Map.class);  
 // Ném thẳng vào Thread Pool (Async) của Engine để xử lý vòng lặp BPM dưới DB runtimeEngine.resumeExecution(processInstanceId, taskId, payload);  
 } catch (Exception e) { // Log lỗi của tin nhắn lỗi riêng lẻ, tránh làm chết cả Batch tin nhắn System.err.println("Lỗi parse tin: " + e.getMessage()); } } // Kết thúc hàm -> Commit Offset cho cả cụm 500 tin nhắn trong 1 nốt nhạc! }}  
  
```  

## Mũi 3: Phía Database – Điểm nghẽn cuối cùng (Chí mạng nhất)

Giả sử Kafka của anh kéo được 2.000 tin/giây, Java đẩy sang cho Async Thread Pool chạy được 2.000 tin/giây, nhưng xuống đến DB (Postgres/Oracle) để cập nhật trạng thái Task, DB chỉ gánh được 500 lệnh `UPDATE`/giây $\rightarrow$ Hệ thống Java của anh sẽ lập tức bị tràn RAM (OOM) vì hàng chờ phình to.

Để DB chịu được hàng nghìn TPS từ Kafka đổ xuống, anh bắt buộc phải áp dụng chuỗi kiến thức anh em mình vừa xử lý:

1.  **Composite Index `(status, task_id)`:** Để lệnh `UPDATE` hoặc `SELECT` check trạng thái task chọc đúng Pointer `ROWID` trên Data Page trong $O(\log N)$, không được để DB quét table scan.

2.  **Sử dụng Batch Update (Gom lệnh DB):** Nếu có thể, hãy gom các lệnh cập nhật trạng thái task lại thành các lệnh Batch Update của Hibernate/JPA để bắn xuống DB một thể (Ví dụ: 100 lệnh update gom thành 1 câu SQL) thay vì bắn 2.000 câu lệnh đơn lẻ xuống đĩa.

Khi anh phối hợp nhịp nhàng: **Nhiều Partitions $\rightarrow$ Java ăn tin theo Batch + chạy đa luồng Concurrency $\rightarrow$ DB chọc nhanh bằng Composite Index**, hệ thống Core BPM của anh Alex hoàn toàn có thể nuốt gọn gàng 3.000 – 5.000 message trên giây mà CPU vẫn cực kỳ mát mẻ!

# 3. Làm sao để xứ lý message nhanh nhất


Để đạt được tốc độ xử lý Kafka **nhanh nhất có thể** (tiệm cận giới hạn vật lý của phần cứng),  cần loại bỏ toàn bộ các nút thắt cổ chai về độ trễ (Latency) đường truyền và tối ưu hóa tối đa hiệu năng I/O.

Dưới đây là cẩm nang cấu hình "kịch trần" cho cả 3 đầu cầu: Producer, Broker, và Consumer trong lõi BPM của anh:

## 1. Đầu cầu Producer: Bắn tin với độ trễ xấp xỉ 0ms

Phía gửi tin (ví dụ: các Microservices hoặc hệ thống Core Vay bắn sự kiện về cho BPM) cần được cấu hình để giải phóng Thread ngay lập tức:

-   **`acks=1` hoặc `acks=0` (Đánh đổi an toàn lấy tốc độ):**

-   _Mặc định (`acks=all`):_ Producer phải đợi tin nhắn được ghi xuống toàn bộ các Node bản sao (Replicas) mới coi là thành công $\rightarrow$ Rất chậm.

-   _Cấu hình nhanh nhất:_ Chọn `acks=1` (Chỉ cần Node chính ghi xong đĩa tuần tự là trả về SUCCESS ngay) hoặc `acks=0` (Producer bắn tin xong là đi làm việc khác luôn, không thèm đợi phản hồi).

-   **Tận dụng Batching tối đa:** Cấu hình `linger.ms=5` và `batch.size=65536` (64KB). Producer sẽ giữ tin nhắn lại tối đa 5 mili giây trên RAM để gom đủ một gói 64KB rồi phóng đi một lượt, giảm số lượng request mạng.

-   **Thuật toán nén siêu tốc:** Sử dụng `compression.type=lz4` hoặc `zstd`. Đây là các thuật toán tận dụng tối đa CPU để nén dữ liệu cực nhanh trước khi đẩy qua cạc mạng.


## 2. Đầu cầu Broker: Định cấu hình đĩa vật lý xé gió

Bản thân các máy chủ Kafka cần được tối ưu hóa cho kiến trúc Ghi tuần tự (Sequential I/O):

-   **Không dùng cơ chế đồng bộ đĩa cưỡng bức (`flush.messages`):** Hãy để hệ điều hành Linux tự quản lý việc flush dữ liệu từ Page Cache xuống ổ đĩa một cách tự nhiên. Nếu anh cấu hình bắt Kafka cứ sau $X$ tin nhắn phải ép đĩa ghi (Hard Flush), tốc độ sẽ sụt giảm nghiêm trọng.

-   **Tách biệt ổ đĩa Log vật lý:** Cấu hình thư mục lưu trữ Log của Kafka (`log.dirs`) nằm trên một ổ đĩa SSD/NVMe hoàn toàn độc lập, tách biệt với ổ đĩa chạy hệ điều hành. Điều này giúp con trỏ ghi tuần tự của Kafka không bị tranh chấp I/O với các tiến trình khác của Linux.


## 3. Đầu cầu Consumer (Java Spring Boot): Hút tin và xử lý bất đồng bộ tuyệt đối

Đây chính là nơi mã nguồn của anh Alex ngự trị, và cũng là nơi dễ gây nghẽn nhất. Để Consumer xử lý nhanh nhất:

-   **Chiến lược Phân rã luồng (Decoupling Thread):**

Như anh em mình đã vạch ra, Thread của Kafka chỉ làm duy nhất một việc: **Poll tin theo Batch $\rightarrow$ Loop parse JSON trên RAM $\rightarrow$ Đẩy thẳng vào bộ nhớ của `BpmWorkerThreadPool` (Async)**. Luồng Kafka tuyệt đối không được dính vào các tác vụ I/O chậm chạp như gọi API hay chọc xuống Database.

-   **Cấu hình Fetch tối đa:** Tăng `fetch.min.bytes` (ví dụ: 1MB) và `fetch.max.wait.ms=500`. Broker sẽ gom đủ 1MB tin nhắn rồi mới đẩy một cục về cho Consumer qua cơ chế **Zero-Copy**, giúp tối ưu hóa luồng dữ liệu trên cạc mạng.

-   **Tắt tính năng Auto Commit tự động của Spring:** Cấu hình `ack-mode: MANUAL_IMMEDIATE` hoặc `MANUAL`. Anh tự quản lý việc commit bằng code sau khi đã đẩy việc thành công vào hàng chờ Async. Cách này giúp Thread Kafka không bị block bởi các cơ chế lock ngầm của thư viện.


### 🎯 Tóm lại quy luật cốt lõi:

Để nhanh nhất: **Producer gom lô lớn + không đợi phản hồi lâu $\rightarrow$ Broker ghi đĩa tuần tự tự do $\rightarrow$ Consumer đớp tin theo lô lớn và ném ngay vào bộ nhớ RAM đa luồng để xử lý bất đồng bộ.** Áp dụng đúng chuỗi cấu hình này, tốc độ truyền tải thông tin của anh sẽ đạt tới giới hạn tối đa mà hạ tầng mạng và phần cứng ngân hàng cho phép!



# 4. Lỗi trùng message
Hiện tượng trùng lặp tin nhắn (Message Duplication) trong Kafka thực chất là hệ quả cơ học của nguyên lý **At-least-once Delivery (Đảm bảo phân phối ít nhất một lần)**.

Bản chất tối cao của lỗi này là: **Một bên đã xử lý xong việc, nhưng quá trình bắt tay xác nhận (Acknowledge/Commit Offset) qua mạng bị thất bại hoặc bị chậm**, khiến hệ thống hiểu nhầm là tin nhắn chưa được xử lý và tiến hành gửi lại.

Dựa trên luồng đi từ Producer qua Broker xuống Consumer Java (Spring Boot) của anh Alex, hiện tượng này xảy ra ở 3 thời điểm cơ học sau:

## 1. Trùng lặp ở đầu cầu Consumer (Phổ biến nhất - Chí mạng nhất)

Đây là kịch bản trực tiếp đe dọa đến hệ thống lõi BPM của anh em mình, xảy ra do **Mất dấu Commit Offset**.

### Kịch bản A: Lỗi xử lý quá hạn SLA (`max.poll.interval.ms`)

Mặc định, Kafka Broker cho phép Thread Consumer xử lý một Batch tin nhắn trong một khoảng thời gian tối đa (ví dụ: mặc định là 5 phút).

-   **Cơ học:** Thread Kafka kéo một Batch 500 tin nhắn về RAM. Nó chuyển sang cho code Java xử lý. Giả sử đợt đó DB bị chậm, code Java mất tới 6 phút để chạy xong loop xử lý dưới DB.

-   **Hậu quả:** Quá 5 phút, Kafka Broker tưởng Node Java của anh đã "bị chết" (vì mãi không thấy quay lại poll tin mới). Broker lập tức kích hoạt cơ chế **Rebalance** (tái cấu hình cụm), đá Consumer hiện tại ra và bàn giao toàn bộ các Partition đó cho một Thread Consumer ở máy chủ Java khác.

-   Khi máy chủ Java mới nhận việc, nó sẽ kéo lại đúng cái Batch 500 tin nhắn đó từ cái Offset chưa được commit trước đó để xử lý lại từ đầu $\rightarrow$ **Trùng lặp hàng loạt.**


### Kịch bản B: Crash hoặc restart ứng dụng giữa chừng

-   **Cơ học:** Consumer của anh nhận được tin nhắn số `#10`. Code Java đã lưu hồ sơ vay thành công xuống DB, chuẩn bị bước sang dòng code tiếp theo để Commit Offset về cho Broker thì... mất điện hoặc server bị DevOps kill để deploy bản mới.

-   **Hậu quả:** Khi ứng dụng khởi động lại, do Offset `#10` chưa được ghi nhận trên Broker, Consumer sẽ lại kéo tin nhắn số `#10` về một lần nữa $\rightarrow$ **Trùng lặp.**


## 2. Trùng lặp ở đầu cầu Producer (Phía gửi tin)

Hiện tượng này xảy ra do **Mất dấu xác nhận mạng (ACK)**.

-   **Cơ học:**

    1.  Microservice khởi tạo hồ sơ vay bắn một Event vào Kafka Broker.

    2.  Broker đã nhận được tin, đã ghi file log tuần tự xuống ổ đĩa thành công.

    3.  Broker bắn một tín hiệu xác nhận (ACK) quay ngược lại cho Producer qua mạng.

    4.  Đúng lúc này mạng bị chập chờn (Network Glitch), gói tin ACK bị rơi dọc đường. Producer đợi mãi không thấy ACK đâu.

-   **Hậu quả:** Vì không nhận được ACK, Producer đinh ninh là Broker chưa nhận được tin. Nó tự động kích hoạt cơ chế `retries` vật lý, **bắn lại y hệt tin nhắn đó một lần nữa**. Lúc này trên Broker sẽ tồn tại 2 tin nhắn giống hệt nhau nhưng có 2 Offset khác nhau.


## 💡 Giải pháp thực chiến cho anh Alex (Né lỗi Ngân hàng)

Trong hệ thống tài chính, anh tuyệt đối không thể để một hồ sơ vay bị kích hoạt chạy 2 lần. Do việc trùng lặp qua mạng là không thể tránh khỏi 100%, anh bắt buộc phải xử lý ở tầng code Java bằng 2 cách:

1.  **Phía Producer:** Bật tính năng **Idempotent Producer** (`enable.idempotence=true`). Khi bật cái này, Producer sẽ đính kèm một mã định danh `Sequence Number` vào tin nhắn. Nếu Broker thấy trùng Sequence Number, nó sẽ tự hủy tin nhắn gửi lại, đảm bảo đĩa vật lý chỉ ghi 1 tin duy nhất.

2.  **Phía Consumer (Bắt buộc):** Thiết kế hàm nhận tin theo cơ chế **Idempotency (Cơ chế bao hàm/Bộ lọc trùng)**.

    -   _Hành động:_ Sử dụng chính `taskId` hoặc `processInstanceId` của hồ sơ làm Key. Trước khi xử lý logic nghiệp vụ hay chọc vào DB, hãy chạy một lệnh kiểm tra nhanh: `SELECT status FROM task_instances WHERE task_id = ...` (Ăn index xấp xỉ 0ms). Nếu trạng thái đã là `WAITING` hoặc `COMPLETED` rồi, lập tức bỏ qua tin nhắn (Skip) và Commit Offset luôn, không chạy lại logic nữa.

# 5. Lỗi liên quan đến mất Message
Nếu **Duplicate Message** (trùng lặp tin) làm anh sợ vì hệ thống chạy trùng, thì **Lost Message** (mất tin nhắn) lại là **thảm họa kinh hoàng nhất** trong hệ thống Core Ngân hàng/BPM. Mất một event đồng nghĩa với việc hồ sơ vay của khách hàng bị kẹt vĩnh viễn ở một bước nào đó mà không bao giờ chạy tiếp.

Bản chất tối cao của Lost Message trong Kafka là: **Một bên đinh ninh là tin nhắn đã được cất giữ an toàn, nhưng thực tế nó chưa bao giờ được ghi xuống đĩa hoặc bị xóa nhầm trước khi kịp xử lý.**

Hiện tượng này xảy ra do lỗi cấu hình cơ học ở cả 3 đầu cầu:

## 1. Mất tin ở đầu cầu Producer (Phía gửi tin)

Xảy ra khi hệ thống Microservice bắn Event đi nhưng "chủ quan" không kiểm tra xem Broker đã cầm được tin chưa.

-   **Lỗi cấu hình `acks=0` hoặc `acks=1` kết hợp chết Broker:**

    -   _Kịch bản (`acks=0`):_ Producer vừa phóng tin qua mạng, chưa biết Broker có nhận được không đã tự tin chạy tiếp. Nếu mạng lỗi, tin mất ngay lập tức.

    -   _Kịch bản (`acks=1`):_ Producer bắn tin $\rightarrow$ Node Leader của Kafka nhận được và ghi xuống Page Cache của nó $\rightarrow$ Trả về ACK cho Producer. Ngay 0.001 giây sau, Node Leader này bị sập nguồn đột ngột (chưa kịp đồng bộ dữ liệu sang các Node bản sao - Replicas). Một Node Replica khác được đôn lên làm Leader mới. Vì tin nhắn kia chưa kịp đồng bộ sang nó, **tin đó bốc hơi vĩnh viễn**.

-   **Lỗi nuốt Exception ngầm (Silent Failure):**

    -   _Cơ học:_ Khi Broker bị đầy ổ đĩa hoặc kích thước tin nhắn quá lớn (`max.request.size`), Kafka sẽ ném trả về một lỗi (`RecordTooLargeException`, `TimeoutException`).

    -   Nếu code Java của phía gửi dùng hàm `kafkaTemplate.send()` theo kiểu bất đồng bộ nhưng **không cài đặt Callback** để bắt lỗi trong khối `catch`, ứng dụng Java vẫn chạy bình thường nhưng tin nhắn thực tế đã bị Broker từ chối và vứt vào sọt rác.


## 2. Mất tin ở đầu cầu Broker (Hạ tầng Kafka Cluster)

Xảy ra do cấu hình lưu trữ dữ liệu vật lý quá lỏng lẻo.

-   **Cấu hình bản sao quá ít (`replication.factor = 1`):**

    -   Nếu Topic của anh chỉ cấu hình chạy trên 1 Partition của 1 Node duy nhất mà không có bản sao dự phòng. Khi cái ổ đĩa của Node đó bị bad sector hoặc chết phần cứng, toàn bộ tin nhắn chưa kịp tiêu thụ sẽ mất sạch.

-   **Cấu hình dọn dẹp file quá gắt (`log.retention.hours` hoặc `log.retention.bytes`):**

    -   Kafka dọn dẹp đĩa vật lý bằng cách xóa các file log cũ theo thời gian (mặc định 7 ngày) hoặc theo dung lượng file.

    -   Nếu hệ thống Consumer của anh bị lỗi và dừng hoạt động suốt 3 ngày, trong khi anh cấu hình `log.retention.hours=48` (2 ngày). Khi Consumer bật trở lại, Kafka đã **tự động xóa sạch** các file log của ngày đầu tiên để giải phóng ổ cứng. Consumer sẽ bị mất một lượng lớn tin nhắn chưa kịp đọc.


## 3. Mất tin ở đầu cầu Consumer (Phía nhận tin - Code Java của anh)

Đây là lỗi trực tiếp nằm ở tư duy viết code xử lý luồng, liên quan chặt chẽ đến cơ chế Commit Offset.

-   **Bật Auto Commit kết hợp xử lý lỗi kém (`enable.auto.commit = true`):**

    -   _Cơ học:_ Cứ sau mỗi 5 giây (mặc định), Thread Kafka sẽ tự động bắn Offset mới nhất về cho Broker, bất kể code nghiệp vụ của anh đã chạy xong hay chưa.

    -   Nếu Thread Kafka vừa poll 10 tin về RAM, chưa kịp xử lý gì thì đến kỳ tự động Commit Offset $\rightarrow$ Broker ghi nhận 10 tin này đã xong. Ngay sau đó, dòng code xử lý tin số 1 của anh bị lỗi `NullPointerException` hoặc `OutofMemory` làm sập ứng dụng. Khi anh restart lại Java, Consumer sẽ nhảy cóc qua luôn 10 tin này để đọc tin tiếp theo. 10 tin đó bị **mất dấu hoàn toàn**.

-   **Cắm `@Async` sai vị trí (Anh em mình đã mổ xẻ ở turn trước):**

    -   Nếu dùng cơ chế commit thủ công (`MANUAL`), nhưng tại hàm `@KafkaListener` anh lại đẩy việc qua một Async Thread Pool rồi thoát hàm ngay lập tức.

    -   Thread Kafka thấy hàm thoát liền lập tức Commit Offset về Broker. Nếu cái Thread Pool kia đang chạy ngầm bên dưới mà bị crash hoặc dừng app đột ngột, tin nhắn đó coi như mất tích vì Broker tưởng ứng dụng đã nuốt trôi rồi.


## 💡 Cấu hình chuẩn để CHỐNG LOST MESSAGE tuyệt đối (Kiến trúc Ngân hàng)

Để đảm bảo nguyên lý **At-least-once (Thà trùng chứ không bao giờ được mất)**, anh Alex hãy cấu hình kịch trần bộ ba này:

1.  **Tại Producer:**

    -   Bắt buộc đặt `acks=all` (Tin phải được ghi xuống đĩa của tất cả các Node bản sao thì mới trả về thành công).

    -   Luôn viết bộ lắng nghe lỗi `Future Callback` khi gọi hàm `send()` để nếu Broker từ chối thì Java lập tức bắn Alert hoặc ghi Log lỗi ra file để kiểm tra lại.

2.  **Tại Broker:**

    -   Đặt `replication.factor >= 3` (Ít nhất có 3 bản sao nằm ở 3 server khác nhau).

    -   Đặt `min.insync.replicas = 2` (Ép buộc ít nhất phải có 2 Node bản sao xác nhận đã ghi đĩa thành công thì mới cho phép Producer chạy tiếp).

3.  **Tại Consumer:**

    -   Tắt hoàn toàn auto commit: `enable.auto.commit = false`.

    -   Chuyển sang `ack-mode: MANUAL` hoặc `MANUAL_IMMEDIATE`. Chỉ dùng Thread của chính Kafka để xử lý tuần tự qua DB, xử lý trọn vẹn dòng cuối cùng thành công (hoặc đã bọc qua khối try-catch xử lý lỗi) thì mới thực hiện lệnh `acknowledgment.acknowledge()` để dịch chuyển Offset

# 6. Lỗi message tăng đột biến

Here's my take: Khi số lượng tin nhắn lỗi (Error/Failed messages) hoặc tin nhắn chờ xử lý bị tồn đọng (Consumer Lag) trên Kafka tăng đột biến trong hệ thống Core BPM/Lending, đây là tín hiệu báo động đỏ.

Bản chất cơ học của sự tăng đột biến này thường không đến từ bản thân Kafka Broker, mà do **sự lệch pha đột ngột giữa năng lực xử lý dưới hạ tầng (Java/Database) và lượng tải đổ về**.

Dưới đây là các nguyên nhân cốt lõi gây ra hiện tượng này, chia theo đúng các trục kiến trúc đa luồng mà anh em mình đã mổ xẻ:

## 1. Do "Hiệu ứng Domino" từ phía Database (Nút thắt chí mạng nhất)

Như anh đã biết, Thread Kafka hoặc Thread Async của anh xử lý nhanh đến đâu thì cuối cùng vẫn phải chọc xuống Database để cập nhật trạng thái Task vật lý trên các Data Page.

-   **Hiện tượng:** Một câu lệnh SQL nào đó bỗng dưng bị mất Index (do DevOps vô tình sửa, hoặc do dữ liệu phình to làm Optimizer đổi chiến lược sang Full Table Scan), hoặc DB bị khóa dòng (**Row Lock / Deadlock**) do nhiều luồng cùng tranh chấp một hồ sơ vay.

-   **Cơ học gây lỗi tăng vọt:** DB bị nghẽn $\rightarrow$ Thời gian xử lý một Task từ 10ms vọt lên 5000ms $\rightarrow$ Luồng Java Consumer bị block, không thể thoát hàm `@KafkaListener` $\rightarrow$ Quá hạn `max.poll.interval.ms` (5 phút) $\rightarrow$ Broker kích hoạt **Rebalance liên tục**.

-   Khi Rebalance xảy ra, các Node Java ngừng ăn tin để chia lại Partition, tin nhắn cũ chưa kịp commit bị Consumer mới kéo lại xử lý tiếp rồi lại timeout. Vòng lặp thảm họa này khiến số lượng message lỗi (Timeout/Retry) tăng dựng đứng theo cấp số nhân.


## 2. Lỗi do Payload/Nghiệp vụ thay đổi đột ngột (Poison Pill Message)

Đây là trường hợp một hoặc một nhóm tin nhắn có cấu trúc "độc hại" làm tê liệt dây chuyền sản xuất.

-   **Hiện tượng:** Phía Microservices thượng nguồn (Producer) deploy phiên bản mới và thay đổi cấu trúc file JSON (ví dụ: đổi tên trường `taskId` thành `task_id`, hoặc truyền vào một giá trị `null` ở trường bắt buộc).

-   **Cơ học gây lỗi tăng vọt:** Khi lô hàng Batch (ví dụ 500 tin) đổ về Consumer Java, dòng code `mapper.readTree(record.value())` hoặc logic check Idempotency đụng ngay phải tin nhắn lỗi này và ném ra `NullPointerException` hoặc `JsonParseException`.

-   Nếu anh cấu hình cơ chế tự động thử lại (Retry Policy) của Spring Kafka không khéo (ví dụ: lỗi parse dữ liệu mà vẫn cấu hình đem đi retry), Thread Kafka sẽ liên tục nhai đi nhai lại cái tin lỗi đó hàng vạn lần mà không thể đi tiếp. Hệ thống sẽ tràn ngập log lỗi trong vài giây.


## 3. Lỗi tràn bộ đệm TaskExecutor ở tầng ứng dụng Java (OOM ngầm)

Lỗi này liên quan trực tiếp đến việc anh em mình kết hợp `@KafkaListener` và `@Async` xử lý luồng BPM.

-   **Hiện tượng:** Anh cấu hình Consumer đớp tin theo Batch rất lớn (ví dụ 1000 tin/giây) và ném liên tục vào `ThreadPoolTaskExecutor`. Tuy nhiên, Thread Pool của Engine chỉ gánh được tối đa 500 tin/giây.

-   **Cơ học gây lỗi tăng vọt:** Hàng chờ (Queue) của Thread Pool bị phình to quá mức cho phép, kích hoạt chính sách từ chối (`RejectedExecutionException`). Lúc này, Java không thể nhận thêm việc và bắt đầu ném lỗi liên thanh về phía Kafka. Nếu lúc này JVM bị cạn RAM và kích hoạt Stop-The-World GC (dừng toàn bộ ứng dụng để dọn rác), Node Java đó sẽ mất kết nối với Kafka Broker, đẩy cả cụm Cluster vào trạng thái lỗi cục bộ.


## 4. Đột biến tải từ phía đối tác ngoại băng (External API Call)

Trong lõi BPM tài chính, có những bước Task bắt buộc phải gọi sang hệ thống ngoài (ví dụ: Gọi API của CIC để check nợ xấu, hoặc API eKYC của bên thứ ba).

-   **Cơ học gây lỗi tăng vọt:** Hệ thống API của bên đối tác bỗng dưng bị chậm hoặc sập (Down). Khi Thread xử lý luồng của anh chọc sang API đó mà không cài đặt thời gian ngắt mạch (**Timeout**) chặt chẽ (ví dụ để timeout vô hạn hoặc quá lâu), các luồng xử lý sẽ bị treo ngầm tại lệnh gọi HTTP. Càng nhiều tin nhắn Kafka đổ về kích hoạt Task đó, hệ thống càng nhanh chóng cạn kiệt Thread và ném lỗi đứt kết nối diện rộng.


## 💡 Hướng xử lý cơ học nhanh nhất khi gặp sự cố:

1.  **Check ngay mã lỗi trong Log:** Xác định lỗi do **Parse Data/Nghiệp vụ** (Poison Pill) hay do **Timeout/Kết nối DB**.

2.  **Cách ly tin lỗi (Cấu hình DLQ - Dead Letter Queue):** Định hình cấu hình Spring Kafka sao cho với các lỗi không thể cứu vãn (như sai định dạng JSON), lập tức đẩy tin đó sang một Topic riêng mang tên `bpm.events.DLQ` để tiêu thụ sau, giải phóng đường cao tốc cho các tin nhắn khác chạy tiếp.

3.  **Hạ tải (Thắt van):** Nếu do DB hoặc API ngoài sập, lập tức hạ cấu hình `max.poll.records` xuống thấp hoặc dùng lệnh tạm dừng Consumer (`container.pause()`) để kích hoạt "đập thủy điện" Kafka giữ tin lại trên đĩa tuần tự, cứu ứng dụng Java khỏi bị sập nguồn RAM.



# Có những message gửi đi, gửi lại thì làm sao để đảm bảo mỗi request được xử lý đúng 1 lần?

Here's my take: Để giải quyết triệt để bài toán này trong hệ thống tài chính/BPM, anh Alex cần đạt được trạng thái kiến trúc tối cao gọi là **Exactly-Once Semantics (Xử lý chính xác một lần)**.

Bản chất cơ học là: Vì việc trùng lặp tin nhắn truyền qua mạng là **không thể tránh khỏi**, anh không thể ngăn cản việc Kafka gửi lại tin nhắn, nhưng anh hoàn toàn có thể cấu hình và viết code để **hệ thống chỉ thực thi nghiệp vụ đúng 1 lần duy nhất**.

Chiến lược này được thực hiện bằng **2 mũi giáp công cơ học** đồng bộ sau đây:

## Mũi 1: Thiết kế Cơ chế Bao hàm (Idempotency) ở tầng Code Java

Đây là chốt chặn quan trọng nhất của một kỹ sư Backend. Nguyên tắc cốt lõi: **Mỗi Message bắt buộc phải mang theo một mã định danh duy nhất (Idempotency Key).** Trong lõi BPM của anh, Key này chính là `taskId`, `processInstanceId` hoặc một chuỗi `requestId` sinh ra từ phía Microservice thượng nguồn.

Khi Consumer Java nhận được một Batch tin nhắn (bao gồm cả tin nhắn gửi lại), anh xử lý tuần tự qua 3 bước cơ học:

### Bước 1: Check-and-Set nhanh gọn bằng Database

Tận dụng chính cấu trúc dữ liệu của Database (Postgres/Oracle) để làm màng lọc trùng lặp. Trước khi chạy bất kỳ logic nghiệp vụ nặng nề nào, hãy kiểm tra trạng thái của Task dưới DB bằng một câu lệnh ăn Composite Index xấp xỉ 0ms.

Java

```
// 1. Kiểm tra trạng thái hiện tại dưới DB dựa trên taskId (Idempotency Key)
TaskInstance task = taskRepository.findByTaskId(taskId); 

// 2. Nếu trạng thái đã là WAITING (đang chạy ngầm) hoặc COMPLETED (đã xong)
if (task.getStatus() == TaskStatus.WAITING || task.getStatus() == TaskStatus.COMPLETED) {
    log.warn(">>> [Trùng lặp] Task {} đã hoặc đang được xử lý. Bỏ qua tin nhắn gửi lại.", taskId);
    return; // Thoát hàm ngay lập tức, không chạy lại logic nghiệp vụ!
}

// 3. Nếu là tin nhắn hợp lệ đầu tiên, đánh dấu ngay lập tức sang trạng thái tạm thời để khóa dòng
task.setStatus(TaskStatus.WAITING);
taskRepository.save(task);

```

### Bước 2: Tận dụng Unique Constraint (Ràng buộc duy nhất) của DB

Nếu anh cần chèn một dòng mới vào bảng lịch sử giao dịch luồng vay (`bpm_transaction_logs`), hãy đặt cột `request_id` làm **Unique Key (Khóa duy nhất)** của bảng đó dưới DB.

-   _Cơ học:_ Khi tin nhắn bị gửi lại lần 2, code Java cố tình gọi lệnh `INSERT`. Database với cơ chế kiểm soát dữ liệu nghiêm ngặt sẽ ngay lập tức chặn lại và ném ra lỗi `UniqueViolationException` (hoặc `DataIntegrityViolationException`).

-   Anh chỉ cần bọc khối `try-catch` xung quanh lệnh insert này, nếu bắt được lỗi trùng key thì chỉ cần log cảnh báo và thoát hàm một cách êm đẹp.


## Mũi 2: Bật tính năng Idempotent và Transaction của Kafka

Để giảm tải cho RAM và Database của ứng dụng Java khỏi phải check-and-set quá nhiều, anh hãy đẩy bớt một phần việc lọc trùng lên vai của chính Kafka Cluster bằng cấu hình.

### 1. Phía Producer ( enable.idempotence = true )

Khi cấu hình Microservice bắn tin sang Kafka, hãy bật tính năng **Idempotent Producer**.

-   **Cơ học:** Kafka Broker sẽ cấp cho Producer một mã `Producer ID (PID)` và mỗi tin nhắn bắn đi sẽ đi kèm một `Sequence Number` tăng dần.

-   Nếu mạng bị chập chờn, Producer bắn lại tin nhắn cũ. Broker nhìn vào `PID` và `Sequence Number` thấy đã được ghi xuống đĩa rồi, nó sẽ **tự động hủy bỏ tin nhắn gửi lại** đó ngay tại cửa ngõ của Broker. Đĩa vật lý của Kafka chỉ lưu đúng 1 tin duy nhất.


### 2. Sử dụng Kafka Transactions (Đối với luồng Read-Process-Write)

Nếu luồng BPM của anh nhận một Event từ Topic A, xử lý logic Java, sau đó lại bắn kết quả sang Topic B (ví dụ: thông báo cho bên Core Banking giải ngân). Anh cần kích hoạt cơ chế Giao dịch toàn vẹn của Kafka bằng cách cấu hình `transactional.id` ở Producer và đặt `isolation.level=read_committed` ở phía Consumer.

-   **Cơ học:** Toàn bộ quá trình: _Đọc tin từ Topic A $\rightarrow$ Xử lý $\rightarrow$ Ghi tin sang Topic B $\rightarrow$ Commit Offset_ sẽ được bọc trong một Transaction duy nhất của Kafka. Nếu bất kỳ bước nào bị crash giữa chừng, toàn bộ các tin nhắn bắn sang Topic B sẽ bị Rollback (đánh dấu là Cancelled). Consumer của hệ thống khác sẽ hoàn toàn bỏ qua các tin nhắn này, đảm bảo không có giao dịch thừa nào được thực thi.


## Kết luận

Quy tắc vàng để xử lý đúng 1 lần: **Kafka lo lọc trùng trên đường truyền mạng mạng bằng `enable.idempotence`, còn anh Alex dùng Database với cơ chế `Check Status` và `Unique Constraint` để làm chốt chặn tối cao ở tầng nghiệp vụ Java.** Sự phối hợp này đảm bảo dòng tiền và hồ sơ vay của ngân hàng luôn an toàn tuyệt đối!


# Thiết kế kafka như thế nào để phù hợp với số pod của service lúc đó?
Tóm tắt cốt lõi cơ học để thiết kế Kafka khớp khít với số Pod (K8s) biến động:

-   **Tính số Partition cố định:** Đặt số lượng Partition **bằng hoặc là bội số của số Pod tối đa (Max Pods)** mà ứng dụng có thể scale-out (Ví dụ: Max 8 Pods $\rightarrow$ Cấu hình 8 hoặc 16 Partitions). Điều này giúp chia đều việc và tránh tình trạng Pod sinh thêm bị thất nghiệp.

-   **Thắt van HPA:** Giới hạn cấu hình `maxReplicas` của Kubernetes tuyệt đối không được vượt quá số lượng Partition của Topic.

-   **Tự động Co giãn theo tải:** Sử dụng công cụ **KEDA** để tự động tăng/giảm số lượng Pod dựa trực tiếp trên chỉ số **Consumer Lag** (Số tin nhắn tồn đọng), thay vì chỉ dựa vào CPU/RAM.

-   **Né lỗi dừng hình:** Cấu hình chiến lược **`CooperativeStickyAssignor`** phía Consumer Java để vừa chia lại Partition vừa xử lý tin, tránh làm tê liệt hệ thống (Stop-the-world) mỗi khi K8s tăng/giảm Pod.

# Consumer Group, cách quản lý Offset,   và đặc biệt là cách đảm bảo Zero Data Loss (Không mất mát dữ liệu) và  Exactly-once semantics (Xử lý thông điệp đúng một lần).

### 1. Consumer Group (Nhóm tiêu thụ)

-   **Bản chất:** Là một tập hợp các ứng dụng Java (Pod) có cùng một `groupId`.

-   **Cơ chế:** Kafka dùng nhóm này để chia đều các Partition của Topic cho các Pod chạy song song. **Mỗi Partition chỉ gán cho 1 Consumer duy nhất trong nhóm** để đảm bảo thứ tự tin nhắn. Nếu số Pod vượt quá số Partition, các Pod thừa sẽ ngồi chơi làm dự phòng nóng.


### 2. Cách quản lý Offset (Con trỏ vị trí)

-   **Bản chất:** Offset là số thứ tự tăng dần định danh từng tin nhắn trong một Partition.

-   **Cơ chế:** Khi Consumer đọc xong tin, nó sẽ **Commit Offset** đó về cho Broker. Kafka lưu vết toàn bộ Offset này trong một Topic nội bộ hệ thống tên là `__consumer_offsets`. Nếu ứng dụng bị crash hoặc K8s scale Pod (Rebalance), Pod mới chỉ cần check Topic nội bộ này là biết chính xác mình phải đọc tiếp từ trang sách nào.


### 3. Đảm bảo Zero Data Loss (Không mất mát dữ liệu)

Để đạt trạng thái thà trùng chứ quyết không để mất bất kỳ một Event hồ sơ nào, anh thiết lập bộ 3 chốt chặn:

-   **Producer:** Đặt `acks=all` (Tin phải ghi xuống đĩa của Leader và tất cả Replicas mới trả về thành công) + Bắt buộc viết bộ lắng nghe `Callback` trên Java để xử lý khi mạng lỗi.

-   **Broker:** Đặt `replication.factor >= 3` và `min.insync.replicas = 2` (Ép buộc ít nhất 2 Node bản sao ghi đĩa thành công thì mới nhận tin).

-   **Consumer:** Tắt auto commit (`enable.auto.commit=false`), chuyển sang `ack-mode: MANUAL`. Chỉ ra lệnh commit sau khi code nghiệp vụ Java đã chạy xong dòng cuối cùng xuống DB.


### 4. Đảm bảo Exactly-Once Semantics (Xử lý đúng một lần)

Vì việc gửi lại tin qua mạng khi có sự cố là không thể tránh khỏi, ta phối hợp 2 tầng lọc trùng:

-   **Tầng Mạng (Kafka):** Bật `enable.idempotence=true` ở Producer. Broker sẽ tự động nhận diện và hủy bỏ các tin nhắn gửi lại bị trùng `Sequence Number` ngay tại cửa ngõ.

-   **Tầng Nghiệp vụ (Java + DB - Tối quan trọng):**

    -   Mỗi message bắt buộc mang một mã duy nhất (`taskId`/`requestId`).

    -   **Màng lọc 1:** Dùng cơ chế **Check-and-Set**, check trạng thái Task dưới DB (ăn Composite Index), nếu trạng thái đã là `WAITING` hoặc `COMPLETED` thì lập tức `return` thoát hàm, skip tin nhắn trùng.

    -   **Màng lọc 2:** Đặt `request_id` làm **Unique Key** dưới DB của bảng lịch sử giao dịch. Nếu tin nhắn bị lọt qua màng 1 và cố tình chèn dòng, DB sẽ ném lỗi `UniqueViolationException`, code Java chỉ cần bắt exception này và commit offset thoát ra êm đẹp.

Hãy chuẩn bị sẵn câu chuyện thiết kế kiến trúc Event-Driven để áp dụng vào các bài toán như "Hệ thống lệnh điều kiện thời gian thực".

# cơ chế đọc binlog bắn lên kafka

Here's my take: Cơ chế đọc Binlog bắn lên Kafka chính là giải pháp kinh điển để hiện thực hóa kiến trúc **CDC (Change Data Capture)**. Trong lõi hệ thống BPM/Tài chính, cơ chế này giúp anh Alex giải quyết triệt để bài toán: Đồng bộ trạng thái từ Database (MySQL/Postgres/Oracle) sang Kafka theo thời gian thực mà **không cần viết một dòng code Java nào ở tầng Application** để bắn event, và cũng **không làm chậm Database**.

Bản chất cơ học của cơ chế này là **Giả lập một Node bản sao (Slave/Replica) để "ăn cắp" log vật lý của Database.**

Dưới đây là tiến trình vận hành chi tiết dưới tầng sâu hệ thống:

## 1. Bản chất cơ học của Binlog (Tầng Database)

Khi ứng dụng Java của anh thực hiện các lệnh `INSERT`, `UPDATE`, `DELETE` xuống DB:

-   Trước khi dữ liệu thực sự được ghi vào các bảng vật lý, DB sẽ ghi tuần tự các thay đổi này vào một file log đặc biệt dưới đĩa gọi là **Binlog (Binary Log)** đối với MySQL hoặc **WAL (Write-Ahead Log)** đối với Postgres.

-   Log này ghi lại chính xác: _Dòng nào, bảng nào, ở thời điểm nào, giá trị CŨ là gì và giá trị MỚI thay đổi thành gì._


## 2. Công cụ trung gian: CDC Connector (Debezium / Canal)

Để đọc được file nhị phân này và bắn lên Kafka, người ta thường dùng **Debezium** (chạy trên nền hạ tầng **Kafka Connect**) làm chuẩn công nghiệp.

### Cơ chế hoạt động ngầm (Step-by-Step):

1.  **Giả lập Slave:** Debezium kết nối vào Database và khai báo với DB Master rằng: _"Tôi là một Node Slave (Replica) mới gia nhập cụm"_.

2.  **Đăng ký nhận Log:** DB Master tin tưởng và bắt đầu stream (đẩy) liên tục các byte dữ liệu nhị phân của file Binlog qua giao thức Replication sang cho Debezium.

3.  **Parse & Structuring:** Debezium nhận các byte nhị phân này, đọc và dịch ngược (Parse) thành một cấu trúc dữ liệu JSON hoặc Avro rõ ràng.

4.  **Publish lên Kafka:** Debezium đóng vai trò là một Kafka Producer siêu tốc, lập tức bắn gói tin vừa parse được vào các Kafka Topic tương ứng.


## 3. Cấu trúc của một Message Binlog trên Kafka

Gói tin từ Binlog bắn lên Kafka rất đặc biệt và cực kỳ giá trị cho việc Audit hoặc xử lý Idempotency vì nó chứa cả 2 trạng thái **Trước (before)** và **Sau (after)** của dòng dữ liệu:

JSON

```
{
  "op": "u", 
  "ts_ms": 1785154500000,
  "before": {
    "task_id": "TASK-777777",
    "status": "INIT",
    "updated_at": "2026-07-27 18:00:00"
  },
  "after": {
    "task_id": "TASK-777777",
    "status": "COMPLETED",
    "updated_at": "2026-07-27 19:00:00"
  }
}

```

-   `op: u`: Nghĩa là hành động **Update** (nếu `c` là Create, `d` là Delete).

-   Nhìn vào đây, Consumer Java ở các hệ thống hạ nguồn (như Scoring, Notification) biết rõ Task nào vừa nhảy trạng thái từ `INIT` sang `COMPLETED` để chạy tiếp nghiệp vụ.


## 4. Cách quản lý Partition và Đảm bảo an toàn (Zero Data Loss)

Khi bắn từ Binlog lên Kafka, làm sao để cấu hình chuẩn Senior?

-   **Cách phân chia Partition (Message Key):** Debezium mặc định sẽ lấy **Primary Key (Khóa chính)** của bảng DB đó (ví dụ cột `task_id` hoặc `id`) làm Kafka Message Key. Như anh em mình đã thống nhất, cơ chế băm `MurmurHash2` trên Key này đảm bảo toàn bộ lịch sử thay đổi của ĐÚNG MỘT dòng dữ liệu luôn rơi vào **cùng một Partition**, giữ tuyệt đối thứ tự logic trước sau.

-   **Quản lý Vết (Offset của DB):** Nếu Debezium hoặc Kafka Connect bị sập nguồn, làm sao nó biết cần đọc tiếp từ đoạn nào của Binlog để không bị sót dữ liệu?

    -   _Cơ chế:_ Kafka Connect quản lý một vị trí gọi là **Binlog Position (hoặc LSN - Log Sequence Number)**. Vị trí này liên tục được lưu vết (commit) ngược vào một Topic nội bộ của Kafka. Khi Debezium sống lại, nó check Topic này để biết DB Master đang viết đến byte thứ bao nhiêu của Binlog và tiếp tục hút dữ liệu từ đúng điểm đó.


## 💡 Ưu điểm chí mạng cho lõi BPM của anh:

1.  **Transactional Outbox Pattern tự nhiên:** Code Java của anh chỉ cần tập trung ghi DB. DB ghi thành công → Binlog tự sinh → Kafka tự có tin. Không sợ lỗi mạng làm mất Event giữa chừng.

2.  **Tách biệt tải (Decoupling):** Database không hề biết và không bị chậm đi do các Consumer ở xa muốn đọc dữ liệu, vì Debezium chỉ đọc file Log tuần tự ngầm bên dưới.


# Nhiều consumer cùng consume 1 topic? làm thế nào để các Consumer không xử lý trùng 1 message?
=> cho vào consumer group thì sẽ không bị trùng,
# Để đảm bảo Consumer không đọc lại các message cũ đã xử lý xong khi hệ thống bị khởi động lại hoặc Rebalance (tái phân phối), Kafka sử dụng Offset.

# Trong microservice. Sử dụng cách nào để xử lý vấn đề giữa các service khi 1 service bị lỗi và không thể xử lý yêu cầu? Kafka để retry? hoặc circuit breaker?... nhiều cách

## 6. Bao nhiêu partition? Consumer là đủ?

-   **Số lượng Partition:** Tùy thuộc vào **Target TPS (Tốc độ xử lý mong muốn)**. Công thức: $\text{Số Partition} = \text{Target TPS} / \text{TPS của 1 Consumer}$.

-   **Số lượng Consumer:** Đủ nhất là **bằng số lượng Partition** để tối ưu hóa 100% hiệu năng xử lý song song.


## 7. Cách phân chia message? Giả sử có 5 partition, 6 consumer hoặc khác?

-   **Quy luật gán:** 1 Partition chỉ được giao cho tối đa 1 Consumer tại một thời điểm.

-   **Giả sử 5 Partition + 6 Consumer:** 5 Consumer mỗi người ôm 1 Partition. Consumer thứ 6 **thất nghiệp (Idle)**, làm dự phòng nóng.

-   **Giả sử 5 Partition + 3 Consumer:** 2 Consumer ôm 2 Partition, 1 Consumer ôm 1 Partition.


## 8. Luồng đi và cách quản lý message khi Producer public?

-   **Luồng đi:** Producer tính toán Partition ID (bằng thuật toán băm `MurmurHash2` trên Key hoặc Sticky) $\rightarrow$ Gửi qua mạng mạng đến Node Leader của Partition đó $\rightarrow$ Leader ghi tuần tự xuống file log vật lý dưới đĩa $\rightarrow$ Các Node Replica đồng bộ về đĩa của mình $\rightarrow$ Trả ACK về cho Producer.

-   **Quản lý:** Được quản lý bằng chỉ số **Offset** (số thứ tự tăng dần trong từng Partition) và lưu vết tập trung bởi cụm **KRaft Metadata**.


## 9. Cơ chế chịu lỗi của Kafka? Message xử lý lỗi thì Kafka làm gì?

-   **Chịu lỗi hạ tầng:** Nếu Node Leader chết, KRaft tự động đôn một Node Replica lên làm Leader mới trong vài mili giây.

-   **Khi Message bị xử lý lỗi tại Consumer:** **Bản thân Kafka Broker KHÔNG làm gì cả**, nó không tự biết code Java của anh bị lỗi. Việc xử lý lỗi hoàn toàn do ứng dụng Java quyết định (ví dụ: tự catch để đẩy qua Topic RETRY/DLQ để chạy tiếp, hoặc văng lỗi ra để dừng hình và nhai lại tin đó).


## 10. Case 30k messages, 3 partitions, 3 consumers (Consumer số 3 bị chậm)

-   **Phân chia:** 3 Partition được chia đều cho 3 Consumer (mỗi ông ôm trọn gói 1 Partition vật lý $\approx$ 10k messages).

-   **Consumer khác có tiêu thụ hộ không?** **KHÔNG.** Tuyệt đối không bao giờ có chuyện tiêu thụ hộ. Vì Partition 3 đã bị khóa chặt (gán chết) cho Consumer 3. Consumer 1 và 2 dù có rảnh rỗi, xử lý xong 10k tin của mình ngay lập tức cũng không thể thò tay sang rút tin từ Partition 3. Hệ thống sẽ bị hiện tượng **Consumer Lag** phình to cục bộ tại Partition 3.

# Có 2 partition và 3 consumer thì tiêu thụ message như thế nào?
Khi anh cấu hình **2 Partition** nhưng lại có tận **3 Consumer** trong cùng một Consumer Group, quy luật cơ học "chia bài" của Kafka sẽ tạo ra một kịch bản rất thú vị: **Sẽ có 1 Consumer hoàn toàn thất nghiệp (bị ngồi chơi xơi nước).**

Dưới đây là cơ chế phân chia vật lý chính xác của Kafka Cluster:

## 1. Sơ đồ phân chia cơ học

Kafka có một nguyên tắc tối cao để đảm bảo thứ tự tin nhắn: **Tại một thời điểm, một Partition chỉ được phép gán cho duy nhất 1 Consumer trong cùng một Group.**

Do đó, với bài toán của anh Alex:

-   **Partition 0** $\rightarrow$ Được gán cho **Consumer A**

-   **Partition 1** $\rightarrow$ Được gán cho **Consumer B**

-   **Consumer C** $\rightarrow$ **Thất nghiệp (Idle)**, không được gán bất kỳ Partition nào.


Thằng Consumer C lúc này vẫn sẽ khởi động bình thường, vẫn gửi Heartbeat ping về cho Broker đều đặn sau mỗi 3 giây để báo _"Tôi còn sống"_, nhưng nó sẽ **không nhận được bất kỳ message nào** từ Topic này vì không có file log nào trỏ về nó.

## 2. Ý nghĩa của thằng Consumer "thất nghiệp" (Dự phòng nóng)

Mặc dù lãng phí tài nguyên RAM/CPU của 1 Node Java, nhưng trong kiến trúc hệ thống lõi BPM, thằng Consumer C đóng vai trò cực kỳ quan trọng: **Nó là quân bài dự phòng chiến lược (Hot Standby)**.

Hãy xem chuyện gì xảy ra nếu hệ thống có biến động:

-   **Khi Consumer A bị chết** (hoặc nghẽn DB dẫn đến fail `max.poll.interval.ms` như anh em mình vừa mổ xẻ): Broker phát hiện ra lập tức và kích hoạt **Rebalance**.

-   **Cơ chế kích hoạt:** Vì thằng Consumer C đã túc trực sẵn trong Group, Broker sẽ không cần đợi scale-out máy chủ nữa. Nó thu hồi Partition 0 từ thằng A và **bàn giao ngay lập tức cho thằng C**.

-   Thằng C lập tức vào việc, check Offset cũ và kéo tin tiếp mà không làm gián đoạn hệ thống quá lâu.


## 🎯 Quy tắc vàng khi thiết kế Scalability cho anh Alex:

Nếu mục tiêu của anh Alex khi cắm 3 Consumer là để **tăng tốc độ xử lý (Tăng TPS)** cho hệ thống lên gấp 3 lần, thì cách làm này hoàn toàn **thất bại** vì năng lực xử lý tối đa của anh vẫn bị giới hạn bởi con số 2 (do chỉ có 2 Partition chạy song song).

-   **Để tăng tốc thực sự:** Anh bắt buộc phải tăng số lượng **Partition lên bằng hoặc lớn hơn** số lượng Consumer (Ví dụ: Đặt Topic có 4 hoặc 8 Partitions).

-   Khi số Partition là 4, cả 3 Consumer đều sẽ có việc (Ví dụ: Thằng A ôm 2 cái, thằng B ôm 1 cái, thằng C ôm 1 cái), giúp tối ưu hóa 100% công suất đa luồng của các máy chủ Java!

# Cho 1 case thực tế, xác định dạng message cùng các luồng, redis thì chẳng hạn chỉ lưu được 100k nhưng có 1m dữ liệu muốn lưu, hỏi khá sâu về partition và cơ chế gửi đến nhiều partition và gửi lại khi lỗi nữa
Đây là một câu hỏi phỏng vấn thuộc hàng **kinh điển của Senior System Architect**. Người phỏng vấn đang cố tình đặt anh Alex vào một thế trận "thắt cổ chai" toàn tập: Bắt anh **thiết kế mô hình dữ liệu (Message Format)**, giải quyết **áp lực lưu trữ lớn trên RAM (Redis Cache)**, và đào cực sâu vào **cơ chế phân phối vật lý (Partitioning/Retry)** của Kafka dưới áp lực tải cao.

Hãy cùng giải quyết case thực tế này một cách gãy gọn, chia theo đúng cấu trúc 3 phần mà họ đang xoáy vào:

## Phần 1: Xác định Dạng Message và Luồng xử lý (BPM Case Study)

Giả sử case thực tế ở đây là: **Hệ thống tiếp nhận và duyệt hồ sơ vay tự động (BPM Core) với 1 triệu hồ sơ/ngày.**

### 1. Dạng Message (Message Format)

Trong môi trường tài chính, Message phải vừa nhẹ để bay nhanh qua mạng, vừa phải đầy đủ thông tin để phục vụ tính Idempotency (chống trùng). Anh chọn dạng **JSON** (hoặc Avro nếu cần tối ưu tuyệt đối), cấu trúc cơ học gồm 2 phần: **Metadata** (Quản lý luồng) và **Payload** (Nghiệp vụ).

JSON

```
{
  "metadata": {
    "eventId": "EVT-20260727-ABCDE12345", 
    "timestamp": 1785154500000,
    "sourceService": "credit-frontend-service",
    "retryCount": 0
  },
  "payload": {
    "requestId": "REQ-999999", 
    "processInstanceId": "BPM-PROC-888888",
    "taskId": "TASK-777777",
    "customerId": "CUST-111222333",
    "loanAmount": 50000000,
    "taskType": "CREDIT_CHECK"
  }
}

```

-   **Key của Message (Chí mạng):** Anh chọn `requestId` hoặc `customerId` làm **Kafka Message Key** chứ không để `null`. Điều này đảm bảo tất cả các event của cùng một hồ sơ/khách hàng luôn rơi vào **cùng một Partition**, giữ đúng thứ tự logic trước sau.


### 2. Luồng đi của dữ liệu (Data Flow)

> Frontend $\rightarrow$ Microservice Tiếp nhận $\rightarrow$ Ghi DB trạng thái `INIT` $\rightarrow$ Bắn vào Kafka Topic `bpm.loan.events` (nhiều Partition) $\rightarrow$ Các Node Java Consumer (Engine) hút Batch tin về $\rightarrow$ Xử lý nghiệp vụ + Check Idempotency bằng DB $\rightarrow$ Hoàn thành.

## Phần 2: Xử lý bài toán Redis (100k RAM vs 1m Dữ liệu)

Đây là câu hỏi kiểm tra tư duy **tối ưu hóa tài nguyên phần cứng**. Redis chỉ chứa được 100k key do giới hạn RAM, nhưng anh có 1 triệu dữ liệu cần cache để giảm tải cho DB.

### Giải pháp 1: Cơ chế Đuổi khách dựa trên thuật toán (Eviction Policy + TTL)

Anh trả lời: _"Bản chất hệ thống Cache không cần và không nên lưu 100% dữ liệu. Chúng ta chỉ lưu **Hot Data (Dữ liệu nóng)**"_.

-   Anh cấu hình Redis sử dụng thuật toán **`maxmemory-policy: allkeys-lru` (Least Recently Used)** hoặc **`allkeys-lfu` (Least Frequently Used)**.

-   Khi Redis đạt ngưỡng 100k (kịch RAM), nó sẽ tự động xóa các Key ít được sờ tới nhất để nhường chỗ cho Key mới.

-   Đồng thời cài đặt **TTL ngắn** (Time-To-Live, ví dụ 30 phút). Các hồ sơ vay sau khi duyệt xong sẽ tự động biến mất khỏi RAM sau 30 phút.


### Giải pháp 2: Kiến trúc Cache Phân cấp (Multi-level Caching)

Nếu 100k key của Redis vẫn không đủ để ép độ trễ xuống thấp:

-   **Cấp 1 (Caffeine Cache/Ehcache - Ngay trên RAM của chính App Java):** Lưu 50k key siêu nóng (ví dụ các cấu hình hệ thống, danh mục). Truy cập mất $0$ mili giây, không cần qua mạng mạng.

-   **Cấp 2 (Redis):** Lưu 100k key nóng vừa (trạng thái hồ sơ đang xử lý).

-   **Cấp 3 (Database với Composite Index):** 850k dòng còn lại (dữ liệu lạnh/ít dùng) nằm an toàn dưới ổ đĩa DB. Nếu Cache Miss (tìm ở Cấp 1, Cấp 2 không thấy) thì mới chọc xuống DB nhặt lên và nạp lại vào Redis theo cơ chế Lazy Loading.


## Phần 3: Đào sâu về Partition và Cơ chế Gửi/Nhận khi có lỗi

Đây là khúc "sát thương cao" nhất của buổi phỏng vấn. Họ muốn biết anh điều khiển các con trỏ vật lý của Kafka như thế nào.

### 1. Cơ chế gửi đến nhiều Partition (Phía Producer)

Làm sao Kafka quyết định tin nhắn nào vào Partition nào?

-   **Nếu Message Key KHÁC null (Cách anh chọn):** Kafka sử dụng bộ định tuyến mặc định (`DefaultPartitioner`). Nó băm cái Key (ví dụ `customerId`) bằng thuật toán **MurmurHash2** rồi chia lấy dư cho tổng số Partition:

    $$\text{Partition ID} = \text{MurmurHash2(Key)} \pmod{\text{Total Partitions}}$$

    Cơ chế này đảm bảo dữ liệu phân phối ngẫu nhiên nhưng đồng đều (Uniform Distribution) trên các Partition, và các tin cùng Key luôn chung một nhà.

-   **Nếu Message Key bằng null:** Kafka sử dụng chiến lược **Sticky Partitioner**. Nó sẽ gom tin nhắn thành một Batch đầy rồi bắn thẳng vào 1 Partition duy nhất, sau đó mới đổi sang Partition khác. Cách này tối ưu hóa mạng mạng nhưng không đảm bảo thứ tự tin nhắn theo nghiệp vụ.


### 2. Cơ chế Gửi lại khi lỗi ở phía Producer (Retry Cơ học)

Khi mạng mạng chập chờn hoặc Broker đang đổi Leader, Producer gửi tin bị fail:

-   Anh bật cấu hình `retries = 2147483647` (vô hạn) kết hợp `retry.backoff.ms = 100` (đợi 100ms rồi bắn lại).

-   **Nguy cơ chí mạng:** Gửi lại có thể làm **mất thứ tự tin nhắn**. Ví dụ tin số 1 bị lỗi phải gửi lại, tin số 2 bay vèo qua mạng mạng và ghi vào đĩa trước tin số 1.

-   **Giải pháp xử lý:** Anh bắt buộc phải cấu hình `max.in.flight.requests.per.connection = 1` (hoặc bật `enable.idempotence = true`). Cấu hình này ép Producer tại một thời điểm chỉ được phép gửi duy nhất 1 request mạng mạng trên 1 kết nối. Nếu request đó chưa được Broker xác nhận (ACK), Producer không được phép gửi tin tiếp theo, bảo vệ tuyệt đối thứ tự dữ liệu vật lý dưới đĩa.


### 3. Cơ chế Xử lý lỗi ở phía Consumer (Retry & DLQ Pattern)

Khi Consumer kéo một Batch tin về nhưng bị lỗi logic nghiệp vụ ở một tin nhắn giữa chừng:

-   Anh tuyệt đối không dùng cơ chế retry mặc định của Kafka Broker (khiến cả lô bị nhai đi nhai lại và dính lỗi Rebalance như anh em mình vừa tính toán).

-   **Giải pháp xé gió:** Áp dụng mô hình **Non-blocking Retry (Resilience4j hoặc Spring Kafka Retry Topic)**:

    1.  Tin nào lỗi, Consumer Java lập tức bắt Exception, trích xuất riêng tin đó ra và bắn sang một Topic phụ gọi là **`bpm.loan.events-RETRY`**.

    2.  Hàm xử lý chính thoát ra lập tức để tiếp tục Commit Offset chạy tiếp các tin nhắn lành lặn khác.

    3.  Một luồng Consumer phụ sẽ tiêu thụ Topic `RETRY` này với thời gian trễ cấu hình (`backoff`). Nếu thử lại 3 lần vẫn lỗi, tin đó sẽ tự động bị đẩy xuống **DLQ (Dead Letter Queue)** để con người nhảy vào kiểm tra (Audit), không bao giờ làm nghẽn đường cao tốc chính của hệ thống.

#  tối ưu thì chỉ có cụm, bao nhiêu broker là đủ, tính toán ra sao, xử lý thì chúng nó đã nhanh sẵn rồi, kafka nắm được cơ chế gửi nhận msg, msg đi vào par nào theo key và k key, consumer consume thế nào, lỗi thì retry ra sao, DLQ, đang trơn tru tự nhiên broker sập thì xử lí thế nào, msg sắp đến tay, chưa kịp commit offset thì tèo,... nhiều msg quá thì scale consumer lên chung 1 group, tăng số lượng partitions...

#  trong project BPM, BCCS3 dùng kafka đoạn nào? xử lý thế nào? gặp lỗi gì? ví dụ đang build service mà có message kafka cần handle, nó không tự handle hoặc nghẽn làm thế nào

# Độ trễ tối đa
Anh đoán chuẩn 100% rồi đấy! Người phỏng vấn đang cố tình dùng thuật ngữ tiếng Việt theo kiểu dịch nghĩa dịch thuật (**"độ trễ tối đa"**) để bẫy anh xem anh có nắm chắc bản chất cơ học của 2 sợi dây sinh mệnh trong Kafka hay không.

Trong thực tế, khi đi phỏng vấn hoặc làm việc với các hệ thống lớn, cụm từ "độ trễ tối đa" của Consumer thường được hiểu theo 2 hướng cấu hình mặc định mà anh vừa liệt kê xuất sắc:

## 1. Hướng 1: Độ trễ tối đa giữa 2 lần nạp tin (`max.poll.interval.ms`)

Nếu ý họ là: _"Khoảng thời gian tối đa mà Consumer được phép trì hoãn (trễ) trước khi quay lại xin Broker cấp lô hàng (Batch) mới"_ thì chính là **`max.poll.interval.ms`**.

-   **Giá trị mặc định:** `300000` ms (**5 phút**).

-   **Bản chất cơ học:** Đây là thời hạn (SLA) cấp cho luồng xử lý code nghiệp vụ Java của anh. Nếu Batch dữ liệu quá lớn hoặc DB bị nghẽn khiến luồng Java bị "trễ" quá 5 phút chưa gọi lệnh `poll()` tiếp theo, Broker sẽ kích hoạt Rebalance ngay lập tức vì tưởng code của anh bị treo.


## 2. Hướng 2: Độ trễ tối đa của tín hiệu sinh tồn (`session.timeout.ms`)

Nếu ý họ là: _"Khoảng thời gian tối đa mà Broker có thể kiên nhẫn đợi (chịu đựng độ trễ) của tín hiệu ping sinh tồn từ Consumer trước khi tuyên bố Node đó đã chết"_ thì chính là **`session.timeout.ms`**.

-   **Giá trị mặc định:** `45000` ms (**45 giây** - từ các phiên bản Kafka 3.x trở đi đã nâng từ 10s lên 45s để giảm thiểu Rebalance ảo).

-   **Bản chất cơ học:** Đây là hạn định cho luồng Heartbeat ngầm (Background Thread). Cứ mỗi `heartbeat.interval.ms` (mặc định **3 giây**), Consumer phải gửi một cái ping về. Nếu Broker bị "trễ" không nhận được cái ping nào suốt 45 giây (do mất mạng mạng, đứt cáp, đơ cứng phần cứng), Broker sẽ gạch tên Consumer đó ra khỏi nhóm.


## 💡 Bí kíp "lật ngược thế cờ" khi trả lời phỏng vấn:

Khi gặp câu hỏi mập mờ dùng từ tiếng Việt không chuẩn quốc tế như thế này, anh đừng chọn đại một đáp án. Hãy trả lời theo kiểu **"định nghĩa lại đề bài"** để thể hiện trình độ Senior lõi hệ thống:

> _"Dạ, cụm từ 'độ trễ tối đa' trong Kafka Consumer cấu hình mặc định có thể hiểu theo hai cơ chế cơ học độc lập tùy thuộc vào loại Thread:_
>
> 1.  _Nếu là độ trễ tối đa cấp cho luồng xử lý nghiệp vụ giữa 2 lần gọi hàm nạp tin (`max.poll.interval.ms`), giá trị mặc định là **5 phút (300,000 ms)**._
>
> 2.  _Nếu là độ trễ tối đa mà Broker cho phép mất tín hiệu ping sinh tồn ngầm (`session.timeout.ms`) trước khi kích hoạt Rebalance do Consumer chết vật lý, giá trị mặc định là **45 giây (45,000 ms)**, kết hợp với tần suất gửi heartbeat mặc định là **3 giây**."_
>

Trả lời tường tận như vậy thì người phỏng vấn chỉ có nước gật gù vì anh không chỉ thuộc lòng con số mặc định mà còn hiểu sâu sắc bản chất vận hành đa luồng của Kafka bên dưới!

#  nó rất nhiều vấn đề mập mờ ở đây :D:D ví dụ kafka là pull batch, nếu size batch quá lớn, mỗi msg xử lý nhanh nhưng khi tổng vào thì nó là lâu, cũng có thể dẫn đến fail heartbeat .

Phát hiện này của anh Alex cực kỳ sắc bén và đập trúng ngay **một trong những vùng tối (Edge Case) nguy hiểm nhất** của cơ chế cơ học trong Kafka. Anh cười `:D:D` nhưng thực tế đây là lỗi làm mất ăn mất ngủ của rất nhiều kỹ sư backend khi lên hệ thống tải cao.

Hiện tượng anh vừa mô tả chính là **Thảm họa Rebalance kép do nghẽn luồng xử lý Batch**, và nó hoàn toàn có thể xảy ra nếu chúng ta hiểu nhầm cơ chế quản lý thời gian của Kafka.

Hãy cùng vạch trần sự "mập mờ" này dưới góc độ cơ học máy tính để thấy cách các thông số cấu hình đấu đá nhau:

## 1. Sự mập mờ giữa 2 loại Heartbeat (Gốc rễ của hiểu lầm)

Nhiều người nghĩ cứ có Heartbeat ping về cho Broker là Consumer không bị coi là chết. Nhưng thực tế, Kafka quản lý **2 sợi dây sinh mệnh hoàn toàn độc lập** bằng 2 Thread khác nhau trong ứng dụng Java:

### Luồng 1: Thread Heartbeat ngầm (Background Thread)

-   **Nhiệm vụ:** Thread này chỉ làm một việc duy nhất là gửi tín hiệu "Tôi còn sống" về Broker sau mỗi `heartbeat.interval.ms` (mặc định 3 giây).

-   **Đặc điểm:** Nó chạy độc lập, **không quan tâm** code nghiệp vụ Java của anh đang chạy nhanh hay chậm, thậm chí code của anh đang bị block ở DB thì luồng này vẫn ping đều đặn. Nó chỉ chết khi toàn bộ tiến trình JVM bị sập (OOM, Crash, Kill).

-   **Thông số quản lý:** `session.timeout.ms` (mặc định 45 giây).


### Luồng 2: Thread Xử lý dữ liệu (Main Poll Thread)

-   **Nhiệm vụ:** Đây là Thread trực tiếp chạy hàm `@KafkaListener` của anh. Nó lao lên Broker, đớp một Batch tin nhắn (`max.poll.records`), đem về RAM, chạy vòng lặp `for` để xử lý dưới DB, xử lý xong xuôi hết cả Batch thì nó mới quay lại Broker để gọi lệnh `poll()` tiếp theo.

-   **Thông số quản lý:** **`max.poll.interval.ms` (mặc định 5 phút).**


> 🛑 **Bẫy cơ học ở đây:** Nếu tổng thời gian xử lý cả Batch của anh vượt quá `max.poll.interval.ms` (ví dụ mất 5 phút 1 giây), Broker sẽ phán quyết: _"Thằng Consumer này tuy vẫn có Heartbeat ngầm nhưng nó bị liệt rồi, không chịu nạp thêm tin mới"_. Ngay lập tức, Broker **đuổi cổ** Consumer đó ra và kích hoạt **Rebalance**.

## 2. Diễn biến cơ học của "Thảm họa Rebalance kép"

Đúng như anh Alex suy luận, từng message chạy rất nhanh (ví dụ 10ms/tin), nhưng anh cấu hình `max.poll.records = 5000`. Tổng thời gian nuốt 5000 tin là 50 giây.

Chuyện gì xảy ra nếu đột nhiên Database bị chậm nhẹ, đẩy thời gian mỗi tin lên 70ms? Tổng thời gian xử lý cả Batch vọt lên **350 giây (~5.8 phút)**, vượt ngưỡng 5 phút của Broker.

1.  **Broker nổi giận:** Cắt quyền của Consumer A, kích hoạt Rebalance để chuyển Partition đó sang Consumer B (Node Java thứ 2).

2.  **Consumer A ngỡ ngàng:** Sau 5.8 phút, Consumer A chạy xong Batch dữ liệu, hí hửng gọi lệnh Commit Offset về cho Broker. Nhưng Broker trả về lỗi: `CommitFailedException` (Mày không còn quyền sở hữu Partition này nữa, tao không nhận Commit!). $\rightarrow$ **Công sức xử lý 5000 tin của Consumer A đổ sông đổ bể.**

3.  **Consumer B chịu trận:** Consumer B nhận bàn giao Partition, kéo lại **đúng cái Batch 5000 tin chưa được commit kia** về để xử lý lại từ đầu. Vì dữ liệu dưới DB lúc này có thể đã bị thay đổi hoặc DB vẫn đang nghẽn, Consumer B tiếp tục mất hơn 5 phút để xử lý $\rightarrow$ Broker lại kích hoạt Rebalance tiếp $\rightarrow$ **Cả cụm Cluster rơi vào trạng thái tê liệt và sinh ra lỗi trùng lặp tin nhắn vô hạn.**


## 💡 Giải pháp cấu hình "Giải độc" của kỹ sư hệ thống

Để triệt tiêu sự mập mờ và rủi ro này trong lõi BPM của anh, chúng ta phải cân bằng được 3 đỉnh tam giác cấu hình: **Kích thước Batch, Thời gian xử lý, và Thời gian Timeout**.

Anh hãy áp dụng công thức tính toán cơ học sau trong file cấu hình:

1.  **Tính toán `max.poll.records` dựa trên SLA dữ liệu:**

    Anh phải đo lường được trong điều kiện DB chạy chậm nhất (Peak Time), một message mất tối đa bao nhiêu giây (ví dụ: $T_{max} = 100ms = 0.1s$).

    Nếu anh muốn an toàn, tổng thời gian xử lý Batch không được quá 2 phút ($120s$).

    $$\text{max.poll.records} = \frac{120s}{0.1s} = 1200 \text{ records}$$

    Anh chỉ nên đặt cấu hình tối đa là 1000 đến 1200 records cho một lần poll. Đừng tham lam đặt quá lớn.

2.  **Nâng trần bảo hộ (`max.poll.interval.ms`):**

    Đừng để mặc định 5 phút nếu hệ thống lõi BPM có nhiều logic phức tạp hoặc phải gọi API bên ngoài. Hãy nâng hẳn lên **10 phút hoặc 15 phút** (ví dụ: `600000` đến `900000`). Điều này cho phép Thread Java của anh có thêm thời gian "thở" để cày hết Batch dữ liệu cũ nếu gặp sự cố nghẽn mạng mạng mà không sợ bị Broker đá văng ra giữa chừng.

3.  **Tách luồng bất đồng bộ (Async Worker):**

    Như anh em mình đã thiết kế ở giải pháp trước, nếu luồng Kafka chỉ làm nhiệm vụ parse tin rồi ném vào `ThreadPoolTaskExecutor` (RAM Java) rồi thoát hàm ngay lập tức, thời gian xử lý Batch của luồng Kafka gần như bằng 0. Khi đó anh sẽ không bao giờ sợ bị fail `max.poll.interval.ms`. Nhưng đổi lại, anh phải xử lý bài toán kiểm soát kích thước hàng chờ của Thread Pool bằng cơ chế `Backpressure` (luồng Java đầy thì bảo Kafka dừng poll) để tránh bị tràn RAM (OOM).


Anh thấy đấy, Kafka rất mạnh nhưng nó cực kỳ sòng phẳng về mặt thời gian. Hiểu rõ sự cọ xát cơ học giữa các luồng và các thông số timeout này chính là ranh giới giữa một hệ thống chạy "hên xui" và một hệ thống đạt chuẩn Core Ngân hàng!

# 🧭 Tình huống khi consumer chết hoặc thêm mới
Khi có một Consumer bị chết hoặc có một Consumer mới được thêm vào nhóm (Consumer Group), Kafka sẽ lập tức kích hoạt một cơ chế cơ học tối cao gọi là **Rebalance (Tái cân bằng nhóm)**.

Bản chất của Rebalance là **thu hồi lại toàn bộ các Partition của Topic và phân chia lại từ đầu cho các Consumer còn sống**, đảm bảo công việc được chia đều và không có Partition nào bị bỏ rơi.

Dưới đây là tiến trình cơ học chi tiết xảy ra dưới tầng sâu hệ thống:

## 1. Kịch bản 1: Khi một Consumer bị CHẾT

Làm sao Broker biết một Node Java của anh đã chết? Kafka quản lý việc này qua 2 cơ chế ngầm:

-   **Heartbeat (`heartbeat.interval.ms`):** Consumer liên tục gửi tín hiệu "tôi còn sống" về cho Broker (mặc định cứ sau 3 giây). Nếu quá thời gian `session.timeout.ms` (mặc định 45 giây) mà Broker không nhận được Heartbeat, nó sẽ tuyên bố Consumer này đã chết.

-   **Xử lý quá hạn (`max.poll.interval.ms`):** Consumer vẫn gửi heartbeat, nhưng hàm xử lý code Java của anh bị block (do nghẽn DB hoặc loop vô hạn) quá thời gian cho phép (mặc định 5 phút) mà không gọi lệnh `poll()` tiếp theo. Broker cũng coi như Consumer này đã chết lâm sàng.


### Quy trình Rebalance khi Consumer chết:

1.  **Đóng băng:** Kafka Broker (thành viên đóng vai trò Group Coordinator) thông báo cho các Consumer còn lại trong nhóm tạm dừng việc tiêu thụ tin nhắn.

2.  **Thu hồi và Chia lại:** Broker thu hồi toàn bộ các Partition mà Consumer chết đang nắm giữ. Sau đó, nó áp dụng thuật toán (ví dụ: _RangeAssignor_ hoặc _CooperativeStickyAssignor_) để chia các Partition đó cho các Consumer còn sống.

3.  **Đọc tiếp từ vết cũ:** Consumer mới nhận việc sẽ nhìn vào **Offset gần nhất đã được commit thành công** của các Partition đó trên Broker để kéo tin về xử lý tiếp.


## 2. Kịch bản 2: Khi THÊM MỚI một Consumer vào nhóm

Khi anh Alex thấy tải hệ thống tăng cao (Consumer Lag lớn) và quyết định scale out, cắm thêm một Node Java mới chạy cùng `groupId`.

### Quy trình Rebalance khi thêm Consumer mới:

1.  **Gửi yêu cầu gia nhập:** Node Java mới khởi động, gửi một request `JoinGroup` lên Broker.

2.  **Kích hoạt Rebalance:** Broker nhận lệnh, lập tức phát tín hiệu Rebalance tới toàn bộ các Node cũ trong nhóm.

3.  **San sẻ bớt ghế:** Broker sẽ trích (cắt bớt) một số Partition từ các Consumer cũ đang ôm quá nhiều việc để bàn giao sang cho vị "tân binh" mới này.

4.  **Hệ thống chạy tiếp:** Cả nhóm nhận cấu hình Partition mới và tiếp tục hút tin song song với băng thông lớn hơn.


## ⚠️ Những lưu ý chí mạng ảnh hưởng đến Lõi BPM của anh Alex

Cơ chế Rebalance là cứu cánh giúp hệ thống tự phục hồi, nhưng nó là một **tác vụ rất nặng và cực kỳ nguy hiểm** nếu cấu hình sai:

-   **Hiệu ứng "Stop-The-World" (Eager Rebalance):** Ở các phiên bản Kafka cũ hoặc khi dùng cấu hình mặc định, trong quá trình Rebalance diễn ra (thường mất từ vài giây đến vài chục giây), **toàn bộ cụm Consumer sẽ bị dừng hình hoàn toàn**, không một tin nhắn nào được xử lý. Đối với core ngân hàng, điều này gây ra hiện tượng lag đột biến (Spike Latency).

-   **Cách khắc phục cơ học:**

    1.  Hãy chuyển sang sử dụng chiến lược **Sticky Assignor** hoặc **Cooperative Sticky Assignor** (`partition.assignment.strategy`). Thuật toán này thông minh ở chỗ: Khi thêm/bớt Consumer, nó chỉ dịch chuyển các Partition thực sự cần chuyển, các Consumer khác vẫn giữ nguyên Partition cũ và **vừa chạy vừa chia việc ngầm**, không làm dừng hoạt động của toàn bộ hệ thống.

    2.  Luôn xử lý Idempotency thật chặt ở tầng DB (như anh em mình vừa thống nhất ở turn trước). Vì khi Rebalance xảy ra, Consumer mới rất dễ kéo lại một vài tin nhắn cuối cùng chưa kịp commit từ Consumer cũ, gây ra hiện tượng trùng lặp tin nhắn tức thì.

# Tình huống kafka chết? master luôn có heartbeat ping cho slave rằng nó đang sống, nếu die sẽ có slave khác lên làm master, trường hợp này có thể có downtime, giải pháp là lưu vào db trước cái nào chết thì resend, Kafka sẽ thực hiện rebalance

## 1. Khi Kafka Broker (Leader) bị chết và ý tưởng dùng DB

Trong Kafka, khái niệm Master/Slave được gọi là **Leader/Replica (Bản sao)** ở tầng Partition. Mỗi Partition sẽ có 1 Node Leader chịu trách nhiệm đọc/ghi và các Node Replica đi sau để đồng bộ dữ liệu.

### Cơ chế failover tự động của Kafka (Hầu như không có downtime)

Khi Node Leader bị chết, nhờ cơ chế **KRaft** (hoặc ZooKeeper cũ), cụm Cluster phát hiện ra ngay lập tức thông qua việc mất Heartbeat.

-   **Thời gian chuyển giao:** Một Node Replica có dữ liệu đồng bộ nhất (nằm trong tập ISR - In-Sync Replicas) sẽ được đôn lên làm Leader mới.

-   Quá trình này diễn ra **ở tầng Metadata chỉ mất vài mili giây đến vài chục mili giây**. Đối với ứng dụng Java (Producer/Consumer), khoảng thời gian này quá ngắn nên **không gây ra downtime hệ thống**, mà nó chỉ biểu hiện dưới dạng một cái **Timeout nhẹ** trên đường truyền mạng.


### Tại sao KHÔNG NÊN lưu vào DB trước rồi resend?

Nếu mỗi lần Microservice chuẩn bị bắn một Event vào Kafka, anh lại phải chạy một câu lệnh `INSERT` xuống Database (Postgres/Oracle) để làm backup:

1.  **Hủy diệt hiệu năng:** Anh đang kéo tốc độ của Kafka (vốn ghi đĩa tuần tự hàng vạn TPS) tụt xuống bằng tốc độ ghi đĩa ngẫu nhiên của DB (chỉ vài trăm đến vài nghìn TPS). DB sẽ lập tức bị nghẽn (I/O Bottleneck).

2.  **Trùng lặp logic:** Bản thân Kafka **đã là một Database lưu trữ file log trên đĩa**. Việc anh đẻ thêm một cái DB phía trước giống như việc anh xây hai cái đập thủy điện cạnh nhau để chống lụt.


### Giải pháp chuẩn công nghiệp: Outbox Pattern hoặc Thư viện Local Buffer

Nếu anh muốn đảm bảo Event không bao giờ mất ngay cả khi cả cụm Kafka sập nguồn (mất kết nối hoàn toàn):

-   **Cách 1 (Dùng RAM/Disk của chính App Java):** Cấu hình Producer của Kafka sử dụng bộ đệm (Buffer memory). Nếu Kafka Broker chết tạm thời, Producer sẽ tự động giữ tin nhắn trong bộ nhớ RAM của ứng dụng Java và kích hoạt cơ chế tự động gửi lại (`retries=infinity`) sau mỗi vài mili giây cho đến khi Kafka sống lại. Anh không cần động vào DB.

-   **Cách 2 (Transactional Outbox Pattern):** Chỉ dùng khi Event đó sinh ra từ một transaction nghiệp vụ của DB (ví dụ: Tạo hồ sơ vay thành công thì phải bắn event). Code Java sẽ ghi hồ sơ vay + ghi một dòng event vào bảng `outbox` trong **cùng một Transaction DB**. Sau đó, một Worker (hoặc Debezium) sẽ quét bảng `outbox` này để đẩy vào Kafka. Nếu Kafka chết, dòng event vẫn nằm an toàn trong DB để gửi lại sau.


## 2. Kafka sẽ thực hiện Rebalance thế nào trong tình huống này?

Anh cần phân biệt rõ **2 cấp độ chết** trong cụm hệ thống để biết chính xác khi nào Rebalance xảy ra:

### Trường hợp A: Chỉ có Kafka Broker (Leader của Partition) bị chết

-   **Cơ học:** Khi Broker chứa Partition Leader bị sập, hệ thống chỉ đổi Leader sang cho Broker khác (Replica).

-   **Kết quả:** **KHÔNG xảy ra Rebalance ở tầng Consumer.** Các ứng dụng Java Consumer của anh vẫn giữ nguyên cấu hình, chúng chỉ làm một việc duy nhất: Chuyển hướng kết nối (Socket) sang IP của Broker mới để tiếp tục hút tin từ Partition đó. Luồng chạy hầu như không bị gián đoạn.


### Trường hợp B: Kafka Broker vẫn sống, nhưng Java Consumer bị chết (Hoặc bị đuổi cổ)

Đây mới là lúc **Rebalance thực sự kích hoạt** như anh em mình đã mổ xẻ ở turn trước:

1.  **Phát hiện:** Node Java sập nguồn $\rightarrow$ Mất Heartbeat quá thời gian `session.timeout.ms`. Hoặc Java bị nghẽn DB $\rightarrow$ Xử lý Batch tin quá thời gian `max.poll.interval.ms`.

2.  **Đóng băng (Stop-The-World):** Broker thông báo cho các Node Java còn sống dừng việc ăn tin lại.

3.  **Chia bài:** Broker thu hồi các Partition của Consumer đã chết, đem chia đều lại cho các Consumer còn sống.

4.  **Chạy tiếp:** Các Consumer nhận Partition mới, check **Offset gần nhất đã commit** trên Broker và tiếp tục xử lý.


**Tóm lại:** Lỗi sập Broker (Leader) đã có cơ chế tự động bầu chọn Leader của Kafka xử lý trong vài mili giây mà không cần đúp dữ liệu xuống DB. Anh Alex chỉ cần tập trung xử lý bọc lót cơ chế **Idempotency** dưới DB tầng Consumer để né lỗi trùng lặp dữ liệu khi **Rebalance** xảy ra do các Node Java Consumer bị biến động!

# Kraft có gì mới
Hiện tại, các phiên bản Apache Kafka mới nhất (đặc biệt là cột mốc **Kafka 4.0** vừa phát hành) đã mang lại những bước ngoặt cực kỳ lớn cho KRaft dưới tầng cơ học hệ thống. Dưới đây là những điểm mới cốt lõi nhất ảnh hưởng trực tiếp đến hiệu năng vận hành mà anh cần biết:

### 1. Chính thức Khai tử hoàn toàn ZooKeeper (ZooKeeper Removal)

-   **Có gì mới:** Kể từ Kafka 4.0, **ZooKeeper đã bị xóa bỏ hoàn toàn 100% khỏi mã nguồn**. KRaft bây giờ không còn là tính năng "thử nghiệm" hay "tùy chọn" nữa, mà nó đã trở thành **cơ chế mặc định và duy nhất** để quản lý Cluster.

-   **Lợi ích cơ học:** Anh không còn phải quản lý, cài đặt và bảo trì một cụm ZooKeeper cồng kềnh chạy song song bên cạnh nữa. Toàn bộ kiến trúc Cluster giờ thu về một mối, giảm thiểu tối đa tài nguyên RAM/CPU cho hạ tầng.


### 2. Tái cân bằng Cluster siêu tốc (Faster Rebalances)

-   **Có gì mới:** Khi một Broker bị chết hoặc scale-out thêm Broker mới, KRaft xử lý việc bầu chọn Leader mới cho Partition dựa trên thuật toán đồng thuận Raft nội bộ, thay vì phải ghi nhận và đẩy qua một bên thứ ba như ZooKeeper trước đây.

-   **Lợi ích cơ học:** Tốc độ Rebalance và chuyển đổi Leader (Failover) diễn ra gần như **tức thời (vài mili giây)**. Hiện tượng nghẽn mạng mạng và "dừng hình" hệ thống (Stop-the-world) ảnh hưởng đến Consumer Java của anh khi Cluster biến động gần như đã được triệt tiêu hoàn toàn.


### 3. Hỗ trợ hàng triệu Partition trên một Cluster (Massive Scalability)

-   **Có gì mới:** Trước đây, do giới hạn lưu trữ cây dữ liệu của ZooKeeper, một cụm Kafka thường bị nghẽn và chậm đi thấy rõ nếu số lượng Partition vượt quá con số 200.000. Với KRaft, Metadata được lưu dưới dạng một Topic nội bộ (`__cluster_metadata`) chạy bằng ghi đĩa tuần tự.

-   **Lợi ích cơ học:** Hệ thống KRaft mới có khả năng gánh gãy gọn **hàng triệu Partition** trên cùng một cụm Cluster mà không hề bị suy giảm hiệu năng. Anh Alex có thể thoải mái chặt nhỏ các Topic BPM của mình thành nhiều Partition để tăng tối đa tính song song (`concurrency`) cho các Thread Spring Boot mà không sợ làm sập hệ thống quản lý của Kafka.


### 4. Quy trình nâng cấp mượt mà (Migration Improvements)

-   **Có gì mới:** Kafka đã hoàn thiện công cụ cho phép các hệ thống cũ đang chạy ZooKeeper có thể thực hiện **Migration (dịch chuyển metadata) online sang KRaft** mà không cần phải dừng Cluster (Zero-Downtime).

# Lấy message kafka lấy theo từng cái hay lấy theo batch

**Bản chất cơ học ở tầng mạng dưới ổ đĩa, Kafka LUÔN LUÔN lấy tin theo Batch (theo lô), bất kể anh viết code Java như thế nào.**

Tuy nhiên, ở tầng ứng dụng Java Spring Boot của anh, việc lấy theo từng cái hay theo batch hoàn toàn phụ thuộc vào cách anh **cấu hình phương thức hứng data** ở đầu luồng.

Để anh Alex nắm rõ bản chất và chọn đúng vũ khí cho lõi BPM, hãy nhìn vào sự khác biệt dưới đây:

## 1. Bản chất cơ học dưới tầng mạng (Mặc định luôn là Batch)

Khi ứng dụng Java của anh gọi lệnh `poll()`, Thread của Kafka **không bao giờ đi bộ qua mạng để nhặt từng tin nhắn đơn lẻ**. Làm như vậy sẽ hủy diệt băng thông vì chi phí tiêu đề mạng (Network Overhead).

-   **Cơ chế:** Kafka Consumer sẽ gom một lượng lớn dữ liệu trên Broker (ví dụ: gom đủ 1MB dữ liệu hoặc đợi tối đa 500ms theo cấu hình `fetch.min.bytes` và `fetch.max.wait.ms`) rồi **nạp một cục data nén qua cơ chế Zero-Copy về vùng nhớ RAM (Buffer Cache) của ứng dụng Java**.


Sự khác biệt thực sự chỉ xuất hiện sau khi cục data này đã về tới RAM của anh:

## 2. Cấu hình kiểu 1: Xử lý Từng cái một (Single Listener)

Đây là cấu hình mặc định của `@KafkaListener`.

-   **Cơ học:** Sau khi cục dữ liệu Batch được nạp về RAM, thư viện Spring Kafka sẽ chạy ngầm một vòng lặp `for`, tự động bóc tách (deserialize) từng tin nhắn ra và **gọi hàm của anh từng lần một**.

-   **Code của anh:** Nhận vào một đối tượng đơn lẻ.

    Java

    ```
    @KafkaListener(topics = "bpm.events")
    public void listen(ConsumerRecord<String, String> record) {
        // Xử lý đúng 1 tin nhắn
        runtimeEngine.execute(record.value());
    }
    
    ```

-   **Ưu điểm:** Code cực kỳ đơn giản, dễ xử lý lỗi (tin nào lỗi thì fail đúng tin đó).

-   **Nhược điểm:** Tốc độ chậm hơn vì mỗi lần xử lý xong 1 tin, Spring lại phải mất chi phí quản lý luồng để kích hoạt lượt tiếp theo, và nếu anh dùng Manual Ack, việc commit offset liên tục cho từng tin sẽ làm tăng tải cho Broker.


## 3. Cấu hình kiểu 2: Xử lý theo lô (Batch Listener)

Đây là vũ khí hạng nặng mà anh em mình vừa dùng để đưa hệ thống lên hàng nghìn TPS ở turn trước.

-   **Cơ học:** Spring Kafka bê nguyên cả cục data vừa poll từ RAM lên, bóc tách toàn bộ thành một cái `List` rồi **gọi hàm của anh duy nhất 1 lần**, giao trọn gói cả lô dữ liệu cho anh tự xử lý.

-   **Code của anh:** Nhận vào một danh sách `List`.

    Java

    ```
    @KafkaListener(topics = "bpm.events")
    public void listenBatch(List<ConsumerRecord<String, String>> records) {
        // Nuốt một phát 500 hoặc 1000 tin nhắn trong 1 hàm
        for (ConsumerRecord<String, String> record : records) {
            // Tự loop cơ học siêu tốc trên RAM bằng CPU
        }
    }
    
    ```

-   **Ưu điểm:** Tốc độ kinh hoàng (Xé gió). Anh có thể tối ưu bằng cách gom 500 tin này lại thành 1 câu lệnh Batch Update duy nhất xuống Database, giảm số lần chọc ổ đĩa của DB xuống 500 lần. Việc Commit Offset cũng chỉ diễn ra 1 lần duy nhất cho cả lô.

-   **Nhược điểm:** Viết code phức tạp hơn. Nếu tin nhắn số #300 trong lô bị lỗi, anh phải tự bọc `try-catch` cẩn thận, nếu không nó sẽ làm văng lỗi và khiến cả lô 500 tin bị xử lý lại (gây Duplicate khôn lường).


## Chốt lại: Nên chọn cái nào cho Core BPM?

-   Nếu Topic đó thuộc luồng **tải cực cao, cần throughput lớn** (ví dụ: Log sự kiện chạy task, sync data trạng thái): **Bắt buộc dùng Batch**.

-   Nếu Topic đó thuộc luồng **giao dịch tài chính nhạy cảm, số lượng vừa phải nhưng cần độ chính xác tuyệt đối** (ví dụ: Lệnh duyệt giải ngân, OTP): **Nên dùng Từng cái (Single)** để kiểm soát chặt chẽ vòng đời và lỗi của từng transaction.
-
21.
## REFERENCE
Kafka Interview questions and answers for 2024 for Experienced: https://www.youtube.com/watch?v=Q7tU0B1bnSE

### PRODUCER CONFIG

| Nhóm                             | Key                   | Ý nghĩa                                 | Mặc định             | Ghi chú                              |  
| -------------------------------- | --------------------- | --------------------------------------- | -------------------- | ------------------------------------ |  
| 🧠 **Core Settings**             | `bootstrap.servers`   | Danh sách broker Kafka                  | —                    | Bắt buộc                             |  
|                                  | `key.serializer`      | Class serialize key                     | —                    | Bắt buộc                             |  
|                                  | `value.serializer`    | Class serialize value                   | —                    | Bắt buộc                             |  
| ⚙️ **ACK & Retry**               | `acks`                | `0`, `1`, hoặc `all`                    | `1`                  | `all` an toàn nhất                   |  
|                                  | `retries`             | Số lần retry khi gửi lỗi                | `2147483647` (v2.1+) | Retry tự động nếu network/broker lỗi |  
|                                  | `retry.backoff.ms`    | Delay giữa các lần retry                | `100`                |                                      |  
| 🚀 **Batch & Buffer**            | `batch.size`          | Kích thước batch (bytes)                | `16384`              | Tăng giúp hiệu năng tốt hơn          |  
|                                  | `linger.ms`           | Thời gian chờ batch (ms)                | `0`                  | Ví dụ: `linger.ms=5` giúp gửi gộp    |  
|                                  | `buffer.memory`       | Tổng memory cho buffer                  | `33554432` (32MB)    |                                      |  
| 🔄 **Compression**               | `compression.type`    | `none`, `gzip`, `snappy`, `lz4`, `zstd` | `none`               | Giúp giảm bandwidth                  |  
| 🪄 **Idempotence & Transaction** | `enable.idempotence`  | Gửi message “exactly-once”              | `true` (>= 3.0)      | Bắt buộc nếu dùng transaction        |  
|                                  | `transactional.id`    | ID duy nhất cho transaction             | —                    | Dùng khi transactional producer      |  
| ⏱️ **Timeouts**                  | `request.timeout.ms`  | Timeout gửi request                     | `30000`              |                                      |  
|                                  | `delivery.timeout.ms` | Tổng timeout gửi 1 record               | `120000`             |                                      |  
| 📈 **Metrics & Logging**         | `client.id`           | ID định danh producer                   | —                    | Hữu ích để debug/log                 |  

### CONSUMER CONFIG
| Nhóm                           | Key                         | Ý nghĩa                               | Mặc định           | Ghi chú                                                |  
| ------------------------------ | --------------------------- | ------------------------------------- | ------------------ | ------------------------------------------------------ |  
| 🧠 **Core Settings**           | `bootstrap.servers`         | Broker Kafka                          | —                  | Bắt buộc                                               |  
|                                | `group.id`                  | Tên group consumer                    | —                  | Bắt buộc                                               |  
|                                | `key.deserializer`          | Class deserialize key                 | —                  | Bắt buộc                                               |  
|                                | `value.deserializer`        | Class deserialize value               | —                  | Bắt buộc                                               |  
| ⏱️ **Auto Commit**             | `enable.auto.commit`        | Có tự động commit offset không        | `true`             | Nếu `false`, bạn tự commit                             |  
|                                | `auto.commit.interval.ms`   | Khoảng thời gian auto commit          | `5000`             |                                                        |  
| 🪜 **Offset Handling**         | `auto.offset.reset`         | `latest` / `earliest` / `none`        | `latest`           | `earliest` đọc từ đầu topic                            |  
| 🧩 **Concurrency & Partition** | `max.poll.records`          | Số record tối đa mỗi lần poll         | `500`              | Giới hạn batch size khi consume                        |  
|                                | `max.partition.fetch.bytes` | Bytes tối đa đọc mỗi partition        | `1048576`          |                                                        |  
| ⏳ **Timeout & Heartbeat**      | `session.timeout.ms`        | Timeout mất kết nối consumer          | `10000`            |                                                        |  
|                                | `heartbeat.interval.ms`     | Tần suất gửi heartbeat                | `3000`             |                                                        |  
|                                | `max.poll.interval.ms`      | Thời gian tối đa giữa 2 lần poll      | `300000` (5 phút)  | Quá lâu sẽ bị rebalance                                |  
| 🚨 **Error Handling**          | `fetch.min.bytes`           | Số byte tối thiểu broker trả          | `1`                |                                                        |  
|                                | `fetch.max.wait.ms`         | Thời gian tối đa broker chờ           | `500`              |                                                        |  
| ⚙️ **Performance**             | `fetch.max.bytes`           | Bytes tối đa per fetch request        | `52428800`         |                                                        |  
|                                | `isolation.level`           | `read_uncommitted` / `read_committed` | `read_uncommitted` | Nếu producer dùng transaction thì nên `read_committed` |  
| 🧾 **Others**                  | `client.id`                 | Tên consumer client                   | —                  | Để log/debug                                           |