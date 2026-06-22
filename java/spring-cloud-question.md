### REFERENCE: 

Real-Time Spring Boot Interview Questions and Answers [All In One Video]: https://www.youtube.com/watch?v=XilRv9wJhzc


Đã dùng Spring Cloud Gateway, Spring Cloud Feign
Có nên thay thế RestTemplate thành FeignClient không?
- RestTemplate phù hợp với monolith, Feign phù hợp với microservice gom nhóm được các api lại với nhau
- RestClient/RestTemplate phù hợp với các api cần custom phức tạp

| Tính năng kiến trúc       | Công nghệ thời kỳ cũ (Netflix) | Công nghệ hiện đại (khuyến nghị hiện nay) |
| ------------------------- | ------------------------------ | ----------------------------------------- |
| Cổng API Gateway          | Netflix Zuul                   | Spring Cloud Gateway                      |
| Đăng ký / Định vị service | Netflix Eureka                 | Eureka Server hoặc Consul / Nacos         |
| Gọi API giữa services     | RestTemplate / Ribbon          | OpenFeign + Spring Cloud LoadBalancer     |
| Cầu chì (Circuit Breaker) | Netflix Hystrix                | Resilience4j                              |
| Quản lý cấu hình          | Spring Cloud Config            | Config Server hoặc Nacos / Consul Config  |
