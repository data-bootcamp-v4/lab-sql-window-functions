USE sakila;
SELECT title, length, RANK() OVER(ORDER BY length DESC) AS 'Rank' FROM film
WHERE length IS NOT NULL AND length <> 0;

SELECT title, length, rating, RANK() OVER(PARTITION BY rating ORDER BY length DESC) AS 'Rank' FROM film
WHERE length IS NOT NULL AND length <> 0;

WITH ActorCounts AS (
    SELECT 
        f.title AS film_title,
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        COUNT(*) OVER (PARTITION BY f.film_id, a.actor_id) AS actor_count
    FROM 
        film f
    JOIN 
        film_actor fa ON f.film_id = fa.film_id
    JOIN 
        actor a ON fa.actor_id = a.actor_id
),
RankedActors AS (
    SELECT 
        film_title,
        actor_name,
        actor_count,
        RANK() OVER (PARTITION BY film_title ORDER BY actor_count DESC) AS 'Ranking'
    FROM 
        ActorCounts
)
SELECT 
    film_title,
    actor_name AS top_actor,
    actor_count AS total_films
FROM 
    RankedActors

ORDER BY 
    film_title;
    
    
SELECT 
    COUNT(DISTINCT (customer_id)) AS active_customers,
    DATE_FORMAT(CONVERT( rental_date , DATE), '%M') AS Activity_Month
FROM
    rental
GROUP BY Activity_Month;
SELECT 
DATE_FORMAT(CONVERT( rental_date , DATE), '%M') AS Activity_Month,
    COUNT(DISTINCT (customer_id)) AS active_customers,
    LAG(COUNT(DISTINCT (customer_id))) OVER(ORDER BY DATE_FORMAT(CONVERT( rental_date , DATE), '%M')) AS Last_month_active_customer
FROM
    rental
GROUP BY Activity_Month;

SELECT 
DATE_FORMAT(CONVERT( rental_date , DATE), '%M') AS Activity_Month,
    COUNT(DISTINCT (customer_id)) AS active_customers,
    LAG(COUNT(DISTINCT (customer_id))) OVER(ORDER BY DATE_FORMAT(CONVERT( rental_date , DATE), '%M')) AS Last_month_active_customer,
	( COUNT(DISTINCT (customer_id))/ LAG(COUNT(DISTINCT (customer_id))) OVER(ORDER BY DATE_FORMAT(CONVERT( rental_date , DATE), '%M'))) *100 AS percentage_change
FROM
    rental
GROUP BY Activity_Month;

SELECT 
DATE_FORMAT(CONVERT( rental_date , DATE), '%M') AS Activity_Month,
    COUNT(DISTINCT (customer_id)) AS active_customers,
    LAG(COUNT(DISTINCT (customer_id))) OVER(ORDER BY DATE_FORMAT(CONVERT( rental_date , DATE), '%M')) AS Last_month_active_customer,
	( COUNT(DISTINCT (customer_id))/ LAG(COUNT(DISTINCT (customer_id))) OVER(ORDER BY DATE_FORMAT(CONVERT( rental_date , DATE), '%M'))) *100 AS percentage_change,
	( COUNT(DISTINCT (customer_id)) - LAG(COUNT(DISTINCT (customer_id))) OVER(ORDER BY DATE_FORMAT(CONVERT( rental_date , DATE), '%M'))) AS retained_customer
FROM
    rental
GROUP BY Activity_Month;