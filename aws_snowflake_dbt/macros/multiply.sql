-- this is a macro that multiplies two numbers and rounds the result to the specified
-- precision
-- for example: multiply(2,3,2) will return 6.00
-- for example: multiply(2,3,0) will return 6
{% macro multiply(x, y, precision) %}
    round({{ x }} * {{ y }},{{ precision }})
{% endmacro %}
