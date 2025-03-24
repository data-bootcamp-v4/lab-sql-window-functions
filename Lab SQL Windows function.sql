USE sakila;
SELECT * FROM film;

-- Challenge 1
-- 1. Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.
SELECT title, length,
	RANK() OVER (ORDER BY length) AS rank_num
FROM film;

-- 2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only.
-- Filter out any rows with null or zero values in the length column.
SELECT title, length, rating,
	RANK() OVER (partition by rating ORDER BY length DESC) AS rank_num
FROM film
WHERE length IS NOT NULL AND length > 0;

-- 3. Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted.
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

DROP temporary table if exists count_film_2;
CREATE temporary Table count_film_2 AS
	SELECT first_name, last_name, af.film_id, COUNT(*) OVER (PARTITION BY a.first_name, a.last_name) AS Number_films
	FROM actor a
	JOIN film_actor af ON af.actor_id = a.actor_id;
    
SELECT f.title, cf2.first_name, cf2.last_name, cf2.number_films
FROM count_film_2 cf2
JOIN film f ON f.film_id = cf2.film_id;


-- Challenge 2
-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%m/%Y') AS month_year,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY month_year
)
-- Step 2. Retrieve the number of active users in the previous month.
SELECT 
    month_year,
    active_customers,
    LAG(active_customers) OVER (ORDER BY STR_TO_DATE(month_year, '%m/%Y')) AS prev_month_active_customers
FROM monthly_active_customers;

-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%m/%Y') AS month_year,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY month_year
)
SELECT 
    month_year,
    active_customers,
    LAG(active_customers) OVER (ORDER BY STR_TO_DATE(month_year, '%m/%Y')) AS prev_month_active_customers,
    ROUND(
        (active_customers - LAG(active_customers) OVER (ORDER BY STR_TO_DATE(month_year, '%m/%Y'))) 
        / LAG(active_customers) OVER (ORDER BY STR_TO_DATE(month_year, '%m/%Y')) * 100, 
        2
    ) AS percentage_change
FROM monthly_active_customers;

-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
WITH monthly_active_customers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%m/%Y') AS month_year,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY month_year
)
SELECT 
    month_year,
    active_customers,
    LAG(active_customers) OVER (ORDER BY STR_TO_DATE(month_year, '%m/%Y')) AS prev_month_active_customers,
    active_customers + LAG(active_customers) OVER (ORDER BY STR_TO_DATE(month_year, '%m/%Y')) AS number_customers_current_previous_month
FROM monthly_active_customers;
