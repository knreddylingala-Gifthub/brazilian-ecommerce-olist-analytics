-- =============================================================================
-- FILE: sql/02_analytical_queries.sql
-- PROJECT: Brazilian E-Commerce Analytics (Olist)
-- PURPOSE: Extract core business KPIs and analytical insights.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Query 1: Monthly Revenue Trend & Month-over-Month (MoM) Growth
-- Evaluates sales trajectory and utilizes Window Functions (LAG).
-- -----------------------------------------------------------------------------
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', o.order_purchase_timestamp) AS sales_month,
        ROUND(SUM(p.payment_value)::numeric, 2) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM fact_orders o
    JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT 
    sales_month,
    total_revenue,
    total_orders,
    LAG(total_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue,
    ROUND(
        ((total_revenue - LAG(total_revenue) OVER (ORDER BY sales_month)) / 
        NULLIF(LAG(total_revenue) OVER (ORDER BY sales_month), 0) * 100)::numeric, 2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY sales_month;


-- -----------------------------------------------------------------------------
-- Query 2: Top 10 High-Revenue Product Categories (English Translation)
-- Ranks categories by total gross revenue.
-- -----------------------------------------------------------------------------
SELECT 
    pr.product_category_name_english AS category_name,
    COUNT(DISTINCT i.order_id) AS items_sold,
    ROUND(SUM(i.price)::numeric, 2) AS total_category_revenue,
    ROUND(AVG(i.price)::numeric, 2) AS avg_item_price
FROM olist_order_items_dataset i
JOIN dim_products pr ON i.product_id = pr.product_id
GROUP BY pr.product_category_name_english
ORDER BY total_category_revenue DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Query 3: Regional Freight Costs & Average Delivery Delay by State
-- Identifies logistics bottlenecks across Brazilian states.
-- -----------------------------------------------------------------------------
SELECT 
    c.customer_state,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(i.freight_value)::numeric, 2) AS avg_freight_cost,
    ROUND(AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)))::numeric, 1) AS avg_actual_delivery_days,
    ROUND(
        (COUNT(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 END)::numeric / 
        COUNT(o.order_id) * 100)::numeric, 2
    ) AS late_delivery_rate_pct
FROM fact_orders o
JOIN dim_customers c ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- -----------------------------------------------------------------------------
-- Query 4: Payment Method Market Share
-- Analyzes payment preferences and total order volume.
-- -----------------------------------------------------------------------------
SELECT 
    payment_type,
    COUNT(DISTINCT order_id) AS total_transactions,
    ROUND(SUM(payment_value)::numeric, 2) AS total_value,
    ROUND((SUM(payment_value) / SUM(SUM(payment_value)) OVER () * 100)::numeric, 2) AS revenue_share_pct
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_value DESC;
