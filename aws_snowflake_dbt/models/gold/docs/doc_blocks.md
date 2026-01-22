{% docs table_obt %}
One Big Table (OBT) - A denormalized fact table combining booking, listing, and host data from the silver layer. This wide table joins silver_bookings with silver_listings and silver_hosts using left joins, providing a single comprehensive dataset for analytics and reporting. Uses dynamic Jinja configuration for flexible column and join management.
{% enddocs %}

{% docs table_ephemeral_bookings %}
Ephemeral model extracting booking-specific columns from the OBT. This model is not materialized in the database but used as a CTE in downstream models. Contains core booking attributes: booking_id, booking_date, booking_status, and created_at.
{% enddocs %}

{% docs table_ephemeral_hosts %}
Ephemeral model extracting host-specific columns from the OBT. This model is not materialized in the database but used as a CTE in downstream models. Contains host attributes: host_id, host_name, host_since, is_superhost, response_rate_quality, and host_created_at.
{% enddocs %}

{% docs table_ephemeral_listings %}
Ephemeral model extracting listing-specific columns from the OBT. This model is not materialized in the database but used as a CTE in downstream models. Contains listing attributes: listing_id, property_type, room_type, city, country, price_per_night_tag, and listing_created_at.
{% enddocs %}

{% docs listing_created_at %}
Timestamp when the listing record was created, aliased from silver_listings.created_at to distinguish from other created_at fields in the OBT.
{% enddocs %}

{% docs host_created_at %}
Timestamp when the host record was created, aliased from silver_hosts.created_at to distinguish from other created_at fields in the OBT.
{% enddocs %}

{% docs table_fact %}
Fact table joining the One Big Table (OBT) with dimension snapshots (dim_listings, dim_hosts). Extracts key metrics and foreign keys for analytics: booking_id, listing_id, host_id, total_amount, service_fee, cleaning_fee, accommodates, bedrooms, bathrooms, price_per_night, and response_rate. Uses dynamic Jinja configuration for flexible column and join management.
{% enddocs %}
