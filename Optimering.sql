
/*	Scripts to get FirstName and LastName of the customer who bought items for the most money (SalesAmount) from FactInternetSales	*/

USE AdventureWorksDW2019
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON
GO


/*	SOLUTION 1	*/
-- Selecting the top 1 results with ties (in case more than one customer have the same value) of SUM(SalesAmount) 
-- Grouped by CustomerKey DESC and INNER JOIN with DimCustomer on CustomerKey to get FirstName and LastName
SELECT TOP 1 WITH TIES
	FirstName,
	LastName,
	SUM(SalesAmount) AS 'TotalSales'
FROM
	FactInternetSales AS S
INNER JOIN
	DimCustomer AS C
ON
	S.CustomerKey = C.CustomerKey
GROUP BY
	S.CustomerKey,
	FirstName,
	LastName
ORDER BY
	SUM(SalesAmount) DESC


/*	SOLUTION 2	*/
-- Using RANK() in a CTE ordered by SUM(SalesAmount) DESC and grouped by CustomerKey
-- INNER JOIN the CTE with DimCustomer on Customer Key to get FirstName and LastName for the first ranked row(s)
WITH
	SalesPerCustomer
AS
(
	SELECT
		CustomerKey,
		RANK() OVER(ORDER BY SUM(SalesAmount) DESC) AS 'Ranking'
	FROM
		FactInternetSales
	GROUP BY
		CustomerKey
) 
SELECT
	FirstName,
	LastName
FROM
	DimCustomer AS D
INNER JOIN
	SalesPerCustomer AS S
ON
	D.CustomerKey = S.CustomerKey
WHERE
	Ranking = 1


/*	SOLUTION 3	*/
-- Also using a CTE but with SUM(SalesAmount) grouped by CustomerKey instead of RANK()
-- Same INNER JOIN between the CTE and DimCustomer to get FirstName and Lastname
-- Using the CTE in a subquery in the WHERE clause to get the rows with MAX(TotalSales)
WITH
	SalesPerCustomer
AS
(
	SELECT
		CustomerKey,
		SUM(SalesAmount) AS 'TotalSales'
	FROM
		FactInternetSales
	GROUP BY
		CustomerKey
) 
SELECT
	FirstName,
	LastName
FROM
	DimCustomer AS D
INNER JOIN
	SalesPerCustomer AS S
ON
	D.CustomerKey = S.CustomerKey
WHERE
	TotalSales = (SELECT MAX(TotalSales) FROM SalesPerCustomer)


/*	SOLUTION 4	*/
-- Same as the previous one (CTE to calculate SUM(SalesAmount), INNER JOIN with FactInternetSales)
-- But selecting the top 1 results with ties like in the first solution 
WITH
	SalesPerCustomer
AS
(
	SELECT
		CustomerKey,
		SUM(SalesAmount) AS 'TotalSales'
	FROM
		FactInternetSales
	GROUP BY
		CustomerKey
) 
SELECT TOP 1 WITH TIES
	FirstName,
	LastName
FROM
	DimCustomer AS D
INNER JOIN
	SalesPerCustomer AS S
ON
	D.CustomerKey = S.CustomerKey
ORDER BY
	TotalSales DESC
