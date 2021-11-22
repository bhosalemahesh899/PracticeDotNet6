IF OBJECT_ID(N'tempdb..#COLUMNS') IS NOT NULL
BEGIN
	DROP TABLE #COLUMNS
END

IF OBJECT_ID(N'tempdb..#TABLES') IS NOT NULL
BEGIN
	DROP TABLE #TABLES
END

IF OBJECT_ID(N'tempdb..#TXTTABLES') IS NOT NULL
BEGIN
	DROP TABLE #TXTTABLES
END

IF OBJECT_ID(N'tempdb..#VARTABLES') IS NOT NULL
BEGIN
	DROP TABLE #VARTABLES
END

--SELECT * INTO #DataSet FROM 
--(
--	SELECT CAST([UniqueId] AS NVARCHAR(10)) AS [UniqueId], [UniqueName], [UniqueIdName], [LastVersion], [LiveVersion] FROM [data].[sys_dataset]
--) AS ABC
--GO

CREATE TABLE #COLUMNS(ColumnName VARCHAR(500));
INSERT INTO #COLUMNS VALUES	('sys_createdOn'),
	('sys_started'),
	('sys_updated'),
	('sys_schedulerStartDate'),
	('sys_schedulerEndDate'),
	('sys_completedDate'),
	('sys_personalLinkExpiryDate'),
	('sys_lastEditedDate')

DECLARE @VariableType NVARCHAR(10) = 3

DECLARE DataSet_CURSER CURSOR FOR SELECT UniqueId, UniqueName, UniqueIdName, [LastVersion] FROM [data].[sys_dataset]
OPEN DataSet_CURSER
DECLARE @UniqueId nvarchar(10);
DECLARE @UniqueName nvarchar(500);
DECLARE @UniqueIdName nvarchar(500);
DECLARE @LastVersion nvarchar(500);
DECLARE @Table nvarchar(500);
DECLARE @TableName VARCHAR(2000);
DECLARE @TxtTable VARCHAR(2000);
DECLARE @TxtTableName VARCHAR(2000);
DECLARE @NumTable VARCHAR(2000);
DECLARE @NumTableName VARCHAR(2000);
DECLARE @VarTable VARCHAR(2000);
DECLARE @Query nvarchar(MAX);
DECLARE @AlterNumTableQuery VARCHAR(MAX);

FETCH NEXT FROM DataSet_CURSER INTO @UniqueId, @UniqueName, @UniqueIdName, @LastVersion
WHILE (@@FETCH_STATUS = 0)
	BEGIN
	SET @TableName = 'DATA_' + @UniqueId + '_';
	SET @Table = '[data].[' + @TableName;
	SET @VarTable = @Table + 'VARS]';

	SET @Query = 'UPDATE ' + @VarTable + ' SET VariableType = ' + @VariableType + ' WHERE Name IN (SELECT ColumnName FROM #COLUMNS) AND VariableType != ' + @VariableType; 
	--EXECUTE sp_executesql @Query --Update VariableType
	--PRINT @Query

	-- Check If any column exist in TXT
	DECLARE @Counter INT 
		SET @Counter = 1
		WHILE ( @Counter <= @LastVersion)
		BEGIN
			SET @TxtTable  = @Table + CONVERT(VARCHAR, @Counter) + '_TXT]';
			SET @TxtTableName  = @TableName + CONVERT(VARCHAR, @Counter) + '_TXT';
			SET @NumTable = @Table + CONVERT(VARCHAR, @Counter) + '_NUM]';
			SET @NumTableName  = @TableName + CONVERT(VARCHAR, @Counter) + '_NUM';
			IF OBJECT_ID(N'tempdb..#TXT_EXISTING_COLUMNS') IS NOT NULL
				BEGIN
					DROP TABLE #TXT_EXISTING_COLUMNS
				END

			IF OBJECT_ID(N'tempdb..#NUM_EXISTING_COLUMNS') IS NOT NULL
				BEGIN
					DROP TABLE #NUM_EXISTING_COLUMNS
				END
			IF OBJECT_ID(N'tempdb..#COLUMNS_TO_UPDATE') IS NOT NULL
				BEGIN
					DROP TABLE #COLUMNS_TO_UPDATE
				END

			SELECT * INTO #TXT_EXISTING_COLUMNS FROM (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TxtTableName AND COLUMN_NAME IN (SELECT ColumnName FROM #COLUMNS)) AS T2
			SELECT * INTO #NUM_EXISTING_COLUMNS FROM (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @NumTableName AND COLUMN_NAME IN (SELECT ColumnName FROM #COLUMNS)) AS T2

			IF EXISTS (SELECT * FROM #TXT_EXISTING_COLUMNS)
				BEGIN
					SELECT @AlterNumTableQuery = STRING_AGG(COLUMN_NAME, ' DATETIME2, ') + ' DATETIME2' FROM #TXT_EXISTING_COLUMNS WHERE COLUMN_NAME NOT IN(SELECT COLUMN_NAME FROM #NUM_EXISTING_COLUMNS);
					IF LEN(ISNULL(@AlterNumTableQuery,'')) > 0
					BEGIN
						SET @AlterNumTableQuery = 'ALTER TABLE ' + @NumTable + ' ADD ' + @AlterNumTableQuery;
						PRINT @AlterNumTableQuery;
					END
					--EXECUTE sp_executesql @@AlterNumTableQuery --Add Columns
				END
			DROP TABLE #TXT_EXISTING_COLUMNS
			DROP TABLE #NUM_EXISTING_COLUMNS
		    SET @Counter  = @Counter  + 1
		END

	FETCH NEXT FROM DataSet_CURSER INTO @UniqueId, @UniqueName, @UniqueIdName, @LastVersion
	END
CLOSE DataSet_CURSER
DEALLOCATE DataSet_CURSER

DROP TABLE #COLUMNS