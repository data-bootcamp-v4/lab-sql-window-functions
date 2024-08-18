#Challenge 1:
#1. Rank films by their length and create an output table that includes the title, length, and rank columns only.
# Filter out any rows with null or zero values in the length column.
SELECT
	title AS movie,
    length,
    DENSE_RANK() OVER (ORDER BY length DESC) AS 'dense_rank'
FROM
	film
WHERE
	length != null OR length != 0;
    
#2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only.
#Filter out any rows with null or zero values in the length column.
SELECT
	title AS 'movie',
    length,
    rating,
    RANK() OVER(PARTITION BY rating ORDER BY length DESC) AS 'rank'
FROM
	film
WHERE
	length != null OR length != 0;
    
#3. Find for each film, the actor/actress who has acted in the greatest number of films, and the total number of films in which they have acted.
# Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.
WITH films_by_actor AS (
	SELECT
		actor_id,
		COUNT(film_id) AS 'n_films'
	FROM
		film_actor
	GROUP BY
		actor_id
),
ranking AS (
	SELECT
		fa.film_id,
		fba.*,
		RANK() OVER(PARTITION BY fa.film_id ORDER BY fba.n_films DESC) AS rank_
	FROM
		film_actor AS fa
	JOIN
		films_by_actor AS fba ON fa.actor_id = fba.actor_id
)
SELECT
	f.title AS 'movie',
    CONCAT(a.first_name, ' ', a.last_name) AS 'greatest_actor',
    fba.n_films AS 'greatest_actor_n_films'
FROM
	film AS f
JOIN
	film_actor AS fa ON f.film_id = fa.film_id
JOIN
	actor AS a ON fa.actor_id = a.actor_id
JOIN
	films_by_actor AS fba ON a.actor_id = fba.actor_id
JOIN
	ranking AS r ON fba.actor_id = r.actor_id
WHERE
	r.rank_ = 1;

# Challenge 2:
#1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
SELECT 
	DATE_FORMAT(rental_date, "%M %Y") AS 'month_',
    COUNT(DISTINCT(customer_id)) AS 'active_customers'
FROM
	rental
GROUP BY
	month_
ORDER BY
	MIN(rental_date);

#2. Retrieve the number of active users in the previous month
SELECT
	month_,
    active_customers,
    active_customers - LAG(active_customers) OVER(ORDER BY min_rental_date) AS active_customer_difference
FROM (
	SELECT 
	    DATE_FORMAT(rental_date, "%M %Y") AS 'month_',
        COUNT(DISTINCT(customer_id)) AS 'active_customers',
        MIN(rental_date) AS min_rental_date
	FROM
		rental
	GROUP BY
		month_
	ORDER BY
		MIN(rental_date)
    ) AS temp_table
ORDER BY min_rental_date;

#3. Calculate the percentage change in the number of active customers between the current and previous month.
WITH act_cust AS (
	SELECT 
	    DATE_FORMAT(rental_date, "%M %Y") AS month_,
        COUNT(DISTINCT(customer_id)) AS active_customers,
        MIN(rental_date) AS min_rental_date
	FROM
		rental
	GROUP BY
		month_
	ORDER BY
		MIN(rental_date)
    ),
act_cust_diff AS (
	SELECT
		*,
		active_customers - LAG(active_customers) OVER(ORDER BY min_rental_date) AS active_customer_difference
	FROM
		act_cust
	ORDER BY
		min_rental_date
        )
SELECT
	*,
    ROUND((active_customer_difference / LAG(active_customers) OVER(ORDER BY min_rental_date))*100, 2) AS act_cust_diff_percentage_change
FROM
	act_cust_diff
ORDER BY
	min_rental_date;
    
#4.  Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months
WITH cust_month AS (
	SELECT 
		DATE_FORMAT(rental_date, "%Y-%M") AS month_,
		customer_id
	FROM
		rental
	GROUP BY
		customer_id, month_
        ),
customer_retention_status AS (
	SELECT
		*,
		CASE
			WHEN LAG(customer_id) OVER(PARTITION BY customer_id ORDER BY month_) = customer_id THEN 'retained'
			ELSE 'unretained'
			END AS retention_status
	FROM
		cust_month
	ORDER BY
		month_ DESC,
		customer_id
        ),
retained_customers_count AS (
	SELECT
		month_,
		COUNT(retention_status) AS retained_customers
	FROM
		customer_retention_status
	WHERE
		retention_status = 'retained'
	GROUP BY
		month_
	ORDER BY
		month_
        )
SELECT
	
	
    













