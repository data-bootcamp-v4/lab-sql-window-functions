	USE sakila;
    
    # CHALLENGE 1
    
    SELECT title, length,
		RANK() OVER(ORDER BY length DESC) AS "Rank"
    FROM film
    WHERE length != 0;
    
    SELECT title, length, rating,
		DENSE_RANK() OVER(PARTITION BY rating ORDER BY length DESC) as "Rank"
    FROM film
    WHERE length IS NOT NULL
    ORDER BY "Rank";
    
    # DROP VIEW view_actors;
    
    CREATE VIEW view_actors AS
		SELECT actor_id, COUNT(*) as count_mov
		FROM film_actor
		GROUP BY actor_id;
    
    CREATE VIEW view_ranks AS
		SELECT *,
			DENSE_RANK() OVER(ORDER BY count_mov DESC) AS actor_rank
		FROM actor
		JOIN view_actors
		USING(actor_id);
        
	SELECT *
    FROM view_ranks;
    
    CREATE VIEW view_results AS
		SELECT actor_id, film_id, CONCAT(first_name, " ", last_name) AS full_name, count_mov, actor_rank
		FROM film_actor
		JOIN view_ranks
		USING(actor_id)
		ORDER BY film_id;

	SELECT actor_id, film_id, full_name, count_mov, rank_intern FROM
    (
    SELECT *,
		DENSE_RANK() OVER(PARTITION BY film_id ORDER BY count_mov) rank_intern
    FROM view_results
    ) AS results
    WHERE rank_intern = 1;
    
    # CHALLENGE 2
    
    DROP VIEW view_months;
    
    CREATE VIEW view_months AS
    SELECT DATE_FORMAT(rental_date, "%M") AS the_month, COUNT(DISTINCT customer_id) AS amount_customer
    FROM rental
    GROUP BY the_month;
    
    CREATE VIEW view_difference AS
    SELECT the_month, amount_customer,
       amount_customer - LAG(amount_customer) OVER (ORDER BY STR_TO_DATE(The_month, "%m")) as difference
	FROM view_months
    ORDER BY STR_TO_DATE(The_month, "%m");

	SELECT *,
		ROUND((ABS(difference) / amount_customer)*100, 1) as percentile
	FROM view_difference;
    
    SELECT customer_id
    FROM rental
    WHERE customer_id IN (SELECT customer_id
							FROM rental
                            GROUP BY the_month AND LAG(the_month)
                            )
	ODER BY the_month;

