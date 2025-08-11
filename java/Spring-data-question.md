# Spring Data, Spring JPA, and Hibernate Interview Questions

## **Theoretical Questions**
1. What is the difference between JPA, Hibernate, and Spring Data JPA?
2. Can you explain the architecture of Hibernate?
3. What is the role of the `EntityManager` in JPA?
4. How does the Spring Data JPA `Repository` abstraction work?
5. What are the benefits of using Spring Data JPA over plain Hibernate?
6. Can you explain the concept of "lazy loading" and "eager loading" in Hibernate?
7. What are the differences between `getOne()` and `findById()` in Spring Data JPA?
8. What is the difference between `save()` and `saveAndFlush()` in Spring Data JPA?
9. How does Hibernate manage caching? Explain the difference between first-level and second-level cache.
10. Can you explain the concept of the persistence context in JPA?
11. What is the difference between `merge()` and `persist()` in JPA?
12. How are transactions managed in Spring Data JPA?
13. What are entity lifecycle callbacks in JPA?
14. Can you explain the N+1 select problem in Hibernate? How can it be solved?
15. What is the difference between `@OneToOne`, `@OneToMany`, and `@ManyToMany` mappings in JPA?

## **Scenario-Based Questions**
1. You notice that Hibernate is generating too many queries (N+1 problem). How would you optimize it?
2. Your application is facing performance issues due to unnecessary database calls. How would you leverage caching in Hibernate to fix it?
3. You need to fetch data from multiple tables with complex joins. How would you approach it in Spring Data JPA?
4. A query is taking too long to execute. How would you debug and improve it in a Spring Data JPA context?
5. You have to migrate from native Hibernate APIs to Spring Data JPA. What steps would you take and what challenges might you face?
6. You need partial updates for entities instead of updating the whole row. How would you achieve this in JPA?
7. A service method is throwing `LazyInitializationException`. How would you resolve it?
8. You need to perform batch inserts or updates using Spring Data JPA. How would you configure it?
9. You want to implement auditing (created date, updated date, created by, updated by) in all entities. How would you do it in Spring Data JPA?
10. You need to execute a stored procedure from Spring Data JPA. How would you handle it?
