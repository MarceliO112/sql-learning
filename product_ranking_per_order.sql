-- Product ranking within orders (Northwind database)
--
-- The query ranks products within each order based on generated revenue.
-- Ranking is calculated using:
--   unit_price * quantity * (1 - discount)
--
-- For each order:
-- - products with the highest revenue receive rank = 1
-- - lower revenue products receive lower ranks
--
-- The query uses window ranking functions to analyze
-- product contribution to total order value.
--
-- Author: Marcel
-- Type: analytical SQL query


with my_rank as (
select
	order_id,
	product_id,
	unit_price * quantity * (1-discount) as wartosc_zamowienia,
	rank() over (partition by order_id order by unit_price * quantity * (1-discount) desc)  as ranking
	from order_details
order by order_id, ranking
)

select * from my_rank
--(Also we can use here " where ranking = 1")
