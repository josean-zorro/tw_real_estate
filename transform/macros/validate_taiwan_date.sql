{% import 'convert_taiwan_date.sql' as house_and_renting %}
{% macro validate_taiwan_date(column, earliest_date="1912-01-01", latest_date=None) %}
    {# Set the latest_date expression: use CURRENT_DATE() if latest_date is not provided #}
    {% if latest_date is none %} {% set latest_date_expr = "CURRENT_DATE()" %}
    {% else %} {% set latest_date_expr = "DATE('" ~ latest_date ~ "')" %}
    {% endif %}

    {# If earliest_date is provided, include the lower bound check; otherwise, skip it #}
    {% if earliest_date is none %}
        (
            {{ house_and_renting.convert_taiwan_date(column) }} is not null
            and {{ house_and_renting.convert_taiwan_date(column) }}
            <= {{ latest_date_expr }}
        )
    {% else %}
        (
            {{ house_and_renting.convert_taiwan_date(column) }} is not null
            and {{ house_and_renting.convert_taiwan_date(column) }}
            >= date('{{ earliest_date }}')
            and {{ house_and_renting.convert_taiwan_date(column) }}
            <= {{ latest_date_expr }}
        )
    {% endif %}
{% endmacro %}
