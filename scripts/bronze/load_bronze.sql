USE [DataWarehouse]
GO
/****** Object:  StoredProcedure [bronze].[load_bronze]    Script Date: 19/07/2026 11:39:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [bronze].[load_bronze] AS
BEGIN
DECLARE @time_start DATETIME, @end_time DATETIME, @batch_time_start DATETIME, @batch_time_end DATETIME;
	BEGIN TRY
	    SET @batch_time_start = GETDATE();
		PRINT '====================================================';
		PRINT 'Loading bronze layer';
		PRINT '====================================================';

		PRINT '----------------------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '----------------------------------------------------';

		PRINT '<< Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
	
		PRINT '<< Loading data into Table: bronze.crm_cust_info';
		SET @time_start = GETDATE();
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\datasets\crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';

		PRINT '<< Truncating Table: bronze.crm_prd_info';	
		TRUNCATE TABLE bronze.crm_prd_info;
	
		PRINT '<< Loading data into Table: bronze.crm_prd_info';
		SET @time_start = GETDATE();
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\datasets\crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';

		PRINT '<< Truncating Table: bronze.crm_sales_details';	
		TRUNCATE TABLE bronze.crm_sales_details;
	
		PRINT '<< Loading data into Table: bronze.crm_sales_details';
		SET @time_start = GETDATE();
		BULK INSERT  bronze.crm_sales_details
		FROM 'D:\datasets\crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';

		PRINT '----------------------------------------------------';
		PRINT 'Loading ERP tables';
		PRINT '----------------------------------------------------';
		
		PRINT '<< Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
	
		PRINT '<< Loading data into Table: bronze.erp_cust_az12';
		SET @time_start = GETDATE();
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\datasets\erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';
		PRINT '<< Truncating Table: bronze.erp_loc_a101'; 
 		TRUNCATE TABLE bronze.erp_loc_a101;
	
		PRINT '<< Loading data into Table: bronze.erp_loc_a101';
		SET @time_start = GETDATE();
		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\datasets\erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';

		PRINT '<< Truncating Table: bronze.erp_px_cat_g1v2'; 	
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	
		PRINT '<< Loading data into Table: bronze.erp_px_cat_g1v2';
		SET @time_start = GETDATE();
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\datasets\erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		
		SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		SET @batch_time_end = GETDATE();
		PRINT '=========================================================';
		PRINT 'Loading bronze layer is done';
		PRINT '   - Total load duration: ' + CAST(DATEDIFF(second,@batch_time_start,@batch_time_end) AS VARCHAR) + ' seconds';
	    PRINT '========================================================='
	END TRY
		BEGIN CATCH
		PRINT '================================================================';
		PRINT 'ERROR HAS OCCURRED' + ERROR_MESSAGE();
		PRINT '================================================================';
		END CATCH
END
