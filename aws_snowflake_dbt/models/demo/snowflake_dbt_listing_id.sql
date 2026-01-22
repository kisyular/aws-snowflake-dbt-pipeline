select * from {{ ref("snowflake_dbt_bookings") }} where listing_id = 1
