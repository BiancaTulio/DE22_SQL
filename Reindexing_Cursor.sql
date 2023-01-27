
/*	procedure with a cursor to check index fragmentation in the current database and reindex/reorganize indexes if needed	*/
/*	note that if an index has less than 8 pages, rebuilding it is not going to reduce fragmentation		*/
						  
CREATE PROC
	usp_indexMaintenance
AS
	SET NOCOUNT ON

	-- get the date and time at the start of the script
	DECLARE @startTime DATETIME = GETDATE()


	-- get the current database's tables, indexes and fragmentation in percent
	-- store the information in a temporary table so it's available outside the cursor
	SELECT 
		OBJECT_NAME(S.[object_id]) AS 'TableName',
		I.[name] AS 'IndexName', 
		CAST(S.avg_fragmentation_in_percent AS decimal(10,2)) AS 'FragmentationInPercent'
	INTO
		#TablesAndIndexes
	FROM 
		sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS S			 
	INNER JOIN 
		--join sys.indexes to get index name						  		   
		sys.indexes AS I								
	ON 
		I.[object_id] = S.[object_id]
	AND 
		I.index_id = S.index_id
	WHERE 
		--skip sysdiagrams tables
		OBJECT_NAME(S.[object_id]) != 'sysdiagrams' 	
	AND
		--skip indexes named NULL, which are tables without indexes  
		I.[name] IS NOT NULL							
	ORDER BY 
		TableName

	
	-- get the number of tables and indexes checked to show in the status at the end of the cursor
	DECLARE @tables INT
	DECLARE @indexes INT 
	SELECT @tables = COUNT(DISTINCT TableName) FROM #TablesAndIndexes
	SELECT @indexes = COUNT(DISTINCT IndexName) FROM #TablesAndIndexes


	-- declare cursor variables
	DECLARE @tableName VARCHAR(255)
	DECLARE @indexName VARCHAR(255)
	DECLARE @fragmentation DECIMAL(10,2)


	-- declare and open cursor
	DECLARE
		db_cursorIdxMntc
	CURSOR FOR
		-- select everything from the temporary table
		SELECT
			*
		FROM
			#TablesAndIndexes
	OPEN
		db_cursorIdxMntc


	-- fetch first data into the variables
	FETCH NEXT FROM
		db_cursorIdxMntc
	INTO
		@tableName,
		@indexName,
		@fragmentation


	-- declare variables to keep track of the reindexing status
	DECLARE @rebuilt INT = 0
	DECLARE @reorganized INT = 0


	-- declare variables to execute ALTER INDEX statements inside the cursor
	DECLARE @reorganizeIdx VARCHAR(MAX) = 'ALTER INDEX ' + @indexName + ' ON ' + @tableName + ' REORGANIZE'
	DECLARE @rebuildIdx VARCHAR(MAX) = 'ALTER INDEX ' + @indexName + ' ON ' + @tableName + ' REBUILD WITH (ONLINE = ON)'


	-- loop until the last row in #TablesAndIndexes
	WHILE
		@@FETCH_STATUS = 0
	BEGIN	
		IF @fragmentation > 5 AND @fragmentation <= 30
		BEGIN
			-- reorganize index
			EXEC (@reorganizeIdx)
			-- add 1 to the reorganized indexes' status
			SET @reorganized += 1
		END

		IF @fragmentation > 30
		BEGIN
			-- rebuild index
			EXEC (@rebuildIdx)
			-- add 1 to the rebuilt indexes' stauts
			SET @rebuilt += 1
		END	
	
		-- fetch next data into the variables
		FETCH NEXT FROM
			db_cursorIdxMntc
		INTO
			@tableName,
			@indexName,
			@fragmentation
	END


	-- close and deallocate cursor
	CLOSE
		db_cursorIdxMntc
	DEALLOCATE
		db_cursorIdxMntc


	-- print the final status for the cursor
	PRINT 'The script started at ' + CAST(@startTime AS varchar(25)) + ' and ended at ' + CAST(GETDATE() AS varchar(25)) + '.' 
	PRINT 'Total elapsed time: ' + CAST(CAST(GETDATE() - @startTime AS TIME) AS varchar(25)) 
	PRINT 'The script has checked ' + CAST(@tables AS varchar(5)) + ' table(s) and ' + CAST(@indexes AS varchar(5)) + ' index(es).' 
	PRINT CAST(@reorganized AS varchar(5)) + ' index(es) reorganized and ' + CAST(@rebuilt AS varchar(5)) + ' index(es) rebuilt.'


	--drop the temporary table
	DROP TABLE #TablesAndIndexes

	SET NOCOUNT OFF
GO


--execute the procedure
EXEC usp_indexMaintenance  

																	   