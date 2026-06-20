# HR Attrition Analysis — README

**Overview:**
- **Purpose:** This repository contains a single SQL analysis script that creates a database/table for employee attrition data and runs a collection of exploratory queries and window/aggregation analyses to surface attrition patterns.
- **SQL file:** [hr_attrition_analysis.sql](hr_attrition_analysis.sql)

**Prerequisites:**
- MySQL 8.0+ (or compatible server supporting window functions and `NTILE`).

**Commands explained**

- **CREATE DATABASE Employee_Attrition;**: Creates a new database named `Employee_Attrition` to hold the analysis tables.

- **USE Employee_Attrition;**: Switches the session to the `Employee_Attrition` database so subsequent DDL/DML applies there.

- **CREATE TABLE hr_attrition (...);**: Defines the `hr_attrition` table and lists columns (types shown). This creates a schema to load employee-level attrition and HR variables such as `Age`, `Attrition`, `Department`, `MonthlyIncome`, `YearsAtCompany`, `OverTime`, etc.

- **SELECT COUNT(*) FROM hr_attrition;**: Returns the total number of rows (employees) in the table — basic dataset size check.

- **SELECT * FROM hr_attrition LIMIT 10;**: Shows a quick sample (first 10 rows) so you can inspect columns and data quality.

- **Department attrition summary (GROUP BY):**
  - Query groups rows by `Department`, counts employees, counts those with `Attrition = 'Yes'`, and computes the department attrition percentage using `ROUND(...)`. Results ordered by attrition rate descending so highest-risk departments appear first.

- **Rank incomes in department (RANK() OVER PARTITION):**
  - Uses `RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC)` to rank employees by `MonthlyIncome` within each `Department`. Useful to find top earners per department.

- **Risk flags CTE and risk-score aggregation:**
  - `WITH risk_flags AS (...)` computes three binary flags per employee: `low_tenure` (YearsAtCompany <= 2), `low_satisfaction` (JobSatisfaction <= 2), and `overtime_flag` (OverTime = 'Yes').
  - The outer query sums flags to form a `risk_score` and reports counts and actual attrition for each score. This shows how combined risk factors map to observed attrition.

- **Tenure vs. income rolling average:**
  - Aggregates `AVG(MonthlyIncome)` per `YearsAtCompany` and computes a 3-row rolling average using `AVG(...) OVER (ORDER BY YearsAtCompany ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`. Helps reveal income trends across tenure.

- **Departments with above-average attrition (HAVING + subquery):**
  - Computes each department's attrition rate and uses a `HAVING` clause to keep only departments with an attrition rate greater than the overall company attrition rate (computed in the subquery).

- **Salary quartiles (NTILE):**
  - `NTILE(4) OVER (ORDER BY MonthlyIncome)` assigns each employee to a salary quartile. Useful for stratified analysis by pay band.

- **Attrition by salary quartile (CTE + GROUP BY):**
  - Places `NTILE` results in a `quartiles` CTE, then summarizes total employees and attrition counts/percent for each quartile to see if attrition correlates with pay.

- **Promotion gap for employees who left (LAG):**
  - For rows where `Attrition = 'Yes'`, the query shows `YearsSinceLastPromotion` and uses `LAG(...) OVER (PARTITION BY Department ORDER BY YearsSinceLastPromotion)` to compare an employee's promotion gap to the previous employee within the same department. Can highlight unusual promotion patterns among leavers.

- **Attrition by `YearsWithCurrManager`:**
  - Groups by `YearsWithCurrManager` and reports counts plus the attrition percentage to evaluate manager-tenure effects.

- **Work-life balance vs. overtime and attrition:**
  - Groups by `WorkLifeBalance`, counts employees working overtime vs not, and reports the attrition percentage for each `WorkLifeBalance` level. Useful to inspect whether poor work-life balance and overtime correlate with attrition.

- **Top earners per `JobRole` (DENSE_RANK):**
  - The derived table uses `DENSE_RANK() OVER (PARTITION BY JobRole ORDER BY MonthlyIncome DESC)` and the outer filter `WHERE rnk = 1` to list the highest-paid employees in each job role.

- **Tenure grouping summary (CTE + GROUP BY):**
  - `WITH base AS (...)` creates a `tenure_group` (`'New'` for `YearsAtCompany <= 2`, else `'Tenured'`). The final aggregation reports total counts, average income, and attrition rate per `tenure_group` and `Department`.

**Notes & tips:**
- The script assumes an existing CSV or ETL process will populate `hr_attrition` after table creation.
- Adjust data types or column sizes in `CREATE TABLE` if your source dataset has different formats.
- For large datasets, remove `LIMIT` and add `WHERE` filters or `EXPLAIN` queries before running heavy aggregations.
- If using a server that requires a different SQL dialect (Postgres, SQL Server), minor syntax changes may be necessary (for example, `LIMIT` vs `TOP`, or quoting rules).

If you want, I can also:
- Add inline comments to `hr_attrition_analysis.sql` explaining each block, or
- Convert the analysis to a Jupyter notebook or Python script that runs these queries and visualizes results.
