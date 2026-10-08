-- ============================================================================
-- SUPPLY CHAIN INTELLIGENCE & OPERATIONS ANALYTICS PLATFORM
-- Data Ingestion Script (MySQL LOAD DATA LOCAL INFILE)
-- ============================================================================
-- Note: Ensure local_infile is enabled in MySQL (SET GLOBAL local_infile = 1;)
-- Replace file paths with absolute paths if running through MySQL Workbench.
-- ============================================================================

USE supply_chain_analytics_db;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Load dim_suppliers
LOAD DATA LOCAL INFILE 'c:/Users/ANSHULA/OneDrive/Documentos/3Skill Data Analytics/data/processed/dim_suppliers.csv'
INTO TABLE dim_suppliers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(supplier_id, supplier_name, contact_email, lead_time_sla_days, supplier_tier);

-- 2. Load dim_warehouses
LOAD DATA LOCAL INFILE 'c:/Users/ANSHULA/OneDrive/Documentos/3Skill Data Analytics/data/processed/dim_warehouses.csv'
INTO TABLE dim_warehouses
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(warehouse_id, warehouse_name, city, state, region, storage_capacity_sqft);

-- 3. Load dim_categories
LOAD DATA LOCAL INFILE 'c:/Users/ANSHULA/OneDrive/Documentos/3Skill Data Analytics/data/processed/dim_categories.csv'
INTO TABLE dim_categories
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(category_id, category_name, target_margin_pct);

-- 4. Load dim_products
LOAD DATA LOCAL INFILE 'c:/Users/ANSHULA/OneDrive/Documentos/3Skill Data Analytics/data/processed/dim_products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(product_id, sku_code, product_name, category_id, category_name, standard_reorder_level);

-- 5. Load dim_date
LOAD DATA LOCAL INFILE 'c:/Users/ANSHULA/OneDrive/Documentos/3Skill Data Analytics/data/processed/dim_date.csv'
INTO TABLE dim_date
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(date_key, full_date, year, quarter, year_quarter, month, month_name, year_month, day_of_month, day_of_week, day_name, is_weekend);

-- 6. Load fact_supply_chain_orders
LOAD DATA LOCAL INFILE 'c:/Users/ANSHULA/OneDrive/Documentos/3Skill Data Analytics/data/processed/fact_supply_chain_orders.csv'
INTO TABLE fact_supply_chain_orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, raw_record_id, order_date, delivery_date, product_id, supplier_id, warehouse_id, units_sold, unit_purchase_cost, unit_selling_price, stock_quantity, reorder_level, shipping_time_days, target_lead_time_days, delivery_delay_days, is_on_time, fulfillment_status, stockout_flag, understock_flag, fulfillment_deficit_units, total_revenue, total_cogs, gross_profit, gross_margin_pct, logistics_cost, net_profit, inventory_risk_category, delivery_risk_category);

SET FOREIGN_KEY_CHECKS = 1;

-- Verification Check
SELECT 'dim_suppliers' AS table_name, COUNT(*) AS total_rows FROM dim_suppliers
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
