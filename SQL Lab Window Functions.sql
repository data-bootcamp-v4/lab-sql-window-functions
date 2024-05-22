-- SQL Lab Window Functions

USE sakila;

-- challenge 1
-- number one -- Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.
WITH RankedFilms AS (SELECT title, length,
RANK() OVER (ORDER BY length DESC) AS film_rank
FROM film
WHERE length IS NOT NULL AND length > 0)
SELECT title, length, film_rank
FROM RankedFilms;

-- number two -- Rank films by length within the rating category and create an output table
WITH RankedFilms AS (SELECT title, length, rating,
DENSE_RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS film_rank
FROM film
WHERE length IS NOT NULL AND length > 0)
SELECT title, length, rating, film_rank
FROM RankedFilms;

-- number three -- 

-- Step 1: Create a CTE to count the number of films per actor
WITH actor_film_count AS (SELECT fa.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS film_count
FROM film_actor fa
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id, a.first_name, a.last_name),

-- Step 2: Identify the actor with the maximum number of films
max_actor AS (SELECT actor_id, first_name, last_name, film_count
FROM actor_film_count
WHERE film_count = (SELECT MAX(film_count) FROM actor_film_count))

-- Step 3: Join with film_actor to get the list of films for the top actor
SELECT f.title, ma.first_name, ma.last_name, ma.film_count
FROM max_actor ma
JOIN film_actor fa ON ma.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id;

-- Challenge 2
-- number one -- Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

SELECT DATE_FORMAT(rental_date, '%Y-%m') AS month, COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
ORDER BY month;

-- number two -- Retrieve the number of active users in the previous month.

WITH monthly_active_customers AS (SELECT DATE_FORMAT(rental_date, '%Y-%m') AS month, COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m'))
SELECT m1.month AS current_month, m1.active_customers AS current_active_customers, m2.active_customers AS previous_active_customers
FROM monthly_active_customers m1
LEFT JOIN monthly_active_customers m2 ON DATE_SUB(m1.month, INTERVAL 1 MONTH) = m2.month
ORDER BY current_month;

-- number three - Calculate the percentage change in the number of active customers between the current and previous month.
WITH monthly_active_customers AS (SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m'))
SELECT m1.month AS current_month, m1.active_customers AS current_active_customers, m2.active_customers AS previous_active_customers, (m1.active_customers - m2.active_customers) / m2.active_customers * 100 AS percentage_change
FROM monthly_active_customers m1
LEFT JOIN monthly_active_customers m2 ON DATE_SUB(m1.month, INTERVAL 1 MONTH) = m2.month
ORDER BY current_month;

-- number four - Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.

WITH customer_monthly_activity AS (SELECT customer_id, DATE_FORMAT(rental_date, '%Y-%m') AS month
FROM rental
GROUP BY customer_id, DATE_FORMAT(rental_date, '%Y-%m')),
retained_customers AS (
SELECT c1.month AS current_month, COUNT(DISTINCT c1.customer_id) AS retained_customers
FROM customer_monthly_activity c1
JOIN customer_monthly_activity c2 ON c1.customer_id = c2.customer_id AND DATE_SUB(c1.month, INTERVAL 1 MONTH) = c2.month
GROUP BY c1.month)
SELECT current_month, retained_customers
FROM retained_customers
ORDER BY current_month;