# 📦 CadetX-Heavy-Supplier-Warehouse-Analytics
12-week Agile data analytics project optimizing supply-chain operations, inventory health, and warehouse efficiency for heavy goods suppliers.

---

## 📌 Project Overview
Warehouses handling heavy goods face complex operational challenges: stock imbalances, overstocking, stockouts, inefficient space utilization, unreliable supplier lead times, and inaccurate demand forecasting. 

This repository serves as the central hub for our analytics team's end-to-end deliverables, tracking weekly Agile sprints, data pipelines, interactive dashboards, predictive models, and executive reporting.

---

## 👥 Analytics Team & Roles

| Role | Contributor | 
| :--- | :--- |
| **Data Analyst** | [@Ruth-Imoni](https://github.com/Ruth-Imoni) | 
| **Data Analyst** | [@MLGideon](https://github.com/MLGideon) | 
| **Data Scientist** | [@Kumari-arya05](https://github.com/Kumari-arya05) | 
---

## 📁 Dataset Download

The analyses across all 12 sprints utilize raw supply-chain operational datasets covering supplier performance, product inventory levels, and warehouse shipment metrics.

The operational supply-chain datasets are stored in the [`/HeavySuppliersWarehouseDatasets Original`](./HeavySuppliersWarehouseDatasets%20Original/) directory and include:

| File Name | Description |
| :--- | :--- |
| `branches.csv` | Warehouse location and regional branch details |
| `customers.csv` | Customer demographics and order profiles |
| `inventory_master.csv` | Current stock levels, SKU IDs, and reorder thresholds |
| `invoices.csv` | Billing and transaction history |
| `payments.csv` | Payment statuses and settlement logs |
| `products.csv` | Heavy goods product categories and weights |
| `purchase_orders_header.csv` | Supplier purchase order headers |
| `purchase_orders_lines.csv` | Detailed line items for purchase orders |
| `sales_orders_header.csv` | Customer sales order summaries |
| `sales_orders_lines.csv` | Detailed line items for customer orders |
| `stock_ledger.csv` | Warehouse inventory movement and tracking logs |
| `suppliers.csv` | Supplier lead times, ratings, and performance data |

---

## 🛠️ Tech Stack & Key Deliverables
* **Languages & Analytics:** SQL, Python (Pandas, NumPy, Scikit-Learn, Matplotlib/Seaborn)
* **Business Intelligence:** Power BI
* **Workflow & Collaboration:** Git, GitHub, Agile/Scrum (Weekly Sprints)
* **Core Outputs:**
  * Supply-Chain & Warehouse Optimization Dashboards
  * SQL Queries & Operational Metrics Reports
  * Demand Forecasting & Stockout Risk Models
  * Weekly Sprint Reports & Scrum Master Retrospectives

---
## 📅 Sprint Progress & Deliverables

| Sprint | Focus Area | Key Deliverables | Status | Scrum Master | 
| :---: | :--- | :--- | :---: | :---:|
| [**Week 01**](./week-01/) | Data Foundation & Exploration |[Week 1 Documentation](./week-01/README.md) | 🟢 Complete | Kumari Arya |
| [**Week 02**](./week-02/) | Slow-Movers Inventory  Analysis | [Week 2 Documentation](./week-02/README.md) | 🟢 Complete | Ruth Imoni |
| [**Week 03**](./week-03/) | Product Health | [Week 3 Documentation](./week-03/README.md) | 🟢 Complete  | Tobiloba Soyinka |
| [**Week 04**](./week-04/) | Supplier Reliability Analysis | [Week 4 Documentation](./week-04/README.md) | 🟢 Complete | Kumari Arya |
| **Week 05** | - | *Pending* | ⚪ Planned | - |
| **Week 06** | - | *Pending* | ⚪ Planned | - |
| **Week 07** | - | *Pending* | ⚪ Planned | - |
| **Week 08** | - | *Pending* | ⚪ Planned | - |
| **Week 09** | - | *Pending* | ⚪ Planned | - |
| **Week 10** | - | *Pending* | ⚪ Planned | - |
| **Week 11** | - | *Pending* | ⚪ Planned | - |
| **Week 12** | Final Portfolio Presentation | *Pending* | ⚪ Planned | - |

---
## 📂 Repository Structure
```text
CadetX-Heavy-Supplier-Warehouse-Analytics/
├── README.md                      <-- Main project overview & index
├── data/
│   └── raw-dataset.zip            <-- Compressed raw project dataset
├── docs/
│   └── sprint-notes/              <-- Weekly Scrum Master notes (Sprints 01-12)
├── week-01/                       <-- Sprint 01 SQL, dashboard, & README
├── week-02/                       <-- Sprint 02 deliverables
└── ...                            <-- Subsequent weekly sprint folders
