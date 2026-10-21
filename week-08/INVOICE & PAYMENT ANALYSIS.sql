WITH ref AS (
  -- Dataset's latest date, used instead of CURRENT_DATE
  SELECT GREATEST(MAX(i.invoice_date), MAX(p.payment_date)) AS ref_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
),
invoice_level AS (
  -- One row per invoice. MAX(payment_date) prevents double counting if an invoice has several payments
  SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_date,
    i.grand_total AS invoice_amount,
    MAX(p.payment_date) AS paid_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
  GROUP BY i.invoice_id, i.customer_id, i.invoice_date, i.grand_total
)
-- Days to pay (DSO) and % of paid invoices paid within 30 days, per customer
-- Only paid invoices are counted, so paid_date IS NOT NULL

SELECT
  c.customer_id,
  c.customer_type,
  COUNT(*) AS paid_invoices,
  ROUND(AVG(il.paid_date - il.invoice_date), 2) AS dso,
  COUNT(CASE WHEN il.paid_date - il.invoice_date <= 30 THEN 1 END) AS on_time_count,
  COUNT(CASE WHEN il.paid_date - il.invoice_date > 30 THEN 1 END) AS late_count,
  ROUND(
    COUNT(CASE WHEN il.paid_date - il.invoice_date <= 30 THEN 1 END)::numeric * 100 / COUNT(*),
    2
  ) AS on_time_percentage
FROM invoice_level AS il
JOIN customers AS c ON il.customer_id = c.customer_id
WHERE il.paid_date IS NOT NULL
  AND il.paid_date >= il.invoice_date
GROUP BY c.customer_id, c.customer_type
ORDER BY dso DESC;

--- 2 ---
WITH ref AS (
  -- Dataset's latest date, used instead of CURRENT_DATE
  SELECT GREATEST(MAX(i.invoice_date), MAX(p.payment_date)) AS ref_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
),
invoice_level AS (
  -- One row per invoice. MAX(payment_date) prevents double counting if an invoice has several payments
  SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_date,
    i.grand_total AS invoice_amount,
    MAX(p.payment_date) AS paid_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
  GROUP BY i.invoice_id, i.customer_id, i.invoice_date, i.grand_total
)
-- Invoices older than 30 days that are still unpaid, or were paid after 30 days
-- days_elapsed = days from invoice to payment, or to the dataset's latest date if unpaid

SELECT
  il.invoice_id,
  il.customer_id,
  c.customer_type,
  il.invoice_date,
  il.invoice_amount,
  il.paid_date,
  COALESCE(il.paid_date, ref.ref_date) - il.invoice_date AS days_elapsed,
  CASE
    WHEN COALESCE(il.paid_date, ref.ref_date) - il.invoice_date > 90 THEN 'Over 90 days'
    WHEN COALESCE(il.paid_date, ref.ref_date) - il.invoice_date > 60 THEN 'Over 60 days'
    WHEN COALESCE(il.paid_date, ref.ref_date) - il.invoice_date > 30 THEN 'Over 30 days'
  END AS overdue_status
FROM invoice_level AS il
CROSS JOIN ref
JOIN customers AS c ON il.customer_id = c.customer_id
WHERE COALESCE(il.paid_date, ref.ref_date) - il.invoice_date > 30
ORDER BY days_elapsed DESC;

--- 3 ---
WITH ref AS (
  -- Dataset's latest date, used instead of CURRENT_DATE
  SELECT GREATEST(MAX(i.invoice_date), MAX(p.payment_date)) AS ref_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
),
invoice_level AS (
  -- One row per invoice. MAX(payment_date) prevents double counting if an invoice has several payments
  SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_date,
    i.grand_total AS invoice_amount,
    MAX(p.payment_date) AS paid_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
  GROUP BY i.invoice_id, i.customer_id, i.invoice_date, i.grand_total
)
-- DSO, consistency (standard deviation), and invoice count by customer type
-- Paid invoices only

SELECT
  c.customer_type,
  COUNT(DISTINCT c.customer_id) AS customer_count,
  COUNT(*) AS paid_invoices,
  ROUND(AVG(il.paid_date - il.invoice_date), 2) AS avg_dso,
  ROUND(STDDEV(il.paid_date - il.invoice_date), 2) AS dso_std_dev,
  ROUND(
    COUNT(CASE WHEN il.paid_date - il.invoice_date <= 30 THEN 1 END)::numeric * 100 / COUNT(*),
    2
  ) AS on_time_percentage
FROM invoice_level AS il
JOIN customers AS c ON il.customer_id = c.customer_id
WHERE il.paid_date IS NOT NULL
GROUP BY c.customer_type
ORDER BY avg_dso DESC;

--- 4 ---
WITH ref AS (
  -- Dataset's latest date, used instead of CURRENT_DATE
  SELECT GREATEST(MAX(i.invoice_date), MAX(p.payment_date)) AS ref_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
),
invoice_level AS (
  -- One row per invoice. MAX(payment_date) prevents double counting if an invoice has several payments
  SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_date,
    i.grand_total AS invoice_amount,
    MAX(p.payment_date) AS paid_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
  GROUP BY i.invoice_id, i.customer_id, i.invoice_date, i.grand_total
),
-- Customers whose average payment time is over 60 days, with unpaid balances
-- Ranked by outstanding amount

customer_risk AS (
  SELECT
    il.customer_id,
    COUNT(*) AS total_invoices,
   ROUND(AVG(CASE WHEN il.paid_date >= il.invoice_date THEN il.paid_date - il.invoice_date END), 2) AS avg_dso,
    COUNT(CASE WHEN il.paid_date IS NULL THEN 1 END) AS unpaid_invoices,
    COALESCE(SUM(CASE WHEN il.paid_date IS NULL THEN il.invoice_amount END), 0) AS outstanding_amount,
    SUM(il.invoice_amount) AS lifetime_invoice_value
  FROM invoice_level AS il
  GROUP BY il.customer_id
)
SELECT
  cr.customer_id,
  c.customer_type,
  cr.total_invoices,
  cr.avg_dso,
  cr.unpaid_invoices,
  cr.outstanding_amount,
  cr.lifetime_invoice_value,
  CASE
    WHEN cr.avg_dso > 60 THEN 'High Risk'
    WHEN cr.avg_dso > 45 THEN 'Medium Risk'
    ELSE 'Low Risk'
  END AS risk_category
FROM customer_risk AS cr
JOIN customers AS c ON cr.customer_id = c.customer_id
ORDER BY cr.outstanding_amount DESC;