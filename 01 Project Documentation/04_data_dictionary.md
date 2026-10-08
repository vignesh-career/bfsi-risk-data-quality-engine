# Data Dictionary

## bank_customers

| Column | Type | Description |
|---|---|---|
| `customer_id` | VARCHAR(20) | Unique identifier for the customer |
| `customer_name` | VARCHAR(100) | Customer name |
| `date_of_birth` | DATE | Customer date of birth |
| `city` | VARCHAR(50) | Customer city |
| `customer_since` | DATE | Date the customer relationship started |

## loan_accounts

| Column | Type | Description |
|---|---|---|
| `loan_id` | VARCHAR(20) | Unique identifier for the loan |
| `customer_id` | VARCHAR(20) | Links the loan to a customer |
| `loan_type` | VARCHAR(30) | Type of loan |
| `loan_amount` | NUMERIC(12,2) | Original loan amount |
| `interest_rate` | NUMERIC(5,2) | Interest rate associated with the loan |
| `loan_start_date` | DATE | Date the loan started |
| `account_status` | VARCHAR(20) | Current status of the loan account |

## payment_logs

| Column | Type | Description |
|---|---|---|
| `payment_id` | VARCHAR(20) | Unique identifier for the payment record |
| `loan_id` | VARCHAR(20) | Links the payment record to a loan |
| `payment_date` | DATE | Actual payment date |
| `payment_period` | DATE | Monthly reporting/payment period |
| `payment_amount` | NUMERIC(12,2) | Payment amount recorded |
| `payment_status` | VARCHAR(20) | Status of the payment |
| `account_status` | VARCHAR(20) | Account status recorded for the payment period |

## Payment Status Values

The expected payment-status values are:

| Value | Meaning |
|---|---|
| `Paid` | Payment was made |
| `Missed` | Expected payment was not made |
| `Partial` | Payment was only partially made |

Any other value is treated as an invalid payment status by the Data Quality Engine.

## Account Status Values

The expected account-status values are:

| Value | Meaning |
|---|---|
| `Active` | Loan account is active |
| `Closed` | Loan account is closed |

Any other value is treated as an invalid account status by the Data Quality Engine.

## Payment Period

`payment_period` represents the reporting month and is stored as the first day of the month.

For example:

```text
2025-01-01
2025-02-01
2025-03-01
```

This field is used for monthly payment-history analysis and for detecting consecutive missed payments.