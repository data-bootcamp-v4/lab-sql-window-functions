USE sakila;
-- Challenge 1
-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. 
-- You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.

-- Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.
SELECT title, length, 
	DENSE_RANK() OVER(ORDER BY length desc) AS rank_of_length
FROM film
WHERE length IS NOT NULL;

-- Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. Filter out any rows with null or 
-- zero values in the length column.
SELECT title, length, rating,
	DENSE_RANK() OVER(PARTITION BY rating ORDER BY length desc) AS rank_of_length
FROM film
WHERE length IS NOT NULL;
-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, as well as the total number of films in which 
-- they have acted. Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

-- DROP TEMPORARY TABLE IF EXISTS film_and_actor;

-- CREATE TEMPORARY TABLE film_and_actor
-- SELECT film.title AS film_name, 
--     CONCAT(actor.first_name,' ',actor.last_name) AS actor_name,
--     film_actor.actor_id AS actor_id,
--     film_actor.film_id AS film_id
-- FROM film
-- JOIN film_actor
-- ON film.film_id = film_actor.film_id
-- JOIN actor
-- ON film_actor.actor_id = actor.actor_id;

WITH how_many AS (
				SELECT actor_id,
				COUNT(actor_id) AS appearance
				FROM film_actor
				GROUP BY actor_id
                ),
film_and_actor AS (
					SELECT film.title AS film_name, 
					CONCAT(actor.first_name,' ',actor.last_name) AS actor_name,
					film_actor.actor_id AS actor_id,
					film_actor.film_id AS film_id,
                    ROW_NUMBER() OVER (PARTITION BY film_id ORDER BY appearance desc) AS top
					FROM film
					JOIN film_actor
					ON film.film_id = film_actor.film_id
					JOIN actor
					ON film_actor.actor_id = actor.actor_id
                    JOIN how_many
                    ON how_many.actor_id= actor.actor_id
                    )
SELECT 
	film_name,
	actor_name
FROM film_and_actor
WHERE top = 1;

-- Challenge 2

-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
SELECT COUNT(DISTINCT(customer_id)),
		MONTH(payment_date),
        YEAR(payment_date)
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY YEAR(payment_date) asc;

-- Step 2. Retrieve the number of active users in the previous month.
DROP TEMPORARY TABLE IF EXISTS users_a_month;

CREATE TEMPORARY TABLE users_a_month
SELECT COUNT(DISTINCT(customer_id)) AS active_users,
		MONTH(payment_date) AS month,
        YEAR(payment_date) AS year
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY YEAR(payment_date) asc;

SELECT 
	month, year, active_users,
	LAG(active_users) OVER(ORDER BY year, month) AS users_last_month
FROM users_a_month
ORDER BY year, month;
    
-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.

WITH user_lag AS (
			SELECT 
					month, 
                    year, 
                    active_users,
					LAG(active_users) OVER(ORDER BY year, month) AS users_last_month
			FROM users_a_month
			ORDER BY year, month)
SELECT 
		month, 
		year, 
		active_users,
		users_last_month,
        ROUND((active_users-users_last_month)/active_users * 100,2) AS percent_change
FROM user_lag
;
-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.



SELECT customer_id AS active_user,
		MONTH(payment_date) AS month,
        YEAR(payment_date) AS year
FROM payment
GROUP BY YEAR(payment_date), MONTH(payment_date), customer_id
ORDER BY YEAR(payment_date) asc
;