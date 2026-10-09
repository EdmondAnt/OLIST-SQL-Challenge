Select COUNT(p.product_id) AS category_count, SUM(pay.payment_value) AS category_revenue, t.product_category_name_english AS category_name
FROM olist.products AS p
JOIN olist.category_translation as t
ON p.product_category_name = t.product_category_name
JOIN olist.order_items as o
ON p.product_id = o.product_id
JOIN olist.payments as pay
ON pay.order_id = o.order_id
GROUP BY t.product_category_name_english
ORDER BY category_count DESC