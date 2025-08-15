# 1. Rank films by their length and create an output table that includes the title, length, and rank columns only. 
# Filter out any rows with null or zero values in the length column.
select title,
       length,
       rank() over(order by length desc) as length_rank
from sakila.film
where length is not null and length != 0 ;




# Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
# Filter out any rows with null or zero values in the length column.
select title,
	   length,
       rating,
       dense_rank()over(partition by rating order by length desc) as length_rank_per_ratingCategory
from sakila.film
where length is not null and length != 0;




# Produce a list that shows for each film in the Sakila database, 
# the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted. 
# s1--> find total number of films by each actor
# s2--> in each film, rank actors by their total films
with actor_films as (
					select *,
						   count(film_id)over(partition by actor_id) as actor_total_films
					from sakila.film_actor)

select film_id,actor_id,actor_total_films
from(
	select *,
		   row_number()over(partition by film_id order by actor_total_films desc) as actor_rank
	from actor_films) as film_actor_rank
where actor_rank = 1;






## create a summary table 
# s1 --> creat a table current_previous_month_active_customer_percentage
create table current_previous_month_active_customer_percentage as 
select *,
	  concat(round(((n_active_customers - n_active_customer_previous_month)/n_active_customers)*100,2),'%') as percentage_change
from 
	  (select *,
		   lag(n_active_customers)over(order by month) as n_active_customer_previous_month
		from (
				select date_format(rental_date,'%c') as month,
					   count(distinct(customer_id)) as n_active_customers               
				from sakila.rental
				group by date_format(rental_date,'%c')) as cur_month_active_customer) as current_previous_month_active_customer;


# s2--> Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
with current_customer_month_count as(
									select customer_id,
										   DATE_FORMAT(rental_date, '%c') as rental_month_curr,
										   count(rental_id) as rental_count_curr
									from sakila.rental
									group by customer_id,DATE_FORMAT(rental_date, '%c')
									order by customer_id asc),

customer_cur_pre_month_count as(
									select cur.customer_id,
										   cur.rental_month_curr,
										   cur.rental_count_curr,
										   pre.rental_month_curr as rental_month_pre,
										   pre.rental_count_curr as rental_count_pre   
									from current_customer_month_count as cur
									join current_customer_month_count as pre
									on cur.customer_id = pre.customer_id
									where (cur.rental_month_curr - pre.rental_month_curr) = 1)

select *
from current_previous_month_active_customer_percentage as c
left join(select rental_month_curr,
		 count(distinct(customer_id)) as ratained_customer_count
		 from customer_cur_pre_month_count
		 group by rental_month_curr) as r
on c.month = r.rental_month_curr;