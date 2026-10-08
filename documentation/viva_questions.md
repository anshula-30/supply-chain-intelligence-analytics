# Academic Viva Voce Defense Questions & Answers
## Final Year B.Tech Computer Engineering Capstone Examination

This document provides 25+ academic viva voce examination questions with rigorous, defensible answers tailored for final-year engineering project evaluation panels.

---

### Q1: What is the core Computer Engineering contribution of this capstone project?
**Answer**:  
"This project applies foundational computer engineering disciplines—specifically relational database management systems (RDBMS), data warehousing principles, dimensional modeling, automated ETL software engineering, and query optimization—to solve a complex operational domain problem. Rather than treating analytics as a purely aesthetic charting exercise, we engineered a deterministic data pipeline that transforms raw unstructured logs into 3NF conformed relational schemas, enforces strict referential integrity, indexes query access paths, executes complex window-function analytical queries, and surfaces metrics through an interactive BI semantic layer."

### Q2: Why did you design the database using a Star Schema instead of a Snowflake Schema?
**Answer**:  
"In a Snowflake Schema, dimension tables are normalized into multiple sub-tables (e.g. `dim_categories` separate from `dim_subcategories` separate from `dim_products`). While this minimizes database redundancy, it requires multiple relational joins during queries. In analytical processing and columnar engines like Power BI's VertiPaq, joins across snowflaked dimensions incur computational overhead. A Star Schema denormalizes non-key attributes into single dimension tables surrounding a central fact table, reducing join depth to a single level ($O(1)$ join depth) and drastically speeding up multi-dimensional aggregations."

### Q3: What is the granularity (grain) of your fact table?
**Answer**:  
"The grain of `fact_supply_chain_orders` is strictly **one individual order dispatch event per row**. Each record captures the atomic state of that specific order transaction: the product ordered, the supplier responsible, the warehouse fulfilling it, the order and delivery timestamps, the quantity demanded, the inventory on hand at that exact event, and the incurred logistics cost. This atomic grain allows slicing at any level of aggregation without losing transactional fidelity."

### Q4: Explain the role of database indexing in your project and the time complexity impact.
**Answer**:  
"Without indexes, evaluating queries with filter criteria (such as `WHERE order_date BETWEEN ...` or `JOIN dim_suppliers ON ...`) requires a full table scan of all 15,000 records, operating in $O(N)$ linear time complexity. We created B-tree indexes on all foreign key columns (`order_date`, `delivery_date`, `product_id`, `supplier_id`, `warehouse_id`) and high-cardinality status flags (`fulfillment_status`, `is_on_time`). B-tree indexes reduce lookup and join time complexity to $O(\log N)$, drastically improving query throughput."

### Q5: What integrity constraints did you enforce at the database layer?
**Answer**:  
"We enforced four tiers of constraints:
1. **Entity Integrity**: Primary keys on all tables (`order_id`, `supplier_id`, `warehouse_id`, `product_id`, `category_id`, `date_key`).
2. **Referential Integrity**: Foreign keys in the fact table linking back to primary keys in dimension tables with `ON DELETE RESTRICT` to prevent orphaned records.
3. **Domain Constraints**: `NOT NULL` constraints on critical business attributes.
4. **Check Constraints**: `CHECK (units_sold >= 0)`, `CHECK (stock_quantity >= 0)`, `CHECK (shipping_time_days > 0)`, `CHECK (is_on_time IN (0, 1))`, and `CHECK (storage_capacity_sqft > 0)`."

### Q6: Why did you use Python only for data cleaning rather than building a web app in Flask or React?
**Answer**:  
"The problem statement explicitly focuses on enterprise **Business Intelligence and Operational Analytics**. Building a lightweight CRUD web app in Flask or React would shift the engineering focus toward web UI routing and frontend styling rather than advanced data modeling, relational schema engineering, window-function SQL analytics, and interactive BI reporting. Power BI is the gold standard enterprise user-facing analytical dashboard. Python was appropriately used as a headless ETL tool for data validation, cleaning, and dimensional normalization."

### Q7: Explain the window function `LAG()` used in Query 24 and how it operates.
**Answer**:  
"`LAG(expression, offset, default)` is an ANSI SQL window function that accesses data from a previous row in the same result set without requiring a self-join. In Query 24:
```sql
LAG(monthly_revenue, 1) OVER (ORDER BY year_month) AS prev_month_revenue
```
It reads the revenue of the preceding calendar month based on chronological ordering, enabling instantaneous calculation of Month-over-Month (MoM) revenue growth:
$$\text{MoM Growth \%} = \frac{\text{Current Month Revenue} - \text{Previous Month Revenue}}{\text{Previous Month Revenue}} \times 100$$
Using `LAG()` reduces the computational complexity of sequential comparison from $O(N^2)$ (self-join) to $O(N \log N)$ (sorting window)."

### Q8: What is the difference between an analytical view and a physical table?
**Answer**:  
"A physical table stores data persistently on disk inside data blocks and consumes storage space. A view is a stored SQL query (a virtual table) that does not store physical data; instead, it dynamically executes its underlying query definition whenever queried. In our platform, the 8 production views provide a clean semantic abstraction layer, allowing Power BI or external BI clients to query complex aggregations without needing to write repetitive joins and calculations."

### Q9: How did you validate that your SQL queries and DAX measures produce identical results?
**Answer**:  
"We developed an automated Python testing harness (`tests/test_sql_analytics.py`) that executes all 28 analytical queries and 8 views against the test database, asserting ground-truth baselines:
- Total Orders: exactly 15,000 in both SQL and DAX (`COUNTROWS`).
- Total Units Sold: exactly 2,222,508 in both SQL and DAX (`SUM`).
- Total Revenue: exactly ₹3,076,312,144 in both SQL and DAX.
- On-Time Orders: exactly 7,494 (49.96%) in both SQL and DAX.
- Stockout Incidents: exactly 32 in both SQL and DAX.
This ensures complete semantic consistency between the database warehouse and the BI dashboard."

### Q10: How does Power BI's VertiPaq in-memory engine optimize analytical queries?
**Answer**:  
"VertiPaq is a columnar, in-memory analytical database engine. Unlike row-oriented databases (which store entire rows contiguously), VertiPaq stores each column separately. This enables:
1. **Dictionary Encoding**: Replacing repetitive strings (such as warehouse names or status text) with compact integer bit masks.
2. **Run-Length Encoding (RLE)**: Compressing repeated consecutive values.
3. **Columnar Scans**: When computing `SUM(total_revenue)`, VertiPaq scans only the `total_revenue` column in CPU cache without reading any other columns, delivering sub-second response times across large datasets."

### Q11: What is the difference between a calculated column and a measure in DAX?
**Answer**:  
"- **Calculated Column**: Evaluated row-by-row during data load, stored permanently in RAM, and increases the file size of the model.
- **DAX Measure**: Evaluated on-the-fly dynamically depending on the current user filter context (slicers, visual selections, row/column headers). Measures do not consume RAM at rest and are calculated instantaneously in memory.  
To optimize memory performance, all our analytical metrics (such as `[Fulfillment Rate %]`, `[On-Time Delivery Rate %]`, `[Gross Margin %]`) were engineered strictly as dynamic measures."

### Q12: Why did you choose a rule-based operational risk engine over machine learning?
**Answer**:  
"In enterprise operations and contractual governance, decisions to penalize suppliers or halt procurement require **explainability, determinism, and auditability**. If a machine learning model assigns a high risk probability, the vendor and executive team cannot inspect why. With our rule-based framework, a supplier is categorized as High Risk because of a specific mathematical breach (OTD < 49.5% and Deficit > 30%). This provides an airtight audit trail that is legally and contractually defensible."

### Q13: How did you ensure data hygiene during the ETL process?
**Answer**:  
"Our ETL script (`scripts/data_cleaning.py`) applied automated validation gates:
1. Verified zero missing values across all fields.
2. Checked for duplicate rows.
3. Validated chronological order (`Delivery_Date >= Order_Date`).
4. Checked for non-negative values across stock quantities, units sold, and prices.
5. Standardized string casing and trimmed leading/trailing whitespace.
6. Enforced conformed code mappings for suppliers, warehouses, and categories."

### Q14: What would happen if a new supplier or warehouse is onboarded in the future?
**Answer**:  
"Because of our modular dimensional design:
1. A new record is inserted into `dim_suppliers` with a new `supplier_id` (e.g. `SUP-F`) and contractual SLA days.
2. Future orders in `fact_supply_chain_orders` simply reference `SUP-F`.
3. The SQL views, queries, Power BI data model, and DAX measures adapt dynamically without requiring any schema refactoring or query code modifications."

### Q15: What are the main limitations of the current implementation?
**Answer**:  
"The primary limitations are:
1. Historical batch processing rather than streaming real-time event ingestion (such as Apache Kafka).
2. Transit lead times are recorded as whole calendar days without granular hourly or checkpoint-level GPS telematics.
3. Pricing and cost figures represent transaction snapshots rather than dynamic supplier tier discount curves."
