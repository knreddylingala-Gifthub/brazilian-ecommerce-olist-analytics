-- =============================================================================
-- FILE: sql/01_schema_and_problems.sql
-- PROJECT: Brazilian E-Commerce Analytics (Olist)
-- PURPOSE: Create relational tables and address raw data quality issues.
-- =============================================================================

-- 1. Create Fact Table: Orders
CREATE TABLE fact_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 2. Create Dimension Table: Customers
CREATE TABLE dim_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(50),
    customer_state VARCHAR(5)
);

-- 3. Create Dimension Table: Products (Translated)
CREATE TABLE dim_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name_english VARCHAR(100),
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- =============================================================================
-- SOLUTION FOR ISSUE #1: Identify Delayed Deliveries (Business Requirement)
-- =============================================================================
SELECT 
    order_id,
    customer_id,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
        ELSE 0 
    END AS is_delayed
FROM fact_orders
WHERE order_status = 'delivered';
