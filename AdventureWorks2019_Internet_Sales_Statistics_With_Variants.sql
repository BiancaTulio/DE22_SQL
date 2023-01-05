USE
	AdventureWorksDW
GO


--1
SELECT
	C.EnglishProductCategoryName AS 'CategoryName',
	S.EnglishProductSubcategoryName AS 'SubcategoryName',
	SUM(OrderQuantity) AS 'TotalOrders',
	ROUND(SUM(SalesAmount), 2) AS 'TotalSales',		   --round so it looks better
	ROUND(AVG(SalesAmount), 2) AS 'AverageSales',
	MIN(SalesAmount) AS 'MinSales',
	MAX(SalesAmount) AS 'MaxSales'
FROM
	FactInternetSales AS F
INNER JOIN
	DimProduct AS P
ON
	F.ProductKey = P.ProductKey
INNER JOIN
	DimProductSubcategory AS S
ON
	P.ProductSubcategoryKey = S.ProductSubcategoryKey
INNER JOIN
	DimProductCategory AS C
ON
	S.ProductCategoryKey = C.ProductCategoryKey
GROUP BY
	C.EnglishProductCategoryName,
	S.EnglishProductSubcategoryName
ORDER BY
	C.EnglishProductCategoryName,
	S.EnglishProductSubcategoryName


--2
SELECT
	C.EnglishProductCategoryName AS 'CategoryName',
	S.EnglishProductSubcategoryName AS 'SubcategoryName',
	D.CalendarYear AS 'OrderYear',
	SUM(OrderQuantity) AS 'TotalOrders',
	ROUND(SUM(SalesAmount), 2) AS 'TotalSales',
	ROUND(AVG(SalesAmount), 2) AS 'AverageSales',	   
	MIN(SalesAmount) AS 'MinSales',
	MAX(SalesAmount) AS 'MaxSales'
FROM
	DimDate AS D 
RIGHT OUTER JOIN
	FactInternetSales AS F
ON
	D.DateKey = F.OrderDateKey
INNER JOIN
	DimProduct AS P
ON
	F.ProductKey = P.ProductKey
INNER JOIN
	DimProductSubcategory AS S
ON
	P.ProductSubcategoryKey = S.ProductSubcategoryKey
INNER JOIN
	DimProductCategory AS C
ON
	S.ProductCategoryKey = C.ProductCategoryKey
WHERE
	YEAR(F.OrderDate) = 2013
GROUP BY
	C.EnglishProductCategoryName,
	S.EnglishProductSubcategoryName,
	D.CalendarYear
ORDER BY
	C.EnglishProductCategoryName,
	S.EnglishProductSubcategoryName,
	D.CalendarYear


--no need to make another inner join, just write YEAR(F.OrderDate) as a column
SELECT
	YEAR(F.OrderDate) AS 'Year',
	C.EnglishProductCategoryName AS 'CategoryName',
	S.EnglishProductSubcategoryName AS 'SubcategoryName',
	SUM(OrderQuantity) AS 'TotalOrders',
	ROUND(SUM(SalesAmount), 2) AS 'TotalSales',
	ROUND(AVG(SalesAmount), 2) AS 'AverageSales',	   --round so it looks better
	MIN(SalesAmount) AS 'MinSales',
	MAX(SalesAmount) AS 'MaxSales'
FROM
	FactInternetSales AS F
INNER JOIN
	DimProduct AS P
ON
	F.ProductKey = P.ProductKey
INNER JOIN
	DimProductSubcategory AS S
ON
	P.ProductSubcategoryKey = S.ProductSubcategoryKey
INNER JOIN
	DimProductCategory AS C
ON
	S.ProductCategoryKey = C.ProductCategoryKey
WHERE
	YEAR(F.OrderDate) = 2013
GROUP BY
	YEAR(F.OrderDate),
	C.EnglishProductCategoryName,
	S.EnglishProductSubcategoryName
ORDER BY
	YEAR(F.OrderDate),
	C.EnglishProductCategoryName,
	S.EnglishProductSubcategoryName


--3						
SELECT
	YEAR(F.OrderDate) AS 'Year',
	C.EnglishProductCategoryName AS 'CategoryName',
	S.EnglishProductSubcategoryName AS 'SubcategoryName',
	SUM(OrderQuantity) AS 'TotalOrders',
	ROUND(SUM(SalesAmount), 2) AS 'TotalSales',
	ROUND(AVG(SalesAmount), 2) AS 'AverageSales',
	MIN(SalesAmount) AS 'MinSales',
	MAX(SalesAmount) AS 'MaxSales'
FROM
	DimDate AS D 
RIGHT OUTER JOIN
	FactInternetSales AS F
ON
	D.DateKey = F.OrderDateKey
INNER JOIN
	DimProduct AS P
ON
	F.ProductKey = P.ProductKey
INNER JOIN
	DimProductSubcategory AS S
ON
	P.ProductSubcategoryKey = S.ProductSubcategoryKey
INNER JOIN
	DimProductCategory AS C
ON
	S.ProductCategoryKey = C.ProductCategoryKey
WHERE
	YEAR(F.OrderDate) = 2013
GROUP BY
	C.EnglishProductCategoryName,
	S.EnglishProductSubcategoryName,
	YEAR(F.OrderDate)
HAVING
	SUM(SalesAmount) > 1000000
ORDER BY
	C.EnglishProductCategoryName,
	S.EnglishProductSubcategoryName,
	YEAR(F.OrderDate)

