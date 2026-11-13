-- Populate the clients table from the raw dataset, converting codes to readable labels.
INSERT INTO clients (
	client_id,
	credit_limit,
	sex,
	education,
	marital_status,
	age,
	default_next_month
)
SELECT
	client_id,
	credit_limit,
	CASE
		WHEN sex_code = 1 THEN 'male'
		WHEN sex_code = 2 THEN 'female'
	END AS sex,
	CASE
		WHEN education_code = 1 THEN 'graduate school'
		WHEN education_code = 2 THEN 'university'
		WHEN education_code = 3 THEN 'high school'
		ELSE 'others'
	END AS education,
	CASE
		WHEN marital_status_code = 1 THEN 'married'
		WHEN marital_status_code = 2 THEN 'single'
		ELSE 'other'
	END AS marital_status,
	age,
	default_next_month
FROM credit_card_clients_raw;


-- Populate the monthly_credit_history table by transforming monthly financial data from wide to long format,
-- creating one record per customer per month.
INSERT INTO monthly_credit_history (
	client_id,
	month_number,
	month,
	repayment_status,
	bill_amount,
	payment_amount
)
SELECT
	client_id,
	9,
	'Sep',
	repayment_status_sep,
	bill_amount_sep,
	payment_amount_sep
FROM credit_card_clients_raw

UNION ALL

SELECT
	client_id,
	8,
	'Aug',
	repayment_status_aug,
	bill_amount_aug,
	payment_amount_aug
FROM credit_card_clients_raw

UNION ALL

SELECT
	client_id,
	7,
	'Jul',
	repayment_status_jul,
	bill_amount_jul,
	payment_amount_jul
FROM credit_card_clients_raw

UNION ALL

SELECT
	client_id,
	6,
	'Jun',
	repayment_status_jun,
	bill_amount_jun,
	payment_amount_jun
FROM credit_card_clients_raw

UNION ALL

SELECT
	client_id,
	5,
	'May',
	repayment_status_may,
	bill_amount_may,
	payment_amount_may
FROM credit_card_clients_raw

UNION ALL

SELECT
	client_id,
	4,
	'Apr',
	repayment_status_apr,
	bill_amount_apr,
	payment_amount_apr
FROM credit_card_clients_raw;