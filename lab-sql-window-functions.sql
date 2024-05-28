USE sakila;

-- Challenge #1
-- Ranking films by length
SELECT title, length,
	RANK() OVER (ORDER BY length DESC) AS rank
FROM film
WHERE length IS NOT NULL AND length > 0);
-- ----------------------------------------------------------------------------------------------------------
-- Ranking films by Length within the rating
SELECT title, length, rating, 
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank
FROM film
WHERE length IS NOT NULL AND length > 0;
-- ----------------------------------------------------------------------------------------------------------
-- Actors with the greatest number of films
WITH ActorFilmCount AS (
    SELECT a.actor_id, 
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        COUNT(fa.film_id) AS film_count
    FROM actor a
    JOIN 
		film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id),
--   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
MaxActorFilmCount AS (
    SELECT actor_name, film_count, 
        RANK() OVER (ORDER BY film_count DESC) AS rank
    FROM ActorFilmCount
)
SELECT actor_name, film_count
FROM MaxActorFilmCount
WHERE rank = 1;
-- ----------------------------------------------------------------------------------------------------------
-- Challenge #2
-- Number of monthly active customers
WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month, 
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT month, active_customers
FROM MonthlyActiveCustomers
ORDER BY month;
-- ----------------------------------------------------------------------------------------------------------
--  Number of active users in the previous month
WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month, 
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY 
		DATE_FORMAT(rental_date, '%Y-%m')
),
PreviousMonthActiveCustomers AS (
    SELECT month, active_customers,
        LAG(active_customers, 1) OVER (ORDER BY month) AS previous_active_customers
    FROM MonthlyActiveCustomers
)
SELECT month, active_customers, previous_active_customers
FROM PreviousMonthActiveCustomers
ORDER BY month;
-- ----------------------------------------------------------------------------------------------------------
-- Percentage change in the number of active customers
WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month, 
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY 
        DATE_FORMAT(rental_date, '%Y-%m')
),
PreviousMonthActiveCustomers AS (
    SELECT month, active_customers,
        LAG(active_customers, 1) OVER (ORDER BY month) AS previous_active_customers
    FROM MonthlyActiveCustomers
)
SELECT month, active_customers, previous_active_customers,
    ROUND(((active_customers - previous_active_customers) / previous_active_customers) * 100, 2) AS percent_change
FROM PreviousMonthActiveCustomers
ORDER BY month;
-- ----------------------------------------------------------------------------------------------------------
-- Number of retained customers every month
WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month, 
        customer_id
    FROM rental
    GROUP BY 
        DATE_FORMAT(rental_date, '%Y-%m'), customer_id
),
CustomerRetention AS (
    SELECT m1.month AS current_month, 
        COUNT(DISTINCT m1.customer_id) AS retained_customers
    FROM MonthlyActiveCustomers m1
    JOIN 
        MonthlyActiveCustomers m2 ON m1.customer_id = m2.customer_id
    WHERE 
        DATE_FORMAT(DATE_SUB(STR_TO_DATE(CONCAT(m1.month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH), '%Y-%m') = m2.month
    GROUP BY m1.month
)
SELECT current_month, retained_customers
FROM CustomerRetention
ORDER BY current_month;