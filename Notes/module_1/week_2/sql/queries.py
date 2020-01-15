query = """SELECT
            p.product_category_name,
            COUNT(*)                 AS items_sold
        FROM olist.order_items oi
            INNER JOIN olist.products p
            ON oi.product_id = p.product_id
        GROUP BY p.product_category_name
        ORDER BY 2 DESC"""