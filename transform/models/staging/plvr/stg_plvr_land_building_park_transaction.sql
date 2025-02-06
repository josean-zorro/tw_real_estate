with
    source as (select * from {{ source("plvr", "land_building_park_transaction") }}),

    renamed as (

        select
            the_villages_and_towns_urban_district as district_township,
            transaction_sign as transaction_subject,
            land_sector_position_building_sector_house_number_plate
            as land_slot_or_address,
            land_shifting_total_area_square_meter as total_tranferred_area_square_meter,
            the_use_zoning_or_compiles_and_checks as metropolis_zone_type,
            the_nonmetropolis_land_use_district as nonmetropolis_zone_type,
            nonmetropolis_land_use as nonmetropolis_land_use_designation,
            transaction_year_month_and_day as transaction_date,
            transaction_pen_number as number_of_property_type,
            shifting_level as transferred_floor,
            total_floor_number as total_floors,
            building_state as building_type,
            main_use as primary_use,
            main_building_materials as primary_building_material,
            construction_to_complete_the_years as construction_completion_date,
            building_shifting_total_area as building_transferred_area_square_meter,
            building_present_situation_pattern_room as building_number_of_bedrooms,
            building_present_situation_pattern_hall as building_number_of_living_rooms,
            building_present_situation_pattern_health as building_number_of_bathrooms,
            building_present_situation_pattern_compartmented
            as building_number_of_partitions,
            whether_there_is_manages_the_organization as has_management_organization,
            total_price_ntd as total_price_ntd,
            the_unit_price_ntd_square_meter as price_per_square_meter,
            the_berth_category as parking_space_type,
            berth_shifting_total_area_square_meter as parking_transferred_sqare_meter,
            the_berth_total_price_ntd as parking_total_price_ntd,
            the_note as note,
            serial_number as transaction_id,
            main_building_area as main_building_area_square_meter,
            auxiliary_building_area as auxiliary_building_area_square_meter,
            balcony_area as balcony_area_square_meter,
            elevator as has_elevator,
            transaction_number as transferred_number,
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
