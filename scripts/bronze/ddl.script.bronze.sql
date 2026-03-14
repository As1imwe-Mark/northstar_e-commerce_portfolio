--- Creating tables in the bronze layer

--- Customer Table
DROP TABLE IF EXISTS bronze.customers;
GO

CREATE TABLE bronze.customers (
customer_id NVARCHAR(50),
signup_date DATE,
acquisition_channel NVARCHAR(50),
preferred_device NVARCHAR(50),
loyalty_tier NVARCHAR(50),
country NVARCHAR(50),
state_code NVARCHAR(50),
state NVARCHAR(50),
city NVARCHAR(50),
region NVARCHAR(50)
);

--- Marketing Spend
DROP TABLE IF EXISTS bronze.marketing_spend;
GO

CREATE TABLE bronze.marketing_spend (
month DATE,
channel NVARCHAR(50),
spend DECIMAL(18,2),
impressions INT,
clicks INT,
sessions INT,
attributed_orders INT,
attributed_revenue DECIMAL(18,2)
);

--- Order Items Table
DROP TABLE IF EXISTS bronze.order_items;
GO

CREATE TABLE bronze.order_items (
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
);

--- Orders Table
DROP TABLE IF EXISTS bronze.orders;
GO

CREATE TABLE bronze.orders (
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
    order_gross_profit DECIMAL(18,2)
);

--- Products Table
DROP TABLE IF EXISTS bronze.products;
GO

CREATE TABLE bronze.products (
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
margin_pct DECIMAL(18,2)
);

--- Returns Table
DROP TABLE IF EXISTS bronze.returns;
GO

CREATE TABLE bronze.returns (
return_id NVARCHAR(50),
order_item_id NVARCHAR(50),
order_id NVARCHAR(50),
return_date DATE,
return_qty INT,
return_reason NVARCHAR(50),
refund_amount DECIMAL(18,2),
return_status NVARCHAR(50)
);