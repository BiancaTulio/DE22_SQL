

USE DVStarSchema
GO

-- create tables for the Star Schema 
CREATE PROC
	usp_fillDimDate (@startDate DATE, @endDate DATE)
AS
BEGIN
	DECLARE @currentDate DATE = @startDate   

	SET NOCOUNT ON

	--loop through the dates
	WHILE @currentDate <= @endDate
	BEGIN

		--insert a new row in DimDate according to each column's datatype and formatting
		INSERT INTO
			DimDate
		SELECT 
			CAST(REPLACE(CAST(@currentDate AS VARCHAR(10)), '-', '') AS INT) AS DateKey,
			@CurrentDate AS [Date], 
			DATEPART(yyyy, @currentDate) AS [Year],
			DATEPART(MM, @currentDate) AS [Month],
			DATEPART(dd, @currentDate) AS [DayOfMonth],
			DATEPART(dy, @currentDate) AS [DayOfYear],
			DATENAME(MM, @currentDate) AS [MonthName]

		--avoid duplicates by adding new rows only if not already in DimDate
		WHERE 
			@currentDate 
		NOT IN
			(SELECT 
				[Date] 
			FROM 
				DimDate)

		--add one day to @currrentDate to continue the loop
		SET @currentDate = DATEADD(DAY, 1, @currentDate)
	END

	SET NOCOUNT OFF
END
GO

EXEC usp_fillDimDate '2023-01-01', '2024-01-01'
GO


INSERT INTO
	DimEmployee
SELECT
	HE.EmployeeID,
	SE.Name
FROM
	DVDataVault.dbo.HubEmployee AS HE
INNER JOIN
	DVDataVault.dbo.SatEmpInfo AS SE
ON
	HE.HK_EmpID = SE.HK_EmpID


INSERT INTO
	DimProject
SELECT
	HP.ProjectID,
	SP.ProjectName
FROM
	DVDataVault.dbo.HubProject AS HP
INNER JOIN
	DVDataVault.dbo.SatProject AS SP
ON
	HP.HK_ProjID = SP.HK_ProjID

INSERT INTO
	FactWorkload
SELECT
	HE.EmployeeID AS EmployeeKey,
	HP.ProjectID AS ProjectKey,
	CAST(REPLACE(CAST(LEP.LoadDate AS VARCHAR(10)), '-', '') AS INT) AS AssignedDateKey 
FROM
	DVDataVault.dbo.LinkEmpProj AS LEP
JOIN
	DVDataVault.dbo.HubEmployee AS HE
ON
	LEP.HK_EmpID = HE.HK_EmpID
JOIN
	DVDataVault.dbo.HubProject AS HP
ON
	LEP.HK_ProjID = HP.HK_ProjID


-- query to get how many projects are each employee working on at the moment
SELECT
	EmployeeName,
	COUNT(ProjectKey) AS 'ProjectAmount',
	[MonthName] AS CurrentMonth
FROM
	FactWorkload AS F
INNER JOIN
	DimEmployee AS E
ON	
	F.EmployeeKey = E.EmployeeKey
INNER JOIN
	DimDate AS D
ON
	AssignedDateKey = DateKey
GROUP BY
	EmployeeName,
	[MonthName] 
ORDER BY 
	COUNT(ProjectKey)

