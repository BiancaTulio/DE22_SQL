

USE 
	DVBikeStoresStarSchema
GO


-- create tables
CREATE TABLE
	DimOrderDate(
		OrderDateKey INT PRIMARY KEY,
		[Date] DATE NOT NULL,
		DayOfWeekNumber TINYINT NOT NULL,
		DayOfWeekName VARCHAR(10) NOT NULL,
		DayOfMonthNumber TINYINT NOT NULL,
		DayOfYearNumber SMALLINT NOT NULL,
		WeekNumber TINYINT NOT NULL,
		MonthNumber TINYINT NOT NULL,
		[MonthName] VARCHAR(10) NOT NULL,
		QuarterNumber TINYINT NOT NULL,
		QuarterName CHAR(2) NOT NULL,
		CalendarYear SMALLINT NOT NULL)
GO

CREATE TABLE
	DimRequiredDate(
		RequiredDateKey INT PRIMARY KEY,
		[Date] DATE NOT NULL,
		DayOfWeekNumber TINYINT NOT NULL,
		DayOfWeekName VARCHAR(10) NOT NULL,
		DayOfMonthNumber TINYINT NOT NULL,
		DayOfYearNumber SMALLINT NOT NULL,
		WeekNumber TINYINT NOT NULL,
		MonthNumber TINYINT NOT NULL,
		[MonthName] VARCHAR(10) NOT NULL,
		QuarterNumber TINYINT NOT NULL,
		QuarterName CHAR(2) NOT NULL,
		CalendarYear SMALLINT NOT NULL)
GO

CREATE TABLE
	DimShippedDate(
		ShippedDateKey INT PRIMARY KEY,
		[Date] DATE NOT NULL,
		DayOfWeekNumber TINYINT NOT NULL,
		DayOfWeekName VARCHAR(10) NOT NULL,
		DayOfMonthNumber TINYINT NOT NULL,
		DayOfYearNumber SMALLINT NOT NULL,
		WeekNumber TINYINT NOT NULL,
		MonthNumber TINYINT NOT NULL,
		[MonthName] VARCHAR(10) NOT NULL,
		QuarterNumber TINYINT NOT NULL,
		QuarterName CHAR(2) NOT NULL,
		CalendarYear SMALLINT NOT NULL)
GO

CREATE TABLE
	DimCustomer(	
		CustomerHashKey VARBINARY(16) PRIMARY KEY,
		CustomerKey INT NOT NULL,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL,
		City VARCHAR(25) NULL,
		[State] VARCHAR(25) NULL,  
		EffectiveStartDate DATETIME2 NOT NULL,
		EffectiveEndDate DATETIME2 NULL,
		IsCurrent TINYINT NOT NULL)
GO


CREATE TABLE
	DimStaff(
		StaffHashKey VARBINARY(16) PRIMARY KEY,
		StaffKey INT NOT NULL,
		FirstName VARCHAR(50) NOT NULL,
		LastName VARCHAR(50) NOT NULL, 
		ManagerFirstName VARCHAR(50) NULL,
		ManagerLastName VARCHAR(50) NULL,
		EffectiveStartDate DATETIME2 NOT NULL,
		EffectiveEndDate DATETIME2 NULL,
		IsCurrent TINYINT NOT NULL)
GO


CREATE TABLE
	DimProduct(
		ProductHashKey VARBINARY(16) PRIMARY KEY,
		ProductKey INT NOT NULL,
		ProductName VARCHAR(50) NOT NULL,
		ModelYear SMALLINT NULL,
		BrandName VARCHAR(50) NULL,
		CategoryName VARCHAR(50) NULL,
		EffectiveStartDate DATETIME2 NOT NULL,
		EffectiveEndDate DATETIME2 NULL,
		IsCurrent TINYINT NOT NULL)
GO

CREATE TABLE
	DimStore(
		StoreHashKey VARBINARY(16) PRIMARY KEY,
		StoreKey INT NOT NULL,
		StoreName VARCHAR(50) NOT NULL,
		City VARCHAR(25) NULL,
		[State] VARCHAR(25) NULL,  
		EffectiveStartDate DATETIME2 NOT NULL,
		EffectiveEndDate DATETIME2 NULL,
		IsCurrent TINYINT NOT NULL)
GO

CREATE TABLE
	FactSales(
		FactSalesKey INT IDENTITY(1,1) PRIMARY KEY,					
		OrderDateKey INT FOREIGN KEY REFERENCES DimOrderDate(OrderDateKey),
		StoreKey VARBINARY(16) FOREIGN KEY REFERENCES DimStore(StoreHashKey),
		--StaffKey VARBINARY(16) FOREIGN KEY REFERENCES DimStaff(StaffHashKey),
		CustomerKey VARBINARY(16) FOREIGN KEY REFERENCES DimCustomer(CustomerHashKey),
		ProductKey VARBINARY(16) FOREIGN KEY REFERENCES DimProduct(ProductHashKey),
		RequiredDateKey INT FOREIGN KEY REFERENCES DimRequiredDate(RequiredDateKey),
		ShippedDateKey INT FOREIGN KEY REFERENCES DimShippedDate(ShippedDateKey),
		OrderStatus TINYINT NOT NULL,
		Quantity INT NOT NULL,
		ListPrice DECIMAL(10,2) NOT NULL,
		Discount DECIMAL(4,2) NOT NULL,
		SalesPrice DECIMAL(10,2) NOT NULL)
GO

--create procedures to fill the Date Dimensions
CREATE PROC
	usp_DimOrderDateAdd (@startDate DATE, @endDate DATE)
AS
BEGIN
	DECLARE @currentDate DATE = @startDate   

	SET NOCOUNT ON

	--loop through the dates
	WHILE @currentDate <= @endDate
	BEGIN

		--insert a new row in DimDate according to each column's datatype and formatting
		INSERT INTO
			DimOrderDate
		SELECT 
			CAST(REPLACE(CAST(@currentDate AS VARCHAR(10)), '-', '') AS INT),
			@currentDate,
			DATEPART(WEEKDAY, @currentDate),
			DATENAME(WEEKDAY, @currentDate),
			DATEPART(DAY, @currentDate),
			DATEPART(DAYOFYEAR, @currentDate),
			DATEPART(ISO_WEEK, @currentDate),
			MONTH(@currentDate),
			DATENAME(MONTH, @currentDate), 
			DATEPART(QUARTER, @currentDate),
			'Q' + DATENAME(QUARTER, @currentDate),
			YEAR(@currentDate)

		--avoid duplicates by adding new rows only if not already in DimDate
		WHERE 
			@currentDate 
		NOT IN
			(SELECT 
				[Date] 
			FROM 
				DimOrderDate)

		--add one day to @currrentDate to continue the loop
		SET @currentDate = DATEADD(DAY, 1, @currentDate)
	END

	SET NOCOUNT OFF
END
GO

CREATE PROC
	usp_DimRequiredDateAdd (@startDate DATE, @endDate DATE)
AS
BEGIN
	DECLARE @currentDate DATE = @startDate   

	SET NOCOUNT ON

	--loop through the dates
	WHILE @currentDate <= @endDate
	BEGIN

		--insert a new row in DimDate according to each column's datatype and formatting
		INSERT INTO
			DimRequiredDate
		SELECT 
			CAST(REPLACE(CAST(@currentDate AS VARCHAR(10)), '-', '') AS INT),
			@currentDate,
			DATEPART(WEEKDAY, @currentDate),
			DATENAME(WEEKDAY, @currentDate),
			DATEPART(DAY, @currentDate),
			DATEPART(DAYOFYEAR, @currentDate),
			DATEPART(ISO_WEEK, @currentDate),
			MONTH(@currentDate),
			DATENAME(MONTH, @currentDate), 
			DATEPART(QUARTER, @currentDate),
			'Q' + DATENAME(QUARTER, @currentDate),
			YEAR(@currentDate)

		--avoid duplicates by adding new rows only if not already in DimDate
		WHERE 
			@currentDate 
		NOT IN
			(SELECT 
				[Date] 
			FROM 
				DimRequiredDate)

		--add one day to @currrentDate to continue the loop
		SET @currentDate = DATEADD(DAY, 1, @currentDate)
	END

	SET NOCOUNT OFF
END
GO

CREATE PROC
	usp_DimShippedDateAdd (@startDate DATE, @endDate DATE)
AS
BEGIN
	DECLARE @currentDate DATE = @startDate   

	SET NOCOUNT ON

	--loop through the dates
	WHILE @currentDate <= @endDate
	BEGIN

		--insert a new row in DimDate according to each column's datatype and formatting
		INSERT INTO
			DimShippedDate
		SELECT 
			CAST(REPLACE(CAST(@currentDate AS VARCHAR(10)), '-', '') AS INT),
			@currentDate,
			DATEPART(WEEKDAY, @currentDate),
			DATENAME(WEEKDAY, @currentDate),
			DATEPART(DAY, @currentDate),
			DATEPART(DAYOFYEAR, @currentDate),
			DATEPART(ISO_WEEK, @currentDate),
			MONTH(@currentDate),
			DATENAME(MONTH, @currentDate), 
			DATEPART(QUARTER, @currentDate),
			'Q' + DATENAME(QUARTER, @currentDate),
			YEAR(@currentDate)

		--avoid duplicates by adding new rows only if not already in DimDate
		WHERE 
			@currentDate 
		NOT IN
			(SELECT 
				[Date] 
			FROM 
				DimShippedDate)

		--add one day to @currrentDate to continue the loop
		SET @currentDate = DATEADD(DAY, 1, @currentDate)
	END

	SET NOCOUNT OFF
END
GO

EXEC usp_DimOrderDateAdd '2012-01-01', '2024-12-14'	
EXEC usp_DimRequiredDateAdd '2012-01-01', '2024-12-14'	
EXEC usp_DimShippedDateAdd '2012-01-01', '2024-12-14'	


-- insert data from the Raw Data Vault into the other tables

INSERT INTO
	DimCustomer
SELECT
	HASHBYTES('md5', (C.CustomerHashKey + HASHBYTES('md5', CAST(C.LoadDate AS VARCHAR(10))))),
	H.CustomerKey,
	C.FirstName,
	C.LastName,
	CI.City,
	CI.State,
	CI.LoadDate,
	CI.LoadEndDate,
	(CASE WHEN CI.LoadEndDate = '9999-12-31' THEN 1 ELSE 0 END)
FROM
	DVBikeStoresEDW.dbo.SatCustomer	AS C		   
INNER JOIN
	DVBikeStoresEDW.dbo.SatCustomerInfo	AS CI
ON
	C.CustomerHashKey = CI.CustomerHashKey
AND 
	CI.LoadDate <= C.LoadDate 
INNER JOIN
	DVBikeStoresEDW.dbo.HubCustomer AS H
ON
	H.CustomerHashKey = C.CustomerHashKey

INSERT INTO
	DimProduct
SELECT
	HASHBYTES('md5', (P.ProductHashKey + HASHBYTES('md5', CAST(P.LoadDate AS VARCHAR(10))))),
	H.ProductKey,
	LEFT(P.ProductName, 25),
	P.ModelYear,
	SB.BrandName,
	SC.CategoryName,
	P.LoadDate,
	P.LoadEndDate,
	(CASE WHEN P.LoadEndDate = '9999-12-31' THEN 1 ELSE 0 END)
FROM
	DVBikeStoresEDW.dbo.HubProduct AS H
INNER JOIN
	DVBikeStoresEDW.dbo.SatProduct AS P
ON
	H.ProductHashKey = P.ProductHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.LinkProductCategory AS LPC
ON
	P.ProductHashKey = LPC.ProductHashKey
INNER JOIN
    DVBikeStoresEDW.dbo.HubCategory AS HC
ON
	LPC.CategoryHashKey = HC.CategoryHashKey
INNER JOIN
    DVBikeStoresEDW.dbo.SatCategory AS SC
ON
	HC.CategoryHashKey = SC.CategoryHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.LinkProductBrand AS LPB
ON
	P.ProductHashKey = LPB.ProductHashKey
INNER JOIN
    DVBikeStoresEDW.dbo.HubBrand AS HB
ON
	LPB.BrandHashKey = HB.BrandHashKey
INNER JOIN
    DVBikeStoresEDW.dbo.SatBrand AS SB
ON
	HB.BrandHashKey = SB.BrandHashKey
GO

--not working!!
WITH 
	ManagerHK
AS
(
	SELECT
		SM.StaffHashKey AS StaffHashKey,
		SM.ManagerHashKey AS ManagerHashKey,
		S.FirstName AS ManagerFirstName,
		S.LastName AS ManagerLastName
	FROM
		DVBikeStoresEDW.dbo.LinkStaffManager AS SM
	INNER JOIN
		DVBikeStoresEDW.dbo.SatStaff AS S
	ON
		SM.ManagerHashKey = S.StaffHashKey
)
--INSERT INTO
	--DimStaff
SELECT
	HASHBYTES('md5', (S.StaffHashKey + HASHBYTES('md5', CAST(S.LoadDate AS VARCHAR(10))))),
	HS.StaffKey,
	S.FirstName,
	S.LastName,
	M.ManagerFirstName,
	M.ManagerLastName,
	S.LoadDate,
	S.LoadEndDate,
	(CASE WHEN S.LoadEndDate = '9999-12-31' THEN 1 ELSE 0 END)
FROM
	ManagerHK AS M
JOIN
	DVBikeStoresEDW.dbo.LinkStaffManager AS SM
ON
	M.ManagerHashKey = SM.ManagerHashKey
JOIN
	DVBikeStoresEDW.dbo.HubStaff AS HS
ON
	SM.StaffHashKey = HS.StaffHashKey
JOIN
	DVBikeStoresEDW.dbo.SatStaff AS S
ON
	HS.StaffHashKey = S.StaffHashKey
GO

INSERT INTO
	DimStore
SELECT
	HASHBYTES('md5', (S.StoreHashKey + HASHBYTES('md5', CAST(S.LoadDate AS VARCHAR(10))))),
	H.StoreKey,
	S.StoreName,
	S.City,
	S.State,
	S.LoadDate,
	S.LoadEndDate,
	(CASE WHEN S.LoadEndDate = '9999-12-31' THEN 1 ELSE 0 END)
FROM
	DVBikeStoresEDW.dbo.HubStore AS H
INNER JOIN
	DVBikeStoresEDW.dbo.SatStore AS S
ON
	H.StoreHashKey = S.StoreHashKey
GO

INSERT INTO
	FactSales
SELECT
	CAST(REPLACE(CAST(SO.OrderDate AS VARCHAR(10)), '-', '') AS INT),
	HASHBYTES('md5', (St.StoreHashKey + HASHBYTES('md5', CAST(St.LoadDate AS VARCHAR(10))))),
	--LOS.StaffHashKey,
	HASHBYTES('md5', (C.CustomerHashKey + HASHBYTES('md5', CAST(C.LoadDate AS VARCHAR(10))))),
	HASHBYTES('md5', (P.ProductHashKey + HASHBYTES('md5', CAST(P.LoadDate AS VARCHAR(10))))),
	CAST(REPLACE(CAST(SO.RequiredDate AS VARCHAR(10)), '-', '') AS INT),
	CAST(REPLACE(CAST(SO.ShippedDate AS VARCHAR(10)), '-', '') AS INT),
	SO.OrderStatus,
	SOI.Quantity,
	P.ListPrice,
	SOI.Discount,
	(SOI.Quantity * (P.ListPrice - (P.ListPrice * SOI.Discount)))
FROM
	DVBikeStoresEDW.dbo.HubOrder AS H
INNER JOIN
	DVBikeStoresEDW.dbo.SatOrder AS SO
ON
	H.OrderHashKey = SO.OrderHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.LinkOrderStaff AS LOS
ON
	H.OrderHashKey = LOS.OrderHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.LinkCustomerOrder AS LCO
ON
	H.OrderHashKey = LCO.OrderHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.SatCustomer AS C
ON
	LCO.CustomerHashKey = C.CustomerHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.LinkOrderItem AS LOI
ON
	H.OrderHashKey = LOI.OrderHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.LinkOrderStore AS LOStr
ON
	H.OrderHashKey = LOStr.OrderHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.SatStore AS St
ON
	LOStr.StoreHashKey = St.StoreHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.SatOrderItem AS SOI
ON
	LOI.OrderItemHashKey = SOI.OrderItemHashKey
INNER JOIN
	DVBikeStoresEDW.dbo.SatProduct AS P
ON
	LOI.ProductHashKey = P.ProductHashKey
WHERE
	H.LoadDate <= SO.LoadDate
AND
	LOS.LoadDate <= SO.LoadDate
AND
	LCO.LoadDate <= SO.LoadDate
AND
	C.LoadDate <= SO.LoadDate
AND
	LOI.LoadDate <= SO.LoadDate
AND
	LOStr.LoadDate <= SO.LoadDate
AND
	St.LoadDate <= SO.LoadDate
AND
	SOI.LoadDate <= SO.LoadDate
AND
	P.LoadDate <= SO.LoadDate



-- queries to test

SELECT
	ProductName,
	Date,
	ListPrice
FROM
	FactSales AS F
INNER JOIN
	DimOrderDate AS D
ON
	F.OrderDateKey = D.OrderDateKey
INNER JOIN
	DimProduct As P
ON
	F.ProductKey = P.ProductHashKey

	

