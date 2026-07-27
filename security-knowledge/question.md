## Các loại tấn công cơ bản

# 🔐 Các loại tấn công phổ biến & Cách phòng tránh

| Loại tấn công | Khái niệm | Cách phòng tránh |
|---------------|-----------|------------------|
| **SQL Injection (SQLi)** | Kẻ tấn công chèn code SQL vào tham số đầu vào để thao túng DB (SELECT/UPDATE/DELETE). | - Luôn dùng **Prepared Statements** / Parameterized Query. <br> - Không build query bằng string. <br> - Validate input. <br> - Sử dụng ORM (Hibernate/JPA). |
| **Cross-Site Scripting (XSS)** | Chèn script độc hại vào web để chạy trên trình duyệt người dùng. | - Escape output (HTML, JS, URL). <br> - Dùng thư viện chống XSS (OWASP ESAPI). <br> - Bật Content Security Policy (CSP). |
| **Cross-Site Request Forgery (CSRF)** | Kẻ tấn công lợi dụng session của user để gửi request trái phép. | - Sử dụng CSRF Token. <br> - Dùng SameSite cookie. <br> - Verifying Origin/Referer header. |
| **Command Injection** | Nhúng lệnh hệ điều hành vào input để thực thi OS command. | - Không truyền input trực tiếp vào shell. <br> - Dùng API thay vì shell (ProcessBuilder). <br> - Validate & sanitize input. |
| **Directory Traversal** | Kẻ tấn công truy cập file hệ thống bằng đường dẫn như `../../etc/passwd`. | - Không cho phép path từ input. <br> - Chuẩn hóa đường dẫn (path normalization). <br> - Chỉ cho phép truy cập whitelist directory. |
| **Broken Authentication** | Lỗi auth cho phép chiếm tài khoản, brute-force, token rò rỉ. | - Dùng JWT/Session an toàn. <br> - Bật rate limit, lock account. <br> - Lưu mật khẩu dạng bcrypt/scrypt. |
| **Broken Access Control** | Bypass RBAC, truy cập API không được phép, sửa dữ liệu người khác. | - Kiểm tra quyền ở backend (server-side). <br> - Không tin data từ client. <br> - Dùng attribute-based access control. |
| **Insecure Deserialization** | Deserialize object độc hại dẫn tới RCE, SQLi… | - Không deserialize object không tin cậy. <br> - Dùng JSON thay object binary. <br> - Dùng allowlist class. |
| **Security Misconfiguration** | Cấu hình sai: mở port, debug mode, header bảo mật thiếu. | - Tắt debug. <br> - Dùng HTTPS. <br> - Bật bảo mật header: HSTS, X-Frame-Options, X-Content-Type. |
| **Sensitive Data Exposure** | Lộ password, token, key, dữ liệu nhạy cảm. | - Mã hóa dữ liệu khi truyền (HTTPS) và khi lưu (AES). <br> - Không log thông tin nhạy cảm. <br> - Dùng secret manager. |
| **API Rate Limit / DDOS** | Kẻ tấn công gửi lượng lớn request làm sập hệ thống. | - Rate limiting (Bucket4j, Nginx). <br> - Load balancer + firewall. <br> - Cache response. |
| **Man-in-the-Middle (MITM)** | Kẻ tấn công chặn và thay đổi dữ liệu giữa client và server. | - Bắt buộc HTTPS. <br> - Kiểm tra certificate. <br> - HSTS. |


## checklist security
# 🛡️ Microservices Security Checklist

## 1️⃣ Authentication (Xác thực)
- [ ] Tách Auth Service riêng (Keycloak, OAuth2, OpenID Connect).
- [ ] Không tự viết JWT validation trong mỗi service (dễ sai).
- [ ] Dùng **Access Token (JWT)** + **Refresh Token**.
- [ ] Ký JWT bằng RSA/EC, tránh HS256 trừ khi có yêu cầu đặc biệt.
- [ ] Token phải có thời gian hết hạn (exp).
- [ ] Sử dụng HTTPS cho mọi request (không truyền token qua HTTP).

---

## 2️⃣ Authorization (Phân quyền)
- [ ] Áp dụng RBAC (Role-Based Access Control) hoặc ABAC.
- [ ] Kiểm tra quyền **tại Server-side**, không tin dữ liệu từ frontend.
- [ ] API Gateway enforce permission đầu tiên.
- [ ] Microservice phải tự kiểm tra lại quyền nếu xử lý dữ liệu nhạy cảm.
- [ ] Không đặt logic phân quyền ở frontend.

---

## 3️⃣ API Gateway Security
- [ ] API Gateway validate JWT & các header.
- [ ] Rate limiting (Bucket4j, Nginx, Kong, APIGW).
- [ ] Throttle + IP filtering + geo-blocking (nếu cần).
- [ ] Gateway phải reject request thiếu token hoặc token hết hạn.
- [ ] Gateway phải remove header nhạy cảm trước khi forward (X-API-KEY, Authorization gốc).

---

## 4️⃣ Service-to-Service Security (Internal Communication)
- [ ] Dùng **mTLS** giữa các microservice.
- [ ] Không gọi HTTP plain-text trong internal network.
- [ ] Không dùng API key hard-code.
- [ ] Sử dụng service mesh (Istio / Linkerd) để quản lý cert rotation.
- [ ] Internal API cũng phải auth (đừng nghĩ “internal thì an toàn”).

---

## 5️⃣ Data Security (Dữ liệu)
- [ ] Mã hóa dữ liệu tại REST (AES-256) khi cần.
- [ ] Không log password, token, card number.
- [ ] Dùng Hash + Salt (BCrypt) cho mật khẩu.
- [ ] Secret phải được lưu trong Secret Manager (Vault/K8s Secret).
- [ ] Không commit secret vào Git (bật gitleaks).

---

## 6️⃣ Input Validation & Protections
- [ ] Validate input ở backend (Spring validation).
- [ ] Escape HTML để bảo vệ XSS.
- [ ] Parameterized query để chống SQLi.
- [ ] Sanitize file upload, hạn chế MIME.
- [ ] Chặn size payload quá lớn (limit request size).

---

## 7️⃣ Logging & Monitoring
- [ ] Log theo chuẩn JSON.
- [ ] Mọi request phải có **traceId** (OpenTelemetry / Sleuth).
- [ ] Log suốt vòng đời request cross-service.
- [ ] Không log thông tin nhạy cảm.
- [ ] Dùng ELK/EFK stack để phát hiện tấn công.

---

## 8️⃣ Rate Limiting & DDOS Protection
- [ ] Implement rate limit: IP-level / user-level.
- [ ] Throttle slow client (Poison Pill Attack).
- [ ] Sử dụng CDN (Cloudflare) cho layer 7 protection.
- [ ] Circuit breaker (Resilience4j) chống overload.
- [ ] Queue incoming traffic khi service bị nghẽn.

---

## 9️⃣ Container & K8S Security
- [ ] Chạy container dưới non-root user.
- [ ] Image scanning (Trivy, Clair).
- [ ] Disable privilege mode.
- [ ] Network Policy hạn chế traffic giữa pod.
- [ ] Rotate secret định kỳ.
- [ ] Hạn chế RBAC trong Kubernetes (least privilege).

---

## 🔟 Code & Dependency Security
- [ ] Sử dụng SCA (OWASP Dependency Check, Snyk).
- [ ] Không dùng thư viện cũ version quá 1 năm.
- [ ] Bật security scanning trong CI/CD pipeline.
- [ ] Không deserialize object không tin cậy.
- [ ] Fix log4j-like vulnerabilities ngay lập tức.

---

## 1️⃣1️⃣ Deploy & Infrastructure Security
- [ ] Bắt buộc HTTPS (TLS 1.2+).
- [ ] Bật HSTS.
- [ ] Tường lửa WAF.
- [ ] Giới hạn port open.
- [ ] Mọi service phải chạy dưới least privilege.
- [ ] Bật audit log cho DB, K8s, Gateway.

---

# 🎯 Tóm tắt 1 câu:
**Microservices security = Protect the identity, protect the data, validate everything, isolate components, and monitor continuously.**


## Question 
1. Lưu refresh token, access token ở đâu? logout thì làm gì
