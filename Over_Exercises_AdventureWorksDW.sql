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
--Region samt medelv�rden f�r Group, Country och Region. Skapa en enda query, anv�nd over
--samtliga regioner i samliga l�nder i samtliga grupper


SELECT TOP 100 * FROM DimSalesTerritory
SELECT TOP 100 * FROM FactInternetSales