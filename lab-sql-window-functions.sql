
-- =============================================================================================================================================================================
-- Challenge 1: use SQL RANK() function to rank films by their length,length within the rating category, and by the actor/actress who has acted in the greatest number of films.
-- =============================================================================================================================================================================
USE sakila;
-- 1. Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.

SELECT 
    title, 
    length, 
    RANK() OVER (ORDER BY length DESC) AS length_rank
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0;

-- 2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. Filter out any rows with null or zero values in the length column.

SELECT 
    title, 
    length, 
    rating, 
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank_within_rating
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0;

-- 3. Produce a list that shows for each film the actor who has acted in the greatest number of films, as well as the total number of films in which they have acted. 
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.  
    
    WITH ActorFilmCount AS (                         # CTE ActorFilmCount calculates how many films each actor has appeared in
    SELECT 
        fa.actor_id,
        COUNT(fa.film_id) AS total_films
    FROM 
        film_actor fa
    GROUP BY 
        fa.actor_id
), 
FilmMaxActor AS (                                    # FilmMaxActor finds the actor with the highest total_films for each film
    SELECT 
        fa.film_id,
        f.title,
        fa.actor_id,
        afc.total_films
    FROM 
        film_actor fa
    JOIN 
        ActorFilmCount afc ON fa.actor_id = afc.actor_id
    JOIN 
        film f ON fa.film_id = f.film_id
    WHERE 
        afc.total_films = (
            SELECT MAX(afc2.total_films)
            FROM film_actor fa2
            JOIN ActorFilmCount afc2 ON fa2.actor_id = afc2.actor_id
            WHERE fa2.film_id = fa.film_id
        )
)
SELECT                                                # Retrieves the actor name along with the film title and the actor’s total film count
    fma.title AS film_title,
    CONCAT(a.first_name," ",a.last_name) AS actor_name,
    fma.total_films
FROM 
    FilmMaxActor fma
JOIN 
    actor a ON fma.actor_id = a.actor_id
ORDER BY 
    film_title;

-- ===============================================================================================================================================================
-- Challenge 2: analyzing customer activity and retention in the Sakila database to gain insight into business performance.
-- ===============================================================================================================================================================

-- Perform a comprehensive analysis of customer activity and retention by conducting an analysis on the monthly percentage change in the number of active customers and the number of retained customers.

-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

SELECT 
    DATE_FORMAT(r.rental_date, '%Y-%m') AS rental_month,
    COUNT(DISTINCT r.customer_id) AS active_customers
FROM
    rental r
GROUP BY rental_month
ORDER BY rental_month;

-- Step 2. Retrieve the number of active users in the previous month.
    
    WITH MonthlyActiveCustomers AS (
    SELECT 
        YEAR(r.rental_date) AS rental_year,
        MONTH(r.rental_date) AS rental_month,
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM 
        rental r
    GROUP BY 
        rental_year, rental_month
)
SELECT 
    curr.rental_year,
    curr.rental_month,
    curr.active_customers AS current_active_customers,
    COALESCE(prev.active_customers, 0) AS previous_active_customers
FROM 
    MonthlyActiveCustomers curr
LEFT JOIN 
    MonthlyActiveCustomers prev 
ON 
    (curr.rental_year = prev.rental_year AND curr.rental_month = prev.rental_month + 1)
    OR (curr.rental_year = prev.rental_year + 1 AND curr.rental_month = 1 AND prev.rental_month = 12)
ORDER BY 
    curr.rental_year, curr.rental_month;
    
-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.

WITH MonthlyActiveCustomers AS (
    SELECT 
        YEAR(r.rental_date) AS rental_year,
        MONTH(r.rental_date) AS rental_month,
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM 
        rental r
    GROUP BY 
        rental_year, rental_month
)
SELECT 
    curr.rental_year,
    curr.rental_month,
    curr.active_customers AS current_active_customers,
    COALESCE(prev.active_customers, 0) AS previous_active_customers,
    CASE 
        WHEN prev.active_customers = 0 THEN NULL  -- Avoid division by zero
        ELSE ROUND(((curr.active_customers - prev.active_customers) / prev.active_customers) * 100, 2)
    END AS percentage_change
FROM 
    MonthlyActiveCustomers curr
LEFT JOIN 
    MonthlyActiveCustomers prev 
ON 
    (curr.rental_year = prev.rental_year AND curr.rental_month = prev.rental_month + 1)
    OR (curr.rental_year = prev.rental_year + 1 AND curr.rental_month = 1 AND prev.rental_month = 12)
ORDER BY 
    curr.rental_year, curr.rental_month;

-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

WITH MonthlyActiveCustomers AS (
    SELECT 
        customer_id,
        YEAR(rental_date) AS rental_year,
        MONTH(rental_date) AS rental_month
    FROM rental
    GROUP BY customer_id, rental_year, rental_month
)
SELECT 
    curr.rental_year,
    curr.rental_month,
    COUNT(DISTINCT curr.customer_id) AS retained_customers
FROM 
    MonthlyActiveCustomers curr
JOIN 
    MonthlyActiveCustomers prev
ON 
    curr.customer_id = prev.customer_id
    AND curr.rental_year = prev.rental_year
    AND curr.rental_month = prev.rental_month + 1
    OR (curr.rental_year = prev.rental_year + 1 AND curr.rental_month = 1 AND prev.rental_month = 12)
GROUP BY 
    curr.rental_year, curr.rental_month
ORDER BY 
    curr.rental_year, curr.rental_month;
