# HR Attrition Analysis — SQL

## Overview

This project presents an SQL-based analysis of the IBM HR Attrition dataset 
(1,470 employee records) to identify and quantify key drivers of employee 
attrition across department, compensation, and behavioural risk indicators. 
The analytical approach mirrors methods applied in an HR Business Partner 
capacity, where attrition diagnosis directly informs retention strategy.

**Tools:** MySQL Workbench · SQL (Common Table Expressions, window functions, 
conditional aggregation, subqueries)

**Dataset:** [IBM HR Analytics Employee Attrition & Performance](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset), 
Kaggle (1,470 records)


## Summary of Findings

| Metric | Result |
|---|---|
| Highest-attrition department | Sales (20.63%) |
| Attrition range across composite risk score | 5.74% – 58.97% |
| Attrition range across compensation quartiles | 10.35% – 29.35% |


## Findings

### 1. Department-Level Attrition Is Independent of Headcount

Sales recorded the highest attrition rate among all departments at 20.63%, 
despite having less than half the headcount of Research & Development 
(446 employees versus 961). Research & Development, by contrast, recorded 
a comparatively lower attrition rate of 13.84%. Human Resources, the smallest 
department by headcount (63 employees), recorded the second-highest attrition 
rate at 19.05%.

This indicates that department size is not a reliable proxy for attrition 
risk, and that retention resource allocation should be informed by 
department-level attrition rate rather than absolute headcount.

### 2. Attrition Risk Compounds Non-Linearly Across Risk Factors

A composite risk score was constructed using three indicators: tenure of two 
years or less, job satisfaction rating of two or below, and active overtime 
status. Employees with zero risk indicators present recorded an attrition 
rate of 5.74%. Employees with all three risk indicators present recorded an 
attrition rate of 58.97% — a tenfold increase.

The magnitude of this increase indicates that attrition risk does not 
accumulate additively across individual factors, but compounds sharply once 
multiple factors co-occur. This suggests that retention interventions are 
likely to be more effective when targeted at employees exhibiting multiple 
concurrent risk indicators, rather than any single indicator in isolation.

### 3. Compensation Shows a Threshold Effect Rather Than a Linear Relationship

Employees in the lowest compensation quartile recorded an attrition rate of 
29.35%, compared to 10.35% in the highest quartile. However, attrition rates 
for the second, third, and fourth quartiles were closely clustered (14.13%, 
10.63%, and 10.35% respectively), with the largest differential occurring 
between the first and second quartiles specifically.

This pattern indicates a threshold effect: attrition risk associated with 
compensation is concentrated primarily among the lowest-paid employees, with 
diminishing marginal impact once a baseline compensation level is reached. 
This has direct implications for how compensation-related retention budget 
is allocated — targeted correction at the lowest quartile is likely to yield 
greater retention impact than uniform increases across the workforce.

---

## Methodology Notes

Attrition rates throughout this analysis are calculated as the proportion of 
employees with `Attrition = 'Yes'` within each respective group, rather than 
absolute counts, to allow for valid comparison across groups of differing size. 
The composite risk score in Finding 2 was constructed using conditional 
aggregation within a Common Table Expression, combining three independently 
selected behavioural and tenure-based indicators.

---

## Query Index

The accompanying file `hr_attrition_analysis.sql` contains the following 
twelve queries:

1. Department-wise attrition rate (headcount-adjusted)
2. Income rank within department (`RANK()`)
3. Composite flight-risk scoring (CTE with conditional aggregation)
4. Rolling average income by tenure (windowed aggregate)
5. Subquery-based identification of above-average-attrition departments
6. Compensation quartile assignment (`NTILE()`)
7. Quartile-wise attrition rate
8. Promotion-gap sequencing by department (`LAG()`)
9. Manager-tenure relationship to attrition
10. Work-life balance and overtime cross-tabulation
11. Highest-compensated employee by job role (`DENSE_RANK()`)
12. Tenure-group and department attrition summary