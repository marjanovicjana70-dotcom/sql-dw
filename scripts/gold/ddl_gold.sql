
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS -- Dodato 'AS' koje je nedostajalo
SELECT         
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    cst_id AS customer_id, 
    cst_key AS customer_number, 
    cst_firstname AS first_name, 
    cst_lastname AS last_name, 
    cntry AS country, 
    cst_material_status AS marital_status, 
    (CASE 
        WHEN TRIM(gen) != TRIM(cst_gndr) AND cst_gndr != 'Unknown' THEN cst_gndr 
        WHEN gen IS NULL THEN 'Unknown' 
        ELSE gen 
     END) AS gender, 
    bdate AS birthdate, 
    cst_create_date AS create_date
FROM silver.crm_cust_info c1 
LEFT JOIN silver.erp_cust_az12 c2 ON c1.cst_key = c2.cid 
LEFT JOIN silver.erp_loc_a101 c3 ON c3.cid = c1.cst_key;
GO


IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY prd_id) AS product_key,
    prd_id AS product_id,
    prd_key AS product_number,
    prd_name AS product_name,
    prd_cost AS product_cost,
    (CASE WHEN prd_line IS NULL THEN 'Unknown' ELSE prd_line END) AS product_line, 
    (CASE WHEN cat IS NULL THEN 'Unknown' ELSE cat END) AS product_category, 
    (CASE WHEN subcat IS NULL THEN 'Unknown' ELSE subcat END) AS product_subcategory,
    (CASE WHEN maintance IS NULL THEN 'Unknown' ELSE maintance END) AS product_maintance,
    prd_start_dt AS product_start_date,
    prd_end_dt AS product_end_date
FROM silver.crm_prd_info p1 
LEFT JOIN silver.erp_px_cat_g1v2 p2 ON SUBSTRING(p1.prd_key, 1, 5) = REPLACE(p2.id, '_', '-');
GO


IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    s.sls_ord_num AS order_number,
    g.product_number as product_key,
    c.customer_id as customer_key, -- Ispravljeno: uzima se surogatni ključ iz dimenzije
    s.sls_order_dt AS order_date,
    s.sls_ship_dt AS shipping_date,
    s.sls_due_dt AS due_date,
    s.sls_sales AS sales,
    s.sls_quantity AS quantity,
    s.sls_price AS price
FROM silver.crm_sales_details s
LEFT JOIN gold.dim_products g ON g.product_number = s.sls_prd_key
LEFT JOIN gold.dim_customers c ON s.sls_cust_id = c.customer_id;
GO
