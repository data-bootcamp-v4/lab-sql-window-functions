## Challenge 1
#1
select title,
       length,
rank() over ( order by length DESC) AS length_rank
from film
where length is not null and length > 0;

#2
select title,
       length,
       rating,
       rank() over ( partition by rating order by length DESC) AS length_rank
from film
where length is not null and length > 0;

#3
SELECT 
    subquery.title,
    subquery.first_name,
    subquery.last_name,
    subquery.films_qty_by_actor
FROM (
    SELECT 
        f.title,
        a.first_name,
        a.last_name,
        COUNT(fa.film_id) OVER (PARTITION BY a.actor_id) AS films_qty_by_actor
    FROM film f
    JOIN film_actor fa ON f.film_id = fa.film_id
    JOIN actor a ON fa.actor_id = a.actor_id
) AS subquery
GROUP BY subquery.title, subquery.first_name, subquery.last_name, subquery.films_qty_by_actor
ORDER BY films_qty_by_actor DESC;



## Challenge 2

# step 1:

create table monthly_active_customers2 as 
select 
       date_format(rental_date ,'%Y-%m') as month,
       count(distinct customer_id) as active_customers
from rental
group by month;

# step 2:
create view previous_month_active_customers as 
select month,
       LAG(active_customers,1) over ( order by month) as previous_active_customers
from monthly_active_customers2;

# step 3:
with customer_change as (
select
     mac.month,
     mac.active_customers,
     pmac.previous_active_customers,
     ((mac.active_customers-pmac.previous_active_customers)/pmac.previous_active_customers)*100 as percentage_change
from monthly_active_customers2 mac
join previous_month_active_customers pmac on mac.month=pmac.month
)
select month,
      active_customers,
      previous_active_customers,
      percentage_change
from customer_change;

# step 4:
