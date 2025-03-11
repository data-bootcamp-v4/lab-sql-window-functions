Use sakila

/**Rank Films by Their Length**/
SELECT 
    title,
    length,
    RANK() OVER (ORDER BY length DESC) AS length_rank
FROM film
WHERE length IS NOT NULL 
  AND length > 0
ORDER BY length DESC;

/**Rank Films by Length Within Their Rating Category**/
SELECT
    title,
    length,
    rating,
    RANK() OVER (
        PARTITION BY rating 
        ORDER BY length DESC
    ) AS length_rank_within_rating
FROM film
WHERE length IS NOT NULL
  AND length > 0
ORDER BY rating, length DESC;

/**List Each Film Along With the Actor Who Has Acted in the Greatest Number of Films**/
WITH actor_filmcounts AS (
    SELECT 
        fa.actor_id,
        COUNT(DISTINCT fa.film_id) AS total_films
    FROM film_actor fa
    GROUP BY fa.actor_id
)

, film_actor_counts AS (
    SELECT
        f.film_id,
        f.title,
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        afc.total_films
    FROM film f
    JOIN film_actor fa
        ON f.film_id = fa.film_id
    JOIN actor a
        ON fa.actor_id = a.actor_id
    JOIN actor_filmcounts afc
        ON fa.actor_id = afc.actor_id
)
SELECT
    film_id,
    title,
    actor_name,
    total_films
FROM (
    SELECT
        fac.*,
        RANK() OVER (
            PARTITION BY fac.film_id
            ORDER BY fac.total_films DESC
        ) AS actor_rank
    FROM film_actor_counts fac
) ranked
WHERE actor_rank = 1
ORDER BY film_id;

/**Challenge 2**/

-- 1 - Retrieving the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month--
SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    COUNT(DISTINCT customer_id)       AS monthly_active_customers
FROM rental
GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
ORDER BY DATE_FORMAT(rental_date, '%Y-%m');

-- 2- Retrieve the number of active users in the previous month --

WITH monthly_active AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id)       AS monthly_active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT
    rental_month,
    monthly_active_customers,
    LAG(monthly_active_customers, 1) OVER (ORDER BY rental_month) AS prev_month_active
FROM monthly_active
ORDER BY rental_month;

Use sakila

-- 3-  Calculate the Percentage Change in Active Customers*/
WITH monthly_activity AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id)       AS active_customers
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
),
monthly_activity_with_prev AS (
    SELECT 
        curr.rental_month,
        curr.active_customers,
        prev.active_customers AS prev_month_active
    FROM monthly_activity AS curr
    LEFT JOIN monthly_activity AS prev
           ON prev.rental_month = DATE_FORMAT(
                                     DATE_SUB(
                                       STR_TO_DATE(CONCAT(curr.rental_month, '-01'), '%Y-%m-%d'),
                                       INTERVAL 1 MONTH
                                     ),
                                     '%Y-%m'
                                   )
)
SELECT
    rental_month,
    active_customers,
    prev_month_active,
    CASE WHEN prev_month_active = 0 OR prev_month_active IS NULL THEN 0
         ELSE 100 * (active_customers - prev_month_active) / prev_month_active
    END AS pct_change
FROM monthly_activity_with_prev
ORDER BY rental_month;

-- 4 - Calculate the Number of Retained Customers Every Month
-- Distinct month–customer combinations
WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        customer_id
    FROM rental
)
SELECT
    mc.rental_month    AS current_month,
    pmc.rental_month   AS previous_month,
    mc.customer_id
FROM monthly_customers mc
JOIN monthly_customers pmc 
    ON mc.customer_id = pmc.customer_id
   AND mc.rental_month = DATE_FORMAT(
                           DATE_ADD(
                             STR_TO_DATE(CONCAT(pmc.rental_month, '-01'), '%Y-%m-%d'),
                             INTERVAL 1 MONTH
                           ),
                           '%Y-%m'
                         );

SELECT DISTINCT
    DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
    customer_id
FROM rental;

SELECT
    mc.rental_month   AS current_month,
    pmc.rental_month  AS previous_month,
    mc.customer_id
FROM monthly_customers mc
JOIN monthly_customers pmc
    ON mc.customer_id = pmc.customer_id
   AND mc.rental_month = DATE_FORMAT(
                           DATE_ADD(
                             STR_TO_DATE(CONCAT(pmc.rental_month, '-01'), '%Y-%m-%d'),
                             INTERVAL 1 MONTH
                           ),
                           '%Y-%m'
                         );
                         
                         
                         