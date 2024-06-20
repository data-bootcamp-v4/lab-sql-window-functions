-- 1 Rank films by their length and create an output table that includes the title,
-- length, and rank columns only. Filter out any rows with null or zero values
-- in the length column.

SELECT film.title, film.length, RANK() OVER(ORDER BY film.length DESC) AS rank_length
FROM sakila.film AS film
WHERE film.length > 0;

-- 2 Rank films by length within the rating category and create an output table
-- that includes the title, length, rating and rank columns only.
-- Filter out any rows with null or zero values in the length column.

SELECT film.title, film.length, film.rating, RANK() OVER(PARTITION BY film.rating ORDER BY film.length DESC) AS rank_length
FROM sakila.film AS film
WHERE film.length > 0;

-- 3 - Produce a list that shows for each film in the Sakila database,
-- the actor or actress who has acted in the greatest number of films,
-- as well as the total number of films in which they have acted.
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your.

WITH TBL AS
(
	SELECT  actor.actor_id
	       ,actor.first_name
	       ,actor.last_name
	       ,COUNT(*) num_films
	FROM sakila.film AS film
	JOIN sakila.film_actor AS film_actor
	ON film_actor.film_id = film.film_id
	JOIN sakila.actor AS actor
	ON actor.actor_id = film_actor.actor_id
	GROUP BY  actor.actor_id
	         ,actor.first_name
	         ,actor.last_name
)
SELECT  sub_query.title AS film
       ,sub_query.first_name
       ,sub_query.last_name
       ,sub_query.num_films
FROM
(
	SELECT  film.title
	       ,TBL.first_name
	       ,TBL.last_name
	       ,TBL.num_films
	       ,RANK() OVER(PARTITION BY film.title ORDER BY  num_films DESC) rank_actor
	FROM TBL
	JOIN sakila.film_actor AS film_actor
	ON film_actor.actor_id = TBL.actor_id
	JOIN sakila.film AS film
	ON film.film_id = film_actor.film_id
) AS sub_query
WHERE rank_actor = 1;


-- Challenge
-- Step 1
SELECT DATE_FORMAT(rental_date, '%Y-%m') AS month_year,
COUNT(DISTINCT customer_id) active_customers
FROM sakila.rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
ORDER BY 1;

-- Step 2
WITH results AS (
	SELECT DATE_FORMAT(rental_date, '%Y-%m') AS month_year,
	COUNT(DISTINCT customer_id) active_customers
	FROM sakila.rental
	GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
	ORDER BY 1
    )
SELECT results.*, prev_results.previous_month_data,
prev_results.previous_active_customers , CASE WHEN STR_TO_DATE(previous_month_data, '%Y-%m') = DATE_ADD(STR_TO_DATE(results.month_year, '%Y-%m'), INTERVAL -1 MONTH) THEN prev_results.previous_active_customers ELSE 0 END prev_act_cust
,DATE_ADD(results.month_year, INTERVAL -1 MONTH) AS comp
FROM results
JOIN 	(
		SELECT results.*, -- DATE_ADD(month_year, INTERVAL -1 MONTH) AS previous_month,
        LAG(month_year, 1) OVER (ORDER BY month_year) AS previous_month_data,
		LAG(active_customers, 1) OVER (ORDER BY month_year) AS previous_active_customers
FROM results) prev_results ON results.month_year = prev_results.month_year;
