"""
Supply Chain Intelligence & Operations Analytics Platform
Data Cleaning, Normalization & ETL Pipeline
Author: B.Tech Computer Engineering Final Year Project
"""

import os
import sys
import pandas as pd
import numpy as np

def run_etl():
    print("=" * 70)
    print("STARTING DATA CLEANING & ETL PIPELINE")
    print("=" * 70)

    # 1. Paths
    raw_path = os.path.join("data", "raw", "supply_chain_inventory_raw.xlsx")
    processed_dir = os.path.join("data", "processed")
    os.makedirs(processed_dir, exist_ok=True)

    if not os.path.exists(raw_path):
        # Fallback to current directory if not copied yet
        raw_path = "Project-03 supply_chain_inventory_dataset_15000_rows 2.xlsx"

    print(f"Loading raw dataset from: {raw_path}")
    raw_df = pd.read_excel(raw_path)
    initial_rows, initial_cols = raw_df.shape
    print(f"Raw dataset loaded: {initial_rows:,} rows, {initial_cols} columns.")

    # 2. Data Cleaning & Validation Checks
    print("\n--- Step 1: Data Integrity & Validation Checks ---")
    null_counts = raw_df.isnull().sum()
    print("Missing values per column:\n", null_counts[null_counts > 0] if null_counts.sum() > 0 else "Zero missing values detected.")

    exact_duplicates = raw_df.duplicated().sum()
    print(f"Exact duplicate rows: {exact_duplicates}")

    # Trim string whitespace
    string_cols = ['Product_Name', 'Category', 'Supplier_Name', 'Warehouse_Location']
    for c in string_cols:
        raw_df[c] = raw_df[c].astype(str).str.strip()

    # Validate Dates
    raw_df['Order_Date'] = pd.to_datetime(raw_df['Order_Date'])
    raw_df['Delivery_Date'] = pd.to_datetime(raw_df['Delivery_Date'])
    invalid_dates = (raw_df['Delivery_Date'] < raw_df['Order_Date']).sum()
    print(f"Invalid date sequence (Delivery < Order): {invalid_dates}")

    # Validate Numerics
    numeric_cols = ['Stock_Quantity', 'Reorder_Level', 'Units_Sold', 'Purchase_Cost', 'Selling_Price', 'Shipping_Time_Days']
    for c in numeric_cols:
        negative_vals = (raw_df[c] < 0).sum()
        if negative_vals > 0:
            print(f"Warning: {c} has {negative_vals} negative values.")
    
    # 3. Dimensional Modeling & Normalization
    print("\n--- Step 2: Normalization & Dimensional Table Generation ---")

    # A. Dimension: Suppliers
    suppliers = sorted(raw_df['Supplier_Name'].unique())
    sup_records = []
    sup_code_map = {
        'Supplier A': ('SUP-A', 'procurement@suppliera.com', 5, 'Tier-1'),
        'Supplier B': ('SUP-B', 'procurement@supplierb.com', 5, 'Tier-1'),
        'Supplier C': ('SUP-C', 'procurement@supplierc.com', 5, 'Tier-1'),
        'Supplier D': ('SUP-D', 'procurement@supplierd.com', 5, 'Tier-2'),
        'Supplier E': ('SUP-E', 'procurement@suppliere.com', 5, 'Tier-2')
    }
    for s_name in suppliers:
        code, email, sla, tier = sup_code_map[s_name]
        sup_records.append({
            'supplier_id': code,
            'supplier_name': s_name,
            'contact_email': email,
            'lead_time_sla_days': sla,
            'supplier_tier': tier
        })
    dim_suppliers = pd.DataFrame(sup_records)
    dim_suppliers.to_csv(os.path.join(processed_dir, "dim_suppliers.csv"), index=False, encoding='utf-8')
    print(f"Created dim_suppliers.csv ({len(dim_suppliers)} rows)")

    # B. Dimension: Warehouses
    warehouses = sorted(raw_df['Warehouse_Location'].unique())
    wh_records = []
    wh_meta = {
        'Bangalore': ('WH-BLR', 'Bangalore Logistics Hub', 'Bangalore', 'Karnataka', 'South', 50000),
        'Chennai': ('WH-MAA', 'Chennai Port Logistics Hub', 'Chennai', 'Tamil Nadu', 'South', 45000),
        'Delhi': ('WH-DEL', 'Delhi NCR Regional Hub', 'Delhi NCR', 'Delhi NCR', 'North', 60000),
        'Hyderabad': ('WH-HYD', 'Hyderabad Cargo Logistics Hub', 'Hyderabad', 'Telangana', 'South', 48000),
        'Mumbai': ('WH-BOM', 'Mumbai Central Logistics Hub', 'Mumbai', 'Maharashtra', 'West', 55000)
    }
    for w_city in warehouses:
        wid, wname, city, state, reg, cap = wh_meta[w_city]
        wh_records.append({
            'warehouse_id': wid,
            'warehouse_name': wname,
            'city': city,
            'state': state,
            'region': reg,
            'storage_capacity_sqft': cap
        })
    dim_warehouses = pd.DataFrame(wh_records)
    dim_warehouses.to_csv(os.path.join(processed_dir, "dim_warehouses.csv"), index=False, encoding='utf-8')
    print(f"Created dim_warehouses.csv ({len(dim_warehouses)} rows)")

    # C. Dimension: Categories
    cat_meta = {
        'Electronics': ('CAT-ELEC', 20.00),
        'Fashion': ('CAT-FASH', 20.00),
        'Home Appliances': ('CAT-APPL', 20.00),
        'Sports': ('CAT-SPRT', 20.00)
    }
    cat_records = []
    for c_name in sorted(raw_df['Category'].unique()):
        cid, target_margin = cat_meta[c_name]
        cat_records.append({
            'category_id': cid,
            'category_name': c_name,
            'target_margin_pct': target_margin
        })
    dim_categories = pd.DataFrame(cat_records)
    dim_categories.to_csv(os.path.join(processed_dir, "dim_categories.csv"), index=False, encoding='utf-8')
    print(f"Created dim_categories.csv ({len(dim_categories)} rows)")

    # D. Dimension: Products (SKUs)
    # 40 distinct catalog SKUs across categories
    sku_df = raw_df[['Category', 'Product_Name']].drop_duplicates().sort_values(['Category', 'Product_Name']).reset_index(drop=True)
    product_records = []
    cat_short = {'Electronics': 'ELEC', 'Fashion': 'FASH', 'Home Appliances': 'APPL', 'Sports': 'SPRT'}
    prod_short = {
        'AC': 'AC', 'Camera': 'CAM', 'Fan': 'FAN', 'Laptop': 'LAP', 'Mixer': 'MIX',
        'Phone': 'PHN', 'Shoes': 'SHOE', 'TV': 'TV', 'Tablet': 'TAB', 'Watch': 'WAT'
    }

    sku_to_pid = {}
    for idx, row in sku_df.iterrows():
        cat = row['Category']
        pname = row['Product_Name']
        pid = f"PRD-{cat_short[cat]}-{prod_short[pname]}"
        sku_code = f"SKU-{cat_short[cat]}-{prod_short[pname]}-{idx+1:03d}"
        cid = cat_meta[cat][0]
        sku_to_pid[(cat, pname)] = pid

        # Calculate average reorder level from historical data
        hist_subset = raw_df[(raw_df['Category'] == cat) & (raw_df['Product_Name'] == pname)]
        avg_reorder = int(round(hist_subset['Reorder_Level'].mean()))

        product_records.append({
            'product_id': pid,
            'sku_code': sku_code,
            'product_name': pname,
            'category_id': cid,
            'category_name': cat,
            'standard_reorder_level': avg_reorder
        })

    dim_products = pd.DataFrame(product_records)
    dim_products.to_csv(os.path.join(processed_dir, "dim_products.csv"), index=False, encoding='utf-8')
    print(f"Created dim_products.csv ({len(dim_products)} rows)")

    # E. Dimension: Date
    min_date = raw_df['Order_Date'].min()
    max_date = raw_df['Delivery_Date'].max() + pd.Timedelta(days=21) # buffer to end of Jan 2025
    date_range = pd.date_range(start=min_date, end=max_date, freq='D')
    date_records = []
    for d in date_range:
        date_records.append({
            'date_key': d.strftime('%Y-%m-%d'),
            'full_date': d.strftime('%Y-%m-%d'),
            'year': d.year,
            'quarter': f"Q{d.quarter}",
            'year_quarter': f"{d.year}-Q{d.quarter}",
            'month': d.month,
            'month_name': d.strftime('%B'),
            'year_month': d.strftime('%Y-%m'),
            'day_of_month': d.day,
            'day_of_week': d.isoweekday(),
            'day_name': d.strftime('%A'),
            'is_weekend': 1 if d.isoweekday() in [6, 7] else 0
        })
    dim_date = pd.DataFrame(date_records)
    dim_date.to_csv(os.path.join(processed_dir, "dim_date.csv"), index=False, encoding='utf-8')
    print(f"Created dim_date.csv ({len(dim_date)} rows, {min_date.date()} to {max_date.date()})")

    # 4. Fact Table Generation: fact_supply_chain_orders
    print("\n--- Step 3: Fact Table Transformation & Enrichment ---")
    fact_df = pd.DataFrame()
    
    # Map foreign keys
    fact_df['order_id'] = raw_df['Product_ID'].apply(lambda x: f"ORD-{x.replace('PROD', '')}")
    fact_df['raw_record_id'] = raw_df['Product_ID']
    fact_df['order_date'] = raw_df['Order_Date'].dt.strftime('%Y-%m-%d')
    fact_df['delivery_date'] = raw_df['Delivery_Date'].dt.strftime('%Y-%m-%d')
    
    # Map product_id
    fact_df['product_id'] = [sku_to_pid[(r.Category, r.Product_Name)] for r in raw_df.itertuples()]
    
    # Map supplier_id
    sup_name_to_id = {k: v[0] for k, v in sup_code_map.items()}
    fact_df['supplier_id'] = raw_df['Supplier_Name'].map(sup_name_to_id)

    # Map warehouse_id
    wh_city_to_id = {k: v[0] for k, v in wh_meta.items()}
    fact_df['warehouse_id'] = raw_df['Warehouse_Location'].map(wh_city_to_id)

    # Measures and quantities
    fact_df['units_sold'] = raw_df['Units_Sold']
    fact_df['unit_purchase_cost'] = raw_df['Purchase_Cost'].astype(float)
    fact_df['unit_selling_price'] = raw_df['Selling_Price'].astype(float)
    fact_df['stock_quantity'] = raw_df['Stock_Quantity']
    fact_df['reorder_level'] = raw_df['Reorder_Level']
    fact_df['shipping_time_days'] = raw_df['Shipping_Time_Days']
    
    # Lead time, SLA and Delays
    TARGET_SLA_DAYS = 5
    fact_df['target_lead_time_days'] = TARGET_SLA_DAYS
    fact_df['delivery_delay_days'] = fact_df['shipping_time_days'].apply(lambda x: max(0, x - TARGET_SLA_DAYS))
    fact_df['is_on_time'] = (fact_df['shipping_time_days'] <= TARGET_SLA_DAYS).astype(int)

    # Fulfillment indicators
    def calc_fulfillment_status(row):
        if row['stock_quantity'] == 0:
            return 'Stockout'
        elif row['stock_quantity'] < row['units_sold']:
            return 'Partial'
        else:
            return 'Fulfilled'

    fact_df['fulfillment_status'] = fact_df.apply(calc_fulfillment_status, axis=1)
    fact_df['stockout_flag'] = (fact_df['stock_quantity'] == 0).astype(int)
    fact_df['understock_flag'] = (fact_df['stock_quantity'] < fact_df['reorder_level']).astype(int)
    fact_df['fulfillment_deficit_units'] = np.maximum(0, fact_df['units_sold'] - fact_df['stock_quantity'])

    # Financial computations
    fact_df['total_revenue'] = fact_df['units_sold'] * fact_df['unit_selling_price']
    fact_df['total_cogs'] = fact_df['units_sold'] * fact_df['unit_purchase_cost']
    fact_df['gross_profit'] = fact_df['total_revenue'] - fact_df['total_cogs']
    fact_df['gross_margin_pct'] = np.where(fact_df['total_revenue'] > 0, (fact_df['gross_profit'] / fact_df['total_revenue']) * 100, 0.0).round(2)

    # Logistics cost model:
    # Base Freight = 120.00
    # Handling rate = 2.50 per unit
    # In-transit rate = 15.00 per shipping day
    fact_df['logistics_cost'] = 120.00 + (fact_df['units_sold'] * 2.50) + (fact_df['shipping_time_days'] * 15.00)
    fact_df['net_profit'] = fact_df['gross_profit'] - fact_df['logistics_cost']

    # Operational Risk Category flags
    def assign_inventory_risk(row):
        if row['stock_quantity'] == 0:
            return 'Critical Stockout'
        elif row['stock_quantity'] < row['units_sold']:
            return 'Deficit Shortfall'
        elif row['stock_quantity'] < row['reorder_level']:
            return 'Understock Warning'
        elif row['stock_quantity'] > (3 * row['reorder_level']):
            return 'Overstock Warning'
        else:
            return 'Healthy Stock'

    fact_df['inventory_risk_category'] = fact_df.apply(assign_inventory_risk, axis=1)

    def assign_delivery_risk(row):
        if row['shipping_time_days'] <= 5:
            return 'On-Time (Low Risk)'
        elif row['shipping_time_days'] <= 7:
            return 'Minor Delay (Medium Risk)'
        else:
            return 'Severe Delay (High Risk)'

    fact_df['delivery_risk_category'] = fact_df.apply(assign_delivery_risk, axis=1)

    fact_df.to_csv(os.path.join(processed_dir, "fact_supply_chain_orders.csv"), index=False, encoding='utf-8')
    print(f"Created fact_supply_chain_orders.csv ({len(fact_df)} rows)")

    # 5. Master Flat Denormalized Dataset (Optimized for Power BI Direct Load)
    print("\n--- Step 4: Master Clean Denormalized File Generation ---")
    master_df = fact_df.copy()
    master_df = master_df.merge(dim_products[['product_id', 'sku_code', 'product_name', 'category_name']], on='product_id', how='left')
    master_df = master_df.merge(dim_suppliers[['supplier_id', 'supplier_name', 'supplier_tier']], on='supplier_id', how='left')
    master_df = master_df.merge(dim_warehouses[['warehouse_id', 'warehouse_name', 'city', 'state', 'region']], on='warehouse_id', how='left')
    
    master_df.to_csv(os.path.join(processed_dir, "supply_chain_master_clean.csv"), index=False, encoding='utf-8')
    print(f"Created supply_chain_master_clean.csv ({len(master_df)} rows, {master_df.shape[1]} columns)")

    # 6. Summary Validation Metrics
    print("\n" + "=" * 70)
    print("ETL VALIDATION AUDIT SUMMARY")
    print("=" * 70)
    print(f"Total Processed Orders:     {len(fact_df):,}")
    print(f"Total Units Sold:           {fact_df['units_sold'].sum():,}")
    print(f"Total Revenue:              INR {fact_df['total_revenue'].sum():,.2f}")
    print(f"Total COGS:                 INR {fact_df['total_cogs'].sum():,.2f}")
    print(f"Total Gross Profit:         INR {fact_df['gross_profit'].sum():,.2f}")
    print(f"Total Logistics Cost:       INR {fact_df['logistics_cost'].sum():,.2f}")
    print(f"Overall Gross Margin %:     {(fact_df['gross_profit'].sum() / fact_df['total_revenue'].sum()) * 100:.2f}%")
    print(f"Average Shipping Time:      {fact_df['shipping_time_days'].mean():.2f} days")
    print(f"On-Time Delivery Rate:      {(fact_df['is_on_time'].mean()) * 100:.2f}%")
    print(f"Stockout Rate:              {(fact_df['stockout_flag'].mean()) * 100:.2f}% ({fact_df['stockout_flag'].sum()} orders)")
    print(f"Understock Rate:            {(fact_df['understock_flag'].mean()) * 100:.2f}% ({fact_df['understock_flag'].sum()} orders)")
    print(f"Fulfillment Deficit Orders: {(fact_df['fulfillment_status'] != 'Fulfilled').mean() * 100:.2f}% ({len(fact_df[fact_df['fulfillment_status'] != 'Fulfilled']):,} orders)")
    print("=" * 70)
    print("ETL COMPLETED SUCCESSFULLY!")
    print("=" * 70)

if __name__ == "__main__":
    run_etl()
