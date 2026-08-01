## 1. Bài toán Làm tròn số và Sai số tích lũy (Rounding & Accumulative Error)

-   **Vấn đề:** Khi tính lãi suất tiết kiệm, phí giao dịch, hoặc tỷ giá hối đoái (ví dụ: lãi suất $4.55\% / \text{năm}$ chia cho 365 ngày), kết quả thường ra các số thập phân vô hạn (ví dụ: `0.01234567...`).

    -   Nếu lập trình viên dùng kiểu dữ liệu `float` hoặc `double` (vốn lưu trữ theo chuẩn nhị phân IEEE 754), hệ thống sẽ bị lỗi làm tròn ngầm (ví dụ: `0.1 + 0.2` trong máy tính sẽ ra `0.30000000000000004`).

    -   Với hàng triệu giao dịch mỗi ngày, sai số vài phần tỷ này tích lũy lại sẽ biến thành khoản chênh lệch khổng lồ lên tới hàng trăm triệu, hàng tỷ đồng.

-   **Giải pháp:**

    -   Trong Java, **tuyệt đối không bao giờ dùng `float` hay `double` để tính tiền**. Bắt buộc phải dùng **`BigDecimal`**. Kiểu dữ liệu này cho phép định nghĩa chính xác số lượng chữ số sau dấu phẩy (Scale) và quy tắc làm tròn bắt buộc (như `RoundingMode.HALF_EVEN` - thuật toán làm tròn của ngân hàng).

    -   _Mẹo lưu trữ:_ Một số hệ thống lớn chọn cách nhân toàn bộ số tiền với 100 hoặc 1000 để chuyển về kiểu số nguyên (`Long`) khi lưu xuống DB (ví dụ: lưu $10,50 \text{ VNĐ}$ thành `1050` xu/mili-đồng), sau đó khi hiển thị mới chia ngược lại.


## 2. Bài toán Đối soát dữ liệu (Reconciliation)

-   **Vấn đề:** Tiền không bao giờ tự nhiên sinh ra hay mất đi, nó chỉ chuyển từ tài khoản này sang tài khoản khác. Khi hệ thống ngân hàng liên kết với các bên thứ ba (Ví dụ: ví điện tử Momo, cổng thanh toán Napas, hoặc tổ chức thẻ Visa/Mastercard), cuối ngày hai bên bắt buộc phải so khớp danh sách giao dịch xem tiền đi và tiền đến có khớp nhau không.

    -   Sẽ luôn có những giao dịch "lơ lửng": Bên ngân hàng báo đã trừ tiền thành công, nhưng bên đối tác báo chưa nhận được do mạng lag đúng lúc.

-   **Giải pháp:**

    -   Hệ thống Backend xây dựng một luồng xử lý chạy ngầm (**Batch Job** - thường dùng Spring Batch) vào lúc 12h đêm. Job này sẽ lấy file danh sách giao dịch (file đối soát) từ bên đối tác về, tự động so sánh với dữ liệu trong DB của ngân hàng.

    -   Các giao dịch lệch sẽ được đẩy vào trạng thái `PENDING_RECONCILE` để hệ thống tự động hoàn tiền (Refund/Rollback) hoặc chuyển cho bộ phận vận hành xử lý thủ công.


## 3. Bài toán Giao dịch phân tán (Distributed Transactions / Saga Pattern)

-   **Vấn đề:** Khi bạn thực hiện chuyển khoản liên ngân hàng từ Ngân hàng A sang Ngân hàng B.

    -   Bước 1: Ngân hàng A trừ tiền tài khoản của bạn thành công.

    -   Bước 2: Hệ thống gọi API sang Ngân hàng B để cộng tiền. Đúng lúc này, mạng sập hoặc Ngân hàng B bị lỗi hệ thống.

    -   Lúc này, tiền của bạn đã bị trừ nhưng bên kia chưa nhận được. Hệ thống rơi vào trạng thái mất tính nhất quán dữ liệu (Data Inconsistency) trên môi trường Microservices.

-   **Giải pháp:**

    -   Không thể dùng `@Transactional` thông thường của Spring vì hai database nằm ở hai ngân hàng khác nhau. Hệ thống phải áp dụng **Saga Pattern**.

    -   Nếu Bước 2 thất bại, hệ thống Saga sẽ kích hoạt một hành động bù đắp (**Compensating Transaction**), cụ thể là tự động thực hiện một lệnh "Cộng lại tiền" vào tài khoản của bạn ở Ngân hàng A kèm theo trạng thái "Giao dịch thất bại, hoàn tiền".


## 4. Bài toán Đóng băng tài khoản / Giữ tiền (Hold/Block Balance)

-   **Vấn đề:** Khi bạn quẹt thẻ tín dụng để đặt phòng khách sạn hoặc thuê xe tự lái, khách sạn sẽ không trừ tiền ngay mà họ sẽ "giữ" (Hold) một khoản tiền cọc trong tài khoản của bạn (ví dụ: 2 triệu đồng). Khoản tiền này không mất đi, nhưng bạn không được phép chi tiêu nó. Sau khi bạn trả phòng an toàn, số tiền này mới được giải phóng (Un-hold).

-   **Giải pháp:**

    -   Trong DB, bảng `accounts` không chỉ có một cột `balance`. Nó bắt buộc phải có ít nhất 3 cột:

        -   `actual_balance` (Số dư thực tế thực có).

        -   `available_balance` (Số dư khả dụng được phép tiêu).

        -   `blocked_balance` (Số dư đang bị đóng băng).

    -   Công thức tính luôn là: `available_balance = actual_balance - blocked_balance`. Khi có lệnh Hold, hệ thống chỉ tăng `blocked_balance` và giảm `available_balance`, tiền vẫn nằm nguyên ở tài khoản cho đến khi có lệnh Capture (Trừ thật) hoặc Release (Nhả ra).


## 5. Bài toán Nhật ký kiểm toán tiền (Audit Trail / Ledger)

-   **Vấn đề:** Để chống gian lận nội bộ (ví dụ: một lập trình viên có quyền truy cập DB tự ý vào sửa cột `balance` của mình từ 1 triệu thành 1 tỷ), ngân hàng không bao giờ tin tưởng vào một con số tổng ở cột `balance`.

-   **Giải pháp:**

    -   Áp dụng tư duy **Ledger (Sổ cái)** giống như Blockchain. Bảng số dư (`accounts`) chỉ là bảng phụ để hiển thị nhanh. Bản chốt chặn tối thượng là bảng `transactions_ledger` (Nhật ký giao dịch).

    -   Bảng này tuân theo nguyên tắc **Append-Only** (Chỉ được ghi thêm dòng mới, cấm tuyệt đối lệnh `UPDATE` hoặc `DELETE`). Mỗi dòng tiền biến động (ví dụ: +50k, -20k) sẽ được ghi thành một dòng log tài chính. Số dư cuối cùng phải bằng tổng (SUM) của tất cả các dòng log từ ngày tài khoản được tạo ra. Nếu ai đó sửa lén cột `balance` ở bảng chính, hệ thống đối soát chạy lại lệnh `SUM` ở bảng sổ cái thấy lệch lập tức sẽ khóa tài khoản đó lại và báo động.