SELECT 
    COUNT(*) AS total_records
FROM
    retail_sales;
DESCRIBE retail_sales;

-- Explore dataset
SELECT 
    *
FROM
    retail_sales
LIMIT 10;
SELECT 
    transaction_id, customer_id, product_name, total_amount
FROM
    retail_sales
LIMIT 10;

-- Data Quality: Is dataset clean enough for analysis?
-- Duplicate transaction IDs:
SELECT 
    transaction_id, COUNT(*) AS duplicate_count
FROM
    retail_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Missing values
SELECT 
    COUNT(*) AS total_rows,
    SUM(transaction_id IS NULL) AS missing_transaction_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(gender IS NULL) AS missing_gender,
    SUM(age IS NULL) AS missing_age,
    SUM(product_category IS NULL) AS missing_product_category,
    SUM(product_name IS NULL) AS missing_product_name,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(unit_price IS NULL) AS missing_unit_price,
    SUM(total_amount IS NULL) AS missing_total_amount,
    SUM(payment_method IS NULL) AS missing_payment_method,
    SUM(order_status IS NULL) AS missing_order_status
FROM
    retail_sales;

-- Invalid values check 
-- Quantity
SELECT 
    *
FROM
    retail_sales
WHERE
    quantity <= 0;
-- Price
SELECT 
    *
FROM
    retail_sales
WHERE
    unit_price <= 0;
-- Age
SELECT 
    *
FROM
    retail_sales
WHERE
    age < 18 OR age > 100;

-- Revenue calculation verify
SELECT 
    transaction_id,
    quantity,
    unit_price,
    total_amount,
    quantity * unit_price AS calculated_amount
FROM
    retail_sales
LIMIT 20;

-- Overall KPIs
SELECT 
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(total_amount), 2) AS total_sales,
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM
    retail_sales;

-- completed revenue
SELECT 
    COUNT(*) AS completed_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(total_amount), 2) AS completed_revenue,
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM
    retail_sales
WHERE
    order_status = 'Completed';

-- Product category analysis
SELECT 
    product_category,
    COUNT(*) AS orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(total_amount), 2) AS revenue
FROM
    retail_sales
WHERE
    order_status = 'Completed'
GROUP BY product_category
ORDER BY revenue DESC;

-- Top 10 products
SELECT 
    product_name,
    SUM(quantity) AS units_sold,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS revenue
FROM
    retail_sales
WHERE
    order_status = 'Completed'
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 10;

-- Monthly revenue
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    ROUND(SUM(total_amount), 2) AS revenue
FROM
    retail_sales
WHERE
    order_status = 'Completed'
GROUP BY YEAR(order_date) , MONTH(order_date)
ORDER BY year , month;

-- Country analysis
SELECT 
    country,
    COUNT(*) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(total_amount), 2) AS revenue
FROM
    retail_sales
WHERE
    order_status = 'Completed'
GROUP BY country
ORDER BY revenue DESC;

-- Customer Segment
SELECT 
    customer_segment,
    COUNT(*) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM
    retail_sales
WHERE
    order_status = 'Completed'
GROUP BY customer_segment
ORDER BY revenue DESC;

-- Top customers
SELECT 
    customer_id,
    COUNT(*) AS orders,
    SUM(quantity) AS units_purchased,
    ROUND(SUM(total_amount), 2) AS total_spent
FROM
    retail_sales
WHERE
    order_status = 'Completed'
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Order Status 
SELECT 
    order_status,
    COUNT(*) AS orders,
    ROUND(COUNT(*) * 100.0 / (SELECT 
                    COUNT(*)
                FROM
                    retail_sales),
            2) AS percentage
FROM
    retail_sales
GROUP BY order_status
ORDER BY orders DESC;

-- Return rate
SELECT 
    ROUND(SUM(order_status = 'Returned') * 100.0 / COUNT(*),
            2) AS return_rate
FROM
    retail_sales;
    
-- Payment Method 
SELECT 
    payment_method,
    COUNT(*) AS transactions,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(SUM(total_amount), 2) AS avg_transaction_value
FROM
    retail_sales
GROUP BY payment_method
ORDER BY revenue DESC;

-- Age Group
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS orders,
    ROUND(SUM(total_amount), 2) AS revenue
FROM
    retail_sales
WHERE
    order_status = 'Completed'
GROUP BY age_group
ORDER BY revenue DESC;

-- CTE
WITH monthly_sales AS (
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(total_amount) AS revenue
FROM
    retail_sales
WHERE
    order_status = 'Completed'
GROUP BY YEAR(order_date) , MONTH(order_date)
)
SELECT 
    year, month, ROUND(revenue, 2) AS revenue
FROM
    monthly_sales
ORDER BY year , month;

-- Window function
SELECT
    product_category,
    ROUND(SUM(total_amount), 2) AS revenue,
    RANK() OVER (
        ORDER BY SUM(total_amount) DESC
    ) AS revenue_rank
FROM retail_sales
WHERE order_status = 'Completed'
GROUP BY product_category;

-- View
CREATE OR REPLACE VIEW completed_sales AS
    SELECT 
        *
    FROM
        retail_sales
    WHERE
        order_status = 'Completed';

SELECT 
    *
FROM
    completed_sales
LIMIT 10;

SELECT 
    product_category, ROUND(SUM(total_amount), 2) AS revenue
FROM
    completed_sales
GROUP BY product_category
ORDER BY revenue DESC;

ALTER USER 'root'@'localhost' IDENTIFIED BY 'noor1515271';

CREATE USER 'powerbi'@'localhost' IDENTIFIED BY 'noor1515271';
GRANT SELECT ON retail_cv_db.* TO 'powerbi'@'localhost';