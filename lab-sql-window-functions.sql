-- Challenge 1
-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.
-- 
-- Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.
-- 
SELECT title, length,
       RANK() OVER (ORDER BY length DESC) AS RANK1
FROM film
WHERE length IS NOT NULL AND length > 0;

-- Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.
-- 
 SELECT title, length, rating,
        RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS RANK1
 FROM film
 WHERE length IS NOT NULL AND LENGTH > 0;

-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted. Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
-- 
WITH ActorFilmCount AS (
    SELECT actor_id, COUNT(*) AS film_count
    FROM film_actor
    GROUP BY actor_id
),
MaxFilmCount AS (
    SELECT MAX(film_count) AS max_film_count
    FROM ActorFilmCount
),
MaxActor AS (
    SELECT a.actor_id, a.film_count
    FROM ActorFilmCount a
    CROSS JOIN MaxFilmCount m
    WHERE a.film_count = m.max_film_count
)
SELECT f.title, a.first_name, a.last_name, m.film_count
FROM film_actor fa
JOIN film f ON fa.film_id = f.film_id
JOIN actor a ON fa.actor_id = a.actor_id
JOIN MaxActor m ON a.actor_id = m.actor_id;

-- Challenge 2
-- This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.
-- 
-- The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an analysis on the monthly percentage change in the number of active customers and the number of retained customers. Use the Sakila database and progressively build queries to achieve the desired outcome.
-- 
-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
SELECT DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
       COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month;

-- Step 2. Retrieve the number of active users in the previous month.

WITH MonthlyActiveCustomers AS (
    SELECT DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
           COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY rental_month
)
SELECT rental_month, active_customers,
       LAG(active_customers) OVER (ORDER BY rental_month) AS previous_month_customers
FROM MonthlyActiveCustomers;

-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.


WITH MonthlyActiveCustomers AS (
    SELECT DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
           COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY rental_month
),
Previous_customers AS (
    SELECT 
        rental_month, 
        active_customers,
        LAG(active_customers) OVER (ORDER BY rental_month) AS previous_month_customers
    FROM MonthlyActiveCustomers
)
SELECT 
    rental_month, 
    active_customers,
    previous_month_customers,
    ROUND(((active_customers - previous_month_customers) / NULLIF(previous_month_customers, 0)) * 100, 2) AS percentage_change
FROM Previous_customers;

-- 
-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.


WITH RetainedCustomers AS (
    SELECT 
        DATE_FORMAT(r1.rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT r1.customer_id) AS retained_customers
    FROM rental r1
    JOIN rental r2 ON r1.customer_id = r2.customer_id
    WHERE 
        r1.rental_date <> r2.rental_date
    GROUP BY rental_month
)
SELECT 
    rc.rental_month, rc.retained_customers,
    LAG(rc.retained_customers) OVER (ORDER BY rc.rental_month) AS previous_month_retained_customers
FROM RetainedCustomers rc;


-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.