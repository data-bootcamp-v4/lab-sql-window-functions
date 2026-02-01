use sakila;

-- 1.1
SELECT 
title, 
length, 
RANK() OVER (ORDER BY length DESC) AS ranking
FROM film
WHERE length IS NOT NULL AND length > 0;

-- 1.2

SELECT 
title, 
length, 
rating,
RANK() OVER (PARTITION BY rating ORDER BY length DESC) AS ranking_por_categoria
FROM film
WHERE length IS NOT NULL AND length > 0;

-- 1.3

WITH actor_counts AS (
    SELECT 
        actor_id, 
        COUNT(film_id) AS total_films
    FROM film_actor
    GROUP BY actor_id
),

actor_rank_per_film AS (
    SELECT 
       f.title,
       a.first_name,
       a.last_name,
       ac.total_films,
       DENSE_RANK() OVER (PARTITION BY f.film_id ORDER BY ac.total_films DESC) AS actor_rank
    FROM film AS f
    LEFT JOIN film_actor AS fa 
    ON f.film_id = fa.film_id
    LEFT JOIN actor AS a 
    ON fa.actor_id = a.actor_id
    LEFT JOIN actor_counts AS ac 
    ON a.actor_id = ac.actor_id
)
SELECT 
    title,
    CONCAT(first_name, ' ', last_name) AS prolific_actor,
    total_films
FROM actor_rank_per_film
WHERE actor_rank = 1;

-- 2

WITH mensual_activos AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS mes_actividad,
        COUNT(DISTINCT customer_id) AS clientes_activos
    FROM rental
    GROUP BY mes_actividad
),
comparativo_mensual AS (
    SELECT 
        mes_actividad,
        clientes_activos,
        LAG(clientes_activos) OVER (ORDER BY mes_actividad) AS mes_anterior
    FROM mensual_activos
)
SELECT 
    mes_actividad,
    clientes_activos,
    mes_anterior,
    ROUND(((clientes_activos - mes_anterior) / mes_anterior) * 100, 2) AS variacion_porcentual
FROM comparativo_mensual;

WITH clientes_por_mes AS (
    SELECT DISTINCT 
        customer_id, 
        DATE_FORMAT(rental_date, '%Y-%m') AS mes_actividad
    FROM rental
),
retencion_calculo AS (
    SELECT 
        curr.mes_actividad,
        COUNT(DISTINCT curr.customer_id) AS clientes_retenidos
    FROM clientes_por_mes AS curr
    INNER JOIN clientes_por_mes AS prev 
        ON curr.customer_id = prev.customer_id 
        AND PERIOD_DIFF(REPLACE(curr.mes_actividad, '-', ''), REPLACE(prev.mes_actividad, '-', '')) = 1
    GROUP BY curr.mes_actividad
)
SELECT * 
FROM retencion_calculo;


