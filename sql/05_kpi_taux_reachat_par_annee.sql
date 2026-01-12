-- Calcul du Taux de ré‑achat (part des clients ayant ≥ 2 commandes complètes sur une année)


SELECT
  year,
  AVG(CAST(is_rebuyer AS INT64)) * 100 AS taux_reachat
FROM (
  SELECT DISTINCT
    EXTRACT(YEAR FROM o.created_at) AS year,
    o.user_id,
    COUNT(DISTINCT o.order_id)
      OVER (PARTITION BY EXTRACT(YEAR FROM o.created_at), o.user_id) >= 2
      AS is_rebuyer
  FROM `bigquery-public-data.thelook_ecommerce.orders` o       -- on se place maintenant sur la table orders. Jointures à faire : order_items, users, products
  JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON o.user_id = u.id
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE           -- On délimite notre périmètre avec la clause WHERE. 
    u.country = 'France'          -- commandes passées en France
    AND p.department = 'Women'     -- produits du département "Femme"
    AND o.status = 'Complete'       -- commandes "Complete"
    AND DATE(o.created_at) BETWEEN '2023-01-01' AND '2024-12-31'       -- lignes de commandes créées en 2023 et 2024
)
GROUP BY year
ORDER BY year;


-- Résultat attendu :

-- year | taux_reachat
-- 2023 : 0.00 %
-- 2024 : 3.39 %

-- Résultat obtenu :

-- year | taux_reachat
-- 2023 | 3.75 %
-- 2024 | 2.53 %