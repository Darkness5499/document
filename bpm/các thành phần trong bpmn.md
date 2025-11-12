##  🧩 Tổng quan về các thành phần chính trong BPMN

BPMN chia các phần tử (elements) thành 4 nhóm lớn:
- 1️⃣ Flow Objects (các đối tượng dòng chảy chính)
- 2️⃣ Connecting Objects (các liên kết giữa các đối tượng)
- 3️⃣ Swimlanes (phân chia vai trò / tổ chức)
- 4️⃣ Artifacts (ghi chú, dữ liệu bổ trợ)


### 🧠 I. Flow Objects – Các phần tử “chạy được” trong process

Đây là trái tim của quy trình, gồm 3 loại chính:

| Loại         | Vai trò                                     | Ví dụ thực tế                          |
| ------------ | ------------------------------------------- | -------------------------------------- |
| **Event**    | Thể hiện “điều gì xảy ra”                   | Bắt đầu, kết thúc, nhận message, timer |
| **Activity** | “Công việc” cần làm (tự động hoặc thủ công) | Gọi API, gửi email, duyệt đơn          |
| **Gateway**  | Điều hướng dòng chảy (rẽ nhánh / hợp nhất)  | Nếu >100 thì duyệt, ngược lại từ chối  |

### 1️⃣ Event (Sự kiện)

Các loại event thường gặp:

| Event                  | Biểu tượng        | Ý nghĩa                                               |
| ---------------------- | ----------------- | ----------------------------------------------------- |
| **Start Event**        | ○                 | Điểm bắt đầu process                                  |
| **End Event**          | ●                 | Kết thúc process                                      |
| **Intermediate Event** | ◎                 | Xảy ra giữa process (như chờ timer, nhận message)     |
| **Boundary Event**     | ⊗ (gắn cạnh task) | Bắt lỗi hoặc event bên ngoài trong khi task đang chạy |

### 2️⃣ Activity (Hoạt động)

| Activity               | Ý nghĩa                                               | Behavior trong Camunda             |
| ---------------------- | ----------------------------------------------------- | ---------------------------------- |
| **Task**               | Công việc đơn giản                                    | `TaskActivityBehavior`             |
| **User Task**          | Task cho người dùng thao tác                          | `UserTaskActivityBehavior`         |
| **Service Task**       | Task tự động (JavaDelegate, REST call, external task) | `ServiceTaskBehavior`              |
| **Script Task**        | Chạy script inline (Groovy, JS…)                      | `ScriptTaskActivityBehavior`       |
| **Manual Task**        | Task thực hiện ngoài hệ thống                         | Không có behavior engine           |
| **Business Rule Task** | Gọi DMN (decision table)                              | `BusinessRuleTaskActivityBehavior` |
| **Receive Task**       | Chờ message                                           | `ReceiveTaskActivityBehavior`      |

### 3️⃣ Gateway (Cổng điều hướng)

Dùng để rẽ nhánh hoặc hợp nhất flow.

| Gateway                     | Biểu tượng | Ý nghĩa                 | Behavior                 |
| --------------------------- | ---------- | ----------------------- | ------------------------ |
| **Exclusive Gateway (XOR)** | ⊕          | chỉ chọn 1 nhánh        | Evaluate condition       |
| **Parallel Gateway (AND)**  | ⊗          | chạy song song          | Fork/join token          |
| **Inclusive Gateway (OR)**  | ◑          | có thể chọn nhiều nhánh | Evaluate nhiều condition |
| **Event-Based Gateway**     | ⭕          | chờ event xảy ra        | Wait for event trigger   |
| **Complex Gateway**         | ⚙️         | logic phức tạp          | ít dùng                  |

### 🔗 II. Connecting Objects – Các phần tử nối
| Element           | Biểu tượng | Vai trò                               |
| ----------------- | ---------- | ------------------------------------- |
| **Sequence Flow** | →          | Chỉ hướng luồng logic trong quy trình |
| **Message Flow**  | --╌╌>      | Trao đổi giữa 2 pool khác nhau        |
| **Association**   | ---        | Liên kết artifact hoặc data object    |

### III. Swimlanes – Phân quyền / tổ chức
| Thành phần | Vai trò                           | Ý nghĩa trong Camunda                    |
| ---------- | --------------------------------- | ---------------------------------------- |
| **Pool**   | Đại diện cho 1 tổ chức / hệ thống | Mỗi pool thường là 1 participant process |
| **Lane**   | Đại diện cho 1 vai trò / bộ phận  | Có thể map sang assignee, candidateGroup |


🔹 Các thành phần chính:

| Thành phần             | Vai trò                                         |
| ---------------------- | ----------------------------------------------- |
| **Process Engine**     | Lõi chính (Engine API) – điều phối mọi thứ      |
| **Repository Service** | Quản lý process definition (deploy BPMN, DMN)   |
| **Runtime Service**    | Start, stop, quản lý process instance đang chạy |
| **Task Service**       | Quản lý User Task                               |
| **History Service**    | Truy vấn lịch sử                                |
| **Job Executor**       | Chạy background jobs (async, timer)             |
| **Persistence Layer**  | ORM layer dùng MyBatis để lưu dữ liệu           |
