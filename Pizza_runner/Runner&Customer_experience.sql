USE pizza_runner;

-- How many runners signed up for each 1 week period?
SELECT WEEK(registration_date) AS Signup_week, COUNT(*) as Num
FROM runners
GROUP BY Signup_week;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id,  ROUND(AVG(TIMESTAMPDIFF(minute, order_time,pickup_time)),0) AS Average_time
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE pickup_time IS NOT NULL
GROUP BY runner_id;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT c.order_id, COUNT(*) AS num_of_pizza, ROUND(AVG(TIMESTAMPDIFF(minute, order_time,pickup_time)),0) AS Average_time
FROM customer_orders c
JOIN runner_orders r
ON c.order_id = r.order_id
WHERE pickup_time IS NOT NULL
GROUP BY c.order_id;

-- What was the average distance travelled for each customer?
SELECT c.customer_id, ROUND(AVG(distance),0)
FROM runner_orders r
JOIN customer_orders c
ON r.order_id = c.order_id
GROUP BY c.customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT (MAX(duration)-MIN(duration)) AS Delivery_time_difference
FROM runner_orders;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, order_id, ROUND((distance/duration),1) AS Speed
FROM runner_orders
WHERE pickup_time IS NOT NULL
ORDER BY runner_id, order_id;

-- What is the successful delivery percentage for each runner?
SELECT runner_id, ROUND(SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)*100/COUNT(order_id),0) AS Success_percentage
FROM runner_orders
GROUP BY runner_id;

