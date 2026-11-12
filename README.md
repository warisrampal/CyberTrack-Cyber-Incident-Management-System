🔐 CyberTrack — Cyber Incident Record Management System

A MySQL-based RDBMS project for organizing and managing cybersecurity incident records.

CyberTrack is an academic database project developed as part of my RDBMS coursework in BCA Cybersecurity at Lamrin Tech Skills University, Punjab.

The project demonstrates how relational database concepts and SQL can be used to manage cybersecurity-related information, including incidents, investigations, evidence records, and incident status history.

🎯 Project Objectives

- Design a structured relational database for cybersecurity incident management.
- Maintain relationships between users, incidents, severity levels, and incident types.
- Store investigation details and evidence metadata.
- Track changes in incident status.
- Demonstrate practical implementation of SQL and RDBMS concepts.

🛠️ Technologies Used

- Database: MySQL 8.0+
- Database Tool: MySQL Workbench
- Language: SQL
- Storage Engine: InnoDB

🗂️ Database Structure

The project consists of seven interconnected tables:

Table| Purpose
"Users"| Stores user information
"Incident_Types"| Defines categories of incidents
"Severity"| Stores incident severity levels
"Incidents"| Maintains incident records
"Investigations"| Stores investigation details
"Evidence"| Maintains evidence metadata
"Incident_Status_History"| Tracks incident status changes

⚙️ SQL Concepts Implemented

This project covers a range of SQL and database management concepts:

- DDL: CREATE, ALTER and database structure management
- DML: INSERT, UPDATE and DELETE
- DQL: SELECT queries and data retrieval
- Constraints: PRIMARY KEY, FOREIGN KEY, UNIQUE and CHECK
- Filtering: WHERE, ORDER BY, DISTINCT and LIMIT
- Joins: INNER JOIN, LEFT JOIN and other join operations
- Aggregation: COUNT, SUM, AVG, MIN, MAX, GROUP BY and HAVING
- Subqueries: Nested queries, EXISTS and NOT EXISTS
- Views and Indexes: Creating reusable views and improving data retrieval
- Transactions: COMMIT, ROLLBACK and SAVEPOINT
- Stored Programs: Stored procedures, functions and triggers
- Query Analysis: EXPLAIN and EXPLAIN ANALYZE
- Set Operations: UNION, UNION ALL, INTERSECT and EXCEPT

🚀 How to Run the Project

1. Install MySQL Server 8.0+ and MySQL Workbench.
2. Download or clone this repository.
3. Open the SQL source file in MySQL Workbench.
4. Connect to your local MySQL server.
5. Execute the script.
6. Refresh the Schemas panel and select the "CyberTrack" database.
7. Run the queries and explore the database objects.

Note: INTERSECT and EXCEPT require MySQL 8.0.31 or later.

📁 Project Files

- "CyberTrack_Complete_Source_Code.sql" — Complete SQL implementation.
- ER diagram and project documentation — Add these files to the repository if included in your submission.

📚 Learning Outcomes

Through this project, I gained practical experience in:

- Relational database design and normalization concepts.
- Establishing relationships using primary and foreign keys.
- Writing SQL queries for data retrieval and analysis.
- Maintaining data integrity through constraints.
- Working with transactions and database objects.
- Applying database concepts to a cybersecurity-related use case.

⚠️ Disclaimer

CyberTrack is an academic RDBMS project developed for learning and demonstration purposes. It is not a live cybersecurity monitoring, threat detection, or incident response platform. All sample records are fictional.

👨‍💻 Author

Waris Sharma
BCA Cybersecurity Student
Lamrin Tech Skills University, Punjab

- GitHub: "github.com/warisrampal" (https://github.com/warisrampal)
- LinkedIn: [Add your LinkedIn profile link]

---

⭐ If you find this project useful for learning SQL or database management, feel free to explore the repository.

Built with SQL | Focused on Cybersecurity | Driven by Learning