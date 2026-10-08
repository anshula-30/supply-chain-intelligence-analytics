# Technical & Placement Interview Preparation Guide

This guide compiles 25+ real-world technical, architectural, and business interview questions based on the **Supply Chain Intelligence & Operations Analytics Platform**, complete with comprehensive model answers for Data Analyst, BI Developer, and Data Engineer roles.

---

## Pillar 1: Data Modeling & Architecture

### Q1: Why did you choose a Star Schema over 3NF or a single flat table for Power BI?
**Answer**:  
"While a single flat table avoids joins, it introduces severe column duplication, inflates memory footprint in Power BI's VertiPaq engine, and makes DAX time intelligence and multi-grain aggregations difficult. On the other hand, a strictly normalized 3NF schema creates snowflaked query chains that degrade interactive dashboard performance. A **Star Schema** provides the ideal balance:
1. Fast 1-to-Many single-direction relationships that VertiPaq compresses with maximum dictionary encoding.
2. Intuitive dimensional filtering where dimension attributes (`dim_suppliers`, `dim_warehouses`, `dim_products`, `dim_date`) cleanly slice numerical measures in `fact_supply_chain_orders`.
3. Maintenance simplicity, allowing changes in warehouse or supplier master data without updating 15,000 fact rows."

### Q2: What is the difference between active and inactive relationships in your Power BI model?
**Answer**:  
"In our fact table, there are two distinct date foreign keys: `order_date` (when the purchase was placed) and `delivery_date` (when goods arrived). Power BI does not allow multiple active relationships between the same two tables (`dim_date` and `fact_supply_chain_orders`) because it introduces ambiguous filter paths. We set `dim_date[date_key] -> fact_supply_chain_orders[order_date]` as the **active relationship** for standard business analysis. The relationship to `delivery_date` is configured as **inactive** and activated specifically when calculating delivery-centric measures using the DAX function `USERELATIONSHIP()`."

### Q3: How did you handle surrogate keys vs natural business keys?
**Answer**:  
"In the raw dataset, the first column was labelled `Product_ID` with unique values like `PROD1000` to `PROD15999`. Profiling revealed that these were actually individual transaction event keys, while product names (`Camera`, `Laptop`, etc.) repeated across categories. We separated natural business keys from surrogate operational keys:
- The transaction record was mapped to `order_id` (`ORD-1000`).
- For products, we created clean surrogate catalog keys (`PRD-ELEC-CAM`, `PRD-FASH-CAM`) combining department and item to uniquely represent distinct SKUs.
- Suppliers and warehouses were given standardized enterprise codes (`SUP-A` to `SUP-E`, `WH-BLR` to `WH-BOM`)."

---

## Pillar 2: SQL Analytics & Query Optimization

### Q4: Explain how you used Window Functions to perform ABC Inventory Pareto analysis in Query 08.
**Answer**:  
"To classify inventory according to the 80/20 Pareto principle, we utilized `SUM() OVER ()` window functions:
1. First, an inner CTE aggregated total sales revenue per product.
2. In the second CTE, we calculated the cumulative running revenue using `SUM(total_rev) OVER (ORDER BY total_rev DESC)` alongside the enterprise grand total `SUM(total_rev) OVER ()`.
3. In the outer query, we computed the cumulative percentage ratio `(running_cumulative_rev * 100.0 / total_enterprise_rev)`.
4. Using a `CASE` statement, products up to the 70th percentile were classified as **Class A** (Core Revenue Drivers), between 70% and 90% as **Class B**, and the remainder as **Class C**. This allowed dynamic classification without hardcoding thresholds."

### Q5: What is the difference between `RANK()`, `DENSE_RANK()`, and `ROW_NUMBER()` in your SQL analysis?
**Answer**:  
"In Query 03, where we ranked suppliers by composite reliability score:
- `ROW_NUMBER()` assigns a strictly unique sequential integer regardless of ties (e.g., 1, 2, 3, 4).
- `RANK()` leaves gaps in ranking numbers when values tie (e.g., 1, 2, 2, 4).
- `DENSE_RANK()` does not leave gaps after ties (e.g., 1, 2, 2, 3).  
We used `DENSE_RANK()` for supplier speed and fulfillment ranks so that if two suppliers tied for 2nd place, the next vendor would be cleanly ranked 3rd."

### Q6: How would you optimize your analytical SQL queries for production scale (100 million rows)?
**Answer**:  
"1. **Partitioning**: Range-partition the central fact table by `order_date` (e.g., monthly or quarterly partitions) so query engines prune unneeded partitions.
2. **Indexing**: Deploy composite B-tree indexes on frequently joined keys, such as `(order_date, warehouse_id)` and `(supplier_id, is_on_time)`.
3. **Materialized Views**: Convert complex analytical views that compute rolling 30-day metrics or ABC rankings into Materialized Views refreshed on a nightly cron schedule.
4. **Columnar Storage**: Migrate fact tables in PostgreSQL to a columnar extension like Citus/pg_analytics or ClickHouse for 10x-50x aggregation acceleration."

---

## Pillar 3: DAX & Business Intelligence

### Q7: Why use `DIVIDE()` instead of the standard `/` operator in DAX?
**Answer**:  
"In DAX, using `A / B` produces a division by zero error (`NaN` or `Infinity`) whenever the denominator is zero or blank. The `DIVIDE(numerator, denominator, [alternateResult])` function internally handles division by zero safely and allows returning an explicit fallback (such as 0 or BLANK), preventing visual crashes across Power BI cards and charts."

### Q8: What is the difference between `CALCULATE()` and `SUM()` in DAX?
**Answer**:  
"`SUM()` is a pure aggregation function that computes the arithmetic sum of a column in the current filter context. `CALCULATE()` is the most powerful function in DAX because it allows **modifying, replacing, or expanding the existing filter context**. For example, in our `[On-Time Orders]` measure:
```dax
CALCULATE(COUNTROWS('fact_supply_chain_orders'), 'fact_supply_chain_orders'[is_on_time] = 1)
```
`CALCULATE` overrides any visual context on `is_on_time` to filter strictly for orders where `is_on_time = 1`."

### Q9: How does your dynamic KPI color measure work in Power BI?
**Answer**:  
"We authored conditional formatting measures using the `SWITCH(TRUE(), ...)` pattern:
```dax
Delivery Risk KPI Color = 
SWITCH(
    TRUE(),
    [On-Time Delivery Rate %] < 0.495, "#D9534F", // Crimson Red
    [On-Time Delivery Rate %] < 0.505, "#F0AD4E", // Amber Warning
    "#5CB85C"                                    // Emerald Green
)
```
In Power BI visual formatting settings (e.g. Card background or KPI font), we select *Format by Field Value* and reference `[Delivery Risk KPI Color]`. As slicers change, the measure recalculates dynamically and updates visual colors."

---

## Pillar 4: Supply Chain Domain & Operations Analytics

### Q10: How do you define and calculate On-Time In-Full (OTIF)?
**Answer**:  
"**OTIF (On-Time In-Full)** is the gold standard metric in supply chain operations. An order is only considered OTIF if it meets two independent conditions:
1. **On-Time**: Delivered within contractual SLA ($\text{Shipping Days} \le 5$).
2. **In-Full**: 100% of the requested quantity is delivered without stock shortages ($\text{Stock\_Quantity} \ge \text{Units\_Sold}$).  
In our dataset, while the standalone On-Time rate was 49.96% and the standalone Fulfillment rate was 70.32%, the compound OTIF rate was approximately 35.1%, indicating that nearly 65% of customer shipments suffered from either delivery delay or fulfillment deficit."

### Q11: What is the bullwhip effect, and did you see evidence of it in your analysis?
**Answer**:  
"The **bullwhip effect** refers to the phenomenon where small fluctuations in retail end-consumer demand create increasingly severe swings in inventory orders as one moves upstream to distributors, warehouses, and suppliers. In our analysis, we observed that while customer order demand hovered consistently around ~625 orders per month, warehouse stock levels swung widely between zero stock (32 stockouts) and severe overstocking (>3x reorder level in 1,422 orders), demonstrating poor upstream replenishment synchronization."

### Q12: Why did small-batch orders carry such a high logistics cost per unit?
**Answer**:  
"Our logistics cost formula models realistic freight pricing:
$$\text{Logistics Cost} = \text{Base Freight (₹120)} + (\text{Units Sold} \times ₹2.50) + (\text{Shipping Days} \times ₹15.00)$$
Because the base freight of ₹120 and daily in-transit charge of ~₹82 are fixed per dispatch regardless of shipment size, dividing this fixed overhead by only 25 units yields an average logistics cost of **₹19.79 per unit**. For a bulk shipment of 250 units, the fixed overhead is diluted across ten times as many units, dropping the unit logistics cost to **₹3.31 per unit** (an 83.3% economy of scale)."

---

## Pillar 5: Business Impact & Strategic Decision Making

### Q13: If the VP of Operations asked you for the single highest-priority recommendation from your project, what would it be?
**Answer**:  
"The highest-priority recommendation is to **implement Dynamic Safety Stock Sizing for the top 10 deficit SKUs**. Currently, 29.68% of orders suffer from stock deficits, leaving 445,082 units of customer demand unmet and jeopardizing over ₹93 Cr in sales revenue. By dynamically scaling safety stock levels according to lead-time standard deviation and increasing reorder points by 25% on chronically understocked items (such as `Fashion - Camera` and `Electronics - Laptop`), the enterprise can reduce the deficit rate from 29.7% to under 10% within 60 days."

### Q14: How does your rule-based risk model compare to a machine learning classifier?
**Answer**:  
"While machine learning models (like Random Forests or XGBoost) are effective for probabilistic pattern recognition, they introduce several major drawbacks in operational governance:
1. **Explainability**: Operations managers and vendors reject penalties derived from a black-box model.
2. **Drift and Maintenance**: ML models require continuous retraining and monitoring for feature drift.
3. **Auditability**: Our rule-based scoring engine uses transparent mathematical conditions ($<49.5\%$ OTD + $>30\%$ Deficit). When a supplier is marked 'High Risk', they can be handed the exact audit trail of delayed dispatches, making penalties contractually defensible."
