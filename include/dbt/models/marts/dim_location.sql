{{
    config(
        materialized = "table", 
        file_format = "delta", 
        schema = 'marts', 
        location_root = "/mnt/hawk-gold"
    )
}}

WITH distinct_locations AS (
    SELECT DISTINCT
        location,
        location_city
    FROM {{ ref('people_snapshot') }}
    WHERE dbt_valid_to IS NULL
),

location_with_keys AS (
    SELECT
        location,
        location_city,
        ROW_NUMBER() OVER (ORDER BY location, location_city) AS location_key
    FROM distinct_locations
)

SELECT *
FROM location_with_keys
