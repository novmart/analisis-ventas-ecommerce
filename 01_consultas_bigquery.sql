-- =========================================================
-- Proyecto: Análisis de ventas - The Look E-commerce
-- Dataset público de BigQuery: bigquery-public-data.thelook_ecommerce
-- =========================================================

-- 1) Ventas totales por mes
SELECT
  DATE_TRUNC(DATE(created_at), MONTH) AS mes,
  COUNT(DISTINCT order_id) AS cantidad_ordenes,
  SUM(sale_price) AS ventas_totales
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status != 'Cancelled'
GROUP BY mes
ORDER BY mes;

-- 2) Top 10 productos más vendidos
SELECT
  p.name AS producto,
  p.category AS categoria,
  COUNT(oi.id) AS unidades_vendidas,
  ROUND(SUM(oi.sale_price), 2) AS ingresos
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE oi.status != 'Cancelled'
GROUP BY producto, categoria
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- 3) Ventas por categoría y país del cliente
SELECT
  u.country AS pais,
  p.category AS categoria,
  ROUND(SUM(oi.sale_price), 2) AS ingresos
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
JOIN `bigquery-public-data.thelook_ecommerce.users` u ON oi.user_id = u.id
WHERE oi.status != 'Cancelled'
GROUP BY pais, categoria
ORDER BY ingresos DESC
LIMIT 20;

-- 4) Tasa de cancelación / devolución por categoría
SELECT
  p.category AS categoria,
  COUNTIF(oi.status = 'Cancelled') AS cancelados,
  COUNTIF(oi.status = 'Returned') AS devueltos,
  COUNT(*) AS total_items,
  ROUND(COUNTIF(oi.status IN ('Cancelled','Returned')) / COUNT(*) * 100, 2) AS tasa_problema_pct
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
GROUP BY categoria
ORDER BY tasa_problema_pct DESC;

-- 5) Vista consolidada para exportar a R / Tableau
-- (esta es la que vas a usar como fuente principal)
SELECT
  oi.id AS item_id,
  oi.order_id,
  DATE(oi.created_at) AS fecha,
  oi.sale_price,
  oi.status,
  p.name AS producto,
  p.category AS categoria,
  u.country AS pais,
  u.gender AS genero,
  u.age AS edad
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
JOIN `bigquery-public-data.thelook_ecommerce.users` u ON oi.user_id = u.id
WHERE DATE(oi.created_at) >= '2023-01-01';
