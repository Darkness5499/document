1 Các thành phần của kafka?
2. Khi nào sử dụng kafka?
3. Ý nghĩa và cách sử dụng từng thành phần?
4. Nhiều consumer cùng consume 1 topic? làm thế nào để các Consumer không xử lý trùng 1 message?
5. Trong microservice. Sử dụng cách nào để xử lý vấn đề giữa các service khi 1 service bị lỗi và không thể xử lý yêu cầu
6. Bao nhiêu partition? Consumer là đủ?
7. Cách phân chia message? giả sử có 5 partition, 6 consumer hoặc khác?
8. Khi producer public message thì luồng đi của message sẽ như thế nào? được quản lý như thế nào?
9. Kafka có cơ chế chịu lỗi như thế nào? Message xử lý lỗi thì kafka làm gì? 
10. Có 30k messages, 3 partitions, 3 consumers, message được phân chia cho các consumer thế nào, consumer thứ 3 tiêu thụ 1 message 5s
    mới xong, trong khi các consumer khác real time xong ngay lập tcứ, lâu hơn các consumer khác, thì các consumer khác có tiêu thụ message hộ không?
11. Có 2 partition và 3 consumer thì tiêu thụ message như thế nào?
12. Cho 1 case thực tế, xác định dạng message cùng các luồng, redis thì chẳng hạn chỉ lưu được 100k nhưng có 1m dữ liệu muốn lưu, hỏi khá sâu về partition và cơ chế gửi đến nhiều partition và gửi lại khi lỗi nữa
13. tối ưu thì chỉ có cụm, bao nhiêu broker là đủ, tính toán ra sao, xử lý thì chúng nó đã nhanh sẵn rồi, kafka nắm được cơ chế gửi nhận msg, msg đi vào par nào theo key và k key, consumer consume thế nào, lỗi thì retry ra sao, DLQ, đang trơn tru tự nhiên broker sập thì xử lí thế nào, msg sắp đến tay, chưa kịp commit offset thì tèo,... nhiều msg quá thì scale consumer lên chung 1 group, tăng số lượng partitions...
14. trong project BPM, BCCS3 dùng kafka đoạn nào? xử lý thế nào? gặp lỗi gì? ví dụ đang build service mà có message kafka cần handle, nó không tự handle hoặc nghẽn làm thế nào
15. ý người phỏng vấn hỏi giá trị mặc định hả ta ? mình đọc cũng ko hiểu ý câu hỏi lắm
mà "độ trễ tối đa" là cái gì nhỉ ? Nếu là thời gian tối đa giữa 2 lần poll thì là 300000ms (5 phút)
còn nếu là thời gian tối đa consumer có thể mất kết nối với Kafka broker trước khi bị coi là "chết" thì là 45000ms (45s)
16. nó rất nhiều vấn đề mập mờ ở đây :D:D ví dụ kafka là pull batch, nếu size batch quá lớn, mỗi msg xử lý nhanh nhưng khi tổng vào thì nó là lâu, cũng có thể dẫn đến fail heartbeat
17. 🧭 Tình huống khi consumer chết hoặc thêm mới

Kafka sẽ thực hiện rebalance:

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

