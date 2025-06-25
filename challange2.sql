-- This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. 
-- By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.

-- The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an analysis on the monthly percentage change in the number of active customers and the number of retained customers. Use the Sakila database and progressively build queries to achieve the desired outcome. 
USE sakila;
-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
-- Step 1: Count the number of unique customers who rented movies each month
SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM 
    rental
GROUP BY 
    DATE_FORMAT(rental_date, '%Y-%m')
ORDER BY 
    month;
-- Step 2. Retrieve the number of active users in the previous month.
-- Step 2: Prepare a list with current and previous month’s active customers
WITH monthly_activity AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT 
    curr.month,
    curr.active_customers,
    prev.active_customers AS prev_month_customers
FROM 
    monthly_activity curr
LEFT JOIN 
    monthly_activity prev 
    ON DATE_FORMAT(DATE_ADD(STR_TO_DATE(curr.month, '%Y-%m'), INTERVAL -1 MONTH), '%Y-%m') = prev.month;
-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
-- Step 3: Add percentage change calculation
WITH monthly_activity AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT 
    curr.month,
    curr.active_customers,
    prev.active_customers AS prev_month_customers,
    ROUND(
        (curr.active_customers - prev.active_customers) / prev.active_customers * 100, 
        2
    ) AS pct_change
FROM 
    monthly_activity curr
LEFT JOIN 
    monthly_activity prev 
    ON DATE_FORMAT(DATE_ADD(STR_TO_DATE(curr.month, '%Y-%m'), INTERVAL -1 MONTH), '%Y-%m') = prev.month;
-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
-- Step 4: Identify customers active in both current and previous months
WITH rentals_by_month AS (
    SELECT 
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS month
    FROM rental
    GROUP BY customer_id, DATE_FORMAT(rental_date, '%Y-%m')
),
paired_months AS (
    SELECT 
        curr.month,
        COUNT(*) AS retained_customers
    FROM rentals_by_month curr
    JOIN rentals_by_month prev
      ON curr.customer_id = prev.customer_id
     AND DATE_FORMAT(DATE_ADD(STR_TO_DATE(curr.month, '%Y-%m'), INTERVAL -1 MONTH), '%Y-%m') = prev.month
    GROUP BY curr.month
)
SELECT * FROM paired_months
ORDER BY month;

-- *Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.*