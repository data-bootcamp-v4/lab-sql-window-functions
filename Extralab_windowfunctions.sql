use sakila;

-- Challenge 1

-- 1.

SELECT title, length, RANK() OVER (ORDER BY length DESC) as ranking 
from film 
WHERE length is nOt null and length != 0;

-- 2.

SELECT title, length, rating, RANK() OVER (PARTITION BY rating ORDER BY length DESC) as ranking 
from film 
WHERE length is NOT NULL and length != 0;

-- 3.

-- Create a view to find the number of films each actor has done

CREATE VIEW top_actor AS
    SELECT 
        fa.actor_id,
        a.first_name,
        a.last_name,
        COUNT(fa.film_id) AS film_count
    FROM
        film_actor fa
            JOIN
        actor a ON fa.actor_id = a.actor_id
    GROUP BY fa.actor_id , a.first_name , a.last_name;
    
SELECT 
    *
FROM
    top_actor;

-- Create a CTE with the view to find the actor who has acted in the greatest number of films

WITH actor_with_maxfilms AS (SELECT f.film_id, f.title, fa.actor_id, a.first_name, a.last_name, ta.film_count,
RANK() OVER (PARTITION BY f.film_id ORDER BY ta.film_count DESC) AS ranking
FROM film f JOIN film_actor fa ON f.film_id = fa.film_id JOIN top_actor ta on fa.actor_id = ta.actor_id JOIN actor a ON fa.actor_id = a.actor_id)
SELECT title, first_name, last_name, film_count FROM actor_with_maxfilms WHERE ranking = 1 ORDER BY title;


-- Challenge 2

-- 1.

WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m-01') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM 
        rental
    GROUP BY 
        DATE_FORMAT(rental_date, '%Y-%m-01')
),
PreviousMonthActiveCustomers AS (
    SELECT
        month,
        active_customers,
        LAG(active_customers) OVER (ORDER BY month) AS previous_month_customers
    FROM 
        MonthlyActiveCustomers
),
PercentageChange AS (
    SELECT
        month,
        active_customers,
        previous_month_customers,
        CASE 
            WHEN previous_month_customers = 0 THEN NULL
            ELSE ROUND((active_customers - previous_month_customers) * 100.0 / previous_month_customers, 2)
        END AS percentage_change
    FROM 
        PreviousMonthActiveCustomers
),
RetainedCustomers AS (
    SELECT 
        DATE_FORMAT(r1.rental_date, '%Y-%m-01') AS month,
        COUNT(DISTINCT r1.customer_id) AS retained_customers
    FROM 
        rental r1
    JOIN 
        rental r2 ON r1.customer_id = r2.customer_id
        AND DATE_FORMAT(r1.rental_date, '%Y-%m-01') = DATE_FORMAT(r2.rental_date - INTERVAL 1 MONTH, '%Y-%m-01')
    GROUP BY 
        DATE_FORMAT(r1.rental_date, '%Y-%m-01')
)
SELECT 
    p.month,
    p.active_customers,
    p.previous_month_customers,
    p.percentage_change,
    r.retained_customers
FROM 
    PercentageChange p
LEFT JOIN 
    RetainedCustomers r ON p.month = r.month
ORDER BY 
    p.month;

