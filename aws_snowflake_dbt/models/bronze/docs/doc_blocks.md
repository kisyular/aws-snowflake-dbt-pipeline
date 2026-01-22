{% docs table_bronze_bookings %}
Incremental model for Bookings data from staging. Captures new records based on created_at timestamp.
{% enddocs %}

{% docs table_bronze_hosts %}
Incremental model for Hosts data from staging. Captures new records based on created_at timestamp.
{% enddocs %}

{% docs table_bronze_listings %}
Incremental model for Listings data from staging. Captures new records based on created_at timestamp.
{% enddocs %}

{% docs host_id %}
Unique identifier for the Airbnb host.
{% enddocs %}

{% docs host_name %}
Name of the Airbnb host.
{% enddocs %}

{% docs host_since %}
Date when the host joined Airbnb.
{% enddocs %}

{% docs is_superhost %}
Boolean flag indicating if the host is a Superhost.
{% enddocs %}

{% docs response_rate %}
The host's response rate to inquiries.
{% enddocs %}

{% docs property_type %}
Type of the property (e.g., Apartment, House).
{% enddocs %}

{% docs room_type %}
Type of room (e.g., Entire place, Private room).
{% enddocs %}

{% docs city %}
City where the listing is located.
{% enddocs %}

{% docs country %}
Country where the listing is located.
{% enddocs %}

{% docs accommodates %}
Maximum number of guests the listing can accommodate.
{% enddocs %}

{% docs bedrooms %}
Number of bedrooms in the listing.
{% enddocs %}

{% docs bathrooms %}
Number of bathrooms in the listing.
{% enddocs %}

{% docs price_per_night %}
Price per night for the listing.
{% enddocs %}
