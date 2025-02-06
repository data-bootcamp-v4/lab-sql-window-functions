USE sakila;

SELECT title, length,
       RANK() OVER (ORDER BY length DESC) AS rank_position
FROM film
WHERE length IS NOT NULL AND length > 0
ORDER BY rank_position;

SELECT title, length, rating,
       RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank_within_rating
FROM film
WHERE length IS NOT NULL AND length > 0
ORDER BY rating, rank_within_rating;

WITH actor_film_counts AS (
    SELECT fa.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS total_films,
           RANK() OVER (ORDER BY COUNT(fa.film_id) DESC) AS rank_position
    FROM film_actor fa
    JOIN actor a ON fa.actor_id = a.actor_id
    GROUP BY fa.actor_id, a.first_name, a.last_name
)
SELECT * FROM actor_film_counts
WHERE rank_position = 1;

WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM rental r
    GROUP BY rental_month
)
SELECT * FROM monthly_active_customers;


WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM rental r
    GROUP BY rental_month
)
SELECT 
    rental_month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY rental_month) AS previous_month_active_customers
FROM monthly_active_customers;


WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM rental r
    GROUP BY rental_month
)
SELECT 
    rental_month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY rental_month) AS previous_month_active_customers,
    ROUND(
        ((active_customers - LAG(active_customers) OVER (ORDER BY rental_month)) / LAG(active_customers) OVER (ORDER BY rental_month)) * 100, 
        2
    ) AS percentage_change
FROM monthly_active_customers;


WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
        r.customer_id
    FROM rental r
    GROUP BY rental_month, r.customer_id
),
retained_customers AS (
    SELECT 
        curr.rental_month,
        COUNT(DISTINCT curr.customer_id) AS retained_customers
    FROM monthly_active_customers curr
    JOIN monthly_active_customers prev 
        ON curr.customer_id = prev.customer_id 
        AND DATE_FORMAT(DATE_SUB(STR_TO_DATE(curr.rental_month, '%Y-%m'), INTERVAL 1 MONTH), '%Y-%m') = prev.rental_month
    GROUP BY curr.rental_month
)
SELECT * FROM retained_customers;
