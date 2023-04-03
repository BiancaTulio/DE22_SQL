
USE DVDataVault
GO

-- tables created with the assistant
-- script to get data from DVStaging

INSERT INTO
	HubDepartment
SELECT
	DepartmentIDHash AS HK_DeptID,
	DepartmentID AS DepartmentID,
	Timestamp AS LoadDate,
	RecordSource AS RecordSource
FROM
	DVStaging.dbo.Department


INSERT INTO
	HubEmployee
SELECT
	EmployeeIDHash AS HK_EmpID,
	EmployeeID AS EmployeeID,
	Timestamp AS LoadDate,
	RecordSource AS RecordSource
FROM
	DVStaging.dbo.Employee


INSERT INTO
	HubProject
SELECT
	ProjectIDHash AS HK_ProjID,
	ProjectID AS ProjectID,
	Timestamp AS LoadDate,
	RecordSource AS RecordSource
FROM
	DVStaging.dbo.Project


INSERT INTO
	LinkEmpProj
SELECT
	LinkWO_IDHash AS HK_LinkEmpProj,
	HASHBYTES('md5', CAST(EmployeeID AS VARCHAR(50))) AS HK_EmpID,
	HASHBYTES('md5', CAST(ProjectID AS VARCHAR(50))) AS HK_ProjID,
	Timestamp AS LoadDate,
	RecordSource AS RecordSource
FROM
	DVStaging.dbo.Link_WorkOn


-- no idea how to deal with LinkDeptEmp


INSERT INTO
	SatDepartment
SELECT
	DepartmentIDHash AS HK_DeptID,
	Timestamp AS LoadDate,
	DepartmentName AS DepartmentName,
	DepartmentCode AS DepartmentCode,
	RecordSource AS RecordSource
FROM
	DVStaging.dbo.Department


INSERT INTO
	SatEmpAddress
SELECT
	EmployeeIDHash AS HK_EmpID,
	Timestamp AS LoadDate,
	Address AS Address,
	City AS City,
	RecordSource AS RecordSource
FROM
	DVStaging.dbo.Employee


INSERT INTO
	SatEmpInfo
SELECT
	EmployeeIDHash AS HK_EmpID,
	Timestamp AS LoadDate,
	Name AS Name,
	Gender AS Gender,
	Birthdate As Birthdate,
	RecordSource AS RecordSource
FROM
	DVStaging.dbo.Employee


INSERT INTO
	SatProject
SELECT
	ProjectIDHash AS HK_ProjID,
	Timestamp AS LoadDate,
	ProjectName AS ProjectName,
	ProjectCode AS ProjectCode,
	RecordSource AS RecordSource
FROM
	DVStaging.dbo.Project

