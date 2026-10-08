-- ============================================================
-- 05_views.sql
-- BFSI Risk & Data Quality Engine
-- ============================================================


-- ============================================================
-- View 1: Data Quality Issues
-- Combines all six DQ rules into one reusable dataset.
-- ============================================================

CREATE OR REPLACE VIEW vw_data_quality_issues AS

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
),

status_history AS (
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
    'Negative payment' AS issue_type,
    'Payment amount is negative' AS issue_description
FROM payment_logs
WHERE payment_amount < 0

UNION ALL

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
    AND p.payment_period = d.payment_period

UNION ALL

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
   OR account_status IS NULL

UNION ALL

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
)

UNION ALL

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
)

UNION ALL

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

  -- ============================================================
-- View 2: Loan Risk
-- Calculates loan-level risk classification.
-- ============================================================

CREATE OR REPLACE VIEW vw_loan_risk AS

WITH loan_tracking_status AS (
    SELECT
        loan_id,
        payment_period AS current_period,
        payment_status AS current_status,

        LAG(payment_period, 1) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS previous_payment_period,

        LAG(payment_status, 1) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS previous_payment_status,

        LAG(payment_period, 2) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS two_period_back_period,

        LAG(payment_status, 2) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS two_period_back_status

    FROM payment_logs
),

risk_signals AS (
    SELECT
        loan_id,

        SUM(
            CASE
                WHEN current_status = 'Missed' THEN 1
                ELSE 0
            END
        ) AS missed_payment_count,

        MAX(
            CASE
                WHEN current_status = 'Missed'
                 AND previous_payment_status = 'Missed'
                 AND previous_payment_period =
                     current_period - INTERVAL '1 month'
                THEN 1
                ELSE 0
            END
        ) AS consecutive_missed_flag,

        MAX(
            CASE
                WHEN current_status = 'Missed'
                 AND previous_payment_status = 'Missed'
                 AND two_period_back_status = 'Missed'
                 AND previous_payment_period =
                     current_period - INTERVAL '1 month'
                 AND two_period_back_period =
                     current_period - INTERVAL '2 months'
                THEN 1
                ELSE 0
            END
        ) AS default_90_day_flag

    FROM loan_tracking_status
    GROUP BY loan_id
)

SELECT
    loan_id,
    missed_payment_count,
    consecutive_missed_flag,
    default_90_day_flag,

    CASE
        WHEN default_90_day_flag = 1 THEN 'Critical'
        WHEN consecutive_missed_flag = 1 THEN 'High'
        WHEN missed_payment_count > 0 THEN 'Moderate'
        ELSE 'Normal'
    END AS risk_classification

FROM risk_signals;