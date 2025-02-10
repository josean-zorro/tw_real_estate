{{
    config(
        materialized="incremental",
        unique_key="transaction_id",
        cluster_by="_sdc_batched_at",
    )
}}

{% if execute and is_incremental() %}
    {% set query = "select max(_sdc_batched_at) from {}".format(this) %}
    {% set result = run_query(query).columns[0].values()[0] %}
{% endif %}

with
    result as (
        select
            city_district_surrogate_key,
            layout_id,
            building_type_id,
            transaction_id,
            transaction_date,
            address_land_slot,
            construction_completion_date,
            land_total_tranferred_area_square_meter,
            building_transferred_area_square_meter,
            parking_transferred_area_square_meter,
            main_building_area_square_meter,
            auxiliary_building_area_square_meter,
            balcony_area_square_meter,
            total_price_ntd,
            price_per_square_meter,
            parking_total_price_ntd,
            {{
                dbt_utils.safe_divide(
                    "(total_price_ntd - parking_total_price_ntd)",
                    "(building_transferred_area_square_meter - parking_transferred_area_square_meter)",
                )
            }}
            as building_price_per_square_meter,

            {{
                dbt_utils.safe_divide(
                    "(total_price_ntd - parking_total_price_ntd)",
                    "(main_building_area_square_meter + auxiliary_building_area_square_meter + balcony_area_square_meter)",
                )
            }}
            as net_private_building_price_per_square_meter,

            {{
                dbt_utils.safe_divide(
                    "(total_price_ntd - parking_total_price_ntd)",
                    "(main_building_area_square_meter)",
                )
            }} as net_exclusive_area_price_per_square_meter,
            _sdc_batched_at
        from {{ ref("int_plvr_transaction") }}
        {%- if is_incremental() %}
            where _sdc_batched_at > (select safe_cast('{{ result }}' as timestamp))
        {% endif %}
    )

select *
from result
