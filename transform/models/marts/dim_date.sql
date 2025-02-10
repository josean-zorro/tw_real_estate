{{ config(materialized="table") }}

{{ config(materialized="table") }}

{% set current_date_sql %}
    SELECT date_add(CURRENT_DATE("Asia/Taipei"), interval 1 day) AS today_date
{% endset %}

{% if execute %}
    {% set results = run_query(current_date_sql) %}
    {% set today_date = results.columns[0].values()[0] %}
{% else %}
    {# Fallback value during compile time #}
    {% set today_date = "2020-01-01" %}
{% endif %}

{{ dbt_date.get_date_dimension("1911-01-01", today_date) }}
