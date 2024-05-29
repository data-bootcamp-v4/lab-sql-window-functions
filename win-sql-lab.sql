USE sakila;
-- 1
SELECT 
    title, 
    length, 
    RANK() OVER (ORDER BY length DESC) AS 'rank'
FROM 
    film
WHERE 
    length IS NOT NULL 
    AND length > 0;
-- 2
SELECT 
    title, 
    length, 
    rating, 
    RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS 'rank'
FROM 
    film
WHERE 
    length IS NOT NULL 
    AND length > 0;
-- 3
WITH ActorFilmCount AS (
    SELECT 
        a.actor_id, 
        a.first_name, 
        a.last_name, 
        COUNT(fa.film_id) AS film_count
    FROM 
        actor a
    JOIN 
        film_actor fa ON a.actor_id = fa.actor_id
    GROUP BY 
        a.actor_id, a.first_name, a.last_name
),
MaxActorFilmCount AS (
    SELECT 
        afc.actor_id, 
        afc.first_name, 
        afc.last_name, 
        afc.film_count,
        RANK() OVER (ORDER BY afc.film_count DESC) AS 'rank'
    FROM 
        ActorFilmCount afc
)
SELECT 
    maf.first_name, 
    maf.last_name, 
    maf.film_count
FROM 
    MaxActorFilmCount maf
WHERE 
    maf.rank = 1;
-- 4
SELECT 
    DATE_FORMAT(rental_date, '%Y-%m') AS month, 
    COUNT(DISTINCT customer_id) AS active_customers
FROM 
    rental
GROUP BY 
    month
ORDER BY 
    month;
-- 5
WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month, 
        COUNT(DISTINCT customer_id) AS active_customers
    FROM 
        rental
    GROUP BY 
        month
)

SELECT 
    mac1.month, 
    mac1.active_customers, 
    mac2.active_customers AS prev_month_active_customers
FROM 
    MonthlyActiveCustomers mac1
LEFT JOIN 
    MonthlyActiveCustomers mac2
ON 
    mac2.month = DATE_FORMAT(DATE_SUB(STR_TO_DATE(mac1.month, '%Y-%m'), INTERVAL 1 MONTH), '%Y-%m')
ORDER BY 
    mac1.month;
-- 6
WITH MonthlyActiveCustomers AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS month, 
        COUNT(DISTINCT customer_id) AS active_customers
    FROM 
        rental
    GROUP BY 
        month
)

SELECT 
    mac1.month, 
    mac1.active_customers, 
    mac2.active_customers AS prev_month_active_customers,
    ((mac1.active_customers - mac2.active_customers) / mac2.active_customers) * 100 AS percentage_change
FROM 
    MonthlyActiveCustomers mac1
LEFT JOIN 
    MonthlyActiveCustomers mac2
ON 
    mac2.month = DATE_FORMAT(DATE_SUB(STR_TO_DATE(mac1.month, '%Y-%m'), INTERVAL 1 MONTH), '%Y-%m')
ORDER BY 
    mac1.month;
-- 7
WITH CustomerMonthlyActivity AS (
    SELECT 
        customer_id, 
        DATE_FORMAT(rental_date, '%Y-%m') AS month
    FROM 
        rental
    GROUP BY 
        customer_id, month
),

RetainedCustomers AS (
    SELECT 
        curr.month AS current_month, 
        prev.month AS previous_month, 
        COUNT(DISTINCT curr.customer_id) AS retained_customers
    FROM 
        CustomerMonthlyActivity curr
    JOIN 
        CustomerMonthlyActivity prev 
    ON 
        curr.customer_id = prev.customer_id 
        AND prev.month = DATE_FORMAT(DATE_SUB(STR_TO_DATE(curr.month, '%Y-%m'), INTERVAL 1 MONTH), '%Y-%m')
    GROUP BY 
        curr.month, prev.month
)

SELECT 
    current_month, 
    retained_customers
FROM 
    RetainedCustomers
ORDER BY 
    current_month;



