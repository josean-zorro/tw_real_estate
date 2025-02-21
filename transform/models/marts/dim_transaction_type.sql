{{ config(materialized="table") }}

with
    result as (
        select transaction_type from {{ ref("int_plvr_transaction") }} group by 1
    )

select *
from result
