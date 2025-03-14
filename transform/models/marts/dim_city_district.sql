{{ config(materialized="incremental", unique_key="city_district_surrogate_key") }}

with
    address as (
        select
            city_id,
            city_district_surrogate_key,
            district_township,
            max(_sdc_batched_at) as last_batched_at
        from {{ ref("int_plvr_transaction") }}
        group by all
    ),

    taiwan_city_code as (
        select city_county, city_id
        from {{ ref("taiwan_city_code") }}
        where valid_to = '9999-01-01'
    ),

    result as (
        select taiwan_city_code.city_county, address.*
        from address
        left join taiwan_city_code using (city_id)
        where
            1 = 1
            {% if is_incremental() %}
                and address.last_batched_at
                >= (select max(this.last_batched_at) from {{ this }} as this)
            {% endif %}
    )

select *
from result
