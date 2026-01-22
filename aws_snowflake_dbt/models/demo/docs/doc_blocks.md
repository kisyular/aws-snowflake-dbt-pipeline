{% docs booking_id %}
The unique identifier for each booking. This is the primary key of the table.
{% enddocs %}

{% docs listing_id %}
The unique identifier for the property listing. This acts as a foreign key to the `listings` table.
{% enddocs %}

{% docs booking_date %}
The timestamp when the booking was made. Used for analyzing booking trends and seasonality.
{% enddocs %}

{% docs nights_booked %}
The number of nights for the reservation.
{% enddocs %}

{% docs booking_amount %}
The total amount charged for the booking, including rent and fees.
{% enddocs %}

{% docs cleaning_fee %}
The fee charged for cleaning the property after the stay.
{% enddocs %}

{% docs service_fee %}
The fee charged by the platform for the service.
{% enddocs %}

{% docs booking_status %}
The current status of the booking (e.g., 'confirmed', 'cancelled', 'pending').
{% enddocs %}

{% docs created_at %}
The timestamp when the record was created in the database.
{% enddocs %}

{% docs table_snowflake_dbt_model %}
A model that selects all booking records from the staging area. This serves as a base model for further transformations.
{% enddocs %}

{% docs table_listid_id_is_1 %}
A filtered view of bookings specifically for listing_id = 1. Used for analyzing performance of this specific property.
{% enddocs %}
