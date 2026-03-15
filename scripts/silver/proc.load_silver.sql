--- Insert Data into Silver Layer tables
--- This stored procedure performs the transformation step of the Medallion Architecture
--- It cleans, standardizes and loads data from the Bronze layer into the Silver layer

CREATE OR ALTER PROCEDURE load_silver_layer AS 
BEGIN

BEGIN TRY

--- =========================================================
--- CUSTOMERS TABLE
--- =========================================================
--- Remove existing records to allow a fresh reload of clean data
TRUNCATE TABLE silver.customers;

--- Insert cleaned customer records
--- The customers table in the silver layer includes transformations to ensure data types are correct and text fields are standardized, which is essential for accurate analysis and reporting.
INSERT INTO silver.customers(
customer_id,
signup_date,
acquisition_channel,
preferred_device,
loyalty_tier,
country,
state_code,
state,
city,
region
)

SELECT
customer_id,
TRY_CAST(signup_date AS DATE),
TRIM(acquisition_channel),
TRIM(preferred_device),
TRIM(loyalty_tier),
TRIM(country),
TRIM(state_code),
TRIM(state),
TRIM(city),
TRIM(region)

FROM
(
--- Deduplicate customers by selecting the first record per customer_id
SELECT *,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY signup_date) AS rn
FROM bronze.customers
) t

WHERE rn = 1
AND customer_id IS NOT NULL;


--- =========================================================
--- MARKETING SPEND TABLE
--- =========================================================

--- Remove old data
TRUNCATE TABLE silver.marketing_spend;

--- Insert cleaned marketing data
--- The marketing_spend table includes transformations to ensure data types are correct and text fields are standardized, which is essential for accurate analysis and reporting.
INSERT INTO silver.marketing_spend
(
month,
channel,
spend,
impressions,
clicks,
sessions,
attributed_orders,
attributed_revenue
)

SELECT
TRY_CAST(month AS DATE),
TRIM(channel),
TRY_CAST(spend AS DECIMAL(18,2)),
TRY_CAST(impressions AS INT),
TRY_CAST(clicks AS INT),
TRY_CAST(sessions AS INT),
TRY_CAST(attributed_orders AS INT),
TRY_CAST(attributed_revenue AS DECIMAL(18,2))

FROM bronze.marketing_spend
WHERE TRY_CAST(month AS DATE) IS NOT NULL;


--- =========================================================
--- ORDER ITEMS TABLE
--- =========================================================

--- Remove existing records before reload
TRUNCATE TABLE silver.order_items;

--- Insert cleaned order item records
--- The order_items table includes transformations to ensure data types are correct and text fields are standardized, which is crucial for accurate analysis and reporting.
INSERT INTO silver.order_items
(
order_item_id,
order_id,
order_date,
customer_id,
product_id,
category,
subcategory,
quantity,
unit_price,
line_subtotal,
item_discount_amount,
line_total,
unit_cost,
line_cogs,
line_gross_profit
)

SELECT
order_item_id,
order_id,
TRY_CAST(order_date AS DATE),
customer_id,
product_id,
TRIM(category),
TRIM(subcategory),
TRY_CAST(quantity AS INT),
TRY_CAST(unit_price AS DECIMAL(18,2)),
TRY_CAST(line_subtotal AS DECIMAL(18,2)),
TRY_CAST(item_discount_amount AS DECIMAL(18,2)),
TRY_CAST(line_total AS DECIMAL(18,2)),
TRY_CAST(unit_cost AS DECIMAL(18,2)),
TRY_CAST(line_cogs AS DECIMAL(18,2)),
TRY_CAST(line_gross_profit AS DECIMAL(18,2))
FROM bronze.order_items
WHERE order_item_id IS NOT NULL
AND order_id IS NOT NULL;



--- =========================================================
--- ORDERS TABLE
--- =========================================================

--- Remove old order data
TRUNCATE TABLE silver.orders;

--- Insert cleaned orders
--- The orders table includes transformations to ensure data types are correct and text fields are standardized, which is essential for accurate analysis and reporting.
INSERT INTO silver.orders
(
order_id,
order_date,
ship_date,
delivery_date,
customer_id,
region,
state,
city,
sales_channel,
payment_method,
shipping_type,
coupon_code,
order_status,
is_first_order,
customer_order_number,
order_gross_sales,
item_discount_amount,
coupon_discount_amount,
order_net_sales,
shipping_fee,
tax_amount,
order_total,
order_cogs,
order_gross_profit
)

SELECT
order_id,
TRY_CAST(order_date AS DATE),
TRY_CAST(ship_date AS DATE),
TRY_CAST(delivery_date AS DATE),
customer_id,
TRIM(region),
TRIM(state),
TRIM(city),
TRIM(sales_channel),
TRIM(payment_method),
TRIM(shipping_type),
CASE 
WHEN UPPER(TRIM(coupon_code)) IS NULL OR UPPER(TRIM(coupon_code)) = '' 
THEN 'n/a'
ELSE TRIM(coupon_code)
END AS coupon_code ,
TRIM(order_status),
TRIM(is_first_order),
TRY_CAST(customer_order_number AS INT),
TRY_CAST(order_gross_sales AS DECIMAL(18,2)),
TRY_CAST(item_discount_amount AS DECIMAL(18,2)),
TRY_CAST(coupon_discount_amount AS DECIMAL(18,2)),
TRY_CAST(order_net_sales AS DECIMAL(18,2)),
TRY_CAST(shipping_fee AS DECIMAL(18,2)),
TRY_CAST(tax_amount AS DECIMAL(18,2)),
TRY_CAST(order_total AS DECIMAL(18,2)),
TRY_CAST(order_cogs AS DECIMAL(18,2)),
TRY_CAST(order_gross_profit AS DECIMAL(18,2))
FROM bronze.orders
WHERE order_id IS NOT NULL;


--- =========================================================
--- PRODUCTS TABLE
--- =========================================================

--- Insert cleaned product records
--- The products table includes transformations to ensure data types are correct and text fields are standardized, which is crucial for accurate analysis and reporting.
INSERT INTO silver.products
(
product_id,
product_name,
category,
subcategory,
brand,
list_price,
unit_cost,
avg_rating,
launch_date,
expected_return_rate,
is_active,
margin_pct
)

SELECT
product_id,
TRIM(product_name),
TRIM(category),
TRIM(subcategory),
TRIM(brand),
TRY_CAST(list_price AS DECIMAL(18,2)),
TRY_CAST(unit_cost AS DECIMAL(18,2)),
TRY_CAST(avg_rating AS DECIMAL(18,2)),
TRY_CAST(launch_date AS DATE),
TRY_CAST(expected_return_rate AS DECIMAL(18,2)),
TRIM(is_active),
TRY_CAST(margin_pct AS DECIMAL(18,2))
FROM bronze.products
WHERE product_id IS NOT NULL;



--- =========================================================
--- RETURNS TABLE
--- =========================================================

--- Insert cleaned return records
--- The returns table includes transformations to ensure data types are correct and text fields are standardized, which is important for data lineage and auditing purposes.
INSERT INTO silver.returns
(
return_id,
order_item_id,
order_id,
return_date,
return_qty,
return_reason,
refund_amount,
return_status
)

SELECT
return_id,
order_item_id,
order_id,
TRY_CAST(return_date AS DATE),
TRY_CAST(return_qty AS INT),
TRIM(return_reason),
TRY_CAST(refund_amount AS DECIMAL(18,2)),
TRIM(return_status)
FROM bronze.returns
WHERE return_id IS NOT NULL;



END TRY

--- =========================================================
--- ERROR HANDLING
--- =========================================================
BEGIN CATCH

PRINT'-----------------------------------------------------------------------------------------'
PRINT'A problem occurred when loading the tables in the silver layer'
PRINT'Error Message'+ ERROR_MESSAGE()
PRINT'Error Message'+ CAST(ERROR_NUMBER() AS NVARCHAR)

PRINT'------------------------------------------------------------------------------------------'

END CATCH;

END;

--- Checking Data integrity
--- After loading the data, you can run SELECT statements to verify that the data has been loaded correctly and is ready for analysis.
SELECT * FROM silver.returns
SELECT * FROM silver.customers
SELECT * FROM silver.orders
SELECT * FROM silver.marketing_spend
SELECT * FROM silver.order_items
SELECT * FROM silver.products
