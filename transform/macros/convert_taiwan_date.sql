{% macro convert_taiwan_date(column) %}
    safe.parse_date(
        '%Y%m%d',
        safe_cast(
            19110000
            + safe_cast(regexp_replace({{ column }}, '^0+', '') as int64) as string
        )
    )
{% endmacro %}
