# Rule-Based Operational Risk Analysis Framework

## 1. Principles of the Risk Framework
This framework establishes a deterministic, transparent, and auditable operational risk scoring engine. 

> **Design Principle**: This system deliberately avoids opaque "black-box" machine learning algorithms. In enterprise supply chain and regulatory compliance environments, stakeholders require **deterministic rules** where any risk score can be directly traced back to specific contract breaches, stock thresholds, or delivery metrics.

---

## 2. Risk Pillar 1: Supplier Operational Risk

### A. Evaluation Parameters
1. **On-Time Delivery Compliance (OTD %)**: Target contractual threshold is $\ge 50.0\%$ (benchmark $\ge 90\%$).
2. **Fulfillment Deficit Rate**: Proportion of orders where vendor inventory failed to satisfy customer demand.
3. **Severe Delays**: Frequency of shipments delayed by 3+ days beyond SLA ($\ge 8$ days in transit).

### B. Classification Rules & Logic
```
IF (OTD % < 49.50% AND Deficit Rate > 30.00%) OR Severe Delays Count > 900 THEN
    Supplier Risk = 'CRITICAL HIGH RISK'
    Action: Freeze contract expansion, mandate formal PIP, divert 20% order volume.

ELSE IF (OTD % < 50.00% OR Deficit Rate > 29.50%) THEN
    Supplier Risk = 'MODERATE RISK'
    Action: Bi-weekly operational reviews, safety buffer multiplier +15%.

ELSE
    Supplier Risk = 'LOW RISK (PREFERRED)'
    Action: Prioritize for multi-year contract renewals and volume discounts.
```

### C. Empirical Classification of Suppliers

| Supplier | OTD Rate % | Deficit Rate % | Avg Shipping Days | Severe Delays (>=8 Days) | Risk Category | Operational Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Supplier E** | 49.49% | 30.48% | 5.55 Days | 922 Orders | **CRITICAL HIGH RISK** | Worst delays & largest unmet deficit |
| **Supplier B** | 49.43% | 29.90% | 5.52 Days | 884 Orders | **MODERATE RISK** | Sub-par punctuality |
| **Supplier D** | 49.39% | 29.21% | 5.54 Days | 903 Orders | **MODERATE RISK** | High severe delay count |
| **Supplier A** | 49.88% | 29.49% | 5.48 Days | 890 Orders | **MODERATE RISK** | Average performer |
| **Supplier C** | **51.58%** | **29.32%** | **5.39 Days** | 903 Orders | **LOW RISK (PREFERRED)** | Top punctuality & shortest lead time |

---

## 3. Risk Pillar 2: Inventory Fragility & Buffer Risk

### A. Evaluation Parameters
Evaluated at the level of each individual order transaction using real-time on-hand stock (`Stock_Quantity`), reorder threshold (`Reorder_Level`), and customer demand (`Units_Sold`).

### B. Classification Rules & Logic

```
SWITCH:
    CASE 1: Stock_Quantity = 0
            -> Category: 'CRITICAL STOCKOUT'
            -> Severity: Grade 1 (Emergency)
            -> Trigger: Stock-out incident alert, immediate emergency replenishment.

    CASE 2: Stock_Quantity < Units_Sold AND Stock_Quantity > 0
            -> Category: 'DEFICIT SHORTFALL'
            -> Severity: Grade 2 (High)
            -> Trigger: Back-order creation, split fulfillment dispatched.

    CASE 3: Stock_Quantity < Reorder_Level AND Stock_Quantity >= Units_Sold
            -> Category: 'UNDERSTOCK WARNING'
            -> Severity: Grade 3 (Medium)
            -> Trigger: Automated replenishment Purchase Order issued to vendor.

    CASE 4: Stock_Quantity > (3 * Reorder_Level)
            -> Category: 'OVERSTOCK WARNING'
            -> Severity: Grade 4 (Capital Risk)
            -> Trigger: Freeze new procurement, schedule promotional clearance.

    DEFAULT:
            -> Category: 'HEALTHY OPERATING BUFFER'
            -> Severity: Normal
            -> Trigger: Standard operating cycle.
```

### C. Empirical Inventory Risk Distribution

| Inventory Risk Category | Total Orders | Percentage Share | Demand Units | Unmet Deficit Units | Revenue at Risk (INR) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Healthy Operating Buffer** | 7,651 | 51.01% | 1,128,477 | 0 | ₹1,561,845,980 |
| **Deficit Shortfall** | 4,420 | 29.47% | 674,844 | 440,240 | ₹932,962,692 |
| **Understock Warning** | 1,475 | 9.83% | 215,815 | 0 | ₹299,997,428 |
| **Overstock Warning** | 1,422 | 9.48% | 198,530 | 0 | ₹274,685,735 |
| **Critical Stockout** | 32 | 0.21% | 4,842 | 4,842 | ₹6,820,309 |

---

## 4. Risk Pillar 3: Delivery SLA Breach Risk

### A. Evaluation Parameters
Measures fulfillment lead time elapsed between `Order_Date` and `Delivery_Date` against contractual Service Level Agreements (5 calendar days).

### B. Classification Rules & Logic
```
IF Shipping_Time_Days <= 5 THEN
    Delivery Risk = 'ON-TIME (LOW RISK)'
    Action: Standard tracking status.

ELSE IF Shipping_Time_Days IN (6, 7) THEN
    Delivery Risk = 'MINOR DELAY (MEDIUM RISK)'
    Action: Automated customer delay SMS/email notification, priority handling.

ELSE (Shipping_Time_Days >= 8) THEN
    Delivery Risk = 'SEVERE DELAY (HIGH RISK)'
    Action: Mandatory customer service escalation, expedited freight credit voucher.
```

### C. Empirical Delivery Risk Distribution

| Delivery Cohort | Elapsed Days | Order Count | Share % | Avg Delay Days | Cumulative Logistics Cost (INR) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **On-Time (Low Risk)** | 1 – 5 Days | 7,494 | 49.96% | 0.00 Days | ₹4,228,840 |
| **Minor Delay (Medium Risk)**| 6 – 7 Days | 3,004 | 20.03% | 1.50 Days | ₹1,749,535 |
| **Severe Delay (High Risk)** | 8 – 10 Days | 4,502 | 30.01% | 4.01 Days | ₹2,614,525 |

---

## 5. Risk Pillar 4: Logistics Unit Economics & Freight Cost Risk

### A. Evaluation Parameters
Logistics Cost Formula:
$$\text{Logistics Cost} = \text{Base Freight (₹120)} + (\text{Units Sold} \times ₹2.50) + (\text{Shipping Days} \times ₹15.00)$$

Cost Risk is measured via **Freight-to-Revenue Ratio** and **Freight Cost per Unit Shipped**.

### B. Classification Rules & Logic
```
IF Units_Sold <= 50 THEN
    Cost Risk = 'HIGH FREIGHT BURDEN'
    Reason: Disproportionate base freight overhead (Avg ₹19.79 per unit vs ₹3.31 in bulk).
    Mitigation: Enforce 50-unit Minimum Order Quantity (MOQ) or ₹250 handling surcharge.

ELSE IF Logistics_Cost / Gross_Profit > 0.05 (5.0%) THEN
    Cost Risk = 'MARGIN EROSION RISK'
    Mitigation: Route through closest regional distribution center.

ELSE
    Cost Risk = 'OPTIMAL FREIGHT COST'
```

---

## 6. Integrated Multi-Risk Priority Matrix

By combining **Inventory Risk** and **Delivery Risk**, the platform generates an operational escalation index:

| Multi-Risk Quadrant | Inventory State | Delivery State | Priority Level | Automated System Trigger |
| :--- | :--- | :--- | :--- | :--- |
| **Red Zone (Code 1)** | Critical Stockout or Deficit | Severe Delay ($\ge 8$ days) | **P1 - Emergency Escalation** | Executive dashboard alert; Operations VP notified |
| **Orange Zone (Code 2)**| Deficit Shortfall | Minor Delay (6–7 days) | **P2 - High Priority** | Expedited cross-docking dispatch |
| **Yellow Zone (Code 3)**| Understock Warning | On-Time | **P3 - Warning** | Automated procurement purchase order release |
| **Blue Zone (Code 4)** | Overstock Warning | Any | **P4 - Capital Review** | Clearance promotion trigger |
| **Green Zone (Code 5)** | Healthy Operating Buffer | On-Time | **P5 - Normal Operation** | Routine processing |
