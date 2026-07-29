## 5. Luồng (Threads) và concurrency
Đa nhiệm: Multitasking chạy nhiều nhiệm vụ, quay vòng các task để có cảm giác liên tục song
ĐA xử lý: tầm phần cứng, Multiprocessing, Các core các thread chạy song song thựcsong
Đa luồng: thread là đơn vị nhỏ nhất CPU quản lý, Mỗi process như 1 ứng  gồm nhiều thread con, chạy các thread đấy song song

Các ứng dụng sẽ được HĐH cấp phát một bộ nhớ RAM riêng biệt để không xung đột với nhau
Trong java, được tách ra làm 2 vùng là stack và heap, stack sẽ lưu các biến local của thread để không va chạm với nhau, như các API khác nhau sẽ nằm ở stack khác nhau

biến static sẽ nằm ở metaspace, trỏ đến object trong

- Thread, Runnable -> ExecutorService -> Future/Callable -> CompletableFuture (Java 8+)
- ThreadPool: pool quản lý số lượng thread (maxPoolSize...)
- Sử dụng CompletableFuture cho xử lý bất đồng bộ.

# Java Concurrency Interview Q&A
# Java Virtual Thread 21

### What is a race condition? How do you prevent it?
- **Race condition** happens when multiple threads access and modify shared data simultaneously, causing inconsistent results.
- **Prevention**: use synchronization (`synchronized`, `ReentrantLock`), atomic classes (`AtomicInteger`), or design with no shared state.

---

### What is deadlock? How can you avoid it?
- **Deadlock** occurs when two or more threads wait for each other’s resources, and none can proceed.
- **Avoidance**: lock ordering, using `tryLock()`, timeout strategies, or reducing shared resources.

---

### Difference between wait(), notify(), and notifyAll().
- `wait()`: makes a thread release the lock and wait.
- `notify()`: wakes up one waiting thread.
- `notifyAll()`: wakes up all waiting threads.

---

### What is ReentrantLock? How is it different from synchronized?
- **ReentrantLock** is an explicit lock with advanced features (tryLock, fairness, multiple conditions).
- Unlike `synchronized`, it gives more control but requires manual `lock()` and `unlock()`.

---

### How many thread is enough for a task?
- Depends on CPU cores and type of task:
    - **CPU-bound** → ~number of cores.
    - **I/O-bound** → more than cores (to hide waiting time).
- To clarify this point, in Java, threads are mapped 1-to-1 with operating system threads. 
Creating more threads does not necessarily make the application faster. 
It depends on the type of task, because creating too many threads incurs overhead such as context switching, saving thread states, and switching between threads.

---

### What is thread pool?
- A **thread pool** is a collection of pre-created threads that execute tasks.
- Benefits: better performance, resource management, and task scheduling.

---

### Compare-And-Swap (CAS)
- **CAS** is an atomic operation that updates a variable only if it matches an expected value.
- Used in `Atomic` classes, avoids locks, improves performance in concurrent programming.  

### start() and run()?


## REFERENCE
Java Multithreading Interview Questions: https://www.youtube.com/watch?v=AfVbJDr-8ic
Java Multithreading Interview: https://www.youtube.com/watch?v=ITPesAZFvWI

# Java Virtual Thread 21