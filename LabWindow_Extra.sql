use sakila;
-- Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

select title , length,  rank() over(ORDER BY length) as rank_num
from film
where length>0 and length is not null;

-- Rank films by length within the rating category and create an output table that includes the title, length, rating and 
-- rank columns only. Filter out any rows with null or zero values in the length column.
select title, length , rating , rank() over(partition by rating order by length) as rank_num
from film
where length>0 and length is not null;


-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number 
-- of films, as well as the total number of films in which they have acted. 
With filmscount as
(select actor_id , count(film_id) as no_of_films
from film_actor
group by actor_id) 
select a.first_name, a.last_name ,f.no_of_films -- ,rank() over(order by f.no_of_films desc)
from actor a join  filmscount f
order by f.no_of_films  desc ;
-- Customer Analysis 

-- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie
-- in each month.
with customer_rental as
(select customer_id, EXTRACT(MONTH FROM rental_date) AS rental_month
from rental)
select count(cr.customer_id), cr.rental_month
from customer_rental cr 
group by cr.rental_month;

-- Step 2. Retrieve the number of active users in the previous month.
with customer_rental as
(select customer_id, EXTRACT(MONTH FROM rental_date) AS rental_month
from rental),
total_customer as
(select count(cr.customer_id) as monthly_cust, cr.rental_month 
from customer_rental cr 
group by cr.rental_month)
select monthly_cust ,rental_month , monthly_cust-LAG(monthly_cust)
OVER (ORDER BY rental_month) AS active_users_previous_month
from total_customer t;

-- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
with customer_rental as
(select customer_id, EXTRACT(MONTH FROM rental_date) AS rental_month
from rental),
total_customer as
(select count(cr.customer_id) as monthly_cust, cr.rental_month 
from customer_rental cr 
group by cr.rental_month),
active_user_per_month as
(select monthly_cust ,rental_month , monthly_cust-LAG(monthly_cust)
OVER (ORDER BY rental_month) AS active_users_previous_month
from total_customer t)

select   monthly_cust ,rental_month , active_users_previous_month/(LAG(monthly_cust) 
OVER (ORDER BY rental_month) * 100) AS percentage
from active_user_per_month;

-- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
with customer_rental as
(select customer_id, EXTRACT(MONTH FROM rental_date) AS rental_month
from rental),
total_customer as
(select count(cr.customer_id) as monthly_cust, cr.rental_month 
from customer_rental cr 
group by cr.rental_month),
active_user_per_month as
(select monthly_cust ,rental_month , monthly_cust-LAG(monthly_cust)
OVER (ORDER BY rental_month) AS active_users_previous_month
from total_customer t)

SELECT MONTHLY_CUST,RENTAL_MONTH,
     SUM(MONTHLY_CUST) OVER (
           ORDER BY RENTAL_MONTH
           ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
       ) AS TOTAL_CUST
FROM active_user_per_month;