# Database interview question
## Câu hỏi kiến thức
1. Cách tối ưu cơ sở dữ liệu, các bước thực hiện của câu lệnh sql, chiến lược thực thi câu lệnh, có những cách nào để tối ưu câu truy vấn?
2. Có những kiểu đánh index nào, đánh index cần lưu ý những gì, loại index
- 2 kiểu gồm single-column index (đánh trên 1 cột) và composite index (đánh trên nhiều cột)
- Lưu ý khi đánh index: +ưu tiên đánh index trên các cột có selectivity cao (=số lượng giá trị unique / tổng số bản ghi)
                        +cột được đánh phải có tần suất sd thường xuyên để truy vấn
                        +trong truy vấn nếu cột đánh index bị bao ngoài bởi 1 hàm (VD: UPPER(NAME), giả sử index trên cột NAME) -> Index trên cột sẽ ko hoạt động
- Trong oracle có 2 loại thường xuyên sử dụng là b-tree index (mặc định) và bitmap index
3. Cách index hoạt động trong oracle
4. có những kiểu đánh partition nào
5. Cách partition hoạt động trong oracle
6. Thiết kế cơ sở dữ liệu như thế nào
7. RAC Real Application Cluster
8. Khi thiết kế, tạo 1 bảng cần những lưu ý gì
9.  ACID
10. Sự khác nhau giữa where và in
11. Hiểu biết vê primary key, constraints, sequence, trigger, sử dụng temporary table, bulk collection trong *oracle*
12. Hiểu biết gì về transaction
ORMs, ACID, Transactions, N+1 Problems Db Normalization, Indexes) và cụm (Data Replication, Sharding Strategies, CAP Theorem)
13. Hãy nêu sự khác biệt giữa việc sử dụng DELETE và TRUNCATE

### Câu hỏi tình huống
1. Giả sử có 1 bảng lưu trữ các tên thư mục, thư mục A chứa B, B chứa CDED... thì thiết kế như thế nào? (Mở rộng theo chiều ngang, thư mục con chứa ID parent foler)


