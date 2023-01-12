
USE 
	T618
GO


--1. Anv�nd CTE och skriv en query f�r att ta fram samtliga anst�llda som tj�nar med �n medell�nen av samtliga anst�llda. 
--Visa f�rnamn, efternamn och personens l�n.
WITH
	Average
AS 
(
	SELECT
		Firstname,
		Lastname,
		Salary,
		AVG(Salary) OVER() AS 'AvgSalary'
	FROM
		Employee
)
SELECT
	Firstname,
	Lastname,
	Salary
FROM
	Average
WHERE
	Salary > AvgSalary


--or (which one is better??)
WITH
	Average
AS
(
	SELECT
		AVG(Salary) AS 'AvgSalary'
	FROM
		Employee
)				
SELECT
	Firstname,
	Lastname,
	Salary
FROM
	Employee AS E
INNER JOIN
	Average AS A
ON
	E.Salary > A.AvgSalary


--or maybe?
WITH
	Salary
AS
(
	SELECT
		Firstname,
		Lastname,
		Salary
	FROM
		Employee
),
	Average
AS
(
	SELECT
		AVG(Salary) OVER() AS 'AvgSalary'
	FROM
		Salary
)
SELECT DISTINCT
	*
FROM
	Salary AS S
INNER JOIN
	Average AS A
ON
	Salary > AvgSalary




--2.Ta fram samtliga anst�lldas f�r- och efternamn, tillsammans med resp chefs f�r- och efternamn 
--(typ en self join som vi gjorde tidigare kurs) men denna g�ng ska din query vara baserad p� CTE
WITH
	Manager
AS
(
	SELECT
		Firstname,
		Lastname,
		EmpID,
		ManagerID
	FROM
		Employee
)
SELECT
	E.Firstname AS 'EmpFirstname',
	E.Lastname AS 'EmpLastname',
	M.Firstname AS 'MngFisrtname',
	M.Lastname AS 'MngLastname'
FROM
	Employee as E
LEFT OUTER JOIN							  --left outer: all from the left, matching to the right
	Manager as M
ON
	E.ManagerID = M.EmpID


--or (probably a better solution, uses data that is already in the RAM memory (CTE table Anst) instead of getting it from the disc)
WITH
	Anst
AS
(
	SELECT
		Firstname,
		Lastname,
		EmpID,
		ManagerID
	FROM
		Employee
),
	Chef
AS
(
	SELECT
		Firstname AS 'MngFirstname',
		Lastname AS 'MngLastname',
		EmpID
	FROM
		Anst
)
SELECT 
	A.Firstname,
	A.Lastname,
	MngFirstname,
	MngLastname
FROM
	Anst AS A
LEFT OUTER JOIN
	Chef AS C
ON
	A.ManagerID = C.EmpID



--3. Hitta anst�llda s�ljare som s�ljer mer �n medelv�rdet av samtliga s�ljare. Anv�nd CTE
WITH
	EmployeeAverage
AS
(
	SELECT DISTINCT
		E.Firstname AS 'Firstname',
		E.Lastname As 'Lastname',
		C.EmpID AS 'SalespersonID',
		SUM(Amount * Price) OVER(PARTITION BY C.EmpID) AS 'Sales'		--or with group by which is more common and straightforward?
	FROM
		OrderDetails AS D
	INNER JOIN
		Orders AS O
	ON
		D.Orders_id = O.Orders_id
	INNER JOIN
		Customers AS C
	ON
		O.Cust_id = C.Cust_ID
	LEFT OUTER JOIN
		Employee AS E
	ON
		C.EmpID = E.EmpID
),
	Average
AS
(
	SELECT
		AVG(Sales) AS 'TotalAvgSales'
	FROM
		EmployeeAverage
)
SELECT
	*
FROM
	EmployeeAverage	as E
INNER JOIN
	Average AS A
ON
	Sales > TotalAvgSales


--4.Hitta de st�der (eller f�rorter) som �r mindre l�nsamma �n medelv�rdet av samtliga st�der.
WITH
	ByCity
AS
(
	SELECT DISTINCT
		Del_City AS 'City',
		SUM(Amount * Price) OVER(PARTITION BY Del_City) AS 'SumCity'
	FROM
		OrderDetails AS D
	INNER JOIN
		Orders AS O
	ON
		D.Orders_id = O.Orders_id
),
	Average
AS
(
	SELECT
		AVG(SumCity) AS 'TotalAvgSales'
	FROM
		ByCity
)
SELECT
	*
FROM
	ByCity AS B
INNER JOIN
	Average AS A
ON
	SumCity < TotalAvgSales



