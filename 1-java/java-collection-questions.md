
### 1. Physical Memory Architecture (Cơ chế vật lý)

-   There are two types of memory allocation: **Contiguous allocation** (stored sequentially in RAM) and **Non-contiguous allocation**.

-   `ArrayList` represents contiguous memory, whereas `LinkedList` and `Map` (Hash buckets/nodes) represent non-contiguous memory.


### 2. Concurrency Control (Cơ chế đọc ghi đồng thời)

-   Collections are categorized into **Non-thread-safe** and **Thread-safe** (synchronized).

-   `ArrayList` and `LinkedList` are non-thread-safe. For multithreaded environments, `CopyOnWriteArrayList` or concurrent alternatives should be used.


### 3. Element Ordering (Về mặt thứ tự)

-   `HashMap`/`HashSet` $\rightarrow$ No guaranteed order.

-   `LinkedHashMap`/`LinkedHashSet` $\rightarrow$ Maintains **insertion order**.

-   `TreeMap`/`TreeSet` $\rightarrow$ Maintains **natural sorting order** (or via a custom `Comparator`).

-   _Note:_ `Vector` and `Stack` are legacy classes and are deprecated in modern architecture.


### 4. The Concurrent Branch (Nhánh xử lý đa luồng)

-   **`ConcurrentHashMap`**: Instead of locking the entire table like `Hashtable`, it achieves high concurrency using **CAS (Compare-And-Swap)** algorithms and **Node-level Locking** (on the first node of each bucket). This allows multiple threads to write concurrently to different buckets without cross-blocking.

-   **`CopyOnWriteArrayList`**: Allows lock-free, parallel reads. For write operations, it clones the underlying array in RAM, applies the modifications, and then swaps the array reference.

-   **`BlockingQueue` (`LinkedBlockingQueue`, `ArrayBlockingQueue`)**:

    -   _Under the hood:_ A smart queue mechanism that automatically puts Consumer threads to sleep if the queue is empty, and puts Producer threads to sleep if the queue is full (**Thread Signaling/Backpressure**).

    -   _Application:_ This directly constitutes the internal engine of the Java Thread Pool (`ThreadPoolExecutor`).


### 5. Architectural Takeaways (Bài học kiến trúc)

-   **Divide and Conquer:** The core philosophy of multithreading—breaking data down into smaller segments for isolated processing—is conceptually identical to **Partitions** in Apache Kafka, Database Sharding, or Disk Partitioning.

-   **HashMap Internal Mechanics:** A `HashMap` is essentially an array of nodes (buckets). To optimize lookup time, if the number of elements linked within a single bucket exceeds the threshold of 8 (`TREEIFY_THRESHOLD`) **and** the total capacity is at least 64, Kafka/Java will convert the linked list into a **Red-Black Tree** to guarantee $O(\log n)$ performance.

## 3. LinkedList vs ArrayList (cơ chế CRUD)
- LinkedList: dùng node với con trỏ, các phần tử là node; chèn/xóa nhanh ở giữa/đầu/cuối.
- ArrayList: mảng động; khi vượt quá capacity sẽ copy sang mảng mới (thường tăng ~1.5x); default capacity = 10; truy xuất ngẫu nhiên nhanh O(1).
- đã hiểu bản chất thực sự chưa? khi nó copy sang mảng mới trên ram thì thế nào? nó có phải tìm 1 mảnh đất mới không? hay nối thêm vào đấy?
- có thực sự hiểu việc cấp phát biến, list trong java hoạt động thế nào khi tương tác với ram không?

## 4. Cấu trúc Map/HashMap/TreeMap/Set
- HashMap/HashSet: triển khai bằng mảng các bucket (mỗi bucket là linked list hoặc tree khi collision nhiều).
- Sau khi hash, các giá trị cùng bucket được so sánh bằng equals để tránh duplicate (với Set).
- TreeMap: triển khai bằng cây (ví dụ Red-Black tree) — sắp xếp theo key.

# Java Collections

## List

### ArrayList
- Backed by a dynamic array; resizes automatically.
- Fast random access O(1) for get/set.
- Slow inserts/removes in the middle (O(n)).
- Uses wrapper classes for primitives; cannot store primitives directly.
- Best for frequent reads.

### LinkedList
- Doubly-linked list.
- Slow random access.
- Fast insert/delete (O(1) at ends).
- Higher memory overhead (data + pointers).
- Best for frequent insert/delete operations.

### Vector
- Similar to ArrayList but synchronized (legacy).
- Can store duplicates and maintains insertion order.
- Prefer modern alternatives (e.g., Collections.synchronizedList) for thread-safety.

### Stack (Le)
- Legacy LIFO subclass of Vector.
- Prefer Deque (ArrayDeque or LinkedList) for stack behavior.

## Set

### HashSet
- Unordered; no duplicates; allows one null.
- Fast average performance for add/remove/contains (O(1)).

### LinkedHashSet
- Maintains insertion order; no duplicates; allows one null.
- Slightly slower than HashSet due to linked list maintenance.

### TreeSet
- Sorted (natural order or Comparator); no duplicates; does not allow nulls.
- Operations are O(log n) (Red-Black tree).

### EnumSet
- For enum types; very fast and memory-efficient (bit vectors).

### CopyOnWriteArraySet

- Thread-safe; maintains insertion order; allows one null.
- Good for read-heavy workloads; writes are expensive (copy on modify)
- Trường hợp dùng: Khi hệ thống có bài toán Đọc cực nhiều nhưng Ghi cực ít (Ví dụ: Danh sách cấu hình hệ thống Ngân hàng, nạp vào lúc khởi động, các luồng chỉ vào đọc để chạy nghiệp vụ, cả ngày mới sửa 1 lần).Cơ chế RAM: Nó cho phép tất cả các Thread đọc song song $O(1)$ hoàn toàn không bị block. Khi có một Thread muốn Ghi/Sửa, nó sẽ sao chép (clone) cái mảng đó ra một vùng RAM khác, sửa trên mảng mới rồi hoán đổi con trỏ địa chỉ.

## Queue
- LinkedList: can be used as a queue/deque (doubly-linked).
- PriorityQueue: orders elements by priority (natural order or Comparator).
- ArrayDeque: resizable array-backed deque; good for stack/queue usage.

## Map

### HashMap
- Key-value pairs; fast access via hashing; allows one null key.

### LinkedHashMap
- Maintains insertion (or access) order; predictable iteration.

### TreeMap
- Sorted keys; O(log n) operations; no null keys.

# Kiến Trúc Bộ Nhớ Và Ứng Dụng Của Java `TreeMap`

`TreeMap` là một cấu trúc dữ liệu thuộc nhóm `Map`, hoạt động dựa trên nguyên lý tự động sắp xếp các phần tử dựa theo thứ tự của **Key**.

### ⚙️ Kiến trúc tầng sâu trên RAM
* **Cấu trúc lõi:** Sử dụng thuật toán **Cây Đỏ-Đen (Red-Black Tree)** - một dạng cây tìm kiếm nhị phân tự cân bằng.
* **Cấp phát bộ nhớ:** Các Node nằm phân tán trên Heap. Mỗi Node tiêu tốn thêm tài nguyên RAM để lưu trữ các con trỏ địa chỉ kết nối (`left`, `right`, `parent`) và thuộc tính `color` (Đỏ/Đen).
* **Độ phức tạp thuật toán:** Các tác vụ `put()`, `get()`, `remove()` đều đạt hiệu năng **$O(\log n)$**.

### 📊 Bảng so sánh cơ học: `HashMap` vs `TreeMap`

| Tiêu chí | `HashMap` | `TreeMap` |
| :--- | :--- | :--- |
| **Cấu trúc ngầm** | Mảng băm (Bucket Array) + Danh sách liên kết. | Cây Đỏ-Đen (Red-Black Tree). |
| **Thứ tự phần tử** | Hoàn toàn ngẫu nhiên, hỗn loạn. | Luôn luôn sắp xếp tăng dần theo Key. |
| **Tốc độ truy xuất** | Siêu nhanh: **$O(1)$**. | Khá nhanh: **$O(\log n)$**. |
| **Yêu cầu đối với Key** | Phải ghi đè chính xác `hashCode()` & `equals()`. | Phải triển khai Interface `Comparable` hoặc `Comparator`. |
| **Điều kiện chấp nhận Null** | Cho phép 1 Key `null`. | **Cấm Key `null`** (vì không thể chạy hàm so sánh). |

### 🛠️ Trường hợp áp dụng (Enterprise Use Cases)
* Sử dụng khi dữ liệu đầu ra bắt buộc phải tuân theo một thứ tự nhất định (Ví dụ: Báo cáo tài chính theo ngày, danh sách lịch sử log hệ thống, phân vùng dữ liệu theo khoảng giá trị nhờ hàm `subMap()`).
* Nếu hệ thống chỉ cần tìm kiếm phần tử theo cơ chế Key-Value thuần túy mà không quan tâm thứ tự, **luôn luôn ưu tiên `HashMap`** để đạt hiệu năng tối ưu nhất.

### ConcurrentHashMap / SynchronizedMap
- Thread-safe maps; prefer ConcurrentHashMap for concurrent access patterns.

## Situational Question
Q: Shared cache used by multiple threads — HashMap data gets corrupted. Cause and fix?
A: Cause: HashMap is not thread-safe under concurrent modifications. Fix: Use ConcurrentHashMap for concurrent read/write access or synchronize access (e.g., Collections.synchronizedMap) depending on requirements.


- Note: Choose the collection based on access patterns (read-heavy vs write-heavy), ordering needs, and thread-safety requirements.


# Cấu Trúc Bộ Nhớ RAM Của Java Collection (`ArrayList` vs `LinkedList`)

Trong Java, tất cả các `Object` bên trong `Collection` đều được cấp phát trên bộ nhớ **Heap**. Tuy nhiên, cách mỗi loại cấu trúc dữ liệu tổ chức và liên kết các địa chỉ ô nhớ trên RAM lại hoàn toàn khác nhau. Việc hiểu sâu cơ chế này giải thích lý do tại sao một cấu trúc lại nhanh ở tác vụ này nhưng lại cực kỳ chậm ở tác vụ khác.

---

## 1. `ArrayList`: Cấp phát liên tục (Contiguous Memory Allocation)

Bản chất của `ArrayList` là một **Mảng thuần (Primitive Array - `Object[]`)** được bọc lại bằng một lớp class tiện ích.

### 🟥 Cơ chế trên RAM
Khi bạn khởi tạo một `ArrayList`, JVM sẽ tìm và cấp phát một **khối ô nhớ liên tục** trên RAM.
* **Địa chỉ ô nhớ:** Các phần tử nằm sát sườn nhau. Ví dụ: Phần tử `[0]` ở địa chỉ `0x01`, phần tử `[1]` ở `0x02`, phần tử `[2]` ở `0x03`...

### ⚡ Tác động hiệu năng
* **Đọc (`get(index)`): Siêu nhanh $O(1)$**
  * CPU chỉ cần làm một phép tính đại số đơn giản để xác định vị trí:
    $$\text{Địa chỉ mục tiêu} = \text{Địa chỉ gốc} + \text{index} \times \text{kích thước phần tử}$$
  * Phép toán này giúp CPU nhảy thẳng tới ô nhớ cần tìm ngay lập tức. Ngoài ra, nó tận dụng tối đa cơ chế **CPU Cache Locality** (CPU nạp một lúc cả cụm ô nhớ lân cận vào Cache nên tốc độ đọc cực mượt).
* **Ghi / Xóa giữa mảng: Siêu chậm $O(n)$**
  * Vì RAM là một khối liên tục, nếu bạn chèn hoặc xóa phần tử ở giữa mảng, JVM bắt buộc phải dùng lệnh `System.arraycopy()` để **dịch chuyển toàn bộ** các phần tử phía sau sang trái hoặc sang phải nhằm sắp xếp lại khoảng trống.
* **Phình to bộ nhớ (Resize)**
  * Khi mảng bị đầy (vượt quá dung lượng ban đầu), JVM sẽ tìm và cấp phát một mảng mới to gấp **1.5 lần** ở một vùng RAM khác trống trải hơn, sau đó sao chép (copy) toàn bộ dữ liệu từ mảng cũ sang.

---

## 2. `LinkedList`: Cấp phát phân tán (Disjointed / Scattered Memory Allocation)

`LinkedList` được cấu tạo từ các **Node** độc lập, bọc trong quan hệ danh sách liên kết đôi (Doubly Linked List).

### ⛓️ Cơ chế trên RAM
Mỗi khi bạn gọi hàm `add()` một phần tử, JVM sẽ tìm **bất kỳ một ô nhớ nào còn trống** trên bộ nhớ Heap để ném cái Node đó vào.
* **Địa chỉ ô nhớ:** Địa chỉ của các phần tử hoàn toàn phân tán và vô định (Ví dụ: Node 1 ở `0x99`, Node 2 nhảy sang `0x12`, Node 3 nằm tại `0xA5`).
* **Liên kết địa chỉ:** Để không bị lạc mất nhau, mỗi Node phải tiêu tốn thêm bộ nhớ để lưu trữ 2 biến con trỏ: `next` (lưu địa chỉ của Node đứng sau) và `prev` (lưu địa chỉ của Node đứng trước).

### ⚡ Tác động hiệu năng
* **Đọc: Siêu chậm $O(n)$**
  * CPU không thể tính toán nhanh địa chỉ dựa trên chỉ mục như `ArrayList`. Nó bắt buộc phải bắt đầu đi từ Node đầu tiên (`head`), đọc con trỏ `next` để lấy địa chỉ Node thứ 2, rồi từ Node 2 lấy địa chỉ Node 3... duyệt tuần tự như đi dò đường.
  * Việc dữ liệu nằm phân tán phá hỏng cơ chế CPU Cache, ép CPU phải liên tục truy cập trực tiếp vào RAM, gây ra hiện tượng **Cache Miss**.
* **Ghi / Xóa: Nhanh $O(1)$ *(Nếu đã đứng sẵn tại điểm cần xử lý)***
  * Bạn chỉ cần thay đổi hướng của các con trỏ `next` và `prev` của các Node lân cận trỏ sang nhau là xong. Tuyệt đối không có bất kỳ sự dịch chuyển vật lý nào của các ô nhớ trên RAM.

---

## 📊 Bảng so sánh kiến trúc RAM giữa `ArrayList` và `LinkedList`

| Tiêu chí | `ArrayList` | `LinkedList` |
| :--- | :--- | :--- |
| **Bố trí vật lý trên RAM** | **Liên tục**, xếp liền kề nhau đặc khít. | **Phân tán**, rời rạc và nối bằng con trỏ địa chỉ. |
| **Cơ chế CPU Cache** | Tối ưu rất tốt (**Cache Hit** cao). | Kém hiệu quả do địa chỉ nhảy cóc (**Cache Miss**). |
| **Chi phí bộ nhớ (Overhead)** | Thấp (chỉ lưu data của phần tử). | Cao (phải tốn thêm RAM lưu con trỏ `next` & `prev`). |
| **Tác vụ tối ưu ($O(1)$)** | Đọc dữ liệu ngẫu nhiên qua Index (`get`). | Thêm/Xóa phần tử ở đầu hoặc cuối danh sách. |
| **Rủi ro hệ thống** | Tốn tài nguyên khi hệ thống tự động **Resize** mảng. | Gây phân mảnh bộ nhớ Heap nếu số lượng phần tử quá lớn. |


2. HashMap và HashSet: Cấu trúc mảng băm trên RAM như thế nào?
HashSet thực chất chỉ là một cái vỏ bọc ngầm của HashMap (nó dùng các phần tử của anh làm Key của HashMap, còn Value là một hằng số dummy). Vì vậy, bản chất RAM của chúng là một.

Một HashMap cấu tạo gồm một Mảng các Bucket (Bucket Array), trong đó mỗi Bucket thực chất là một danh sách liên kết (Linked List) hoặc Cây Đỏ-Đen (Red-Black Tree từ Java 8).

Cơ chế cấp phát:

Khi anh put(Key, Value), đầu tiên JVM chạy hàm hashCode() của Key để tính ra một con số (mã băm).

Nó dùng thuật toán modulo để quy con số đó về một chỉ mục (index) trong Mảng Bucket (Mảng này là vùng nhớ liên tục như ArrayList).

Tại vị trí index đó, một đối tượng Node (Entry) chứa Hash, Key, Value, Next được cấp phát động trên Heap.

Hiện tượng Đụng độ mã băm (Hash Collision): Nếu hai Key khác nhau nhưng tính ra cùng một index Bucket (ví dụ cùng ra index = 5). JVM sẽ xử lý bằng cơ chế Chaining: Ô nhớ tại index 5 sẽ tạo một danh sách liên kết. Node mới sẽ lưu địa chỉ của Node cũ vào con trỏ next.

Hiệu năng cấp phát: Khi số lượng phần tử vượt quá ngưỡng Load Factor (mặc định là 0.75 dung lượng mảng), HashMap sẽ thực hiện Rehash — cấp phát một mảng Bucket mới to gấp đôi mảng cũ trên RAM và tính toán lại vị trí cho toàn bộ các Node.