USE ROLE accountadmin;
CREATE DATABASE dbt_project;
USE SCHEMA public;


-- Create credentials
CREATE OR REPLACE SECRET dbt_project.public.github_pat
  TYPE = password
  USERNAME = 'your_github_account'
  PASSWORD = 'your_github_pat';

-- Create the API integration
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/your_account') -- URL to your GitHub profile
  ALLOWED_AUTHENTICATION_SECRETS = (github_pat) -- the secret created above
  ENABLED = TRUE;

-- Create the git repository object
CREATE OR REPLACE GIT REPOSITORY dbt_project.public.dbt_project_demo
  API_INTEGRATION =  git_api_integration -- Name of the API integration defined above
  ORIGIN = 'https://github.com/your_account/your_project.git' -- Insert URL of forked repo
  GIT_CREDENTIALS = dbt_project.public.github_pat;

SHOW GIT REPOSITORIES;

SHOW SECRET:

-- to create oauth integration
-- this approach need and additional step in Github, you need to install in your account snowflakeDB
CREATE OR REPLACE API INTEGRATION oauth_github
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/your_account')
  API_USER_AUTHENTICATION = (TYPE = snowflake_github_app)
  ENABLED = TRUE
  ;

-- Drop a git REPOSITORY
-- DROP GIT REPOSITORY dbt_project.public.dbt_project_demo;