{% macro validate_taiwan_date(column, earliest_date="2011-07-01", latest_date=None) %}
    {# Set the latest_date expression: use CURRENT_DATE() if latest_date is not provided #}
    {% if latest_date is none %} {% set latest_date_expr = "CURRENT_DATE()" %}
    {% else %} {% set latest_date_expr = "DATE('" ~ latest_date ~ "')" %}
    {% endif %}

    {# If earliest_date is provided, include the lower bound check; otherwise, skip it #}
    {% if earliest_date is none %}
        (
            {{ convert_taiwan_date(column) }} is not null
            and {{ convert_taiwan_date(column) }} <= {{ latest_date_expr }}
        )
    {% else %}
        (
            {{ convert_taiwan_date(column) }} is not null
            and {{ convert_taiwan_date(column) }} >= date('{{ earliest_date }}')
            and {{ convert_taiwan_date(column) }} <= {{ latest_date_expr }}
        )
    {% endif %}
{% endmacro %}
