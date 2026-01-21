-- Use the `ref` function to select from other models
select * from {{ ref("snowflake_dbt_model") }} where listing_id = 1
