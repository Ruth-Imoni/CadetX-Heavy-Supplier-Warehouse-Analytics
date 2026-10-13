# 🔍 Week 06: Geographic Sales Performance 

**Status:** Completed

## Project Overview


  
**Status:** Completed  
**Stakeholder:** Regional Sales Team

---

## Team

| Name | Role | Task |
|------|------|------|
| Ruth Imoni | SQL Data Analyst | Product margin & revenue queries |
| Tobi | Dashboard Developer | Power BI profitability dashboard |

---

## Business Questions

1. 
2.
3. 
4. 
5. 

---

## Datasets Used



---

## Tech Stack

- **Database:** PostgreSQL
- **Query Language:** SQL (CTEs, aggregations, margin calculations)
- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables


---

## Dashboard



---

## Analysis & Results
---

### Executive Summary



### Key Metrics

| Metric | Value |
|--------|-------|


### Key Findings

1. **Top Profit Driver:**
2. **Category Standouts:**
3. **Margin Disparity:** 
4. **Volume vs. Margin Mismatch:** 

---

## Data Quality

- 
- 
- 

---

## Scrum Master Notes

**Sprint Goal:** 
**Actual Output:** 
**Recommendation:** 

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


* 📜 **SQL Script:** 

---
### Output Files

