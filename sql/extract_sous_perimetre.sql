SELECT
    oi.order_id, oi.id AS order_item_id, p.id AS product_id, oi.created_at AS item_created_at,
    oi.status AS item_status, oi.sale_price, p.cost, p.category, p.department, p.brand,
    p.name AS product_name, o.status AS order_status, o.created_at AS order_created_at, 
    oi.shipped_at, oi.delivered_at, u.id AS user_id, u.gender, u.country, u.state, u.city
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
ORDER BY item_created_at, oi.order_id, order_item_id;