-- combined table
CREATE VIEW output AS 
SELECT e.visit_id, e.cookie_id,e.page_id,e.event_type, e.sequence_number, e.event_time,ei.event_name,p.page_name, p.product_category, p.product_id 
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type
JOIN page_hierarchy p ON e.page_id = p.page_id;

-- output table for products
DROP VIEW  IF EXISTS product_table;
CREATE VIEW product_table AS
WITH CTE AS (SELECT product_id, COUNT(visit_id) AS Views FROM output WHERE event_name = 'Page View' GROUP BY product_id),
     CTE2 AS (SELECT product_id,COUNT(visit_id) AS added_to_cart FROM output WHERE event_name = 'Add to Cart' GROUP BY product_id),
     CTE3 AS ( WITH not_purchased AS ( SELECT  *, 
              DENSE_RANK() OVER (PARTITION BY visit_id order by sequence_number) as ranks,
              ROW_NUMBER() OVER (PARTITION BY visit_id order by sequence_number DESC) AS row_num
              from output 
              where event_name IN ('Add to Cart', 'Purchase'))
              SELECT Product_id, count(DISTINCT visit_id) AS abandoned FROM not_purchased where row_num = 1 and event_name <> 'Purchase'
              GROUP BY product_id
			  ORDER BY product_id),
	   CTE4 AS(WITH purchased AS (select *, 
               DENSE_RANK() OVER (PARTITION BY visit_id order by sequence_number) as ranks,
			   ROW_NUMBER() OVER (PARTITION BY visit_id order by sequence_number DESC) AS row_num
			   from output 
               where event_name IN ('Add to Cart', 'Purchase'))
               SELECT Product_id, count(DISTINCT visit_id) AS Purchased
               from purchased where event_name = 'Add to cart' not in (row_num = 1)
               GROUP BY product_id
               ORDER BY product_id)
SELECT CTE.product_id, Views, added_to_cart, abandoned, Purchased
FROM CTE 
JOIN CTE2 ON cte.product_id = cte2.product_id
JOIN CTE3 ON cte.product_id = cte3.product_id
JOIN CTE4 ON cte.product_id = cte4.product_id;

SELECT * from product_table;

-- output table for product category
DROP VIEW  IF EXISTS product_category_table;
CREATE VIEW product_category_table AS
WITH CTE AS (SELECT product_category, COUNT(visit_id) AS Views FROM output WHERE event_name = 'Page View' GROUP BY product_category),
     CTE2 AS (SELECT product_category,COUNT(visit_id) AS added_to_cart FROM output WHERE event_name = 'Add to Cart' GROUP BY product_category),
     CTE3 AS ( WITH not_purchased AS ( SELECT  *, 
              DENSE_RANK() OVER (PARTITION BY visit_id order by sequence_number) as ranks,
              ROW_NUMBER() OVER (PARTITION BY visit_id order by sequence_number DESC) AS row_num
              from output 
              where event_name IN ('Add to Cart', 'Purchase'))
              SELECT product_category, count( visit_id) AS abandoned FROM not_purchased where row_num = 1 and event_name <> 'Purchase'
              GROUP BY product_category),
	   CTE4 AS(WITH purchased AS (select *, 
               DENSE_RANK() OVER (PARTITION BY visit_id order by sequence_number) as ranks,
			   ROW_NUMBER() OVER (PARTITION BY visit_id order by sequence_number DESC) AS row_num
			   from output 
               where event_name IN ('Add to Cart', 'Purchase'))
               SELECT product_category, count(visit_id) AS Purchased
               from purchased where event_name = 'Add to cart' not in (row_num = 1)
               GROUP BY product_category)
SELECT CTE.product_category, Views, added_to_cart, abandoned, Purchased
FROM CTE 
JOIN CTE2 ON cte.product_category = cte2.product_category
JOIN CTE3 ON cte.product_category = cte3.product_category
JOIN CTE4 ON cte.product_category = cte4.product_category
ORDER BY CTE.product_category ;

SELECT * FROM product_category_table;

-- Which product had the most views, cart adds and purchases?
SELECT * FROM product_table
ORDER BY Views DESC
LIMIT 1;

-- Which product was most likely to be abandoned?
SELECT product_id FROM product_table
ORDER BY abandoned DESC
LIMIT 1;

-- Which product had the highest view to purchase percentage?
SELECT *, (Purchased*100/Views) as percent FROM product_table
ORDER BY percent DESC
LIMIT 1;

-- What is the average conversion rate from view to cart add?
SELECT round(AVG(added_to_cart*100/Views),2) FROM product_table;

-- What is the average conversion rate from cart add to purchase?
SELECT round(AVG(Purchased*100/added_to_cart),2) FROM product_table;

     