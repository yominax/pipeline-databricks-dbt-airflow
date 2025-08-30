{{
    config(
        materialized = "table", 
        file_format = "delta", 
        schema = 'marts', 
        location_root = "/mnt/hawk-gold"
    )
}}

WITH distinct_marital_status AS (
    SELECT DISTINCT
        marital_status
    FROM {{ ref('people_snapshot') }}
    WHERE dbt_valid_to IS NULL
),

marital_status_with_keys AS (
    SELECT
        marital_status,
        ROW_NUMBER() OVER (ORDER BY marital_status DESC) AS marital_key
    FROM distinct_marital_status
)

SELECT *
FROM marital_status_with_keys
