{% set congigs = [
    {
        "table": "airbnb.gold.obt",
        "columns": "obt.booking_id, obt.listing_id, obt.host_id, obt.total_amount, obt.service_fee, obt.cleaning_fee, obt.accommodates, obt.bedrooms, obt.bathrooms, obt.price_per_night, obt.response_rate",
        "alias": "obt",
    },
    {
        "table": "airbnb.gold.dim_listings",
        "columns": "",
        "alias": "dim_listings",
        "join_condition": "obt.listing_id = dim_listings.listing_id",
    },
    {
        "table": "airbnb.gold.dim_hosts",
        "columns": "",
        "alias": "dim_hosts",
        "join_condition": "obt.host_id = dim_hosts.host_id",
    },
] %}


select {{ congigs[0]["columns"] }}

from
{% for config in congigs %}
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
    obt.booking_id, obt.listing_id, obt.host_id, obt.total_amount, obt.service_fee, 
    obt.cleaning_fee, obt.accommodates, obt.bedrooms, obt.bathrooms, 
    obt.price_per_night, obt.response_rate
from
    airbnb.gold.obt as obt
left join
    airbnb.gold.dim_listings as dim_listings
    on obt.listing_id = dim_listings.listing_id
left join
    airbnb.gold.dim_hosts as dim_hosts
    on obt.host_id = dim_hosts.host_id
*/
