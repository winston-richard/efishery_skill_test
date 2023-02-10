CREATE OR REPLACE TABLE analytic_scd.fact_order_accumulating (
order_date_id int64
, invoice_date_id int64
, payment_date_id int64
, customer_id int64
, order_number STRING
, invoice_number STRING
, payment_number STRING
, product_id int64
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
, product_id
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
ol.product_id,
ol.quantity,
ol.usd_amount,
date_diff(i.date, o.date, day) as order_to_invoice_lag_days,
date_diff(p.date, i.date, day) as invoice_to_payment_lag_days
from order_lines ol
left join orders o
	on ol.order_number = o.order_number
left join invoices i
	on o.order_number = i.order_number
left join payments p
	on i.invoice_number = p.invoice_number

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

CREATE OR REPLACE TABLE analytic_scd.dim_product as (
SELECT
id,
name
FROM CUSTOMERS
)
;

/*
query dari soal =
pros
memudahkan kerja tableau / qlikview / visualisation tools lain, karena sudah di agregasi di query

cons
tidak bisa melihat analisa product mana yang paling laris, dikarenakan data di order lines sudah di summary
*/

/*
query dari saya
pros
sudah bisa melihat analisa product mana yang paling laris,
dikarenakan data di order lines sudah di jabarkan secara detail

cons
karena data dijabarkan dalam 1 tabel, maka ada penyesuaian untuk menghitung jumlah barang, uang masuk, invoice terbit, payment terbit, dan lain sebagainya.
hal ini disebabkan karena data yang di hasilkan sudah mendetail.
*/