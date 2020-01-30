WITH actuals_kpis AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS month_id,
        COUNT(DISTINCT oi.order_id)                         AS orders,
        SUM(oi.price)                                       AS revenue
    FROM olist.order_items oi
        JOIN olist.orders o
        ON oi.order_id = o.order_id
    WHERE
        o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY 1)

   , kpis_month AS (
    SELECT
        DATE_ADD(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01'), INTERVAL 1 month) AS month_id_shifted_month,
        COUNT(DISTINCT oi.order_id)                                                     AS orders,
        SUM(oi.price)                                                                   AS revenue
    FROM olist.order_items oi
        JOIN olist.orders o
        ON oi.order_id = o.order_id
    WHERE
        o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY 1)

   , kpis_year AS (
    SELECT
        DATE_ADD(DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01'), INTERVAL 1 year)  AS month_id_shifted_year,
        COUNT(DISTINCT oi.order_id)                                                     AS orders,
        SUM(oi.price)                                                                   AS revenue
    FROM olist.order_items oi
        JOIN olist.orders o
        ON oi.order_id = o.order_id
    WHERE
            o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY 1)

SELECT
    a.month_id,
    a.orders,
    m.orders    AS orders_lm,
    y.orders    AS orders_ly,
    a.revenue,
    m.revenue   AS revenue_lm,
    y.revenue   AS revenue_ly
FROM actuals_kpis a
    LEFT JOIN kpis_month m
    ON a.month_id = m.month_id_shifted_month
    LEFT JOIN kpis_year y
    ON a.month_id = y.month_id_shifted_year;