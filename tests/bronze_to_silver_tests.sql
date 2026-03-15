--- The bronze table tests
--- This script is designed to validate the data in the bronze layer 
--- after it has been loaded from the source files. It checks for data integrity issues such as 
--- duplicates, white spaces in string columns, bad dates, and verifies calculated columns. 
--- It also checks for null values in critical fields before being loaded to the silver layer.

------------------------------ Checking for duplicates----------------------------------------------

--- Customer Table
SELECT customer_id,COUNT(*) AS count_ FROM bronze.customers GROUP BY customer_id HAVING COUNT(*) > 1

--- Products Tables 
SELECT product_id,COUNT(*) AS count_ FROM bronze.products GROUP BY product_id HAVING COUNT(*) > 1

--- Orders Table
SELECT order_id,COUNT(*) FROM bronze.orders GROUP BY order_id HAVING COUNT(*) > 1

--- Returns table
SELECT return_id,COUNT(*) FROM bronze.returns GROUP BY return_id HAVING COUNT(*) > 1

--- Order Items Table
SELECT order_item_id, COUNT(*) FROM bronze.order_items  GROUP BY order_item_id HAVING COUNT(*) > 1

----------------------------------------------------------------------------------------------------------

------------------------------ CHECKING FOR WHITE SPACES IN STRING COLUMNS -----------------------------------------

--- Customer Table
SELECT * FROM bronze.customers WHERE acquisition_channel != TRIM(acquisition_channel)
SELECT * FROM bronze.customers WHERE preferred_device != TRIM(preferred_device)
SELECT * FROM bronze.customers WHERE loyalty_tier != TRIM(loyalty_tier)
SELECT * FROM bronze.customers WHERE country != TRIM(country)
SELECT * FROM bronze.customers WHERE state_code != TRIM(state_code)
SELECT * FROM bronze.customers WHERE state != TRIM(state)
SELECT * FROM bronze.customers WHERE city != TRIM(city)
SELECT * FROM bronze.customers WHERE region != TRIM(region)
--- Products Table
SELECT * FROM bronze.products WHERE product_name != TRIM(product_name)
SELECT * FROM bronze.products WHERE category != TRIM(category)
SELECT * FROM bronze.products WHERE subcategory != TRIM(subcategory)   

--- Marketing Spend Table
SELECT * FROM bronze.marketing_spend WHERE channel != TRIM(channel)

--- Orders Table
SELECT * FROM bronze.orders WHERE order_status != TRIM(order_status)
SELECT * FROM bronze.orders WHERE payment_method != TRIM(payment_method)
SELECT * FROM bronze.orders WHERE state != TRIM(state)
SELECT * FROM bronze.orders WHERE city != TRIM(city)
SELECT * FROM bronze.orders WHERE region != TRIM(region)
SELECT * FROM bronze.orders WHERE customer_id != TRIM(customer_id)
SELECT * FROM bronze.orders WHERE order_id != TRIM(order_id)
SELECT * FROM bronze.orders WHERE order_status != TRIM(order_status)
SELECT * FROM bronze.orders WHERE payment_method != TRIM(payment_method)

---returns Table
SELECT * FROM bronze.returns WHERE return_status != TRIM(return_status)
SELECT * FROM bronze.returns WHERE return_reason != TRIM(return_reason)

------------------------------ CHECKING BAD DATES --------------------------------------------------------
SELECT * FROM bronze.orders WHERE order_date > ship_date
SELECT * FROM bronze.orders WHERE order_date IS NULL
SELECT * FROM bronze.orders WHERE delivery_date < ship_date;
SELECT 
SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS ship_nulls,
SUM(CASE WHEN delivery_date IS NULL THEN 1 ELSE 0 END) AS delivery_nulls
FROM bronze.orders;
SELECT * FROM bronze.orders WHERE order_status = 'Delivered' AND delivery_date IS NULL;



------------------------------- VERIFY CALCULATED COLUMNS ------------------------------------------------
SELECT * FROM bronze.order_items WHERE line_total != line_subtotal - item_discount_amount;
SELECT * FROM bronze.order_items WHERE line_gross_profit != line_total - line_cogs;
SELECT * FROM bronze.orders WHERE order_net_sales != order_gross_sales - item_discount_amount - coupon_discount_amount;
SELECT * FROM bronze.orders WHERE order_total != order_net_sales + shipping_fee + tax_amount;
SELECT * FROM bronze.orders WHERE order_gross_profit != order_net_sales - order_cogs;


------------------------------- CHECKING FOR NULL ---------------------------------------------------------

SELECT * FROM bronze.order_items WHERE TRY_CAST(unit_price AS DECIMAL(18,2)) IS NULL
AND unit_price IS NOT NULL;

SELECT * FROM bronze.order_items WHERE TRY_CAST(quantity AS INT) IS NULL
AND quantity IS NOT NULL;
SELECT * FROM bronze.order_items WHERE TRY_CAST(line_total AS DECIMAL(18,2)) IS NULL
AND line_total IS NOT NULL;
SELECT * FROM bronze.order_items WHERE TRY_CAST(line_subtotal AS DECIMAL(18,2)) IS NULL
AND line_subtotal IS NOT NULL;
SELECT * FROM bronze.order_items WHERE TRY_CAST(item_discount_amount AS DECIMAL(18,2)) IS NULL
AND item_discount_amount IS NOT NULL;
SELECT * FROM bronze.order_items WHERE TRY_CAST(line_cogs AS DECIMAL(18,2)) IS NULL
AND line_cogs IS NOT NULL;
SELECT * FROM bronze.order_items WHERE TRY_CAST(line_gross_profit AS DECIMAL(18,2)) IS NULL
AND line_gross_profit IS NOT NULL;
SELECT * FROM bronze.order_items WHERE TRY_CAST(unit_cost AS DECIMAL(18,2)) IS NULL
AND unit_cost IS NOT NULL;  
SELECT * FROM bronze.orders WHERE TRY_CAST(order_gross_sales AS DECIMAL(18,2)) IS NULL
AND order_gross_sales IS NOT NULL;
SELECT * FROM bronze.orders WHERE TRY_CAST(order_net_sales AS DECIMAL(18,2)) IS NULL
AND order_net_sales IS NOT NULL;
SELECT * FROM bronze.orders WHERE TRY_CAST(shipping_fee AS DECIMAL(18,2)) IS NULL
AND shipping_fee IS NOT NULL;
SELECT * FROM bronze.orders WHERE TRY_CAST(tax_amount AS DECIMAL(18,2)) IS NULL
AND tax_amount IS NOT NULL;
SELECT * FROM bronze.orders WHERE TRY_CAST(order_total AS DECIMAL(18,2)) IS NULL
AND order_total IS NOT NULL;
SELECT * FROM bronze.orders WHERE TRY_CAST(order_cogs AS DECIMAL(18,2)) IS NULL
AND order_cogs IS NOT NULL;
SELECT * FROM bronze.orders WHERE TRY_CAST(order_gross_profit AS DECIMAL(18,2)) IS NULL
AND order_gross_profit IS NOT NULL;
SELECT * FROM bronze.returns WHERE TRY_CAST(refund_amount AS DECIMAL(18,2)) IS NULL
AND refund_amount IS NOT NULL;  
SELECT * FROM bronze.returns WHERE TRY_CAST(return_date AS DATE) IS NULL
AND return_date IS NOT NULL;    


SELECT * FROM bronze.returns WHERE return_id IS NULL
SELECT * FROM bronze.customers WHERE customer_id IS NULL
SELECT * FROM bronze.orders WHERE order_id IS NULL
SELECT * FROM bronze.order_items WHERE order_item_id IS NULL
SELECT * FROM bronze.products WHERE product_id IS NULL
SELECT * FROM bronze.marketing_spend WHERE channel IS NULL
SELECT * FROM bronze.marketing_spend WHERE month IS NULL

------------------------------- CHECKING FOR NEGATIVE VALUES ---------------------------------------------------------

--- From observations all prices and quantities are positives
SELECT * FROM bronze.order_items WHERE TRY_CAST(unit_price AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.order_items WHERE TRY_CAST(quantity AS INT) < 0
SELECT * FROM bronze.order_items WHERE TRY_CAST(line_total AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.order_items WHERE TRY_CAST(line_subtotal AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.order_items WHERE TRY_CAST(item_discount_amount AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.order_items WHERE TRY_CAST(line_cogs AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.order_items WHERE TRY_CAST(line_gross_profit AS DECIMAL(18 ,2)) < 0
SELECT * FROM bronze.order_items WHERE TRY_CAST(unit_cost AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.orders WHERE TRY_CAST(order_gross_sales AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.orders WHERE TRY_CAST(order_net_sales AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.orders WHERE TRY_CAST(shipping_fee AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.orders WHERE TRY_CAST(tax_amount AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.orders WHERE TRY_CAST(order_total AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.orders WHERE TRY_CAST(order_cogs AS DECIMAL(18,2)) < 0
SELECT * FROM bronze.orders WHERE TRY_CAST(order_gross_profit AS DECIMAL(18,2)) < 0 
SELECT * FROM bronze.returns WHERE TRY_CAST(refund_amount AS DECIMAL(18,2)) < 0 


  


--- Checking for data Integrity
SELECT * FROM silver.returns
SELECT * FROM silver.customers
SELECT * FROM silver.orders
SELECT * FROM silver.marketing_spend
SELECT * FROM silver.order_items
SELECT * FROM silver.products