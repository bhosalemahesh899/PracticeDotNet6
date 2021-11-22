/*************************************
IDEA-303
This script runs on a single tenant and performs the following steps
1) Changes datatype of listed columns to VariableType 3 IN VAR tables to define them as of date type
2) Adds listed columns as new columns in NUM tables and updates the column value from TXT tables
3) Removes listed columns from TXT tables
*************************************/
BEGIN TRAN
	
	IF OBJECT_ID(N'tempdb..#TXTTABLES') IS NOT NULL
	BEGIN
		DROP TABLE #TXTTABLES
	END

	IF OBJECT_ID(N'tempdb..#VARTABLES') IS NOT NULL
	BEGIN
		DROP TABLE #VARTABLES
	END

	IF OBJECT_ID(N'tempdb..#COLUMNS') IS NOT NULL
	BEGIN
		DROP TABLE #COLUMNS
	END

	IF OBJECT_ID(N'tempdb..#EXISTINGCOLUMNS') IS NOT NULL
	BEGIN
		DROP TABLE #EXISTINGCOLUMNS
	END

	--Start Actual Script Execution
	DECLARE @ColumnsToProcess  VARCHAR(500) = '';
	DECLARE @Query NVARCHAR(MAX) = ''
	DECLARE @TxtTable VARCHAR(2000) = ''
	DECLARE @NumTable VARCHAR(2000) = ''
	DECLARE @VarTable VARCHAR(2000) = ''
	DECLARE @IsColumnExistsInNum INT = 0
	DECLARE @IsColumnExistsInTxt INT = 0
	DECLARE @VariableType INT = 3
	DECLARE @Iterator INT = 0
	DECLARE @Iterator_Column INT = 0
	

	CREATE TABLE #COLUMNS(ColumnName varchar(500))
	CREATE TABLE #EXISTINGCOLUMNS(ColumnName VARCHAR(500), IsColumnExistsInTxt BIT, IsColumnExistsInNum BIT)
	CREATE TABLE #VARTABLES(varName VARCHAR(2000))
	CREATE TABLE #TXTTABLES(txtName VARCHAR(2000))
	
	INSERT INTO #COLUMNS VALUES
	('sys_createdOn'),
	('sys_started'),
	('sys_updated'),
	('sys_schedulerStartDate'),
	('sys_schedulerEndDate'),
	('sys_completedDate'),
	('sys_personalLinkExpiryDate'),
	('sys_lastEditedDate')

	SET @Query = ' INSERT INTO #VARTABLES SELECT CONCAT(''data.'',TABLE_NAME) FROM INFORMATION_SCHEMA.Tables WHERE TABLE_NAME LIKE ''%data_%[0-9]%_VARS%''; ' 
	EXEC(@Query)
	
	SELECT @Iterator = COUNT(*) from #VARTABLES;
	WHILE (@Iterator > 0)  
	BEGIN
		SELECT @Iterator = @Iterator - 1;
		SELECT DISTINCT @VarTable = varName  FROM #VARTABLES ORDER BY varName DESC OFFSET @Iterator ROWS FETCH NEXT 1 ROWS ONLY;

		SELECT @Query = ' DECLARE @UniqueId VARCHAR(20) = SUBSTRING(''' + @VarTable + ''',PATINDEX(''%[0-9]%'',''' + @VarTable + '''),PATINDEX(''%_VARS%'',''' + @VarTable + ''')-(PATINDEX(''%[0-9]%'',''' + @VarTable + '''))); '
		SELECT @Query += ' INSERT INTO #TXTTABLES(txtName) 
						SELECT DISTINCT CONCAT(''data.'',TABLE_NAME) 
						FROM INFORMATION_SCHEMA.TABLES 
						WHERE CONCAT(''data.'',TABLE_NAME) LIKE ''%data.DATA_''+@UniqueId+''_%_TXT''; ' 
		EXEC(@Query)
		
		-- Update datetype = 3 to refer column as of date type
		SELECT @Query = ' UPDATE ' + @VarTable + ' SET VariableType = ' + CAST(@VariableType AS VARCHAR(10)) + ' WHERE Name IN (SELECT ColumnName FROM #COLUMNS); '
		EXEC(@Query)
	END
	
	SELECT DISTINCT @Iterator = COUNT(*) from #TXTTABLES;
	WHILE (@Iterator > 0)  
	BEGIN  
		SELECT @Iterator = @Iterator - 1;
		SELECT DISTINCT @TxtTable = txtName  FROM #TXTTABLES ORDER BY txtName DESC OFFSET @Iterator ROWS FETCH NEXT 1 ROWS ONLY;
		SELECT @NumTable = REPLACE(@TxtTable,'TXT','NUM');
	
		DELETE FROM #EXISTINGCOLUMNS
		SELECT DISTINCT @Iterator_Column = COUNT(*) FROM #COLUMNS
		WHILE(@Iterator_Column > 0)
		BEGIN
			SELECT @Iterator_Column = @Iterator_Column - 1;
			SELECT DISTINCT @ColumnsToProcess = ColumnName  FROM #COLUMNS ORDER BY ColumnName DESC OFFSET @Iterator_Column ROWS FETCH NEXT 1 ROWS ONLY;
			
			SELECT @Query = ' SELECT @Result = COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
													WHERE CONCAT(TABLE_SCHEMA,''.'',TABLE_NAME) = ''' + CAST(@NumTable AS NVARCHAR(2000)) + ''' AND COLUMN_NAME = ''' + @ColumnsToProcess + '''; ' 
			EXEC sp_executesql @Query, N'@Result INT OUT', @IsColumnExistsInNum OUT  
			
			SELECT @Query = ' SELECT @Result = COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
													WHERE CONCAT(TABLE_SCHEMA,''.'',TABLE_NAME) = ''' + CAST(@TxtTable AS NVARCHAR(2000)) + ''' AND COLUMN_NAME = ''' + @ColumnsToProcess + '''; ' 
			EXEC sp_executesql @Query, N'@Result INT OUT', @IsColumnExistsInTxt OUT
			
			INSERT INTO #EXISTINGCOLUMNS VALUES (@ColumnsToProcess, @IsColumnExistsInTxt, @IsColumnExistsInNum )  
		END

		IF (SELECT COUNT(*) FROM #EXISTINGCOLUMNS WHERE IsColumnExistsInTxt > 0 AND IsColumnExistsInNum = 0) > 0
		BEGIN
			SELECT @Query = CONCAT(' ALTER TABLE ' ,@NumTable, ' ADD ');
			WHILE(@Iterator_Column > 0)
			BEGIN
				SELECT @Iterator_Column = @Iterator_Column - 1;
				
				SELECT DISTINCT @ColumnsToProcess = ColumnName  FROM #EXISTINGCOLUMNS 
				WHERE IsColumnExistsInTxt > 0 AND IsColumnExistsInNum = 0
				ORDER BY ColumnName DESC OFFSET @Iterator_Column ROWS FETCH NEXT 1 ROWS ONLY;	 
				 
				SELECT @Query += CONCAT(@ColumnsToProcess , ' DATETIME2 NULL ', CASE WHEN @Iterator_Column = 0 THEN ';' ELSE ',' END)
			END

			EXECUTE sp_executesql @Query;
		END
	END

	GO
	
	DECLARE @ColumnsToProcess  VARCHAR(500) = '' 
	DECLARE @Query NVARCHAR(MAX) = ''
	DECLARE @TxtTable VARCHAR(MAX) = ''
	DECLARE @NumTable VARCHAR(MAX) = ''
	DECLARE @IsImportTable INT = 0
	DECLARE @IsColumnExistsInNum INT = 0
	DECLARE @IsColumnExistsInTxt INT = 0
	DECLARE @Iterator INT = 0
	DECLARE @Iterator_Column INT = 0
	
	SELECT DISTINCT @Iterator = COUNT(*) from #TXTTABLES;
	WHILE (@Iterator > 0)  
	BEGIN  
		SELECT @Iterator = @Iterator - 1;
		SELECT DISTINCT @TxtTable = txtName  FROM #TXTTABLES ORDER BY txtName DESC OFFSET @Iterator ROWS FETCH NEXT 1 ROWS ONLY;
		SELECT @NumTable = REPLACE(@TxtTable,'TXT','NUM');
		
		-- Determine whether table is IMPORT or PROJECT
			SELECT @Query = ' SELECT @Result = COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
												 WHERE CONCAT(TABLE_SCHEMA,''.'',TABLE_NAME) = ''' + CAST(@NumTable AS NVARCHAR(2000)) + ''' AND COLUMN_NAME = ''sys_imports''; ' 
			EXEC sp_executesql @Query, N'@Result INT OUT', @IsImportTable OUT
        
		DELETE FROM #EXISTINGCOLUMNS
		SELECT DISTINCT @Iterator_Column = COUNT(*) FROM #COLUMNS
		WHILE(@Iterator_Column > 0)
		BEGIN
			SELECT @Iterator_Column = @Iterator_Column - 1;
			SELECT DISTINCT @ColumnsToProcess = ColumnName  FROM #COLUMNS ORDER BY ColumnName DESC OFFSET @Iterator_Column ROWS FETCH NEXT 1 ROWS ONLY;
			
			SELECT @Query = ' SELECT @Result = COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS  
													WHERE CONCAT(TABLE_SCHEMA,''.'',TABLE_NAME) = ''' + CAST(@NumTable AS NVARCHAR(2000)) + ''' AND COLUMN_NAME = ''' + @ColumnsToProcess + '''; ' 
			EXEC sp_executesql @Query, N'@Result INT OUT', @IsColumnExistsInNum OUT  
			
			SELECT @Query = ' SELECT @Result = COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS  
			                                        WHERE CONCAT(TABLE_SCHEMA,''.'',TABLE_NAME) = ''' + CAST(@TxtTable AS NVARCHAR(2000)) + ''' AND COLUMN_NAME = ''' + @ColumnsToProcess + '''; ' 
			EXEC sp_executesql @Query, N'@Result INT OUT', @IsColumnExistsInTxt OUT
			
			INSERT INTO #EXISTINGCOLUMNS VALUES (@ColumnsToProcess, @IsColumnExistsInTxt, @IsColumnExistsInNum ) 

		END
		
		IF (SELECT COUNT(*) FROM #EXISTINGCOLUMNS WHERE IsColumnExistsInTxt > 0 AND IsColumnExistsInNum > 0) > 0
		BEGIN
			SELECT @Query = CONCAT(' UPDATE N ' ,' SET ');
			WHILE(@Iterator_Column > 0)
			BEGIN
				SELECT @Iterator_Column = @Iterator_Column - 1;
				
				SELECT DISTINCT @ColumnsToProcess = ColumnName  FROM #EXISTINGCOLUMNS 
				WHERE IsColumnExistsInTxt > 0 AND IsColumnExistsInNum = 0
				ORDER BY ColumnName DESC OFFSET @Iterator_Column ROWS FETCH NEXT 1 ROWS ONLY;	 
				 
				SELECT @Query += CONCAT('N.', @ColumnsToProcess , ' = CASE WHEN IIF(TRY_CONVERT(DATETIME,T.' , 
				@ColumnsToProcess + ') IS NULL,0,1) = 0 THEN NULL ELSE T.' , @ColumnsToProcess , ' END ',
				CASE WHEN @Iterator_Column = 0 THEN '' ELSE ',' END)
			END

			EXECUTE sp_executesql @Query;
		END

		IF @IsImportTable >= 1
		BEGIN
			SELECT @Query = CONCAT(@Query, ' FROM ', @NumTable , ' N JOIN ', @TxtTable, ' T ON N.sys_imports = T.sys_imports; ')
		END
		ELSE
		BEGIN
			SELECT @Query = CONCAT(@Query, ' FROM ', @NumTable, ' N JOIN ', @TxtTable, ' T ON N.sys_respondentId = T.sys_respondentId; ')
		END

		EXEC(@Query);
		
		IF (SELECT COUNT(*) FROM #EXISTINGCOLUMNS WHERE IsColumnExistsInTxt > 0 AND IsColumnExistsInNum > 0) > 0
		BEGIN
			SELECT @Query = CONCAT(' ALTER TABLE ' , @TxtTable,' DROP COLUMN ') 
			WHILE(@Iterator_Column > 0)
				BEGIN
					SELECT @Iterator_Column = @Iterator_Column - 1;
					
					SELECT DISTINCT @ColumnsToProcess = ColumnName  FROM #EXISTINGCOLUMNS 
					WHERE IsColumnExistsInTxt > 0 
					ORDER BY ColumnName DESC OFFSET @Iterator_Column ROWS FETCH NEXT 1 ROWS ONLY;	 
					
					SELECT @Query += CONCAT(@ColumnsToProcess , CASE WHEN @Iterator_Column = 0 THEN '' ELSE ',' END)

					END 
			EXECUTE sp_executesql @Query;
		END
	END
	GO 

	DELETE FROM #TXTTABLES
	DROP TABLE #TXTTABLES
	DROP TABLE #VARTABLES
	DROP TABLE #COLUMNS
	DROP TABLE #EXISTINGCOLUMNS
	
IF @@TRANCOUNT > 0
BEGIN
    COMMIT
END
ELSE
BEGIN
	ROLLBACK
END
