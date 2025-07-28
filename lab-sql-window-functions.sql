SELECT 
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS length_rank
FROM film
WHERE length IS NOT NULL AND length > 0;
SELECT 
    title,
    length,
    rating,
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS rating_length_rank
FROM film
WHERE length IS NOT NULL AND length > 0;
WITH actor_film_count AS (
  SELECT 
    fa.actor_id,
    COUNT(*) AS film_count
  FROM film_actor fa
  GROUP BY fa.actor_id
),
top_actor AS (
  SELECT 
    actor_id
  FROM actor_film_count
  ORDER BY film_count DESC
  LIMIT 1
)
SELECT 
    f.title,
    a.first_name,
    a.last_name,
    afc.film_count
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
JOIN actor_film_count afc ON afc.actor_id = a.actor_id
WHERE a.actor_id = (SELECT actor_id FROM top_actor);
WITH monthly_active_customers AS (
  SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_customers
  FROM rental
  GROUP BY month
)
SELECT * FROM monthly_active_customers;
WITH monthly_active_customers AS (
  SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_customers
  FROM rental
  GROUP BY month
)
SELECT 
  month,
  active_customers,
  LAG(active_customers) OVER (ORDER BY month) AS prev_month_customers
FROM monthly_active_customers;
WITH monthly_active_customers AS (
  SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_customers
  FROM rental
  GROUP BY month
)
SELECT 
  month,
  active_customers,
  LAG(active_customers) OVER (ORDER BY month) AS prev_month_customers,
  ROUND(
    100 * (active_customers - LAG(active_customers) OVER (ORDER BY month)) 
    / LAG(active_customers) OVER (ORDER BY month), 2
  ) AS percent_change
FROM monthly_active_customers;
WITH rentals_by_month AS (
  SELECT 
    customer_id,
    DATE_FORMAT(rental_date, '%Y-%m') AS month
  FROM rental
  GROUP BY customer_id, month
),
retained_customers AS (
  SELECT 
    curr.month AS current_month,
    COUNT(DISTINCT curr.customer_id) AS retained
  FROM rentals_by_month curr
  JOIN rentals_by_month prev 
    ON curr.customer_id = prev.customer_id
   AND PERIOD_DIFF(REPLACE(curr.month, '-', ''), REPLACE(prev.month, '-', '')) = 1
  GROUP BY curr.month
)
SELECT * FROM retained_customers;
