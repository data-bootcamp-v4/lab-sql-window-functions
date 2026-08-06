USE sakila;


-- =====================================================
-- CHALLENGE 1
-- =====================================================


-- 1. Rank films by length

SELECT
    title,
    length,
    RANK() OVER (
        ORDER BY length DESC
    ) AS film_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0
ORDER BY film_rank, title;



-- 2. Rank films by length within each rating

SELECT
    title,
    length,
    rating,
    RANK() OVER (
        PARTITION BY rating
        ORDER BY length DESC
    ) AS film_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0
ORDER BY rating, film_rank, title;



-- 3. Show the most prolific actor for each film

WITH actor_totals AS (
    SELECT
        actor_id,
        COUNT(film_id) AS total_films
    FROM film_actor
    GROUP BY actor_id
),

film_actor_ranking AS (
    SELECT
        f.title,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        at.total_films,

        RANK() OVER (
            PARTITION BY f.film_id
            ORDER BY at.total_films DESC
        ) AS actor_rank

    FROM film AS f

    JOIN film_actor AS fa
        ON f.film_id = fa.film_id

    JOIN actor AS a
        ON fa.actor_id = a.actor_id

    JOIN actor_totals AS at
        ON a.actor_id = at.actor_id
)

SELECT
    title,
    actor_name,
    total_films
FROM film_actor_ranking
WHERE actor_rank = 1
ORDER BY title, actor_name;



-- =====================================================
-- CHALLENGE 2
-- =====================================================


-- 1. Monthly active customers

WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)

SELECT
    rental_month,
    active_customers
FROM monthly_active
ORDER BY rental_month;



-- 2. Active customers in the previous month

WITH monthly_active AS (
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

FROM monthly_active
ORDER BY rental_month;



-- 3. Percentage change in active customers

WITH monthly_active AS (
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

    FROM monthly_active
)

SELECT
    rental_month,
    active_customers,
    previous_month_customers,

    ROUND(
        (
            active_customers
            - previous_month_customers
        )
        / NULLIF(previous_month_customers, 0)
        * 100,
        2
    ) AS percentage_change

FROM monthly_comparison
ORDER BY rental_month;



-- 4. Retained customers

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        CAST(
            DATE_FORMAT(rental_date, '%Y-%m-01')
            AS DATE
        ) AS rental_month
    FROM rental
)

SELECT
    DATE_FORMAT(
        current_month.rental_month,
        '%Y-%m'
    ) AS rental_month,

    COUNT(
        DISTINCT current_month.customer_id
    ) AS retained_customers

FROM customer_months AS current_month

JOIN customer_months AS previous_month
    ON current_month.customer_id =
       previous_month.customer_id

   AND previous_month.rental_month =
       DATE_SUB(
           current_month.rental_month,
           INTERVAL 1 MONTH
       )

GROUP BY current_month.rental_month
ORDER BY current_month.rental_month;