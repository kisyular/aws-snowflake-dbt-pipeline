{{ config(materialized="incremental", unique_key="host_id") }}

select
    host_id,
    replace(host_name, ' ', '_') as host_name,
    host_since,
    is_superhost,
    response_rate,
    case
        when response_rate > 95
        then 'very good'
        when response_rate > 80
        then 'good'
        when response_rate > 60
        then 'fair'
        else 'poor'
    end as response_rate_quality,
    created_at
from {{ ref("bronze_hosts") }}
