Select SUM(pay.payment_value) AS period_revenue, 
DATE_BUCKET(MONTH, 1, o.order_purchase_timestamp)  AS order_period
FROM olist.orders AS o
JOIN olist.payments as pay
ON pay.order_id = o.order_id
WHERE o.order_status NOT IN ('cancelled', 'unavailable') 
AND o.order_purchase_timestamp >= '2017-06-01' 
AND o.order_purchase_timestamp <  '2018-07-01'
GROUP BY DATE_BUCKET(MONTH, 1, o.order_purchase_timestamp)
ORDER BY order_period ASC