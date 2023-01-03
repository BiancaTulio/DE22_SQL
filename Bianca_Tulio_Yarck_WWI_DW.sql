--create staging database WWI_DW
--allocating more memory than default, based on the amount of data taken from WideWorldImporters
--setting the collation the same as WideWorldImporters, otherwise an error was occurring
CREATE DATABASE
	WWI_DW
ON  PRIMARY 
	(NAME = N'WWI_DW', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DE22\MSSQL\DATA\WWI_DW.mdf', 
	SIZE = 1048576KB, 
	FILEGROWTH = 10%)
LOG ON 
	(NAME = N'WWI_DW_log', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DE22\MSSQL\DATA\WWI_DW_log.ldf', 
	SIZE = 262144KB, 
	FILEGROWTH = 10%)
COLLATE 
	Latin1_General_100_CI_AS
GO


USE 
	WWI_DW
GO


--create all empty staging tables with datatypes matching WideWorldImporters
CREATE TABLE
	DimDate(
		DateID INT PRIMARY KEY,
		[Date] DATE,
		[Year] SMALLINT,
		[Month] TINYINT,
		[MonthName] VARCHAR(10),
		[Weekday] TINYINT,
		WeekdayName VARCHAR(10),
		[Week] TINYINT,
		[Day] TINYINT,
		[Quarter] TINYINT,
		QuarterName CHAR(2))
GO


CREATE TABLE
	DimCustomer(	
		CustomerID INT PRIMARY KEY,
		CustomerName NVARCHAR(100),
		CustomerCategoryName NVARCHAR(50))
GO


CREATE TABLE
	DimSalesPerson(
		SalespersonPersonID INT PRIMARY KEY,
		Lastname NVARCHAR(50),
		Fullname NVARCHAR(50))
GO


CREATE TABLE
	DimProduct(
		ProductID INT IDENTITY(1,1) PRIMARY KEY,
		SKUNumber INT,
		ProductName NVARCHAR(100))
GO


CREATE TABLE
	FactSales(
		--adding the extra column FactSalesID as an identity to create a unique ID to each entry
		FactSalesID INT IDENTITY(1,1) PRIMARY KEY,					
		CustomerID INT FOREIGN KEY REFERENCES DimCustomer(CustomerID),
		SalespersonPersonID INT FOREIGN KEY REFERENCES DimSalesPerson(SalespersonPersonID),
		ProductID INT FOREIGN KEY REFERENCES DimProduct(ProductID),
		OrderDateID INT FOREIGN KEY REFERENCES DimDate(DateID),
		Quantity INT,
		UnitPrice DECIMAL(18,2),
		Sales DECIMAL(18,2))
GO


--create indexes for FactSales' Foreign Keys
CREATE INDEX idx_FactSales_CustomerID ON FactSales(CustomerID)
CREATE INDEX idx_FactSales_SalespersonPersonID ON FactSales(SalespersonPersonID)		 
CREATE INDEX idx_FactSales_ProductID ON FactSales(ProductID)		 
CREATE INDEX idx_FactSales_OrdeDateID ON FactSales(OrderDateID)
GO


--create procedures to fill staging tables with historical data and take care of periodic updates
--proc to fill DimDate 
CREATE PROC
	usp_DimDateAdd (@startDate DATE, @endDate DATE)
AS
BEGIN
	DECLARE @currentDate DATE = @startDate   

	SET NOCOUNT ON
	SET LANGUAGE svenska

	--loop through the dates
	WHILE @currentDate <= @endDate
	BEGIN

		--insert a new row in DimDate according to each column's datatype and formatting
		INSERT INTO
			DimDate
		SELECT 
			CAST(REPLACE(CAST(@currentDate AS VARCHAR(10)), '-', '') AS INT) AS DateID,
			@currentDate AS [Date],
			YEAR(@currentDate) AS [Year],	 
			MONTH(@currentDate) AS [Month],
			DATENAME(MONTH, @currentDate) AS [MonthName],
			DATEPART(WEEKDAY, @currentDate) AS [Weekday],
			DATENAME(WEEKDAY, @currentDate) AS WeekdayName,
			DATEPART(ISO_WEEK, @currentDate) AS [Week],
			DATEPART(DAY, @currentDate) AS [Day],
			DATEPART(QUARTER, @currentDate) AS [Quarter],
			'Q' + DATENAME(QUARTER, @currentDate) AS QuarterName		

		--avoid duplicates by adding new rows only if not already in DimDate
		WHERE 
			@currentDate 
		NOT IN
			(SELECT 
				[Date] 
			FROM 
				DimDate)

		--add one day to @currrentDate to continue the loop
		SET @currentDate = DATEADD(DAY, 1, @currentDate)
	END

	SET LANGUAGE us_english  
	SET NOCOUNT OFF
END
GO


--proc to fill and update DimCustomer
CREATE PROC
	usp_DimCustomerAdd
AS
BEGIN
	--insert data into DimCustomer only if not already in the table
	INSERT INTO
		DimCustomer
	SELECT	
		CustomerID AS CustomerID,
		CustomerName AS CustomerName,
		CustomerCategoryName AS CustomerCategoryName
	FROM
		WideWorldImporters.Sales.Customers AS Cust
	LEFT JOIN
		WideWorldImporters.Sales.CustomerCategories as Cat
	ON
		Cust.CustomerCategoryID = Cat.CustomerCategoryID
	WHERE
		Cust.CustomerID
	NOT IN
		(SELECT
			CustomerID
		FROM
			DimCustomer)

	--update DimCustomer only if something changed in WideWorldImporters
	UPDATE
		DimCustomer
	SET
		CustomerID = Cust.CustomerID,
		CustomerName = Cust.CustomerName,
		CustomerCategoryName = Cat.CustomerCategoryName
	FROM
		DimCustomer
	INNER JOIN
		WideWorldImporters.Sales.Customers AS Cust
	ON
		DimCustomer.CustomerID = Cust.CustomerID
	LEFT JOIN
		WideWorldImporters.Sales.CustomerCategories as Cat
	ON
		Cust.CustomerCategoryID = Cat.CustomerCategoryID
	WHERE
		DimCustomer.CustomerID != Cust.CustomerID
	OR
		DimCustomer.CustomerName != Cust.CustomerName
	OR
		DimCustomer.CustomerCategoryName != Cat.CustomerCategoryName
END
GO


--proc to fill and update DimSalesPerson
CREATE PROC
	usp_DimSalesPersonAdd
AS
BEGIN
	
	--insert data into DimSalesPerson only if not already in the table
	INSERT INTO
		DimSalesPerson
	SELECT
		PersonID AS SalespersonPersonID,
		REVERSE(SUBSTRING(REVERSE(FullName), 1, CHARINDEX(' ', REVERSE(FullName)) - 1)) AS Lastname,
		FullName AS Fullname
	FROM
		WideWorldImporters.[Application].People
	WHERE
		IsSalesperson = 1
	AND
		PersonID
	NOT IN
		(SELECT	
			SalespersonPersonID
		FROM
			DimSalesPerson)

	--update DimSalesPerson only if something changed in WideWorldImporters
	UPDATE
		DimSalesPerson
	SET
		SalespersonPersonID = P.PersonID,
		Lastname = REVERSE(SUBSTRING(REVERSE(P.FullName), 1, CHARINDEX(' ', REVERSE(P.FullName)) - 1)),
		FullName = P.Fullname
	FROM
		DimSalesPerson AS SP
	INNER JOIN
		WideWorldImporters.[Application].People AS P
	ON
		SP.SalespersonPersonID = P.PersonID
	WHERE		
		SP.SalespersonPersonID != P.PersonID
	OR
		REVERSE(SUBSTRING(REVERSE(P.FullName), 1, CHARINDEX(' ', REVERSE(P.FullName)) - 1)) != SP.Lastname
	OR	
		P.Fullname != SP.FullName 
END
GO


--proc to fill and update DimProduct
CREATE PROC
	usp_DimProductAdd
AS
BEGIN

	--insert data into DimProduct only if not already in the table
	INSERT INTO 
		DimProduct
	SELECT
		StockItemID AS SKUNumber,
		StockItemName AS ProductName
	FROM
		WideWorldImporters.Warehouse.StockItems
	WHERE
		StockItemID 
	NOT IN
		(SELECT
			SKUNumber
		FROM
			DimProduct)

	--update DimProduct only if something changed in WideWorldImporters
	UPDATE
		DimProduct
	SET	
		SKUNumber = StockItemID,
		ProductName = StockItemName
	FROM
		DimProduct AS P
	INNER JOIN
		WideWorldImporters.Warehouse.StockItems AS S
	ON
		P.SKUNumber = S.StockItemID
	WHERE
		StockItemID != SKUNumber
	OR
		StockItemName != ProductName 
END
GO


--proc to fill FactSales (no updates in this case, once an order is placed it shouldn't be changed)
CREATE PROC
	usp_FactSalesAdd
AS
BEGIN

	SET NOCOUNT OFF

	--drop all indexes for efficiency
	DROP INDEX FactSales.idx_FactSales_CustomerID 
	DROP INDEX FactSales.idx_FactSales_SalespersonPersonID 
	DROP INDEX FactSales.idx_FactSales_ProductID 
	DROP INDEX FactSales.idx_FactSales_OrdeDateID 

	--insert data into FactSales only if not already in the table
	INSERT INTO
		FactSales
	SELECT
		CustomerID AS CustomerID,
		SalespersonPersonID AS SalespersonPersonID,
		ProductID AS ProductID,
		CAST(REPLACE(OrderDate, '-', '') AS INT) AS OrderDateID,
		Quantity AS Quantity,
		UnitPrice AS UnitPrice,
		(Quantity * UnitPrice) AS Sales
	FROM
		WideWorldImporters.Sales.Orders AS O
	INNER JOIN
		WideWorldImporters.Sales.OrderLines AS L
	ON
		O.OrderID = L.OrderID
	INNER JOIN
		DimProduct as P
	ON
		P.SKUNumber = L.StockItemID
	WHERE
		(CAST(REPLACE(OrderDate, '-', '') AS INT)) > 
			(SELECT
				ISNULL(MAX(OrderDateID), 0)
			FROM
				FactSales)		

	--recreate all indexes
	CREATE INDEX idx_FactSales_CustomerID ON FactSales(CustomerID)
	CREATE INDEX idx_FactSales_SalespersonPersonID ON FactSales(SalespersonPersonID)		 
	CREATE INDEX idx_FactSales_ProductID ON FactSales(ProductID)		 
	CREATE INDEX idx_FactSales_OrdeDateID ON FactSales(OrderDateID)

	SET NOCOUNT ON
END
GO


--execute usp_DimDateAdd to fill DimDate from first order date in WideWorldImporters until two years in the future from now
EXEC usp_DimDateAdd '2012-01-01', '2024-12-14'		 


--execute those procedures once to fill the tables with existing data
--then execute them periodically to get new data and/or update old data
EXEC usp_DimCustomerAdd
EXEC usp_DimSalesPersonAdd
EXEC usp_DimProductAdd
EXEC usp_FactSalesAdd