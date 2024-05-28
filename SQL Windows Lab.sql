use sakila;
-- Challenge 1
-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.
select title, length, RANK() over (order by length desc) as ranking
	from film
    where length is not null and length > 0; 
-- Rank films by their length and create an output table that includes the title, length, and rank columns only. Filter out any rows with null or zero values in the length column.
SELECT title, length, rating, RANK() over (PARTITION BY rating ORDER BY length DESC) as ranking 
	from film
    where length is not null and length > 0;

-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted. Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
CREATE TEMPORARY TABLE actor_film_count AS 
	SELECT
		a.actor_id,
        CONCAT (a.first_name, ' ', a.last_name) as actor_name,
        COUNT(fa.film_id) AS film_count
	FROM actor a 
    JOIN film_actor fa on a.actor_id = fa.actor_id
    GROUP BY a.actor_id; 
    
WITH film_actor_count as (
	select 
		f.film_id,
        f.title,
        afc.actor_name,
        afc.film_count,
        RANK() OVER (PARTITION BY f.film_id ORDER BY afc.film_count DESC) AS ranking_1
	FROM film f 
    JOIN film_actor fa on f.film_id = fa.film_id
    JOIN actor_film_count afc on fa.actor_id = afc.actor_id 
)
SELECT 
	title,
    actor_name,
    film_count
FROM film_actor_count
WHERE ranking_1 = 1; 
-- Challenge 2
-- This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.

-- The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an analysis on the monthly percentage change in the number of active customers and the number of retained customers. Use the Sakila database and progressively build queries to achieve the desired outcome.

-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
CREATE TEMPORARY TABLE monthly_active_customers AS 
SELECT 
	DATE_FORMAT(rental_date, '%Y-%m') AS month, 
    COUNT(DISTINCT customer_id) as active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m');
-- Step 2. Retrieve the number of active users in the previous month.
CREATE TEMPORARY TABLE monthly_active_customers_previous AS 
SELECT 
	month, 
    LAG(active_customers) OVER (ORDER BY month) AS previous_active_customers 
FROM monthly_active_customers; 
-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
WITH active_customer_changes AS (
	SELECT 
		mac.month,
        mac.active_customers,
        macp.previous_active_customers, 
        ((mac.active_customers - macp.previous_active_customers) / macp.previous_active_customers * 100) AS pct_change
	FROM monthly_active_customers mac 
    JOIN monthly_active_customers_previous macp ON mac.month = macp.month
) 
SELECT 
	month,
    active_customers,
    previous_active_customers, 
    pct_change
FROM active_customers_changes; 
-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

WITH current_month_customers AS (
	SELECT 
		DATE_FORMAT(rental_date, '%Y-%m') AS month,
        customer_id
	FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m'), customer_id
), 
previous_month_customers AS (
	SELECT 
		DATE_FORMAT(DATE_SUB(rental_date, INTERVAL 1 MONTH), '%Y-%m') AS month,
        customer_id
	FROM rental
    GROUP BY DATE_FORMAT(DATE_SUB(rental_date, INTERVAL 1 MONTH), '%Y-%m'), customer_id
),
retained_customers AS (
	SELECT 
		cm.month,
        COUNT(cm.customer_id) AS retained_customers 
	FROM current_month_customers cm
    JOIN previous_month_customers pm on cm.customer_id = pm.customer_id AND cm.month = pm.month
	GROUP BY cm.month
)
SELECT 
	rc.month, 
    mac.active_customers,
    rc.retained_customers,
    (rc.retained_customers / mac.active_customers * 100) AS retention_rate
FROM retained_customers rc
JOIN monthly_active_customers mac ON rc.month = mac.month; 