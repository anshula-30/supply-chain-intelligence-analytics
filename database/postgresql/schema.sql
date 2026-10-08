-- ============================================================================
-- SUPPLY CHAIN INTELLIGENCE & OPERATIONS ANALYTICS PLATFORM
-- Relational Database DDL Schema (PostgreSQL 13+)
-- ============================================================================
-- Architecture: Star Schema / Normalized Dimensional Model (3NF Conformed Dims)
-- Database Engine: PostgreSQL
-- Author: B.Tech Computer Engineering Final Year Project
-- ============================================================================

-- Drop existing tables if re-running
DROP TABLE IF EXISTS fact_supply_chain_orders CASCADE;
DROP TABLE IF EXISTS dim_products CASCADE;
DROP TABLE IF EXISTS dim_categories CASCADE;
DROP TABLE IF EXISTS dim_warehouses CASCADE;
DROP TABLE IF EXISTS dim_suppliers CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;

-- ----------------------------------------------------------------------------
-- 1. DIMENSION: SUPPLIERS
-- ----------------------------------------------------------------------------
CREATE TABLE dim_suppliers (
    supplier_id VARCHAR(10) PRIMARY KEY,
    supplier_name VARCHAR(50) NOT NULL UNIQUE,
    contact_email VARCHAR(100),
    lead_time_sla_days INT NOT NULL DEFAULT 5 CHECK (lead_time_sla_days > 0),
    supplier_tier VARCHAR(20) NOT NULL DEFAULT 'Tier-1',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dim_suppliers IS 'Dimension storing vendor profiles and contractual lead-time SLAs';
COMMENT ON COLUMN dim_suppliers.supplier_id IS 'Unique supplier key code (e.g., SUP-A)';
COMMENT ON COLUMN dim_suppliers.lead_time_sla_days IS 'Agreed target turnaround SLA in days';

-- ----------------------------------------------------------------------------
-- 2. DIMENSION: WAREHOUSES & REGIONS
-- ----------------------------------------------------------------------------
CREATE TABLE dim_warehouses (
    warehouse_id VARCHAR(10) PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    region VARCHAR(20) NOT NULL,
    storage_capacity_sqft INT NOT NULL CHECK (storage_capacity_sqft > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dim_warehouses IS 'Fulfillment distribution centers and geographic regional attributes';

-- ----------------------------------------------------------------------------
-- 3. DIMENSION: PRODUCT CATEGORIES
-- ----------------------------------------------------------------------------
CREATE TABLE dim_categories (
    category_id VARCHAR(10) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    target_margin_pct NUMERIC(5, 2) NOT NULL DEFAULT 20.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dim_categories IS 'Classification hierarchy for inventory goods and financial margin benchmarks';

-- ----------------------------------------------------------------------------
-- 4. DIMENSION: PRODUCTS (SKU CATALOG)
-- ----------------------------------------------------------------------------
CREATE TABLE dim_products (
    product_id VARCHAR(20) PRIMARY KEY,
    sku_code VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(50) NOT NULL,
    category_id VARCHAR(10) NOT NULL,
    category_name VARCHAR(50) NOT NULL,
    standard_reorder_level INT NOT NULL CHECK (standard_reorder_level >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prod_category FOREIGN KEY (category_id) REFERENCES dim_categories (category_id) ON DELETE RESTRICT
);

COMMENT ON TABLE dim_products IS 'Catalog master containing stock keeping units (SKUs) linked to categories';

-- ----------------------------------------------------------------------------
-- 5. DIMENSION: DATE (TIME INTELLIGENCE)
-- ----------------------------------------------------------------------------
CREATE TABLE dim_date (
    date_key DATE PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter VARCHAR(5) NOT NULL,
    year_quarter VARCHAR(10) NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    year_month VARCHAR(10) NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    is_weekend SMALLINT NOT NULL DEFAULT 0 CHECK (is_weekend IN (0, 1))
);

COMMENT ON TABLE dim_date IS 'Calendar dimension supporting fiscal time-series analysis and rolling metrics';

-- ----------------------------------------------------------------------------
-- 6. FACT TABLE: SUPPLY CHAIN ORDERS & SHIPMENTS
-- ----------------------------------------------------------------------------
CREATE TABLE fact_supply_chain_orders (
    order_id VARCHAR(20) PRIMARY KEY,
    raw_record_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    delivery_date DATE NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    supplier_id VARCHAR(10) NOT NULL,
    warehouse_id VARCHAR(10) NOT NULL,
    units_sold INT NOT NULL CHECK (units_sold >= 0),
    unit_purchase_cost NUMERIC(10, 2) NOT NULL CHECK (unit_purchase_cost > 0),
    unit_selling_price NUMERIC(10, 2) NOT NULL CHECK (unit_selling_price > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    reorder_level INT NOT NULL CHECK (reorder_level >= 0),
    shipping_time_days INT NOT NULL CHECK (shipping_time_days > 0),
    target_lead_time_days INT NOT NULL DEFAULT 5,
    delivery_delay_days INT NOT NULL DEFAULT 0 CHECK (delivery_delay_days >= 0),
    is_on_time SMALLINT NOT NULL DEFAULT 1 CHECK (is_on_time IN (0, 1)),
    fulfillment_status VARCHAR(20) NOT NULL CHECK (fulfillment_status IN ('Fulfilled', 'Partial', 'Stockout')),
    stockout_flag SMALLINT NOT NULL DEFAULT 0 CHECK (stockout_flag IN (0, 1)),
    understock_flag SMALLINT NOT NULL DEFAULT 0 CHECK (understock_flag IN (0, 1)),
    fulfillment_deficit_units INT NOT NULL DEFAULT 0 CHECK (fulfillment_deficit_units >= 0),
    total_revenue NUMERIC(14, 2) NOT NULL,
    total_cogs NUMERIC(14, 2) NOT NULL,
    gross_profit NUMERIC(14, 2) NOT NULL,
    gross_margin_pct NUMERIC(5, 2) NOT NULL,
    logistics_cost NUMERIC(10, 2) NOT NULL CHECK (logistics_cost >= 0),
    net_profit NUMERIC(14, 2) NOT NULL,
    inventory_risk_category VARCHAR(30) NOT NULL,
    delivery_risk_category VARCHAR(30) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_date FOREIGN KEY (order_date) REFERENCES dim_date (date_key),
    CONSTRAINT fk_delivery_date FOREIGN KEY (delivery_date) REFERENCES dim_date (date_key),
    CONSTRAINT fk_order_product FOREIGN KEY (product_id) REFERENCES dim_products (product_id),
    CONSTRAINT fk_order_supplier FOREIGN KEY (supplier_id) REFERENCES dim_suppliers (supplier_id),
    CONSTRAINT fk_order_warehouse FOREIGN KEY (warehouse_id) REFERENCES dim_warehouses (warehouse_id)
);

COMMENT ON TABLE fact_supply_chain_orders IS 'Central fact table containing order fulfillment, logistics lead times, inventory levels, and financial performance';

-- ----------------------------------------------------------------------------
-- 7. PERFORMANCE INDEXES
-- ----------------------------------------------------------------------------
CREATE INDEX idx_fact_order_date ON fact_supply_chain_orders (order_date);
CREATE INDEX idx_fact_delivery_date ON fact_supply_chain_orders (delivery_date);
CREATE INDEX idx_fact_product_id ON fact_supply_chain_orders (product_id);
CREATE INDEX idx_fact_supplier_id ON fact_supply_chain_orders (supplier_id);
CREATE INDEX idx_fact_warehouse_id ON fact_supply_chain_orders (warehouse_id);
CREATE INDEX idx_fact_fulfillment_status ON fact_supply_chain_orders (fulfillment_status);
CREATE INDEX idx_fact_is_on_time ON fact_supply_chain_orders (is_on_time);
CREATE INDEX idx_fact_inventory_risk ON fact_supply_chain_orders (inventory_risk_category);
CREATE INDEX idx_dim_prod_category ON dim_products (category_id);
CREATE INDEX idx_dim_wh_region ON dim_warehouses (region);
