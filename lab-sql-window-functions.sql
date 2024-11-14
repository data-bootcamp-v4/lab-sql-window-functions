-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. 
-- You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.
USE sakila; 

-- 1.1. Rank films by their length and create an output table that includes the title, length, and rank columns only.
-- Filter out any rows with null or zero values in the length column.
SELECT title,
length,
RANK() OVER(ORDER BY length DESC) as 'rank'
FROM sakila.film AS f
WHERE length > 0 AND length is not null
ORDER BY length DESC;

-- 1.2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only.
-- Filter out any rows with null or zero values in the length column.
SELECT title,
length,
rating,
RANK() OVER(partition by rating ORDER BY length DESC) as 'rank'
FROM sakila.film AS f
WHERE length > 0 AND length is not null
ORDER BY rating, length DESC;

-- 1.3 Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films,
-- as well as the total number of films in which they have acted. 
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
CREATE VIEW actor_films AS
SELECT actor_id,
count(distinct(film_id)) as num_films
FROM film_actor
GROUP BY actor_id
;

CREATE VIEW film_actors as
SELECT f.title, a.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name FROM film as f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id;

CREATE VIEW film_actor_ranking AS
SELECT f.title, a.actor_id, f.actor_name,
a.num_films as actor_in_n_films,
RANK() OVER(partition by title order by title, num_films DESC) as actor_rank
FROM actor_films as a
JOIN film_actors as f
ON f.actor_id = a.actor_id
ORDER BY title, actor_in_n_films DESC
;

SELECT title, actor_name, actor_in_n_films  FROM film_actor_ranking
WHERE actor_rank = 1;

-- 2 This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance.
-- By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.

-- The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an analysis on the 
-- monthly percentage change in the number of active customers and the number of retained customers. 
-- Use the Sakila database and progressively build queries to achieve the desired outcome.

-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
SELECT COUNT(customer_id), 
       DATE_FORMAT(CONVERT(rental_date, DATE), '%m') AS rental_month,
       DATE_FORMAT(CONVERT(rental_date, DATE), '%Y') AS rental_year
FROM sakila.rental
GROUP BY rental_year, rental_month;

CREATE OR REPLACE VIEW user_activity AS
SELECT DATE_FORMAT(CONVERT(rental_date,DATE), '%Y') AS rental_year,
       DATE_FORMAT(CONVERT(rental_date,DATE), '%m') AS rental_month,
       COUNT(DISTINCT(customer_id)) as unique_customers
FROM sakila.rental
GROUP BY rental_year, rental_month;

SELECT * FROM user_activity;

-- Step 2. Retrieve the number of active users in the previous month.
CREATE OR REPLACE VIEW user_activity_2 AS
SELECT *, LAG(unique_customers,1) OVER(ORDER BY rental_year, rental_month) AS previous_month_uniques
FROM user_activity
;

-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
CREATE OR REPLACE VIEW user_activity_3 AS
SELECT *, 100*(unique_customers/previous_month_uniques-1) as unique_change_pct
FROM user_activity_2;

-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
Create view monthly_customer_rentals as
SELECT customer_id, 
       DATE_FORMAT(CONVERT(rental_date, DATE), '%m') AS rental_month,
       DATE_FORMAT(CONVERT(rental_date, DATE), '%Y') AS rental_year,
       count(*) AS total_rentals
FROM sakila.rental
GROUP BY customer_id, rental_month, rental_year
ORDER BY customer_id, rental_year, rental_month;

SELECT * FROM monthly_customer_rentals;