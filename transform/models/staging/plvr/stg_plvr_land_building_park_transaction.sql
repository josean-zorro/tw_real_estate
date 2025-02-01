with
    source as (select * from {{ source("plvr", "land_building_park_transaction") }}),

    renamed as (

        select
            the_villages_and_towns_urban_district as district_township,
            transaction_sign as property_type,
            land_sector_position_building_sector_house_number_plate,
            land_shifting_total_area_square_meter,
            the_use_zoning_or_compiles_and_checks,
            the_nonmetropolis_land_use_district,
            nonmetropolis_land_use,
            transaction_year_month_and_day,
            transaction_pen_number,
            shifting_level,
            total_floor_number,
            building_state,
            main_use,
            main_building_materials,
            construction_to_complete_the_years,
            building_shifting_total_area,
            building_present_situation_pattern_room,
            building_present_situation_pattern_hall,
            building_present_situation_pattern_health,
            building_present_situation_pattern_compartmented,
            whether_there_is_manages_the_organization,
            total_price_ntd,
            the_unit_price_ntd_square_meter,
            the_berth_category,
            berth_shifting_total_area_square_meter,
            the_berth_total_price_ntd,
            the_note,
            serial_number,
            main_building_area,
            auxiliary_building_area,
            balcony_area,
            elevator,
            transaction_number,
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
