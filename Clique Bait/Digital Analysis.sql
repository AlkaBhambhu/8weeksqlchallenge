-- How many users are there?
SELECT COUNT(DISTINCT user_id) AS users_count
FROM users;

-- How many cookies does each user have on average?
SELECT AVG(Count_cookie)
FROM (SELECT COUNT(cookie_id) count_cookie
      FROM users
      GROUP BY user_id) AS ct;
      
-- What is the unique number of visits by all users per month?
SELECT DISTINCT user_id, 
       MONTHname(start_date) AS Month_name,
       COUNT(cookie_id) OVER (PARTITION BY user_id, EXTRACT(MONTH FROM start_date) ) AS visits
FROM users;

-- What is the number of events for each event type?
SELECT event_type, COUNT(event_type) AS event_number
FROM events
GROUP BY event_type;


-- What is the percentage of visits which have a purchase event?
SELECT ROUND((purchase_event*100/total_event),2) AS purchase_visits_percentage
FROM (SELECT COUNT(event_type) AS total_event
	  FROM events) AS total_visits
JOIN (SELECT COUNT(e.event_type) as purchase_event
      FROM events e
      JOIN event_identifier ei ON e.event_type = ei.event_type
      WHERE event_name = 'purchase') AS purchase_visits
ON 1=1;


-- What is the percentage of visits which view the checkout page but do not have a purchase event?
SELECT ROUND((no_purchase*100/total_event),2) AS view_not_purchased
FROM (SELECT COUNT(event_type) AS total_event
	  FROM events) AS total_visits
JOIN (SELECT COUNT(*) AS no_purchase
	  FROM events e
	  JOIN page_hierarchy p ON e.page_id = p.page_id
	  JOIN event_identifier ei ON e.event_type = ei.event_type
	  WHERE page_name = 'checkout' AND event_name <> 'purchase') AS no_purchased
ON 1=1;

-- What are the top 3 pages by number of views
SELECT page_id,COUNT(*) AS view_num
FROM events e
JOIN event_identifier ei
     ON e.event_type = ei.event_type
WHERE ei.event_name = 'Page View'
GROUP BY page_id
ORDER BY view_num DESC
LIMIT 3;

-- What is the number of views and cart adds for each product category?
SELECT product_category,event_name, COUNT( visit_id)
FROM events e
JOIN event_identifier ei
     ON e.event_type = ei.event_type
JOIN page_hierarchy p ON e.page_id = p.page_id
WHERE event_name IN ('Page View','Add To Cart') AND product_category IS NOT NULL
GROUP BY event_name, product_category
ORDER BY product_category;

-- What are the top 3 products by purchases?
WITH purchased AS (select *, 
               DENSE_RANK() OVER (PARTITION BY visit_id order by sequence_number) as ranks,
			   ROW_NUMBER() OVER (PARTITION BY visit_id order by sequence_number DESC) AS row_num
			   from output 
               where event_name IN ('Add to Cart', 'Purchase'))
SELECT Product_id, count(DISTINCT visit_id) AS Purchased
from purchased where event_name = 'Add to cart' not in (row_num = 1)
GROUP BY product_id
ORDER BY Purchased desc
limit 3;








