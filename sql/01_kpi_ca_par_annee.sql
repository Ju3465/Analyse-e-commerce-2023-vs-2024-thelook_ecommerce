-- Calcul du Chiffre d’affaires (somme de sale_price pour les lignes de vente) annuel


SELECT
  SUM(oi.sale_price) AS chiffre_affaires_total, 
  EXTRACT(YEAR FROM oi.created_at) AS year      -- CA annuel
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

-- year | chiffre_affaires_total
-- 2023 : 7806.32 €
-- 2024 : 15716.28 €

-- Résultat obtenu :

-- year | chiffre_affaires_total
-- 2023 | 7065.42 €
-- 2024 | 14137.46 €