Here is the text extracted from the image:

```
/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- ===============================================================================
-- Create Dimension: gold.dim_customers
-- ===============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
```



create view gold.dim_customers As
select 
	ROW_NUMBER() over (order by cst_id) as customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
		la.cntry AS country,
	ci.cst_material_status AS maritial_status ,
	case when ci.cst_gndr != 'n/a' then ci.cst_gndr
	else coalesce(ca.gen,'n/a')
end as gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date


from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key =ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key=la.cid


-- ===============================================================================
-- Create Dimension: gold.dim_products
-- ===============================================================================


create view gold.dim_products as
select row_number() over (order by pn.prd_start_dt, pn.prd_key) as product_key,
 pn.[prd_id] AS product_id,
        pn.[prd_key] as product_number,
        pn.[prd_nm] as product_name,
      pn. [cat_id] as category_id , 
      pc.cat as category ,
      pc.subcat as subcategory,
       pc.maintenance,
      pn.[prd_cost] as cost
      ,pn.[prd_line] as product_line
      ,pn.[prd_start_dt] as start_date
  FROM [DataWareHouse].[silver].[crm_prd_info] pn
  left join silver.erp_px_cat_g1v2 pc
  on pn.cat_id=pc.id
  where prd_end_dt is null 



-- ===============================================================================
-- Create Dimension: gold.dim_sales
-- ===============================================================================



create view gold.fact_sales AS

SELECT sd.[sls_ord_num] AS order_number,
        pr.product_key,
        cu.customer_key
    
     
      ,sd.[sls_order_dt] As order_date
      ,sd.[sls_ship_dt] As shipping_date
      ,sd.[sls_due_dt] As due_date
      ,sd.[sls_sales] As sales_amount
      ,sd.[sls_quantity] As quantity
      ,sd.[sls_price] As price
     
  FROM [DataWareHouse].[silver].[crm_sales_details] sd
  left join gold.dim_products pr
  on sd.sls_prd_key = pr.product_number
  left join gold.dim_customers cu
  on sd.sls_cust_id= cu.customer_id

