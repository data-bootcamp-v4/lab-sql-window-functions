USE sakila;

-- Ranking film by lengths
SELECT 
    title, 
    length, 
    RANK() OVER (ORDER BY length DESC) AS 'rank'
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0;
    
-- Rank Films by Length Within Each Rating Category
SELECT 
    title, 
    length, 
    rating, 
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS 'rank'
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0;

-- Actor / Actress with the Most Films per Film
WITH actor_film_count AS (
    SELECT 
        actor_id, 
        COUNT(film_id) AS total_films
    FROM 
        film_actor
    GROUP BY 
        actor_id
),
max_actor_per_film AS (
    SELECT 
        fa.film_id,
        fa.actor_id,
        afc.total_films,
        RANK() OVER (PARTITION BY fa.film_id ORDER BY afc.total_films DESC) AS actor_rank
    FROM 
        film_actor fa
    JOIN 
        actor_film_count afc ON fa.actor_id = afc.actor_id
)
SELECT 
    f.title,
    a.first_name,
    a.last_name,
    m.total_films
FROM 
    max_actor_per_film m
JOIN 
    film f ON m.film_id = f.film_id
JOIN 
    actor a ON m.actor_id = a.actor_id
WHERE 
    m.actor_rank = 1;


-- Challenge 2
-- Step 1: Monthly active customers
WITH monthly_active AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS activity_month, 
        COUNT(DISTINCT customer_id) AS active_customers 
    FROM rental
    GROUP BY activity_month
),

-- Step 2: Previous month's active customers 
previous_month AS ( 
    SELECT 
        activity_month, 
        active_customers, 
        LAG(active_customers) OVER (ORDER BY activity_month) AS prev_month_active
    FROM monthly_active
),

-- Step 3: Retained customers (active in both current and previous month)
retention_data AS (
    SELECT
        current_month,
        COUNT(DISTINCT current.customer_id) AS retained_customers
    FROM (
        SELECT 
            DATE_FORMAT(rental_date, '%Y-%m') AS current_month,
            customer_id
        FROM rental
    ) current
    JOIN (
        SELECT 
            DATE_FORMAT(rental_date, '%Y-%m') AS previous_month,
            customer_id
        FROM rental
    ) previous
    ON current.customer_id = previous.customer_id
       AND current.current_month = DATE_FORMAT(
           DATE_ADD(STR_TO_DATE(CONCAT(previous.previous_month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH),
           '%Y-%m'
       )
    GROUP BY current_month
)

-- Final calculation
SELECT
    pm.activity_month,
    pm.active_customers,
    pm.prev_month_active,
    
    -- % Change in active customers
    ROUND(
        100.0 * (pm.active_customers - pm.prev_month_active) / 
        NULLIF(pm.prev_month_active, 0), 2
    ) AS pct_change_active,

    rd.retained_customers,
    
    -- Retention Rate
    ROUND(
        100.0 * rd.retained_customers / 
        NULLIF(pm.prev_month_active, 0), 2
    ) AS retention_rate

FROM previous_month pm
LEFT JOIN retention_data rd
    ON pm.activity_month = rd.current_month
ORDER BY pm.activity_month;

 
