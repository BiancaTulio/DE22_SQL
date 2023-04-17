

USE 
	DVBikeStoresStarSchema
GO


-- create tables
CREATE TABLE
	DimDate(
		DateKey INT PRIMARY KEY,
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



