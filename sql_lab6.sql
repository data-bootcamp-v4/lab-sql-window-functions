USE sakila;

#Challenge 1

#1. Rank films by their length and create an output table that includes the title, length, and rank columns only. 
#   Filter out any rows with null or zero values in the length column.

SELECT 
title,
length,
DENSE_RANK() OVER (
ORDER BY length DESC
) as length_rank
FROM film
WHERE length IS NOT NULL OR length != 0;

#2. Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. 
#   Filter out any rows with null or zero values in the length column.

CREATE TEMPORARY TABLE output_table AS
SELECT 
title,
length,
rating,
DENSE_RANK() OVER (
PARTITION BY rating
ORDER BY length DESC
) as length_rank
FROM film
WHERE length IS NOT NULL OR length != 0;

SELECT * 
FROM output_table;

#Challenge 2

#1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

-- it keeps giving me error code 1235 I can't do any of this lmao




