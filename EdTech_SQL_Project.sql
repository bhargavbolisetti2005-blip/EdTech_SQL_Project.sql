-- ========================================================================
-- SECTION 1: DATABASE CREATION   
-- ========================================================================
CREATE DATABASE EdTechLearnPro;
GO

-- Switch into the database 
USE EdTechLearnPro;
GO


-- ========================================================================
-- SECTION 2: CREATE TABLES USING DDL + CONSTRAINTS   
-- ========================================================================

-- =================================================
-- Create Students Table 
-- Stores Students information
-- =================================================
CREATE TABLE Students
(
    StudentID INT NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    RegistrationDate DATE NOT NULL
        DEFAULT GETDATE(),
    IsActive BIT NOT NULL
        DEFAULT 1,
    
    -- Primary Key Constraint
    -- Ensures every StudentID is unique and NOT NULL 
    CONSTRAINT PK_Students
        PRIMARY KEY (StudentID),

    -- Unique Constraint
    -- Prevents duplicate email addresses 
    CONSTRAINT UQ_Students_Email
        UNIQUE (Email),
     
    -- Unique Constraint
    -- Prevents duplicate phone numbers 
    CONSTRAINT UQ_Students_Phone
        UNIQUE (Phone),
     
    -- Check Constraint
    -- Allows only 0 (Inactive) or 1 (Active) 
    CONSTRAINT CK_Students_IsActive
        CHECK (IsActive IN (0,1))

);

-- =================================================
-- Create Courses Table 
-- Stores Courses information
-- =================================================
CREATE TABLE Courses
(
    CourseID INT NOT NULL,
    CourseName VARCHAR(100) NOT NULL,
    Category VARCHAR(100) NOT NULL,
    CourseFee DECIMAL(10,2) NOT NULL,
    DifficultyLevel VARCHAR(50) NOT NULL,

    -- Primary Key Constraint
    -- Ensures every CourseID is unique and NOT NULL 
    CONSTRAINT PK_Courses
        PRIMARY KEY (CourseID),
    
    -- Unique Constraint
    -- Prevents duplicate course names
    CONSTRAINT UQ_Courses_CourseName
        UNIQUE (CourseName),

    -- Check Constraint
    -- Course fee cannot be negative
    CONSTRAINT CK_Courses_CourseFee
        CHECK (CourseFee >= 0),

    -- Check Constraint
    -- Allows only valid difficulty levels
    CONSTRAINT CK_Courses_Difficulty
        CHECK(DifficultyLevel IN
            ('Beginner','Intermediate','Advanced'))

);

-- =================================================
-- Create Trainers Table
-- Stores trainer information
-- =================================================
CREATE TABLE Trainers
(
    TrainerID INT NOT NULL,
    TrainerName	VARCHAR(100) NOT NULL,
    Expertise VARCHAR(50) NOT NULL,
    SatisfactionScore DECIMAL (10,2) NOT NULL,

    -- Primary Key Constraint
    -- Ensures every TrainerID is unique and NOT NULL
    CONSTRAINT PK_TrainerID
       PRIMARY KEY (TrainerID),

    -- Check Constraint
    -- Allows satisfaction score only between 0 and 5
    CONSTRAINT CK_SatisfactionScore
        CHECK(SatisfactionScore BETWEEN 0 AND 5)

);

-- =================================================
-- Create TrainerCourseMapping Table
-- Maps trainers to the courses they teach.
-- =================================================
CREATE TABLE TrainerCourseMapping
(
    MappingID INT NOT NULL,
    TrainerID INT NOT NULL,
    CourseID INT NOT NULL,
    AssignedDate DATE NOT NULL
        DEFAULT GETDATE(),

    -- Primary Key Constraint
    -- Ensures every MappingID is unique
    CONSTRAINT PK_TrainerCourseMapping
           PRIMARY KEY (MappingID),
    
    -- Foreign Key Constraint
    -- Links TrainerID with Trainers table
    CONSTRAINT FK_TrainerCourseMapping_Trainers
           FOREIGN KEY (TrainerID)
           REFERENCES Trainers(TrainerID),

    -- Foreign Key Constraint
    -- Links CourseID with Courses table
    CONSTRAINT FK_TrainerCourseMapping_Courses
           FOREIGN KEY (CourseID)
           REFERENCES Courses(CourseID)

);

-- =================================================
-- Create Enrollments Table
-- Stores student course enrollment details.
-- =================================================
CREATE TABLE  Enrollments
(
    EnrollmentID INT NOT NULL,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollmentDate DATE NOT NULL
        DEFAULT GETDATE(),
    Discount INT,
    PaymentStatus VARCHAR(30),

    -- Primary Key Constraint
    -- Ensures every EnrollmentID is unique
    CONSTRAINT PK_Enrollments_EnrollmentID
        PRIMARY KEY (EnrollmentID),

    -- Foreign Key Constraint
    -- Links StudentID with Students table
    CONSTRAINT FK_Enrollments_StudentID
        FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID),

    -- Foreign Key Constraint
    -- Links CourseID with Courses table
    CONSTRAINT FK_Enrollments_Courses
        FOREIGN KEY (CourseID)
        REFERENCES Courses(CourseID),

    -- Check Constraint
    -- Discount must be between 0% and 30%
    CONSTRAINT CK_Discount
        CHECK(Discount BETWEEN 0 AND 30),

    -- Check Constraint
    -- Allows only valid payment statuses
    CONSTRAINT CK_PaymentStatus
        CHECK(PaymentStatus IN 
            ('Paid','Partially Paid','Unpaid'))

);

-- =================================================
-- Create Payments Table
-- Stores payment details for each enrollment.
-- =================================================
CREATE TABLE Payments 
(
    PaymentID INT NOT NULL,
    EnrollmentID INT NOT NULL,
    AmountPaid DECIMAL(10,2) NOT NULL,
    PaymentDate DATE NOT NULL
        DEFAULT GETDATE(),

    -- Primary Key Constraint
    -- Ensures every PaymentID is unique
    CONSTRAINT PK_Payments_PaymentID
        PRIMARY KEY (PaymentID),

    -- Foreign Key Constraint
    -- Links EnrollmentID with Enrollments table
    CONSTRAINT FK_Payments_EnrollmentID
        FOREIGN KEY (EnrollmentID)
        REFERENCES Enrollments(EnrollmentID),

    -- Check Constraint
    -- Amount paid cannot be negative
    CONSTRAINT CK_AmountPaid
        CHECK (AmountPaid >=0)

);

-- =================================================
-- Create Marketing Table
-- Stores monthly marketing performance.
-- =================================================
CREATE TABLE Marketing
(
    MonthYear DATE NOT NULL,
    Channel VARCHAR(50) NOT NULL,
    Spend DECIMAL(10,2) NOT NULL,
    LeadsGenerated INT NOT NULL,

    -- Composite Primary Key
    -- One marketing channel should have only one record per month
    CONSTRAINT PK_Marketing
        PRIMARY KEY (MonthYear, Channel),

    -- Marketing spend cannot be negative
    CONSTRAINT CK_Marketing_Spend
        CHECK (Spend >= 0),

    -- Leads generated cannot be negative
    CONSTRAINT CK_Marketing_LeadsGenerated
        CHECK (LeadsGenerated >= 0)
);


-- ========================================================================
-- SECTION 3: IMPORT DATA FROM EXCEL  
-- ========================================================================

-- Import Wizard successful import
 
SELECT DB_NAME() AS CurrentDatabase;

SELECT * FROM Students

SELECT * FROM Trainers

SELECT * FROM TrainerCourseMapping

SELECT * FROM Courses

SELECT * FROM Payments

SELECT * FROM Marketing

SELECT * FROM Enrollments


-- ===========================================================
-- SECTION 4: ANALYTICAL QUERIES (DQL)
-- ===========================================================

-- Top 5 cities by student enrollments.  
SELECT TOP 5
    City,
    COUNT(DISTINCT StudentID) AS [Students Enrolled]
FROM Students
GROUP BY City
ORDER BY [Students Enrolled] DESC;

-- Students enrolled in more than 2 courses.
SELECT 
    StudentID,
    COUNT(DISTINCT CourseID) AS [Students Enrolled]
FROM Enrollments
GROUP BY StudentID
HAVING COUNT(CourseID) > 2
ORDER BY [Students Enrolled] DESC;

-- Students with no payment records.  
SELECT * FROM Enrollments
WHERE PaymentStatus IS NULL;

-- Highest revenue generating month.  
SELECT TOP 1
    FORMAT(PaymentDate,'yyyy-MM') AS [Year-Month],
    SUM(AmountPaid) AS Revenue
FROM Payments
GROUP BY FORMAT(PaymentDate,'yyyy-MM')
ORDER BY Revenue DESC;

-- Top 3 most popular courses.  
SELECT TOP 3
    C.CourseID,
    C.CourseName,
    COUNT(EnrollmentID) AS Enrollements
FROM Enrollments E
INNER JOIN Courses C ON C.CourseID = E.CourseID
GROUP BY C.CourseID,C.CourseName
ORDER BY Enrollements DESC;

-- Enrollments with discount above average discount.  
SELECT * FROM Enrollments
WHERE Discount > (SELECT AVG(Discount) FROM Enrollments)

-- States with more than 10 paid enrollments.  
SELECT 
    s.State,
    COUNT(e.EnrollmentID) AS Paid_Enrollments
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
WHERE e.PaymentStatus = 'Paid'
GROUP BY s.State
HAVING COUNT(e.EnrollmentID) > 10
ORDER BY Paid_Enrollments DESC;


-- ===========================================================
-- SECTION 5:  JOINS (ALL TYPES) 
-- ===========================================================

-- Students + Enrollments + Courses 
SELECT 
    S.FullName AS StudentName,
    C.CourseName,
    E.EnrollmentDate,
    E.PaymentStatus
FROM Students S 
INNER JOIN Enrollments E ON S.StudentID = E.StudentID
INNER JOIN Courses C ON C.CourseID = E.CourseID;

-- Courses + TrainerCourseMapping + Trainers 
SELECT 
    C.CourseName,
    T.TrainerName,
    T.Expertise,
    T.SatisfactionScore,
    TC.AssignedDate
FROM Courses C
INNER JOIN TrainerCourseMapping TC ON C.CourseID = TC.CourseID
INNER JOIN Trainers T ON T.TrainerID = TC.TrainerID;

--  Enrollments + Payments 
SELECT 
    E.EnrollmentID,
    E.StudentID,
    E.CourseID,
    E.PaymentStatus,
    P.AmountPaid,
    P.PaymentDate
FROM Enrollments E
LEFT JOIN Payments P ON E.EnrollmentID = P.EnrollmentID;

-- Marketing + Enrollments (month based)  
SELECT 
    FORMAT(M.MonthYear, 'yyyy-MM') AS Month,
    M.Channel,
    M.Spend,
    M.LeadsGenerated,
    COUNT(E.EnrollmentID) AS Total_Enrollments
FROM Enrollments E
RIGHT JOIN Marketing M
    ON FORMAT(E.EnrollmentDate, 'yyyy-MM') = FORMAT(M.MonthYear, 'yyyy-MM')
GROUP BY 
    FORMAT(M.MonthYear, 'yyyy-MM'),
    M.Channel,
    M.Spend,
    M.LeadsGenerated
ORDER BY Month, M.Channel;

-- Student Name + Course Name + Trainer Name  
SELECT 
    S.FullName AS Student_Name,
    C.CourseName,
    T.TrainerName
FROM Students S
INNER JOIN Enrollments E ON S.StudentID = E.StudentID
INNER JOIN Courses C ON C.CourseID = E.CourseID 
INNER JOIN TrainerCourseMapping TC ON TC.CourseID = C.CourseID
INNER JOIN Trainers T ON T.TrainerID = TC.TrainerID;

-- Trainer performance with number of assigned courses  
SELECT
    T.TrainerID,
    T.TrainerName,
    T.Expertise,
    COUNT(TC.CourseID) AS Assigned_Courses
FROM Trainers T
LEFT JOIN TrainerCourseMapping TC ON T.TrainerID = TC.TrainerID
GROUP BY T.TrainerID, T.TrainerName, T.Expertise
ORDER BY Assigned_Courses DESC;

-- Revenue per course  
SELECT 
    C.CourseID,
    C.CourseName,
    c.Category,
    SUM(P.AmountPaid) AS Total_Revenue
FROM Courses C
INNER JOIN Enrollments E ON E.CourseID = C.CourseID
INNER JOIN Payments P ON P.EnrollmentID = E.EnrollmentID
GROUP BY C.CourseID,C.CourseName,C.Category
ORDER BY Total_Revenue DESC;

-- City wise + course wise revenue summary 
SELECT 
S.City,
C.CourseName,
SUM(P.AmountPaid) AS Total_Revenue
FROM Students S
INNER JOIN Enrollments E ON S.StudentID = E.StudentID
INNER JOIN Courses C ON E.CourseID = C.CourseID
INNER JOIN Payments P ON P.EnrollmentID = E.EnrollmentID
GROUP BY S.City, C.CourseName
ORDER BY S.City, Total_Revenue DESC;


-- ================================================
-- SECTION 6: GROUP BY + HAVING + AGGREGATION
-- ================================================

-- 1. Monthly revenue
SELECT 
    FORMAT(PaymentDate, 'yyyy-MM') AS Month,
    SUM(AmountPaid) AS Monthly_Revenue
FROM Payments
GROUP BY FORMAT(PaymentDate, 'yyyy-MM')
ORDER BY Month DESC;


-- 2. Enrollment counts per course
SELECT 
    c.CourseName,
    c.Category,
    COUNT(e.EnrollmentID) AS Enrollment_Count
FROM Courses c
INNER JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName, c.Category
ORDER BY Enrollment_Count DESC;


-- 3. Average fee per category
SELECT 
    Category,
    AVG(CourseFee) AS Average_Fee,
    MIN(CourseFee) AS Min_Fee,
    MAX(CourseFee) AS Max_Fee
FROM Courses
GROUP BY Category
ORDER BY Average_Fee DESC;


-- 4. Trainer satisfaction averages
SELECT 
    Expertise,
    AVG(SatisfactionScore) AS Avg_Satisfaction,
    COUNT(TrainerID) AS Total_Trainers
FROM Trainers
GROUP BY Expertise
ORDER BY Avg_Satisfaction DESC;


-- 5. State wise registration patterns
SELECT 
    State,
    COUNT(StudentID) AS Total_Students,
    MIN(RegistrationDate) AS First_Registration,
    MAX(RegistrationDate) AS Latest_Registration
FROM Students
GROUP BY State
ORDER BY Total_Students DESC;


-- Extra (HAVING example) - States with more than 5 students
SELECT 
    State,
    COUNT(StudentID) AS Total_Students
FROM Students
GROUP BY State
HAVING COUNT(StudentID) > 5
ORDER BY Total_Students DESC;


-- ================================================
-- SECTION 7: SUBQUERIES + CTEs  
-- ================================================

--  Courses with above average enrollments 
SELECT 
    c.CourseID,
    c.CourseName,
    c.Category,
    COUNT(e.EnrollmentID) AS Enrollment_Count
FROM Courses c
INNER JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName, c.Category
HAVING COUNT(e.EnrollmentID) > (
    SELECT AVG(EnrollmentCount)
    FROM (
        SELECT COUNT(EnrollmentID) AS EnrollmentCount
        FROM Enrollments
        GROUP BY CourseID
    ) AS CourseEnrollments
)
ORDER BY Enrollment_Count DESC;

-- Students enrolled in the most expensive course 
SELECT 
    E.EnrollmentID,
    E.StudentID,
    C.CourseName,
    C.CourseFee
FROM Enrollments E
INNER JOIN Courses C ON C.CourseID = E.CourseID
WHERE C.CourseFee = (SELECT MAX(CourseFee) FROM Courses)

-- Highest discount enrollment details 
SELECT 
    E.EnrollmentID,
    S.FullName AS StudentName,
    C.CourseName,
    E.Discount,
    E.EnrollmentDate,
    E.PaymentStatus
FROM Enrollments E
INNER JOIN Students S ON E.StudentID = S.StudentID
INNER JOIN Courses C ON E.CourseID = C.CourseID
WHERE E.Discount = (SELECT MAX(Discount) FROM Enrollments);

-- Revenue trend CTE for last 6 months  
WITH MonthlyRevenue AS(
SELECT 
        FORMAT(PaymentDate, 'yyyy-MM') AS Year_Month,
        SUM(AmountPaid) AS Revenue
    FROM Payments
    GROUP BY FORMAT(PaymentDate, 'yyyy-MM')
)
SELECT 
    Year_Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year_Month) AS Previous_Month_Revenue,
    Revenue - LAG(Revenue) OVER (ORDER BY Year_Month) AS Revenue_Change
FROM MonthlyRevenue
ORDER BY Year_Month DESC
OFFSET 0 ROWS FETCH NEXT 6 ROWS ONLY;


-- ================================================
-- SECTION 8:  WINDOW FUNCTIONS
-- ================================================

-- RANK() revenue per month 
WITH MonthlyRevenue AS
(
    SELECT DISTINCT
        FORMAT(PaymentDate, 'yyyy-MM') AS Year_Month,
        SUM(AmountPaid) OVER (PARTITION BY FORMAT(PaymentDate, 'yyyy-MM')) AS Revenue
    FROM Payments
)
SELECT
    Year_Month,
    Revenue,
    RANK() OVER (ORDER BY Revenue DESC) AS Revenue_Rank
FROM MonthlyRevenue;

-- DENSE_RANK() top 3 courses per month 
WITH CourseCounts AS
(
    SELECT DISTINCT 
        FORMAT(EnrollmentDate,'yyyy-MM') AS Year_Month,
        C.CourseName,
        COUNT(E.EnrollmentID) OVER(PARTITION BY FORMAT(EnrollmentDate,'yyyy-MM'),C.CourseName) AS Enrollment_Count
    FROM Enrollments E 
    INNER JOIN Courses C ON C.CourseID = E.CourseID
),
RankedCourses AS
(
    SELECT 
        Year_Month,
        CourseName,
        Enrollment_Count,
        DENSE_RANK() OVER(PARTITION BY Year_Month ORDER BY Enrollment_Count DESC) AS Course_Rank
    FROM CourseCounts
)
SELECT *
FROM RankedCourses
WHERE Course_Rank <= 3
ORDER BY Year_Month, Course_Rank;

-- LAG() for month over month revenue change 
WITH MonthlyRevenue AS
(
    SELECT
        FORMAT(PaymentDate, 'yyyy-MM') AS Year_Month,
        SUM(AmountPaid) AS Revenue
    FROM Payments
    GROUP BY FORMAT(PaymentDate, 'yyyy-MM')
)
SELECT
    Year_Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year_Month) AS Previous_Month_Revenue,
    Revenue - LAG(Revenue) OVER (ORDER BY Year_Month) AS Revenue_Change
FROM MonthlyRevenue;

-- LEAD() to forecast next month trend 
WITH MonthlyRevenue AS
(
    SELECT
        FORMAT(PaymentDate, 'yyyy-MM') AS Year_Month,
        SUM(AmountPaid) AS Revenue
    FROM Payments
    GROUP BY FORMAT(PaymentDate, 'yyyy-MM')
)
SELECT
    Year_Month,
    Revenue,
    LEAD(Revenue) OVER (ORDER BY Year_Month) AS Next_Month_Revenue,
    LEAD(Revenue) OVER (ORDER BY Year_Month) - Revenue AS Expected_Change
FROM MonthlyRevenue;

-- ROW_NUMBER() for duplicate detection
SELECT 
    StudentID,
    FullName,
    Email,
    ROW_NUMBER() OVER (PARTITION BY Email ORDER BY StudentID) AS Row_Num -- IF Row_Num IS GRATER THAN 1 --> Duplicate detection
FROM Students;


-- ================================================
-- SECTION 9:   VIEWS 
-- ================================================

-- vw_MonthlyRevenue  
CREATE VIEW vw_MonthlyRevenue AS 
SELECT 
    FORMAT(PaymentDate,'yyyy-MM') AS Year_Month,
    SUM(AmountPaid) AS Revenue,
    AVG(AmountPaid) AS Average_Amount
FROM Payments
GROUP BY FORMAT(PaymentDate,'yyyy-MM')

SELECT * FROM vw_MonthlyRevenue
ORDER BY Year_Month;

-- vw_TrainerPerformance  
CREATE VIEW vw_TrainerPerformance AS
SELECT 
    t.TrainerID,
    t.TrainerName,
    t.Expertise,
    t.SatisfactionScore,
    COUNT(tcm.CourseID) AS Assigned_Courses,
    AVG(t.SatisfactionScore) OVER() AS Overall_Avg_Satisfaction
FROM Trainers t
LEFT JOIN TrainerCourseMapping tcm ON t.TrainerID = tcm.TrainerID
GROUP BY 
    t.TrainerID, 
    t.TrainerName, 
    t.Expertise, 
    t.SatisfactionScore;

SELECT * FROM vw_TrainerPerformance
ORDER BY Assigned_Courses DESC;


-- ================================================
-- SECTION 10:  INDEXES  
-- ================================================

-- 1. Index on Students.Email
CREATE NONCLUSTERED INDEX IX_Students_Email
ON Students (Email);

-- 2. Index on Courses.CourseName
CREATE NONCLUSTERED INDEX IX_Courses_CourseName
ON Courses (CourseName);

-- 3. Index on Enrollments.EnrollmentDate
CREATE NONCLUSTERED INDEX IX_Enrollments_EnrollmentDate
ON Enrollments (EnrollmentDate);

-- 4. Composite Index on (StudentID, CourseID)
CREATE NONCLUSTERED INDEX IX_Enrollments_Student_Course
ON Enrollments (StudentID, CourseID);
GO

-- ================================================
-- SECTION 11:  STORED PROCEDURES   
-- ================================================

-- Fetching monthly revenue (IN parameter)  
CREATE PROCEDURE sp_MonthlyRevenue
    @YearMonth VARCHAR(7)   
AS
BEGIN
    SELECT 
        FORMAT(PaymentDate, 'yyyy-MM') AS Year_Month,
        SUM(AmountPaid) AS Total_Revenue
    FROM Payments
    WHERE FORMAT(PaymentDate, 'yyyy-MM') = @YearMonth
    GROUP BY FORMAT(PaymentDate, 'yyyy-MM');
END;

EXEC sp_MonthlyRevenue @YearMonth = '2025-06'
GO

-- Adding a new student with validation (INOUT)  
CREATE PROCEDURE sp_AddNewStudent
    @FullName        VARCHAR(100),
    @Email           VARCHAR(100),
    @Phone           VARCHAR(15),
    @City            VARCHAR(50),
    @State           VARCHAR(50),
    @StudentID       INT           OUTPUT,   -- returns the newly generated StudentID
    @StatusMessage   VARCHAR(200)  OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Students WHERE Email = @Email)
    BEGIN
        SET @StatusMessage = 'Error: A student with this email already exists.';
        SET @StudentID = NULL;
        RETURN;
    END
 
    IF EXISTS (SELECT 1 FROM Students WHERE Phone = @Phone)
    BEGIN
        SET @StatusMessage = 'Error: A student with this phone number already exists.';
        SET @StudentID = NULL;
        RETURN;
    END
 
    SELECT @StudentID = ISNULL(MAX(StudentID), 1000) + 1 FROM Students;
 
    INSERT INTO Students (StudentID, FullName, Email, Phone, City, State, RegistrationDate, IsActive)
    VALUES (@StudentID, @FullName, @Email, @Phone, @City, @State, GETDATE(), 1);
 
    SET @StatusMessage = 'Success: Student added with StudentID ' + CAST(@StudentID AS VARCHAR(10)) + '.';
END;
GO

DECLARE @NewID INT, @Msg VARCHAR(200);
EXEC sp_AddNewStudent
    @FullName = 'Test Student', @Email = 'test999@example.com', @Phone = '9999999999',
    @City = 'Hyderabad', @State = 'Telangana',
    @StudentID = @NewID OUTPUT, @StatusMessage = @Msg OUTPUT;
SELECT @NewID AS NewStudentID, @Msg AS Message;
GO

-- Getting trainer performance above a threshold (OUT)
CREATE PROCEDURE sp_TrainerPerformanceAboveThreshold
    @Threshold      DECIMAL(10,2),
    @TrainerCount   INT OUTPUT
AS
BEGIN
    SELECT TrainerID, TrainerName, Expertise, SatisfactionScore
    FROM Trainers
    WHERE SatisfactionScore > @Threshold
    ORDER BY SatisfactionScore DESC;
 
    SELECT @TrainerCount = COUNT(*) FROM Trainers WHERE SatisfactionScore > @Threshold;
END;
GO
 
DECLARE @Cnt INT;
EXEC sp_TrainerPerformanceAboveThreshold @Threshold = 4.0, @TrainerCount = @Cnt OUTPUT;
SELECT @Cnt AS TrainersAboveThreshold;
GO

-- ================================================
-- SECTION 12:  USER DEFINED FUNCTIONS     
-- ================================================

-- 1. Scalar Function -> fn_NetFeeAfterDiscount
CREATE FUNCTION fn_NetFeeAfterDiscount
(
    @CourseFee  DECIMAL(10,2),
    @Discount   INT              -- percentage, e.g. 20 = 20%
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @CourseFee - (@CourseFee * @Discount / 100.0);
END;
GO

SELECT CourseName, CourseFee, dbo.fn_NetFeeAfterDiscount(CourseFee, 20) AS NetFeeAt20Pct
FROM Courses;
GO
 
-- 2. Table Valued Function -> return enrollments by course
CREATE FUNCTION fn_GetEnrollmentsByCourse
(
    @CourseID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        e.EnrollmentID,
        s.FullName       AS StudentName,
        c.CourseName,
        e.EnrollmentDate,
        e.Discount,
        e.PaymentStatus
    FROM Enrollments e
    JOIN Students s ON e.StudentID = s.StudentID
    JOIN Courses  c ON e.CourseID  = c.CourseID
    WHERE e.CourseID = @CourseID
);
GO

SELECT * FROM dbo.fn_GetEnrollmentsByCourse(501);
GO


-- ================================================
-- SECTION 13:  EXCEPTION HANDLING
-- ================================================

-- ErrorLog Table
IF OBJECT_ID('ErrorLog') IS NULL
BEGIN
    CREATE TABLE ErrorLog
    (
        ErrorID INT IDENTITY(1,1) PRIMARY KEY,
        ErrorMessage NVARCHAR(MAX),
        ErrorNumber INT,
        ErrorSeverity INT,
        ErrorState INT,
        ErrorTime DATETIME DEFAULT GETDATE()
    );
END
GO

-- Example: Stored Procedure with TRY...CATCH
CREATE OR ALTER PROCEDURE sp_AddStudent_Safe
    @FullName VARCHAR(100),
    @Email VARCHAR(100),
    @Phone VARCHAR(15),
    @City VARCHAR(50),
    @State VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Validation
        IF @FullName IS NULL OR @Email IS NULL
        BEGIN
            RAISERROR('FullName and Email are required fields.', 16, 1);
            RETURN;
        END

        -- Insert Student
        INSERT INTO Students (FullName, Email, Phone, City, State, RegistrationDate, IsActive)
        VALUES (@FullName, @Email, @Phone, @City, @State, GETDATE(), 1);

        PRINT 'Student added successfully.';
    END TRY
    BEGIN CATCH
        -- Log error into ErrorLog table
        INSERT INTO ErrorLog (ErrorMessage, ErrorNumber, ErrorSeverity, ErrorState)
        VALUES (
            ERROR_MESSAGE(),
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE()
        );

        -- User friendly message
        PRINT 'Something went wrong. Please check the input values.';
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

EXEC sp_AddStudent_Safe
    @FullName = NULL,
    @Email = 'test@gmail.com',
    @Phone = '9999999999',
    @City = 'Chennai',
    @State = 'Tamil Nadu';

-- ErrorLog check
SELECT * FROM ErrorLog ORDER BY ErrorTime DESC;
GO

-- ================================================
-- SECTION 14 — TRIGGERS
-- ================================================

-- 1. BEFORE INSERT → Prevent Discount > 50%
CREATE OR ALTER TRIGGER trg_PreventHighDiscount
ON Enrollments
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE Discount > 50)
    BEGIN
        RAISERROR('Discount cannot be more than 50%%.', 16, 1);
        RETURN;
    END

    INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID, EnrollmentDate, Discount, PaymentStatus)
    SELECT 
        EnrollmentID, 
        StudentID, 
        CourseID, 
        EnrollmentDate, 
        Discount, 
        PaymentStatus
    FROM inserted;
END;
GO

INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID, EnrollmentDate, Discount, PaymentStatus)
VALUES (9991, 1, 1, GETDATE(), 60, 'Unpaid');
GO

-- 2. AFTER INSERT → Auto insert AmountPaid = 0 when PaymentStatus = 'Unpaid'
CREATE OR ALTER TRIGGER trg_AutoZeroPayment
ON Enrollments
AFTER INSERT
AS
BEGIN
    INSERT INTO Payments (PaymentID, EnrollmentID, AmountPaid, PaymentDate)
    SELECT 
        (SELECT ISNULL(MAX(PaymentID), 0) + ROW_NUMBER() OVER (ORDER BY i.EnrollmentID) FROM Payments),
        i.EnrollmentID,
        0,
        GETDATE()
    FROM inserted i
    WHERE i.PaymentStatus = 'Unpaid'
      AND NOT EXISTS (SELECT 1 FROM Payments p WHERE p.EnrollmentID = i.EnrollmentID);
END;
GO
-- This should succeed + create payment with 0
INSERT INTO Enrollments (EnrollmentID, StudentID, CourseID, EnrollmentDate, Discount, PaymentStatus)
VALUES (9004, 1001, 502, GETDATE(), 10, 'Unpaid');

SELECT * FROM Payments WHERE EnrollmentID = 9004;
GO

-- 3. AFTER UPDATE → Log old + new values into AuditLog
IF OBJECT_ID('AuditLog') IS NULL
BEGIN
    CREATE TABLE AuditLog
    (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        TableName VARCHAR(50),
        OldValues NVARCHAR(MAX),
        NewValues NVARCHAR(MAX),
        ChangedAt DATETIME DEFAULT GETDATE()
    );
END
GO

CREATE OR ALTER TRIGGER trg_AuditEnrollmentUpdate
ON Enrollments
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditLog (TableName, OldValues, NewValues)
    SELECT 
        'Enrollments',
        (SELECT * FROM deleted FOR XML PATH('Old')),
        (SELECT * FROM inserted FOR XML PATH('New'));
END;
GO

UPDATE Enrollments SET Discount = 25 WHERE EnrollmentID = 9002;
SELECT * FROM AuditLog;

-- ================================================
-- SECTION 15:   FINAL ANALYTICAL TASKS  
-- ================================================

-- CAC (Cost per Acquisition)- ROI per marketing channel 
WITH MonthlySpend AS (
    SELECT 
        FORMAT(MonthYear, 'yyyy-MM') AS Year_Month, 
        SUM(Spend) AS Total_Spend, 
        SUM(LeadsGenerated) AS Total_Leads
    FROM Marketing
    GROUP BY FORMAT(MonthYear, 'yyyy-MM')
),
MonthlyEnrollments AS (
    SELECT 
        FORMAT(EnrollmentDate, 'yyyy-MM') AS Year_Month, 
        COUNT(*) AS New_Enrollments
    FROM Enrollments
    GROUP BY FORMAT(EnrollmentDate, 'yyyy-MM')
)
SELECT
    ms.Year_Month,
    ms.Total_Spend,
    ms.Total_Leads,
    me.New_Enrollments,
    ROUND(ms.Total_Spend * 1.0 / NULLIF(me.New_Enrollments, 0), 2) AS CAC
FROM MonthlySpend ms
JOIN MonthlyEnrollments me ON ms.Year_Month = me.Year_Month
ORDER BY ms.Year_Month;
 
-- 2. ROI / efficiency per marketing channel
SELECT
    Channel,
    SUM(Spend) AS Total_Spend,
    SUM(LeadsGenerated) AS Total_Leads,
    ROUND(SUM(Spend) * 1.0 / NULLIF(SUM(LeadsGenerated), 0), 2) AS Cost_Per_Lead
FROM Marketing
GROUP BY Channel
ORDER BY Cost_Per_Lead ASC;
 
-- 3. 12-month enrollment heatmap (Month x City)
SELECT *
FROM (
    SELECT 
        s.City, 
        FORMAT(e.EnrollmentDate, 'yyyy-MM') AS Year_Month
    FROM Enrollments e
    JOIN Students s ON e.StudentID = s.StudentID
) AS src
PIVOT (
    COUNT(Year_Month)
    FOR Year_Month IN (
        [2025-01],[2025-02],[2025-03],[2025-04],[2025-05],[2025-06],
        [2025-07],[2025-08],[2025-09],[2025-10],[2025-11],[2025-12]
    )
) AS pvt
ORDER BY City;
 
-- 4. Top course & worst course by revenue
WITH CourseRevenue AS (
    SELECT 
        c.CourseID, 
        c.CourseName, 
        SUM(p.AmountPaid) AS Revenue
    FROM Courses c
    JOIN Enrollments e ON c.CourseID = e.CourseID
    JOIN Payments p ON e.EnrollmentID = p.EnrollmentID
    GROUP BY c.CourseID, c.CourseName
)
SELECT *,'Top Course' AS Category 
FROM CourseRevenue
WHERE Revenue = (SELECT MAX(Revenue) FROM CourseRevenue)
UNION ALL
SELECT *, 'Worst Course' AS Category 
FROM CourseRevenue 
WHERE Revenue = (SELECT MIN(Revenue) FROM CourseRevenue);
 
-- 5. Trainer impact on course satisfaction / revenue
SELECT
    t.TrainerID,
    t.TrainerName,
    t.SatisfactionScore,
    COUNT(DISTINCT tcm.CourseID) AS Courses_Assigned,
    SUM(rev.Revenue) AS Total_Revenue_Of_Assigned_Courses
FROM Trainers t
JOIN TrainerCourseMapping tcm ON t.TrainerID = tcm.TrainerID
LEFT JOIN (
    SELECT e.CourseID, SUM(p.AmountPaid) AS Revenue
    FROM Enrollments e
    JOIN Payments p ON e.EnrollmentID = p.EnrollmentID
    GROUP BY e.CourseID
) rev ON rev.CourseID = tcm.CourseID
GROUP BY t.TrainerID, t.TrainerName, t.SatisfactionScore
ORDER BY t.SatisfactionScore DESC;
 
-- 6. Month over month business growth
WITH MonthlyRevenue AS (
    SELECT 
        FORMAT(PaymentDate, 'yyyy-MM') AS Year_Month, 
        SUM(AmountPaid) AS Revenue
    FROM Payments
    GROUP BY FORMAT(PaymentDate, 'yyyy-MM')
)
SELECT
    Year_Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year_Month)  AS Previous_Month_Revenue,
    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY Year_Month)) * 100.0
        / NULLIF(LAG(Revenue) OVER (ORDER BY Year_Month), 0)
    , 2) AS Growth_Percent
FROM MonthlyRevenue
ORDER BY Year_Month;
   


  