-- Re-confection du csv originel avec BigQuery


SELECT
    oi.order_id, oi.id AS order_item_id, oi.created_at AS item_created_at,      -- remise des colonnes dans l'ordre du csv d'origine en enlevant les colonnes shipped_at, delivered_at et product_id qui ne sont pas indispensables
    oi.status AS item_status, oi.sale_price, p.cost, p.category, p.department, p.brand,   -- on garde order_status pour le calcul du taux de ré-achat
    p.name AS product_name, o.status AS order_status, o.created_at AS order_created_at,
    u.id AS user_id, u.gender, u.country, u.state, u.city
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi       -- jointures à faire avec les tables orders, users, products
INNER JOIN `bigquery-public-data.thelook_ecommerce.orders` o
  ON oi.order_id = o.order_id
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u
  ON o.user_id = u.id
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE           -- On délimite notre périmètre avec la clause WHERE. 
  u.country = 'France'          -- commandes passées en France
  AND p.department = 'Women'     -- produits du département "Femme"  // pas de fitrage sur le statut car nous les voulons tous
  AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'       -- lignes de commandes créées en 2023 et 2024
ORDER BY item_created_at, oi.order_id, order_item_id;