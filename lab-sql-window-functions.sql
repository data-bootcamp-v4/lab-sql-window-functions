USE sakila;

-- ============================================
-- Challenge 1:
-- ============================================
-- 1. Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.
SELECT title, length, RANK() OVER (ORDER BY length DESC) AS "rank"
FROM film
WHERE length IS NOT NULL AND length <> 0;

-- 2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.
SELECT title, length, rating, RANK() OVER(PARTITION BY rating ORDER BY length DESC) AS "rank"
FROM film
WHERE length IS NOT NULL AND length <> 0;

-- 3. Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in 
-- the greatest number of films, as well as the total number of films in which they have acted. 
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
WITH cte_total_film AS (
SELECT a.actor_id, CONCAT(a.first_name, " ", a.last_name) as name, COUNT(fa.film_id) AS total_film
FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id
),
top_actor AS (
    SELECT *
    FROM cte_total_film
    WHERE total_film = (SELECT MAX(total_film) FROM cte_total_film)
)
SELECT 
    f.title,
    t.name,
    t.total_film
FROM film AS f
CROSS JOIN top_actor AS t;

-- ==========================================
-- Challenge 2:
-- ==========================================
-- This challenge involves analyzing customer activity and retention in the Sakila database to gain 
-- insight into business performance. By analyzing customer behavior over time, businesses 
-- can identify trends and make data-driven decisions to improve customer retention and increase revenue.

-- The goal of this exercise is to perform a comprehensive analysis of customer activity and retention 
-- by conducting an analysis on the monthly percentage change in the number of active customers 
-- and the number of retained customers. 
-- Use the Sakila database and progressively build queries to achieve the desired outcome.

-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers 
-- who rented a movie in each month.
SELECT COUNT(DISTINCT r.customer_id) AS active_users,
    DATE_FORMAT(r.rental_date, '%Y') AS activity_year,
    DATE_FORMAT(r.rental_date, '%M') AS activity_month
FROM rental AS r
GROUP BY activity_year, activity_month
ORDER BY activity_year, activity_month;

DROP VIEW sakila.monthly_active_users;
CREATE VIEW sakila.monthly_active_users AS
SELECT COUNT(DISTINCT r.customer_id) AS active_users,
    DATE_FORMAT(r.rental_date, '%Y') AS activity_year,
    DATE_FORMAT(r.rental_date, '%M') AS activity_month
FROM rental AS r
GROUP BY activity_year, activity_month
ORDER BY activity_year, activity_month;

-- Step 2. Retrieve the number of active users in the previous month.
SELECT active_users, activity_year, activity_month, LAG(active_users, 1) OVER(ORDER BY activity_month) AS last_moth_active_users
FROM monthly_active_users;

-- Step 3. Calculate the percentage change in the number of active customers between the current 
-- and previous month.
WITH cte_view AS (
    SELECT active_users, activity_year, activity_month, LAG(active_users) OVER 
    (ORDER BY activity_year, activity_month) AS last_month_active_users
    FROM monthly_active_users
)
SELECT activity_year, activity_month, active_users, last_month_active_users,
    ROUND(CASE 
            WHEN last_month_active_users = 0 THEN NULL
            ELSE ((active_users - last_month_active_users) / last_month_active_users) * 100
        END, 2) AS percent_change
FROM cte_view
ORDER BY activity_year, activity_month;

-- Step 4. Calculate the number of retained customers every month, i.e., 
-- customers who rented movies in the current and previous months.
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
WITH monthly_customers AS (
    SELECT DISTINCT
        customer_id,
        YEAR(rental_date) AS activity_year,
        MONTH(rental_date) AS activity_month
    FROM rental
),
retained_customers AS (
    SELECT 
        curr.activity_year,
        curr.activity_month,
        COUNT(DISTINCT curr.customer_id) AS retained_count
    FROM monthly_customers curr
    JOIN monthly_customers prev
        ON curr.customer_id = prev.customer_id
        AND (
            (curr.activity_year = prev.activity_year 
             AND curr.activity_month = prev.activity_month + 1)
            OR
            (curr.activity_year = prev.activity_year + 1 
             AND curr.activity_month = 1 
             AND prev.activity_month = 12)
        )
    GROUP BY curr.activity_year, curr.activity_month
)
SELECT *
FROM retained_customers
ORDER BY activity_year, activity_month;




