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

