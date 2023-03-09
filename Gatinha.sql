

/* Database for Dhiana's birthday present project */


CREATE DATABASE
	Gatinha
ON  PRIMARY 
	(NAME = N'Gatinha_DW', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DE22\MSSQL\DATA\Gatinha.mdf', 
	SIZE = 1048576KB, 
	FILEGROWTH = 10%)
LOG ON 
	(NAME = N'Gatinha_log', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.DE22\MSSQL\DATA\Gatinha_log.ldf', 
	SIZE = 262144KB, 
	FILEGROWTH = 10%)
COLLATE 
	 Latin1_General_100_BIN2_UTF8
GO


USE 
	Birthday
GO


--create DimDate
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
		[Day] TINYINT
		)
GO



--create procedure to fill DimDate 
CREATE PROC
	usp_DimDateAdd (@startDate DATE, @endDate DATE)
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
			CAST(REPLACE(CAST(@currentDate AS VARCHAR(10)), '-', '') AS INT) AS DateID,
			@currentDate AS [Date],
			YEAR(@currentDate) AS [Year],	 
			MONTH(@currentDate) AS [Month],
			DATENAME(MONTH, @currentDate) AS [MonthName],
			DATEPART(WEEKDAY, @currentDate) AS [Weekday],
			DATENAME(WEEKDAY, @currentDate) AS WeekdayName,
			DATEPART(ISO_WEEK, @currentDate) AS [Week],
			DATEPART(DAY, @currentDate) AS [Day]		

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


--execute usp_DimDateAdd to fill DimDate from birth to 10 years in the future
EXEC usp_DimDateAdd '1989-02-23', '2033-02-23'	


--create DimTerritory and insert basic info
CREATE TABLE
	DimTerritory(	
		TerritoryID INT IDENTITY (1,1) PRIMARY KEY,
		Country VARCHAR(100),
		City VARCHAR(50),
		Neighborhood VARCHAR(50))
GO

ALTER TABLE DimTerritory ADD Latitude VARCHAR(15)
ALTER TABLE DimTerritory ADD Longitude VARCHAR(15)


INSERT INTO	
	DimTerritory
VALUES
	()

--create DimPerson and insert basic info
CREATE TABLE
	DimPerson(	
		PersonID INT IDENTITY (1,1) PRIMARY KEY,
		PersonName VARCHAR(100),
		PersonCategoryName VARCHAR(50),
		BirthdayID INT FOREIGN KEY REFERENCES DimDate(DateID),
		BirthPlaceID INT FOREIGN KEY REFERENCES DimTerritory(TerritoryID))
GO

ALTER TABLE DimPerson ADD BirthDate DATE

INSERT INTO	
	DimPerson
VALUES
	(
	'Pippi',
	'Cassorra',
	20121022,
	1
	)


--create DimConcerts and insert basic info
CREATE TABLE
	DimConcerts(
		ConcertID INT IDENTITY (1,1) PRIMARY KEY,	
		ConcertName VARCHAR(255),
		TerritoryID INT FOREIGN KEY REFERENCES DimTerritory(TerritoryID),
		DateID INT FOREIGN KEY REFERENCES DimDate(DateID)
		)
GO


INSERT INTO	
	DimConcerts
VALUES
	(
	'Paramore',
	11,
	20230423
	)


--create DimTravels and insert basic info
CREATE TABLE
	DimTravels(
		TravelID INT IDENTITY (1,1) PRIMARY KEY,	
		TravelName VARCHAR(255),
		PersonID INT FOREIGN KEY REFERENCES DimPerson(PersonID),
		OtherPersonID INT FOREIGN KEY REFERENCES DimPerson(PersonID),
		TerritoryID INT FOREIGN KEY REFERENCES DimTerritory(TerritoryID),
		StartDateID INT FOREIGN KEY REFERENCES DimDate(DateID),
		EndDateID INT FOREIGN KEY REFERENCES DimDate(DateID)
		)
GO


INSERT INTO	
	DimTravels
VALUES
	(
	'Rio de Janeiro',
	1,
	NULL,
	3,
	20230217,
	20230211
	)


--create DimAnniversaries and insert basic info
CREATE TABLE
	DimAnniversaries(
		AnniversaryID INT IDENTITY (1,1) PRIMARY KEY,	
		AnniversaryName VARCHAR(255),
		TerritoryID INT FOREIGN KEY REFERENCES DimTerritory(TerritoryID),
		DateID INT FOREIGN KEY REFERENCES DimDate(DateID)
		)
GO

ALTER TABLE DimAnniversaries ADD AnniversaryDate DATE

INSERT INTO	
	DimAnniversaries
VALUES
	(
	'U-Haul',
	9,
	20220729
	)

CREATE TABLE	
	FactEvents(
		EventID INT IDENTITY(1,1) PRIMARY KEY,
		EventName VARCHAR(255),
		EventPlace VARCHAR(50),
		TerritoryID INT FOREIGN KEY REFERENCES DimTerritory(TerritoryID),
		Latitude VARCHAR(10),
		Longitude VARCHAR(10),
		StartDate DATE,
		EndDate DATE,
		DurationInDays INT,
		DurationInMonths INT,
		DurationinYears INT,
		IsConcert INT
		)

ALTER TABLE FactEvents ALTER COLUMN DurationInDays INT

INSERT INTO FactEvents
VALUES(
	'Pride Week',
	'Stockholm',
	9,
	'59.32',
	'18.05',
	'2022-08-01',
	'2022-08-16',
	NULL,
	NULL,
	NULL,
	0,
	1
)

CASE

