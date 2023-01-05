USE
	AdventureWorksDW
GO


--5
--Ta fram de olika territorierna som finns, visa Group, Country och Region (tabellen DimSalesTerritory) 
SELECT
	SalesTerritoryGroup AS 'Group',
	SalesTerritoryCountry AS 'Country',
	SalesTerritoryRegion AS 'Region'
FROM
	DimSalesTerritory


--6
--Ta fram medelv�rden avseende f�rs�ljning (tabellen FactInternetSales) f�r de olika territorierna, visa Group, Country och
--Region samt medelv�rden f�r Group, Country och Region. Skapa en enda query, anv�nd overSELECT DISTINCT	SalesTerritoryGroup AS 'Group',	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryGroup ORDER BY SalesTerritoryGroup), 2) AS 'AvgSalesByGroup',	SalesTerritoryCountry AS 'Country',	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryCountry ORDER BY SalesTerritoryCountry), 2) AS 'AvgSalesByCountry',	SalesTerritoryRegion AS 'Region',	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryRegion ORDER BY SalesTerritoryRegion), 2) AS 'AvgSalesByRegion'FROM	FactInternetSales AS SINNER JOIN	DimSalesTerritory AS TON	S.SalesTerritoryKey = T.SalesTerritoryKey--7--Samma som 6, men se till att det bara �r ordrar under 2013 som r�knas. L�gg �ven till totala medelv�rdet, allts� medelv�rdet f�r
--samtliga regioner i samliga l�nder i samtliga grupperSELECT DISTINCT	2013 AS 'Year',	ROUND(AVG(SalesAmount) OVER(), 2) AS 'AvgSales',	SalesTerritoryGroup AS 'Group',	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryGroup ORDER BY SalesTerritoryGroup), 2) AS 'AvgSalesByGroup',	SalesTerritoryCountry AS 'Country',	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryCountry ORDER BY SalesTerritoryCountry), 2) AS 'AvgSalesByCountry',	SalesTerritoryRegion AS 'Region',	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryRegion ORDER BY SalesTerritoryRegion), 2) AS 'AvgSalesByRegion'FROM	FactInternetSales AS SINNER JOIN	DimSalesTerritory AS TON	S.SalesTerritoryKey = T.SalesTerritoryKeyWHERE	YEAR(OrderDate) = 2013	


SELECT TOP 100 * FROM DimSalesTerritory
SELECT TOP 100 * FROM FactInternetSales
