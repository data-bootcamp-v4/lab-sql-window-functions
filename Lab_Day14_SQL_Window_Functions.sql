-- Step 1: Monthly active customers
WITH monthly_activity AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM rental
    GROUP BY rental_month
),

-- Step 2: Previous month activity
activity_with_lag AS (
    SELECT 
        rental_month,
        active_customers,
        LAG(active_customers) OVER (ORDER BY rental_month) AS previous_month_customers
    FROM monthly_activity
),

-- Step 3: Percentage change
activity_with_change AS (
    SELECT 
        rental_month,
        active_customers,
        previous_month_customers,
        ROUND(
            (active_customers - previous_month_customers) / previous_month_customers * 100, 2
        ) AS percent_change
    FROM activity_with_lag
)

-- Step 4: Retained customers
SELECT 
    activity_with_change.rental_month,
    activity_with_change.active_customers,
    activity_with_change.previous_month_customers,
    activity_with_change.percent_change,
    COUNT(DISTINCT current.customer_id) AS retained_customers
FROM activity_with_change
LEFT JOIN (
    SELECT 
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM rental
) AS current ON current.rental_month = activity_with_change.rental_month
LEFT JOIN (
    SELECT 
        customer_id,
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month
    FROM rental
) AS previous ON previous.rental_month = DATE_FORMAT(
    DATE_SUB(STR_TO_DATE(activity_with_change.rental_month, '%Y-%m-01'), INTERVAL 1 MONTH),
    '%Y-%m'
) AND current.customer_id = previous.customer_id
GROUP BY activity_with_change.rental_month,
         activity_with_change.active_customers,
         activity_with_change.previous_month_customers,
         activity_with_change.percent_change;
