-- Monthly revenue analysis (Northwind database)
--
-- The query calculates monthly metrics:
-- - first and last order date in each month
-- - total monthly revenue (after discounts)
-- - previous month revenue (LAG)
-- - month-over-month revenue difference
--
-- Implemented using CTEs and window functions.
--
-- Author: Marcel
-- Type: analytical SQL query

with raport as (
select to_char(order_date, 'YYYY') as rok ,
to_char(order_date, 'MM') as msc, 
MIN(order_date) over 
(partition by to_char(order_date, 'YYYY'), to_char(order_date, 'MM')) as pierwsze_zamowienie_w_msc,
MAX(order_date) over 
(partition by to_char(order_date, 'YYYY'), to_char(order_date, 'MM')) as ostatnie_zamowienie_w_msc,
SUM((od.unit_price * od.quantity) * (1 - od.discount )) 
over (partition by to_char(order_date,  'YYYY'), to_char(order_date, 'MM')) as przychod_w_miesiacu
from orders o 
join order_details od on o.order_id = od.order_id 
),
miesieczne as( select distinct rok,msc, pierwsze_zamowienie_w_msc, ostatnie_zamowienie_w_msc, przychod_w_miesiacu from raport)
select *, lag(przychod_w_miesiacu) over (order by rok, msc)  as poprzedni_miesiac,
(przychod_w_miesiacu - lag(przychod_w_miesiacu) over (order by rok,msc)) as roznica
from miesieczne
