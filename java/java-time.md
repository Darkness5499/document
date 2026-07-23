# 📑 BẢN TỔNG HỢP CÁC KIỂU DỮ LIỆU DATE/TIME TRONG JAVA

## 1. Nhóm Di Sản Cũ (`java.util.*` và `java.sql.*`) - KHÔNG NÊN DÙNG

Các class này mang bản chất **Mutable** (không an toàn đa luồng), thiết kế lộn xộn (tháng bắt đầu từ 0) và hiện tại chỉ tồn tại để tương thích với các hệ thống legacy (cũ kỹ).

-   **`java.util.Date`**: Kiểu dữ liệu thời gian thô sơ nhất của Java, chứa cả ngày và giờ nhưng thiếu cơ chế quản lý múi giờ chuẩn chỉ.

-   **`java.sql.Date`**: Kiểu bọc (Wrapper) của JDBC cổ điển, **chặt bỏ giờ**, chỉ giữ lại Ngày/Tháng/Năm để map với cột `DATE` của SQL.

-   **`java.sql.Time`**: Ngược lại với bản SQL Date, nó **chặt bỏ ngày**, chỉ giữ lại Giờ/Phút/Giây để map với cột `TIME` của SQL.

-   **`java.sql.Timestamp`**: Class giữ cả ngày, giờ, chính xác đến **nanogiây** và chạy theo múi giờ hệ điều hành của máy chủ (System Timezone). Map với cột `TIMESTAMP` hoặc `DATETIME`.


## 2. Nhóm Hiện Đại (`java.time.*` - Java 8+) - KHUYẾN NGHỊ DÙNG 100%

Được thiết kế theo triết lý **Immutable** (Bất biến, an toàn tuyệt đối cho đa luồng), phân tách rạch ròi theo từng mục đích nghiệp vụ.

### 🔹 Nhóm Không Chứa Múi Giờ (Local - Thời gian treo tường)

-   **`LocalDate`**: Chỉ có Ngày/Tháng/Năm (Ví dụ: `2026-06-23`). Dùng cho ngày sinh nhật, ngày lễ.

-   **`LocalTime`**: Chỉ có Giờ/Phút/Giây (Ví dụ: `15:45:00`). Dùng cho giờ mở cửa, giờ đặt báo thức.

-   **`LocalDateTime`**: Gồm cả ngày và giờ (Ví dụ: `2026-06-23T15:45:00`). Dùng cho lịch hẹn cố định của một địa điểm quốc gia.


### 🔹 Nhóm Chứa Múi Giờ (Global - Thời gian vật lý toàn cầu)

-   **`Instant`**: Điểm mốc thời gian tuyệt đối của vũ trụ tính từ mốc năm 1970, luôn chạy theo **chuẩn quốc tế UTC** (Ví dụ: `2026-06-23T08:45:00Z`). **Đây là lựa chọn bắt buộc cho các cột `created_at`, `updated_at` trong kiến trúc Microservices.**

-   **`ZonedDateTime`**: Ngày + Giờ + Múi giờ cụ thể của vùng (Ví dụ: `2026-06-23T15:45:00+07:00[Asia/Ho_Chi_Minh]`). Dính kèm ID múi giờ để tính toán lịch bay xuyên quốc gia, giao dịch chứng khoán toàn cầu.


## 📊 BẢNG MA TRẬN DỊCH CHUYỂN TƯ DUY (MAPPING DATABASE)

Khi thiết kế Entity với Spring Data JPA hoặc Hibernate, anh Alex hãy bỏ qua hoàn toàn các class `java.sql.*` và map thẳng từ Java 8 xuống SQL theo chuẩn sau:

**Nghiệp vụ hệ thống**

**Kiểu cũ (java.sql.*)**

**Kiểu mới (java.time.*)**

**Kiểu dữ liệu dưới SQL (Postgres/MySQL)**

Lưu ngày sinh, ngày cấp CCCD

`Date`

**`LocalDate`**

`DATE`

Giờ chạy Cron Job, giờ bảo trì hàng ngày

`Time`

**`LocalTime`**

`TIME`

Lịch hẹn, sự kiện tại 1 địa điểm vật lý

`Timestamp`

**`LocalDateTime`**

`DATETIME` / `TIMESTAMP`

**Vết hệ thống (`created_at`, `updated_at`)**

`Timestamp`

**`Instant`**

`TIMESTAMP WITH TIME ZONE` (hoặc `BIGINT` dạng Epoch)