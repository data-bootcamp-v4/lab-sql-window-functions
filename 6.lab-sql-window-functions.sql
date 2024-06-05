-- Challenge 1
--Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.
SELECT
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS rank
FROM
    film
WHERE
    length IS NOT NULL AND length > 0;

-- Rank films by length within the rating category and create an output table that includes the title, length, rating, and rank columns only. Filter out any rows with null or zero values in the length column.
SELECT
    title,
    length,
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank
FROM
    film
WHERE
    length IS NOT NULL AND length > 0;

-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted.
-- Step 1: Create a CTE to count the number of films each actor has acted in.
WITH actor_film_count AS (
    SELECT
        actor_id,
        COUNT(film_id) AS film_count
    FROM
        film_actor
    GROUP BY
        actor_id
),

-- Step 2: Find the actor with the greatest number of films.
top_actor AS (
    SELECT
        actor_id,
        film_count,
        RANK() OVER (ORDER BY film_count DESC) AS rank
    FROM
        actor_film_count
)

-- Step 3: Join with the actor table to get the actor's name.
SELECT
    a.first_name,
    a.last_name,
    t.film_count
FROM
    actor a
JOIN
    top_actor t ON a.actor_id = t.actor_id
WHERE
    t.rank = 1;

-- Challenge 2
-- Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
SELECT
    DATE_FORMAT(rental_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM
    rental
GROUP BY
    month
ORDER BY
    month;

-- Retrieve the number of active users in the previous month.
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM
        rental
    GROUP BY
        month
    ORDER BY
        month
)
SELECT
    month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY month) AS prev_month_active_customers
FROM
    monthly_active;

-- Calculate the percentage change in the number of active customers between the current and previous month.
WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM
        rental
    GROUP BY
        month
    ORDER BY
        month
)
SELECT
    month,
    active_customers,
    prev_month_active_customers,
    (active_customers - prev_month_active_customers) / prev_month_active_customers * 100 AS pct_change
FROM (
    SELECT
        month,
        active_customers,
        LAG(active_customers) OVER (ORDER BY month) AS prev_month_active_customers
    FROM
        monthly_active
) AS temp
WHERE
    prev_month_active_customers IS NOT NULL;

-- Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
WITH monthly_rentals AS (
    SELECT
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS month
    FROM
        rental
),
current_month_customers AS (
    SELECT DISTINCT
        customer_id,
        month
    FROM
        monthly_rentals
),
previous_month_customers AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(DATE_SUB(STR_TO_DATE(month, '%Y-%m'), INTERVAL 1 MONTH), '%Y-%m') AS prev_month
    FROM
        current_month_customers
)
SELECT
    cm.month,
    COUNT(DISTINCT cm.customer_id) AS retained_customers
FROM
    current_month_customers cm
JOIN
    previous_month_customers pm ON cm.customer_id = pm.customer_id
WHERE
    cm.month = pm.prev_month
GROUP BY
    cm.month;
