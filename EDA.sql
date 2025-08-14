
-- Total orders and revenue per month
SELECT 
  DATE_FORMAT(purchase_ts, '%Y-%m') AS month,
  COUNT(order_id) AS total_orders,
  ROUND(SUM(usd_price),2) AS total_revenue
FROM orders
WHERE purchase_ts IS  NOT NUll
GROUP BY month
ORDER BY month;


-- Year-over-year growth
SELECT
  YEAR(purchase_ts) AS year,
  COUNT(order_id) AS total_orders,
  ROUND(SUM(usd_price),2) AS total_revenue
FROM orders
WHERE purchase_ts IS  NOT NUll
GROUP BY year
ORDER BY year;

-- Year with the most revenue
 SELECT
  YEAR(purchase_ts) AS year,
  COUNT(order_id) AS total_orders,
  ROUND(SUM(usd_price),2) AS total_revenue
FROM orders
WHERE purchase_ts IS  NOT NUll
GROUP BY year
ORDER BY total_revenue DESC;


-- Revenue by country
SELECT 
  c.country_code,
  ROUND(SUM(o.usd_price), 2) AS total_revenue,
  COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.id
GROUP BY c.country_code
ORDER BY total_revenue DESC;

-- Revenue by region
SELECT 
  c.region,
  ROUND(SUM(o.usd_price), 2) AS total_revenue,
  COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.id
GROUP BY c.country_code
ORDER BY total_revenue DESC;


-- Top 10 best-selling products by quantity
SELECT 
  product_id, product_name, 
  COUNT(order_id) AS total_sold,
  ROUND(SUM(usd_price),2) AS revenue
FROM orders
GROUP BY product_id, product_name
ORDER BY total_sold DESC
LIMIT 10;


SELECT 
product_name, 
  COUNT(order_id) AS total_sold,
  ROUND(SUM(usd_price),2) AS revenue
FROM orders
GROUP BY product_name
ORDER BY total_sold DESC
LIMIT 10;


-- New vs Repeat customers
SELECT 
  customer_id,
  COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id;

-- Customers per country
SELECT 
  c.country_code,
  COUNT(DISTINCT o.customer_id) AS unique_customers
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.country_code
ORDER BY unique_customers DESC;



-- Refund rate per product
SELECT 
  o.product_id,
  COUNT(DISTINCT o.order_id) AS total_orders,
  COUNT(DISTINCT os.refund_ts) AS total_refunds,
  ROUND(COUNT(DISTINCT os.refund_ts) / COUNT(DISTINCT o.order_id) * 100, 2) AS refund_rate
FROM orders o
JOIN order_status os ON o.order_id = os.order_id
GROUP BY o.product_id
ORDER BY refund_rate DESC;


-- Average delivery time
SELECT 
  AVG(DATEDIFF(delivery_ts, ship_ts)) AS avg_delivery_days
FROM order_status
WHERE delivery_ts IS NOT NULL AND ship_ts IS NOT NULL;


-- Orders per sales channel
SELECT 
  purchase_platform,
  COUNT(order_id) AS total_orders,
  SUM(usd_price) AS revenue
FROM orders
GROUP BY purchase_platform
ORDER BY revenue DESC;


-- top 10 customers based on lifetime revenue contribution.
WITH customer_spend AS (
  SELECT 
    customer_id,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(usd_price), 2) AS total_spent
  FROM orders
  GROUP BY customer_id
)
SELECT *
FROM (
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS `rank`
  FROM customer_spend
) ranked_customers
WHERE `rank` <= 20;


-- top-performing products in each region.

SELECT 
  c.country_code,
  o.product_name,
  COUNT(o.order_id) AS total_sold,
  ROUND(SUM(o.usd_price), 2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.id
GROUP BY c.country_code, o.product_name
ORDER BY c.country_code, revenue DESC;




--  refund behavior between loyalty and non-loyalty customers.
-- Joins orders with customers and order_status to analyze refund rate by segment.

SELECT 
  c.loyalty_program,
  COUNT(os.order_id) AS total_orders,
  COUNT(os.refund_ts) AS total_refunds,
  ROUND(COUNT(os.refund_ts) / COUNT(os.order_id) * 100, 2) AS refund_rate
FROM order_status os
JOIN orders o ON os.order_id = o.order_id
JOIN customers c ON o.customer_id = c.id
GROUP BY c.loyalty_program;


-- Percentage of customers placing multiple orders per year.

WITH customer_orders AS (
  SELECT 
    customer_id,
    YEAR(purchase_ts) AS order_year,
    COUNT(order_id) AS orders_this_year
  FROM orders
  WHERE purchase_ts IS NOT NULL
  GROUP BY customer_id, YEAR(purchase_ts)
)
SELECT 
  order_year,
  COUNT(DISTINCT customer_id) AS unique_customers,
  SUM(CASE WHEN orders_this_year > 1 THEN 1 ELSE 0 END) AS repeat_customers,
  ROUND(SUM(CASE WHEN orders_this_year > 1 THEN 1 ELSE 0 END) / COUNT(DISTINCT customer_id) * 100, 2) AS repeat_rate_pct
FROM customer_orders
GROUP BY order_year
ORDER BY order_year;


-- Annual revenue contribution by each marketing channel.


SELECT 
  YEAR(o.purchase_ts) AS year,
  c.marketing_channel,
  ROUND(SUM(o.usd_price), 2) AS total_revenue,
  COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE purchase_ts AND marketing_channel IS NOT NULL
GROUP BY year, c.marketing_channel
ORDER BY year, total_revenue DESC;


--  Average order value for each product.


SELECT 
  product_id,
  product_name,
  COUNT(order_id) AS total_orders,
  ROUND(SUM(usd_price), 2) AS total_revenue,
  ROUND(AVG(usd_price), 2) AS avg_order_value
FROM orders
GROUP BY product_id, product_name
ORDER BY total_orders DESC;

--  AOV by product name (aggregating across similar product IDs).

SELECT 
  product_name,
  COUNT(order_id) AS total_orders,
  ROUND(SUM(usd_price), 2) AS total_revenue,
  ROUND(AVG(usd_price), 2) AS avg_order_value
FROM orders
GROUP BY product_name
ORDER BY avg_order_value DESC;



SELECT 
  o.order_id,
  o.customer_id,
  o.product_id,
  o.product_name,
  o.purchase_ts,
  o.purchase_platform,
  o.usd_price,
  o.currency,
  o.local_price,
  os.ship_ts,
  os.delivery_ts,
  os.refund_ts,
  c.created_on,
  c.loyalty_program,
  c.account_creation_method,
  c.marketing_channel
FROM orders o
LEFT JOIN order_status os ON o.order_id = os.order_id
LEFT JOIN customers c ON o.customer_id = c.id;



CREATE TABLE orders_full AS
SELECT 
    o.order_id,
  o.customer_id,
  o.product_id,
  o.product_name,
  o.purchase_ts,
  o.purchase_platform,
  o.usd_price,
  o.currency,
  o.local_price,
  
  os.ship_ts,
  os.delivery_ts,
  os.refund_ts,
  
  c.created_on,
  c.loyalty_program,
  c.account_creation_method,
  c.marketing_channel

FROM orders o
LEFT JOIN (
    SELECT 
        order_id,
        MIN(ship_ts) AS ship_ts,
        MIN(delivery_ts) AS delivery_ts,
        MIN(refund_ts) AS refund_ts
    FROM order_status
    GROUP BY order_id
) os ON o.order_id = os.order_id
LEFT JOIN customers c ON o.customer_id = c.id;

describe orders_full
