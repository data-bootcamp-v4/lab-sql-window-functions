SELECT title, length,
       RANK() OVER (ORDER BY length DESC) AS rank_length
FROM film
WHERE length IS NOT NULL
  AND length > 0;
  
SELECT title, length, rating,
       RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rank_null
FROM film
WHERE length IS NOT NULL
  AND length > 0;
  
WITH actor_film_counts AS (
    SELECT 
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        COUNT(DISTINCT fa.film_id) AS film_count,
        RANK() OVER (ORDER BY COUNT(DISTINCT fa.film_id) DESC) AS actor_rank
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id, actor_name
)
SELECT 
    f.film_id,
    f.title AS film_title,
    afc.actor_name,
    afc.film_count
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor_film_counts afc ON fa.actor_id = afc.actor_id
WHERE afc.actor_rank = 1;

SELECT
    DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
    COUNT(DISTINCT rental.customer_id) AS active_customers
FROM rental
GROUP BY rental_month
ORDER BY rental_month;

SELECT
    current_month.rental_month,
    current_month.active_customers,
    COALESCE(previous_month.active_customers, 0) AS previous_active_customers
FROM
    (
        SELECT
            DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
            COUNT(DISTINCT rental.customer_id) AS active_customers
        FROM rental
        GROUP BY rental_month
    ) AS current_month
LEFT JOIN
    (
        SELECT
            DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
            COUNT(DISTINCT rental.customer_id) AS active_customers
        FROM rental
        GROUP BY rental_month
    ) AS previous_month ON DATE_ADD(current_month.rental_month, INTERVAL -1 MONTH) = previous_month.rental_month
ORDER BY current_month.rental_month;

SELECT
    rental_month,
    active_customers,
    previous_active_customers,
    ROUND(((active_customers - previous_active_customers) / previous_active_customers) * 100, 2) AS percentage_change
FROM
    (
        SELECT
            current_month.rental_month,
            current_month.active_customers,
            COALESCE(previous_month.active_customers, 0) AS previous_active_customers
        FROM
            (
                SELECT
                    DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
                    COUNT(DISTINCT rental.customer_id) AS active_customers
                FROM rental
                GROUP BY rental_month
            ) AS current_month
        LEFT JOIN
            (
                SELECT
                    DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
                    COUNT(DISTINCT rental.customer_id) AS active_customers
                FROM rental
                GROUP BY rental_month
            ) AS previous_month ON DATE_ADD(current_month.rental_month, INTERVAL -1 MONTH) = previous_month.rental_month
    ) AS monthly_changes
ORDER BY rental_month;

SELECT
    current_month.rental_month,
    COUNT(DISTINCT current_month.customer_id) AS retained_customers
FROM
    (
        SELECT
            DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
            rental.customer_id
        FROM rental
        WHERE rental.rental_date >= DATE_ADD(DATE_FORMAT(rental.rental_date, '%Y-%m-01'), INTERVAL 1 MONTH)
    ) AS current_month
JOIN
    (
        SELECT
            DATE_FORMAT(rental.rental_date, '%Y-%m') AS rental_month,
            rental.customer_id
        FROM rental
        WHERE rental.rental_date < DATE_ADD(DATE_FORMAT(rental.rental_date, '%Y-%m-01'), INTERVAL 1 MONTH)
    ) AS previous_month ON current_month.customer_id = previous_month.customer_id
GROUP BY current_month.rental_month
ORDER BY current_month.rental_month;