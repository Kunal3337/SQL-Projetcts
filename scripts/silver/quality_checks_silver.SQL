/*

Quality Check

Script Purpose:
This script performs various quality checks for data consistency, accuracy, and standardization across the 'silver' schema. It includes checks for:
- Null or duplicate primary keys.
- Unwanted spaces in string fields.
- Data standardization and consistency.
- Invalid date ranges and orders
- Data consistency between related fields

Usage notes:
 - Run these checks after data loading silver layer.
 - Investigate and resolve any discrepancies found during the checks 
 
 */

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL 
   DROP TABLE silver.crm_cust_info 
CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50) ,
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date Date,
);

alter table silver.crm_cust_info 
add dwh_create_date DATETIME2 DEFAULT GETDATE()

UPDATE silver.crm_cust_info
SET dwh_create_date = GETDATE()
WHERE dwh_create_date IS NULL;

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
   DROP TABLE silver.crm_prd_info 
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME,
);

ALTER TABLE silver.crm_prd_info 
add dwh_create_date DATETIME2 DEFAULT GETDATE()

update silver.crm_prd_info 
set dwh_create_date = GETDATE()
where dwh_create_date is null

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
   DROP TABLE silver.crm_sales_details 
CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
) ;

ALTER TABLE silver.crm_sales_details
ADD dwh_create_date DATETIME2 DEFAULT GETDATE()

update silver.crm_sales_details
set dwh_create_date = GETDATE()
where dwh_create_date is null


IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
   DROP TABLE silver.erp_cust_az12
CREATE TABLE silver.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate date,
    gen NVARCHAR(50),
);

Alter table silver.erp_cust_az12
add dwh_create_date DATETIME2 DEFAULT getdate()

update silver.erp_cust_az12
set dwh_create_date = GETDATE()
where dwh_create_date is null 


IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
   DROP TABLE silver.erp_loc_a101
CREATE TABLE  silver.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
);

Alter table silver.erp_loc_a101
add dwh_create_date DATETIME2 DEFAULT getdate()

update silver.erp_loc_a101
set dwh_create_date = getdate()
where dwh_create_date is null


IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
   DROP TABLE silver.erp_px_cat_g1v2
CREATE TABLE silver.erp_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50),
);

Alter table silver.erp_px_cat_g1v2
add dwh_create_date DATETIME2 DEFAULT getdate()

update silver.erp_px_cat_g1v2
set dwh_create_date = getdate()
where dwh_create_date is null

  

 ================================================================================================================================================================================================================================

  DATE CLEANING 
  
 -- Check for Nulls or Duplicates in Primary Key
 -- Expectation: No Result

select cst_id, count(*) from silver.crm_cust_info group by cst_id having count(*) > 1 or cst_id is null

select * from (select *, ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_test
FROM silver.crm_cust_info where cst_id is not null)t where flag_test = 1


-- Check for unwanted spaces in string values and case statement
-- Expectation: No Result

select cst_lastname
from silver.crm_cust_info
where cst_lastname != TRIM(cst_lastname)    -- We have to keep changing the each char column whether there is space or not

-- Data Normalization & Standardization
select DISTINCT cst_marital_status
from silver.crm_cust_info

INSERT INTO silver.crm_cust_info (cst_id,
    cst_key,
    cst_firstname ,
    cst_lastname ,
    cst_marital_status,
    cst_gndr,
    cst_create_date )

select
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
case when upper(trim(cst_marital_status)) = 'S' then 'Single'
     when upper(trim(cst_marital_status)) = 'M' then 'Married' Else 'n/a'
     END cst_marital_status,
case when upper(trim(cst_gndr)) = 'M' then 'Male'
     when upper(trim(cst_gndr)) = 'F' then 'Female' Else 'n/a'
     END cst_gndr,
cst_create_date
from ( select *, ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_test
FROM bronze.crm_cust_info where cst_id is not null)t where flag_test = 1


-- ====================================================================================================================

INSERT INTO silver.crm_prd_info(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,    
SUBSTRING(PRD_KEY,7,LEN(PRD_KEY)) AS prd_key,
prd_nm,
ISNULL(prd_cost, 0) AS prd_cost,                      
CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain' 
     wHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'     
     wHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
     wHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
     ELSE 'n/a'
     END as prd_line,
CAST(prd_start_dt as DATE) as prd_start_dt,
CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) AS prd_end_dt
from bronze.crm_prd_info 

Alter table silver.crm_prd_info
add dwh_create_date DATETIME2 default getdate()

Update silver.crm_prd_info
set dwh_create_date = GETDATE()
where dwh_create_date is null

-- Check for Nulls or duplicates in primary key
-- Expectation: No Result
select prd_id as prd, count(*) from silver.crm_prd_info
group by prd_id having count(*) > 1 or prd_id is null

-- Check for unwanted spaces

select prd_nm from silver.crm_prd_info where prd_nm != TRIM(prd_nm)

--  Check for NULLs or Negative Numbers 

select prd_cost from silver.crm_prd_info where prd_cost < 0 or prd_cost is null

-- Data Standardization & Consistency

SELECT DISTINCT prd_line from silver.crm_prd_info  

-- Check for Invalid Date Orders
SELECT * 
FROM silver.crm_prd_info  WHERE prd_end_dt < prd_start_dt

select * from silver.crm_prd_info
--   ============================================================================================================
select * from silver.crm_sales_details

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
CASE WHEN sls_order_dt < = 0 OR LEN(sls_order_dt) !=8 THEN NULL
     ELSE CAST(CAST(sls_order_dt as varchar) as date)
     END AS sls_order_dt,
CASE WHEN sls_ship_dt < = 0 OR LEN(sls_ship_dt) !=8 THEN NULL
     ELSE CAST(CAST(sls_ship_dt as varchar) as date)
     END AS sls_ship_dt,
CASE WHEN sls_due_dt < = 0 OR LEN(sls_due_dt) !=8 THEN NULL
     ELSE CAST(CAST(sls_due_dt as varchar) as date)
     END AS sls_due_dt,
CASE WHEN sls_sales is null OR sls_sales <= 0 OR sls_sales != sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
ELSE sls_sales
END as sls_sales, 
sls_quantity,  
CASE WHEN sls_price IS NULL OR sls_price <=0   
THEN sls_sales/ NULLIF(sls_quantity,0)
ELSE sls_price
END as sls_price
FROM bronze.crm_sales_details

-- Check for Invalid Dates
SELECT 
NULLIF(sls_order_dt,0) sls_due_dt
from silver.crm_sales_details
WHERE sls_order_dt <= 0
OR len(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

-- Check for valid date orders
select * from silver.crm_sales_details where sls_order_dt > sls_ship_dt or sls_order_dt>sls_due_dt

-- Check Data Consistency : Between Sales, Quantity and price
-- >> Sales = Quantity * Price
-- >> values must not be NULL, or Negative

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_price*sls_quantity
OR sls_sales IS NULL 
OR sls_quantity IS NULL 
OR sls_price IS NULL 
OR sls_sales <= 0
OR sls_quantity <= 0
OR sls_quantity <= 0
ORDER BY sls_sales,sls_price,sls_quantity


--===================================silver.erp_cust_az12===========================================================================
INSERT INTO silver.erp_cust_az12(
    cid,
    bdate,
    gen
)

SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,

    CASE
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,

    CASE
        WHEN cleaned_gen IN ('M', 'MALE') THEN 'Male'
        WHEN cleaned_gen IN ('F', 'FEMALE') THEN 'Female'
        WHEN cleaned_gen = '' OR cleaned_gen IS NULL THEN 'n/a'
        ELSE cleaned_gen
    END AS gen
FROM (
    SELECT
        cid,bdate,UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''),CHAR(10), ''))) AS cleaned_gen
    FROM bronze.erp_cust_az12
) t;
select distinct gen from silver.erp_cust_az12
select * from silver.erp_cust_az12


--================================================silver.erp_loc_a101=====================================================================================

select * from silver.erp_loc_a101 

INSERT INTO silver.erp_loc_a101(
    cid,
    cntry
)

SELECT
    replace(cid,'-','') as cid,
    CASE
        WHEN cleaned_cntry = 'DE' THEN 'Germany'
        WHEN cleaned_cntry IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
        WHEN cleaned_cntry = '' OR cleaned_cntry IS NULL THEN 'n/a'
        ELSE cleaned_cntry
    END AS cntry
FROM (
    SELECT
        cid, UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) AS cleaned_cntry
    FROM bronze.erp_loc_a101
) t;

select cntry from silver.erp_loc_a101 where cntry = 'n/a'

--===========================================silver.erp_px_cat_g1v2=========================================================================

INSERT INTO silver.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    maintenance
)

select id,
cat,
subcat,
 REPLACE(
        REPLACE(maintenance, CHAR(13), ''),
        CHAR(10), ''
    ) AS maintenance
from bronze.erp_px_cat_g1v2

select * from silver.erp_px_cat_g1v2
