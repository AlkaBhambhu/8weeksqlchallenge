-- Data exploration 

-- What day of the week is used for each week_date value?
SELECT DISTINCT week_number, DAYNAME(week_date)
FROM weekly_sales
ORDER BY week_number;

-- What range of week numbers are missing from the dataset?

-- How many total transactions were there for each year in the dataset?
SELECT year_number, COUNT(transactions)
FROM weekly_sales
GROUP BY year_number;

-- What is the total sales for each region for each month?
SELECT region, month_number, SUM(sales)
FROM weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

-- What is the total count of transactions for each platform
SELECT platform, COUNT(transactions)
FROM weekly_sales
GROUP BY platform;

-- What is the percentage of sales for Retail vs Shopify for each month?
SELECT grp.platform, ROUND((grp.group_sales/total.total_sales),2) AS percentage
FROM (
	 SELECT platform, SUM(sales) AS group_sales
     FROM weekly_sales
     GROUP BY platform) AS grp 
LEFT JOIN (
	      SELECT SUM(sales) AS total_sales
          FROM weekly_sales) AS total 
ON 1 = 1;

-- What is the percentage of sales by demographic for each year in the dataset?
WITH CTE AS(
            SELECT year_number, demographic, SUM(sales) AS total_sales
            FROM weekly_sales
            GROUP BY year_number, demographic)
SELECT year_number, demographic, ROUND(total_sales*100/(SELECT SUM(total_sales) FROM CTE),1) AS sales_percentage
FROM CTE;

-- Which age_band and demographic values contribute the most to Retail sales?
SELECT *
FROM (SELECT age_band, SUM(sales) AS age_band_sales
     FROM weekly_sales
     WHERE platform = 'Retail'
     GROUP BY age_band) AS age_band_cont
LEFT JOIN(SELECT demographic, SUM(sales) AS demo_sales
         FROM weekly_sales
         WHERE platform = 'Retail'
         GROUP BY demographic) AS demo_cont
ON 1=1
ORDER BY age_band_sales DESC, demo_sales DESC
LIMIT 1;

-- Find the average transaction size for each year for Retail vs Shopify?
SELECT DISTINCT year_number, platform, ROUND(AVG(transactions) OVER (PARTITION BY year_number, platform),0) AS avg_transaction_size
FROM weekly_sales;


 






