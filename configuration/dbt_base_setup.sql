USE ROLE accountadmin;
USE DATABASE dbt_project;

-- -------------------- SCHEMAS -------------------------------------------------
-- need to create base schemas for DEV & PROD
CREATE SCHEMA DEV;
CREATE SCHEMA PROD;
show schemas;

-- ============== CREATE DBT PROJECT =======================
CREATE OR REPLACE GIT REPOSITORY dbt_project.public.dbt_project_demo
  API_INTEGRATION =  git_api_integration -- Name of the API integration defined above
  ORIGIN = 'https://github.com/your_account/your_project.git' -- Insert URL of forked repo
  GIT_CREDENTIALS = dbt_project.public.github_pat;

CREATE DBT PROJECT IF NOT EXISTS DBT_project.PROD_MODELED.FOOD_TRACKING_PROJECT
    FROM '@dbt_project.public.dbt_project_demo/branches/main'
    DEFAULT_TARGET = 'prod'
    COMMENT= 'My food tracking dbt project';

-- -------------------- SCHEDULES -------------------------------------------------
-- configure tasks to run the schedules. You can execute custom commands using args='your dbt command'
-- PROD_PIPELINE: name of the DBT project I deployed. It creates an object in snowflake
create or replace task DBT_PROJECT.PROD_MODELED.FIRST_DBT_TASK
	warehouse=COMPUTE_WH
	schedule='USING CRON 1 10 * * * America/Bogota'
	as EXECUTE dbt project DBT_project.PROD_MODELED.FOOD_TRACKING_PROJECT args = 'run --target prod';

-- All taks need activation after creation
ALTER TASK DBT_PROJECT.PROD_MODELED.FIRST_DBT_TASK RESUME;

-- To suspend task EXECUTION
ALTER TASK DBT_PROJECT.PROD_MODELED.FIRST_DBT_TASK SUSPEND;

-- show created tasks in a database
show tasks in database dbt_project;

