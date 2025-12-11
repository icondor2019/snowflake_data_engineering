{{ config(
    materialized = "incremental",
    unique_key = "id",
    incremental_strategy = "merge"
) }}

with source_data as (

    select
        id,
        created_at,
        status,
        categoria,
        nombre,
        calorias,
        proteina,
        grasa,
        carbohidratos,
        fibra,
        user_uuid,
        contenido_embedding,
        embedding
    from DBT_PROJECT.AIRBYTE.PRODUCTS

    {% if is_incremental() %}
        -- Tomar solo productos nuevos (mayor fecha)
        where created_at > (select max(created_at) from {{ this }})
    {% endif %}
)

select * from source_data;
