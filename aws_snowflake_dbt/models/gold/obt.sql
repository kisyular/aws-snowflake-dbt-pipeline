{% set configs = [
    {
        "table": "airbnb.silver.silver_bookings",
        "columns": "silver_bookings.*",
        "alias": "silver_bookings",
    },
    {
        "table": "airbnb.silver.silver_listings",
        "columns": "silver_listings.host_id, silver_listings.property_type, silver_listings.room_type, silver_listings.city, silver_listings.country, silver_listings.accommodates, silver_listings.bedrooms, silver_listings.bathrooms, silver_listings.price_per_night, silver_listings.price_per_night_tag, silver_listings.created_at AS listing_created_at",
        "alias": "silver_listings",
        "join_condition": "silver_bookings.listing_id = silver_listings.listing_id",
    },
    {
        "table": "airbnb.silver.silver_hosts",
        "columns": "silver_hosts.host_name, silver_hosts.host_since, silver_hosts.is_superhost, silver_hosts.response_rate, silver_hosts.response_rate_quality, silver_hosts.created_at AS host_created_at",
        "alias": "silver_hosts",
        "join_condition": "silver_listings.host_id = silver_hosts.host_id",
    },
] %}


select
    {% for config in configs %}
        {{ config["columns"] }}{% if not loop.last %},{% endif %}
    {% endfor %}
from
{% for config in configs %}
        {% if loop.first %} {{ config["table"] }} as {{ config["alias"] }}
    {% else %}
        left join
            {{ config["table"] }} as {{ config["alias"] }}
            on {{ config["join_condition"] }}
    {% endif %}
{% endfor %}

    /*
When the code above is compiled, it will look like this:

select
    silver_bookings.*,
    silver_listings.host_id, silver_listings.property_type, silver_listings.room_type, 
    silver_listings.city, silver_listings.country, silver_listings.accommodates, 
    silver_listings.bedrooms, silver_listings.bathrooms, silver_listings.price_per_night, 
    silver_listings.price_per_night_tag, silver_listings.created_at AS listing_created_at,
    silver_hosts.host_name, silver_hosts.host_since, silver_hosts.is_superhost, 
    silver_hosts.response_rate, silver_hosts.response_rate_quality, 
    silver_hosts.created_at AS host_created_at
from
    airbnb.silver.silver_bookings as silver_bookings
left join
    airbnb.silver.silver_listings as silver_listings
    on silver_bookings.listing_id = silver_listings.listing_id
left join
    airbnb.silver.silver_hosts as silver_hosts
    on silver_listings.host_id = silver_hosts.host_id
*/
