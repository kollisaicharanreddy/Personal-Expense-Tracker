# Personal Expense Tracker - Spring Boot Backend Analysis & Interview Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture & Design Patterns](#architecture--design-patterns)
3. [Code Component Analysis](#code-component-analysis)
4. [Database Design & Relationships](#database-design--relationships)
5. [Spring Boot Concepts Explained](#spring-boot-concepts-explained)
6. [Interview Questions & Answers](#interview-questions--answers)
7. [Challenging Technical Questions](#challenging-technical-questions)

---

## Project Overview

### What is this application?
The **Personal Expense Tracker** is a Spring Boot web application that helps users manage their personal finances by tracking expenses across different categories.

### Key Features:
- ✅ Add/view expenses with description, amount, date, and category
- ✅ Manage expense categories (Bills, Food, Travel, etc.)
- ✅ RESTful APIs for frontend integration
- ✅ MySQL database for persistent storage
- ✅ Automatic database initialization with default categories

### Technology Stack:
- **Backend**: Spring Boot 3.5.5, Spring Data JPA, Hibernate
- **Database**: MySQL 8.4
- **Java**: JDK 17
- **Build Tool**: Maven
- **Architecture**: MVC (Model-View-Controller) pattern

---

## Architecture & Design Patterns

### 1. **Layered Architecture**
```
┌─────────────────────┐
│   Controller Layer   │ ← Handles HTTP requests/responses
├─────────────────────┤
│    Service Layer     │ ← Business logic
├─────────────────────┤
│  Repository Layer    │ ← Data access
├─────────────────────┤
│     Model Layer      │ ← Entity definitions
└─────────────────────┘
```

### 2. **Design Patterns Used:**
- **Repository Pattern**: Abstracts data access logic
- **Dependency Injection**: Spring manages object dependencies
- **MVC Pattern**: Separation of concerns
- **Builder Pattern**: Entity creation (via JPA)

---

## Code Component Analysis

### 1. Main Application Class

```java
@SpringBootApplication
public class PersonalExpenseTrackerApplication {
    public static void main(String[] args) {
        SpringApplication.run(PersonalExpenseTrackerApplication.class, args);
    }
}
```

**📝 Explanation:**
- `@SpringBootApplication` is a **meta-annotation** that combines:
  - `@Configuration`: Defines Spring configuration
  - `@EnableAutoConfiguration`: Enables Spring Boot's auto-configuration
  - `@ComponentScan`: Scans for Spring components in current package and sub-packages

**🎯 Interview Point:** "This is the entry point of our Spring Boot application. The annotation enables auto-configuration, which automatically configures Spring based on dependencies in the classpath."

---

### 2. Entity Classes (Model Layer)

#### Category Entity
```java
@Entity
public class Category {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    
    private String name;
    
    @OneToMany(mappedBy="category")
    @JsonIgnore
    private Set<Expense> expenses;
    
    // getters, setters, toString()
}
```

**📝 Key Points:**
- `@Entity`: Marks this as a JPA entity (database table)
- `@Id`: Primary key field
- `@GeneratedValue(strategy = GenerationType.IDENTITY)`: Auto-increment ID
- `@OneToMany`: One category can have many expenses
- `@JsonIgnore`: Prevents infinite recursion during JSON serialization

**🎯 Interview Explanation:** "This represents the Category table in our database. The @OneToMany relationship establishes that one category can contain multiple expenses. We use @JsonIgnore to prevent circular references when converting to JSON."

#### Expense Entity
```java
@Entity
public class Expense {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String description;
    private Double amount;
    private LocalDate date;
    
    @ManyToOne
    @JoinColumn(name="category_id", nullable=false)
    private Category category;
    
    // getters, setters, toString()
}
```

**📝 Key Points:**
- `@ManyToOne`: Many expenses belong to one category
- `@JoinColumn`: Specifies foreign key column name
- `nullable=false`: Category is mandatory for every expense
- Uses `LocalDate` for date handling (Java 8+ feature)

---

### 3. Repository Layer

#### CategoryRepository
```java
@Repository
public interface CategoryRepository extends JpaRepository<Category,Long> {
    // Inherits standard CRUD operations
}
```

#### ExpenseRepository
```java
@Repository
public interface ExpenseRepository extends JpaRepository<Expense,Long> {
    List<Expense> findByCategoryId(Long id);
}
```

**📝 Explanation:**
- Extends `JpaRepository<Entity, PrimaryKeyType>`
- Provides built-in methods: `findAll()`, `save()`, `deleteById()`, etc.
- Custom query method `findByCategoryId()` follows Spring Data naming conventions

**🎯 Interview Point:** "We use Spring Data JPA repositories which provide CRUD operations out of the box. The custom method `findByCategoryId` uses method name query derivation - Spring automatically generates the SQL query based on the method name."

---

### 4. Service Layer

#### CategoryService
```java
@Service
public class CategoryService {
    private final CategoryRepository categoryRepository;
    
    @Autowired
    public CategoryService(CategoryRepository categoryRepository){
        this.categoryRepository = categoryRepository;
    }
    
    public List<Category> getAll(){
        return categoryRepository.findAll();
    }
    
    public Category create(Category category){
        return categoryRepository.save(category);
    }
}
```

#### ExpenseService
```java
@Service
public class ExpenseService {
    private final ExpenseRepository expenseRepository;
    
    @Autowired
    public ExpenseService(ExpenseRepository expenseRepository){
        this.expenseRepository = expenseRepository;
    }
    
    public List<Expense> getAll(){
        return expenseRepository.findAll();
    }
    
    public Optional<Expense> getById(Long id){
        return expenseRepository.findById(id);
    }
    
    public Expense createExpense(Expense expense){
        return expenseRepository.save(expense);
    }
    
    public boolean deleteById(Long id){
        if(expenseRepository.existsById(id)){
            expenseRepository.deleteById(id);
            return true;
        }
        return false;
    }
    
    public List<Expense> getExpensesByCategoryId(Long categoryId) {
        return expenseRepository.findByCategoryId(categoryId);
    }
    
    public Optional<Expense> updateExpense(Long id, Expense expenseDetails) {
        return expenseRepository.findById(id).map(existingExpense -> {
            existingExpense.setDescription(expenseDetails.getDescription());
            existingExpense.setAmount(expenseDetails.getAmount());
            existingExpense.setDate(expenseDetails.getDate());
            existingExpense.setCategory(expenseDetails.getCategory());
            return expenseRepository.save(existingExpense);
        });
    }
}
```

**📝 Key Concepts:**
- `@Service`: Marks this as a service layer component
- **Constructor Injection**: Recommended over field injection for better testability
- **Optional<>**: Java 8 feature to handle null values gracefully
- **Method Chaining**: Using `.map()` for functional programming approach

**🎯 Interview Explanation:** "The service layer contains our business logic. I use constructor injection for dependencies, which makes the code more testable and ensures required dependencies are available. The updateExpense method uses Optional and functional programming with map() to handle the case where an expense might not exist."

---

### 5. Controller Layer

#### CategoryController
```java
@RestController
@RequestMapping("/api/categories")
public class CategoryController {
    private final CategoryService categoryService;
    
    @Autowired
    public CategoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }
    
    @GetMapping
    public List<Category> getAll() {
        return categoryService.getAll();
    }
    
    @PostMapping
    public ResponseEntity<Category> createCategory(@RequestBody Category category) {
        Category newCategory = categoryService.create(category);
        return new ResponseEntity<>(newCategory, HttpStatus.CREATED);
    }
}
```

#### ExpenseController
```java
@RestController
@RequestMapping("/api/expenses")
public class ExpenseController {
    private final ExpenseService expenseService;
    
    @GetMapping
    public List<Expense> getAll() {
        return expenseService.getAll();
    }
    
    @PostMapping
    public ResponseEntity<Expense> createExpense(@RequestBody Expense expense) {
        Expense createdExpense = expenseService.createExpense(expense);
        return new ResponseEntity<>(createdExpense, HttpStatus.CREATED);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Expense> getById(@PathVariable Long id) {
        return expenseService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Expense> updateExpense(@PathVariable Long id, @RequestBody Expense expenseDetails) {
        return expenseService.updateExpense(id, expenseDetails)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteById(@PathVariable Long id) {
        if (expenseService.deleteById(id)) {
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
```

**📝 Key Annotations:**
- `@RestController`: Combines `@Controller` and `@ResponseBody`
- `@RequestMapping`: Base URL mapping for all endpoints
- `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`: HTTP method mappings
- `@PathVariable`: Extracts values from URL path
- `@RequestBody`: Binds HTTP request body to method parameter

**🎯 Interview Point:** "The controller layer handles HTTP requests and responses. I use proper HTTP status codes (201 for creation, 404 for not found) and ResponseEntity for fine-grained control over the HTTP response."

---

### 6. Data Initialization

```java
@Component
public class DataInitializer implements CommandLineRunner {
    private final CategoryRepository categoryRepository;
    
    @Override
    public void run(String... args){
        if(categoryRepository.count()==0) {
            // Create default categories
            Category bills = new Category();
            bills.setName("Bills");
            // ... more categories
            
            List<Category> categories = Arrays.asList(bills, food, travel, utilities, shopping, entertainment);
            categoryRepository.saveAll(categories);
        }
    }
}
```

**📝 Explanation:**
- `@Component`: Spring-managed bean
- `CommandLineRunner`: Executes code after Spring context is loaded
- Provides default data for fresh installations

---

### 7. CORS Configuration (WebConfig)

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins(
                    "http://localhost:3000",    // React development server
                    "http://localhost:4200",    // Angular development server
                    "http://localhost:8080",    // Same origin
                    "http://127.0.0.1:5500"     // Live Server extension
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.addAllowedOriginPattern("http://localhost:*");
        configuration.addAllowedOriginPattern("https://*.yourdomain.com");
        configuration.addAllowedMethod("*");
        configuration.addAllowedHeader("*");
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }
}
```

**📝 Key Points:**
- **CORS (Cross-Origin Resource Sharing)**: Allows web pages from different domains to access your API
- **WebMvcConfigurer**: Spring interface for customizing MVC configuration
- **allowedOrigins**: Specifies which domains can make requests to your API
- **allowedMethods**: Which HTTP methods are permitted
- **allowCredentials**: Allows cookies and authorization headers
- **maxAge**: How long browsers cache preflight requests

**🎯 Interview Explanation:** "I implemented CORS configuration to allow my frontend applications running on different ports to access the backend API. This is essential when developing with separate frontend and backend servers. I used both the WebMvcConfigurer approach for simplicity and a CorsConfigurationSource bean for more flexibility, especially when integrating with Spring Security."

---

## Database Design & Relationships

### Entity Relationship Diagram
```
┌─────────────────┐         ┌─────────────────┐
│    Category     │ 1     * │     Expense     │
├─────────────────┤────────<├─────────────────┤
│ PK id (Long)    │         │ PK id (Long)    │
│    name (String)│         │    description  │
│                 │         │    amount       │
│                 │         │    date         │
│                 │         │ FK category_id  │
└─────────────────┘         └─────────────────┘
```

### Relationship Explanation:
- **One-to-Many**: One category can have multiple expenses
- **Many-to-One**: Each expense belongs to exactly one category
- **Foreign Key**: `category_id` in expense table references `id` in category table

### SQL Tables Generated:
```sql
CREATE TABLE category (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE expense (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(255),
    amount DOUBLE,
    date DATE,
    category_id BIGINT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES category(id)
);
```

---

## Spring Boot Concepts Explained

### 1. **Dependency Injection**
```java
@Autowired
public CategoryService(CategoryRepository categoryRepository){
    this.categoryRepository = categoryRepository;
}
```
**Simple Explanation:** Spring automatically provides the required dependencies. Instead of creating objects manually (`new CategoryRepository()`), Spring manages object creation and injection.

### 2. **Auto-Configuration**
Spring Boot automatically configures:
- Database connection (based on `application.properties`)
- JPA/Hibernate setup
- Web server (Tomcat)
- JSON serialization/deserialization

### 3. **Annotations Explained:**
- `@Entity`: "This class represents a database table"
- `@Service`: "This class contains business logic"
- `@Repository`: "This class handles database operations"
- `@Controller`: "This class handles web requests"
- `@Autowired`: "Spring, please provide this dependency"

### 4. **JPA/Hibernate Benefits:**
- **Object-Relational Mapping (ORM)**: Work with objects, not SQL
- **Automatic table creation**: Hibernate creates tables from entities
- **Built-in CRUD operations**: No need to write basic SQL queries
- **Query methods**: `findByCategoryId` automatically becomes SQL query

---

## Interview Questions & Answers

### **Basic Questions:**

**Q1: What is Spring Boot and why did you use it?**
**A:** Spring Boot is a framework that simplifies Spring application development by providing auto-configuration, embedded servers, and production-ready features out of the box. I used it because it eliminates boilerplate configuration and allows rapid development of enterprise-grade applications.

**Q2: Explain the difference between @Component, @Service, and @Repository.**
**A:** 
- `@Component`: Generic Spring-managed bean
- `@Service`: Business logic layer, specialization of @Component
- `@Repository`: Data access layer, provides exception translation

**Q3: What is JPA and how does it work in your project?**
**A:** JPA (Java Persistence API) is a specification for Object-Relational Mapping. In my project, Hibernate implements JPA. It maps our Java entities (Category, Expense) to database tables and provides CRUD operations without writing SQL.

**Q4: Explain the relationship between Category and Expense entities.**
**A:** It's a bidirectional One-to-Many relationship. One Category can have multiple Expenses, but each Expense belongs to exactly one Category. This is mapped using @OneToMany on Category side and @ManyToOne on Expense side.

**Q5: Why did you use @JsonIgnore on the expenses field in Category?**
**A:** To prevent infinite recursion during JSON serialization. Without it, when serializing a Category, it would serialize its expenses, which would serialize their categories, leading to a stack overflow.

### **Intermediate Questions:**

**Q6: How does Spring Data JPA work? How does `findByCategoryId` method work without implementation?**
**A:** Spring Data JPA uses method name query derivation. It parses the method name `findByCategoryId` and automatically generates the equivalent SQL query: `SELECT * FROM expense WHERE category_id = ?`. This is done at runtime using proxy patterns.

**Q7: Explain dependency injection in your service classes. Why constructor injection?**
**A:** I use constructor injection because:
- Dependencies are required and immutable (final fields)
- Better for testing (can mock dependencies easily)
- Spring recommends it over field injection
- Makes circular dependencies obvious

**Q8: What is CommandLineRunner and why did you use it?**
**A:** CommandLineRunner is a Spring Boot interface that executes code after the application context is loaded. I used it in DataInitializer to populate default categories when the application starts for the first time.

**Q9: How would you handle exceptions in your application?**
**A:** I would implement:
- Global exception handler using `@ControllerAdvice`
- Custom exception classes for business logic
- Proper HTTP status codes
- Standardized error response format

**Q10: Explain the HTTP methods you used and their purposes.**
**A:**
- `GET /api/categories`: Retrieve all categories (200 OK)
- `POST /api/categories`: Create new category (201 Created)
- `GET /api/expenses/{id}`: Get specific expense (200 OK or 404 Not Found)
- `PUT /api/expenses/{id}`: Update expense (200 OK or 404 Not Found)
- `DELETE /api/expenses/{id}`: Delete expense (200 OK or 404 Not Found)

**Q11: What is CORS and why did you implement it?**
**A:** CORS (Cross-Origin Resource Sharing) is a security feature that allows or restricts web pages from one domain to access resources from another domain. I implemented it because:
- Frontend and backend run on different ports during development
- Browsers block cross-origin requests by default for security
- It's essential for modern web applications with separate frontend/backend
- I configured specific allowed origins, methods, and headers for security

**Q12: Explain the difference between the two CORS configurations you used.**
**A:**
- **WebMvcConfigurer approach**: Simple, direct configuration using `addCorsMappings()`. Good for basic CORS needs.
- **CorsConfigurationSource Bean**: More flexible, can be integrated with Spring Security, allows programmatic configuration. Better for complex scenarios and production use.

**Q13: How would you handle CORS in production vs development?**
**A:**
- **Development**: Allow localhost with various ports for testing
- **Production**: Restrict to specific domains only (https://yourdomain.com)
- Use environment-specific configuration files
- Never use wildcards (*) for origins in production
- Set appropriate maxAge for performance

---

## Challenging Technical Questions

### **Advanced Spring Boot:**

**Q1: How would you implement pagination in your expense listing?**
**A:** 
```java
// In Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {
    Page<Expense> findByCategoryId(Long categoryId, Pageable pageable);
}

// In Controller
@GetMapping
public Page<Expense> getAll(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "10") int size,
    @RequestParam(defaultValue = "date") String sortBy) {
    
    Pageable pageable = PageRequest.of(page, size, Sort.by(sortBy).descending());
    return expenseService.getAll(pageable);
}
```

**Q2: How would you implement caching to improve performance?**
**A:**
```java
@Service
public class ExpenseService {
    @Cacheable("expenses")
    public List<Expense> getAll() {
        return expenseRepository.findAll();
    }
    
    @CacheEvict(value = "expenses", allEntries = true)
    public Expense createExpense(Expense expense) {
        return expenseRepository.save(expense);
    }
}
```

**Q3: How would you implement validation?**
**A:**
```java
@Entity
public class Expense {
    @NotNull(message = "Description is required")
    @Size(min = 3, max = 100, message = "Description must be between 3-100 characters")
    private String description;
    
    @NotNull(message = "Amount is required")
    @Positive(message = "Amount must be positive")
    private Double amount;
    
    @NotNull(message = "Date is required")
    @PastOrPresent(message = "Date cannot be in future")
    private LocalDate date;
}

// In Controller
@PostMapping
public ResponseEntity<Expense> createExpense(@Valid @RequestBody Expense expense) {
    // @Valid triggers validation
}
```

**Q4: How would you implement security?**
**A:**
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/**").authenticated()
            )
            .oauth2Login()
            .jwt();
        return http.build();
    }
}
```

**Q5: How would you implement database transactions?**
**A:**
```java
@Service
@Transactional
public class ExpenseService {
    
    @Transactional(rollbackFor = Exception.class)
    public void transferExpenseToCategory(Long expenseId, Long newCategoryId) {
        Expense expense = expenseRepository.findById(expenseId)
            .orElseThrow(() -> new ExpenseNotFoundException("Expense not found"));
        
        Category newCategory = categoryRepository.findById(newCategoryId)
            .orElseThrow(() -> new CategoryNotFoundException("Category not found"));
        
        expense.setCategory(newCategory);
        expenseRepository.save(expense);
        
        // If any exception occurs, entire transaction rolls back
    }
}
```

**Q6: How would you implement custom queries?**
**A:**
```java
@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {
    
    @Query("SELECT e FROM Expense e WHERE e.date BETWEEN :startDate AND :endDate")
    List<Expense> findExpensesBetweenDates(
        @Param("startDate") LocalDate startDate,
        @Param("endDate") LocalDate endDate);
    
    @Query(value = "SELECT c.name, SUM(e.amount) FROM expense e " +
                   "JOIN category c ON e.category_id = c.id " +
                   "GROUP BY c.id, c.name", nativeQuery = true)
    List<Object[]> getCategoryWiseExpenseSum();
}
```

**Q7: How would you implement testing?**
**A:**
```java
@WebMvcTest(ExpenseController.class)
class ExpenseControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private ExpenseService expenseService;
    
    @Test
    void testGetAllExpenses() throws Exception {
        List<Expense> expenses = Arrays.asList(new Expense());
        when(expenseService.getAll()).thenReturn(expenses);
        
        mockMvc.perform(get("/api/expenses"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$", hasSize(1)));
    }
}

@DataJpaTest
class ExpenseRepositoryTest {
    
    @Autowired
    private ExpenseRepository expenseRepository;
    
    @Test
    void testFindByCategoryId() {
        // Test repository methods
    }
}
```

### **Architecture & Design Questions:**

**Q8: How would you scale this application?**
**A:**
- **Database**: Read replicas, connection pooling, database sharding
- **Caching**: Redis for session storage and frequently accessed data
- **Load Balancing**: Multiple application instances behind load balancer
- **Microservices**: Split into separate services (User Service, Expense Service, Category Service)
- **API Gateway**: Centralized routing and cross-cutting concerns

**Q9: What design patterns did you use and why?**
**A:**
- **Repository Pattern**: Abstraction over data access
- **Dependency Injection**: Loose coupling, better testability
- **Builder Pattern**: Entity creation through JPA
- **Strategy Pattern**: Different expense calculation strategies
- **Observer Pattern**: Event-driven updates (could implement for notifications)

**Q10: How would you handle different database environments?**
**A:**
```properties
# application-dev.properties
spring.datasource.url=jdbc:mysql://localhost:3306/expense_tracker_dev
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true

# application-prod.properties
spring.datasource.url=jdbc:mysql://prod-server:3306/expense_tracker_prod
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
logging.level.org.springframework=WARN
```

---

## Key Points to Remember for Interview

### **Technical Strengths to Highlight:**
1. **Clean Architecture**: Proper separation of concerns with layered architecture
2. **Spring Best Practices**: Constructor injection, proper annotations usage
3. **Database Design**: Well-defined relationships, foreign key constraints
4. **RESTful Design**: Proper HTTP methods and status codes
5. **Error Handling**: Graceful handling of edge cases

### **Areas for Potential Improvement (Be Honest):**
1. **Security**: Currently no authentication/authorization
2. **Validation**: Limited input validation
3. **Exception Handling**: No global exception handler
4. **Testing**: Could add comprehensive unit and integration tests
5. **Logging**: Could add structured logging
6. **Monitoring**: Could add health checks and metrics

### **Demonstration Points:**
1. Show how to add a new endpoint
2. Explain the request flow from controller to database
3. Demonstrate how Spring manages dependencies
4. Show how JPA generates queries
5. Explain the database schema

### **Confidence Builders:**
- "I chose this architecture because it's scalable and maintainable"
- "I used Spring Boot because it reduces boilerplate and increases productivity"
- "The repository pattern makes the code testable and database-agnostic"
- "I used proper HTTP status codes to make the API consumer-friendly"

---

**Good luck with your interview! Remember to explain not just what you did, but WHY you made those choices. This shows deeper understanding and architectural thinking.**