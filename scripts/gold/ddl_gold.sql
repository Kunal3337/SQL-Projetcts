/*
===============================================================
DDL Script: Create gold views
===============================================================
This script creates views in data warehouse
*/

-- GOLD LAYER
-------------------------------------------gold.dim_customers--------------------------
CREATE VIEW gold.dim_customers AS 
SELECT
ROW_NUMBER() over(order by cst_id asc) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name ,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_marital_status AS marital_status,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr
else COALESCE(ca.gen,'n/a')
end as gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca 
ON     ci.cst_key = ca.cid
left join silver.erp_loc_a101 la 
ON   ci.cst_key = la.cid

----------------------------------------------------------------------------------------------------

SELECT DISTINCT
ci.cst_gndr,
ca.gen,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr
else COALESCE(ca.gen,'n/a')
end as new_gen
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca 
ON     ci.cst_key = ca.cid
left join silver.erp_loc_a101 la 
ON   ci.cst_key = la.cid
order by 1,2

select * from gold.dim_customers

---------------------------------------gold.dim_product-------------------------------------------------------------

CREATE VIEW gold.dim_product AS 
SELECT
Row_number() over(order by pn.prd_start_dt, pn.prd_key) AS product_key,
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id AS category_id,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt
from silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc 
ON pn.cat_id = pc.id
where prd_end_dt is null --- Filter out all historical data whose end_dt is not extracted yet

select * from gold.dim_product

------------------------------------gold.fact_sales----------------------------------------------------------------

CREATE VIEW gold.fact_sales AS
SELECT
sd.sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price price 
FROM silver.crm_sales_details sd 
LEFT JOIN gold.dim_product pr 
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu 
ON sd.sls_cust_id = cu.customer_id

select * from gold.fact_sales






