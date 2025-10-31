use sakila;

-- 1. Rank films by their length and create an output table that includes the title, length, and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

select title, length,
rank () over (order by length desc) as rank_length
from film
WHERE 
    length IS NOT NULL AND length > 0;
    
-- 2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
-- Filter out any rows with null or zero values in the length column.

select title, length, rating,
rank () over (partition by rating order by length desc) as rank_within_raiting
from film
WHERE 
    length IS NOT NULL AND length > 0;
    




    

