--- Creating views in the gold layer implementing and completing the STAR schema
--- This script creates the following views in the gold layer:
--- 1. fact_order_items 

--- Fact order_items View
CREATE OR ALTER VIEW gold.fact_order_items AS

SELECT 
oi.order_item_id,
oi.order_id,
oi.product_id,
oi.customer_id,
oi.order_date,
oi.quantity,
oi.unit_price,
oi.unit_cost,
oi.item_discount_amount AS discount_amount,
oi.line_subtotal AS gross_sales,
oi.line_total AS net_sales,
oi.line_cogs,
oi.line_gross_profit
FROM silver.order_items AS oi
LEFT JOIN silver.orders AS o 
ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered' AND o.order_id IS NOT NULL;



--- factOrders view 
-- This view aggregates order-level information and includes a flag for valid orders and first-time orders.
CREATE OR ALTER VIEW gold.fact_orders AS

SELECT 
order_id,
order_date,
ship_date,
delivery_date,
customer_id,
sales_channel,
payment_method,
shipping_type,
coupon_code,
order_status,
CASE 
    WHEN order_status IN ('Cancelled','Failed') THEN 0
    ELSE 1 END AS valid_order_flag,
is_first_order As first_order_flag,
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
FROM silver.orders
WHERE order_id IS NOT NULL;


--- factReturns View
-- This view captures return-level information and includes only valid returns (where return_id is not null).
CREATE OR ALTER VIEW gold.fact_returns AS

SELECT 
return_id,
order_item_id,
order_id,
return_date,
return_qty,
refund_amount,
return_reason,
return_status
FROM silver.returns
WHERE return_id IS NOT NULL;


--- factMarketing_spend View
--- This view captures marketing spend information and includes only valid records (where month and channel are not null).
CREATE OR ALTER VIEW gold.fact_marketing_spend AS

SELECT 
month,
channel,
spend,
impressions,
clicks,
sessions,
attributed_orders,
attributed_revenue
FROM silver.marketing_spend
WHERE month IS NOT NULL AND channel IS NOT NULL;

--- DimCustomers View
-- This view captures customer-level information and includes only valid customers (where customer_id is not null).
CREATE OR ALTER VIEW gold.dim_customers AS 
SELECT 
customer_id,
signup_date,
acquisition_channel,
preferred_device,
loyalty_tier,
country,
state,
city,
region
FROM silver.customers
WHERE customer_id IS NOT NULL;


--- DimProducts View
-- This view captures product-level information and includes only valid products (where product_id is not null).
CREATE OR ALTER VIEW gold.dim_products AS
SELECT
product_id,
product_name,
category,
subcategory,
brand,
list_price,
unit_cost,
launch_date,
is_active,
avg_rating,
expected_return_rate,
margin_pct
FROM silver.products
WHERE product_id IS NOT NULL;