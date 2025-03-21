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
        ~ ",'01')  WHEN SAFE_CAST("
        ~ cleaned
        ~ " as int64 ) >= safe_cast(     CONCAT(       CAST(CAST(REGEXP_EXTRACT(_smart_source_file, r'/(\d{4})Q') AS INT64) - 1911 AS STRING),       CASE REGEXP_EXTRACT(_smart_source_file, r'Q(\d)')         WHEN '1' THEN '0331'         WHEN '2' THEN '0630'         WHEN '3' THEN '0930'         WHEN '4' THEN '1231'       END     )      AS int64) then          CONCAT(     CAST(CAST(SUBSTR(transaction_year_month_and_day, 1, 3) AS INT64) - 1 AS STRING),     SUBSTR(transaction_year_month_and_day, 4)     )          ELSE "
        ~ cleaned
        ~ "     END   "
    ) %}

    safe.parse_date(
        '%Y%m%d', safe_cast(19110000 + safe_cast({{ final_val }} as int64) as string)
    )
{% endmacro %}
