-- Create a table to store the original dataset.
CREATE TABLE credit_card_clients_raw (
	client_id INT PRIMARY KEY, -- Customer ID
	credit_limit INT, -- Assigned credit limit
	sex_code SMALLINT, -- Encoded sex
	education_code SMALLINT, -- Encoded education level
	marital_status_code SMALLINT, -- Encoded marital status
	age SMALLINT, -- Customer age
	repayment_status_sep SMALLINT, -- Repayment status - September
	repayment_status_aug SMALLINT, -- August
	repayment_status_jul SMALLINT, -- July
	repayment_status_jun SMALLINT, -- June
	repayment_status_may SMALLINT, -- May
	repayment_status_apr SMALLINT, -- April
	bill_amount_sep INT, -- Bill statement amount - September
	bill_amount_aug INT, -- August
	bill_amount_jul INT, -- July
	bill_amount_jun INT, -- June
	bill_amount_may INT, -- May
	bill_amount_apr INT, -- April
	payment_amount_sep INT, -- Payment amount - September
	payment_amount_aug INT, -- August
	payment_amount_jul INT, -- July
	payment_amount_jun INT, -- June
	payment_amount_may INT, -- May
	payment_amount_apr INT, -- April
	default_next_month SMALLINT -- Default indicator for the following month (0 = No, 1 = Yes)
);


-- Create a table to store customer information.
CREATE TABLE clients (
	client_id INT PRIMARY KEY,
	credit_limit INT,
	sex VARCHAR(10),
	education VARCHAR(30),
	marital_status VARCHAR(15),
	age SMALLINT,
	default_next_month SMALLINT
);


-- Create a table to store monthly credit history.
CREATE TABLE monthly_credit_history (
	client_id INT REFERENCES clients(client_id),
	month_number SMALLINT,
	month VARCHAR(10),
	repayment_status SMALLINT,
	bill_amount INT,
	payment_amount INT,
	PRIMARY KEY (client_id, month_number)
);