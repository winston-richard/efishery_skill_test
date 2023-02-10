CREATE OR REPLACE TABLE analytic_scd.fact_order_accumulating (
order_date_id int64
, invoice_date_id int64
, payment_date_id int64
, customer_id int64
, order_number STRING
, invoice_number STRING
, payment_number STRING
, total_order_quantity int64
, total_order_usd_amount decimal
, order_to_invoice_lag_days int64
, invoice_to_payment_lag_days int64
)
;

insert into analytic_scd.fact_order_accumulating
(
order_date_id
, invoice_date_id
, payment_date_id
, customer_id
, order_number
, invoice_number
, payment_number
, total_order_quantity
, total_order_usd_amount
, order_to_invoice_lag_days
, invoice_to_payment_lag_days
)
select
cast(format_date("%Y%m%d"), o.date) as int64) as order_date_id,
cast(format_date("%Y%m%d"), i.date) as int64) as invoice_date_id,
cast(format_date("%Y%m%d"), p.date) as int64) as payment_date_id,
o.customer_id,
o.order_number,
i.invoice_number,
p.payment_number,
sum(ol.quantity) as total_order_quantity,
sum(ol.usd_amount) as total_order_usd_amount,
date_diff(i.date, o.date, day) as order_to_invoice_lag_days,
date_diff(p.date, i.date, day) as invoice_to_payment_lag_days
from order_lines ol
left join orders o
	on ol.order_number = o.order_number
left join invoices i
	on o.order_number = i.order_number
left join payments p
	on i.invoice_number = p.invoice_number
group by 1,2,3,4,5,6,7,10,11

CREATE OR REPLACE TABLE analytic_scd.dim_date (
id int64
,DATE DATE
,YEAR INT64
,MONTH INT64
,QUARTER_OF_YEAR INT64
,MONTH_NAME STRING
,DAY_OF_MON INT64
,DAY_OF_WEEK INT64
,WEEK_OF_YEAR INT64
,DAY_OF_YEAR INT64
,IS_WEEKEND BOOL
)
CLUSTER BY MY_DATE,YEAR,MONTH;

SELECT
cast(format_date("%Y%m%d"), MY_DATE) as int64) as id,
,EXTRACT(YEAR FROM MY_DATE) AS YEAR
,EXTRACT(MONTH FROM MY_DATE) AS MONTH
,CEIL(EXTRACT(MONTH FROM MY_DATE) / 3) AS QUARTER_OF_YEAR
,FORMAT_DATETIME("%B", DATETIME(MY_DATE)) as MONTH_NAME
,EXTRACT(DAY FROM MY_DATE) as DAY_OF_MON
,EXTRACT(DAYOFWEEK FROM MY_DATE) as DAY_OF_WEEK
,EXTRACT(WEEK FROM MY_DATE) AS WEEK_OF_YEAR
,EXTRACT(DAYOFYEAR FROM MY_DATE) AS DAY_OF_YEAR
,case when (EXTRACT(DAYOFWEEK FROM MY_DATE) = 1) or (EXTRACT(DAYOFWEEK FROM MY_DATE) = 7) then true else false end as IS_WEEKEND
FROM
(
SELECT DATE_ADD('2023-01-01',INTERVAL param DAY) AS MY_DATE
FROM unnest(GENERATE_ARRAY(0, 10000, 1)) as param
)
;

CREATE OR REPLACE TABLE analytic_scd.dim_customer as (
SELECT
id,
name
FROM CUSTOMERS
)
;

-- for data quality check purpose
select true
from fact_order_accumulating
group by order_number, invoice_number, payment_number
having count(order_number) > 1
;

select true
from orders
group by order_number
having count(order_number) > 1
;

select true
from invoices
group by invoice_number
having count(invoice_number) > 1
;

select true
from payments
group by payment_number
having count(payment_number) > 1
;
