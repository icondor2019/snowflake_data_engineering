USE ROLE accountadmin;
USE DATABASE dbt_project;

-- -------------------- SCHEMAS -------------------------------------------------
-- need to create base schemas for DEV & PROD
CREATE SCHEMA DEV;

CREATE SCHEMA PROD;

show schemas;

-- -------------------- SCHEDULES -------------------------------------------------
-- configure tasks to run the schedules. You can execute custom commands using args='your dbt command'
-- PROD_PIPELINE: name of the DBT project I deployed. It creates an object in snowflake
create or replace task DBT_PROJECT.PROD_MODELED.FIRST_DBT_TASK
	warehouse=COMPUTE_WH
	schedule='USING CRON 1 10 * * * America/Bogota'
	as EXECUTE dbt project PROD_PIPELINE args='run --target prod';

-- All taks need activation after creation
ALTER TASK DBT_PROJECT.PROD_MODELED.FIRST_DBT_TASK RESUME;

-- To suspend task EXECUTION
ALTER TASK DBT_PROJECT.PROD_MODELED.FIRST_DBT_TASK SUSPEND;

-- show created tasks in a database
show tasks in database dbt_project;

