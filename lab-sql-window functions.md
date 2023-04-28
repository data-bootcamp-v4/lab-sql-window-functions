![logo_ironhack_blue 7](https://user-images.githubusercontent.com/23629340/40541063-a07a0a8a-601a-11e8-91b5-2f13e4e6b441.png)

# Lab | Window Functions

<details>
  <summary>
   <h2>Learning Goals</h2>
  </summary>

  This lab allows you to practice and apply the concepts and techniques taught in class. 

  Upon completion of this lab, you will be able to:
  
- Use window functions to perform complex analytical queries and gain insights into data, including computing rolling calculations, ranking data, and performing aggregations over subsets of data.

  <br>
  <hr> 

</details>

<details>
  <summary>
   <h2>Prerequisites</h2>
  </summary>

Before this starting this lab, you should have learnt about:

- SELECT, FROM, ORDER BY, LIMIT, WHERE, GROUP BY, and HAVING clauses. DISTINCT, AS keywords.
- Built-in SQL functions such as COUNT, MAX, MIN, AVG, ROUND, DATEDIFF, or DATE_FORMAT.
- JOIN to combine data from multiple tables.
- Subqueries, Temporary Tables, Views, CTEs.
- Window Functions: RANK() OVER with PARTITION BY, LAG().
 
  <br>
  <hr> 

</details>


## Introduction

Welcome to the Window Functions lab!

In this lab, you will be working with the [Sakila](https://dev.mysql.com/doc/sakila/en/) database on movie rentals. The goal of this lab is to help you practice and gain proficiency in using window functions in SQL queries.

Window functions are a powerful tool for performing complex data analysis in SQL. They allow you to perform calculations across multiple rows of a result set, without the need for subqueries or self-joins. This can greatly simplify your SQL code and make it easier to understand and maintain.

By the end of this lab, you will have a better understanding of how to use window functions in SQL to perform complex data analysis, assign rankings, and retrieve previous row values. These skills will be useful in a variety of real-world scenarios, such as sales analysis, financial reporting, and trend analysis.

## Challenge 1

This challenge consists of three exercises that will test your ability to use SQL RANK() function. You will use it to rank films by their length, rank films by length within the rating category, and find the actor or actress who has acted in the most number of films.

1. Rank films by their length and create an output table that includes only the title, length, and rank columns. Filter out any rows with null or zero values in the length column.

2. Rank films by length within the rating category and create an output table that includes only the title, length, rating and rank columns. Filter out any rows with null or zero values in the length column.

3. Produce a list that shows, for each film in the Sakila database, the actor or actress who has acted in the most number of films, as well as the total number of films in which they have acted. *Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.*

## Challenge 2

This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. 
By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.

The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an analysis on the monthly percentage change in the number of active customers and the number of retained customers. Use the Sakila database and progressively build queries to achieve the desired outcome. 

- Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.
- Step 2. Retrieve the number of active users in the previous month.
- Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
- Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.

*Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.*

## Requirements

- Fork this repo
- Clone it to your machine


## Getting Started

Complete the challenge in this readme in a `.sql` file.

## Submission

- Upon completion, run the following commands:

```bash
git add .
git commit -m "Solved lab"
git push origin master
```

- Create a Pull Request so that your TAs can check your work.



