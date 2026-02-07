WITH source_data as (
    SELECT
      uuid,
      created_at,
      last_modified_at,
      client_id,
      daily_kcal,
      daily_proteine,
      daily_carbohydrates,
      status,
      daily_fiber,
      user_uuid,
    FROM DBT_PROJECT.AIRBYTE.PLANS
)
SELECT * FROM source_data