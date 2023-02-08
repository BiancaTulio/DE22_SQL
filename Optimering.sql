
/*	Scripts to get FirstName and LastName of the customer who bought items for the most money (SalesAmount) from FactInternetSales	*/

USE AdventureWorksDW2019
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON
GO


-- The queries were first executed using the existing indexes in the database
-- After that, the following indexes were created and the queries were executed again 
-- Statitics and Query Plans for all queries with both indexes are shown and analysed in the .docx file

CREATE INDEX idx_DimCustomer_CustomerKey ON DimCustomer(CustomerKey) INCLUDE (FirstName, LastName)
CREATE INDEX idx_FactInternetSales_CustomerKey ON FactInternetSales(CustomerKey) INCLUDE (SalesAmount)



/*	QUERY 1	*/
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

-- Very straightforward, simple and with good performance when compared to the other solutions
-- TotalSales has to be shown in the results, so not ideal if this data should not be part of the result set
-- The second most effective of the my three solutions according to my analysis, both with existing and new indexes



/*	QUERY 2	*/
-- Using RANK() in a CTE ordered by SUM(SalesAmount) DESC and grouped by CustomerKey
-- INNER JOIN the CTE with DimCustomer on CustomerKey to get FirstName and LastName for the first ranked row(s)

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

-- The worst performing of the three solutions, slower and using more resources both with existing and new indexes
-- Still, it might be useful in other contexts or more complex queries



/*	QUERY 3	*/
-- Also using a CTE but with SUM(SalesAmount) grouped by CustomerKey instead of RANK()
-- Selecting top 1 with ties in the CTE then joining it with DimCustomer to get FirstName and Lastname

WITH
	SalesPerCustomer
AS
(
	SELECT TOP 1 WITH TIES
		CustomerKey,
		SUM(SalesAmount) AS 'TotalSales'
	FROM
		FactInternetSales
	GROUP BY
		CustomerKey
	ORDER BY
		SUM(SalesAmount) DESC
) 
SELECT 
	FirstName,
	LastName
FROM
	SalesPerCustomer AS S
INNER JOIN
	DimCustomer AS D	
ON
	S.CustomerKey = D.CustomerKey

-- Very similar performance to Query 1 in this exercise but might make a difference when querying big amounts of data
-- Less Logical Reads with both existing and new indexes, the most effective of the three solutions



/*	QUERY 3 ALT	*/
-- Wondering if less Logical Reads than Query 1 was due to the CTE itself or to the filtering being done before the join
-- Rewrote Query 3 using SELECT TOP 1 WITH TIES outside the CTE

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

-- Statistics were almost identical to Query 1, meaning the CTE itself didn't alter the performance
-- Might be a good solution for code readability purposes or to remove TotalSales from the result set (comparing to Query 1)
-- But filtering the results before joining DimCustomer is what provided less Logical Reads

