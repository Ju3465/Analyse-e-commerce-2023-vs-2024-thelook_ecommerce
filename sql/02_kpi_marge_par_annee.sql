-- Calcul de la Marge brute (somme de sale_price – cost pour les lignes de vente) annuelle


SELECT
  SUM(oi.sale_price) - SUM(p.cost) AS marge_brute, 
  EXTRACT(YEAR FROM oi.created_at) AS year      -- Marge brute annuelle
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi       -- jointures à faire avec les tables users, products
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u
  ON oi.user_id = u.id
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE           -- On délimite notre périmètre avec la clause WHERE.
  u.country = 'France'          -- commandes passées en France
  AND p.department = 'Women'     -- produits du département "Femme"
  AND oi.status ='Complete'       -- lignes de commandes "Complete" 
  AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'       -- lignes de commandes créées en 2023 et 2024
GROUP BY year;


-- Résultat attendu :

-- year | marge_brute
-- 2023 : 4075.34 €
-- 2024 : 8134.61 €

-- Résultat obtenu :

-- year | marge_brute
-- 2023 | 3647.46 €
-- 2024 | 7409.43 €