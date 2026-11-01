--- Units sold per product per month ---
SELECT
  sol.product_id,
  DATE_TRUNC('month', soh.order_date) AS month,
  SUM(sol.quantity) AS units_sold
FROM sales_orders_lines AS sol
JOIN sales_orders_header AS soh ON sol.so_id = soh.so_id
WHERE soh.order_status = 'Delivered'
GROUP BY sol.product_id, DATE_TRUNC('month', soh.order_date)
ORDER BY sol.product_id, month;

--- 90-day forecast by product and branch ---
WITH ref AS (
  -- Latest order date in the dataset, used instead of today's date
  SELECT MAX(order_date) AS ref_date
  FROM sales_orders_header
),
windows AS (
  SELECT
    soh.branch_id,
    sol.product_id,
    -- Method A: last 90 days, up to and including the reference date
    SUM(CASE WHEN soh.order_date > ref.ref_date - 90
              AND soh.order_date <= ref.ref_date
             THEN sol.quantity ELSE 0 END) AS units_last_90d,
    -- Method B: same 90 days one year earlier
    SUM(CASE WHEN soh.order_date > ref.ref_date - 365
              AND soh.order_date <= ref.ref_date - 275
             THEN sol.quantity ELSE 0 END) AS units_same_period_ly
  FROM sales_orders_lines AS sol
  JOIN sales_orders_header AS soh ON sol.so_id = soh.so_id
  CROSS JOIN ref
  WHERE soh.order_status = 'Delivered'
  GROUP BY soh.branch_id, sol.product_id
)
SELECT
  w.product_id,
  p.product_name,
  w.branch_id,
  w.units_last_90d AS forecast_method_a,
  w.units_same_period_ly AS forecast_method_b,
  -- Avoid dividing by zero: leave change blank when last year had no sales
  CASE
    WHEN w.units_same_period_ly = 0 THEN NULL
    ELSE ROUND((w.units_last_90d - w.units_same_period_ly) * 100.0 / w.units_same_period_ly, 1)
  END AS change_pct
FROM windows AS w
JOIN products AS p ON w.product_id = p.product_id
ORDER BY w.branch_id, change_pct DESC NULLS LAST;

--- Method A forecast: the 90 days before that period ---
WITH ref AS (
  SELECT MAX(order_date) AS ref_date
  FROM sales_orders_header
),
backtest AS (
  SELECT
    sol.product_id,
    -- Actual: 180 to 90 days ago
    SUM(CASE WHEN soh.order_date > ref.ref_date - 180
              AND soh.order_date <= ref.ref_date - 90
             THEN sol.quantity ELSE 0 END) AS actual_units,
    -- Method A: the 90 days before the actual window
    SUM(CASE WHEN soh.order_date > ref.ref_date - 270
              AND soh.order_date <= ref.ref_date - 180
             THEN sol.quantity ELSE 0 END) AS forecast_a,
    -- Method B: the actual window one year earlier
    SUM(CASE WHEN soh.order_date > ref.ref_date - 545
              AND soh.order_date <= ref.ref_date - 455
             THEN sol.quantity ELSE 0 END) AS forecast_b
  FROM sales_orders_lines AS sol
  JOIN sales_orders_header AS soh ON sol.so_id = soh.so_id
  CROSS JOIN ref
  WHERE soh.order_status = 'Delivered'
  GROUP BY sol.product_id
)
SELECT
  b.product_id,
  p.product_name,
  b.actual_units,
  b.forecast_a,
  b.forecast_b,
  ABS(b.actual_units - b.forecast_a) AS abs_error_a,
  ABS(b.actual_units - b.forecast_b) AS abs_error_b
FROM backtest AS b
JOIN products AS p ON b.product_id = p.product_id
ORDER BY b.actual_units DESC;

--- Method B forecast: the same 90 days one year before that period ---
WITH ref AS (
  SELECT MAX(order_date) AS ref_date
  FROM sales_orders_header
),
backtest AS (
  SELECT
    sol.product_id,
    -- Actual: 180 to 90 days ago
    SUM(CASE WHEN soh.order_date > ref.ref_date - 180
              AND soh.order_date <= ref.ref_date - 90
             THEN sol.quantity ELSE 0 END) AS actual_units,
    -- Method A: the 90 days before the actual window
    SUM(CASE WHEN soh.order_date > ref.ref_date - 270
              AND soh.order_date <= ref.ref_date - 180
             THEN sol.quantity ELSE 0 END) AS forecast_a,
    -- Method B: the actual window one year earlier
    SUM(CASE WHEN soh.order_date > ref.ref_date - 545
              AND soh.order_date <= ref.ref_date - 455
             THEN sol.quantity ELSE 0 END) AS forecast_b
  FROM sales_orders_lines AS sol
  JOIN sales_orders_header AS soh ON sol.so_id = soh.so_id
  CROSS JOIN ref
  WHERE soh.order_status = 'Delivered'
  GROUP BY sol.product_id
)
SELECT
  'Method A (recent run rate)' AS method,
  ROUND(SUM(ABS(actual_units - forecast_a)) * 100.0 / SUM(actual_units), 1) AS wape_pct
FROM backtest
UNION ALL
SELECT
  'Method B (same period last year)' AS method,
  ROUND(SUM(ABS(actual_units - forecast_b)) * 100.0 / SUM(actual_units), 1) AS wape_pct
FROM backtest;

--- Method Aa forecast: the 180 days before that period ---
WITH ref AS (
  SELECT MAX(order_date) AS ref_date
  FROM sales_orders_header
),
backtest AS (
  SELECT
    sol.product_id,
    -- Actual: 180 to 90 days ago
    SUM(CASE WHEN soh.order_date > ref.ref_date - 270
              AND soh.order_date <= ref.ref_date - 180
             THEN sol.quantity ELSE 0 END) AS actual_units,
    -- Method A: the 90 days before the actual window
    SUM(CASE WHEN soh.order_date > ref.ref_date - 360
              AND soh.order_date <= ref.ref_date - 270
             THEN sol.quantity ELSE 0 END) AS forecast_a,
    -- Method B: the actual window one year earlier
    SUM(CASE WHEN soh.order_date > ref.ref_date - 635
              AND soh.order_date <= ref.ref_date - 545
             THEN sol.quantity ELSE 0 END) AS forecast_b
  FROM sales_orders_lines AS sol
  JOIN sales_orders_header AS soh ON sol.so_id = soh.so_id
  CROSS JOIN ref
  WHERE soh.order_status = 'Delivered'
  GROUP BY sol.product_id
)
SELECT
  b.product_id,
  p.product_name,
  b.actual_units,
  b.forecast_a,
  b.forecast_b,
  ABS(b.actual_units - b.forecast_a) AS abs_error_a,
  ABS(b.actual_units - b.forecast_b) AS abs_error_b
FROM backtest AS b
JOIN products AS p ON b.product_id = p.product_id
ORDER BY b.actual_units DESC;

--- Bb---
WITH ref AS (
  SELECT MAX(order_date) AS ref_date
  FROM sales_orders_header
),
backtest AS (
  SELECT
    sol.product_id,
    -- Actual: 180 to 90 days ago
    SUM(CASE WHEN soh.order_date > ref.ref_date - 270
              AND soh.order_date <= ref.ref_date - 180
             THEN sol.quantity ELSE 0 END) AS actual_units,
    -- Method A: the 90 days before the actual window
    SUM(CASE WHEN soh.order_date > ref.ref_date - 360
              AND soh.order_date <= ref.ref_date - 270
             THEN sol.quantity ELSE 0 END) AS forecast_a,
    -- Method B: the actual window one year earlier
    SUM(CASE WHEN soh.order_date > ref.ref_date - 635
              AND soh.order_date <= ref.ref_date - 545
             THEN sol.quantity ELSE 0 END) AS forecast_b
  FROM sales_orders_lines AS sol
  JOIN sales_orders_header AS soh ON sol.so_id = soh.so_id
  CROSS JOIN ref
  WHERE soh.order_status = 'Delivered'
  GROUP BY sol.product_id
)
SELECT
  'Method A (recent run rate)' AS method,
  ROUND(SUM(ABS(actual_units - forecast_a)) * 100.0 / SUM(actual_units), 1) AS wape_pct
FROM backtest
UNION ALL
SELECT
  'Method B (same period last year)' AS method,
  ROUND(SUM(ABS(actual_units - forecast_b)) * 100.0 / SUM(actual_units), 1) AS wape_pct
FROM backtest;