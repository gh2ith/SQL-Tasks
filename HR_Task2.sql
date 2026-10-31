USE TechWorldHRDB;
GO

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Salary DECIMAL(10,2),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

INSERT INTO Departments (DepartmentID, DepartmentName)
VALUES
(1, 'IT'),
(2, 'Human Resources'),
(3, 'Finance');

INSERT INTO Employees (EmployeeID, FullName, Email, Salary, DepartmentID)
VALUES
(1, 'Ahmad Ali', 'ahmad@example.com', 1500, 1),
(2, 'Sara Hassan', 'sara@example.com', 1200, 2),
(3, 'Zaid Omar', 'zaid@example.com', 900, 1);

CREATE TABLE AccessCards (
    CardID INT PRIMARY KEY,
    CardNumber VARCHAR(50) NOT NULL UNIQUE,
    EmployeeID INT NOT NULL UNIQUE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL
);

CREATE TABLE EmployeeProjects (
    EmployeeID INT,
    ProjectID INT,
    AssignedDate DATE,
    PRIMARY KEY (EmployeeID, ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

INSERT INTO AccessCards (CardID, CardNumber, EmployeeID)
VALUES
(101, 'CARD-101', 1),
(102, 'CARD-102', 2),
(103, 'CARD-103', 3);

INSERT INTO Projects (ProjectID, ProjectName)
VALUES
(1, 'AI & Security Training'),
(2, 'Cloud Migration');

INSERT INTO EmployeeProjects (EmployeeID, ProjectID, AssignedDate)
VALUES
(1, 1, '2026-11-01'),
(1, 2, '2026-11-01'),
(2, 1, '2026-11-01'),
(3, 2, '2026-11-01');

SELECT Employees.FullName, Employees.Salary, Departments.DepartmentName
FROM Employees
INNER JOIN Departments
ON Employees.DepartmentID = Departments.DepartmentID;

SELECT Departments.DepartmentName, Employees.FullName
FROM Departments
LEFT JOIN Employees
ON Departments.DepartmentID = Employees.DepartmentID;

SELECT Employees.FullName, AccessCards.CardNumber
FROM Employees
INNER JOIN AccessCards
ON Employees.EmployeeID = AccessCards.EmployeeID;

SELECT Employees.FullName, Projects.ProjectName, EmployeeProjects.AssignedDate
FROM Employees
INNER JOIN EmployeeProjects
ON Employees.EmployeeID = EmployeeProjects.EmployeeID
INNER JOIN Projects
ON EmployeeProjects.ProjectID = Projects.ProjectID;

SELECT DepartmentID,
       SUM(Salary) AS TotalSalary,
       COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY DepartmentID;

SELECT DepartmentID, AVG(Salary) AS AvgSalary
FROM Employees
GROUP BY DepartmentID
HAVING AVG(Salary) > 1000;

SELECT *
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees);

CREATE TABLE EmployeeAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    Action VARCHAR(50),
    ActionDate DATETIME
);
GO

CREATE VIEW vw_EmployeeDetails AS
SELECT Employees.EmployeeID,
       Employees.FullName,
       Employees.Email,
       Departments.DepartmentName
FROM Employees
INNER JOIN Departments
ON Employees.DepartmentID = Departments.DepartmentID;
GO

CREATE PROCEDURE sp_GetEmployeesByDepartment
    @DeptID INT
AS
BEGIN
    SELECT *
    FROM Employees
    WHERE DepartmentID = @DeptID;
END;
GO

CREATE TRIGGER trg_EmployeeDelete
ON Employees
AFTER DELETE
AS
BEGIN
    INSERT INTO EmployeeAudit (EmployeeID, Action, ActionDate)
    SELECT EmployeeID, 'DELETE', GETDATE()
    FROM deleted;
END;
GO

SELECT * FROM vw_EmployeeDetails;

EXEC sp_GetEmployeesByDepartment @DeptID = 1;

SELECT * FROM EmployeeAudit;