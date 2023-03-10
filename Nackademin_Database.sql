--create database Nackademin
CREATE DATABASE
	Nackademin
ON  PRIMARY 
	(NAME = N'Nackademin', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DE22\MSSQL\DATA\Nackademin.mdf', 
	SIZE = 1048576KB, 
	FILEGROWTH = 10%)
LOG ON 
	(NAME = N'Nackademin_log', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DE22\MSSQL\DATA\Nackademin_log.ldf', 
	SIZE = 262144KB, 
	FILEGROWTH = 10%)
COLLATE 
	Latin1_General_100_CI_AS
GO


USE 
	Nackademin
GO


--create database tables and insert some sample data
CREATE TABLE
	Students(
		StudentID INT IDENTITY(1,1) PRIMARY KEY,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL,
		Personnummer VARCHAR(12) NOT NULL
	)

INSERT INTO Students VALUES ('Bianca', 'Tulio Yarck', '8903186420')
INSERT INTO Students VALUES ('Roberta', 'de Souza Rodrigues Alves', '8703091234')
INSERT INTO Students VALUES ('Dhiana Deva', 'Cavalcanti Rocha', '8902231234')
INSERT INTO Students VALUES ('Bruna', 'Tulio Yarck', '8208181234')


CREATE TABLE
	StudentInfo(
		StudentInfoID INT IDENTITY(1,1) PRIMARY KEY, 
		StudentID INT FOREIGN KEY REFERENCES Students(StudentID) NOT NULL,
		StudentAddress VARCHAR(255) NOT NULL,
		Zipcode VARCHAR(15) NOT NULL,
		Phone VARCHAR(15) NOT NULL,
		Email VARCHAR(100) NOT NULL,
		EmergencyContact VARCHAR(100),
		EmergencyPhone VARCHAR(15),
		CSN INT
	)

INSERT INTO StudentInfo VALUES (1, 'Ringvägen 6', '11726', '0738715690', 'bianca.yarck@gmail.com', 'Dhiana (Sambo)', '123456789', 1)
INSERT INTO StudentInfo VALUES (2, 'Ringvägen 6', '11726', '123456789', 'betaalves.gd@gmail.com', 'Bianca (Sambo)', '9738715690', 0)
INSERT INTO StudentInfo VALUES (3, 'Ringvägen 6', '11726', '123456789', 'dhianadeva@gmail.com', 'Bianca (Sambo)', '123456789', 0)
INSERT INTO StudentInfo VALUES (4, 'Rua Marechal Castelo Branco', '80050020', '0738715690', 'brunatulio@gmail.com', NULL, NULL, 0)


CREATE TABLE
	Staff(
		StaffID INT IDENTITY(1,1) PRIMARY KEY,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL,
		Personnummer VARCHAR(12) NOT NULL
	)

INSERT INTO Staff VALUES ('Mikael', 'Lönroos', '1234567890')
INSERT INTO Staff VALUES ('Andreas', 'Någonting', '1234567890')
INSERT INTO Staff VALUES ('Ottilia', 'Någonting', '1234567890')
INSERT INTO Staff VALUES ('Astrid', 'Någonting', '1234567890')


CREATE TABLE
	StaffInfo(
		StaffInfoID INT IDENTITY(1,1) PRIMARY KEY, 
		StaffID INT FOREIGN KEY REFERENCES Staff(StaffID) NOT NULL,
		StaffAddress VARCHAR(255) NOT NULL,
		Zipcode VARCHAR(15) NOT NULL,
		Phone VARCHAR(15) NOT NULL,
		Email VARCHAR(100) NOT NULL,
		EmergencyContact VARCHAR(100),
		EmergencyPhone VARCHAR(15),
		BankAccount VARCHAR(50) NOT NULL
	)

INSERT INTO StaffInfo VALUES (1, 'Tomtebodavägen 3A', '17165', '1234567890', 'milo@yh.nackademin.se', NULL, NULL, '0987654321')
INSERT INTO StaffInfo VALUES (2, 'Tomtebodavägen 3A', '17165', '1234567890', 'anna@yh.nackademin.se', NULL, NULL, '0987654321')
INSERT INTO StaffInfo VALUES (3, 'Tomtebodavägen 3A', '17165', '1234567890', 'otna@yh.nackademin.se', NULL, NULL, '0987654321')
INSERT INTO StaffInfo VALUES (4, 'Tomtebodavägen 3A', '17165', '1234567890', 'asna@yh.nackademin.se', NULL, NULL, '0987654321')


CREATE TABLE
	Departments(
		DepartmentID INT IDENTITY(1,1) PRIMARY KEY, 
		DepartmentName VARCHAR(50) NOT NULL
	)

INSERT INTO Departments VALUES ('Executive')
INSERT INTO Departments VALUES ('Administration')
INSERT INTO Departments VALUES ('Academy')


CREATE TABLE
	Roles(
		RoleID INT IDENTITY(1,1) PRIMARY KEY, 
		RoleName VARCHAR(50) NOT NULL,
		DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID) NOT NULL
	)

INSERT INTO Roles VALUES ('CEO', 1)
INSERT INTO Roles VALUES ('CTO', 1)
INSERT INTO Roles VALUES ('Program Manager', 2)
INSERT INTO Roles VALUES ('Secretary', 2)
INSERT INTO Roles VALUES ('Teacher', 3)
INSERT INTO Roles VALUES ('Consultant', 3)


CREATE TABLE
	Contracts(
		ContractID INT IDENTITY(1,1) PRIMARY KEY, 
		StaffID INT FOREIGN KEY REFERENCES Staff(StaffID) NOT NULL,
		ContractType VARCHAR(50) NOT NULL,
		StartDate DATETIME2 NOT NULL,
		EndDate DATETIME2,
		RoleID INT FOREIGN KEY REFERENCES Roles(RoleID) NOT NULL,
		ManagerID INT FOREIGN KEY REFERENCES Staff(StaffID)
	)

INSERT INTO Contracts VALUES (1, 'Permanent', '2020-08-01', NULL, 5, 3)
INSERT INTO Contracts VALUES (2, 'Temporary', '2023-08-01', '2023-09-01', 6, 3)
INSERT INTO Contracts VALUES (3, 'Permanent', '2020-08-01', NULL, 3, 4)
INSERT INTO Contracts VALUES (4, 'Permanent', '2002-01-01', NULL, 1, NULL)


CREATE TABLE
	Salaries(
		SalaryID INT IDENTITY(1,1) PRIMARY KEY, 
		StaffID INT FOREIGN KEY REFERENCES Staff(StaffID) NOT NULL,
		PaymentDate DATETIME2 NOT NULL,
		SalaryMonth INT NOT NULL,
		HourPay DECIMAL(10,2) NOT NULL,
		WorkedHours INT NOT NULL,
		ExtraHours INT, 
		SickLeaveHours INT,
		BonusPercent DECIMAL(10,2),
		TotalAmount AS ((HourPay * WorkedHours) + ((HourPay * WorkedHours) * BonusPercent) - 
							(SickLeaveHours * HourPay) + (ExtraHours * (HourPay * 1.5)))
	)

INSERT INTO Salaries VALUES (1, '2023-02-25', 2, 190, 64, 16, 0, 0.1)
INSERT INTO Salaries VALUES (1, '2023-03-25', 3, 190, 80, 4, 8, 0.1)
INSERT INTO Salaries VALUES (2, '2022-08-25', 8, 140, 64, 96, 0, 0)
INSERT INTO Salaries VALUES (3, '2023-02-25', 2, 160, 120, 12, 12, 0)
INSERT INTO Salaries VALUES (3, '2023-03-25', 3, 160, 120, 0, 0, 0)
INSERT INTO Salaries VALUES (4, '2023-02-25', 2, 250, 200, 9, 16, 0.3)
INSERT INTO Salaries VALUES (4, '2023-03-25', 3, 250, 200, 2, 0, 0.3)


CREATE TABLE
	Branches(
		BranchID INT IDENTITY(1,1) PRIMARY KEY, 
		BranchName VARCHAR(50) NOT NULL
	)

INSERT INTO Branches VALUES ('IT')
INSERT INTO Branches VALUES ('Design')
INSERT INTO Branches VALUES ('Communication')
INSERT INTO Branches VALUES ('Short Courses')


CREATE TABLE
	ProgramTypes(
		ProgramTypeID INT IDENTITY(1,1) PRIMARY KEY,
		ProgramTypeName VARCHAR(50),
		BranchID INT FOREIGN KEY REFERENCES Branches(BranchID)
	)

INSERT INTO ProgramTypes VALUES ('Data Engineer', 1)
INSERT INTO ProgramTypes VALUES ('Business Intelligence', 1)
INSERT INTO ProgramTypes VALUES ('DevOps Engineer', 1)
INSERT INTO ProgramTypes VALUES ('Digital Design', 2)
INSERT INTO ProgramTypes VALUES ('Package Design', 2)
INSERT INTO ProgramTypes VALUES ('Marketing', 3)
INSERT INTO ProgramTypes VALUES ('SQL Programming', 4)


CREATE TABLE
	Programs(
		ProgramID INT IDENTITY(1,1) PRIMARY KEY, 
		ProgramName VARCHAR(50) NOT NULL,
		ProgramTypeID INT FOREIGN KEY REFERENCES ProgramTypes(ProgramTypeID) NOT NULL,
		Points INT NOT NULL,
		StartDate DATETIME2 NOT NULL,
		EndDate DATETIME2 NOT NULL,
		ProgramManagerID INT FOREIGN KEY REFERENCES Staff(StaffID) 
	)

INSERT INTO Programs VALUES ('DE22', 1, 400, '2022-08-20', '2024-06-01', 3)
INSERT INTO Programs VALUES ('DE23', 1, 400, '2023-08-20', '2025-06-01', 3)
INSERT INTO Programs VALUES ('BI22', 2, 400, '2022-08-20', '2024-06-01', 3)
INSERT INTO Programs VALUES ('DD22', 4, 400, '2022-08-20', '2024-06-01', 3)
INSERT INTO Programs VALUES ('SQL22', 7, 40, '2022-06-15', '2024-08-15', 3)


CREATE TABLE
	Courses(
		CourseID INT IDENTITY(1,1) PRIMARY KEY, 
		CourseName VARCHAR(50) NOT NULL,
		ProgramID INT FOREIGN KEY REFERENCES Programs(ProgramID) NOT NULL,
		Points INT NOT NULL,
		StartDate DATETIME2 NOT NULL,
		EndDate DATETIME2 NOT NULL,
		TeacherID INT FOREIGN KEY REFERENCES Staff(StaffID)
	)

INSERT INTO Courses VALUES ('Business Processes', 1, 30, '2022-08-20', '2022-09-01', 2)
INSERT INTO Courses VALUES ('Business Processes', 2, 30, '2022-08-20', '2022-09-01', 2)
INSERT INTO Courses VALUES ('SQL1', 1, 40, '2022-09-02', '2022-11-01', 1)
INSERT INTO Courses VALUES ('SQL1', 2, 40, '2022-09-02', '2022-11-01', 1)
INSERT INTO Courses VALUES ('SQL2', 1, 40, '2022-11-02', '2023-01-01', 1)
INSERT INTO Courses VALUES ('Data Modeling', 1, 50, '2023-01-02', '2022-03-01', 1)
INSERT INTO Courses VALUES ('SQL1', 5, 20, '2022-06-15', '2022-07-15', 1)
INSERT INTO Courses VALUES ('SQL2', 5, 20, '2022-07-16', '2022-08-15', 1)


CREATE TABLE
	Enrollment(
		EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
		ProgramID INT FOREIGN KEY REFERENCES Programs(ProgramID) NOT NULL,
		StudentID INT FOREIGN KEY REFERENCES Students(StudentID) NOT NULL
	)

INSERT INTO Enrollment VALUES (1, 1)
INSERT INTO Enrollment VALUES (1, 3)
INSERT INTO Enrollment VALUES (4, 2)
INSERT INTO Enrollment VALUES (5, 4)


CREATE TABLE
	Grades(
		GradeID INT IDENTITY(1,1) PRIMARY KEY, 
		CourseID INT FOREIGN KEY REFERENCES Courses(CourseID) NOT NULL,
		StudentID INT FOREIGN KEY REFERENCES Students(StudentID) NOT NULL,
		Grade VARCHAR(2) NOT NULL,
		GradeDate DATETIME2 NOT NULL
	)

INSERT INTO Grades VALUES (1, 1, 'VG', '2022-09-15')
INSERT INTO Grades VALUES (3, 1, 'VG', '2022-11-15')
INSERT INTO Grades VALUES (5, 1, 'VG', '2023-01-15')
INSERT INTO Grades VALUES (6, 1, 'VG', '2023-03-15')
INSERT INTO Grades VALUES (1, 3, 'VG', '2022-09-15')
INSERT INTO Grades VALUES (3, 3, 'VG', '2022-11-15')
INSERT INTO Grades VALUES (5, 3, 'VG', '2023-01-15')
INSERT INTO Grades VALUES (6, 3, 'VG', '2023-03-15')
INSERT INTO Grades VALUES (3, 1, 'VG', '2022-11-15')
INSERT INTO Grades VALUES (5, 1, 'VG', '2023-01-15')
INSERT INTO Grades VALUES (7, 4, 'VG', '2022-08-01')
INSERT INTO Grades VALUES (8, 4, 'G', '2022-09-01')


CREATE TABLE
	Classrooms(
		ClassroomID INT IDENTITY(1,1) PRIMARY KEY, 
		ClassroomName VARCHAR(10) NOT NULL,
		HasComputers INT NOT NULL,
		IsAccessible INT NOT NULL
	)

INSERT INTO Classrooms VALUES ('A211', 0, 1)
INSERT INTO Classrooms VALUES ('A215', 0, 1)
INSERT INTO Classrooms VALUES ('B205', 0, 1)
INSERT INTO Classrooms VALUES ('B404', 0, 1)
INSERT INTO Classrooms VALUES ('C305', 0, 1)
INSERT INTO Classrooms VALUES ('C404', 0, 1)
INSERT INTO Classrooms VALUES ('A210', 1, 0)


CREATE TABLE
	Classes(
		ClassID INT IDENTITY(1,1) PRIMARY KEY, 
		CourseID INT FOREIGN KEY REFERENCES Courses(CourseID),
		ClassroomID INT FOREIGN KEY REFERENCES Classrooms(ClassroomID),
		IsOnline INT NOT NULL,
		ClassDate DATETIME2 NOT NULL
	)

INSERT INTO Classes VALUES (6, 1, 0, '2023-02-15')
INSERT INTO Classes VALUES (6, 4, 0, '2023-02-16')
INSERT INTO Classes VALUES (6, 4, 0, '2023-02-20')
INSERT INTO Classes VALUES (6, NULL, 1, '2023-02-21')
INSERT INTO Classes VALUES (6, 4, 0, '2023-02-23')


--some queries to test the database
SELECT
	FirstName,
	LastName,
	ProgramName
FROM
	Students AS S
INNER JOIN
	Enrollment AS E
ON	
	S.StudentID = E.StudentID
INNER JOIN
	Programs AS P
ON 
	E.ProgramID = P.ProgramID



