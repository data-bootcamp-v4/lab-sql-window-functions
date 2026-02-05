USE sakila;

-- RANKING PELIS POR DURACION --

SELECT
f.title,
f.length,
RANK() OVER (ORDER BY length DESC) AS rank_pelis
FROM film f
WHERE length IS NOT NULL
AND length >0;

-- RANKING PELIS DURACION SEGUN RATING --
SELECT
f.title,
f.length,
f.rating,
RANK()OVER (
PARTITION BY rating
ORDER BY length DESC) AS rank_pelis
FROM film f
WHERE length IS NOT NULL
AND length >0;

-- LISTA DE ACTOR CON MAS PELIS TRABAJADAS Y EL NUMERO DE PELIS DONDE TRABAJO --

SELECT
actor_id,
COUNT(film_id) AS total_pelis
FROM film_actor
GROUP BY actor_id;

WITH conteo_actor AS (
SELECT
actor_id,
COUNT(film_id) AS total_pelis
FROM film_actor
GROUP BY actor_id)
SELECT
actor_id,
total_pelis,
RANK()OVER (ORDER BY total_pelis DESC) AS ranking_actores
FROM conteo_actor;

WITH conteo_actor AS ( 
SELECT
actor_id,
COUNT(film_id) AS total_pelis
FROM film_actor
GROUP BY actor_id),
goat_actor AS (
SELECT *
FROM conteo_actor
ORDER BY total_pelis DESC
LIMIT 1
)
SELECT
f.title,
a.first_name,
a.last_name,
ga.total_pelis
FROM goat_actor ga
JOIN actor a ON ga.actor_id = a.actor_id
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id;

-- CHALLENGE 2 --
-- NUMERO DE CLIENTES ACTIVOS DEL MES --
SELECT
date_format(rental_date, '%Y-%m') AS mes,
COUNT(DISTINCT customer_id) AS clientes_activos
FROM rental
GROUP BY mes
ORDER BY mes;

-- NUMERO DE CLIENTES ACTIVOS DEL MES PASADO --
WITH activos_mensuales AS (
SELECT
date_format(rental_date, '%Y-%m') AS mes,
COUNT(DISTINCT customer_id) AS clientes_activos
FROM rental
GROUP BY mes)
SELECT
mes,
clientes_activos,
LAG(clientes_activos) OVER(ORDER BY mes) AS mes_anterior
FROM activos_mensuales;

-- TASA DE VARIACION DE CLIENTES ACTIVOS --
WITH activos_mensuales AS (
    SELECT 
        DATE_FORMAT(rental_date, '%Y-%m') AS mes,
        COUNT(DISTINCT customer_id) AS clientes_activos
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)

SELECT 
    mes,
    clientes_activos,
    LAG(clientes_activos) OVER (ORDER BY mes) AS mes_anterior,
    ROUND(
        (clientes_activos - LAG(clientes_activos) OVER (ORDER BY mes))
        / LAG(clientes_activos) OVER (ORDER BY mes) * 100,
        2
    ) AS variacion_mensual
FROM activos_mensuales;

-- NUMERO DE CLIENTES RETENIDOS -- 

WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(rental_date, '%Y-%m') AS mes,
        customer_id
    FROM rental
)

SELECT 
    mc1.mes,
    COUNT(DISTINCT mc1.customer_id) AS clientes_retenidos
FROM monthly_customers mc1
JOIN monthly_customers mc2
    ON mc1.customer_id = mc2.customer_id
   AND mc2.mes = DATE_FORMAT(
        DATE_SUB(STR_TO_DATE(CONCAT(mc1.mes,'-01'), '%Y-%m-%d'), INTERVAL 1 MONTH),
        '%Y-%m'
   )
GROUP BY mc1.mes
ORDER BY mc1.mes;
