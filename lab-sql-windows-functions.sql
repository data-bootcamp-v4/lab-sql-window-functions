-- ## Challenge 1
-- This challenge consists of three exercises that will test your ability to use the SQL RANK() function. 
-- You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.
-- 1. Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.
CREATE OR REPLACE VIEW length_view AS SELECT title, length, RANK() OVER (ORDER BY length DESC) AS Film_Rank FROM sakila.film
WHERE  length <> ' ';

-- checked if it worked 
SELECT * from length_view LIMIT 15; 

-- 2. Rank films by length within the rating category and create an output table that 
-- includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.
CREATE OR REPLACE VIEW ranking_view AS SELECT f.length, f.title, f.rating, RANK() OVER (partition by f.rating ORDER BY l.Film_Rank) as Per_Rating  
FROM sakila.film as f
JOIN length_view as l 
on f.length = l.length 
WHERE  f.length <> ' ';
-- checked if it worked 
SELECT * FROM ranking_view LIMIT 30 ; 

-- 3. Produce a list that shows for each film in the Sakila database, (film_id, film) =>  <film_list_view> 
-- the actor or actress (actor, actor_id) who has acted in the greatest number of films
-- as well as the total number of films in which they have acted (film_actor (actor_id, film_id) => <film_actor_view>
-- *Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.*

-- <film_list_view> a view with film & film IDs 
CREATE OR REPLACE VIEW film_list_view AS SELECT film_id, title FROM sakila.film; 
-- checking if it worked 
SELECT * FROM film_list_view; 

-- <film_actor_view> list of the actors sorted by number of films they've acted in, with actor_id 
CREATE OR REPLACE VIEW film_actor_view AS SELECT COUNT(f.film_id) as film_count, af.actor_id
FROM sakila.film as f 
JOIN sakila.film_actor as af
on f.film_id = af.film_id 
GROUP BY af.actor_id;
-- checked if it worked
SELECT * FROM film_actor_view
ORDER BY film_count DESC; 

-- <film_actor_name> a view that puts actors' names against actor_id 
CREATE OR REPLACE VIEW film_actor_name AS SELECT fav.actor_id, fav.film_count, a.first_name, a.last_name
FROM film_actor_view as fav 
JOIN sakila.actor as a
on fav.actor_id = a.actor_id 
GROUP BY fav.actor_id, a.first_name, a.last_name;
-- checked if it worked 
SELECT * FROM film_actor_name
ORDER BY film_count DESC ; 

-- 3. further combine film_actor_name with number of films 
CREATE OR REPLACE VIEW film_actor_combined AS SELECT fav.actor_id, fav.film_count, fan.first_name, fan.last_name
FROM film_actor_view as fav 
JOIN film_actor_name as fan
on fan.actor_id = fav.actor_id 
GROUP BY fav.actor_id, fan.first_name, fan.last_name;
-- checked if it worked 
SELECT * FROM film_actor_combined ORDER BY film_count DESC; 
## Challenge 2
-- By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions 
-- to improve customer retention and increase revenue.
-- The goal of this exercise is to perform a comprehensive analysis of customer activity and retention 
-- by conducting an analysis on the monthly percentage change in the number of active customers and 
-- the number of retained customers. 
-- Use the Sakila database and progressively build queries to achieve the desired outcome. 

-- Step 1. Retrieve the number of monthly active customers, 
-- i.e., the number of unique customers who rented a movie in each month.
SELECT * FROM rental; 
CREATE OR REPLACE VIEW mac_view as
SELECT DISTINCT COUNT(customer_id) OVER (PARTITION BY MONTHNAME(rental_date)) as monthly_active_customers, MONTHNAME(rental_date)  as Month_name, MONTH(rental_date) as Month_number
FROM sakila.rental
ORDER BY Month_number;  
-- checked if it worked 
SELECT * FROM mac_view ; 
-- Step 2. Retrieve the number of active users in the previous month.
CREATE OR REPLACE VIEW last_month_view as SELECT LAG(monthly_active_customers,1) OVER(ORDER BY Month_number) AS Last_month, monthly_active_customers, Month_name, Month_number FROM mac_view ; 
SELECT * FROM last_month_view; 
-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
CREATE TEMPORARY TABLE percentage_table_change AS
SELECT LAG(monthly_active_customers) OVER(ORDER BY Month_number) as last_month_value, ROUND(((monthly_active_customers - LAG (monthly_active_customers) OVER (ORDER BY Month_number))/
LAG (monthly_active_customers) OVER (ORDER BY Month_number))*100, 2) AS uplift_percentage
FROM mac_view; 
-- Step 4. Calculate the number of retained customers every month 
-- i.e., customers who rented movies in the current and previous months. 

-- <customer_id_view> added customer_ids to the months conveted 
CREATE OR REPLACE VIEW customer_id_view as
SELECT DISTINCT customer_id, MONTHNAME(rental_date) as Month_name, MONTH(rental_date) as Month_number
FROM sakila.rental
ORDER BY Month_number; 
SELECT * FROM customer_id_view; 

-- Now creating a list of retained_customers by using self-join 
SELECT ci1.Month_name, COUNT(ci2.customer_id) as retained_customer_count 
FROM customer_id_view as ci1 
LEFT JOIN customer_id_view as ci2 
on ci1.customer_id = ci2.customer_id 
AND ci1.Month_number = ci2.Month_number +1 
GROUP BY ci1.Month_name, ci1.Month_number
ORDER BY ci1.Month_number; 
 



