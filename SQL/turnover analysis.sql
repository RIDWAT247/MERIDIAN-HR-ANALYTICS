/* ============================================================
   MERIDIAN HR ANALYTICS
   02 - TURNOVER ANALYSIS
   ============================================================

   Objective:
   Analyze employee turnover across demographic, employment,
   compensation, job-level, and tenure groups.

   Business Question:
   Which employee groups experience the highest turnover?

   Turnover Definition:
   Employees with Turnover_Status <> 'Active' are classified
   as employees who have left the organization.

   Active employees:
   Turnover_Status = 'Active'

   Author: [Your Name]
============================================================ */

USE meridian_hr;

/* ============================================================
   1. OVERALL TURNOVER
   Purpose:
   Determine the total workforce, number of employees who left,
   number of active employees, and overall turnover rate.
============================================================ */
SELECT
    COUNT(*) AS Total_Employees,
    SUM(
        CASE
            WHEN Turnover_Status <> 'Active' THEN 1
            ELSE 0
        END
    ) AS Employees_Left,
    SUM(
        CASE
            WHEN Turnover_Status = 'Active' THEN 1
            ELSE 0
        END
    ) AS Active_Employees,
    ROUND(
        SUM(
            CASE
                WHEN Turnover_Status <> 'Active' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Overall_Turnover_Rate
FROM Meridian;
---Insights:
--- 1.  1790 out of the 5000 employees left
--- 2.  3210 employees are active
--- 3.  35.80% is the rate of turnover 

/* ============================================================
   2. TURNOVER BY DEPARTMENT
   Purpose:
   Identify departments with the highest employee turnover.
============================================================ */
SELECT
    Department,
    COUNT(*) AS Total_Employees,
    SUM(CASE 
            WHEN Turnover_Status <> 'Active' 
            THEN 1 ELSE 0 
        END) AS Employees_Left,
    ROUND(
        SUM(CASE 
                WHEN Turnover_Status <> 'Active' 
                THEN 1 ELSE 0 
            END) * 100.0 / COUNT(*),2
    ) AS Turnover_Rate_Percentage
FROM Meridian
GROUP BY Department
ORDER BY Turnover_Rate_Percentage DESC;
--- Insights:
--- Sales recorded the highest turnover rate among the departments, 
--- indicating that retention challenges may be particularly concentrated within the department.
--- Information Technology is the second highest, followed closely by Operations
--- Human Resources is the fourth and Risk and Compliance is the least

/* ============================================================
   3. TURNOVER BY SALARY BAND
   Purpose:
   Determine whether turnover is concentrated among
   lower-paid employees.
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
    SUM(CASE 
            WHEN Turnover_Status <> 'Active'
            THEN 1 ELSE 0
        END) AS Employees_Left,
    ROUND(
        SUM(CASE 
                WHEN Turnover_Status <> 'Active'
                THEN 1 ELSE 0
            END) * 100.0 / COUNT(*),2
    ) AS Turnover_Rate
FROM Meridian
GROUP BY
    CASE
        WHEN Monthly_Salary_NGN < 100000 THEN 'Poor Salary'
        WHEN Monthly_Salary_NGN BETWEEN 100000 AND 257000 THEN 'Low Salary'
        WHEN Monthly_Salary_NGN BETWEEN 257001 AND 357000 THEN 'Below Average'
        WHEN Monthly_Salary_NGN BETWEEN 357001 AND 557000 THEN 'Above Average'
        ELSE 'High Salary'
    END
ORDER BY Turnover_Rate DESC;
--- Insights:
--- Poor Salary Band employees has the highest rate of turnover
--- However, other salary band also leave. 
--- Above average Salary band has turnover rate more than below average salary band employees
--- And low Salary Band turnover rate is smaller than both below and above average salary band
--- while High Salary has the lowest turnover rate.

/* ============================================================
   4. TURNOVER BY JOB LEVEL
   Purpose:
   Identify the job levels experiencing the highest turnover.
============================================================ */
SELECT
    Job_Level,
    COUNT(*) AS Total_Employees,
    SUM(CASE 
            WHEN Turnover_Status <> 'Active' THEN 1
            ELSE 0
        END) AS Employees_Left,
    ROUND(
        SUM(CASE 
                WHEN Turnover_Status <> 'Active' THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),2
    ) AS Turnover_Rate
FROM Meridian
GROUP BY Job_Level
ORDER BY Turnover_Rate DESC;
--- Insights:
--- Mid-level employees recorded the highest turnover rate of 36.54%
--- followed closely by senior employees with 36.2%
--- Junior employees recorded 35.63%
--- Manager recorded 34.93%
--- Director is the least with 32.81%

/* ============================================================
   5. TURNOVER BY EDUCATION LEVEL
   Purpose:
   Compare turnover rates within each education group.
============================================================ */
--- Query:Count Turnover by Education level
--- Purpose: What Education level  of employees leave most
SELECT
    Education_Level,
    COUNT(*) AS Total_Employees,
    SUM(CASE 
            WHEN Turnover_Status <> 'Active'
            THEN 1
            ELSE 0
        END) AS Employees_Left,
    ROUND(
        SUM(CASE 
                WHEN Turnover_Status <> 'Active'
                THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),2
    ) AS Turnover_Rate
FROM Meridian
GROUP BY Education_Level
ORDER BY Turnover_Rate DESC;
--- Insights:
--- PhD	recorded 103 turnover 43.46%
--- MSc	recorded 438 turnover 36.99%
--- HND	recorded 334 turnover 35.01%
--- BSc	recorded 678 turnover 34.98%
--- OND	recorded 167 turnover 34.36%

/* ============================================================
   6. TURNOVER BY EMPLOYMENT TYPE
   Purpose:
   Identify whether turnover differs across employment types.
============================================================ */
SELECT
    Employment_Type,
    COUNT(*) AS Total_Employees,
    SUM(CASE 
            WHEN Turnover_Status <> 'Active'
            THEN 1 ELSE 0
        END) AS Employees_Left,
    ROUND(
        SUM(CASE 
                WHEN Turnover_Status <> 'Active'
                THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),2
    ) AS Turnover_Rate
FROM Meridian
GROUP BY Employment_Type
ORDER BY Turnover_Rate DESC;
--- Insights:
--- Contract employees has the highest turnover rate of 42.48%
--- Part-time recorded 34.36%
--- Full-time recorded 33.62%
--- Full time employees is the highest employment type

/* ============================================================
   7. TURNOVER BY GENDER
   Purpose:
   Compare turnover rates between male and female employees.
============================================================ */
SELECT
    Gender,
    COUNT(*) AS Total_Employees,
    SUM(CASE 
            WHEN Turnover_Status <> 'Active'
            THEN 1 ELSE 0
        END) AS Employees_Left,
    ROUND(
        SUM(CASE 
                WHEN Turnover_Status <> 'Active'
                THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),2
    ) AS Turnover_Rate
FROM Meridian
GROUP BY Gender
ORDER BY Turnover_Rate DESC;
--- Insights:
--- Females employees has the highest rate of turnover
--- 35.87% of Female employees left
--- 35.74% of Male employees left

/* ============================================================
   8. TURNOVER BY YEARS OF SERVICE
   Purpose:
   Determine whether turnover is concentrated at specific
   stages of employee tenure.
============================================================ */
SELECT    
    CASE
        WHEN Years_Of_Service <= 1 THEN '<1yr'
        WHEN Years_Of_Service <= 2 THEN '1-2yr'
        WHEN Years_Of_Service <= 3 THEN '2-3yr'
        WHEN Years_Of_Service <= 5 THEN '3-5yr'
        WHEN Years_Of_Service <= 10 THEN '5-10yr'
        ELSE '10yr+'
    END AS tenure_band,
    COUNT(*) AS Total_employee,
    SUM(CASE 
            WHEN Turnover_Status <> 'Active'
            THEN 1 ELSE 0
        END) AS Employees_Left,
    CAST(100.0 * SUM(CASE WHEN Turnover_Status <> 'Active' 
            THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,1)) AS Turnover_rate
FROM Meridian
GROUP BY
    CASE
        WHEN Years_Of_Service <= 1 THEN '<1yr'
        WHEN Years_Of_Service <= 2 THEN '1-2yr'
        WHEN Years_Of_Service <= 3 THEN '2-3yr'
        WHEN Years_Of_Service <= 5 THEN '3-5yr'
        WHEN Years_Of_Service <= 10 THEN '5-10yr'
        ELSE '10yr+'
    END
ORDER BY MIN(Years_Of_Service);
---Insights: 
--- Employees 5-10years tenure band recorded the highest rate of turnover
--- Followed by 3-5years
--- the early years has lesser turnover
--- All employees that has been with the company for more than 10years are still active

/* ============================================================
   9. TURNOVER STATUS DISTRIBUTION
   Purpose:
   Understand the composition of employee exits by status.
============================================================ */
SELECT
    Turnover_Status,
    COUNT(*) AS Employee_Count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage
FROM Meridian
GROUP BY Turnover_Status
ORDER BY Employee_Count DESC;
---Insights: 
--- 64.20% Active
---	22.74% Resigned
--- 8.90% Terminated
--- 4.160% Retired

/* ============================================================
   10. SALARY AND TURNOVER BY DEPARTMENT
   Purpose:
   Identify departments where compensation and turnover
   may be occurring together.
============================================================ */
SELECT
    Department,
    ROUND(AVG(Monthly_Salary_NGN), 2) AS Average_Salary,
    SUM(
        CASE
            WHEN Turnover_Status <> 'Active' THEN 1
            ELSE 0
        END
    ) AS Employees_Left,
    ROUND(
        SUM(
            CASE
                WHEN Turnover_Status <> 'Active' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Turnover_Rate
FROM Meridian
GROUP BY Department
ORDER BY
    Average_Salary DESC,
    Turnover_Rate DESC;
---Insights:
---Risk & Compliance recorded highest average salary, lowest turnover
---IT recorded high salary but relatively high turnover
---Human resources recorded medium average salary but relatively high turnover
---Operations recorded lower salary and high turnover
---Sales recorded lowest average salary and highest turnover

/* ============================================================
   11. SALARY AND TURNOVER STATUS
   Purpose:
   Compare turnover distribution within each salary band.
============================================================ */
WITH SalaryGroups AS
(SELECT CASE
            WHEN Monthly_Salary_NGN < 100000 THEN 'Poor Salary'
            WHEN Monthly_Salary_NGN BETWEEN 100000 AND 257000 THEN 'Low Salary'
            WHEN Monthly_Salary_NGN BETWEEN 257001 AND 357000 THEN 'Below Average'
            WHEN Monthly_Salary_NGN BETWEEN 357001 AND 557000 THEN 'Above Average'
            ELSE 'High Salary'
        END AS Salary_Band,
        Turnover_Status
    FROM Meridian)
SELECT
    Salary_Band,
    Turnover_Status,
    COUNT(*) AS Employee_Count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY Salary_Band),
        1
    ) AS Turnover_Rate_Percent
FROM SalaryGroups
GROUP BY
    Salary_Band,
    Turnover_Status
ORDER BY
    CASE Salary_Band
        WHEN 'Poor Salary' THEN 1
        WHEN 'Low Salary' THEN 2
        WHEN 'Below Average' THEN 3
        WHEN 'Above Average' THEN 4
        WHEN 'High Salary' THEN 5
    END,
    Turnover_Status;
--- Insights:
--- Employees earning poor salaries resigned more than others
--- Employees earning above average resigned more than those earning below average
--- Low salary earners recorded more active workers than above average salary earners
--- high salary earners recorded the highest numbers of active employees and lowest numbers of resigned employees
--- 133 out of employees earning below 100000 are active, 58 resigned,7 retired,16 terminated

/* ============================================================
   KEY BUSINESS INSIGHTS
===========================================================
1. Overall turnover:
   1,790 of 5,000 employees left the organization,
   representing approximately 35.80% turnover.

2. Department:
   Sales recorded the highest turnover rate, indicating
   a potential department-specific retention challenge.

3. Salary:
   Employees in the Poor Salary band recorded the highest
   turnover rate.

4. Job Level:
   Mid-Level employees recorded the highest turnover rate,
   followed closely by Senior-Level employees.

5. Education:
   PhD employees recorded the highest turnover rate,
   followed by MSc employees.

6. Employment Type:
   Contract employees recorded the highest turnover rate at approximately 42.48%, 
   suggesting that retention may be a particular concern among non-permanent employees.

7. Gender:
   Female employees recorded a slightly higher turnover
   rate than male employees, although the difference was small.

8. Tenure:
   Employees with 5–10 years of service recorded the
   highest turnover rate.

9. Salary + Department:
   Sales combines relatively low average salary with the
   highest turnover rate, making compensation and retention
   an area worth investigating further.
============================================================ */