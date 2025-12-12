{{ config(
    materialized = "incremental",
    unique_key = "uuid",
    incremental_strategy = "merge"
) }}

WITH source_data as (
    SELECT
        uuid,
        user_uuid,
        created_at,
        peso,
        grasa,
        cintura,
        musculo
    FROM DBT_PROJECT.AIRBYTE.BODY_DIMENSIONS
    {% if is_incremental() %}
        where created_at > (select max(created_at) from {{ this }})
    {% endif %}
)
SELECT * FROM source_data
