/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- Data Quality Check: Table bronze.crm_cust_info

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL;



-- Check for unwanted Spaces
-- Expectations: No Results
SELECT 
cst_firstname,
cst_lastname
FROM bronze.crm_cust_info
WHERE LEN(cst_firstname) != LEN(TRIM(cst_firstname))

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info


-- Data Quality Check: Table silver.crm_prd_info

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL;



-- Check for unwanted Spaces
-- Expectations: No Results
SELECT 
prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLS or Negative Numbers
-- Expectations: No Results

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL


-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check for Invalid Date Orders 
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_date < prd_start_date

SELECT *
FROM silver.crm_prd_info

-- ==================================================
-- Data & Check for crm_sales_details
-- ==================================================

SELECT 
NULLIF(sls_order_dt, 0) sls_order_dt 
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101 
OR sls_order_dt < 19000101

-- Check for Invalid Dates
-- Order dates shouldn't be later than shipping dates and due dates

SELECT
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Sales = Quantity * Price

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price




-- identify out-of-range dates

SELECT DISTINCT

bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1926-01-01' OR bdate > GETDATE()

SELECT DISTINCT 
gen
FROM bronze.erp_cust_az12

--=================================================
SELECT cst_key FROM silver.crm_cust_info;

-- Check the possibility of the join
SELECT
REPLACE(cid, '-', '') cid,
cntry
FROM bronze.erp_loc_a101 WHERE REPLACE(cid, '-', '') NOT IN
(SELECT cst_key FROM silver.crm_cust_info)

-- Data Standardization & Consistency

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

SELECT
cid, 
REPLACE(cid, '-', '') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101;

SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;

SELECT *
FROM silver.crm_prd_info;

-- check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency

SELECT DISTINCT 
subcat 
FROM bronze.erp_px_cat_g1v2
