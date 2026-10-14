# 🔍 Week 06: Geographic Sales Performance 

**Status:** Completed

## Project Overview

Evaluated regional and branch sales performance across 6 branches and 18K orders to identify growth opportunities and underperforming locations. The analysis highlights the South region as the market leader with 9.9bn in revenue (34% of total), while the North and East regions lag behind despite significant order volume.

**Stakeholder:** Regional Management / Growth Strategy

---

## Team

| Name | Role | Task |
|------|------|------|
| Tobi | SQL Data Analyst | Regional queries & customer distribution analysis |
| Ruth | Dashboard Developer | Regional sales Power BI dashboard |

---

## Business Questions

1. Which branches and regions generate the highest sales revenue?
2. How does order volume correlate with overall revenue generation across hubs?
3. How are unique customers distributed across regions?
4. Which regions are underperforming and require strategic intervention?
5. How do branch performance ratings (out of 8) align with financial metrics?

---

## Datasets Used

- `branches.csv` — Branch location metadata and performance scores
- `sales_orders_header.csv` — Regional sales orders and order values
- `sales_orders_lines.csv` — Line item order quantities and pricing
- `customers.csv` — Customer location and regional mapping

---

## Tech Stack

- **Database:** PostgreSQL
- **Query Language:** SQL (Joins, aggregations, window functions)
- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables

1. Regional SQL performance queries aggregating revenue, orders, and customer counts
2. Regional sales CSV output exports
3. Power BI Geographic Performance Dashboard featuring scatter plots and branch rankings
4. Regional growth recommendations for executive leadership

---

## Dashboard

![Geographic Sales Dashboard](./Geographic%20Analysis.png)

* 📥 **Power BI File:** [`Geographic_Sales_Dashboard.pbix`](./Geographic%20sales%20performance.pbix)

---

## Analysis & Results

### Executive Summary

Analysis across **6 main branches** and **18K total orders** generated **29bn** in overall revenue. The South region leads significantly at **9.9bn** (34% of total sales), anchored by Chennai South Hub. The North region represents the weakest performance at **4.5bn** (15% of total revenue), highlighting a clear geographic imbalance in sales conversion.

### Regional Breakdown

| Region | Revenue | Revenue % | Unique Customers % | Top Performing Branch |
|--------|---------|-----------|--------------------|----------------------|
| **South** | 9.9bn | 34% | 35.0% | Chennai South Hub (3.7K orders) |
| **West** | 9.4bn | 32% | 19.2% | Ahmedabad West Hub (3.1K orders) |
| **East** | 5.5bn | 19% | 14.0% | Kolkata East Depot (3.4K orders) |
| **North** | 4.5bn | 15% | 14.2% | Northern Regional Hub |

### Key Findings

1. **Market Leader:** South region dominates revenue generation (9.9bn) and customer concentration (35%).
2. **Top Hub:** Chennai South Hub leads all branches in revenue and order volume (3.7K orders).
3. **Underperforming Markets:** North (4.5bn) and East (5.5bn) lag significantly behind.
4. **Performance Scores:** Branch performance ratings range from 5.0 to 8.0 out of 8.

---

## Data Quality

- Verified all 18,000 order records joined accurately to regional branch IDs.
- Validated customer regional distributions against branch order headers.
- Confirmed zero unmapped or orphaned branch records.

---

## Scrum Master Notes

**Sprint Goal:** Identify regional growth opportunities and underperforming branch locations.  
**Actual Output:** SQL regional breakdown scripts, CSV branch metrics, and Power BI geographic dashboard.  
**Recommendation:** Replicate Chennai South Hub operational practices in low-performing North and East hubs.  
**Confidence Level:** High. Dataset covers 100% of order history and branch metadata.

---

## SQL Queries

### Query 1: Branch-level performance

```sql
SELECT 
b.branch_id,b.branch_name,b.city,b.state,b.region,b.warehouse_type,b.avg_monthly_revenue,b.monthly_operational_cost,b.total_employees,
COUNT(DISTINCT h.so_id) AS total_orders, SUM(h.grand_total) AS total_revenue, COUNT(DISTINCT h.customer_id) AS Unique_customers, 
CAST( SUM(h.grand_total)/NULLIF(COUNT(DISTINCT customer_id), 0) AS DECIMAL(18,2)) AS Revenue_per_customer FROM branches b 
LEFT JOIN sales_orders_header h ON b.branch_id=h.branch_id AND h.order_status='Delivered'
GROUP BY b.branch_id,b.branch_name,b.city,b.state,b.region,b.warehouse_type,b.avg_monthly_revenue,b.monthly_operational_cost,b.total_employees
ORDER BY total_revenue DESC
```

### QUERY 2: Regional sales performance

```sql
SELECT b.region, COUNT(DISTINCT b.branch_id) AS total_branches,
 COUNT(DISTINCT h.so_id) AS total_orders, SUM(h.grand_total) AS total_revenue,
COUNT(DISTINCT h.customer_id) AS Unique_customers, 
CAST(SUM(h.grand_total)/NULLIF(COUNT(DISTINCT h.so_id),0) AS DECIMAL(18,2)) AS average_order_value,
CAST(100.0 * SUM(h.grand_total)/NULLIF(SUM(SUM(h.grand_total)) OVER(), 0) AS DECIMAL(10,2)) AS Revenue_contribution_percentage
 FROM branches b LEFT JOIN sales_orders_header h ON b.branch_id=h.branch_id
AND h.order_status='Delivered'
GROUP BY b.region
ORDER BY total_revenue DESC
```
---
### Output Files
📊 `geographic_sales_results.csv` — Regional sales metrics export.
