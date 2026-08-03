Mỗi bài test trong dự án Spring Boot được cấu thành từ 4 thành phần cốt lõi sau:

Framework quản lý (Testing Framework - JUnit 5): Bộ khung quản lý vòng đời bài test, cung cấp các annotation nền tảng như @Test, @BeforeEach, @AfterEach.

Bộ giả lập phụ thuộc (Mocking Framework - Mockito): Công cụ cô lập class cần test bằng cách tạo các đối tượng giả (@Mock) và tiêm chúng vào đối tượng thực tế (@InjectMocks), định nghĩa hành vi giả lập bằng when(...).thenReturn(...).

Hỗ trợ từ Spring (Spring Test Support): Cung cấp các công cụ cấu hình ngữ cảnh (@WebMvcTest, @DataJpaTest) và bộ giả lập request MockMvc để kiểm tra các tầng kiến trúc mà không cần chạy server thật.

Bộ xác minh kết quả (Assertions - AssertJ/JUnit): Các hàm đối chiếu kết quả thực tế với mong đợi như assertEquals(), assertThrows(), hoặc viết theo dạng fluent API như assertThat().isEqualTo()