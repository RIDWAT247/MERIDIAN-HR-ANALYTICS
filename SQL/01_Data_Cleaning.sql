/* ============================================================
   MERIDIAN HR ANALYTICS
   01 - DATA CLEANING
   ============================================================
   Objective:
   Prepare the Meridian HR dataset for analysis by:
   - Identifying and removing duplicates
   - Standardizing categorical variables
   - Handling missing values
   - Converting data types
   - Investigating invalid values
   - Validating the cleaned dataset

   Dataset:
   5,000 employee records

   Database:
   meridian_hr
============================================================ */

CREATE DATABASE meridian_hr;

USE meridian_hr;

/* ============================================================
   1. INITIAL DATA INSPECTION
============================================================ */
-- View the dataset
SELECT *
FROM Meridian;

-- Review available columns
SELECT TOP 10 *
FROM Meridian;

/* ============================================================
   2. DUPLICATE CHECK
============================================================ */
-- Identify employees appearing more than once 
select 
	employee_ID, employee_name, 
		count(employee_id)as dub
from Meridian
group by employee_id, employee_name
having count(*)>1
order by employee_id, employee_name;

/* ============================================================
   3. DUPLICATE REMOVAL
============================================================ */
-- Keep the first occurrence of each Employee_ID + Employee_Name
-- combination and remove subsequent duplicates.
with cte as(
	select *, 
	row_number() over(
		partition by employee_id, employee_name 
		order by employee_id)as row
		from Meridian) 
delete from cte
where row > 1

---Validate duplicate removal 
SELECT
    Employee_ID,
    Employee_Name,
    COUNT(*) AS Record_Count
FROM Meridian
GROUP BY Employee_ID, Employee_Name
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS Total_Records
FROM Meridian;
-- 5,000 records remain after duplicate removal.

/* ============================================================
   4. CATEGORICAL DATA CLEANING
   4.1 Gender
============================================================ */
-- Check gender values using case-sensitive comparison
SELECT DISTINCT
    Gender COLLATE Latin1_General_CS_AS AS Gender
FROM Meridian
ORDER BY Gender;

--standardize capitalization
UPDATE Meridian
SET Gender =
    UPPER(LEFT(Gender, 1)) +
    LOWER(SUBSTRING(Gender, 2, LEN(Gender)))
WHERE Gender IS NOT NULL;

--Validate
SELECT DISTINCT
    Gender
FROM Meridian
ORDER BY Gender;

--fill missing values in gender, use employees where the first name matches and gender already known to fill the missing ones
select a.employee_name,
	a.gender as current_gender,
	b.gender as gender_to_fill
from meridian a
join meridian b
	on left (a.employee_name,CHARINDEX(' ',a.employee_name)-1)
	= left (b.employee_name,CHARINDEX(' ',b.employee_name)-1)
where a.gender is null 
and b.gender is not null 

--update it
update a
set a.gender = b.gender 
from meridian a
join meridian b
	on left (a.employee_name,CHARINDEX(' ',a.employee_name)-1)
	= left (b.employee_name,CHARINDEX(' ',b.employee_name)-1)
where a.gender is null 
and b.gender is not null; 

-- Validate 
select 
	gender 
from Meridian
where gender is null

/* 4.2 Department */
SELECT DISTINCT
    Department COLLATE Latin1_General_CS_AS AS Department
FROM Meridian
ORDER BY Department;

--standardize capitalization
UPDATE Meridian
SET Department = 'Sales'
WHERE Department LIKE '%sa%';

UPDATE Meridian
SET Department = 'Human Resources'
WHERE Department LIKE '%human re%';

UPDATE Meridian
SET Department = 'Information Technology'
WHERE Department LIKE '%information tech%';

UPDATE Meridian
SET Department = 'Operations'
WHERE Department LIKE '%ope%';

UPDATE Meridian
SET Department = 'Risk and Compliance'
WHERE Department LIKE '%risk and com%';

-- Validate 
SELECT DISTINCT
    Department
FROM Meridian
ORDER BY Department;

/* 4.3 Employment_type */
SELECT DISTINCT
    Employment_Type COLLATE Latin1_General_CS_AS AS Employment_Type
FROM Meridian
ORDER BY Employment_Type;

--Standardize
UPDATE Meridian
SET Employment_Type = 'Full-time'
WHERE Employment_Type LIKE '%full time%';

-- Validate 
SELECT DISTINCT
    Employment_Type
FROM Meridian
ORDER BY Employment_Type;

/* 4.4 Job Level */
SELECT DISTINCT
    Job_Level COLLATE Latin1_General_CS_AS AS Job_Level
FROM Meridian
ORDER BY Job_Level;

/* 4.5 Location */
SELECT DISTINCT
    Location COLLATE Latin1_General_CS_AS AS Location
FROM Meridian
ORDER BY Location;

/* 4.6 Age Group */
SELECT DISTINCT
    Age_Group COLLATE Latin1_General_CS_AS AS Age_Group
FROM Meridian
ORDER BY Age_Group;

/* 4.7 Education Level */
SELECT DISTINCT
    Education_Level COLLATE Latin1_General_CS_AS AS Education_Level
FROM Meridian
ORDER BY Education_Level;

/* 4.8 Turnover Status */
SELECT DISTINCT
    Turnover_Status COLLATE Latin1_General_CS_AS AS Turnover_Status
FROM Meridian
ORDER BY Turnover_Status;

/* 4.9 Handle missing Age Group values
   The most frequent Age_Group is used as the replacement
   for missing categorical values.
*/
SELECT TOP 1
    Age_Group,
    COUNT(*) AS Frequency
FROM Meridian
WHERE Age_Group IS NOT NULL
GROUP BY Age_Group
ORDER BY COUNT(*) DESC;

UPDATE Meridian
SET Age_Group = '31-40'
WHERE Age_Group IS NULL;

--- Validate 
select 
	age_group from Meridian
where age_group is null;

/* ============================================================
   5. DATA TYPE CONVERSION
============================================================ */
-- Years of service
ALTER TABLE Meridian
ALTER COLUMN Years_of_Service DECIMAL(10,2);

-- Monthly salary
ALTER TABLE Meridian
ALTER COLUMN Monthly_Salary_NGN MONEY;

-- Performance score
ALTER TABLE Meridian
ALTER COLUMN Performance_Score DECIMAL(10,2);

-- Absenteeism days
ALTER TABLE Meridian
ALTER COLUMN Absenteeism_Days INT;

/* ============================================================
   6. SALARY
============================================================ */
--Calcuate average salary
select 
	ROUND (avg(monthly_salary_NGN), 7)
from Meridian

--fill missing values with mean/avg(expected monthly salary)
update Meridian
set monthly_salary_ngn = '357005.64'
where monthly_salary_ngn is null;

--Validate
select * from Meridian
WHERE monthly_salary_ngn IS NULL;

/* ============================================================
   7. INVALID VALUE INVESTIGATION
   7.1 Performance Score
============================================================ */
-- Identify performance scores below the expected range
SELECT
    Employee_ID,
    Department,
    Performance_Score,
    Turnover_Status
FROM Meridian
WHERE Performance_Score < 0
ORDER BY Performance_Score;

/* 7.2  Missing performance */
SELECT
    AVG(Performance_Score) AS Average_Performance
FROM Meridian
WHERE Performance_Score IS NOT NULL;

UPDATE Meridian
SET Performance_Score =
    (SELECT AVG(Performance_Score)
    FROM Meridian
    WHERE Performance_Score IS NOT NULL)
WHERE Performance_Score IS NULL;

--Validate
SELECT
    COUNT(*) AS Missing_Performance
FROM Meridian
WHERE Performance_Score IS NULL;

/* ============================================================
   8. Absenteeism days
============================================================ */
SELECT
    AVG(Absenteeism_Days) AS Average_Absenteeism
FROM Meridian
WHERE Absenteeism_Days IS NOT NULL;

UPDATE Meridian
SET Absenteeism_Days =
    (SELECT AVG(CAST(Absenteeism_Days AS DECIMAL(10,2)))
    FROM Meridian
    WHERE Absenteeism_Days IS NOT NULL)
WHERE Absenteeism_Days IS NULL;

/* ============================================================
   9. HANDLE MISSING CATEGORICAL VALUES

   Missing categorical values are retained as 'Unknown'
   rather than deleting employee records.
============================================================ */
UPDATE Meridian
SET Job_Level = 'Unknown'
WHERE Job_Level IS NULL;

UPDATE Meridian
SET Department = 'Unknown'
WHERE Department IS NULL;

UPDATE Meridian
SET Employment_Type = 'Unknown'
WHERE Employment_Type IS NULL;

UPDATE Meridian
SET Location = 'Unknown'
WHERE Location IS NULL;

UPDATE Meridian
SET Education_Level = 'Unknown'
WHERE Education_Level IS NULL;

--Validate
SELECT
    SUM(CASE WHEN Job_Level = 'Unknown' THEN 1 ELSE 0 END)
        AS Unknown_Job_Level,

    SUM(CASE WHEN Department = 'Unknown' THEN 1 ELSE 0 END)
        AS Unknown_Department,

    SUM(CASE WHEN Employment_Type = 'Unknown' THEN 1 ELSE 0 END)
        AS Unknown_Employment_Type,

    SUM(CASE WHEN Location = 'Unknown' THEN 1 ELSE 0 END)
        AS Unknown_Location,

    SUM(CASE WHEN Education_Level = 'Unknown' THEN 1 ELSE 0 END)
        AS Unknown_Education
FROM Meridian;

/* ============================================================
   8. FINAL DATA VALIDATION
============================================================ */
-- Total number of records
SELECT
    COUNT(*) AS Total_Records
FROM Meridian;

-- Check for duplicate Employee IDs
SELECT
    Employee_ID,
    COUNT(*) AS Record_Count
FROM Meridian
GROUP BY Employee_ID
HAVING COUNT(*) > 1;

-- Check missing salary
SELECT
    COUNT(*) AS Missing_Salary
FROM Meridian
WHERE Monthly_Salary_NGN IS NULL;

-- Check missing performance
SELECT
    COUNT(*) AS Missing_Performance
FROM Meridian
WHERE Performance_Score IS NULL;

-- Check missing absenteeism
SELECT
    COUNT(*) AS Missing_Absenteeism
FROM Meridian
WHERE Absenteeism_Days IS NULL;

-- Check invalid negative performance
SELECT
    COUNT(*) AS Negative_Performance
FROM Meridian
WHERE Performance_Score < 0;

-- Check departments
SELECT DISTINCT
    Department
FROM Meridian
ORDER BY Department;

-- Check turnover categories
SELECT DISTINCT
    Turnover_Status
FROM Meridian
ORDER BY Turnover_Status;
