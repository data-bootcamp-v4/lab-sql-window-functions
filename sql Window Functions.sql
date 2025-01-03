-- 1
SELECT 
    title, 
    length, 
    RANK() OVER (ORDER BY length DESC) as 'Rank'
FROM film
WHERE length IS NOT NULL AND length > 0;
-- 2 
SELECT 
    title, 
    length,
    rating,
    RANK() OVER (Partition by rating ORDER BY length DESC) as 'Rank'
FROM film
WHERE length IS NOT NULL AND length > 0;

-- 3
CREATE TEMPORARY TABLE ActorFilmCount AS
SELECT 
    fa.actor_id, 
    a.first_name, 
    a.last_name, 
    COUNT(fa.film_id) AS total_films
FROM film_actor fa
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id, a.first_name, a.last_name;

select * from ActorFilmCount
order by total_films DESC;

WITH FilmActors AS (
    SELECT 
        f.film_id,
        f.title,
        fa.actor_id,
        a.first_name,
        a.last_name
    FROM film f
    JOIN film_actor fa ON f.film_id = fa.film_id
    JOIN actor a ON fa.actor_id = a.actor_id
)
SELECT * FROM FilmActors;

WITH MaxActorFilms AS (
    SELECT 
        fa.film_id,
        fa.title,
        af1.actor_id,
        af1.first_name,
        af1.last_name,
        af1.total_films
    FROM FilmActors fa
    JOIN ActorFilmCount af1
    ON fa.actor_id = af.actor_id
    WHERE af.total_films = (
        SELECT MAX(afc.total_films)
        FROM ActorFilmCount afc
        WHERE afc.actor_id = af1.actor_id
    )
)
SELECT 
    title, 
    first_name AS actor_first_name, 
    last_name AS actor_last_name, 
    total_films
FROM MaxActorFilms
ORDER BY title;

-- Challenge 2
-- step 1
SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month, 
    COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month;
-- step 2

-- step 3
WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY rental_month),
CurrentAndPreviousMonth AS (
    SELECT 
        rental_month,
        active_customers,
        LAG(active_customers) OVER (ORDER BY rental_month) AS previous_month_customers
    FROM MonthlyActiveCustomers)
SELECT 
    rental_month AS current_month,
    active_customers AS current_month_customers,
    previous_month_customers,
    ROUND(((active_customers - previous_month_customers) / previous_month_customers) * 100, 0) AS percentage_change
FROM CurrentAndPreviousMonth
WHERE previous_month_customers IS NOT NULL;

-- step 4
SELECT 
    customer_id,
    COUNT(DISTINCT DATE_FORMAT(rental_date, '%Y-%m')) AS months_rented,
    CASE 
        WHEN COUNT(DISTINCT DATE_FORMAT(rental_date, '%Y-%m')) > 1 THEN 1
        ELSE 0
    END AS repeated_customer
FROM rental
GROUP BY customer_id
ORDER BY months_rented DESC;

