SELECT
    o.*,
    order_purchase_timestamp,
    DATE(order_purchase_timestamp) AS date_id
FROM olist.orders o
LIMIT 1000;

SELECT *
FROM olist.orders
LIMIT 1000;

-------
-- GROUP BYs + agg functions
-------

-- number of orders in the month 2018-01

-- first, get the number of orders
SELECT
    COUNT(order_id),
    COUNT(*),
    SUM(1),
    COUNT(1)
FROM olist.orders;

-- what is SELECT 1 doing?
SELECT
    1,
    olist.orders.*
FROM olist.orders;

-- now filter for 2018-01
SELECT
    COUNT(1) AS orders
FROM olist.orders
WHERE
    DATE(order_purchase_timestamp) >= '2018-01-01'
    AND DATE(order_purchase_timestamp) < '2018-02-01';

-- total revenue
SELECT
    CAST(SUM(price) AS UNSIGNED) AS total_revenue
FROM olist.order_items;

-- how well is each item selling?
SELECT
    product_id,
    price
FROM olist.order_items
ORDER BY product_id
LIMIT 1000;

SELECT
    product_id,
    CAST(SUM(price) AS UNSIGNED)    AS revenue,
    COUNT(1)                        AS items_sold,
    CAST(SUM(price) AS UNSIGNED) /
        COUNT(1)                    AS avg_price,
    AVG(price)                      AS avg_price_from_fct
FROM olist.order_items
GROUP BY product_id;

-- What are the best-selling items? Show Top 10

SELECT
    product_id,
    COUNT(1)                        AS items_sold
FROM olist.order_items
GROUP BY product_id
ORDER BY items_sold DESC
LIMIT 10;

SELECT
    product_id,
    COUNT(1)    AS items_sold
FROM olist.order_items
GROUP BY product_id
ORDER BY COUNT(1) DESC -- order by can reference aliases defined in the select clause or explicit columns/functions
LIMIT 10;

SELECT
    product_id,
    COUNT(1)    AS items_sold
FROM olist.order_items
GROUP BY product_id
ORDER BY 2 DESC -- order by can reference aliases defined in the select clause or position in the select clause
LIMIT 10;

-- remove items_sold
SELECT
    product_id
FROM olist.order_items
GROUP BY product_id
ORDER BY COUNT(1) DESC
LIMIT 10;

-- how well is each item selling for each seller?
SELECT
    seller_id,
    product_id,
    COUNT(1)    AS items_sold
FROM olist.order_items
GROUP BY
    seller_id,
    product_id;

-- daily orders in 2018-01
SELECT
    DATE(order_purchase_timestamp)  AS date_id,
    COUNT(1)                        AS orders
FROM olist.orders
WHERE
    DATE(order_purchase_timestamp) >= '2018-01-01'
    AND DATE(order_purchase_timestamp) < '2018-02-01'
GROUP BY 1
ORDER BY 1;

-- monthly orders over all time
# SELECT
#     o.*,
#     order_purchase_timestamp,
#     DATE_FORMAT(order_purchase_timestamp, '%Y-%m-01')
# FROM olist.orders o
# LIMIT 1000;


SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m-01')   AS month_id,
    COUNT(1)                                            AS orders
FROM olist.orders
GROUP BY 1
ORDER BY 1;

-- Sidetrack
SELECT 2 = 2;

SELECT *
FROM (SELECT
        5 as col,
        NULL AS col_1) a
    LEFT JOIN (SELECT 1 AS col_2) b
    ON a.col_1 = b.col_2;
-- End of sidetrack

-------
-- GROUP BYs + agg functions
-------

SELECT *
FROM olist.products
LIMIT 1000;

-- how well is each product category selling?

    -- quick validation if product_id is unique in olist.products
SELECT
    COUNT(*),
    COUNT(DISTINCT product_id)
FROM olist.products;

    -- first, do it step by step
        -- join the tables
SELECT
    oi.product_id,
    p.product_category_name
FROM olist.order_items oi
    LEFT JOIN olist.products p
    ON oi.product_id = p.product_id

    -- nest the output from above and wrap into another query

SELECT
    product_category,
    COUNT(*)                AS items_sold
FROM (SELECT
        oi.product_id,
        p.product_category_name AS product_category
    FROM olist.order_items oi
        LEFT JOIN olist.products p
        ON oi.product_id = p.product_id) pc
GROUP BY product_category;

------
-- Let's talk about intermediate tables
------

-- Alternatives to the subquery:
-- 1) Using temporary tables
CREATE TEMPORARY TABLE order_items_product_category
    SELECT
        oi.product_id,
        p.product_category_name AS product_category
    FROM olist.order_items oi
        LEFT JOIN olist.products p
        ON oi.product_id = p.product_id;

SELECT
    product_category,
    COUNT(*)                AS items_sold
FROM order_items_product_category
GROUP BY product_category;

-- 2) Using Common Table Expressions (CTEs)
WITH order_items_product_category AS (
    SELECT
        oi.product_id,
        p.product_category_name AS product_category
    FROM olist.order_items oi
        LEFT JOIN olist.products p
        ON oi.product_id = p.product_id),

filtered_order_items_product_cagegory AS (
    SELECT *
    FROM order_items_product_category
    WHERE product_category != 'cool_stuff')

SELECT
    product_category,
    COUNT(*)                AS items_sold
FROM filtered_order_items_product_cagegory
GROUP BY product_category;

------
-- That's it for subqueries: Use CTEs if possible
------

SELECT
    p.product_category_name AS product_category,
    COUNT(*)                AS items_sold
FROM olist.order_items oi
    LEFT JOIN olist.products p
    ON oi.product_id = p.product_id
GROUP BY 1;

-- What are the top 10 product categories based on items_sold?

SELECT
    p.product_category_name AS product_category
    -- COUNT(*)                AS items_sold
FROM olist.order_items oi
    LEFT JOIN olist.products p
    ON oi.product_id = p.product_id
GROUP BY 1
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Monthly Revenue

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS month_id,
    CAST(SUM(oi.price) AS UNSIGNED)                     AS revenue
FROM olist.order_items oi
    LEFT JOIN olist.orders o
    ON oi.order_id = o.order_id
GROUP BY 1
ORDER BY 1;
