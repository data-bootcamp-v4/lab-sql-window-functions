use sakila;

-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. 
-- You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.

-- Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.

SELECT
    title,
    length,
    RANK() OVER (ORDER BY length) AS film_rank
FROM
    film
WHERE
    length IS NOT NULL
    AND length > 0;

-- Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

select title, length, rating,
rank() over (partition by rating order by length) as length_rank
from film
where length is not null
and length > 0;


-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted. 
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

SELECT
    f.film_id,
    f.title AS film_title,
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    COUNT(*) AS total_films
FROM
    film f
JOIN
    film_actor fa ON f.film_id = fa.film_id
JOIN
    actor a ON fa.actor_id = a.actor_id
GROUP BY
    f.film_id
HAVING
    total_films = (
        SELECT
            COUNT(*)
        FROM
            film_actor
        WHERE
            film_id = f.film_id
        GROUP BY
            film_id
        ORDER BY
            COUNT(*) DESC
        LIMIT 1
    );

