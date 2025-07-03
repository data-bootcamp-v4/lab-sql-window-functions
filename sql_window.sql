

USE sakila;
	

-- 1 Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.


DROP TEMPORARY TABLE rank_films;

CREATE TEMPORARY TABLE IF NOT EXISTS rank_films
SELECT title,length, RANK() OVER(ORDER BY length DESC) AS 'Rank'
FROM sakila.film
WHERE length IS NOT NULL;

select * from rank_films;

-- 2 Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

SELECT title,length, rating, RANK() OVER(partition by rating order BY length, rating DESC) AS 'Rank'
FROM sakila.film
WHERE length IS NOT NULL;

-- 3 Produce a list that shows for each film in the Sakila database, 
-- the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted. 
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
DROP temporary table names_actors;

CREATE TEMPORARY TABLE names_actors
SELECT fa.film_id,f.title, a.actor_id, a.first_name, a.last_name FROM sakila.actor as a
JOIN sakila.film_actor as fa
ON a.actor_id = film_id
JOIN sakila.film as f
ON fa.film_id = f.film_id;

SELECT film_id, title, actor_id, first_name, last_name , COUNT(actor_id) OVER(partition by film_id, actor_id) AS 'Row Number'
FROM names_actors;



CREATE TEMPORARY TABLE names_actors
SELECT fa.film_id, a.actor_id, a.first_name, a.last_name FROM sakila.actor as a
JOIN sakila.film_actor as fa;

SELECT film_id, actor_id, first_name, last_name , COUNT(film_id) OVER(partition by actor_id) AS 'Number films'
FROM names_actors;

