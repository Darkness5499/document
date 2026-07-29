## 10. Streams

- Stream provides a functional-style API to process data using operations such as `map`, `filter`, and `reduce`.
- Stream does not store data. It only describes a pipeline of operations to process data.
- Performance depends on the situation. `parallelStream()` may improve performance in some cases but introduces additional overhead.

### 5 Key Points for Senior Interviews

1. **Stream does not contain data; it only defines how to process data.**

2. **Intermediate operations are lazy.**  
   They are executed only when a terminal operation is called.

3. **Stream processes data through a pipeline.**  
   Each element goes through the entire pipeline before moving to the next element.

4. **Stream does not automatically make code faster.**  
   It may be slower than traditional loops due to additional overhead.

5. **Use parallel streams carefully.**  
   They are suitable for large, independent, CPU-bound workloads, not for every situation.

---

## Stream Best Practice

Avoid mutating external state inside Stream operations.

Prefer:
`Input → Transform → Output`
Avoid:
`Input → Modify External State`

Example:

```java
int count = 0;

list.stream()
    .forEach(x -> count++);
```

This does not compile because local variables captured by lambda expressions must be **final** or **effectively final**.

### Reason

- Lambda captures local variables by value.
- This restriction helps prevent unsafe shared mutable state, especially in parallel execution.

### Summary

- ✔ Traditional `for` loop allows modifying local variables and object state.
- ❌ Lambda/Stream cannot modify captured local variable references.
- ✔ Use `collect()`, reduction operations, or carefully controlled mutable objects when state is required.