# Week 10: Demand Forecast (SQL Baseline)

## Project Overview

Built a baseline forecast of units sold per product and branch over the next 90 days, using two simple methods, and tested both against past sales to measure accuracy. Neither method was consistently more accurate, so forecasts are shown as a range between the two. Stock is not part of this analysis.
 
**Stakeholders:** Procurement / Sales Planning

---

## Team

| Name | Role | Task |
|------|------|------|
| Ruth Imoni | SQL Data Analyst | Demand history, forecast, and backtest queries |
| Tobiloba Soyinka | Dashboard Developer | Baseline Demand Forecast dashboard |

---

## Business Questions

1. How many units is each product likely to sell at each branch over the next 90 days?
2. How accurate would each simple method have been on past sales?
3. Which products and branches show the largest change against last year?

---

## Method

- **Reference date:** Latest order date in `sales_orders_header` 
- **Filter:** Delivered orders only.
- **Method A (recent run rate):** Forecast equals units sold in the last 90 days.
- **Method B (same period last year):** Forecast equals units sold in the same 90 days one year earlier.
- **Change %:** Method A compared with Method B, by product and branch.
- **Backtest:** Actual sales are the 90 days from 180 to 90 days before the reference date. Method A and Method B are each built from the windows before that period. Accuracy is measured with WAPE (sum of absolute errors divided by sum of actuals).
- **Window 2:** The same backtest, shifted back 90 days, to test whether the first result holds.

---

## Datasets Used

- `sales_orders_header.csv` — so_id, branch_id, order_date, order_status
- `sales_orders_lines.csv` — so_id, product_id, quantity
- `products.csv` — product_id, product_name

---

## Tech Stack

- **Database:** PostgreSQL
- **Query Language:** SQL 
- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables

1. Monthly demand history by product (Query 1)
2. 90-day forecast by product and branch, both methods, with change % (Query 2)
3. Backtest accuracy by product (Query 3a)
4. Overall WAPE by method (Query 3b)
5. Window 2 backtest and summary (same code, shifted offsets)
6. Baseline Demand Forecast dashboard

---

## Dashboard

![Baseline Demand Forecast Dashboard](./Baseline%20Demand%20Forecast%20Snapshot.png)

* 📥 **Power BI File:** [`Demand_Forecast_Dashboard.pbix`](./Demand%20Forecast%20Analysis%20Dashboard.pbix)

---

## Dashboard Visuals

**Filters Available:**
* Branch ID

**Chart 1: Baseline Forecast by Branch (Method A)** Bar chart showing KOL001 highest at 9.4K units, then CHN001 (9.2K), DEL001 (8.2K), AHM001 (7.2K), PUN001 (7.1K), and HYD001 (6.9K).

**Chart 2: Baseline Forecast by Branch (Method B)** Bar chart showing CHN001 highest at 10.6K units, then KOL001 (9.6K), DEL001 (8.5K), HYD001 (7.6K), AHM001 (7.6K), and PUN001 (7.1K).

**Chart 3: Top 10 Products by Baseline Forecast (Method A)** Bar chart featuring Hydraulic Pump HP-300 (1,832), Hydraulic Cylinder HC-200 (1,816), Track Chain TC-45 (1,801), Engine Oil Filter OF-90 (1,750), and Control Valve CV-75 (1,713).

**Chart 4: Top 10 Products by Baseline Forecast (Method B)** Bar chart featuring Pressure Sensor PS-90 (2.1K), Air Filter AF-120 (1.9K), Engine Oil Filter OF-90 (1.9K), and Fuel Pump FP-350 (1.8K).

**Chart 5: Monthly Trend** Line chart showing monthly total units from `monthly_demand_history.csv` with partial final periods removed.

**Chart 6: Forecast Method Accuracy Comparison Table** Summary comparing Method A (Window 1: 10.70, Window 2: 10.80) against Method B (Window 1: 12.50, Window 2: 10.90).

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Baseline forecast range (next 90 days) | 47,955 to 50,937 units (Method A total to Method B total) |
| WAPE, Method A (window 1 / window 2) | 10.7% / 10.8% |
| WAPE, Method B (window 1 / window 2) | 12.5% / 10.9% |
| Products analysed | 30 |
| Branches | 6 (AHM001, CHN001, DEL001, HYD001, KOL001, PUN001) |

---

## Key Findings

1. **The two methods give different totals.** Method A forecasts about 48K units across all products and branches. Method B forecasts about 51K. The baseline range is 47,955 to 50,937 units.
2. **Accuracy is similar for both methods.** In window 1, Method A had lower error (10.7% against 12.5%). In window 2, the methods were level (10.8% against 10.9%).
3. **Branch rankings differ by method.** KOL001 leads under Method A, while CHN001 leads under Method B.
4. **Pressure Sensor PS-90 leads Method B.** It is also one of the fastest-moving products from Week 9 analysis.
5. **Change against last year is large for some products.** Changes above 20% are treated as signals to check.

---

## Business Recommendations

1. Use the forecast as a planning range (47,955 to 50,937 units), not a single target.
2. Check the top 10 products by forecast before placing orders.
3. Review products with changes above 20% in either direction against last year.
4. Re-run the backtest each quarter since accuracy results were unstable across windows.
5. Test branch-level accuracy before relying on branch forecasts for ordering.

---

## Data Quality and Limitations

### Method limits
* **Product-level backtest only:** Accuracy is measured per product across all branches; branch-level error is likely higher.
* **Two methods, neither clearly better:** Results are sensitive to the test window chosen.
* **Short horizon:** Forecast covers 90 days only.
* **Low-volume products:** Small monthly volumes make percentage changes less reliable.

### Interpretation Rules & Scope
* Changes and trend moves above ~20% are signals to check, not final conclusions.
* Stock is excluded entirely from this analysis.

---

## Scrum Master Notes

**Sprint Goal:** Give Procurement and Sales Planning a baseline range for the next 90 days, with a measured accuracy figure.  
**Actual Output:** Four SQL queries, window 2 backtest, six CSV exports, and baseline forecast dashboard.  
**Recommendation:** Report both methods as a range because accuracy metrics did not support choosing a single method.  
**Confidence Level:** Moderate. Accuracy is measured at the product level, and windows disagree on the preferred method.

---

## SQL Queries

### Query 1: Monthly Demand History

```sql
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
```

### Query 2: 90-Day Forecast by Product and Branch
```sql
WITH ref AS (
  SELECT MAX(order_date) AS ref_date
  FROM sales_orders_header
),
windows AS (
  SELECT
    soh.branch_id,
    sol.product_id,
    SUM(CASE WHEN soh.order_date > ref.ref_date - 90
              AND soh.order_date <= ref.ref_date
             THEN sol.quantity ELSE 0 END) AS units_last_90d,
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
  CASE
    WHEN w.units_same_period_ly = 0 THEN NULL
    ELSE ROUND((w.units_last_90d - w.units_same_period_ly) * 100.0 / w.units_same_period_ly, 1)
  END AS change_pct
FROM windows AS w
JOIN products AS p ON w.product_id = p.product_id
ORDER BY w.branch_id, change_pct DESC NULLS LAST;
```

### Query 3a: Backtest, Product Level (Window 1)
```sql
WITH ref AS (
  SELECT MAX(order_date) AS ref_date
  FROM sales_orders_header
),
backtest AS (
  SELECT
    sol.product_id,
    SUM(CASE WHEN soh.order_date > ref.ref_date - 180
              AND soh.order_date <= ref.ref_date - 90
             THEN sol.quantity ELSE 0 END) AS actual_units,
    SUM(CASE WHEN soh.order_date > ref.ref_date - 270
              AND soh.order_date <= ref.ref_date - 180
             THEN sol.quantity ELSE 0 END) AS forecast_a,
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
```

### Query 3b: Overall Accuracy (WAPE), Window 1
```sql
WITH ref AS (
  SELECT MAX(order_date) AS ref_date
  FROM sales_orders_header
),
backtest AS (
  SELECT
    sol.product_id,
    SUM(CASE WHEN soh.order_date > ref.ref_date - 180
              AND soh.order_date <= ref.ref_date - 90
             THEN sol.quantity ELSE 0 END) AS actual_units,
    SUM(CASE WHEN soh.order_date > ref.ref_date - 270
              AND soh.order_date <= ref.ref_date - 180
             THEN sol.quantity ELSE 0 END) AS forecast_a,
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
```

---

## Output Files
` monthly_demand_history.csv`
`demand_forecast_next_90d.csv`
`forecast_backtest_accuracy.csv`
`forecast_accuracy_summary.csv`
`forecast_backtest_accuracy_window2.csv`
` forecast_accuracy_summary_window2.csv`

---

## Files in This Directory
```text
├── README.md (this file)
├── queries/
│   ├── 01_monthly_demand_history.sql
│   ├── 02_demand_forecast_90d.sql
│   ├── 03a_backtest_product_level.sql
│   └── 03b_backtest_wape_summary.sql
├── data/
│   ├── monthly_demand_history.csv
│   ├── demand_forecast_next_90d.csv
│   ├── forecast_backtest_accuracy.csv
│   ├── forecast_accuracy_summary.csv
│   ├── forecast_backtest_accuracy_window2.csv
│   └── forecast_accuracy_summary_window2.csv
└── dashboards/
    └── demand_forecast_dashboard.pbix

---
