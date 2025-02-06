-- macros/validate_taiwan_date.sql
{% macro validate_taiwan_date(column) %}
    (
        {{ convert_taiwan_date(column) }} is not null
        and {{ convert_taiwan_date(column) }} < current_date()
    )
{% endmacro %}
