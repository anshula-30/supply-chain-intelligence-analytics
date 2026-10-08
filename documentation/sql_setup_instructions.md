# SQL Database Setup & Execution Guide

This guide provides step-by-step instructions for deploying and running the relational schema, loading the processed data, creating analytical views, and executing analytical queries on both **PostgreSQL** and **MySQL 8.0**.

---

## OPTION A: MySQL 8.0 Setup (Workbench or CLI)

### Prerequisites
- MySQL Server 8.0+ installed and running.
- MySQL Workbench or MySQL Command Line Client.

### Step 1: Allow Local File Ingestion
Because MySQL restricts `LOAD DATA LOCAL INFILE` by default for security, execute this command as administrator / root:
```sql
SET GLOBAL local_infile = 1;
```

### Step 2: Create Database and Schema
Open MySQL Workbench, create a new SQL tab, and open `database/mysql/schema.sql` (or paste its contents):
```sql
SOURCE database/mysql/schema.sql;
```
*Alternatively, in MySQL Command Line:*
```powershell
mysql -u root -p < "database/mysql/schema.sql"
```

### Step 3: Load Data from CSV
Open `database/mysql/load_data.sql`.  
Ensure file paths match your local directory structure:
```sql
USE supply_chain_analytics_db;
SOURCE database/mysql/load_data.sql;
```
*Alternatively, in MySQL Command Line with `--local-infile=1`:*
```powershell
mysql --local-infile=1 -u root -p supply_chain_analytics_db < "database/mysql/load_data.sql"
```

### Step 4: Create Analytical Views
Execute the view definitions:
```sql
SOURCE database/views/views.sql;
```

### Step 5: Verify Row Counts & Run Queries
```sql
SELECT 'dim_suppliers' AS tbl, COUNT(*) FROM dim_suppliers
UNION ALL
SELECT 'dim_warehouses', COUNT(*) FROM dim_warehouses
UNION ALL
SELECT 'dim_categories', COUNT(*) FROM dim_categories
UNION ALL
SELECT 'dim_products', COUNT(*) FROM dim_products
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'fact_supply_chain_orders', COUNT(*) FROM fact_supply_chain_orders;
```
Expected row counts:
- `dim_suppliers`: 5
- `dim_warehouses`: 5
- `dim_categories`: 4
- `dim_products`: 40
- `dim_date`: 762
- `fact_supply_chain_orders`: 15,000

---

## OPTION B: PostgreSQL 13+ Setup (pgAdmin or psql)

### Prerequisites
- PostgreSQL 13+ installed.
- pgAdmin 4 or `psql` command line tool.

### Step 1: Create Database
In pgAdmin or psql:
```sql
CREATE DATABASE supply_chain_analytics;
```
Connect to the database:
```sql
\c supply_chain_analytics;
```

### Step 2: Execute Schema DDL
Run the PostgreSQL schema script:
```sql
\i 'database/postgresql/schema.sql'
```

### Step 3: Ingest Data via COPY
Run the ingestion script:
```sql
\i 'database/postgresql/load_data.sql'
```
*Note: In pgAdmin Query Tool, you can also right-click each table -> Import/Export Data -> Select the respective CSV file from `data/processed/` with Header = ON and Delimiter = `,`.*

### Step 4: Compile Production Views
```sql
\i 'database/views/views.sql'
```

---

## OPTION C: Automated SQLite Embedded Testing (Zero Setup)
If you do not have PostgreSQL or MySQL running with permissions, you can run the entire database, views, and all 28 queries instantly using Python's built-in SQLite engine:
```powershell
python tests/test_sql_analytics.py
```
This script automatically:
1. Creates an isolated relational SQLite database (`database/supply_chain_test.db`).
2. Loads all 6 tables from `data/processed/`.
3. Creates and tests all 8 production views.
4. Executes all 28 analytical queries and measures query response time in milliseconds.
5. Verifies all 15,000 orders against ground-truth business metrics.
