/* ============================================================
   MERIDIAN HR ANALYTICS PROJECT
   File: 05_Absenteeism_Analysis.sql

   Purpose:
   Analyze employee absenteeism patterns and identify
   workforce groups with higher absence levels.

   Key Areas:
   - Overall absenteeism profile
   - Absenteeism by department
   - High and low absenteeism
   - Absenteeism by job level
   - Absenteeism by salary band
   - Absenteeism by turnover status
   - Employees with high absenteeism
   - Performance and absenteeism patterns
   ============================================================ */

   /* ============================================================
   1. OVERALL ABSENTEEISM PROFILE
   ============================================================ */

SELECT
    COUNT(*) AS Total_Employees,
    ROUND(AVG(Absenteeism_Days), 2) AS Average_Absenteeism_Days,
    MIN(Absenteeism_Days) AS Minimum_Absenteeism_Days,
    MAX(Absenteeism_Days) AS Maximum_Absenteeism_Days
FROM Meridian;
/*
Insight:
Employees record between 0 and 40 absenteeism days,
with an overall average of approximately 10 days. */

/* ============================================================
   2. AVERAGE ABSENTEEISM BY DEPARTMENT
   ============================================================ */
SELECT
    Department,
    ROUND(AVG(Absenteeism_Days), 2) AS Average_Abs 
FROM Meridian
GROUP BY
    Department
ORDER BY
    Average_Abs;
/*
Insights:
Risk and Compliance recorded the lowest	(9 days)
While other departments recorded 10 days each. */

/* ============================================================
   3. HIGH ABSENTEEISM BY DEPARTMENT
   Absenteeism_Days > 10
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Total_Employees,
    SUM(
        CASE
            WHEN Absenteeism_Days > 10 THEN 1
            ELSE 0
        END
    ) AS High_Absenteeism_Count,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Absenteeism_Days > 10 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS High_Absenteeism_Percentage
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department
ORDER BY High_Absenteeism_Percentage DESC;
/*
Insights
Information Technology recorded 269	(37.26%)
Human Resources recorded 263 (36.48%)
Risk and Compliance	recorded 356 (36.22%)
Sales recorded 415 (35.62%)
Operations recorded 417	(34.78%) */

/* ============================================================
   4. LOW ABSENTEEISM BY DEPARTMENT
   Absenteeism_Days <= 10
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Total_Employees,
    SUM(
        CASE
            WHEN Absenteeism_Days <= 10 THEN 1
            ELSE 0
        END
    ) AS Low_Absenteeism_Count,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Absenteeism_Days <= 10 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Low_Absenteeism_Percentage
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department
ORDER BY Low_Absenteeism_Percentage DESC;
/*
Insights
Information Technology recorded 453	(62.74%)
Human Resources recorded 458 (63.52.48%)
Risk and Compliance	recorded 627 (63.78%)
Sales recorded 750 (64.38%)
Operations recorded 782 (65.22%) */

/* ============================================================
   5. ABSENTEEISM BY JOB LEVEL
   ============================================================ */
SELECT
    Job_Level,
    ROUND(AVG(Absenteeism_Days), 2) AS Average_Abs   
FROM Meridian
GROUP BY
    Job_Level
ORDER BY
    Average_Abs;
--- Insights:
--- Junior, Manager	and Senior level recorded 9 absenteeism days
--- Mid-level recorded 10 days
--- Director recorded 11 days

/* ============================================================
   6. ABSENTEEISM BY SALARY BAND
   ============================================================ */
SELECT
    CASE
        WHEN Monthly_Salary_NGN < 100000
            THEN 'Poor Salary'
        WHEN Monthly_Salary_NGN BETWEEN 100000 AND 257000
            THEN 'Low Salary'
        WHEN Monthly_Salary_NGN BETWEEN 257001 AND 357000
            THEN 'Below Average'
        WHEN Monthly_Salary_NGN BETWEEN 357001 AND 557000
            THEN 'Above Average'
        WHEN Monthly_Salary_NGN > 557000
            THEN 'High Salary'
        ELSE 'Unknown'
    END AS Salary_Band,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Absenteeism_Days), 2) AS Average_Absenteeism_Days
FROM Meridian
GROUP BY
    CASE
        WHEN Monthly_Salary_NGN < 100000
            THEN 'Poor Salary'
        WHEN Monthly_Salary_NGN BETWEEN 100000 AND 257000
            THEN 'Low Salary'
        WHEN Monthly_Salary_NGN BETWEEN 257001 AND 357000
            THEN 'Below Average'
        WHEN Monthly_Salary_NGN BETWEEN 357001 AND 557000
            THEN 'Above Average'
        WHEN Monthly_Salary_NGN > 557000
            THEN 'High Salary'
        ELSE 'Unknown'
    END
ORDER BY Average_Absenteeism_Days DESC;
/*
Insights
Poor salary recorded the lowest average absenteeism */

/* ============================================================
   7. ABSENTEEISM BY TURNOVER STATUS
   ============================================================ */
SELECT
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END AS Employee_Status,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Absenteeism_Days), 2) AS Average_Absenteeism_Days
FROM Meridian
GROUP BY
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END
ORDER BY Average_Absenteeism_Days DESC;
/*
Insights
Active employees recorded a ower average absenteeism days */

/* ============================================================
   8. TOP 100 EMPLOYEES BY ABSENTEEISM
   ============================================================ */
SELECT TOP 100
    Employee_ID,
    Department,
    Job_Level,
    Absenteeism_Days,
    Performance_Score,
    Monthly_Salary_NGN,
    Turnover_Status
FROM Meridian
ORDER BY Absenteeism_Days DESC;

/* ============================================================
   9. DEPARTMENT DISTRIBUTION OF TOP 100 ABSENTEEISM
   ============================================================ */
WITH TopAbsenteeism AS
(
    SELECT TOP 100
        Employee_ID,
        Department,
        Absenteeism_Days,
        Performance_Score,
        Monthly_Salary_NGN,
        Turnover_Status
    FROM Meridian
    ORDER BY Absenteeism_Days DESC)
SELECT
    Department,
    COUNT(*) AS Employee_Count
FROM TopAbsenteeism
GROUP BY Department
ORDER BY Employee_Count DESC;
/*
Insight
Sales recorded 31
Operations recoded 24
Risk and Compliance recorded 15
Information Technology recorded 14
Human Resources	13
Unknown recorded 3 */

/* ============================================================
   10. ABSENTEEISM BY PERFORMANCE CATEGORY
   ============================================================ */
SELECT
    CASE
        WHEN Performance_Score < 3.4
            THEN 'Low Performer'
        ELSE 'High Performer'
    END AS Performance_Category,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Absenteeism_Days), 2) AS Average_Absenteeism_Days
FROM Meridian
GROUP BY
    CASE
        WHEN Performance_Score < 3.4
            THEN 'Low Performer'
        ELSE 'High Performer'
    END
ORDER BY Average_Absenteeism_Days DESC;
/*
Insights
there is no difference in average absenteeism days across performance categories */

/* ============================================================
   11. LOW PERFORMANCE + HIGH ABSENTEEISM BY DEPARTMENT
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Employee_Count
FROM Meridian
WHERE Performance_Score < 3.4
  AND Absenteeism_Days > 10
GROUP BY Department
ORDER BY Employee_Count DESC;

/* ============================================================
   12. LOW PERFORMANCE + HIGH ABSENTEEISM BY DEPARTMENT
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Total_Employees,
    SUM(
        CASE
            WHEN Performance_Score < 3.4
             AND Absenteeism_Days > 10
            THEN 1
            ELSE 0
        END
    ) AS Low_Performance_High_Absenteeism,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Performance_Score < 3.4
                 AND Absenteeism_Days > 10
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Percentage
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department
ORDER BY Percentage DESC;
/*
Insights
265(22.75%) employees from sales department has low performance and high absenteeism
Operations	has 194(16.18%)
Risk and Compliance	has 133(13.53%)
Information Technology	has 105(14.54%)
Human Resources	has 101(14.01%) */

/* ============================================================
   13. HIGH ABSENTEEISM AND TURNOVER
   ============================================================ */
SELECT
    Employee_ID,
    Department,
    Job_Level,
    Absenteeism_Days,
    Performance_Score,
    Monthly_Salary_NGN,
    Turnover_Status
FROM Meridian
WHERE Absenteeism_Days > 10
  AND LOWER(LTRIM(RTRIM(Turnover_Status))) <> 'active'
ORDER BY Absenteeism_Days DESC;
/*
Insight
657 employees with high absenteeism are not active
*/

/* ============================================================
   14. HIGH ABSENTEEISM AND TURNOVER BY DEPARTMENT
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS High_Absenteeism_Turnover_Count
FROM Meridian
WHERE Absenteeism_Days > 10
  AND LOWER(LTRIM(RTRIM(Turnover_Status))) <> 'active'
  AND Department <> 'Unknown'
GROUP BY Department
ORDER BY High_Absenteeism_Turnover_Count DESC;
/*
Insights
212 employees is sales department with high absenteeism are not active
Operations	recorded 134
Information recorded Technology	99
Risk and Compliance	recorded 99
Human Resources recorded 93

/* ============================================================
   BUSINESS INSIGHTS
   ============================================================

   1. Average absenteeism across the workforce is approximately
      10.13 days.

   2. Absenteeism varies descriptively across departments,
      job levels and salary bands.

   3. Employees with performance scores below 3.4 can be
      examined alongside absenteeism to identify workforce
      patterns.

   4. Employees with both low performance and high absenteeism
      represent a group that may warrant further HR review.

   5. Sales has the highest number of employees combining
      low performance and high absenteeism in the current
      analysis. Department size should be considered when
      interpreting this count.

   6. Statistical tests are required before concluding that
      differences or relationships are statistically significant.

   7. Absenteeism should not be interpreted as a cause of poor
      performance or turnover based solely on these descriptive
      analyses.
   ============================================================ */

