use ecommerce_analysis;
SHOW TABLES;
SELECT *
FROM olist_orders_dataset
LIMIT 10;
-- Query 1 — Total orders and order status
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;
-- Query 2 — Total sales and freight
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price), 2) AS total_sales,
    ROUND(SUM(freight_value), 2) AS total_freight
FROM olist_order_items_dataset;

-- Query 3 — Monthly sales trend
SELECT
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS sales_month,
    ROUND(SUM(i.price), 2) AS monthly_sales
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
    ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY sales_month
ORDER BY sales_month;

-- Top 10 product categories
SELECT
    COALESCE(
        p.product_category_name,
        'Unknown'
    ) AS category,
    ROUND(SUM(i.price), 2) AS category_sales
FROM olist_order_items_dataset i
JOIN olist_products_dataset p
    ON i.product_id = p.product_id
GROUP BY category
ORDER BY category_sales DESC
LIMIT 10;

-- Query 5 — Top 10 states by sales
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(i.price), 2) AS total_sales
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset i
    ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_sales DESC
LIMIT 10;

-- Query 6 — Average order value
SELECT
    ROUND(
        SUM(order_sales) / COUNT(*),
        2
    ) AS average_order_value
FROM (
    SELECT
        o.order_id,
        SUM(i.price) AS order_sales
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset i
        ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
) AS order_summary;

-- Query 7 — Payment method analysis
SELECT
    payment_type,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_payment_value DESC;

-- Query 8 — High-value orders using HAVING
SELECT
    order_id,
    ROUND(SUM(price), 2) AS order_value
FROM olist_order_items_dataset
GROUP BY order_id
HAVING SUM(price) > 500
ORDER BY order_value DESC;

-- Query 9 — Customer order frequency
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
FROM olist_customers_dataset c
JOIN olist_orders_dataset o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY order_count DESC;

-- Query 10 — Products with above-average sales
SELECT
    product_id,
    ROUND(SUM(price), 2) AS product_sales
FROM olist_order_items_dataset
GROUP BY product_id
HAVING SUM(price) > (
    SELECT AVG(product_total)
    FROM (
        SELECT SUM(price) AS product_total
        FROM olist_order_items_dataset
        GROUP BY product_id
    ) AS product_summary
)
ORDER BY product_sales DESC
LIMIT 20;

