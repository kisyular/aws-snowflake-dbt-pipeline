-- you can set variables in dbt using set
{% set flag = 1 %}
{% set night_booked_greater_than_10 = 10 %}
{% set night_booked_equal_to_two = 2 %}

-- you can use if else in dbt
{% if flag == 1 %} select * from {{ source("staging", "listings") }}
{% else %} select * from {{ source("staging", "bookings") }}
{% endif %}

-- you can use if else in dbt
select *
from {{ ref("bronze_bookings") }}
-- using the variables defined above
-- because flag is 1, it will use the first condition
-- and it will filter the bookings where night_booked is greater than 10
{% if flag == 1 %} where night_booked > {{ night_booked_greater_than_10 }}
{% else %} where night_booked = {{ night_booked_equal_to_two }}
{% endif %}
