/* ============================================================
   MERIDIAN HR ANALYTICS PROJECT
   File: 07_Risk_Analysis.sql

   Purpose:
   Identify employees who may require HR intervention based on
   salary, performance and absenteeism indicators.

   Risk Factors:
   - Salary below ₦257,000
   - Performance score below 3.4
   - Absenteeism above 10 days

   Scoring:
   - Each risk factor = 2 points

   Risk Categories:
   - 0–2 points  = Low Risk
   - 3–4 points  = Medium Risk
   - 5–6 points  = High Risk

   Important:
   This is an analytical risk-screening model and should not
   be interpreted as a prediction of employee behavior or
   termination.
   ============================================================ */--- RISK PROFILLING

/* ============================================================
   1. EMPLOYEE RISK SCORE
   ============================================================ */
WITH RiskScore AS
(
    SELECT
        Employee_ID,
        Department,
        Monthly_Salary_NGN,
        Performance_Score,
        Absenteeism_Days,
        Turnover_Status,
        (CASE
                WHEN Monthly_Salary_NGN < 257000
                    THEN 2
                ELSE 0
            END
            +
            CASE
                WHEN Performance_Score < 3.4
                    THEN 2
                ELSE 0
            END
            +
            CASE
                WHEN Absenteeism_Days > 10
                    THEN 2
                ELSE 0
            END
        ) AS Risk_Score
    FROM Meridian)
SELECT *
FROM RiskScore;

/* ============================================================
   2. EMPLOYEE RISK CATEGORY
   ============================================================ */
WITH RiskScore AS
(SELECT
        Employee_ID,
        Department,
        Monthly_Salary_NGN,
        Performance_Score,
        Absenteeism_Days,
        Turnover_Status,
            (CASE
                WHEN Monthly_Salary_NGN < 257000 THEN 2
                ELSE 0
            END
            +
            CASE
                WHEN Performance_Score < 3.4 THEN 2
                ELSE 0
            END
            +
            CASE
                WHEN Absenteeism_Days > 10 THEN 2
                ELSE 0
            END
        ) AS Risk_Score
    FROM Meridian)
SELECT
    Employee_ID,
    Department,
    Monthly_Salary_NGN,
    Performance_Score,
    Absenteeism_Days,
    Turnover_Status,
    Risk_Score,
    CASE
        WHEN Risk_Score >= 5
            THEN 'High Risk'
        WHEN Risk_Score BETWEEN 3 AND 4
            THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Category
FROM RiskScore;

/* ============================================================
   3. RISK SCORE WITH INDIVIDUAL RISK FACTORS
   ============================================================ */
WITH RiskScore AS
(SELECT
        Employee_ID,
        Department,
        Monthly_Salary_NGN,
        Performance_Score,
        Absenteeism_Days,
        Turnover_Status,
        CASE
            WHEN Monthly_Salary_NGN < 257000
                THEN 2
            ELSE 0
        END AS Salary_Risk_Points,
        CASE
            WHEN Performance_Score < 3.4
                THEN 2
            ELSE 0
        END AS Performance_Risk_Points,
        CASE
            WHEN Absenteeism_Days > 10
                THEN 2
            ELSE 0
        END AS Absenteeism_Risk_Points
    FROM Meridian)
SELECT
    Employee_ID,
    Department,
    Monthly_Salary_NGN,
    Performance_Score,
    Absenteeism_Days,

    Salary_Risk_Points,
    Performance_Risk_Points,
    Absenteeism_Risk_Points,

    Salary_Risk_Points
    + Performance_Risk_Points
    + Absenteeism_Risk_Points AS Risk_Score
FROM RiskScore;

DROP VIEW vw_Employee_Risk;

/* ============================================================
   4. CREATE EMPLOYEE RISK VIEW
   ============================================================ */
CREATE VIEW vw_Employee_Risk
AS
WITH RiskScore AS
    (SELECT
        Employee_ID,
        Department,
        Monthly_Salary_NGN,
        Performance_Score,
        Absenteeism_Days,
        Turnover_Status,
        CASE
            WHEN Monthly_Salary_NGN < 257000
                THEN 2
            ELSE 0
        END AS Salary_Risk_Points,
        CASE
            WHEN Performance_Score < 3.4
                THEN 2
            ELSE 0
        END AS Performance_Risk_Points,
        CASE
            WHEN Absenteeism_Days > 10
                THEN 2
            ELSE 0
        END AS Absenteeism_Risk_Points
    FROM Meridian)
SELECT
    Employee_ID,
    Department,
    Monthly_Salary_NGN,
    Performance_Score,
    Absenteeism_Days,
    Turnover_Status,

    Salary_Risk_Points,
    Performance_Risk_Points,
    Absenteeism_Risk_Points,

    Salary_Risk_Points
    + Performance_Risk_Points
    + Absenteeism_Risk_Points AS Risk_Score,
    CASE
        WHEN
            Salary_Risk_Points
            + Performance_Risk_Points
            + Absenteeism_Risk_Points >= 5
            THEN 'High Risk'
        WHEN
            Salary_Risk_Points
            + Performance_Risk_Points
            + Absenteeism_Risk_Points BETWEEN 3 AND 4
            THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Category
FROM RiskScore;

/* ============================================================
   5. RISK CATEGORY DISTRIBUTION AND PERCENTAGE
   ============================================================ */
SELECT
    Risk_Category,
    COUNT(*) AS Employee_Count,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage_of_Employees
FROM vw_Employee_Risk
GROUP BY Risk_Category
ORDER BY
    CASE Risk_Category
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk' THEN 3
    END;

   /* ============================================================
   6. HIGH-RISK EMPLOYEES
   ============================================================ */
SELECT
    Employee_ID,
    Department,
    Monthly_Salary_NGN,
    Performance_Score,
    Absenteeism_Days,
    Risk_Score,
    Risk_Category
FROM vw_Employee_Risk
WHERE Risk_Category = 'High Risk'
ORDER BY Risk_Score DESC;


/* ============================================================
   7. HIGH-RISK RATE BY DEPARTMENT
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Total_Employees,
    SUM(
        CASE
            WHEN Risk_Category = 'High Risk'
                THEN 1
            ELSE 0
        END
    ) AS High_Risk_Employees,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Risk_Category = 'High Risk'
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS High_Risk_Percentage
FROM vw_Employee_Risk
WHERE Department <> 'Unknown'
GROUP BY Department
ORDER BY High_Risk_Percentage DESC;

/* ============================================================
   8. ACTIVE EMPLOYEES AT HIGH RISK
   ============================================================ */
SELECT
    Employee_ID,
    Department,
    Monthly_Salary_NGN,
    Performance_Score,
    Absenteeism_Days,
    Risk_Score,
    Risk_Category
FROM vw_Employee_Risk
WHERE LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
  AND Risk_Category IN ('High Risk')
ORDER BY
    Risk_Score DESC,
    Department;

/* ============================================================
   9. ACTIVE HIGH-RISK EMPLOYEES BY DEPARTMENT
   ============================================================ */
SELECT
    Department,
    COUNT(*) AS Active_High_Risk_Employees
FROM vw_Employee_Risk
WHERE LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
  AND Risk_Category = 'High Risk'
  AND Department <> 'Unknown'
GROUP BY Department
ORDER BY Active_High_Risk_Employees DESC;

/* ============================================================
   10. RISK DRIVER COMPARISON
   ============================================================ */
SELECT
    SUM(CASE WHEN Salary_Risk_Points = 2
             THEN 1 ELSE 0 END) AS Salary_Risk_Employees,
    SUM(CASE WHEN Performance_Risk_Points = 2
             THEN 1 ELSE 0 END) AS Performance_Risk_Employees,
    SUM(CASE WHEN Absenteeism_Risk_Points = 2
             THEN 1 ELSE 0 END) AS Absenteeism_Risk_Employees
FROM vw_Employee_Risk;

/* ============================================================
   11. RISK BY JOB LEVEL
   ============================================================ */
SELECT
    M.Job_Level,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(CAST(R.Risk_Score AS DECIMAL(10,2))), 2) AS Average_Risk_Score
FROM vw_Employee_Risk R
JOIN Meridian M
    ON R.Employee_ID = M.Employee_ID
WHERE M.Job_Level IS NOT NULL
GROUP BY M.Job_Level
ORDER BY Average_Risk_Score DESC;

/* ============================================================
   12. ACTIVE EMPLOYEE RISK PROFILE
   ============================================================ */
SELECT
    Risk_Category,
    COUNT(*) AS Active_Employees,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage
FROM vw_Employee_Risk
WHERE LOWER(LTRIM(RTRIM(Turnover_Status))) = 'active'
GROUP BY Risk_Category
ORDER BY
    CASE Risk_Category
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk' THEN 3
    END;

/* ============================================================
   13. RISK CATEGORY BY TURNOVER STATUS
   ============================================================ */
SELECT
    Risk_Category,
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
FROM vw_Employee_Risk
GROUP BY Risk_Category
ORDER BY
    CASE Risk_Category
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk' THEN 3
    END;

/* ============================================================
   14. RISK MODEL VALIDATION
   ============================================================ */
SELECT
    MIN(Risk_Score) AS Minimum_Risk_Score,
    MAX(Risk_Score) AS Maximum_Risk_Score,
    COUNT(*) AS Total_Employees,
    SUM(
        CASE
            WHEN Risk_Category = 'High Risk'
                THEN 1
            ELSE 0
        END
    ) AS High_Risk_Count,
    SUM(
        CASE
            WHEN Risk_Category = 'Medium Risk'
                THEN 1
            ELSE 0
        END
    ) AS Medium_Risk_Count,

    SUM(
        CASE
            WHEN Risk_Category = 'Low Risk'
                THEN 1
            ELSE 0
        END
    ) AS Low_Risk_Count
FROM vw_Employee_Risk;

/* ============================================================
   15. RISK CATEGORY VALIDATION
   ============================================================ */
SELECT
    Risk_Score,
    Risk_Category,
    COUNT(*) AS Employee_Count
FROM vw_Employee_Risk
GROUP BY
    Risk_Score,
    Risk_Category
ORDER BY Risk_Score;

/* ============================================================
   BUSINESS INSIGHTS
   ============================================================
   1. The risk model combines salary, performance and
      absenteeism indicators into a single employee risk score.

   2. Employees with multiple risk indicators receive higher
      risk scores and require greater attention.

   3. Department-level risk percentages should be used rather
      than raw counts when comparing departments of different
      sizes.

   4. Active high-risk employees represent the most actionable
      population for proactive HR intervention.

   5. Risk drivers should be examined individually to determine
      whether salary, performance or absenteeism contributes
      most frequently to employee risk classification.

   6. The model is a screening framework and should not be
      interpreted as a causal or predictive model of turnover.

   7. HR decisions should combine risk scores with employee
      context, managerial review and additional evidence.

   ============================================================ */
