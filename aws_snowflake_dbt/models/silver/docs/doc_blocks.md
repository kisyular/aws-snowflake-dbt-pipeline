{% docs table_silver_bookings %}
Cleaned and enriched booking data from bronze layer. Includes calculated total_amount field and standardized booking_status in uppercase. Uses incremental loading with booking_id as unique key.
{% enddocs %}

{% docs table_silver_hosts %}
Cleaned and enriched host data from bronze layer. Includes standardized host_name (spaces replaced with underscores) and derived response_rate_quality categorization. Uses incremental loading with host_id as unique key.
{% enddocs %}

{% docs table_silver_listings %}
Cleaned and enriched listing data from bronze layer. Includes cleaned property_type (trimmed and uppercased) and price_per_night_tag categorization. Uses incremental loading with listing_id as unique key.
{% enddocs %}

{% docs total_amount %}
Calculated field: nights_booked multiplied by booking_amount, rounded to 2 decimal places. Represents the total booking value before fees.
{% enddocs %}

{% docs response_rate_quality %}
Derived categorization of host response rate:
- 'very good': response_rate > 95
- 'good': response_rate > 80
- 'fair': response_rate > 60
- 'poor': response_rate <= 60
{% enddocs %}

{% docs property_type_cleaned %}
Cleaned property_type field with whitespace trimmed and converted to uppercase for standardization.
{% enddocs %}

{% docs price_per_night_tag %}
Categorization of price_per_night into pricing tiers:
- 'low': price < 100
- 'medium': price >= 100 and < 200
- 'high': price >= 200
{% enddocs %}
