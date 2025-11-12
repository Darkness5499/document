### Dự án BCCS3 Viettel
Công nghệ sử dụng: Saga, Kafka, Redis, Docker, Jipkins, Keycloak, SonarQube,...
Việc đã làm:
    - Upload download file cấu hình
    - ...
Mô tả luồng hoạt động:
    - Sau khi hoàn thành hết phần nhập liệu, data các bước sẽ được cache lên redis
    - Khi hoàn thành các bươc, data sẽ bắt đầu call api chạy luồng 
    - Saga-service chịu trách nhiệm chuẩn bị dữ liệu và đẩy cho các service khác thực thi
    - khi các service khác hoàn thành sẽ bắn message thông qua kafka cho saga
    - Các service con chạy luồng dựa trên camunda bpmn dưới dạng service task
    - các bước bắn message đều được lưu vào 1 bảng có cùng traceID để lưu trữ data trace log
    - Zipkins có trách nhiệm trace log thông quan traceid
    - chức năng tìm kiếm hợp đồng được đẩy lên elastic seach để tổng hợp thông tin giúp việc tìm kiếm nhanh hơn


### Dự án CRA
    1. Chức năng đồng bộ dữ liệu từ CRA MB
    2. Chức năng kiểm tra CRA, public cho bên ngoài dùng
    3.

3. Dự án CIC
    1. chức năng truy vấn đơn
    2. chức năng upload
    3. chức năng sử dụng quart job tự động update bản ghi >30 days, đồng bộ cic ngân hàng nhà nước
    4. Chức năng upload dữ liệu test XML
4. Dự án BPM
    1. đổi giao diện + api phân quyền cho user
    2. tích hợp một số API của CIC/CRA sang
5. Dự án BPM Servey

