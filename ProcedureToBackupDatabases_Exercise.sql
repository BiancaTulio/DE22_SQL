
--I presentationen finns ett skript baserat på cursor för att ta backup av respektive databas i en SQL-server.
--Samtidigt så vet ni att man bör undvika cursors. Ert jobb är därför att skriva om backup-skriptet, till ett
--skript som gör samma sak, men som INTE är baserad på cursor.

--Using a while loop in a stored procedure
CREATE PROC
	usp_backupDatabases
AS
BEGIN
	SET NOCOUNT ON

	--declare variables
	DECLARE @databaseName NVARCHAR(255)
	DECLARE @date NVARCHAR(20)
	DECLARE @path NVARCHAR(255)
	DECLARE @count INT
	DECLARE @numRows INT

	--create a temporary table to loop through with the names of the databases to backup and a row number to iterate
	SELECT 
		CAST([name] AS nvarchar(255)) AS 'DatabaseName',
		ROW_NUMBER() OVER(ORDER BY [name]) AS 'RowNumber'
	INTO
		#temp_info
	FROM 
		sysdatabases
	WHERE
		[name] NOT IN ('master', 'model', 'msdb', 'tempdb')
	AND
		([status] & 512) != 512

	--set @numRows with the number of rows from the temporary table
	SELECT 
		@numRows = COUNT(*) 
	FROM 
		#temp_info

	--set @count as 1
	SET @count = 1

	--start the loop through all rows of the temporary table
	WHILE 
		@count <= @numRows 
	BEGIN
		--set @databaseName as the DatabaseName from the row we currently are in the loop  
		SELECT 
			@databaseName = DatabaseName
		FROM
			#temp_info
		WHERE
			RowNumber = @count

		--set @date as the current date
		SET @date = CONVERT(NVARCHAR(20), GETDATE(), 23)

		--set @path with the updated variables for the current database being backed up  
		SET @path = 'C:\Windows\Temp\' + @databaseName + '_' + @date + '.BAK'
	
		--backup the database
		BACKUP DATABASE 
			@databaseName TO DISK = @path

		--loop
		SET @count += 1
	END

	--get rid of the temporary table
	DROP TABLE 
		#temp_info
	
	SET NOCOUNT ON
END
GO

--execute procedure to backup all databases
EXEC usp_backupDatabases
