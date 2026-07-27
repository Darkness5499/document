# Các việc đã làm

## Dự án BCCS3 Viettel

- Công nghệ: Saga, Kafka, Redis, Docker, Jenkins, Keycloak, SonarQube

### Việc đã làm
- Upload / download file cấu hình
- ...

### Mô tả luồng hoạt động
- Sau khi hoàn thành phần nhập liệu, dữ liệu ở các bước được cache lên Redis.
- Khi hoàn tất, hệ thống gọi API để chạy luồng xử lý.
- Saga-service chịu trách nhiệm chuẩn bị dữ liệu và đẩy cho các service khác thực thi.
- Các service khác hoàn thành sẽ gửi message qua Kafka cho Saga.
- Các service con chạy luồng dựa trên Camunda BPMN dưới dạng Service Task.
- Các bước gửi message được lưu vào bảng có cùng traceID để lưu trace log.
- Zipkin dùng traceID để trace log phân tán.
- Chức năng tìm kiếm hợp đồng được đẩy lên Elasticsearch để tối ưu tra cứu.
- Dữ liệu giữa các luồng lưu trạng thái; rollback mềm và tạo giao dịch đền bù khi cần.
- Dữ liệu luồng lưu vào bảng tramCDC ở saga service để xử lý tiếp khi một service sập hoặc message chưa được consume.

## Dự án CRA/CIC

### Tổng quan & chức năng chính
- Đồng bộ dữ liệu từ CRA (MB).
- Kiểm tra CRA và public API cho bên ngoài.
- CIC: truy vấn đơn, upload file, tạo annotation.
- Thiết kế động cho các cột Excel bằng Java Reflection để code linh hoạt và dễ đọc.
- Sử dụng Quartz job để tự động cập nhật bản ghi > 30 ngày; đồng bộ CIC với Ngân hàng Nhà nước và MB.
- Upload dữ liệu test XML.
- Tổng hợp dữ liệu cho bên thứ ba; sử dụng EXPLAIN để tối ưu chiến lược thực thi DB; dùng bulk collection để giảm số lần gọi.
- Upload/download file bằng streaming để tránh đọc toàn bộ vào RAM.
- Sử dụng Keycloak để phân quyền (realm, BPM-provider).
- Dùng đa luồng để gọi CIC/CRA.
- Xuất PDF từ Word bằng thư viện .NET.
- Ghi log bằng Spring AOP, tách biệt khỏi business logic.

## Dự án BPM

- Đổi giao diện và API phân quyền cho người dùng.
- Tích hợp một số API của CIC/CRA.

### Kiến trúc & hành vi
- BPM là hệ thống lớn, gồm nhiều service; mục tiêu chính: quy trình cho vay (đề xuất → thẩm định → giải ngân).
- Phân quyền theo RBAC: role, right, user, permission, right_role.
- Sử dụng Keycloak cho authentication/authorization giữa các service.
- BPM hoạt động theo Choreography: mỗi service xử lý khi nhận message Kafka; không có bên điều phối tập trung.

### Runtime & thực thể
- Khi khởi tạo luồng mới sẽ tạo một ProcessInstance lưu trạng thái, bước hiện tại.
- Thực thể chính: ServiceTask (tự động) và UserTask (tương tác người dùng).
- Dùng ServiceRegistry để ánh xạ tên task tới handler tương ứng; tránh tạo quá nhiều message Kafka.
- Với UserTask: engine đặt trạng thái Task là Waiting rồi dừng; khi user hoàn thành gọi `completeTask` để resume luồng.
- RuntimeEngine thực chất là 1 vòng loop, chạy hết task này thì đến task khác, gặp usertask thì tạo Task, status là Waiting
khi task được user hoàn thành thì sẽ move tới task tiếp theo, gọi lại BPM engine để chạy tiếp luồng
- Mỗi bước có Step ID; khi trả lại hồ sơ thì set lại Step ID tương ứng.
- Luồng con: tổng hợp các bước liên quan thành một luồng con để quản lý gọn hơn.

## Ghi chú
- Màn hình quản lý luôn có hồ sơ đến, hồ sơ đi, trạng thái.
- Tối ưu database và bulk operations là yếu tố quan trọng để giảm tải.

