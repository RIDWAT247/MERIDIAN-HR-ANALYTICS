/* ============================================================
   MERIDIAN HR ANALYTICS
   03 - SALARY ANALYSIS
   ============================================================

   Objective:
   Analyze employee salary levels and identify compensation
   patterns across departments, job levels, demographics,
   and turnover groups.

   Key Business Questions:
   - What is the overall salary distribution?
   - Which departments have the highest and lowest salaries?
   - Which job levels earn below or above the company average?
   - How many employees earn below key salary thresholds?
   - How does salary differ between active and former employees?

   Salary Reference:
   Overall average salary is approximately ₦357,000.

============================================================ */

USE meridian_hr;

/* ============================================================
   1. OVERALL SALARY PROFILE
============================================================ */
SELECT
    COUNT(*) AS Total_Employees,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary,
    MIN(Monthly_Salary_NGN) AS Minimum_Salary,
    MAX(Monthly_Salary_NGN) AS Maximum_Salary
FROM Meridian;
--- Insights:
--- Minimum salary: ₦85,000
--- Maximum salary: ₦2,200,000
--- Average salary: ₦357,000

/* ============================================================
   2. AVERAGE SALARY BY DEPARTMENT
   Purpose: Compare compensation across Departments
============================================================ */
SELECT
    Department,
    MIN(Monthly_Salary_NGN) AS Minimum_Salary,
    MAX(Monthly_Salary_NGN) AS Maximum_Salary,
    ROUND(AVG(Monthly_Salary_NGN),2) AS Average_Salary
FROM Meridian
GROUP BY Department
ORDER BY Average_Salary DESC;
--- Insights:
--- Sales and Operation Department earn below overall average salary.
--- Human Resources earn above average salary.
--- Risk and compliance earns the highest average salary, followed by information Technology.
--- Information Technology is the highest maximum earner amongst others.
--- Risk and compliance is the 2nd highest maximum earner followed by Operations and Sales.
--- the lowest maximum earner is Human resources department.
--- Sales, Operations and Human Resources recorded minimum salary of #85,000.
--- Risk and compliance recorded minimum salary of #86,000.
--- Information Technology recorded the highest minimum salary of #95,000.

/* ============================================================
   3. SALARY BY JOB LEVEL
============================================================ */
SELECT
    Job_Level,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary,
    MIN(Monthly_Salary_NGN) AS Minimum_Salary,
    MAX(Monthly_Salary_NGN) AS Maximum_Salary
FROM Meridian
GROUP BY Job_Level
ORDER BY Average_Salary DESC;
--- Insights:
--- Junior and mid_level staff earn below company overall average salary
--- Senior staff earn above over-all average salary
--- Directors are the highest earners followed by managers

/* ============================================================
   4. SALARY BY GENDER
============================================================ */
SELECT
    Gender,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary,
    MIN(Monthly_Salary_NGN) AS Minimum_Salary,
    MAX(Monthly_Salary_NGN) AS Maximum_Salary
FROM Meridian
GROUP BY Gender
ORDER BY Average_Salary DESC;
--- Insights:
--- Male employee recorded the highest average salary
--- Female employee recorded the highest maximum salary

/* ============================================================
   5. SALARY BY EDUCATION LEVEL
   Purpose:Compare compensation accross job level
============================================================ */
SELECT
    Education_Level,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary,
    MIN(Monthly_Salary_NGN) AS Minimum_Salary,
    MAX(Monthly_Salary_NGN) AS Maximum_Salary
FROM Meridian
GROUP BY Education_Level
ORDER BY Average_Salary DESC;
--- Insights:
--- OND recorded the highest average salary and also the lowest maximum salary
--- BSc recorded the lowest average salary
--- MSc recorded the highest maximum

/* ============================================================
   6. SALARY BY EMPLOYMENT TYPE
   Purpose:Compare compensation accross employment type
============================================================ */
SELECT
    Employment_Type,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary,
    MIN(Monthly_Salary_NGN) AS Minimum_Salary,
    MAX(Monthly_Salary_NGN) AS Maximum_Salary
FROM Meridian
GROUP BY Employment_Type
ORDER BY Average_Salary DESC;
--- Insights:
--- Part time recorded the highest average salary 
--- Contract recorded the lowest average salary and also recorded the highest maximmum salary
--- Full time recorded the 2nd highest average and the 2nd highest maximum salary

/* ============================================================
   7. SALARY BAND DISTRIBUTION - ORDERED
============================================================ */
WITH SalaryBands AS
(SELECT CASE
            WHEN Monthly_Salary_NGN < 100000
                THEN 'Poor Salary'
            WHEN Monthly_Salary_NGN BETWEEN 100000 AND 257000
                THEN 'Low Salary'
            WHEN Monthly_Salary_NGN BETWEEN 257001 AND 357000
                THEN 'Below Average'
            WHEN Monthly_Salary_NGN BETWEEN 357001 AND 557000
                THEN 'Above Average'
            ELSE 'High Salary'
        END AS Salary_Band,
        CASE
            WHEN Monthly_Salary_NGN < 100000 THEN 1
            WHEN Monthly_Salary_NGN BETWEEN 100000 AND 257000 THEN 2
            WHEN Monthly_Salary_NGN BETWEEN 257001 AND 357000 THEN 3
            WHEN Monthly_Salary_NGN BETWEEN 357001 AND 557000 THEN 4
            ELSE 5
        END AS Band_Order
    FROM Meridian)
SELECT
    Salary_Band,
    COUNT(*) AS Employee_Count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage_of_Workforce
FROM SalaryBands
GROUP BY
    Salary_Band,
    Band_Order
ORDER BY
    Band_Order;
--- Insights:
--- Poor Salary	recorded 4.28%
--- Low Salary recorded 39.38%
--- Below Average recorded 18.54%
--- Above Average recorded 22.22%
--- High Salary	recorded 15.58%


/* ============================================================
   8. EMPLOYEES EARNING BELOW ₦100,000
   Purpose:Determine numbers of employees earning poor salary
============================================================ */
SELECT
    COUNT(*) AS Employees_Below_100K,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM Meridian),
        2
    ) AS Percentage_of_Workforce
FROM Meridian
WHERE Monthly_Salary_NGN < 100000;
--- Insights:
--- 214 employees earn below 100,000

/* ============================================================
   9. LOW-SALARY EMPLOYEES BY DEPARTMENT
   Purpose: Determine which departments have the highest number of employees earning less than ₦100,000 per month.
============================================================ */
SELECT
    Department,
    COUNT(*) AS Employees_Below_100K,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage_of_Low_Salary_Group
FROM Meridian
WHERE Monthly_Salary_NGN < 100000
GROUP BY Department
ORDER BY Employees_Below_100K DESC;
--- Insights:
--- The Sales department has the highest number of employees earning less than ₦100,000, with 86 employees.
--- The Operations department follows with 57 employees, while Human Resources has 33 employees.
--- Risk and Compliance has 26 employees earning below ₦100,000 whereas Information Technology has the fewest, with only 4 employees.
--- Lower-paid employees are concentrated primarily in the Sales and Operations departments.


/* ============================================================
   10. SALARY AND PERFORMANCE
============================================================ */
SELECT
    CASE
        WHEN Performance_Score < 3.4
            THEN 'Low Performer'
        ELSE 'High Performer'
    END AS Performance_Category,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary
FROM Meridian
GROUP BY
    CASE
        WHEN Performance_Score < 3.4
            THEN 'Low Performer'
        ELSE 'High Performer'
    END;
---Insight:
---High Performance employees are 2713 with average salary of 413888.55
---Low Performance employees are 2287 with average salary of 289527.14


/* ============================================================
   11. SALARY, DEPARTMENT AND TURNOVER
   Purpose: To determine high paying department with high turnover.
============================================================ */
SELECT
    Department,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary,
    COUNT(*) AS Total_Employees,
    SUM(
        CASE
            WHEN Turnover_Status <> 'Active'
                THEN 1
            ELSE 0
        END
    ) AS Employees_Left,
    ROUND(
        SUM(
            CASE
                WHEN Turnover_Status <> 'Active'
                    THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Turnover_Rate
FROM Meridian
GROUP BY Department
ORDER BY Turnover_Rate DESC;
--- Insight: 
--- Risk and compliance pays the highest average salary and they maintain the lowest turnover rate
--- Information Technology pays high average salary but recorded high turnover rate.
--- Human Resources pay lower than IT and their exit rate is also lesser than IT
--- Operations pays lower and recorded high turnover rate
--- Sales pays the lowest average salary and also maintain the highest turnover rate.


/* ============================================================
   KEY BUSINESS INSIGHTS
============================================================

1. Overall salary:
   Monthly salary ranges from approximately ₦85,000 to
   ₦2,200,000, with an overall average of approximately
   ₦357,000.

2. Department:
   Risk and Compliance has the highest average salary,
   while Sales has the lowest.

3. Job Level:
   Junior and Mid-Level employees have average salaries
   below the overall company average.

4. Low salary:
   214 employees earn below ₦100,000.

5. Department concentration:
   Sales has the largest number of employees earning
   below ₦100,000.

6. Performance:
   Salary and performance patterns should not be interpreted
   as causal relationships based on descriptive analysis alone.

============================================================ */
