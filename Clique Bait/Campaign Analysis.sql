DROP TABLE IF EXISTS visit_record;
CREATE TABLE visit_record
WITH CTE AS(SELECT  e.visit_id, c.campaign_name
            FROM events e 
            JOIN page_hierarchy p on e.page_id = p.page_id 
			JOIN campaign_identifier c ON p.product_id = c.products
            WHERE (e.event_time BETWEEN c.start_date AND c.end_date)),
    CTE2 AS( SELECT e.visit_id, GROUP_CONCAT(p.product_id) AS cart_products ,GROUP_CONCAT(p.page_name) AS cart_products_name
             FROM events e 
            JOIN page_hierarchy p on e.page_id = p.page_id
            WHERE e.event_type = 2
            GROUP BY e.visit_id)
SELECT DISTINCT u.user_id, e.visit_id, visit_start_time.event_time,
                SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) OVER (PARTITION BY visit_id) AS page_views,
			    SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) OVER (PARTITION BY visit_id) AS ecart_adds,
                SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) OVER (PARTITION BY visit_id) AS purchase,
                CTE.campaign_name,
                SUM(CASE WHEN event_type = 4 THEN 1 ELSE 0 END) OVER (PARTITION BY visit_id) AS impression,
                SUM(CASE WHEN event_type = 5 THEN 1 ELSE 0 END) OVER (PARTITION BY visit_id) AS click,
                CTE2.cart_products, CTE2.cart_products_name
FROM events e
JOIN users u 
    ON e.cookie_id = u.cookie_id
JOIN (SELECT visit_id, event_time FROM events WHERE sequence_number = 1) AS visit_start_time
    ON e.visit_id = visit_start_time.visit_id
LEFT JOIN CTE ON e.visit_id = CTE.visit_id
LEFT JOIN CTE2 ON e.visit_id = CTE2.visit_id
ORDER BY user_id, e.visit_id;

SELECT * FROM visit_record;