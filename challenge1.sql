USE sakila;

-- Task 1: Rank films by their length
SELECT 
    f.title, 
    f.length, 
    RANK() OVER (ORDER BY f.length DESC) AS rank
FROM film f
WHERE f.length > 0;

-- Task 2: Rank films by length within the rating category
SELECT 
    f.title, 
    f.length, 
    f.rating, 
    RANK() OVER (PARTITION BY f.rating ORDER BY f.length DESC) AS rank
FROM film f
WHERE f.length > 0;

-- Task 3: Rank actors by the number of films they have acted in
SELECT 
    a.first_name, 
    a.last_name, 
    COUNT(fa.film_id) AS film_count, 
    RANK() OVER (ORDER BY COUNT(fa.film_id) DESC) AS rank
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY rank;
