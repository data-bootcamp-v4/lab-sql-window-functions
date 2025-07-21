-- Challenge 1.1
  SELECT 
  title,
  length,
  RANK() OVER (ORDER BY length DESC) AS _rank
FROM 
  film
WHERE 
  length IS NOT NULL AND length > 0;

  -- 1.2
  SELECT 
  title,
  length,
  rating,
  RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS _rank
FROM 
  film
WHERE 
  length IS NOT NULL AND length > 0;

  -- 1.3
  WITH actor_film_counts AS (
    SELECT 
        fa.actor_id,
        COUNT(*) AS film_count
    FROM 
        film_actor fa
    GROUP BY 
        fa.actor_id
),
most_prolific_actor AS (
    SELECT 
        actor_id,
        film_count
    FROM 
        actor_film_counts
    ORDER BY 
        film_count DESC
    LIMIT 1
)
SELECT 
    f.title,
    a.first_name || ' ' || a.last_name AS actor_name,
    afc.film_count
FROM 
    film f
JOIN 
    film_actor fa ON f.film_id = fa.film_id
JOIN 
    actor a ON a.actor_id = fa.actor_id
JOIN 
    most_prolific_actor mpa ON a.actor_id = mpa.actor_id
JOIN 
    actor_film_counts afc ON a.actor_id = afc.actor_id;


-- challenge 2.1
WITH monthly_active_customers AS (
  SELECT
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    customer_id
  FROM rental
  GROUP BY rental_month, customer_id
)
SELECT
  rental_month,
  COUNT(DISTINCT customer_id) AS active_customers
FROM monthly_active_customers
GROUP BY rental_month
ORDER BY rental_month;

-- challenge 2.2 active users in the previous month
WITH monthly_active_customers AS (
  SELECT
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    customer_id
  FROM rental
  GROUP BY rental_month, customer_id
),
active_count_by_month AS (
  SELECT
    rental_month,
    COUNT(DISTINCT customer_id) AS active_customers
  FROM monthly_active_customers
  GROUP BY rental_month
),
active_with_prev AS (
  SELECT 
    rental_month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY rental_month) AS prev_month_customers
  FROM active_count_by_month
)
SELECT * FROM active_with_prev;

-- challenge 2.3 change in active clients
WITH monthly_active_customers AS (
  SELECT
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    customer_id
  FROM rental
  GROUP BY rental_month, customer_id
),
active_count_by_month AS (
  SELECT
    rental_month,
    COUNT(DISTINCT customer_id) AS active_customers
  FROM monthly_active_customers
  GROUP BY rental_month
),
active_with_prev AS (
  SELECT 
    rental_month,
    active_customers,
    LAG(active_customers) OVER (ORDER BY rental_month) AS prev_month_customers
  FROM active_count_by_month
)
SELECT 
  rental_month,
  active_customers,
  prev_month_customers,
  ROUND(((active_customers - prev_month_customers) / prev_month_customers) * 100, 2) AS percent_change
FROM active_with_prev
WHERE prev_month_customers IS NOT NULL;

-- challenge 2.4 customer retention betwixt months
WITH monthly_customers AS (
  SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    customer_id
  FROM rental
  GROUP BY rental_month, customer_id
),
customer_month_pairs AS (
  SELECT 
    mc1.rental_month AS current_month,
    mc2.rental_month AS previous_month,
    mc1.customer_id
  FROM monthly_customers mc1
  JOIN monthly_customers mc2 
    ON mc1.customer_id = mc2.customer_id
    AND PERIOD_DIFF(REPLACE(mc1.rental_month, '-', ''), REPLACE(mc2.rental_month, '-', '')) = 1
)
SELECT 
  current_month,
  COUNT(DISTINCT customer_id) AS retained_customers
FROM customer_month_pairs
GROUP BY current_month
ORDER BY current_month;


