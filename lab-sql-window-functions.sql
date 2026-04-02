USE sakila;
-- ## Challenge 1
SELECT 
title, 
length,
RANK() OVER (ORDER BY length DESC)
FROM film
WHERE length != 0
;

SELECT 
title, 
length,
rating,
RANK() OVER (ORDER BY length DESC)
FROM film
WHERE length != 0
;

SELECT f.film_id, f.title, fa.actor_id, a.first_name, a.last_name
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id
JOIN actor a
ON fa.actor_id = a.actor_id
;


WITH actor_film_cte AS (
    SELECT 
        f.film_id, 
        f.title, 
        fa.actor_id, 
        a.first_name, 
        a.last_name,
        RANK() OVER (
            PARTITION BY fa.actor_id 
            ORDER BY f.title
        ) AS film_rank
    FROM film f
    JOIN film_actor fa ON f.film_id = fa.film_id
    JOIN actor a ON fa.actor_id = a.actor_id
)
SELECT 
    actor_id,
    first_name,
    last_name,
    COUNT(film_id) AS film_count,
    GROUP_CONCAT(title ORDER BY title SEPARATOR ', ') AS films
FROM actor_film_cte
GROUP BY actor_id, first_name, last_name;

-- ## Challenge 2
WITH monthly_activity AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT c.customer_id) AS monthly_active_customers
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    WHERE c.active = 1
    GROUP BY DATE_FORMAT(r.rental_date, '%Y-%m')
)
SELECT 
    rental_month,
    monthly_active_customers,
    RANK() OVER (
        ORDER BY monthly_active_customers DESC
    ) AS rank_by_active_customers,
    SUM(monthly_active_customers) OVER (
        ORDER BY rental_month
    ) AS cumulative_active_customers
FROM monthly_activity
ORDER BY rental_month;

WITH monthly_activity AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT c.customer_id) AS monthly_active_customers
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    WHERE c.active = 1
    GROUP BY DATE_FORMAT(r.rental_date, '%Y-%m')
)
SELECT 
    rental_month,
    monthly_active_customers,
    LAG(monthly_active_customers) OVER (
        ORDER BY rental_month
    ) AS previous_month_active_customers,
    RANK() OVER (
        ORDER BY monthly_active_customers DESC
    ) AS rank_by_active_customers,
    SUM(monthly_active_customers) OVER (
        ORDER BY rental_month
    ) AS cumulative_active_customers
FROM monthly_activity
ORDER BY rental_month;

WITH monthly_activity AS (
    SELECT 
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT c.customer_id) AS monthly_active_customers
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    WHERE c.active = 1
    GROUP BY DATE_FORMAT(r.rental_date, '%Y-%m')
)
SELECT 
    rental_month,
    monthly_active_customers,
    LAG(monthly_active_customers) OVER (
        ORDER BY rental_month
    ) AS previous_month_customers,
    ROUND(
        (monthly_active_customers - LAG(monthly_active_customers) OVER (ORDER BY rental_month))
        / LAG(monthly_active_customers) OVER (ORDER BY rental_month) * 100, 2
    ) AS pct_change
FROM monthly_activity
ORDER BY rental_month;

WITH customer_months AS (
    SELECT DISTINCT
        c.customer_id,
        DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    WHERE c.active = 1
),
customer_with_prev AS (
    SELECT 
        customer_id,
        rental_month,
        LAG(rental_month) OVER (
            PARTITION BY customer_id
            ORDER BY rental_month
        ) AS prev_month
    FROM customer_months
)
SELECT 
    rental_month,
    COUNT(customer_id) AS retained_customers
FROM customer_with_prev
WHERE prev_month = DATE_FORMAT(
        DATE_SUB(STR_TO_DATE(CONCAT(rental_month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH),
        '%Y-%m'
    )
GROUP BY rental_month
ORDER BY rental_month;