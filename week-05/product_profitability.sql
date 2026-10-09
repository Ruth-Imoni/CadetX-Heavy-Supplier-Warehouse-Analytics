
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



--- Loss Making Products ---

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



