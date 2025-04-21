SELECT 
    title,
    length,
    RANK() OVER (ORDER BY film.length DESC) AS rank_position
FROM film
WHERE length IS NOT NULL AND length > 0;
SELECT 
    title,
    length,
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank_within_rating
FROM film
WHERE length IS NOT NULL AND length > 0;
WITH actor_film_count AS (
    SELECT 
        fa.actor_id,
        a.first_name,
        a.last_name,
        COUNT(*) AS total_films
    FROM film_actor fa
    JOIN actor a ON fa.actor_id = a.actor_id
    GROUP BY fa.actor_id, a.first_name, a.last_name
),
actor_rank_per_film AS (
    SELECT 
        f.title,
        a.first_name,
        a.last_name,
        afc.total_films,
        ROW_NUMBER() OVER (PARTITION BY f.film_id ORDER BY afc.total_films DESC) AS rank_position
    FROM film f
    JOIN film_actor fa ON f.film_id = fa.film_id
    JOIN actor_film_count afc ON afc.actor_id = fa.actor_id
    JOIN actor a ON a.actor_id = fa.actor_id
)
SELECT 
    title,
    first_name,
    last_name,
    total_films
FROM actor_rank_per_film
WHERE rank_position = 1;
SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month
ORDER BY rental_month;
WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY rental_month
)
SELECT 
    rental_month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY rental_month) AS previous_active_customers
FROM monthly_active_customers;
WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY rental_month
)
SELECT 
    rental_month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY rental_month) AS previous_active_customers,
    ROUND(
        100 * (active_customers - LAG(active_customers) OVER (ORDER BY rental_month)) 
        / LAG(active_customers) OVER (ORDER BY rental_month), 
        2
    ) AS percent_change
FROM monthly_active_customers;
WITH monthly_customers AS (
    SELECT DISTINCT
        customer_id,
        DATE(rental_date) AS rental_day,
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM rental
),
retained_customers AS (
    SELECT 
        curr.rental_month AS rental_month,
        COUNT(*) AS retained_customers
    FROM monthly_customers curr
    JOIN monthly_customers prev
        ON curr.customer_id = prev.customer_id
        AND MONTH(curr.rental_day) = MONTH(prev.rental_day) + 1
        AND YEAR(curr.rental_day) = YEAR(prev.rental_day)
    GROUP BY curr.rental_month
)
SELECT *
FROM retained_customers
ORDER BY rental_month;

