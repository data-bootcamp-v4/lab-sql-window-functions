-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function.

-- You will use it to rank films by their length,
use sakila;
-- their length within the rating category,
-- Rank films by length within each rating category, excluding null or 0 lengths


-- and by the actor or actress who has acted in the greatest number of films.

-- Exercise 1: Rank films by their length
-- Create an output table that includes the title, length, and rank columns only.
-- Filter out any rows with null or zero values in the length column.
SELECT 
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS rank_length
FROM film
WHERE length IS NOT NULL AND length > 0;
-- Exercise 2: Rank films by length within the rating category
-- Create an output table that includes the title, length, rating, and rank columns only.
-- Filter out any rows with null or zero values in the length column.
SELECT 
    title,
    length,
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank_length
FROM film
WHERE length IS NOT NULL AND length > 0;

-- Exercise 3: For each film, show the actor or actress who has acted in the greatest number of films.
-- Include the total number of films in which they have acted.
-- Use temporary tables, CTEs, or Views when appropriate to simplify your queries.

-- First, get the number of films each actor has appeared in
WITH actor_film_counts AS (
    SELECT 
        actor_id,
        COUNT(*) AS film_count
    FROM film_actor
    GROUP BY actor_id
),

-- Then, join actor names to those counts
actor_stats AS (
    SELECT 
        a.actor_id,
        a.first_name,
        a.last_name,
        afc.film_count
    FROM actor a
    JOIN actor_film_counts afc ON a.actor_id = afc.actor_id
),

-- Join with film_actor again to associate actors with films
film_with_actors AS (
    SELECT 
        fa.film_id,
        fs.actor_id,
        fs.first_name,
        fs.last_name,
        fs.film_count
    FROM film_actor fa
    JOIN actor_stats fs ON fa.actor_id = fs.actor_id
),

-- Rank the actors per film based on their total number of films
ranked_actors AS (
    SELECT 
        fwa.film_id,
        fwa.first_name,
        fwa.last_name,
        fwa.film_count,
        RANK() OVER (PARTITION BY fwa.film_id ORDER BY fwa.film_count DESC) AS actor_rank
    FROM film_with_actors fwa
)

-- Select only the top-ranked actor per film
SELECT 
    f.title,
    ra.first_name,
    ra.last_name,
    ra.film_count
FROM ranked_actors ra
JOIN film f ON ra.film_id = f.film_id
WHERE actor_rank = 1;