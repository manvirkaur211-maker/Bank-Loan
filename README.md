# Bank-LoanLoan Performance Analytics Project

1. Project Description

The objective of this project was to analyze loan portfolio performance, identify default risk, evaluate recovery outcomes, and understand customer payment behaviour. SQL Server was used for data cleaning and analysis, while Power BI was used to build an interactive dashboard for business insights.

2. Data Source

The dataset consisted of five related tables:

* Customers
* Accounts
* Loans
* Defaults
* Transactions

The data included loan details, customer information, payment history, default records, and recovery status.

3. Technologies Used

* SQL Server Management Studio (SSMS)
* SQL
* Power BI
* DAX
* Power Query

4. Data Preprocessing / Cleaning

* Checked for duplicate records and missing values.
* Standardized inconsistent values (e.g., CHECKNG → CHECKING, SAVNGS → SAVINGS, CHARGE-OFF → CHARGED OFF).
* Converted loan amount to the correct numeric data type.
* Validated relationships between tables.
* Documented unmatched records and data quality issues.

5. Data Loading (Optional)

The cleaned SQL tables were imported into Power BI. Relationships were created between the tables, and DAX measures were developed to support KPI calculations and dashboard visualizations.

6. Analysis / Insights

* Built six SQL queries to analyze loan status, default rates, recovery performance, payment behaviour, payment channels, and loan lifecycle.
* Created an Executive Summary dashboard with KPI cards and interactive charts.
* Identified Home Equity loans as having the highest default rate.
* Found that Active loans represented the largest portion of the portfolio.
* Analyzed recovery outcomes and customer payment behaviour to support risk assessment.

7. Recommendations

* Monitor loan products with higher default rates more closely.
* Prioritize follow-up for borrowers with multiple missed payments.
* Improve data quality by resolving unmatched records across related tables.
* Continue monitoring recovery performance to improve collection strategies.
* Use the Power BI dashboard for ongoing portfolio and credit risk monitoring.
