USE sakila;

-- Challenge 1

-- Exercise 1

SELECT
    title, 
    length,
    RANK() OVER (ORDER BY length DESC) AS rank
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0;

-- Exercise 2

SELECT 
    title, 
    length, 
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0;
    
-- Exercise 3

WITH ActorFilmCount AS (
    SELECT 
        actor_id,
        COUNT(film_id) AS film_count
    FROM 
        film_actor
    GROUP BY 
        actor_id
)
SELECT 
    f.title,
    a.first_name,
    a.last_name,
    afc.film_count
FROM 
    film f
JOIN 
    film_actor fa ON f.film_id = fa.film_id
JOIN 
    actor a ON fa.actor_id = a.actor_id
JOIN 
    ActorFilmCount afc ON a.actor_id = afc.actor_id
ORDER BY 
    afc.film_count DESC;

-- Challenge 2

-- Step 1

SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM 
    rental
GROUP BY 
    DATE_FORMAT(rental_date, '%Y-%m');
    
-- Step 2

WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM 
        rental
    GROUP BY 
        DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT 
    month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY month) AS previous_month_active_customers
FROM 
    MonthlyActiveCustomers;
    
    -- Step 3
    
    WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM 
        rental
    GROUP BY 
        DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT 
    month,
    active_customers,
    previous_month_active_customers,
    ((active_customers - previous_month_active_customers) / previous_month_active_customers) * 100 AS percentage_change
FROM (
    SELECT 
        month,
        active_customers,
        LAG(active_customers) OVER (ORDER BY month) AS previous_month_active_customers
    FROM 
        MonthlyActiveCustomers
) AS subquery;

# Step 4

WITH MonthlyActiveCustomers AS (
    SELECT 
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS month
    FROM 
        rental
    GROUP BY 
        customer_id, month
),
RetainedCustomers AS (
    SELECT 
        a.customer_id,
        a.month AS current_month,
        b.month AS previous_month
    FROM 
        MonthlyActiveCustomers a
    JOIN 
        MonthlyActiveCustomers b ON a.customer_id = b.customer_id
    AND 
        a.month = DATE_FORMAT(DATE_ADD(STR_TO_DATE(b.month, '%Y-%m'), INTERVAL 1 MONTH), '%Y-%m')
)
SELECT 
    current_month,
    COUNT(DISTINCT customer_id) AS retained_customers
FROM 
    RetainedCustomers
GROUP BY 
    current_month;






