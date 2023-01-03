--create database
CREATE DATABASE
	BikeStores_Staging
ON  PRIMARY 
	(NAME = N'BikeStores_Staging', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DE22\MSSQL\DATA\BikeStores_Staging.mdf', 
	SIZE = 1048576KB, 
	FILEGROWTH = 10%)
LOG ON 
	(NAME = N'WWI_DW_log', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DE22\MSSQL\DATA\BikeStores_Staging_log.ldf', 
	SIZE = 262144KB, 
	FILEGROWTH = 10%)
GO


USE
	BikeStores_Staging
GO


--create tables
CREATE TABLE 
	DimDate(
		DateKey INT PRIMARY KEY NOT NULL,
		[Date] DATE,
		FullDate VARCHAR(25),
		DayOfWeekName VARCHAR(15),
		DayOfWeekShort CHAR(3),
		DayOfWeekNumber SMALLINT,
		DayNumberInMonth SMALLINT,
		DayNumberInYear SMALLINT,
		[Week] SMALLINT,
		[MonthName] VARCHAR(15),
		MonthNameShort CHAR(3),
		MonthNumber SMALLINT,
		YearMonth VARCHAR(7),
		QuarterName CHAR(2),
		QuarterNumber TINYINT,
		YearQuarterNumber VARCHAR(7),
		[Year] SMALLINT,
		[Weekday] SMALLINT)
GO


CREATE TABLE
	DimCustomer(
		CustomerID INT NOT NULL PRIMARY KEY,
		LastName VARCHAR(255),
		FullName VARCHAR(511),
		City VARCHAR(50),
		[State] VARCHAR(25))
GO


CREATE TABLE 
	DimProduct(
		ProductID INT NOT NULL PRIMARY KEY,
		ProductName VARCHAR(255),
		ModelYear SMALLINT,
		BrandName VARCHAR(255),
		CategoryName  VARCHAR(255))
GO


CREATE TABLE 
	DimStaff(
		StaffID INT PRIMARY KEY NOT NULL,
		EmpLastName VARCHAR(50),
		EmpFullName VARCHAR(101),
		ManagerLastName VARCHAR(50),
		ManagerFullName VARCHAR(101),
		StoreName VARCHAR(255),
		StoreCity VARCHAR(255),
		StoreState VARCHAR(10))
GO


CREATE TABLE
	FactSales(
		FactSalesID INT IDENTITY (1,1) PRIMARY KEY NOT NULL,
		DateKey INT FOREIGN KEY REFERENCES DimDate(DateKey),
		CustomerID INT FOREIGN KEY REFERENCES DimCustomer(CustomerID),
		StaffID INT FOREIGN KEY REFERENCES DimStaff(StaffID),
		ProductID INT FOREIGN KEY REFERENCES DimProduct(ProductID),
		Quantity INT,
		TotalSales DECIMAL(10,2))
GO	


--create indexes for FactSales
CREATE INDEX idx_FactSales_DateKey ON FactSales(DateKey)		 
CREATE INDEX idx_FactSales_CustomerID ON FactSales(CustomerID)		 
CREATE INDEX idx_FactSales_ProductID ON FactSales(ProductID)		 
CREATE INDEX idx_FactSales_StaffID ON FactSales(StaffID)
GO


--create procedures to fill staging tables with historical data and take care of periodic updates
CREATE PROC
	usp_fillDimDate (@startDate DATE, @endDate DATE)
AS
BEGIN
	DECLARE @currentDate DATE = @startDate   

	SET NOCOUNT ON

	--loop through the dates
	WHILE @currentDate <= @endDate
	BEGIN

		--insert a new row in DimDate according to each column's datatype and formatting
		INSERT INTO
			DimDate
		SELECT 
			CAST(REPLACE(CAST(@currentDate AS VARCHAR(10)), '-', '') AS INT) AS DateKey,
			@CurrentDate AS [Date], 
			FORMAT(@currentDate, 'dd MMMM yyy') AS FullDate, 
			DATENAME(weekday, @currentDate) AS DayOfWeekName,
			LEFT(DATENAME(dw, @currentDate), 3) AS DayOfWeekShort,
			DATEPART(dw, @currentDate) AS DayOfWeekNumber,
			DATEPART(dd, @currentDate) AS DayNumberInMonth,
			DATEPART(dy, @currentDate) AS DayNumberInYear,
			DATEPART(iso_week, @currentDate) AS [Week],
			DATENAME(MM, @currentDate) AS [MonthName],
			FORMAT(@currentDate, 'MMM') AS MonthNameShort,
			DATEPART(MM, @currentDate) AS MonthNumber,
			CONVERT(varchar(7), @currentDate, 120) AS YearMonth,
			'Q' + DATENAME(Q, @currentDate) AS QuarterName,
			DATEPART(q, @currentDate) AS QuarterNumber,
			DATENAME(yyyy, @currentDate) + '-' + DATENAME(Q, @currentDate) AS YearQuarterNumber,
			DATEPART(yyyy, @currentDate) AS [Year],
			(CASE WHEN DATEPART(dw, @currentDate) = 6 OR DATEPART(dw, @currentDate) = 7 THEN 0 ELSE 1 END) AS [Weekday]
	

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

	SET NOCOUNT OFF
END
GO


CREATE PROC
	usp_fillDimCustomer
AS
BEGIN

	SET NOCOUNT ON

	--create a select that fills info from database
	INSERT INTO
		DimCustomer
	SELECT
		customer_id as CustomerID,
		last_name as Lastname,
		first_name + ' ' + last_name as FullName,
		city as City,
		[state] as [State]
	FROM
		Bikestores.sales.customers														   
	WHERE 
		customer_id 
	NOT IN
		(SELECT DISTINCT 
			CustomerID
		FROM
			DimCustomer)

	--update only if it changed
	UPDATE 
		C
	SET 
		C.CustomerID = s.customer_id,
		C.Lastname = s.last_name,
		C.FullName = s.first_name + ' ' + s.last_name,
		C.City = s.city,
		C.[State] = s.[State]
	FROM 
		Bikestores.sales.customers as s
	JOIN 
		DimCustomer as C
	ON 
		C.CustomerID = s.customer_id
	WHERE EXISTS 
		(SELECT 		
			s.customer_id,
			s.last_name,
			s.first_name,
			s.city,
			s.[State]
		EXCEPT
		SELECT
			s.customer_id,
			s.last_name,
			s.city,
			s.first_name,
			s.[State])

	SET NOCOUNT OFF
END
GO


CREATE PROC
	usp_fillDimProduct
AS
BEGIN

	SET NOCOUNT ON

	--script to get information from BikeStores	as well as new entries
	INSERT INTO
		DimProduct
	SELECT
		p.product_id as ProductID,
		p.product_name as ProductName,
		p.model_year as ModelYear,
		b.brand_name as BrandName,
		c.category_name as CategoryName
	FROM
		BikeStores.production.products as p
	JOIN
		BikeStores.production.categories as c
	ON
		c.category_id = p.category_id
	JOIN
		BikeStores.production.brands as b
	ON
		b.brand_id = p.brand_id
	WHERE 
		p.product_id
	NOT IN
		(SELECT
			ProductID
		FROM
			DimProduct)

	--script to take care of updates in BikeStores
	UPDATE
		Prod
	SET
		Prod.ProductID = p.product_id,
		Prod.ProductName = p.product_name,
		Prod.ModelYear = p.model_year,
		Prod.BrandName = b.brand_name,
		Prod.CategoryName = c.category_name
	FROM
		BikeStores.production.products as p	
	JOIN
		BikeStores.production.brands as b
	ON
		p.brand_id = b.brand_id
	JOIN
		BikeStores.production.categories as c
	ON
		p.category_id = c.category_id
	JOIN
		DimProduct as Prod
	ON
		Prod.ProductID = p.product_id
	WHERE
		Prod.ProductID != p.product_id
	OR
		Prod.ProductName != p.product_name
	OR
		Prod.ModelYear != p.model_year
	OR
		Prod.BrandName != b.brand_name
	OR 
		Prod.CategoryName != c.category_name

	SET NOCOUNT OFF
END
GO


CREATE PROC
	usp_fillDimStaff
AS
BEGIN
	SET NOCOUNT ON

	--script to get data from BikeStores database
	INSERT INTO
		DimStaff
	SELECT
		stf1.staff_id as StaffID,
		stf1.last_name as EmpLastName,
		stf1.first_name + ' ' + stf1.last_name as EmpFullName,
		stf2.last_name as ManagerLastName,
		stf2.first_name + ' ' + stf2.last_name as ManagerFullName,
		sto.store_name as StoreName,
		sto.city as StoreCity,
		sto.[state] as StoreState 	
	FROM
		BikeStores.sales.staffs as stf1		 --or employee emp
	FULL JOIN								 --or left outer join
		BikeStores.sales.staffs as stf2		--or manager mng
	ON
		stf1.manager_id	= stf2.staff_id
	JOIN
		BikeStores.sales.stores as sto
	ON
		sto.store_id = stf1.store_id
	WHERE
		stf1.staff_id
	NOT IN
		(SELECT
			StaffID
		FROM
			DimStaff)

	--script to update only if changed
	UPDATE
		S
	SET
		S.StaffID = stf1.staff_id,
		S.EmpLastName = stf1.last_name,
		S.EmpFullName = stf1.first_name + ' ' + stf1.last_name,
		S.ManagerLastName = stf2.last_name,
		S.ManagerFullName = stf2.first_name + ' ' + stf2.last_name,
		S.StoreName = sto.store_name,
		S.StoreCity = sto.city,
		S.StoreState = sto.[state]
	FROM
		BikeStores.sales.staffs as stf1
	FULL JOIN
		BikeStores.sales.staffs as stf2
	ON
		stf1.manager_id	= stf2.staff_id
	JOIN
		BikeStores.sales.stores as sto
	ON
		sto.store_id = stf1.store_id
	JOIN
		DimStaff as S
	ON
		S.StaffID = stf1.staff_id
	WHERE
		S.StaffID != stf1.staff_id
	OR
		S.EmpLastName != stf1.last_name
	OR
		S.EmpFullName != stf1.first_name + ' ' + stf1.last_name
	OR
		S.ManagerLastName != stf2.last_name
	OR
		S.ManagerFullName != stf2.first_name + ' ' + stf2.last_name
	OR	
		S.StoreName != sto.store_name
	OR
		S.StoreCity != sto.city
	OR
		S.StoreState != sto.[state]	

	SET NOCOUNT OFF

END
GO


CREATE PROC
	usp_fillFactSales
AS
BEGIN
	SET NOCOUNT ON
	--drop all indexes

	DROP INDEX FactSales.idx_FactSales_DateKey
	DROP INDEX FactSales.idx_FactSales_CustomerID
	DROP INDEX FactSales.idx_FactSales_ProductID
	DROP INDEX FactSales.idx_FactSales_StaffID


	--script to get data from BikeStores/Staging and new entries
	INSERT INTO
		FactSales
	SELECT
		CAST(REPLACE(CAST(order_date AS VARCHAR(10)), '-', '') AS INT) as DateKey,
		customer_id as CustomerID,
		staff_id as staffID,
		product_id as ProductID,
		SUM(quantity) as Quantity,
		SUM(quantity * (list_price * (1 - discount))) as TotalSales
	FROM
		BikeStores.sales.orders as o
	JOIN
		BikeStores.sales.order_items as i
	ON
		o.order_id = i.order_id	
	GROUP BY
		CAST(REPLACE(CAST(order_date AS VARCHAR(10)), '-', '') AS INT),
		customer_id,
		staff_id,
		product_id		


	--recreate indexes
	CREATE INDEX idx_FactSales_DateKey ON FactSales(DateKey)		 
	CREATE INDEX idx_FactSales_CustomerID ON FactSales(CustomerID)		 
	CREATE INDEX idx_FactSales_ProductID ON FactSales(ProductID)		 
	CREATE INDEX idx_FactSales_StaffID ON FactSales(StaffID)	

	SET NOCOUNT OFF

END
GO


--execute procedure to fill DimDate
EXEC usp_fillDimDate '2012-01-01', '2025-01-01'
GO

--execute procedures to fill tables with historical data and/or update periodically
EXEC usp_fillDimCustomer
EXEC usp_fillDimProduct
EXEC usp_fillDimStaff
EXEC usp_fillFactSales
GO