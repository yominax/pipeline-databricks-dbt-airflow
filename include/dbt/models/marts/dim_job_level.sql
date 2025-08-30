{{
    config(
        materialized = "table", 
        file_format = "delta", 
        schema = 'marts', 
        location_root = "/mnt/hawk-gold"
    )
}}

WITH distinct_job_levels AS (
    SELECT DISTINCT
        job_level
    FROM {{ ref('employment_history_snapshot') }}
    WHERE dbt_valid_to IS NULL
),

job_levels_with_keys AS (
    SELECT
        job_level,
        ROW_NUMBER() OVER (ORDER BY job_level) AS job_level_key
    FROM distinct_job_levels
)

SELECT *
FROM job_levels_with_keys
