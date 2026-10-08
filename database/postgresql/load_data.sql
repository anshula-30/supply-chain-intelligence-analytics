-- ============================================================================
-- SUPPLY CHAIN INTELLIGENCE & OPERATIONS ANALYTICS PLATFORM
-- Data Ingestion Script (PostgreSQL COPY)
-- ============================================================================
-- Note: Replace absolute paths if executing on a remote server.
-- In psql, run using: \i database/postgresql/load_data.sql
-- ============================================================================

-- 1. Ingest Dimensions
\copy dim_suppliers(supplier_id, supplier_name, contact_email, lead_time_sla_days, supplier_tier) FROM 'data/processed/dim_suppliers.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy dim_warehouses(warehouse_id, warehouse_name, city, state, region, storage_capacity_sqft) FROM 'data/processed/dim_warehouses.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy dim_categories(category_id, category_name, target_margin_pct) FROM 'data/processed/dim_categories.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy dim_products(product_id, sku_code, product_name, category_id, category_name, standard_reorder_level) FROM 'data/processed/dim_products.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

\copy dim_date(date_key, full_date, year, quarter, year_quarter, month, month_name, year_month, day_of_month, day_of_week, day_name, is_weekend) FROM 'data/processed/dim_date.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 2. Ingest Fact Table
\copy fact_supply_chain_orders(order_id, raw_record_id, order_date, delivery_date, product_id, supplier_id, warehouse_id, units_sold, unit_purchase_cost, unit_selling_price, stock_quantity, reorder_level, shipping_time_days, target_lead_time_days, delivery_delay_days, is_on_time, fulfillment_status, stockout_flag, understock_flag, fulfillment_deficit_units, total_revenue, total_cogs, gross_profit, gross_margin_pct, logistics_cost, net_profit, inventory_risk_category, delivery_risk_category) FROM 'data/processed/fact_supply_chain_orders.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

-- 3. Verification Counts
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
