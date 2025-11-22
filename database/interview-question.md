# Database interview questions

### Pessimistic Locking Optimistic Locking

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
    - Ngoài ra còn có partial index (đánh index 1 phần) và compound index (đánh index trên nhiều cộtin)
    - index nhiều cột thì cột đầu tiên cũng được index, như cuốn sách nhiều trang được index, trong trang các dòng lại được index tiếp

```sql
CREATE
INDEX_TYPE INDEX idx_emp_name ON employees (last_name);
``` 

4. Có những kiểu đánh partition nào, cần lưu ý những gì, cách hoạt động của partition trong oracle
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

10. sự khác biệt giữa where và in
    - => không có quá nhiều sự khác biệt về hiệu năng
11. Hiểu biết về primary key, constraints, sequence, trigger, sử dụng temporary table, bulk collection trong Oracle
12. OLTP và OLAP

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



    
13. Hiểu gì về transaction, transaction
14. Connection pool là gì, thông thường là bao nhiêu, tạo nhiều có được không, tính toán số connections hợp lý
    - Ý tưởng cũng như thread pool, nếu mỗi lần cần thao tác với db cần tạo connect, xử lý rồi đóng rất lâu nên sinh ra
      pool để tái sử dụng
    - giống như nhân viên bán hàng trong siêu thị
15. cụm (Data Replication, Sharding Strategies, CAP Theorem, )
16. Có các kiểu join nào? Nested loop, hash join, merge join...
    

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
17. N+1 Problem là gì? cách giải quyết
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


