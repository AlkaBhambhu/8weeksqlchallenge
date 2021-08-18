-- PIZZA METRICS

-- How many pizzas were ordered?
SELECT COUNT(order_id)
FROM customer_orders;

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id)
FROM customer_orders;

-- How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id)
FROM runner_orders
WHERE cancellation is null
GROUP BY runner_id;

-- How many of each type of pizza was delivered?
SELECT pizza_id, COUNT(c.order_id)
FROM customer_orders c
JOIN runner_orders r
    ON c.order_id = r.order_id
WHERE cancellation is null
GROUP BY pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, pizza_name, COUNT(c.pizza_id) AS order_count
FROM customer_orders c
JOIN pizza_names p
   ON c.pizza_id = p.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id, pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
SELECT c.order_id,COUNT(pizza_id) AS Maximum_num
FROM customer_orders c
JOIN runner_orders r
    ON c.order_id = r.order_id
WHERE cancellation is null
GROUP BY c.order_id
ORDER BY Maximum_num DESC LIMIT 1;
	
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT C.customer_id, 
       SUM(CASE WHEN exclusions is not null OR extras is not null THEN 1 ELSE 0 END) AS 'Change',
       SUM(CASE WHEN exclusions is null AND extras is null THEN 1 ELSE 0 END) AS 'No_Change'
FROM customer_orders c
JOIN runner_orders r
    ON c.order_id = r.order_id
WHERE cancellation is null
GROUP BY c.customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*)
FROM customer_orders c
JOIN runner_orders r
    ON c.order_id = r.order_id
WHERE cancellation is null 
AND exclusions IS NOT NULL
AND extras IS NOT NULL;

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time) AS Hour, COUNT(*) AS Total_num
FROM customer_orders
GROUP BY Hour
ORDER BY Hour;

-- What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) AS Week_num, COUNT(*) AS Total_num
FROM customer_orders
GROUP BY Week_num
ORDER BY Week_num;
       
       















