USE sakila;

-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. 
-- You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.

-- 1. Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.
SELECT title, length, RANK() OVER(ORDER BY length DESC) AS 'rank_by_length'
FROM film;

-- 2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.
SELECT title, length, rating, RANK() OVER(ORDER BY length DESC) AS 'rank_by_length'
FROM film
ORDER BY rating;

-- 3. Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, 
-- as well as the total number of films in which they have acted. 
WITH film_actor_counts AS(
	SELECT 	
		f.film_id, 
		f.title, 
        a.actor_id, 
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name, 
		COUNT(f.film_id) OVER (PARTITION BY f.film_id, a.actor_id),
        COUNT(f.film_id) OVER (PARTITION BY a.actor_id) AS 'total_films_per_actor' 
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
),
ranked_actors AS (
	SELECT	
		film_id,
        title,
        actor_name,
        total_films_per_actor,
        RANK() OVER(PARTITION BY film_id ORDER BY total_films_per_actor DESC) AS rnk
        FROM film_actor_counts
)
SELECT 
	title,
    actor_name,
    total_films_per_actor
FROM ranked_actors
WHERE rnk = 1
ORDER BY title;


-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.


-- This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. 
-- By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.

-- The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by 
-- conducting an analysis on the monthly percentage change in the number of active customers and the number of retained customers. 
-- Use the Sakila database and progressively build queries to achieve the desired outcome.

-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
CREATE OR REPLACE VIEW user_activity AS
SELECT customer_id, 
       CONVERT(rental_date, DATE) AS activity_date,
       DATE_FORMAT(CONVERT(rental_date,DATE), '%M') AS Activity_Month,
       DATE_FORMAT(CONVERT(rental_date,DATE), '%m') AS Activity_Month_number,
       DATE_FORMAT(CONVERT(rental_date,DATE), '%Y') AS Activity_Year
FROM rental;

-- Show view
SELECT * FROM user_activity;

-- retrieve monthly active customers
SELECT 
   Activity_Month, 
   Activity_Month_number,
   Activity_Year,
   COUNT(DISTINCT(customer_id)) AS Active_users
FROM user_activity
GROUP BY Activity_Month, Activity_Month_number, Activity_Year
ORDER BY Activity_Month_number ASC;

-- Step 2. Retrieve the number of active users in the previous month.
SELECT 
   Activity_Month, 
   Activity_Month_number,
   Activity_Year,
   COUNT(DISTINCT(customer_id)) AS Active_users, 
   LAG(COUNT(DISTINCT(customer_id)), 1) OVER(ORDER BY Activity_year, Activity_Month_number) AS last_month
FROM user_activity
GROUP BY Activity_Month, Activity_Month_number, Activity_Year
ORDER BY Activity_Year, Activity_Month_number ASC;

-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
SELECT 
   Activity_Month, 
   Activity_Month_number,
   Activity_Year,
   COUNT(DISTINCT(customer_id)) AS Active_users, 
   LAG(COUNT(DISTINCT(customer_id)), 1) OVER(ORDER BY Activity_year, Activity_Month_number) AS last_month, 
   (COUNT(DISTINCT(customer_id)) - LAG(COUNT(DISTINCT(customer_id)), 1) OVER(ORDER BY Activity_year, Activity_Month_number)) * 100 / LAG(COUNT(DISTINCT(customer_id)), 1) OVER(ORDER BY Activity_year, Activity_Month_number) AS percentage_difference 

FROM user_activity
GROUP BY Activity_Month, Activity_Month_number, Activity_Year
ORDER BY Activity_Year, Activity_Month_number ASC;

-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.


-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
