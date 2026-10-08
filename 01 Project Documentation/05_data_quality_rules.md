# Data Quality Rules

The Data Quality Engine checks the payment data for business and structural issues.

Each detected issue is returned in a standard format containing:

- `loan_id`
- `payment_id`
- `payment_period`
- `issue_type`
- `issue_description`

## DQ-01: Negative Payment Amount

### Rule

A payment amount should not be negative.

```text
payment_amount < 0
```

### Expected result in test data

10 negative payment records.

## DQ-02: Duplicate Payment Records

### Rule

A loan should normally have only one payment record for a given payment period.

The business key used for this check is:

```text
loan_id + payment_period
```

If more than one record exists for the same combination, the records are flagged as duplicates.

### Expected result in test data

10 duplicate groups.

Because each duplicate group contains two records, the consolidated Data Quality view returns 20 issue records.

## DQ-03: Missing Required Values

### Rule

Required payment fields should not contain `NULL` values.

The check covers:

- `payment_id`
- `loan_id`
- `payment_date`
- `payment_period`
- `payment_amount`
- `payment_status`
- `account_status`

### Expected result in test data

0 issues.

The columns are also defined as `NOT NULL` in the table structure where appropriate.

## DQ-04: Invalid Payment Status

### Rule

`payment_status` must contain one of the approved values:

- `Paid`
- `Missed`
- `Partial`

Any other value is flagged.

### Expected result in test data

10 invalid payment-status records.

## DQ-05: Invalid Account Status

### Rule

`account_status` must contain one of:

- `Active`
- `Closed`

Any other value is flagged.

### Expected result in test data

10 invalid account-status records.

## DQ-06: Account Status Reversion

### Rule

A loan should not change from `Closed` back to `Active` in its payment history without a valid business explanation.

The check compares the current account status with the previous status using `LAG()`.

The following transition is flagged:

```text
Closed → Active
```

### Expected result in test data

10 state-reversion records.

## Validation Results

The consolidated `vw_data_quality_issues` view was validated against the controlled test data.

| Issue Type | Expected Issue Rows | Validated Result |
|---|---:|---:|
| Negative payment | 10 | 10 |
| Duplicate payment record | 20 | 20 |
| Missing required value | 0 | 0 |
| Invalid payment status | 10 | 10 |
| Invalid account status | 10 | 10 |
| State reversion | 10 | 10 |
| **Total** | **60** | **60** |

## Design Note

Database constraints and Data Quality rules serve different purposes.

Primary keys, foreign keys, and `NOT NULL` constraints provide basic structural integrity.

The Data Quality Engine checks business expectations that may not be suitable for database constraints, such as duplicate business records and unexpected status transitions.