--- Create silver layer tables 
--- This script defines the schema for the silver layer, which is designed to hold cleaned and transformed data ready for analysis.
--- The silver layer serves as an intermediate step between the raw data in the bronze layer and the curated datasets in the gold layer.


--- Customer Table
--- The customers table in the silver layer includes a load_timestamp column to track when records were loaded, which is useful for data lineage and auditing purposes.
DROP TABLE IF EXISTS silver.customers;
GO

CREATE TABLE silver.customers (
customer_id NVARCHAR(50),
signup_date DATE,
acquisition_channel NVARCHAR(50),
preferred_device NVARCHAR(50),
loyalty_tier NVARCHAR(50),
country NVARCHAR(50),
state_code NVARCHAR(50),
state NVARCHAR(50),
city NVARCHAR(50),
region NVARCHAR(50),
load_timestamp DATETIME DEFAULT GETDATE()
);

--- Marketing Spend
--- The marketing_spend table in the silver layer also includes a load_timestamp column to track data loading times, which is essential for monitoring data freshness and troubleshooting.
DROP TABLE IF EXISTS silver.marketing_spend;
GO

CREATE TABLE silver.marketing_spend (
month DATE,
channel NVARCHAR(50),
spend DECIMAL(18,2),
impressions INT,
clicks INT,
sessions INT,
attributed_orders INT,
attributed_revenue DECIMAL(18,2),
load_timestamp DATETIME DEFAULT GETDATE()
);

--- Order Items Table
--- The order_items table in the silver layer includes a load_timestamp column to track when records were loaded, which is important for data lineage and auditing purposes.
DROP TABLE IF EXISTS silver.order_items;
GO

CREATE TABLE silver.order_items (
    order_item_id NVARCHAR(50),
    order_id NVARCHAR(50),
    order_date DATE,
    customer_id NVARCHAR(50),
    product_id NVARCHAR(50),
    category NVARCHAR(50),
    subcategory NVARCHAR(50),
    quantity INT,
    unit_price DECIMAL(18,2),
    line_subtotal DECIMAL(18,2),
    item_discount_amount DECIMAL(18,2),
    line_total DECIMAL(18,2),
    unit_cost DECIMAL(18,2),
    line_cogs DECIMAL(18,2),
    line_gross_profit DECIMAL(18,2),
    load_timestamp DATETIME DEFAULT GETDATE()
);

--- Orders Table
--- The orders table in the silver layer includes a load_timestamp column to track when records were loaded, which is crucial for data lineage and auditing purposes.
DROP TABLE IF EXISTS silver.orders;
GO

CREATE TABLE silver.orders (
    order_id NVARCHAR(50),
    order_date DATE,
    ship_date DATE,
    delivery_date DATE,
    customer_id NVARCHAR(50),
    region NVARCHAR(50),
    state NVARCHAR(50),
    city NVARCHAR(50),
    sales_channel NVARCHAR(50),
    payment_method NVARCHAR(50),
    shipping_type NVARCHAR(50),      
    coupon_code NVARCHAR(50),        
    order_status NVARCHAR(50),       
    is_first_order NVARCHAR(10),  
    customer_order_number INT,
    order_gross_sales DECIMAL(18,2),
    item_discount_amount DECIMAL(18,2),
    coupon_discount_amount DECIMAL(18,2),
    order_net_sales DECIMAL(18,2),
    shipping_fee DECIMAL(18,2),
    tax_amount DECIMAL(18,2),
    order_total DECIMAL(18,2),
    order_cogs DECIMAL(18,2),
    order_gross_profit DECIMAL(18,2),
    load_timestamp DATETIME DEFAULT GETDATE()
);

--- Products Table
--- The products table in the silver layer includes a load_timestamp column to track when records were loaded, which is essential for data lineage and auditing purposes.
DROP TABLE IF EXISTS silver.products;
GO

CREATE TABLE silver.products (
product_id NVARCHAR(50),
product_name NVARCHAR(50),
category NVARCHAR(50),
subcategory NVARCHAR(50),
brand NVARCHAR(50),
list_price DECIMAL(18,2),
unit_cost DECIMAL(18,2),
avg_rating DECIMAL(18,2),
launch_date DATE,
expected_return_rate DECIMAL(18,2),
is_active NVARCHAR(10),
margin_pct DECIMAL(18,2),
load_timestamp DATETIME DEFAULT GETDATE()
);

--- Returns Table
--- The returns table in the silver layer includes a load_timestamp column to track when records were loaded, which is important for data lineage and auditing purposes.
DROP TABLE IF EXISTS silver.returns;
GO

CREATE TABLE silver.returns (
return_id NVARCHAR(50),
order_item_id NVARCHAR(50),
order_id NVARCHAR(50),
return_date DATE,
return_qty INT,
return_reason NVARCHAR(50),
refund_amount DECIMAL(18,2),
return_status NVARCHAR(50),
load_timestamp DATETIME DEFAULT GETDATE()
);

--- Checking Data integrity
--- After creating the tables, you can run SELECT statements to verify that the tables have been created successfully and are ready for data loading.
SELECT * FROM silver.returns
SELECT * FROM silver.customers
SELECT * FROM silver.orders
SELECT * FROM silver.marketing_spend
SELECT * FROM silver.order_items
SELECT * FROM silver.products
