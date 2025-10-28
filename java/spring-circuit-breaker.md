Rất hay 👏 — Circuit Breaker là một pattern cực kỳ quan trọng trong các hệ thống microservices và được Spring Cloud Resilience4j hỗ trợ rất mạnh mẽ.
Mình sẽ giải thích theo kiểu phỏng vấn thực tế để bạn vừa hiểu concept, vừa nhớ cách dùng trong Spring Boot nhé 👇

⚙️ 1️⃣ Circuit Breaker là gì?

Circuit Breaker (CB) là một cơ chế bảo vệ hệ thống khi một service con hoặc API phụ thuộc bị lỗi hoặc quá tải, giúp tránh lan truyền lỗi sang các service khác.

🧠 Giống như cầu chì trong mạch điện — khi dòng điện quá tải thì cầu chì “ngắt mạch”, tránh cháy cả hệ thống.

💥 2️⃣ Vấn đề thực tế mà Circuit Breaker giải quyết

Giả sử bạn có 2 service:

Order Service  --->  Payment Service


Khi Payment Service bị chậm hoặc down, mỗi request từ Order Service lại:

gọi sang Payment,

đợi timeout,

retry liên tục → gây tắc nghẽn tài nguyên (thread, connection),

dẫn đến cascade failure (sụp cả hệ thống).

Circuit Breaker sẽ tự động:

Phát hiện lỗi hoặc timeout liên tục.

“Mở mạch” (open circuit) — tạm ngưng gửi request sang Payment.

Sau một thời gian, “nửa mở” (half-open) để thử lại.

Nếu ổn, “đóng mạch” (close circuit) để phục hồi lưu thông.

🔁 3️⃣ Các trạng thái của Circuit Breaker
Trạng thái	Ý nghĩa
Closed	Mạch đóng, request gửi bình thường
Open	Phát hiện lỗi liên tục → ngắt kết nối, ném lỗi ngay lập tức
Half-Open	Sau thời gian “cool down”, thử cho phép một số request để test
Back to Closed	Khi test thành công, hệ thống ổn định trở lại
🧩 4️⃣ Cách triển khai trong Spring Boot (Resilience4j)

Cài dependency:

<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot2</artifactId>
    <version>1.7.1</version>
</dependency>


Annotation:

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/order")
public class OrderController {

    @GetMapping("/{id}")
    @CircuitBreaker(name = "paymentService", fallbackMethod = "fallbackPayment")
    public String getOrder(@PathVariable Long id) {
        // gọi sang service khác
        return callPaymentService(id);
    }

    public String fallbackPayment(Long id, Throwable ex) {
        return "⚠️ Payment service unavailable, please try again later!";
    }
}

⚙️ 5️⃣ Cấu hình trong application.yml
resilience4j:
circuitbreaker:
instances:
paymentService:
registerHealthIndicator: true
slidingWindowSize: 10
failureRateThreshold: 50
waitDurationInOpenState: 5s
permittedNumberOfCallsInHalfOpenState: 3
minimumNumberOfCalls: 5


Ý nghĩa:

failureRateThreshold: 50 → Nếu 50% request lỗi, sẽ mở mạch.

waitDurationInOpenState: 5s → Sau 5 giây thử lại (half-open).

slidingWindowSize: 10 → đánh giá trên 10 request gần nhất.

💡 6️⃣ So sánh Circuit Breaker với Retry & Fallback
Pattern	Mục tiêu
Retry	Thử gọi lại vài lần trước khi báo lỗi
Fallback	Cung cấp kết quả thay thế khi service lỗi
Circuit Breaker	Ngắt tạm thời kết nối đến service lỗi, tránh overload

→ Trên thực tế, ba cái này thường kết hợp với nhau trong Spring Cloud Resilience4j.

🧱 7️⃣ Case thực tế

Ví dụ khi Payment Service bị lỗi:

Lần đầu → Retry vài lần.

Lỗi nhiều → Circuit Breaker mở.

Trong thời gian open → Request nào đến cũng được fallback luôn.

Sau vài giây → CB thử “half-open”. Nếu thành công → đóng lại.

✅ 8️⃣ Tóm tắt để trả lời phỏng vấn:

Circuit Breaker is a design pattern used to prevent cascading failures when a downstream service is slow or unavailable.
In Spring Boot, it’s implemented via Resilience4j or Hystrix (legacy).
It monitors failures and switches between CLOSED, OPEN, and HALF-OPEN states to protect the system.
It can be combined with Retry and Fallback mechanisms for resilience.