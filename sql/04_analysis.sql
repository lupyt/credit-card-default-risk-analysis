-- 1. Overall default rate and credit limit statistics.
SELECT 
	COUNT(*) AS clients,
	SUM(default_next_month) AS defaulted,
	ROUND(AVG(default_next_month) * 100.0, 2) AS default_rate,
	ROUND(AVG(credit_limit), -3) AS avg_credit_limit,
	PERCENTILE_CONT(0.5) WITHIN GROUP (
		ORDER BY credit_limit
	) AS median_credit_limit
FROM clients;


-- 2. Default rate by demographic characteristics.
-- 2.1. Default rate by sex.
SELECT 
	sex,
	COUNT(*) AS clients,
	ROUND(AVG(default_next_month) * 100.0, 2) AS default_rate
FROM clients
GROUP BY sex;


-- 2.2. Default rate by age group.
SELECT 
	CASE
		WHEN age < 30 THEN 'under 30'
		WHEN age < 40 THEN '30-39'
		WHEN age < 50 THEN '40-49'
		WHEN age < 60 THEN '50-59'
		ELSE '60+'
	END AS age_category,
	COUNT(*) AS clients,
	ROUND(AVG(default_next_month) * 100.0, 2) AS default_rate
FROM clients
GROUP BY 
	CASE
		WHEN age < 30 THEN 'under 30'
		WHEN age < 40 THEN '30-39'
		WHEN age < 50 THEN '40-49'
		WHEN age < 60 THEN '50-59'
		ELSE '60+'
	END
ORDER BY MIN(age);


-- 2.3. Default rate by education level.
SELECT
	education,
	COUNT(*) AS clients,
	ROUND(AVG(default_next_month) * 100.0, 2) AS default_rate
FROM clients
GROUP BY education;


-- 2.4. Default rate by marital status.
SELECT
	marital_status,
	COUNT(*) AS clients,
	ROUND(AVG(default_next_month) * 100.0, 2) AS default_rate
FROM clients
GROUP BY marital_status;


-- 3. Default rate by credit limit group.
SELECT
	CASE
		WHEN credit_limit < 50000 THEN '<50k'
		WHEN credit_limit < 100000 THEN '50-100k'
		WHEN credit_limit < 200000 THEN '100-200k'
		WHEN credit_limit < 300000 THEN '200-300k'
		WHEN credit_limit < 500000 THEN '300-500k'
		ELSE '500k+'
	END AS credit_limit_group,
	COUNT(*) AS clients,
	ROUND(AVG(default_next_month) * 100.0, 2) AS default_rate
FROM clients
GROUP BY
	CASE
		WHEN credit_limit < 50000 THEN '<50k'
		WHEN credit_limit < 100000 THEN '50-100k'
		WHEN credit_limit < 200000 THEN '100-200k'
		WHEN credit_limit < 300000 THEN '200-300k'
		WHEN credit_limit < 500000 THEN '300-500k'
		ELSE '500k+'
	END
ORDER BY MIN(credit_limit);


-- 4. Default rate by average credit utilization across the six-month period.
WITH credit_utilization AS (
	SELECT
		c.client_id,
		c.credit_limit,
		AVG(GREATEST(mch.bill_amount, 0)) * 100.0 / NULLIF(c.credit_limit, 0) AS avg_credit_utilization,
		c.default_next_month
	FROM clients c
	JOIN monthly_credit_history mch
		ON c.client_id = mch.client_id
	GROUP BY
		c.client_id,
		c.credit_limit,
		c.default_next_month
)
SELECT
	CASE
		WHEN avg_credit_utilization < 25 THEN '<25%'
		WHEN avg_credit_utilization < 50 THEN '25-50%'
		WHEN avg_credit_utilization < 75 THEN '50-75%'
		WHEN avg_credit_utilization <= 100 THEN '75-100%'
		ELSE '>100%'
	END AS credit_utilization_group,
	COUNT(*) AS clients,
	ROUND(AVG(default_next_month) * 100.0, 2) AS default_rate
FROM credit_utilization
WHERE avg_credit_utilization IS NOT NULL
GROUP BY
	CASE
		WHEN avg_credit_utilization < 25 THEN '<25%'
		WHEN avg_credit_utilization < 50 THEN '25-50%'
		WHEN avg_credit_utilization < 75 THEN '50-75%'
		WHEN avg_credit_utilization <= 100 THEN '75-100%'
		ELSE '>100%'
	END
ORDER BY MIN(avg_credit_utilization);


-- 5. Default rate by each customer's highest monthly credit utilization during the six-month observation period.
-- Values above 100% indicate that the reported bill amount exceeded the customer's assigned credit limit.
WITH max_credit_utilization AS (
	SELECT
		c.client_id,
		MAX(	
			GREATEST(mch.bill_amount, 0) * 100.0 / NULLIF(c.credit_limit, 0)
		) AS max_credit_utilization,
		c.default_next_month
	FROM clients c
	JOIN monthly_credit_history mch
		ON c.client_id = mch.client_id
	GROUP BY
		c.client_id,
		c.default_next_month
)
SELECT
	CASE
		WHEN max_credit_utilization < 25 THEN '<25%'
		WHEN max_credit_utilization < 50 THEN '25-50%'
		WHEN max_credit_utilization < 75 THEN '50-75%'
		WHEN max_credit_utilization <= 100 THEN '75-100%'
		ELSE '>100%'
	END AS max_credit_utilization_group,
	COUNT(*) AS clients,
	ROUND(AVG(default_next_month) * 100.0, 2) AS default_rate
FROM max_credit_utilization
WHERE max_credit_utilization IS NOT NULL
GROUP BY
	CASE
		WHEN max_credit_utilization < 25 THEN '<25%'
		WHEN max_credit_utilization < 50 THEN '25-50%'
		WHEN max_credit_utilization < 75 THEN '50-75%'
		WHEN max_credit_utilization <= 100 THEN '75-100%'
		ELSE '>100%'
	END
ORDER BY MIN(max_credit_utilization);


-- 6. Default rate by delinquency frequency.
-- Count the number of months with recorded payment delays for each customer.
WITH delay_frequency AS (
	SELECT
		client_id,
		SUM(
			CASE
				WHEN repayment_status > 0 THEN 1
				ELSE 0
			END
		) AS delayed_months
	FROM monthly_credit_history
	GROUP BY client_id
)
SELECT
	CASE
		WHEN delayed_months = 0 THEN '0 months'
		WHEN delayed_months = 1 THEN '1 month'
		WHEN delayed_months = 2 THEN '2 months'
		WHEN delayed_months = 3 THEN '3 months'
		ELSE '4+ months'
	END AS delay_group,
	COUNT(*) AS clients,
	ROUND(AVG(c.default_next_month) * 100.0, 2) AS default_rate
FROM delay_frequency df
JOIN clients c
	ON df.client_id = c.client_id
GROUP BY
	CASE
		WHEN delayed_months = 0 THEN '0 months'
		WHEN delayed_months = 1 THEN '1 month'
		WHEN delayed_months = 2 THEN '2 months'
		WHEN delayed_months = 3 THEN '3 months'
		ELSE '4+ months'
	END
ORDER BY MIN(delayed_months);


-- 7. Default rate by the highest delay status recorded for each customer during the observation period.
WITH client_status AS (
	SELECT
		client_id,
		MAX(repayment_status) AS max_repayment_status
	FROM monthly_credit_history
	GROUP BY client_id
)
SELECT
	CASE
		WHEN max_repayment_status <= 0 THEN 'no delay'
		WHEN max_repayment_status = 1 THEN '1 month'
		WHEN max_repayment_status = 2 THEN '2 months'
		ELSE '3+ months'
	END AS delay_group,
	COUNT(*) AS clients,
	ROUND(AVG(default_next_month) * 100.0, 2) AS default_rate
FROM client_status cs
JOIN clients c
	ON cs.client_id = c.client_id
GROUP BY delay_group
ORDER BY MIN(max_repayment_status);


-- 8. Default rate by timing of payment delays.
-- 		Compare the number of delayed months across two periods:
-- 			-> Earlier period: April-June 2005
--			-> Recent period: July-September 2005
-- Examine whether the timing of payment delays provides additional information about default risk beyond delay frequency.
WITH delay_periods AS (
	SELECT
		client_id,
		SUM(
			CASE
				WHEN month_number BETWEEN 4 AND 6
					AND repayment_status > 0
				THEN 1
				ELSE 0
			END
		) AS earlier_delayed_months,
		SUM(
			CASE
				WHEN month_number BETWEEN 7 AND 9
					AND repayment_status > 0
				THEN 1
				ELSE 0
			END
		) AS recent_delayed_months
	FROM monthly_credit_history
	GROUP BY client_id
)
SELECT
	earlier_delayed_months,
	recent_delayed_months,
	earlier_delayed_months + recent_delayed_months AS total_delayed_months,
	COUNT(*) AS clients,
	ROUND(AVG(c.default_next_month) * 100.0, 2) AS default_rate
FROM delay_periods dp
JOIN clients c
	ON dp.client_id = c.client_id
GROUP BY
	earlier_delayed_months,
	recent_delayed_months
ORDER BY
	earlier_delayed_months,
	recent_delayed_months;