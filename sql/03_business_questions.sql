-- ============ 12 BUSINESS QUESTIONS ============

-- Q1. What are total sales, profit, profit margin, orders and customers?
SELECT ROUND(SUM(sales), 2)                        AS total_sales,
       ROUND(SUM(profit), 2)                       AS total_profit,
       ROUND(100.0 * SUM(profit) / SUM(sales), 2)  AS profit_margin_pct,
       COUNT(DISTINCT order_id)                    AS total_orders,
       COUNT(DISTINCT customer_id)                 AS total_customers
FROM orders;

-- Q2. How did sales and profit grow year over year?
WITH yearly AS (
    SELECT strftime('%Y', order_date) AS year,
           SUM(sales) AS sales, SUM(profit) AS profit
    FROM orders GROUP BY year
)
SELECT year,
       ROUND(sales, 2)  AS sales,
       ROUND(profit, 2) AS profit,
       ROUND(100.0 * (sales - LAG(sales) OVER (ORDER BY year)) / LAG(sales) OVER (ORDER BY year), 2) AS sales_growth_pct
FROM yearly ORDER BY year;

-- Q3. Which months are the strongest for sales (seasonality)?
SELECT strftime('%m', order_date) AS month,
       ROUND(SUM(sales), 2) AS sales
FROM orders GROUP BY month ORDER BY month;

-- Q4. How do regions compare on sales, profit and margin?
SELECT region,
       ROUND(SUM(sales), 2)  AS sales,
       ROUND(SUM(profit), 2) AS profit,
       ROUND(100.0 * SUM(profit) / SUM(sales), 2) AS margin_pct
FROM orders GROUP BY region ORDER BY profit DESC;

-- Q5. Which categories bring the most sales and profit?
SELECT category,
       ROUND(SUM(sales), 2)  AS sales,
       ROUND(SUM(profit), 2) AS profit,
       ROUND(100.0 * SUM(profit) / SUM(sales), 2) AS margin_pct
FROM orders GROUP BY category ORDER BY sales DESC;

-- Q6. Which sub-categories are losing money?
SELECT category, sub_category,
       ROUND(SUM(sales), 2)  AS sales,
       ROUND(SUM(profit), 2) AS profit,
       ROUND(AVG(discount) * 100, 1) AS avg_discount_pct
FROM orders GROUP BY category, sub_category
HAVING SUM(profit) < 0
ORDER BY profit;

-- Q7. What are the top 10 products by profit?
SELECT product_name,
       ROUND(SUM(sales), 2)  AS sales,
       ROUND(SUM(profit), 2) AS profit
FROM orders GROUP BY product_name
ORDER BY profit DESC LIMIT 10;

-- Q8. How does discount level affect profit?
SELECT CASE
           WHEN discount = 0     THEN '1. No discount'
           WHEN discount <= 0.10 THEN '2. 1-10%'
           WHEN discount <= 0.20 THEN '3. 11-20%'
           WHEN discount <= 0.30 THEN '4. 21-30%'
           WHEN discount <= 0.50 THEN '5. 31-50%'
           ELSE '6. Above 50%'
       END AS discount_band,
       COUNT(*)              AS order_lines,
       ROUND(SUM(sales), 2)  AS sales,
       ROUND(SUM(profit), 2) AS profit,
       ROUND(100.0 * SUM(profit) / SUM(sales), 2) AS margin_pct
FROM orders GROUP BY discount_band ORDER BY discount_band;

-- Q9. Which customer segment is most valuable?
SELECT segment,
       COUNT(DISTINCT customer_id) AS customers,
       ROUND(SUM(sales), 2)  AS sales,
       ROUND(SUM(profit), 2) AS profit,
       ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM orders GROUP BY segment ORDER BY sales DESC;

-- Q10. Who are the top 10 customers by sales?
SELECT customer_name, segment,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(SUM(sales), 2)  AS sales,
       ROUND(SUM(profit), 2) AS profit
FROM orders GROUP BY customer_id, customer_name, segment
ORDER BY sales DESC LIMIT 10;

-- Q11. Which states make the biggest losses?
SELECT state, region,
       ROUND(SUM(sales), 2)  AS sales,
       ROUND(SUM(profit), 2) AS profit
FROM orders GROUP BY state, region
ORDER BY profit ASC LIMIT 10;

-- Q12. Which ship mode is used most, and how fast is it (average days to ship)?
SELECT ship_mode,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(100.0 * COUNT(DISTINCT order_id) / (SELECT COUNT(DISTINCT order_id) FROM orders), 1) AS pct_of_orders,
       ROUND(AVG(julianday(ship_date) - julianday(order_date)), 1) AS avg_days_to_ship
FROM orders GROUP BY ship_mode ORDER BY orders DESC;
