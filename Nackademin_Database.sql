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


--create database tables
CREATE TABLE
	Students(
		StudentID INT IDENTITY(1,1) PRIMARY KEY,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL,
		Personnummer VARCHAR(12) NOT NULL
	)


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


CREATE TABLE
	Staff(
		StaffID INT IDENTITY(1,1) PRIMARY KEY,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL,
		Personnummer VARCHAR(12) NOT NULL
	)



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


CREATE TABLE
	Departments(
		DepartmentID INT IDENTITY(1,1) PRIMARY KEY, 
		DepartmentName VARCHAR(50) NOT NULL
	)


CREATE TABLE
	Roles(
		RoleID INT IDENTITY(1,1) PRIMARY KEY, 
		RoleName VARCHAR(50) NOT NULL,
		DepartmentID INT FOREIGN KEY REFERENCES Departments(DepartmentID) NOT NULL
	)


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


CREATE TABLE
	Branches(
		BranchID INT IDENTITY(1,1) PRIMARY KEY, 
		BranchName VARCHAR(50) NOT NULL
	)


CREATE TABLE
	Programs(
		ProgramID INT IDENTITY(1,1) PRIMARY KEY, 
		ProgramName VARCHAR(50) NOT NULL,
		BranchID INT FOREIGN KEY REFERENCES Branches(BranchID) NOT NULL,
		Points INT NOT NULL,
		StartDate DATETIME2 NOT NULL,
		EndDate DATETIME2 NOT NULL,
		ProgramManagerID INT FOREIGN KEY REFERENCES Staff(StaffID) 
	)


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


CREATE TABLE
	Enrollment(
		EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
		ProgramID INT FOREIGN KEY REFERENCES Programs(ProgramID) NOT NULL,
		StudentID INT FOREIGN KEY REFERENCES Students(StudentID) NOT NULL
	)


CREATE TABLE
	Grades(
		GradeID INT IDENTITY(1,1) PRIMARY KEY, 
		CourseID INT FOREIGN KEY REFERENCES Courses(CourseID) NOT NULL,
		StudentID INT FOREIGN KEY REFERENCES Students(StudentID) NOT NULL,
		Grade VARCHAR(2) NOT NULL,
		GradeDate DATETIME2 NOT NULL
	)


CREATE TABLE
	Classrooms(
		ClassroomID INT IDENTITY(1,1) PRIMARY KEY, 
		ClassroomName VARCHAR(10) NOT NULL,
		ClassroomFloor INT NOT NULL,
		ClassroomBlock VARCHAR(5) NOT NULL,
		HasComputers INT NOT NULL,
		IsAccessible INT NOT NULL
	)


CREATE TABLE
	Classes(
		ClassID INT IDENTITY(1,1) PRIMARY KEY, 
		ClassroomID INT FOREIGN KEY REFERENCES Classrooms(ClassroomID),
		IsOnline INT NOT NULL,
		StartDate DATETIME2 NOT NULL,
		EndDate DATETIME2 NOT NULL
	)

