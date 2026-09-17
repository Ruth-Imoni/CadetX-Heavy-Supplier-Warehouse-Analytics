# 🔍 Week 01: Data Foundation & Exploration

**Status:** Completed

Week 01 focused on establishing the data foundation for the project through initial inspection, data profiling, and quality validation across all datasets.

---

## 🛠️ Work Completed
* Explored and profiled all 12 CSV datasets.
* Reviewed dataset rows, columns, and data types.
* Checked missing values across datasets.
* Checked duplicate records.
* Standardized date-related fields.
* Performed data-quality validation.
* Analyzed missing values in `purchase_orders_header.csv`.
* Published the completed work to GitHub.


## 📁 Project Datasets

The operational supply-chain datasets include:

| File Name | 
| :--- | 
| `branches.csv` | 
| `customers.csv` | 
| `inventory_master.csv` | 
| `invoices.csv` | 
| `payments.csv` | 
| `products.csv` | 
| `purchase_orders_header.csv` | 
| `purchase_orders_lines.csv` | 
| `sales_orders_header.csv` |
| `sales_orders_lines.csv` | 
| `stock_ledger.csv` | 
| `suppliers.csv` | 

---

## 📌 Key Findings
Analysis of `purchase_orders_header.csv` revealed:
* **24,000** total rows
* **2,370** missing `received_date` values
* **0** duplicate rows

*Note: Missing `received_date` values were retained as blank because they represent purchase orders that have not yet been received. Artificial dates were intentionally omitted to preserve source data integrity.*
