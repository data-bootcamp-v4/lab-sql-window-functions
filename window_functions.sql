-- Challenge 1 - Exercise 1
SELECT
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS film_rank
FROM film
WHERE length IS NOT NULL
  AND length <> 0;


-- Challenge 1 - Exercise 2
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
  AND length <> 0;

  -- Challenge 1 - Exercise 3
WITH actor_film_counts AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        COUNT(fa.film_id) AS film_count
    FROM actor a
    JOIN film_actor fa
        ON a.actor_id = fa.actor_id
    GROUP BY
        a.actor_id,
        a.first_name,
        a.last_name
)
SELECT
    first_name,
    last_name,
    film_count
FROM actor_film_counts
ORDER BY film_count DESC
LIMIT 1;

-- Challenge 2 - Step 1
SELECT
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month
ORDER BY rental_month;

-- Challenge 2 - Step 2
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY rental_month
)
SELECT
    rental_month,
    active_customers,
    LAG(active_customers) OVER (
        ORDER BY rental_month
    ) AS previous_month_customers
FROM monthly_active
ORDER BY rental_month;

-- Challenge 2 - Step 3
-- Challenge 2 - Step 3
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY rental_month
),
monthly_with_previous AS (
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
        (active_customers - previous_month_customers)
        / previous_month_customers * 100,
        2
    ) AS percentage_change
FROM monthly_with_previous
ORDER BY rental_month;

-- Challenge 2 - Step 4

WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        customer_id
    FROM rental
),
customer_with_previous AS (
    SELECT
        rental_month,
        customer_id,
        LAG(rental_month) OVER (
            PARTITION BY customer_id
            ORDER BY rental_month
        ) AS previous_rental_month
    FROM monthly_customers
)
SELECT
    rental_month,
    COUNT(DISTINCT customer_id) AS retained_customers
FROM customer_with_previous
WHERE previous_rental_month IS NOT NULL
GROUP BY rental_month
ORDER BY rental_month;

-- Challenge 2 - Step 4

WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        customer_id
    FROM rental
),
customer_with_previous AS (
    SELECT
        rental_month,
        customer_id,
        LAG(rental_month) OVER (
            PARTITION BY customer_id
            ORDER BY rental_month
        ) AS previous_rental_month
    FROM monthly_customers
)
SELECT
    rental_month,
    COUNT(DISTINCT customer_id) AS retained_customers
FROM customer_with_previous
WHERE previous_rental_month IS NOT NULL
GROUP BY rental_month
ORDER BY rental_month;

-- Challenge 2 - Step 5

WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        customer_id
    FROM rental
),
monthly_retention AS (
    SELECT
        current.rental_month,
        COUNT(DISTINCT current.customer_id) AS active_customers,
        COUNT(DISTINCT previous.customer_id) AS retained_customers
    FROM monthly_customers current
    LEFT JOIN monthly_customers previous
        ON current.customer_id = previous.customer_id
        AND previous.rental_month = DATE_FORMAT(
            DATE_SUB(
                STR_TO_DATE(CONCAT(current.rental_month, '-01'), '%Y-%m-%d'),
                INTERVAL 1 MONTH
            ),
            '%Y-%m'
        )
    GROUP BY current.rental_month
)
SELECT
    rental_month,
    active_customers,
    retained_customers,
    ROUND(
        retained_customers * 100.0 / active_customers,
        2
    ) AS retention_rate
FROM monthly_retention
ORDER BY rental_month;

-- Challenge 2 - Step 6

WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        customer_id
    FROM rental
),
monthly_retention AS (
    SELECT
        current.rental_month,
        COUNT(DISTINCT current.customer_id) AS active_customers,
        COUNT(DISTINCT previous.customer_id) AS retained_customers
    FROM monthly_customers current
    LEFT JOIN monthly_customers previous
        ON current.customer_id = previous.customer_id
        AND previous.rental_month = DATE_FORMAT(
            DATE_SUB(
                STR_TO_DATE(CONCAT(current.rental_month, '-01'), '%Y-%m-%d'),
                INTERVAL 1 MONTH
            ),
            '%Y-%m'
        )
    GROUP BY current.rental_month
),
retention_rates AS (
    SELECT
        rental_month,
        active_customers,
        retained_customers,
        ROUND(
            retained_customers * 100.0 / active_customers,
            2
        ) AS retention_rate
    FROM monthly_retention
)
SELECT
    rental_month,
    active_customers,
    retained_customers,
    retention_rate,
    LAG(retention_rate) OVER (
        ORDER BY rental_month
    ) AS previous_retention_rate
FROM retention_rates
ORDER BY rental_month;

