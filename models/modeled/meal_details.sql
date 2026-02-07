with source_data as (
    select
        details.client_id,
        details.created_at,
        details.uuid,
        details.plan_uuid,
        details.product_id,
        products.nombre,
        products.categoria,
        products.calorias,
        CASE
            WHEN calorias > 4 THEN 'Hiper'
            WHEN calorias >= 2.5 THEN 'Alto'
            WHEN calorias >= 1.2 THEN 'Medio'
            ELSE 'Bajo'
        END AS categoria_calorica
    FROM {{ref ('int_meal_details')}} as details
    INNER JOIN {{ref('stg_supabase_products')}} as products
        ON products.id = details.product_id
)
select 
    *
from source_data