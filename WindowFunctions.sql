USE sakila;


 /*
 CHALLENGE 1
 Exercise 1
 Rank films by length
 */

SELECT
    title,
    length,
    RANK() OVER (
        ORDER BY length DESC
    ) AS length_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0
ORDER BY length_rank, title;


/*
Exercise 2
Rank films by length within each rating category
*/

SELECT
    title,
    length,
    rating,
    RANK() OVER (
        PARTITION BY rating
        ORDER BY length DESC
    ) AS rating_length_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0
ORDER BY rating, rating_length_rank, title;


/*
Exercise 3
For every film, identify the cast member
who has appeared in the greatest number of films
*/

WITH actor_film_totals AS (
    SELECT
        actor_id,
        COUNT(DISTINCT film_id) AS total_films
    FROM film_actor
    GROUP BY actor_id
),

film_cast_rankings AS (
    SELECT
        f.film_id,
        f.title,
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        aft.total_films,
        RANK() OVER (
            PARTITION BY f.film_id
            ORDER BY aft.total_films DESC
        ) AS actor_rank
    FROM film AS f
    JOIN film_actor AS fa
        ON f.film_id = fa.film_id
    JOIN actor AS a
        ON fa.actor_id = a.actor_id
    JOIN actor_film_totals AS aft
        ON a.actor_id = aft.actor_id
)

SELECT
    film_id,
    title,
    actor_id,
    actor_name,
    total_films
FROM film_cast_rankings
WHERE actor_rank = 1
ORDER BY title, actor_name;