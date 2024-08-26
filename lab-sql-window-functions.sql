
## Challenge 1
#This challenge consists of three exercises that will test your ability to use the SQL RANK() function. You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.

#1. Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.
use sakila;
SELECT 
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS rank
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0;

#2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. Filter out any rows with null or zero values in the length column.
SELECT 
    title,
    length,
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank
FROM 
    film
WHERE 
    length IS NOT NULL AND length > 0
    
#3. Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted. *Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.*
WITH ActorFilmCount AS (
    SELECT 
        actor_id,
        COUNT(film_id) AS film_count
    FROM 
        film_actor
    GROUP BY 
        actor_id
), MaxActorFilmCount AS (
    SELECT 
        actor_id,
        MAX(film_count) AS max_film_count
    FROM 
        ActorFilmCount
    GROUP BY 
        actor_id
)
SELECT 
    f.title,
    a.first_name,
    a.last_name,
    afc.film_count
FROM 
    film f
JOIN 
    film_actor fa ON f.film_id = fa.film_id
JOIN 
    actor a ON fa.actor_id = a.actor_id
JOIN 
    ActorFilmCount afc ON a.actor_id = afc.actor_id
JOIN 
    MaxActorFilmCount mafc ON afc.actor_id = mafc.actor_id AND afc.film_count = mafc.max_film_count;

## Challenge 2

#This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. 
#By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.

#The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an analysis on the monthly percentage change in the number of active customers and the number of retained customers. Use the Sakila database and progressively build queries to achieve the desired outcome. 
#- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month just to git and comit.
SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM 
    rental
GROUP BY 
    rental_month
ORDER BY 
    rental_month;
    
#- Step 2. Retrieve the number of active users in the previous month.
WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM 
        rental
    GROUP BY 
        rental_month
)
SELECT 
    rental_month,
    active_customers,
    LAG(active_customers, 1) OVER (ORDER BY rental_month) AS previous_month_active_customers
FROM 
    MonthlyActiveCustomers;

#- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM 
        rental
    GROUP BY 
        rental_month
)
SELECT 
    rental_month,
    active_customers,
    LAG(active_customers, 1) OVER (ORDER BY rental_month) AS previous_month_active_customers,
    ROUND(((active_customers - LAG(active_customers, 1) OVER (ORDER BY rental_month)) / 
           LAG(active_customers, 1) OVER (ORDER BY rental_month)) * 100, 2) AS pct_change
FROM 
    MonthlyActiveCustomers;

#- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
WITH MonthlyCustomerRentals AS (
    SELECT 
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM 
        rental
    GROUP BY 
        customer_id, rental_month
),
RetainedCustomers AS (
    SELECT 
        current_month.rental_month AS current_month,
        COUNT(DISTINCT current_month.customer_id) AS retained_customers
    FROM 
        MonthlyCustomerRentals current_month
    JOIN 
        MonthlyCustomerRentals previous_month 
        ON current_month.customer_id = previous_month.customer_id
        AND DATE_ADD(previous_month.rental_month, INTERVAL 1 MONTH) = current_month.rental_month
    GROUP BY 
        current_month.rental_month
)
SELECT 
    current_month,
    retained_customers
FROM 
    RetainedCustomers
ORDER BY 
    current_month;