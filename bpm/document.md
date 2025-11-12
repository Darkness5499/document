https://viblo.asia/p/cung-tim-hieu-ve-business-process-modeling-notation-bpmn-Qbq5Qm8m5D8

Mô tả luồng BPM MB
1. Tạo 1 Process defination = 1 mô bình BPM
2. Lưu vào DB, dạng microservice chung db
3. đọc luồng, clone sang 1 bảng Process Instance thể hiện luồng đang hoạt động
4. Nếu gặp service task => chạy thông thường, nếu gặp user task -> dừng lại, cho người dùng hoàn thành tác vụ và gọi complete-task để trigger bpm engine tiếp tục chạy
5. mỗi màn hình là 1 user task, sẽ được gắn UUID riêng, khi bâm vào tác vụ FE sẽ load màn hình tương ứng cho user
6. mỗi khi hoàn thành tác vụ -> bắn message lên kafka bao gồm thông tin người dùng điền của tác vụ đó
7. nếu muốn quay lại bước trước dùng gateway
8. 
