{{ config(materialized="incremental", unique_key="layout_id") }}

with
    result as (
        select
            (
                case
                    when building_number_of_bedrooms = 1
                    then '1房'
                    when building_number_of_bedrooms = 2
                    then '2房'
                    when building_number_of_bedrooms = 3
                    then '3房'
                    when building_number_of_bedrooms = 4
                    then '4房'
                    when building_number_of_bedrooms = 5
                    then '5房及以上'
                    else '0房（不適用）'
                end
            ) as number_of_bedrooms_categorized,
            building_number_of_bedrooms,
            building_number_of_living_rooms,
            building_number_of_bathrooms,
            building_number_of_partitions,
            layout_id,
            max(_sdc_batched_at) as last_batched_at
        from {{ ref("int_plvr_transaction") }}
        where
            1 = 1
            {% if is_incremental() %}
                and _sdc_batched_at
                >= (select max(this.last_batched_at) from {{ this }} as this)
            {% endif %}
        group by all
    )

select *
from result
