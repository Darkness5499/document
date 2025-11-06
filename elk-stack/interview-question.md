
🧠 1️⃣ Tổng quan kiến trúc ELK
Câu hỏi:


ELK Stack là gì? Từng thành phần có vai trò gì?


Tại sao lại cần ELK trong hệ thống microservices?


Bạn có thể mô tả pipeline dữ liệu từ ứng dụng đến khi hiển thị trên Kibana không?


Gợi ý trả lời:

ELK gồm Elasticsearch để lưu và tìm kiếm dữ liệu log, Logstash để thu thập và transform log, và Kibana để visualize.
Ứng dụng của tôi đẩy log ra stdout, được Fluentd hoặc Filebeat thu thập gửi về Logstash, Logstash xử lý rồi gửi vào Elasticsearch. Cuối cùng, Kibana đọc dữ liệu từ Elasticsearch để hiển thị dashboard.


🔍 2️⃣ Elasticsearch
Câu hỏi:


Elasticsearch lưu trữ dữ liệu như thế nào?


Index, shard và replica là gì?


Làm sao để tối ưu truy vấn hoặc lưu trữ log cũ?


Nếu Elasticsearch bị “red” cluster state thì bạn xử lý sao?


Gợi ý trả lời:

Mỗi index chia thành nhiều shard, mỗi shard là một Lucene instance. Replica giúp tăng tính sẵn sàng.
Tôi thường set up rollover policy cho index cũ để giảm dung lượng, và nếu cluster bị “red” thì kiểm tra node nào lỗi, xem log elasticsearch.log, rồi restore replica hoặc reallocate shard.


🧩 3️⃣ Logstash / Beats
Câu hỏi:


Bạn dùng Logstash hay Filebeat? Vì sao?


Pipeline trong Logstash có mấy giai đoạn?


Filter plugin nào bạn hay dùng?


Nếu log có format khác nhau thì bạn xử lý sao?


Gợi ý trả lời:

Tôi dùng Filebeat để nhẹ hơn, đẩy log thẳng về Logstash.
Logstash pipeline gồm input, filter và output.
Tôi hay dùng filter grok để parse log, mutate để đổi tên field, và date để chuẩn hóa timestamp.
Khi log khác định dạng, tôi tạo nhiều pipeline hoặc condition trong filter.


📊 4️⃣ Kibana
Câu hỏi:


Bạn dùng Kibana để theo dõi những gì?


Có thể tạo alert từ Kibana không?


Bạn có dùng Canvas hay Dashboard không?


Gợi ý trả lời:

Tôi tạo dashboard theo microservice để xem error rate, response time và log level.
Kibana có Alerting feature (trong Elastic Stack license) để gửi email hoặc webhook khi có lỗi.
Tôi cũng dùng Visualization để thống kê theo @timestamp và log.level.


⚙️ 5️⃣ Triển khai và thực tế
Câu hỏi:


Bạn triển khai ELK ở đâu (on-prem, Docker, hay Kubernetes)?


Bạn làm sao để thu thập log của tất cả microservice trong cluster?


Khi Logstash bị nghẽn, bạn xử lý thế nào?


Gợi ý trả lời:

Tôi deploy bằng Helm chart trong K8S.
Fluentd/Fluent Bit sidecar thu log từ container và gửi về Logstash service.
Khi nghẽn, tôi kiểm tra hàng đợi Logstash (persistent queue), tăng pipeline worker hoặc scale Logstash horizontally.


🔒 6️⃣ Bảo mật & tối ưu
Câu hỏi:


Làm sao để bảo vệ dữ liệu trong Elasticsearch?


Bạn có giới hạn ai được truy cập Kibana không?


Làm sao tối ưu dung lượng lưu trữ log?


Gợi ý trả lời:

Tôi bật authentication qua Elastic Security (hoặc Keycloak SSO).
Giới hạn index retention 7–14 ngày bằng ILM (Index Lifecycle Management).
Và dùng gzip + rollover index để giảm dung lượng.


💬 7️⃣ Câu hỏi trải nghiệm cá nhân


Bạn gặp lỗi nào khó chịu nhất khi triển khai ELK?


ELK giúp bạn debug production issue thế nào?


Nếu hệ thống lớn, bạn có thay ELK bằng giải pháp nào khác không?



Nếu bạn muốn, mình có thể giúp bạn soạn sẵn 10 câu trả lời ngắn gọn theo kiểu phỏng vấn (Q&A) để bạn luyện nói tiếng Anh (kiểu như: “What’s the purpose of Logstash?” – “It’s a data processing pipeline that ingests logs, transforms them, and sends them to Elasticsearch.”).
Bạn có muốn mình soạn phần đó luôn không?