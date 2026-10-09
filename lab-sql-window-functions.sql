-- Challenge 1
-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.
-- Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.

SELECT
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS film_rank
FROM film
WHERE length IS NOT NULL
  AND length > 0
ORDER BY film_rank;

-- Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. Filter out any rows with null or zero values in the length column.

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
ORDER BY rating, film_rank;

-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted. Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

WITH actor_film_counts AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        COUNT(fa.film_id) AS total_films
    FROM actor AS a
    JOIN film_actor AS fa
        ON a.actor_id = fa.actor_id
    GROUP BY
        a.actor_id,
        a.first_name,
        a.last_name
),
ranked_actors AS (
    SELECT
        actor_id,
        first_name,
        last_name,
        total_films,
        RANK() OVER (ORDER BY total_films DESC) AS actor_rank
    FROM actor_film_counts
)
SELECT
    f.title,
    ra.first_name,
    ra.last_name,
    ra.total_films
FROM ranked_actors AS ra
JOIN film_actor AS fa
    ON ra.actor_id = fa.actor_id
JOIN film AS f
    ON fa.film_id = f.film_id
WHERE ra.actor_rank = 1
ORDER BY f.title;

-- Challenge 2
-- This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.
-- The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an analysis on the monthly percentage change in the number of active customers and the number of retained customers. Use the Sakila database and progressively build queries to achieve the desired outcome.

-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

SELECT
    DATE_FORMAT(rental_date, '%Y-%m-01') AS rental_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m-01')
ORDER BY rental_month;

-- Step 2. Retrieve the number of active users in the previous month.

WITH monthly_activity AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m-01') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m-01')
)
SELECT
    rental_month,
    active_customers,
    LAG(active_customers) OVER (
        ORDER BY rental_month
    ) AS previous_month_customers
FROM monthly_activity
ORDER BY rental_month;

-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.

WITH monthly_activity AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m-01') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m-01')
),
activity_comparison AS (
    SELECT
        rental_month,
        active_customers,
        LAG(active_customers) OVER (
            ORDER BY rental_month
        ) AS previous_month_customers
    FROM monthly_activity
)
SELECT
    rental_month,
    active_customers,
    previous_month_customers,
    ROUND(
        100.0 * (active_customers - previous_month_customers)
        / NULLIF(previous_month_customers, 0),
        2
    ) AS percentage_change
FROM activity_comparison
ORDER BY rental_month;

-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m-01') AS rental_month
    FROM rental
)
SELECT
    current_month.rental_month,
    COUNT(DISTINCT current_month.customer_id) AS retained_customers
FROM customer_months AS current_month
JOIN customer_months AS previous_month
    ON current_month.customer_id = previous_month.customer_id
    AND previous_month.rental_month =
        DATE_FORMAT(
            DATE_SUB(
                STR_TO_DATE(current_month.rental_month, '%Y-%m-%d'),
                INTERVAL 1 MONTH
            ),
            '%Y-%m-01'
        )
GROUP BY current_month.rental_month
ORDER BY current_month.rental_month;