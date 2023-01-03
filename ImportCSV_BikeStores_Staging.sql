USE 
	BikeStores_Staging
GO


--create table ImportProduct
CREATE TABLE
	ImportProduct(
		ID INT,
		ProductName VARCHAR(255),
		SupplierID INT,
		UnitPrice VARCHAR(50),
		Package VARCHAR(50),
		IsDiscontinued VARCHAR(10))
GO


--import data from .csv file
BULK INSERT
	ImportProduct
FROM
	'C:\SQL1\CSV\Product.csv'
WITH
	(FIRSTROW = 2,
	CODEPAGE = '1252')
GO


--update UnitPrice data type and ProductID so it's not duplicated in DimProduct
--this works but it's not ideal, it would be better to have a surrogate key system in the DimProduct table
UPDATE
	ImportProduct
SET
	UnitPrice = CAST(REPLACE(UnitPrice, ',', '.') as decimal(10,2)),
	ID = ID + 321

ALTER TABLE
	ImportProduct
ALTER COLUMN
	UnitPrice DECIMAL(10,2)
GO


--load relevant data into DimProduct
INSERT INTO
	DimProduct
SELECT
	ID as ProductID,
	ProductName as ProductName,
	NULL as ModelYear,
	NULL as BrandName,
	NULL as CategoryName
FROM
	ImportProduct
GO


--create table ImportCurstomer
CREATE TABLE
	ImportCustomer(
		ID INT,
		FirstName VARCHAR(50),
		LastName VARCHAR(50),
		City VARCHAR(50),
		Country VARCHAR(50),
		Phone VARCHAR(50))
GO


--import data from .csv file
BULK INSERT
	ImportCustomer
FROM
	'C:\SQL1\CSV\Customer.csv'
WITH
	(FIRSTROW = 2,
	CODEPAGE = '1252')
GO


--last CustomerID in DimCustomer 1445
--update table ImportCustomer so CustomerID is not duplicate
UPDATE
	ImportCustomer
SET
	ID = ID + 1445	 
GO

--add a Country column to DimCustomer
ALTER TABLE
	DimCustomer
ADD 
	Country VARCHAR(50)
GO


--load relevant data on to DimCustomer
INSERT INTO
	DimCustomer
SELECT
	ID as CustomerID,
	LastName as LastName,
	FirstName + ' ' + Lastname as FullName,
	City as City,
	NULL as [State],
	Country as Country
FROM
	ImportCustomer
GO


--update NULL Countries in DimCustomer to United States
UPDATE	
	DimCustomer
SET
	Country = 'United States'
WHERE
	Country IS NULL
GO


--create table ImportSuppliers
CREATE TABLE
	ImportSuppliers(
		ID INT,
		CompanyName VARCHAR(100),
		ContactName VARCHAR(100),
		ContactTitle VARCHAR(50),
		City VARCHAR(50),
		Country VARCHAR(50),
		Phone VARCHAR(50),
		Fax VARCHAR(50))
GO


--import data from .csv file
BULK INSERT
	ImportSuppliers
FROM
	'C:\SQL1\CSV\Supplier.csv'
WITH
	(FIRSTROW = 2,
	CODEPAGE = '1252')		  --to get swedish characters
GO


--create table ImportProduct
CREATE TABLE
	ImportOrder(
		ID INT,
		OrderDate VARCHAR(50),
		OrderNumber INT,
		CustomerID INT,
		TotalAmount VARCHAR(25))
GO


--import data from .csv file
BULK INSERT
	ImportOrder
FROM
	'C:\SQL1\CSV\Order.csv'	
WITH
	(FIRSTROW = 2)
GO


--change data type for TotalAmount, OrderDate to the same format as in DateKey and CustomerID to match ImportCustomer
UPDATE
	ImportOrder
SET
	TotalAmount = CAST(REPLACE(TotalAmount, ',', '.') as decimal(10,2)),
	OrderDate = CAST(REPLACE(LEFT(OrderDate, 10), '-', '') as INT),
	CustomerID = CustomerID + 1445

ALTER TABLE
	ImportOrder
ALTER COLUMN
	TotalAmount DECIMAL(10,2)

ALTER TABLE
	ImportOrder
ALTER COLUMN
	OrderDate INT
GO


--create table ImportOrderItem
CREATE TABLE
	ImportOrderItem(
		ID INT,
		OrderID INT,
		ProductID INT,
		UnitPrice VARCHAR(50),
		Quantity INT)
GO


--import data from .csv file
BULK INSERT
	ImportOrderItem
FROM
	'C:\SQL1\CSV\OrderItem.csv'
WITH
	(FIRSTROW = 2)
GO


--change data type for UnitPrice and ProductID so it's not duplicate
--last ProductID in DimProduct 321
UPDATE
	ImportOrderItem
SET
	UnitPrice = CAST(REPLACE(UnitPrice, ',', '.') as decimal(10,2)),
	ProductID = ProductID + 321

ALTER TABLE
	ImportOrderItem
ALTER COLUMN
	UnitPrice DECIMAL(10,2)
GO


--load relevant data into FactSales
INSERT INTO
	FactSales
SELECT
	OrderDate as DateKey,
	CustomerID as CustomerID,
	NULL as StaffID,
	ProductID as ProductID,
	Quantity as Quantity,
	TotalAmount as TotalSales
FROM
	ImportOrder as O
JOIN
	ImportOrderItem as I
ON
	O.ID = I.OrderID
GO