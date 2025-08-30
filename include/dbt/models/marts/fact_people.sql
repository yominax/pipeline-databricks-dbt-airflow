{{
    config(
        materialized = "table", 
        file_format = "delta", 
        schema = 'marts', 
        location_root = "/mnt/hawk-gold"
    )
}}

WITH people_combined AS (
    SELECT
        eh.employee_id,
        eh.first_name,
        eh.last_name,
        CONCAT(eh.first_name, ' ', eh.last_name) AS full_name, -- Add full_name
        eh.department,
        eh.sub_department,
        eh.job_level,
        eh.salary,
        eh.hire_date,
        eh.term_date,
        eh.term_type,
        eh.term_reason,
        eh.active_status,
        ps.gender,
        ps.race,
        ps.age,
        ps.education,
        ps.location,
        ps.location_city,
        ps.marital_status,
        ps.employment_status
    FROM {{ ref('employment_history_snapshot') }} AS eh
    LEFT JOIN {{ ref('people_snapshot') }} AS ps
        ON eh.employee_id = ps.employee_id
),

joined_data AS (
    SELECT
        pc.employee_id,
        pc.first_name,
        pc.last_name,
        pc.full_name, -- Include full_name here
        pc.salary,
        pc.hire_date,
        pc.term_date,
        pc.active_status,
        pc.gender,
        pc.race,
        pc.age,
        pc.education,
        pc.location,
        pc.location_city,
        pc.employment_status,
        -- Join with Dimensional Tables
        d.department_key,
        j.job_level_key,
        t.term_key,
        dem.demog_key,
        e.education_key,
        l.location_key,
        m.marital_key
    FROM people_combined AS pc
    LEFT JOIN {{ ref('dim_department') }} AS d
        ON pc.department = d.department
        AND pc.sub_department = d.sub_department
    LEFT JOIN {{ ref('dim_job_level') }} AS j
        ON pc.job_level = j.job_level
    LEFT JOIN {{ ref('dim_term') }} AS t
        ON pc.term_type = t.term_type
        AND pc.term_reason = t.term_reason
    LEFT JOIN {{ ref('dim_demographic') }} AS dem
        ON pc.gender = dem.gender
        AND pc.race = dem.race
        AND pc.age = dem.age
    LEFT JOIN {{ ref('dim_education') }} AS e
        ON pc.education = e.education
    LEFT JOIN {{ ref('dim_location') }} AS l
        ON pc.location = l.location
        AND pc.location_city = l.location_city
    LEFT JOIN {{ ref('dim_marital') }} AS m
        ON pc.marital_status = m.marital_status
)

SELECT
    employee_id, 
    first_name, 
    last_name, 
    full_name, -- Add full_name in final output
    salary, 
    hire_date, 
    term_date, 
    active_status, 
    employment_status, 
    department_key, 
    job_level_key, 
    term_key, 
    demog_key, 
    education_key, 
    location_key, 
    marital_key
FROM joined_data
