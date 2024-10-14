-- Challenge 1, Exercise 1: Rank films by their length
SELECT title, length, 
       RANK() OVER (ORDER BY length DESC) AS film_rank
FROM film
WHERE length IS NOT NULL AND length > 0;

-- Challenge 1, Exercise 2: Rank films by length within the rating category
SELECT title, length, rating, 
       RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS film_rank
FROM film
WHERE length IS NOT NULL AND length > 0;

-- Challenge 1, Exercise 3: Actor/actress with the greatest number of films
WITH actor_film_count AS (
    SELECT actor.actor_id, actor.first_name, actor.last_name, COUNT(film_actor.film_id) AS film_count
    FROM actor
    JOIN film_actor ON actor.actor_id = film_actor.actor_id
    GROUP BY actor.actor_id
),
max_actor_film_count AS (
    SELECT film.film_id, MAX(actor_film_count.film_count) AS max_films
    FROM film
    JOIN film_actor ON film.film_id = film_actor.film_id
    JOIN actor_film_count ON film_actor.actor_id = actor_film_count.actor_id
    GROUP BY film.film_id
)
SELECT film.title, actor.first_name, actor.last_name, actor_film_count.film_count
FROM max_actor_film_count
JOIN film_actor ON max_actor_film_count.film_id = film_actor.film_id
JOIN actor_film_count ON film_actor.actor_id = actor_film_count.actor_id
JOIN actor ON actor.actor_id = actor_film_count.actor_id
WHERE actor_film_count.film_count = max_actor_film_count.max_films;

-- Challenge 2, Step 1: Retrieve the number of monthly active customers
WITH monthly_rentals AS (
    SELECT customer_id, DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM rental
    GROUP BY customer_id, rental_month
)
SELECT rental_month, COUNT(DISTINCT customer_id) AS active_customers
FROM monthly_rentals
GROUP BY rental_month;

-- Challenge 2, Step 2: Retrieve the number of active users in the previous month
WITH monthly_rentals AS (
    SELECT customer_id, DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM rental
    GROUP BY customer_id, rental_month
),
previous_months AS (
    SELECT rental_month, COUNT(DISTINCT customer_id) AS active_customers,
           LAG(COUNT(DISTINCT customer_id), 1) OVER (ORDER BY rental_month) AS previous_month_customers
    FROM monthly_rentals
    GROUP BY rental_month
)
SELECT rental_month, active_customers, previous_month_customers
FROM previous_months;

-- Challenge 2, Step 3: Calculate the percentage change in the number of active customers
WITH monthly_rentals AS (
    SELECT customer_id, DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM rental
    GROUP BY customer_id, rental_month
),
previous_months AS (
    SELECT rental_month, COUNT(DISTINCT customer_id) AS active_customers,
           LAG(COUNT(DISTINCT customer_id), 1) OVER (ORDER BY rental_month) AS previous_month_customers
    FROM monthly_rentals
    GROUP BY rental_month
)
SELECT rental_month, active_customers, previous_month_customers,
       ((active_customers - previous_month_customers) / previous_month_customers) * 100 AS percentage_change
FROM previous_months
WHERE previous_month_customers IS NOT NULL;

-- Challenge 2, Step 4: Calculate the number of retained customers every month
WITH current_month_customers AS (
    SELECT customer_id, DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM rental
    GROUP BY customer_id, rental_month
),
previous_month_customers AS (
    SELECT customer_id, DATE_FORMAT(DATE_ADD(rental_date, INTERVAL -1 MONTH), '%Y-%m') AS rental_month
    FROM rental
    GROUP BY customer_id, rental_month
)
SELECT cm.rental_month, COUNT(DISTINCT cm.customer_id) AS retained_customers
FROM current_month_customers cm
JOIN previous_month_customers pm ON cm.customer_id = pm.customer_id
AND cm.rental_month = pm.rental_month
GROUP BY cm.rental_month;