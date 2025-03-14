{{ config(materialized="table") }}

with
    result as (
        select *, concat(year_number, '-', month_of_year) as year_month_number
        from {{ ref("date") }}
    )

select *
from result
