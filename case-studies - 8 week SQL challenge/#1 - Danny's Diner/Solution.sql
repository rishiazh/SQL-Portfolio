 -- Q1. What is the total amount each customer spent at the restaurant?
  
  select a.customer_id,sum(b.price) from sales_food a
  inner join menu b on a.product_id=b.product_id
  group by a.customer_id;
  
select * from sales_food;
select * from menu;
select * from members_food;
-- Q2. How many days has each customer visited the restaurant?
  
  select customer_id,count(order_date) from sales_food
  group by customer_id;

select * from sales_food;
select * from menu;
select * from members_food;

-- Q4. Which item was the most popular for each customer?
select customer_id,product_name,count_,rank_ from (
select a.customer_id,b.product_name,
count(b.product_name) over (partition by a.customer_id ) as count_,
rank() over (partition by a.customer_id order by b.product_name desc) as rank_
from sales_food a
inner join menu b on a.product_id=b.product_id ) as d1
where rank_=1;


-- Q3. What was the first item from the menu purchased by each customer?
with cte as (
select customer_id,product_name,order_date,
rank() over (partition by customer_id order by order_date asc) as s1
from sales_food a
inner join menu b on a.product_id=b.product_id
) 
select customer_id,product_name,order_date,s1 from cte
where s1=1;
  
-- Q4.What is the most purchased item on the menu and how many times was it purchased by all customers?
select * from sales_food;
select * from menu;
select * from members_food;

select b.product_name,count(a.product_id) from sales_food a
inner join menu b on a.product_id=b.product_id
group by b.product_name
order by count(a.product_id) desc;

-- Q5. Which item was purchased first by the customer after they became a member?
with cte as(
select a.customer_id,a.order_date,b.product_name,
rank() over (partition by a.customer_id order by a.order_date asc) as cust_rank
from sales_food a
join menu b on a.product_id=b.product_id
join members_food c on a.customer_id=c.customer_id
where c.join_date<a.order_date )
select  customer_id,order_date,product_name,cust_rank from cte
where cust_rank=1;


/* 

Which item was purchased just before the customer became a member?

What is the total items and amount spent for each member before they became a member?

If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? */
  
  
  