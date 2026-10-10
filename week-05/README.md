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
- **Query Language:** SQL (CTEs, aggregations, margin calculations)
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

Product Profitability Dashboard

* 📥 product_profitability_dashboard.pbix

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

### Query 1: Product Profitability & Margin Ranking

```sql
---Analyze product profitability ranking by total revenue, cost, gross profit, and margin %---

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(so.quantity * so.unit_price) AS total_revenue,
    SUM(so.quantity * p.unit_cost) AS total_cost,
    SUM(so.quantity * (so.unit_price - p.unit_cost)) AS gross_profit,
    ROUND((SUM(l.quantity * (so.unit_price - p.unit_cost)) / NULLIF(SUM(so.quantity * so.unit_price), 0)) * 100, 2) AS profit_margin_pct
FROM sales_orders_lines AS so
JOIN products AS p ON so.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY gross_profit DESC;
```
* 📜 **SQL Script:** [`Product Profitability.sql`](./product_profitability.sql)

---
### Output Files
📊 [`product_profitability.csv`](./product_profitability.csv) — Detailed product revenue, profit, and margin breakdown.
