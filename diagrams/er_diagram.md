# Entity-Relationship (ER) Diagram

The diagram below represents the complete Entity-Relationship schema for the Supply Chain Intelligence platform. All tables are structured in a Star Schema / 3NF dimensional model with primary and foreign key constraints.

```mermaid
erDiagram
    dim_suppliers ||--o{ fact_supply_chain_orders : "supplies (1:N)"
    dim_warehouses ||--o{ fact_supply_chain_orders : "fulfills (1:N)"
    dim_categories ||--o{ dim_products : "classifies (1:N)"
    dim_products ||--o{ fact_supply_chain_orders : "ordered_in (1:N)"
    dim_date ||--o{ fact_supply_chain_orders : "ordered_on (1:N)"
    dim_date ||--o{ fact_supply_chain_orders : "delivered_on (1:N)"

    dim_suppliers {
        VARCHAR_10 supplier_id PK "Unique Supplier Code"
        VARCHAR_50 supplier_name "Vendor Name"
        VARCHAR_100 contact_email "Procurement Email"
        INT lead_time_sla_days "Contractual Lead Time SLA (5)"
        VARCHAR_20 supplier_tier "Tier-1 / Tier-2"
        TIMESTAMP created_at "Audit Creation Date"
    }

    dim_warehouses {
        VARCHAR_10 warehouse_id PK "Unique Hub Code"
        VARCHAR_100 warehouse_name "Facility Title"
        VARCHAR_50 city "Metro City"
        VARCHAR_50 state "State / Territory"
        VARCHAR_20 region "North / South / West"
        INT storage_capacity_sqft "Storage Footprint (sq ft)"
        TIMESTAMP created_at "Audit Creation Date"
    }

    dim_categories {
        VARCHAR_10 category_id PK "Category Code"
        VARCHAR_50 category_name "Category Description"
        DECIMAL target_margin_pct "Target Margin % (20.00)"
        TIMESTAMP created_at "Audit Creation Date"
    }

    dim_products {
        VARCHAR_20 product_id PK "Product SKU Code"
        VARCHAR_30 sku_code "Catalog SKU Identifier"
        VARCHAR_50 product_name "Product Title"
        VARCHAR_10 category_id FK "Parent Category Reference"
        VARCHAR_50 category_name "Category Name"
        INT standard_reorder_level "Safety Reorder Threshold"
        TIMESTAMP created_at "Audit Creation Date"
    }

    dim_date {
        DATE date_key PK "Calendar Date (YYYY-MM-DD)"
        DATE full_date "Standard Date"
        INT year "Year (2023, 2024, 2025)"
        VARCHAR_5 quarter "Quarter (Q1 - Q4)"
        VARCHAR_10 year_quarter "Compound Quarter (2023-Q1)"
        INT month "Month Index (1 - 12)"
        VARCHAR_20 month_name "Full Month Name"
        VARCHAR_10 year_month "Compound Month (2023-01)"
        INT day_of_month "Day Number (1 - 31)"
        INT day_of_week "Day of Week (1 - 7)"
        VARCHAR_20 day_name "Weekday Name"
        SMALLINT is_weekend "1 if Weekend, else 0"
    }

    fact_supply_chain_orders {
        VARCHAR_20 order_id PK "Unique Order Number"
        VARCHAR_20 raw_record_id "Raw Dataset Identifier"
        DATE order_date FK "Order Date (Active Date Link)"
        DATE delivery_date FK "Delivery Date (Inactive Date Link)"
        VARCHAR_20 product_id FK "Product SKU Reference"
        VARCHAR_10 supplier_id FK "Supplier Reference"
        VARCHAR_10 warehouse_id FK "Fulfillment Hub Reference"
        INT units_sold "Sales Quantity Demanded"
        DECIMAL unit_purchase_cost "Unit Procurement Cost (COGS)"
        DECIMAL unit_selling_price "Unit Selling Price"
        INT stock_quantity "On-Hand Warehouse Inventory"
        INT reorder_level "Replenishment Threshold"
        INT shipping_time_days "Elapsed Transit Days (1 - 10)"
        INT target_lead_time_days "Contractual SLA Benchmark (5)"
        INT delivery_delay_days "Delay Days Beyond SLA"
        SMALLINT is_on_time "1 if On-Time, else 0"
        VARCHAR_20 fulfillment_status "Fulfilled / Partial / Stockout"
        SMALLINT stockout_flag "1 if Stock is 0, else 0"
        SMALLINT understock_flag "1 if Stock < Reorder, else 0"
        INT fulfillment_deficit_units "Unmet Demand Units"
        DECIMAL total_revenue "Gross Revenue (Units * Price)"
        DECIMAL total_cogs "Procurement Cost (Units * Cost)"
        DECIMAL gross_profit "Gross Profit (Revenue - COGS)"
        DECIMAL gross_margin_pct "Gross Margin Percentage"
        DECIMAL logistics_cost "Freight & Handling Expenditure"
        DECIMAL net_profit "Operating Profit (Profit - Freight)"
        VARCHAR_30 inventory_risk_category "Stock Risk Classification"
        VARCHAR_30 delivery_risk_category "Delivery Risk Classification"
        TIMESTAMP created_at "Audit Creation Date"
    }
```

---

## Relationship & Integrity Rules
1. **Referential Integrity**: Every order record in `fact_supply_chain_orders` is strictly bound to valid records in `dim_suppliers`, `dim_warehouses`, `dim_products`, and `dim_date`.
2. **Cardinality**: All relationships between dimensions and the fact table are **1-to-Many ($1 : N$)**, preventing many-to-many ambiguity and circular filtering paths.
3. **Primary Key Constraints**: Enforce uniqueness of order IDs, product IDs, supplier IDs, warehouse IDs, category IDs, and date keys.
4. **Domain & Check Constraints**:
   - `units_sold >= 0`
   - `stock_quantity >= 0`
   - `shipping_time_days > 0`
   - `unit_purchase_cost > 0`
   - `unit_selling_price > 0`
   - `is_on_time IN (0, 1)`
   - `stockout_flag IN (0, 1)`
   - `understock_flag IN (0, 1)`
