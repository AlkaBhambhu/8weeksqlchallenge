USE data_mart;

-- Data Cleaning
ALTER TABLE weekly_sales
MODIFY COLUMN week_date varchar(10); -- data too long for column

UPDATE weekly_sales 
SET week_date = str_to_date(week_date, '%d/%m/%Y'); -- updated data type for week_date

ALTER TABLE weekly_sales
ADD week_number varchar(2)
   AFTER week_date,
ADD month_number varchar(2)
   AFTER week_number,
ADD year_number varchar(4)
   AFTER month_number;

UPDATE weekly_sales
SET week_number = WEEK(week_date),
    month_number = MONTH(week_date),
    year_number = YEAR(week_date);

ALTER TABLE weekly_sales
ADD age_band varchar(15)
   AFTER segment,
ADD demographic varchar(10)
    AFTER age_band ;

UPDATE weekly_sales 
SET age_band = (
			CASE WHEN segment LIKE '_1' THEN 'Young Adults'
                 WHEN segment LIKE '_2' THEN 'Middle Aged'
                 WHEN segment LIKE '_3' OR segment LIKE '_4' THEN 'Retirees'
			END),
	demographic = (
			 CASE WHEN segment LIKE 'C_' THEN 'Couples'
                  WHEN segment LIKE 'F_' THEN 'Families'
			 END);
  
ALTER TABLE weekly_sales
MODIFY COLUMN segment varchar(8);

UPDATE weekly_sales
SET segment = 'Unknown',
    age_band = 'Unknown',
    demographic = 'Unknown'
WHERE segment = 'NULL';

ALTER TABLE weekly_sales
ADD avg_transactions float;

UPDATE weekly_sales
SET avg_transactions = ROUND(sales/transactions, 2);




