Project Overview
What is this application?
The Personal Expense Tracker is a Spring Boot web application that helps users manage their personal finances by tracking expenses across different categories.

Key Features:

✅ Add/view expenses with description, amount, date, and category

✅ Manage expense categories (Bills, Food, Travel, etc.)

✅ RESTful APIs for frontend integration

✅ MySQL database for persistent storage

✅ Automatic database initialization with default categories

Technology Stack:

Backend: Spring Boot 3.5.5, Spring Data JPA, Hibernate

Database: MySQL 8.4

Java: JDK 17

Build Tool: Maven

Architecture: MVC (Model-View-Controller) pattern

Architecture & Design Patterns


1. Layered Architecture

Controller Layer  -Handles HTTP requests/responses

Service Layer  - Business logic

Repository Layer - Data access

Model Layer - Entity definitions

2. Design Patterns Used:

Repository Pattern: Abstracts data access logic

Dependency Injection: Spring manages object dependencies

MVC Pattern: Separation of concerns

Builder Pattern: Entity creation (via JPA)
