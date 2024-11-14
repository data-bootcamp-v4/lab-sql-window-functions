-- 1.1.
SELECT title, length, RANK() OVER(ORDER BY length DESC) `rank`
FROM film;

-- 1.2.
SELECT title, length, rating, RANK() OVER(PARTITION BY rating ORDER BY length DESC) `rank`
FROM film;

-- 1.3.
WITH
cte_acted_films_per_actor AS (
	SELECT fa.actor_id, COUNT(*) films_acted FROM film_actor fa
	JOIN actor a ON a.actor_id = fa.actor_id
	GROUP BY fa.actor_id
),
cte_top_actor AS (
    SELECT actor_id 
    FROM cte_acted_films_per_actor 
    WHERE films_acted = (SELECT MAX(films_acted) FROM cte_acted_films_per_actor)
)
SELECT CONCAT(a.first_name, " ", a.last_name) actor_name, f.title FROM film_actor fa
JOIN film f ON f.film_id = fa.film_id
JOIN actor a ON a.actor_id = fa.actor_id
JOIN cte_top_actor ta ON ta.actor_id = fa.actor_id;

-- 2.1.
WITH cte_rental_counts AS (
	SELECT
		customer_id,
		CONCAT(MONTH(rental_date), "/", YEAR(rental_date)) AS current_month,
		COUNT(*) AS rental_count,
		LAG(COUNT(*), 1) OVER(ORDER BY customer_id) AS previous_rental_count
	FROM rental
	GROUP BY customer_id, current_month
)
SELECT
	customer_id,
    current_month,
    100 * (rental_count - previous_rental_count) / rental_count AS percentage_change
FROM cte_rental_counts;

