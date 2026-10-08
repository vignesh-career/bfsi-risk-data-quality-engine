# Business Problem

Loan and mortgage payment data is used for reporting and risk analysis. Before using this data, two things need to be checked:

1. Is the data reliable?
2. Does the payment history indicate any risk?

Payment data can contain issues such as duplicate records, negative payment amounts, invalid status values, and inconsistent account-status changes. These issues can affect downstream reporting and analysis.

Payment behavior can also indicate risk. Missed payments, consecutive missed payments, and longer periods of missed payments can be used as risk indicators.

## Project Objective

This project builds a SQL-based BFSI Risk & Data Quality Engine using PostgreSQL.

The project has two parts:

### Data Quality Engine

Identifies problems in payment data:

- Negative payment amounts
- Duplicate payment records
- Missing required values
- Invalid payment statuses
- Invalid account statuses
- Closed-to-Active status reversions

### Risk Engine

Analyzes payment history to identify:

- Missed payments
- Consecutive missed payments
- 90-day default
- Payment behavior
- Loan-level risk classification

The final output combines customer information, loan information, risk indicators, and data-quality status at one-row-per-loan level.

The output is intended to provide a SQL dataset that can later be used for analysis and Power BI reporting.