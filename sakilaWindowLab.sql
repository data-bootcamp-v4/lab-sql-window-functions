USE sakila;

-- Challenge 1

-- 1: Rank Films by Length
SELECT
    film.title,
    film.length,
    RANK() OVER (ORDER BY film.length) AS film_rank
FROM
    film
WHERE
    film.length IS NOT NULL AND film.length > 0;


-- 2: Rank Films by Length Within Rating Category

SELECT
    film.title,
    film.length,
    film.rating,
    RANK() OVER (PARTITION BY film.rating ORDER BY film.length) AS film_rank_within_rating
FROM
    film
WHERE
    film.length IS NOT NULL AND film.length > 0;
    
-- 3: Most Prolific Actor or Actress

WITH actor_film_counts AS (
    SELECT
        actor.actor_id,
        CONCAT(actor.first_name, ' ', actor.last_name) AS actor_name,
        COUNT(film_actor.film_id) AS film_count
    FROM
        actor
    JOIN
        film_actor ON actor.actor_id = film_actor.actor_id
    GROUP BY
        actor.actor_id, actor_name
)
SELECT
    actor_name,
    film_count
FROM
    actor_film_counts
WHERE
    film_count = (SELECT MAX(film_count) FROM actor_film_counts);

-- Challenge 2

-- 1: Retrieve Monthly Active Customers

SELECT
    DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
    COUNT(DISTINCT rental.customer_id) AS active_customers
FROM
    rental
GROUP BY
    rental_month
ORDER BY
    rental_month;

-- 2: Retrieve Active Users in the Previous Month

WITH previous_month_rentals AS (
    SELECT
        DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
        rental.customer_id
    FROM
        rental
    WHERE
        DATE_FORMAT(rental.rental_date, '%Y-%m') = DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m')
)
SELECT
    COUNT(DISTINCT customer_id) AS active_users_previous_month
FROM
    previous_month_rentals;

-- 3: Calculate Percentage Change in Active Customers

WITH current_month_active AS (
SELECT
    DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
    COUNT(DISTINCT rental.customer_id) AS active_customers
FROM
    rental
GROUP BY
    rental_month
ORDER BY
    rental_month
),
previous_month_active AS (
 WITH previous_month_rentals AS (
    SELECT
        DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
        rental.customer_id
    FROM
        rental
    WHERE
        DATE_FORMAT(rental.rental_date, '%Y-%m') = DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m')
)
SELECT
    COUNT(DISTINCT customer_id) AS active_users_previous_month
FROM
    previous_month_rentals
)
SELECT
    (current_month_active.active_customers - previous_month_active.active_users_previous_month) /
    previous_month_active.active_users_previous_month * 100 AS percentage_change
FROM
    current_month_active, previous_month_active;

-- 4: Calculate Retained Customers

WITH current_month_rentals AS (
    SELECT
        DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
        rental.customer_id
    FROM
        rental
    WHERE
        DATE_FORMAT(rental.rental_date, '%Y-%m') = DATE_FORMAT(NOW(), '%Y-%m')
),
previous_month_rentals AS (
    SELECT
        DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
        rental.customer_id
    FROM
        rental
    WHERE
        DATE_FORMAT(rental.rental_date, '%Y-%m') = DATE_FORMAT(NOW() - INTERVAL 1 MONTH, '%Y-%m')
)
SELECT
    current_month_rentals.rental_month,
    COUNT(DISTINCT current_month_rentals.customer_id) AS retained_customers
FROM
    current_month_rentals
JOIN
    previous_month_rentals ON current_month_rentals.customer_id = previous_month_rentals.customer_id
GROUP BY
    current_month_rentals.rental_month;
