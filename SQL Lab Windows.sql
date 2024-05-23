USE sakila;
	-- Rank films by their length and create an output table that includes the title, length, and rank columns only. 
    -- Filter out any rows with null or zero values in the length column.

SELECT f.title, f.length,
RANK() OVER(ORDER BY length DESC)
FROM film AS f
WHERE f.length > 0;

-- Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

SELECT f.title, f.length, f.rating,
RANK() OVER(PARTITION BY rating ORDER BY length DESC) AS 'rank'
FROM film AS f
WHERE f.length IS NOT NULL AND f.rating !=0;

-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, 
-- as well as the total number of films in which they have acted. Hint: Use temporary tables, CTEs, or Views when appropiate to 
-- simplify your queries. 

-- CREATE TEMPORARY TABLE actors_ranked
#SELECT fa.film_id, f.title, a.actor_id, CONCAT(a.first_name, ' ', a.last_name) AS 'Actor Name',
#RANK() OVER(ORDER BY 'Actor Name') AS 'rank'
#FROM film AS f
#JOIN film_actor AS fa
#ON f.film_id = fa.film_id
#JOIN actor AS a
#ON fa.actor_id = a.actor_id;

SELECT *
FROM actors_ranked;

-- CORRECTION BY IRONBOT
WITH ranked_actors AS (
    SELECT
        fa.actor_id,
        a.first_name,
        a.last_name,
        COUNT(*) AS film_count,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS 'rank'
    FROM film_actor AS fa
    JOIN actor AS a ON fa.actor_id = a.actor_id
    GROUP BY fa.actor_id
)
SELECT f.title as film_title, CONCAT(a.first_name, ' ', a.last_name) as actor_name, ra.film_count
FROM film AS f
JOIN film_actor AS fa ON f.film_id = fa.film_id
JOIN actor AS a ON fa.actor_id = a.actor_id
JOIN ranked_actors AS ra ON ra.actor_id = a.actor_id
WHERE ra.rank = 1;
