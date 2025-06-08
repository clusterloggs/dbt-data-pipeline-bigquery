{{
    config(
        materialized="incremental",
        incremental_strategy="merge",
        partition_by={"field": "age_group", "data_type": "string"},
    )
}}

with
    age_groups as (
        select
            patient_id,  -- Include patient_id here
            case
                when age < 18
                then 'Child'
                when age between 18 and 34
                then 'Young Adult'
                when age between 35 and 64
                then 'Adult'
                else 'Senior'
            end as age_group,
            gender,
            insurance_type
        from {{ source("health_dataset", "patient_data_external") }}
    )

select
    patient_id,  -- Include patient_id in the final SELECT if required
    age_group,
    gender,
    insurance_type,
    count(*) as patient_count
from age_groups
group by patient_id, age_group, gender, insurance_type  -- Include patient_id in GROUP BY
order by age_group
