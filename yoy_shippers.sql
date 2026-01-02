-- Year-over-year analysis of shipping companies performance (Northwind database)
--
-- For each shipping company and year, the query calculates:
-- - number of orders handled (distinct order_id)
-- - number of orders in the previous year
-- - number of product positions to be shipped (product_id per orders)
--   (one order can contain multiple products)
-- - year-over-year (YoY) change in number of shipped products
-- - total quantity of all shipped items
-- - sum of unit prices (without quantity, for price structure insight)
-- - total revenue after discounts:
--   unit_price * quantity * (1 - discount)
--
-- YoY is calculated based on the number of product positions per company
-- compared to the previous year.
--
-- Author: Marcel
-- Type: analytical SQL query



select distinct  
        s.company_name,
        extract(year from o.order_date) as year,
        count(distinct(o.order_id )) as liczba_zamowien,
        lag( count(distinct(o.order_id )), 1) over (partition by s.company_name order by extract(year from o.order_date) ) as poprzednia_wartosc,
        
   /* --- YOY  --- */
        (
            (
                count(distinct(o.order_id))::numeric
                - lag(count(distinct(o.order_id)), 1) over (partition by s.company_name order by extract(year from o.order_date))
            )
            /
            lag(count(distinct(o.order_id)), 1) over (partition by s.company_name order by extract(year from o.order_date))
        ) * 100  as yoy,
        count(od.product_id ) as liczba_produktow,
        lag( count(od.product_id ), 1) over (partition by s.company_name order by extract(year from o.order_date) ) as poprzednia_wartosc_produktow,
        
        /* --- YOY  --- */
        (
            (
                count(od.product_id)::numeric
                - lag(count(od.product_id), 1) over (partition by s.company_name order by extract(year from o.order_date))
            )
            /
            lag(count(od.product_id), 1) over (partition by s.company_name order by extract(year from o.order_date))
        ) * 100  as yoy,

        SUM(od.quantity) as ilosc_wszystkich_egzemplarzy,
        SUM(od.unit_price) as koszt_wszystkich_egzemplarzy,
        round(
            cast(SUM(unit_price*(1-discount) * quantity) as numeric)
        ,2) as suma_wszystkich_zamowien

    from orders o
    join employees e on e.employee_id = o.employee_id
    join shippers s on o.ship_via = s.shipper_id
    join (select order_id, discount , unit_price , quantity , product_id from order_details) as od 
        on o.order_id = od.order_id

    group by 1, 2
    order by year
