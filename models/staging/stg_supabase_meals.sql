{{ config(
    materialized="incremental",
    unique_key="uuid"
) }}

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
    FROM DBT_PROJECT.AIRBYTE.MEALS
    {% if is_incremental() %}
        -- solo filas cuyo uuid no exista aún
        where uuid not in (select uuid from {{ this }})
    {% endif %}
)
SELECT * FROM source_data