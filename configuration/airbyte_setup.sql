-- Created also when configure airbyte destination
CREATE OR REPLACE SCHEMA dbt_project.airbyte;

-- ---> create warehouses
CREATE OR REPLACE WAREHOUSE ingestion_wh
    WAREHOUSE_SIZE = 'xsmall'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
COMMENT = 'wh to manage raw data ingestion with airbyte';

USE WAREHOUSE ingestion_wh;

-- quering records after airbyte ingestion
select * from dbt_project.airbyte.meals
limit 10