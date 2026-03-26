---
name: dbt-project-standards
description: Use this skill when creating, configuring, or modifying any dbt project. It defines the user's preferred conventions for profiles, project structure, materialization, coding style, tasks, testing, and deployment setup on Snowflake.
---

# DBT Project Standards & Preferences

## 1. Profile Configuration (`profiles.yml`)

- **Two outputs required:** `dev` and `prod`
- **Default target:** `dev`
- **Schema naming:** The base schema is simply `DEV` for dev and `PROD` for prod. dbt will then append the custom schema defined in each model folder (e.g., `DEV_staging`, `PROD_modeled`). Do NOT add a suffix to the base schema itself — it must be just `DEV` or `PROD`
- **Threads:** Maximum of 6
- **Warehouse and database:** Must be explicitly provided by the user — never assume or hardcode
- **No `password`, `authenticator`, or `env_var()`** in profiles (Snowflake-native dbt handles auth via session)

### Template

```yaml
<project_name>:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <ACCOUNT>
      user: <USER>
      role: <ROLE>
      database: <DATABASE>
      warehouse: <WAREHOUSE>
      schema: DEV
      threads: 4
    prod:
      type: snowflake
      account: <ACCOUNT>
      user: <USER>
      role: <ROLE>
      database: <DATABASE>
      warehouse: <WAREHOUSE>
      schema: PROD
      threads: 6
```

## 2. dbt_project.yml — Model Folder Structure

Models must be organized under `models/` with these mandatory subfolders. Each subfolder has its own materialization and schema config:

```yaml
models:
  <project_name>:
    staging:
      +materialized: view
      +schema: staging
    modeled:
      +materialized: table
      +schema: modeled
    intermediate:
      +materialized: table
      +schema: intermediate
    incremental:
      +materialized: table
      +schema: incremental
      +tags:
        - incremental
    bi:
      +materialized: view
      +schema: bi
```

### Cold Stage Subfolders

- **Every model subfolder** must contain a `cold_stage/` subdirectory
- Files in `cold_stage/` must be tagged with `cold`
- Configure in `dbt_project.yml`:

```yaml
    staging:
      +materialized: view
      +schema: staging
      cold_stage:
        +tags:
          - cold
    modeled:
      +materialized: table
      +schema: modeled
      cold_stage:
        +tags:
          - cold
    intermediate:
      +materialized: table
      +schema: intermediate
      cold_stage:
        +tags:
          - cold
    incremental:
      +materialized: table
      +schema: incremental
      +tags:
        - incremental
      cold_stage:
        +tags:
          - cold
    bi:
      +materialized: view
      +schema: bi
      cold_stage:
        +tags:
          - cold
```

### Standard dbt Paths

Use default paths for all other folders:

```yaml
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]
```

## 3. Project Setup File (`project_setup.sql`)

Every dbt project must include a `project_setup.sql` file at the root. This file contains all Snowflake SQL needed to manage the dbt project lifecycle:

1. **Create the dbt project object** from a Git repository
2. **Alter the dbt project** to update to a new version
3. **Create tasks** to trigger dbt project execution on schedule
4. **Monitor task executions** with a query to check run history
5. **Configure email notifications** for task error alerts (allowed recipients list)

## 4. Task Configuration

### Execution Scope
- Tasks should call the `models` folder
- **Always exclude** `tag:cold` and `tag:incremental` by default
- Only include `cold` or `incremental` if explicitly requested by the user

### Schedule
- Use **Colombia/Bogota UTC offset** (UTC-5) when defining CRON schedules
- Example: `USING CRON 0 6 * * * America/Bogota`

### Error Notifications
- Tasks must have **email notifications on error**
- The SQL to configure the allowed email recipients list (via `SYSTEM$ADD_EVENT_SHARING_NOTIFICATION_INTEGRATION` or notification integration) must be included in `project_setup.sql`

## 5. Coding Style

### SQL Conventions
- **UPPERCASE** all SQL keywords and commands: `SELECT`, `FROM`, `WHERE`, `AS`, `GROUP BY`, `ORDER BY`, `ON`, `AND`, `OR`, `JOIN`, `LEFT JOIN`, `INNER JOIN`, `UNION`, `WITH`, `CASE`, `WHEN`, `THEN`, `END`, `HAVING`, `LIMIT`, `INSERT`, `UPDATE`, `DELETE`, `CREATE`, `ALTER`, `DROP`, etc.
- Column names and aliases in **lowercase**

### Model References
- **Only staging models** may use hardcoded source table references (e.g., `FROM database.schema.table`)
- **All other models** (modeled, intermediate, incremental, bi) must use dbt references: `{{ ref('model_name') }}` or `{{ source('source', 'table') }}`

### Staging Models
- **Always include all columns** from the source table — never drop columns in staging, even if not immediately needed

### Query Structure
- **CTEs over subqueries** — always prefer `WITH` blocks
- Structure complex queries as chained CTEs for readability
- **Use `GROUP BY ALL`** whenever possible instead of listing columns by position or name

### Performance Optimization
- **Optimize from the start** — if a modeled table requires heavy processing (e.g., JSON parsing, complex transformations) in a CTE, move that CTE to its own **intermediate model** so it materializes as a table and avoids recomputation
- Think about materialization boundaries early: expensive transformations belong in intermediate, not buried in CTEs of downstream models

### Join Aliases
- **Use descriptive aliases** in joins — never use single letters like `a`, `b`, `c`
- Aliases should reflect the table/model name (e.g., `clients`, `meals`, `dim_cat`)

### Example

```sql
WITH base_meals AS (
    SELECT
        meal_id,
        client_id,
        meal_date,
        total_calories
    FROM {{ ref('stg_supabase_meals') }}
    WHERE is_active = TRUE
),

enriched_meals AS (
    SELECT
        base_meals.meal_id,
        base_meals.meal_date,
        base_meals.total_calories,
        clients.client_name,
        dim_cat.category
    FROM base_meals
    LEFT JOIN {{ ref('stg_supabase_clients') }} AS clients
        ON base_meals.client_id = clients.client_id
    LEFT JOIN {{ ref('dim_categories') }} AS dim_cat
        ON base_meals.meal_id = dim_cat.source_id
)

SELECT * FROM enriched_meals
```

## 6. Testing Standards

- **Not fully defined yet** — evolving
- At minimum, ensure **unique value tests** on key columns in models within the `models/modeled/` folder
- Use dbt's built-in `unique` and `not_null` tests on primary/surrogate keys
- Consider adding `dbt_expectations` tests as the project matures

### Example (`models/modeled/schema.yml`)

```yaml
models:
  - name: meal_details
    columns:
      - name: meal_id
        tests:
          - unique
          - not_null
```
