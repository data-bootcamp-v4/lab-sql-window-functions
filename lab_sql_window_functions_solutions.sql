USE sakila;
#Rank films by their length and create an output table that includes the title, length, and rank columns only. 
#Filter out any rows with null or zero values in the length column.
SELECT film_id, title, length,
    RANK() OVER (ORDER BY length DESC) AS rank_num
FROM film;
CREATE TEMPORARY TABLE filtered_data AS
SELECT film_id, title, length
FROM film
WHERE length IS NOT NULL 
  AND length > 0;

#Rank films by length within the rating category and create an output table that includes the title, length, 
#rating and rank columns only. Filter out any rows with null or zero values in the length column.
SELECT film_id, title, length,
    RANK() OVER (ORDER BY length DESC) AS rank_num
FROM film;

SELECT film_id, title, length, rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank_num
FROM film;
CREATE TEMPORARY TABLE filtered_data2 AS
SELECT film_id, title, length, rating
FROM film
WHERE length IS NOT NULL 
  AND length > 0;
  
#Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number 
#films, as well as the total number of films in which they have acted. Hint: Use temporary tables, CTEs, or Views 
#when appropiate to simplify your queries.

CREATE VIEW films9 AS
SELECT COUNT(film_id) AS film_number, actor_id, first_name, last_name
FROM FILM
INNER JOIN FILM_ACTOR
USING(film_id)
INNER JOIN ACTOR
USING(actor_id)
GROUP BY actor_id, first_name, last_name
ORDER BY film_number DESC;

SELECT *
FROM films9;

CREATE TEMPORARY TABLE film_top_actors AS
SELECT film.film_id, film.title, films9.first_name, films9.last_name, films9.film_number,
ROW_NUMBER() OVER (PARTITION BY film_id ORDER BY films9.film_number DESC) as rank_num
FROM FILM_ACTOR
INNER JOIN films9
USING(actor_id)
INNER JOIN FILM
USING(film_id);

SELECT *
FROM film_top_actors
WHERE rank_num=1
ORDER BY (film_id);

#Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
SELECT MONTH(rental_date) AS month, COUNT(DISTINCT(customer_id))
FROM RENTAL
GROUP BY month;
#STep 2: Retrieve the number of active users in the previous month
with cte as (
SELECT MONTH(rental_date) AS current_month, COUNT(DISTINCT(customer_id)) AS customer_num
FROM RENTAL
GROUP BY current_month)
SELECT current_month, customer_num, LAG (customer_num, 1) OVER (ORDER BY current_month) as prev_mon
FROM cte;

#Step 3. Calculate the percentage change in the number of active customers between the current and previous month

with cte as (
SELECT MONTH(rental_date) AS current_month, COUNT(DISTINCT(customer_id)) AS customer_num
FROM RENTAL
GROUP BY current_month)
SELECT current_month, customer_num, LAG (customer_num, 1) OVER (ORDER BY current_month) as prev_mon, 
((customer_num-LAG (customer_num, 1) OVER (ORDER BY current_month) )/LAG (customer_num, 1) OVER (ORDER BY current_month))*100  as percentage_change
FROM cte;
#Step 4.Calculate the number of retained customers every month, i.e., customers who rented movies in the current and 
#previous months

WITH customer_monthly_activity AS (
    SELECT DISTINCT
        YEAR(rental_date) AS rental_year,
        MONTH(rental_date) AS rental_month, 
        customer_id,
        LAG(YEAR(rental_date)) OVER (
            PARTITION BY customer_id 
            ORDER BY YEAR(rental_date), MONTH(rental_date)
        ) AS prev_year,
        LAG(MONTH(rental_date)) OVER (
            PARTITION BY customer_id 
            ORDER BY YEAR(rental_date), MONTH(rental_date)
        ) AS prev_month
    FROM RENTAL
)
SELECT 
    rental_year,
    rental_month, 
    COUNT(customer_id) AS total_customers,
    SUM(CASE 
        -- Normal case: same year, previous month
        WHEN prev_year = rental_year AND prev_month = rental_month - 1 THEN 1
        -- Year boundary case: Dec → Jan
        WHEN prev_year = rental_year - 1 AND prev_month = 12 AND rental_month = 1 THEN 1
        ELSE 0 
    END) AS retained_customers
FROM customer_monthly_activity
GROUP BY rental_year, rental_month
ORDER BY rental_month DESC;