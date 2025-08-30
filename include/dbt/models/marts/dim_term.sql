{{
    config(
        materialized = "table", 
        file_format = "delta", 
        schema = 'marts', 
        location_root = "/mnt/hawk-gold"
    )
}}

WITH distinct_terms AS (
    SELECT DISTINCT
        term_type,
        term_reason
    FROM {{ ref('employment_history_snapshot') }}
    WHERE dbt_valid_to IS NULL
      AND term_type IS NOT NULL
      AND term_reason IS NOT NULL
),

terms_with_keys AS (
    SELECT
        term_type,
        term_reason,
        ROW_NUMBER() OVER (ORDER BY term_type, term_reason) AS term_key
    FROM distinct_terms
)

SELECT *
FROM terms_with_keys
