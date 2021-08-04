CREATE SCHEMA dannys_diner;

USE dannys_diner;
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price)
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, count(DISTINCT order_date)
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH CTE AS (
		SELECT s.customer_id,m.product_name, rank() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS ranks
        FROM sales s
        JOIN menu m
        ON s.product_id = m.product_id)
SELECT DISTINCT customer_id, product_name 
FROM CTE 
WHERE ranks = 1;

-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT  s.customer_id, m.product_name,count(1) -- (s.product_id) AS count_total
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY m.product_name, s.customer_id
ORDER BY count(1) desc
;

-- 5.Which item was the most popular for each customer?
WITH CTE AS(
		SELECT s.customer_id, s.product_id, COUNT(s.product_id)AS total_count, RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS ranks
        FROM sales s
        GROUP BY customer_id, product_id)
SELECT CTE.customer_id, m.product_name, total_count
FROM CTE
JOIN menu m
ON CTE.product_id = m.product_id
WHERE ranks = 1;

-- 6.Which item was purchased first by the customer after they became a member?
WITH CTE AS (
		SELECT s.customer_id,s.order_date, m.product_name, rank() OVER (PARTITION BY customer_id ORDER BY order_date) AS ranks
        FROM menu m
        JOIN sales s
			ON m.product_id = s.product_id
        JOIN members mb
			ON s.customer_id = mb.customer_id
WHERE S.order_date >= mb.join_date)
SELECT CTE.customer_id, CTE.product_name, CTE.order_date
FROM CTE 
WHERE CTE.ranks = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH CTE AS (
		SELECT s.customer_id,s.order_date, m.product_name, rank() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS ranks
        FROM menu m
        JOIN sales s
			ON m.product_id = s.product_id
        JOIN members mb
			ON s.customer_id = mb.customer_id
WHERE S.order_date < mb.join_date)
SELECT CTE.customer_id, CTE.product_name, CTE.order_date
FROM CTE 
WHERE CTE.ranks = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, sum(m.price)AS total, Count(s.product_id)
FROM menu m
JOIN sales s
	ON m.product_id = s.product_id
JOIN members mb
	ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY customer_id;

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, SUM(Price*(CASE WHEN product_name = 'sushi' THEN 20 ELSE 10 END)) AS total_points
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi
-- how many points do customer A and B have at the end of January?
SELECT s.customer_id, 
		SUM(CASE WHEN s.order_date >= mb.join_date AND s.order_date <= mb.join_date + 7
			     THEN price*20
                 ELSE price *10 END) AS points
FROM  sales s
INNER JOIN menu m
	ON s.product_id = m.product_id
INNER JOIN members mb
	ON s.customer_id = mb.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY customer_id;
    
    
            