SELECT
  COUNTIF(oi.status = 'Returned') / COUNTIF(oi.status IN ('Returned', 'Complete')) AS taux_retour, EXTRACT(YEAR FROM oi.created_at) AS year
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
INNER JOIN `bigquery-public-data.thelook_ecommerce.orders` o
  ON oi.order_id = o.order_id
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u
  ON o.user_id = u.id
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE u.country = 'France'
  AND p.department = 'Women'
  AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'
GROUP BY year;