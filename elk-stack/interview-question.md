# ⚡ Tổng quan Elasticsearch

- **Elasticsearch** là một distributed search engine được xây dựng trên nền tảng **Lucene**.


- Dữ liệu trong Elasticsearch được lưu theo cấu trúc:
    ### index → shard → segment → inverted index

- Kiến trúc cluster của Elasticsearch gồm các loại node:
- **Master Node** – quản lý metadata & cluster state
- **Data Node** – lưu shard và xử lý truy vấn
- **Coordinating Node** – nhận request, phân tán và merge kết quả
- **Ingest Node** – transform log trước khi index



- Khi thực hiện một truy vấn, Elasticsearch sẽ:
1. Phân tán query tới các shard song song
2. Mỗi shard tìm dữ liệu trong segment của nó
3. Trả về partial results
4. Coordinating node merge & sort kết quả cuối cùng
- Nhờ kiến trúc phân tán và xử lý song song này, Elasticsearch:
- **cực nhanh**
- **dễ scale-out**
- **phù hợp hệ thống lớn và real-time search**

### FLOW đẩy Log


