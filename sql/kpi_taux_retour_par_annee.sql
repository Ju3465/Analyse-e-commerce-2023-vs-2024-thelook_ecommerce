
-- Calcul du Taux de retour (part des lignes au statut "Returned" parmi les lignes vendues : ventes + retours) annuel


SELECT
  COUNTIF(oi.status = 'Returned') / COUNTIF(oi.status IN ('Returned', 'Complete')) AS taux_retour, 
  EXTRACT(YEAR FROM oi.created_at) AS year      -- Taux de retour annuel
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi       -- jointures à faire avec les tables users, products
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u
  ON oi.user_id = u.id
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE           -- On délimite notre périmètre avec la clause WHERE. 
  u.country = 'France'          -- commandes passées en France
  AND p.department = 'Women'     -- produits du département "Femme"  // pas de fitrage sur le statut "Complete" car nous avons besoin de "Returned"
  AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'       -- lignes de commandes créées en 2023 et 2024
GROUP BY year;