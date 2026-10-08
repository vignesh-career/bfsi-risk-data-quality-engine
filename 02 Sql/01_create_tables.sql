CREATE TABLE bank_customers (
    customer_id     VARCHAR(20) PRIMARY KEY,
    customer_name   VARCHAR(100) NOT NULL,
    date_of_birth   DATE,
    city            VARCHAR(50),
    customer_since  DATE
);


CREATE TABLE loan_accounts (
    loan_id          VARCHAR(20) PRIMARY KEY,
    customer_id      VARCHAR(20) NOT NULL,
    loan_type        VARCHAR(30) NOT NULL,
    loan_amount      NUMERIC(12,2) NOT NULL,
    interest_rate    NUMERIC(5,2) NOT NULL,
    loan_start_date  DATE NOT NULL,
    account_status   VARCHAR(20) NOT NULL,

    FOREIGN KEY (customer_id)
        REFERENCES bank_customers(customer_id)
);


CREATE TABLE payment_logs (
    payment_id       VARCHAR(20) PRIMARY KEY,
    loan_id          VARCHAR(20) NOT NULL,
    payment_date     DATE NOT NULL,
    payment_period   DATE NOT NULL,
    payment_amount   NUMERIC(12,2) NOT NULL,
    payment_status   VARCHAR(20) NOT NULL,
    account_status   VARCHAR(20) NOT NULL,

    FOREIGN KEY (loan_id)
        REFERENCES loan_accounts(loan_id)
);