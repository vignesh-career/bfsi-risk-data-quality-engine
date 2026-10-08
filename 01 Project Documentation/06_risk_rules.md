# Risk Rules

The Risk Engine analyzes payment history at loan level.

The main risk signals are missed payments, consecutive missed payments, and 90-day default.

## R-01: Missed Payments

### Rule

A payment is treated as missed when:

```text
payment_status = 'Missed'
```

The Risk Engine counts the number of missed payment periods for each loan.

### Test Data

Six loans were given intentional missed-payment events.

| Loan | Missed Payment Count |
|---|---:|
| L00015 | 2 |
| L00016 | 2 |
| L00017 | 3 |
| L00018 | 1 |
| L00019 | 1 |
| L00020 | 1 |

Total missed-payment events: **10**.

## R-02: Consecutive Missed Payments

### Rule

A loan is flagged when two consecutive monthly payment periods have:

```text
payment_status = 'Missed'
```

The payment periods must also be consecutive months.

`LAG()` is used to compare the current payment record with the previous payment record.

### Test Data

Three loans contain consecutive missed payments:

- L00015
- L00016
- L00017

## R-03: 90-Day Default

### Rule

A loan is treated as reaching the 90-day default threshold when three consecutive monthly payment periods are marked as `Missed`.

The query checks both:

- Payment status
- Monthly continuity of the payment periods

`LAG()` with offsets of 1 and 2 is used to examine the previous two payment periods.

### Test Data

L00017 contains three consecutive missed periods:

```text
2025-07-01
2025-08-01
2025-09-01
```

This produces one 90-day default case.

## R-04: Payment Behavior

Payment behavior is summarized at loan level.

The metrics include:

- Total payment records
- Paid payment count
- Missed payment count
- Partial payment count
- Missed-payment rate
- Partial-payment rate

Conditional aggregation using `SUM(CASE...)` is used to calculate these metrics.

## R-05: Risk Classification

The final classification is based on the strongest risk signal present.

| Condition | Classification |
|---|---|
| 90-day default | Critical |
| Consecutive missed payments | High |
| One or more missed payments | Moderate |
| No missed payments | Normal |

The conditions are evaluated in this order so that a stronger risk signal takes priority.

For example, a loan with three consecutive missed payments satisfies both the missed-payment and consecutive-missed rules, but it is classified as `Critical` when it also meets the 90-day default condition.

## Risk View

The final risk logic is stored in:

`vw_loan_risk`

The view contains one row per loan with:

- `loan_id`
- `missed_payment_count`
- `consecutive_missed_flag`
- `default_90_day_flag`
- `risk_classification`

## Validation Results

The current test dataset produced:

| Risk Classification | Loan Count |
|---|---:|
| Critical | 1 |
| High | 2 |
| Moderate | 3 |
| Normal | 1,494 |
| **Total** | **1,500** |

The six loans with intentional missed-payment events were also checked individually:

| Loan | Missed | Consecutive | 90-Day Default | Classification |
|---|---:|---:|---:|---|
| L00015 | 2 | 1 | 0 | High |
| L00016 | 2 | 1 | 0 | High |
| L00017 | 3 | 1 | 1 | Critical |
| L00018 | 1 | 0 | 0 | Moderate |
| L00019 | 1 | 0 | 0 | Moderate |
| L00020 | 1 | 0 | 0 | Moderate |