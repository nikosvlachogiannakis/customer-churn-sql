# E-Commerce Customer Churn Analysis (SQL)

A SQL-based exploratory analysis of customer churn for an e-commerce platform, using SQLite. The project cleans a raw customer dataset and then explores churn patterns across demographics, behavior, and service-experience variables to identify which factors are most associated with customers leaving.

## Dataset

The dataset contains **5,630 rows and 20 columns**, with one row per customer.

| Column | Description |
|---|---|
| CustomerID | Unique customer ID |
| Churn | Churn flag (1 = churned, 0 = stayed) |
| Tenure | Tenure of customer with the organization |
| PreferredLoginDevice | Customer's preferred login device |
| CityTier | City tier |
| WarehouseToHome | Distance between warehouse and customer's home |
| PreferredPaymentMode | Customer's preferred payment method |
| Gender | Customer's gender |
| HourSpendOnApp | Hours spent on the app/website |
| NumberOfDeviceRegistered | Number of devices registered to the customer |
| PreferedOrderCat | Preferred order category in the last month |
| SatisfactionScore | Customer satisfaction score |
| MaritalStatus | Marital status |
| NumberOfAddress | Number of addresses registered |
| Complain | Whether a complaint was raised in the last month |
| OrderAmountHikeFromlastYear | % increase in order amount vs. last year |
| CouponUsed | Number of coupons used in the last month |
| OrderCount | Number of orders placed in the last month |
| DaySinceLastOrder | Days since the customer's last order |
| CashbackAmount | Average cashback received in the last month |

## Tools

- **SQLite** for all data cleaning and querying
- **Python** (`pandas`, `openpyxl`) to convert the raw `.xlsx` dataset into a SQLite database
- Raw `.sql` script (`e_comm_churn_analysis.sql`) containing the full workflow

## What the analysis does

**1. Data Cleaning**
- Checked row and duplicate-ID counts
- Checked for NULL values across key numeric columns and imputed them with column averages
- Standardized inconsistent categorical labels (e.g. `Mobile Phone` → `Phone`, `COD` → `Cash on Delivery`, `CC` → `Credit Card`)
- Fixed obvious data-entry outliers in `WarehouseToHome` (e.g. `126` → `26`)
- Added two derived columns: `CustomerStatus` (Churned/Stayed) and `CustomerComplain` (Yes/No), for more readable grouping in later queries

**2. Data Exploration**
Churn rate was broken down across: login device, city tier, payment mode, gender, average app usage time, preferred order category, satisfaction score, marital status, complaint status, and coupon usage.

## Key Findings

Overall churn rate: **16.84%** (948 of 5,630 customers churned).

| Segment | Highest-churn group | Churn rate | Lowest-churn group | Churn rate |
|---|---|---|---|---|
| Complaint status | Complaint raised | **31.67%** | No complaint | 10.93% |
| Marital status | Single | **26.73%** | Married | 11.52% |
| Preferred order category | Phone | **27.4%** | Grocery | 4.88% |
| City tier | Tier 3 | **21.37%** | Tier 1 | 14.51% |
| Payment mode | Cash on Delivery | **24.9%** | Credit Card | 14.21% |
| Login device | Computer | **19.83%** | Phone | 15.62% |
| Satisfaction score | Score 5 | **23.83%** | Score 1 | 11.51% |
| Gender | Male | 17.73% | Female | 15.49% |

**Standout observations:**
- **Complaints are the single strongest signal in this dataset.** Customers who raised a complaint in the last month churned at nearly 3x the rate of those who didn't (31.67% vs. 10.93%).
- **Single customers churn more than double the rate of married customers** (26.73% vs. 11.52%), with divorced customers in between (14.62%).
- **Customers who order primarily "Phone" category products churn far more** than any other category (27.4%), while Grocery customers are by far the most loyal (4.88%).
- **Satisfaction score is not linear with churn.** Customers with the *highest* satisfaction score (5) had the second-highest churn rate (23.83%), notably above scores of 2, 3, and 4. This is counterintuitive and worth digging into further — it may reflect customers who leave positive scores but churn for reasons like price or convenience, or a data quality issue worth validating.
- **Average time spent on the app was nearly identical between churned and retained customers** (2.96 vs. 2.93 hours), suggesting app usage time alone isn't a meaningful churn predictor in this dataset.
- **Digital payment methods (Credit/Debit Card, UPI) retain customers better than Cash on Delivery or E-wallet.**

## Repository Structure

```
├── xlsx_to_sql.py               # Converts the raw .xlsx dataset into a SQLite .db file
├── e_comm_churn_analysis.sql    # Full SQL script: cleaning + exploration
├── README.md                    # This file
└── visuals/                     # Dashboard/chart exports (coming soon)
```

## Visuals

*Placeholder — a dashboard (Power BI/Tableau) or chart set summarizing the churn-rate breakdowns above is planned for this section.*

## How to Run

1. **Install dependencies**
   ```
   pip install pandas openpyxl
   ```
2. **Convert the raw dataset to SQLite**
   Open `xlsx_to_sql.py` and set `XLSX_PATH` to the path of your `.xlsx` file, then run:
   ```
   python xlsx_to_sql.py
   ```
   This creates a `.db` file (same name as the xlsx) with one table per sheet. The sheet containing the customer data becomes the `e_comm` table used throughout the SQL script (rename the table if your sheet name sanitizes to something different).
3. **Open the `.db` file** in a SQLite client (e.g. DB Browser for SQLite).
4. **Run `e_comm_churn_analysis.sql`** from top to bottom — cleaning steps must run before the exploration queries, since exploration relies on the `CustomerStatus` and `CustomerComplain` columns created during cleaning.

## Limitations & Future Work

- Numeric predictors like `Tenure`, `NumberOfDeviceRegistered`, `DaySinceLastOrder`, and `CashbackAmount` haven't yet been analyzed against churn and are likely strong candidates for further exploration.
- No statistical significance testing (e.g. chi-square, t-tests) has been applied to confirm which differences are meaningful vs. noise.
- Outlier detection was manual and limited to one column; a systematic pass (IQR/z-score) across all numeric fields would strengthen the cleaning step.
- A visualization layer (dashboard or chart set) is planned to make these findings easier to communicate at a glance.

## Author

*[Your name here]*
