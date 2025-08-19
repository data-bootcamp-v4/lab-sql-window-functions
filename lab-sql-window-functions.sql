USE sakila;

# Challenge 1

#1: Rank films by their length and create an output table that includes the title, length, and rank columns only. 
# Filter out any rows with null or zero values in the length column.

SELECT title, length,
RANK() OVER (PARTITION BY title ORDER BY length) AS `rank`
FROM film
WHERE length IS NOT NULL AND length > 0;

#2: Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
# Filter out any rows with null or zero values in the length column.
SELECT title, length, rating,
RANK() OVER (PARTITION BY rating ORDER BY length DESC)
FROM film
WHERE length IS NOT NULL AND length > 0;

#3: Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, 
# as well as the total number of films in which they have acted. 
# Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

SELECT COUNT(title), actor_id, first_name, last_name
FROM actor
INNER JOIN film_actor
USING(actor_id)
INNER JOIN film
USING(film_id)
GROUP BY actor_id
ORDER BY count(title) desc;

SELECT *
FROM actors_films;

DROP VIEW actors_films;

# Challenge 2

# 1: Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
CREATE VIEW monthly_sales AS
SELECT COUNT(DISTINCT customer_id) AS monthly_active_customers, MONTH(rental_date) AS month
FROM customer 
INNER JOIN rental
USING(customer_id)
GROUP BY month
ORDER BY month;

DROP VIEW monthly_sales;

SELECT *
FROM monthly_sales;

# 2: Retrieve the number of active users in the previous month  
# LAG() function: Gets the previous month's active customer count
  
 SELECT month, monthly_active_customers,
  LAG(monthly_active_customers) OVER (ORDER BY month) AS previous_month
FROM monthly_sales
ORDER BY month; 

# 3: Calculate the percentage change in the number of active customers between the current and previous month.
# Google says: ((Current Month - Previous Month) / Previous Month) * 100
# use the cte created above
WITH cte AS (SELECT month, monthly_active_customers,
  LAG(monthly_active_customers) OVER (ORDER BY month) AS previous_month
FROM monthly_sales
ORDER BY month)
SELECT *,
((monthly_active_customers - previous_month)/previous_month) * 100
FROM cte;


# 4: Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
# Asked deepseek for help :(
     
     WITH monthly_retained_customers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month,
        customer_id
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m'), customer_id
)
SELECT 
    current_month.month,
    COUNT(DISTINCT current_month.customer_id) AS retained_customers
FROM monthly_retained_customers current_month
JOIN monthly_retained_customers previous_month 
    ON current_month.customer_id = previous_month.customer_id
    AND current_month.month = DATE_ADD(previous_month.month, INTERVAL 1 MONTH)
GROUP BY current_month.month
ORDER BY current_month.month;


# Retained customers = Customers who rented in BOTH the current month AND the previous month
# Finds all customers who rented each month
# Matches them with themselves from the previous month
# Counts how many customers appear in both months