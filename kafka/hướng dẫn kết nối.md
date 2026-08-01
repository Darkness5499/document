
## 1. Khai báo Dependency (`pom.xml`)

Thêm thư viện Spring Kafka vào dự án Spring Boot của anh:

XML

```
<dependency>
    <groupId>https://mvnrepository.com/artifact/org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>

```

## 2. Lớp Cấu hình Vật lý (Kafka Configuration Class)

Thay vì cấu hình trong `application.yml` dễ bị gõ sai tên thuộc tính, ta viết class Java dùng `@Configuration` để quản lý chặt chẽ cấu trúc đa luồng.

Java

```
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.*;
import org.springframework.kafka.listener.ContainerProperties;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class KafkaConfig {

    private final String bootstrapServers = "localhost:9092"; // Thay bằng IP Cụm KRaft của anh

    // ================= PRODUCER CONFIG =================
    @Bean
    public ProducerFactory<String, String> producerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        
        // Cấu hình an toàn & hiệu năng cao như anh em mình đã mổ xẻ
        configProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true"); // Bật Idempotence chống trùng mạng
        configProps.put(ProducerConfig.ACKS_CONFIG, "all");               // Zero Data Loss
        configProps.put(ProducerConfig.BATCH_SIZE_CONFIG, 65536);          // Gom lô 64KB
        configProps.put(ProducerConfig.LINGER_MS_CONFIG, 5);               // Đợi 5ms gom lô
        return new DefaultKafkaProducerFactory<>(configProps);
    }

    @Bean
    public KafkaTemplate<String, String> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }

    // ================= CONSUMER CONFIG =================
    @Bean
    public ConsumerFactory<String, String> consumerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        configProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        configProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        
        // Kiểm soát "Sợi dây sinh mệnh" để né thảm họa Rebalance
        configProps.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 45000);       // 45s mất heartbeat => chết
        configProps.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, 300000);   // SLA xử lý batch tối đa 5 phút
        configProps.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 500);          // Kích thước lô vừa vặn (500 tin)
        configProps.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);       // Tắt Auto Commit để quản lý Manual
        return new DefaultKafkaConsumerFactory<>(configProps);
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, String> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, String> factory = 
                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        factory.setBatchListener(true); // BẬT CHẾ ĐỘ NUỐT TIN THEO BATCH ĐỂ TĂNG TPS XÉ GIÓ
        
        // Quản lý Commit thủ công sau khi xử lý xong nghiệp vụ
        factory.getContainerProperties().setAckMode(ContainerProperties.AckMode.MANUAL_IMMEDIATE);
        return factory;
    }
}

```

## 3. Cơ chế Gửi Message (Kafka Producer Service)

Sử dụng `KafkaTemplate` để bắn dữ liệu bất đồng bộ. Nhớ truyền **Message Key** (`customerId` hoặc `taskId`) để định tuyến chuẩn Partition.

Java

```
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;
import java.util.concurrent.CompletableFuture;

@Service
public class LoanProducerService {

    private final KafkaTemplate<String, String> kafkaTemplate;

    public LoanProducerService(KafkaTemplate<String, String> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendLoanEvent(String taskId, String messageJson) {
        // Bắn tin kèm Key (taskId) để giữ đúng thứ tự vật lý trong Partition
        CompletableFuture<SendResult<String, String>> future = 
                kafkaTemplate.send("mb.credit.lending.bpm.events", taskId, messageJson);

        // Đăng ký Callback xử lý kết quả mạng cơ học
        future.whenComplete((result, ex) -> {
            if (ex == null) {
                System.out.println("Sent success! Offset: " + result.getRecordMetadata().offset());
            } else {
                System.err.println("Sent failed due to: " + ex.getMessage());
                // Luồng xử lý bù (Retry/Ghi log lỗi) nằm ở đây
            }
        });
    }
}

```

## 4. Cơ chế Nhận Message (Kafka Consumer Listener)

Hàm Listener nhận dữ liệu đầu vào là một `List<String>` (vì ta đã bật chế độ Batch Listener ở Class Config).

Java

```
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class LoanConsumerListener {

    // concurrency = "3": Tự động đẻ ra 3 Thread Java phục vụ cho 3 Partition độc lập
    @KafkaListener(
        topics = "mb.credit.lending.bpm.events",
        groupId = "bpm-core-group",
        containerFactory = "kafkaListenerContainerFactory",
        concurrency = "3"
    )
    public void consumeBatch(List<ConsumerRecord<String, String>> records, Acknowledgment ack) {
        System.out.println(">>> Đớp được lô hàng gồm " + records.size() + " messages!");

        try {
            // Vòng lặp cày dữ liệu trên RAM
            for (ConsumerRecord<String, String> record : records) {
                String taskId = record.key();
                String payload = record.value();
                
                // Bước 1: Check Idempotency dưới DB chống trùng tin ở đây
                // Bước 2: Chạy xử lý nghiệp vụ chính của anh
                System.out.println("Processing Task: " + taskId + " with Offset: " + record.offset());
            }

            // CHỈ COMMIT OFFSET KHI CẢ LÔ ĐÃ XỬ LÝ XUỐNG DB THÀNH CÔNG (Zero Data Loss)
            ack.acknowledge(); 

        } catch (Exception e) {
            System.err.println("Lỗi xử lý luồng nghiệp vụ: " + e.getMessage());
            // Tuyệt đối không để crash luồng. Catch lỗi ở đây để ném tin lỗi vào RETRY/DLQ topic
        }
    }
}
```