
--cursor to check index fragmentation in a database and reindex/reorganize indexes if needed
--first select the database you want to use, then run the code

--declare variables
DECLARE @tableName VARCHAR(255)
DECLARE @indexName VARCHAR(255)
DECLARE @indexType VARCHAR(255)
DECLARE @fragmentation DECIMAL(10,2)


--declare cursor
DECLARE
	db_reindexingCursor
CURSOR FOR
	--get the table name, index name, index type and fragmentation in percent	
	SELECT 
		OBJECT_NAME(fq.OBJECT_ID) AS 'TableName',
		fq.name AS 'IndexName', 
		qs.index_type_desc AS 'IndexType',
		CAST(qs.avg_fragmentation_in_percent AS decimal(10,2))	AS 'FragmentationInPercent'
	FROM 
		sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS qs
	INNER JOIN sys.indexes AS fq
	ON 
		fq.object_id = qs.object_id
	AND 
		fq.index_id = qs.index_id
	WHERE 
		qs.avg_fragmentation_in_percent > 0
	ORDER BY 
		qs.avg_fragmentation_in_percent DESC

--open cursor
OPEN
	db_reindexingCursor

--fetch first data
FETCH NEXT FROM
	db_reindexingCursor
INTO
	@tableName,
	@indexName,
	@indexType,
	@fragmentation

--loop until the last row
WHILE
	@@FETCH_STATUS = 0
BEGIN
	IF @fragmentation BETWEEN 5 AND 30
		BEGIN
			SELECT @fragmentation
		END
	IF @fragmentation > 30
		BEGIN
			SELECT @fragmentation
		END	

	--fetch next data
	FETCH NEXT FROM
		db_reindexingCursor
	INTO
		@tableName,
		@indexName,
		@indexType,
		@fragmentation
END
