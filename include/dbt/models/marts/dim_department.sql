{{
    config(
        materialized = "table", 
        file_format = "delta", 
        schema = 'marts', 
        location_root = "/mnt/hawk-gold"
    )
}}

WITH distinct_departments AS (
    SELECT DISTINCT
        department,
        sub_department
    FROM {{ ref('employment_history_snapshot') }}
    WHERE dbt_valid_to is null
),

department_with_keys AS (
    SELECT
        department,
        sub_department,
        ROW_NUMBER() OVER (ORDER BY department, sub_department) AS department_key
    FROM distinct_departments
)

SELECT *
FROM department_with_keys
