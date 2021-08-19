-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- how much money has Pizza Runner made so far if there are no delivery fees?

SELECT SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS Sales
FROM customer_orders;

-- What if there was an additional $1 charge for any pizza extras?
SELECT SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) + SUM(CASE WHEN extras IS NOT NULL THEN 1 ELSE 0 END) AS Sales
FROM customer_orders;

-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset - 
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS Rating;
CREATE TABLE Rating ( 
					order_id INT,
                    customer_id INT,
                    runner_id INT, 
                    ratings INT);

INSERT INTO RATING (order_id,customer_id,runner_id, ratings)
VALUES (1 , 101, 1, 4),
	   (2 , 101, 1, 5),
       (3 , 102, 1, 4),
       (4 , 103, 2, 3),
       (5 , 104, 3, 4),
       (6 , 101, 3, 4),
       (7 , 105, 2, 4),
       (8 , 102, 2, 4);
       
SELECT * FROM Rating;

-- customer_id, order_id, runner_id,rating,order_time,pickup_time,Time between order and pickup,Delivery duration,Average speed

SELECT r.order_id, r.customer_id, r.runner_id, r.ratings, c.order_time, ro.pickup_time, 
       TIMESTAMPDIFF(minute, c.order_time,ro.pickup_time) AS Time_diff,
	   ro.duration,
       ROUND((ro.distance/ro.duration),1) AS Speed
FROM Rating r
JOIN customer_orders c
    ON r.order_id = c.order_id
JOIN runner_orders ro
    ON c.order_id = ro.order_id;
    
-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
-- how much money does Pizza Runner have left over after these deliveries?
SELECT  runner_id, SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) + ROUND(SUM(CASE WHEN distance IS NOT NULL THEN distance*.3 ELSE 0 END),0) AS Sales
FROM runner_orders r
JOIN customer_orders c
ON r.order_id = c.order_id
WHERE cancellation IS NULL
GROUP BY runner_id;













