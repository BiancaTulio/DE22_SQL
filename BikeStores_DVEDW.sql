
USE DVBikeStoresEDW
GO

-- create tables for the Hubs

CREATE TABLE 
	HubBrand(
		BrandHashKey VARBINARY(16) PRIMARY KEY,
		BrandKey INT NOT NULL,
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	HubCategory(
		CategoryHashKey VARBINARY(16) PRIMARY KEY,
		CategoryKey INT NOT NULL,
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,		
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	HubProduct(
		ProductHashKey VARBINARY(16) PRIMARY KEY,
		ProductKey INT NOT NULL,
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,		
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	HubOrder(
		OrderHashKey VARBINARY(16) PRIMARY KEY,
		OrderKey INT NOT NULL,
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,		
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	HubStore(
		StoreHashKey VARBINARY(16) PRIMARY KEY,
		StoreKey INT NOT NULL,
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,		
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	HubCustomer(
		CustomerHashKey VARBINARY(16) PRIMARY KEY,
		CustomerKey INT NOT NULL,
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,		
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	HubStaff(
		StaffHashKey VARBINARY(16) PRIMARY KEY,
		StaffKey INT NOT NULL,
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,		
		RecordSource VARCHAR(50) NULL)


-- create tables for the Links

CREATE TABLE 
	LinkProductBrand(
		ProductBrandHashKey VARBINARY(16) PRIMARY KEY,
		ProductHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubProduct(ProductHashKey),
		BrandHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubBrand(BrandHashKey),
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	LinkStock(
		StockHashKey VARBINARY(16) PRIMARY KEY,
		StoreHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStore(StoreHashKey),
		ProductHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubProduct(ProductHashKey),
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	LinkOrderItem(
		OrderItemHashKey VARBINARY(16) PRIMARY KEY,
		OrderHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubOrder(OrderHashKey),
		ProductHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubProduct(ProductHashKey),
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	LinkProductCategory(
		ProductCategoryHashKey VARBINARY(16) PRIMARY KEY,
		ProductHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubProduct(ProductHashKey),
		CategoryHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubCategory(CategoryHashKey),
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	LinkCustomerOrder(
		CustomerOrderHashKey VARBINARY(16) PRIMARY KEY,
		CustomerHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubCustomer(CustomerHashKey),
		OrderHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubOrder(OrderHashKey),
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	LinkOrderStore(
		OrderStoreHashKey VARBINARY(16) PRIMARY KEY,
		OrderHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubOrder(OrderHashKey),
		StoreHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStore(StoreHashKey),
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	LinkStoreStaff(
		StoreStaffHashKey VARBINARY(16) PRIMARY KEY,
		StoreHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStore(StoreHashKey),
		StaffHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStaff(StaffHashKey),
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	LinkOrderStaff(
		OrderSatffHashKey VARBINARY(16) PRIMARY KEY,
		OrderHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubOrder(OrderHashKey),
		StaffHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStaff(StaffHashKey),
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)
			 
CREATE TABLE 
	LinkStaffManager(
		StaffManagerHashKey VARBINARY(16) PRIMARY KEY,
		StaffHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStaff(StaffHashKey),
		ManagerHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStaff(StaffHashKey),
		LoadDate DATETIME2 NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)


-- create the tables for the Satellites

CREATE TABLE 
	SatBrand(
		BrandHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubBrand(BrandHashKey),
		BrandName VARCHAR(255) NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(BrandHashKey, LoadDate))

CREATE TABLE 
	SatProduct(
		ProductHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubProduct(ProductHashKey),
		ProductName VARCHAR(255) NULL,
		ModelYear SMALLINT NULL,
		ListPrice DECIMAL(10, 2) NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(ProductHashKey, LoadDate))

CREATE TABLE 
	SatCategory(
		CategoryHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubCategory(CategoryHashKey),
		CategoryName VARCHAR(255) NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(CategoryHashKey, LoadDate))

CREATE TABLE 
	SatStock(
		StockHashKey VARBINARY(16) FOREIGN KEY REFERENCES LinkStock(StockHashKey),
		Quantity INT NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(StockHashKey, LoadDate))

CREATE TABLE 
	SatStore(
		StoreHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStore(StoreHashKey),
		StoreName VARCHAR(255) NULL,
		Phone VARCHAR(25) NULL,
		Email VARCHAR(255) NULL,
		Street VARCHAR(255) NULL,
		City VARCHAR(255) NULL,
		[State] VARCHAR(10) NULL,
		ZipCode VARCHAR(5) NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(StoreHashKey, LoadDate))

CREATE TABLE 
	SatOrderItem(
		OrderItemHashKey VARBINARY(16) FOREIGN KEY REFERENCES LinkOrderItem(OrderItemHashKey),
		ItemID INT NULL,
		Quantity INT NULL,
		Discount DECIMAL(4,2) NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(OrderItemHashKey, LoadDate))

CREATE TABLE 
	SatCustomerInfo(
		CustomerHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubCustomer(CustomerHashKey),
		Email VARCHAR(255) NULL,
		Phone VARCHAR(25) NULL,
		Street VARCHAR(255) NULL,
		City VARCHAR(50) NULL,
		[State] VARCHAR(25) NULL,
		ZipCode VARCHAR(5) NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(CustomerHashKey, LoadDate))

CREATE TABLE 
	SatCustomer(
		CustomerHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubCustomer(CustomerHashKey),
		FirstName VARCHAR(255) NULL,
		LastName VARCHAR(255) NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(CustomerHashKey, LoadDate))

CREATE TABLE 
	SatOrder(
		OrderHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubOrder(OrderHashKey),
		OrderStatus TINYINT NULL,
		OrderDate DATE NULL,
		RequiredDate DATE NULL,
		ShippedDate DATE NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(OrderHashKey, LoadDate))

CREATE TABLE 
	SatStaff(
		StaffHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStaff(StaffHashKey),
		FirstName VARCHAR(50) NULL,
		LastName VARCHAR(50) NULL,
		ManagerKey INT NULL,
		IsActive TINYINT NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(StaffHashKey, LoadDate))

CREATE TABLE 
	SatStaffInfo(
		StaffHashKey VARBINARY(16) FOREIGN KEY REFERENCES HubStaff(StaffHashKey),
		Email VARCHAR(255) NULL,
		Phone VARCHAR(25) NULL,
		LoadDate DATETIME2 NOT NULL,
		LoadEndDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(StaffHashKey, LoadDate))


-- get data from DVBikestoresStaging

-- declare a time variable so all records from the same batch have the same timestamp

DECLARE @time DATETIME2 = GETDATE()


-- Hubs

INSERT INTO 
	HubBrand
SELECT
	BrandHashKey,
	brand_id,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.brands'
FROM
	DVBikeStoresStaging.production.brands

INSERT INTO 
	HubCategory
SELECT
	CategoryHashKey,
	category_id,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.categories'
FROM
	DVBikeStoresStaging.production.categories

INSERT INTO 
	HubProduct
SELECT
	ProductHashKey,
	product_id,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.products'
FROM
	DVBikeStoresStaging.production.products

INSERT INTO 
	HubOrder
SELECT
	OrderHashKey,
	order_id,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.orders'
FROM
	DVBikeStoresStaging.sales.orders

INSERT INTO 
	HubStore
SELECT
	StoreHashKey,
	store_id,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.stores'
FROM
	DVBikeStoresStaging.sales.stores

INSERT INTO 
	HubCustomer
SELECT
	CustomerHashKey,
	customer_id,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.customers'
FROM
	DVBikeStoresStaging.sales.customers

INSERT INTO 
	HubStaff
SELECT
	StaffHashKey,
	staff_id,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.staffs'
FROM
	DVBikeStoresStaging.sales.staffs


-- Links

INSERT INTO 
	LinkProductBrand
SELECT
	HASHBYTES('md5', (ProductHashKey + HASHBYTES('md5', CAST(brand_id AS VARCHAR(10))))),
	ProductHashKey,
	HASHBYTES('md5', CAST(brand_id AS VARCHAR(10))),
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.products'
FROM
	DVBikeStoresStaging.production.products

INSERT INTO 
	LinkStock
SELECT
	StockHashKey,
	HASHBYTES('md5', CAST(store_id AS VARCHAR(10))),
	HASHBYTES('md5', CAST(product_id AS VARCHAR(10))),
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.stocks'
FROM
	DVBikeStoresStaging.production.stocks

INSERT INTO 
	LinkOrderItem
SELECT
	OrderItemHashKey,
	HASHBYTES('md5', CAST(order_id AS VARCHAR(10))),
	HASHBYTES('md5', CAST(product_id AS VARCHAR(10))),
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.order_items'
FROM
	DVBikeStoresStaging.sales.order_items

INSERT INTO 
	LinkProductCategory
SELECT
	HASHBYTES('md5', (ProductHashKey + HASHBYTES('md5', CAST(category_id AS VARCHAR(10))))),
	ProductHashKey,
	HASHBYTES('md5', CAST(category_id AS VARCHAR(10))),
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.products'
FROM
	DVBikeStoresStaging.production.products

INSERT INTO 
	LinkCustomerOrder
SELECT
	HASHBYTES('md5', (HASHBYTES('md5', CAST(customer_id AS VARCHAR(10))) + OrderHashKey)),
	HASHBYTES('md5', CAST(customer_id AS VARCHAR(10))),
	OrderHashKey,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.orders'
FROM
	DVBikeStoresStaging.sales.orders

INSERT INTO 
	LinkOrderStore
SELECT
	HASHBYTES('md5', (OrderHashKey + HASHBYTES('md5', CAST(store_id AS VARCHAR(10))))),
	OrderHashKey,
	HASHBYTES('md5', CAST(store_id AS VARCHAR(10))),
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.orders'
FROM
	DVBikeStoresStaging.sales.orders

INSERT INTO 
	LinkStoreStaff
SELECT
	HASHBYTES('md5', (HASHBYTES('md5', CAST(store_id AS VARCHAR(10))) + StaffHashKey)),
	HASHBYTES('md5', CAST(store_id AS VARCHAR(10))),
	StaffHashKey,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.staffs'
FROM
	DVBikeStoresStaging.sales.staffs

INSERT INTO 
	LinkOrderStaff
SELECT
	HASHBYTES('md5', (OrderHashKey + HASHBYTES('md5', CAST(staff_id AS VARCHAR(10))))),
	OrderHashKey,
	HASHBYTES('md5', CAST(staff_id AS VARCHAR(10))),
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.orders'
FROM
	DVBikeStoresStaging.sales.orders

INSERT INTO 
	LinkStaffManager
SELECT
	HASHBYTES('md5', (StaffHashKey + HASHBYTES('md5', CAST(manager_id AS VARCHAR(10))))),
	StaffHashKey,
	HASHBYTES('md5', CAST(manager_id AS VARCHAR(10))),
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.staffs'
FROM
	DVBikeStoresStaging.sales.staffs
WHERE
	manager_id IS NOT NULL


-- Satellites

INSERT INTO 
	SatBrand
SELECT
	BrandHashKey,
	brand_name,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.brands'
FROM
	DVBikeStoresStaging.production.brands

INSERT INTO 
	SatProduct
SELECT
	ProductHashKey,
	product_name,
	model_year,
	list_price,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.products'
FROM
	DVBikeStoresStaging.production.products

INSERT INTO 
	SatCategory
SELECT
	CategoryHashKey,
	category_name,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.categories'
FROM
	DVBikeStoresStaging.production.categories

INSERT INTO 
	SatStock
SELECT
	StockHashKey,
	quantity,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.production.stocks'
FROM
	DVBikeStoresStaging.production.stocks

INSERT INTO 
	SatStore
SELECT
	StoreHashKey,
	store_name,
	phone,
	email,
	street,
	city,
	[state],
	zip_code,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.stores'
FROM
	DVBikeStoresStaging.sales.stores

INSERT INTO 
	SatOrderItem
SELECT
	OrderItemHashKey,
	item_id,
	quantity,
	discount,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.order_items'
FROM
	DVBikeStoresStaging.sales.order_items

INSERT INTO 
	SatCustomerInfo
SELECT
	CustomerHashKey,
	email,
	phone,
	street,
	city,
	[state],
	zip_code,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.customers'
FROM
	DVBikeStoresStaging.sales.customers

INSERT INTO 
	SatCustomer
SELECT
	CustomerHashKey,
	first_name,
	last_name,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.customers'
FROM
	DVBikeStoresStaging.sales.customers

INSERT INTO 
	SatOrder
SELECT
	OrderHashKey,
	order_status,
	order_date,
	required_date,
	shipped_date,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.orders'
FROM
	DVBikeStoresStaging.sales.orders

INSERT INTO 
	SatStaff
SELECT
	StaffHashKey,
	first_name,
	last_name,
	manager_id,
	active,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.staffs'
FROM
	DVBikeStoresStaging.sales.staffs

INSERT INTO 
	SatStaffInfo
SELECT
	StaffHashKey,
	email,
	phone,
	@time,
	'9999-12-31',
	'DVBikeStoresStaging.sales.staffs'
FROM
	DVBikeStoresStaging.sales.staffs
GO


-- sample query to test if it's working

SELECT
	S.FirstName,
	S.LastName,
	M.FirstName,
	M.LastName
FROM
	SatStaff AS S
INNER JOIN
	SatStaff AS M
ON
	HASHBYTES('md5', CAST(S.ManagerKey AS VARCHAR(10))) = M.StaffHashKey
