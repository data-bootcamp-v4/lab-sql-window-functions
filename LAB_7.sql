USE sakila;

-- CHALLENGE 1
-- 1. Rank films by their length, exclude nulls and zeros
SELECT
f.title,
f.length,
RANK() OVER (ORDER BY f.length DESC) AS 'rank'
FROM film AS f
WHERE f.length IS NOT NULL
AND f.length > 0;

-- 2. Rank films by length within the rating category
 SELECT
f.title,
f.length,
f.rating,
RANK() OVER (PARTITION BY f.rating ORDER BY f.length DESC) AS 'rank'
FROM film AS f
WHERE f.length IS NOT NULL
AND f.length > 0;

-- 3. Show actors with the greatest number of films per movie
WITH actor_film_counts AS (
SELECT
fa.actor_id,
a.first_name,
a.last_name,
COUNT(fa.film_id) AS total_films
FROM film_actor AS fa
INNER JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY
fa.actor_id,
a.first_name,
a.last_name
)
SELECT
f.title,
afc.first_name,
afc.last_name,
afc.total_films
FROM film AS f
INNER JOIN film_actor AS fa2
ON f.film_id = fa2.film_id
INNER JOIN actor_film_counts AS afc
ON fa2.actor_id = afc.actor_id;

-- CHALLENGE 2; Customer Activity and Retention
-- STEP 1: Total number of unique acitive customers per month
SELECT
DATE_FORMAT(r.rental_date, '%Y-%m') AS activity_month,
COUNT(DISTINCT r.customer_id) AS active_users
FROM rental AS r
GROUP BY
DATE_FORMAT(r.rental_date, '%Y-%m');

-- STEP 2: Retrieve the number of active Users in the previous month
WITH monthly_active_customers AS (
SELECT
DATE_FORMAT(r.rental_date, '%Y-%m') AS activity_month,
COUNT(DISTINCT r.customer_id) AS active_users
FROM rental AS r
GROUP BY
DATE_FORMAT(r.rental_date, '%Y-%m')
)
SELECT
mac.activity_month,
mac.active_users,
LAG(mac.active_users, 1) OVER (ORDER BY mac.activity_month) AS previous_monthe_users
FROM monthly_active_customers AS mac;

-- STEP 3: Calculate the Percentge change in active customers
WITH monthly_active_customers AS (
SELECT
DATE_FORMAT(r.rental_date, '%Y-%m') AS activity_month,
COUNT(DISTINCT r.customer_id) AS active_users
FROM rental AS r
GROUP BY
DATE_FORMAT(r.rental_date, '%Y-%m')
),
lagged_active_customers AS (
SELECT
mac.activity_month,
mac.active_users,
LAG(mac.active_users, 1) OVER (ORDER BY mac.activity_month) AS previous_month_users
FROM monthly_active_customers AS mac
)
SELECT
lac.activity_month,
lac.active_users,
lac.previous_month_users,
ROUND(((lac.active_users - lac.previous_month_users) / lac.previous_month_users) * 100, 2) AS percentage_change
FROM lagged_active_customers AS lac;

-- STEP 4: Count customers who rented a movie in both the current month AND the previous month
WITH customer_rentals_by_month AS (
SELECT DISTINCT
r.customer_id,
DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month
FROM rental AS r
)
SELECT
cur.rental_month AS activity_month,
COUNT(DISTINCT cur.customer_id) AS retained_users
FROM customer_rentals_by_month AS cur
INNER JOIN customer_rentals_by_month AS prev
ON cur.customer_id = prev.customer_id
AND STR_TO_DATE(CONCAT(cur.rental_month, '-01'), '%Y-%m-%d') = STR_TO_DATE(CONCAT(prev.rental_month, '-01'), '%Y-%m-%d') + INTERVAL 1 MONTH
GROUP BY
cur.rental_month;