-- Órdenes nuevas por día en hora de Costa Rica (UTC-6), por país de la cuenta.
-- Fuente: analytics.manufacturing.mfg_all_orders (Databricks, LightForce).
-- scan_received_date está en UTC; se convierte a America/Costa_Rica antes de tomar la fecha.
-- Puerto Rico (PR) se suma a EE. UU.; acero = brackets de acero inoxidable.
-- Salida: ordenes_diarias.csv (fecha, ordenes, acero, us, ca, au, nz), del 2023-01-01 al 2026-11-11.
WITH o AS (
  SELECT to_date(from_utc_timestamp(scan_received_date, 'America/Costa_Rica')) AS fecha,
         CASE WHEN account_country IN ('US', 'PR') THEN 'US' ELSE account_country END AS pais,
         CASE WHEN bracket_material_name = 'Stainless Steel' THEN 1 ELSE 0 END AS acero
  FROM analytics.manufacturing.mfg_all_orders
  WHERE order_type = 'New case' AND scan_received_date IS NOT NULL
)
SELECT fecha,
       count(*) AS ordenes,
       sum(acero) AS acero,
       sum(CASE WHEN pais = 'US' THEN 1 ELSE 0 END) AS us,
       sum(CASE WHEN pais = 'CA' THEN 1 ELSE 0 END) AS ca,
       sum(CASE WHEN pais = 'AU' THEN 1 ELSE 0 END) AS au,
       sum(CASE WHEN pais = 'NZ' THEN 1 ELSE 0 END) AS nz
FROM o
WHERE fecha BETWEEN DATE'2023-01-01' AND DATE'2026-11-11'
GROUP BY fecha
ORDER BY fecha;
