-- ============================================================
-- Lab | Window Functions (Sakila database)
-- ============================================================


-- ================================================================
-- CHALLENGE 1
-- ================================================================

-- ----------------------------------------------------------------
-- 1.1 Rank films by their length.
-- Output: title, length, rank only.
-- Filter out rows with null or zero length.
-- ----------------------------------------------------------------
SELECT
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS rank_num
FROM film
WHERE length IS NOT NULL
  AND length <> 0;


-- ----------------------------------------------------------------
-- 1.2 Rank films by length within the rating category.
-- Output: title, length, rating, rank only.
-- Filter out rows with null or zero length.
-- ----------------------------------------------------------------
SELECT
    title,
    length,
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank_num
FROM film
WHERE length IS NOT NULL
  AND length <> 0;


-- ----------------------------------------------------------------
-- 1.3 For each film in Sakila, show the actor/actress who has
-- acted in the greatest number of films, and the total number
-- of films in which they have acted.
--
-- Approach:
--   1) actor_film_counts: total films per actor.
--   2) ranked_actor_film_counts: rank actors by that count
--      (DESC), per film, using film_actor to know which actors
--      appear in which film.
--   3) Final SELECT: keep, for each film, only the actor with
--      rank = 1 (i.e. the actor with the most films overall,
--      among those who acted in that film).
-- ----------------------------------------------------------------

-- Step 1: total number of films per actor
WITH actor_film_counts AS (
    SELECT
        fa.actor_id,
        COUNT(fa.film_id) AS film_count
    FROM film_actor fa
    GROUP BY fa.actor_id
),

-- Step 2: for every film, rank the actors who appear in it
-- by their overall film_count (descending)
ranked_actor_film_counts AS (
    SELECT
        fa.film_id,
        fa.actor_id,
        afc.film_count,
        RANK() OVER (
            PARTITION BY fa.film_id
            ORDER BY afc.film_count DESC
        ) AS actor_rank
    FROM film_actor fa
    JOIN actor_film_counts afc
        ON afc.actor_id = fa.actor_id
)

-- Step 3: keep the top-ranked actor per film and bring in names/titles
SELECT
    f.film_id,
    f.title,
    a.actor_id,
    a.first_name,
    a.last_name,
    rafc.film_count AS total_films
FROM ranked_actor_film_counts rafc
JOIN film f
    ON f.film_id = rafc.film_id
JOIN actor a
    ON a.actor_id = rafc.actor_id
WHERE rafc.actor_rank = 1
ORDER BY f.film_id;


-- ================================================================
-- CHALLENGE 2
-- ================================================================

-- ----------------------------------------------------------------
-- Step 1: Monthly active customers
-- (number of unique customers who rented a movie in each month)
-- ----------------------------------------------------------------
WITH monthly_active_customers AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT *
FROM monthly_active_customers
ORDER BY rental_month;


-- ----------------------------------------------------------------
-- Step 2: Active customers in the previous month
-- (uses LAG() to bring the previous row's active_customers value)
-- ----------------------------------------------------------------
WITH monthly_active_customers AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
),
monthly_active_with_previous AS (
    SELECT
        rental_month,
        active_customers,
        LAG(active_customers) OVER (ORDER BY rental_month) AS previous_month_active_customers
    FROM monthly_active_customers
)
SELECT *
FROM monthly_active_with_previous
ORDER BY rental_month;


-- ----------------------------------------------------------------
-- Step 3: Percentage change in active customers
-- between the current and the previous month
-- ----------------------------------------------------------------
WITH monthly_active_customers AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
),
monthly_active_with_previous AS (
    SELECT
        rental_month,
        active_customers,
        LAG(active_customers) OVER (ORDER BY rental_month) AS previous_month_active_customers
    FROM monthly_active_customers
)
SELECT
    rental_month,
    active_customers,
    previous_month_active_customers,
    ROUND(
        (active_customers - previous_month_active_customers)
        / previous_month_active_customers * 100,
        2
    ) AS pct_change
FROM monthly_active_with_previous
ORDER BY rental_month;


-- ----------------------------------------------------------------
-- Step 4: Number of retained customers every month
-- (customers who rented movies in BOTH the current and the
-- previous month)
--
-- Approach: build a per-customer, per-month activity table, then
-- self-join each (customer, month) row to the same customer's
-- row from the previous month (month - 1) to check retention.
-- ----------------------------------------------------------------
WITH customer_rental_months AS (
    SELECT DISTINCT
        customer_id,
        CAST(DATE_FORMAT(rental_date, '%Y-%m-01') AS DATE) AS rental_month
    FROM rental
),
retained_customers AS (
    SELECT
        curr.rental_month,
        COUNT(DISTINCT curr.customer_id) AS retained_customers
    FROM customer_rental_months curr
    JOIN customer_rental_months prev
        ON prev.customer_id = curr.customer_id
       AND prev.rental_month = DATE_SUB(curr.rental_month, INTERVAL 1 MONTH)
    GROUP BY curr.rental_month
)
SELECT
    DATE_FORMAT(rental_month, '%Y-%m') AS rental_month,
    retained_customers
FROM retained_customers
ORDER BY rental_month;