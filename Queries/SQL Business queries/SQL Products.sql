Select p.product_id, o.price, t.product_category_name_english
FROM olist.products AS p
JOIN olist.category_translation as t
ON p.product_category_name = t.product_category_name
JOIN olist.order_items as o
ON p.product_id = o.product_id