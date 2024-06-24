use sakila;
-- Challenge 1: Using the SQL RANK() Function

-- Step 1: Rank films by their length
CREATE TEMPORARY TABLE ranked_films AS
SELECT 
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS 'rank'
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0;
SELECT * FROM ranked_films;

-- Step 2: Rank films by length within the rating category 
CREATE TEMPORARY TABLE ranked_films_by_rating AS
SELECT 
    title,
    length,
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS 'rank'
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0;

SELECT * FROM ranked_films_by_rating;

-- Step 3: Actor or actress who has acted in the greatest number of films
CREATE TEMPORARY TABLE actor_film_count AS
SELECT 
    actor.actor_id,
    actor.first_name,
    actor.last_name,
    COUNT(film_actor.film_id) AS film_count
FROM 
    actor
JOIN 
    film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY 
    actor.actor_id, actor.first_name, actor.last_name;

CREATE TEMPORARY TABLE max_actor_films AS
SELECT 
    film.film_id,
    film.title,
    actor_film_count.actor_id,
    actor_film_count.first_name,
    actor_film_count.last_name,
    actor_film_count.film_count,
    RANK() OVER (PARTITION BY film.film_id ORDER BY actor_film_count.film_count DESC) AS 'ranked'
FROM 
    film
JOIN 
    film_actor ON film.film_id = film_actor.film_id
JOIN 
    actor_film_count ON film_actor.actor_id = actor_film_count.actor_id;

SELECT 
    title,
    first_name,
    last_name,
    film_count
FROM 
    max_actor_films
WHERE 
    ranked = 1;
    
-- Challenge 2: Analyzing Customer Activity and Retention

-- Step 1: Retrieve the number of monthly active customers
CREATE TEMPORARY TABLE monthly_active AS
SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM 
    rental
GROUP BY 
    DATE_FORMAT(rental_date, '%Y-%m');

SELECT * FROM monthly_active;

-- Step 2: Retrieve the number of active users in the previous month
CREATE TEMPORARY TABLE previous_month_active AS
SELECT 
    month,
    active_customers,
    LAG(active_customers, 1) OVER (ORDER BY month) AS previous_month_active_customers
FROM 
    monthly_active;

SELECT * FROM previous_month_active;

-- Step 3: Calculate the percentage change in the number of active customers
CREATE TEMPORARY TABLE percentage_changes AS
SELECT 
    month,
    active_customers,
    previous_month_active_customers,
    ((active_customers - previous_month_active_customers) / previous_month_active_customers) * 100 AS percentage_change
FROM 
    previous_month_active;

SELECT * FROM percentage_changes;
-- --------------------------------------------------------------
-- Step 4: Calculate the number of retained customers every month
CREATE TEMPORARY TABLE monthly_client AS
SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS months,
    customer_id
FROM 
    rental
GROUP BY 
    DATE_FORMAT(rental_date, '%Y-%m'), customer_id;


CREATE TEMPORARY TABLE previous_month_client AS
SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS months,
    customer_id
FROM 
    rental
GROUP BY 
    DATE_FORMAT(rental_date, '%Y-%m'), customer_id;

CREATE TEMPORARY TABLE retained_cust AS
SELECT 
    ma.months AS current_month,
    COUNT(DISTINCT ma.customer_id) AS active_customers,
    COUNT(DISTINCT pm.customer_id) AS retained_customers
FROM 
    monthly_client ma
LEFT JOIN 
    previous_month_client pm 
ON 
    ma.customer_id = pm.customer_id 
    AND DATE_FORMAT(DATE_SUB(concat(ma.months,'-01'), INTERVAL 1 MONTH), '%Y-%m') = pm.months
GROUP BY 
    ma.months;

SELECT * FROM retained_cust;