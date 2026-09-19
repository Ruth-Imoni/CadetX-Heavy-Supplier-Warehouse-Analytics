# Week 4: Supplier Reliability Analysis

## Project Overview

Analyzed on-time delivery performance across 8 suppliers to identify delivery risk and inform procurement strategy. The analysis reveals that all suppliers perform identically at 84-85% on-time delivery, indicating the problem is not supplier quality but process-based issues like unrealistic expected delivery dates or order processing bottlenecks.
 
**Status:** Completed  
**Stakeholder:** Supply Chain Manager / Procurement Team

---

## Team

| Name | Role | Task |
|------|------|------|
| [@Kumari-arya05](https://github.com/Kumari-arya05) | Scrum Master | Project oversight, stakeholder alignment |
| [@Ruth-Imoni](https://github.com/Ruth-Imoni) | SQL Data Analyst | Query design, root cause analysis |
| [@MLGideon](https://github.com/MLGideon) | Dashboard Developer | Power BI scorecard, supplier rankings |

---

## Business Questions

1. Which suppliers consistently deliver on time?
2. How often does each supplier miss delivery dates?
3. How many days late are suppliers when they miss deadlines?
4. Do critical products have different reliability patterns than regular products?
5. Can procurement mitigate delivery risk through supplier diversification?

---

## Datasets Used

- `purchase_orders_header.csv` — PO metadata including order date, expected delivery date, received date, status
- `purchase_orders_lines.csv` — Line-item product details
- `suppliers.csv` — Supplier master data and IDs
- `products.csv` — Product catalog with criticality levels

---

## Tech Stack

- **Database:** PostgreSQL
- **Query Language:** SQL (CTEs, aggregations, case logic)
- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables

1. Three SQL queries analyzing supplier performance at different levels
2. Three CSV exports showing on-time %, days late, and critical product performance
3. Power BI supplier scorecard with rankings and filters
4. Root cause analysis and procurement recommendations

---

## Dashboard

![Supplier Reliability Scorecard]

---

## Analysis & Results

### Executive Summary

All 8 suppliers deliver  84-85% of the time. When late, suppliers average a 3.9- to 4.2-day delay. Critical products show identical reliability patterns as regular products. Switching suppliers will not improve delivery performance. The root issue is process-based: expected delivery dates may not reflect actual lead times, or order processing creates upstream bottlenecks.

### Key Findings

1. **On-Time Performance:** All suppliers cluster at 84-85%, no differentiation
2. **Late Order Frequency:** 15-16% of orders miss expected delivery dates consistently
3. **Average Delay:** 3.9 to 4.2 days when late (predictable, narrow range)
4. **Critical Products:** Identical 84-85% on-time rate for high-criticality items
5. **Supplier Comparison:** No single supplier outperforms others

**Detailed Breakdown by Supplier:**

| Supplier | On-Time % | Late Orders | Avg Days Late |
|----------|-----------|-------------|---------------|
| Tianjin OEM Supplies | 85.00% | 404 | 3.98 |
| Qingdao Distributor Supplies | 85.00% | 407 | 4.02 |
| Shanghai Distributor Supplies | 84.00% | 408 | 4.19 |
| Hangzhou OEM Supplies | 85.00% | 380 | 3.94 |
| Others | 84-85% | Varies | 3.94-4.10 |

### Critical Insight

**The problem is not supplier quality. All suppliers perform identically.**

Procurement has been optimizing the wrong variable. Supplier switching will not improve delivery rates. The root cause must be investigated in:

1. Expected delivery date realism vs. actual lead times
2. Order processing delays creating upstream bottlenecks
3. Logistics and customs clearance timing
4. Industry standard benchmarks (is 84% acceptable?)

### Data Quality

- Filtered to completed orders only (po_status = 'Received')
- Excluded pending orders and NULL received dates
- All 8 suppliers have sufficient order volume for statistical validity (2,300+ orders each)
- Critical products filtering verified through products.criticality_level = 'High'

---

## Scrum Master Notes

**Sprint Goal:** Identify suppliers with delivery risk to guide procurement decisions  
**Actual Output:** 3 SQL queries, supplier performance rankings, root cause analysis  
**Key Challenge:** Expected finding (supplier differentiation) not supported by data. All suppliers identical.  
**Recommendation:** Stop supplier optimization. Instead, investigate process-level causes of delays.  
**Confidence Level:** Very High. Analysis covers 9,000+ orders and all 8 suppliers with complete data.

---

## SQL Queries

### Query 1: Supplier On-Time Delivery Rate

```sql
---Supplier on-time delivery rate. Ranks suppliers by percentage of orders received on or before the expected delivery date---

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
```

### Query 2: Average Days Late per Supplier

```sql
---Average days late per supplier. Shows how many days late each supplier is when they miss delivery dates---

SELECT su.supplier_name,
COUNT(*) as late_order_count,
ROUND(AVG(p.received_date - p.expected_delivery_date), 2) as avg_days_late
FROM purchase_orders_header AS p
JOIN suppliers AS su ON p.supplier_id = su.supplier_id
WHERE p.po_status = 'Received' AND p.received_date IS NOT NULL AND p.received_date > p.expected_delivery_date
GROUP BY su.supplier_name
ORDER BY avg_days_late DESC;
```

### Query 3: Critical Products Supplier Summary

```sql
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
  WHERE pr.criticality_level = 'HIGH' 
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
```

---

## Output Files

- `supplier_ontime_rate.csv` — On-time percentage and order counts for each supplier
- `supplier_avg_days_late.csv` — Average days late when suppliers miss delivery dates
- `critical_products_supplier_summary.csv` — On-time performance for critical product orders only

---

## Recommendations for Procurement

**Stop optimizing by supplier switching.** Instead:

1. Adjust safety stock calculations to account for a consistent 15% late order rate
2. Negotiate longer lead times with suppliers based on actual delivery patterns
3. Investigate non-supplier root causes: customs processing, logistics delays, order processing bottlenecks
4. Research industry on-time delivery benchmarks. Is 84% acceptable or below standard?
5. Consider increasing order frequency with lower quantities to reduce supplier dependency
6. Implement automated alerts for expected late arrivals (4-day buffer)

---

## Files in This Directory

```text
├── README.md (this file)
├── queries/
│ ├── 01_supplier_ontime_rate.sql
│ ├── 02_supplier_avg_days_late.sql
│ └── 03_critical_products_supplier_summary.sql
├── data/
│ ├── supplier_ontime_rate.csv
│ ├── supplier_avg_days_late.csv
│ └── critical_products_supplier_summary.csv
└── dashboards/
└── supplier_reliability_dashboard.pbix
