USE sakila;

#This challenge consists of three exercises that will test your ability to use the SQL RANK() function. You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.
#C1.1 Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.
SELECT title, 
		length,
		RANK() OVER(ORDER BY length DESC) AS ranking
FROM film
WHERE length > 0;

#C1.2 Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. Filter out any rows with null or zero values in the length column.
SELECT title, 
		length,
        rating,
		RANK() OVER(PARTITION BY rating ORDER BY length DESC) AS ranking
FROM film
WHERE length > 0;

#C1.3 Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted. Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
CREATE TEMPORARY TABLE movies_per_actor2 AS 
SELECT a.actor_id, first_name, last_name, COUNT(f.film_id) AS total_films, RANK() OVER(ORDER BY COUNT(f.film_id) DESC) as ranking
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id
JOIN actor a
ON a.actor_id = fa.actor_id
GROUP BY actor_id;

SELECT * FROM movies_per_actor2;

CREATE TEMPORARY TABLE film_actor_rating AS 
SELECT f.film_id, title, a.actor_id, ranking
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id
JOIN actor a
ON a.actor_id = fa.actor_id
JOIN movies_per_actor2 mpa
ON a.actor_id = mpa.actor_id;

CREATE TEMPORARY TABLE IF NOT EXISTS min_rating AS
SELECT film_id, MIN(ranking) as highest_rank
FROM film_actor_rating
GROUP BY film_id;

SELECT far.film_id, title, far.ranking, mpa.total_films, far.actor_id,mpa.first_name,mpa.last_name
FROM film_actor_rating far
JOIN min_rating mr
ON far.film_id = mr.film_id 
AND far.ranking = mr.highest_rank
JOIN movies_per_actor2 mpa
ON far.actor_id = mpa.actor_id
ORDER BY far.film_id ASC;

DROP TEMPORARY TABLE IF EXISTS min_rating;

#Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
SELECT DATE_FORMAT(rental_date,"%Y-%m") AS "Month", COUNT(DISTINCT customer_id) AS monthly_active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date,"%Y-%m");

#Step 2. Retrieve the number of active users in the previous month.
CREATE TEMPORARY TABLE temp_month_customers AS
SELECT
	DATE_FORMAT(rental_date,"%Y-%m") AS "Month",
	COUNT(DISTINCT customer_id) AS monthly_active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date,"%Y-%m")
ORDER BY DATE_FORMAT(rental_date,"%Y-%m");

SELECT tmc.Month, monthly_active_customers, LAG(monthly_active_customers) OVER (ORDER BY month) AS "active_users_prev_month"
FROM temp_month_customers tmc
ORDER BY tmc.Month;

#Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
SELECT tmc.Month, 
monthly_active_customers, 
LAG(monthly_active_customers) OVER (ORDER BY month) AS "active_users_prev_month",
CONCAT((100*(monthly_active_customers - LAG(monthly_active_customers) OVER (ORDER BY month)) / (LAG(monthly_active_customers) OVER (ORDER BY month))),"%") as "percentage_change"
FROM temp_month_customers tmc
ORDER BY tmc.Month;

#Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        customer_id
    FROM rental
)
SELECT
    curr.month AS month,
    COUNT(DISTINCT curr.customer_id) AS retained_customers
FROM monthly_customers curr
JOIN monthly_customers prev
    ON curr.customer_id = prev.customer_id
    AND prev.month = DATE_FORMAT(
        DATE_SUB(CONCAT(curr.month, '-01'), INTERVAL 1 MONTH),
        '%Y-%m'
    )
GROUP BY curr.month
ORDER BY curr.month;