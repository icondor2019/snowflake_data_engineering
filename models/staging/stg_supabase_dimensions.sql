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
)
SELECT * FROM source_data
