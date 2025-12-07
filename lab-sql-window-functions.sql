--1. Rank films by their length.
SELECT
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS film_rank
FROM
    film
WHERE
    length IS NOT NULL AND length > 0
ORDER BY
    film_rank, length DESC;
--Rank films by length within the rating category.
SELECT
    title,
    length,
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS length_rank_by_rating
FROM
    film
WHERE
    length IS NOT NULL AND length > 0
ORDER BY
    rating, length_rank_by_rating;
--Identify the most prolific actor/actress for each film.
WITH actor_film_count AS (
    -- CTE 1: Calculates the total number of films for each actor
    SELECT
        actor_id,
        COUNT(film_id) AS total_films_acted_in
    FROM
        film_actor
    GROUP BY
        actor_id
), 
film_actor_rank AS (
    -- CTE 2: Joins actors and films, then ranks actors within each film by their total film count
    SELECT
        f.title,
        a.first_name,
        a.last_name,
        afc.total_films_acted_in,
        RANK() OVER (
            PARTITION BY f.film_id
            ORDER BY afc.total_films_acted_in DESC
        ) AS prolific_rank
    FROM
        film f
    JOIN
        film_actor fa ON f.film_id = fa.film_id
    JOIN
        actor a ON fa.actor_id = a.actor_id
    JOIN
        actor_film_count afc ON a.actor_id = afc.actor_id
)
-- Final Select: Filter for the most prolific actor (Rank 1) for each film
SELECT
    title AS film_title,
    CONCAT(first_name, ' ', last_name) AS most_prolific_actor,
    total_films_acted_in
FROM
    film_actor_rank
WHERE
    prolific_rank = 1
ORDER BY
    film_title;
--Calculate the number of retained customers every month.
WITH monthly_rentals AS (
    -- CTE 1: Lists each customer's active month
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS current_month
    FROM
        rental
),
retained_customers AS (
    -- CTE 2: Self-join to identify retained customers
    SELECT
        m2.current_month,
        m2.customer_id
    FROM
        monthly_rentals m1
    JOIN
        monthly_rentals m2 ON m1.customer_id = m2.customer_id
    WHERE
        -- Check if m1 (previous month) is exactly one month before m2 (current month)
        m2.current_month = DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(m1.current_month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH), '%Y-%m')
)
SELECT
    current_month,
    COUNT(DISTINCT customer_id) AS retained_customer_count
FROM
    retained_customers
GROUP BY
    current_month
ORDER BY
    current_month;