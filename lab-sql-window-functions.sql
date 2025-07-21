SELECT 
	f.title,
    f.length,
    RANK() OVER (ORDER BY f.length DESC) AS length_rank
FROM film f
WHERE f.length IS NOT NULL AND f.length <> 0;

SELECT
    f.title,
    f.length,
    f.rating,
    RANK() OVER (PARTITION BY f.rating ORDER BY f.length DESC) AS length_rank
FROM film f
WHERE f.length IS NOT NULL AND f.length <> 0;

WITH actor_film_count AS (
    SELECT
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS full_name,
        COUNT(fa.film_id) AS film_count
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id
),
film_actor_with_count AS (
    SELECT
        f.film_id,
        f.title,
        afc.actor_id,
        afc.full_name,
        afc.film_count,
        RANK() OVER (PARTITION BY f.film_id ORDER BY afc.film_count DESC) AS actor_rank
    FROM film f
    JOIN film_actor fa ON f.film_id = fa.film_id
    JOIN actor_film_count afc ON fa.actor_id = afc.actor_id
)
SELECT
    title,
    full_name,
    film_count
FROM film_actor_with_count
WHERE actor_rank = 1;

SELECT
    DATE_FORMAT(rental_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS monthly_active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
ORDER BY month;

SELECT
    COUNT(DISTINCT customer_id) AS previous_month_active_customers
FROM rental
WHERE rental_date >= DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m-01')
AND rental_date < DATE_FORMAT(NOW(), '%Y-%m-01');

WITH monthly_active_customers AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT
    curr.month AS current_month,
    prev.month AS previous_month,
    curr.active_customers AS current_active_customers,
    prev.active_customers AS previous_active_customers,
    ROUND(
        100 * (curr.active_customers - prev.active_customers) / prev.active_customers, 2
    ) AS percent_change
FROM monthly_active_customers curr
JOIN monthly_active_customers prev
    ON curr.month = DATE_FORMAT(STR_TO_DATE(prev.month, '%Y-%m') + INTERVAL 1 MONTH, '%Y-%m')
ORDER BY curr.month DESC
LIMIT 1;

WITH monthly_customers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        customer_id
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m'), customer_id
),
retained_customers AS (
    SELECT 
        curr.month AS current_month,
        COUNT(curr.customer_id) AS retained_customers
    FROM monthly_customers curr
    JOIN monthly_customers prev
        ON curr.customer_id = prev.customer_id
        AND curr.month = DATE_FORMAT(STR_TO_DATE(prev.month, '%Y-%m') + INTERVAL 1 MONTH, '%Y-%m')
    GROUP BY curr.month
    ORDER BY curr.month
)
SELECT * FROM retained_customers;
