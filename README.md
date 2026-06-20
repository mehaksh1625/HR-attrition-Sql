# HR Attrition Analysis — SQL

SQL-based analysis of the IBM HR Attrition dataset (1,470 employees) to identify 
key drivers of employee turnover across department, compensation, and risk indicators.

## Tools Used
MySQL Workbench · SQL (window functions, CTEs, subqueries, conditional aggregation)

## Key Findings

**1. Sales has the highest attrition rate among all departments (20.63%)**, 
nearly double that of Research & Development (13.84%) despite R&D having more 
than double the headcount (961 vs. 446 employees). Human Resources, while the 
smallest department (63 employees), shows the second-highest attrition rate 
at 19.05% — suggesting attrition risk is not simply a function of department size.

**2. A composite flight-risk score (combining low tenure, low job satisfaction, 
and overtime status) shows a 10x difference in attrition rate between the 
lowest and highest risk groups** — employees with zero risk flags churn at 
just 5.74%, while employees with all three risk flags churn at 58.97%. This 
demonstrates that attrition risk compounds sharply when multiple stress factors 
overlap, rather than scaling linearly.

**3. Compensation has a strong but non-linear relationship with attrition.** 
Employees in the lowest salary quartile churn at 29.35% — nearly 3x the rate 
of the highest quartile (10.35%). However, attrition rates for Quartiles 2, 3, 
and 4 are much closer together (14.13%, 10.63%, 10.35%), indicating that being 
underpaid relative to peers is a much stronger driver of attrition than 
incremental pay increases once a baseline compensation threshold is met.

## Business Implication
Retention strategy should prioritise: (1) targeted intervention for the lowest 
salary quartile specifically, rather than broad compensation increases, and 
(2) early identification of employees accumulating multiple risk flags 
(low tenure + low satisfaction + overtime), since risk compounds rather than 
adds linearly.

## Queries Included
- Department-wise attrition rate (headcount-adjusted)
- Composite flight-risk scoring using CTEs and conditional aggregation
- Salary quartile analysis using `NTILE()` window function
- Income ranking within department using `RANK()`
- Rolling average income by tenure
- Manager relationship tenure vs. attrition
- Work-life balance vs. overtime cross-tabulation
- Highest earner per job role using `DENSE_RANK()`
- Subquery-based identification of above-average attrition departments

## Dataset
[IBM HR Analytics Employee Attrition & Performance](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset) — Kaggle, 1,470 records
