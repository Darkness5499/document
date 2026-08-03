
# Tại Sao Hiện Nay Không Cần Viết `Serializable` Trong Code?

Trong các ứng dụng Java Enterprise hiện đại (Spring Boot), lập trình viên không còn phải viết `implements Serializable` vì các Framework đã thay thế cơ chế mặc định của Java bằng các chuẩn mở, tối ưu hơn:

1. **Giao tiếp API:** Dữ liệu được chuyển đổi thành định dạng **JSON** thông qua thư viện **Jackson Framework**.
2. **Tương tác Database:** Dữ liệu được bóc tách thành các kiểu dữ liệu nguyên thủy (Primitive) để lưu vào các cột của bảng thông qua **Hibernate / JDBC Driver**.

### ⚠️ Các trường hợp hiếm hoi vẫn bắt buộc cần `Serializable` trong Modern Java:
* Cấu hình đồng bộ hóa HTTP Session giữa các Server (Session Clustering).
* Sử dụng bộ cấu hình mặc định của `Spring Cache` để lưu Object nguyên khối vào **Redis** (Nếu không chuyển cấu hình sang dạng JSON serialization).