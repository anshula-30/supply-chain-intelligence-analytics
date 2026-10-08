-- ============================================================================
-- SUPPLY CHAIN INTELLIGENCE & OPERATIONS ANALYTICS PLATFORM
-- Analytical SQL Queries (Master Suite - 28 Comprehensive Queries)
-- ============================================================================
-- Compatible with: PostgreSQL 13+, MySQL 8.0+, SQLite 3
-- Author: B.Tech Computer Engineering Final Year Project
-- ============================================================================

-- ============================================================================
-- PILLAR 1: SUPPLIER PERFORMANCE & RELIABILITY ANALYTICS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 01: Supplier Lead Time & SLA Breach Analysis
-- Business Question: Which suppliers have the highest delivery delay rate against
-- the contractual SLA of 5 days, and what is their average delay?
-- ----------------------------------------------------------------------------
SELECT 
    s.supplier_id,
    s.supplier_name,
    COUNT(f.order_id) AS total_orders,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_lead_time_days,
    SUM(CASE WHEN f.shipping_time_days > s.lead_time_sla_days THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(SUM(CASE WHEN f.shipping_time_days > s.lead_time_sla_days THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS sla_breach_rate_pct,
    ROUND(AVG(CASE WHEN f.shipping_time_days > s.lead_time_sla_days THEN f.delivery_delay_days ELSE NULL END), 2) AS avg_delay_when_late
FROM dim_suppliers s
JOIN fact_supply_chain_orders f ON s.supplier_id = f.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY sla_breach_rate_pct DESC;


-- ----------------------------------------------------------------------------
-- QUERY 02: Supplier Fulfillment Reliability & Deficit Volume
-- Business Question: What proportion of orders from each supplier encounter inventory
-- deficits (demand > on-hand stock), and what is the total unmet quantity?
-- ----------------------------------------------------------------------------
SELECT 
    s.supplier_id,
    s.supplier_name,
    COUNT(f.order_id) AS total_orders,
    SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) AS fully_fulfilled_orders,
    ROUND(SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS fulfillment_rate_pct,
    SUM(CASE WHEN f.fulfillment_status != 'Fulfilled' THEN 1 ELSE 0 END) AS deficit_orders_count,
    ROUND(SUM(CASE WHEN f.fulfillment_status != 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS deficit_rate_pct,
    SUM(f.fulfillment_deficit_units) AS total_unmet_demand_units
FROM dim_suppliers s
JOIN fact_supply_chain_orders f ON s.supplier_id = f.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY deficit_rate_pct DESC;


-- ----------------------------------------------------------------------------
-- QUERY 03: Supplier Relative Ranking via Window Functions
-- Business Question: How do suppliers rank against each other when combining
-- on-time delivery percentage, fulfillment rate, and total revenue?
-- ----------------------------------------------------------------------------
WITH supplier_scorecard AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(f.order_id) AS total_orders,
        ROUND(SUM(f.is_on_time) * 100.0 / COUNT(f.order_id), 2) AS on_time_pct,
        ROUND(SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS fulfill_pct,
        ROUND(SUM(f.total_revenue), 2) AS total_rev,
        ROUND(
            (SUM(f.is_on_time) * 100.0 / COUNT(f.order_id)) * 0.5 + 
            (SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id)) * 0.5,
            2
        ) AS composite_score
    FROM dim_suppliers s
    JOIN fact_supply_chain_orders f ON s.supplier_id = f.supplier_id
    GROUP BY s.supplier_id, s.supplier_name
)
SELECT 
    supplier_id,
    supplier_name,
    total_orders,
    on_time_pct,
    fulfill_pct,
    composite_score,
    total_rev,
    RANK() OVER (ORDER BY composite_score DESC) AS overall_rank,
    DENSE_RANK() OVER (ORDER BY on_time_pct DESC) AS delivery_speed_rank,
    DENSE_RANK() OVER (ORDER BY fulfill_pct DESC) AS fulfillment_rank
FROM supplier_scorecard
ORDER BY overall_rank;


-- ----------------------------------------------------------------------------
-- QUERY 04: Procurement Spend & Financial Margin Generation by Supplier
-- Business Question: What is the total procurement spend (COGS) allocated to each
-- vendor, and what gross margin percentage does each generate?
-- ----------------------------------------------------------------------------
SELECT 
    s.supplier_id,
    s.supplier_name,
    SUM(f.units_sold) AS total_units_procured,
    ROUND(SUM(f.total_cogs), 2) AS total_procurement_spend,
    ROUND(SUM(f.total_revenue), 2) AS total_sales_revenue,
    ROUND(SUM(f.gross_profit), 2) AS gross_profit_generated,
    ROUND(SUM(f.gross_profit) * 100.0 / NULLIF(SUM(f.total_revenue), 0), 2) AS gross_margin_pct,
    ROUND(AVG(f.unit_purchase_cost), 2) AS avg_unit_cost,
    ROUND(AVG(f.unit_selling_price), 2) AS avg_unit_price
FROM dim_suppliers s
JOIN fact_supply_chain_orders f ON s.supplier_id = f.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_sales_revenue DESC;


-- ----------------------------------------------------------------------------
-- QUERY 05: Supplier Lead Time Consistency & Variance Analysis
-- Business Question: What is the statistical distribution (min, avg, max) of
-- shipping lead times per supplier to assess delivery predictability?
-- ----------------------------------------------------------------------------
SELECT 
    s.supplier_id,
    s.supplier_name,
    COUNT(f.order_id) AS sample_size,
    MIN(f.shipping_time_days) AS fastest_ship_days,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_ship_days,
    MAX(f.shipping_time_days) AS slowest_ship_days,
    ROUND(AVG(f.shipping_time_days * f.shipping_time_days) - (AVG(f.shipping_time_days) * AVG(f.shipping_time_days)), 2) AS variance_approx,
    SUM(CASE WHEN f.shipping_time_days >= 8 THEN 1 ELSE 0 END) AS severe_delay_orders_count
FROM dim_suppliers s
JOIN fact_supply_chain_orders f ON s.supplier_id = f.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY avg_ship_days ASC;


-- ============================================================================
-- PILLAR 2: PROCUREMENT & INVENTORY HEALTH ANALYTICS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 06: Critical Stock-Out Incident Identification
-- Business Question: Which products and warehouses experienced complete zero-stock
-- stock-out events, and what sales revenue was lost or jeopardized?
-- ----------------------------------------------------------------------------
SELECT 
    f.order_id,
    f.order_date,
    p.product_name,
    p.category_name,
    w.city AS warehouse_city,
    s.supplier_name,
    f.units_sold AS demand_units,
    f.stock_quantity AS on_hand_stock,
    f.total_revenue AS jeopardized_revenue,
    f.shipping_time_days
FROM fact_supply_chain_orders f
JOIN dim_products p ON f.product_id = p.product_id
JOIN dim_warehouses w ON f.warehouse_id = w.warehouse_id
JOIN dim_suppliers s ON f.supplier_id = s.supplier_id
WHERE f.stockout_flag = 1
ORDER BY f.order_date DESC;


-- ----------------------------------------------------------------------------
-- QUERY 07: Safety Stock Breach / Understock Warning Analysis
-- Business Question: Which product SKUs breach reorder thresholds most frequently,
-- indicating chronic replenishment lags?
-- ----------------------------------------------------------------------------
SELECT 
    p.product_id,
    p.product_name,
    p.category_name,
    COUNT(f.order_id) AS total_orders,
    SUM(f.understock_flag) AS understock_incidents,
    ROUND(SUM(f.understock_flag) * 100.0 / COUNT(f.order_id), 2) AS understock_frequency_pct,
    ROUND(AVG(f.stock_quantity), 1) AS avg_stock_level,
    ROUND(AVG(f.reorder_level), 1) AS avg_reorder_level,
    ROUND(AVG(f.reorder_level - f.stock_quantity), 1) AS avg_deficit_below_threshold
FROM dim_products p
JOIN fact_supply_chain_orders f ON p.product_id = f.product_id
GROUP BY p.product_id, p.product_name, p.category_name
HAVING SUM(f.understock_flag) > 0
ORDER BY understock_frequency_pct DESC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- QUERY 08: Pareto ABC Inventory Classification by Product Revenue
-- Business Question: What is the cumulative revenue contribution of each product,
-- classifying them into Class A (Top 70%), Class B (Next 20%), and Class C (Bottom 10%)?
-- ----------------------------------------------------------------------------
WITH product_sales AS (
    SELECT 
        p.product_name,
        SUM(f.units_sold) AS total_units,
        ROUND(SUM(f.total_revenue), 2) AS total_rev
    FROM dim_products p
    JOIN fact_supply_chain_orders f ON p.product_id = f.product_id
    GROUP BY p.product_name
),
ranked_sales AS (
    SELECT 
        product_name,
        total_units,
        total_rev,
        SUM(total_rev) OVER (ORDER BY total_rev DESC) AS running_cumulative_rev,
        SUM(total_rev) OVER () AS total_enterprise_rev
    FROM product_sales
)
SELECT 
    product_name,
    total_units,
    total_rev,
    ROUND(running_cumulative_rev * 100.0 / total_enterprise_rev, 2) AS cumulative_rev_pct,
    CASE 
        WHEN (running_cumulative_rev * 100.0 / total_enterprise_rev) <= 70.0 THEN 'Class A (Core Revenue Driver)'
        WHEN (running_cumulative_rev * 100.0 / total_enterprise_rev) <= 90.0 THEN 'Class B (Moderate Revenue)'
        ELSE 'Class C (Marginal Volume)'
    END AS abc_classification
FROM ranked_sales
ORDER BY total_rev DESC;


-- ----------------------------------------------------------------------------
-- QUERY 09: Overstocked SKUs & Working Capital Inefficiency
-- Business Question: Which products hold excess buffer stock (>3x reorder level),
-- unnecessarily tying up working capital and warehouse footprint?
-- ----------------------------------------------------------------------------
SELECT 
    p.category_name,
    p.product_name,
    COUNT(f.order_id) AS total_transactions,
    SUM(CASE WHEN f.stock_quantity > (3 * f.reorder_level) THEN 1 ELSE 0 END) AS overstock_orders_count,
    ROUND(SUM(CASE WHEN f.stock_quantity > (3 * f.reorder_level) THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS overstock_incidence_pct,
    ROUND(AVG(f.stock_quantity), 1) AS avg_stock,
    ROUND(AVG(f.reorder_level), 1) AS avg_reorder_level
FROM dim_products p
JOIN fact_supply_chain_orders f ON p.product_id = f.product_id
GROUP BY p.category_name, p.product_name
ORDER BY overstock_incidence_pct DESC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- QUERY 10: Inventory Turnover Ratio Proxy by Category
-- Business Question: What is the velocity of stock rotation (Units Sold / Average Stock)
-- across each merchandising category?
-- ----------------------------------------------------------------------------
SELECT 
    c.category_name,
    COUNT(f.order_id) AS total_orders,
    SUM(f.units_sold) AS total_units_sold,
    ROUND(AVG(f.stock_quantity), 1) AS avg_warehouse_stock,
    ROUND(CAST(SUM(f.units_sold) AS NUMERIC) / NULLIF(AVG(f.stock_quantity), 0), 2) AS inventory_turnover_ratio,
    ROUND(SUM(f.total_revenue), 2) AS total_revenue
FROM dim_categories c
JOIN dim_products p ON c.category_id = p.category_id
JOIN fact_supply_chain_orders f ON p.product_id = f.product_id
GROUP BY c.category_name
ORDER BY inventory_turnover_ratio DESC;


-- ============================================================================
-- PILLAR 3: WAREHOUSE & DISTRIBUTION OPERATIONS ANALYTICS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 11: Warehouse Fulfillment Throughput & Stock Adequacy
-- Business Question: How do the 5 regional logistics hubs compare in dispatch volume,
-- on-time delivery rate, and fulfillment deficit rate?
-- ----------------------------------------------------------------------------
SELECT 
    w.warehouse_id,
    w.city,
    w.region,
    COUNT(f.order_id) AS total_orders,
    SUM(f.units_sold) AS total_units_shipped,
    ROUND(SUM(f.is_on_time) * 100.0 / COUNT(f.order_id), 2) AS on_time_delivery_pct,
    SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) AS fully_fulfilled_orders,
    ROUND(SUM(CASE WHEN f.fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS fulfillment_rate_pct,
    SUM(f.stockout_flag) AS stockouts_logged,
    ROUND(SUM(f.total_revenue), 2) AS total_revenue
FROM dim_warehouses w
JOIN fact_supply_chain_orders f ON w.warehouse_id = f.warehouse_id
GROUP BY w.warehouse_id, w.city, w.region
ORDER BY total_units_shipped DESC;


-- ----------------------------------------------------------------------------
-- QUERY 12: Regional Warehouse Transit Efficiency & Delay Penalties
-- Business Question: What is the average transit duration per warehouse hub,
-- and what is the typical delay duration when shipments breach SLA?
-- ----------------------------------------------------------------------------
SELECT 
    w.city,
    w.region,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_shipping_days,
    SUM(CASE WHEN f.delivery_delay_days > 0 THEN 1 ELSE 0 END) AS delayed_shipments_count,
    ROUND(SUM(CASE WHEN f.delivery_delay_days > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS delay_incidence_pct,
    ROUND(AVG(CASE WHEN f.delivery_delay_days > 0 THEN f.delivery_delay_days ELSE NULL END), 2) AS avg_delay_days_when_delayed,
    MAX(f.delivery_delay_days) AS max_single_delay_days
FROM dim_warehouses w
JOIN fact_supply_chain_orders f ON w.warehouse_id = f.warehouse_id
GROUP BY w.city, w.region
ORDER BY avg_shipping_days ASC;


-- ----------------------------------------------------------------------------
-- QUERY 13: Warehouse Logistics Freight Burden & Cost per Unit
-- Business Question: How much total logistics and freight expenditure is absorbed
-- by each warehouse, and what is the freight cost per unit shipped?
-- ----------------------------------------------------------------------------
SELECT 
    w.city,
    w.region,
    SUM(f.units_sold) AS total_units,
    ROUND(SUM(f.logistics_cost), 2) AS total_logistics_cost,
    ROUND(AVG(f.logistics_cost), 2) AS avg_logistics_cost_per_order,
    ROUND(SUM(f.logistics_cost) / NULLIF(SUM(f.units_sold), 0), 2) AS logistics_cost_per_unit,
    ROUND(SUM(f.logistics_cost) * 100.0 / NULLIF(SUM(f.total_revenue), 0), 2) AS logistics_to_revenue_pct
FROM dim_warehouses w
JOIN fact_supply_chain_orders f ON w.warehouse_id = f.warehouse_id
GROUP BY w.city, w.region
ORDER BY total_logistics_cost DESC;


-- ----------------------------------------------------------------------------
-- QUERY 14: Cross-Regional Demand vs Stock Imbalance (Deficit Density)
-- Business Question: Which warehouse locations have the highest proportion of orders
-- where on-hand inventory failed to meet customer demand?
-- ----------------------------------------------------------------------------
SELECT 
    w.city AS warehouse_location,
    w.region,
    COUNT(f.order_id) AS total_orders,
    SUM(CASE WHEN f.stock_quantity < f.units_sold THEN 1 ELSE 0 END) AS deficit_orders,
    ROUND(SUM(CASE WHEN f.stock_quantity < f.units_sold THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS deficit_order_pct,
    SUM(f.fulfillment_deficit_units) AS total_deficit_units,
    ROUND(SUM(f.fulfillment_deficit_units * f.unit_selling_price), 2) AS estimated_lost_sales_value
FROM dim_warehouses w
JOIN fact_supply_chain_orders f ON w.warehouse_id = f.warehouse_id
GROUP BY w.city, w.region
ORDER BY deficit_order_pct DESC;


-- ----------------------------------------------------------------------------
-- QUERY 15: Warehouse Capacity Utilization Throughput Proxy
-- Business Question: What is the throughput density (Units Sold per sq ft of storage)
-- across the distribution network?
-- ----------------------------------------------------------------------------
SELECT 
    w.warehouse_name,
    w.city,
    w.storage_capacity_sqft,
    SUM(f.units_sold) AS total_units_processed,
    ROUND(CAST(SUM(f.units_sold) AS NUMERIC) / w.storage_capacity_sqft, 2) AS throughput_units_per_sqft,
    ROUND(SUM(f.total_revenue) / w.storage_capacity_sqft, 2) AS revenue_yield_per_sqft
FROM dim_warehouses w
JOIN fact_supply_chain_orders f ON w.warehouse_id = f.warehouse_id
GROUP BY w.warehouse_name, w.city, w.storage_capacity_sqft
ORDER BY throughput_units_per_sqft DESC;


-- ============================================================================
-- PILLAR 4: ORDER FULFILLMENT & DELIVERY PERFORMANCE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 16: Order Fulfillment Tiers Breakdown
-- Business Question: What is the comprehensive breakdown of order fulfillment states
-- across the entire business?
-- ----------------------------------------------------------------------------
SELECT 
    f.fulfillment_status,
    COUNT(f.order_id) AS order_count,
    ROUND(COUNT(f.order_id) * 100.0 / 15000.0, 2) AS percentage_of_orders,
    SUM(f.units_sold) AS total_units_sold,
    SUM(f.fulfillment_deficit_units) AS total_unfulfilled_units,
    ROUND(SUM(f.total_revenue), 2) AS total_revenue_inr
FROM fact_supply_chain_orders f
GROUP BY f.fulfillment_status
ORDER BY order_count DESC;


-- ----------------------------------------------------------------------------
-- QUERY 17: Delivery Lead Time Cohort Analysis
-- Business Question: How are order shipments distributed across lead time cohorts,
-- from Express delivery to Severe Delay?
-- ----------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN f.shipping_time_days <= 2 THEN '1-2 Days: Express (Tier 1)'
        WHEN f.shipping_time_days <= 5 THEN '3-5 Days: Standard SLA Met (Tier 2)'
        WHEN f.shipping_time_days <= 7 THEN '6-7 Days: Minor Delay (Tier 3)'
        ELSE '8-10 Days: Severe Delay (Tier 4)'
    END AS shipping_duration_cohort,
    COUNT(f.order_id) AS total_orders,
    ROUND(COUNT(f.order_id) * 100.0 / 15000.0, 2) AS volume_share_pct,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_days_in_transit,
    ROUND(AVG(f.logistics_cost), 2) AS avg_logistics_cost,
    ROUND(SUM(f.total_revenue), 2) AS cohort_revenue
FROM fact_supply_chain_orders f
GROUP BY 
    CASE 
        WHEN f.shipping_time_days <= 2 THEN '1-2 Days: Express (Tier 1)'
        WHEN f.shipping_time_days <= 5 THEN '3-5 Days: Standard SLA Met (Tier 2)'
        WHEN f.shipping_time_days <= 7 THEN '6-7 Days: Minor Delay (Tier 3)'
        ELSE '8-10 Days: Severe Delay (Tier 4)'
    END
ORDER BY avg_days_in_transit ASC;


-- ----------------------------------------------------------------------------
-- QUERY 18: Day of Week Order Arrival and Delay Patterns
-- Business Question: Do orders placed on weekends or specific days of the week
-- suffer higher shipping transit delays?
-- ----------------------------------------------------------------------------
SELECT 
    d.day_name,
    d.day_of_week,
    d.is_weekend,
    COUNT(f.order_id) AS orders_placed,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_shipping_time,
    ROUND(SUM(f.is_on_time) * 100.0 / COUNT(f.order_id), 2) AS on_time_rate_pct,
    ROUND(AVG(f.delivery_delay_days), 2) AS avg_delay_days,
    ROUND(SUM(f.total_revenue), 2) AS total_revenue
FROM dim_date d
JOIN fact_supply_chain_orders f ON d.date_key = f.order_date
GROUP BY d.day_name, d.day_of_week, d.is_weekend
ORDER BY d.day_of_week ASC;


-- ----------------------------------------------------------------------------
-- QUERY 19: Cumulative Chronological Revenue Progression
-- Business Question: What is the cumulative chronological progression of revenue
-- and orders across the two-year operating timeline?
-- ----------------------------------------------------------------------------
WITH monthly_rollup AS (
    SELECT 
        d.year_month,
        COUNT(f.order_id) AS monthly_orders,
        SUM(f.units_sold) AS monthly_units,
        ROUND(SUM(f.total_revenue), 2) AS monthly_revenue
    FROM dim_date d
    JOIN fact_supply_chain_orders f ON d.date_key = f.order_date
    GROUP BY d.year_month
)
SELECT 
    year_month,
    monthly_orders,
    monthly_units,
    monthly_revenue,
    SUM(monthly_orders) OVER (ORDER BY year_month) AS running_total_orders,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY year_month), 2) AS running_total_revenue
FROM monthly_rollup
ORDER BY year_month;


-- ----------------------------------------------------------------------------
-- QUERY 20: 30-Day Rolling Average Shipping Lead Time
-- Business Question: How has the 30-day moving average of shipping lead time
-- trended across days to identify seasonal spikes?
-- ----------------------------------------------------------------------------
WITH daily_lead_time AS (
    SELECT 
        f.order_date,
        COUNT(f.order_id) AS daily_order_count,
        AVG(f.shipping_time_days) AS daily_avg_lead_time
    FROM fact_supply_chain_orders f
    GROUP BY f.order_date
)
SELECT 
    order_date,
    daily_order_count,
    ROUND(daily_avg_lead_time, 2) AS daily_avg_lead_time,
    ROUND(AVG(daily_avg_lead_time) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_30day_avg_lead_time
FROM daily_lead_time
ORDER BY order_date DESC
LIMIT 30;


-- ============================================================================
-- PILLAR 5: LOGISTICS COST & FINANCIAL MARGINS ANALYTICS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 21: Logistics Cost as a Share of Gross Revenue and Margin
-- Business Question: How much does freight and distribution cost consume from gross
-- revenue and gross profit across categories?
-- ----------------------------------------------------------------------------
SELECT 
    c.category_name,
    ROUND(SUM(f.total_revenue), 2) AS gross_revenue,
    ROUND(SUM(f.gross_profit), 2) AS gross_profit,
    ROUND(SUM(f.logistics_cost), 2) AS logistics_cost,
    ROUND(SUM(f.net_profit), 2) AS net_profit,
    ROUND(SUM(f.logistics_cost) * 100.0 / NULLIF(SUM(f.total_revenue), 0), 2) AS logistics_to_revenue_pct,
    ROUND(SUM(f.logistics_cost) * 100.0 / NULLIF(SUM(f.gross_profit), 0), 2) AS logistics_to_gross_profit_pct,
    ROUND(SUM(f.net_profit) * 100.0 / NULLIF(SUM(f.total_revenue), 0), 2) AS net_profit_margin_pct
FROM dim_categories c
JOIN dim_products p ON c.category_id = p.category_id
JOIN fact_supply_chain_orders f ON p.product_id = f.product_id
GROUP BY c.category_name
ORDER BY gross_revenue DESC;


-- ----------------------------------------------------------------------------
-- QUERY 22: High-Cost Logistics Outlier Detection
-- Business Question: Which orders have the highest logistics cost per unit shipped,
-- indicating inefficient freight utilization?
-- ----------------------------------------------------------------------------
SELECT 
    f.order_id,
    f.order_date,
    p.product_name,
    w.city AS warehouse_city,
    f.units_sold,
    f.shipping_time_days,
    ROUND(f.logistics_cost, 2) AS logistics_cost,
    ROUND(f.logistics_cost / NULLIF(f.units_sold, 0), 2) AS cost_per_unit,
    ROUND(f.total_revenue, 2) AS order_revenue,
    ROUND(f.logistics_cost * 100.0 / NULLIF(f.total_revenue, 0), 2) AS freight_to_revenue_pct
FROM fact_supply_chain_orders f
JOIN dim_products p ON f.product_id = p.product_id
JOIN dim_warehouses w ON f.warehouse_id = w.warehouse_id
WHERE f.units_sold > 0
ORDER BY cost_per_unit DESC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- QUERY 23: Net Profit Margin Ranking by Product SKU
-- Business Question: What are the top 10 most profitable products and bottom 5 least
-- profitable products based on Net Operating Margin (Gross Margin - Logistics Cost)?
-- ----------------------------------------------------------------------------
WITH sku_profitability AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category_name,
        SUM(f.units_sold) AS units_sold,
        ROUND(SUM(f.total_revenue), 2) AS total_revenue,
        ROUND(SUM(f.gross_profit), 2) AS gross_profit,
        ROUND(SUM(f.logistics_cost), 2) AS logistics_cost,
        ROUND(SUM(f.net_profit), 2) AS net_profit,
        ROUND(SUM(f.net_profit) * 100.0 / NULLIF(SUM(f.total_revenue), 0), 2) AS net_margin_pct
    FROM dim_products p
    JOIN fact_supply_chain_orders f ON p.product_id = f.product_id
    GROUP BY p.product_id, p.product_name, p.category_name
)
SELECT 
    product_id,
    product_name,
    category_name,
    units_sold,
    total_revenue,
    net_profit,
    net_margin_pct,
    DENSE_RANK() OVER (ORDER BY net_profit DESC) AS rank_by_net_profit,
    DENSE_RANK() OVER (ORDER BY net_margin_pct DESC) AS rank_by_margin_pct
FROM sku_profitability
ORDER BY net_profit DESC
LIMIT 15;


-- ----------------------------------------------------------------------------
-- QUERY 24: Month-over-Month Revenue Growth & Shipping Trend
-- Business Question: What was the month-over-month revenue growth rate and shipping
-- time progression across all months using LAG()?
-- ----------------------------------------------------------------------------
WITH monthly_data AS (
    SELECT 
        d.year_month,
        COUNT(f.order_id) AS total_orders,
        ROUND(SUM(f.total_revenue), 2) AS monthly_revenue,
        ROUND(AVG(f.shipping_time_days), 2) AS avg_shipping_days
    FROM dim_date d
    JOIN fact_supply_chain_orders f ON d.date_key = f.order_date
    GROUP BY d.year_month
)
SELECT 
    year_month,
    total_orders,
    monthly_revenue,
    LAG(monthly_revenue, 1) OVER (ORDER BY year_month) AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY year_month)) * 100.0 / 
        NULLIF(LAG(monthly_revenue, 1) OVER (ORDER BY year_month), 0),
        2
    ) AS mom_revenue_growth_pct,
    avg_shipping_days,
    ROUND(avg_shipping_days - LAG(avg_shipping_days, 1) OVER (ORDER BY year_month), 2) AS lead_time_change_days
FROM monthly_data
ORDER BY year_month;


-- ============================================================================
-- PILLAR 6: MULTI-DIMENSIONAL OPERATIONAL RISK SCORING
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 25: High-Risk Supplier Identification Matrix
-- Business Question: Which suppliers are categorized as High Risk based on combined
-- late delivery frequency (>50%) and high fulfillment deficit (>29.5%)?
-- ----------------------------------------------------------------------------
SELECT 
    s.supplier_id,
    s.supplier_name,
    COUNT(f.order_id) AS total_orders,
    ROUND(SUM(f.is_on_time) * 100.0 / COUNT(f.order_id), 2) AS on_time_delivery_pct,
    ROUND(SUM(CASE WHEN f.fulfillment_status != 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS fulfillment_deficit_pct,
    ROUND(AVG(f.delivery_delay_days), 2) AS avg_delay_days,
    ROUND(SUM(f.fulfillment_deficit_units), 0) AS unmet_demand_units,
    CASE 
        WHEN (SUM(f.is_on_time) * 100.0 / COUNT(f.order_id)) < 49.5 
             AND (SUM(CASE WHEN f.fulfillment_status != 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id)) > 30.0
        THEN 'CRITICAL HIGH RISK'
        WHEN (SUM(f.is_on_time) * 100.0 / COUNT(f.order_id)) < 50.0 
             OR (SUM(CASE WHEN f.fulfillment_status != 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id)) > 29.5
        THEN 'MODERATE RISK'
        ELSE 'LOW RISK'
    END AS supplier_risk_rating
FROM dim_suppliers s
JOIN fact_supply_chain_orders f ON s.supplier_id = f.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY fulfillment_deficit_pct DESC;


-- ----------------------------------------------------------------------------
-- QUERY 26: Inventory Vulnerability & Revenue Exposure Matrix
-- Business Question: What is the total enterprise revenue exposed across each
-- inventory risk tier (Critical Stockout, Deficit Shortfall, Understock Warning)?
-- ----------------------------------------------------------------------------
SELECT 
    f.inventory_risk_category,
    COUNT(f.order_id) AS impacted_order_count,
    ROUND(COUNT(f.order_id) * 100.0 / 15000.0, 2) AS order_exposure_pct,
    SUM(f.units_sold) AS demand_units,
    SUM(f.fulfillment_deficit_units) AS unmet_deficit_units,
    ROUND(SUM(f.total_revenue), 2) AS exposed_revenue_inr,
    ROUND(SUM(f.gross_profit), 2) AS impacted_gross_profit_inr
FROM fact_supply_chain_orders f
GROUP BY f.inventory_risk_category
ORDER BY exposed_revenue_inr DESC;


-- ----------------------------------------------------------------------------
-- QUERY 27: Delivery Risk Escalation Radar (Severe Delays >= 8 Days)
-- Business Question: How many orders experienced severe delays (8-10 days in transit),
-- and which supplier-warehouse corridors are responsible for this breakdown?
-- ----------------------------------------------------------------------------
SELECT 
    s.supplier_name,
    w.city AS warehouse_city,
    COUNT(f.order_id) AS severe_delay_orders,
    ROUND(AVG(f.shipping_time_days), 2) AS avg_transit_days,
    ROUND(AVG(f.delivery_delay_days), 2) AS avg_delay_beyond_sla,
    ROUND(SUM(f.total_revenue), 2) AS customer_revenue_at_risk
FROM fact_supply_chain_orders f
JOIN dim_suppliers s ON f.supplier_id = s.supplier_id
JOIN dim_warehouses w ON f.warehouse_id = w.warehouse_id
WHERE f.shipping_time_days >= 8
GROUP BY s.supplier_name, w.city
ORDER BY severe_delay_orders DESC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- QUERY 28: Composite Operational Bottleneck Priority Index
-- Business Question: What are the top 10 most troubled operational lanes
-- (Supplier + Warehouse Corridor) based on a combined score of delay and deficits?
-- ----------------------------------------------------------------------------
WITH lane_analytics AS (
    SELECT 
        s.supplier_name,
        w.city AS warehouse_city,
        COUNT(f.order_id) AS lane_orders,
        ROUND(AVG(f.shipping_time_days), 2) AS avg_lane_shipping_days,
        ROUND(SUM(CASE WHEN f.shipping_time_days > 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS lane_delay_pct,
        ROUND(SUM(CASE WHEN f.stock_quantity < f.units_sold THEN 1 ELSE 0 END) * 100.0 / COUNT(f.order_id), 2) AS lane_deficit_pct,
        ROUND(SUM(f.logistics_cost), 2) AS lane_logistics_cost
    FROM fact_supply_chain_orders f
    JOIN dim_suppliers s ON f.supplier_id = s.supplier_id
    JOIN dim_warehouses w ON f.warehouse_id = w.warehouse_id
    GROUP BY s.supplier_name, w.city
)
SELECT 
    supplier_name,
    warehouse_city,
    lane_orders,
    avg_lane_shipping_days,
    lane_delay_pct,
    lane_deficit_pct,
    lane_logistics_cost,
    ROUND((lane_delay_pct * 0.5) + (lane_deficit_pct * 0.5), 2) AS bottleneck_severity_score,
    DENSE_RANK() OVER (ORDER BY (lane_delay_pct * 0.5) + (lane_deficit_pct * 0.5) DESC) AS bottleneck_priority_rank
FROM lane_analytics
ORDER BY bottleneck_priority_rank ASC
LIMIT 10;
