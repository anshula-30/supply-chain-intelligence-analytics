# Final Year B.Tech Project Defense Presentation Deck Outline
## Topic: Supply Chain Intelligence & Operations Analytics Platform
**Duration**: 15 Minutes | **Target Audience**: Evaluation Committee & External Academic Examiners

---

### Slide 1: Title & Introduction (1 Minute)
- **Title**: Supply Chain Intelligence & Operations Analytics Platform
- **Sub-Title**: End-to-End Relational Data Warehousing, SQL Analytics, and Business Intelligence System
- **Candidate Details**: Final Year B.Tech Computer Engineering Capstone Project
- **Core Technology Stack**: PostgreSQL / MySQL 8.0 | Advanced SQL | Python (ETL) | Power BI | DAX | Git

---

### Slide 2: Problem Statement & Industrial Context (1 Minute)
- **The Modern Supply Chain Crisis**:
  - Unpredictable vendor lead times causing SLA breaches and lost customer trust.
  - Opaque warehouse stock levels leading to stockouts and chronic order fulfillment deficits.
  - Freight cost leakage on uncoordinated small-batch orders eroding net operating margins.
  - Data siloed in unstructured flat spreadsheets without relational integrity or executive visibility.
- **The Core Solution**: An end-to-end analytics platform transforming 15,000 raw operational records into actionable executive intelligence.

---

### Slide 3: Project Objectives & Architecture (1.5 Minutes)
- **System Objectives**:
  1. Automated data cleaning and 3NF/Star Schema normalization.
  2. Enterprise relational warehouse implementation with primary/foreign keys and B-tree indexing.
  3. Analytical SQL engine comprising 8 production views and 28 advanced queries.
  4. Explainable, rule-based operational risk scoring engine.
  5. Interactive 5-page Power BI dashboard with 40+ dynamic DAX measures.
- **Architecture Pipeline Diagram**:
  - Raw Dataset $\rightarrow$ Python ETL $\rightarrow$ Relational RDBMS $\rightarrow$ SQL Views/Queries $\rightarrow$ Risk Engine $\rightarrow$ Power BI Semantic Layer $\rightarrow$ Executive Decisions.

---

### Slide 4: Data Profiling, Cleaning & Dimensional Modeling (1 Minute)
- **Dataset Scale**: 15,000 records spanning 2 calendar years (2023–2024).
- **Integrity Validation**: Zero nulls, zero duplicates, verified temporal sequence (`Delivery_Date >= Order_Date`).
- **Surrogate vs Natural Keys**: Separated raw transaction identifiers (`order_id`) from SKU catalog definitions (`product_id`).
- **Dimensional Entities Created**:
  - `dim_suppliers` (5 Vendors) | `dim_warehouses` (5 Regional Hubs) | `dim_categories` (4 Departments) | `dim_products` (40 SKUs) | `dim_date` (762 Days) | `fact_supply_chain_orders` (15,000 Records).

---

### Slide 5: Database Schema & Entity-Relationship Design (1.5 Minutes)
- **Star Schema Architecture**: Central fact table surrounded by conformed dimension tables.
- **Join Cardinality**: Strict 1-to-Many ($1:N$) relationships with single-direction cross-filtering.
- **Data Integrity Constraints**:
  - Primary Key uniqueness and Foreign Key referential integrity (`ON DELETE RESTRICT`).
  - Domain Check Constraints (`units_sold >= 0`, `stock_quantity >= 0`, `shipping_time_days > 0`, `is_on_time IN (0, 1)`).
  - B-tree indexing on all foreign keys reducing search complexity from $O(N)$ to $O(\log N)$.

---

### Slide 6: Advanced SQL Analytical Processing (2 Minutes)
- **8 Production Views**: Reusable semantic views for supplier scorecards, warehouse throughput, inventory health, and SLA trends.
- **28 Analytical Queries Across 6 Pillars**:
  - *Advanced SQL Techniques*: Common Table Expressions (CTEs), Window Functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD`, `AVG OVER`), conditional aggregations, and rolling 30-day moving averages.
  - *Query 08 Showcase*: Pareto ABC Inventory Classification using cumulative window functions:
    ```sql
    SUM(total_rev) OVER (ORDER BY total_rev DESC) / SUM(total_rev) OVER ()
    ```
  - *Query 24 Showcase*: Month-over-Month Revenue & Shipping Growth using `LAG()`.

---

### Slide 7: KPI Framework & Mathematical Formulations (1 Minute)
- **Volume & Financials**: Total Orders (15,000), Revenue (₹307.63 Cr), Gross Margin (19.92%), Logistics Cost (₹85.93 Lakhs).
- **Service Levels**: On-Time Delivery Rate (49.96%), Average Shipping Time (5.50 Days), Average Delay (3.01 Days).
- **Fulfillment Health**: Fulfillment Rate (70.32%), Deficit Rate (29.68%), Stockout Incidents (32 / 0.21%), Understock Rate (19.95%).
- **Composite Vendor Health**: Supplier Reliability Index = $(0.5 \times \text{OTD \%}) + (0.5 \times \text{Fulfillment \%})$.

---

### Slide 8: Rule-Based Operational Risk Scoring Engine (1.5 Minutes)
- **Why Rule-Based instead of ML?**: Full explainability, auditability, and legal/contractual defensibility.
- **4 Operational Risk Pillars**:
  1. *Supplier Risk*: Classifies vendors into Critical High Risk, Moderate Risk, and Low Risk based on OTD $<49.5\%$ and Deficit $>30\%$.
  2. *Inventory Fragility*: Flags orders into Critical Stockout, Deficit Shortfall, Understock Warning, Healthy Buffer, and Overstock Warning.
  3. *Delivery SLA Risk*: On-Time (1–5 days), Minor Delay (6–7 days), Severe Delay (8–10 days).
  4. *Logistics Freight Risk*: Exposes unit cost inflation on sub-50 unit dispatches.

---

### Slide 9: Power BI Executive Dashboard Architecture (2 Minutes)
- **5-Page Analytical Layout**:
  - **Page 1: Executive Overview**: High-level cockpit with KPI callouts, monthly order velocity vs OTD trajectory, and warehouse alerts.
  - **Page 2: Supplier Performance**: Vendor quadrant scatter plot, lead time bars, and vendor scorecards.
  - **Page 3: Inventory & Warehouse Logistics**: 100% stacked bar chart of risk tiers, warehouse throughput, and SKU deficit treemap.
  - **Page 4: Orders & Delivery SLA Analytics**: Duration distribution histogram (1–10 days) and weekday transit bottlenecks.
  - **Page 5: Cost & Operational Risk Prioritization**: Unit freight economies of scale, risk radar matrix, and prioritized bottleneck action table.
- **DAX Semantic Layer**: 40+ modular measures organized in display folders with dynamic field-value conditional formatting.

---

### Slide 10: Empirical Findings (Data-Driven Evidence) (1.5 Minutes)
- **Finding 1 (Systemic SLA Failure)**: 50.04% of all orders breached the contractual 5-day SLA, averaging 3.01 days of late transit.
- **Finding 2 (Supplier E Friction)**: Logged the lowest OTD rate (49.49%), highest severe delays (922 orders), and 92,022 units of unmet customer demand.
- **Finding 3 (Demand-Availability Deficit)**: 29.68% of orders arrived when stock was insufficient, leaving 445,082 units unfulfilled.
- **Finding 4 (Freight Diseconomies of Scale)**: Sub-50 unit dispatches cost ₹19.79 per unit in freight vs ₹3.31 per unit for bulk dispatches (a 6x penalty).

---

### Slide 11: Strategic Business Recommendations (1 Minute)
- **Action 1 (Vendor Governance & PIP)**: Issue formal Performance Improvement Plan for Supplier E; re-route 20% of high-volume SKUs to Supplier C.
- **Action 2 (Dynamic Safety Stock Sizing)**: Scale reorder points by 25% on chronically understocked SKUs (`Fashion - Camera`, `Electronics - Laptop`) to cut deficits from 29.7% to $<10\%$.
- **Action 3 (Freight Optimization & MOQ)**: Enforce a 50-unit Minimum Order Quantity or a ₹250 handling surcharge to protect net operating margins.
- **Action 4 (Regional Route Optimization)**: Rebalance carrier allocations in Bangalore and Mumbai to resolve regional transit bottlenecks.

---

### Slide 12: Automated Verification, Quality Control & Defense Summary (1 Minute)
- **Automated Testing Suite (`tests/test_sql_analytics.py`)**:
  - 100% of the 8 production views and 28 analytical queries compiled and executed with zero errors.
  - Verified 100% mathematical consistency between database SQL outputs and Power BI DAX measures.
- **Limitations**: Whole-day delivery timestamps, synthetic benchmark distributions, and batch processing.
- **Future Scope**: Real-time Kafka telemetry ingestion, predictive demand forecasting, and Multi-Echelon Inventory Optimization (MEIO).
- **Conclusion**: A robust, academically defensible, and industrially viable Computer Engineering capstone platform.

---

### Slide 13: Thank You & Committee Q&A
- *Open floor for evaluation panel questions and viva examination.*
