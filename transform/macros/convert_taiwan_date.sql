{% macro convert_taiwan_date(column) %}
    safe.parse_date(
        '%Y%m%d',
        safe_cast(
            19110000 + safe_cast(
                regexp_replace({{ column }}, r'(^0+)|(\.0)|(\s+)', '') as int64
            ) as string
        )
    )
{% endmacro %}
