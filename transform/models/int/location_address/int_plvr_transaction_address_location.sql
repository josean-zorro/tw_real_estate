with
    result as (
        select city_code, district_township, max(_sdc_batched_at) as last_batched_at
        from {{ ref("stg_plvr_land_building_park_transaction") }}
        group by all
    )

select *
from result
