# Week-09: Inventory Availability & Reorder Analysis


## Project Overview

Assessed current stock availability across six branches to identify products that need replenishment and imbalances between where stock sits and where it sells. Sales-based results are reliable. Stock-based results are **provisional** because the recorded stock figures could not be fully reconciled with the stock ledger, and current stock is about 300 times each product's recorded max_stock.

9  
**Status:** Completed with open data validation items   
**Stakeholders:** Inventory Management / Procurement / Operations

---

## Team

| Name | Role | Task |
|------|------|------|
| Ruth | SQL Data Analyst | Inventory, sales, and stock reconciliation queries |
| Tobiloba | Dashboard Developer | Inventory Management Overview dashboard |

---

## Business Questions

1. Which products are out of stock, critical, or at reorder level?
2. How much stock does each branch hold, and how many days of cover does that represent?
3. Which products are fast-moving and which are slow-moving?
4. How is stock distributed across branches compared with where products sell?
5. Which products are growing or declining in recent sales?

---

## Datasets Used

- `inventory_master.csv` — product_id, branch_id, opening_stock, reorder_level, safety_stock, max_stock, current_stock, warehouse_bin
- `stock_ledger.csv` — movement history per product and branch, used for reconciliation only
- `products.csv` — product_name, category, criticality_level, lead_time_days
- `sales_orders_header.csv` — so_id, branch_id, order_date, order_status
- `sales_orders_lines.csv` — so_id, product_id, quantity

**Warehouse definition:** The dataset has no separate warehouse table. `branch_id` is treated as the warehouse level. `warehouse_bin` is the shelf location within a branch and is not used in this analysis.

---

## Tech Stack

- **Database:** PostgreSQL
- **Query Language:** SQL (CTEs, window functions, CASE logic, PERCENTILE_CONT)
- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables

1. Stock status by product and branch (Query 1)
2. Sales trend by product, last 90 days vs prior 90 days (Query 2)
3. Fast, medium, and slow movers (Query 3)
4. Stock availability and days of cover by branch (Query 4)
5. Replenishment list (Query 5, returned no rows)
6. Stock share vs sales share imbalance by product and branch (Query 6)
7. Inventory Management Overview dashboard
8. Data validation log

---

## Dashboard

![Inventory Management Overview](./Screenshot%202026-11-01%20033234.png)

* 📥 **Power BI File:** [`inventory_monitoring_dashboard.pbix`](./Inventory%20Management.pbix)

---

## Dashboard Visuals

**Filters Available:**
* Branch ID
* Movement Class (Fast-moving, Medium-moving, Slow-moving)

**Key Performance Cards:**
* Total Current Stock: 19M
* Average Days of Cover: 35.95K (see Dashboard Notes: not a meaningful figure yet)
* Average Sales Share %: 16.67 (see Dashboard Notes: equals 100 divided by 6 by construction)

**Chart 1: Total Stock by Branch** Column chart showing all six branches holding between about 3.1M and 3.3M units.

**Chart 2: Days of Cover by Branch** Column chart ranking branches from HYD001 (42K) down to CHN001 (29K).

**Chart 3: Stock Share vs Sales Share** Scatter plot displaying points spread widely around the diagonal.

**Chart 4: Total Units Sold by Product** Horizontal bar chart featuring top products like Fuel Pump FP-350, Alternator ALT-500, and Radiator RD-250.

**Chart 5: Stock Availability Table** Detailed view sorted by units sold, displaying product name, branch ID, current stock, sales share %, stock share %, and units sold.

---

## Key Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Products tracked | 180 (30 products × 6 branches) | Verified |
| Out of stock | 0 | Provisional (stock-based) |
| Critical (below safety stock) | 0 | Provisional (stock-based) |
| At reorder level | 0 | Provisional (stock-based) |
| Replenishment list | 0 rows | Provisional (stock-based) |
| Total current stock | 19M units | Provisional (stock-based) |
| Cancelled orders excluded | 1,967 | Verified |
| Delivered orders used | 18,033 | Verified |
| Ledger vs current_stock mismatches | 14 of 180 | Verified |

---

## Key Findings

### Reliable (sales-based):

1. **Growing products:** Cabin Glass CG-20 (+25.1%), Hydraulic Pump HP-300 (+13.9%), Hydraulic Cylinder HC-200 (+10.7%), Seal Kit SK-15 (+9.5%), Light Assembly LA-18 (+9.0%).
2. **Declining products:** Track Roller TR-60 (-25.7%), Radiator RD-250 (-20.5%), Pivot Pin PP-12 (-18.3%), Hydraulic Hose HH-60 (-17.9%), Wheel Rim WR-24 (-17.7%).
3. **Radiator RD-250** was fast-moving over 12 months but is now declining sharply.
4. **Cabin Glass CG-20 and Light Assembly LA-18** were slow-moving over 12 months but are now growing.
5. **Movement classes are relative:** Every product sold between ~6,300 and ~7,500 units over 12 months.
6. **Engine Block EB-600** is slow-moving by units (6,318) but was the top profit product in Week 5 due to high value per unit.

### Provisional (stock-based):

7. **No product shows as out of stock, critical, or at reorder level** under recorded figures.
8. **Largest stock-to-sales imbalances (understock):** CHN001 Idler Wheel IW-55 (-7.1 pts), CHN001 O-Ring Set OR-50 (-6.5 pts), KOL001 Wheel Rim WR-24 (-6.2 pts), KOL001 Turbocharger TB-900 (-5.7 pts).
9. **Days of cover ranking:** CHN001 has the lowest (29K) and HYD001 the highest (42K).

---

## Business Recommendations
1. **Flag Radiator RD-250 to Procurement now** due to sharp sales decline.
2. **Monitor Cabin Glass CG-20 and Light Assembly LA-18** for sustained growth.
3. **Use a 20% threshold for trend alerts** to account for sample size variations.

---

## Data Quality and Validation Log

### Check 1: Column names
Queries ran successfully without column errors.

### Check 2: Order status
Excluded 1,967 cancelled orders; utilized 18,033 delivered orders.

### Check 3: Duplicate stock rows
No duplicate product_id and branch_id pairs found in inventory_master.

### Check 4: Ledger reconciliation
166 of 180 pairs match. 14 mismatches remain under review.

### Check 5: Scale of stock figures
Current stock is ~300 times max_stock for every product, representing a critical open validation item.

---

## Scrum Master Notes

**Sprint Goal:** Identify products needing replenishment and stock imbalances across branches.  
**Actual Output:** Six SQL queries, validation log, and Inventory Management Overview dashboard (replenishment list returned 0 rows).  
**Recommendation:** Present stock figures with provisional labels until unit and max_stock questions are resolved.  
**Confidence Level:** High for sales-based findings; low for stock-based findings pending verification.

---

## SQL Queries

### Shared Base CTEs

```sql
WITH ref AS (
  SELECT MAX(order_date) AS ref_date
  FROM sales_orders_header
),
sales_12m AS (
  SELECT
    sol.product_id,
    soh.branch_id,
    SUM(sol.quantity) AS units_sold_12m
  FROM sales_orders_lines AS sol
  JOIN sales_orders_header AS soh ON sol.so_id = soh.so_id
  CROSS JOIN ref
  WHERE soh.order_date > ref.ref_date - 365
    AND soh.order_status = 'Delivered'
  GROUP BY sol.product_id, soh.branch_id
),
stock AS (
  SELECT
    i.product_id,
    i.branch_id,
    p.product_name,
    p.category,
    p.criticality_level,
    p.lead_time_days,
    i.current_stock,
    i.reorder_level,
    i.safety_stock,
    i.max_stock,
    COALESCE(s.units_sold_12m, 0) AS units_sold_12m
  FROM inventory_master AS i
  JOIN products AS p ON i.product_id = p.product_id
  LEFT JOIN sales_12m AS s ON i.product_id = s.product_id AND i.branch_id = s.branch_id
)
```

### Query 1: Stock Status by Product and Branch
```sql
SELECT
  product_id, branch_id, product_name, category,
  current_stock, reorder_level, safety_stock,
  CASE
    WHEN current_stock <= 0 THEN 'Out of stock'
    WHEN current_stock <= safety_stock THEN 'Critical (below safety stock)'
    WHEN current_stock <= reorder_level THEN 'Reorder level reached'
    ELSE 'OK'
  END AS stock_status
FROM stock
ORDER BY current_stock ASC;
```

### Query 2: Sales Trend by Product
```sql
, sales_trend AS (
  SELECT
    sol.product_id,
    SUM(CASE WHEN soh.order_date > ref.ref_date - 90 THEN sol.quantity ELSE 0 END) AS units_last_90d,
    SUM(CASE WHEN soh.order_date > ref.ref_date - 180
              AND soh.order_date <= ref.ref_date - 90 THEN sol.quantity ELSE 0 END) AS units_prev_90d
  FROM sales_orders_lines AS sol
  JOIN sales_orders_header AS soh ON sol.so_id = soh.so_id
  CROSS JOIN ref
  WHERE soh.order_status = 'Delivered'
  GROUP BY sol.product_id
)
SELECT
  p.product_id, p.product_name, p.category,
  COALESCE(SUM(s.units_sold_12m), 0) AS units_sold_12m,
  st.units_last_90d,
  st.units_prev_90d,
  ROUND((st.units_last_90d - st.units_prev_90d) * 100.0 / NULLIF(st.units_prev_90d, 0), 1) AS trend_pct
FROM products AS p
LEFT JOIN sales_12m AS s ON p.product_id = s.product_id
LEFT JOIN sales_trend AS st ON p.product_id = st.product_id
GROUP BY p.product_id, p.product_name, p.category, st.units_last_90d, st.units_prev_90d
ORDER BY trend_pct DESC NULLS LAST;
```

### Query 3: Fast, Medium, and Slow Movers
```sql
, product_units AS (
  SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(s.units_sold_12m), 0) AS units_12m
  FROM products AS p
  LEFT JOIN sales_12m AS s ON p.product_id = s.product_id
  GROUP BY p.product_id, p.product_name
),
cutoffs AS (
  SELECT
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY units_12m) AS fast_cut,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY units_12m) AS slow_cut
  FROM product_units
)
SELECT
  pu.product_id,
  pu.product_name,
  pu.units_12m,
  CASE
    WHEN pu.units_12m >= c.fast_cut THEN 'Fast-moving'
    WHEN pu.units_12m <= c.slow_cut THEN 'Slow-moving'
    ELSE 'Medium-moving'
  END AS movement_class
FROM product_units AS pu
CROSS JOIN cutoffs AS c
ORDER BY pu.units_12m DESC;
```

### Query 4: Stock Availability by Branch
```sql
SELECT
  branch_id,
  COUNT(*) AS products_stocked,
  COUNT(CASE WHEN current_stock <= 0 THEN 1 END) AS out_of_stock,
  COUNT(CASE WHEN current_stock > 0 AND current_stock <= safety_stock THEN 1 END) AS critical,
  COUNT(CASE WHEN current_stock > safety_stock AND current_stock <= reorder_level THEN 1 END) AS reorder_level_reached,
  SUM(current_stock) AS total_units_in_stock,
  SUM(units_sold_12m) AS units_sold_12m,
  ROUND(SUM(current_stock) * 365.0 / NULLIF(SUM(units_sold_12m), 0), 0) AS days_of_cover
FROM stock
GROUP BY branch_id
ORDER BY days_of_cover DESC NULLS LAST;
```

### Query 5: Products Requiring Replenishment
```sql
SELECT
  product_id, branch_id, product_name, category, criticality_level,
  current_stock, reorder_level, lead_time_days,
  ROUND(current_stock * 365.0 / NULLIF(units_sold_12m, 0), 0) AS days_of_cover,
  GREATEST(max_stock - current_stock, 0) AS suggested_order_qty
FROM stock
WHERE current_stock <= reorder_level
   OR (units_sold_12m > 0 AND current_stock * 365.0 / units_sold_12m < lead_time_days)
ORDER BY days_of_cover ASC NULLS LAST, current_stock ASC;
```

### Query 6: Stock Distribution and Imbalance Across Branches
```sql
SELECT
  x.*,
  x.stock_share_pct - x.sales_share_pct AS imbalance_pts
FROM (
  SELECT
    product_id, branch_id, product_name,
    current_stock, units_sold_12m,
    ROUND(current_stock * 100.0 / NULLIF(SUM(current_stock) OVER (PARTITION BY product_id), 0), 1) AS stock_share_pct,
    ROUND(units_sold_12m * 100.0 / NULLIF(SUM(units_sold_12m) OVER (PARTITION BY product_id), 0), 1) AS sales_share_pct
  FROM stock
) AS x
ORDER BY ABS(x.stock_share_pct - x.sales_share_pct) DESC NULLS LAST;
```

---
## Output Files

- `stock_status_by_product_branch.csv`
- `sales_trend_by_product.csv`
- `movement_classification.csv`
- `branch_stock_availability.csv`
- `replenishment_list.csv`
- `stock_distribution_imbalance.csv`
---
### Files in this Directory
```text

├── README.md (this file)
├── queries/
│    
├── data/
│   ├── stock_status_by_product_branch.csv
│   ├── sales_trend_by_product.csv
│   ├── movement_classification.csv
│   ├── branch_stock_availability.csv
│   ├── replenishment_list.csv
│   └── stock_distribution_imbalance.csv
└── dashboards/
    └── inventory_Analysis_dashboard.pbix
