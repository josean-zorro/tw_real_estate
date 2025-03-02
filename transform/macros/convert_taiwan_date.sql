{% macro convert_taiwan_date(column) %}
    {# First, clean the input by removing leading zeros, occurrences of ".0", and whitespace #}
    {% set cleaned = "REGEXP_REPLACE(" ~ column ~ ", r'(^0+)|(\.0)|(\s+)|(-)', '')" %}

    {# Now, adjust the cleaned value based on its content #}
    {% set final_val = (
        "     CASE       WHEN LENGTH("
        ~ cleaned
        ~ ") <= 3 THEN CONCAT("
        ~ cleaned
        ~ ", '0101')       WHEN RIGHT("
        ~ cleaned
        ~ ", 4) = '0000' THEN CONCAT(SUBSTR("
        ~ cleaned
        ~ ", 1, LENGTH("
        ~ cleaned
        ~ ") - 4), '0101') WHEN RIGHT("
        ~ cleaned
        ~ ", 2) = '00' THEN CONCAT(SUBSTR("
        ~ cleaned
        ~ ", 1, LENGTH("
        ~ cleaned
        ~ ") - 2), '01')  WHEN Length("
        ~ cleaned
        ~ ") in (4,5) then concat("
        ~ cleaned
        ~ ",'01')     ELSE "
        ~ cleaned
        ~ "     END   "
    ) %}

    safe.parse_date(
        '%Y%m%d', safe_cast(19110000 + safe_cast({{ final_val }} as int64) as string)
    )
{% endmacro %}
