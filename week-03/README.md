# 🔍 Week 03: Product Performance Analysis 

**Status:** Completed

## Project Overview
The purpose of

**Stakeholder:** Operations Manager / Inventory Team

---

## Team

| Name | Role | Task |
|------|------|------|
| [@MLGideon](https://github.com/MLGideon) | Scrum Master & Dashboard Developer | Power BI visualization, stakeholder presentation |
| [@Ruth-Imoni](https://github.com/Ruth-Imoni) | SQL Data Analyst | Query design, database analysis, findings |

---

## Business Questions

1. What are the Top 10 Product by revenue, Quantity Sold
2. How much inventory is tied up in slow-moving products?
3. Which branches have the most dead stock?
4. What product categories are most affected by slow movement?
5. How long has the slowest-moving inventory been sitting idle?

---

## Datasets Used

- `stock_ledger.csv` — Product movement history (IN/OUT transactions)
- `inventory_master.csv` — Current stock levels by product and branch
- `products.csv` — Product names, categories, and metadata

---

## Tech Stack

- **Database:** PostgreSQL
- **Query Language:** SQL
- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables

1. SQL query identifying 180 slow-moving products
2. CSV export with product details and last sales dates
3. Power BI dashboard with interactive filters by branch and category
4. Analysis findings and recommendations for the Operations team

---

## Dashboard

![Slow Movers Dashboard]

---

## Analysis & Results

### Executive Summary

The analysis identified 180 products with zero sales activity for 90+ days. These products collectively represent 99,000+ units of inventory across multiple branches, tying up significant warehouse space and capital.

### Key Findings

1. **Total Slow-Moving Products:** 180 across all branches
2. **Inventory Volume:** Current stock ranges from thousands to 99,000+ units per product
3. **Time Since Last Sale:** Products haven't sold for 1+ years
4. **Distribution:** Multiple high-value products stuck across different warehouse locations
5. **Impact:** Dead stock consumes prime warehouse real estate and ties up working capital

### Data Quality

- No duplicates or missing values in stock ledger OUT movements
- All required fields populated in inventory master
- Stock levels current as of analysis date
- Analysis covers 100% of inventory transactions

---

## Scrum Master Notes

**Sprint Goal:** Identify slow-moving inventory by branch to reduce dead stock  
**Actual Output:** 180 products flagged, 4 dashboard visuals created  
**Challenges:** None. Data quality was clean across all three tables  
**Next Steps:** Present findings to Operations Manager for clearance decisions  
**Confidence Level:** High. Analysis covers the complete dataset with no data gaps

---

## SQL Query

```sql
---Identify products with no sales in 90+ days by branch to reduce dead stock and understand inventory risk---

SELECT s.product_id, s.branch_id, product_name, category, current_stock,
AGE(CURRENT_DATE, MAX(movement_date)) AS last_sales_day
FROM stock_ledger AS s
JOIN products AS p ON s.product_id = p.product_id
JOIN inventory_master AS i ON s.product_id = i.product_id AND s.branch_id = i.branch_id
WHERE movement_type = 'OUT'
GROUP BY s.product_id, s.branch_id, product_name, category, current_stock
HAVING AGE(CURRENT_DATE, MAX(movement_date)) >= '90 days'
ORDER BY last_sales_day DESC;
```

---

## Output Files

- `slow_movers_results.csv` — 180 products with product ID, branch, name, category, current stock, and days since last sale

---

## Dashboard Visuals

1. **Table:** Product name, branch location, last sales date, current stock (sorted by oldest first)
2. **Card:** Total count of slow-moving products (180)
3. **Slicer:** Filter by branch location
4. **Bar Chart:** Count of slow movers by product category

---

## Recommendations

1. Conduct a clearance sale on products idle for 1+ years
2. Review pricing strategy for products idle for 6-12 months
3. Investigate why certain categories have higher slow-mover rates
4. Implement automated alerts when products reach the 180-day mark
5. Allocate warehouse space based on velocity, not just volume

---

## Files in This Directory

```text
week-02/
├── README.md (this file)
├── queries/
│ └── slow_movers_analysis.sql
├── data/
│ └── slow_movers_results.csv
└── dashboards/
└── slow_movers_dashboard.pbix
