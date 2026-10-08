# System Architecture Diagram

The Supply Chain Intelligence & Operations Analytics Platform is built on a decoupled, production-grade 6-stage end-to-end analytics engineering pipeline.

```mermaid
flowchart TD
    subgraph S1["1. Raw Data Ingestion Layer"]
        A["Public Supply Chain Dataset<br/>(15,000 Records, Excel / CSV)"]
        A1["Unnormalized Transaction Logs<br/>13 Raw Columns: Product, Supplier, Dates, Stock, Pricing"]
        A --> A1
    end

    subgraph S2["2. Data Cleaning & Normalization Layer (Python / ETL)"]
        B["Python ETL Pipeline<br/>(scripts/data_cleaning.py)"]
        B1["Integrity Validation<br/>(Null checks, deduplication, date sequencing)"]
        B2["Dimensional Normalization (3NF / Star Schema)<br/>Suppliers, Warehouses, Categories, Products, Date"]
        B3["Feature Engineering & Business Logic<br/>Deficits, Margin, Logistics Cost, Risk Classification"]
        A1 --> B
        B --> B1 --> B2 --> B3
    end

    subgraph S3["3. Enterprise Relational Database Layer (SQL)"]
        C["Relational Database Engine<br/>PostgreSQL 13+ / MySQL 8.0+ / SQLite 3"]
        C1[("dim_suppliers (5)")]
        C2[("dim_warehouses (5)")]
        C3[("dim_categories (4)")]
        C4[("dim_products (40)")]
        C5[("dim_date (762)")]
        C6[("fact_supply_chain_orders (15,000)")]
        B3 --> C
        C --> C1 & C2 & C3 & C4 & C5 & C6
    end

    subgraph S4["4. Analytical Processing & Risk Scoring Engine"]
        D["8 Production SQL Views<br/>(Supplier, Warehouse, Inventory, SLA Trends)"]
        E["28 Advanced Analytical SQL Queries<br/>(CTEs, Window Functions, Rolling Averages, Pareto ABC)"]
        F["Rule-Based Operational Risk Engine<br/>(Supplier Risk, Inventory Fragility, Delivery SLA Risk)"]
        C6 --> D
        C6 --> E
        C6 --> F
    end

    subgraph S5["5. Business Intelligence & DAX Semantic Layer"]
        G["Power BI Data Model<br/>(Star Schema, 1-to-Many Relationships, Single Cross-Filter)"]
        H["DAX Measure Library<br/>(40+ Measures: Financials, OTD %, Deficits, Time Intelligence, Risk Status)"]
        D --> G
        F --> G
        G --> H
    end

    subgraph S6["6. Executive Presentation & Decision Layer"]
        I["Power BI Interactive Dashboard (5 Pages)"]
        I1["Page 1: Executive Overview"]
        I2["Page 2: Supplier Performance"]
        I3["Page 3: Inventory & Warehouse"]
        I4["Page 4: Orders & Delivery"]
        I5["Page 5: Cost & Operational Risk"]
        J["Strategic Business Actions<br/>(Vendor PIP, Safety Stock Dynamic Sizing, MOQ Surcharge)"]
        H --> I
        I --> I1 & I2 & I3 & I4 & I5
        I --> J
    end

    style S1 fill:#E3F2FD,stroke:#1565C0,stroke-width:2px;
    style S2 fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;
    style S3 fill:#FFF3E0,stroke:#E65100,stroke-width:2px;
    style S4 fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px;
    style S5 fill:#EDE7F6,stroke:#4527A0,stroke-width:2px;
    style S6 fill:#ECEFF1,stroke:#37474F,stroke-width:2px;
```

---

## Architecture Component Description

1. **Raw Ingestion Layer**: Takes unnormalized operational logistics data comprising 15,000 historical order transactions spanning 2023–2024.
2. **Data Cleaning & ETL Layer**: Automated Python script (`scripts/data_cleaning.py`) executes data validation, cleans whitespace, parses dates, derives financial metrics, applies the logistics freight cost model, assigns operational risk tiers, and exports 3NF conformed CSV tables.
3. **Enterprise SQL Layer**: PostgreSQL 13+ and MySQL 8.0+ DDL scripts enforce primary keys, foreign key constraints, column validations, and B-tree indexes across fact and dimension tables.
4. **Analytical SQL Engine**: 8 reusable SQL views and 28 analytical queries execute complex window functions, running totals, rolling averages, conditional aggregations, and Pareto ABC classifications to answer core business questions.
5. **Power BI & DAX Modeling**: Star schema with single-direction 1:* relationships, coupled with a comprehensive DAX measure library in display folders.
6. **Executive Dashboard & Decision Layer**: 5-page interactive Power BI dashboard delivering cross-filtering, slicers, KPI alert cards, and drill-through paths to convert analytical findings into high-ROI business interventions.
