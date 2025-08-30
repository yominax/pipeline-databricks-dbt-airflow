{{
    config(
        materialized = "table", 
        file_format = "delta", 
        schema = 'marts', 
        location_root = "/mnt/hawk-gold"
    )
}}

WITH managers AS (
    SELECT
        pe.employee_id,
        pe.first_level_manager,
        m1.first_name AS first_level_manager_first_name,
        m1.last_name AS first_level_manager_last_name,
        pe.second_level_manager,
        m2.first_name AS second_level_manager_first_name,
        m2.last_name AS second_level_manager_last_name,
        pe.third_level_manager,
        m3.first_name AS third_level_manager_first_name,
        m3.last_name AS third_level_manager_last_name,
        pe.fourth_level_manager,
        m4.first_name AS fourth_level_manager_first_name,
        m4.last_name AS fourth_level_manager_last_name
    FROM {{ ref('employment_history_snapshot') }} AS pe
    LEFT JOIN {{ ref('employment_history_snapshot') }} AS m1
        ON pe.first_level_manager = m1.employee_id
    LEFT JOIN {{ ref('employment_history_snapshot') }} AS m2
        ON pe.second_level_manager = m2.employee_id
    LEFT JOIN {{ ref('employment_history_snapshot') }} AS m3
        ON pe.third_level_manager = m3.employee_id
    LEFT JOIN {{ ref('employment_history_snapshot') }} AS m4
        ON pe.fourth_level_manager = m4.employee_id
    WHERE pe.dbt_valid_to IS NULL
)

SELECT
    employee_id,
    first_level_manager,
    CONCAT(first_level_manager_first_name, ' ', first_level_manager_last_name) AS first_level_manager_name,
    second_level_manager,
    CONCAT(second_level_manager_first_name, ' ', second_level_manager_last_name) AS second_level_manager_name,
    third_level_manager,
    CONCAT(third_level_manager_first_name, ' ', third_level_manager_last_name) AS third_level_manager_name,
    fourth_level_manager,
    CONCAT(fourth_level_manager_first_name, ' ', fourth_level_manager_last_name) AS fourth_level_manager_name
FROM managers
