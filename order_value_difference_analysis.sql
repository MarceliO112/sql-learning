-- Order value difference analysis (Northwind database)
--
-- The query calculates:
-- - total value of each order (unit_price * quantity * (1 - discount))
-- - value of the previous order within the same year (LAG)
-- - difference between consecutive orders
-- - yearly aggregation of order value differences (AVG, SUM, COUNT)
--
-- Two approaches are presented:
-- 1) Using CTEs and window functions step by step
-- 2) Alternative simplified aggregation approach
--
-- Author: Marcel
-- Type: analytical SQL query

-- =========================
-- Solution 1: CTE + LAG
-- =========================


with zestawienie_sprzedazy as (
select od.order_id, extract(year from o.order_date) as rok,  SUM(od.quantity * od.unit_price * (1- od.discount)) as suma_zamowienia
from order_details od 
join(select o.order_id , o.order_date  from orders o ) as o on od.order_id = o.order_id 
group by od.order_id, extract(year from o.order_date)
order by od.order_id



),
baza as (

select  zs.order_id, rok, 
zs.suma_zamowienia, 
lag(zs.suma_zamowienia, 1) over (partition by zs.rok order by zs.order_id) as kwota_poprzedniego_zamowienia,
(zs.suma_zamowienia - lag(zs.suma_zamowienia, 1) over (partition by zs.rok order by zs.order_id)) as roznica
from zestawienie_sprzedazy zs
)

select * from baza





  -- =========================
-- Solution 2: Alternative approach
-- =========================




with zestawienie_sprzedazy as (
select od.order_id, extract(year from o.order_date) as rok,  SUM(od.quantity * od.unit_price * (1- od.discount)) as suma_zamowienia
from order_details od 
join(select o.order_id , o.order_date  from orders o ) as o on od.order_id = o.order_id 
group by od.order_id, extract(year from o.order_date)
order by od.order_id



),
baza as (

select  zs.order_id, rok, 
zs.suma_zamowienia, 
lag(zs.suma_zamowienia, 1) over (partition by zs.rok order by zs.order_id) as kwota_poprzedniego_zamowienia,
(zs.suma_zamowienia - lag(zs.suma_zamowienia, 1) over (partition by zs.rok order by zs.order_id)) as roznica
from zestawienie_sprzedazy zs
)



select  rok, AVG(roznica) as srednia_roznica, SUM(roznica) as suma_roznicy, count(roznica) as ilosc_roznicy_w_1996
from baza
group by rok
