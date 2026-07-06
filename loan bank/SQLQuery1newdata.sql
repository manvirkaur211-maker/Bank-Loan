USE loanANLYTICS2;
GO
--1. CUSTOMERS TABLE
--Duplicate IDs
SELECT customer_id, COUNT(*) AS duplicate_count
FROM [Copy of customers]
GROUP BY customer_id
HAVING COUNT(*) > 1;
--Missing id
SELECT COUNT(*) AS missing_customer_id
FROM [Copy of customers]
WHERE customer_id IS NULL;
--ACCOUNTS TABLE
--duplicate account id
SELECT account_id, COUNT(*) AS duplicate_count
FROM accounts
GROUP BY account_id
HAVING COUNT(*) > 1;
--Missing account id
SELECT COUNT(*) AS missing_account_id
FROM accounts
WHERE account_id IS NULL;
--Check Account Types
SELECT account_type, COUNT(*)
FROM accounts
GROUP BY account_type
ORDER BY account_type;
UPDATE accounts
SET account_type = UPPER(account_type);
SELECT account_type, COUNT(*)
FROM accounts
GROUP BY account_type
ORDER BY account_type;
UPDATE accounts
SET account_type = UPPER(LTRIM(RTRIM(account_type)));
SELECT account_type, COUNT(*)
FROM accounts
GROUP BY account_type
ORDER BY account_type;
UPDATE accounts
SET account_type = 'CHECKING'
WHERE account_type = 'CHECKNG';
UPDATE accounts
SET account_type = 'SAVINGS'
WHERE account_type = 'SAVNGS';
SELECT account_type, COUNT(*)
FROM accounts
GROUP BY account_type
ORDER BY account_type;

-----Loans table:
SELECT loan_type, COUNT(*)
FROM [Copy of loans]
GROUP BY loan_type
ORDER BY loan_type;
SELECT loan_status, COUNT(*)
FROM [Copy of loans]
GROUP BY loan_status
ORDER BY loan_status;
UPDATE [Copy of loans]
SET loan_status = 'CHARGED OFF'
WHERE loan_status = 'CHARGE-OFF';
SELECT loan_status, COUNT(*)
FROM [Copy of loans]
GROUP BY loan_status
ORDER BY loan_status;
----Document

--Loan Status Cleaning

--Found inconsistent values:
--CHARGED OFF
--CHARGE-OFF
--Standardized all records to CHARGED OFF.

---Transaction
SELECT channel, COUNT(*)
FROM transactions
GROUP BY channel
ORDER BY channel;
--transaction type
SELECT transaction_type, COUNT(*)
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_type;
--Defaults
SELECT recovery_status, COUNT(*)
FROM defaults
GROUP BY recovery_status
ORDER BY recovery_status;
--RELATION SHIP
SELECT COUNT(*)
FROM [Copy of loans] l
LEFT JOIN accounts a
ON l.account_id = a.account_id
WHERE a.account_id IS NULL;
--Loans → Accounts: 1000 unmatched records
--Cause: account_id is missing (NULL) in the loans table.
SELECT COUNT(*)
FROM accounts a
LEFT JOIN [Copy of customers] c
ON a.customer_id = c.customer_id
WHERE c.customer_id IS NULL;
--26 accounts do not have a matching customer in the customers table.
SELECT COUNT(*)
FROM defaults d
LEFT JOIN [Copy of loans] l
ON d.loan_id = l.loan_id
WHERE l.loan_id IS NULL;
--3 default records have a loan_id that does not exist in the loans table
SELECT COUNT(*)
FROM transactions t
LEFT JOIN accounts a
ON t.account_id = a.account_id
WHERE a.account_id IS NULL;
--52 records unmatched transaction and accounts

-- 1. Row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM [Copy of customers]
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL SELECT 'loans', COUNT(*) FROM [Copy of loans]
UNION ALL SELECT 'defaults', COUNT(*) FROM defaults
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;

-- 2. Duplicate ID checks
SELECT loan_id, COUNT(*) AS duplicate_count
FROM [Copy of loans]
GROUP BY loan_id
HAVING COUNT(*) > 1;

SELECT customer_id, COUNT(*) AS duplicate_count
FROM [Copy of customers]
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT account_id, COUNT(*) AS duplicate_count
FROM accounts
GROUP BY account_id
HAVING COUNT(*) > 1;

SELECT default_id, COUNT(*) AS duplicate_count
FROM defaults
GROUP BY default_id
HAVING COUNT(*) > 1;

SELECT transaction_id, COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 3. Missing key IDs
SELECT COUNT(*) AS missing_loan_id FROM [Copy of loans] WHERE loan_id IS NULL;
SELECT COUNT(*) AS missing_customer_id FROM [Copy of customers] WHERE customer_id IS NULL;
SELECT COUNT(*) AS missing_account_id FROM accounts WHERE account_id IS NULL;
SELECT COUNT(*) AS missing_default_id FROM defaults WHERE default_id IS NULL;
SELECT COUNT(*) AS missing_transaction_id FROM transactions WHERE transaction_id IS NULL;

-- 4. Text standardization checks
SELECT loan_type, COUNT(*) FROM [Copy of loans] GROUP BY loan_type ORDER BY loan_type;
SELECT loan_status, COUNT(*) FROM [Copy of loans] GROUP BY loan_status ORDER BY loan_status;
SELECT channel, COUNT(*) FROM transactions GROUP BY channel ORDER BY channel;
SELECT transaction_type, COUNT(*) FROM transactions GROUP BY transaction_type ORDER BY transaction_type;
SELECT recovery_status, COUNT(*) FROM defaults GROUP BY recovery_status ORDER BY recovery_status;
--Standardize Values
UPDATE [Copy of loans]
SET loan_type = UPPER(loan_type);

UPDATE [Copy of loans]
SET loan_status = UPPER(loan_status);

UPDATE transactions
SET channel = UPPER(channel);

UPDATE transactions
SET transaction_type = UPPER(transaction_type);

UPDATE defaults
SET recovery_status = UPPER(recovery_status);
-- High missed payments
SELECT *
FROM [Copy of loans]
WHERE payments_missed >= 5;

-- Low credit score
SELECT *
FROM [Copy of loans]
WHERE credit_score_at_origination < 600;

-- High loan amount
SELECT *
FROM [Copy of loans]
ORDER BY loan_amount DESC;

-- Defaulted loans
SELECT *
FROM [Copy of loans]

ERE loan_status LIKE '%DEFAULT%';
-------------------
--------------------------
--------------------------------------------------------------------------------------------------------------------
--Query 1 – Portfolio Snapshot by Loan Status
SELECT
    loan_status,
    COUNT(*) AS loan_count,
    SUM(CAST(REPLACE(loan_amount, ',', '') AS DECIMAL(18,2))) AS total_loan_amount
FROM [Copy of loans]
GROUP BY loan_status
ORDER BY loan_count DESC;
--Query 2 – Default Rate by Loan Type
SELECT
    loan_type,
    COUNT(*) AS total_loans,
    SUM(CASE
            WHEN loan_status IN ('DEFAULT','CHARGED OFF')
            THEN 1
            ELSE 0
        END) AS defaulted_loans,
    ROUND(
        100.0 * SUM(CASE
                        WHEN loan_status IN ('DEFAULT','CHARGED OFF')
                        THEN 1
                        ELSE 0
                    END)
        / COUNT(*), 2
    ) AS default_rate_pct
FROM [Copy of loans]
GROUP BY loan_type
ORDER BY default_rate_pct DESC;
---Query 3 – Recovery Performance
SELECT
    recovery_status,
    COUNT(*) AS loan_count
FROM defaults
GROUP BY recovery_status
ORDER BY loan_count DESC;
--Query 4 – Payment Behavior Segmentation (Missed Payments)
SELECT
    CASE
        WHEN payments_missed = 0 THEN 'No Missed Payments'
        WHEN payments_missed BETWEEN 1 AND 3 THEN 'Low Risk (1-3)'
        WHEN payments_missed BETWEEN 4 AND 6 THEN 'Medium Risk (4-6)'
        ELSE 'High Risk (7+)'
    END AS risk_segment,
    COUNT(*) AS loan_count
FROM [Copy of loans]
GROUP BY
    CASE
        WHEN payments_missed = 0 THEN 'No Missed Payments'
        WHEN payments_missed BETWEEN 1 AND 3 THEN 'Low Risk (1-3)'
        WHEN payments_missed BETWEEN 4 AND 6 THEN 'Medium Risk (4-6)'
        ELSE 'High Risk (7+)'
    END
ORDER BY loan_count DESC;
--Query 5 – Payment Channel Mix.
SELECT
    channel,
    COUNT(*) AS transaction_count
FROM transactions
WHERE transaction_type = 'LOAN PAYMENT'
GROUP BY channel
ORDER BY transaction_count DESC;
--query6– Loan lifecycle join:
SELECT
    l.loan_id,
    l.loan_type,
    l.loan_status,
    l.loan_amount,
    l.payments_missed,
    d.recovery_status,
    COUNT(t.transaction_id) AS payment_transactions
FROM [Copy of loans] l
LEFT JOIN defaults d
    ON l.loan_id = d.loan_id
LEFT JOIN transactions t
    ON l.account_id = t.account_id
    AND t.transaction_type = 'LOAN PAYMENT'
GROUP BY
    l.loan_id,
    l.loan_type,
    l.loan_status,
    l.loan_amount,
    l.payments_missed,
    d.recovery_status
ORDER BY l.loan_id;
