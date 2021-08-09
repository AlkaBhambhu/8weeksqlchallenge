USE data_base;

-- 1.How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id)
FROM customer_nodes;

-- 2.What is the number of nodes per region?
SELECT DISTINCT region_id, COUNT(DISTINCT node_id) AS nodes_per_region
FROM customer_nodes
GROUP BY region_id
ORDER BY region_id;

-- 3.How many customers are allocated to each region?
SELECT DISTINCT region_id, COUNT(DISTINCT customer_id) AS customers_per_region
FROM customer_nodes
GROUP BY region_id
ORDER BY region_id;

-- 4.How many days on average are customers reallocated to a different node?
WITH CTE AS(
		SELECT *, LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS Next_Date
        FROM customer_nodes
        ORDER BY customer_id)
SELECT ROUND(AVG(DATEDIFF(Next_date,start_date)))
FROM CTE;


-- B. Customer Transactions
-- 1.What is the unique count and total amount for each transaction type?
SELECT DISTINCT txn_type, COUNT(DISTINCT customer_id) AS unique_count, SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;

-- What is the average total historical deposit counts and amounts for all customers?
SELECT COUNT(txn_type) AS 'Count', ROUND(AVG(txn_amount),1) AS average_amount
FROM customer_transactions
WHERE txn_type = 'deposit';

-- For each month-how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH CTE_DEPOSIT AS (SELECT EXTRACT(MONTH FROM txn_date) AS Month_num, customer_id, COUNT(txn_type) AS deposits
					 FROM customer_transactions
                     WHERE txn_type = 'deposit'
                     GROUP BY Month_num , customer_id),
	CTE_PURCHASE AS (SELECT EXTRACT(MONTH FROM txn_date) AS Month_num, customer_id, COUNT(txn_type) AS purchases
					 FROM customer_transactions
                     WHERE txn_type = 'purchase'
                     GROUP BY Month_num , customer_id),
	CTE_WITHDRAWAL AS (SELECT EXTRACT(MONTH FROM txn_date) AS Month_num, customer_id, COUNT(txn_type) AS withdrawals
					 FROM customer_transactions
                     WHERE txn_type = 'withdrawal'
                     GROUP BY Month_num , customer_id)
SELECT d.Month_num, COUNT(d.customer_id) AS total_count
FROM CTE_DEPOSIT d
JOIN CTE_PURCHASE p
	ON d.Month_num = p.month_num AND d.customer_id = p.customer_id
JOIN CTE_WITHDRAWAL w
	ON p.Month_num = w.month_num AND p.customer_id = w.customer_id
WHERE deposits >1 AND (purchases = 1 OR withdrawals = 1)
GROUP BY Month_num 
ORDER BY Month_num;


-- What is the closing balance for each customer at the end of the month?

WITH CTE AS 
    (SELECT EXTRACT(MONTH FROM txn_date)AS Month_num, Customer_id,  
	        CASE WHEN txn_type = 'deposit' THEN txn_amount 
			ELSE -txn_amount
			END AS amount
	 FROM customer_transactions)
SELECT  customer_id,Month_num, SUM(amount) AS balance
FROM CTE
Group by Month_num, customer_id
ORDER BY customer_id,Month_num;




