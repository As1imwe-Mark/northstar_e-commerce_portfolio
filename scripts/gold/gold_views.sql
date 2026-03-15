--- Gold Layer Views
--- These views provide analytics-ready data for business intelligence and reporting
--- Built on top of the silver layer with aggregations and calculations for key metrics
USE Northstar_portfolio;
GO --- =====================================================
    --- MONTHLY KPIs VIEW
    --- =====================================================
    CREATE
    OR ALTER VIEW gold.monthly_kpis AS
SELECT YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    FORMAT(o.order_date, 'yyyy-MM') AS year_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_net_sales) AS net_sales,
    SUM(o.order_gross_profit) AS gross_profit,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    AVG(o.order_net_sales) AS avg_order_value,
    SUM(
        CASE
            WHEN o.order_status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,
    CAST(
        SUM(
            CASE
                WHEN o.order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) AS FLOAT
    ) / NULLIF(COUNT(DISTINCT o.order_id), 0) AS cancellation_rate
FROM silver.orders o
WHERE o.order_date IS NOT NULL
GROUP BY YEAR(o.order_date),
    MONTH(o.order_date),
    FORMAT(o.order_date, 'yyyy-MM');
--- =====================================================
--- CATEGORY PERFORMANCE VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.category_performance AS
SELECT p.category,
    p.subcategory,
    SUM(oi.line_total) AS net_sales,
    SUM(oi.line_gross_profit) AS gross_profit,
    COUNT(DISTINCT oi.order_id) AS orders_count,
    COUNT(DISTINCT oi.customer_id) AS customers_count,
    AVG(oi.line_total) AS avg_line_value,
    SUM(oi.quantity) AS total_units_sold,
    SUM(
        CASE
            WHEN r.return_id IS NOT NULL THEN oi.quantity
            ELSE 0
        END
    ) AS returned_units,
    CAST(
        SUM(
            CASE
                WHEN r.return_id IS NOT NULL THEN oi.quantity
                ELSE 0
            END
        ) AS FLOAT
    ) / NULLIF(SUM(oi.quantity), 0) AS return_rate
FROM silver.order_items oi
    JOIN silver.products p ON oi.product_id = p.product_id
    LEFT JOIN silver.returns r ON oi.order_item_id = r.order_item_id
    JOIN silver.orders o ON oi.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY p.category,
    p.subcategory;
--- =====================================================
--- CUSTOMER SUMMARY VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.customer_summary AS
SELECT c.customer_id,
    c.signup_date,
    c.acquisition_channel,
    c.preferred_device,
    c.loyalty_tier,
    c.region,
    c.state,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_net_sales) AS total_net_sales,
    SUM(o.order_gross_profit) AS total_gross_profit,
    AVG(o.order_net_sales) AS avg_order_value,
    DATEDIFF(DAY, MIN(o.order_date), MAX(o.order_date)) AS customer_lifetime_days,
    COUNT(DISTINCT o.order_id) - 1 AS repeat_purchases,
    CASE
        WHEN COUNT(DISTINCT o.order_id) > 1 THEN 1
        ELSE 0
    END AS is_repeat_customer,
    SUM(
        CASE
            WHEN o.coupon_code IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS orders_with_coupons,
    AVG(
        CASE
            WHEN o.coupon_code IS NOT NULL THEN o.order_net_sales
            ELSE NULL
        END
    ) AS avg_order_with_coupon,
    AVG(
        CASE
            WHEN o.coupon_code IS NULL THEN o.order_net_sales
            ELSE NULL
        END
    ) AS avg_order_without_coupon
FROM silver.customers c
    LEFT JOIN silver.orders o ON c.customer_id = o.customer_id
    AND o.order_status != 'Cancelled'
GROUP BY c.customer_id,
    c.signup_date,
    c.acquisition_channel,
    c.preferred_device,
    c.loyalty_tier,
    c.region,
    c.state;
--- =====================================================
--- PRODUCT PERFORMANCE VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.product_performance AS
SELECT p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.brand,
    p.list_price,
    p.unit_cost,
    p.avg_rating,
    SUM(oi.line_total) AS total_revenue,
    SUM(oi.line_gross_profit) AS total_gross_profit,
    SUM(oi.quantity) AS total_units_sold,
    COUNT(DISTINCT oi.order_id) AS orders_count,
    AVG(oi.unit_price) AS avg_selling_price,
    SUM(oi.line_gross_profit) / NULLIF(SUM(oi.line_total), 0) AS gross_margin_pct,
    SUM(
        CASE
            WHEN r.return_id IS NOT NULL THEN oi.quantity
            ELSE 0
        END
    ) AS returned_units,
    CAST(
        SUM(
            CASE
                WHEN r.return_id IS NOT NULL THEN oi.quantity
                ELSE 0
            END
        ) AS FLOAT
    ) / NULLIF(SUM(oi.quantity), 0) AS return_rate,
    SUM(r.refund_amount) AS total_refunds
FROM silver.products p
    LEFT JOIN silver.order_items oi ON p.product_id = oi.product_id
    LEFT JOIN silver.returns r ON oi.order_item_id = r.order_item_id
    LEFT JOIN silver.orders o ON oi.order_id = o.order_id
    AND o.order_status != 'Cancelled'
GROUP BY p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.brand,
    p.list_price,
    p.unit_cost,
    p.avg_rating;
--- =====================================================
--- RETURNS ANALYSIS VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.returns_analysis AS
SELECT r.return_reason,
    p.category,
    p.subcategory,
    p.product_name,
    o.sales_channel,
    o.shipping_type,
    COUNT(r.return_id) AS return_count,
    SUM(r.return_qty) AS total_returned_qty,
    SUM(r.refund_amount) AS total_refund_amount,
    AVG(r.refund_amount) AS avg_refund_amount,
    COUNT(DISTINCT r.order_id) AS orders_with_returns,
    CAST(COUNT(r.return_id) AS FLOAT) / NULLIF(COUNT(DISTINCT oi.order_id), 0) AS return_rate_by_orders
FROM silver.returns r
    JOIN silver.order_items oi ON r.order_item_id = oi.order_item_id
    JOIN silver.products p ON oi.product_id = p.product_id
    JOIN silver.orders o ON r.order_id = o.order_id
GROUP BY r.return_reason,
    p.category,
    p.subcategory,
    p.product_name,
    o.sales_channel,
    o.shipping_type;
--- =====================================================
--- MARKETING EFFICIENCY VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.marketing_efficiency AS
SELECT ms.month,
    ms.channel,
    ms.spend,
    ms.impressions,
    ms.clicks,
    ms.sessions,
    ms.attributed_orders,
    ms.attributed_revenue,
    CAST(ms.attributed_revenue AS FLOAT) / NULLIF(ms.spend, 0) AS roas,
    CAST(ms.spend AS FLOAT) / NULLIF(ms.attributed_orders, 0) AS cac_proxy,
    CAST(ms.clicks AS FLOAT) / NULLIF(ms.impressions, 0) AS ctr,
    CAST(ms.attributed_orders AS FLOAT) / NULLIF(ms.sessions, 0) AS conversion_rate
FROM silver.marketing_spend ms;
--- =====================================================
--- CUSTOMER COHORTS VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.customer_cohorts AS WITH cohort_base AS (
    SELECT c.customer_id,
        YEAR(c.first_order_date) AS cohort_year,
        MONTH(c.first_order_date) AS cohort_month,
        FORMAT(c.first_order_date, 'yyyy-MM') AS cohort_period
    FROM gold.customer_summary c
    WHERE c.first_order_date IS NOT NULL
),
cohort_orders AS (
    SELECT cb.customer_id,
        cb.cohort_year,
        cb.cohort_month,
        cb.cohort_period,
        YEAR(o.order_date) AS order_year,
        MONTH(o.order_date) AS order_month,
        FORMAT(o.order_date, 'yyyy-MM') AS order_period,
        o.order_net_sales,
        ROW_NUMBER() OVER (
            PARTITION BY cb.customer_id
            ORDER BY o.order_date
        ) AS order_sequence
    FROM cohort_base cb
        JOIN silver.orders o ON cb.customer_id = o.customer_id
        AND o.order_status != 'Cancelled'
),
cohort_metrics AS (
    SELECT cohort_period,
        order_period,
        COUNT(DISTINCT customer_id) AS customers,
        SUM(order_net_sales) AS revenue,
        AVG(order_net_sales) AS avg_order_value,
        DATEDIFF(
            MONTH,
            cohort_period + '-01',
            order_period + '-01'
        ) AS months_since_first
    FROM cohort_orders
    GROUP BY cohort_period,
        order_period
),
cohort_sizes AS (
    SELECT cohort_period,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohort_base
    GROUP BY cohort_period
)
SELECT cm.cohort_period,
    cm.order_period,
    cm.months_since_first,
    cm.customers,
    cs.cohort_size,
    CAST(cm.customers AS FLOAT) / cs.cohort_size AS retention_rate,
    cm.revenue,
    cm.avg_order_value
FROM cohort_metrics cm
    JOIN cohort_sizes cs ON cm.cohort_period = cs.cohort_period
WHERE cm.months_since_first BETWEEN 0 AND 6;
--- =====================================================
--- SALES CHANNEL ANALYSIS VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.sales_channel_analysis AS
SELECT o.sales_channel,
    o.shipping_type,
    o.payment_method,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_net_sales) AS net_sales,
    SUM(o.order_gross_profit) AS gross_profit,
    AVG(o.order_net_sales) AS avg_order_value,
    SUM(
        CASE
            WHEN o.coupon_code IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS orders_with_coupons,
    CAST(
        SUM(
            CASE
                WHEN o.coupon_code IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS FLOAT
    ) / COUNT(DISTINCT o.order_id) AS coupon_usage_rate,
    SUM(
        CASE
            WHEN o.order_status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,
    CAST(
        SUM(
            CASE
                WHEN o.order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) AS FLOAT
    ) / COUNT(DISTINCT o.order_id) AS cancellation_rate,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM silver.orders o
WHERE o.order_status != 'Cancelled' -- Exclude cancelled for most metrics, but calculate rate separately
GROUP BY o.sales_channel,
    o.shipping_type,
    o.payment_method;
--- =====================================================
--- REGIONAL SALES VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.regional_sales AS
SELECT o.region,
    o.state,
    o.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_net_sales) AS net_sales,
    SUM(o.order_gross_profit) AS gross_profit,
    AVG(o.order_net_sales) AS avg_order_value,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    SUM(
        CASE
            WHEN o.coupon_code IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS orders_with_coupons
FROM silver.orders o
WHERE o.order_status != 'Cancelled'
GROUP BY o.region,
    o.state,
    o.city;
--- =====================================================
--- NET SALES AFTER REFUNDS VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.net_sales_after_refunds AS
SELECT YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    FORMAT(o.order_date, 'yyyy-MM') AS year_month,
    SUM(o.order_net_sales) AS gross_sales,
    SUM(COALESCE(r.total_refunds, 0)) AS total_refunds,
    SUM(o.order_net_sales) - SUM(COALESCE(r.total_refunds, 0)) AS net_sales_after_refunds,
    SUM(o.order_gross_profit) AS gross_profit,
    SUM(o.order_gross_profit) - SUM(COALESCE(r.total_refunds, 0)) AS net_profit_after_refunds,
    SUM(o.order_cogs) AS total_cogs,
    (
        SUM(o.order_gross_profit) / NULLIF(SUM(o.order_net_sales), 0)
    ) * 100 AS gross_margin_pct,
    (
        (
            SUM(o.order_gross_profit) - SUM(COALESCE(r.total_refunds, 0))
        ) / NULLIF(
            (
                SUM(o.order_net_sales) - SUM(COALESCE(r.total_refunds, 0))
            ),
            0
        )
    ) * 100 AS net_margin_pct
FROM silver.orders o
    LEFT JOIN (
        SELECT order_id,
            SUM(refund_amount) AS total_refunds
        FROM silver.returns
        GROUP BY order_id
    ) r ON o.order_id = r.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY YEAR(o.order_date),
    MONTH(o.order_date),
    FORMAT(o.order_date, 'yyyy-MM');
--- =====================================================
--- ACQUISITION CHANNEL PERFORMANCE VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.acquisition_performance AS
SELECT c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(
        DISTINCT CASE
            WHEN cs.total_orders > 0 THEN c.customer_id
        END
    ) AS active_customers,
    SUM(cs.total_net_sales) AS lifetime_value,
    AVG(cs.total_net_sales) AS avg_customer_lifetime_value,
    AVG(cs.total_orders) AS avg_orders_per_customer,
    SUM(cs.total_gross_profit) AS total_gross_profit,
    AVG(cs.customer_lifetime_days) AS avg_customer_lifetime_days,
    CAST(
        COUNT(
            DISTINCT CASE
                WHEN cs.is_repeat_customer = 1 THEN c.customer_id
            END
        ) AS FLOAT
    ) / COUNT(DISTINCT c.customer_id) AS repeat_customer_rate
FROM silver.customers c
    LEFT JOIN gold.customer_summary cs ON c.customer_id = cs.customer_id
GROUP BY c.acquisition_channel;
--- =====================================================
--- FIRST-TIME VS REPEAT CUSTOMERS VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.first_time_vs_repeat AS
SELECT CASE
        WHEN cs.is_repeat_customer = 1 THEN 'Repeat'
        ELSE 'First-Time'
    END AS customer_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_net_sales) AS total_net_sales,
    AVG(o.order_net_sales) AS avg_order_value,
    SUM(o.order_gross_profit) AS total_gross_profit,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    SUM(
        CASE
            WHEN o.coupon_code IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS orders_with_coupons,
    CAST(
        SUM(
            CASE
                WHEN o.coupon_code IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS FLOAT
    ) / COUNT(DISTINCT o.order_id) AS coupon_usage_rate,
    SUM(COALESCE(r.total_refunds, 0)) AS total_refunds,
    CAST(SUM(COALESCE(r.total_refunds, 0)) AS FLOAT) / NULLIF(SUM(o.order_net_sales), 0) AS refund_rate
FROM gold.customer_summary cs
    JOIN silver.orders o ON cs.customer_id = o.customer_id
    AND o.order_status != 'Cancelled'
    LEFT JOIN (
        SELECT oi.order_id,
            SUM(refund_amount) AS total_refunds
        FROM silver.returns r
            JOIN silver.order_items oi ON r.order_item_id = oi.order_item_id
        GROUP BY oi.order_id
    ) r ON o.order_id = r.order_id
GROUP BY CASE
        WHEN cs.is_repeat_customer = 1 THEN 'Repeat'
        ELSE 'First-Time'
    END;
--- =====================================================
--- REPEAT PURCHASE ANALYSIS VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.repeat_purchase_analysis AS WITH customer_orders AS (
    SELECT customer_id,
        order_date,
        order_net_sales,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS order_number
    FROM silver.orders
    WHERE order_status != 'Cancelled'
),
order_gaps AS (
    SELECT customer_id,
        order_date,
        LEAD(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS next_order_date,
        DATEDIFF(
            DAY,
            order_date,
            LEAD(order_date) OVER (
                PARTITION BY customer_id
                ORDER BY order_date
            )
        ) AS days_between_orders
    FROM customer_orders
)
SELECT COUNT(
        DISTINCT CASE
            WHEN co.order_number > 1 THEN co.customer_id
        END
    ) AS repeat_customers,
    COUNT(DISTINCT co.customer_id) AS total_customers,
    CAST(
        COUNT(
            DISTINCT CASE
                WHEN co.order_number > 1 THEN co.customer_id
            END
        ) AS FLOAT
    ) / COUNT(DISTINCT co.customer_id) AS repeat_purchase_rate,
    AVG(og.days_between_orders) AS avg_days_between_orders,
    MIN(og.days_between_orders) AS min_days_between_orders,
    MAX(og.days_between_orders) AS max_days_between_orders
FROM customer_orders co
    LEFT JOIN order_gaps og ON co.customer_id = og.customer_id
    AND co.order_date = og.order_date;
--- =====================================================
--- SHIPPING ANALYSIS VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.shipping_analysis AS
SELECT o.shipping_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_net_sales) AS total_net_sales,
    AVG(o.order_net_sales) AS avg_order_value,
    SUM(o.shipping_fee) AS total_shipping_fees,
    AVG(o.shipping_fee) AS avg_shipping_fee,
    SUM(
        CASE
            WHEN r.return_id IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS orders_with_returns,
    CAST(
        SUM(
            CASE
                WHEN r.return_id IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS FLOAT
    ) / COUNT(DISTINCT o.order_id) AS return_rate,
    DATEDIFF(DAY, o.order_date, o.delivery_date) AS avg_delivery_days
FROM silver.orders o
    LEFT JOIN silver.returns r ON o.order_id = r.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY o.shipping_type;
--- =====================================================
--- DISCOUNT IMPACT ANALYSIS VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.discount_impact AS
SELECT p.category,
    o.sales_channel,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_gross_sales) AS gross_sales_before_discounts,
    SUM(o.order_net_sales) AS net_sales_after_discounts,
    SUM(o.item_discount_amount) AS total_item_discounts,
    SUM(o.coupon_discount_amount) AS total_coupon_discounts,
    SUM(
        o.item_discount_amount + o.coupon_discount_amount
    ) AS total_discounts,
    SUM(o.order_gross_profit) AS gross_profit,
    (
        SUM(
            o.item_discount_amount + o.coupon_discount_amount
        ) / NULLIF(SUM(o.order_gross_sales), 0)
    ) * 100 AS discount_rate_pct,
    (
        SUM(o.order_gross_profit) / NULLIF(SUM(o.order_net_sales), 0)
    ) * 100 AS profit_margin_pct
FROM silver.orders o
    JOIN silver.order_items oi ON o.order_id = oi.order_id
    JOIN silver.products p ON oi.product_id = p.product_id
WHERE o.order_status != 'Cancelled'
GROUP BY p.category,
    o.sales_channel;
--- =====================================================
--- MONTHLY DISCOUNTS VIEW
--- =====================================================
CREATE
OR ALTER VIEW gold.monthly_discounts AS
SELECT YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    FORMAT(o.order_date, 'yyyy-MM') AS year_month,
    SUM(o.order_gross_sales) AS gross_sales,
    SUM(
        o.item_discount_amount + o.coupon_discount_amount
    ) AS total_discounts,
    (
        SUM(
            o.item_discount_amount + o.coupon_discount_amount
        ) / NULLIF(SUM(o.order_gross_sales), 0)
    ) * 100 AS discount_rate_pct,
    SUM(o.order_gross_profit) AS gross_profit,
    (
        SUM(o.order_gross_profit) / NULLIF(SUM(o.order_net_sales), 0)
    ) * 100 AS profit_margin_pct
FROM silver.orders o
WHERE o.order_status != 'Cancelled'
    AND o.order_date IS NOT NULL
GROUP BY YEAR(o.order_date),
    MONTH(o.order_date),
    FORMAT(o.order_date, 'yyyy-MM');
GO