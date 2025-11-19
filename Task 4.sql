---------------------------------------TASK-----------------------------------------

---Q1. Find the Top 10 customers by total revenue generated.
---
---Return:
---
---customer_id
---
---customer_name
---
---total_revenue
---
---rank




Select 
c.customer_id,
customer_name,
sum(order_amount) as order_amount,
rank() over (order by sum(order_amount) desc) as ranking
from dbo.Customers c
left join dbo.Orders_task4 o on c.customer_id = o.customer_id
where o.order_status = 'delivered'
group by c.customer_id,customer_name


---Q2. Calculate cancellation rate per region.

select
    c.region, 
    sum(case when o.order_status = 'cancelled' then 1 else 0 end) * 100.0 / count(*) as Cancellation_rate
from dbo.Orders_task4 o
left join Customers c
    on o.customer_id = c.customer_id
group by c.region


--Q3. Find the longest streak of continuous daily delivered orders.
--
--(Return start_date, end_date, streak_length)

;WITH delivered AS (
    SELECT 
        order_date
    FROM dbo.Orders_task4
    WHERE order_status = 'delivered'
    GROUP BY order_date
),
flagged AS (
    SELECT 
        order_date,
        CASE 
            WHEN LAG(order_date) OVER (ORDER BY order_date) = DATEADD(day, -1, order_date)
                THEN 0   -- continues previous streak
            ELSE 1       -- new streak starts
        END AS new_group
    FROM delivered
),
groups AS (
    SELECT 
        order_date,
        SUM(new_group) OVER (ORDER BY order_date 
                             ROWS UNBOUNDED PRECEDING) AS grp
    FROM flagged
),
streaks AS (
    SELECT 
        MIN(order_date) AS start_date,
        MAX(order_date) AS end_date,
        COUNT(*) AS streak_length
    FROM groups
    GROUP BY grp
)
SELECT TOP 1 *
FROM streaks
ORDER BY streak_length ASC ;


--Q4. For each product category, compute:
--
--total orders
--
--total revenue
--
--average order value (AOV)
--
--percentage contribution to overall revenue
--

;WITH total AS (
    SELECT 
        SUM(order_amount) AS total_revenue 
    FROM dbo.Orders_task4
    WHERE order_status = 'delivered'
)
SELECT 
    product_id,
    COUNT(*) AS total_orders,
    SUM(order_amount) AS revenue,
    AVG(order_amount) AS avg_order_value,
    SUM(order_amount) * 100.0 / t.total_revenue AS revenue_percentage
FROM dbo.Orders_task4 o
CROSS JOIN total t
WHERE order_status = 'delivered'
GROUP BY product_id, t.total_revenue
ORDER BY revenue_percentage DESC;


--Q5. Which region has the highest average order amount for electronics?
--
--Join Products → Orders → Customers.

select top 1 region,avg(order_amount) from dbo.Orders_task4 o
left join Customers c on o.customer_id =c.customer_id
left join Products p on o.product_id = p.product_id
where category = 'Electronics'
group by region




