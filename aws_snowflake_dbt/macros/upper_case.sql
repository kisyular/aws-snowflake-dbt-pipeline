-- this is a macro that converts a string to uppercase
{% macro upper_case(column_name) %} upper({{ column_name }}) {% endmacro %}
