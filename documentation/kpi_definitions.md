# Core KPI Framework & Mathematical Formulations

This document provides formal definitions, mathematical equations, SQL queries, DAX formulas, target benchmarks, and actual baseline values for all supply chain Key Performance Indicators (KPIs).

---

## 1. Summary KPI Matrix

| KPI Name | Category | Mathematical Formula | Target Benchmark | Actual Baseline |
| :--- | :--- | :--- | :--- | :--- |
| **Total Orders** | Volume | $\sum \text{Orders}$ | Growth Target | **15,000 Orders** |
| **Total Units Sold** | Volume | $\sum \text{Units\_Sold}$ | Growth Target | **2,222,508 Units** |
| **Fulfillment Rate** | Operational | $\frac{\text{Fulfilled Orders}}{\text{Total Orders}} \times 100$ | $\ge 95.00\%$ | **70.32%** |
| **On-Time Delivery Rate** | Service Level | $\frac{\text{Orders with Shipping Time} \le 5}{\text{Total Orders}} \times 100$ | $\ge 90.00\%$ | **49.96%** |
| **Average Shipping Lead Time** | Velocity | $\frac{\sum \text{Shipping\_Time\_Days}}{\text{Total Orders}}$ | $\le 4.0\text{ Days}$ | **5.50 Days** |
| **Average Delivery Delay** | Service Level | $\frac{\sum \max(0, \text{Shipping\_Time} - 5)}{\text{Delayed Orders}}$ | $\le 1.0\text{ Day}$ | **3.01 Days** |
| **Supplier Reliability Index** | Vendor Perf | $(0.5 \times \text{OTD \%}) + (0.5 \times \text{Fulfillment \%})$ | $\ge 85.00\%$ | **60.14%** |
| **Stock-Out Rate** | Inventory Risk| $\frac{\text{Orders with Stock} = 0}{\text{Total Orders}} \times 100$ | $\le 0.05\%$ | **0.21% (32 orders)** |
| **Understock Warning Rate**| Inventory Risk| $\frac{\text{Orders with Stock} < \text{Reorder Level}}{\text{Total Orders}} \times 100$ | $\le 5.00\%$ | **19.95% (2,992 orders)**|
| **Fulfillment Deficit Rate**| Fulfillment | $\frac{\text{Orders with Stock} < \text{Units Demanded}}{\text{Total Orders}} \times 100$ | $\le 5.00\%$ | **29.68% (4,452 orders)**|
| **Inventory Availability %**| Inventory | $100\% - \text{Fulfillment Deficit Rate}$ | $\ge 95.00\%$ | **70.32%** |
| **Inventory Turnover Proxy**| Inventory | $\frac{\text{Total Units Sold}}{\text{Average On-Hand Stock}}$ | $\ge 12.0\times$ | **8.86x** |
| **Total Revenue** | Financial | $\sum (\text{Units\_Sold} \times \text{Selling\_Price})$ | Maximized | **₹3,076,312,144** |
| **Gross Margin %** | Financial | $\frac{\text{Total Revenue} - \text{Total COGS}}{\text{Total Revenue}} \times 100$ | $\ge 20.00\%$ | **19.92%** |
| **Total Logistics Cost** | Efficiency | $\sum [120 + (2.50 \times \text{Units}) + (15 \times \text{Days})]$ | Minimized | **₹8,592,900** |
| **Logistics Cost per Order**| Efficiency | $\frac{\text{Total Logistics Cost}}{\text{Total Orders}}$ | $\le ₹500$ | **₹572.86** |
| **Cumulative Deficit Units**| Backlog Exposure| $\sum \max(0, \text{Units\_Sold} - \text{Stock\_Quantity})$ | $0\text{ Units}$ | **445,082 Units** |
| **Zero Demand / Stalled Rate**| Demand Health | $\frac{\text{Orders with Units} = 0}{\text{Total Orders}} \times 100$ | $\le 0.10\%$ | **0.33% (49 orders)** |

---

## 2. Detailed Mathematical & Code Specifications

### KPI 01: Fulfillment Rate (%)
- **Business Meaning**: Measures the proportion of customer orders that can be 100% fulfilled immediately from available on-hand inventory without back-ordering or partial delivery.
- **Formula**:
  $$\text{Fulfillment Rate} = \frac{\text{Count of Orders where Stock\_Quantity} \ge \text{Units\_Sold}}{\text{Total Orders}} \times 100$$
- **SQL Implementation**:
  ```sql
  SELECT ROUND(SUM(CASE WHEN stock_quantity >= units_sold THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fulfillment_rate_pct
  FROM fact_supply_chain_orders;
  ```
- **DAX Implementation**:
  ```dax
  Fulfillment Rate % = 
  DIVIDE(
      CALCULATE(COUNTROWS('fact_supply_chain_orders'), 'fact_supply_chain_orders'[fulfillment_status] = "Fulfilled"),
      COUNTROWS('fact_supply_chain_orders'),
      0
  )
  ```

---

### KPI 02: On-Time Delivery Rate (OTD %)
- **Business Meaning**: The percentage of completed orders that reached the customer within the agreed Service Level Agreement (SLA) turnaround window of 5 days.
- **Formula**:
  $$\text{OTD \%} = \frac{\text{Count of Orders with Shipping\_Time\_Days} \le 5}{\text{Total Orders}} \times 100$$
- **SQL Implementation**:
  ```sql
  SELECT ROUND(SUM(CASE WHEN shipping_time_days <= 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS otd_rate_pct
  FROM fact_supply_chain_orders;
  ```
- **DAX Implementation**:
  ```dax
  On-Time Delivery Rate % = 
  DIVIDE(
      CALCULATE(COUNTROWS('fact_supply_chain_orders'), 'fact_supply_chain_orders'[is_on_time] = 1),
      COUNTROWS('fact_supply_chain_orders'),
      0
  )
  ```

---

### KPI 03: Average Delivery Delay (Days)
- **Business Meaning**: For orders that breached the contractual 5-day SLA, this measures the average number of late days suffered before final delivery.
- **Formula**:
  $$\text{Avg Delay (Late Orders)} = \frac{\sum_{\text{Days} > 5} (\text{Shipping\_Time\_Days} - 5)}{\text{Count of Orders with Shipping\_Time\_Days} > 5}$$
- **SQL Implementation**:
  ```sql
  SELECT ROUND(AVG(shipping_time_days - 5), 2) AS avg_delay_days_late
  FROM fact_supply_chain_orders
  WHERE shipping_time_days > 5;
  ```
- **DAX Implementation**:
  ```dax
  Average Delay Days (Delayed Orders Only) = 
  CALCULATE(
      AVERAGE('fact_supply_chain_orders'[delivery_delay_days]),
      'fact_supply_chain_orders'[delivery_delay_days] > 0
  )
  ```

---

### KPI 04: Supplier Reliability Index
- **Business Meaning**: A composite 0–100% operational vendor health index balancing logistical punctuality (OTD %) and fulfillment readiness.
- **Formula**:
  $$\text{Reliability Index} = (0.50 \times \text{OTD \%}) + (0.50 \times \text{Fulfillment Rate \%})$$
- **SQL Implementation**:
  ```sql
  SELECT 
      supplier_id,
      ROUND(
          (SUM(is_on_time) * 100.0 / COUNT(*)) * 0.5 + 
          (SUM(CASE WHEN fulfillment_status = 'Fulfilled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) * 0.5,
          2
      ) AS supplier_reliability_index
  FROM fact_supply_chain_orders
  GROUP BY supplier_id;
  ```
- **DAX Implementation**:
  ```dax
  Supplier Reliability Index = 
  ([On-Time Delivery Rate %] * 0.50) + ([Fulfillment Rate %] * 0.50)
  ```

---

### KPI 05: Stock-Out Rate & Understock Warning Rate (%)
- **Business Meaning**: Measures inventory fragility: Stock-Out indicates zero stock available (immediate crisis); Understock indicates stock dipping below the minimum buffer threshold (replenishment urgency).
- **Formulas**:
  $$\text{Stock-Out Rate} = \frac{\text{Count of Orders with Stock} = 0}{\text{Total Orders}} \times 100$$
  $$\text{Understock Rate} = \frac{\text{Count of Orders with Stock} < \text{Reorder\_Level}}{\text{Total Orders}} \times 100$$
- **SQL Implementation**:
  ```sql
  SELECT 
      ROUND(SUM(stockout_flag) * 100.0 / COUNT(*), 2) AS stockout_rate_pct,
      ROUND(SUM(understock_flag) * 100.0 / COUNT(*), 2) AS understock_rate_pct
  FROM fact_supply_chain_orders;
  ```
- **DAX Implementation**:
  ```dax
  Stockout Rate % = DIVIDE(CALCULATE(COUNTROWS('fact_supply_chain_orders'), 'fact_supply_chain_orders'[stockout_flag] = 1), [Total Orders], 0)
  Understock Rate % = DIVIDE(CALCULATE(COUNTROWS('fact_supply_chain_orders'), 'fact_supply_chain_orders'[understock_flag] = 1), [Total Orders], 0)
  ```

---

### KPI 06: Logistics Cost per Order & Unit
- **Business Meaning**: Quantifies the transportation and fulfillment handling expenditure consumed per sales transaction and per individual physical unit moved.
- **Formula**:
  $$\text{Logistics Cost per Order} = \frac{\text{Total Freight Cost}}{\text{Total Orders}}, \quad \text{Cost per Unit} = \frac{\text{Total Freight Cost}}{\text{Total Units Sold}}$$
- **SQL Implementation**:
  ```sql
  SELECT 
      ROUND(SUM(logistics_cost) / COUNT(*), 2) AS cost_per_order,
      ROUND(SUM(logistics_cost) / SUM(units_sold), 2) AS cost_per_unit
  FROM fact_supply_chain_orders;
  ```
- **DAX Implementation**:
  ```dax
  Logistics Cost per Order = DIVIDE([Total Logistics Cost], [Total Orders], 0)
  Logistics Cost per Unit = DIVIDE([Total Logistics Cost], [Total Units Sold], 0)
  ```
