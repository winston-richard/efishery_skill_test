select b.name as customer_name, sum(total_order_quantity) as total_order_quantity
from analytic_scd.fact_order_accumulating a
left join analytic_scd.dim_customer b
	on a.customer_id = b.id

select b.name as customer_name, sum(total_order_usd_amount) as total_order_usd_amount
from analytic_scd.fact_order_accumulating a
left join analytic_scd.dim_customer b
	on a.customer_id = b.id

select b.name as customer_name, count(payment_number) as total_payment
from analytic_scd.fact_order_accumulating a
left join analytic_scd.dim_customer b
	on a.customer_id = b.id

select b.name as customer_name, sum(invoice_to_payment_lag_days) as invoice_to_payment_lag_days
from analytic_scd.fact_order_accumulating a
left join analytic_scd.dim_customer b
	on a.customer_id = b.id