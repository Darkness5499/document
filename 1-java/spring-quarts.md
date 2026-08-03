
Trong kiến trúc Microservices hiện đại, khi anh Alex cần xây dựng một hệ thống xử lý tác vụ ngầm (Background Jobs/Tasks) như quét DB để gửi email nhắc việc, kiểm tra hạn chót của task (Deadline), hay chạy báo cáo tài chính định kỳ, Spring Boot cung cấp sẵn annotation `@Scheduled`.

Tuy nhiên, `@Scheduled` mặc định chỉ chạy tốt trong môi trường **đơn instance (Single Instance)**. Khi anh scale hệ thống lên **nhiều instance (Cluster)** để chịu tải, nếu dùng `@Scheduled`, tất cả các instance sẽ cùng đồng thời nhảy vào chạy cái Job đó $\rightarrow$ Dữ liệu bị xử lý trùng lặp, sập hệ thống.

**Spring Quartz (Quartz Scheduler)** chính là giải pháp "vũ khí hạng nặng" sinh ra để giải quyết bài toán chạy Job phân tán, có cơ chế lưu trữ trạng thái xuống Database và điều phối luồng cực kỳ mạnh mẽ.

## 1. 3 Thành phần cốt lõi của Quartz (Kiến trúc RAM/DB)

Để làm chủ Quartz ở tầm Senior, anh cần hiểu rõ bộ ba nguyên tử cấu thành nên nó:

### ① `Job` và `JobDetail` (Làm cái gì?)

-   **`Job`:** Là một Interface của Quartz. Anh sẽ `implement Job` và viết logic nghiệp vụ thực tế (Ví dụ: Trừ tiền, gửi mail) bên trong hàm `execute(JobExecutionContext context)`.

-   **`JobDetail`:** Là đối tượng bọc ngoài cái `Job`. Nó chứa các thông tin Meta-data để Quartz quản lý như: Tên Job (JobName), Nhóm Job (JobGroup), và các tham số truyền vào Job (`JobDataMap`).


### ② `Trigger` (Khi nào làm?)

Là thành phần quy định thời gian kích hoạt Job. Quartz cung cấp 2 loại Trigger thông dụng nhất:

-   **SimpleTrigger:** Chạy ngay lập tức, lặp lại sau mỗi $X$ giây, lặp lại $Y$ lần.

-   **CronTrigger:** Chạy dựa trên biểu thức **Cron Expression** cực kỳ linh hoạt (Ví dụ: `0 0 12 ? * WED` -> Chạy vào lúc 12h trưa thứ 4 hàng tuần).


### ③ `Scheduler` (Bộ điều phối tối cao)

Đóng vai trò là "Trái tim" của hệ thống Quartz. Nó quản lý tất cả các `JobDetail` và `Trigger`. Nó sử dụng một Thread Pool riêng (mặc định là `SimpleThreadPool`) để bốc các Job ra chạy khi Trigger kích hoạt.

## 2. Cơ chế Cluster ngầm phá bẫy chạy trùng Job (RAM vs DB Lock)

Đây chính là lý do vì sao hệ thống lớn bắt buộc phải dùng Quartz thay vì `@Scheduled`. Quartz hỗ trợ 2 cơ chế lưu trữ (JobStore):

-   **RAMJobStore (Mặc định):** Toàn bộ thông tin về Job, Trigger được lưu trên bộ nhớ RAM (Heap). Cơ chế này chạy siêu nhanh nhưng nếu app bị restart hoặc sập nguồn là mất sạch dữ liệu Job, và không chạy được Cluster.

-   **JDBCJobStore (Kiến trúc Doanh nghiệp):** Quartz sẽ tạo ra khoảng 11 cái bảng trong Database của anh (Ví dụ: `QRTZ_JOB_DETAILS`, `QRTZ_TRIGGERS`, `QRTZ_LOCKS`...).


### ⚙️ Cơ chế khóa phân tán (Distributed Lock) hoạt động ra sao?

Khi anh deploy ứng dụng Spring Boot của anh thành 3 Instances (Instance A, B, C) cùng kết nối chung vào một Database:

1.  Đến đúng 12h trưa (Thời điểm Trigger kích hoạt), cả 3 Instance đều phát hiện ra có Job cần chạy.

2.  Ngay lập tức, cơ chế ngầm của Quartz trên mỗi Instance sẽ lao vào Database và tìm cách chiếm đoạt một dòng (Row) trong bảng **`QRTZ_LOCKS`** bằng câu lệnh khóa độc quyền:

    $$\text{SELECT} \dots \text{FROM QRTZ\_LOCKS WHERE LOCK\_NAME} = \dots \text{FOR UPDATE}$$

3.  **Instance A** nhanh chân hơn, chiếm được Row Lock (Khóa DB). Hai instance B và C lập tức bị block, phải đứng ngoài chờ.

4.  Instance A lôi dữ liệu Job ra xử lý, cập nhật trạng thái Job thành `RUNNING` xuống DB. Sau khi làm xong, nó giải phóng Lock và cập nhật thời gian chạy tiếp theo (`NEXT_FIRE_TIME`).

5.  Lúc này Instance B và C được giải phóng, nhảy vào check DB thì thấy Job này đã được chạy rồi, thế là chúng rút lui an toàn.


Nhờ cơ chế **Database Row Lock** này, Quartz đảm bảo **chỉ có duy nhất 1 Instance được chạy Job tại một thời điểm**, né hoàn toàn bẫy trùng lặp dữ liệu.

## 💡 Câu hỏi tình huống tầm Senior về Spring Quartz

### 💬 Tình huống: "Hệ thống của em đang chạy Quartz Cluster. Một Job cấu hình chạy mất 10 phút, nhưng Trigger lại set 5 phút chạy 1 lần. Hiện tượng gì sẽ xảy ra và em cấu hình thế nào để ngăn chặn việc Job cũ chưa xong mà Job mới đã lao vào?"

-   **Phân tích bản chất:** Theo mặc định, Quartz cho phép các Job chạy **song song đồng thời (Concurrent)**. Nếu lúc 12:00 Job chạy (dự kiến đến 12:10 mới xong), thì đúng 12:05, Trigger lại kích hoạt và Quartz sẽ mở tiếp một Thread nữa để chạy chính cái Job đó. Việc này gây quá tải CPU, cạn kiệt Thread Pool và làm sai lệch logic nghiệp vụ.

-   **Cách xử lý của Senior:**

    Để bắt Quartz phải đợi Job cũ chạy xong hoàn toàn mới được kích hoạt lượt tiếp theo, anh chỉ cần đặt Annotation **`@DisallowConcurrentExecution`** ngay trên đầu Class triển khai `Job` đó.


Java

```
@DisallowConcurrentExecution // 🎯 Từ khóa vàng cứu cánh hệ thống
public class DataProcessingJob implements Job {
    @Override
    public void execute(JobExecutionContext context) {
        // Logic chạy nặng, mất 10 phút
    }
}

```

-   **Cơ chế RAM/DB lúc này:** Khi dính annotation này, Quartz sẽ khóa cái `JobDetail` đó lại. Lượt Trigger lúc 12:05 sẽ bị hoãn lại (gọi là trạng thái _Misfire_) cho đến khi lượt 12:00 chạy xong hoàn toàn.


## 📊 Bảng so sánh Kiến trúc: Spring `@Scheduled` vs `Spring Quartz`

**Tiêu chí**

**Spring @Scheduled**

**Spring Quartz (JDBC JobStore)**

**Lưu trữ dữ liệu**

Chỉ trên RAM (Heap).

Xuống các bảng Database (Bền vững dữ liệu).

**Hỗ trợ Cluster**

**Không** (Bị chạy trùng Job trên nhiều instance).

**Có** (Dùng DB Row Lock để điều phối).

**Động (Dynamic Scheduling)**

Khó (Cấu hình cứng bằng code/properties).

**Cực dễ** (Có API để tạo mới, sửa, xóa, dừng Job ngay khi app đang chạy).

**Quản lý lỗi (Misfire)**

Không có cơ chế xử lý khi sập app.

Có cấu hình bù Job nếu lỡ hẹn do sập app (_Misfire Instructions_).

**Độ phức tạp**

Siêu nhẹ, chỉ cần 1 dòng code.

Khá nặng, cần tạo bảng DB và cấu hình Data Source.

