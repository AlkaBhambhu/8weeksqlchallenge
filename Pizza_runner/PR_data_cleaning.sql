USE pizza_runner;

-- Data exploration & cleaning
UPDATE customer_orders 
SET exclusions = null
WHERE exclusions IN ('NULL', '');

UPDATE customer_orders 
SET extras = null
WHERE extras IN ('NULL', '');

UPDATE runner_orders 
SET pickup_time = null
WHERE pickup_time IN ('NULL', '');

UPDATE runner_orders 
SET distance = null
WHERE distance IN ('NULL', '');

UPDATE runner_orders 
SET duration = null
WHERE duration IN ('NULL', '');

UPDATE runner_orders 
SET cancellation = null
WHERE cancellation IN ('NULL', '');

-- converting data type for pickup_time from varchar to timestamp
ALTER TABLE runner_orders
CHANGE COLUMN pickup_time pickup_time DATETIME NULL DEFAULT NULL ;
