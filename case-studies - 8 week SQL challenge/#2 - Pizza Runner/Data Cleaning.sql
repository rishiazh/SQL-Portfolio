use pizza_runner;
select  * from customer_orders;

/*
 Table 1 : customer_orders
	Upon observing the customer_orders table below, we can see that there are :
		Missing values ' ' and null values in the exclusions column.
	    Missing values ' ' and null values in the extras column.
	Result set before removing null values :
		In order to remove these values, we will Create a temporary table with all the columns.
        
	Remove null values in both the exclusions and extras columns and replace them with blank space ' '.
*/

create temporary table temp_customer_order as select
order_id,customer_id,pizza_id,
case
 when exclusions='' or exclusions= 'null' then null
 else exclusions
 end as exclusions,
case  
 when extras='null' or extras='' then null
 else extras
 end as extras,
 order_time from customer_orders;
 
 select * from temp_customer_order;
 
 /*
 Table 2 : runner_orders
	The columns for pickup_time, distance, duration, and cancellation within the runner_orders table require cleaning prior to their utilization in queries.
	The pickup_time column includes missing values.
	Missing values are present in the distance column, which also features the unit "km" that needs to be removed.
	The duration column is not only missing values but also contains the terms "minutes", "mins", and "minute" that should be eliminated.
	Both blank spaces and missing values are found in the cancellation column.
*/
select * from runner_orders;

create temporary table temp_runner_order as select
order_id,runner_id,
case
	when pickup_time = '' or pickup_time = 'null' then null
    else pickup_time
    end as pickup_time,
case 
	when  distance = '' or distance = 'null' then null
    else distance
    end as distance,
case
	when duration = '' or duration = 'null' then null
    else duration 
    end as duration,
case 
	when cancellation = '' or cancellation = 'null' then null
    else cancellation
    end as cancellation from runner_orders;
    
select * from temp_runner_order;    
    