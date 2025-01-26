# C. Ingredient Optimisation

#1. What are the standard ingredients for each pizza?

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

#2. What was the most commonly added extra?

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

#3. What was the most common exclusion?
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

#4. Generate an order item for each record in the customers_orders table 
# in the format of one of the following:
        Meat Lovers
        Meat Lovers - Exclude Beef
        Meat Lovers - Extra Bacon
        Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
        
with exclusions_list as  
	(select customer_id, order_id, pizza_id,record_id,
		substring_index(substring_index(exclusions,',',n),',',-1) as topping_id
		from customer_orders_new join temp on
		char_length(exclusions)-char_length(replace(exclusions,',','')) >= n-1
	),
    extras_list as  
	(select customer_id, order_id, pizza_id,record_id,
		substring_index(substring_index(extras,',',n),',',-1) as topping_id
		from customer_orders_new join temp on
		char_length(extras)-char_length(replace(extras,',','')) >= n-1
	),
	cte as
	(select customer_id,
		order_id,
        pizza_name,
        ext.record_id,
        group_concat(distinct pt.topping_name) as exclude,
        group_concat(distinct pn.topping_name) as extra
	from extras_list ext 
	inner join exclusions_list excl using (customer_id,order_id,pizza_id)
	left join pizza_names p on p.pizza_id = ext.pizza_id
	left join pizza_toppings pt on pt.topping_id = excl.topping_id
	left join pizza_toppings pn on pn.topping_id = ext.topping_id
	group by ext.record_id
    )
select customer_id, order_id,
		case
        when isnull(extra) and isnull(exclude) then pizza_name
        when isnull(extra) then concat(pizza_name,' - Exclude ',exclude)
        when isnull(exclude) then concat(pizza_name,' -Extra ',extra)
        else concat(pizza_name,' - Exclude ',exclude,' - Extra ',extra)
        end as order_details
from cte;
        
#5. Generate an alphabetically ordered comma separated ingredient list 
#for each pizza order from the customer_orders table and 
#add a 2x in front of any relevant ingredients
#For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- Step 1: Extract extras for each customer order
with extras_list AS (
    SELECT 
        record_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1)) AS ext_top_id
    FROM customer_orders_new
    JOIN temp 
        ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1
),
-- Step 2: Extract toppings for each pizza recipe
cust_list AS (
    SELECT 
        pizza_id,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', n), ',', -1)) AS topping_id
    FROM pizza_recipes
    JOIN temp 
        ON CHAR_LENGTH(toppings) - CHAR_LENGTH(REPLACE(toppings, ',', '')) >= n - 1
)
-- Step 3: Combine the data and generate the final result
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
 
#6. What is the total quantity of each ingredient used in all delivered 
# pizzas sorted by most frequent first?
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

# D. Pricing and Ratings

#1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and 
# there were no charges for changes - how much money has Pizza Runner 
# made so far if there are no delivery fees?
 select sum(
		case 
			when pizza_name = 'Vegetarian' then 10
            else 12
        end) as revenue
from pizza_runner.customer_orders_new 
inner join pizza_names using (pizza_id)
inner join runner_orders_new using (order_id)
where distance is not null;

#2. What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra
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

#3. The Pizza Runner team now wants to add an additional ratings system
# that allows customers to rate their runner, how would you design an
# additional table for this new dataset -
# generate a schema for this new table and insert your own data for 
# ratings for each successful customer order between 1 to 5.
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

#4. Using your newly generated table - can you join all of the information 
# together to form a table which has the following information for 
# successful deliveries?
        #customer_id, order_id, runner_id, rating, order_time
        #pickup_time, Time between order and pickup, Delivery duration
        #Average speed, Total number of pizzas
      
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

#5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices 
# with no cost for extras and each runner is paid $0.30 per kilometre 
# traveled - how much money does Pizza Runner have left over after 
# these deliveries?
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


