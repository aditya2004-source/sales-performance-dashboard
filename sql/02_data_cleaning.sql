-- ============ DATA QUALITY CHECKS ============

-- 1. Total rows loaded
SELECT COUNT(*) AS total_rows FROM orders;

-- 2. Missing values in key columns
SELECT
    SUM(CASE WHEN order_id   IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN sales      IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN profit     IS NULL THEN 1 ELSE 0 END) AS missing_profit
FROM orders;

-- 3. Exact duplicate rows
SELECT COUNT(*) AS duplicate_rows FROM (
    SELECT order_id, product_id, sales, quantity, discount, profit, COUNT(*) AS c
    FROM orders
    GROUP BY order_id, product_id, sales, quantity, discount, profit
    HAVING c > 1
);

-- 4. Remove exact duplicates (keep the first occurrence)
DELETE FROM orders
WHERE rowid NOT IN (
    SELECT MIN(rowid) FROM orders
    GROUP BY order_id, order_date, product_id, sales, quantity, discount, profit
);

-- 5. Invalid values (negative sales/quantity, discount outside 0-1, ship before order)
SELECT
    SUM(CASE WHEN sales <= 0 THEN 1 ELSE 0 END)              AS invalid_sales,
    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END)           AS invalid_quantity,
    SUM(CASE WHEN discount < 0 OR discount > 1 THEN 1 ELSE 0 END) AS invalid_discount,
    SUM(CASE WHEN ship_date < order_date THEN 1 ELSE 0 END)  AS ship_before_order
FROM orders;

-- 6. Rows after cleaning
SELECT COUNT(*) AS rows_after_cleaning FROM orders;
