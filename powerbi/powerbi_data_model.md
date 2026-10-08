# Power BI Dimensional Data Model Specification

## 1. Architectural Model Overview
The analytical platform utilizes an industry-standard **Star Schema** dimensional architecture designed for optimal analytical query throughput, intuitive DAX authoring, and seamless interactive slicing.

```
+------------------+         +----------------------------+         +------------------+
|  dim_suppliers   | 1     * |  fact_supply_chain_orders  | *     1 |  dim_warehouses  |
|------------------|---------|----------------------------|---------|------------------|
| PK supplier_id   |         | PK order_id                |         | PK warehouse_id  |
|    supplier_name |         | FK order_date (active)     |         |    warehouse_name|
|    contact_email |         | FK delivery_date (inactive)|         |    city          |
|    lead_time_sla |         | FK product_id              |         |    state         |
|    supplier_tier |         | FK supplier_id             |         |    region        |
+------------------+         | FK warehouse_id            |         |    capacity_sqft |
                             |    units_sold              |         +------------------+
+------------------+         |    unit_purchase_cost      |
|    dim_date      | 1     * |    unit_selling_price      |         +------------------+
|------------------|---------|    stock_quantity          | *     1 |   dim_products   |
| PK date_key      |         |    reorder_level           |---------|------------------|
|    full_date     |         |    shipping_time_days      |         | PK product_id    |
|    year          |         |    target_lead_time_days   |         |    sku_code      |
|    quarter       |         |    delivery_delay_days     |         |    product_name  |
|    year_quarter  |         |    is_on_time              |         | FK category_id   |
|    month         |         |    fulfillment_status      |         |    category_name |
|    month_name    |         |    stockout_flag           |         |    reorder_level |
|    year_month    |         |    understock_flag         |         +--------+---------+
|    day_of_month  |         |    deficit_units           |                  | *
|    is_weekend    |         |    total_revenue           |                  | 1
+------------------+         |    total_cogs              |         +--------+---------+
                             |    gross_profit            |         |  dim_categories  |
                             |    gross_margin_pct        |         |------------------|
                             |    logistics_cost          |         | PK category_id   |
                             |    net_profit              |         |    category_name |
                             |    inv_risk_category       |         |    target_margin |
                             |    deliv_risk_category     |         +------------------+
                             +----------------------------+
```

---

## 2. Table Relationships Matrix

| From Table (Dimension) | From Column (PK) | To Table (Fact / Dim) | To Column (FK) | Cardinality | Cross Filter Direction | State |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `dim_suppliers` | `supplier_id` | `fact_supply_chain_orders` | `supplier_id` | 1 to Many (1:*) | Single (`dim_suppliers` filters fact) | Active |
| `dim_warehouses` | `warehouse_id` | `fact_supply_chain_orders` | `warehouse_id` | 1 to Many (1:*) | Single (`dim_warehouses` filters fact) | Active |
| `dim_categories` | `category_id` | `dim_products` | `category_id` | 1 to Many (1:*) | Single (`dim_categories` filters `dim_products`) | Active |
| `dim_products` | `product_id` | `fact_supply_chain_orders` | `product_id` | 1 to Many (1:*) | Single (`dim_products` filters fact) | Active |
| `dim_date` | `date_key` | `fact_supply_chain_orders` | `order_date` | 1 to Many (1:*) | Single (`dim_date` filters fact) | Active |
| `dim_date` | `date_key` | `fact_supply_chain_orders` | `delivery_date` | 1 to Many (1:*) | Single (`dim_date` filters fact) | Inactive (use via `USERELATIONSHIP`) |

---

## 3. Dedicated Measures Organization (`_Measures` Table)

To maintain an enterprise-grade model, all calculation measures are grouped into clear **Display Folders**:

1. `_Measures\01 Core Financials & Volume`
   - `[Total Orders]`, `[Total Units Sold]`, `[Total Revenue]`, `[Total COGS]`, `[Gross Profit]`, `[Gross Margin %]`, `[Total Logistics Cost]`, `[Net Operating Profit]`, `[Net Margin %]`
2. `_Measures\02 SLA & Delivery Performance`
   - `[Average Shipping Lead Time]`, `[On-Time Orders]`, `[On-Time Delivery Rate %]`, `[Delayed Orders]`, `[Delay Rate %]`, `[Average Delay Days (All Orders)]`, `[Average Delay Days (Delayed Orders Only)]`, `[Severe Delay Orders (>= 8 Days)]`, `[Severe Delay Rate %]`
3. `_Measures\03 Inventory & Fulfillment Health`
   - `[Fully Fulfilled Orders]`, `[Fulfillment Rate %]`, `[Stockout Incidents]`, `[Stockout Rate %]`, `[Understock Warning Orders]`, `[Understock Rate %]`, `[Total Fulfillment Deficit Units]`, `[Deficit Orders Count]`, `[Deficit Order Rate %]`, `[Inventory Availability %]`, `[Inventory Turnover Proxy]`
4. `_Measures\04 Supplier Intelligence`
   - `[Supplier Reliability Index]`, `[Supplier Rank by Revenue]`, `[Supplier Rank by Reliability]`
5. `_Measures\05 Time Intelligence`
   - `[Revenue Previous Month]`, `[Revenue MoM Growth %]`, `[Orders Previous Month]`, `[Orders MoM Growth %]`, `[Revenue Same Period Last Year]`, `[Revenue YoY Growth %]`, `[Rolling 30-Day Orders]`, `[Rolling 30-Day Revenue]`
6. `_Measures\06 Risk & Formatting`
   - `[Supplier Risk Category]`, `[Delivery Risk KPI Color]`, `[Inventory Risk KPI Color]`, `[Fulfillment KPI Color]`

---

## 4. Modeling Best Practices Implemented
1. **Hide Foreign Keys in Fact Table**: Columns `supplier_id`, `warehouse_id`, `product_id`, `order_date`, `delivery_date` in `fact_supply_chain_orders` are set to `Hidden` in Report View to force users to slice by Dimension tables.
2. **Sort by Column**:
   - `dim_date[month_name]` is configured with `Sort by Column` = `dim_date[month]`.
   - `dim_date[year_quarter]` is sorted by `dim_date[year_quarter]`.
   - `dim_date[day_name]` is sorted by `dim_date[day_of_week]`.
3. **Data Type & Format Strings**:
   - Currency: `Total Revenue`, `Total COGS`, `Gross Profit`, `Total Logistics Cost`, `Net Operating Profit` formatted as Currency (`₹ #,##0` or `$ #,##0`).
   - Percentage: All rates formatted as `0.00%` (e.g., `49.96%`).
   - Counts: Whole Number (`#,##0`).
   - Averages: Decimal Number (`0.00`).
