### 1. Bản chất điểm chung của mọi bài toán Database

-   **Bản chất của RAM vs Đĩa cứng (Disk I/O):** Mọi bài toán hiệu năng DB thực chất là cuộc chiến giảm thiểu số lần đọc/ghi xuống ổ đĩa vật lý. RAM nhanh hơn đĩa cứng hàng chục ngàn lần. Index, Cache, WAL log, hay Partitioning... tất cả đều là các kỹ thuật cố gắng giữ dữ liệu nóng trên RAM và gom việc ghi xuống đĩa thành một hàng đợi tuần tự để né tránh thảm họa nghẽn I/O.

-   **Sự đánh đổi (Trade-offs) không thể né tránh:** Bạn không thể có một Database vừa ghi cực nhanh, vừa đọc cực nhanh, dữ liệu vừa nhất quán 100% ở mọi nơi, lại vừa có chi phí rẻ.

    -   Muốn đọc nhanh? Phải đánh Index (chấp nhận ghi chậm đi và tốn dung lượng).

    -   Muốn hệ thống chịu tải cao (Scale)? Phải chấp nhận dữ liệu nhất quán sau một khoảng thời gian (Eventual Consistency) thay vì nhất quán tức thời (Strong Consistency).

-   **Concurrency (Sự tranh chấp tài nguyên):** Hệ thống chạy chậm không phải vì phần cứng yếu, mà vì các tiến trình phải **xếp hàng chờ nhau**. Khóa vật lý (Locking), tranh chấp bộ nhớ đệm, hay nghẽn kết nối (Connection Pool) đều sinh ra khi có quá nhiều luồng dữ liệu cùng muốn giành giật một tài nguyên tại một thời điểm.


### 2. Bốn nhóm vấn đề "kinh điển" luôn luôn phải giải quyết

Bất kỳ hệ thống nào, sau một thời gian vận hành và phát triển, đều sẽ lần lượt va phải 4 bức tường bài toán này:

**Nhóm 1: Tốc độ và Khả năng đáp ứng (Performance & Latency)**

-   _Bài toán:_ Dữ liệu phình to khiến các câu lệnh `SELECT` trước đây chạy mất 10ms giờ nhảy lên 5 giây.

-   _Vấn đề cần giải quyết liên tục:_ Thiết kế chiến lược Index hợp lý (tránh lạm dụng), phân tích Execution Plan để phát hiện và triệt tiêu tình trạng Full Table Scan, cấu hình tối ưu bộ nhớ đệm (Buffer Pool) của DB Engine.


**Nhóm 2: Tính toàn vẹn và Đồng thời (Consistency & Concurrency)**

-   _Bài toán:_ Hai người dùng cùng bấm mua chiếc vé máy bay cuối cùng tại một tích tắc. Hoặc hệ thống Microservices ghi thành công ở DB này nhưng thất bại ở DB khác.

-   _Vấn đề cần giải quyết liên tục:_ Chọn lựa Isolation Level phù hợp cho Transaction; thiết kế chiến lược khóa (Locking) để vừa không làm sai lệch dữ liệu vừa không gây nghẽn mạch (Deadlock); triển khai các pattern xử lý phân tán như Saga hoặc Two-Phase Commit.


**Nhóm 3: Khả năng mở rộng (Scalability & Volume)**

-   _Bài toán:_ Lượng truy cập hoặc dung lượng lưu trữ vượt quá giới hạn vật lý của một mô hình máy chủ đơn lẻ (Single Instance).

-   _Vấn đề cần giải quyết liên tục:_ Tách biệt luồng Đọc/Ghi (Read/Write Splitting với mô hình Primary-Replica); thực hiện phân mảnh dữ liệu theo chiều dọc (Vertical Partitioning) hoặc chiều ngang (Sharding) để chia tải ra nhiều máy chủ.


**Nhóm 4: Tính sẵn sàng và An toàn (Availability & Disaster Recovery)**

-   _Bài toán:_ Trung tâm dữ liệu (Data Center) bị mất điện, ổ cứng bị hỏng vật lý, hoặc sự cố con người vô tình xóa nhầm dữ liệu.

-   _Vấn đề cần giải quyết liên tục:_ Thiết kế cơ chế Replication (đồng bộ/bất đồng bộ) giữa các node; tính toán chỉ số RPO/RTO để lập chiến lược Backup dữ liệu (Hot/Cold backup) và lập kế hoạch khôi phục sau thảm họa (Disaster Recovery) mà không làm gián đoạn hệ thống.


Một Senior Database Engineer giỏi không phải là người thuộc lòng mọi câu lệnh, mà là người nhìn vào một lỗi Bug cụ thể trên Production và ngay lập tức định vị được nó thuộc về điểm nghẽn nào trong 4 nhóm cốt lõi trên để đưa ra phương án xử lý gốc rễ.

------

**1. Tư duy Thiết kế & Trade-offs (Sự đánh đổi)**

-   "Hệ thống hiện tại đang chạy mô hình Relational DB (SQL) và gặp bài toán scale ghi (Write scalability) rất nặng do lượng user tăng đột biến. Bạn sẽ chọn giải pháp nào giữa: Sharding SQL, chuyển dịch sang NoSQL, hay ứng dụng CQRS (Command Query Responsibility Segregation)? Dựa trên những tiêu chí đánh giá nào để bạn đưa ra quyết định đó?"

-   "Khi thiết kế một bảng chứa lịch sử giao dịch tài chính với hàng trăm triệu dòng, bạn sẽ chọn cách phân vùng dữ liệu (Partitioning) như thế nào? Khi nào thì Partitioning thực sự cải thiện hiệu năng, và khi nào nó lại làm hệ thống chậm đi?"


**2. Tối ưu hóa & Khắc phục Sự cố (Troubleshooting & Tuning)**

-   "Hệ thống Production đang bị cảnh báo CPU DB nhảy lên 100% đúng vào khung giờ cao điểm. Bạn có 5 phút để tìm ra nguyên nhân và hạ nhiệt hệ thống. Các bước điều tra cụ thể của bạn từ tầng OS đến tầng SQL Engine là gì?"

-   "Hãy giải thích cách bạn xử lý một tình huống Deadlock phức tạp trong hệ thống microservices khi có nhiều dịch vụ cùng ghi vào các bảng liên quan. Bạn sẽ dùng công cụ gì để phát hiện và chiến lược code/DB nào để triệt tiêu nó?"

-   "Một câu lệnh `SELECT ... WHERE ...` chạy rất nhanh trên môi trường Staging (dữ liệu ít) nhưng bị nghẽn (Timeout) trên Production (dữ liệu lớn), dù cột trong `WHERE` đã được đánh Index. Bạn sẽ phân tích Execution Plan như thế nào để tìm ra 'thủ phạm' (ví dụ: Index Scan vs Index Seek, Implicit Conversion, hay Data Skew)?"


**3. Hiểu biết sâu sắc về Bản chất Hệ thống (Internals)**

-   "Hãy giải thích cơ chế hoạt động bên dưới của WAL (Write-Ahead Logging) hoặc Redo/Undo Log. Tại sao CSDL lại ghi vào Log trước khi ghi vào đĩa file dữ liệu chính? Điều gì xảy ra nếu hệ thống mất điện đột ngột ngay khi Log vừa ghi xong nhưng Data file chưa kịp cập nhật?"

-   "Trong các hệ thống phân tán (Distributed Databases), bạn hiểu thế nào về hiện tượng Read Phenomema (Dirty Read, Non-repeatable Read, Phantom Read) dưới góc nhìn của các mức cô lập (Isolation Levels) khác nhau? Bạn đã từng phải hạ hoặc nâng Isolation Level để giải quyết bài toán hiệu năng/chính xác dữ liệu chưa?"


**4. Khả năng Thực chiến & Vận hành (Operational Excellence)**

-   "Bạn được giao nhiệm vụ thực hiện một đợt Migration thay đổi Schema lớn trên một bảng có dung lượng 500GB đang hoạt động 24/7 (Zero-downtime). Bạn sẽ lập kế hoạch và các bước thực thi như thế nào để đảm bảo không làm gián đoạn người dùng và có đường lui (Rollback plan) an toàn nếu xảy ra sự cố?"

-   "Hãy kể lại một sự cố sập Database nghiêm trọng nhất mà bạn từng trực tiếp xử lý. Bạn đã học được bài học gì từ lỗi thiết kế hoặc lỗi vận hành đó?"

**1. Bài toán Tải siêu cao & Chiến lược Caching nâng cao**

-   **Tình huống:** "Hệ thống chuẩn bị chạy chiến dịch Flash Sale với lượng truy cập đồng thời tăng gấp 100 lần ngày thường. Bạn sẽ thiết kế chiến lược Cache (sử dụng Redis/Memcached) như thế nào để bảo vệ Database phía sau? Hãy nêu phương án xử lý cụ thể cho 3 hiện tượng: **Cache Penetration** (Yêu cầu tìm kiếm dữ liệu không tồn tại), **Cache Breakdown** (Hot key bị hết hạn ngay lúc cao điểm), và **Cache Avalanche** (Hàng loạt key hết hạn cùng lúc)."

-   **Mục đích:** Đánh giá khả năng phòng thủ từ xa cho Database của ứng viên.


**2. Kiến trúc Database phân tán & Tính nhất quán (Distributed DB & Consistency)**

-   **Câu hỏi:** "Khi triển khai mô hình Database **Multi-Region (Active-Active)** để phục vụ người dùng toàn cầu, thách thức lớn nhất là độ trễ mạng khi đồng bộ dữ liệu. Bạn sẽ giải quyết bài toán xung đột dữ liệu khi hai user ở hai châu lục cùng cập nhật một dòng dữ liệu tại một thời điểm như thế nào? Bạn sẽ chọn chiến lược _Last-Write-Wins_, _CRDTs (Conflict-free Replicated Data Types)_, hay chấp nhận hy sinh tính nhất quán thời gian thực theo định lý CAP?"

-   **Mục đích:** Kiểm tra tư duy thiết kế hệ thống ở quy mô toàn cầu (Global Scale), nơi các ràng buộc của hệ thống SQL truyền thống không còn áp dụng nguyên vẹn được nữa.


**3. Khả năng "Dọn dẹp chiến trường" (Technical Debt & Refactoring)**

-   **Câu hỏi:** "Bạn tiếp nhận một hệ thống Legacy với Database được thiết kế từ 5 năm trước: Các bảng không có khóa ngoại, dữ liệu dư thừa bị sai lệch nghiêm trọng, nhiều cột lưu chuỗi JSON vô tội vạ khiến truy vấn cực kỳ chậm, nhưng hệ thống vẫn đang mang lại doanh thu chính cho công ty. Bạn sẽ lập lộ trình tái cấu trúc (Refactor) sơ đồ Database này như thế nào mà không làm sập ứng dụng hiện tại?"

-   **Mục đích:** Senior không chỉ xây mới giỏi mà phải sửa cũ tốt. Câu hỏi này đo lường sự kiên nhẫn, tư duy thực tế và khả năng quản lý rủi ro của ứng viên.