-- This query calculates how much each customer has spent, how often they order, and when they last purchased
-- We'll use this to identify valuable customers and their patterns

SELECT 
  c.customer_id,
  c.customer_type,
  COUNT(DISTINCT so.so_id) as total_orders,
  ROUND(AVG(so.grand_total), 2) as avg_order_value,
  SUM(so.grand_total) as total_revenue,
  MAX(so.order_date) as last_purchase_date,
  ROUND(((CURRENT_DATE - MAX(so.order_date)) / 30.5)::numeric, 1) AS months_since_purchase
FROM customers AS c
LEFT JOIN sales_orders_header AS so ON c.customer_id = so.customer_id
GROUP BY c.customer_id, c.customer_type
HAVING COUNT(DISTINCT so.so_id) > 0
ORDER BY total_revenue DESC;



-- RFM is a customer segmentation technique
-- R = Recency (how recently did they buy?) 
-- F = Frequency (how often do they buy?)
-- M = Monetary (how much do they spend?)
-- We score each customer 1-5 on each dimension

-- First, find the most recent order date in the entire dataset
-- This becomes our "reference point" instead of today's date

WITH max_date AS (
  SELECT MAX(so.order_date) as latest_date
  FROM sales_orders_header as so
),

customer_behavior AS (
  SELECT 
    c.customer_id,
    c.customer_type,
    COUNT(DISTINCT so.so_id) as frequency,
    SUM(so.grand_total) as monetary,
    (SELECT latest_date FROM max_date) - MAX(so.order_date) as recency_days
    
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
      WHEN recency_days <= 30 THEN 5    -- Recently active within dataset
      WHEN recency_days <= 60 THEN 4
      WHEN recency_days <= 90 THEN 3
      WHEN recency_days <= 180 THEN 2
      ELSE 1                             -- Long inactive
    END as recency_score,
    
    CASE 
      WHEN frequency >= 50 THEN 5
      WHEN frequency >= 25 THEN 4
      WHEN frequency >= 10 THEN 3
      WHEN frequency >= 5 THEN 2
      ELSE 1
    END as frequency_score,
    
    CASE 
      WHEN monetary >= 1000000 THEN 5
      WHEN monetary >= 500000 THEN 4
      WHEN monetary >= 200000 THEN 3
      WHEN monetary >= 50000 THEN 2
      ELSE 1
    END as monetary_score
    
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
  ROUND((recency_score + frequency_score + monetary_score)::numeric / 3, 2) as avg_rfm_score,
  CONCAT(recency_score, frequency_score, monetary_score) as rfm_segment

FROM rfm_scores
ORDER BY avg_rfm_score DESC;
			
-- Use RFM to categorize customers into actionable segments
-- Helps marketing/sales decide who to target

WITH max_date AS (
  SELECT MAX(so.order_date) as latest_date
  FROM sales_orders_header as so
),

customer_behavior AS (
  SELECT 
    c.customer_id,
    c.customer_type,
    COUNT(DISTINCT so.so_id) as frequency,
    SUM(so.grand_total) as monetary,
    (SELECT latest_date FROM max_date) - MAX(so.order_date) as recency_days
    
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
    END as recency_score,
    
    CASE 
      WHEN frequency >= 50 THEN 5
      WHEN frequency >= 25 THEN 4
      WHEN frequency >= 10 THEN 3
      WHEN frequency >= 5 THEN 2
      ELSE 1
    END as frequency_score,
    
    CASE 
      WHEN monetary >= 1000000 THEN 5
      WHEN monetary >= 500000 THEN 4
      WHEN monetary >= 200000 THEN 3
      WHEN monetary >= 50000 THEN 2
      ELSE 1
    END as monetary_score
    
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
  END as customer_segment

FROM rfm_analysis
ORDER BY monetary DESC;


-- Find customers who haven't bought in 90 days+
-- Marketing can run re-engagement campaigns on these

SELECT 
  c.customer_id,
  c.customer_type,
  MAX(so.order_date) as last_purchase_date,
  	(SELECT MAX(order_date) FROM sales_orders_header) - MAX(so.order_date) AS days_inactive,
  COUNT(DISTINCT so.so_id) as lifetime_orders,
  SUM(so.grand_total) as lifetime_value
FROM customers AS c
LEFT JOIN sales_orders_header AS so ON c.customer_id = so.customer_id
WHERE so.so_id IS NOT NULL  
GROUP BY c.customer_id, c.customer_type
HAVING (SELECT MAX(order_date) FROM sales_orders_header) - MAX(so.order_date) >= 90
ORDER BY lifetime_value DESC;







			