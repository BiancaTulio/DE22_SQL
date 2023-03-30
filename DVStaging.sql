
USE DVStaging
GO

-- script to get data from DVSource

INSERT INTO
	Department
SELECT
	DepartmentID AS DepartmentID,
	DepartmentName AS DepartmentName,
	DepartmentCode AS DepartmentCode,
	GETDATE() AS Timestamp,
	'DVSource.dbo.Department' AS RecordSource,
	HASHBYTES('md5', CAST(DepartmentID AS VARCHAR(MAX))) AS DepartmentIDHash
FROM
	DVSource.dbo.Department


INSERT INTO
	Employee
SELECT
	EmployeeID AS EmployeeID,
	Name AS Name,
	Gender AS Gender,
	Birthdate AS Birthdate,
	Address AS Address,
	City AS City,
	DepartmentID AS DepartmentID,
	GETDATE() AS Timestamp,
	'DVSource.dbo.Employee' AS RecordSource,
	HASHBYTES('md5', CAST(EmployeeID AS VARCHAR(MAX))) AS EmployeeIDHash
FROM
	DVSource.dbo.Employee


INSERT INTO
	Project
SELECT
	ProjectID AS ProjectID,
	ProjectName AS ProjecttName,
	ProjectCode AS ProjectCode,
	GETDATE() AS Timestamp,
	'DVSource.dbo.Project' AS RecordSource,
	HASHBYTES('md5', CAST(ProjectID AS VARCHAR(MAX))) AS ProjectIDHash
FROM
	DVSource.dbo.Project


INSERT INTO
	Link_WorkOn
SELECT
	LinkWO_ID AS LinkWO_ID,
	EmployeeID AS EmployeeID,
	ProjectID AS ProjectID,
	GETDATE() AS Timestamp,
	'DVSource.dbo.Link_WorkOn' AS RecordSource,
	HASHBYTES('md5', CAST(LinkWO_ID AS VARCHAR(MAX))) AS LinkWO_IDHash
FROM
	DVSource.dbo.Link_WorkOn


