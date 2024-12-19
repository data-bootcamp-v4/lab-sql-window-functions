-- CHALLENGE 1
-- 1.1

select rank() over (order by length desc) as ranking,
	title, 
	length
from film
where length is not null and length > 0
order by ranking;

-- 1.2
select rank() over (partition by rating order by length) as ranking,
		title, 
        length,
        rating
from film
where length is not null and length > 0
order by ranking;

-- 1.3 l'acteur qui a participé aux plus de film pour chaque film

with best_actor as (
select fa.actor_id,
		concat(a.first_name, ' ', a.last_name) as full_name,
		count(fa.film_id) as number_of_film
from film_actor fa
join actor a on fa.actor_id = a.actor_id
group by 1, 2),

film_actor as(
	select row_number () over (partition by f.title order by ba.number_of_film desc) as ranking,
		f.title, 
		ba.full_name,
        ba.number_of_film
	from film_actor fa
    join film f on fa.film_id = f.film_id
    join best_actor ba on fa.actor_id = ba.actor_id)
    
select *
from film_actor
where ranking = 1;


-- CHALLENGE 2

with customer_count as (
select 
	count(distinct(customer_id)) as number_of_customer,
	date_format(rental_date, '%m') as months, 
    date_format(rental_date, '%y') as year
from rental
group by 2, 3),

last_month_calcul as(
	select  
		months, 
        year,
        number_of_customer,
        coalesce (lag(number_of_customer) over (order by year, months), 0) as last_month
	from customer_count),
 
 percentage as (
	select 
		months, 
        year, 
        number_of_customer,
        last_month,
        coalesce (round((1.0 * number_of_customer / last_month), 2), 0) as percentage_change
	from last_month_calcul)

select 
	months, 
	year, 
	number_of_customer, 
	last_month,
    percentage_change
from percentage p;

with month_preview as (
	select 
		customer_id, 
        date_format(rental_date, '%Y-%m') as rental_month
	from rental),
    
retained_customers as (
	select 
		mp.rental_month as current_month, 
        count(distinct mp.customer_id) as retained_custo
	from month_preview as mp
    join month_preview as mp1
		on mp.customer_id = mp1.customer_id
        and mp1.rental_month = date_format(date_sub(str_to_date(mp.rental_month, '%Y-%m'), interval 1 month), '%Y-%m')
	group by mp.rental_month)

SELECT 
    current_month,
    retained_custo
FROM retained_customers
ORDER BY current_month;

    
    
















