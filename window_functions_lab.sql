use sakila;

# Rank films by their length and create an output table that includes the title, length, and rank columns only. 
# Filter out any rows with null or zero values in the length column.

SELECT title, length,
	RANK() OVER (ORDER BY length DESC) as ranking
FROM film
WHERE length > 0 and length IS NOT NULL;


# Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
# Filter out any rows with null or zero values in the length column.

SELECT title, rating, length,
	DENSE_RANK() OVER (PARTITION BY rating ORDER BY length DESC) as rating
FROM film
WHERE length > 0;

# Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, 
# as well as the total number of films in which they have acted. 
# Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

CREATE VIEW films_per_actor AS
SELECT first_name, last_name, actor_id, COUNT(film_id) as amount_of_films
FROM film
INNER JOIN film_actor
USING (film_id)
INNER JOIN actor
USING (actor_id)
GROUP BY first_name, last_name, actor_id
ORDER BY amount_of_films DESC;


select *
from films_per_actor;

with cte as (
SELECT title, actor_id, first_name, last_name, amount_of_films,
	RANK() OVER (PARTITION BY title ORDER BY amount_of_films DESC) as rank_per_films
FROM films_per_actor
INNER JOIN film_actor
USING (actor_id)
INNER JOIN film
USING (film_id))
select title, actor_id, first_name, last_name, amount_of_films,rank_per_films
from cte 
where rank_per_films =1;


#Challenge 2

#Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

SELECT COUNT(DISTINCT(customer_id)), MONTH(rental_date) as month
FROM rental
GROUP BY month;

# Step 2. Retrieve the number of active users in the previous month. 

#When you use window function you cannot use aggregated data from the same query, that's why I am creating CTE
with cte AS (
SELECT COUNT(DISTINCT(customer_id)) AS active_customers, MONTH(rental_date) AS month
FROM rental
GROUP BY month
)
SELECT month,active_customers, 
	  LAG(active_customers,1) OVER (ORDER BY month) as previous_month_users
FROM cte
GROUP BY month;

#Step 3. Calculate the percentage change in the number of active customers between the current and previous month.

with cte AS (
SELECT COUNT(DISTINCT(customer_id)) AS active_customers, MONTH(rental_date) AS month
FROM rental
GROUP BY month
)
SELECT month,active_customers, 
	  LAG(active_customers,1) OVER (ORDER BY month) as previous_month_users,
      (active_customers - LAG(active_customers,1) OVER (ORDER BY month) )/ LAG(active_customers,1) OVER (ORDER BY month) *100 as percentage
FROM cte
GROUP BY month;
