
--1. Gör en cursor som tar backup av samtliga databaser i er SQL-server. Ange valfri destination, exempelvis C:\Temp
--declare variables
DECLARE @databaseName VARCHAR(255)
DECLARE @path VARCHAR(255)
DECLARE @date VARCHAR(255)


--declare cursor
DECLARE 
	db_autoBackup

--populate with the logic
CURSOR FOR
	SELECT
		[name]
	FROM
		sysdatabases
	WHERE
		[name] NOT IN ('master', 'tempdb', 'model', 'msdb')
	AND
		[version] IS NOT NULL

--open cursor
OPEN
	db_autoBackup

--fetch data 
FETCH NEXT FROM
	db_autoBackup
INTO
	@databaseName

WHILE
	@@FETCH_STATUS = 0

--begin the custom business logic
BEGIN
	SET
		@date = CONVERT(VARCHAR(20), GETDATE(), 23) 
	SET 
		@path = 'C:\Windows\Temp\' + @databaseName + '_' + @date + '.BAK'
	BACKUP DATABASE 
		@databaseName TO DISK = @path

	--fetch the next data
	FETCH NEXT FROM
		db_autoBackup
	INTO
		@databaseName
END

--close and deallocate cursor
CLOSE
	db_autoBackup
DEALLOCATE
	db_autoBackup


--2. Skapa en tabell vid namn Almost_fact. Kolumnerna ska vara ID (som en räknare för att få unikhet), Date (inte tidpunkt),
--Prod_id, och Amount
USE 
	T618
GO

CREATE TABLE
	Almost_Fact(
		ID INT IDENTITY(1,1) PRIMARY KEY,
		[Date] DATE,
		Prod_ID INT,
		Amount INT)


--3. Skapa en cursor som går igenom rad efter rad i Order (samt Orderdetails) och lägger in datum, prod_id och Amount i
--respektive kolumn i Almost_fact

DECLARE @date DATE
DECLARE @prod_id INT
DECLARE @amount INT

DECLARE
	db_almostFactAdd
CURSOR FOR
	SELECT 
		FORMAT(OrderDate, 'yyyy-MM-dd'),					 --or cast(OrderDate as date)
		Prod_id,
		Amount
	FROM 
		Orders AS O
	INNER JOIN
		OrderDetails AS OD
	ON
		O.Orders_id = OD.Orders_id
	ORDER BY
		FORMAT(OrderDate, 'yyyy-MM-dd'),
		Prod_id

OPEN
	db_almostFactAdd

FETCH NEXT FROM
	db_almostFactAdd
INTO
	@date,
	@prod_id,
	@amount

WHILE
	@@FETCH_STATUS = 0
BEGIN
	INSERT INTO
		Almost_Fact(
		[Date],
		Prod_ID,
		Amount)
	VALUES(
		@date,
		@prod_id,
		@amount)

	FETCH NEXT FROM
		db_almostFactAdd
	INTO
		@date,
		@prod_id,
		@amount
END

CLOSE
	db_almostFactAdd

DEALLOCATE
	db_almostFactAdd
GO


SELECT * FROM Almost_Fact


