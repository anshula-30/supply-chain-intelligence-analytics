# Supply Chain Intelligence Platform - Data Dictionary

This document provides the formal data dictionary defining all entities, attributes, data types, constraints, and valid ranges implemented in the relational database and Power BI data model.

---

## 1. Dimension Table: `dim_suppliers`
- **Description**: Stores vendor master records, procurement contacts, contractual lead-time SLAs, and supplier tiers.
- **Grain**: 1 record per unique vendor.

| Column Name | Data Type | Nullable | Key / Constraint | Description / Valid Values |
| :--- | :--- | :--- | :--- | :--- |
| `supplier_id` | `VARCHAR(10)` | No | Primary Key | Unique vendor identifier (e.g., `SUP-A`, `SUP-B`, ..., `SUP-E`). |
| `supplier_name`| `VARCHAR(50)` | No | UNIQUE | Official name of vendor (`Supplier A` to `Supplier E`). |
| `contact_email`| `VARCHAR(100)`| Yes | None | Procurement contact email (`procurement@suppliera.com`). |
| `lead_time_sla_days`| `INT` | No | CHECK (>0), Default 5 | Agreed turnaround time in days (Contractual benchmark: 5 days). |
| `supplier_tier`| `VARCHAR(20)` | No | Default 'Tier-1' | Strategic vendor classification (`Tier-1`, `Tier-2`). |
| `created_at` | `TIMESTAMP` | No | Default Current | Record creation audit timestamp. |

---

## 2. Dimension Table: `dim_warehouses`
- **Description**: Contains geographic, operational, and facility attributes for regional fulfillment and distribution hubs.
- **Grain**: 1 record per physical distribution center.

| Column Name | Data Type | Nullable | Key / Constraint | Description / Valid Values |
| :--- | :--- | :--- | :--- | :--- |
| `warehouse_id` | `VARCHAR(10)` | No | Primary Key | Unique distribution center code (`WH-BLR`, `WH-MAA`, `WH-DEL`, `WH-HYD`, `WH-BOM`). |
| `warehouse_name` | `VARCHAR(100)`| No | None | Facility name (e.g., `Bangalore Logistics Hub`). |
| `city` | `VARCHAR(50)` | No | None | Metro city location (`Bangalore`, `Chennai`, `Delhi NCR`, `Hyderabad`, `Mumbai`). |
| `state` | `VARCHAR(50)` | No | None | State / Territory (`Karnataka`, `Tamil Nadu`, `Delhi NCR`, `Telangana`, `Maharashtra`). |
| `region` | `VARCHAR(20)` | No | None | Geographic operating territory (`South`, `North`, `West`). |
| `storage_capacity_sqft` | `INT` | No | CHECK (>0) | Usable warehouse storage footprint (45,000 to 60,000 sq ft). |

---

## 3. Dimension Table: `dim_categories`
- **Description**: High-level classification hierarchy for merchandising lines and margin targets.
- **Grain**: 1 record per merchandise category.

| Column Name | Data Type | Nullable | Key / Constraint | Description / Valid Values |
| :--- | :--- | :--- | :--- | :--- |
| `category_id` | `VARCHAR(10)` | No | Primary Key | Unique category code (`CAT-ELEC`, `CAT-FASH`, `CAT-APPL`, `CAT-SPRT`). |
| `category_name` | `VARCHAR(50)` | No | UNIQUE | Category name (`Electronics`, `Fashion`, `Home Appliances`, `Sports`). |
| `target_margin_pct` | `DECIMAL(5,2)`| No | Default 20.00 | Planned corporate gross margin benchmark (20.00%). |

---

## 4. Dimension Table: `dim_products`
- **Description**: SKU catalog mapping product lines across categories with standard replenishment triggers.
- **Grain**: 1 record per unique catalog SKU (40 SKUs).

| Column Name | Data Type | Nullable | Key / Constraint | Description / Valid Values |
| :--- | :--- | :--- | :--- | :--- |
| `product_id` | `VARCHAR(20)` | No | Primary Key | Catalog identifier (e.g., `PRD-ELEC-AC`, `PRD-FASH-CAM`). |
| `sku_code` | `VARCHAR(30)` | No | UNIQUE | Stock keeping unit code (`SKU-ELEC-AC-001`). |
| `product_name` | `VARCHAR(50)` | No | None | Commercial product title (`AC`, `Camera`, `Fan`, `Laptop`, `Mixer`, `Phone`, `Shoes`, `TV`, `Tablet`, `Watch`). |
| `category_id` | `VARCHAR(10)` | No | Foreign Key to `dim_categories` | Reference to parent category. |
| `category_name` | `VARCHAR(50)` | No | None | De-normalized category name. |
| `standard_reorder_level`| `INT` | No | CHECK (>=0) | Baseline reorder inventory threshold (typically 100 units). |

---

## 5. Dimension Table: `dim_date`
- **Description**: Conformed enterprise calendar dimension supporting time intelligence and seasonal rollups.
- **Grain**: 1 record per calendar day (2023-01-01 to 2025-01-31).

| Column Name | Data Type | Nullable | Key / Constraint | Description / Valid Values |
| :--- | :--- | :--- | :--- | :--- |
| `date_key` | `DATE` | No | Primary Key | ISO formatted calendar date (`YYYY-MM-DD`). |
| `full_date` | `DATE` | No | None | Date value. |
| `year` | `INT` | No | None | Calendar year (2023, 2024, 2025). |
| `quarter` | `VARCHAR(5)` | No | None | Quarter designation (`Q1`, `Q2`, `Q3`, `Q4`). |
| `year_quarter` | `VARCHAR(10)` | No | None | Composite year-quarter (`2023-Q1`). |
| `month` | `INT` | No | None | Month number (1 to 12). |
| `month_name` | `VARCHAR(20)` | No | None | Full month name (`January`, ..., `December`). |
| `year_month` | `VARCHAR(10)` | No | None | Composite year-month (`2023-01`). |
| `day_of_month` | `INT` | No | None | Day number within month (1 to 31). |
| `day_of_week` | `INT` | No | None | ISO weekday number (1 = Monday, 7 = Sunday). |
| `day_name` | `VARCHAR(20)` | No | None | Weekday name (`Monday`, ..., `Sunday`). |
| `is_weekend` | `SMALLINT` | No | CHECK (0, 1) | Binary weekend flag (1 if Saturday or Sunday, else 0). |

---

## 6. Fact Table: `fact_supply_chain_orders`
- **Description**: Central transactional fact table containing order fulfillment, logistics lead times, inventory levels, and financial performance.
- **Grain**: 1 record per customer order dispatch event (15,000 records).

| Column Name | Data Type | Nullable | Key / Constraint | Description / Valid Values |
| :--- | :--- | :--- | :--- | :--- |
| `order_id` | `VARCHAR(20)` | No | Primary Key | Unique order identifier (`ORD-1000` to `ORD-15999`). |
| `raw_record_id` | `VARCHAR(20)` | No | None | Raw dataset identifier (`PROD1000` to `PROD15999`). |
| `order_date` | `DATE` | No | FK to `dim_date` | Date order was placed by customer (2023-01-01 to 2024-12-31). |
| `delivery_date` | `DATE` | No | FK to `dim_date` | Date shipment was delivered (2023-01-02 to 2025-01-10). |
| `product_id` | `VARCHAR(20)` | No | FK to `dim_products` | SKU catalog reference code. |
| `supplier_id` | `VARCHAR(10)` | No | FK to `dim_suppliers` | Vendor source reference code. |
| `warehouse_id` | `VARCHAR(10)` | No | FK to `dim_warehouses`| Dispatched distribution center code. |
| `units_sold` | `INT` | No | CHECK (>=0) | Quantity of items demanded in order (0 to 300 units). |
| `unit_purchase_cost`| `DECIMAL(10,2)`| No | CHECK (>0) | Unit procurement cost (₹200 to ₹2,000). |
| `unit_selling_price`| `DECIMAL(10,2)`| No | CHECK (>0) | Unit retail sales price (₹263 to ₹2,492). |
| `stock_quantity` | `INT` | No | CHECK (>=0) | On-hand inventory in warehouse at order time (0 to 500 units). |
| `reorder_level` | `INT` | No | CHECK (>=0) | Safety stock replenishment threshold (50 to 150 units). |
| `shipping_time_days`| `INT` | No | CHECK (>0) | Elapsed transit time: `delivery_date - order_date` (1 to 10 days). |
| `target_lead_time_days`| `INT`| No | Default 5 | Standard contractual SLA target (5 days). |
| `delivery_delay_days`| `INT` | No | CHECK (>=0) | Delay beyond SLA: `MAX(0, shipping_time_days - 5)` (0 to 5 days). |
| `is_on_time` | `SMALLINT` | No | CHECK (0, 1) | 1 if `shipping_time_days <= 5`, else 0. |
| `fulfillment_status`| `VARCHAR(20)` | No | CHECK | `Fulfilled` (stock >= units), `Partial` (stock < units), `Stockout` (stock = 0). |
| `stockout_flag` | `SMALLINT` | No | CHECK (0, 1) | 1 if `stock_quantity = 0`, else 0. |
| `understock_flag`| `SMALLINT` | No | CHECK (0, 1) | 1 if `stock_quantity < reorder_level`, else 0. |
| `fulfillment_deficit_units`| `INT`| No | CHECK (>=0) | Unmet quantity: `MAX(0, units_sold - stock_quantity)`. |
| `total_revenue` | `DECIMAL(14,2)`| No | None | Gross sales value: `units_sold * unit_selling_price`. |
| `total_cogs` | `DECIMAL(14,2)`| No | None | Cost of goods sold: `units_sold * unit_purchase_cost`. |
| `gross_profit` | `DECIMAL(14,2)`| No | None | Gross profit: `total_revenue - total_cogs`. |
| `gross_margin_pct`| `DECIMAL(5,2)`| No | None | Percentage margin: `(gross_profit / total_revenue) * 100`. |
| `logistics_cost` | `DECIMAL(10,2)`| No | CHECK (>=0) | Freight cost: `120.00 + (units_sold * 2.50) + (shipping_time_days * 15.00)`. |
| `net_profit` | `DECIMAL(14,2)`| No | None | Operating profit: `gross_profit - logistics_cost`. |
| `inventory_risk_category`| `VARCHAR(30)`| No| None | Risk classification: `Critical Stockout`, `Deficit Shortfall`, `Understock Warning`, `Healthy Stock`, `Overstock Warning`. |
| `delivery_risk_category`| `VARCHAR(30)`| No| None | Delivery classification: `On-Time (Low Risk)`, `Minor Delay (Medium Risk)`, `Severe Delay (High Risk)`. |
