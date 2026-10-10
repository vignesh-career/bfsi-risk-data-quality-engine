# BFSI Risk & Data Quality Engine

A PostgreSQL and Power BI portfolio project for validating loan payment data, identifying repayment risk, and analyzing data-quality issues at loan level.

## Project Overview

Loan and mortgage payment data can contain data-quality issues that affect reporting and analysis. Payment history can also contain patterns that indicate potential repayment risk.

This project addresses both areas through two SQL-based components:

- **Data Quality Engine** — identifies problems in payment data.
- **Risk Engine** — analyzes payment behavior and assigns a loan-level risk classification.

PostgreSQL performs the data-quality checks and risk calculations. Power BI provides interactive reporting and visual analysis using the validated SQL outputs.

The final analytical output maintains **one row per loan**, combining loan details, risk indicators, and data-quality information.

## Project Architecture

The project follows this workflow:

1. Generate controlled customer, loan, and payment datasets in PostgreSQL.
2. Evaluate payment data using the Data Quality Engine.
3. Analyze repayment behavior using the Risk Engine.
4. Create reusable SQL views for data-quality issues and loan-level risk.
5. Validate the business results and loan-level output.
6. Connect Power BI to the validated PostgreSQL tables and views.
7. Visualize portfolio risk and data-quality patterns through a two-page dashboard.

## Dataset

The project uses controlled mock data generated in PostgreSQL.

| Dataset | Records |
|---|---:|
| Customers | 1,000 |
| Loans | 1,500 |
| Baseline payment records | 36,000 |
| Payment periods | 24 months |
| Final payment records | 36,010 |

The payment history covers January 2024 through December 2025.

Controlled defects and risk scenarios were added after the baseline data was generated so that the SQL rules could be tested against known cases.

## Data Quality Engine

The Data Quality Engine checks for six types of issues.

| Rule | Description |
|---|---|
| DQ-01 | Negative payment amount |
| DQ-02 | Duplicate loan-period records |
| DQ-03 | Missing required values |
| DQ-04 | Invalid payment status |
| DQ-05 | Invalid account status |
| DQ-06 | Closed-to-Active account-status reversion |

The consolidated results are stored in the reusable SQL view:

`vw_data_quality_issues`

### Data Quality Validation

| Issue | Validated Issue Rows |
|---|---:|
| Negative payment | 10 |
| Duplicate payment records | 20 |
| Missing required values | 0 |
| Invalid payment status | 10 |
| Invalid account status | 10 |
| State reversion | 10 |
| **Total data-quality issue rows** | **60** |

The 20 duplicate-payment issue rows represent 10 duplicate groups, with both records in each group flagged.

A total of **10 distinct loans** are affected by data-quality issues.

## Risk Engine

The Risk Engine analyzes payment history using SQL window functions, conditional aggregation, and business rules.

The main risk signals include:

- Missed payments
- Consecutive missed payments
- 90-day default
- Payment behavior
- Risk classification

Risk classification follows this order:

| Condition | Classification |
|---|---|
| 90-day default | Critical |
| Consecutive missed payments | High |
| One or more missed payments | Moderate |
| No missed payments | Normal |

The reusable risk view is:

`vw_loan_risk`

### Risk Validation

| Classification | Loans |
|---|---:|
| Critical | 1 |
| High | 2 |
| Moderate | 3 |
| Normal | 1,494 |
| **Total** | **1,500** |

These counts reflect the final risk classification produced by the project's SQL rules.

## Final Business Output

The final analytical dataset maintains a grain of **one row per loan**.

It combines:

- Customer information
- Loan information
- Missed-payment metrics
- Risk classification
- Data-quality issue count
- Data-quality issue indicator

Final grain validation:

```text
Total rows: 1,500
Distinct loans: 1,500
```

This confirms that the final analytical output contains one record for each distinct loan.

## Power BI Dashboard

The Power BI dashboard connects to PostgreSQL and presents the validated SQL results through two report pages.

### Page 1 — BFSI Risk & Data Quality Overview

This page provides a high-level summary of the loan portfolio through five KPI cards:

| KPI | Validated Value |
|---|---:|
| Total Loans | 1,500 |
| Critical Risk Loans | 1 |
| High Risk Loans | 2 |
| Loans with Data Quality Issues | 10 |
| Total Data Quality Issues | 60 |

It also includes two charts:

- **Loans by Risk Classification** — shows the distribution of loans across Critical, High, Moderate, and Normal categories.
- **Data Quality Issues by Type** — compares the number of flagged issue rows for each data-quality rule.

### Page 2 — Risk & Data Quality Analysis

This page provides a more detailed view of the loan portfolio through:

- A risk-classification slicer for filtering the analysis.
- A loan-level detail table showing risk classification and data-quality status.
- A stacked column chart comparing risk classification with data-quality status.

The detail table supports investigation of the affected loans and helps distinguish loans with data-quality issues from those without them.

### Power BI Data Model

The report imports the following PostgreSQL tables and views:

- `bank_customers`
- `loan_accounts`
- `vw_loan_risk`
- `vw_data_quality_issues`

The raw `payment_logs` table is not imported into Power BI. Data-quality and risk logic remain in PostgreSQL, while Power BI is used for reporting, filtering, and visual analysis.

### Dashboard Screenshots

Dashboard screenshots are stored in the `06 Screenshots` folder.

**Page 1 — Overview**

![BFSI Risk & Data Quality Overview](06%20Screenshots/powerbi_page1_overview.png)

**Page 2 — Risk & Data Quality Analysis**

![Risk & Data Quality Analysis](06%20Screenshots/powerbi_page2_risk_analysis.png)

## SQL Techniques Used

- PostgreSQL
- Common Table Expressions (CTEs)
- Window functions
- `LAG()`
- `ROW_NUMBER()`
- `CASE`
- Conditional aggregation
- `GROUP BY`
- `HAVING`
- `JOIN`
- `LEFT JOIN`
- `UNION ALL`
- Views
- `COALESCE()`
- Date and interval operations
- Primary and foreign keys

## Project Structure

```text
BFSI-Risk-Data-Quality-Engine/
│
├── 01 Project Documentation/
├── 02 Sql/
│   ├── 01_create_tables.sql
│   ├── 02_generate_data.sql
│   ├── 03_data_quality_checks.sql
│   ├── 04_risk_analysis.sql
│   └── 05_views.sql
│
├── 03 Data/
├── 04 Analysis/
├── 05 Power Bi/
│   └── BFSI Risk & Data Quality Dashboard.pbix
├── 06 Screenshots/
│   ├── powerbi_page1_overview.png
│   └── powerbi_page2_risk_analysis.png
├── 07 Project Notes/
├── .gitignore
└── README.md
```

## Tools

- PostgreSQL
- pgAdmin
- SQL
- Power BI Desktop
- Git
- GitHub

## Current Status

### Completed

- Database design
- Mock data generation
- Controlled defect generation
- Data Quality Engine
- Risk Engine
- Risk classification
- Reusable SQL views
- Loan-level analytical output
- Data-quality and risk validation
- Project documentation
- Power BI dashboard development
- Two-page report with KPI cards, charts, slicer, and detail table
- Dashboard screenshots
- GitHub repository setup

### Future Improvements

- Refine dashboard layout and visual consistency