-- ============================================================================
-- SUPPLY CHAIN INTELLIGENCE & OPERATIONS ANALYTICS PLATFORM
-- Production Analytical Views (Standard ANSI SQL / PostgreSQL / MySQL 8.0)
-- ============================================================================
-- Purpose: Modular Semantic Layer for Power BI Direct Query & Reporting
-- Author: B.Tech Computer Engineering Final Year Project
-- ============================================================================

-- ----------------------------------------------------------------------------
-- VIEW 1: SUPPLIER PERFORMANCE & RELIABILITY SCORECARD
-- ----------------------------------------------------------------------------
-- Business Value: Evaluates vendor reliability, contractual SLA compliance,
-- average shipping lead time, delivery delays, and fulfillment deficits.
CREATE OR REPLACE VIEW vw_supplier_performance_summary AS
SELECT 
    s.supplier_id,
    s.supplier_name,
    s.supplier_tier,
    COUNT(f.order_id) AS total_orders,
    SUM(f.units_sold) AS total_units_procured,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_lead_time_days,
    ROUND(AVG(f.delivery_delay_days), 2) AS avg_delay_days,
    SUM(f.is_on_time) AS on_time_orders,
    ROUND(SUM(f.is_on_time) * 100.0 / COUNT(f.order_id), 2) AS on_time_delivery_rate_pct,
    SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) AS fully_fulfilled_orders,
    ROUND(SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS fulfillment_rate_pct,
    SUM(CASE WHEN f.fulfillment_status != 'Fulfilled' THEN 1 ELSE 0 END) AS deficit_orders,
    SUM(f.fulfillment_deficit_units) AS total_deficit_units,
    ROUND(SUM(f.total_cogs), 2) AS total_procurement_cost,
    ROUND(SUM(f.total_revenue), 2) AS total_revenue_generated,
    ROUND(
        (SUM(f.is_on_time) * 100.0 / COUNT(f.order_id)) * 0.5 + 
        (SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id)) * 0.5,
        2
    ) AS supplier_reliability_index
FROM dim_suppliers s
JOIN fact_supply_chain_orders f ON s.supplier_id = f.supplier_id
GROUP BY s.supplier_id, s.supplier_name, s.supplier_tier;

-- ----------------------------------------------------------------------------
-- VIEW 2: WAREHOUSE FULFILLMENT & LOGISTICS OPERATIONS
-- ----------------------------------------------------------------------------
-- Business Value: Assesses distribution center throughput, regional stock
-- adequacy, logistics freight costs, and shipping lead time efficiency.
CREATE OR REPLACE VIEW vw_warehouse_fulfillment_metrics AS
SELECT 
    w.warehouse_id,
    w.warehouse_name,
    w.city,
    w.region,
    w.storage_capacity_sqft,
    COUNT(f.order_id) AS total_dispatched_orders,
    SUM(f.units_sold) AS total_units_sold,
    SUM(f.stock_quantity) AS total_stock_processed,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_transit_days,
    ROUND(SUM(f.is_on_time) * 100.0 / COUNT(f.order_id), 2) AS on_time_shipment_pct,
    SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) AS fully_fulfilled_orders,
    ROUND(SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS fulfillment_rate_pct,
    SUM(f.stockout_flag) AS stockout_count,
    SUM(f.understock_flag) AS understock_warning_count,
    ROUND(SUM(f.logistics_cost), 2) AS total_logistics_cost,
    ROUND(AVG(f.logistics_cost), 2) AS avg_logistics_cost_per_order,
    ROUND(SUM(f.total_revenue), 2) AS total_warehouse_revenue
FROM dim_warehouses w
JOIN fact_supply_chain_orders f ON w.warehouse_id = f.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_name, w.city, w.region, w.storage_capacity_sqft;

-- ----------------------------------------------------------------------------
-- VIEW 3: PRODUCT INVENTORY HEALTH & STOCK-OUT ANALYSIS
-- ----------------------------------------------------------------------------
-- Business Value: Monitors product SKU level stock-out frequency, safety stock
-- breaches (understock), demand-supply gap (deficit), and gross profit.
CREATE OR REPLACE VIEW vw_product_inventory_health AS
SELECT 
    p.product_id,
    p.sku_code,
    p.product_name,
    p.category_name,
    COUNT(f.order_id) AS total_order_events,
    SUM(f.units_sold) AS total_units_sold,
    ROUND(AVG(f.stock_quantity), 1) AS avg_on_hand_stock,
    ROUND(AVG(f.reorder_level), 1) AS avg_reorder_threshold,
    SUM(f.stockout_flag) AS total_stockouts,
    ROUND(SUM(f.stockout_flag) * 100.0 / COUNT(f.order_id), 2) AS stockout_frequency_pct,
    SUM(f.understock_flag) AS total_understock_events,
    ROUND(SUM(f.understock_flag) * 100.0 / COUNT(f.order_id), 2) AS understock_rate_pct,
    SUM(f.fulfillment_deficit_units) AS cumulative_unmet_demand_units,
    ROUND(SUM(f.total_revenue), 2) AS total_product_revenue,
    ROUND(SUM(f.gross_profit), 2) AS total_gross_profit,
    ROUND(SUM(f.gross_profit) * 100.0 / NULLIF(SUM(f.total_revenue), 0), 2) AS profit_margin_pct,
    ROUND(CAST(SUM(f.units_sold) AS NUMERIC) / NULLIF(AVG(f.stock_quantity), 0), 2) AS inventory_turnover_proxy
FROM dim_products p
JOIN fact_supply_chain_orders f ON p.product_id = f.product_id
GROUP BY p.product_id, p.sku_code, p.product_name, p.category_name;

-- ----------------------------------------------------------------------------
-- VIEW 4: MONTHLY DELIVERY SLA & VELOCITY TRENDS
-- ----------------------------------------------------------------------------
-- Business Value: Tracks monthly temporal trajectory of order volumes, delivery
-- performance, logistics expenditure, and on-time compliance.
CREATE OR REPLACE VIEW vw_monthly_delivery_sla_trends AS
SELECT 
    d.year_month,
    d.year,
    d.month,
    d.month_name,
    COUNT(f.order_id) AS total_orders,
    SUM(f.units_sold) AS total_units_sold,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_lead_time_days,
    ROUND(SUM(f.is_on_time) * 100.0 / COUNT(f.order_id), 2) AS on_time_delivery_pct,
    SUM(CASE WHEN f.is_on_time = 0 THEN 1 ELSE 0 END) AS delayed_orders_count,
    ROUND(AVG(CASE WHEN f.delivery_delay_days > 0 THEN f.delivery_delay_days ELSE NULL END), 2) AS avg_delay_when_delayed,
    ROUND(SUM(f.total_revenue), 2) AS monthly_revenue,
    ROUND(SUM(f.logistics_cost), 2) AS monthly_logistics_cost,
    ROUND(SUM(f.logistics_cost) * 100.0 / NULLIF(SUM(f.total_revenue), 0), 3) AS logistics_cost_ratio_pct
FROM dim_date d
JOIN fact_supply_chain_orders f ON d.date_key = f.order_date
GROUP BY d.year_month, d.year, d.month, d.month_name;

-- ----------------------------------------------------------------------------
-- VIEW 5: CATEGORY PROFITABILITY & LOGISTICS EXPENSE BURDEN
-- ----------------------------------------------------------------------------
-- Business Value: Evaluates gross margins versus logistics cost burden across
-- merchandise categories to spot logistics margin leakage.
CREATE OR REPLACE VIEW vw_category_profitability_logistics AS
SELECT 
    c.category_id,
    c.category_name,
    c.target_margin_pct,
    COUNT(f.order_id) AS total_orders,
    SUM(f.units_sold) AS total_units_sold,
    ROUND(SUM(f.total_revenue), 2) AS gross_revenue,
    ROUND(SUM(f.total_cogs), 2) AS total_cogs,
    ROUND(SUM(f.gross_profit), 2) AS gross_profit,
    ROUND(SUM(f.gross_profit) * 100.0 / NULLIF(SUM(f.total_revenue), 0), 2) AS actual_margin_pct,
    ROUND(SUM(f.logistics_cost), 2) AS total_logistics_cost,
    ROUND(SUM(f.net_profit), 2) AS net_operating_profit,
    ROUND(SUM(f.net_profit) * 100.0 / NULLIF(SUM(f.total_revenue), 0), 2) AS net_margin_pct,
    ROUND(SUM(f.logistics_cost) * 100.0 / NULLIF(SUM(f.gross_profit), 0), 2) AS logistics_cost_of_profit_pct
FROM dim_categories c
JOIN dim_products p ON c.category_id = p.category_id
JOIN fact_supply_chain_orders f ON p.product_id = f.product_id
GROUP BY c.category_id, c.category_name, c.target_margin_pct;

-- ----------------------------------------------------------------------------
-- VIEW 6: MULTI-DIMENSIONAL OPERATIONAL RISK RADAR
-- ----------------------------------------------------------------------------
-- Business Value: Categorizes operational risk matrices across inventory stock
-- status and delivery SLA status, highlighting immediate escalation points.
CREATE OR REPLACE VIEW vw_operational_risk_radar AS
SELECT 
    f.inventory_risk_category,
    f.delivery_risk_category,
    COUNT(f.order_id) AS incident_count,
    ROUND(COUNT(f.order_id) * 100.0 / 15000.0, 2) AS share_of_total_orders_pct,
    SUM(f.fulfillment_deficit_units) AS total_deficit_units,
    ROUND(SUM(f.total_revenue), 2) AS revenue_at_stake,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_shipping_time_days,
    ROUND(AVG(f.delivery_delay_days), 2) AS avg_delay_days,
    ROUND(SUM(f.logistics_cost), 2) AS incurred_logistics_cost
FROM fact_supply_chain_orders f
GROUP BY f.inventory_risk_category, f.delivery_risk_category;

-- ----------------------------------------------------------------------------
-- VIEW 7: ORDER LEAD TIME DISTRIBUTION BREAKDOWN
-- ----------------------------------------------------------------------------
-- Business Value: Bins order counts and costs across shipping turnaround times
-- from 1 to 10 days to expose lead time bottlenecks.
CREATE OR REPLACE VIEW vw_order_lead_time_distribution AS
SELECT 
    f.shipping_time_days,
    CASE 
        WHEN f.shipping_time_days <= 2 THEN '1-2 Days (Express)'
        WHEN f.shipping_time_days <= 5 THEN '3-5 Days (Standard SLA Met)'
        WHEN f.shipping_time_days <= 7 THEN '6-7 Days (Minor Delay)'
        ELSE '8-10 Days (Severe Delay)'
    END AS lead_time_cohort,
    COUNT(f.order_id) AS order_volume,
    ROUND(COUNT(f.order_id) * 100.0 / 15000.0, 2) AS order_volume_pct,
    SUM(f.units_sold) AS total_units_shipped,
    ROUND(AVG(f.delivery_delay_days), 2) AS avg_delay_days,
    ROUND(SUM(f.logistics_cost), 2) AS total_logistics_cost,
    ROUND(AVG(f.logistics_cost), 2) AS avg_cost_per_order
FROM fact_supply_chain_orders f
GROUP BY 
    f.shipping_time_days,
    CASE 
        WHEN f.shipping_time_days <= 2 THEN '1-2 Days (Express)'
        WHEN f.shipping_time_days <= 5 THEN '3-5 Days (Standard SLA Met)'
        WHEN f.shipping_time_days <= 7 THEN '6-7 Days (Minor Delay)'
        ELSE '8-10 Days (Severe Delay)'
    END;

-- ----------------------------------------------------------------------------
-- VIEW 8: SUPPLIER OPERATIONAL RISK TIERING MATRIX
-- ----------------------------------------------------------------------------
-- Business Value: Ranks suppliers into High, Medium, or Low Operational Risk
-- based on delivery failure rates, fulfillment deficits, and delay severity.
CREATE OR REPLACE VIEW vw_supplier_risk_tiering AS
WITH supplier_metrics AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(f.order_id) AS total_orders,
        ROUND(SUM(f.is_on_time) * 100.0 / COUNT(f.order_id), 2) AS on_time_pct,
        ROUND(SUM(CASE WHEN f.fulfillment_status != 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS deficit_rate_pct,
        ROUND(AVG(f.delivery_delay_days), 2) AS avg_delay_days,
        ROUND(SUM(f.total_revenue), 2) AS total_revenue
    FROM dim_suppliers s
    JOIN fact_supply_chain_orders f ON s.supplier_id = f.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
)
SELECT 
    supplier_id,
    supplier_name,
    total_orders,
    on_time_pct,
    deficit_rate_pct,
    avg_delay_days,
    total_revenue,
    CASE 
        WHEN on_time_pct < 49.5 AND deficit_rate_pct > 30.0 THEN 'High Risk (Vendor Review Required)'
        WHEN on_time_pct < 50.0 OR deficit_rate_pct > 29.5 THEN 'Medium Risk (Monitor Closely)'
        ELSE 'Low Risk (Preferred Partner)'
    END AS operational_risk_status,
    DENSE_RANK() OVER (ORDER BY on_time_pct DESC, deficit_rate_pct ASC) AS performance_rank
FROM supplier_metrics;
