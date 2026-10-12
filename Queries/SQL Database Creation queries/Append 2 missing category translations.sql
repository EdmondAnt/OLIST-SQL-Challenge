-- Adding 2 missing categories to the translation: "portable kitchen appliances and food processors" and "PC gamer"
INSERT INTO olist.category_translation
VALUES ('pc_gamer','pc_gamer'), ('portateis_cozinha_e_preparadores_de_alimentos','portable_kitchen_appliances_and_food_processors');

--Check Result. There should be only null values.
SELECT product_id, p.product_category_name, t.product_category_name_english
FROM olist.products AS p
FULL OUTER JOIN olist.category_translation AS t
ON t.product_category_name = p.product_category_name
WHERE product_category_name_english IS NULL
ORDER BY product_category_name DESC
