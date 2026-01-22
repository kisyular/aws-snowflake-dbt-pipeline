/*
-- the below code when compiled will look like this:
SELECT 
    NIGHTS_BOOKED,
    BOOKING_ID,
    BOOKING_AMOUNT
FROM {{ ref('bronze_bookings') }}
*/
{% set cols = ["NIGHTS_BOOKED", "BOOKING_ID", "BOOKING_AMOUNT"] %}

select {% for col in cols %} {{ col }} {% if not loop.last %}, {% endif %} {% endfor %}
from {{ ref("bronze_bookings") }}
