
/*	Script to get FirstName and LastName of the customer who bought items for the most money (SalesAmount) from FactInternetSales	*/

USE AdventureWorksDW2019
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON
GO

/*	SOLUTION 1	*/

-- Selecting the top 1 result with ties (in case more than one customer have the same value) of SUM(SalesAmount) 
-- Grouped by CustomerKey in descending order and making an inner join with DimCustomer on CustomerKey to get FirstName and LastName

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
-- Using a CTE to rank SUM(SalesAmount) grouped by CustomerKey in descending order
-- Making an inner join of the CTE with DimCustomer on Customer Key to get FirstName and LastName for the first ranked row(s)

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
-- About the same as the previous solution but instead of a CTE, using a Derived Table to get the rank

SELECT
	FirstName,
	LastName
FROM
	(SELECT
		FirstName,
		LastName,
		RANK() OVER(ORDER BY SUM(SalesAmount) DESC) AS 'Ranking'
	FROM
		FactInternetSales AS S
	INNER JOIN
		DimCustomer AS C
	ON
		S.CustomerKey = C.CustomerKey
	GROUP BY
		S.CustomerKey,
		FirstName,
		LastName) AS SalesPerCustomer
WHERE
	Ranking = 1
	


/*	SOLUTION 4	*/
-- Using a CTE to calculate	SUM(SalesAmount) grouped by CustomerKey
-- Making an inner join of the CTE and DimCustomer to get FirstName and Lastname
-- Using the CTE in a Subquery in the WHERE clause to get the rows with MAX(TotalSales)

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


/*	SOLUTION 5	*/
-- Similar to the previous solution but making the inner join between FactInternetSales and DimCustomer in the CTE instead
-- Querying the CTE for FirstName and LastName and using the CTE in a subquery in the WHERE clause to get the rows with MAX(TotalSales)

WITH
	SalesPerCustomer
AS
(
	SELECT
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
) 
SELECT
	FirstName,
	LastName
FROM
	SalesPerCustomer
WHERE
	TotalSales = (SELECT MAX(TotalSales) FROM SalesPerCustomer)


/*	SOLUTION 6	*/
-- A blending of the first solution and the previous one 
-- Making a CTE with FactInternetSales and DimCustomer joined on CustomerKey
-- To get FirstName, LastName and SUM(SalesAmount) grouped by CustomerKey
-- Then querying the CTE to select top 1 FirstName and LastName with ties with TotalSales ordered descending

WITH
	SalesPerCustomer
AS
(
	SELECT
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
) 
SELECT TOP 1 WITH TIES
	FirstName,
	LastName
FROM
	SalesPerCustomer
ORDER BY
	TotalSales DESC


/*	SOLUTION 7	*/

WITH
	CustomerInfo
AS
(
	SELECT
		FirstName,
		LastName,
		CustomerKey
	FROM
		DimCustomer
),
	SalesInfo
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
	CustomerInfo AS C
INNER JOIN
	SalesInfo AS S
ON
	C.CustomerKey = S.CustomerKey
ORDER BY
	TotalSales DESC



/*	SOLUTION 8	*/

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
	LastName,
	TotalSales
FROM
	DimCustomer AS D
INNER JOIN
	SalesPerCustomer AS S
ON
	D.CustomerKey = S.CustomerKey
ORDER BY
	TotalSales DESC



/*	SOLUTION 9	*/

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




-- Indexes chosen by the most queries
-- CREATE INDEX idx_DimCustomer_CustomerKey ON DimCustomer(CustomerKey) INCLUDE (FirstName, LastName)
-- CREATE INDEX idx_FactInternetSales_CustomerKey ON FactInternetSales(CustomerKey) INCLUDE (SalesAmount)


-- Solution 2 chose this index instead of the other ones
-- CREATE INDEX idx_DimCustomer_FirstNameLastName ON DimCustomer(FirstName, LastName)


-- Solution 2, 3 and 5 chose this index instead of the other ones
-- CREATE INDEX idx_DimCustomer_CustFirstLast ON DimCustomer(CustomerKey, FirstName, LastName)


-- Indexes that weren't chosen at all
-- CREATE INDEX idx_DimCustomer_CKOnly ON DimCustomer(CustomerKey)
-- CREATE INDEX idx_FactInternetSales_CKOnly ON FactInternetSales(CustomerKey)
-- CREATE INDEX idx_FactInternetSales_SalesAmount ON FactInternetSales(SalesAmount)
-- CREATE INDEX idx_FactInternetSales_CustSales ON FactInternetSales(CustomerKey, SalesAmount)





