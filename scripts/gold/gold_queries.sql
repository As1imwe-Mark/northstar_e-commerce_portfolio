--- Gold Layer Queries - Answering Portfolio Questions
--- These queries use the gold layer views to answer the business questions

USE Northstar_portfolio;
GO

--- =====================================================
--- Q1 (Beginner): What are total orders, net sales, gross profit, and unique customers by month?
--- =====================================================
SELECT
    year_month,
    total_orders,
    CONCAT('$', FORMAT(net_sales, 'N0')) AS net_sales,
    CONCAT('$', FORMAT(gross_profit, 'N0')) AS gross_profit,
    unique_customers
FROM gold.monthly_kpis
ORDER BY year_month;

--- =====================================================
--- Q2 (Beginner): Which categories and subcategories drive the most net sales and gross profit?
--- =====================================================
SELECT
    category,
    subcategory,
    CONCAT('$', FORMAT(net_sales, 'N0')) AS net_sales,
    CONCAT('$', FORMAT(gross_profit, 'N0')) AS gross_profit,
    orders_count,
    FORMAT(return_rate, 'P1') AS return_rate
FROM gold.category_performance
ORDER BY net_sales DESC;

--- =====================================================
--- Q3 (Beginner): What is average order value (AOV) by sales channel and shipping type?
--- =====================================================
SELECT
    sales_channel,
    shipping_type,
    CONCAT('$', FORMAT(avg_order_value, 'N2')) AS avg_order_value,
    total_orders,
    CONCAT('$', FORMAT(net_sales, 'N0')) AS total_net_sales
FROM gold.sales_channel_analysis
ORDER BY sales_channel, shipping_type;

--- =====================================================
--- Q4 (Beginner): What share of orders use coupons, and how does coupon usage affect AOV and gross profit?
--- =====================================================
SELECT
    'Overall' AS metric,
    CAST(SUM(orders_with_coupons) AS FLOAT) / SUM(total_orders) AS coupon_usage_rate,
    AVG(CASE WHEN orders_with_coupons > 0 THEN avg_order_value END) AS avg_order_with_coupon,
    AVG(CASE WHEN orders_with_coupons = 0 THEN avg_order_value END) AS avg_order_without_coupon
FROM gold.sales_channel_analysis;

--- =====================================================
--- Q5 (Beginner): Which states or regions generate the most sales?
--- =====================================================
SELECT TOP 10
    region,
    state,
    CONCAT('$', FORMAT(net_sales, 'N0')) AS net_sales,
    total_orders,
    unique_customers
FROM gold.regional_sales
ORDER BY net_sales DESC;

--- =====================================================
--- Q6 (Intermediate): What is the cancellation rate by month, sales channel, and payment method?
--- =====================================================
SELECT
    year_month,
    FORMAT(cancellation_rate, 'P2') AS cancellation_rate,
    cancelled_orders,
    total_orders
FROM gold.monthly_kpis
ORDER BY year_month;

SELECT
    sales_channel,
    payment_method,
    FORMAT(cancellation_rate, 'P2') AS cancellation_rate,
    cancelled_orders,
    total_orders
FROM gold.sales_channel_analysis
ORDER BY sales_channel, payment_method;

--- =====================================================
--- Q7 (Intermediate): Which products have high revenue but low gross margin?
--- =====================================================
SELECT TOP 20
    product_name,
    category,
    subcategory,
    CONCAT('$', FORMAT(total_revenue, 'N0')) AS total_revenue,
    FORMAT(gross_margin_pct, 'P1') AS gross_margin_pct,
    total_units_sold,
    FORMAT(return_rate, 'P1') AS return_rate
FROM gold.product_performance
WHERE total_revenue > 10000  -- Focus on products with significant revenue
ORDER BY total_revenue DESC, gross_margin_pct ASC;

--- =====================================================
--- Q8 (Intermediate): What are repeat purchase rates and average days between orders?
--- =====================================================
SELECT
    repeat_purchase_rate,
    FORMAT(repeat_purchase_rate, 'P1') AS repeat_purchase_rate_formatted,
    avg_days_between_orders,
    min_days_between_orders,
    max_days_between_orders,
    repeat_customers,
    total_customers
FROM gold.repeat_purchase_analysis;

--- =====================================================
--- Q9 (Intermediate): Which acquisition channels bring the highest-value customers over time?
--- =====================================================
SELECT
    acquisition_channel,
    total_customers,
    active_customers,
    CONCAT('$', FORMAT(avg_customer_lifetime_value, 'N0')) AS avg_clv,
    CONCAT('$', FORMAT(lifetime_value, 'N0')) AS total_lifetime_value,
    FORMAT(repeat_customer_rate, 'P1') AS repeat_customer_rate,
    avg_orders_per_customer
FROM gold.acquisition_performance
ORDER BY avg_customer_lifetime_value DESC;

--- =====================================================
--- Q10 (Intermediate): How do first-time buyers behave differently from repeat customers in AOV, discount usage, and return rate?
--- =====================================================
SELECT
    customer_type,
    total_orders,
    unique_customers,
    CONCAT('$', FORMAT(avg_order_value, 'N2')) AS avg_order_value,
    FORMAT(coupon_usage_rate, 'P1') AS coupon_usage_rate,
    FORMAT(refund_rate, 'P2') AS refund_rate,
    CONCAT('$', FORMAT(total_net_sales, 'N0')) AS total_net_sales
FROM gold.first_time_vs_repeat
ORDER BY customer_type;

--- =====================================================
--- Q11 (Intermediate): What is the return rate by category, product, and shipping type?
--- =====================================================
-- By Category
SELECT
    category,
    SUM(return_count) AS total_returns,
    SUM(total_returned_qty) AS total_returned_units,
    FORMAT(AVG(return_rate_by_orders), 'P2') AS avg_return_rate
FROM gold.returns_analysis
GROUP BY category
ORDER BY avg_return_rate DESC;

-- By Shipping Type (from shipping analysis)
SELECT
    shipping_type,
    total_orders,
    orders_with_returns,
    FORMAT(return_rate, 'P2') AS return_rate
FROM gold.shipping_analysis
ORDER BY return_rate DESC;

--- =====================================================
--- Q12 (Intermediate): Which return reasons are most common, and what revenue is lost to refunds?
--- =====================================================
SELECT
    return_reason,
    COUNT(*) AS return_count,
    CONCAT('$', FORMAT(SUM(total_refund_amount), 'N0')) AS total_refund_amount,
    FORMAT(SUM(total_refund_amount) / (SELECT SUM(total_refunds) FROM gold.returns_analysis) * 100, 'N1') + '%' AS pct_of_total_refunds
FROM gold.returns_analysis
GROUP BY return_reason
ORDER BY total_refund_amount DESC;

--- =====================================================
--- Q13 (Intermediate): How does discounting affect gross profit by category and channel?
--- =====================================================
SELECT
    category,
    sales_channel,
    total_orders,
    CONCAT('$', FORMAT(total_discounts, 'N0')) AS total_discounts,
    FORMAT(discount_rate_pct, 'P1') AS discount_rate,
    CONCAT('$', FORMAT(gross_profit, 'N0')) AS gross_profit,
    FORMAT(profit_margin_pct, 'P1') AS profit_margin
FROM gold.discount_impact
ORDER BY discount_rate DESC;

--- =====================================================
--- Q14 (Intermediate): Are faster shipping options associated with higher conversion, higher AOV, or higher return rates?
--- =====================================================
SELECT
    shipping_type,
    total_orders,
    CONCAT('$', FORMAT(avg_order_value, 'N2')) AS avg_order_value,
    FORMAT(return_rate, 'P2') AS return_rate,
    CONCAT('$', FORMAT(avg_shipping_fee, 'N2')) AS avg_shipping_fee,
    avg_delivery_days
FROM gold.shipping_analysis
ORDER BY avg_delivery_days;

--- =====================================================
--- Q15 (Advanced): Build monthly customer cohorts based on first order month and measure retention over the next 6 months.
--- =====================================================
SELECT
    cohort_period,
    months_since_first,
    customers,
    cohort_size,
    FORMAT(retention_rate, 'P1') AS retention_rate,
    CONCAT('$', FORMAT(revenue, 'N0')) AS revenue,
    CONCAT('$', FORMAT(avg_order_value, 'N2')) AS avg_order_value
FROM gold.customer_cohorts
WHERE months_since_first <= 6
ORDER BY cohort_period, months_since_first;

--- =====================================================
--- Q16 (Advanced): Estimate net sales after refunds by month and compare gross vs net margin.
--- =====================================================
SELECT
    year_month,
    CONCAT('$', FORMAT(gross_sales, 'N0')) AS gross_sales,
    CONCAT('$', FORMAT(total_refunds, 'N0')) AS total_refunds,
    CONCAT('$', FORMAT(net_sales_after_refunds, 'N0')) AS net_sales_after_refunds,
    FORMAT(gross_margin_pct, 'P1') AS gross_margin_pct,
    FORMAT(net_margin_pct, 'P1') AS net_margin_pct,
    CONCAT('$', FORMAT(net_profit_after_refunds, 'N0')) AS net_profit_after_refunds
FROM gold.net_sales_after_refunds
ORDER BY year_month;

--- =====================================================
--- Q17 (Advanced): Which channels are most efficient when comparing attributed revenue to marketing spend (ROAS) and attributed orders to spend (CAC proxy)?
--- =====================================================
SELECT
    channel,
    CONCAT('$', FORMAT(SUM(spend), 'N0')) AS total_spend,
    SUM(attributed_orders) AS attributed_orders,
    CONCAT('$', FORMAT(SUM(attributed_revenue), 'N0')) AS attributed_revenue,
    FORMAT(AVG(roas), 'N2') AS avg_roas,
    CONCAT('$', FORMAT(AVG(cac_proxy), 'N2')) AS avg_cac_proxy,
    FORMAT(AVG(ctr), 'P2') AS avg_ctr,
    FORMAT(AVG(conversion_rate), 'P2') AS avg_conversion_rate
FROM gold.marketing_efficiency
GROUP BY channel
ORDER BY AVG(roas) DESC;

--- =====================================================
--- Q18 (Advanced): Identify products or subcategories that should be promoted, repriced, or discontinued based on sales, margin, and return behavior.
--- =====================================================
-- Products to promote (high sales, good margin, low returns)
SELECT TOP 10
    'Promote' AS recommendation,
    product_name,
    category,
    subcategory,
    CONCAT('$', FORMAT(total_revenue, 'N0')) AS revenue,
    FORMAT(gross_margin_pct, 'P1') AS margin,
    FORMAT(return_rate, 'P1') AS return_rate,
    total_units_sold
FROM gold.product_performance
WHERE gross_margin_pct > 0.3 AND return_rate < 0.1 AND total_revenue > 5000
ORDER BY total_revenue DESC;

-- Products to reprice (high returns, low margin)
SELECT TOP 10
    'Reprice' AS recommendation,
    product_name,
    category,
    subcategory,
    CONCAT('$', FORMAT(total_revenue, 'N0')) AS revenue,
    FORMAT(gross_margin_pct, 'P1') AS margin,
    FORMAT(return_rate, 'P1') AS return_rate
FROM gold.product_performance
WHERE return_rate > 0.15 OR gross_margin_pct < 0.1
ORDER BY return_rate DESC;

-- Products to discontinue (low sales, high returns, low margin)
SELECT TOP 10
    'Discontinue' AS recommendation,
    product_name,
    category,
    subcategory,
    CONCAT('$', FORMAT(total_revenue, 'N0')) AS revenue,
    FORMAT(gross_margin_pct, 'P1') AS margin,
    FORMAT(return_rate, 'P1') AS return_rate,
    total_units_sold
FROM gold.product_performance
WHERE total_revenue < 1000 OR (return_rate > 0.2 AND gross_margin_pct < 0.15)
ORDER BY total_revenue ASC;

--- =====================================================
--- Q19 (Advanced): Create an executive dashboard that explains why revenue can grow while profit does not.
--- =====================================================
-- Key metrics showing revenue vs profit trends
SELECT
    year_month,
    total_orders,
    CONCAT('$', FORMAT(net_sales, 'N0')) AS net_sales,
    CONCAT('$', FORMAT(gross_profit, 'N0')) AS gross_profit,
    FORMAT(gross_profit / NULLIF(net_sales, 0), 'P1') AS profit_margin,
    unique_customers,
    FORMAT(cancellation_rate, 'P1') AS cancellation_rate
FROM gold.monthly_kpis
ORDER BY year_month;

-- Discount impact over time
SELECT
    year_month,
    CONCAT('$', FORMAT(total_discounts, 'N0')) AS total_discounts,
    FORMAT(discount_rate_pct, 'P1') AS discount_rate,
    CONCAT('$', FORMAT(gross_profit, 'N0')) AS gross_profit,
    FORMAT(profit_margin_pct, 'P1') AS profit_margin
FROM gold.monthly_discounts
ORDER BY year_month;

-- Return impact
SELECT
    year_month,
    CONCAT('$', FORMAT(total_refunds, 'N0')) AS total_refunds,
    FORMAT(total_refunds / gross_sales, 'P1') AS refund_rate
FROM gold.net_sales_after_refunds
ORDER BY year_month;

--- =====================================================
--- Q20 (Advanced): Write 3 concrete business recommendations to improve profitability without hurting growth too much.
--- =====================================================
-- Based on the analysis above, here are the recommendations:

-- Recommendation 1: Optimize discounting strategy
-- Analysis shows discount rates are impacting margins
SELECT
    FORMAT(AVG(discount_rate_pct), 'P1') AS avg_discount_rate,
    FORMAT(AVG(profit_margin_pct), 'P1') AS avg_profit_margin
FROM gold.discount_impact;

-- Recommendation 2: Improve product assortment
-- Focus on high-margin, low-return products
SELECT TOP 5
    category,
    subcategory,
    FORMAT(AVG(gross_margin_pct), 'P1') AS avg_margin,
    FORMAT(AVG(return_rate), 'P1') AS avg_return_rate
FROM gold.category_performance
GROUP BY category, subcategory
ORDER BY AVG(gross_margin_pct) DESC, AVG(return_rate) ASC;

-- Recommendation 3: Enhance customer retention
-- Repeat customers show better profitability
SELECT
    customer_type,
    FORMAT(avg_order_value, 'C') AS avg_order_value,
    FORMAT(coupon_usage_rate, 'P1') AS coupon_usage,
    FORMAT(refund_rate, 'P1') AS refund_rate
FROM gold.first_time_vs_repeat
WHERE customer_type = 'Repeat';

GO