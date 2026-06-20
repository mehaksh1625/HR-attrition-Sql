CREATE DATABASE Employee_Attrition;
USE Employee_Attrition;
CREATE TABLE hr_attrition (
    Age INT,
    Attrition VARCHAR(10),
    BusinessTravel VARCHAR(50),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT,
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(20),
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 VARCHAR(5),
    OverTime VARCHAR(10),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

SELECT COUNT(*) FROM hr_attrition;
SELECT * FROM hr_attrition LIMIT 10;

SELECT 
  Department,
  COUNT(*) AS total_employees,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
  ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

SELECT 
  EmployeeNumber, Department, JobRole, MonthlyIncome,
  RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome DESC) AS income_rank_in_dept
FROM hr_attrition
ORDER BY Department, income_rank_in_dept;

WITH risk_flags AS (
  SELECT *,
    CASE WHEN YearsAtCompany <= 2 THEN 1 ELSE 0 END AS low_tenure,
    CASE WHEN JobSatisfaction <= 2 THEN 1 ELSE 0 END AS low_satisfaction,
    CASE WHEN OverTime = 'Yes' THEN 1 ELSE 0 END AS overtime_flag
  FROM hr_attrition
)
SELECT 
  (low_tenure + low_satisfaction + overtime_flag) AS risk_score,
  COUNT(*) AS employee_count,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS actual_attrition,
  ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM risk_flags
GROUP BY risk_score
ORDER BY risk_score DESC;

SELECT 
  YearsAtCompany,
  AVG(MonthlyIncome) AS avg_income_this_tenure,
  AVG(AVG(MonthlyIncome)) OVER (ORDER BY YearsAtCompany ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_income
FROM hr_attrition
GROUP BY YearsAtCompany
ORDER BY YearsAtCompany;

SELECT Department, 
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS dept_attrition_rate
FROM hr_attrition
GROUP BY Department
HAVING dept_attrition_rate > (
  SELECT 100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*) 
  FROM hr_attrition
);

SELECT 
  EmployeeNumber, Department, MonthlyIncome,
  NTILE(4) OVER (ORDER BY MonthlyIncome) AS salary_quartile
FROM hr_attrition;

WITH quartiles AS (
  SELECT *, NTILE(4) OVER (ORDER BY MonthlyIncome) AS salary_quartile
  FROM hr_attrition
)
SELECT 
  salary_quartile,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS left_count,
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM quartiles
GROUP BY salary_quartile
ORDER BY salary_quartile;

SELECT 
  EmployeeNumber, Department, YearsSinceLastPromotion, Attrition,
  LAG(YearsSinceLastPromotion) OVER (PARTITION BY Department ORDER BY YearsSinceLastPromotion) AS prev_employee_promo_gap
FROM hr_attrition
WHERE Attrition = 'Yes'
ORDER BY Department;

SELECT 
  YearsWithCurrManager,
  COUNT(*) AS total,
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY YearsWithCurrManager
ORDER BY YearsWithCurrManager;

SELECT 
  WorkLifeBalance,
  SUM(CASE WHEN OverTime='Yes' THEN 1 ELSE 0 END) AS overtime_count,
  SUM(CASE WHEN OverTime='No' THEN 1 ELSE 0 END) AS no_overtime_count,
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_attrition
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;

SELECT * FROM (
  SELECT EmployeeNumber, JobRole, MonthlyIncome,
    DENSE_RANK() OVER (PARTITION BY JobRole ORDER BY MonthlyIncome DESC) AS rnk
  FROM hr_attrition
) ranked
WHERE rnk = 1;

WITH base AS (
  SELECT *,
    CASE WHEN YearsAtCompany <= 2 THEN 'New' ELSE 'Tenured' END AS tenure_group
  FROM hr_attrition
)
SELECT 
  tenure_group, Department,
  COUNT(*) AS total,
  ROUND(AVG(MonthlyIncome),0) AS avg_income,
  ROUND(100.0 * SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate_pct
FROM base
GROUP BY tenure_group, Department
ORDER BY Department, tenure_group;