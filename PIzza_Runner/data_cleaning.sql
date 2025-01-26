# Data Cleaning
# customer_orders
DROP table IF EXISTS customer_orders_new;
CREATE TABLE customer_orders_new AS
	SELECT order_id,
			customer_id,
            pizza_id,
            CASE
				WHEN exclusions IS NULL OR exclusions = 'null' THEN ''
                ELSE exclusions
			END AS exclusions,
            CASE
				WHEN extras IS NULL OR extras = 'null' OR extras ='NaN' THEN ''
                ELSE extras
			END AS extras,
            order_time
FROM customer_orders;

SELECT * FROM customer_orders_new;
DROP TABLE IF EXISTS runner_orders_new;
CREATE TABLE runner_orders_new AS
	select order_id,
			runner_id,
            case 
				when pickup_time ='null' then NULL
                else pickup_time 
			end as pickup_time,
            case 
				when distance ='null' then NULL
                when distance like '%km' then trim('km' from distance)
                else distance 
			end as distance,
            case 
				when duration ='null' then NULL
                when duration like '%mins' then trim('mins' from duration)
                when duration like '%minute' then trim('minute' from duration)
                when duration like '%minutes' then trim('minutes' from duration)
                else duration
			end as duration,
            case 
				when cancellation ='null' or cancellation ='null' or cancellation = 'NaN' then ''
                else cancellation
			end as cancellation
from runner_orders;

ALTER TABLE runner_orders_new MODIFY pickup_time timestamp;
ALTER TABLE runner_orders_new MODIFY distance numeric;
ALTER TABLE runner_orders_new MODIFY duration integer;

-- Add a record_id column to identify records individually
ALTER TABLE customer_orders_new ADD record_id INT PRIMARY KEY AUTO_INCREMENT FIRST;	

#Temporary table
drop table if exists temp;
create table temp as (select 1 as n union select 2 as n union select 3 as n union
	select 4 as n union select 5 as n union select 6 as n union select 7 as n 
    union select 8 as n union select 9 as n union select 10 as n);
