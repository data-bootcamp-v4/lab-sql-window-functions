USE sakila;

-- Challenge 1, Exercise 1
-- Rank films from longest to shortest

SELECT
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS length_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0;
  -- Challenge 1, Exercise 2
-- Rank films by length within each rating category

SELECT
    title,
    length,
    rating,
    RANK() OVER (
        PARTITION BY rating
        ORDER BY length DESC
    ) AS length_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0;
  -- Challenge 1, Exercise 3
-- For each film, find the actor with the most film appearances

WITH actor_film_counts AS (
    SELECT
        actor_id,
        COUNT(*) AS total_films
    FROM film_actor
    GROUP BY actor_id
),

ranked_actors AS (
    SELECT
        f.film_id,
        f.title,
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        afc.total_films,
        RANK() OVER (
            PARTITION BY f.film_id
            ORDER BY afc.total_films DESC
        ) AS actor_rank
    FROM film AS f
    JOIN film_actor AS fa
        ON f.film_id = fa.film_id
    JOIN actor AS a
        ON fa.actor_id = a.actor_id
    JOIN actor_film_counts AS afc
        ON a.actor_id = afc.actor_id
)

SELECT
    title,
    actor_name,
    total_films
FROM ranked_actors
WHERE actor_rank = 1
ORDER BY title;
-- Challenge 2, Step 1
-- Count unique active customers per month

SELECT
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
ORDER BY rental_month;
-- Challenge 2, Step 2
-- Retrieve active customers from the previous month

WITH monthly_active_customers AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)

SELECT
    rental_month,
    active_customers,
    LAG(active_customers) OVER (
        ORDER BY rental_month
    ) AS previous_month_customers
FROM monthly_active_customers
ORDER BY rental_month;
-- Challenge 2, Step 3
-- Calculate the monthly percentage change in active customers

WITH monthly_active_customers AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
),

monthly_comparison AS (
    SELECT
        rental_month,
        active_customers,
        LAG(active_customers) OVER (
            ORDER BY rental_month
        ) AS previous_month_customers
    FROM monthly_active_customers
)

SELECT
    rental_month,
    active_customers,
    previous_month_customers,
    ROUND(
        (
            active_customers - previous_month_customers
        ) / previous_month_customers * 100,
        2
    ) AS percentage_change
FROM monthly_comparison
ORDER BY rental_month;
-- Challenge 2, Step 4
-- Calculate retained customers for each month

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m-01') AS rental_month
    FROM rental
),

monthly_retention AS (
    SELECT
        current_month.rental_month,
        COUNT(DISTINCT current_month.customer_id) AS retained_customers
    FROM customer_months AS current_month
    JOIN customer_months AS previous_month
        ON current_month.customer_id = previous_month.customer_id
        AND current_month.rental_month =
            DATE_FORMAT(
                DATE_ADD(previous_month.rental_month, INTERVAL 1 MONTH),
                '%Y-%m-01'
            )
    GROUP BY current_month.rental_month
)

SELECT
    DATE_FORMAT(rental_month, '%Y-%m') AS rental_month,
    retained_customers
FROM monthly_retention
ORDER BY rental_month;
