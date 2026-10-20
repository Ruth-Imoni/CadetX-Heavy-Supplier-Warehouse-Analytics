# Week 8: Invoice & Payment Analysis

## Project Overview

Measured how long customers take to pay, how much invoiced value remains unpaid, and which customers carry the most collection and bad debt risk. Of 18.06bn invoiced, 2.92bn (about 16%) is still outstanding. The main issue is cash timing and collection risk. Week 5 gross profit is recorded at the point of sale and does not reflect whether those invoices were paid.

**Status:** Completed  
**Stakeholder:** Finance / Accounts Receivable

---

## Team

| Name | Role | Task |
|------|------|------|
| Ruth | Scrum Master, SQL Data Analyst | Invoice, payment, and risk queries; data validation |
| Tobiloba | Dashboard Developer | Power BI invoice and payment dashboard |

---

## Business Questions

1. How long do customers take to pay on average?
2. How much invoiced value is still unpaid, and how old is it?
3. Which customer types hold the largest outstanding balances?
4. Which customers carry the highest bad debt risk?

---

## Datasets Used

- `invoices.csv` — Invoice metadata, customer IDs, branch IDs, dates, and amounts
- `payments.csv` — Payment records, dates, amounts, and methods
- `customers.csv` — Customer master profiles, types, and payment terms

---

## Tech Stack

- **Database:** PostgreSQL
- **Query Language:** SQL (CTEs, aggregations, CASE logic, date arithmetic)
- **Visualization:** Power BI
- **Version Control:** GitHub

---

## Key Deliverables

1. Payment timeliness by customer (Query 1)
2. Overdue invoice list with open and paid-late status (Query 2)
3. Customer bad debt risk assessment with outstanding amounts (Query 4)
4. Power BI Invoice & Payment Risk Dashboard
5. Data validation log for negative payment days

---

## Dashboard

![Invoice & Payment Risk Dashboard](./invoice_payment_dashboard.png)

* 📥 **Power BI File:** `invoice_payment_dashboard.pbix`

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Invoiced Amount | 18.06bn |
| Total Invoices | 18K |
| Paid Invoices | 16K |
| Unpaid Invoices | 2K |
| Outstanding Amount | 2.92bn |
| On-Time Payment % | 42.39% (recalculation to be confirmed, see Data Quality) |

---

## Dashboard Visuals

**Filters Available:**
* Invoice Date
* Customer ID

**Key Performance Cards:**
* Total Invoiced, Total Invoices, Paid, Unpaid, Outstanding, On-Time %

**Chart 1: Customer Type by Outstanding Balance** Horizontal bar chart showing outstanding balances spread across Corporate (0.67bn), Government (0.63bn), Fleet Owner (0.58bn), Dealer (0.57bn), and Retail (0.47bn).

**Chart 2: Ageing of Outstanding Amount** Donut chart splitting the 2.92bn outstanding balance into Over 30, Over 60, and Over 90 days.

**Chart 3: Payment Risk Summary** Table categorizing invoices into High Risk (429.67M), Medium Risk (349.21M), and Low Risk (2,144.94M).

**Chart 4: Count of Customers by Type** Bar chart displaying invoice counts by customer type (Government 1,549, Dealer 1,384, Corporate 1,375, Fleet Owner 1,318, Retail 1,247).

**Chart 5: Invoice Details Table** Detailed sortable view covering invoice ID, customer details, dates, elapsed days, and risk categories.

---

## Analysis & Results

### Executive Summary

Analysis across 18.06bn in invoiced orders reveals that 2.92bn (16%) remains unpaid. While 73% of outstanding value sits in the Low Risk category, 429.67M requires immediate collection action. Delays are systemic across all customer types rather than isolated to specific accounts.

### Key Findings

1. **Outstanding Receivables:** 16% of total invoiced value (2.92bn) remains unpaid across 2K open invoices.
2. **Systemic Delay:** Outstanding balances are evenly distributed across all customer types, ranging from 0.47bn to 0.67bn.
3. **Risk Distribution:** Most outstanding value is in Low Risk (73%), but High Risk accounts hold 429.67M.
4. **Account Concentration:** A single Fleet Owner account carries 17.03M outstanding out of 73.07M invoiced (23%).
5. **Aged Bad Debt Candidates:** Unpaid invoices dating back to 2019 exceed 2,200 days past due and require Finance review.

---

## Business Recommendations

1. Build a collection priority list starting with open invoices over 90 days.
2. Ask Finance to confirm write-off status for open invoices from 2019 to 2020.
3. Review credit limits and payment terms for High Risk accounts before extending new credit.
4. Measure payment against each customer's specific payment terms using due dates.
5. Fix payment-to-invoice matching and run negative payment checks before the next reporting cycle.

---

## Data Quality and Validation Log

### Issue: Negative payment days

* **Detection:** Initial diagnostics returned negative payment days (-666 to -1,967 days), indicating payments dated before invoices.
* **Scope:** 19 invoices affected (Net 30: 6, Advance: 5, Net 45: 4, Net 60: 3, Net 15: 1).
* **Resolution:** Excluded these 19 rows from DSO and on-time calculations. Rows remain in source data pending manual confirmation.

---

## Scrum Master Notes

**Sprint Goal:** Quantify unpaid invoices, payment timing, and bad debt risk to guide collections and cash planning.  
**Actual Output:** Three SQL queries, Power BI dashboard, and validation logs for payment anomalies.  
**Recommendation:** Confirm status of 2019-2020 open invoices with Finance and align risk category rules before final submission.  
**Confidence Level:** Moderate. Totals match dashboard outputs, but negative payment rows and partial payment allocations remain under review.

---

## SQL Queries

### Shared Base CTEs

```sql
WITH ref AS (
  SELECT GREATEST(MAX(i.invoice_date), MAX(p.payment_date)) AS ref_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
),
invoice_level AS (
  SELECT
    i.invoice_id,
    i.customer_id,
    i.invoice_date,
    i.grand_total AS invoice_amount,
    MAX(p.payment_date) AS paid_date
  FROM invoices AS i
  LEFT JOIN payments AS p ON i.invoice_id = p.invoice_id
  GROUP BY i.invoice_id, i.customer_id, i.invoice_date, i.grand_total
)
```

### Query 1: Payment Timeliness by Customer
```
SELECT
  c.customer_id,
  c.customer_type,
  COUNT(*) AS paid_invoices,
  ROUND(AVG(il.paid_date - il.invoice_date), 2) AS dso,
  COUNT(CASE WHEN il.paid_date - il.invoice_date <= 30 THEN 1 END) AS on_time_count,
  COUNT(CASE WHEN il.paid_date - il.invoice_date > 30 THEN 1 END) AS late_count,
  ROUND(
    COUNT(CASE WHEN il.paid_date - il.invoice_date <= 30 THEN 1 END)::numeric * 100 / COUNT(*),
    2
  ) AS on_time_percentage
FROM invoice_level AS il
JOIN customers AS c ON il.customer_id = c.customer_id
WHERE il.paid_date IS NOT NULL
  AND il.paid_date >= il.invoice_date
GROUP BY c.customer_id, c.customer_type
ORDER BY dso DESC;
```

### Query 2: Overdue Invoices
```
SELECT
  il.invoice_id,
  il.customer_id,
  c.customer_type,
  il.invoice_date,
  il.invoice_amount,
  il.paid_date,
  COALESCE(il.paid_date, ref.ref_date) - il.invoice_date AS days_elapsed,
  CASE
    WHEN COALESCE(il.paid_date, ref.ref_date) - il.invoice_date > 90 THEN 'Over 90 days'
    WHEN COALESCE(il.paid_date, ref.ref_date) - il.invoice_date > 60 THEN 'Over 60 days'
    WHEN COALESCE(il.paid_date, ref.ref_date) - il.invoice_date > 30 THEN 'Over 30 days'
  END AS overdue_status
FROM invoice_level AS il
CROSS JOIN ref
JOIN customers AS c ON il.customer_id = c.customer_id
WHERE COALESCE(il.paid_date, ref.ref_date) - il.invoice_date > 30
ORDER BY days_elapsed DESC;
```

### Query 4: Bad Debt Risk Assessment
```
, customer_risk AS (
  SELECT
    il.customer_id,
    COUNT(*) AS total_invoices,
    ROUND(AVG(CASE WHEN il.paid_date >= il.invoice_date THEN il.paid_date - il.invoice_date END), 2) AS avg_dso,
    COUNT(CASE WHEN il.paid_date IS NULL THEN 1 END) AS unpaid_invoices,
    COALESCE(SUM(CASE WHEN il.paid_date IS NULL THEN il.invoice_amount END), 0) AS outstanding_amount,
    SUM(il.invoice_amount) AS lifetime_invoice_value
  FROM invoice_level AS il
  GROUP BY il.customer_id
)
SELECT
  cr.customer_id,
  c.customer_type,
  cr.total_invoices,
  cr.avg_dso,
  cr.unpaid_invoices,
  cr.outstanding_amount,
  cr.lifetime_invoice_value,
  ROUND(cr.outstanding_amount * 100 / NULLIF(cr.lifetime_invoice_value, 0), 2) AS outstanding_pct,
  CASE
    WHEN cr.avg_dso IS NULL THEN 'No Paid History'
    WHEN cr.avg_dso > 60 THEN 'High Risk'
    WHEN cr.avg_dso > 45 THEN 'Medium Risk'
    ELSE 'Low Risk'
  END AS risk_category
FROM customer_risk AS cr
JOIN customers AS c ON cr.customer_id = c.customer_id
ORDER BY cr.outstanding_amount DESC;
```

---

## Output Files
