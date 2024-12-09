USE sakila;

-- Step 1: Retrieve the number of monthly active customers
SELECT 
    YEAR(r.rental_date) AS rental_year, 
    MONTH(r.rental_date) AS rental_month, 
    COUNT(DISTINCT r.customer_id) AS active_customers
FROM rental r
GROUP BY rental_year, rental_month
ORDER BY rental_year, rental_month;

-- Step 2: Retrieve the number of active customers in the previous month
WITH monthly_active AS (
    SELECT 
        YEAR(r.rental_date) AS rental_year, 
        MONTH(r.rental_date) AS rental_month, 
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM rental r
    GROUP BY rental_year, rental_month
)
SELECT 
    m1.rental_year, 
    m1.rental_month, 
    m1.active_customers, 
    COALESCE(m2.active_customers, 0) AS previous_month_active_customers
FROM monthly_active m1
LEFT JOIN monthly_active m2 
    ON m1.rental_year = m2.rental_year 
    AND m1.rental_month = m2.rental_month + 1
ORDER BY m1.rental_year, m1.rental_month;

-- Step 3: Calculate the percentage change in active customers
WITH monthly_active AS (
    SELECT 
        YEAR(r.rental_date) AS rental_year, 
        MONTH(r.rental_date) AS rental_month, 
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM rental r
    GROUP BY rental_year, rental_month
)
SELECT 
    m1.rental_year, 
    m1.rental_month, 
    m1.active_customers, 
    COALESCE(m2.active_customers, 0) AS previous_month_active_customers,
    CASE 
        WHEN m2.active_customers = 0 THEN NULL
        ELSE ((m1.active_customers - m2.active_customers) / m2.active_customers) * 100
    END AS percentage_change
FROM monthly_active m1
LEFT JOIN monthly_active m2 
    ON m1.rental_year = m2.rental_year 
    AND m1.rental_month = m2.rental_month + 1
ORDER BY m1.rental_year, m1.rental_month;

-- Step 4: Calculate the number of retained customers
WITH monthly_active AS (
    SELECT 
        YEAR(r.rental_date) AS rental_year, 
        MONTH(r.rental_date) AS rental_month, 
        COUNT(DISTINCT r.customer_id) AS active_customers
    FROM rental r
    GROUP BY rental_year, rental_month
),
retained_customers AS (
    SELECT 
        r1.rental_year, 
        r1.rental_month, 
        COUNT(DISTINCT r1.customer_id) AS retained_customers
    FROM rental r1
    JOIN rental r2 
        ON r1.customer_id = r2.customer_id
        AND r1.rental_date BETWEEN r2.rental_date AND LAST_DAY(r2.rental_date)
    GROUP BY r1.rental_year, r1.rental_month
)
SELECT 
    m.rental_year, 
    m.rental_month, 
    m.active_customers, 
    COALESCE(rc.retained_customers, 0) AS retained_customers
FROM monthly_active m
LEFT JOIN retained_customers rc 
    ON m.rental_year = rc.rental_year 
    AND m.rental_month = rc.rental_month
ORDER BY m.rental_year, m.rental_month;
