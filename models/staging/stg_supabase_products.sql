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
)

select * from source_data
