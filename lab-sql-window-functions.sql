USE sakila;

# Challenge 1
-- Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

SELECT title,
		length,
        RANK() OVER(ORDER BY length DESC) AS 'rank' # partition by is not alway needed 
FROM film
WHERE length IS NOT null AND length != 0; # is not and null go together 

-- Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

SELECT rating,
		title,
        length, 
        RANK() OVER(ORDER BY length DESC) AS 'rank'
FROM film
WHERE length IS NOT null AND length != 0;

-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, 
-- as well as the total number of films in which they have acted. 
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries. 


WITH actor_film_counts AS (
    SELECT
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        COUNT(fa.film_id) AS total_films
    FROM actor a
    JOIN film_actor fa
        ON a.actor_id = fa.actor_id
    GROUP BY
        a.actor_id,
        a.first_name,
        a.last_name
),
ranked_actors_per_film AS (
    SELECT
        f.film_id,
        f.title,
        afc.actor_name,
        afc.total_films,
        RANK() OVER (
            PARTITION BY f.film_id
            ORDER BY afc.total_films DESC
        ) AS actor_rank
    FROM film f
    JOIN film_actor fa
        ON f.film_id = fa.film_id
    JOIN actor_film_counts afc
        ON fa.actor_id = afc.actor_id
)
SELECT
    film_id,
    title,
    actor_name,
    total_films
FROM ranked_actors_per_film
WHERE actor_rank = 1
ORDER BY title;


# Challenge 2
-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(rental_date, '%Y-%M') AS rental_month,
        customer_id
    FROM rental)
SELECT DISTINCT
    rental_month,
    COUNT(customer_id) OVER (PARTITION BY rental_month) AS active_customers
FROM monthly_customers;
        
        
-- Step 2. Retrieve the number of active users in the previous month.
   
WITH monthly_active_customers AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%M') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%M')
)
SELECT
    rental_month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY rental_month) AS previous_month_active_customers
FROM monthly_active_customers;




-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.


WITH monthly_active_customers AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
),
monthly_with_previous AS (
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
    ) AS percentage_change
FROM monthly_with_previous;



-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.

WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        customer_id
    FROM rental
),
customers_with_previous AS (
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
    COUNT(customer_id) AS retained_customers
FROM customers_with_previous
WHERE previous_rental_month = DATE_FORMAT(
    DATE_SUB(STR_TO_DATE(CONCAT(rental_month, '-01'), '%Y-%m-%d'),
    INTERVAL 1 MONTH),
    '%Y-%m'
)
GROUP BY rental_month
ORDER BY rental_month;

        