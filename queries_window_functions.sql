select 
	title, 
    length, 
    RANK() OVER (order by length desc) AS rank_num
from film
where length is not null and length >0;

select 
	title, 
    length, 
    rating, 
    RANK() OVER (partition by rating order by length desc) AS rank_num
from film
where length is not null and length >0;

with actor_counts as (
	select 
		fa.actor_id, 
		concat(a.first_name,' ',a.last_name) as name, 
        count(fa.film_id) as num_films 
    from film_actor as fa 
    join actor as a on a.actor_id=fa.actor_id 
    group by actor_id),
top_actors as (
	select 
		f.film_id, 
        ac.name, 
        ac.num_films, 
        rank() over (partition by film_id order by num_films desc) as ranking 
	from film_actor as f 
    join actor_counts as ac on ac.actor_id=f.actor_id)
select 
	f.title, 
    ta.name, 
    ta.num_films 
from top_actors as ta 
join film as f on f.film_id=ta.film_id 
where ranking=1;

select 
	month(rental_date) as month, 
    year(rental_date) as year, 
    count(distinct(customer_id)) as unique_customers
from rental
group by month(rental_date), year(rental_date)
order by year;

select 
	month(rental_date) as month, 
    year(rental_date) as year, 
    count(distinct(customer_id)) as unique_customers, 
    lag(count(distinct(customer_id))) over () as prev_month_users
from rental
group by month(rental_date), year(rental_date) having year=2005;

with totals as (select 
	month(rental_date) as month, 
    year(rental_date) as year, 
    count(distinct(customer_id)) as unique_customers, 
    lag(count(distinct(customer_id))) over () as prev_month_users
from rental
group by month(rental_date), year(rental_date) having year=2005)
select *, (unique_customers-prev_month_users)/prev_month_users*100 as percentage_change from totals;

WITH custs AS (
    SELECT DISTINCT
        customer_id,
        MONTH(rental_date) AS month,
        year(rental_date) as year
    FROM rental
    WHERE YEAR(rental_date) = 2005
)
SELECT last_month.month, last_month.year,
count(last_month.customer_id) as retained_customers
FROM custs last_month
JOIN custs this_month
    ON last_month.customer_id = this_month.customer_id
   AND this_month.month = last_month.month + 1
   group by last_month.month, last_month.year;     
