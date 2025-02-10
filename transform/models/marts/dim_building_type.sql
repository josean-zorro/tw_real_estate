{{ config(materialized="incremental") }}

with
    result as (
        select
            building_type_id,
            building_type,
            building_type_origin,
            max(_sdc_batched_at) as last_batched_at
        from {{ ref("int_plvr_transaction") }}
        where
            1 = 1
            {% if is_incremental() %}
                and last_batched_at
                >= (select max(this.last_batched_at) from {{ this }} as this)
            {% endif %}
        group by all
    )

select *
from result
