
USE
	AdventureWorksDW
GO


--Anv�nd AdventureWorksDW och tabellen FactInternetSales
--Skapa en query som tar fram �r, M�nad, M�natlig f�rs�ljning samt en summerad YTD-f�rs�ljning (YTD = YearToDate)
--Sortera per �r och M�nad
SELECT
	[Year],
	[Month],
	MonthlySales,
	SUM(MonthlySales) OVER(PARTITION BY [Year]
						   ORDER BY [Month]) AS 'YTD'		--YTD should start over in the beginning of the year
FROM
	(
	SELECT
		YEAR(OrderDate) AS 'Year',
		MONTH(OrderDate) AS 'Month',
		SUM(SalesAmount) AS 'MonthlySales'
	FROM
		FactInternetSales
	GROUP BY
		YEAR(OrderDate),
		MONTH(OrderDate)
	) AS SalesByMonth
GROUP BY
	[Year],
	[Month],
	MonthlySales
ORDER BY
	[Year],
	[Month]


--R12
SELECT
	[Year],
	[Month],
	MonthlySales,
	SUM(MonthlySales) OVER(ORDER BY [Year], [Month]
						   ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS 'R12'	  --don't start over in the beginning of the year
FROM
	(
	SELECT
		YEAR(OrderDate) AS 'Year',
		MONTH(OrderDate) AS 'Month',
		SUM(SalesAmount) AS 'MonthlySales'
	FROM
		FactInternetSales
	GROUP BY
		YEAR(OrderDate),
		MONTH(OrderDate)
	) AS SalesByMonth
GROUP BY
	[Year],
	[Month],
	MonthlySales
ORDER BY
	[Year],
	[Month]





