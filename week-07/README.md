# Week 7: Customer Analytics

## Project Overview

Analyzed customer behavior across 500 active customers to measure lifetime value, purchase frequency, recency, and RFM segmentation. The goal was to identify high-value customers, detect inactive or at-risk accounts, and prioritize retention efforts. The analysis shows that Loyalist customers generate the largest share of revenue, while Hibernating and Cannot Lose Them segments represent the main retention risk.

**Status:** Completed  
**Stakeholder:** Sales / Marketing / Finance

---

## Team

| Name | Role | Task |
|------|------|------|
| Ruth | SQL Data Analyst | Customer behavior and RFM queries |
| Tobi | Dashboard Developer | Power BI customer analytics dashboard |

---

## Business Questions

1. Who are our highest-value customers?
2. Which customers purchase most frequently?
3. Which customers are becoming inactive?
4. Which customer segments generate the most revenue?
5. Which customer groups should be prioritized for retention?

---

## Datasets Used

- `customers.csv` — Customer master data and customer type
- `sales_orders_header.csv` — Order-level totals, order dates, customer IDs
- `sales_orders_lines.csv` — Line-item detail for order composition

---

## Tech Stack

- **Database:** PostgreSQL
- **Query Language:** SQL (CTEs, aggregations, CASE logic, date calculations)
- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables

1. Customer behavior analysis (revenue, orders, AOV, last purchase, months since purchase)
2. RFM scoring for all active customers using dataset-aligned recency
3. Customer segmentation into actionable groups
4. Inactive customer list (90+ days since last purchase)
5. Power BI Customer Analytics Dashboard

---

## Dashboard

![Customer Analytics Dashboard](./customer_analytics_dashboard.png)

* 📥 **Power BI File:** [`customer_analytics_dashboard.pbix`](./customer_analytics_dashboard.pbix)

---

## Dashboard Visuals

**Filters Available:**
* Customer ID
* Purchase Date

**Key Performance Cards:**
* Total Revenue: 32.42bn
* Total Customers: 500

**Chart 1: Total Revenue by Customer Segment** Horizontal bar chart showing Loyalist generating 12.8bn (largest revenue segment) and Cannot Lose Them contributing 8.3bn.

**Chart 2: Customer Count by Segment** Column chart detailing account distribution, led by Loyalist (189) and Cannot Lose Them (129).

**Chart 3: Total Revenue by Customer Type** Column chart highlighting Dealer accounts as the highest revenue contributor at 8.6bn.

**Chart 4: Customer Details Table** Detailed sortable view covering Customer ID, customer type, total orders, revenue, and RFM scores for individual account follow-ups.

---

## Analysis & Results

### Executive Summary

Analysis across 500 active customers generated **32.42bn** in total revenue. Roughly 65% of total revenue is tied up in the Loyalist and Cannot Lose Them segments, indicating that proactive retention is critical for safeguarding portfolio stability.

### Key Findings

1. **Revenue Backbone:** Loyalist customers drive 12.8bn, representing about 39.5% of total revenue.
2. **High-Value Concentration:** Champions form a small elite tier (32 customers) with high value per account.
3. **Retention Risk:** Hibernating (96 customers) and Cannot Lose Them (129 customers) pose the highest churn risk.
4. **Customer Type Leader:** Dealer accounts lead revenue generation across categories at 8.6bn.

---

## Data Quality

- Excluded customers with no sales orders using an inner filter on order IDs.
- Recency was calculated against the dataset's latest order date (`2024-12-18`) rather than current time, as the dataset is historical.
- Confirmed zero duplicate customer IDs in the output.

---

## Scrum Master Notes

**Sprint Goal:** Segment customers by value and behavior to prioritize retention and sales efforts.  
**Actual Output:** Four core SQL queries (behavior, RFM scores, segmentation, inactive list), CSV exports, and Power BI customer dashboard.  
**Key Decision:** Recency was recalibrated to the dataset's max order date to prevent all accounts from defaulting into the lowest recency score.  
**Confidence Level:** High. Covers all 500 active customers with orders.

---

## SQL Queries

### Query 1: Customer Behavior Analysis

```sql
-- Revenue, order count, average order value, last purchase, and months since purchase per customer

SELECT 
  c.customer_id,
  c.customer_type,
  COUNT(DISTINCT so.so_id) AS total_orders,
  ROUND(AVG(so.grand_total), 2) AS avg_order_value,
  SUM(so.grand_total) AS total_revenue,
  MAX(so.order_date) AS last_purchase_date,
  ROUND(((CURRENT_DATE - MAX(so.order_date)) / 30.5)::numeric, 1) AS months_since_purchase
FROM customers AS c
LEFT JOIN sales_orders_header AS so ON c.customer_id = so.customer_id
GROUP BY c.customer_id, c.customer_type
HAVING COUNT(DISTINCT so.so_id) > 0
ORDER BY total_revenue DESC;
```

### Query 2: RFM Scoring

```sql
-- RFM scores using the dataset's latest order date as the reference point

WITH max_date AS (
  SELECT MAX(so.order_date) AS latest_date
  FROM sales_orders_header AS so
),
customer_behavior AS (
  SELECT 
    c.customer_id,
    c.customer_type,
    COUNT(DISTINCT so.so_id) AS frequency,
    SUM(so.grand_total) AS monetary,
    (SELECT latest_date FROM max_date) - MAX(so.order_date) AS recency_days
  FROM customers AS c
  LEFT JOIN sales_orders_header AS so ON c.customer_id = so.customer_id
  WHERE so.so_id IS NOT NULL
  GROUP BY c.customer_id, c.customer_type
),
rfm_scores AS (
  SELECT 
    customer_id,
    customer_type,
    frequency,
    monetary,
    recency_days,
    CASE 
      WHEN recency_days <= 30 THEN 5
      WHEN recency_days <= 60 THEN 4
      WHEN recency_days <= 90 THEN 3
      WHEN recency_days <= 180 THEN 2
      ELSE 1
    END AS recency_score,
    CASE 
      WHEN frequency >= 50 THEN 5
      WHEN frequency >= 25 THEN 4
      WHEN frequency >= 10 THEN 3
      WHEN frequency >= 5 THEN 2
      ELSE 1
    END AS frequency_score,
    CASE 
      WHEN monetary >= 1000000 THEN 5
      WHEN monetary >= 500000 THEN 4
      WHEN monetary >= 200000 THEN 3
      WHEN monetary >= 50000 THEN 2
      ELSE 1
    END AS monetary_score
  FROM customer_behavior
)
SELECT 
  customer_id,
  customer_type,
  frequency,
  monetary,
  recency_days,
  recency_score,
  frequency_score,
  monetary_score,
  ROUND((recency_score + frequency_score + monetary_score)::numeric / 3, 2) AS avg_rfm_score,
  CONCAT(recency_score, frequency_score, monetary_score) AS rfm_segment
FROM rfm_scores
ORDER BY avg_rfm_score DESC;
```

### Query 3: Customer Segmentation

```sql
-- Assign each customer to an action-based segment using RFM scores

WITH max_date AS (
  SELECT MAX(so.order_date) AS latest_date
  FROM sales_orders_header AS so
),
customer_behavior AS (
  SELECT 
    c.customer_id,
    c.customer_type,
    COUNT(DISTINCT so.so_id) AS frequency,
    SUM(so.grand_total) AS monetary,
    (SELECT latest_date FROM max_date) - MAX(so.order_date) AS recency_days
  FROM customers AS c
  LEFT JOIN sales_orders_header AS so ON c.customer_id = so.customer_id
  WHERE so.so_id IS NOT NULL
  GROUP BY c.customer_id, c.customer_type
),
rfm_analysis AS (
  SELECT 
    customer_id,
    customer_type,
    frequency,
    monetary,
    recency_days,
    CASE 
      WHEN recency_days <= 30 THEN 5
      WHEN recency_days <= 60 THEN 4
      WHEN recency_days <= 90 THEN 3
      WHEN recency_days <= 180 THEN 2
      ELSE 1
    END AS recency_score,
    CASE 
      WHEN frequency >= 50 THEN 5
      WHEN frequency >= 25 THEN 4
      WHEN frequency >= 10 THEN 3
      WHEN frequency >= 5 THEN 2
      ELSE 1
    END AS frequency_score,
    CASE 
      WHEN monetary >= 1000000 THEN 5
      WHEN monetary >= 500000 THEN 4
      WHEN monetary >= 200000 THEN 3
      WHEN monetary >= 50000 THEN 2
      ELSE 1
    END AS monetary_score
  FROM customer_behavior
)
SELECT 
  customer_id,
  customer_type,
  monetary,
  frequency,
  recency_days,
  CASE 
    WHEN recency_score = 5 AND frequency_score = 5 AND monetary_score = 5 THEN 'Champions'
    WHEN recency_score = 5 AND frequency_score >= 4 THEN 'Loyal Customers'
    WHEN recency_score = 5 AND monetary_score >= 4 THEN 'Big Spenders'
    WHEN recency_score >= 4 THEN 'At Risk (Declining)'
    WHEN recency_score = 3 THEN 'Needs Attention'
    WHEN recency_score <= 2 AND monetary_score >= 3 THEN 'Win Back'
    WHEN recency_score <= 2 THEN 'Lost'
    ELSE 'Other'
  END AS customer_segment
FROM rfm_analysis
ORDER BY monetary DESC;
```

### Query 4: Inactive Customers (90+ Days No Purchase)

```sql
-- Customers whose last order is 90+ days before the dataset's latest order date

SELECT 
  c.customer_id,
  c.customer_type,
  MAX(so.order_date) AS last_purchase_date,
  (SELECT MAX(order_date) FROM sales_orders_header) - MAX(so.order_date) AS days_inactive,
  COUNT(DISTINCT so.so_id) AS lifetime_orders,
  SUM(so.grand_total) AS lifetime_value
FROM customers AS c
LEFT JOIN sales_orders_header AS so ON c.customer_id = so.customer_id
WHERE so.so_id IS NOT NULL
GROUP BY c.customer_id, c.customer_type
HAVING (SELECT MAX(order_date) FROM sales_orders_header) - MAX(so.order_date) >= 90
ORDER BY lifetime_value DESC;
```

---

## Output Files
📊 `customer_behavior.csv` — Customer behavior and revenue metrics.

📊 `customer_rfm_scores.csv` — RFM breakdown scores.

📊 `customer_segments.csv` — Actionable customer segment mappings.

📊 `inactive_customers.csv` — List of inactive accounts (90+ days).

---

## Files in This Directory

```text
├── README.md (this file)
├── queries/
│   ├── 01_customer_behavior.sql
│   ├── 02_customer_rfm_scores.sql
│   ├── 03_customer_segments.sql
│   └── 04_inactive_customers.sql
├── data/
│   ├── customer_behavior.csv
│   ├── customer_rfm_scores.csv
│   ├── customer_segments.csv
│   └── inactive_customers.csv
└── dashboards/
    └── customer_analytics_dashboard.pbix
