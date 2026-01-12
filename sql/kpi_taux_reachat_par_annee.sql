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
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON o.user_id = u.id
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
    ON o.order_id = oi.order_id
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE o.status = 'Complete'
    AND u.country = 'France'
    AND p.department = 'Women'
    AND DATE(o.created_at) BETWEEN '2023-01-01' AND '2024-12-31'
)
GROUP BY year
ORDER BY year;