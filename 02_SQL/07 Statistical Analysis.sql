/* ============================================================
   MERIDIAN HR ANALYTICS PROJECT
   File: 06_Statistical_Business_Analysis.sql

   Purpose:
   Conduct statistical and business analysis to determine
   whether observed differences and relationships in the
   workforce data are statistically significant.

   Statistical Methods:
   - Independent-samples T-tests
   - One-way ANOVA
   - Chi-square test of independence
   - Pearson correlation
   - Multi-factor descriptive analysis

   Significance Level:
   α = 0.05

   Interpretation Rule:
   p-value < 0.05  → Reject H0
   p-value >= 0.05 → Fail to reject H0

   Important:
   Statistical significance does not automatically imply
   practical significance or causation.
   ============================================================ */

   /* ============================================================
   1. STATISTICAL SIGNIFICANCE LEVEL
   ============================================================ */

-- Significance level:
-- α = 0.05

-- If p-value < 0.05:
-- Reject H0

-- If p-value >= 0.05:
-- Fail to reject H0

/* ============================================================
   2. SALARY BY TURNOVER GROUP
   ============================================================ */
/* Research Question: 
Does average salary differ between employees who stayed and employees who left?

Hypotheses
H0: There is no significant difference in mean salary between employees who remained and employees who left.
H1: There is a significant difference in mean salary between the two groups. */
SELECT
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END AS Employee_Group,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary
FROM Meridian
GROUP BY
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END;

/* ============================================================
   3. PERFORMANCE BY TURNOVER 
   ============================================================ */
/* Research question:
Does average performance differ between employees who stayed and employees who left?

Hypotheses
H0: There is no significant difference in mean performance between employees who remained and employees who left.
H1: There is a significant difference in mean performance between the two groups. */
SELECT
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END AS Employee_Group,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Performance_Score), 3) AS Average_Performance
FROM Meridian
GROUP BY
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END;

/* ============================================================
   4. ABSENTEEISM BY TURNOVER GROUP
   ============================================================ */
/* Research question:
Does average absenteeism differ between active and turnover employees?

Hypotheses
H0: There is no significant difference in mean absenteeism between employees who remained and employees who left.
H1: There is a significant difference in mean absenteeism between the two groups. */
SELECT
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END AS Employee_Group,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Absenteeism_Days), 2) AS Average_Absenteeism
FROM Meridian
GROUP BY
    CASE
        WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
            THEN 'Active'
        ELSE 'Turnover'
    END;

/* ============================================================
   5. SALARY BY DEPARTMENT — ANOVA DATA
   ============================================================ */
/* Research questions:
Does mean salary differ across departments

H0: Mean salary is equal across all departments.
H1: At least one department has a different mean salary. */
SELECT
    Department,
    AVG(Monthly_Salary_NGN)
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department;

/* ============================================================
   6. PERFORMANCE BY DEPARTMENT — ANOVA DATA
   ============================================================ */
/* Research question:
Does mean performance differ across departments?

H0: Mean performance is equal across departments.
H1: At least one department has a different mean performance. */

SELECT
    Department,
    AVG (Performance_Score)
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department;

/* ============================================================
   7. ABSENTEEISM BY DEPARTMENT — ANOVA DATA
   ============================================================ */
/* Research question:
Does mean absenteeism differ across departments?

Hypotheses
H0: Mean absenteeism is equal across departments.
H1: At least one department has a different mean absenteeism. */
SELECT
    Department,
    AVG (Absenteeism_Days)
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department;
--There is insufficient statistical evidence to conclude that mean absenteeism differs across departments.

/* ============================================================
   8. DEPARTMENT × TURNOVER CONTINGENCY TABLE
   ============================================================ */
/* Research question:
Is there a significant association between department and turnover status?

Hypotheses
H0: Department and turnover status are independent.
H1: Department and turnover status are associated. */
SELECT
    Department,
    SUM(
        CASE
            WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
                THEN 1
            ELSE 0
        END
    ) AS Active_Employees,
    SUM(
        CASE
            WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) <> 'active'
                THEN 1
            ELSE 0
        END
    ) AS Turnover_Employees
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department
ORDER BY Department;

/* ============================================================
   9. SALARY × PERFORMANCE CORRELATION
   ============================================================ */
/*Research question:
Is there a linear relationship between salary and performance?

Hypotheses
H0: There is no significant relationship between employee salary and performance score.
H1: There is a significant relationship between employee salary and performance score. */
SELECT
(COUNT(*) * SUM(CAST(Monthly_Salary_NGN AS FLOAT) * CAST(Performance_Score AS FLOAT))
    - SUM(CAST(Monthly_Salary_NGN AS FLOAT)) * SUM(CAST(Performance_Score AS FLOAT)))
/
SQRT(
(COUNT(*) * SUM(POWER(CAST(Monthly_Salary_NGN AS FLOAT),2))
    - POWER(SUM(CAST(Monthly_Salary_NGN AS FLOAT)),2))
*
(COUNT(*) * SUM(POWER(CAST(Performance_Score AS FLOAT),2))
    - POWER(SUM(CAST(Performance_Score AS FLOAT)),2))
) AS Correlation
FROM Meridian;
/* Insight: 
0.2431 is positive but close to "0". it indicate weak positive relationship 
Which means there is almost no relationship  between Performance and Salary
Change in Salary are not meaningfully associated with change in Performance. */

/* ============================================================
   10. SALARY × ABSENTEEISM CORRELATION
   ============================================================ */
/* Research question:
Is there a linear relationship between salary and absenteeism?

H0: There is no significant relationship between employee salary and absenteeism.
H1: There is a significant relationship between employee salary and absenteeism. */
SELECT
(COUNT(*) * SUM(CAST(Monthly_Salary_NGN AS FLOAT) * CAST(Absenteeism_Days AS FLOAT))
    - SUM(CAST(Monthly_Salary_NGN AS FLOAT)) * SUM(CAST(Absenteeism_Days AS FLOAT)))
/
SQRT(
(COUNT(*) * SUM(POWER(CAST(Monthly_Salary_NGN AS FLOAT),2))
    - POWER(SUM(CAST(Monthly_Salary_NGN AS FLOAT)),2))
*
(COUNT(*) * SUM(POWER(CAST(Absenteeism_Days AS FLOAT),2))
    - POWER(SUM(CAST(Absenteeism_Days AS FLOAT)),2))
) AS Correlation
FROM Meridian;
/* Insight: 
0.0125 is positive but close to "0". it indicate weak positive relationship 
Which means there is almost no relationship  between Absenteeism and Salary
Change in Salary are not meaningfully associated with change in Absenteeism */

/* ============================================================
   11. PERFORMANCE × ABSENTEEISM CORRELATION
   ============================================================ */
/*
Research Questions:
Is there a linear relationship between performance and absenteeism?

H0: There is no significant relationship between employee performance and absenteeism.
H1: There is a significant relationship between employee performance and absenteeism. */
SELECT
(COUNT(*) * SUM(CAST(Absenteeism_Days AS FLOAT) * CAST(Performance_Score AS FLOAT))
    - SUM(CAST(Absenteeism_Days AS FLOAT)) * SUM(CAST(Performance_Score AS FLOAT)))
/
SQRT(
(COUNT(*) * SUM(POWER(CAST(Absenteeism_Days AS FLOAT),2))
    - POWER(SUM(CAST(Absenteeism_Days AS FLOAT)),2))
*
(COUNT(*) * SUM(POWER(CAST(Performance_Score AS FLOAT),2))
    - POWER(SUM(CAST(Performance_Score AS FLOAT)),2))
) AS Correlation
FROM Meridian;
/* Insight: 
0.0118 is positive but very cose to "0". it indicate weak positive relationship 
Which means there is almost no relationship  between absenteeism and performance
Change in performance are not meaningfully associated with change in absenteeism */

/* ============================================================
   12. STATISTICAL RESULTS SUMMARY
   ============================================================

   Test                              P-value          Decision
   ------------------------------------------------------------
   Salary vs Turnover               0.45725         Fail to reject
   Performance vs Turnover          4.65582E-05     Reject H0
   Absenteeism vs Turnover          0.092112855     Fail to reject

   Salary by Department ANOVA       5.30107E-31     Reject H0
   Performance by Department ANOVA  1.38E-72        Reject H0
   Absenteeism by Department ANOVA  0.799883        Fail to reject H0

   Department vs Turnover Chi²      9.0175E-27      Reject H0

   Salary vs Performance            362E-68         Significant
   Salary vs Absenteeism            0.3783          Not significant     
   Performance vs Absenteeism       0.4054          Not significant   

   Significance level: α = 0.05
   ============================================================ */

/* ============================================================
   13. MULTI-FACTOR EMPLOYEE ANALYSIS
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary,
    ROUND(AVG(Performance_Score), 2) AS Average_Performance,
    ROUND(AVG(Absenteeism_Days), 2) AS Average_Absenteeism,
    SUM(
        CASE
            WHEN Performance_Score < 3.4
             AND Absenteeism_Days > 10
            THEN 1
            ELSE 0
        END
    ) AS Low_Performance_High_Absenteeism,
    SUM(
        CASE
            WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) <> 'active'
            THEN 1
            ELSE 0
        END
    ) AS Turnover_Count
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department
ORDER BY Turnover_Count DESC;

/* ============================================================
   14. DEPARTMENT WORKFORCE PROFILE
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary,
    ROUND(AVG(Performance_Score), 2) AS Average_Performance,
    ROUND(AVG(Absenteeism_Days), 2) AS Average_Absenteeism,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN LOWER(LTRIM(RTRIM(Turnover_Status))) <> 'active'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS Turnover_Rate
FROM Meridian
WHERE Department <> 'Unknown'
GROUP BY Department
ORDER BY Turnover_Rate DESC;

/* ============================================================
   STATISTICAL INTERPRETATION
   ============================================================

   1. SALARY BY DEPARTMENT
      The ANOVA produced F = 37.585727 and
      p = 5.30107E-31.

      Since p < 0.05, reject H0.

      Conclusion:
      There is statistically significant evidence that
      mean salary differs across departments.


   2. ABSENTEEISM BY DEPARTMENT
      ANOVA p = 0.799883.

      Since p > 0.05, fail to reject H0.

      Conclusion:
      There is insufficient evidence to conclude that
      mean absenteeism differs across departments.

   3. PERFORMANCE BY DEPARTMENT
      The ANOVA produced F = 88.40088 and
      p = 1.38E-72.

      Since p < 0.05, reject H0.

      Conclusion:
      There is statistically significant evidence that
      mean performance differs across departments.

   4. DEPARTMENT AND TURNOVER
      Chi-square p = 9.0175E-27.

      Since p < 0.05, reject H0.

      Conclusion:
      There is statistically significant evidence of an
      association between department and turnover status.


   5. SALARY AND ABSENTEEISM
      Correllation analysis p = 0.378265692.

      Since p > 0.05, fail to reject H0.

      Conclusion:
      There is insufficient evidence of a statistically
      significant relationship between salary and absenteeism.

    
   6. SALARY AND PERFORMANCE
      Correllation analysis p = 3.62E-68

      Since p < 0.05, fail to reject H0.

      Conclusion:
      There is statistically significant evidence of an
      association between salary and performance

   7. PERFORMANCE AND ABSENTEEISM
      Correlation analysis p = 0.405435462.

      Since p > 0.05, fail to reject H0.

      Conclusion:
      There is insufficient evidence of a statistically
      significant relationship between performance and
      absenteeism.

   ============================================================ */

/* ============================================================
   BUSINESS RECOMMENDATIONS
   ============================================================

   1. Investigate salary differences across departments because
      the ANOVA indicates statistically significant differences.

   2. Investigate department-level turnover because the
      chi-square test indicates an association between department
      and turnover.

   3. Avoid implementing department-wide absenteeism interventions
      solely on the basis of average differences because the
      absenteeism ANOVA was not statistically significant.

   4. Review employees with both low performance and high
      absenteeism as a potentially important workforce segment.

   5. Use further analysis to determine whether salary,
      performance, absenteeism and turnover patterns remain
      consistent after controlling for other employee factors.

   6. Statistical significance should be combined with business
      relevance before management decisions are made.

   ============================================================ */
