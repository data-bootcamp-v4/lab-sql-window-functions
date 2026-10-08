USE sakila;

-- CH 1
-- 1.1
SELECT * FROM film;

SELECT 	title,
		length,
        RANK () OVER (ORDER BY length DESC) AS length_rank
FROM film
WHERE length IS NOT NULL AND length > 0;

-- 1.2
SELECT * FROM film;

SELECT 	title,
		length,
        rating,
        RANK () OVER (PARTITION BY rating ORDER BY length DESC) AS length_rank
FROM film
WHERE length IS NOT NULL AND length > 0;

-- 1.3
SELECT * FROM film;
SELECT * FROM actor;
SELECT * FROM film_actor;

WITH actor_counts AS (
	SELECT actor_id, COUNT(film_id) AS film_count
	FROM film_actor
	GROUP BY actor_id
),
	ranked_actors AS (SELECT ac.actor_id, 
		film_count,
        RANK() OVER(PARTITION BY fa.film_id ORDER BY film_count DESC) AS actor_rank,
        a.first_name,
        a.last_name,
        fa.film_id
	FROM actor_counts AS ac
	JOIN actor AS a
	ON ac.actor_id = a.actor_id
	JOIN film_actor AS fa
	ON ac.actor_id = fa.actor_id)
SELECT 	title, 
		first_name, 
		last_name, 
        film_count
FROM ranked_actors AS ra
JOIN film AS f
ON ra.film_id = f.film_id
WHERE actor_rank = 1;

-- CH2


