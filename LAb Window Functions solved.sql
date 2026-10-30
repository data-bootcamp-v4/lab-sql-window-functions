-- ============================================================
-- Lab: Window Functions - Sakila Database
-- Author: Data Analyst / Data Engineer
-- Description: Solutions for Challenge 1 & Challenge 2
-- ============================================================

USE sakila;

-- ============================================================
-- CHALLENGE 1: RANK() Function
-- ============================================================

-- ------------------------------------------------------------
-- 1.1 Rank films by their length
-- Output: title, length, rank
-- Filter: length IS NOT NULL AND length > 0
-- ------------------------------------------------------------
SELECT
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS length_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0
ORDER BY length_rank;


-- ------------------------------------------------------------
-- 1.2 Rank films by length within the rating category
-- Output: title, length, rating, rank
-- Filter: length IS NOT NULL AND length > 0
-- ------------------------------------------------------------
SELECT
    title,
    length,
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS length_rank_in_rating
FROM film
WHERE length IS NOT NULL
  AND length > 0
ORDER BY rating, length_rank_in_rating;


-- ------------------------------------------------------------
-- 1.3 For each film, list the actor/actress who has acted
--     in the greatest number of films (the "most prolific actor")
--     as well as the total number of films in which they acted.
--
-- Approach: 
--   Step A: CTE to count total films per actor.
--   Step B: CTE to rank actors within each film by their total film count.
--   Step C: Join with film and actor tables to retrieve names.
-- ------------------------------------------------------------
WITH actor_film_count AS (
    -- Total number of films each actor has acted in
    SELECT
        actor_id,
        COUNT(*) AS total_films
    FROM film_actor
    GROUP BY actor_id
),
film_actor_ranking AS (
    -- For each film, rank actors by their total film count (descending)
    SELECT
        fa.film_id,
        fa.actor_id,
        afc.total_films,
        RANK() OVER (PARTITION BY fa.film_id ORDER BY afc.total_films DESC) AS actor_rank
    FROM film_actor fa
    INNER JOIN actor_film_count afc
        ON fa.actor_id = afc.actor_id
)
SELECT
    f.title AS film_title,
    CONCAT(a.first_name, ' ', a.last_name) AS most_prolific_actor,
    far.total_films AS actor_total_films
FROM film_actor_ranking far
INNER JOIN film f
    ON far.film_id = f.film_id
INNER JOIN actor a
    ON far.actor_id = a.actor_id
WHERE far.actor_rank = 1
ORDER BY f.title;


-- ============================================================
-- CHALLENGE 2: Customer Activity & Retention Analysis
-- ============================================================

-- ------------------------------------------------------------
-- Step 1. Monthly Active Customers (unique customers per month)
-- ------------------------------------------------------------
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT
    rental_month,
    active_customers
FROM monthly_active
ORDER BY rental_month;


-- ------------------------------------------------------------
-- Step 2. Active users in the previous month (using LAG)
-- ------------------------------------------------------------
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT
    rental_month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY rental_month) AS prev_month_active_customers
FROM monthly_active
ORDER BY rental_month;


-- ------------------------------------------------------------
-- Step 3. Percentage change in active customers (MoM)
-- ------------------------------------------------------------
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
),
monthly_comparison AS (
    SELECT
        rental_month,
        active_customers,
        LAG(active_customers) OVER (ORDER BY rental_month) AS prev_month_active
    FROM monthly_active
)
SELECT
    rental_month,
    active_customers,
    prev_month_active,
    ROUND(
        100.0 * (active_customers - prev_month_active) / NULLIF(prev_month_active, 0),
        2
    ) AS pct_change_mom
FROM monthly_comparison
ORDER BY rental_month;


-- ------------------------------------------------------------
-- Step 4. Retained customers every month
-- A customer is "retained" if they rented in both the current
-- month and the previous month.
--
-- Approach:
--   CTE 1: unique customer/month pairs.
--   CTE 2: self-join with LAG to check if the customer was
--          also active in the immediately preceding month.
--   Final: count retained customers per month.
-- ------------------------------------------------------------
WITH customer_monthly AS (
    -- Unique combinations of customer and rental month
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM rental
),
customer_with_prev AS (
    -- For each customer-month, retrieve the previous rental month (if any)
    SELECT
        customer_id,
        rental_month,
        LAG(rental_month) OVER (PARTITION BY customer_id ORDER BY rental_month) AS prev_rental_month
    FROM customer_monthly
),
retained_flags AS (
    -- Flag customers who were also active in the previous calendar month
    SELECT
        rental_month,
        customer_id,
        CASE
            WHEN prev_rental_month IS NOT NULL
             AND prev_rental_month = DATE_FORMAT(
                     DATE_SUB(STR_TO_DATE(CONCAT(rental_month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH),
                     '%Y-%m'
                 )
            THEN 1
            ELSE 0
        END AS is_retained
    FROM customer_with_prev
)
SELECT
    rental_month,
    SUM(is_retained) AS retained_customers
FROM retained_flags
GROUP BY rental_month
ORDER BY rental_month;