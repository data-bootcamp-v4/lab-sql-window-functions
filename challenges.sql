-- Challenge 1

-- 1. Rank films by length and create an output table that includes just title,
-- length, and rank. Null or zero values in length are filter out

SELECT title, length, rank() over (order by length desc) as 'rank' FROM film where length > 0;

-- 2. Rank films by length within the rating category

SELECT title, length, rating,
       rank() over (partition by rating order by length desc) as 'rank'
FROM film where length > 0;

-- 3. for each film, show the actor/actress who has acted in the greatest number of films,
-- as well as the number of films they acted in

-- Let's get the participation per actor
create view actor_participation as
    select actor_id, count(*) as num_films from film_actor group by actor_id;


-- Now let's get the main actor per film
create view film_main_actor as
    select film_id, actor_id
    from (
        select film_actor.film_id as film_id,
               film_actor.actor_id as actor_id,
               num_films,
               rank() over (partition by film_actor.film_id order by num_films desc) as ranking
        from film_actor, actor_participation
        where film_actor.actor_id = actor_participation.actor_id ) as ranked
    where ranking = 1;

-- Finally, let's get the title and the actor's name
select title as film_title, concat(first_name, " ", last_name) as main_actor
from film_main_actor join
     film on film_main_actor.film_id = film.film_id join
     actor on film_main_actor.actor_id = actor.actor_id;


-- Challenge 2

-- step 1. Number of monthly active customers (number of unique customers who rented a movie each month)


select yearmonth, count(*) as active
from (
    select distinct
        customer_id,
        concat(year(rental_date), '/', lpad(month(rental_date), 2, '0')) as yearmonth
    from rental
) as customermonth
group by yearmonth
order by yearmonth asc;


-- step 2. number of active users in the previous month


select yearmonth,
       count(*) as active,
       lag(count(*), 1) over (order by yearmonth) as previous
from (
    select distinct
        customer_id,
        concat(year(rental_date), '/', lpad(month(rental_date), 2, '0')) as yearmonth
    from rental ) as customermonth
group by yearmonth
order by yearmonth asc;

-- step 3. percent change in active users in the previous month

select yearmonth,
       active,
       previous,
       round((active - previous) / previous * 100, 2) as percent_change
from (
    select yearmonth,
        count(*) as active,
        lag(count(*), 1) over (order by yearmonth) as previous
    from (
        select distinct
            customer_id,
            concat(year(rental_date), '/', lpad(month(rental_date), 2, '0')) as yearmonth
        from rental ) as customermonth
    group by yearmonth
    order by yearmonth asc
) as activeusers;

-- step 4. number of retained customers per month (customers who rented movies
-- in the current and previous months)
-- I'm assuming here that this step is to get the numbers and not the actually
-- retained customers (i.e. actual customer_id in one month to the next)


select yearmonth,
       active,
       previous,
       active - previous as percent_change
from (
    select yearmonth,
        count(*) as active,
        lag(count(*), 1) over (order by yearmonth) as previous
    from (
        select distinct
            customer_id,
            concat(year(rental_date), '/', lpad(month(rental_date), 2, '0')) as yearmonth
        from rental ) as customermonth
    group by yearmonth
    order by yearmonth asc
) as activeusers;

