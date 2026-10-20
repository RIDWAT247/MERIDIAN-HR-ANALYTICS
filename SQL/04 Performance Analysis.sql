/* ============================================================
   MERIDIAN HR ANALYTICS PROJECT
   File: 04_Performance_Analysis.sql
   Purpose: Analyze employee performance and identify
            performance-related workforce patterns.

   Key Areas:
   - Overall performance profile
   - Performance by department
   - Low and high performers
   - Performance by salary band
   - Performance by job level
   - Performance by turnover status
   - Low-performance employee analysis

   Performance Threshold:
   < 3.4  = Low Performer
   >= 3.4 = High Performer
   ============================================================ */

   /* ============================================================
   1. OVERALL PERFORMANCE PROFILE
   ============================================================ */
SELECT
    COUNT(*) AS Total_Employees,
    ROUND(AVG(Performance_Score), 2) AS Average_Performance,
    MIN(Performance_Score) AS Minimum_Performance,
    MAX(Performance_Score) AS Maximum_Performance
FROM Meridian;
--- Insights
--- Minimum performance is -0.50
--- Maximum performance is 5.00
--- Average performance is 3.43
/*
The average employee performance score is approximately 3.43,
with scores ranging from -0.50 to 5.00. The negative minimum
requires validation because it may represent an invalid or
anomalous performance value depending on the organization's
performance scoring system.
*/  

/* ============================================================
   2. AVERAGE PERFORMANCE BY DEPARTMENT
   ============================================================ */
SELECT
    Department,
    ROUND(AVG(Performance_Score), 2) AS Average_Perf   
FROM Meridian
GROUP BY
    Department
ORDER BY
    Average_Perf;
--- Insights:
--- Sales recorded the lowest average performance of 3.030000
--- Operations rcorded 3.500000
--- Information Technology recorded	3.580000
--- Risk and Compliance	3.600000
--- Human Resources	recorded the highest average performance of 3.610000

/* ============================================================
   3. LOW PERFORMERS BY DEPARTMENT
   Performance_Score < 3.4
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Total_Employees,
    SUM(
        CASE
            WHEN Performance_Score < 3.4 THEN 1
            ELSE 0
        END
    ) AS Low_Performer_Count,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Performance_Score < 3.4 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Low_Performer_Percentage
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department
ORDER BY Low_Performer_Percentage DESC;
--- Insight:
--- The Sales department has the highest number of employees with performance scores below 3.4
--- Operations recorded 516
--- Risk and Compliance recorded 379 and it is above Human resources and Information Technology
--- Human Resources recorded 272
--- Information Technology is the lowest with 269

/* ============================================================
   4. HIGH PERFORMERS BY DEPARTMENT
   Performance_Score >= 3.4
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Total_Employees,
    SUM(
        CASE
            WHEN Performance_Score >= 3.4 THEN 1
            ELSE 0
        END
    ) AS High_Performer_Count,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Performance_Score >= 3.4 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS High_Performer_Percentage
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department
ORDER BY High_Performer_Percentage DESC;
--- Insight:
--- Operations department has the highest number of employees with performance scores above 3.4 (651)
--- Risk and Compliance recorded 574
--- Human Resources recorded 427
--- Information Technology also recorded 427
--- Sales is the lowest with 364


/* ============================================================
   5. PERFORMANCE BY SALARY BAND
   Purpose: To evaluate performance of employees by salary
   ============================================================ */
SELECT
    CASE
        WHEN Monthly_Salary_NGN < 100000 THEN 'Poor Salary'
        WHEN Monthly_Salary_NGN BETWEEN 100000 AND 257000 THEN 'Low Salary'
        WHEN Monthly_Salary_NGN BETWEEN 257001 AND 357000 THEN 'Below Average'
        WHEN Monthly_Salary_NGN BETWEEN 357001 AND 557000 THEN 'Above Average'
        ELSE 'High Salary'
    END AS Salary_Band,
    COUNT(*) AS Total_Employees,
    ROUND(avg(Performance_Score), 2) AS Average_Perf  
FROM Meridian
GROUP BY
    CASE
        WHEN Monthly_Salary_NGN < 100000 THEN 'Poor Salary'
        WHEN Monthly_Salary_NGN BETWEEN 100000 AND 257000 THEN 'Low Salary'
        WHEN Monthly_Salary_NGN BETWEEN 257001 AND 357000 THEN 'Below Average'
        WHEN Monthly_Salary_NGN BETWEEN 357001 AND 557000 THEN 'Above Average'
        ELSE 'High Salary'
    END
ORDER BY Average_Perf DESC;
--- Insights:
--- High Salary band recorded the highest average performance of 3.870000 
--- Below Average salary band recorded 3.500000
--- Above Average salary band recorded 3.480000
--- Low Salary band	recorded 3.230000
--- Poor Salary	band has the lowest average performance of 3.150000

/* ============================================================
   6. PERFORMANCE BY JOB LEVEL
   ============================================================ */
--- Query: Performance by job level
--- Purpose: Determine the average performance by job level
SELECT
    Job_Level,
    ROUND(AVG(Performance_Score), 2) AS Average_Perf   
FROM Meridian
GROUP BY
    Job_Level
ORDER BY
    Average_Perf;
--- Insights:
--- Junior employees has the lowest average performance of 3.190000
--- Mid-level employees has	3.430000
--- Senior employees recorded 3.490000
--- Director recorded 3.980000
--- Manager	recorded 3.990000.

/* ============================================================
   8. PERFORMANCE BY TURNOVER STATUS
   ============================================================ */
SELECT
    Turnover_Status,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Performance_Score), 2) AS Average_Performance
FROM Meridian
GROUP BY Turnover_Status
ORDER BY Average_Performance DESC;
---Insights:
---Active employees are 3210 in numbers they recorded 3.470000 average performance
---Retired employees are 208, they recorded 3.410000 average performance
---Terminated employees are	445, they recorded 3.380000 average performance
---Resigned	employees are 1137,they recorded 3.350000 average performance

/* ============================================================
   9. DEPARTMENT DISTRIBUTION OF THE 100 LOWEST PERFORMERS
   ============================================================ */
WITH LowestPerformers AS
    (SELECT TOP 100
        Employee_ID,
        Department,
        Performance_Score,
        Monthly_Salary_NGN,
        Absenteeism_Days,
        Turnover_Status
    FROM Meridian
    ORDER BY Performance_Score ASC)
SELECT
    Department,
    COUNT(*) AS Low_Performer_Count
FROM LowestPerformers
GROUP BY Department
ORDER BY Low_Performer_Count DESC;
---Insights
---Sales is highly represented among the lowest-performing employees

/* ============================================================
   10. LOW PERFORMERS BY TURNOVER STATUS
   ============================================================ */
SELECT
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END AS Employee_Status,
    COUNT(*) AS Employee_Count,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage
FROM Meridian
WHERE Performance_Score < 3.4
GROUP BY
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END;
---Insights
---1414	(61.83%) of the low-performing employees are active
---873 (38.17%) of the low-performing employees are not active

/* ============================================================
   BUSINESS INSIGHTS
   ============================================================

   1. Overall average employee performance is approximately 3.43.

   2. Human Resources records the highest average performance,
      while Sales records the lowest average performance among
      the identified departments.

   3. Employees with performance scores below 3.4 are classified
      as Low Performers.

   4. Performance varies across departments and job levels,
      providing areas for further investigation.

   5. Low-performing employees should be examined alongside
      salary, absenteeism and turnover status to identify
      potentially important workforce patterns.

   6. Descriptive relationships do not establish causation.
      Statistical tests are therefore performed separately in
      06_Statistical_Business_Analysis.sql.

   7. Negative performance values require validation if the
      organization's intended performance scale is 0–5.
   ============================================================ */
