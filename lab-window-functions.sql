use sakila;
-- Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

select 
title, 
length, 
row_number() over(order by length desc) as longest_films_ranked
from film
WHERE length IS NOT NULL AND length > 0;

-- Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

select
title, 
length, 
rating,
row_number() over(order by length desc) as longest_films_ranked
from film
WHERE length IS NOT NULL AND length > 0; 

-- Produce a list that shows for each film in the Sakila database, the actor or actress who has acted in the greatest number of films, 
-- as well as the total number of films in which they have acted. 
-- Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

with actors_rank as (
	select
	a.first_name,
	a.last_name,
    a.actor_id,
	count(f.film_id) as total_films_acted
	from actor as a
	join film_actor as f 
	on a.actor_id = f.actor_id
	group by a.first_name, a.last_name, a.actor_id
	order by count(f.film_id) desc
),
film_actor_rank as (
	select 
    first_name,
	last_name,
	total_films_acted,
	film_id,
	rank() over(partition by film_id order by total_films_acted desc) as actor_rank
	from actors_rank as ar
	join film_actor as fa on ar.actor_id = fa.actor_id 
)
select * 
from film_actor_rank 
where actor_rank = 1
order by last_name;

-- Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

select
	DATE_FORMAT(rental_date, '%Y-%m') as month,
	count(distinct customer_id) as unique_customers
from rental
group by month;

--  Retrieve the number of active users in the previous month.

with monthly_active as 
(
	select
		DATE_FORMAT(rental_date, '%Y-%m') as month,
		count(distinct customer_id) as unique_customers
	from rental
group by month
)
select 
month,
unique_customers,
lag(unique_customers) over (order by month) as prev_month_active,
unique_customers - lag(unique_customers) over (order by month) as monthly_c_change
from monthly_active
order by month;

-- Calculate the percentage change in the number of active customers between the current and previous month.

with monthly_active as 
(
	select
		DATE_FORMAT(rental_date, '%Y-%m') as month,
		count(distinct customer_id) as monthly_unique_active_customers
	from rental
group by month
),
result as (
	select 
	month,
	monthly_unique_active_customers,
	lag(monthly_unique_active_customers) over (order by month) as prev_months_active_customers,
	monthly_unique_active_customers - lag(monthly_unique_active_customers) over (order by month) as monthly_c_change
	from monthly_active
	order by month
)
SELECT 
	month,
	monthly_unique_active_customers,
    prev_months_active_customers,
    ROUND(
  100.0 * (monthly_unique_active_customers - prev_months_active_customers) 
          / prev_months_active_customers,
  1
) AS pct_change
FROM result
ORDER BY month DESC;


-- Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months

-- CTE 1: Get a distinct list of each customer active in each month.
with monthly_customer_activity as (
	select
		distinct 
		DATE_FORMAT(rental_date, '%Y-%m') as month,
		customer_id
	from rental
-- CTE 2: For each customer, find the month of their previous activity.
), customer_activity_with_lag as (
select 
	month,
	customer_id,
	lag(month) over (partition by customer_id order by month) as previous_month
from monthly_customer_activity
)
-- Final Query: Count the retained customers for each month.
select
month,
count(customer_id) as retained_customers
FROM
  customer_activity_with_lag
WHERE
  TIMESTAMPDIFF(
    MONTH,
    STR_TO_DATE(CONCAT(previous_month, '-01'), '%Y-%m-%d'),
    STR_TO_DATE(CONCAT(month, '-01'), '%Y-%m-%d')
  ) = 1
GROUP BY
  month
ORDER BY
  month;

