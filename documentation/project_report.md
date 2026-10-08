# SUPPLY CHAIN INTELLIGENCE & OPERATIONS ANALYTICS PLATFORM
## Final Year B.Tech Computer Engineering Capstone Project Report

---

### Executive Summary & Abstract
Modern global supply chain networks face severe operational challenges, including unpredictable vendor lead times, fulfillment stockouts, inventory misallocation, and eroding logistics profit margins. This project designs and implements an enterprise-grade **Supply Chain Intelligence & Operations Analytics Platform** that bridges the gap between raw operational transaction logs and executive decision-making. 

Utilizing a conformed dataset of **15,000 transaction orders** spanning two operating calendar years (2023–2024), the platform implements an end-to-end analytical architecture comprising:
1. Automated Python ETL and data cleaning pipeline enforcing domain constraints and relational normalization.
2. A relational dimensional data warehouse (Star Schema) deployed on **PostgreSQL / MySQL 8.0** with B-tree performance indexing.
3. An analytical SQL engine featuring **8 reusable production views** and **28 advanced analytical queries** utilizing Common Table Expressions (CTEs), window functions, conditional aggregations, and rolling moving averages.
4. A deterministic, rule-based **Operational Risk Scoring Engine** evaluating vendor SLA compliance, inventory buffer fragility, delivery latency, and freight unit economics.
5. An interactive **5-page Power BI executive intelligence dashboard** powered by a robust Star Schema semantic layer and a library of 40+ DAX measures.

The system revealed critical empirical discoveries: a systemic **50.04% delivery SLA breach rate** across all vendors, a **29.68% inventory deficit rate** resulting in 445,082 units of unmet customer demand, severe vendor friction concentrated in `Supplier E`, and a **6x logistics cost penalty** on sub-50 unit shipments. Actionable mitigation strategies—including dynamic safety stock sizing, vendor Performance Improvement Plans (PIPs), and Minimum Order Quantity (MOQ) thresholds—were formulated with measurable ROI projections.

---

## 1. Problem Statement & Motivation
Supply chain disruptions and inventory imbalances impose severe financial penalties on modern enterprises:
- **Lead Time Variability**: Inability to monitor vendor dispatch timelines leads to missed customer delivery expectations.
- **Stock-Out and Deficit Penalties**: Ordering systems operating without real-time inventory visibility accept customer orders that exceed on-hand warehouse stock, creating stockouts, split shipments, and customer churn.
- **Logistics Margin Leakage**: Inefficient freight handling, uncoordinated small-batch orders, and high transit durations inflate logistics expenses, eroding operating margins.
- **Data Fragmentation**: Raw transaction data is typically siloed in monolithic spreadsheets or flat CSVs lacking relational normalization, referential integrity, and executive visualization.

This project solves these challenges by architecting a production-ready, defensively engineered Business Intelligence (BI) and Data Engineering platform tailored for supply chain operations.

---

## 2. Project Objectives & Scope
The primary objectives of this engineering capstone project are:
1. **Data Normalization & Engineering**: Cleanse 15,000 raw operational records, eliminate syntax and domain anomalies, and normalize flat structures into a 3NF Star Schema relational model.
2. **Relational Database Warehouse**: Deploy high-performance schemas in PostgreSQL 13+ and MySQL 8.0+ with primary keys, foreign key constraints, domain checks, and indexing.
3. **Advanced SQL Analytics**: Author 28 complex analytical SQL queries and 8 production views answering critical operational questions using CTEs, window functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD`, `AVG OVER`), and rolling averages.
4. **Transparent Risk Engine**: Build an explainable, deterministic rule-based operational risk engine assessing Supplier, Inventory, Delivery, and Logistics cost risks.
5. **Interactive Executive BI Dashboard**: Develop a 5-page Power BI dashboard with cross-filtering, slicers, drill-through paths, and DAX calculations.
6. **Data-Driven Strategy**: Convert empirical findings into quantifiable business interventions with documented evidence, business impact, and recommendations.

---

## 3. Technology Stack & Architectural Pipeline
The platform adopts an enterprise analytics engineering stack without unnecessary web frameworks:

- **Relational Databases**: PostgreSQL 13+ (preferred enterprise RDBMS) & MySQL 8.0+ (InnoDB engine).
- **Core Query Language**: ANSI SQL / PostgreSQL PL-pgSQL / MySQL 8.0 Dialects.
- **Data Engineering / ETL**: Python 3.11 (`pandas`, `openpyxl`, `numpy`) used strictly for deterministic data cleansing and dimension generation.
- **Business Intelligence**: Power BI Desktop, Power Query (M Language), Data Analysis Expressions (DAX).
- **Embedded Testing Engine**: Python `sqlite3` test runner verifying 100% of SQL views, queries, and business assertions.
- **Version Control**: Git & GitHub repository architecture.

```
Public Supply Chain Dataset (15,000 Rows)
       ↓
Python Data Cleaning & ETL Pipeline (scripts/data_cleaning.py)
       ↓
Relational Star Schema Database (PostgreSQL / MySQL / SQLite)
       ↓
Analytical SQL Engine (8 Production Views + 28 Master Queries)
       ↓
Rule-Based Operational Risk Analysis Framework
       ↓
Power BI Semantic Data Model + 40+ DAX Measures
       ↓
Interactive Executive Dashboard (5 Pages)
       ↓
Actionable Strategic Business Interventions
```

---

## 4. Dataset Profiling & Cleaning Process
The raw dataset (`Project-03 supply_chain_inventory_dataset_15000_rows 2.xlsx`) comprises 15,000 records spanning January 1, 2023 through December 31, 2024.

### Initial Profiling
- **Record Volume**: 15,000 rows, 13 columns.
- **Missing Values**: 0 nulls across all fields.
- **Duplicates**: 0 exact duplicate rows.
- **Key Observation**: The raw column `Product_ID` uniquely numbered each row from `PROD1000` to `PROD15999`. In reality, these represented individual transactional order events across 10 core products and 4 merchandising categories.
- **Date Relationship**: For all 15,000 rows, `Delivery_Date - Order_Date == Shipping_Time_Days` exactly, confirming temporal consistency.

### Cleansing & Transformation Steps
1. **String Normalization**: Trimmed whitespace across `Product_Name`, `Category`, `Supplier_Name`, and `Warehouse_Location`.
2. **Key Code Mapping**: Mapped text identifiers into standardized enterprise codes:
   - Suppliers: `Supplier A` to `Supplier E` $\rightarrow$ `SUP-A` to `SUP-E`.
   - Warehouses: Metro cities $\rightarrow$ `WH-BLR`, `WH-MAA`, `WH-DEL`, `WH-HYD`, `WH-BOM`.
   - Categories: `Electronics`, `Fashion`, `Home Appliances`, `Sports` $\rightarrow$ `CAT-ELEC`, `CAT-FASH`, `CAT-APPL`, `CAT-SPRT`.
   - Products: 40 distinct catalog SKUs generated based on Category and Product Title.
3. **Derived Operational Metrics**:
   - `delivery_delay_days` = $\max(0, \text{shipping\_time\_days} - 5)$
   - `is_on_time` = $1$ if $\text{shipping\_time\_days} \le 5$ else $0$
   - `fulfillment_status` = 'Fulfilled' if $\text{stock} \ge \text{units}$, 'Partial' if $0 < \text{stock} < \text{units}$, 'Stockout' if $\text{stock} = 0$.
   - `fulfillment_deficit_units` = $\max(0, \text{units\_sold} - \text{stock\_quantity})$.
4. **Logistics Cost Formulation**: Modeled as:
   $$\text{Logistics Cost} = ₹120.00 + (\text{Units Sold} \times ₹2.50) + (\text{Shipping Days} \times ₹15.00)$$
5. **Financial Metrics**: Derived Gross Revenue, COGS, Gross Profit, Gross Margin %, and Net Profit.

---

## 5. Relational Database & Star Schema Design
The normalized dimensional data warehouse contains 5 conformed dimensions and 1 central fact table:

1. `dim_suppliers` (5 rows): Vendor profiles, contact emails, SLA thresholds, and tiers.
2. `dim_warehouses` (5 rows): Hub locations, regions, states, and facility storage square footage.
3. `dim_categories` (4 rows): Merchandise departments and target gross margin benchmarks.
4. `dim_products` (40 rows): Distinct SKUs with parent category foreign keys and baseline reorder levels.
5. `dim_date` (762 rows): Enterprise calendar from Jan 1, 2023 to Jan 31, 2025 with year, quarter, month, and day attributes.
6. `fact_supply_chain_orders` (15,000 rows): Transactional grain storing order events, inventory on-hand, quantities, unit prices, costs, logistics charges, and risk classifications.

### Referential Integrity & Indexing
- Primary Keys enforce entity uniqueness.
- Foreign Keys enforce valid references from the fact table to all dimension tables.
- B-tree indexes were deployed on all foreign keys (`supplier_id`, `warehouse_id`, `product_id`, `order_date`, `delivery_date`) and high-cardinality status flags (`fulfillment_status`, `is_on_time`).

---

## 6. Advanced SQL Analytical Engine
The analytical engine is structured into:
- **8 Production SQL Views** acting as a reusable semantic abstraction layer for reporting.
- **28 Modular Analytical Queries** grouped into 6 operational pillars:
  1. *Supplier Performance & Reliability* (Q01–Q05): Evaluating SLA compliance, deficit rates, vendor rankings via `DENSE_RANK()`, and lead time variance.
  2. *Procurement & Inventory Health* (Q06–Q10): Identifying zero-stock events, safety stock breaches, Pareto ABC classification via `SUM() OVER ()`, and inventory turnover.
  3. *Warehouse Operations* (Q11–Q15): Measuring dispatch throughput, regional delay rates, freight burden, and capacity utilization per sq ft.
  4. *Order Fulfillment & Delivery Performance* (Q16–Q20): Fulfillment state breakdown, lead-time cohort bins, day-of-week patterns, running revenue totals, and 30-day moving averages.
  5. *Logistics Cost & Financial Margins* (Q21–Q24): Freight cost leakage, outlier cost detection, SKU net margins, and MoM growth rates via `LAG()`.
  6. *Multi-Dimensional Operational Risk Scoring* (Q25–Q28): High-risk vendor matrix, revenue exposure under deficit, severe delay escalations, and corridor bottleneck priority ranking.

All 28 queries and 8 views were tested and verified via an automated test suite (`tests/test_sql_analytics.py`) with zero syntax or execution errors.

---

## 7. Key Performance Indicators (KPIs) Summary

| Category | Metric | Actual Baseline | Benchmark | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Volume** | Total Orders | **15,000** | — | Normal |
| **Volume** | Total Units Sold | **2,222,508** | — | Normal |
| **Financial**| Total Revenue | **₹3,076,312,144** | — | Normal |
| **Financial**| Gross Profit Margin | **19.92%** | 20.00% | Near Target |
| **Financial**| Total Logistics Cost | **₹8,592,900** | — | Normal |
| **Financial**| Avg Logistics Cost / Order| **₹572.86** | ₹500.00 | High |
| **Delivery** | On-Time Delivery Rate (OTD)| **49.96%** | $\ge 90.00\%$ | **Critical Failure** |
| **Delivery** | Avg Shipping Time | **5.50 Days** | $\le 4.00$ Days | High |
| **Delivery** | Avg Delay (Late Cohort) | **3.01 Days** | $\le 1.00$ Day | High |
| **Inventory**| Fulfillment Rate | **70.32%** | $\ge 95.00\%$ | **Severe Deficit** |
| **Inventory**| Stockout Incidents | **32 (0.21%)** | $\le 0.05\%$ | Elevated |
| **Inventory**| Understock Warning Rate | **19.95% (2,992 orders)**| $\le 5.00\%$ | **High Risk** |
| **Inventory**| Fulfillment Deficit Rate | **29.68% (4,452 orders)**| $\le 5.00\%$ | **Severe Deficit** |
| **Inventory**| Unmet Deficit Units | **445,082 Units** | 0 Units | High Exposure |

---

## 8. Rule-Based Operational Risk Analysis
The platform rejects black-box machine learning in favor of an auditable, rule-based operational risk engine:
1. **Supplier Risk**: Classifies vendors into *Critical High Risk*, *Moderate Risk*, and *Low Risk* based on combined on-time delivery percentage ($<49.5\%$), deficit rate ($>30\%$), and severe delay frequency ($\ge 8$ days).
2. **Inventory Risk**: Categorizes every order into *Critical Stockout*, *Deficit Shortfall*, *Understock Warning*, *Healthy Buffer*, or *Overstock Warning*.
3. **Delivery Risk**: Categorizes orders into *On-Time (Low Risk)*, *Minor Delay (Medium Risk)*, and *Severe Delay (High Risk)*.
4. **Cost Risk**: Flags small-batch dispatches ($<50$ units) carrying an exorbitant freight burden of ₹19.79 per unit vs ₹3.31 in bulk.

---

## 9. Power BI Interactive Dashboard Architecture
The 5-page Power BI dashboard is designed according to enterprise visual ergonomics:
- **PAGE 1: Executive Supply Chain Overview**: High-level cockpit showing revenue, fulfillment rate, OTD %, monthly velocity, and geographic alerts.
- **PAGE 2: Supplier Performance**: Scatter plot quadrant matrix comparing OTD % against fulfillment rate, lead time bars, and vendor scorecards.
- **PAGE 3: Inventory & Warehouse Logistics**: 100% stacked bar charts of inventory risk tiers, warehouse throughput vs stock on-hand, and SKU deficit treemaps.
- **PAGE 4: Orders & Delivery SLA Analytics**: Duration distribution histogram (1–10 days), regional transit lead times, and rolling 30-day order trends.
- **PAGE 5: Cost & Operational Risk Prioritization**: Scatter plot of unit freight economies of scale, risk radar matrix, and prioritized operational bottleneck action lists.

A comprehensive library of **40+ DAX measures** was authored to calculate dynamic rates, financial margins, rolling periods, and conditional KPI colors.

---

## 10. Empirical Findings & Strategic Recommendations

### Finding 1: Pervasive 50.04% Delivery SLA Breach
- **Evidence**: 7,506 out of 15,000 orders breached the 5-day contractual delivery window, averaging 3.01 days of late transit.
- **Impact**: Erodes brand reputation and exposes the enterprise to SLA non-compliance penalties.
- **Recommendation**: Transition from static 5-day SLAs to dynamic regional zone SLAs, and establish automated day-4 transit escalation alerts.

### Finding 2: Chronic Vendor Vulnerability in Supplier E
- **Evidence**: `Supplier E` registered the lowest on-time delivery rate (49.49%), highest average transit duration (5.55 days), highest severe delays (922 orders), and highest unmet deficit (92,022 units).
- **Impact**: Direct operational instability across all five distribution hubs.
- **Recommendation**: Issue a formal Supplier Performance Improvement Plan (PIP) and divert 20% of high-volume SKUs to `Supplier C` (top on-time performer at 51.58%).

### Finding 3: 29.68% Demand-Availability Deficit
- **Evidence**: 4,452 orders arrived when warehouse inventory was insufficient, creating 445,082 units of back-ordered demand.
- **Impact**: High split-shipment handling expenses and delayed customer gratification.
- **Recommendation**: Deploy dynamic safety stock buffers based on lead-time standard deviation, raising reorder levels on high-deficit items by 25%.

### Finding 4: Freight Diseconomy on Small Batch Dispatches
- **Evidence**: Sub-50 unit shipments cost ₹19.79 per unit in logistics freight, whereas bulk shipments (201–300 units) cost only ₹3.31 per unit.
- **Impact**: Severe margin leakage on 2,547 small orders.
- **Recommendation**: Enforce a 50-unit Minimum Order Quantity (MOQ) or a ₹250 low-volume logistics handling surcharge.

---

## 11. Limitations & Future Scope

### Limitations
1. **Deterministic Lead Times**: The dataset provides discrete 1-to-10 day delivery durations without GPS telemetry or multi-stop transit checkpoint timestamps.
2. **Fixed Product Lines**: The dataset captures 10 fixed product categories across 4 departments without seasonal product discontinuation.
3. **Simulated Synthetic Attributes**: Raw data reflects synthetic benchmark distributions common in academic datasets.

### Future Scope
1. **Predictive Time-Series Forecasting**: Incorporate ARIMA / Prophet forecasting models to anticipate regional demand spikes 60 days in advance.
2. **Automated Reverse Logistics Analytics**: Integrate return merchandise authorization (RMA) tracking and return freight cost analytics.
3. **Multi-Echelon Inventory Optimization (MEIO)**: Model inter-warehouse transfer routes allowing surplus inventory in Delhi to dynamically replenish deficits in Bangalore.
4. **Real-Time IoT Integration**: Connect streaming Kafka / MQTT feeds from telematics-enabled freight carriers to Power BI via DirectQuery / Streaming Datasets.

---

## 12. Conclusion
The **Supply Chain Intelligence & Operations Analytics Platform** successfully demonstrates the complete data engineering, database warehousing, analytical SQL, and business intelligence lifecycle. By transforming 15,000 raw operational records into normalized Star Schema relational tables, 28 high-impact analytical queries, a transparent risk engine, and an interactive 5-page Power BI dashboard, the project delivers defensible, enterprise-ready supply chain decision support. Every component is rigorously tested, fully documented, and engineered to standard B.Tech Computer Engineering excellence.
