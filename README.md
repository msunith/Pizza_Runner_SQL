# Pizza_Runner_SQL
- Case study solutions for Pizza Runner #8weeksqlchallenge

## Problem statement

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

All datasets exist within the pizza_runner database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.
## Entity Relationship Diagram

<img src="https://github.com/msunith/Pizza_Runner_SQL/blob/main/PIzza_Runner/ERD.png" width ="500" height="50%"/>


## A. Pizza Metrics
1.How many pizzas were ordered?

```sql
SELECT COUNT(pizza_id) AS Total_Pizza_Count
FROM pizza_runner.customer_orders_new;
```

<table>
    <tr>
        <th>Total_Pizza_Count</th>
    </tr>
    <tr>
        <td>14</td>
      </tr>
  </table>

2.How many unique customer orders were made?
```sql
SELECT COUNT(DISTINCT order_id) AS Unique_Customer_Orders
FROM pizza_runner.customer_orders_new;
```
<table>
    <tr>
        <th>Unique_Customer_Orders</th>
    </tr>
    <tr>
        <td>10</td>
      </tr>
  </table>

3.How many successful orders were delivered by each runner?
```sql
SELECT runner_id,
		COUNT(*) AS delivered_orders 
FROM pizza_runner.runner_orders_new
WHERE distance is not null
GROUP BY runner_id;
```
<table>
    <tr>
        <th>runner_id</th>
        <th>delivered_orders</th>
    </tr>
    <tr>
        <td>1</td>
        <td>4</td>
    </tr>
    <tr>
        <td>2</td>
        <td>3</td>
    </tr>
  <tr>
        <td>3</td>
        <td>1</td>
    </tr>
</table>

4. How many of each type of pizza was delivered?
```sql
SELECT pizza_id,pizza_name,
		count(pizza_id) AS pizza_count
FROM pizza_runner.customer_orders_new 
INNER JOIN pizza_runner.runner_orders_new USING (order_id)
INNER JOIN pizza_runner.pizza_names USING (pizza_id)
WHERE distance IS NOT NULL
GROUP BY pizza_id;
```
<table>
    <tr>
        <th>pizza_id</th>
        <th>pizza_name</th>
        <th>pizza_count</th>
    </tr>
    <tr>
        <td>1</td>
        <td>Meatlovers</td>
        <td>9</td>
    </tr>
    <tr>
        <td>2</td>
        <td>Vegetarian</td>
        <td>3</td>
    </tr>
</table>

5.How many Vegetarian and Meatlovers were ordered by each customer?
```sql
SELECT customer_id,pizza_name,
		count(pizza_id) AS pizza_count
FROM pizza_runner.customer_orders_new 
INNER JOIN pizza_runner.runner_orders USING (order_id)
INNER JOIN pizza_runner.pizza_names USING (pizza_id)
GROUP BY customer_id,pizza_id 
ORDER BY customer_id;
```
<table>
    <tr>
        <th>customer_id</th>
        <th>pizza_name</th>
        <th>pizza_count</th>
    </tr>
    <tr>
        <td>101</td>
        <td>Meatlovers</td>
        <td>2</td>
    </tr>
    <tr>
        <td>101</td>
        <td>Vegetarian</td>
        <td>1</td>
    </tr>
    <tr>
        <td>102</td>
        <td>Meatlovers</td>
        <td>2</td>
    </tr>
    <tr>
        <td>102</td>
        <td>Vegetarian</td>
        <td>1</td>
    </tr>
    <tr>
        <td>103</td>
        <td>Meatlovers</td>
        <td>3</td>
    </tr>
    <tr>
        <td>103</td>
        <td>Vegetarian</td>
        <td>1</td>
    </tr>
    <tr>
        <td>104</td>
        <td>Meatlovers</td>
        <td>3</td>
    </tr>
    <tr>
        <td>105</td>
        <td>Vegetarian</td>
        <td>1</td>
    </tr>
</table>

6.What was the maximum number of pizzas delivered in a single order?
```sql
SELECT count(pizza_id) AS max_order_count
FROM pizza_runner.customer_orders_new 
INNER JOIN pizza_runner.runner_orders_new USING (order_id)
WHERE pickup_time IS NOT NULL
GROUP BY order_id 
ORDER BY max_order_count DESC LIMIT 1;
```
<table>
    <tr>
        <th>max_order_count</th>
    </tr>
    <tr>
        <td>3</td>
      </tr>
  </table>

7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
``` sql
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
```
<table>
    <tr>
        <th>customer_id</th>
        <th>changed</th>
        <th>unchanged</th>
    </tr>
    <tr>
        <td>101</td>
        <td>0</td>
        <td>2</td>
    </tr>
    <tr>
        <td>102</td>
        <td>0</td>
        <td>3</td>
    </tr>
    <tr>
        <td>103</td>
        <td>3</td>
        <td>0</td>
    </tr>
    <tr>
        <td>104</td>
        <td>2</td>
        <td>1</td>
    </tr>
    <tr>
        <td>105</td>
        <td>1</td>
        <td>0</td>
    </tr>
</table>

8.How many pizzas were delivered that had both exclusions and extras?
```sql
SELECT 
	COUNT(CASE 
		WHEN exclusions <> '' AND extras <> '' THEN 1
        end) AS 'pizza(with_exclusions_and_extra)'
FROM pizza_runner.customer_orders_new
INNER JOIN pizza_runner.runner_orders_new USING (order_id)
WHERE distance IS NOT NULL;
```
<table>
    <tr>
        <th>pizza(with_exclusions_and_extra)</th>
    </tr>
    <tr>
        <td>1</td>
      </tr>
  </table>

9.What was the total volume of pizzas ordered for each hour of the day?
```sql
SELECT 
	CASE
		WHEN HOUR(order_time) >= 12 AND HOUR(order_time) < 24 THEN concat((HOUR(order_time)-12),' PM')
        ELSE CONCAT(HOUR(order_time) ,' AM')
	END AS 'order_time(hour)',
        count(*) AS total_orders
 FROM pizza_runner.customer_orders_new
 GROUP BY HOUR(order_time)
 ORDER BY HOUR(order_time);
 ```
<table>
    <tr>
        <th>order_time(hour)</th>
        <th>total_orders</th>
    </tr>
    <tr>
        <td>11 AM</td>
        <td>1</td>
    </tr>
    <tr>
        <td>1 PM</td>
        <td>3</td>
    </tr>
    <tr>
        <td>6 PM</td>
        <td>3</td>
    </tr>
    <tr>
        <td>7 PM</td>
        <td>1</td>
    </tr>
    <tr>
        <td>9 PM</td>
        <td>3</td>
    </tr>
    <tr>
        <td>11 PM</td>
        <td>3</td>
    </tr>
</table>

10.What was the volume of orders for each day of the week?
```SQL
SELECT DAYNAME(order_time) AS order_date,
        count(*) AS total_orders
 FROM pizza_runner.customer_orders_new
 GROUP BY DAYNAME(order_time)
 ORDER BY order_time;
 ```
<table>
    <tr>
        <th>order_date</th>
        <th>total_orders</th>
    </tr>
    <tr>
        <td>Wednesday</td>
        <td>5</td>
    </tr>
    <tr>
        <td>Thursday</td>
        <td>3</td>
    </tr>
    <tr>
        <td>Saturday</td>
        <td>5</td>
    </tr>
    <tr>
        <td>Friday</td>
        <td>1</td>
    </tr>
</table>

## B. Runner and Customer Experience

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```sql
SELECT 
    FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) + 1 AS week_no,
    COUNT(runner_id) AS runner_count
FROM 
    pizza_runner.runners
GROUP BY 
    week_no
ORDER BY 
    week_no;
```
<table>
    <tr>
        <th>week_no</th>
        <th>runner_count</th>
    </tr>
    <tr>
        <td>1</td>
        <td>2</td>
    </tr>
    <tr>
        <td>2</td>
        <td>1</td>
    </tr>
    <tr>
        <td>3</td>
        <td>1</td>
    </tr>
</table>

2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql
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
```
<table>
    <tr>
        <th>runner_id</th>
        <th>avg_time</th>
    </tr>
    <tr>
        <td>1</td>
        <td>15:40</td>
    </tr>
    <tr>
        <td>2</td>
        <td>23:43</td>
    </tr>
    <tr>
        <td>3</td>
        <td>10:28</td>
    </tr>
</table>

3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
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
```
<table>
    <tr>
        <th>num_pizza</th>
        <th>avg_time</th>
    </tr>
    <tr>
        <td>1</td>
        <td>12:21</td>
    </tr>
    <tr>
        <td>2</td>
        <td>18:22</td>
    </tr>
    <tr>
        <td>3</td>
        <td>29:17</td>
    </tr>
</table>

4. What was the average distance travelled for each customer?
```sql
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
```
<table>
    <tr>
        <th>customer_id</th>
        <th>avg_distance</th>
    </tr>
    <tr>
        <td>101</td>
        <td>20 km</td>
    </tr>
    <tr>
        <td>102</td>
        <td>18 km</td>
    </tr>
    <tr>
        <td>103</td>
        <td>23 km</td>
    </tr>
    <tr>
        <td>104</td>
        <td>10 km</td>
    </tr>
    <tr>
        <td>105</td>
        <td>25 km</td>
    </tr>
</table>

5. What was the difference between the longest and shortest delivery times for all orders?
```sql
SELECT max(duration) - min(duration) as delivery_time_diff
 FROM runner_orders_new;
 ```
 <table>
    <tr>
        <th>delivery_time_diff</th>
    </tr>
    <tr>
        <td>30</td>
    </tr>
</table>

6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
```sql
WITH cte AS(
	SELECT DISTINCT order_id,runner_id,distance,duration,
		round((distance/(duration/60)),2) AS speed
	FROM runner_orders_new
    WHERE distance IS NOT NULL)
SELECT runner_id,order_id,
		speed AS 'Speed(KM per Hour)'
FROM cte 
ORDER BY runner_id,order_id;
```
<table>
    <tr>
        <th>runner_id</th>
        <th>order_id</th>
        <th>Speed(KM per Hour)</th>
    </tr>
    <tr>
        <td>1</td>
        <td>1</td>
        <td>37.50</td>
    </tr>
    <tr>
        <td>1</td>
        <td>2</td>
        <td>44.44</td>
    </tr>
    <tr>
        <td>1</td>
        <td>3</td>
        <td>39.00</td>
    </tr>
    <tr>
        <td>1</td>
        <td>10</td>
        <td>60.00</td>
    </tr>
    <tr>
        <td>2</td>
        <td>4</td>
        <td>34.50</td>
    </tr>
    <tr>
        <td>2</td>
        <td>7</td>
        <td>60.00</td>
    </tr>
    <tr>
        <td>2</td>
        <td>8</td>
        <td>92.00</td>
    </tr>
    <tr>
        <td>3</td>
        <td>5</td>
        <td>40.00</td>
    </tr>
</table>

7. What is the successful delivery percentage for each runner?
```sql
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
```
<table>
    <tr>
        <th>runner_id</th>
        <th>delivery_percentage</th>
    </tr>
    <tr>
        <td>1</td>
        <td>100%</td>
    </tr>
    <tr>
        <td>2</td>
        <td>75%</td>
    </tr>
    <tr>
        <td>3</td>
        <td>50%</td>
    </tr>
</table>

## C. Ingredient Optimisation

1. What are the standard ingredients for each pizza?
```sql
WITH pizza_toppings_name AS  
	(SELECT pizza_id,
	substring_index(substring_index(toppings,',',n),',',-1) AS topping_id
    FROM pizza_recipes JOIN temp ON
    char_length(toppings)-char_length(replace(toppings,',','')) >= n-1)
SELECT pizza_name,
		group_concat(topping_name) AS std_toppings 
FROM pizza_toppings_name 
INNER JOIN pizza_toppings USING (topping_id) 
INNER JOIN pizza_names USING (pizza_id)
GROUP BY pizza_name;  
```
<table>
    <tr>
        <th>pizza_name</th>
        <th>std_toppings</th>
    </tr>
    <tr>
        <td>Meatlovers</td>
        <td>Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
    <tr>
        <td>Vegetarian</td>
        <td>Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce</td>
    </tr>
</table>

2. What was the most commonly added extra?
```sql
WITH extras_list AS  
	(SELECT customer_id,
		substring_index(substring_index(extras,',',n),',',-1) AS topping_id
		FROM customer_orders_new JOIN temp ON
		char_length(extras)-char_length(replace(extras,',','')) >= n-1
	) 
SELECT trim(topping_id) AS topping_id,
	   topping_name,
	   count(*) AS occurance
FROM extras_list 
INNER JOIN pizza_toppings USING (topping_id)
WHERE topping_id !=''
GROUP BY topping_id
ORDER BY topping_id;
```
<table>
    <tr>
        <th>topping_id</th>
        <th>topping_name</th>
        <th>occurance</th>
    </tr>
    <tr>
        <td>1</td>
        <td>Bacon</td>
        <td>4</td>
    </tr>
    <tr>
        <td>4</td>
        <td>Cheese</td>
        <td>1</td>
    </tr>
    <tr>
        <td>5</td>
        <td>Chicken</td>
        <td>1</td>
    </tr>
</table>

3. What was the most common exclusion?
```sql
WITH exclusions_list AS  
	(SELECT customer_id,
		substring_index(substring_index(exclusions,',',n),',',-1) AS topping_id
		FROM customer_orders_new JOIN temp ON
		char_length(exclusions)-char_length(replace(exclusions,',','')) >= n-1
	) 
SELECT trim(topping_id) AS topping_id,
	   topping_name,
	   count(*) AS occurance
FROM exclusions_list 
INNER JOIN pizza_toppings USING (topping_id)
WHERE topping_id !=''
GROUP BY topping_id
ORDER BY topping_id;
```
<table>
    <tr>
        <th>topping_id</th>
        <th>topping_name</th>
        <th>occurance</th>
    </tr>
    <tr>
        <td>2</td>
        <td>BBQ Sauce</td>
        <td>1</td>
    </tr>
    <tr>
        <td>4</td>
        <td>Cheese</td>
        <td>4</td>
    </tr>
    <tr>
        <td>6</td>
        <td>Mushrooms</td>
        <td>1</td>
    </tr>
</table>

4. Generate an order item for each record in the customers_orders table in the format of one of the following:<br>
        Meat Lovers <br>
        Meat Lovers - Exclude Beef <br>
        Meat Lovers - Extra Bacon <br>
        Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
WITH exclusions_list AS (
    SELECT 
        customer_id, 
        order_id, 
        pizza_id, 
        record_id,
        SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n), ',', -1) AS topping_id
    FROM 
        customer_orders_new 
    JOIN 
        temp 
    ON 
        CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= n - 1
),
extras_list AS (
    SELECT 
        customer_id, 
        order_id, 
        pizza_id, 
        record_id,
        SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1) AS topping_id
    FROM 
        customer_orders_new
    JOIN 
        temp 
    ON 
        CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1
),
cte AS (
    SELECT 
        customer_id,
        order_id,
        pizza_name,
        ext.record_id,
        GROUP_CONCAT(DISTINCT pt.topping_name) AS exclude,
        GROUP_CONCAT(DISTINCT pn.topping_name) AS extra
    FROM 
        extras_list ext 
    INNER JOIN 
        exclusions_list excl 
    USING 
        (customer_id, order_id, pizza_id)
    LEFT JOIN 
        pizza_names p 
    ON 
        p.pizza_id = ext.pizza_id
    LEFT JOIN 
        pizza_toppings pt 
    ON 
        pt.topping_id = excl.topping_id
    LEFT JOIN 
        pizza_toppings pn 
    ON 
        pn.topping_id = ext.topping_id
    GROUP BY 
        ext.record_id
)
SELECT 
    customer_id, 
    order_id,
    CASE
        WHEN ISNULL(extra) AND ISNULL(exclude) THEN pizza_name
        WHEN ISNULL(extra) THEN CONCAT(pizza_name, ' - Exclude ', exclude)
        WHEN ISNULL(exclude) THEN CONCAT(pizza_name, ' - Extra ', extra)
        ELSE CONCAT(pizza_name, ' - Exclude ', exclude, ' - Extra ', extra)
    END AS order_details
FROM 
    cte;
```
<table>
    <tr>
        <th>customer_id</th>
        <th>order_id</th>
        <th>order_details</th>
    </tr>
    <tr>
        <td>101</td>
        <td>1</td>
        <td>Meatlovers</td>
    </tr>
   <tr>
        <td>101</td>
        <td>2</td>
        <td>Meatlovers</td>
    </tr>
    <tr>
        <td>102</td>
        <td>3</td>
        <td>Meatlovers</td>
    </tr>
    <tr>
        <td>102</td>
        <td>3</td>
        <td>Vegetarian</td>
    </tr>
    <tr>
        <td>103</td>
        <td>4</td>
        <td>Meatlovers - Exclude Cheese</td>
    </tr>
    <tr>
        <td>103</td>
        <td>4</td>
        <td>Meatlovers - Exclude Cheese</td>
    </tr>
    <tr>
        <td>103</td>
        <td>4</td>
        <td>Vegetarian - Exclude Cheese</td>
    </tr>
    <tr>
        <td>104</td>
        <td>5</td>
        <td>Meatlovers - Extra Bacon</td>
    </tr>
    <tr>
        <td>101</td>
        <td>6</td>
        <td>Vegetarian</td>
    </tr>
     <tr>
        <td>105</td>
        <td>7</td>
        <td>Vegetarian- Extra Bacon</td>
    </tr>
    <tr>
        <td>102</td>
        <td>8</td>
        <td>Meatlovers</td>
    </tr>
    <tr>
        <td>103</td>
        <td>9</td>
        <td>Meatlovers - Exclude Cheese - Extra Bacon,Chicken</td>
    </tr>
    <tr>
        <td>104</td>
        <td>10</td>
        <td>Meatlovers - Exclude BBQ Sauce,Mushrooms</td>
    </tr>
    <tr>
        <td>104</td>
        <td>10</td>
        <td>Meatlovers - Exclude BBQ Sauce,Mushrooms - Extra Bacon,Cheese</td>
    </tr>
</table>

5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients<br>
        For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

```sql
with extras_list AS (
    SELECT 
        record_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1)) AS ext_top_id
    FROM customer_orders_new
    JOIN temp 
        ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1
),
cust_list AS (
    SELECT 
        pizza_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', n), ',', -1)) AS topping_id
    FROM pizza_recipes
    JOIN temp 
        ON CHAR_LENGTH(toppings) - CHAR_LENGTH(REPLACE(toppings, ',', '')) >= n - 1
)
SELECT 
    co.customer_id,
    co.order_id,
    concat(p.pizza_name,' - ',
		GROUP_CONCAT(
        CASE
            WHEN e.ext_top_id = cl.topping_id THEN CONCAT('2x', pt.topping_name)
            ELSE pt.topping_name
        END
    )) AS pizza_toppings
FROM cust_list cl
LEFT JOIN customer_orders_new co 
    ON co.pizza_id = cl.pizza_id
LEFT JOIN extras_list e 
    ON co.record_id = e.record_id AND cl.topping_id = e.ext_top_id
INNER JOIN pizza_toppings pt 
    ON cl.topping_id = pt.topping_id
INNER JOIN pizza_names p 
    ON p.pizza_id = cl.pizza_id
GROUP BY co.record_id;
```
<table>
    <tr>
        <th>customer_id</th>
        <th>order_id</th>
        <th>pizza_toppings</th>
    </tr>
    <tr>
        <td>101</td>
        <td>1</td>
        <td>Meatlovers - Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
    <tr>
        <td>101</td>
        <td>2</td>
        <td>Meatlovers - Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
    <tr>
        <td>102</td>
        <td>3</td>
        <td>Meatlovers - Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
    <tr>
        <td>102</td>
        <td>3</td>
        <td>	Vegetarian - Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce</td>
    </tr>
    <tr>
        <td>103</td>
        <td>4</td>
        <td>Meatlovers - Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
    <tr>
        <td>103</td>
        <td>4</td>
        <td>Meatlovers - Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
    <tr>
        <td>103</td>
        <td>4</td>
        <td>Vegetarian - Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce</td>
    </tr>
    <tr>
        <td>104</td>
        <td>5</td>
        <td>Meatlovers - 2xBacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
    <tr>
        <td>101</td>
        <td>6</td>
        <td>Vegetarian - Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce</td>
    </tr>
    <tr>
        <td>105</td>
        <td>7</td>
        <td>Vegetarian - Cheese,Mushrooms,Onions,Peppers,Tomatoes,Tomato Sauce</td>
    </tr>
    <tr>
        <td>102</td>
        <td>8</td>
        <td>Meatlovers - Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
        <td>103</td>
        <td>9</td>
        <td>Meatlovers - 2xBacon,BBQ Sauce,Beef,Cheese,2xChicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
    <tr>
        <td>104</td>
        <td>10</td>
        <td>Meatlovers - Bacon,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
    <tr>
        <td>104</td>
        <td>10</td>
        <td>Meatlovers - 2xBacon,BBQ Sauce,Beef,2xCheese,Chicken,Mushrooms,Pepperoni,Salami</td>
    </tr>
</table>

6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
```sql
WITH pizza_topping AS (
    SELECT 
        pizza_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', n), ',', -1)) AS topping_id
    FROM pizza_recipes
    JOIN temp 
        ON CHAR_LENGTH(toppings) - CHAR_LENGTH(REPLACE(toppings, ',', '')) >= n - 1
),
extras_list AS (
    SELECT 
        customer_id, order_id, pizza_id, record_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1)) AS topping_id
    FROM customer_orders_new
    JOIN temp 
        ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1
        where order_id not in 
        (select order_id from runner_orders_new where distance is null)
),
exclusions_list AS (
    SELECT 
        customer_id, order_id, pizza_id, record_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n), ',', -1)) AS topping_id
    FROM customer_orders_new
    JOIN temp 
        ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= n - 1
		where order_id not in 
        (select order_id from runner_orders_new where distance is null)
),
cte AS (
    SELECT 
        ptop.topping_id,
        ptop.topping_name,
        COUNT(pt.topping_id) AS frequently_used
    FROM pizza_topping pt
    INNER JOIN customer_orders_new cor ON pt.pizza_id = cor.pizza_id
    INNER JOIN pizza_toppings ptop ON pt.topping_id = ptop.topping_id
    where cor.order_id not in 
        (select order_id from runner_orders_new where distance is null)
    GROUP BY pt.topping_id, ptop.topping_name
)
SELECT 
    c.topping_id,
    c.topping_name,
    c.frequently_used
    + COALESCE(SUM(CASE WHEN e.topping_id = c.topping_id THEN 1 ELSE 0 END), 0)
    - COALESCE(SUM(CASE WHEN exc.topping_id = c.topping_id THEN 1 ELSE 0 END), 0) AS used_frequency
FROM cte c
LEFT JOIN extras_list e ON c.topping_id = e.topping_id
LEFT JOIN exclusions_list exc ON c.topping_id = exc.topping_id
GROUP BY c.topping_id
ORDER BY used_frequency desc;
```
<table>
    <tr>
        <th>topping_id</th>
        <th>topping_name</th>
        <th>used_frequency</th>
    </tr>
    <tr>
        <td>1</td>
        <td>Bacon</td>
        <td>12</td>
    </tr>
    <tr>
        <td>4</td>
        <td>Cheese</td>
        <td>12</td>
    </tr>
    <tr>
        <td>6</td>
        <td>Mushrooms</td>
        <td>11</td>
    </tr>
    <tr>
        <td>3</td>
        <td>Beef</td>
        <td>9</td>
    </tr>
    <tr>
        <td>5</td>
        <td>Chicken</td>
        <td>9</td>
    </tr>
    <tr>
        <td>8</td>
        <td>Pepperoni</td>
        <td>9</td>
    </tr>
    <tr>
        <td>10</td>
        <td>Salami</td>
        <td>9</td>
    </tr>
    <tr>
        <td>2</td>
        <td>BBQ Sauce</td>
        <td>8</td>
    </tr>
    <tr>
        <td>7</td>
        <td>Onions</td>
        <td>3</td>
    </tr>
    <tr>
        <td>9</td>
        <td>Peppers</td>
        <td>3</td>
    </tr>
    <tr>
        <td>11</td>
        <td>Tomatoes</td>
        <td>3</td>
    </tr>
    <tr>
        <td>12</td>
        <td>Tomato Sauce</td>
        <td>3</td>
    </tr>
</table>

## D. Pricing and Ratings

1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
select sum(
		case 
			when pizza_name = 'Vegetarian' then 10
            else 12
        end) as revenue
from pizza_runner.customer_orders_new 
inner join pizza_names using (pizza_id)
inner join runner_orders_new using (order_id)
where distance is not null;
```
<table>
    <tr>
        <th>Revenue</th>
    </tr>
    <tr>
        <td>138</td>
    </tr>
</table>

2. What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra
```sql
with extras_list AS (
    SELECT 
        customer_id, 
        order_id, 
        pizza_id, 
        record_id,
        SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1) AS topping_id
    FROM 
        customer_orders_new 
    JOIN 
        temp 
    ON 
        CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1
),
extra_cost as
	(select count(topping_id) as extra_money from extras_list where 
topping_id),
pizza_cost as
	(select sum(
		case 
			when pizza_name = 'Vegetarian' then 10
            else 12
        end) as revenue
from pizza_runner.customer_orders_new 
inner join pizza_names using (pizza_id)
inner join runner_orders_new using (order_id)
where distance is not null)
select (extra_money+revenue) as total_revenue from extra_cost
cross join pizza_cost; 
```
<table>
    <tr>
        <th>total_revenue</th>
    </tr>
    <tr>
        <td>144</td>
    </tr>
</table>

3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
drop table if exists ratings;
create table ratings 
	(order_id integer,
    rating integer);
insert into ratings(order_id,rating) values
	(1,4),
    (2,4),
    (3,2),
    (4,5),
    (5,3),
    (7,4),
    (8,3),
    (10,3);
select * from ratings;
```
<table>
    <tr>
        <th>order_id</th>
        <th>rating</th>
    </tr>
    <tr>
        <td>1</td><td>4</td>
    </tr>
    <tr>
        <td>2</td><td>4</td>
    </tr>
    <tr>
        <td>3</td><td>2</td>
    </tr>
    <tr>
        <td>4</td><td>5</td>
    </tr>
    <tr>
        <td>5</td><td>3</td>
    </tr>
    <tr>
        <td>7</td><td>4</td>
    </tr>
    <tr>
        <td>8</td><td>3</td>
    </tr>
    <tr>
        <td>10</td><td>3</td>
    </tr>
</table>


4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
    customer_id, order_id, runner_id, rating, order_time,pickup_time, Time between order and pickup, Delivery duration,Average speed, Total number of pizzas
```sql
select customer_id,
        order_id,
        runner_id,
        rating,
        order_time,
        pickup_time,
        trim('00:' from timediff(pickup_time,order_time)) as time_diff,
        duration,
        round((distance/(duration/60)),2) as 'Speed(km/h)',
        count(pizza_id) as num_pizza
from customer_orders_new 
left join runner_orders_new using (order_id)
left join ratings using (order_id)
group by order_id
order by customer_id;
```
<table>
    <tr>
        <th>customer_id</th>
        <th>order_id</th>
        <th>runner_id</th>
        <th>rating</th>
        <th>order_time</th>
        <th>pickup_time</th>
        <th>time_diff</th>
        <th>duration</th>
        <th>Speed(km/h)</th>
        <th>num_pizza</th>
    </tr>
    <tr>
        <td>101</td><td>1</td><td>1</td><td>4</td><td>2020-01-01 18:05:02</td><td>2020-01-01 18:15:34</td><td>10:32</td><td>	32</td><td>37.50</td><td>1</td>
    </tr>
    <tr>
        <td>101</td><td>2</td><td>1</td><td>4</td><td>2020-01-01 19:00:52</td><td>2020-01-01 19:10:54</td><td>10:02</td><td>27</td><td>44.44</td><td>1</td>
    </tr>
    <tr>
        <td>101</td><td>6</td><td>3</td><td>NULL</td><td>2020-01-08 21:03:13</td><td>NULL</td><td>NULL</td><td>NULL</td><td>NULL</td><td>1</td>
    </tr>
    <tr>
        <td>102</td><td>3</td><td>1</td><td>2</td><td>2020-01-02 23:51:23</td>
        <td>2020-01-03 00:12:37</td>
        <td>21:14</td>
        <td>20</td>
        <td>39.00</td>
        <td>2</td>
    </tr>
    <tr>
        <td>102</td>
        <td>8</td>
        <td>2</td>
        <td>3</td>
        <td>2020-01-09 23:54:33</td>
        <td>2020-01-10 00:15:02</td>
        <td>20:29</td>
        <td>15</td>
        <td>92.00</td>
        <td>1</td>
    </tr>
    <tr>
        <td>103</td>
        <td>4</td>
        <td>2</td>
        <td>5</td>
        <td>2020-01-04 13:23:46</td>
        <td>2020-01-04 13:53:03</td>
        <td>29:17</td>
        <td>40</td>
        <td>34.50</td>
        <td>3</td>
    </tr>
    <tr>
        <td>103</td>
        <td>9</td>
        <td>2</td>
        <td>NULL</td>
        <td>2020-01-10 11:22:59</td>
        <td>NULL</td>
        <td>NULL</td>
        <td>NULL</td>
        <td>NULL</td>
        <td>1</td>
    </tr>
    <tr>
        <td>104</td>
        <td>5</td>
        <td>3</td>
        <td>3</td>
        <td>2020-01-08 21:00:29</td>
        <td>2020-01-08 21:10:57</td>
        <td>10:28</td>
        <td>15</td>
        <td>40.00</td>
        <td>1</td>
    </tr>
    <tr>
        <td>104</td>
        <td>10</td>
        <td>1</td>
        <td>3</td>
        <td>2020-01-11 18:34:49</td>
        <td>2020-01-11 18:50:20</td>
        <td>15:31</td>
        <td>10</td>
        <td>60.00</td>
        <td>2</td>
    </tr>
    <tr>
        <td>105</td>
        <td>7</td>
        <td>2</td>
        <td>4</td>
        <td>2020-01-08 21:20:29</td>
        <td>2020-01-08 21:30:45</td>
        <td>10:16</td>
        <td>25</td>
        <td>60.00</td>
        <td>1</td>
    </tr>

5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices 
with no cost for extras and each runner is paid $0.30 per kilometre 
traveled - how much money does Pizza Runner have left over after 
these deliveries?

```sql
with cte_revenue as
	(select sum(case 
			when pizza_name = 'Vegetarian' then 10
            else 12
        end) as Revenue
	from pizza_runner.customer_orders_new 
	inner join pizza_names using (pizza_id)
    inner join runner_orders_new using (order_id)
	where distance is not null),
	cte_pay as
    (select sum(distance) as Total_distance,
        sum(distance)*0.30 as Expense
	from runner_orders_new 
	where distance is not null)
select Revenue,
	   Expense,
       (revenue-expense) as Profit 
from cte_revenue cross join cte_pay;
```
<table>
    <tr>
        <th>Revenue</th>
        <th>Expense</th>
        <th>Profit</th>
    </tr>
    <tr>
        <td>138</td>
        <td>43.20</td>
        <td>94.80</td>
    </tr>
</table>

## E. Bonus Questions

If Danny wants to expand his range of pizzas - how would this impact the existing data design?
Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

```sql
create table pizza_names_new as
 (select * from pizza_names);

create table pizza_recipes_new as
 (select * from pizza_recipes);
 
insert into pizza_names_new values(3,'Supreme Pizza');

insert into pizza_recipes_new values (3,'1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

select * from pizza_names_new;
select * from pizza_recipes_new;

```
<table>
    <tr>
        <th>pizza_id</th>
        <th>pizza_name</th>
    </tr>
    <tr>
        <td>1</td>
        <td>Meatlovers</td>
    </tr>
    <tr>
        <td>2</td>
        <td>Vegetarian</td>
    </tr>
    <tr>
        <td>3</td>
        <td>Supreme Pizza</td>
    </tr>
</table>

<table>
    <tr>
        <th>pizza_id</th>
        <th>toppings</th>
    </tr>
    <tr>
        <td>1</td>
        <td>1, 2, 3, 4, 5, 6, 8, 10</td>
    </tr>
    <tr>
        <td>2</td>
        <td>4, 6, 7, 9, 11, 12</td>
    </tr>
    <tr>
        <td>3</td>
        <td>1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12</td>
    </tr>
</table>
