-- ============================================================
-- 03_data_quality_checks.sql
-- BFSI Risk & Data Quality Engine
-- ============================================================


-- ============================================================
-- DQ-01: Negative Payment
-- Business rule:
-- Payment amounts should not be negative.
-- ============================================================

SELECT
    loan_id,
    payment_id,
    payment_period,
    'Negative payment' AS issue_type,
    'Payment amount is negative' AS issue_description
FROM payment_logs
WHERE payment_amount < 0;


-- ============================================================
-- DQ-02: Duplicate Payment Record
-- Business rule:
-- A loan should have no more than one payment record
-- for the same payment period.
-- ============================================================

WITH duplicate_periods AS (
    SELECT
        loan_id,
        payment_period,
        COUNT(*) AS total_records
    FROM payment_logs
    GROUP BY
        loan_id,
        payment_period
    HAVING COUNT(*) > 1
)
SELECT
    d.loan_id,
    p.payment_id,
    d.payment_period,
    'Duplicate payment record' AS issue_type,
    'Multiple payment records exist for the same loan and payment period'
        AS issue_description
FROM payment_logs p
JOIN duplicate_periods d
    ON p.loan_id = d.loan_id
    AND p.payment_period = d.payment_period;


-- ============================================================
-- DQ-03: Missing Required Values
-- Business rule:
-- Required payment fields should not contain NULL values.
-- ============================================================

SELECT
    loan_id,
    payment_id,
    payment_period,
    'Missing required value' AS issue_type,
    'One or more required fields contain NULL' AS issue_description
FROM payment_logs
WHERE payment_id IS NULL
   OR loan_id IS NULL
   OR payment_date IS NULL
   OR payment_period IS NULL
   OR payment_amount IS NULL
   OR payment_status IS NULL
   OR account_status IS NULL;


-- ============================================================
-- DQ-04: Invalid Payment Status
-- Approved values:
-- Paid, Missed, Partial
-- ============================================================

SELECT
    loan_id,
    payment_id,
    payment_period,
    'Invalid payment status' AS issue_type,
    'Payment status is outside the approved value domain'
        AS issue_description
FROM payment_logs
WHERE payment_status NOT IN (
    'Paid',
    'Missed',
    'Partial'
);


-- ============================================================
-- DQ-05: Invalid Account Status
-- Approved values:
-- Active, Closed
-- ============================================================

SELECT
    loan_id,
    payment_id,
    payment_period,
    'Invalid account status' AS issue_type,
    'Account status is outside the approved value domain'
        AS issue_description
FROM payment_logs
WHERE account_status NOT IN (
    'Active',
    'Closed'
);


-- ============================================================
-- DQ-06: State Reversion
-- Business rule:
-- Closed → Active is invalid.
-- ============================================================

WITH status_history AS (
    SELECT
        loan_id,
        payment_id,
        payment_period,
        account_status,
        LAG(account_status) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS previous_account_status
    FROM payment_logs
)
SELECT
    loan_id,
    payment_id,
    payment_period,
    'State reversion' AS issue_type,
    'Loan status changed from Closed to Active'
        AS issue_description
FROM status_history
WHERE previous_account_status = 'Closed'
  AND account_status = 'Active';