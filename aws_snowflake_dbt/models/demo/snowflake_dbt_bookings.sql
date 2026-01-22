{{ config(materialized="table") }} select * from {{ source("staging", "bookings") }}
