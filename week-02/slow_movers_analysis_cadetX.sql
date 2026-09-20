---Supplier on-time delivery rate. Ranks suppliers by percentage of orders received on or before expected delivery date---

SELECT su.supplier_name,
COUNT(*) as total_orders,
COUNT(CASE WHEN p.received_date <= p.expected_delivery_date THEN 1 END) as on_time_orders,
COUNT(*) - COUNT(CASE WHEN p.received_date <= p.expected_delivery_date THEN 1 END) AS late_orders,
ROUND(COUNT(CASE WHEN p.received_date <= p.expected_delivery_date THEN 1 END) * 100 / COUNT(*), 2) as on_time_percentage
FROM purchase_orders_header AS p
JOIN suppliers AS su ON p.supplier_id = su.supplier_id
WHERE p.po_status = 'Received' AND p.received_date IS NOT NULL
GROUP BY su.supplier_name
ORDER BY on_time_percentage DESC;

---Average days late per supplier. Shows how many days late each supplier is when they miss delivery dates---

SELECT su.supplier_name,
COUNT(*) as late_order_count,
ROUND(AVG(p.received_date - p.expected_delivery_date), 2) as avg_days_late
FROM purchase_orders_header AS p
JOIN suppliers AS su ON p.supplier_id = su.supplier_id
WHERE p.po_status = 'Received' AND p.received_date IS NOT NULL AND p.received_date > p.expected_delivery_date
GROUP BY su.supplier_name
ORDER BY avg_days_late DESC;

---Critical products supplier summary. Analyzes on-time performance for high-criticality products only across all suppliers---

WITH critical_products AS (
SELECT
pol.product_id,
pr.product_name,
p.supplier_id,
p.received_date,
p.expected_delivery_date
FROM purchase_orders_header AS p
JOIN purchase_orders_lines AS pol ON p.po_id = pol.po_id
JOIN products AS pr ON pol.product_id = pr.product_id
WHERE pr.criticality_level = 'High'
AND p.po_status = 'Received'
AND p.received_date IS NOT NULL
),
supplier_performance AS (
SELECT
su.supplier_name,
COUNT(DISTINCT cp.product_id) as critical_products_count,
COUNT(*) as total_orders,
COUNT(CASE WHEN cp.received_date <= cp.expected_delivery_date THEN 1 END) as on_time_orders,
ROUND(COUNT(CASE WHEN cp.received_date <= cp.expected_delivery_date THEN 1 END) * 100 / COUNT(*), 2) as avg_on_time_percentage
FROM critical_products AS cp
JOIN suppliers AS su ON cp.supplier_id = su.supplier_id
GROUP BY su.supplier_name
)
SELECT * FROM supplier_performance
ORDER BY avg_on_time_percentage ASC;