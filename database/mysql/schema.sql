-- ============================================================================
-- SUPPLY CHAIN INTELLIGENCE & OPERATIONS ANALYTICS PLATFORM
-- Relational Database DDL Schema (MySQL 8.0+)
-- ============================================================================
-- Architecture: Star Schema / Normalized Dimensional Model (InnoDB)
-- Database Engine: MySQL
-- Author: B.Tech Computer Engineering Final Year Project
-- ============================================================================

CREATE DATABASE IF NOT EXISTS supply_chain_analytics_db;
USE supply_chain_analytics_db;

-- Drop child tables first
DROP TABLE IF EXISTS fact_supply_chain_orders;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_categories;
DROP TABLE IF EXISTS dim_warehouses;
DROP TABLE IF EXISTS dim_suppliers;
DROP TABLE IF EXISTS dim_date;

-- ----------------------------------------------------------------------------
-- 1. DIMENSION: SUPPLIERS
-- ----------------------------------------------------------------------------
CREATE TABLE dim_suppliers (
    supplier_id VARCHAR(10) NOT NULL,
    supplier_name VARCHAR(50) NOT NULL UNIQUE,
    contact_email VARCHAR(100) NULL,
    lead_time_sla_days INT NOT NULL DEFAULT 5,
    supplier_tier VARCHAR(20) NOT NULL DEFAULT 'Tier-1',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (supplier_id),
    CONSTRAINT chk_sla_days CHECK (lead_time_sla_days > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 2. DIMENSION: WAREHOUSES & REGIONS
-- ----------------------------------------------------------------------------
CREATE TABLE dim_warehouses (
    warehouse_id VARCHAR(10) NOT NULL,
    warehouse_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    region VARCHAR(20) NOT NULL,
    storage_capacity_sqft INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (warehouse_id),
    CONSTRAINT chk_capacity CHECK (storage_capacity_sqft > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 3. DIMENSION: PRODUCT CATEGORIES
-- ----------------------------------------------------------------------------
CREATE TABLE dim_categories (
    category_id VARCHAR(10) NOT NULL,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    target_margin_pct DECIMAL(5, 2) NOT NULL DEFAULT 20.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 4. DIMENSION: PRODUCTS (SKU CATALOG)
-- ----------------------------------------------------------------------------
CREATE TABLE dim_products (
    product_id VARCHAR(20) NOT NULL,
    sku_code VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(50) NOT NULL,
    category_id VARCHAR(10) NOT NULL,
    category_name VARCHAR(50) NOT NULL,
    standard_reorder_level INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id),
    CONSTRAINT fk_mysql_prod_category FOREIGN KEY (category_id) REFERENCES dim_categories (category_id) ON DELETE RESTRICT,
    CONSTRAINT chk_prod_reorder CHECK (standard_reorder_level >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 5. DIMENSION: DATE (TIME INTELLIGENCE)
-- ----------------------------------------------------------------------------
CREATE TABLE dim_date (
    date_key DATE NOT NULL,
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
    is_weekend TINYINT NOT NULL DEFAULT 0,
    PRIMARY KEY (date_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 6. FACT TABLE: SUPPLY CHAIN ORDERS & SHIPMENTS
-- ----------------------------------------------------------------------------
CREATE TABLE fact_supply_chain_orders (
    order_id VARCHAR(20) NOT NULL,
    raw_record_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    delivery_date DATE NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    supplier_id VARCHAR(10) NOT NULL,
    warehouse_id VARCHAR(10) NOT NULL,
    units_sold INT NOT NULL,
    unit_purchase_cost DECIMAL(10, 2) NOT NULL,
    unit_selling_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    reorder_level INT NOT NULL,
    shipping_time_days INT NOT NULL,
    target_lead_time_days INT NOT NULL DEFAULT 5,
    delivery_delay_days INT NOT NULL DEFAULT 0,
    is_on_time TINYINT NOT NULL DEFAULT 1,
    fulfillment_status VARCHAR(20) NOT NULL,
    stockout_flag TINYINT NOT NULL DEFAULT 0,
    understock_flag TINYINT NOT NULL DEFAULT 0,
    fulfillment_deficit_units INT NOT NULL DEFAULT 0,
    total_revenue DECIMAL(14, 2) NOT NULL,
    total_cogs DECIMAL(14, 2) NOT NULL,
    gross_profit DECIMAL(14, 2) NOT NULL,
    gross_margin_pct DECIMAL(5, 2) NOT NULL,
    logistics_cost DECIMAL(10, 2) NOT NULL,
    net_profit DECIMAL(14, 2) NOT NULL,
    inventory_risk_category VARCHAR(30) NOT NULL,
    delivery_risk_category VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_mysql_order_date FOREIGN KEY (order_date) REFERENCES dim_date (date_key),
    CONSTRAINT fk_mysql_deliv_date FOREIGN KEY (delivery_date) REFERENCES dim_date (date_key),
    CONSTRAINT fk_mysql_order_prod FOREIGN KEY (product_id) REFERENCES dim_products (product_id),
    CONSTRAINT fk_mysql_order_sup FOREIGN KEY (supplier_id) REFERENCES dim_suppliers (supplier_id),
    CONSTRAINT fk_mysql_order_wh FOREIGN KEY (warehouse_id) REFERENCES dim_warehouses (warehouse_id),
    CONSTRAINT chk_units_sold CHECK (units_sold >= 0),
    CONSTRAINT chk_stock_qty CHECK (stock_quantity >= 0),
    CONSTRAINT chk_ship_days CHECK (shipping_time_days > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- 7. PERFORMANCE INDEXES
-- ----------------------------------------------------------------------------
CREATE INDEX idx_my_fact_order_date ON fact_supply_chain_orders (order_date);
CREATE INDEX idx_my_fact_delivery_date ON fact_supply_chain_orders (delivery_date);
CREATE INDEX idx_my_fact_product_id ON fact_supply_chain_orders (product_id);
CREATE INDEX idx_my_fact_supplier_id ON fact_supply_chain_orders (supplier_id);
CREATE INDEX idx_my_fact_warehouse_id ON fact_supply_chain_orders (warehouse_id);
CREATE INDEX idx_my_fact_fulfill_status ON fact_supply_chain_orders (fulfillment_status);
CREATE INDEX idx_my_fact_is_on_time ON fact_supply_chain_orders (is_on_time);
CREATE INDEX idx_my_fact_inv_risk ON fact_supply_chain_orders (inventory_risk_category);
CREATE INDEX idx_my_dim_prod_cat ON dim_products (category_id);
CREATE INDEX idx_my_dim_wh_region ON dim_warehouses (region);
