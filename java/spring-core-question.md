# Câu hỏi spring framework
### Common
1. Nêu các thành phần của spring
2. Sự khác nhau giữa spring và spring boot


### Spring boot
1. Spring core, vòng đời
2. Dependency injection là gì
3. Cách inject bean, sự khác nhau, inject bean bằng applicationContext.getBean


### Spring JPA
1. Spring data jpa, hibernate,thành phần cấu trúc, cơ chế hoạt động
2. Có 2 Service A và B đều có annotation @Transaction, service A call Service B. giả sử B không lỗi mà A lỗi thì B có được rollback không? giải thích




### Spring Security
1. Spring security, Các annotation để chặn request, @PreAuth, HasRole?...
2. Các thành phần của JWT, cách hoạt động khi service nhận 1 token và verify
3. Cách sử dụng token trong microservice? (JKS)
4. Hiểu biết về public, private key, hash
5.



### Spring cloud
1. Spring cloud, các thành phần, spring feign, spring rest Template
2. Spring filter chain partten



### Quartz
1. Tại sao phải dùng Quartz?
2. Tách riêng 1 service 1 Service Schedule có được không? Băng cách nào?
3. Không cùng database thì tách biệt kiểu gì?
4. Nếu 1 service có nhiều instance cùng chạy, dùgn annotation @Schedule time bằng nhau hết thì chạy kiểu gì? Cái nào trước cái nào sau, có conflict gì không

### Spring circuit breaker
Các implement? Giải quyết vấn đề gì

### Các thành phần khác

[Spring Boot] Xử lý sự kiện với @EventListener + @Async
