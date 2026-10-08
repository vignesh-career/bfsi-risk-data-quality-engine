# Business Requirements

## 1. Customer Data

The project should contain customer-level information such as:

- Customer ID
- Customer name
- Date of birth
- City
- Customer since date

## 2. Loan Data

The project should contain loan-level information such as:

- Loan ID
- Customer ID
- Loan type
- Loan amount
- Interest rate
- Loan start date
- Account status

## 3. Payment Data

The payment table should contain:

- Payment ID
- Loan ID
- Payment date
- Payment period
- Payment amount
- Payment status
- Account status

## 4. Data Quality Checks

The Data Quality Engine should identify:

- Negative payment amounts
- Duplicate loan-period records
- Missing required values
- Invalid payment statuses
- Invalid account statuses
- Closed-to-Active account-status reversions

## 5. Risk Analysis

The Risk Engine should identify:

- Missed payments
- Consecutive missed payments
- 90-day default
- Payment behavior metrics
- Risk classification

Risk classification should follow this priority:

| Condition | Classification |
|---|---|
| 90-day default | Critical |
| Consecutive missed payments | High |
| One or more missed payments | Moderate |
| No missed payments | Normal |

## 6. Final Output

The final analytical dataset should contain **one row per loan**.

It should combine:

- Customer details
- Loan details
- Missed-payment metrics
- Risk classification
- Data-quality issue count
- Data-quality issue indicator

## 7. Data Integrity

Primary keys and foreign keys should be used for basic structural integrity.

Business-level data-quality rules should be handled separately by the Data Quality Engine.

The `loan_id + payment_period` combination represents the expected business-level uniqueness of payment records. A database `UNIQUE` constraint is intentionally not added because duplicate records are required for testing the Data Quality Engine.