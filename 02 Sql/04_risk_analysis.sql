-- ============================================================
-- 04_risk_analysis.sql
-- BFSI Risk & Data Quality Engine
-- ============================================================


-- ============================================================
-- R-01: Missed Payments
-- Business rule:
-- Identify payment records where the customer missed a payment.
-- ============================================================

SELECT
    loan_id,
    payment_id,
    payment_period,
    payment_status
FROM payment_logs
WHERE payment_status = 'Missed';


-- ============================================================
-- R-02: Consecutive Missed Payments
-- Business rule:
-- Identify loans with missed payments in two consecutive
-- monthly payment periods.
-- ============================================================

WITH payment_history AS (
    SELECT
        loan_id,
        payment_period,
        payment_status,

        LAG(payment_status) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS previous_status,

        LAG(payment_period) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS previous_period

    FROM payment_logs
)
SELECT
    loan_id,
    payment_period,
    payment_status,
    previous_status
FROM payment_history
WHERE previous_status = 'Missed'
  AND payment_status = 'Missed'
  AND previous_period = payment_period - INTERVAL '1 month';


-- ============================================================
-- R-03: 90-Day Default
-- Business rule:
-- Identify three consecutive monthly missed payments.
-- ============================================================

WITH payment_history AS (
    SELECT
        loan_id,
        payment_period,
        payment_status,

        LAG(payment_status, 1) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS previous_status,

        LAG(payment_status, 2) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS two_period_back_status,

        LAG(payment_period, 1) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS previous_period,

        LAG(payment_period, 2) OVER (
            PARTITION BY loan_id
            ORDER BY payment_period
        ) AS two_period_back_period

    FROM payment_logs
)
SELECT
    loan_id,
    payment_period,
    payment_status
FROM payment_history
WHERE payment_status = 'Missed'
  AND previous_status = 'Missed'
  AND two_period_back_status = 'Missed'
  AND previous_period = payment_period - INTERVAL '1 month'
  AND two_period_back_period = payment_period - INTERVAL '2 months';


-- ============================================================
-- R-04: Payment Behavior
-- Business rule:
-- Calculate payment behavior metrics for each loan.
-- ============================================================

SELECT
    loan_id,

    COUNT(*) AS total_payment_records,

    SUM(
        CASE
            WHEN payment_status = 'Paid' THEN 1
            ELSE 0
        END
    ) AS paid_count,

    SUM(
        CASE
            WHEN payment_status = 'Missed' THEN 1
            ELSE 0
        END
    ) AS missed_count,

    SUM(
        CASE
            WHEN payment_status = 'Partial' THEN 1
            ELSE 0
        END
    ) AS partial_count,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN payment_status = 'Missed' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS missed_payment_rate,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN payment_status = 'Partial' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS partial_payment_rate

FROM payment_logs
GROUP BY loan_id;


-- ============================================================
-- R-05: Risk Classification
-- Business rule:
-- Critical → 90-day default
-- High     → consecutive missed payments
-- Moderate → at least one missed payment
-- Normal   → no missed payments
-- ============================================================

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

FROM risk_signals
ORDER BY loan_id;