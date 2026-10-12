    SELECT 
        DATE_BUCKET(MONTH, 1, o.order_purchase_timestamp) AS order_period,
        t.product_category_name_english                    AS category_name,
        SUM(ord.price)                        AS Gross_Merchandize_Value
    FROM olist.orders AS o
    JOIN olist.order_items AS ord 
        ON ord.order_id = o.order_id
    JOIN olist.products AS pr 
        ON pr.product_id = ord.product_id
    JOIN olist.category_translation AS t 
        ON pr.product_category_name = t.product_category_name
    WHERE 
        o.order_status IN ('delivered') 
        AND o.order_purchase_timestamp >= '2017-06-01' 
        AND o.order_purchase_timestamp <  '2018-07-01'
    GROUP BY 
        DATE_BUCKET(MONTH, 1, o.order_purchase_timestamp), 
        t.product_category_name_english;




WITH CategoryMonthlyRevenue AS (
    SELECT 
        DATE_BUCKET(MONTH, 1, o.order_purchase_timestamp) AS order_period,
        t.product_category_name_english                    AS category_name,
        SUM(ord.price)                        AS Gross_Merchandize_Value
    FROM olist.orders AS o
    JOIN olist.order_items AS ord 
        ON ord.order_id = o.order_id
    JOIN olist.products AS pr 
        ON pr.product_id = ord.product_id
    JOIN olist.category_translation AS t 
        ON pr.product_category_name = t.product_category_name
    WHERE 
        o.order_status IN ('delivered') 
        AND o.order_purchase_timestamp >= '2017-06-01' 
        AND o.order_purchase_timestamp <  '2018-07-01'
    GROUP BY 
        DATE_BUCKET(MONTH, 1, o.order_purchase_timestamp), 
        t.product_category_name_english
),
June2018 AS (
    SELECT category_name, Gross_Merchandize_Value AS rev_2018
    FROM CategoryMonthlyRevenue
    WHERE order_period = '2018-06-01'
),
June2017 AS (
    SELECT category_name, Gross_Merchandize_Value AS rev_2017
    FROM CategoryMonthlyRevenue
    WHERE order_period = '2017-06-01'
)
SELECT 
    j18.category_name,
    ISNULL(j17.rev_2017, 0) AS june_2017_revenue,
    j18.rev_2018            AS june_2018_revenue,
    -- Absolute Growth
    j18.rev_2018 - ISNULL(j17.rev_2017, 0) AS revenue_growth_amount,
    -- Percentage YoY Growth
    CAST(
        (j18.rev_2018 - ISNULL(j17.rev_2017, 0)) * 100.0 / NULLIF(j17.rev_2017, 0)
    AS DECIMAL(10,2)) AS revenue_growth_YoY_pct

FROM June2018 AS j18
LEFT JOIN June2017 AS j17 
    ON j18.category_name = j17.category_name
ORDER BY 
    revenue_growth_YoY_pct DESC, 
    june_2018_revenue DESC;