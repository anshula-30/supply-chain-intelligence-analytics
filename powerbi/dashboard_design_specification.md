# Power BI Interactive Dashboard Design Specification

## Executive Dashboard Canvas Standard
- **Page Size**: 16:9 Standard Widescreen (1280 x 720 px or 1920 x 1080 px)
- **Design Theme**: Executive Dark Slate & Clean White Palette (Modern Corporate BI)
  - Primary Accent: Navy Deep Blue (`#1A365D`)
  - Positive / On-Target: Emerald Green (`#2E7D32` or `#5CB85C`)
  - Warning / Watchlist: Amber / Gold (`#F57C00` or `#F0AD4E`)
  - Danger / SLA Breach: Crimson Coral (`#C62828` or `#D9534F`)
  - Neutral Background: Clean Canvas (`#F8F9FA`)
- **Global Header Banner (Uniform Across All 5 Pages)**:
  - Top 60px Banner containing:
    1. Project Title: **SUPPLY CHAIN INTELLIGENCE & OPERATIONS PLATFORM**
    2. Active Slicers: `dim_date[year]` (Tile / Dropdown), `dim_categories[category_name]` (Dropdown), `dim_warehouses[city]` (Dropdown), `dim_suppliers[supplier_name]` (Dropdown).
    3. Reset Slicers Bookmarks Button.

---

## PAGE 1 — Executive Supply Chain Overview
**Objective**: High-level operational cockpit for the Chief Supply Chain Officer (CSCO) & VP of Logistics providing enterprise pulse, core financial returns, delivery SLA health, and operational alerts.

### 1. KPI Callout Cards (Top Row: Y=70px, Height=100px)
- **Card 1: Total Order Volume**:
  - Value: `[Total Orders]` (15,000)
  - Subtitle / Trend: MoM Orders Growth `[Orders MoM Growth %]`
- **Card 2: Fulfillment Rate**:
  - Value: `[Fulfillment Rate %]` (70.32%)
  - Target Callout: Benchmark >= 95.0% (Color: Red / `#D9534F`)
- **Card 3: On-Time Delivery Rate**:
  - Value: `[On-Time Delivery Rate %]` (49.96%)
  - Target Callout: Contractual SLA 5 Days (Color: Red / `#D9534F`)
- **Card 4: Average Shipping Lead Time**:
  - Value: `[Average Shipping Lead Time]` (5.50 Days)
  - Subtitle: Avg Delay when Late: `3.01 Days`
- **Card 5: Total Revenue & Margin**:
  - Value: `[Total Revenue]` (₹307.63 Cr / $3.08B)
  - Subtitle: Gross Margin `19.92%` (`[Gross Margin %]`)
- **Card 6: Total Logistics Freight Spend**:
  - Value: `[Total Logistics Cost]` (₹85.93 Lakhs)
  - Subtitle: Avg Cost per Order `₹572.86`

### 2. Main Visuals (Middle & Bottom Rows)
- **Visual 1 (Line and Clustered Column Chart - Left Center)**:
  - **Title**: Monthly Order Velocity vs On-Time Delivery SLA Trajectory
  - **X-Axis**: `dim_date[year_month]`
  - **Column Values (Y1)**: `[Total Orders]`
  - **Line Values (Y2)**: `[On-Time Delivery Rate %]`
  - **Constant Reference Line**: 50.0% benchmark line
  - **Insight**: Demonstrates steady order demand with persistent ~50% delivery SLA non-compliance.
- **Visual 2 (Donut Chart - Right Top)**:
  - **Title**: Enterprise Order Fulfillment State Breakdown
  - **Legend**: `fact_supply_chain_orders[fulfillment_status]` ('Fulfilled', 'Partial', 'Stockout')
  - **Values**: `[Total Orders]`
  - **Data Labels**: Percentage of Total & Count (Fulfilled: 70.3%, Partial: 29.5%, Stockout: 0.2%)
- **Visual 3 (Clustered Bar Chart - Left Bottom)**:
  - **Title**: Category Profitability & Logistics Expense Burden
  - **Y-Axis**: `dim_categories[category_name]`
  - **X-Axis**: `[Total Revenue]` and `[Total Gross Profit]`
  - **Tooltip**: `[Total Logistics Cost]`, `[Net Margin %]`
- **Visual 4 (Table / Alert Matrix - Right Bottom)**:
  - **Title**: Critical Operational Escalations & Bottlenecks
  - **Rows**: `dim_warehouses[city]`
  - **Columns / Values**: `[Delayed Orders]`, `[Deficit Orders Count]`, `[Stockout Incidents]`, `[Total Logistics Cost]`
  - **Conditional Formatting**: Background color gradient on `[Delayed Orders]` (Red for highest delay counts).

---

## PAGE 2 — Supplier Performance & Reliability
**Objective**: Vendor evaluation matrix identifying supplier lead-time compliance, fulfillment capability, delay distributions, and risk profiling.

### 1. KPI Callout Cards (Top Row)
- `[Active Suppliers Count]` (5 Vendors: A, B, C, D, E)
- `[Supplier Reliability Index]` (Mean: 60.14%)
- `[Total Procurement Spend (COGS)]` (₹246.34 Cr)
- `[Severe Vendor Delays (>= 8 Days)]` (4,502 orders)

### 2. Main Visuals
- **Visual 1 (Scatter / Bubble Plot - Top Center)**:
  - **Title**: Supplier Performance Matrix: On-Time Delivery % vs Fulfillment Rate %
  - **X-Axis**: `[On-Time Delivery Rate %]` (49% to 51%)
  - **Y-Axis**: `[Fulfillment Rate %]` (69% to 71%)
  - **Bubble Size**: `[Total Revenue]`
  - **Details**: `dim_suppliers[supplier_name]`
  - **Quadrant Reference Lines**: X = 50.0%, Y = 70.0% (Classifying vendors into Strategic, Operational Risk, and Lagging).
- **Visual 2 (Clustered Column Chart - Bottom Left)**:
  - **Title**: Average Shipping Lead Time & Delay by Vendor
  - **X-Axis**: `dim_suppliers[supplier_name]`
  - **Y-Axis**: `[Average Shipping Lead Time]`
  - **Secondary Line**: Contractual Target Lead Time (5.0 Days)
- **Visual 3 (Matrix / Scorecard Table - Bottom Right)**:
  - **Title**: Vendor Comprehensive Performance Scorecard
  - **Rows**: `dim_suppliers[supplier_name]`
  - **Columns**: `[Total Orders]`, `[On-Time Delivery Rate %]`, `[Fulfillment Rate %]`, `[Total Fulfillment Deficit Units]`, `[Average Delay Days (Delayed Orders Only)]`, `[Supplier Risk Category]`
  - **Conditional Formatting**: Font color / icons on `[Supplier Risk Category]` (Red Icon: High Risk, Amber: Medium, Green: Low).

---

## PAGE 3 — Inventory Health & Warehouse Logistics
**Objective**: Monitoring stock availability, safety stock breaches (understock), zero-stock outages, and distribution center capacity utilization.

### 1. KPI Callout Cards (Top Row)
- `[Average On-Hand Warehouse Stock]` (250.9 Units per SKU)
- `[Critical Stockout Incidents]` (32 Events)
- `[Understock Warning Orders]` (2,992 Orders / 19.95%)
- `[Fulfillment Deficit Orders]` (4,452 Orders / 29.68%)

### 2. Main Visuals
- **Visual 1 (100% Stacked Bar Chart - Top Left)**:
  - **Title**: Inventory Operating Risk Tiers by Merchandising Category
  - **Y-Axis**: `dim_categories[category_name]`
  - **Legend**: `fact_supply_chain_orders[inventory_risk_category]` ('Critical Stockout', 'Deficit Shortfall', 'Understock Warning', 'Healthy Stock', 'Overstock Warning')
  - **Values**: `[Total Orders]`
  - **Colors**: Red (Stockout), Orange (Deficit), Yellow (Understock), Green (Healthy), Purple (Overstock).
- **Visual 2 (Clustered Column Chart - Top Right)**:
  - **Title**: Warehouse Dispatch Throughput & Stock Fulfillment
  - **X-Axis**: `dim_warehouses[city]`
  - **Values**: `[Total Units Sold]` and `[Average On-Hand Stock]`
- **Visual 3 (Treemap - Bottom Left)**:
  - **Title**: Stock Deficit Exposure by Product SKU
  - **Category**: `dim_products[category_name]` -> `dim_products[product_name]`
  - **Values**: `[Total Fulfillment Deficit Units]`
  - **Color Saturation**: `[Deficit Order Rate %]`
- **Visual 4 (Detailed Table - Bottom Right)**:
  - **Title**: Top 10 SKUs Requiring Replenishment Escalation
  - **Columns**: `Product Name`, `Category`, `Average Stock`, `Average Reorder Level`, `Understock Rate %`, `Stockout Incidents`, `Unmet Deficit Units`
  - **Sort**: `Understock Rate %` Descending.

---

## PAGE 4 — Orders & Delivery SLA Analytics
**Objective**: Tracking order throughput, lead-time frequency cohorts, geographic distribution delays, and fulfillment cycle efficiency.

### 1. KPI Callout Cards (Top Row)
- `[Total Dispatched Orders]` (15,000)
- `[On-Time Shipments]` (7,494)
- `[Delayed Shipments]` (7,506)
- `[Average Delivery Delay (Delayed Cohort)]` (3.01 Days)

### 2. Main Visuals
- **Visual 1 (Histogram / Column Chart - Top Left)**:
  - **Title**: Order Lead Time Duration Distribution (1 to 10 Days)
  - **X-Axis**: `fact_supply_chain_orders[shipping_time_days]` (1 to 10 Days)
  - **Y-Axis**: `[Total Orders]`
  - **Data Colors**: Days 1-5 = Emerald Green (SLA Met), Days 6-10 = Crimson Coral (SLA Breached).
- **Visual 2 (Map / Filled Map or Bar Chart - Top Right)**:
  - **Title**: Regional Delivery Lead Time & SLA Compliance by Warehouse City
  - **Location**: `dim_warehouses[city]`
  - **Size / Values**: `[Total Orders]`
  - **Tooltips**: `[Average Shipping Lead Time]`, `[On-Time Delivery Rate %]`, `[Delayed Orders]`
- **Visual 3 (Heatmap Matrix - Bottom Left)**:
  - **Title**: Day of Week vs Delivery SLA Compliance Matrix
  - **Rows**: `dim_date[day_name]` (Monday - Sunday)
  - **Columns**: `dim_warehouses[region]` (North, South, West)
  - **Values**: `[Average Shipping Lead Time]`
  - **Conditional Formatting**: Color gradient (Green = 5.0 days, Red = 6.0 days).
- **Visual 4 (Area Chart - Bottom Right)**:
  - **Title**: Cumulative 30-Day Rolling Order Velocity
  - **X-Axis**: `dim_date[date_key]`
  - **Values**: `[Rolling 30-Day Orders]`

---

## PAGE 5 — Logistics Cost & Operational Risk Prioritization
**Objective**: Translating supply chain operations into unit economics, identifying high-cost freight leaks, and scoring multi-dimensional operational risks.

### 1. KPI Callout Cards (Top Row)
- `[Total Logistics Cost]` (₹8,592,900)
- `[Average Cost per Order]` (₹572.86)
- `[Freight as % of Gross Revenue]` (0.28%)
- `[Freight as % of Gross Profit]` (1.40%)

### 2. Main Visuals
- **Visual 1 (Scatter Plot - Top Left)**:
  - **Title**: Unit Freight Efficiency: Order Size vs Logistics Cost per Unit
  - **X-Axis**: `fact_supply_chain_orders[units_sold]`
  - **Y-Axis**: `[Logistics Cost per Unit]`
  - **Legend**: `dim_categories[category_name]`
  - **Insight**: Visualizes freight economy of scale (unit cost plummets as order volume rises from 10 to 300 units).
- **Visual 2 (Clustered Bar Chart - Top Right)**:
  - **Title**: Logistics Freight Expenditure by Regional Hub & Category
  - **Y-Axis**: `dim_warehouses[city]`
  - **X-Axis**: `[Total Logistics Cost]`
  - **Legend**: `dim_categories[category_name]`
- **Visual 3 (Risk Radar Matrix - Bottom Left)**:
  - **Title**: Operational Risk Cross-Tab: Inventory Risk vs Delivery Risk
  - **Rows**: `fact_supply_chain_orders[inventory_risk_category]`
  - **Columns**: `fact_supply_chain_orders[delivery_risk_category]`
  - **Values**: `[Total Revenue]` (Revenue at Stake)
  - **Conditional Formatting**: Crimson highlight on top-right quadrant (Severe Delay + Critical Stockout / Deficit).
- **Visual 4 (Action Priority Table - Bottom Right)**:
  - **Title**: Immediate Supply Chain Action Items (Lane Priority)
  - **Rows**: `Supplier Name` + `Warehouse Location`
  - **Columns**: `Total Orders`, `Avg Transit Days`, `Delay Rate %`, `Deficit Rate %`, `Logistics Cost`, `Priority Action Needed`
  - **Sort**: Combined Delay + Deficit rate descending.

---

## 3. Interactive Filtering, Cross-Highlighting & Tooltips
1. **Interactive Slicers**:
   - Selecting any Supplier (e.g. `Supplier E`) immediately updates all visuals across the page, revealing vendor-specific delay profiles and affected products.
   - Selecting a Warehouse (e.g. `Mumbai`) filters all charts to Mumbai Hub dispatches.
2. **Drill-Through Target**:
   - A dedicated hidden drill-through page called **Product Deep-Dive** allows right-clicking any Product SKU on Page 3 to view chronological order history, stock-out timelines, and regional demand breakdown.
3. **Report Tooltips**:
   - Custom hover tooltip page on the Delivery Delay visual displaying the top 3 delayed SKUs and supplier breakdown for that specific day.
