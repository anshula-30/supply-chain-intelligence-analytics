# Power BI Desktop Step-by-Step Manual Build Instructions

This guide provides click-by-click instructions to construct the complete 5-page interactive **Supply Chain Intelligence & Operations Analytics Platform** dashboard in Power BI Desktop from scratch in under 15 minutes.

---

## Prerequisites
- **Power BI Desktop** (free version, downloadable from [powerbi.microsoft.com](https://powerbi.microsoft.com)).
- Cleaned datasets located in `data/processed/`.

---

## Stage 1: Data Ingestion (2 Options)

### Recommended Approach: Normalized Star Schema (Best Practice)
1. Open Power BI Desktop.
2. In the Home Ribbon, click **Get Data** -> **Text/CSV**.
3. Navigate to `data/processed/` and load the following files sequentially:
   - `dim_suppliers.csv`
   - `dim_warehouses.csv`
   - `dim_categories.csv`
   - `dim_products.csv`
   - `dim_date.csv`
   - `fact_supply_chain_orders.csv`
4. Click **Load** for each table.

### Fast Alternative: Single Master Table Ingestion
If you prefer single-table simplicity without configuring relationships:
1. Click **Get Data** -> **Text/CSV**.
2. Select `data/processed/supply_chain_master_clean.csv`.
3. Click **Load**. (All 37 pre-joined columns and attributes will be available immediately in a single table).

---

## Stage 2: Configure Relationships (Model View)
*(Applicable if using the Star Schema)*
1. Switch to **Model View** (icon on left navigation bar).
2. Arrange `fact_supply_chain_orders` in the center and place the dimension tables around it.
3. Establish the following 1-to-Many ($1:*$) relationships (drag and drop PK to FK):
   - `dim_suppliers[supplier_id]` $\rightarrow$ `fact_supply_chain_orders[supplier_id]`
   - `dim_warehouses[warehouse_id]` $\rightarrow$ `fact_supply_chain_orders[warehouse_id]`
   - `dim_categories[category_id]` $\rightarrow$ `dim_products[category_id]`
   - `dim_products[product_id]` $\rightarrow$ `fact_supply_chain_orders[product_id]`
   - `dim_date[date_key]` $\rightarrow$ `fact_supply_chain_orders[order_date]` (Active)
   - `dim_date[date_key]` $\rightarrow$ `fact_supply_chain_orders[delivery_date]` (Inactive)
4. Ensure **Cross filter direction** is set to **Single** (Dimension filters Fact).

---

## Stage 3: Create Measures Table & Paste DAX
1. In Home Ribbon, click **Enter Data**.
2. Name the table `_Measures` and click **Load**.
3. Open `powerbi/dax_measures.dax` from this project.
4. In the Fields pane, right-click `_Measures` -> **New Measure**.
5. Copy and paste each DAX formula from `powerbi/dax_measures.dax` into the formula bar and press Enter:
   - Core Financials: `Total Orders`, `Total Revenue`, `Total COGS`, `Gross Profit`, `Gross Margin %`, `Total Logistics Cost`, `Net Operating Profit`.
   - Service Levels: `Average Shipping Lead Time`, `On-Time Delivery Rate %`, `Delayed Orders`, `Delay Rate %`, `Average Delay Days (Delayed Orders Only)`.
   - Inventory & Fulfillment: `Fulfillment Rate %`, `Stockout Incidents`, `Stockout Rate %`, `Understock Rate %`, `Inventory Availability %`, `Supplier Reliability Index`.
   - Time Intelligence: `Revenue MoM Growth %`, `Orders MoM Growth %`, `Rolling 30-Day Orders`.
   - Formatting / Rules: `Supplier Risk Category`, `Delivery Risk KPI Color`, `Inventory Risk KPI Color`.
6. Format each measure appropriately:
   - Currency: `Total Revenue`, `Gross Profit`, `Total Logistics Cost` -> Format as Currency (`$ #,##0` or `₹ #,##0`).
   - Percentage: `Fulfillment Rate %`, `On-Time Delivery Rate %`, `Gross Margin %` -> Format as Percentage (`0.00%`).
   - Integers: `Total Orders`, `Stockout Incidents`, `Delayed Orders` -> Whole number with commas.

---

## Stage 4: Constructing the 5 Dashboard Pages

### Global Banner (Add to Top of Every Page)
1. Add a **Shape** (Rectangle) across the top ($X=0, Y=0, \text{Width}=1280, \text{Height}=60$, Fill: `#1A365D` Deep Blue).
2. Insert a **Text Box**: "SUPPLY CHAIN INTELLIGENCE & OPERATIONS ANALYTICS PLATFORM" (Font: Segoe UI, Size: 16pt Bold, Color: White).
3. Add Slicers in top bar:
   - `dim_date[year]` (Dropdown or Tile)
   - `dim_categories[category_name]` (Dropdown)
   - `dim_warehouses[city]` (Dropdown)
   - `dim_suppliers[supplier_name]` (Dropdown)

---

### PAGE 1: Executive Supply Chain Overview
1. **KPI Cards Row** ($Y=70$ to $160$):
   - Card 1: `[Total Orders]`
   - Card 2: `[Fulfillment Rate %]` (Conditional font color: Red if $<72\%$)
   - Card 3: `[On-Time Delivery Rate %]` (Conditional font color: Red if $<50\%$)
   - Card 4: `[Average Shipping Lead Time]`
   - Card 5: `[Total Revenue]`
   - Card 6: `[Total Logistics Cost]`
2. **Visual 1: Line and Clustered Column Chart**:
   - X-Axis: `dim_date[year_month]`
   - Column: `[Total Orders]`
   - Line: `[On-Time Delivery Rate %]`
3. **Visual 2: Donut Chart**:
   - Legend: `fulfillment_status`
   - Values: `[Total Orders]`
4. **Visual 3: Clustered Bar Chart**:
   - Y-Axis: `dim_categories[category_name]`
   - X-Axis: `[Total Revenue]` and `[Gross Profit]`
5. **Visual 4: Table / Operational Alerts**:
   - Rows: `dim_warehouses[city]`
   - Values: `[Delayed Orders]`, `[Deficit Orders Count]`, `[Stockout Incidents]`, `[Total Logistics Cost]`

---

### PAGE 2: Supplier Performance
1. **Visual 1: Scatter Plot (Vendor Performance Quadrant)**:
   - X-Axis: `[On-Time Delivery Rate %]`
   - Y-Axis: `[Fulfillment Rate %]`
   - Details: `dim_suppliers[supplier_name]`
   - Size: `[Total Revenue]`
2. **Visual 2: Clustered Column Chart**:
   - X-Axis: `dim_suppliers[supplier_name]`
   - Y-Axis: `[Average Shipping Lead Time]`
   - Add Constant Line: Target SLA = 5.0 Days
3. **Visual 3: Scorecard Matrix**:
   - Rows: `dim_suppliers[supplier_name]`
   - Values: `[Total Orders]`, `[On-Time Delivery Rate %]`, `[Fulfillment Rate %]`, `[Total Fulfillment Deficit Units]`, `[Average Delay Days (Delayed Orders Only)]`, `[Supplier Risk Category]`

---

### PAGE 3: Inventory & Warehouse
1. **Visual 1: 100% Stacked Bar Chart**:
   - Y-Axis: `dim_categories[category_name]`
   - Legend: `inventory_risk_category`
   - Values: `[Total Orders]`
2. **Visual 2: Clustered Column Chart**:
   - X-Axis: `dim_warehouses[city]`
   - Values: `[Total Units Sold]` and `[Average On-Hand Stock]`
3. **Visual 3: Treemap**:
   - Category: `product_name`
   - Values: `[Total Fulfillment Deficit Units]`
4. **Visual 4: Table (Understock Watchlist)**:
   - Columns: `product_name`, `category_name`, `Average Stock`, `Average Reorder Level`, `Understock Rate %`, `Stockout Incidents`

---

### PAGE 4: Orders & Delivery
1. **Visual 1: Histogram / Column Chart**:
   - X-Axis: `shipping_time_days` (1 to 10)
   - Y-Axis: `[Total Orders]`
   - Data Colors: 1-5 = Emerald Green, 6-10 = Coral Red
2. **Visual 2: Bar Chart by Region**:
   - Y-Axis: `dim_warehouses[city]`
   - Values: `[Average Shipping Lead Time]` and `[On-Time Delivery Rate %]`
3. **Visual 3: Matrix (Weekday Bottlenecks)**:
   - Rows: `dim_date[day_name]`
   - Columns: `dim_warehouses[region]`
   - Values: `[Average Shipping Lead Time]`
4. **Visual 4: Area Chart**:
   - X-Axis: `dim_date[date_key]`
   - Values: `[Rolling 30-Day Orders]`

---

### PAGE 5: Cost & Operational Risk
1. **Visual 1: Scatter Plot (Logistics Economies of Scale)**:
   - X-Axis: `units_sold`
   - Y-Axis: `[Logistics Cost per Unit]`
   - Legend: `category_name`
2. **Visual 2: Stacked Bar Chart**:
   - Y-Axis: `dim_warehouses[city]`
   - X-Axis: `[Total Logistics Cost]`
   - Legend: `category_name`
3. **Visual 3: Heatmap Matrix (Risk Radar)**:
   - Rows: `inventory_risk_category`
   - Columns: `delivery_risk_category`
   - Values: `[Total Revenue]` (Revenue at Stake)
4. **Visual 4: Action Priority Table**:
   - Rows: `Supplier Name`, `Warehouse City`
   - Values: `Total Orders`, `Avg Transit Days`, `Delay Rate %`, `Deficit Rate %`, `Logistics Cost`

---

## Stage 5: Save and Publish
1. Save report as `Supply_Chain_Intelligence_Platform.pbix`.
2. Test interactive cross-filtering by clicking on any chart element or selecting filter dropdowns.
3. (Optional) Click **Publish** to share on Power BI Service.
