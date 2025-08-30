{% snapshot people_snapshot %}

{{
    config(
        file_format = "delta",
        location_root = "/mnt/hawk-silver",
        target_schema = 'snapshots',
        invalidate_hard_deletes = True,
        unique_key = 'employee_id',
        strategy = 'check',
        check_cols = 'all'
    )
}}

SELECT 
    CAST(employee_id AS STRING) AS employee_id,
    gender,
    race,
    FLOOR(DATEDIFF(CURRENT_DATE(), CAST(birth_date AS DATE)) / 365) AS age,
    education,
    location,
    location_city,
    marital_status,
    employment_status
FROM {{ source('humanresourcesd', 'people_data') }}

{% endsnapshot %}
