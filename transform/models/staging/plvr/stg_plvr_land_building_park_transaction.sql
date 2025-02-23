with
    source as (select * from {{ source("plvr", "land_building_park_transaction") }}),

    renamed as (

        select
            the_villages_and_towns_urban_district as district_township,
            transaction_sign as transaction_subject,
            land_sector_position_building_sector_house_number_plate
            as address_land_slot,
            safe_cast(
                land_shifting_total_area_square_meter as float64
            ) as land_total_tranferred_area_square_meter,
            the_use_zoning_or_compiles_and_checks as metropolis_zone_type,
            the_nonmetropolis_land_use_district as nonmetropolis_zone_type,
            nonmetropolis_land_use as nonmetropolis_land_use_designation,
            case
                when {{ validate_taiwan_date("transaction_year_month_and_day") }}
                then {{ convert_taiwan_date("transaction_year_month_and_day") }}
                else cast('1911-01-01' as date)
            end as transaction_date,
            transaction_pen_number as number_of_property_type,
            shifting_level as transferred_floor,
            total_floor_number as total_floors,
            regexp_replace(building_state, r'\(.*?\)', '') as building_type,
            building_state as building_type_origin,
            main_use as primary_use,
            main_building_materials as primary_building_material,
            case
                when
                    {{
                        validate_taiwan_date(
                            "construction_to_complete_the_years", earliest_date=None
                        )
                    }}
                then {{ convert_taiwan_date("construction_to_complete_the_years") }}
                else cast('1911-01-01' as date)
            end as construction_completion_date,
            safe_cast(
                building_shifting_total_area as float64
            ) as building_transferred_area_square_meter,
            safe_cast(
                building_present_situation_pattern_room as int64
            ) as building_number_of_bedrooms,
            safe_cast(
                building_present_situation_pattern_hall as int64
            ) as building_number_of_living_rooms,
            safe_cast(
                building_present_situation_pattern_health as int64
            ) as building_number_of_bathrooms,
            building_present_situation_pattern_compartmented
            as building_number_of_partitions,
            whether_there_is_manages_the_organization as has_management_organization,
            safe_cast(total_price_ntd as float64) as total_price_ntd,
            safe_cast(
                the_unit_price_ntd_square_meter as int64
            ) as price_per_square_meter,
            the_berth_category as parking_space_type,
            safe_cast(
                berth_shifting_total_area_square_meter as float64
            ) as parking_transferred_area_square_meter,
            safe_cast(the_berth_total_price_ntd as int64) as parking_total_price_ntd,
            the_note as note,
            serial_number as transaction_id,
            safe_cast(main_building_area as float64) as main_building_area_square_meter,
            safe_cast(
                auxiliary_building_area as float64
            ) as auxiliary_building_area_square_meter,
            safe_cast(balcony_area as float64) as balcony_area_square_meter,
            elevator as has_elevator,
            transaction_number as transferred_number,
            upper(regexp_extract(_smart_source_file, r'/([a-z])_')) as city_id,
            _smart_source_bucket,
            _smart_source_file,
            _smart_source_lineno,
            _sdc_received_at,
            _sdc_deleted_at,
            _sdc_batched_at,
            _sdc_extracted_at,
            _sdc_sequence,
            _sdc_table_version

        from source

    )

select *
from renamed
