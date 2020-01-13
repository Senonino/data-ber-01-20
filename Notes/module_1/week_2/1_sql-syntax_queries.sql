SELECT 1;

-- I'm a comment

/*
 I'm a comment blocks
 yaaaay
 */


------
-- 1. Selecting columns
------

SELECT *            -- display all columns
FROM olist.orders   -- in table: orders from schema: olist
LIMIT 10;           -- only show the first 10 rows

SELECT -- only select specific columns
    customer_id,
    order_purchase_timestamp
FROM olist.orders
LIMIT 10;

SELECT -- you can select the same column an arbitrary amount of times
    customer_id,
    customer_id,
    customer_id,
    order_purchase_timestamp
FROM olist.orders
LIMIT 10;

SELECT
    CUSTOMER_ID,
    customer_id,
    customer_id,
    order_purchase_timestamp
FROM
     olist.orders
LIMIT
    10;

SELECT
    order_purchase_timestamp,
    customer_id,
    customer_id
FROM
     olist.orders
LIMIT
    10;

SELECT * -- get a sample from table sellers
FROM olist.sellers
LIMIT 10;

------
-- 2. Sorting rows
------

-- sort dates, from old to new

SELECT -- sort by order_purchase_timestamp in ascending order
    customer_id,
    order_id,
    order_purchase_timestamp,
    order_status
FROM olist.orders
ORDER BY order_purchase_timestamp ASC
LIMIT 100;

SELECT -- sort by order_purchase_timestamp in ascending order
    customer_id,
    order_id,
    order_purchase_timestamp,
    order_status
FROM olist.orders
ORDER BY order_purchase_timestamp -- ASC is the default
LIMIT 100;

SELECT -- sort by order_purchase_timestamp in descending order
    customer_id,
    order_id,
    order_purchase_timestamp,
    order_status
FROM olist.orders
ORDER BY order_purchase_timestamp DESC
LIMIT 100;

-- check the customers table
SELECT *
FROM olist.customers
LIMIT 1000;

SELECT
    customer_id,
    customer_state
FROM olist.customers
ORDER BY customer_state
LIMIT 100;

SELECT -- sorting by multiple columns
    customer_id,
    customer_state
FROM olist.customers
ORDER BY
    customer_state DESC,
    customer_id ASC
LIMIT 100;

SELECT -- sorting gets evaluated before SELECT. columns in ORDER BY do not have to be in SELECT
    customer_unique_id
FROM olist.customers
ORDER BY
    customer_state DESC,
    customer_id ASC
LIMIT 100;

------
-- 3. Aliases
------

SELECT
    customer_id                 AS first_customer_id_occurence,
    customer_id                 AS second_customer_id_occurence,
    customer_id                 AS third_customer_id_occurence,
    order_purchase_timestamp    banana -- AS is not required
FROM olist.orders
LIMIT 10;

SELECT
    customer_id                 AS first_customer_id_occurence,
    customer_id                 AS second_customer_id_occurence,
    customer_id                 AS third_customer_id_occurence,
    order_purchase_timestamp    banana -- AS is not required
FROM olist.orders AS magic_table -- tables can have aliases as well
LIMIT 10;

SELECT -- convention: use AS for columns, but not for tables
    customer_id                 AS first_customer_id_occurence,
    customer_id                 AS second_customer_id_occurence,
    customer_id                 AS third_customer_id_occurence,
    order_purchase_timestamp    AS banana
FROM olist.orders magic_table
LIMIT 10;

------
-- 4. Selecting rows (Filtering)
------

SELECT -- get all order from 2017-10-04
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp
FROM olist.orders
WHERE
    order_purchase_timestamp >= '2017-10-04'
    AND order_purchase_timestamp < '2017-10-05';

-- being more explicit and trying to avoid implicit type conversion
SELECT -- get all order from 2017-10-04
    order_id,
    customer_id,
    order_status,
    DATE(order_purchase_timestamp) AS order_purchase_date
FROM olist.orders
WHERE
    order_purchase_timestamp >= '2017-10-04'
    AND order_purchase_timestamp < '2017-10-05';

-- being more explicit and trying to avoid implicit type conversion
SELECT -- get all order from 2017-10-04
    order_id,
    customer_id,
    order_status,
    DATE(order_purchase_timestamp) AS order_purchase_date
FROM olist.orders
WHERE DATE(order_purchase_timestamp) = DATE('2017-10-04');

SELECT
    customer_id,
    customer_state
FROM olist.customers
WHERE customer_state = 'SP'
LIMIT 100;

-- OR
SELECT -- get all order from 2017-10-04
    order_id,
    customer_id,
    order_status,
    DATE(order_purchase_timestamp) AS order_purchase_date
FROM olist.orders
WHERE
    (DATE(order_purchase_timestamp) >= DATE('2018-01-01')
    AND DATE(order_purchase_timestamp) < DATE('2018-02-01'))
    OR
    (DATE(order_purchase_timestamp) >= DATE('2018-12-01')
    AND DATE(order_purchase_timestamp) < DATE('2019-01-01'))
LIMIT 100;

------
-- 5. Type conversion (Casting)
------

SELECT -- using the cast function
    CAST(order_purchase_timestamp AS DATE) AS order_purchase_date
FROM olist.orders;

SELECT
    seller_zip_code_prefix,
    seller_city,
    CAST(seller_zip_code_prefix AS CHAR) AS zip_code,
    CONCAT(CAST(seller_zip_code_prefix AS CHAR), ' ', seller_city) AS address
FROM olist.sellers
LIMIT 100;

------
-- 6.Decoding, Enumerating, Translating
------

SELECT -- Using IF()
    product_id,
    order_id,
    seller_id,
    price,
    IF(price <= 150, 'cheap', 'expensive') AS price_category
FROM olist.order_items
LIMIT 1000;

SELECT
    product_id,
    order_id,
    seller_id,
    price,
    IF(price <= 150, 'cheap', IF(price <= 300, 'affordable', 'expensive')) AS price_category
FROM olist.order_items
LIMIT 1000;

SELECT -- Using CASE
    product_id,
    order_id,
    seller_id,
    price,
    IF(price <= 150, 'cheap', IF(price <= 300, 'affordable', 'expensive'))  AS price_category,
    CASE
        WHEN price <= 150 THEN 'cheap'
        ELSE 'expensive'
    END                                                                     AS case_price_category
FROM olist.order_items
LIMIT 1000;

SELECT -- Using CASE
    product_id,
    order_id,
    seller_id,
    price,
    IF(price <= 150, 'cheap', IF(price <= 300, 'affordable', 'expensive'))  AS price_category,
    CASE
        WHEN price <= 150 THEN 'cheap'
        WHEN price <= 300 THEN 'affordable'
        ELSE 'expensive'
    END                                                                     AS case_price_category
FROM olist.order_items
ORDER BY 1,2,3
LIMIT 1000;

------
-- 7. Deduplicating
------

SELECT -- using GROUP BY
    seller_id
FROM olist.order_items
GROUP BY seller_id
ORDER BY seller_id;

SELECT DISTINCT -- using SELECT DISTINCT
    seller_id
FROM olist.order_items
ORDER BY seller_id;

-- multiple columns
SELECT
    seller_id,
    product_id
FROM olist.order_items
GROUP BY
    seller_id,
    product_id
ORDER BY
    seller_id,
    product_id;

SELECT DISTINCT
    seller_id,
    product_id
FROM olist.order_items
ORDER BY
    seller_id,
    product_id;