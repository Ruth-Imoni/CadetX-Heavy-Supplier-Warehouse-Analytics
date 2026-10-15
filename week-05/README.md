# Week 5: Product Profitability Analysis

## Project Overview

Analyzed product and category profitability across the heavy goods portfolio to identify top profit drivers and uncover low-margin or loss-making items. The analysis evaluated 20+ products, revealing a total gross profit of 5bn (45.83% gross margin) on 25bn total revenue, with Engine Block EB-600 leading as the primary profit driver.
  
**Status:** Completed  
**Stakeholder:** Finance / Product Management

---

## Team

| Name | Role | Task |
|------|------|------|
| Ruth Imoni | SQL Data Analyst | Product margin & revenue queries |
| Tobi | Dashboard Developer | Power BI profitability dashboard |

---

## Business Questions

1. Which specific products generate the highest total profit?
2. What is the overall gross profit margin across all categories?
3. Are there high-revenue products yielding unexpectedly low profit margins?
4. How does profitability vary across product categories?
5. Which products should be targeted for cost optimization or repricing?

---

## Datasets Used

- `products.csv` — Product metadata, costs, pricing, and categories
- `sales_orders_header.csv` — Order-level revenue and metadata
- `sales_orders_lines.csv` — Detailed line item sales and quantities

---

## Tech Stack

- **Database:** PostgreSQL
- **Query Language:** SQL 
- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables

1. SQL scripts evaluating revenue, cost, and gross profit by product and category
2. CSV output exports detailing product-level profit performance
3. Power BI Product Profitability Dashboard with scatter plots and category rankings
4. Executive findings and portfolio optimization recommendations

---

## Dashboard

![Product Profitability](./Product%20Profitability.png)

* 📥 [Product_Profitability.pbix](./Product%20profitability.pbix)

---

## Analysis & Results
---

### Executive Summary

Across 20+ heavy supplier products, total revenue reached **25bn** against **20bn** in cost, generating **5bn** in Gross Profit (45.83% overall gross profit margin). Profitability ranges significantly between products (from ~13% to ~46%). While top performers like Engine Block EB-600 drive significant bottom-line value, several high-revenue products suffer from low profit margins due to elevated component costs.

### Key Metrics

| Metric | Value |
|--------|-------|
| **Total Revenue** | 25bn |
| **Total Cost** | 20bn |
| **Gross Profit** | 5bn |
| **Gross Profit Margin** | 45.83% |
| **Top Profit Product** | Engine Block EB-600 (1.06bn) |

### Key Findings

1. **Top Profit Driver:** Engine Block EB-600 leads the portfolio with **1.06bn** in net profit.
2. **Category Standouts:** Attachments category demonstrates consistently strong profit margins.
3. **Margin Disparity:** Profit margins range from ~13% to ~46% across the catalog.
4. **Volume vs. Margin Mismatch:** High-revenue items identified in the scatter analysis underperform on margin %.

---

## Data Quality

- Verified product cost and pricing integrity against sales order quantities.
- Confirmed zero missing records across critical revenue and cost fields.
- Validated revenue calculations against header-level order totals.

---

## Scrum Master Notes

**Sprint Goal:** Identify profit drivers and underperforming products to guide product strategy.  
**Actual Output:** Comprehensive SQL scripts, CSV margin reports, and interactive Power BI dashboard.  
**Recommendation:** Focus marketing on the top 10 profit drivers and re-evaluate pricing for low-margin, high-revenue products.  **Confidence Level:** High. Analysis covers the complete product dataset with zero missing data gaps.

---

## SQL Queries

### Query 

```sql
--- Product Profitability ---

SELECT 
  p.product_id,
  p.product_name,
  p.category,
  p.unit_cost,
  p.unit_price,
  SUM(sol.quantity) as total_quantity_sold,
  SUM(sol.quantity * p.unit_price) as total_revenue,
  SUM(sol.quantity * p.unit_cost) as total_cost,
  SUM(sol.quantity * p.unit_price) - SUM(sol.quantity * p.unit_cost) as total_profit,
  ROUND(((SUM(sol.quantity * p.unit_price) - SUM(sol.quantity * p.unit_cost)) / SUM(sol.quantity * p.unit_price)) * 100, 2) as profit_margin_percent
FROM products AS p
JOIN sales_orders_lines AS sol ON p.product_id = sol.product_id
WHERE sol.quantity > 0
GROUP BY p.product_id, p.product_name, p.category, p.unit_cost, p.unit_price
ORDER BY total_profit DESC;



--- Loss-Making Products ---

SELECT 
  p.product_id,
  p.product_name,
  p.category,
  p.unit_cost,
  p.unit_price,
  SUM(sol.quantity) as total_quantity_sold,
  SUM(sol.quantity * p.unit_price) as total_revenue,
  SUM(sol.quantity * p.unit_cost) as total_cost,
  SUM(sol.quantity * p.unit_price) - SUM(sol.quantity * p.unit_cost) as total_profit,
  ROUND(((SUM(sol.quantity * p.unit_price) - SUM(sol.quantity * p.unit_cost)) / SUM(sol.quantity * p.unit_price)) * 100, 2) as profit_margin_percent
FROM products AS p
JOIN sales_orders_lines AS sol ON p.product_id = sol.product_id
WHERE sol.quantity > 0
GROUP BY p.product_id, p.product_name, p.category, p.unit_cost, p.unit_price
HAVING SUM(sol.quantity * p.unit_price) - SUM(sol.quantity * p.unit_cost) < 0
ORDER BY total_profit DESC;

--- The result for the loss products was empty, which means all products are profitable ---
```
* 📜 **SQL Script:** [`Product Profitability.sql`](./product_profitability.sql)

---

## Dashboard Visuals

**Filters Available:**
* Product Category (All, by category)
* Region (All, by region)

**Key Performance Cards:**
* Total Revenue: 25bn
* Gross Profit: 5bn
* Gross Profit Margin: 45.83%

**Chart 1: Total Profit by Product** Horizontal bar chart ranking all products by profit contribution, led by Engine Block EB-600 at 1.06bn profit.

**Chart 2: Top 10 Products by Profit** Vertical bar chart highlighting top profit drivers, including Engine Block EB-600 (1.06bn), Transmission Assembly TA-800 (0.68bn), and Boom Cylinder BC-400 (0.49bn).

**Chart 3: Profit Margin % by Category** Pie chart showing category distribution, featuring high-margin leaders like O-Ring Set (48.83%) and Grease Cartridge (47.94%).

**Chart 4: Revenue vs Profit Scatter Plot** Scatter plot displaying the relationship between total revenue and profit, identifying high-revenue items with low margins.

**Chart 5: Product Table** Sortable detailed view of product name, total revenue, total profit, and profit margin percentage.

---

### Output Files
📊 [`product_profitability.csv`](./product_profitability.csv) — Detailed product revenue, profit, and margin breakdown.

---

## Files in This Directory

```text
├── README.md (this file)
├── queries/
│ ├── 01 product profitability.sql
├── data/
│ ├── product profitability.csv
└── dashboards/
└── product profitability.pbix

