-- challenge 1
-- 1
SELECT 
    title, 
    length, 
    RANK() OVER (ORDER BY length DESC) AS film_rank
FROM 
    sakila.film
WHERE 
    length IS NOT NULL AND length > 0;

-- 2
SELECT 
    title, 
    length, 
    rating, 
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS film_rank
FROM 
    sakila.film
WHERE 
    length IS NOT NULL AND length > 0;


-- 3
WITH actor_film_count AS (
    SELECT 
        a.actor_id,
        a.first_name,
        a.last_name,
        COUNT(fa.film_id) AS film_count
    FROM 
        sakila.actor a
    JOIN 
        sakila.film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY 
        a.actor_id, a.first_name, a.last_name
),
most_prolific_actor AS (
    SELECT 
        actor_id,
        first_name,
        last_name,
        film_count,
        RANK() OVER (ORDER BY film_count DESC) AS actor_rank
    FROM 
        actor_film_count
)
SELECT 
    f.title,
    mpa.first_name,
    mpa.last_name,
    mpa.film_count
FROM 
    sakila.film f
JOIN 
    sakila.film_actor fa ON f.film_id = fa.film_id
JOIN 
    most_prolific_actor mpa ON fa.actor_id = mpa.actor_id
WHERE 
    mpa.actor_rank = 1
ORDER BY 
    f.title;
    
    -- challenge 2
    -- 1
    SELECT 
    YEAR(rental_date) AS rental_year, 
    MONTH(rental_date) AS rental_month, 
    COUNT(DISTINCT customer_id) AS active_customers
FROM 
    sakila.rental
GROUP BY 
    YEAR(rental_date), 
    MONTH(rental_date)
ORDER BY 
    rental_year, 
    rental_month;
    -- 2
    SELECT 
    CURRENT_YEAR AS rental_year,
    CURRENT_MONTH AS rental_month,
    COUNT(DISTINCT customer_id) AS active_customers,
    LAG(COUNT(DISTINCT customer_id), 1) OVER (ORDER BY YEAR(rental_date), MONTH(rental_date)) AS active_customers_previous_month
FROM (
    SELECT 
        YEAR(rental_date) AS CURRENT_YEAR, 
        MONTH(rental_date) AS CURRENT_MONTH,
        customer_id
    FROM 
        sakila.rental
) AS subquery
GROUP BY 
    CURRENT_YEAR, 
    CURRENT_MONTH
ORDER BY 
    CURRENT_YEAR, 
    CURRENT_MONTH;
-- 3
SELECT 
    rental_year,
    rental_month,
    active_customers,
    active_customers_previous_month,
    ROUND(
        ((active_customers - active_customers_previous_month) / active_customers_previous_month) * 100,
        2
    ) AS percentage_change
FROM (
    SELECT 
        CURRENT_YEAR AS rental_year,
        CURRENT_MONTH AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers,
        LAG(COUNT(DISTINCT customer_id), 1) OVER (ORDER BY YEAR(rental_date), MONTH(rental_date)) AS active_customers_previous_month
    FROM (
        SELECT 
            YEAR(rental_date) AS CURRENT_YEAR, 
            MONTH(rental_date) AS CURRENT_MONTH,
            customer_id
        FROM 
            sakila.rental
    ) AS subquery
    GROUP BY 
        CURRENT_YEAR, 
        CURRENT_MONTH
) AS monthly_activity
ORDER BY 
    rental_year, 
    rental_month;
    -- 4
    WITH current_month_rentals AS (
    SELECT 
        YEAR(rental_date) AS current_year,
        MONTH(rental_date) AS current_month,
        customer_id
    FROM 
        sakila.rental
),
previous_month_rentals AS (
    SELECT 
        YEAR(rental_date) AS previous_year,
        MONTH(rental_date) AS previous_month,
        customer_id
    FROM 
        sakila.rental
    WHERE 
        DATE_ADD(rental_date, INTERVAL 1 MONTH) = CURDATE()  -- Adjust this condition according to your database setup
)
SELECT 
    cm.current_year AS rental_year,
    cm.current_month AS rental_month,
    COUNT(DISTINCT cm.customer_id) AS retained_customers
FROM 
    current_month_rentals cm
JOIN 
    previous_month_rentals pm ON cm.customer_id = pm.customer_id
    AND cm.current_year = pm.previous_year
    AND cm.current_month = pm.previous_month
GROUP BY 
    cm.current_year,
    cm.current_month
ORDER BY 
    cm.current_year,
    cm.current_month;




