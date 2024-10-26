USE sakila;
--- CHALLENGE 1
--- 1

SELECT f.title, f.length, f.rating
FROM film AS F
WHERE f.length IS NOT NULL AND f.length > 0
ORDER BY f.length;

--- 2

SELECT f.title, f.length, f.rating,
RANK() OVER (PARTITION BY f.rating ORDER BY f.length) AS duration_rank
FROM film AS f
WHERE f.length IS NOT NULL AND f.length > 0
ORDER BY f.rating, f.length;

--- 3

WITH ActorMovieCounts AS (
SELECT
a.actor_id,
a.first_name,
a.last_name,
COUNT(fa.film_id) AS movie_count
FROM actor as a
JOIN film_actor as fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
)
SELECT first_name, last_name, movie_count
FROM ActorMovieCounts
WHERE movie_count = (SELECT MAX(movie_count) FROM ActorMovieCounts);

--- CHALLENGE 2
--- 1

WITH MonthlyActiveCustomers AS(
SELECT
DATE_FORMAT(rental_date,'%Y-%m') AS rental_month,
COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month)
SELECT * FROM MonthlyActiveCustomers;

--- 2

WITH MonthlyActiveCustomers AS(
SELECT
DATE_FORMAT(rental_date,'%Y-%m') AS rental_month,
COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month),
PreviousActiveCustomers AS(
SELECT rental_month, active_customers, LAG(active_customers) OVER (ORDER BY rental_month) AS previous_active_costumers
FROM MonthlyActiveCustomers)
SELECT * FROM PreviousActiveCustomers;

--- 3

WITH MonthlyActiveCustomers AS(
SELECT
DATE_FORMAT(rental_date,'%Y-%m') AS rental_month,
COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month),
PreviousActiveCustomers AS(
SELECT rental_month, active_customers, LAG(active_customers) OVER (ORDER BY rental_month) AS previous_active_customers
FROM MonthlyActiveCustomers)
SELECT rental_month, active_customers, previous_active_customers, ((active_customers - previous_active_customers)/previous_active_customers * 100) AS percentage_change
FROM PreviousActiveCustomers
WHERE previous_active_customers IS NOT NULL;

--- 4

WITH MonthlyActiveCustomers AS (
SELECT 
DATE_FORMAT(rental_date, '%Y-%m') AS rental_month, customer_id
FROM rental
GROUP BY rental_month, customer_id),
RetentionCounts AS (
SELECT cm.rental_month, COUNT(DISTINCT cm.customer_id) AS retained_customers
FROM MonthlyActiveCustomers AS cm
JOIN MonthlyActiveCustomers AS pm ON cm.customer_id = pm.customer_id
WHERE pm.rental_month < cm.rental_montH
GROUP BY cm.rental_month)
SELECT * FROM RetentionCounts;
