# 🔍 Week 03: Product Performance Analysis 

**Status:** Completed

## Project Overview 
The purpose is to assess product performance to identify high-performing, underperforming, and slow-moving products and generate actionable insights to support better inventory and sales decisions. 

**Stakeholder:** Sales Team

---

## Team

| Name | Role | Task |
|------|------|------|
| [@MLGideon](https://github.com/MLGideon) | Scrum Master & Dashboard Developer | Power BI visualization, stakeholder presentation |
| [@Ruth-Imoni](https://github.com/Ruth-Imoni) | SQL Data Analyst | Query design, database analysis, findings |

---

## Business Questions

1. What is the overall sales/revenue performance of the product?
2. What are the Top 10 products by revenue and Quantity Sold?
3. Which products are high-performing, under-performing, and slow-moving?
4. What are the revenue margin percentages by product category?
5.  What percentage of total revenue comes from the high-performing products?

---

## Datasets Used

- `Line_Sales_table.csv'
- `Sales_Header_Table.csv'
- `products.csv` — Product names, categories, and metadata

---

## Tech Stack

- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables

1. Power BI dashboard with interactive filters by Product ID
2. Analysis findings and recommendations for the Sales team

---

## Dashboard

![Product Health Analysis]

---

## Analysis & Results

### Executive Summary

The analysis identified the overall level of product performance to understand which products are performing well, underperforming, or struggling, and the reasons behind the distinctions across all product categories and branches.
### Key Findings

1. **Top 10 products by revenue and quantity sold**
2. **Total Revenue** 
3. **Total Order Value** 
4. **Product Segmentation:** Identified the High-performing, Under-Performing and slow-Moving Product and the reason behind it - The analysis shows that changes in prices of the product is the key influencer in the product segmentation. 
5. **Margin Percentage by Category**

### Data Quality

- No duplicates or missing values in all datasets provided.
- 20,000 Sales Orders
- 30 Products

---

## Scrum Master Notes

**Sprint Goal:** Determine the overall product performance, identifying the top product by revenue and quantity sold, sales and high-performing product driving the revenue of the business and reason led to the under-performing products. 
**Actual Output:** Total Revenue, Sales, Product Table Summary and Product Segmentation
**Challenges:** None. Data quality was clean across all three tables  
**Next Steps:** Present findings to the sales team or manager
**Confidence Level:** High. Analysis covers the complete dataset with no data gaps

---

## SQL Query

No SQL Query was conducted. The analysis was mainly carried out using DAX measures to calculate Total Revenue & Quantity Sold. 

---

## Dashboard Visuals

1. **Table:** Product name, branch location, last sales date, current stock (sorted by oldest first)
2. **Card:** Total Order Value, Total revenue & Sum of Quantity
3. **Slicer:** Filter by Product ID
4. **Bar Chart:** Top 10 products by Revenue and Quantity Sold 
5. **Ribbon Chart:** Product Segmentation (High-performing, Underperforming & Slow )
6. **Table**: **Product-Demand Analysis

---

## Recommendations
1. The under-performing products (17), as captured in the analysis, are a result of price differentiation. Despite the high product demand, customers still find it very difficult to complete the orders due to price or shipment delivery. Therefore, the sales team needs to consider the price differentiation so as to increase the trust of the customers. 

---

## Files in This Directory

```text
week-02/
├── README.md (this file)
├──
└── dashboards/
└── Product Health Dashboard
