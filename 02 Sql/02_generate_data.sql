-- ============================================================
-- 02_generate_data.sql
-- BFSI Risk & Data Quality Engine
-- ============================================================


-- ============================================================
-- 1. Generate bank customers
-- ============================================================

INSERT INTO bank_customers (
    customer_id,
    customer_name,
    date_of_birth,
    city,
    customer_since
)
SELECT
    'C' || LPAD(gs::TEXT, 4, '0'),
    'Customer ' || gs,
    DATE '1970-01-01' + (RANDOM() * 15000)::INT,
    (ARRAY[
        'Chennai',
        'Bangalore',
        'Hyderabad',
        'Mumbai',
        'Delhi'
    ])[1 + FLOOR(RANDOM() * 5)::INT],
    DATE '2015-01-01' + (RANDOM() * 3000)::INT
FROM generate_series(1, 1000) AS gs;


-- ============================================================
-- 2. Generate loan accounts
-- ============================================================

INSERT INTO loan_accounts (
    loan_id,
    customer_id,
    loan_type,
    loan_amount,
    interest_rate,
    loan_start_date,
    account_status
)
SELECT
    'L' || LPAD(gs::TEXT, 5, '0'),
    'C' || LPAD(
        (1 + FLOOR(RANDOM() * 775))::INT::TEXT,
        4,
        '0'
    ),
    (ARRAY[
        'Home Loan',
        'Mortgage',
        'Property Loan'
    ])[1 + FLOOR(RANDOM() * 3)::INT],
    ROUND((500000 + RANDOM() * 4500000)::NUMERIC, 2),
    ROUND((6 + RANDOM() * 5)::NUMERIC, 2),
    DATE '2020-01-01' + (RANDOM() * 1800)::INT,
    'Active'
FROM generate_series(1, 1500) AS gs;


-- ============================================================
-- 3. Generate clean baseline payment records
--    1,500 loans × 24 months = 36,000 records
-- ============================================================

INSERT INTO payment_logs (
    payment_id,
    loan_id,
    payment_date,
    payment_period,
    payment_amount,
    payment_status,
    account_status
)
SELECT
    'P' || LPAD(
        ROW_NUMBER() OVER (
            ORDER BY l.loan_id, m.payment_period
        )::TEXT,
        6,
        '0'
    ),
    l.loan_id,
    m.payment_period + INTERVAL '10 days',
    m.payment_period,
    ROUND((10000 + RANDOM() * 40000)::NUMERIC, 2),
    'Paid',
    'Active'
FROM loan_accounts l
CROSS JOIN generate_series(
    DATE '2024-01-01',
    DATE '2025-12-01',
    INTERVAL '1 month'
) AS m(payment_period);


-- ============================================================
-- 4. Inject negative payment defects
--    DQ-01: Negative payment
-- ============================================================

UPDATE payment_logs
SET payment_amount = -5000
WHERE payment_id IN (
    SELECT payment_id
    FROM payment_logs
    ORDER BY payment_id
    LIMIT 10
);


-- ============================================================
-- 5. Inject invalid payment status defects
--    DQ-04: Invalid payment status
-- ============================================================

UPDATE payment_logs
SET payment_status = 'Pending'
WHERE payment_id IN (
    SELECT payment_id
    FROM payment_logs
    ORDER BY payment_id
    OFFSET 10
    LIMIT 10
);


-- ============================================================
-- 6. Inject invalid account status defects
--    DQ-05: Invalid account status
-- ============================================================

UPDATE payment_logs
SET account_status = 'Suspended'
WHERE payment_id IN (
    SELECT payment_id
    FROM payment_logs
    ORDER BY payment_id
    OFFSET 20
    LIMIT 10
);


-- ============================================================
-- 7. Inject duplicate payment records
--    DQ-02: Duplicate loan_id + payment_period
-- ============================================================

INSERT INTO payment_logs (
    payment_id,
    loan_id,
    payment_date,
    payment_period,
    payment_amount,
    payment_status,
    account_status
)
SELECT
    'D' || LPAD(
        ROW_NUMBER() OVER (
            ORDER BY payment_id
        )::TEXT,
        6,
        '0'
    ),
    loan_id,
    payment_date,
    payment_period,
    payment_amount,
    payment_status,
    account_status
FROM payment_logs
WHERE payment_id > 'P000030'
ORDER BY payment_id
LIMIT 10;


-- ============================================================
-- 8. Inject Closed → Active state reversions
--    DQ-06: State reversion
-- ============================================================

WITH target_loans AS (
    SELECT loan_id
    FROM loan_accounts
    ORDER BY loan_id
    LIMIT 10
)
UPDATE payment_logs p
SET account_status = CASE
    WHEN payment_period = DATE '2025-06-01' THEN 'Closed'
    WHEN payment_period = DATE '2025-07-01' THEN 'Active'
END
FROM target_loans t
WHERE p.loan_id = t.loan_id
  AND p.payment_period IN (
      DATE '2025-06-01',
      DATE '2025-07-01'
  );

  -- ============================================================
-- 9. Inject missed-payment events
--    R-01: Missed payments
-- ============================================================

UPDATE payment_logs
SET payment_status = 'Missed'
WHERE
    (loan_id = 'L00015' AND payment_period IN (
        DATE '2025-01-01',
        DATE '2025-02-01'
    ))
    OR
    (loan_id = 'L00016' AND payment_period IN (
        DATE '2025-03-01',
        DATE '2025-04-01'
    ))
    OR
    (loan_id = 'L00017' AND payment_period IN (
        DATE '2025-07-01',
        DATE '2025-08-01',
        DATE '2025-09-01'
    ))
    OR
    (loan_id = 'L00018' AND payment_period = DATE '2025-05-01')
    OR
    (loan_id = 'L00019' AND payment_period = DATE '2025-08-01')
    OR
    (loan_id = 'L00020' AND payment_period = DATE '2025-11-01');

---------------------------------------------------------------------------
-- Controlled risk defects were injected into selected monthly payment records
-- to test missed-payment, consecutive-missed-payment, 
-- and 90-day-default detection.
-----------------------------------------------------------------------------