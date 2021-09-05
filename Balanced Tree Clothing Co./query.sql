/*   High Level Sales Analysis  */

-- What was the total quantity sold for all products?
SELECT SUM(qty) AS total_sales
FROM sales;

-- What is the total generated revenue for all products before discounts?
SELECT SUM(price*qty) AS total_revenue
FROM sales;

-- What was the total discount amount for all products?
SELECT ROUND(SUM(discount*qty*price/100),2) AS total_discount
FROM sales;

/*  Transaction Analysis  */

-- How many unique transactions were there?
SELECT COUNT(DISTINCT txn_id)
FROM sales;

-- What is the average unique products purchased in each transaction?
SELECT DISTINCT txn_id, ROUND(count(prod_id) OVER (PARTITION BY txn_id),0) AS Average_product
FROM sales;

-- What are the 25th, 50th and 75th percentile values for the revenue per transaction?
-- What is the average discount value per transaction?
SELECT DISTINCT txn_id, ROUND(avg(discount) OVER (PARTITION BY txn_id),0) AS Average_discount
FROM sales;

-- What is the percentage split of all transactions for members vs non-members?
SELECT members_trans.members, ROUND(members_trans.member_transactions*100/total_trans.total_transactions,2) AS percentage 
FROM(
	  SELECT members, COUNT(txn_id) AS member_transactions
    FROM sales
    GROUP BY members) AS members_trans
LEFT JOIN(		
	SELECT COUNT(txn_id) AS total_transactions
    FROM sales) AS total_trans
ON 1=1;

-- What is the average revenue for member transactions and non-member transactions?
SELECT members, ROUND(AVG(SUM(qty*price - qty*price*discount/100)) OVER (PARTITION BY members),2)
FROM sales
GROUP BY members;

/*   Product Analysis  */

-- What are the top 3 products by total revenue before discount?
SELECT prod_id, SUM(qty*price) AS Revenue
FROM sales
GROUP BY prod_id
ORDER BY REVENUE DESC LIMIT 3;

-- What is the total quantity, revenue and discount for each segment?
SELECT p.segment_id, 
	   SUM(s.qty),ROUND(SUM(s.qty*s.price - s.qty*s.price*s.discount/100),2) AS Revenue,
	   ROUND(SUM(s.discount*s.qty*s.price/100),2) AS total_discount
FROM sales s
JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.segment_id;

-- What is the top selling product for each segment?

SELECT segment_id, segment_name, prod_id, product_name
FROM ( SELECT pd.segment_id, pd.segment_name, s.prod_id, pd.product_name,SUM(s.qty),
       ROW_NUMBER() Over (PARTITION BY segment_id ORDER BY SUM(s.qty) DESC) as ranks 
       FROM sales s
       INNER JOIN product_details pd
       ON s.prod_id = pd.product_id
       GROUP BY pd.segment_id, pd.segment_name, s.prod_id, pd.product_name) ranked 
Where ranks = 1;

-- What is the total quantity, revenue and discount for each category?
SELECT p.category_id, 
	   SUM(s.qty),
       ROUND(SUM(s.qty*s.price - s.qty*s.price*s.discount/100),2) AS Revenue,
	   ROUND(SUM(s.discount*s.qty*s.price/100),2) AS total_discount
FROM sales s
JOIN product_details p
	ON s.prod_id = p.product_id
GROUP BY p.category_id;

-- What is the top selling product for each category?
SELECT category_id, category_name, prod_id, product_name
FROM ( SELECT pd.category_id, pd.category_name, s.prod_id, pd.product_name,SUM(s.qty),
       ROW_NUMBER() Over (PARTITION BY category_id ORDER BY SUM(s.qty) DESC) as ranks 
       FROM sales s
       INNER JOIN product_details pd
       ON s.prod_id = pd.product_id
       GROUP BY pd.category_id, pd.category_name, s.prod_id, pd.product_name) ranked 
Where ranks = 1;

-- What is the percentage split of revenue by product for each segment?
SELECT segment_id, segment_name, ROUND((Revenue*100/t_revenue),2) AS percentage_split
FROM (SELECT pd.segment_id, pd.segment_name,ROUND(SUM(s.qty*s.price - s.qty*s.price*s.discount/100),2) AS Revenue
       FROM sales s
       INNER JOIN product_details pd
       ON s.prod_id = pd.product_id
       GROUP BY pd.segment_id, pd.segment_name) Segment_revenue
LEFT JOIN (SELECT ROUND(SUM(s.qty*s.price - s.qty*s.price*s.discount/100),2) AS t_Revenue
       FROM sales s
       INNER JOIN product_details pd
       ON s.prod_id = pd.product_id) total_revenue
ON 1=1;

-- What is the percentage split of revenue for each category?
SELECT category_id, category_name, ROUND((Revenue*100/t_revenue),2) AS percentage_split
FROM (SELECT pd.category_id, pd.category_name,ROUND(SUM(s.qty*s.price - s.qty*s.price*s.discount/100),2) AS Revenue
       FROM sales s
       INNER JOIN product_details pd
       ON s.prod_id = pd.product_id
       GROUP BY pd.category_id, pd.category_name) Segment_revenue
LEFT JOIN (SELECT ROUND(SUM(s.qty*s.price - s.qty*s.price*s.discount/100),2) AS t_Revenue
       FROM sales s
       INNER JOIN product_details pd
       ON s.prod_id = pd.product_id) total_revenue
ON 1=1;

-- What is the percentage split of revenue by segment for each category?
SELECT category_id, segment_id, segment_name, ROUND((Revenue*100/sum(Revenue) OVER (PARTITION BY category_id)),2) AS percentage_split
FROM (SELECT pd.category_id,pd.segment_id, pd.segment_name,ROUND(SUM(s.qty*s.price - s.qty*s.price*s.discount/100),2) AS Revenue
       FROM sales s
       INNER JOIN product_details pd
       ON s.prod_id = pd.product_id
       GROUP BY pd.category_id,pd.segment_id, pd.segment_name
       ORDER BY pd.category_id) Segment_revenue;
 
-- What is the total transaction “penetration” for each product? 
SELECT prod_id, ROUND((product_transaction*100/total_transaction),2) AS penetration_rate
FROM (SELECT prod_id, COUNT(txn_id) AS product_transaction
      FROM sales 
      GROUP BY prod_id) product_txn
LEFT JOIN (SELECT COUNT(DISTINCT txn_id) AS total_transaction
		   FROM sales) total_txn
ON 1=1
ORDER BY penetration_rate;

