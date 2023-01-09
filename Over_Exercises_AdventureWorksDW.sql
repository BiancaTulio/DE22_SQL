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
--Ta fram medelvärden avseende försäljning (tabellen FactInternetSales) för de olika territorierna, visa Group, Country och
--Region samt medelvärden för Group, Country och Region. Skapa en enda query, använd over
SELECT DISTINCT
	SalesTerritoryGroup AS 'Group',
	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryGroup), 2) AS 'AvgSalesByGroup',
	SalesTerritoryCountry AS 'Country',
	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryCountry), 2) AS 'AvgSalesByCountry',
	SalesTerritoryRegion AS 'Region',
	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryRegion), 2) AS 'AvgSalesByRegion'
FROM
	FactInternetSales AS S
INNER JOIN
	DimSalesTerritory AS T
ON
	S.SalesTerritoryKey = T.SalesTerritoryKey
ORDER BY
	SalesTerritoryGroup, SalesTerritoryCountry, SalesTerritoryRegion


--7
--Samma som 6, men se till att det bara är ordrar under 2013 som räknas. Lägg även till totala medelvärdet, alltså medelvärdet för
--samtliga regioner i samliga länder i samtliga grupper
SELECT DISTINCT
	2013 AS 'Year',
	ROUND(AVG(SalesAmount) OVER(), 2) AS 'AvgSales',
	SalesTerritoryGroup AS 'Group',
	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryGroup), 2) AS 'AvgSalesByGroup',
	SalesTerritoryCountry AS 'Country',
	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryCountry), 2) AS 'AvgSalesByCountry',
	SalesTerritoryRegion AS 'Region',
	ROUND(AVG(SalesAmount) OVER(PARTITION BY SalesTerritoryRegion), 2) AS 'AvgSalesByRegion'
FROM
	FactInternetSales AS S
INNER JOIN
	DimSalesTerritory AS T
ON
	S.SalesTerritoryKey = T.SalesTerritoryKey
WHERE
	YEAR(OrderDate) = 2013
ORDER BY
	SalesTerritoryGroup, SalesTerritoryCountry, SalesTerritoryRegion
