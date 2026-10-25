/*
=========================================================
Meridian HR ANALYTICS
DATA CLEANING AND VALIDATION
=========================================================

Purpose:
This script documents the data cleaning and validation
process performed on the Meridian HR datASET.

DatASET:
5,050 employee records

Tools:
Microsoft SQL Server

Key fields:
- Employee_id
- Department
- Gender
- Education_Level
- Employment_Type
- Job_Level
- Monthly_Salary_NGN
- Performance_Score
- Absenteeism_Days
- TurnOVER_Status

=========================================================*/

/* =========================================
 1.		INITIAL DATA INSPECTION
 =========================================*/
SELECT * FROM Meridian;

SELECT
    COUNT(*) AS Total_Records
FROM Meridian;

/* =========================================
 2. DUPLICATE CHECK
 =========================================*/
SELECT DISTINCT 
	Employee_id, Employee_name
FROM Meridian;

/* =========================================
 2.1	DUPLICATED ROWS
		Find the duplicated rows
 =========================================*/
SELECT 
	Employee_id, Employee_name, 
		COUNT(Employee_id)AS dub
FROM Meridian
GROUP BY Employee_id, Employee_name
HAVING COUNT(*)>1
ORDER BY Employee_id, Employee_name;

/* =========================================
 2.2	DUPLICATE REMOVAL
		Keep one row per duplicates
 =========================================*/ 
WITH cte AS(
	SELECT *, 
	ROW_number() OVER(
		PARTITION BY Employee_id, Employee_name 
		ORDER BY Employee_id)AS ROW
		FROM Meridian) 
DELETE FROM cte
WHERE ROW > 1

/* =========================================
 2.3	VALIDATE DUPLICATE REMOVAL
 =========================================*/ 
SELECT
    Employee_id,
    Employee_name,
    COUNT(*) AS Record_Count
FROM Meridian
GROUP BY Employee_id, Employee_name
HAVING COUNT(*) > 1;

/* =========================================
 3		CHECK FOR INCONSISTENCIES IN GENDER COLUMN
		Inconsistencies in gender column with case sensitivity
 =========================================*/ 
SELECT DISTINCT		
	Gender 
		COLLATE latin1_general_CS_AS AS Gender
FROM Meridian
ORDER BY gender;

/* =========================================
 3.1	INCONSISTENCIES IN GENDER COLUMN
		Change the first letter to capital letter(proper cASe)
 =========================================*/ 
SELECT
	upper(left(gender, 1))
	+LOWER(substring(gender, 2, len(gender))) AS capitalize
FROM Meridian;

/* =========================================
 3.2	UPDATE GENDER TO PROPER CASE
 =========================================*/ 
UPDATE Meridian
SET gender = upper(left(gender, 1))+	
	LOWER(substring(gender, 2, len(gender))) 
WHERE gender is not null;

/* =========================================
 3.3	VALIDATE
 =========================================*/ 
SELECT DISTINCT
    Gender
FROM Meridian
ORDER BY Gender;

/* =========================================
 4		MISSING VALUE CHECK IN GENDER COLUMN
 =========================================*/ 
 SELECT gender 
 FROM Meridian
 WHERE gender is null;

 /* =========================================
 4.1	FILL THE MISSING VALUES
 =========================================*/ 
SELECT a.Employee_name,
	a.gender AS current_gender,
	b.gender AS gender_to_fill
FROM Meridian a
join Meridian b
	on left (a.Employee_name,CHARINDEX(' ',a.Employee_name)-1)
	= left (b.Employee_name,CHARINDEX(' ',b.Employee_name)-1)
WHERE a.gender is null 
and b.gender is not null 

/* =========================================
 4.2	UPDATE
 =========================================*/ 
UPDATE a
SET a.gender = b.gender 
FROM Meridian a
join Meridian b
	on left (a.Employee_name,CHARINDEX(' ',a.Employee_name)-1)
	= left (b.Employee_name,CHARINDEX(' ',b.Employee_name)-1)
WHERE a.gender is null 
and b.gender is not null; 

/* =========================================
 4.3	VALIDATE
 =========================================*/ 
SELECT 
	gender 
FROM Meridian
WHERE gender is null

/* =========================================
 5		CHECK FOR INCONSISTENCIES IN DEPARTMENT COLUMN
		Inconsistencies in Department column with case sensitivity
 =========================================*/ 
SELECT DISTINCT 
	Department 
	COLLATE latin1_general_cs_AS AS Department
FROM Meridian
ORDER BY department;

/* =========================================
 5.1		UPDATE
 =========================================*/ 
UPDATE Meridian
SET department = 'Sales'
WHERE department like '%sa%';

UPDATE Meridian
SET department = 'Human Resources'
WHERE department like '%human re%';

UPDATE Meridian
SET department = 'Information Technology'
WHERE department like '%information tech%';

UPDATE Meridian
SET department = 'Operations'
WHERE department like '%ope%';

UPDATE Meridian
SET department = 'Risk and Compliance'
WHERE department like '%risk and com%';

/* =========================================
 5.2	VALIDATE
 =========================================*/ 
 SELECT DISTINCT
    Department
FROM Meridian
ORDER BY Department;

/* =========================================
 6		CHECK FOR INCONSISTENCIES IN EMPLOYMENT TYPE COLUMN
		Inconsistencies in Employment type column with case sensitivity
 =========================================*/  
SELECT DISTINCT 
	employment_type 
		COLLATE latin1_general_cs_AS AS employment_type
FROM Meridian
ORDER BY employment_type;

/* =========================================
 6.1	UPDATE
		Employment-type to proper case
 =========================================*/ 
UPDATE Meridian
SET employment_type = 'Full-time'
WHERE employment_type like '%full time%';

/* =========================================
 6.2	VALIDATE
 =========================================*/ 
 SELECT DISTINCT
    Employment_Type
FROM Meridian
ORDER BY Employment_Type;

/* =========================================
 7		CHECK FOR INCONSISTENCIES IN JOB LEVEL COLUMN
		Inconsistencies in Job Level column with case sensitivity
 =========================================*/   
SELECT DISTINCT 
	Job_level 
		COLLATE latin1_general_cs_AS AS job_level 
FROM Meridian
ORDER BY job_level;

/* =========================================
 8		CHECK FOR INCONSISTENCIES IN LOCATION COLUMN
		Inconsistencies in Location column with case sensitivity
 =========================================*/   
SELECT DISTINCT 
	Location 
		COLLATE latin1_general_cs_AS AS location 
FROM Meridian
ORDER BY Location;

/* =========================================
 9		CHECK FOR INCONSISTENCIES IN AGE GROUP COLUMN
		Inconsistencies in Age Group column with case sensitivity
 =========================================*/ 
SELECT DISTINCT 
	age_group 
		COLLATE latin1_general_cs_AS AS age_group 
FROM Meridian
ORDER BY age_group;

/* =========================================
 9.1	MISSING VALUE CHECK IN AGE GROUP COLUMN
 =========================================*/ 
 SELECT gender 
 FROM Meridian
 WHERE gender is null;

 /* =========================================
 9.2	CHECK MOST OCCURED VALUE IN AGE GROUP COLUMN
 =========================================*/ 
SELECT 
	top 1 age_group, 
		COUNT(*) AS frequency   
FROM Meridian
GROUP BY age_group
ORDER BY COUNT(*)DESC;

/* =========================================
 9.3	FILL MISSING VALUE IN AGE GROUP COLUMN
 =========================================*/ 
UPDATE Meridian
SET Age_Group = '31-40'
WHERE Age_Group IS NULL;

/* =========================================
 9.4	VALIDATE
 =========================================*/ 
SELECT COUNT(*)
FROM Meridian
WHERE Age_Group IS NULL;

/* =========================================
 10		CHECK FOR INCONSISTENCIES IN EDUCATION LEVEL COLUMN
		Inconsistencies in Education Level column with case sensitivity
 =========================================*/  
SELECT DISTINCT 
	education_level 
		COLLATE latin1_general_cs_AS AS education_level 
FROM Meridian
ORDER BY education_level;

/* =========================================
 10.1	CHECK FOR INCONSISTENCIES IN TURNOVER STATUS COLUMN
		Inconsistencies in Turnover Status column with case sensitivity
 =========================================*/  
SELECT DISTINCT 
	turnOVER_status 
		COLLATE latin1_general_cs_AS AS turnover_status 
FROM Meridian
ORDER BY turnover_status;

/* ============================================================
 11		DATA TYPE CONVERSION
============================================================ */
---change nvarchar data type column to decimal
alter table Meridian
alter column years_of_service decimal(10, 2);

---change nvarchar data type column(salary) to money
alter table Meridian
alter column Monthly_salary_NGN MONEY;

---convert nvarchar data type to decimal 
alter table Meridian
alter column performance_score decimal(10, 2);

--convert nvarchar data type to integers
alter table Meridian
alter column absenteeism_days int;

/* =========================================
 12		MISSING VALUE CHECK IN SALARY COLUMN
 =========================================*/ 
SELECT Monthly_Salary_NGN
FROM Meridian
WHERE Monthly_Salary_NGN is null;

/* =========================================
 12.1	UPDATE SALARY
 =========================================*/ 
UPDATE Meridian
SET Monthly_Salary_NGN =
	(SELECT AVG(Monthly_Salary_NGN)
    FROM Meridian)
WHERE Monthly_Salary_NGN IS NULL;

/* ============================================================
 13		INVALID VALUE INVESTIGATION PERFORMANCE COLUMN
============================================================ */
SELECT
    Employee_id,
    Department,
    Performance_Score,
    Turnover_Status
FROM Meridian
WHERE Performance_Score < 0
ORDER BY Performance_Score;

/* =========================================
 13.1	MISSING VALUE CHECK IN PERFORMANCE COLUMN
 =========================================*/ 
SELECT Performance_Score
FROM Meridian
WHERE Performance_Score is null;

/* =========================================
 13.2	UPDATE PERFORMANCE SCORE
 =========================================*/ 
UPDATE Meridian
SET Performance_Score =
	(SELECT AVG(Performance_Score)
    FROM Meridian
    WHERE Performance_Score IS NOT NULL)
WHERE Performance_Score IS NULL;

/* =========================================
 13.3	VALIDATE
 =========================================*/ 
 SELECT
    COUNT(*) 
FROM Meridian
WHERE Performance_Score IS NULL;

/* =========================================
 14		MISSING VALUE CHECK IN ABSENTEEISM COLUMN
 =========================================*/ 
SELECT Absenteeism_Days
FROM Meridian
WHERE Absenteeism_Days is null;

/* =========================================
 14.1	UPDATE ABSENTEEISM DAYS
 =========================================*/ 
UPDATE Meridian
SET Absenteeism_Days =
	(SELECT AVG(Absenteeism_Days)
    FROM Meridian
    WHERE Absenteeism_Days IS NOT NULL)
WHERE Absenteeism_Days IS NULL;

/* =========================================
 14.2	VALIDATE
 =========================================*/ 
 SELECT
    COUNT(*) 
FROM Meridian
WHERE Absenteeism_Days IS NULL;

/* =========================================
 15		UPDATE MISSING CATEGORICAL FIELDS 
 =========================================*/ 
UPDATE Meridian
SET Job_Level = 'Unknown'
WHERE Job_Level is null;

UPDATE Meridian
SET Department = 'Unknown'
WHERE Department is null;

UPDATE Meridian
SET Employment_Type = 'Unknown'
WHERE Employment_Type is null;

UPDATE Meridian
SET Location = 'Unknown'
WHERE Location is null;

UPDATE Meridian
SET Education_Level = 'Unknown'
WHERE Education_Level is null;

UPDATE Meridian
SET Hire_Date = 'Unknown'
WHERE Hire_Date is null;

UPDATE Meridian
SET Exit_Date = 'Unknown'
WHERE Exit_Date is null;

UPDATE Meridian
SET Exit_Date = 'Null'
WHERE Exit_Date = 'Unknown';


/* =========================================
Data Cleaning Summary

1.	Initial Data Inspection: The initial inspection revealed that the dataset contained 5,050 rows.

2.	Duplicate Identification: A total of 50 duplicate records were identified in the dataset.

3.	Duplicate Removal: After removing the duplicate records, the dataset contained 5,000 rows.

4.	Data Standardization: Inconsistencies in the dataset were identified and corrected to improve data quality and consistency.

5.	Missing Gender Values: Missing values in the gender column were filled using gender information associated with employees who had the same first name in the dataset.

6.	Missing Age Group Values: Missing values in the age group column were filled with the most frequently occurring age group (mode).

7.	Missing Salary Values: Missing salary values were replaced with the average salary.

8.	Missing Performance Scores: Missing performance scores were replaced with the average performance score.

9.	Missing Absenteeism Values: Missing absenteeism values were replaced with the average absenteeism value.

10. Missing Categorical Values: Missing values in other categorical columns were replaced with unknown

 =========================================*/