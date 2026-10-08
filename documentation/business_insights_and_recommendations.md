# Empirical Supply Chain Business Insights & Strategic Recommendations

This document presents empirical findings derived from the statistical and SQL analysis of the 15,000 transaction records across 2 full operating years (2023–2024).

All insights follow the required institutional decision-making framework:  
**Finding → Evidence → Business Impact → Recommendation**

---

## Finding 1: Systemic Delivery Lead Time SLA Failure Across All Suppliers
- **Finding**: Delivery transit times are uniformly distributed between 1 and 10 days rather than clustering within the agreed 5-day contractual Service Level Agreement (SLA). More than 50% of all dispatches breach the customer SLA.
- **Evidence**:
  - Out of 15,000 orders, **7,506 shipments (50.04%) breached the 5-day SLA**, taking between 6 and 10 days to reach destinations.
  - Average shipping duration across the enterprise is **5.50 days**.
  - For the delayed cohort, the average delay is **3.01 days beyond the SLA**, with 4,502 shipments (30.01% of all shipments) suffering severe delays of 8 to 10 days.
  - Even the best-performing vendor (`Supplier C`) still suffered a **48.42% SLA breach rate** (1,473 delayed orders).
- **Business Impact**:
  - Customer trust erosion and high customer service ticket volumes.
  - Retail and wholesale partner SLA penalties.
  - Exposure to customer cancellation and lost lifetime value (LTV).
- **Recommendation**:
  1. Restructure vendor contracts to introduce dynamic lead-time SLA tiering based on warehouse destination zones.
  2. Implement an automated SLA Early-Warning Notification at Day 4 of transit.
  3. Partner with regional express 3PL (third-party logistics) providers for high-priority SKUs.

---

## Finding 2: Chronic Vendor Vulnerability & Deficit Concentration in Supplier E
- **Finding**: `Supplier E` demonstrates the highest operational friction across the supplier base, exhibiting the longest lead times, the highest number of severe delays, and the largest volume of unmet customer demand.
- **Evidence**:
  - `Supplier E` logged the longest average shipping time (**5.55 days**) and the lowest on-time delivery rate (**49.49%**).
  - `Supplier E` accumulated **922 severe delay orders (>= 8 days)**.
  - `Supplier E` had the highest fulfillment deficit rate (**30.48%**), generating **92,022 units of unmet customer demand**, representing over ₹12.5 Cr in unfulfilled demand volume.
- **Business Impact**:
  - Creates severe downstream fulfillment bottlenecks across all five distribution hubs.
  - Ties up customer service teams dealing with delayed dispatches and partial fulfillments.
- **Recommendation**:
  1. Institute a mandatory **Supplier Performance Improvement Plan (PIP)** for `Supplier E`.
  2. Shift 15–20% of procurement volume for high-velocity SKUs from `Supplier E` to `Supplier C`, which boasts the shortest lead time (5.39 days) and highest on-time compliance (51.58%).
  3. Link quarterly vendor payment terms and rebate structures to on-time in-full (OTIF) fulfillment thresholds.

---

## Finding 3: High Stock Deficit Rate (29.68%) Driving Fulfillment Failure
- **Finding**: Nearly 30% of incoming customer orders arrived at distribution centers when available on-hand inventory was insufficient to fulfill the ordered quantity.
- **Evidence**:
  - **4,452 out of 15,000 orders (29.68%) experienced a stock deficit** where `Stock_Quantity < Units_Sold`.
  - Cumulative unmet demand across these deficit orders reached **445,082 units**.
  - There were **32 total stock-out incidents** where on-hand stock was exactly 0 at the moment of order processing, jeopardizing ₹2.19 Cr in immediate revenue.
  - In addition, **2,992 orders (19.95%)** occurred when stock had already breached the safety reorder threshold (`Stock_Quantity < Reorder_Level`).
- **Business Impact**:
  - Orders must be split-shipped or back-ordered, multiplying warehouse handling touches and increasing freight expenses.
  - Direct customer dissatisfaction resulting from partial fulfillments.
- **Recommendation**:
  1. Shift from static reorder points to **Dynamic Safety Stock Sizing** based on demand variability and vendor lead-time variance.
  2. Increase the safety stock multiplier for top deficit SKUs (`Fashion - Camera`, `Fashion - Tablet`, `Electronics - Laptop`) by 25%.
  3. Implement automated reorder triggers that generate Purchase Orders as soon as stock reaches 1.25x the reorder level.

---

## Finding 4: Substantial Freight Cost Penalties on Small Batch Shipments
- **Finding**: Low-volume orders (1–50 units) incur disproportionately high logistics costs per unit compared to bulk shipments, representing significant margin leakage.
- **Evidence**:
  - Orders of **1–50 units** carry an average logistics cost of **₹19.79 per unit**.
  - Orders of **51–100 units** carry an average cost of **₹5.31 per unit**.
  - Orders of **201–300 units** achieve economies of scale at only **₹3.31 per unit** (an 83.3% cost reduction per unit).
  - Out of 15,000 orders, **2,547 orders (16.98%)** were small batch dispatches (<50 units), absorbing over ₹68 Lakhs in freight while contributing lower total revenue.
- **Business Impact**:
  - Erodes net operating margins on small orders, sometimes reducing net margin below 15%.
  - Increases warehouse handling congestion and packaging overhead.
- **Recommendation**:
  1. Establish a **Minimum Order Quantity (MOQ)** of 50 units for B2B/wholesale accounts or enforce a tiered freight surcharge for sub-50 unit orders.
  2. Implement order batching and consolidation algorithms in the Warehouse Management System (WMS) to combine regional deliveries into single dispatches.

---

## Finding 5: Bangalore and Mumbai Regional Transit Bottlenecks
- **Finding**: The southern and western logistics corridors centered at Bangalore and Mumbai experience the highest delivery delays and highest freight expenditures in the distribution network.
- **Evidence**:
  - **Bangalore Logistics Hub**: Highest delay incidence (**51.23%** of orders delayed), with an average transit time of **5.55 days** and total logistics cost of ₹17.33 Lakhs.
  - **Mumbai Central Hub**: Second highest delay incidence (**50.63%** of orders delayed), with average shipping time of **5.53 days** and the highest overall logistics spend (**₹17.42 Lakhs**).
  - In contrast, the **Delhi NCR Hub** achieved the shortest transit turnaround (**5.43 days**) and the lowest delay rate (**48.94%**).
- **Business Impact**:
  - Concentrates delivery dissatisfaction in high-demand economic metropolitan centers (Karnataka, Maharashtra, and adjoining industrial corridors).
- **Recommendation**:
  1. Re-negotiate carrier lane allocations in Bangalore and Mumbai, onboarding dedicated regional express linehaul carriers.
  2. Rebalance inventory by pre-positioning fast-moving items in satellite fulfillment facilities closer to urban delivery nodes.

---

## Finding 6: Product SKU Demand-Availability Imbalance in Cross-Category Goods
- **Finding**: Specific high-demand SKUs across Fashion and Electronics suffer acute fulfillment deficits, whereas other goods maintain excessive safety stock.
- **Evidence**:
  - Top deficit SKUs:
    1. `Fashion - Camera`: 13,680 unmet units across 386 orders.
    2. `Fashion - Tablet`: 13,479 unmet units across 394 orders.
    3. `Electronics - Laptop`: 12,906 unmet units across 380 orders.
    4. `Electronics - AC`: 12,883 unmet units across 376 orders.
  - Simultaneously, **overstocking (>3x reorder level)** was observed in 843 orders across slow-moving appliance lines, locking up over ₹4.5 Cr in idle working capital.
- **Business Impact**:
  - Inventory holding costs are incurred on the wrong items while top-selling items face stockouts and missed revenue.
- **Recommendation**:
  1. Implement an **ABC/XYZ Inventory Prioritization Matrix**: Allocate 60% of working capital strictly to Category A/X items.
  2. Run targeted promotional clearance on slow-moving overstocked appliance items to release trapped liquidity and warehouse floor space.

---

## Summary Action Matrix

| Initiative | Priority | Target Area | Expected Impact | Timeline |
| :--- | :--- | :--- | :--- | :--- |
| **Vendor OTIF Governance & PIP** | High | Supplier E & B | Reduce severe delays by 35% | Q1 |
| **Dynamic Reorder Point Calibration** | High | Top 10 Deficit SKUs | Cut stock deficit rate from 29.7% to < 10% | Immediate |
| **Small-Order Freight Surcharge & MOQ**| Medium | Orders < 50 Units | Save ~₹18–22 Lakhs annually in freight | Q1 |
| **Bangalore / Mumbai Linehaul Route Review**| Medium | South & West Hubs | Improve on-time delivery rate to > 65% | Q2 |
| **Working Capital Rationalization** | Medium | Overstocked Goods | Free up ₹4.5 Cr in trapped liquidity | Q2 |
