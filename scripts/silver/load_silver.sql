
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
DECLARE @time_start DATETIME, @end_time DATETIME, @batch_time_start DATETIME, @batch_time_end DATETIME;
	BEGIN TRY
	    SET @batch_time_start = GETDATE();
		PRINT '====================================================';
		PRINT 'Loading silver layer';
		PRINT '====================================================';

		PRINT '----------------------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '----------------------------------------------------';

		PRINT '<< Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info
		PRINT '<< Loading data into Table: silver.crm_cust_info';
		SET @time_start = GETDATE();
    INSERT INTO silver.crm_cust_info
    (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_material_status,
    cst_gndr,
    cst_create_date
    )
    SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) as cst_firstname,
    TRIM(cst_lastname) as cst_lastname,
    (
    CASE
    WHEN TRIM(UPPER(cst_material_status)) = 'S' THEN 'Single'
    WHEN TRIM(UPPER(cst_material_status)) = 'M' THEN 'Married'
    ELSE 'Unknown'
    END ) AS cst_material_status,
    (
    CASE
    WHEN TRIM(UPPER(cst_gndr)) = 'F' THEN 'Female'
    WHEN TRIM(UPPER(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'Unknown'
    END ) AS cst_gndr,
    cst_create_date
    FROM 
    (
    SELECT
    *,
    row_number() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as red
    FROM 
    bronze.crm_cust_info
    ) t 
    WHERE red = 1 
    AND
    cst_id IS NOT NULL
SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';

		PRINT '<< Truncating Table: silver.crm_prd_info';	
		TRUNCATE TABLE silver.crm_prd_info;
	
		PRINT '<< Loading data into Table: silver.crm_prd_info';
		SET @time_start = GETDATE();
    INSERT INTO silver.crm_prd_info
    (
    prd_id,
    cat_id,
    prd_key,
    prd_name,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
    )
    SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
    SUBSTRING(prd_key,7,len(prd_key)) as prd_key,
    prd_name,
    isnull(prd_cost,0) as prd_cost,
    (
    CASE UPPER(TRIM(prd_line))
    WHEN 'M' THEN 'Mountain'
    WHEN 'R' THEN 'Road'
    WHEN 'S' THEN 'Other sales'
    WHEN 'T' THEN 'Touring'
    ELSE 'Unknown'
    END) as prd_line,
    prd_start_dt,
    CAST(DATEADD(day,-1,LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt))AS DATE) as prd_end_dt
    FROM 
    bronze.crm_prd_info
		SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';

		PRINT '<< Truncating Table: silver.crm_sales_details';	
		TRUNCATE TABLE silver.crm_sales_details;
	
		PRINT '<< Loading data into Table: silver.crm_sales_details';
		SET @time_start = GETDATE();
    INSERT INTO silver.crm_sales_details(
       sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    (
    CASE 
    WHEN LEN(sls_order_dt) != 8 OR sls_order_dt = 0  THEN NULL
     ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END) as sls_order_dt,
    (
    CASE 
    WHEN LEN(sls_ship_dt) != 8 OR sls_ship_dt = 0  THEN NULL
     ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END) as sls_ship_dt,
    (
    CASE 
    WHEN LEN(sls_due_dt) != 8 OR sls_due_dt = 0  THEN NULL
     ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END) as sls_due_dt,
    (
    CASE 
    WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
        ELSE  sls_sales
    END) AS sls_sales,
    sls_quantity,
    (
    CASE
    WHEN sls_price IS NULL OR sls_price <=0 
       THEN sls_sales/nullif(sls_quantity,0)
    ELSE sls_price
    END) AS sls_price
    FROM
    bronze.crm_sales_details
	SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';

		PRINT '----------------------------------------------------';
		PRINT 'Loading ERP tables';
		PRINT '----------------------------------------------------';
		
		PRINT '<< Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
	
		PRINT '<< Loading data into Table: silver.erp_cust_az12';
		SET @time_start = GETDATE();
    INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen
    )
    SELECT
    (
    CASE
    WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,len(cid))
        ELSE cid
    END) as cid,
    (CASE
    WHEN bdate>'2010-01-01' THEN NULL
         ELSE bdate
    END) as bdate,
        CASE 
            WHEN upper(gen) = 'F' THEN 'Female'
            WHEN upper(gen) = 'M' THEN 'Male'
            WHEN gen IS NULL OR gen = '' THEN 'Unknown'
            ELSE gen
        END AS gen
    FROM bronze.erp_cust_az12
    
		SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';
		PRINT '<< Truncating Table: silver.erp_loc_a101'; 
 		TRUNCATE TABLE silver.erp_loc_a101;
	
		PRINT '<< Loading data into Table: silver.erp_loc_a101';
		SET @time_start = GETDATE();
    INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
    )
    SELECT
    REPLACE(cid,'-','') as cid,
    (
    CASE
    WHEN TRIM(cntry) IN ('USA','US','United States') THEN 'United States'
    WHEN TRIM(cntry) IN ('DE','Germany') THEN 'Germany'
    WHEN TRIM(cntry) IS NULL OR TRIM(cntry) = '' THEN 'Unknown'
     ELSE TRIM(cntry)
    END) as cntry
    FROM
    bronze.erp_loc_a101
		SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';

		PRINT '<< Truncating Table: silver.erp_px_cat_g1v2'; 	
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
	
		PRINT '<< Loading data into Table: silver.erp_px_cat_g1v2';
		SET @time_start = GETDATE();
    
    INSERT INTO silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintance
    
    )
    SELECT
    *
    FROM
    bronze.erp_px_cat_g1v2
    	SET @end_time = GETDATE();
		PRINT '>> Load Time: ' + CAST(DATEDIFF(second, @time_start, @end_time) AS VARCHAR) + ' seconds';
		SET @batch_time_end = GETDATE();
		PRINT '=========================================================';
		PRINT 'Loading silver layer is done';
		PRINT '   - Total load duration: ' + CAST(DATEDIFF(second,@batch_time_start,@batch_time_end) AS VARCHAR) + ' seconds';
	    PRINT '========================================================='
	END TRY
		BEGIN CATCH
		PRINT '================================================================';
		PRINT 'ERROR HAS OCCURRED' + ERROR_MESSAGE();
		PRINT '================================================================';
		END CATCH
END
