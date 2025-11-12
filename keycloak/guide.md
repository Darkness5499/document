TÀI LIỆU HƯỚNG DẪN CÀI ĐẶT - TRIỂN KHAI KEYCLOAK

| Thực thể                                | Vai trò                                                                | Ví dụ trong hệ thống của bạn                  |
| --------------------------------------- | ---------------------------------------------------------------------- | --------------------------------------------- |
| **Authentication Server (Auth Server)** | Cấp token, xác thực người dùng hoặc client, quản lý user, role, client | Keycloak                                      |
| **Resource Server**                     | Server chứa dữ liệu / API, verify token trước khi trả dữ liệu          | Spring Boot microservice (10 service của bạn) |
| **Resource Owner**                      | Người sở hữu dữ liệu / quyền truy cập                                  | User cuối của ứng dụng, nhân viên, khách hàng |
| **Client**                              | Ứng dụng hoặc service muốn truy cập Resource Server                    | Web app, mobile app, microservice khác        |
| **Access Token (JWT)**                  | Token dùng để xác thực và phân quyền                                   | JWT trả từ Keycloak, chứa roles và claims     |
| **Refresh Token**                       | Token dùng để lấy access token mới khi hết hạn                         | JWT trả từ Keycloak                           |
| **Role**                                | Quyền hạn, dùng trong RBAC                                             | ADMIN, USER, MANAGER                          |
| **Permission**                          | Quyền chi tiết, mapping với API hoặc menu                              | READ_USER, WRITE_ORDER                        |
| **User**                                | Người dùng được quản lý trong Keycloak hoặc DB ứng dụng                | Alex, Nhân viên IT                            |


```pgsql
Resource Owner (User)
      |
      | login
      v
Authentication Server (Keycloak)
      |
      | issue Access Token (JWT)
      v
Client (Web App / Microservice)
      |
      | Bearer Token
      v
Resource Server (Spring Boot microservice)
      |
      | verify token, check roles/permissions
      v
API / Data

```


| **Khái niệm**                  | **Mô tả ngắn gọn**                                                         | **Ví dụ / Ghi chú**                                   |
| ------------------------------ | -------------------------------------------------------------------------- | ----------------------------------------------------- |
| 🏰 **Realm**                   | Không gian quản lý độc lập (tenant). Chứa user, role, client, group riêng. | Realm mặc định: `master`. Có thể tạo `my-app-realm`.  |
| 👥 **User**                    | Đại diện cho người dùng thật hoặc hệ thống.                                | Có username, password, role, group, attribute.        |
| 👨‍👩‍👧 **Group**             | Tập hợp user có quyền chung.                                               | `admin`, `staff`, `customer`.                         |
| 🧩 **Client**                  | Ứng dụng hoặc service kết nối đến Keycloak để xác thực.                    | Frontend (React, Angular) hoặc Backend (Spring Boot). |
| 🔑 **Client ID / Secret**      | Định danh và bí mật của client.                                            | `client_id=backend-service`, `client_secret=abc123`.  |
| 🧾 **Role**                    | Quyền truy cập trong hệ thống.                                             | Realm role (`admin`), Client role (`read`, `write`).  |
| 🪪 **Token**                   | Chứng thực người dùng / service.                                           | `Access Token`, `Refresh Token`, `ID Token`.          |
| 🔄 **Authentication Flow**     | Chuỗi các bước xác thực user.                                              | username/password → OTP → success.                    |
| 🧱 **Identity Provider (IdP)** | Cho phép đăng nhập bằng hệ thống khác.                                     | Google, Facebook, Azure AD, GitHub.                   |
| 🔐 **Protocol Mapper**         | Map thuộc tính user vào JWT token.                                         | Thêm `department`, `email`, `role` vào token.         |
| 🧠 **Scope**                   | Phạm vi quyền client được cấp khi lấy token.                               | `openid`, `profile`, `email`.                         |
| 🧾 **Service Account**         | Tài khoản kỹ thuật cho client (machine-to-machine).                        | Dùng với `grant_type=client_credentials`.             |
| ⚙️ **Admin Console**           | Giao diện web quản trị Keycloak.                                           | Tạo realm, user, role, client,...                     |
| ⚙️ **Admin REST API**          | API để thao tác quản lý tự động.                                           | `GET /admin/realms/{realm}/users`                     |
| 🌍 **OIDC Endpoint**           | Endpoint theo chuẩn OpenID Connect.                                        | `/realms/{realm}/.well-known/openid-configuration`    |

