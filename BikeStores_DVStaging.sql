
USE DVBikeStoresStaging
GO

-- create schemas

CREATE SCHEMA production
CREATE SCHEMA sales


-- create tables

CREATE TABLE 
	[production].[brands](
		[brand_id] [int] PRIMARY KEY NOT NULL,
		[brand_name] [varchar](255) NULL,
		SequenceKey INT IDENTITY(1,1),
		BrandHashKey VARBINARY(16) NULL,
		LoadDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	[production].[categories](
		[category_id] [int] PRIMARY KEY NOT NULL,
		[category_name] [varchar](255) NULL,
		SequenceKey INT IDENTITY(1,1),
		CategoryHashKey VARBINARY(16) NULL,
		LoadDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	[production].[products](
		[product_id] [int] PRIMARY KEY NOT NULL,
		[product_name] [varchar](255) NULL,
		[brand_id] [int] NULL,
		[category_id] [int] NULL,
		[model_year] [smallint] NULL,
		[list_price] [decimal](10, 2) NULL,
		SequenceKey INT IDENTITY(1,1),
		ProductHashKey VARBINARY(16) NULL,
		LoadDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	[production].[stocks](
		[store_id] [int] NOT NULL,
		[product_id] [int] NOT NULL,
		[quantity] [int] NULL,
		SequenceKey INT IDENTITY(1,1),
		StockHashKey VARBINARY(16) NULL,
		LoadDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(store_id, product_id))

CREATE TABLE 
	[sales].[customers](
		[customer_id] [int] PRIMARY KEY NOT NULL,
		[first_name] [varchar](255) NULL,
		[last_name] [varchar](255) NULL,
		[phone] [varchar](25) NULL,
		[email] [varchar](255) NULL,
		[street] [varchar](255) NULL,
		[city] [varchar](50) NULL,
		[state] [varchar](25) NULL,
		[zip_code] [varchar](5) NULL,
		SequenceKey INT IDENTITY(1,1),
		CustomerHashKey VARBINARY(16) NULL,
		LoadDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	[sales].[order_items](
		[order_id] [int] NOT NULL,
		[item_id] [int] NOT NULL,
		[product_id] [int] NULL,
		[quantity] [int] NULL,
		[list_price] [decimal](10, 2) NULL,
		[discount] [decimal](4, 2) NULL,
		SequenceKey INT IDENTITY(1,1),
		OrderItemHashKey VARBINARY(16) NULL,
		LoadDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL,
		PRIMARY KEY(order_id, item_id))

CREATE TABLE 
	[sales].[orders](
		[order_id] [int] PRIMARY KEY NOT NULL,
		[customer_id] [int] NULL,
		[order_status] [tinyint] NULL,
		[order_date] [date] NULL,
		[required_date] [date] NULL,
		[shipped_date] [date] NULL,
		[store_id] [int] NULL,
		[staff_id] [int] NULL,
		SequenceKey INT IDENTITY(1,1),
		OrderHashKey VARBINARY(16) NULL,
		LoadDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	[sales].[staffs](
		[staff_id] [int] PRIMARY KEY NOT NULL,
		[first_name] [varchar](50) NULL,
		[last_name] [varchar](50) NULL,
		[email] [varchar](255) NULL,
		[phone] [varchar](25) NULL,
		[active] [tinyint] NULL,
		[store_id] [int] NULL,
		[manager_id] [int] NULL,
		SequenceKey INT IDENTITY(1,1),
		StaffHashKey VARBINARY(16) NULL,
		LoadDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)

CREATE TABLE 
	[sales].[stores](
		[store_id] [int] PRIMARY KEY NOT NULL,
		[store_name] [varchar](255) NULL,
		[phone] [varchar](25) NULL,
		[email] [varchar](255) NULL,
		[street] [varchar](255) NULL,
		[city] [varchar](255) NULL,
		[state] [varchar](10) NULL,
		[zip_code] [varchar](5) NULL,
		SequenceKey INT IDENTITY(1,1),
		StoreHashKey VARBINARY(16) NULL,
		LoadDate DATETIME2 NULL,
		RecordSource VARCHAR(50) NULL)


-- get data from DVBikestores

-- declare a time variable so all records from the same batch have the same timestamp
DECLARE @time DATETIME2 = GETDATE()

INSERT INTO 
	production.brands
SELECT
	[brand_id],
	[brand_name],
	HASHBYTES('md5', CAST(brand_id AS VARCHAR(10))),
	@time,
	'DVBikeStores.production.brands'
FROM
	DVBikeStores.production.brands


INSERT INTO
	[production].[categories]
SELECT
	[category_id],
	[category_name],
	HASHBYTES('md5', CAST(category_id AS VARCHAR(10))),
	@time,
	'DVBikeStores.production.categories'
FROM
	DVBikeStores.production.categories


INSERT INTO
	[production].[products]
SELECT
	[product_id],
	[product_name],
	[brand_id],
	[category_id],
	[model_year],
	[list_price],
	HASHBYTES('md5', CAST(product_id AS VARCHAR(10))),
	@time,
	'DVBikeStores.production.products'
FROM
	DVBikeStores.production.products


INSERT INTO
	[production].[stocks]
SELECT
	[store_id],
	[product_id],
	[quantity],
	HASHBYTES('md5', (HASHBYTES('md5', CAST(store_id AS VARCHAR(10))) + 
					 HASHBYTES('md5', CAST(product_id AS VARCHAR(10))))),
	@time,
	'DVBikeStores.production.stocks'
FROM
	DVBikeStores.production.stocks


INSERT INTO
	[sales].[customers]
SELECT
	[customer_id],
	[first_name],
	[last_name],
	[phone],
	[email],
	[street],
	[city],
	[state],
	[zip_code],
	HASHBYTES('md5', CAST(customer_id AS VARCHAR(10))),
	@time,
	'DVBikeStores.sales.customers'
FROM
	DVBikeStores.sales.customers


INSERT INTO
	[sales].[order_items]
SELECT
	[order_id],
	[item_id],
	[product_id],
	[quantity],
	[list_price],
	[discount],
	HASHBYTES('md5', (HASHBYTES('md5', CAST(order_id AS VARCHAR(10))) + 
					 HASHBYTES('md5', CAST(item_id AS VARCHAR(10))))),
	@time,
	'DVBikeStores.sales.order_items'
FROM
	DVBikeStores.sales.order_items


INSERT INTO
	[sales].[orders]
SELECT
	[order_id],
	[customer_id],
	[order_status],
	[order_date],
	[required_date],
	[shipped_date],
	[store_id],
	[staff_id],
	HASHBYTES('md5', CAST(order_id AS VARCHAR(10))),
	@time,
	'DVBikeStores.sales.orders'
FROM
	DVBikeStores.sales.orders


INSERT INTO
	[sales].[staffs]
SELECT		
	[staff_id],
	[first_name],
	[last_name],
	[email],
	[phone],
	[active],
	[store_id],
	[manager_id],
	HASHBYTES('md5', CAST(staff_id AS VARCHAR(10))),
	@time,
	'DVBikeStores.sales.staffs'
FROM
	DVBikeStores.sales.staffs


INSERT INTO
	[sales].[stores]
SELECT
	[store_id],
	[store_name],
	[phone],
	[email],
	[street],
	[city],
	[state],
	[zip_code],
	HASHBYTES('md5', CAST(store_id AS VARCHAR(10))),
	@time,
	'DVBikeStores.sales.stores'
FROM
	DVBikeStores.sales.stores
