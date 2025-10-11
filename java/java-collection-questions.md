# Java collection
#### LIST
####   ArrayList
- Backed by a dynamic array, it can resize if the number of elements are up or down, resizes automatically
- Fast random access O(1) for get/set, because it use index for each element
- Slow for insert, because if the number 
- Less memory (Stores data only)
- Best for frequent access/ read operations
- wrapper classes are required, cannot store primitive types directly
  
#### LinkedList
- Doubly linked list
- Slow random access
- Fast insert/ delete
- more memory (store data + pointers)
- best for frequently insert/delete operation

### Vector
- Can store duplicate elements
- maintains ordered elements inserted
- synchronized, using when runs with multi thread

### Stack
- likes vector, it is synchronized
- using LIFO algorithm

##

### SET

#### 1. HashSet
- Order: Unordered → Does not maintain insertion order.

- Duplicates: Not allowed (unique elements only).

- Null values: Allows one null.

- Performance: Fast for basic operations (add, remove, contains) because it uses hashing.

- When to use: When you need a set with no duplicates and don’t care about order.

#### 2. LinkedHashSet
- Order: Maintains insertion order.

- Duplicates: Not allowed.

- Null values: Allows one null.

- Performance: Slightly slower than HashSet due to maintaining a linked list internally.

- When to use: When you want a set with unique elements and predictable iteration order.

#### 3. TreeSet
- Order: Sorted in natural order or by a custom Comparator.

- Duplicates: Not allowed.

- Null values: Does not allow null (will throw NullPointerException).

- Performance: Slower than HashSet (O(log n) time complexity) because it uses a Red-Black Tree.

- When to use: When you need elements sorted automatically.

#### 4. EnumSet
- Order: Maintains natural order of enum constants.

- Duplicates: Not allowed.

- Null values: Does not allow null.

- Performance: Very fast and memory efficient because it uses bit vectors internally.

- When to use: When storing enum values.

#### 5. CopyOnWriteArraySet
- Order: Maintains insertion order.

- Duplicates: Not allowed.

- Null values: Allows null (only one).

- Performance: Good for read-heavy operations, slower for frequent writes because it copies the array on each modification.

- When to use: When multiple threads access a set mostly for reading.

##

### QUEUE
#### LinkedList
#### PriorityQueue
#### ArrayDeque
##

### MAP
### HashMap
- Stores data as key-value pairs
- uses hashing for fast access, converting keys into hash codes to index value efficiently
- To retrieve value the corresponding key is required
- internally, HashSet is also backed by HashMap
### LinkedHashMap
- Like a HashMap but maintaining the order of elements inserted to it
### TreeMap
- Key are in sorted order
### ConcurrentHashMap, SynchronizedHashMap


##




  