﻿IF OBJECT_ID(N'tempdb..#COLUMNS') IS NOT NULL
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

CREATE TABLE #COLUMNS(ColumnName NVARCHAR(500));
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
DECLARE @UniqueId NVARCHAR(10);
DECLARE @UniqueName NVARCHAR(500);
DECLARE @UniqueIdName NVARCHAR(500);
DECLARE @LastVersion NVARCHAR(500);
DECLARE @Table NVARCHAR(500);
DECLARE @TableName NVARCHAR(2000);
DECLARE @TxtTable NVARCHAR(2000);
DECLARE @TxtTableName NVARCHAR(2000);
DECLARE @NumTable NVARCHAR(2000);
DECLARE @NumTableName NVARCHAR(2000);
DECLARE @VarTable NVARCHAR(2000);

FETCH NEXT FROM DataSet_CURSER INTO @UniqueId, @UniqueName, @UniqueIdName, @LastVersion
WHILE (@@FETCH_STATUS = 0)
	BEGIN
	SET @TableName = 'DATA_' + @UniqueId + '_';
	SET @Table = '[data].[' + @TableName;
	SET @VarTable = @Table + 'VARS]';

	-- Check If any column exist in TXT
	DECLARE @Counter INT 
		SET @Counter = 1
		WHILE ( @Counter <= @LastVersion)
		BEGIN
			SET @TxtTable  = @Table + CONVERT(NVARCHAR, @Counter) + '_TXT]';
			SET @TxtTableName  = @TableName + CONVERT(NVARCHAR, @Counter) + '_TXT';
			SET @NumTable = @Table + CONVERT(NVARCHAR, @Counter) + '_NUM]';
			SET @NumTableName  = @TableName + CONVERT(NVARCHAR, @Counter) + '_NUM';
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

			IF EXISTS(SELECT TOP 1 * FROM #TXT_EXISTING_COLUMNS)
			BEGIN
				PRINT 'COLUMNS SHOULD NOT EXIST IN ' + @TxtTableName 
			END

			IF NOT EXISTS(SELECT TOP 1 * FROM #NUM_EXISTING_COLUMNS)
			BEGIN
				PRINT 'COLUMNS SHOULD EXIST IN ' + @NumTableName 
			END

			SELECT * INTO #COLUMNS_TO_UPDATE FROM #TXT_EXISTING_COLUMNS WHERE COLUMN_NAME NOT IN(SELECT COLUMN_NAME FROM #NUM_EXISTING_COLUMNS);

			IF EXISTS (SELECT TOP 1 * FROM #COLUMNS_TO_UPDATE)
			BEGIN
				PRINT 'COLUMNS SHOULD NOT EXIST IN COLUMNS_TO_UPDATE';
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