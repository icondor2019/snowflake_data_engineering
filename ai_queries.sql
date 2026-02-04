use role accountadmin;
use warehouse snowflake_learning_wh;
use database dbt_project;

select * from prod_modeled.stg_supabase_meals
where created_at >= '2025-12-07';
;
-- ====== AI_COMPLETE EXAMPLE ========

SELECT AI_COMPLETE(
    model => 'deepseek-r1',
    model_parameters => {
        'temperature': 0.85,
        'max_tokens': 1500
    },
    prompt => 
    CONCAT('make a short 3 michelin stars culinary name for this simple meal. 
    The objetive is to be sofistically funny. 
    Only output the short review (max 50 words), no aditional comments: <meal>', descripcion, '</meal>')
    , show_details => False
)
from prod_modeled.stg_supabase_meals
where created_at >= '2025-12-07'
limit 3
;