TÀI LIỆU HƯỚNG DẪN CÀI ĐẶT - TRIỂN KHAI - LƯU Ý DOCKER

| Thành phần                    | Mô tả ngắn                                                 | Ví dụ thực tế                             |
| ----------------------------- | ---------------------------------------------------------- | ----------------------------------------- |
| **Docker Engine**             | Là nhân chính, gồm 3 phần nhỏ: *daemon*, *REST API*, *CLI* | Dịch vụ chạy nền quản lý container        |
| **Docker Daemon (`dockerd`)** | Quản lý images, containers, networks, volumes              | Tự động khởi động khi bật máy             |
| **Docker CLI (`docker`)**     | Công cụ dòng lệnh để tương tác với daemon                  | `docker run`, `docker ps`, `docker build` |
| **Docker Image**              | Mẫu "read-only" chứa toàn bộ môi trường chạy app           | `openjdk:17-jdk-slim`, `nginx:latest`     |
| **Docker Container**          | Thực thể đang chạy (từ image)                              | Một instance của app                      |
| **Dockerfile**                | File mô tả cách build image                                | Dùng `FROM`, `COPY`, `RUN`...             |
| **Docker Hub / Registry**     | Nơi lưu trữ và chia sẻ images                              | `hub.docker.com`, `ghcr.io`               |
| **Volume**                    | Lưu trữ dữ liệu bền vững                                   | Database data, log files                  |
| **Network**                   | Kết nối các container                                      | `bridge`, `host`, `overlay`               |

🔹 2. Luồng hoạt động tổng quát
- Dockerfile → Build → Image → Run → Container

🔹 3. Ví dụ dockerfile
 ```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/myapp.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]

```
🔹 4. Các lệnh trong dockerfile


