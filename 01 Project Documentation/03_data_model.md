# Data Model

## 1. Overview

The project uses three main tables:

- `bank_customers`
- `loan_accounts`
- `payment_logs`

Customer information is stored separately from loan information, and payment records are linked to individual loans.

## 2. Relationships

`bank_customers` contains customer-level information.

`loan_accounts` contains loan-level information. Each loan belongs to a customer through `customer_id`. A customer can have multiple loans.

`payment_logs` contains payment-level information. Each payment record belongs to a loan through `loan_id`. A loan can have multiple payment records across reporting periods.

| Parent Table | Child Table | Join Column | Relationship |
|---|---|---|---|
| `bank_customers` | `loan_accounts` | `customer_id` | One-to-many |
| `loan_accounts` | `payment_logs` | `loan_id` | One-to-many |

## 3. Table Grain

| Table | Grain |
|---|---|
| `bank_customers` | One row per customer |
| `loan_accounts` | One row per loan |
| `payment_logs` | One row per loan and payment period under normal conditions |

`payment_id` is the technical unique identifier for payment records.

The business-level uniqueness expected for payment data is:

`loan_id + payment_period`

## 4. bank_customers

| Column | Data Type | Constraint | Description |
|---|---|---|---|
| `customer_id` | VARCHAR(20) | Primary Key | Unique customer identifier |
| `customer_name` | VARCHAR(100) | NOT NULL | Customer name |
| `date_of_birth` | DATE | — | Customer date of birth |
| `city` | VARCHAR(50) | — | Customer city |
| `customer_since` | DATE | — | Date customer relationship began |

## 5. loan_accounts

| Column | Data Type | Constraint | Description |
|---|---|---|---|
| `loan_id` | VARCHAR(20) | Primary Key | Unique loan identifier |
| `customer_id` | VARCHAR(20) | Foreign Key | Customer associated with the loan |
| `loan_type` | VARCHAR(30) | NOT NULL | Type of loan |
| `loan_amount` | NUMERIC(12,2) | NOT NULL | Loan amount |
| `interest_rate` | NUMERIC(5,2) | NOT NULL | Loan interest rate |
| `loan_start_date` | DATE | NOT NULL | Loan start date |
| `account_status` | VARCHAR(20) | NOT NULL | Current account status |

## 6. payment_logs

| Column | Data Type | Constraint | Description |
|---|---|---|---|
| `payment_id` | VARCHAR(20) | Primary Key | Unique payment record |
| `loan_id` | VARCHAR(20) | Foreign Key | Loan associated with the payment |
| `payment_date` | DATE | NOT NULL | Actual payment date |
| `payment_period` | DATE | NOT NULL | Reporting/payment period |
| `payment_amount` | NUMERIC(12,2) | NOT NULL | Payment amount |
| `payment_status` | VARCHAR(20) | NOT NULL | Payment status |
| `account_status` | VARCHAR(20) | NOT NULL | Account status recorded for the period |

## 7. Design Decisions

### Payment uniqueness

`payment_id` is used as the technical primary key.

The business expectation is that a loan should normally have one payment record for each `payment_period`.

A `UNIQUE` constraint is not applied to `loan_id + payment_period` because the project intentionally creates duplicate records to test the Data Quality Engine.

### Account status in payment_logs

`account_status` is stored in `payment_logs` even though `loan_accounts` also contains account status.

This allows the project to analyze status changes over time and detect a Closed-to-Active reversion.

### Financial data types

`NUMERIC` is used for `loan_amount`, `interest_rate`, and `payment_amount` to avoid unnecessary floating-point precision issues.

## 8. Mock Data

The baseline dataset contains:

- 1,000 customers
- 1,500 loans
- 36,000 payment records
- 24 monthly payment periods
- January 2024 through December 2025

Controlled data-quality and risk defects are added after the baseline data is generated.