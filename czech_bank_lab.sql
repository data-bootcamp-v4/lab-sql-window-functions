USE bank;
# Czech Bank SQL Lab 

## 1️⃣ Basic Querying

#1.1 Retrieve the first 10 clients, displaying their client_id and birth_date.
SELECT client_id, birth_number
FROM client
LIMIT 10;
#1.2 Get a list of distinct operation types from the trans table.
SELECT DISTINCT type 
FROM trans;

#1.3 Find all accounts opened after January 1, 1996.
SELECT date FROM account;

SELECT account_id, date 
FROM account 
HAVING date  > 960101;


#1.4 Count the total number of transactions in the trans table.
SELECT COUNT(trans_id) as num_transactions
From trans;

#1.5 Retrieve all loans where the amount is greater than 50,000, sorted by date descending.

SELECT date, amount, account_id
FROM loan
WHERE amount > 50000
ORDER BY date DESC;


## 2️⃣ Joins

#2.1 Retrieve a list of clients and their account numbers.
SELECT client.client_id, account.account_id AS account_num
FROM account
INNER JOIN client
ON account.district_id = client.district_id; 
SELECT client_id, account_id 
FROM disp; 

#2.2 Show a list of transactions along with the corresponding account owner (client_id).
SELECT trans.trans_id, disp.client_id
FROM disp
INNER JOIN trans
ON disp.account_id = trans.account_id;

#2.3 Find clients who have a credit card, showing their client_id, account_id, and card type.

SELECT DISTINCT card.type, card.card_id, disp.client_id, disp.account_id
FROM card
INNER JOIN disp
USING(disp_id); 

#2.4 Retrieve all loan details along with the respective account holder’s client_id.
SELECT loan_id,account_id,date,amount,duration,payments,status, disp.client_id
FROM loan
INNER JOIN disp
USING(account_id); 


#2.5 Find the total number of transactions per account, ordered by the highest number of transactions first.

SELECT account_id, COUNT(trans_id) AS num_transactions
FROM trans
GROUP BY account_id
ORDER BY num_transactions DESC;


## 3️⃣ Subqueries

#3.1 Find all clients who have taken loans of more than 100,000.
SELECT disp.client_id, high_loans.amount
FROM ( SELECT account_id, amount
    FROM loan
    WHERE amount > 100000
) AS high_loans
INNER JOIN disp
USING(account_id);


#3.2 Retrieve accounts that have more than 10 transactions.
SELECT *
FROM ( SELECT account_id, COUNT(trans_id) AS num_transactions
    FROM trans
    GROUP BY account_id) AS t
WHERE num_transactions > 10;

#3.3 Find clients who do NOT have a credit card.
SELECT client_id, card_id

#3.4 Show the account with the highest loan amount.

#3.5 List all accounts where the total deposited amount (credit operations) is greater than 500,000.

## 4️⃣ CTEs & Window Functions

#4.1 Use a CTE to find the total number of transactions per account

WITH report AS (
    SELECT account_id, SUM(trans_id) AS total_num_trans
    FROM trans
    GROUP BY account_id
)
SELECT * FROM report;


#4.2 Use a window function to show each transaction along with the running total of transaction amounts per account
SELECT  account_id, trans_id, amount,
    SUM(amount) OVER (PARTITION BY account_id 
					 ORDER BY trans_id
                     ) AS running_total
FROM trans;

#4.3 Rank accounts by loan amount using RANK().
SELECT account_id, amount,
       RANK() OVER (PARTITION BY account_id ORDER BY amount DESC) as rank_num 
FROM loan;

#4.4 Find the oldest account per client using ROW_NUMBER().

SELECT client_id, date,
       ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY date ASC
       ) AS row_num
FROM account
INNER JOIN disp 
USING(account_id)
LIMIT 1;


# 4.5 Find the 3 largest transactions for each account using DENSE RANK().

SELECT account_id, trans_id, amount,
       DENSE_RANK() OVER (
           PARTITION BY account_id 
           ORDER BY amount DESC
       ) AS dense_rank_num
FROM trans
LIMIT 3;


