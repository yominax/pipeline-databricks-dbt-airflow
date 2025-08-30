{{
    config(
        materialized = "table", 
        file_format = "delta", 
        schema = 'marts', 
        location_root = "/mnt/hawk-gold"
    )
}}

WITH distinct_education AS (
    SELECT DISTINCT
        education
    FROM {{ ref('people_snapshot') }}
    WHERE dbt_valid_to IS NULL
        -- Include NULL explicitly
        OR education IS NOT NULL
),

education_with_keys AS (
    SELECT
        education,
        ROW_NUMBER() OVER (ORDER BY COALESCE(education, 'None')) AS education_key
    FROM distinct_education
)

SELECT *
FROM education_with_keys

