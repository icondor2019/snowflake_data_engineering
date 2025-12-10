{{ config(materialized="table") }}

with source_data as (
    SELECT
      client_id,
      created_at,
      descripcion ,
      peso_total_gr,
      energia_kcal,
      proteina_gr,
      grasas_gr,
      carbohidratos_gr,
      fibra_gr,
      uuid,
      plan_uuid,
      product_ids,
    FROM AIRBYTE.SUPABASE.MEALS
)
SELECT * FROM source_data