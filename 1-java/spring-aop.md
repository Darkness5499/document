Khái niệm:
- khi nói về Spring AOP (Aspect-Oriented Programming), ta cần hiểu rằng AOP cho phép tách riêng phần logic "phụ trợ" (cross-cutting concerns) — như logging, transaction, security, performance monitoring — khỏi logic chính của ứng dụng

| Annotation                    | Vai trò                                                             | Giải thích                                                                               |
| ----------------------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `@Aspect`                     | Đánh dấu một class là **Aspect**                                    | Class này chứa các “Advice” – tức là code được chạy trước/sau/quanh các method mục tiêu. |
| `@Before("pointcut")`         | Advice chạy **trước** khi method mục tiêu thực thi                  | Dùng để log, kiểm tra quyền, validate input…                                             |
| `@After("pointcut")`          | Advice chạy **sau khi** method kết thúc (dù có exception hay không) | Dùng để cleanup, log kết thúc, hoặc reset context.                                       |
| `@AfterReturning("pointcut")` | Advice chạy **sau khi method trả về thành công**                    | Dùng để log kết quả, cache dữ liệu...                                                    |
| `@AfterThrowing("pointcut")`  | Advice chạy **khi method ném ra exception**                         | Dùng để log lỗi, gửi alert...                                                            |
| `@Around("pointcut")`         | Advice bao quanh **toàn bộ quá trình thực thi** method              | Có thể thay đổi tham số, chặn, hoặc sửa kết quả trả về.                                  |

| Annotation               | Vai trò                                               | Giải thích                                    |
| ------------------------ | ----------------------------------------------------- | --------------------------------------------- |
| `@Pointcut("biểu_thức")` | Định nghĩa **tập hợp các method** sẽ bị “bắt” bởi AOP | Giúp tái sử dụng giữa nhiều advice khác nhau. |

```java
@Aspect
@Component
public class LoggingAspect {

    @Pointcut("execution(* com.example.service.*.*(..))")
    public void serviceLayer() {}

    @Before("serviceLayer()")
    public void logBefore(JoinPoint joinPoint) {
        System.out.println("Before: " + joinPoint.getSignature().getName());
    }

    @AfterReturning(pointcut = "serviceLayer()", returning = "result")
    public void logAfterReturning(Object result) {
        System.out.println("Returned: " + result);
    }

    @AfterThrowing(pointcut = "serviceLayer()", throwing = "ex")
    public void logException(Exception ex) {
        System.out.println("Exception: " + ex.getMessage());
    }
}

```

```java
package com.example.demo.aop;

import java.lang.annotation.*;

@Target(ElementType.METHOD) // annotation áp dụng cho method
@Retention(RetentionPolicy.RUNTIME) // giữ lại ở runtime để AOP đọc được
public @interface LogSystem {
    String value() default ""; // có thể thêm message tùy chọn
}

```

```java
package com.example.demo.aop;

import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

@Slf4j
@Aspect
@Component
public class LogSystemAspect {

    @Around("@annotation(logSystem)") // bắt tất cả method có @LogSystem
    public Object logExecution(ProceedingJoinPoint joinPoint, LogSystem logSystem) throws Throwable {
        long start = System.currentTimeMillis();
        String methodName = joinPoint.getSignature().toShortString();
        Object[] args = joinPoint.getArgs();

        log.info("🚀 Start: {} | Args: {}", methodName, args);

        try {
            Object result = joinPoint.proceed(); // thực thi method gốc
            long duration = System.currentTimeMillis() - start;

            log.info("✅ End: {} | Result: {} | Duration: {}ms", methodName, result, duration);
            return result;
        } catch (Throwable ex) {
            log.error("❌ Exception in {} | Message: {}", methodName, ex.getMessage());
            throw ex;
        }
    }
}

```

