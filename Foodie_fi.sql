USE foodie_fi;

-- How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS Total_customers
FROM subscriptions;

-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT MONTHNAME(start_date) AS 'Month', COUNT(plan_id)
FROM subscriptions
WHERE plan_id = 0
GROUP BY MONTHNAME(start_date);

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT p.plan_name, COUNT(s.plan_id) AS start_date_count
FROM subscriptions s
JOIN plans p
	ON s.plan_id = p.plan_id
WHERE EXTRACT(YEAR FROM start_date)= 2021
GROUP BY p.plan_name
ORDER BY start_date_count;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(customer_id) AS Total_count, 
	   CONCAT(ROUND(count(DISTINCT customer_id) *100 / (SELECT count(DISTINCT customer_id) FROM subscriptions),1), '%') AS percentage_total
FROM subscriptions
WHERE plan_id = 4;

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH CTE AS(
			SELECT s.customer_id,s.plan_id, LAG(plan_id,1) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) As Previous_plan
            FROM subscriptions s)
SELECT Count(DISTINCT customer_id) AS 'Churn_total', 
	   CONCAT(ROUND(Count(DISTINCT customer_id)*100/ (SELECT count(DISTINCT customer_id) FROM CTE),0), '%') AS percentage 
FROM CTE 
WHERE previous_plan = 0 AND plan_id = 4;

-- What is the number and percentage of customer plans after their initial free trial?
WITH CTE AS(
			SELECT s.customer_id,s.plan_id, LAG(plan_id,1) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) As Previous_plan
            FROM subscriptions s)
SELECT Count(DISTINCT customer_id) AS 'Success_total', 
	   CONCAT(ROUND(Count(DISTINCT customer_id)*100/ (SELECT count(DISTINCT customer_id) FROM CTE),0), '%') AS percentage 
FROM CTE 
WHERE previous_plan = 0 AND plan_id IN (1,2,3);

-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?


-- How many customers have upgraded to an annual plan in 2020?
WITH CTE AS(
			SELECT s.customer_id,s.plan_id,s.start_date, LAG(plan_id,1) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) As Previous_plan
            FROM subscriptions s)
SELECT Count(DISTINCT customer_id) AS Upgrade_total, 
	   CONCAT(ROUND(Count(DISTINCT customer_id)*100/ (SELECT count(DISTINCT customer_id) FROM CTE),0), '%') AS percentage 
FROM CTE 
WHERE previous_plan IN (0,1,2) AND plan_id = 3 AND EXTRACT(YEAR FROM start_date)= 2020;

-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?/not sure
WITH CTE AS(
			SELECT customer_id, start_date AS join_date
            FROM subscriptions 
            WHERE plan_id in (0,1,2)),
	CTE2 AS(
		    SELECT customer_id, start_date AS plan_date
            FROM subscriptions 
            WHERE plan_id = 3)
SELECT ROUND(AVG(datediff(c2.plan_date,c1.join_date)),0) AS Average_days
FROM CTE c1
INNER JOIN CTE2 c2
ON c1.customer_id = c2.customer_id;

-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH CTE AS (
			 SELECT customer_id,start_date,plan_id,LAG(plan_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS basic_monthly
             FROM subscriptions)
SELECT COUNT(customer_id) 
FROM CTE
WHERE basic_monthly = 2 AND plan_id = 1 AND EXTRACT(YEAR FROM start_date)= 2020;







