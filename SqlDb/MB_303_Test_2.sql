IF OBJECT_ID(N'tempdb..#COLUMNS') IS NOT NULL DROP TABLE #COLUMNS


CREATE TABLE #COLUMNS(ColumnName NVARCHAR(500));
INSERT INTO #COLUMNS VALUES	('sys_createdOn'),
	('sys_started'),
	('sys_updated'),
	('sys_schedulerStartDate'),
	('sys_schedulerEndDate'),
	('sys_completedDate'),
	('sys_personalLinkExpiryDate'),
	('sys_lastEditedDate')

DECLARE DataSet_CURSER CURSOR FOR SELECT UniqueId, UniqueName, UniqueIdName, [LastVersion] FROM [data].[sys_dataset] WHERE UniqueName LIKE 'PROJECTS_%'
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

			DECLARE @Query NVARCHAR(1000) = 'SELECT @C = COUNT(1) FROM ' + @NumTable + ' WHERE sys_updated IS NOT NULL';
			DECLARE @Count AS INT
			EXEC sp_executesql @Query, N'@C INT OUTPUT', @C = @Count OUTPUT
			IF (@Count > 0) PRINT @NumTable

		    SET @Counter  = @Counter  + 1
		END

	FETCH NEXT FROM DataSet_CURSER INTO @UniqueId, @UniqueName, @UniqueIdName, @LastVersion
	END
CLOSE DataSet_CURSER
DEALLOCATE DataSet_CURSER

DROP TABLE #COLUMNS