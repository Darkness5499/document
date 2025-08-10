### What is the difference between String, StringBuffer, and StringBuilder in Java?
- String: Immutable, once created, it cannot be changed, Stored in string pool to save memory, concat, replace... => create a new string
- StringBuffer: Mutable, Synchronized, use when using multi-threaded enviroment
- StringBuilder: Mutable, not-synchronized, Faster than StringBuilder because no synchronization, use when run in single-thread

### Why are String objects immutable in Java? What are the advantages of immutability?

### What happens in memory when you create a String using string literal vs new String()?

### What is the String Constant Pool (SCP) and how does it work?

### How does string concatenation work internally? How is it optimized by the compiler?

### What’s the difference between == and .equals() when comparing strings?

### How does hashCode() behave for two equal strings?

### What are interned strings in Java? When should you use intern() method?

### What are the thread-safety differences between StringBuffer and StringBuilder?

### Which class should you use for frequent string modifications, and why?

### What is String pool?