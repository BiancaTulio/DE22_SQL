
USE
	AdventureWorksDW
GO


--Använd AdventureWorksDW och tabellen FactInternetSales
--Skapa en query som tar fram År, Månad, Månatlig försäljning samt en summerad YTD-försäljning (YTD = YearToDate)
--Sortera per År och Månad
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





