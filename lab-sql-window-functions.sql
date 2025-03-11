/*
Challenge 1.
This challenge consists of three exercises that will test your ability to use the SQL RANK() function. 
You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.

1. Rank films by their length and create an output table that includes the title, length, and rank columns only. 
Filter out any rows with null or zero values in the length column.
*/

USE sakila;

SELECT title, length, RANK() OVER (ORDER BY length DESC) as `rank`
FROM film
WHERE length IS NOT NULL AND length > 0;

/*
2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
Filter out any rows with null or zero values in the length column.
*/

SELECT length, title, rating, RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS `rank`
FROM film
WHERE 
length IS NOT NULL AND length >0;

/*
Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, 
as well as the total number of films in which they have acted. 
Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
*/

WITH actor_film_count AS
(SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS film_count
FROM actor a 
JOIN film_actor fa ON a.actor_id= fa.actor_id
GROUP BY a.actor_id),

ranked_actors AS
(SELECT actor_id, first_name, last_name, film_count, RANK() OVER ( ORDER BY film_count DESC) AS `rank` 
FROM actor_film_count)
SELECT raf.first_name, raf.last_name, raf.film_count
FROM
ranked_actors raf
WHERE RAF.RANK = 1;

/*
Challenge 2
This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. 
By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.
The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an analysis 
on the monthly percentage change in the number of active customers and the number of retained customers. 
Use the Sakila database and progressively build queries to achieve the desired outcome.

Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
*/
SELECT DATE_FORMAT(rental_date, '%Y-%m') AS rental_month, COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month
ORDER BY rental_month;

/*
Step 2. Retrieve the number of active users in the previous month.
*/

WITH monthly_active_customers AS 
(SELECT DATE_FORMAT(rental_date, '%Y-%m') AS rental_month, COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month
ORDER BY rental_month
)
SELECT rental_month, active_customers, LAG(active_customers, 1) OVER (ORDER BY rental_month) AS prev_month_active_customers
FROM monthly_active_customers;

/*
Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
*/

WITH monthly_active_customers AS 
(SELECT DATE_FORMAT(rental_date, '%Y-%m') AS rental_month, COUNT(DISTINCT customer_id) AS active_customers
FROM rental
GROUP BY rental_month
ORDER BY rental_month
),
monthly_change AS 
(SELECT rental_month, active_customers, LAG(active_customers, 1) OVER (ORDER BY rental_month) AS prev_month_active_customers
FROM monthly_active_customers
)
SELECT rental_month, active_customers, prev_month_active_customers,
CASE
	WHEN prev_month_active_customers IS NOT NULL THEN
        (active_customers - prev_month_active_customers) / prev_month_active_customers * 100
	ELSE
        NULL
    END AS percent_change
FROM monthly_change;

/*
Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
*/

WITH monthly_customers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        customer_id
    FROM 
        rental
    GROUP BY 
        rental_month, customer_id
),

customer_pairs AS (
    SELECT 
        mc1.rental_month AS current_month,
        mc2.rental_month AS next_month,
        mc1.customer_id
    FROM 
        monthly_customers mc1
    JOIN 
        monthly_customers mc2 
    ON 
        mc1.customer_id = mc2.customer_id
        AND mc2.rental_month > mc1.rental_month
    WHERE 
        DATE_ADD(mc1.rental_month, INTERVAL 1 MONTH) = mc2.rental_month
)

SELECT 
    current_month,
    COUNT(DISTINCT customer_id) AS retained_count
FROM 
    customer_pairs
GROUP BY 
    current_month
ORDER BY
    current_month;