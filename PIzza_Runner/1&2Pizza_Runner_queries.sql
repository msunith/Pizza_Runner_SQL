A. Pizza Metrics
#1.How many pizzas were ordered?
#2.How many unique customer orders were made?
#3.How many successful orders were delivered by each runner?
#4.How many of each type of pizza was delivered?
#5.How many Vegetarian and Meatlovers were ordered by each customer?
#6.What was the maximum number of pizzas delivered in a single order?
#7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
#8.How many pizzas were delivered that had both exclusions and extras?
#9.What was the total volume of pizzas ordered for each hour of the day?
#10.What was the volume of orders for each day of the week?

#1.How many pizzas were ordered?
SELECT COUNT(pizza_id) AS Total_Pizza_count
FROM pizza_runner.customer_orders_new;

#2.How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS Unique_customer_orders
FROM pizza_runner.customer_orders_new;

#3.How many successful orders were delivered by 
# each runner?
SELECT runner_id,
		COUNT(*) AS delivered_orders 
FROM pizza_runner.runner_orders_new
WHERE distance is not null
GROUP BY runner_id;

#4.How many of each type of pizza was delivered?
SELECT pizza_id,pizza_name,
		count(pizza_id) AS pizza_count
FROM pizza_runner.customer_orders_new 
INNER JOIN pizza_runner.runner_orders_new USING (order_id)
INNER JOIN pizza_runner.pizza_names USING (pizza_id)
WHERE distance IS NOT NULL
GROUP BY pizza_id ;

#5.How many Vegetarian and Meatlovers 
# were ordered by each customer?
SELECT customer_id,pizza_name,
		count(pizza_id) AS pizza_count
FROM pizza_runner.customer_orders_new 
INNER JOIN pizza_runner.runner_orders USING (order_id)
INNER JOIN pizza_runner.pizza_names USING (pizza_id)
GROUP BY customer_id,pizza_id 
ORDER BY customer_id;

#6.What was the maximum number of pizzas delivered in a 
# single order?
SELECT count(pizza_id) AS max_order_count
FROM pizza_runner.customer_orders_new 
INNER JOIN pizza_runner.runner_orders_new USING (order_id)
WHERE pickup_time IS NOT NULL
GROUP BY order_id 
ORDER BY max_order_count DESC LIMIT 1;

#7.For each customer, how many delivered pizzas had at least 1 change 
# and how many had no changes
SELECT customer_id,
	count(case 
		when exclusions <> '' or extras <> '' then 1
        end) as changed,
	count(case 
		when exclusions = '' and extras = '' then 1
        end) as unchanged
FROM pizza_runner.customer_orders_new
INNER JOIN pizza_runner.runner_orders_new USING (order_id)
WHERE distance IS NOT NULL
GROUP BY customer_id 
ORDER BY customer_id;


#8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
	COUNT(CASE 
		WHEN exclusions <> '' AND extras <> '' THEN 1
        end) AS 'pizza(with_exclusions_and_extra)'
FROM pizza_runner.customer_orders_new
INNER JOIN pizza_runner.runner_orders_new USING (order_id)
WHERE distance IS NOT NULL;

#9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
	CASE
		WHEN HOUR(order_time) >= 12 AND HOUR(order_time) < 24 THEN concat((HOUR(order_time)-12),' PM')
        ELSE CONCAT(HOUR(order_time) ,' AM')
	END AS 'order_time(hour)',
        count(*) AS total_orders
 FROM pizza_runner.customer_orders_new
 GROUP BY HOUR(order_time)
 ORDER BY HOUR(order_time);

select dayname(order_time) from customer_orders_new

 #10. What was the volume of orders for each day of the week?
 SELECT DAYNAME(order_time) AS order_date,
        count(*) AS total_orders
 FROM pizza_runner.customer_orders_new
 GROUP BY DAYNAME(order_time)
 ORDER BY order_time;
 
 #B. Runner and Customer Experience

#1.How many runners signed up for each 1 week period? 
# (i.e. week starts 2021-01-01)
SELECT 
    FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) + 1 AS week_no,
    COUNT(runner_id) AS runner_count
FROM 
    pizza_runner.runners
GROUP BY 
    week_no
ORDER BY 
    week_no;

#2.What was the average time in minutes it took for each runner 
#to arrive at the Pizza Runner HQ to pickup the order?
 WITH cte AS (
    SELECT 
        runner_id,
        order_id,
        TIME_TO_SEC(TIMEDIFF(pickup_time, order_time)) AS time_diff
    FROM 
        pizza_runner.customer_orders_new
    INNER JOIN 
        runner_orders_new USING (order_id)
)
SELECT 
    runner_id,
    LEFT(SUBSTRING_INDEX(SEC_TO_TIME(AVG(time_diff)), ':', -2),5) AS avg_time
FROM 
    cte
GROUP BY 
    runner_id;
 
#3.Is there any relationship between the number of pizzas and 
# how long the order takes to prepare?
WITH cte AS
	(SELECT c.customer_id, 
		c.order_id,
        count(pizza_id) AS num_pizza,
        TIMESTAMPDIFF(SECOND, order_time, pickup_time) AS time_diff     
	FROM pizza_runner.customer_orders_new c
	INNER JOIN runner_orders_new r ON c.order_id =r.order_id
    WHERE distance IS NOT NULL
	GROUP BY order_id)
SELECT num_pizza, 
		time_format(sec_to_time(avg(time_diff)),'%i:%s') AS avg_time
FROM cte
GROUP BY num_pizza
ORDER BY num_pizza;

#4.What was the average distance travelled for each customer?
WITH cte AS
	(SELECT customer_id,order_id,distance
	FROM pizza_runner.customer_orders_new
	INNER JOIN runner_orders_new USING (order_id)
    WHERE distance IS NOT NULL
	GROUP BY order_id
    )
SELECT customer_id,
	concat(round(avg(distance),0), " km") AS avg_distance
FROM cte
GROUP BY customer_id;

#5.What was the difference between the longest and shortest delivery times 
# for all orders?
SELECT max(duration) - min(duration) as delivery_time_diff
 FROM runner_orders_new;
 
#6.What was the average speed for each runner for each delivery and 
# do you notice any trend for these values?
WITH cte AS(
	SELECT DISTINCT order_id,runner_id,distance,duration,
		round((distance/(duration/60)),2) AS speed
	FROM runner_orders_new
    WHERE distance IS NOT NULL)
SELECT runner_id,order_id,
		speed AS 'Speed(KM per Hour)'
FROM cte 
ORDER BY runner_id,order_id;
    
#7.What is the successful delivery percentage for each runner?
WITH cte AS
	(SELECT
		runner_id,
		sum(
		CASE 
			WHEN ISNULL(distance) THEN 0
			ELSE 1
		END
		) AS success_delivery,
		count(runner_id) AS total_delivery
		FROM runner_orders_new
		GROUP BY runner_id)
SELECT runner_id, 
	concat(round((success_delivery/total_delivery)*100), '%') AS delivery_percentage
FROM cte;





