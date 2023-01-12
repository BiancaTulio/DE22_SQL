
USE
	AdventureWorksDW
GO


--5.Skriv en WITH som tar fram �r, Veckonummer och F�rs�ljning (allts� f�rs�ljningen f�r den specifika veckan). 
--Anv�nd d�refter huvudquerien f�r att bara visa de �r veckor som g�tt med vinst. F�r att g� med vinst r�knar vi med 
--att man m�ste s�lja f�r 140000 eller mer. Sortera per �r och per m�nad.
WITH
	Sales
AS
(
	SELECT DISTINCT
		YEAR(OrderDate) AS 'SalesYear',
		DATEPART(ISO_WEEK, OrderDate) AS 'SalesWeek',
		SUM(SalesAmount) OVER(PARTITION BY YEAR(OrderDate), DATEPART(ISO_WEEK, OrderDate)) AS 'WeeklySalesAmount'
	FROM												  
		FactInternetSales
)
SELECT
	*
FROM
	Sales
WHERE
	WeeklySalesAmount >= 140000
ORDER BY
	SalesYear,
	SalesWeek


--or group by which is more common and straightforward?
WITH
	Sales
AS
(
	SELECT
		YEAR(OrderDate) AS 'Year',
		DATEPART(ISO_WEEK, OrderDate) AS 'Week',
		SUM(SalesAmount) AS 'WeeklySales'
	FROM
		FactInternetSales
	GROUP BY
		YEAR(OrderDate),
		DATEPART(ISO_WEEK, OrderDate)
)
SELECT
	*
FROM
	Sales
WHERE
	WeeklySales >= 140000
ORDER BY
	[Year],
	[Week]



--6.Ta fram samtliga anst�lldas f�r- och efternamn, tillsammans med resp chefs f�r- och efternamn 
--(typ en self join som vi gjorde tidigare kurs) men denna g�ng ska din query vara baserad p� CTE
WITH
	Manager
AS
(
	SELECT
		EmployeeKey,
		ParentEmployeeKey,
		FirstName,
		LastName
	FROM
		DimEmployee
)
SELECT
	E.FirstName AS 'EmpFirstname',
	E.LastName AS 'EmpLastname',
	M.FirstName AS 'MngFirstname',
	M.LastName AS 'MngLastname'
FROM
	DimEmployee AS E
LEFT OUTER JOIN
	Manager AS M
ON
	E.ParentEmployeeKey = M.EmployeeKey


--or with two CTE tables, using what's already stored in the RAM memory
WITH
	Emp
AS
(
	SELECT
		EmployeeKey,
		FirstName,
		LastName,
		ParentEmployeeKey
	FROM
		DimEmployee
),
	Mng
AS
(
	SELECT
		Firstname AS 'MngFirstname',
		Lastname AS 'MngLastname',
		EmployeeKey
	FROM
		Emp
)
SELECT
	FirstName,
	LastName,
	MngFirstname,
	MngLastname
FROM
	Emp AS E
LEFT OUTER JOIN
	Mng As M
ON
	E.ParentEmployeeKey = M.EmployeeKey


--7.G�r om fr�ga 6 och l�gg till en kolumn som visar p� vilken niv� i hierarkin den anst�llde �r.
WITH
	Hierarchy
AS
(
	--anchor member
	SELECT
		FirstName,
		LastName,
		1 AS 'HierarchyLevel',
		EmployeeKey,
		ParentEmployeeKey,
		CAST(NULL AS varchar(50)) AS 'MngFirstname',
		CAST(NULL AS varchar(50)) AS 'MngLastname'
	FROM
		DimEmployee
	WHERE
		ParentEmployeeKey IS NULL

	UNION ALL

	--recursive member
	--works as a loop incrementing this column until the last row in the recursive table
	--but it only adds 1 to the Employees directly below in hierarchy to the previous ones, instead of at every row 
	--e.g. if Brian Welcker has a HierarchyLevel of 2, Amy Alberts that has Brian as their ParentEmployee gets 1 added to HierarchyLevel 
	SELECT
		E.FirstName,
		E.LastName,	
		HierarchyLevel + 1,	
		E.EmployeeKey,		
		E.ParentEmployeeKey,							 
		CAST(H.FirstName AS varchar(50)) AS 'MngFirstname',			
		CAST(H.LastName AS varchar(50)) AS 'MngLastname'
	FROM
		DimEmployee AS E
	INNER JOIN
		Hierarchy AS H
	ON
		E.ParentEmployeeKey = H.EmployeeKey
)
SELECT							
	FirstName,
	LastName,
	HierarchyLevel,
	MngFirstname,
	MngLastname
FROM
	Hierarchy
ORDER BY
	HierarchyLevel


