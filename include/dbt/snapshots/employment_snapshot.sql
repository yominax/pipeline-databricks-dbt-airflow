{% snapshot employment_history_snapshot %}

{{
    config(
        file_format = "delta",
        location_root = "/mnt/hawk-silver",
        target_schema='snapshots',
        invalidate_hard_deletes=True,
        unique_key='employee_id',
        strategy='check',
        check_cols='all'
    )
}}

-- Query to retrieve the current state of the data
SELECT 
    CAST(employee_id AS STRING) AS employee_id,
    first_name,
    last_name,
    department,
    sub_department,
    CAST(first_level_manager AS STRING) AS first_level_manager,
    CAST(second_level_manager AS STRING) AS second_level_manager,
    CAST(third_level_manager AS STRING) AS third_level_manager,
    CAST(fourth_level_manager AS STRING) AS fourth_level_manager,
    job_level,
    salary,
    hire_date,
    term_date,
    term_type,
    term_reason,
    CASE 
        WHEN active_status = 1 THEN 'Yes'
        WHEN active_status = 0 THEN 'No'
        ELSE CAST(active_status AS STRING) -- Ensure all outputs are strings
    END AS active_status
FROM {{ source('humanresourcesd', 'people_employment_history') }}

{% endsnapshot %}
