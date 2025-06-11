--PROJECT 2

-- Students Table
CREATE TABLE Project2_Students (
    Student_ID INT PRIMARY KEY,
    FullName VARCHAR(100),
    City VARCHAR(100)
);

-- Courses Table
CREATE TABLE Project2_Courses (
    Course_ID INT PRIMARY KEY,
    CourseName VARCHAR(100)
);

-- Enrollments Table
CREATE TABLE Project2_Enrollments (
    Enrollment_ID INT PRIMARY KEY,
    Student_ID INT FOREIGN KEY REFERENCES Project2_Students(Student_ID),
    Course_ID INT FOREIGN KEY REFERENCES Project2_Courses(Course_ID),
    EnrollmentDate DATE
);

-- Payments Table
CREATE TABLE Project2_Payments (
    Payment_ID INT PRIMARY KEY,
    Student_ID INT FOREIGN KEY REFERENCES Project2_Students(Student_ID),
    Amount DECIMAL(10,2),
    PaymentDate DATE
);

-- Support Tickets Table
CREATE TABLE Project2_Tickets (
    Ticket_ID INT PRIMARY KEY,
    Student_ID INT FOREIGN KEY REFERENCES Project2_Students(Student_ID),
    Issue VARCHAR(255),
    CreatedAt DATETIME
);


-- Insert Customers
INSERT INTO DEMO_NCPL VALUES
(1, 'Alice', 'Toronto'),
(2, 'Bob', 'Montreal'),
(3, 'Charlie', 'Calgary'),
(4, 'Diana', 'Vancouver');

-- Students
INSERT INTO Project2_Students VALUES
(1, 'Arjun Sharma', 'Delhi'),
(2, 'Meera Kaur', 'Chandigarh'),
(3, 'Ravi Nair', 'Mumbai');

-- Courses
INSERT INTO Project2_Courses VALUES
(101, 'Azure Data Fundamentals'),
(102, 'SQL for Data Analysis');

-- Enrollments
INSERT INTO Project2_Enrollments VALUES
(1001, 1, 101, '2024-05-01'),
(1002, 2, 102, '2024-06-15');

-- Payments
INSERT INTO Project2_Payments VALUES
(5001, 1, 299.00, '2024-05-05'),
(5002, 2, 399.00, '2024-06-20');

-- Tickets
INSERT INTO Project2_Tickets VALUES
(7001, 1, 'Login issue', GETDATE()),
(7002, 2, 'Course access problem', GETDATE());


-- For all constraints on Project2 tables
SELECT 
    TABLE_NAME, 
    CONSTRAINT_NAME, 
    CONSTRAINT_TYPE
FROM 
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE 
    TABLE_NAME LIKE 'Project2%';


-- Drop Foreign Keys
ALTER TABLE Project2_Enrollments DROP CONSTRAINT FK__Project2___Stude__59C55456;
ALTER TABLE Project2_Enrollments DROP CONSTRAINT FK__Project2___Cours__5AB9788F;

ALTER TABLE Project2_Payments DROP CONSTRAINT FK__Project2___Stude__5D95E53A;

ALTER TABLE Project2_Tickets DROP CONSTRAINT FK__Project2___Stude__607251E5;

-- Drop Primary Keys
ALTER TABLE Project2_Students DROP CONSTRAINT PK__Project2__A2F4E9ACF2771454;
ALTER TABLE Project2_Courses DROP CONSTRAINT PK__Project2__37E005FBA5124E6D;
ALTER TABLE Project2_Enrollments DROP CONSTRAINT PK__Project2__4365BD6AAA78E87A;
ALTER TABLE Project2_Payments DROP CONSTRAINT PK__Project2__DA6C7FE1F5983115;
ALTER TABLE Project2_Tickets DROP CONSTRAINT PK__Project2__ED7260D9EAE7BCA5;

-- Duplicate primary key
INSERT INTO Project2_Students VALUES (1, 'Duplicate Arjun', 'Bangalore');

-- Insert NULL into primary key field
INSERT INTO Project2_Tickets VALUES (NULL, 1, 'NULL Ticket ID Test', GETDATE());

-- Insert enrollment with non-existent student
INSERT INTO Project2_Enrollments VALUES (1003, 999, 999, '2024-07-01');
INSERT INTO Project2_Payments VALUES (5003, 888, 199.00, '2024-07-25');
INSERT INTO Project2_Tickets VALUES (7003, 999, 'Fake Student ID', GETDATE());

-- Insert payment with non-existent student
INSERT INTO Project2_Payments VALUES (5003, 888, 189.00, '2024-07-25');

-- Insert Tickets for a non-existent student
INSERT INTO Project2_Tickets VALUES (7003, 999, 'Fake Student ID', GETDATE());


SELECT * 
FROM Project2_Enrollments e
LEFT JOIN Project2_Students s ON e.Student_ID = s.Student_ID
WHERE s.Student_ID IS NULL;

SELECT Student_ID, COUNT(*) 
FROM Project2_Students
GROUP BY Student_ID
HAVING COUNT(*) > 1;
