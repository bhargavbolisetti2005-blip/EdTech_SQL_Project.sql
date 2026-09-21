# EdTech Subscription Analytics Platform – End-to-End SQL Project

## Project Overview

This project is a complete end-to-end SQL solution developed for **LearnPro**, a subscription-based EdTech platform.  
The objective was to design a relational database, load business data, perform advanced analytics, and generate actionable business insights using Microsoft SQL Server.

The project demonstrates practical skills in database design, querying, performance optimization, and procedural programming in SQL.

---

## Business Problem

LearnPro manages data related to:
- Students
- Courses
- Trainers
- Enrollments
- Payments
- Marketing campaigns

The goal was to analyze this data to understand revenue trends, marketing effectiveness, course performance, trainer impact, and city-wise demand so that the business can make data-driven decisions.

---

## What Was Implemented

### 1. Database Design (DDL)
- Created database: `EdTechLearnPro`
- Designed 7 normalized tables with proper relationships
- Applied Primary Keys, Foreign Keys, Unique, Check, Default, and Not Null constraints

### 2. Data Loading
- Imported data from Excel files using SQL Server Import Wizard
- Ensured referential integrity was maintained

### 3. Analytical Queries (DQL)
- Top cities by enrollments
- Students enrolled in multiple courses
- Students with no payment records
- Highest revenue generating months
- Most popular courses
- Discount analysis
- State-wise paid enrollments

### 4. Advanced SQL Concepts
- JOINs (INNER JOIN, LEFT JOIN, RIGHT JOIN)
- GROUP BY + HAVING + Aggregate functions
- Subqueries (Scalar & Nested)
- Common Table Expressions (CTEs)
- Window Functions:
  - RANK()
  - DENSE_RANK()
  - LAG()
  - LEAD()
  - ROW_NUMBER()

### 5. Database Objects
- **Views**: Monthly Revenue & Trainer Performance
- **Indexes**: Single and Composite indexes for performance
- **Stored Procedures**: Monthly revenue, Add Student with validation, Trainer performance
- **User Defined Functions**:
  - Scalar function for net fee after discount
  - Table-valued function for enrollments by course
- **Exception Handling**: TRY...CATCH with ErrorLog table
- **Triggers**:
  - Prevent discount greater than allowed limit
  - Auto-insert zero payment for unpaid enrollments
  - Audit logging on updates

### 6. Final Business Analysis
- Customer Acquisition Cost (CAC)
- ROI / Cost per Lead by marketing channel
- 12-month Enrollment Heatmap (Month × City)
- Top & Worst performing courses by revenue
- Trainer impact on revenue and satisfaction
- Month-over-Month business growth

### 7. Insights Report
A structured summary covering:
- Revenue trends
- Marketing effectiveness
- High-performing courses
- City-wise demand
- Trainer impact
- Business recommendations

---

## Project Structure

| File | Description |
|------|-------------|
| `EdTech_SQL_Project.sql` | Complete SQL script containing all DDL, DML, Queries, Views, Procedures, Functions, Triggers |
| `Screenshots_of_Outputs.pdf` | Output results of all analytical queries + Final Insights Report |

---

## Tools & Technologies

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- Excel (for source data)

---

## How to Run

1. Open SQL Server Management Studio
2. Connect to your SQL Server instance
3. Open the `EdTech_SQL_Project.sql` file
4. Execute the script section by section
5. Refer to the PDF for expected outputs

---

## Key Learning Outcomes

- Designed a complete relational database from scratch
- Wrote complex analytical queries for real business questions
- Implemented advanced SQL features (Window Functions, CTEs, Triggers)
- Created reusable database objects (Views, Procedures, Functions)
- Generated business insights from raw data

---

## Author

**Bhargav Bolisetti**  
SQL Data Analyst Project
