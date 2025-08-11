### 1. What is the difference between String, StringBuffer, and StringBuilder in Java?
- String: Immutable, once created, it cannot be changed, Stored in string pool to save memory, concat, replace... => create a new string
- StringBuffer: Mutable, Synchronized, use when using multi-threaded enviroment
- StringBuilder: Mutable, not-synchronized, Faster than StringBuilder because no synchronization, use when run in single-thread

### 2. Why are String objects immutable in Java? What are the advantages of immutability?
**String Constant Pool (SCP) efficiency**
- Java stores string literals in a shared pool to save memory.
- If strings were mutable, changing one literal could accidentally change the value for all references to it.

**Security**
- Strings are often used for sensitive data like file paths, database URLs, usernames, and passwords.
- If they were mutable, malicious code could alter them after validation.

**Thread-safety**
- Immutable objects are inherently thread-safe because their state cannot be changed after creation.
- Multiple threads can share a String without synchronization.

**Caching & performance**
- Because they never change, strings can be cached (e.g., hash code is calculated once and reused).
- This improves performance in operations like using Strings as keys in a HashMap.
### 3. What happens in memory when you create a String using string literal vs new String()?
- using string literal will put string into pool(SCP - string constant pool)
- using new String () will create new object and store it in heap memory
- using string method will create new object and save in heap memory

### 4.What is the String Constant Pool (SCP) and how does it work?
- it’s the special memory region inside the heap where String literals are stored and reused.
- It’s called constant because only immutable string values (constants) are stored there, and once created, they cannot be changed.
### 5.How does string concatenation work internally? How is it optimized by the compiler?

### 6.What’s the difference between == and .equals() when comparing strings?
- ==: compares the reference 
- equals(): Compares the actual characters inside the strings. (content)

### 7.How does hashCode() behave for two equal strings?

### 8.What are interned strings in Java? When should you use intern() method?
intern() method add a string to pool

### 9.What are the thread-safety differences between StringBuffer and StringBuilder?
#### StringBuffer
- Thread-safe
- All public methods are synchronized.
- Multiple threads can access the same StringBuffer object without corrupting the internal state.
- Downside → Synchronization makes it slower in single-threaded scenarios.
#### StringBuilder
- Not thread-safe
- Methods are not synchronized.
- Designed for single-threaded use cases where thread safety is not needed.
- Faster than StringBuffer because there’s no synchronization overhead.

### 10.Which class should you use for frequent string modifications, and why?
it depends on single-thread or multi-thread, if single => StringBuilder whereas StringBuffer because String is immutable, it will create new object

### 11. What is String pool?
The String Pool in Java is a special area in memory (inside the heap) where String literals are stored and reused to save memory.
if you use new keyword, new String created in the heap, not pool
