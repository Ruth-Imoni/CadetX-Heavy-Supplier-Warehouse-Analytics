# 🔍 Week 03: Product Performance Analysis 

**Status:** Completed

## Project Overview
The purpose is to assess product performance to identify high-performing, underperforming, and slow moving products and generate action insights to support better inventory and sales decisions. 

**Stakeholder:** Sales / Inventory Team

---

## Team

| Name | Role | Task |
|------|------|------|
| [@MLGideon](https://github.com/MLGideon) | Scrum Master & Dashboard Developer | Power BI visualization, stakeholder presentation |
| [@Ruth-Imoni](https://github.com/Ruth-Imoni) | SQL Data Analyst | Query design, database analysis, findings |

---

## Business Questions

1. What is the overall sales/revenue performance of the product?
2. What are the Top 10 product by revenue and Quantity Sold?
3. Which products are high-performing, under-performing and slow moving?
4.  Which products have the highest inventory value ?
5.  What percentage of total revenue comes from the high-performing products?

---

## Datasets Used

- `Sales_Header_table.csv'
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

1. 
2. CSV export with product details and last sales dates
3. Power BI dashboard with interactive filters by branch and category
4. Analysis findings and recommendations for the Operations team

---

## Dashboard

![Product Health Analysis]

---

## Analysis & Results

### Executive Summary

The analysis identified the overall level of product performance to understand what products are performing well and underperforming or struggling and the reason behind the distinction of all product category across all branches.
### Key Findings

1. **Top 10 product by revenue amd Quantity Sold**
2. **Total Revenue** 
3. **Total sales** 
4. **Product Segmentation:** Identified the High-performing, Under-Performing and slow-Moving Product and the reason behind it - The analysis shows that changes in prices of the product is the key influencer in the product segmentation. 

### Data Quality

- No duplicates or missing values in all datasets provided. 

---

## Scrum Master Notes

**Sprint Goal:** Determine the overall level of performance of all product 
**Actual Output:** Total Revenue, Sales, Product Table Summary and Product Segmentation
**Challenges:** None. Data quality was clean across all three tables  
**Next Steps:** Present findings to the sales team or manager
**Confidence Level:** High. Analysis covers the complete dataset with no data gaps

---

## SQL Query

No SQL Query was conducted. The analysis was mainly carried out using powerBI

```

---

---

## Dashboard Visuals

1. **Table:** Product name, branch location, last sales date, current stock (sorted by oldest first)
2. **Card:** Total count of slow-moving products (180)
3. **Slicer:** Filter by branch location
4. **Bar Chart:** Count of slow movers by product category
5. **Ribbon Chart:** Product Segmentation (High-performing, Underperforming & Slow )

---

## Recommendations
1. 

---

## Files in This Directory

```text
week-02/
├── README.md (this file)
├──
└── dashboards/
└── Product Health Dashboard
