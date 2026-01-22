{{ config(materialized="incremental", unique_key="booking_id") }}

select
    booking_id,
    listing_id,
    booking_date,
    nights_booked,
    booking_amount,
    -- using macro to multiply two numbers and round the result to the specified
    -- precision
    {{ multiply("nights_booked", "booking_amount", 2) }} as total_amount,
    service_fee,
    cleaning_fee,
    -- using macro to convert to uppercase
    {{ upper_case("booking_status") }} as booking_status,
    created_at
from {{ ref("bronze_bookings") }}
