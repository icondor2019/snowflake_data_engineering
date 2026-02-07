with meals as (
select 
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
      f.value::string as product_id -- Flatten array to get individual product IDs
from {{ref('inc_meals')}},
lateral flatten(input => product_ids) f -- Use Snowflake's LATERAL FLATTEN to explode array
where product_ids is not null
)
select * from meals