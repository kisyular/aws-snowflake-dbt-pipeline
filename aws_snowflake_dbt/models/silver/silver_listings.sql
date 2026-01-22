{{ config(materialized="incremental", unique_key="listing_id") }}

select
    listing_id,
    host_id,
    property_type,
    {{ trimmer("property_type") }} as property_type_cleaned,
    room_type,
    city,
    country,
    accommodates,
    bedrooms,
    bathrooms,
    price_per_night,
    -- we first cast the price_per_night to int and then use the tag macro to tag it
    {{ tag("cast(price_per_night as int)") }} as price_per_night_tag,
    created_at
from {{ ref("bronze_listings") }}
