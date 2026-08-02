
# Database interview questions

### Pessimistic Locking(Bi quan, ít có tranh chấp) Optimistic Locking(lạc quan, lúc nào cũng có tranh chấp)

1. Thứ tự thực hiện câu lệnh truy vấn SQL?
    - FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT/OFFSET/ROWNUM (ORACLE)

2. Chiến lược thực thi câu lệnh SQL - Explain plan
    - Syntax check: Kiểm tra cú pháp
    - Semantic check: Kiểm tra ngữ nghĩa, xem các bảng các cột, alias có tồn tại không
    - Check Cache: Kiểm tra xem có plan cho câu này đã tồn tại hay chưa, nếu đã có tái sử dụng để tiết kiệm thời gian
    - Ví dụ
      `
      SELECT * FROM employees WHERE id = :id;

   `
   Thay vì: SELECT * FROM employees WHERE id = 1;
   Optimization Phase: Bộ tối ưu hoá oracle làm việc
   Row Source Generation
   Execution Phase
   Fetch Phase
   Trong phần này chủ yếu tập trung tối ưu hoá được ở giai đoạn **Check Cache**

3. Có những kiểu đánh index nào, đánh index cần lưu ý những gì, cách index hoạt động
    - B-tree index: Balanced Tree, sử dụng các phép quay để tạo ra cây cân bằng, độ chênh lệch của nhánh phải và trái
      không quá 1
    - Hash index: Hash Table
    - Bitmap index
    - Composite index: Index trên nhiều cột
    - Ngoài ra còn có partial index (đánh index 1 phần) và composite index (đánh index trên nhiều cột)
    - index nhiều cột thì cột đầu tiên cũng được index, như cuốn sách nhiều trang được index, trong trang các dòng lại được index tiếp

    - composite index là đánh index trên nhiều cột, ví dụ A và B thì index A sau đó sắp xếp B theo A -> Select Where B and A thì optimizer sẽ tối ưu
lại câu lệnh rồi mới thực thi -> vẫn là A rồi B

* Đúng như anh chỉnh, Database không bao giờ sắp xếp lại dữ liệu gốc trong các Data Pages hay Data Blocks trên ổ đĩa. Dữ liệu gốc khi anh INSERT vào vẫn nằm cố định, lộn xộn ở các Data Page đó theo thời gian.
* Khi em nói "cột B được sắp xếp", ý em hoàn toàn là "các bản ghi nằm bên trong cấu trúc cây Index (cái Map) được sắp xếp", chứ không phải dữ liệu gốc.
* Để làm rõ bản chất cơ học chuẩn xác mà anh vừa chỉ ra, hãy nhìn vào cách cái Map Index này hoạt động dưới tầng lưu trữ Block/Page:
* Cơ chế cơ học chính xác dưới ổ đĩa
* Giả sử dữ liệu gốc của anh nằm cố định tại các Data Page (vị trí vật lý trên ổ cứng) như sau:
* Data Page 1, Slot 1: [Trần, Bình]
* Data Page 1, Slot 2: [Nguyễn, An]
* Data Page 2, Slot 1: [Trần, An]
* Dữ liệu gốc này giữ nguyên, không dịch chuyển một phân ly nào khi anh tạo index.
* Kịch bản 1: Nếu anh chỉ tạo một cái Map Index trên cột A
* Cái Map Index (Cây B-Tree) được đẻ riêng ra. Bên trong cái Map này, các node chứa bản sao dữ liệu của cột A và được sắp xếp theo thứ tự chữ cái, kèm theo địa chỉ Pointer (Page, Slot) để trỏ về dữ liệu gốc:
* Node 1: Nguyễn → Trỏ về (Page 1, Slot 2)
* Node 2: Trần → Trỏ về (Page 1, Slot 1)
* Node 3: Trần → Trỏ về (Page 2, Slot 1)
* Nhìn vào cái Map này, anh sẽ thấy: Vì Map chỉ sắp xếp theo cột A, nên ở hai Node có cùng giá trị Trần, cái Map xếp thằng Bình (Page 1, Slot 1) đứng trước thằng An (Page 2, Slot 1). Nghĩa là bên trong cấu trúc Map, cột B hoàn toàn lộn xộn.
* Kịch bản 2: Nếu anh tạo Composite Index trên (A, B)
* Cái Map Index lúc này sẽ chứa bản sao dữ liệu của cả cột A và cột B. Và các node bên trong cái Map này được sắp xếp phân cấp:
* Node 1: [Nguyễn, An] → Trỏ về (Page 1, Slot 2)
* Node 2: [Trần, An] → Trỏ về (Page 2, Slot 1)
* Node 3: [Trần, Bình] → Trỏ về (Page 1, Slot 1)
* Lúc này: Chính cấu trúc các Node bên trong cái Map đã được sắp xếp lại. Thằng [Trần, An] đã được đưa lên đứng trước thằng [Trần, Bình] ngay trong cấu trúc cây của Index.
* Kết luận cơ học:
* Anh tư duy cực kỳ chuẩn: Index thực chất là một cái Map (cây chỉ mục) được sắp xếp sẵn, chứa bản sao thu nhỏ của data và địa chỉ con trỏ để bắn thẳng xuống các Data Page gốc.
* Nếu chỉ Index cột A: Cái Map chỉ sắp xếp theo A, thông tin cột B không có hoặc không được xếp thứ tự trong Map → Tìm kiếm theo B trong Map vô tác dụng.
* Nếu Index Composite (A, B): Cái Map sắp xếp theo cặp (A, B) → Tìm kiếm theo cả A và B trên Map đều cực nhanh, tìm xong Map mới bốc con trỏ nhảy xuống Data Page gốc lấy trọn vẹn dòng dữ liệu lên.
  - 
```sql
CREATE
INDEX_TYPE INDEX idx_emp_name ON employees (last_name);
``` 
mục đích của index là để tìm kiếm nhanh những trường có độ chọn lọc cao, nếu index trên code gender thì vẫn phải search thêm hàng triệu bản ghi khác để tìm thông tin -> vô tác dụng
Cơ chế từ chối của Optimizer: Khi anh WHERE gioi_tinh = 'Nam', Bộ tối ưu hóa (Query Optimizer) của DB sẽ tính toán: "Nếu tao dùng Index, tao phải lật cái Map Index 5 triệu lần để lấy 5 triệu cái địa chỉ Pointer (ROWID), rồi lại phải chọc xuống ổ đĩa 5 triệu lần để bốc các Data Pages lên. Thà tao quét cụm từ đầu đến cuối bảng (Full Table Scan) nạp hàng loạt Page vào RAM đọc cho xong, đỡ mất công lật qua lật lại!"

Index + Pagination (LIMIT/OFFSET):
Không Index: DB phải nạp toàn bộ Data Page lên RAM để sắp xếp và đếm tuần tự từng dòng từ số 1 đến vị trí OFFSET $\rightarrow$ Càng lật trang sâu càng chậm.
Có Index: DB chỉ cần đếm các node gọn nhẹ trên cây Map Index, sau đó chọc đúng vài dòng đích dưới Data Page gốc $\rightarrow$ Tốc độ tăng hàng trăm lần.Keyset Pagination (Dùng dấu < hoặc > thay cho OFFSET): DB nhảy cóc $O(\log N)$ thẳng đến dòng cần lấy trên Map Index $\rightarrow$ Lật đến trang thứ 1 triệu tốc độ vẫn xấp xỉ 0 mili giây.

Index B-Tree phù hợp nhất với các toán tử tìm điểm chính xác (=) và tìm đoạn liên tục (<, >, BETWEEN, IN). Cứ làm sao để cột ở vế trái mệnh đề WHERE hoàn toàn cô lập, không bị bọc bởi hàm hay toán thức nào là anh đã bảo vệ được Index thành công!
like %text% thì không tối ưu cho index vì nó chả biết cái nào mà tìm


4. Có những kiểu đánh partition nào, cần lưu ý những gì, cách hoạt động của partition trong oraclepartition
    partition giống như chia ra các thư mục nhỏ, hoặc bảng nhỏ, data của phần nào thì vào khu vực đấy
   ```sql 
        CREATE TABLE sales (
        sale_id NUMBER,
        sale_date DATE,
        amount NUMBER
        )
        PARTITION BY RANGE (sale_date) (
        PARTITION sales_2022 VALUES LESS THAN (TO_DATE('01-01-2023','DD-MM-YYYY')),
        PARTITION sales_2023 VALUES LESS THAN (TO_DATE('01-01-2024','DD-MM-YYYY'))
        );
    ```
   | Loại Partition | Chia theo          | Khi nên dùng               | Ghi chú                         |
      | -------------- | ------------------ | -------------------------- | ------------------------------- |
   | **Range**      | Khoảng giá trị     | Dữ liệu theo thời gian     | Dễ pruning                      |
   | **List**       | Danh sách cụ thể   | Dữ liệu theo nhóm, vùng    | Cần cập nhật khi có giá trị mới |
   | **Hash**       | Hàm băm            | Dữ liệu phân bố ngẫu nhiên | Phân bố đều, khó lọc            |
   | **Composite**  | Kết hợp nhiều loại | Bảng cực lớn, đa chiều     | Linh hoạt nhưng phức tạp        |

5. Thiết kế cơ sở dữ liệu như thế nào, những lưu ý khi thiết kế cơ sở dữ liệu, có những chuẩn nào hoặc quy định nào
   không
   ### Database Design Summary

Database Design là nền móng của hệ thống, ảnh hưởng trực tiếp tới khả năng scale và hiệu năng.

#### Quy trình thiết kế:
1. Phân tích nghiệp vụ: xác định Entity, dữ liệu cần lưu.
2. Thiết kế ERD: xác định bảng và quan hệ (1-1, 1-N, N-N).
3. Normalization: loại bỏ dữ liệu dư thừa, tránh lỗi update.
4. Physical Design: tối ưu Data Type, Index, Partition.

#### Normalization:
- 1NF: Mỗi cột chỉ chứa một giá trị nguyên tử.
- 2NF: Field phải phụ thuộc đầy đủ vào toàn bộ khóa chính.
- 3NF: Không có phụ thuộc bắc cầu giữa các field.

#### Senior Perspective:
- Chuẩn hóa giúp dữ liệu sạch nhưng quá mức sẽ nhiều JOIN → có thể Denormalization để tối ưu đọc.
- Chọn Data Type nhỏ nhất có thể.
- Primary Key nên tối ưu cho index (UUID Binary, UUIDv7, Snowflake).
- Naming convention: snake_case, table dạng số nhiều.
- Luôn có audit field: created_at, updated_at, status/is_deleted.
- Foreign Key giúp đảm bảo dữ liệu nhưng hệ thống lớn có thể quản lý bằng Application để tăng throughput.

=> Database tốt cần cân bằng giữa: Consistency - Performance - Scalability.

6. RAC Real Application Cluster, Database trong thực tế được quản lý hoặc chia ra như thế nào, kiểu dạng chỉ đọc/ghi
   hoặc nhiều cluster để tránh sập...
7. Khi thiết kế, tạo 1 bảng cần lưu ý những gì

8. tính ACID của database
   

   | Thuộc tính | Tên đầy đủ      | Ý nghĩa chính                                              |
      | ---------- | --------------- | ---------------------------------------------------------- |
   | **A**      | **Atomicity**   | Toàn vẹn (Tất cả hoặc không có gì xảy ra)                  |
   | **C**      | **Consistency** | Dữ liệu phải hợp lệ, đúng quy tắc trước và sau giao dịch   |
   | **I**      | **Isolation**   | Giao dịch độc lập, không bị ảnh hưởng bởi transaction khác |
   | **D**      | **Durability**  | Kết quả sau khi commit sẽ được lưu vĩnh viễn               |
9. Tính BASE trong NOSQL
- BASE là mô hình được dùng trong các hệ thống phân tán (NoSQL), ưu tiên tính sẵn sàng (Availability) và khả năng mở rộng (Scalability) hơn là tính nhất quán ngay lập tức.
    | Thành phần                    | Nghĩa                                                                  |
    | ----------------------------- | ---------------------------------------------------------------------- |
    | **B – Basically Available**   | Hệ thống luôn sẵn sàng, even when nodes fail                           |
    | **S – Soft State**            | Trạng thái dữ liệu có thể thay đổi theo thời gian (do replication trễ) |
    | **E – Eventually Consistent** | Dữ liệu sẽ nhất quán sau một khoảng thời gian, không ngay lập tức      |

10. sự khác biệt giữa where và in??? câu này ngáo à where in ở trường hợp nào
    - => không có quá nhiều sự khác biệt về hiệu năng
11. Hiểu biết về primary key, constraints, sequence, trigger, sử dụng temporary table, bulk collection trong Oracle
#### Oracle Database Concepts Summary

##### 1. Primary Key (PK)
- Là định danh duy nhất của mỗi record trong bảng.
- Không được NULL và không được trùng.
- Thường được dùng để tạo index tự động.
- Giúp đảm bảo tính toàn vẹn dữ liệu.

---

##### 2. Constraints (Ràng buộc dữ liệu)
Dùng để đảm bảo dữ liệu hợp lệ trong bảng.

Các loại chính:
- PRIMARY KEY: định danh duy nhất
- FOREIGN KEY: ràng buộc quan hệ giữa bảng
- NOT NULL: không được để trống
- UNIQUE: giá trị không được trùng
- CHECK: ràng buộc điều kiện logic

---

#####  3. Sequence
- Object dùng để sinh số tăng tự động trong Oracle.
- Thường dùng cho Primary Key.

Ví dụ:
- NEXTVAL: lấy giá trị tiếp theo
- CURRVAL: lấy giá trị hiện tại

---

##### 4. Trigger
- Là đoạn PL/SQL tự động chạy khi có sự kiện xảy ra:
  - INSERT
  - UPDATE
  - DELETE
- Dùng để:
  - Audit log
  - Validate dữ liệu
  - Tự động cập nhật field

---

#####  5. Temporary Table
- Bảng tạm thời dùng trong session hoặc transaction.
- Dữ liệu không được lưu lâu dài.
- Dùng để xử lý intermediate data (report, batch processing).
- Có thể tự động xóa khi commit hoặc end session.

---

##### 6. Bulk Collection (PL/SQL)
- Kỹ thuật xử lý dữ liệu theo batch thay vì từng dòng.
- Giảm số lần context switch giữa SQL engine và PL/SQL engine.
- Tăng hiệu năng đáng kể khi xử lý dữ liệu lớn.

Ví dụ khái niệm:
- FOR ALL (bulk insert/update/delete)
- BULK COLLECT (fetch nhiều dòng cùng lúc)

---

##### Tổng kết
- PK + Constraints: đảm bảo toàn vẹn dữ liệu
- Sequence: sinh ID tự động
- Trigger: tự động hóa logic DB
- Temporary Table: xử lý dữ liệu tạm thời
- Bulk Collection: tối ưu hiệu năng xử lý dữ liệu lớn trong Oracle
13. OLTP và OLAP

        ## 🟦 OLTP (Online Transaction Processing)
        - Hệ thống xử lý giao dịch thời gian thực.
        - Truy vấn ngắn, đơn giản.
        - Tối ưu cho **ghi (write)**, độ trễ thấp.
        - Dữ liệu thay đổi liên tục.
        - Yêu cầu **ACID mạnh**.
        - Ví dụ: Banking, e-commerce order, booking.

        ## 🟩 OLAP (Online Analytical Processing)
        - Hệ thống phân tích dữ liệu, báo cáo.
        - Truy vấn dài, phức tạp, nhiều aggregate.
        - Tối ưu cho **đọc (read)**, scan lớn.
        - Dữ liệu dạng lịch sử, ít cập nhật.
        - Không cần ACID mạnh.
        - Ví dụ: Dashboard BI, KPI, phân tích dữ liệu.

        ## 📊 Bảng so sánh

        | Tiêu chí | OLTP | OLAP |
        |---------|------|------|
        | Mục đích | Xử lý giao dịch | Phân tích dữ liệu |
        | Truy vấn | Ngắn, đơn giản | Dài, phức tạp |
        | Tối ưu | Write | Read |
        | Tính nhất quán | ACID mạnh | Eventual/loose consistency |
        | Dữ liệu | Thay đổi liên tục | Lịch sử, tổng hợp |
        | Dùng cho | App transactional | Data warehouse / BI |



    
14. Hiểu gì về transaction, transaction
15. Connection pool là gì, thông thường là bao nhiêu, tạo nhiều có được không, tính toán số connections hợp lý
    - Ý tưởng cũng như thread pool, nếu mỗi lần cần thao tác với db cần tạo connect, xử lý rồi đóng rất lâu nên sinh ra
      pool để tái sử dụng
    - giống như nhân viên bán hàng trong siêu thị
    # Connection Pool trong Database (Spring Boot)

##### 1. Connection Pool là gì?
Connection Pool là một bộ nhớ đệm chứa sẵn các kết nối DB (JDBC Connection) được giữ trên RAM để tái sử dụng, thay vì tạo mới mỗi lần query.

###### Cơ chế:
- Không dùng pool:
  - Mỗi request → tạo connection mới → TCP handshake → xác thực DB → chạy SQL → đóng connection
  - Tốn thời gian (10–50ms) và gây quá tải DB nếu traffic lớn.

- Có pool:
  - App khởi động tạo sẵn một số connection
  - Request đến → mượn connection → chạy SQL → trả lại pool (không đóng vật lý)
  - Nhanh hơn rất nhiều (microseconds)

👉 Trong Spring Boot, mặc định dùng **HikariCP** (nhanh và tối ưu nhất hiện nay).

---

##### 2. Số lượng Connection trong Spring Boot

Không cố định, phụ thuộc cấu hình và tài nguyên hệ thống.

###### Mặc định:
- HikariCP: ~10 connections

###### Cấu hình chính:

```yaml
spring:
  datasource:
    hikari:
      minimum-idle: 10        # số connection luôn giữ sẵn
      maximum-pool-size: 30   # số connection tối đa
      connection-timeout: 30000 # thời gian chờ lấy connection (ms)
   ```
   ##### 3. Cơ chế hoạt động

-   Bình thường: giữ `minimum-idle`
-   Khi tải cao:
    -   Pool mở rộng dần đến `maximum-pool-size`
-   Khi tải giảm:
    -   Thu hồi connection dư về lại mức tối thiểu

----------

##### 4. Lưu ý quan trọng (Senior level)

❌ Không nên set max pool quá lớn (100–1000):

-   Gây context switching cao
-   DB bị quá tải

----------

##### 5. Công thức tham khảo tối ưu (PostgreSQL)

```
Max Connections = (CPU Core × 2) + Disk Spindle
```

Ví dụ:

-   4 CPU cores + SSD
    → khoảng 9–20 connections là hợp lý

----------

##### 6. Lưu ý hệ thống thực tế

Tổng connection thực tế =

```
number_of_instances × maximum_pool_size
```

Ví dụ:

-   5 instance Spring Boot
-   mỗi instance max 30 connections

→ DB phải chịu tối đa 150 connections

----------

##### Kết luận

Connection Pool (HikariCP) giúp:

-   Tái sử dụng connection
-   Giảm latency
-   Tránh quá tải DB

Nhưng cần cấu hình hợp lý để cân bằng giữa:
Performance ↔ DB load ↔ số instance


16. cụm (Data Replication, Sharding Strategies, CAP Theorem, )
17. Có các kiểu join nào? Nested loop, hash join, merge join...
    

    | Join Type           | Khi nào dùng                             | Ưu điểm                  | Nhược điểm                  |
    | ------------------- | ---------------------------------------- | ------------------------ | --------------------------- |
    | **Nested Loop**     | Bảng nhỏ + có index                      | Nhanh, ít tốn CPU        | Chậm nếu bảng lớn           |
    | **Hash Join**       | Cả hai bảng lớn, không có index          | Hiệu quả, không cần sort | Tốn RAM, không dùng với `>` |
    | **Sort Merge Join** | Join không phải `=` hoặc dữ liệu đã sort | Linh hoạt                | Cần sort, tốn I/O           |

    - Explain plain để xem loại join

    | Id | Operation              | Name        |
    |----|------------------------|-------------|
    |  0 | SELECT STATEMENT       |             |
    |  1 |  NESTED LOOPS          |             |
    |  2 |   TABLE ACCESS BY INDEX| EMPLOYEES   |
    |  3 |   INDEX UNIQUE SCAN    | IDX_DEPT_ID |
18. N+1 Problem là gì? cách giải quyết
    - Là vấn đề khi ứng dụng truy vấn dữ liệu con (child) cho mỗi bản ghi cha (parent) riêng lẻ → gây ra N+1 truy vấn
      thay vì chỉ 1 hoặc 2 truy vấn.
    ```java
    
    Ví dụ:
    
    List<Department> departments = departmentRepo.findAll(); // 1 query
    for (Department d : departments) {
    d.getEmployees().size(); // N queries (1 per department)
    }
    ```

→ Tổng cộng: 1 + N truy vấn ❌

| Cách         | Ưu điểm         | Nhược điểm               |
|--------------|-----------------|--------------------------|
| Fetch Join   | Nhanh, đơn giản | Có thể duplicate dữ liệu |
| Entity Graph | Linh hoạt       | Khó debug hơn            |
| Batch Fetch  | Giảm query      | Vẫn nhiều truy vấn       |
| DTO Query    | Tối ưu nhất     | Mất tính tự động ORM     |

16. So sánh **truncate**, **delete** và **drop**

    | Tiêu chí                          | **DELETE**                                             | **TRUNCATE**                                     | **DROP**                                      |
    | --------------------------------- | ------------------------------------------------------ | ------------------------------------------------ | --------------------------------------------- |
    | **Mục đích**                      | Xóa dữ liệu trong bảng (có thể theo điều kiện `WHERE`) | Xóa **toàn bộ dữ liệu** trong bảng               | Xóa **cả bảng** (bao gồm cấu trúc và dữ liệu) |
    | **Cú pháp**                       | `DELETE FROM employees WHERE id = 10;`                 | `TRUNCATE TABLE employees;`                      | `DROP TABLE employees;`                       |
    | **Có dùng WHERE**                 | ✅ Có thể dùng `WHERE` để xóa chọn lọc                  | ❌ Không có `WHERE`                               | ❌ Không có `WHERE`                            |
    | **Tác động đến cấu trúc bảng**    | ❌ Giữ nguyên cấu trúc                                  | ❌ Giữ nguyên cấu trúc                            | ❌ Xóa luôn cấu trúc                           |
    | **Khả năng rollback**             | ✅ Có thể rollback (vì là DML)                          | ❌ Không rollback được (DDL)                      | ❌ Không rollback được (DDL)                   |
    | **Tốc độ**                        | ⏳ Chậm (xóa từng dòng, ghi log cho mỗi bản ghi)        | ⚡ Rất nhanh (xóa bằng cách *deallocate extents*) | ⚡⚡ Rất nhanh (xóa metadata của bảng)          |
    | **Ghi log**                       | Ghi log chi tiết từng bản ghi bị xóa                   | Ghi log tối thiểu (chỉ metadata)                 | Ghi log metadata (xóa object)                 |
    | **Tự tăng (sequence / identity)** | Không reset                                            | Reset về mặc định (tuỳ DB)                       | Không còn vì bảng bị xóa                      |
    | **Khóa (Lock)**                   | Row-level lock                                         | Table-level lock                                 | Không cần vì bảng bị xóa                      |
    | **Sử dụng khi**                   | Cần xóa một phần dữ liệu có điều kiện                  | Cần xóa toàn bộ dữ liệu nhưng giữ bảng           | Cần xóa hoàn toàn bảng khỏi database          |

17. Khi nào cần join, khi nào dùng query riêng
    - Với bảng nhỏ và quan hệ rõ ràng → JOIN.

    - Với bảng cực lớn hoặc logic nghiệp vụ phức tạp → chia query + xử lý song song.

    - Khi làm việc với Spring Data JPA, có thể :

    - Dùng fetch join khi cần lấy cùng lúc (tránh N+1).

    - Dùng repository riêng cho từng entity khi dữ liệu độc lập.

### Câu hỏi tình huống

1. Giả sử có 1 bảng lưu trữ các tên thư mục, thư mục A chứa B, B chứa CDED... thì thiết kế như thế nào? (Mở rộng theo
   chiều ngang, thư mục con chứa ID parent foler)
2. Khi insert, update số lượng lớn thì xử lý thế nào? Từ Spring data jpa cho tới oracle
    - insert update theo batch ở spring, nhưng phải mở cấu hình nếu không mặc định vẫn insert theo từng dòng
    - Nếu insert nhiều quá có thể tạm thời tắt index đi
    - chia luồng để insert
3. Ưu nhược điểm của việc không dùng khoá ngoại là gì
    - logic đỡ lằng nhằng phức tạp, cải thiện về mặt hiệu năng, chỉ xử lý logic ở phía service application
4. Prepared statement Trong jpa
    - bind parameter chống SQL injection, viết native query
5. Phi chuẩn hoá có kiểm soát là gì
    - là thêm các cột thông tin đã có ở các bảng khác để đỡ phải join
6. Tạo sẵn bảng lưu kết quả câu truy vấn phức tạp
7. có 100 triệu user cần tìm 1 user tồn tại thì làm thế nào?
8. Làm sao để sử dụng Postgres/Mysql làm event pool/queue cho worker. Nghĩa là Worker sẽ lấy các bản ghi từ 1 table trong DB ra để xử lý, sau khi xử lý xong sẽ mark done ở DB. Làm sao để scale lên 100 worker mà các worker ko bị xử lý lặp nhau
    | Cách                     | Collision-free | Performance | Recommended   |
    | ------------------------ | -------------- | ----------- | ------------- |
    | `FOR UPDATE SKIP LOCKED` | ✔              | ⭐⭐⭐⭐⭐    | **Best**      |
    | UPDATE RETURNING         | ✔              | ⭐⭐⭐⭐      | Best          |
    | Lease (locked_until)     | ✔              | ⭐⭐⭐        | For retries   |
    | Advisory Locks           | ✔              | ⭐⭐⭐⭐      | Postgres only |
    | Poll & status            | ❌             | ⭐⭐          | Avoid         |

9. Giả sử có 2 câu lệnh select * và select column_name from user where name = "Điệp" thì câu 2 có nhanh hơn câu 1 không?
    Thực sự là không nhanh hơn, bản chất vẫn phải select * để lọc ra dữ liệu, nếu trường name không được đánh index vẫn phải full table scan, còn về số trường select ít hơn thì có nhanh hơn 1 chút ở pharse đó
10. Điều gì xảy ra khi 2 câu update cùng thực thi ?


# 🔥 Những điểm tạo nên sự khác biệt giữa các Database Engine

## 1. Storage Engine Architecture (Kiến trúc lưu trữ)
- Quy định cách DB tổ chức dữ liệu trên disk.
- Oracle: Block → Extent → Segment → Tablespace  
- PostgreSQL: Page → Tuple (MVCC)  
- SQL Server: Page → Extent → Allocation Maps  
- MySQL/InnoDB: Page → Extent → TableSpace

## 2. Concurrency Control (Kiểm soát đồng thời)
- Cách xử lý đọc/ghi cùng lúc: MVCC, locking.
- Oracle: MVCC bằng UNDO (rất mạnh)
- PostgreSQL: MVCC theo phiên bản tuple
- MySQL: MVCC trung bình (Undo Log)
- SQL Server: Locking mặc định, snapshot cần bật

## 3. Query Optimizer (Bộ tối ưu truy vấn)
- Quyết định execution plan: index, join, scan.
- Oracle: Optimizer mạnh nhất (CBO)
- PostgreSQL: Rất mạnh, ngày càng tốt
- SQL Server: tốt nhưng bị parameter sniffing
- MySQL: yếu nhất khi join phức tạp

## 4. Feature Set (Tính năng đặc thù)
- Oracle: Partitioning, RAC, Flashback, Data Guard
- PostgreSQL: JSONB, Extensions, FDW
- SQL Server: Columnstore, AlwaysOn
- MySQL/MariaDB: Replication dễ, InnoDB ổn định

## 5. Index Types & Data Structures
- Oracle: B-tree, Bitmap, Function-based, IOT
- PostgreSQL: B-tree, Hash, GIN, GiST, BRIN
- SQL Server: B-tree, Columnstore
- MySQL: B-tree, Fulltext, Spatial

## 6. Logging & Write-Ahead Logging (WAL/Redo)
- Bảo đảm ACID khi crash.
- Oracle: Redo log buffer → LGWR
- PostgreSQL: WAL
- SQL Server: Transaction Log
- MySQL: Redo + Binlog (2 lớp)

## 7. Crash Recovery Architecture
- Quy trình rollback/rollforward.
- Oracle: recover rất nhanh (undo + redo)
- PostgreSQL: WAL replay
- SQL Server: rollback/rollforward tự động
- MySQL: doublewrite buffer, checkpoint

## 8. Replication & High Availability
- Oracle: Data Guard, RAC
- PostgreSQL: Streaming Replication, Logical Replication
- SQL Server: AlwaysOn Availability Groups
- MySQL/MariaDB: Binlog Replication, Galera Cluster


