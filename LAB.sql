USE sakila;
SHOW TABLES;
SELECT title, length, DENSE_RANK() OVER (ORDER BY length DESC) AS length_rank
FROM film
WHERE length IS NOT NULL;

SELECT f.title, f.length, c.name AS category, RANK() OVER(PARTITION BY c.name ORDER BY length DESC)
FROM film AS f
JOIN film_category AS fc
ON fc.film_id = f.film_id
JOIN category AS c 
ON c.category_id = fc.category_id
WHERE length IS NOT NULL;

WITH actor_count AS(
    SELECT fa.actor_id, 
    count(*) AS total_films, 
    CONCAT(a.first_name,' ',a.last_name) AS actor_name 
FROM film_actor as fa
JOIN actor AS a 
ON a.actor_id = fa.actor_id
GROUP BY actor_id)
SELECT f.title, ac.actor_name, ac.total_films FROM film_actor AS fa
JOIN film as f
ON f.film_id = fa.film_id
JOIN actor_count AS ac
ON ac.actor_id = fa.actor_id;


SELECT COUNT(*) AS active_users,DATE_FORMAT(CONVERT(rental_date, DATE),'%M') AS month, COUNT(DISTINCT customer_id) AS unique_customers
FROM rental
GROUP BY month

SELECT COUNT(*) AS active_users,DATE_FORMAT(CONVERT(rental_date, DATE),'%M') AS month
FROM rental
GROUP BY month
