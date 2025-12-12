
Caching là gì, caching trong spring

  

### Reference

1. https://viblo.asia/p/tong-hop-30-cau-hoi-phong-van-redis-thuong-gap-38X4E8EdVN2
2. https://viblo.asia/p/interview-cung-10-phut-toan-canh-redis-cluster-and-sentinel-zXRJ8NYdVGq
3. https://aithietke.com/redis-giai-phap-xu-ly-300-trieu-ban-ghi-voi-redis/
4. https://quanghoang.substack.com/p/50-days-of-sd-slow-redis
5. https://quanghoang.substack.com/p/50-days-of-sd-dragonfly

###  How redis work
# ⚡ **Cách Redis hoạt động (ngắn gọn – chuẩn kỹ thuật)**

1.  **Redis lưu toàn bộ dữ liệu trong RAM**  
    → Truy cập siêu nhanh (micro-seconds).  
    → GET/SET là O(1).
    
2.  **Redis xử lý bằng single-thread event loop**  
    → Không có lock, không context switching, không cạnh tranh thread.  
    → Mỗi request được xử lý tuần tự → đơn giản + cực nhanh.
    
3.  **Sử dụng cấu trúc dữ liệu tối ưu**  
    Redis không chỉ key-value đơn thuần.  
    Nó có nhiều cấu trúc dữ liệu tốc độ cao:
    
    -   String
        
    -   Hash
        
    -   List
        
    -   Set
        
    -   Sorted Set
        
    -   Bitmap
        
    -   HyperLogLog  
        → Tất cả được tối ưu hoá để thực hiện O(1) hoặc O(log N).
        
4.  **I/O Non-blocking + epoll (event loop)**  
    Redis dùng event loop giống Node.js để xử lý nhiều kết nối cùng lúc, nhưng vẫn chỉ 1 luồng logic.  
    → Không block network.
    
5.  **Persistence (nếu bật)**  
    Redis có 2 kiểu lưu ra disk:
    
    -   **RDB snapshot** (định kỳ chụp ảnh)
        
    -   **AOF** (ghi lại các lệnh để replay)  
        → Nhưng truy cập vẫn từ RAM 100%.
        
6.  **Replication + Sentinel + Cluster**  
    Redis hỗ trợ:
    
    -   master/slave replication
        
    -   automatic failover với Sentinel
        
    -   sharding ngang bằng Redis Cluster