
/*	procedure with a cursor to check index fragmentation in the current database and reindex/reorganize indexes if needed	*/

CREATE PROC
	usp_indexMaintenance
AS
BEGIN

	--get the date and time at the start of the script
	DECLARE @startTime DATETIME = GETDATE()


	--get information about the current database's tables, indexes and fragmentation 
	--store the information in a temporary table so it's easy to get the status of checked tables and indexes later
	SELECT 
		OBJECT_NAME(I.OBJECT_ID) AS 'TableName',
		I.[name] AS 'IndexName', 
		S.index_type_desc AS 'IndexType',
		CAST(S.avg_fragmentation_in_percent AS decimal(10,2)) AS 'FragmentationInPercent'
	INTO
		#TableIndexes
	FROM 
		sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS S		--DB_ID() gets info from the current database only		 
	INNER JOIN 
		sys.indexes AS I		--join sys.indexes to get index name						  		   
	ON 
		I.object_id = S.object_id
	AND 
		I.index_id = S.index_id
	WHERE 
		OBJECT_NAME(I.OBJECT_ID) != 'sysdiagrams' 
	ORDER BY 
		TableName


	--declare cursor variables
	DECLARE @tableName VARCHAR(255)
	DECLARE @indexName VARCHAR(255)
	DECLARE @indexType VARCHAR(255)
	DECLARE @fragmentation DECIMAL(10,2)


	--declare cursor
	DECLARE
		db_reindexingCursor
	CURSOR FOR
		--select everything from the temporary table
		SELECT
			*
		FROM
			#TableIndexes


	--open cursor
	OPEN
		db_reindexingCursor


	--fetch first data into the variables
	FETCH NEXT FROM
		db_reindexingCursor
	INTO
		@tableName,
		@indexName,
		@indexType,
		@fragmentation


	--declare variables to keep track of the cursor's status
	DECLARE @reindexed INT = 0
	DECLARE @reorganized INT = 0

	--loop until the last row
	WHILE
		@@FETCH_STATUS = 0
	BEGIN
		--if the fragmentation is less than or equal to 5%, do nothing
		IF @fragmentation <= 5
			BEGIN
				SELECT 
					@tableName AS 'Table', 
					@indexName AS 'Index', 
					@indexType AS 'Type', 
					@fragmentation AS 'Fragmentation',
					'SKIP' AS 'Action'
			END
	
		--if it's more than 5% and less or equal 30%, reorganize the index 
		IF @fragmentation > 5 AND @fragmentation <= 30
			BEGIN
				SELECT 
					@tableName AS 'Table', 
					@indexName AS 'Index', 
					@indexType AS 'Type', 
					@fragmentation AS 'Fragmentation',
					'REORGANIZE' AS 'Action'
				--add 1 to the reorganized indexes' status
				SELECT @reorganized += 1
			END

		--if it's more than 30%, rebuild the index
		IF @fragmentation > 30
			BEGIN
				SELECT 
					@tableName AS 'Table', 
					@indexName AS 'Index', 
					@indexType AS 'Type', 
					@fragmentation AS 'Fragmentation',
					'REBUILD' AS 'Action'
				--add 1 to the rebuilt indexes' stauts
				SELECT @reindexed += 1
			END	
	
		--fetch next data into the variables
		FETCH NEXT FROM
			db_reindexingCursor
		INTO
			@tableName,
			@indexName,
			@indexType,
			@fragmentation
	END


	--close and deallocate cursor
	CLOSE
		db_reindexingCursor

	DEALLOCATE
		db_reindexingCursor


	--declare and initialize variables to show in the status how many tables and indexes were checked by the cursor
	DECLARE @tables INT
	DECLARE @indexes INT = 0
	SELECT @tables = COUNT(DISTINCT TableName) FROM #TableIndexes
	SELECT @indexes = COUNT(DISTINCT IndexName) FROM #TableIndexes


	--show the final status for the cursor
	SELECT 'The script started at ' + CAST(@startTime AS varchar(25)) + ' and ended at ' + CAST(GETDATE() AS varchar(25)) + '.'
	SELECT 'Total elapsed time: ' + CAST(CAST(GETDATE() - @startTime AS TIME) AS varchar(25))
	SELECT 'The script has checked ' + CAST(@tables AS varchar(5)) + ' tables and '	+ CAST(@indexes AS varchar(5)) + ' indexes.'
	SELECT CAST(@reorganized AS varchar(5)) + ' indexes were reorganized and ' + CAST(@reindexed AS varchar(5)) + ' indexes were reindexed.'


	--drop the temporary table
	DROP TABLE #TableIndexes
END
GO

--execute the procedure
EXEC usp_indexMaintenance 
																	   