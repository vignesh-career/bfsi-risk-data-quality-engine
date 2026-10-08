# Project Flow

## 1. Create Database Tables

The project starts by creating three PostgreSQL tables:

- `bank_customers`
- `loan_accounts`
- `payment_logs`

Primary keys, foreign keys, data types, and required-field constraints are defined at this stage.

SQL file:

`02 Sql/01_create_tables.sql`

## 2. Generate Baseline Data

Mock data is generated for:

- 1,000 customers
- 1,500 loans
- 36,000 payment records

The payment history covers 24 monthly periods from January 2024 through December 2025.

SQL file:

`02 Sql/02_generate_data.sql`

## 3. Add Controlled Test Defects

After the baseline data is created, controlled defects are introduced into the dataset.

Data-quality defects include:

- Negative payments
- Duplicate payment records
- Invalid payment statuses
- Invalid account statuses
- Closed-to-Active status reversions

Risk scenarios include:

- Missed payments
- Consecutive missed payments
- 90-day default

The controlled defects make it possible to validate whether the SQL rules detect the intended cases.

## 4. Run Data Quality Checks

Individual SQL checks are created for each Data Quality rule.

SQL file:

`02 Sql/03_data_quality_checks.sql`

The checks are later combined into the reusable:

`vw_data_quality_issues`

## 5. Run Risk Analysis

Payment history is analyzed using SQL window functions and conditional aggregation.

The Risk Engine identifies:

- Missed payments
- Consecutive missed payments
- 90-day default
- Payment behavior
- Risk classification

SQL file:

`02 Sql/04_risk_analysis.sql`

## 6. Create Reusable Views

Two main views are created:

### `vw_data_quality_issues`

Contains detected data-quality issues with standardized issue information.

### `vw_loan_risk`

Contains one risk record per loan.

SQL file:

`02 Sql/05_views.sql`

## 7. Combine Risk and Data Quality

The loan-level business output combines:

- Customer details
- Loan details
- Risk information
- Data-quality information

The final output is maintained at:

**One row per loan**

Data-quality issues are aggregated by `loan_id` before joining to the loan-level dataset so that duplicate DQ records do not change the final grain.

## 8. Validation

The final database was validated at multiple levels.

### Data Quality Validation

The consolidated DQ view returned the expected issue counts:

- 10 negative payments
- 20 duplicate payment records
- 10 invalid payment statuses
- 10 invalid account statuses
- 10 state reversions

Total:

**60 DQ issue records**

### Risk Validation

The risk view returned:

- 1 Critical
- 2 High
- 3 Moderate
- 1,494 Normal

Total:

**1,500 loans**

### Final Grain Validation

The final loan-level dataset returned:

- 1,500 total rows
- 1,500 distinct `loan_id` values

This confirms that the final output maintains the required one-row-per-loan grain.

## 9. Downstream Analysis

The final SQL dataset can be used as the source for further analysis and Power BI reporting.

Potential reporting areas include:

- Risk distribution
- Data-quality issue distribution
- Loan-level risk monitoring
- Customer and loan analysis
- Risk and data-quality overview