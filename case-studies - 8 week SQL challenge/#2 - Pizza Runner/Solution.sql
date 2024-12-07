use  pizza_runner;
 
  select * from customer_orders;
  select * from runner_orders;
  select * from pizza_toppings;
  select * from pizza_recipes;
  select * from pizza_names;
  select * from runners;
  
 -- A. Pizza Metrics

-- 1. How many pizzas were ordered?
SELECT COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT 
    runner_id,
    COUNT(order_id) AS successful_deliveries
FROM runner_orders
WHERE cancellation IS NULL OR cancellation = ''
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT 
    pn.pizza_name,
    COUNT(co.order_id) AS delivered_count
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = ''
GROUP BY pn.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    co.customer_id,
    pn.pizza_name,
    COUNT(co.order_id) AS order_count
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id, pn.pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT 
    MAX(pizza_count) AS max_pizzas_in_single_order
FROM (
    SELECT 
        order_id,
        COUNT(*) AS pizza_count
    FROM customer_orders
    GROUP BY order_id
) subquery;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
    co.customer_id,
    SUM(CASE WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL THEN 1 ELSE 0 END) AS pizzas_with_changes,
    SUM(CASE WHEN co.exclusions IS NULL AND co.extras IS NULL THEN 1 ELSE 0 END) AS pizzas_without_changes
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = ''
GROUP BY co.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
    COUNT(*) AS pizzas_with_both_exclusions_and_extras
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE co.exclusions IS NOT NULL AND co.extras IS NOT NULL
  AND (ro.cancellation IS NULL OR ro.cancellation = '');

-- 9. Total volume of pizzas ordered for each hour of the day.
SELECT 
    HOUR(order_time) AS order_hour,
    COUNT(order_id) AS total_pizzas
FROM customer_orders
GROUP BY HOUR(order_time)
ORDER BY order_hour;

-- 10. Volume of orders for each day of the week.
SELECT 
    DAYOFWEEK(order_time) AS day_of_week,
    COUNT(order_id) AS total_orders
FROM customer_orders
GROUP BY DAYOFWEEK(order_time)
ORDER BY day_of_week;

-- B. Runner and Customer Experience

-- 1. How many runners signed up for each 1-week period?
SELECT 
    CONCAT(YEAR(registration_date), '-W', WEEK(registration_date)) AS week_period,
    COUNT(runner_id) AS total_runners_signed_up
FROM runners
GROUP BY CONCAT(YEAR(registration_date), '-W', WEEK(registration_date));

-- 2. Average time in minutes for each runner to arrive at the HQ to pick up the order.
SELECT 
    runner_id,
    ROUND(AVG(CAST(REPLACE(duration, ' minutes', '') AS DECIMAL)), 2) AS avg_time_minutes
FROM runner_orders
WHERE duration IS NOT NULL
GROUP BY runner_id;

-- 3. Relationship between number of pizzas and preparation time.
SELECT 
    co.order_id,
    COUNT(co.pizza_id) AS total_pizzas,
    ROUND(AVG(CAST(REPLACE(ro.duration, ' minutes', '') AS DECIMAL)), 2) AS avg_preparation_time_minutes
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.duration IS NOT NULL
GROUP BY co.order_id;

-- 4. Average distance traveled for each customer.
SELECT 
    co.customer_id,
    ROUND(AVG(CAST(REPLACE(ro.distance, 'km', '') AS DECIMAL)), 2) AS avg_distance_km
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.distance IS NOT NULL
GROUP BY co.customer_id;

-- 5. Difference between the longest and shortest delivery times for all orders.
SELECT 
    MAX(CAST(REPLACE(duration, ' minutes', '') AS DECIMAL)) - 
    MIN(CAST(REPLACE(duration, ' minutes', '') AS DECIMAL)) AS time_difference_minutes
FROM runner_orders
WHERE duration IS NOT NULL;

-- 6. Average speed for each runner for each delivery.
SELECT 
    runner_id,
    ROUND(AVG(CAST(REPLACE(distance, 'km', '') AS DECIMAL) / 
              CAST(REPLACE(duration, ' minutes', '') AS DECIMAL) * 60), 2) AS avg_speed_kmph
FROM runner_orders
WHERE distance IS NOT NULL AND duration IS NOT NULL
GROUP BY runner_id;

-- 7. Successful delivery percentage for each runner.
SELECT 
    runner_id,
    ROUND((SUM(CASE WHEN cancellation IS NULL OR cancellation = '' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS success_rate_percentage
FROM runner_orders
GROUP BY runner_id;

-- C. Ingredient Optimisation

-- 1. Standard ingredients for each pizza.
SELECT 
    pn.pizza_name,
    pr.toppings AS standard_ingredients
FROM pizza_recipes pr
JOIN pizza_names pn ON pr.pizza_id = pn.pizza_id;

-- 2. Most commonly added extra.
SELECT 
    extra_topping AS most_common_extra,
    COUNT(extra_topping) AS frequency
FROM (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', numbers.n), ',', -1)) AS extra_topping
    FROM customer_orders
    JOIN numbers ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) + 1 >= numbers.n
) subquery
GROUP BY extra_topping
ORDER BY frequency DESC
LIMIT 1;

-- 3. What was the most common exclusion?
SELECT 
    topping_id,
    COUNT(*) AS frequency
FROM (
    SELECT 
        DISTINCT order_id, topping_id
    FROM customer_orders
    CROSS JOIN JSON_TABLE(exclusions, '$[*]' COLUMNS (topping_id INT PATH '$')) AS exclusions_parsed
) parsed_exclusions
GROUP BY topping_id
ORDER BY frequency DESC
LIMIT 1;

-- 4. Generate an order item for each record in the customer_orders table
SELECT 
    co.order_id,
    pn.pizza_name,
    CASE 
        WHEN co.exclusions IS NOT NULL AND co.extras IS NOT NULL THEN 
            CONCAT(pn.pizza_name, ' - Exclude ', co.exclusions, ' - Extra ', co.extras)
        WHEN co.exclusions IS NOT NULL THEN 
            CONCAT(pn.pizza_name, ' - Exclude ', co.exclusions)
        WHEN co.extras IS NOT NULL THEN 
            CONCAT(pn.pizza_name, ' - Extra ', co.extras)
        ELSE pn.pizza_name
    END AS order_description
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;

-- 5. Generate an alphabetically ordered, comma-separated ingredient list for each pizza order
SELECT 
    co.order_id,
    pn.pizza_name,
    GROUP_CONCAT(DISTINCT 
        CASE 
            WHEN FIND_IN_SET(pt.topping_id, pr.toppings) > 0 THEN 
                CONCAT(IF(co.extras LIKE CONCAT('%', pt.topping_id, '%'), '2x', ''), pt.topping_name)
            ELSE NULL
        END
        ORDER BY pt.topping_name ASC
    ) AS ingredient_list
FROM customer_orders co
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY co.order_id, pn.pizza_name;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas?
SELECT 
    pt.topping_name,
    COUNT(pt.topping_id) AS total_quantity
FROM customer_orders co
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = ''
GROUP BY pt.topping_name
ORDER BY total_quantity DESC;

-- D. Pricing and Ratings

-- 1. Total revenue from delivered pizzas (without extras charges)
SELECT 
    SUM(CASE 
        WHEN pn.pizza_name = 'Meatlovers' THEN 12
        WHEN pn.pizza_name = 'Vegetarian' THEN 10
    END) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = '';

-- 2. Total revenue with $1 charge for extras
SELECT 
    SUM(CASE 
        WHEN pn.pizza_name = 'Meatlovers' THEN 12
        WHEN pn.pizza_name = 'Vegetarian' THEN 10
    END) + 
    COUNT(DISTINCT extra_topping_id) AS total_revenue_with_extras
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
LEFT JOIN JSON_TABLE(co.extras, '$[*]' COLUMNS (extra_topping_id INT PATH '$')) AS extras_parsed
WHERE ro.cancellation IS NULL OR ro.cancellation = '';

-- 3. Design a ratings system table
CREATE TABLE ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    runner_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (order_id) REFERENCES runner_orders(order_id),
    FOREIGN KEY (runner_id) REFERENCES runners(runner_id)
);

-- Insert sample ratings
INSERT INTO ratings (order_id, runner_id, rating)
VALUES 
    (1, 1, 5),
    (2, 1, 4),
    (3, 1, 4),
    (4, 2, 3),
    (5, 3, 5),
    (7, 2, 4),
    (8, 2, 3),
    (10, 1, 5);

-- 4. Join all information into a summary table
SELECT 
    co.customer_id,
    ro.order_id,
    ro.runner_id,
    r.rating,
    co.order_time,
    ro.pickup_time,
    TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) AS time_to_pickup_minutes,
    CAST(REPLACE(ro.duration, ' minutes', '') AS DECIMAL) AS delivery_duration_minutes,
    ROUND(CAST(REPLACE(ro.distance, 'km', '') AS DECIMAL) / (CAST(REPLACE(ro.duration, ' minutes', '') AS DECIMAL) / 60), 2) AS avg_speed_kmph,
    COUNT(co.pizza_id) AS total_pizzas
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
LEFT JOIN ratings r ON ro.order_id = r.order_id
GROUP BY co.customer_id, ro.order_id, ro.runner_id, r.rating;

-- 5. Calculate remaining money after paying runners
SELECT 
    SUM(CASE 
        WHEN pn.pizza_name = 'Meatlovers' THEN 12
        WHEN pn.pizza_name = 'Vegetarian' THEN 10
    END) - 
    SUM(CAST(REPLACE(ro.distance, 'km', '') AS DECIMAL) * 0.30) AS remaining_money
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = '';

-- E. Bonus Questions

-- 1. Add a Supreme pizza with all toppings to the menu
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

