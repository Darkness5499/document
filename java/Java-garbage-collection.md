# Java Garbage Collection (GC)

Java Garbage Collection (GC) là cơ chế quản lý bộ nhớ tự động của JVM nhằm tìm và giải phóng những vùng nhớ Heap chứa các Object không còn được sử dụng (Unreachable Objects), giúp né lỗi rò rỉ bộ nhớ (OutOfMemoryError).

Để vượt qua các câu hỏi tình huống tầm cỡ Senior, anh Alex cần nắm chắc bản chất cơ học của GC từ sơ đồ phân vùng cho đến cách các thuật toán tối ưu hóa chu kỳ quét của CPU.

---

# I. TỔNG HỢP LÝ THUYẾT CỐT LÕI (KIẾN TRÚC GC)

Cơ chế GC của Java hoạt động dựa trên giả thuyết **Weak Generational Hypothesis**:

> “Hầu hết các Object sinh ra đều chết đi rất nhanh (vòng đời ngắn)”

Vì vậy, bộ nhớ Heap được chia làm các phân vùng rõ rệt để tối ưu hóa tần suất dọn rác:

---

## 1. Young Generation (Vùng chứa các Object non trẻ)

Là nơi đầu tiên tiếp nhận các Object vừa được `new` ra. Vùng này được chia nhỏ thành 3 phần:

### Eden Space
- Nơi Object vừa chào đời
- Khi Eden đầy → kích hoạt **Minor GC**
- Quét các object không còn tham chiếu

### Survivor Spaces (S0 và S1)
- Object sống sót sau Minor GC sẽ được chuyển sang đây
- Hai vùng S0 và S1 luân phiên hoạt động
- Mỗi lần sống sót → Object tăng **Age (tuổi)**

---

## 2. Old / Tenured Generation (Vùng chứa Object già cỗi)

- Object đạt đến ngưỡng tuổi (mặc định ~15, cấu hình `-XX:MaxTenuringThreshold`)
- Được **Promote** sang Old Generation

### Đặc điểm:
- Chứa object sống lâu: Spring Beans, Cache, config...
- Khi đầy → kích hoạt **Major GC / Full GC**

---

## 3. Khái niệm chí mạng: Stop-The-World (STW)

- JVM tạm dừng toàn bộ Application Threads
- Chỉ GC được phép chạy để quét heap

### Hệ quả:
- Gây latency spike
- Hệ thống bị “đơ” tạm thời

👉 Senior architect luôn tối ưu để **STW càng ngắn càng tốt**

---

# II. CÁC DÒNG SẢN PHẨM GC HIỆN ĐẠI (ENTERPRISE GC)

| GC Collector | Cơ chế hoạt động | Điểm đặc trưng | Phù hợp bài toán |
|---|---|---|---|
| **Parallel GC** | Dùng nhiều thread CPU để quét rác, nhưng STW dài | Tối ưu Throughput | Batch processing, report, job nặng |
| **G1 GC (Garbage First)** | Chia heap thành nhiều region nhỏ, ưu tiên dọn vùng nhiều rác | Cân bằng throughput và latency (STW vài trăm ms) | Web app, microservices |
| **ZGC (Z Garbage Collector)** | Concurrent toàn bộ với application bằng colored pointers & load barriers | STW cực ngắn (<1ms), scale heap rất lớn | Hệ thống low-latency (banking, trading, realtime) |

---

# III. CÁC CÂU HỎI TÌNH HUỐNG TẦM CỠ SENIOR (INTERVIEW FOCUS)

---

## 💬 Tình huống 1

> Hệ thống microservices phản hồi chậm, CPU 100%, log có:
> `java.lang.OutOfMemoryError: GC overhead limit exceeded`

### Phân tích bản chất cơ học

- JVM dành >98% CPU cho GC
- Nhưng reclaim được <2% heap
- Full GC liên tục → hệ thống gần như “chết”

👉 Dấu hiệu:
- Memory leak hoặc query load quá lớn

---

### Cách xử lý Senior

**1. Khẩn cấp**
- Heap Dump bằng `jcmd` hoặc `jmap`

**2. Phân tích root cause**
- Dùng Eclipse Memory Analyzer (MAT)
- Tìm object giữ memory bất thường:
  - static collection leak
  - cache không giới hạn
  - SQL load quá nhiều data

**3. Tối ưu**
- Tăng heap (`-Xmx`) nếu cần
- Hoặc chuyển sang ZGC để giảm STW pressure

---

## 💬 Tình huống 2

> Object có 1 biến static và 1 biến local trỏ tới nó. Khi Minor GC chạy, object có bị dọn không?

### Phân tích cơ chế

GC dùng **Reachability Analysis** từ GC Roots:

GC Roots gồm:
- static variables (Metaspace)
- local variables (Stack)

---

### Kết luận

- Object **KHÔNG bị GC**
- Vì vẫn còn reference từ `static`
- Local variable mất cũng không ảnh hưởng

👉 Object sẽ:
- sống qua Minor GC
- tăng age
- chuyển sang Old Generation

---

## 💬 Tình huống 3

> G1GC heap 32GB bị freeze 2–3 giây STW. Tune gì?

### Phân tích

- Heap lớn → region scan nhiều
- Old gen cleanup bị dồn
- Pause target không hợp lý

---

### Cách xử lý Senior

**1. Không chỉnh -Xmn**
- Không phá G1 auto-tuning

**2. Set pause target**

```bash
-XX:MaxGCPauseMillis=200