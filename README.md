# Credit Card Default Risk Analysis

**SQL | PostgreSQL | Excel | Power Query**

This project analyzes credit card customer data to identify factors associated with payment default risk. The goal is to understand how credit exposure, repayment behaviour, and customer characteristics relate to the likelihood of default in the following month.

The dataset contains information on 30,000 credit card clients in Taiwan, covering a six-month period from April to September 2005.

The analysis focuses on three key areas:
1. **Credit Exposure:** Credit limits and maximum credit utilization.
2. **Repayment Behaviour:** Frequency and timing of payment delays.
3. **Customer Profile:** Demographic characteristics and their relationship with default risk.

## Dashboard

**The primary metric used throughout the analysis was the default rate, defined as the percentage of customers who defaulted in the following month.**

The Excel dashboard presents the main results across three analytical areas: Credit Exposure, Repayment Behaviour, and Customer Profile.

![Dashboard](images/dashboard.png)

The dashboard is connected to PostgreSQL views through Power Query, allowing the results to be refreshed when the underlying data changes.

## Analysis Summary

### Key Findings
- **Overall default rate:** Approximately 22% of customers defaulted in the following month.
- **Credit limits:** Customers with lower credit limits exhibited substantially higher default rates.
- **Credit utilization:** Higher maximum credit utilization was associated with increased default risk among customers whose maximum utilization exceeded 50%.
- **Repayment history:** Customers with more frequent payment delays generally had higher default rates.
- **Delay recency:** Recent payment delays were associated with higher default rates than earlier delays, even among customers with the same total number of delayed months.
- **Customer profile:** Demographic differences were observed, but repayment-related patterns were generally more pronounced.

### Credit Limit
- Default rates consistently decreased as credit limits increased, from approximately 36% among customers with limits below NT$50,000 (New Taiwan Dollar) to 11% among those with limits of NT$500,000 or more.
- The largest drop occurred between the two lowest credit limit groups, with default rates falling from 36% to 26%, a difference of approximately 10 percentage points.
- However, this relationship should not be interpreted as causal. Higher credit limits may have been granted to customers already considered less risky based on factors unavailable in the dataset, such as income or previous credit history.

### Maximum Credit Utilization
Maximum credit utilization represents the highest percentage of a customer's credit limit used in a single month during the six-month observation period.
- Customers with maximum credit utilization below 50% had similar default rates of approximately 18–19%.
- Default rates began to increase among customers whose maximum utilization reached 50–75% (24%), rising further to 25% in the 75–100% group.
- Customers whose maximum utilization exceeded 100% had the highest default rate (30%).

### Repayment History
Delinquency frequency measures the number of months in which a customer had a recorded payment delay during the six-month observation period.
- Customers with no recorded payment delays had the lowest default rate, at approximately 12%.
- Customers with a recorded payment delay in just one month had a default rate of 30%, more than twice the rate observed among customers without delays.
- Default rates continued to increase with delinquency frequency, reaching approximately 64% among customers with four or more delayed months.

### Timing of Payment Delays
To examine whether the timing of repayment delays matters, the six-month observation period was divided into two three-month periods:
- **Earlier period:** April–June 2005
- **Recent period:** July–September 2005

The analysis compared customers with the same total number of delayed months, with delays occurring exclusively in either the earlier or the recent period.

The table below presents default rates for customers with exactly one, two, or three delayed months.

| Timing of Delays | 1 month | 2 months | 3 months |
|:---|:---:|:---:|:---:|
| April–June	| 20% | 28% | 33% |
| July–September |	34% | 40% | 56% |

In all three comparisons, customers with recent payment delays had higher default rates, with differences ranging from approximately 12 to 23 percentage points.

### Customer Profile
- **Age:** Default rates ranged from 20% among customers aged 30–39 to 28% among those aged 60+, while the remaining age groups had rates between 23% and 25%. However, the 60+ group had the smallest sample size (339 customers), so this result should be interpreted with caution.
- **Sex:** Male customers had a higher default rate (24%) than female customers (21%).
- **Education:** Customers with graduate school education had the lowest default rate (19%), followed by university (24%) and high school (25%).

Overall, demographic differences were generally less pronounced than those associated with repayment behaviour.

## Business Recommendations
1. **Prioritize repayment history in credit risk assessment:** Customers with repeated payment delays should be considered a higher-risk group when assessing default risk in the following month.
2. **Consider the timing of payment delays when assessing default risk:** Risk assessment should distinguish between recent and earlier payment delays rather than relying solely on the total number of delayed months.
3. **Consider credit exposure when assessing default risk:** Both credit limits and maximum credit utilization showed clear associations with default rates.
4. **Treat demographic findings as supplementary context:** Demographic differences were generally smaller than those associated with repayment behaviour and credit exposure. They provide useful context, but the use of certain demographic characteristics in credit decisions may be legally restricted.
5. **Combine multiple indicators:** Combining repayment history and credit exposure may provide a more complete picture of default risk than relying on a single factor, while demographic patterns can be considered as additional descriptive context.

## Dataset Structure
Source: https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients

The dataset contains 30,000 customer records, including demographic information, credit limits, six months of financial history, and the following month's default outcome.

After importing the data into PostgreSQL, it was organized into three tables:
- **credit_card_clients_raw:** Stores the imported dataset before analytical transformations.
- **clients:** Stores customer-level information, including demographics, credit limits, and default outcomes.
- **monthly_credit_history:** Stores monthly repayment statuses, bill amounts, and payment amounts.

The original dataset contained one row per customer. Monthly financial data was transformed from wide to long format, creating six records per customer. The diagram below illustrates the one-to-many relationship between the two analytical tables. The raw data table is not included in the diagram.

![Database_Schema](images/database_schema.png)


## Project Workflow
The project involved the following stages:
1. Importing the dataset into PostgreSQL, cleaning the data, and transforming it into a relational database structure.
2. Conducting exploratory and descriptive analysis using SQL.
3. Creating SQL views and connecting them to Excel through Power Query.
4. Developing an Excel dashboard to visualize the results.
5. Summarizing key findings and providing business recommendations.

___
___
___

## Additional Technical Details
### Data Cleaning Decisions
The original data was preserved in credit_card_clients_raw, while the transformations were applied to the analytical tables and SQL queries.

The following decisions were made during data preparation:
- **Education:** Undocumented education codes (0, 5, 6) were grouped into the others category.
- **Marital status:** Undefined marital status codes were grouped into the other category.
- **Repayment status:** Positive values were treated as payment delays, while zero and negative values were treated as months without recorded delays. Original status values were preserved in the database.
- **Negative bill amounts:** Negative statement balances were treated as zero when calculating credit utilization to avoid interpreting negative balances as negative credit usage.

### Limitations
Several limitations should be considered when interpreting the results:
- **Historical dataset:** The observations cover April-September 2005 and may not reflect current customer behaviour.
- **Limited observation window:** Only six months of repayment history were available.
- **Undocumented categories:** Certain education and repayment status values are not fully explained in the original documentation.
- **Limited financial information:** The dataset does not include important factors such as customer income, employment status, or previous credit history, limiting the interpretation of observed differences between credit limit groups.
- **Observational analysis:** The identified relationships represent associations rather than causal effects.
- **No predictive model:** This project focuses on descriptive analysis rather than developing or validating a predictive credit risk model.
	
### Reproducing the Analysis
1. Download the original dataset from the UCI Machine Learning Repository.
2. Remove the header row containing generic variable names (X1, X2, etc.) and save the prepared file as CSV.
3. Run 01_create_database.sql to create the PostgreSQL database.
4. Connect to the credit_risk_analysis database.
5. Run 02_create_tables.sql and import the source data into credit_card_clients_raw.
6. Run 03_load_transform_data.sql to populate the analytical tables.
7. Run 04_analysis.sql to explore the results.
8. Run 05_create_views.sql to create the analytical views.
9. Open the Excel dashboard and configure the existing Power Query connections to your PostgreSQL database.
10. Refresh the Power Query connections to load the analytical results.

Note: Connecting Excel Power Query to PostgreSQL may require installing the Npgsql driver, depending on the Excel version and configuration.
Refreshing the Excel workbook requires access to the PostgreSQL database. A static dashboard preview is available in the repository.

### Data Source
Source: https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients  
Yeh, I. (2009). Default of Credit Card Clients. UCI Machine Learning Repository.  
DOI: https://doi.org/10.24432/C55S3H  
Dataset licensed under CC BY 4.0.  
