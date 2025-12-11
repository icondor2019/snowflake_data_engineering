{{ config(materialized="table") }}

WITH source_data as (
    SELECT
        supabase_user_uuid,
        telegram_id,
        name,
        created_at
    FROM AIRBYTE.SUPABASE.PLANS
)
SELECT * FROM source_data