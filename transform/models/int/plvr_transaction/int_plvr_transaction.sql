with
    new_columns as (
        select
            {{ dbt_utils.star(ref("stg_plvr_land_building_park_transaction")) }},

            {{
                dbt_utils.generate_surrogate_key(
                    [
                        "upper(regexp_extract(_smart_source_file, r'/(a-za-z])_'))",
                        "district_township",
                    ]
                )
            }} as city_district_surrogate_key,
            {{
                dbt_utils.generate_surrogate_key(
                    [
                        "building_number_of_bedrooms",
                        "building_number_of_living_rooms",
                        "building_number_of_bathrooms",
                        "building_number_of_partitions",
                    ]
                )
            }} as layout_id,
            {{ dbt_utils.generate_surrogate_key(["building_type"]) }}
            as building_type_id
        from {{ ref("stg_plvr_land_building_park_transaction") }}
    )

select *
from new_columns
