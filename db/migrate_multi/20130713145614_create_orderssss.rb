

payments
account_id integer
amount     decimal
payment_date  date
state
response_code  string
avs_response

allocation
payment_id    integer
order_id      integer
amount        decimal

variants
add cost_price  decimal
permalink  ---> gem

adjustments
order_id       integer
adjustment_type   string
amount  decimal

shipments
order_id
state

stock
add state