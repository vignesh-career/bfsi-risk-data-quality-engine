# BFSI Risk & Data Quality Engine

A PostgreSQL-based project for checking loan payment data quality and identifying payment-related risk at loan level.

## Project Overview

Loan and mortgage payment data can contain data-quality issues that affect reporting and analysis. Payment history can also contain patterns that indicate potential repayment risk.

This project addresses both areas through two SQL-based components:

- **Data Quality Engine** — identifies problems in payment data.
- **Risk Engine** — analyzes payment behavior and assigns a loan-level risk classification.

The final output combines customer details, loan details, risk indicators, and data-quality information at **one row per loan**.

## Project Architecture

The project follows this flow:

Customer and loan data are combined with payment history. The payment data is evaluated by the Data Quality Engine and Risk Engine. The resulting risk and data-quality information is combined into a loan-level dataset that can be used for Power BI reporting.


## Dataset

The project uses controlled mock data generated in PostgreSQL.

| Dataset | Records |
|---------|---------|
| Customers | 1,000 |
| Loans | 1,500 |
| Baseline payment records | 36,000 |
| Payment periods | 24 months |
| Final payment records | 36,010 |

The payment history covers January 2024 through December 2025.

Controlled defects and risk scenarios were added after the baseline data was generated so that the SQL rules could be tested against known cases.

## Data Quality Engine

The Data Quality Engine checks for six types of issues:

| Rule | Description |
|---|---|
| DQ-01 | Negative payment amount |
| DQ-02 | Duplicate loan-period records |
| DQ-03 | Missing required values |
| DQ-04 | Invalid payment status |
| DQ-05 | Invalid account status |
| DQ-06 | Closed-to-Active account-status reversion |

The consolidated results are stored in:

`vw_data_quality_issues`

### DQ Validation

| Issue | Validated Records |
|---|---:|
| Negative payment | 10 |
| Duplicate payment records | 20 |
| Missing required values | 0 |
| Invalid payment status | 10 |
| Invalid account status | 10 |
| State reversion | 10 |
| **Total** | **60** |

## Risk Engine

The Risk Engine analyzes payment history using SQL window functions and conditional aggregation.

The main risk signals are:

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

This confirms that the final joins do not introduce duplicate loan records.

## SQL Techniques Used

- PostgreSQL
- CTEs
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
│   ├── 01_business_problem.md
│   ├── 02_business_requirements.md
│   ├── 03_data_model.md
│   ├── 04_data_dictionary.md
│   ├── 05_data_quality_rules.md
│   ├── 06_risk_rules.md
│   └── 07_project_flow.md
│
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
├── 06 Screenshots/
├── 07 Project Notes/
├── .gitignore
└── README.md
```

## Tools

- PostgreSQL
- pgAdmin
- SQL
- Git
- GitHub
- Power BI

## Current Status

### Completed

- Database design
- Mock data generation
- Controlled defect generation
- Data Quality Engine
- Risk Engine
- Risk classification
- Reusable SQL views
- Loan-level business output
- Validation
- Project documentation
- GitHub repository setup

### Next

Power BI dashboard development using the validated SQL output.