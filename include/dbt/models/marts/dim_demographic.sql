{{
    config(
        materialized = "table", 
        file_format = "delta", 
        schema = 'marts', 
        location_root = "/mnt/hawk-gold"
    )
}}

WITH distinct_demographics AS (
    SELECT DISTINCT
        gender,
        race,
        age
    FROM {{ ref('people_snapshot') }}
    WHERE dbt_valid_to IS NULL
      AND gender IS NOT NULL
      AND race IS NOT NULL
      AND age IS NOT NULL
),

deduplicated_demographics AS (
    SELECT
        gender,
        race,
        age,
        COUNT(*) OVER (PARTITION BY gender, race, age) AS count
    FROM distinct_demographics
)

SELECT
    gender,
    race,
    age,
    ROW_NUMBER() OVER (ORDER BY gender, race, age) AS demog_key
FROM deduplicated_demographics
WHERE count = 1

