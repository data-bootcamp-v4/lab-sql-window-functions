use sakila;
-- 1.1 Rank films by their length and create an output table that 
-- includes the title, length, and rank columns only. Filter out any 
-- rows with null or zero values in the length column.
SELECT title, length, RANK() OVER(ORDER BY length asc) AS 'Rank'
FROM film;


-- Rank films by length within the rating category and create an output 
-- table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.
SELECT f.title, length, rating, RANK() OVER(PARTITION BY rating ORDER BY length asc) AS 'Rank'
FROM film;


-- Produce a list that shows for each film in the Sakila database, 
-- the actor or actress who has acted in the greatest number of films, 
-- as well as the total number of films in which they have acted. 
-- *Hint: Use temporary tables, CTEs, or Views when appropiate to 
-- simplify your queries.*
CREATE VIEW actor_films_3 AS
SELECT a.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name, count(*) as film_counts
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
group by a.actor_id, a.first_name, a.last_name;

select *
from actor_films_3;

SELECT af.actor_name, af.film_counts, f.title AS film
FROM film_actor fa
JOIN film f ON fa.film_id = f.film_id
JOIN actor_films_3 af ON fa.actor_id = af.actor_id
JOIN (
  SELECT actor_id
  FROM actor_films_3
  GROUP BY actor_id
  ORDER BY COUNT(*) DESC
  LIMIT 1
) sub ON af.actor_id = sub.actor_id;

-- Step 1. Retrieve the number of monthly active customers, i.e., 
-- the number of unique customers who rented a movie in each month.
SELECT YEAR(rental_date) AS rental_year, MONTH(rental_date) AS rental_month, COUNT(DISTINCT customer_id) AS num_active_customers
FROM rental
GROUP BY rental_year, rental_month
ORDER BY rental_year, rental_month;


-- Step 2. Retrieve the number of active users in the previous month.
SELECT r.rental_year, r.rental_month, r.num_active_customers,
       (SELECT COUNT(DISTINCT customer_id)
        FROM rental
        WHERE YEAR(rental_date) = r.rental_year
          AND MONTH(rental_date) = r.rental_month - 1) AS prev_month_active_customers
FROM (
  SELECT YEAR(rental_date) AS rental_year, MONTH(rental_date) AS rental_month, COUNT(DISTINCT customer_id) AS num_active_customers
  FROM rental
  GROUP BY rental_year, rental_month
  HAVING rental_month > 1
) r
ORDER BY r.rental_year, r.rental_month;


-- Step 3. Calculate the percentage change in the number of active 
-- customers between the current and previous month.



-- Step 4. Calculate the number of retained customers every month, 
-- i.e., customers who rented movies in the current and previous 
-- months.
