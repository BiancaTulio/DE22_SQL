
USE
	AdventureWorksDW
GO

--YoY calculations by month on FactInternetSales				  

--using CTE, get the Year, Month and the SUM() of SalesAmount by Month from FactInternetSales
WITH
	MonthlySales
AS
(
	SELECT 
		YEAR(OrderDate) AS 'SalesYear',
		MONTH(OrderDate) AS 'SalesMonth',
		SUM(SalesAmount) AS 'TotalSales'
	FROM 
		FactInternetSales
	GROUP BY
		YEAR(OrderDate),
		MONTH(OrderDate)
)
--in the main query, select all from the derived table and calculate the difference in percent between TotalSales and PreviousYearSales
SELECT  
	*,
	ROUND(((TotalSales - PreviousYearSales) * 100) / PreviousYearSales, 2) AS 'DifferenceInPercent'
FROM
	--use the CTE as a derived table named PreviousYear and get the TotalSales value from 12 months (or rows) back with LAG()
	(SELECT	
		*,
		ROUND(LAG(TotalSales, 12) OVER(ORDER BY SalesYear, SalesMonth), 2) AS 'PreviousYearSales'
	FROM
		MonthlySales) AS PreviousYear	
ORDER BY
	SalesYear DESC,
	SalesMonth DESC


 
