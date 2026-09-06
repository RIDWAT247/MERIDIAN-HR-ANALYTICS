/*
=========================================================
MERIDIAN HR ANALYTICS
DATA CLEANING AND VALIDATION
=========================================================

Purpose:
This script documents the data cleaning and validation
process performed on the Meridian HR dataset.

Dataset:
5,050 employee records

Tools:
Microsoft SQL Server

Key fields:
- Employee_ID
- Department
- Gender
- Education_Level
- Employment_Type
- Job_Level
- Monthly_Salary_NGN
- Performance_Score
- Absenteeism_Days
- Turnover_Status

=========================================================
*/

select * from meridian;

-- DATA CLEANING PROCESS 

--to know the numbers of rows without duplicates 
select distinct 
	employee_id, employee_name
from Meridian;

-- to find the duplicated rows
select 
	employee_ID, employee_name, 
		count(employee_id)as dub
from Meridian
group by employee_id, employee_name
having count(*)>1
order by employee_id, employee_name;

-- to keep one row per duplicates 
with cte as(
	select *, 
	row_number() over(
		partition by employee_id, employee_name 
		order by employee_id)as row
		from Meridian) 
delete from cte
where row > 1

-- after removing duplicates, the dataset has 5000 records.
select * from Meridian;

--to check for inconsistencies in gender column with case sensitivity
select distinct		
	Gender 
		collate latin1_general_cs_as as gender
from meridian
order by gender;

--to change the first letter to capital letter(proper case)
select
	upper(left(gender, 1))
	+LOWER(substring(gender, 2, len(gender))) as capitalize
from Meridian;

--to update the first letter to capital letter(proper case)
update meridian
set gender = upper(left(gender, 1))+	
	LOWER(substring(gender, 2, len(gender))) 
where gender is not null;

--to fill missing values in gender, use employees where the first name matches and gender already known to fill the missing ones
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

select 
	gender 
from Meridian
where gender is null


--to check for incosistencies in department column with case sensitivity
select distinct 
	department 
	collate latin1_general_cs_as as department
from meridian
order by department;

--updating department proper case 
update Meridian
set department = 'Sales'
where department like '%sa%';

update Meridian
set department = 'Human Resources'
where department like '%human re%';

update Meridian
set department = 'Information Technology'
where department like '%information tech%';

update Meridian
set department = 'Operations'
where department like '%ope%';

update Meridian
set department = 'Risk and Compliance'
where department like '%risk and com%';

select * from Meridian;

--- check distinct employment-type to find inconsistency 
select distinct 
	employment_type 
		collate latin1_general_cs_as as employment_type
from meridian
order by employment_type;

--update employment-type to proper case
update Meridian
set employment_type = 'Full-time'
where employment_type like '%full time%';

--- check distinct job level to find inconsistency 
select distinct 
	job_level 
		collate latin1_general_cs_as as job_level 
from meridian
order by job_level;

select * from meridian;

--- check distinct location, to find inconsistency 
select distinct 
	location 
		collate latin1_general_cs_as as location 
from meridian
order by location;

--- check distinct age group, to find inconsistency 
select distinct 
	age_group 
		collate latin1_general_cs_as as age_group 
from meridian
order by age_group;

--- check distinct education-level, to find inconsistency 
select distinct 
	education_level 
		collate latin1_general_cs_as as education_level 
from meridian
order by education_level;

--- check distinct turnover-status, to find inconsistency 
select distinct 
	turnover_status 
		collate latin1_general_cs_as as turnover_status 
from meridian
order by turnover_status;

---to check most occurred values in age_group(categorical data)
select 
	top 1 age_group, 
		COUNT(*) as frequency   
from meridian
group by age_group
order by COUNT(*)desc;

--fill missing values with mode(most of occurred age-group)
update Meridian
set age_group = '31-40'
where age_group is null;

--- check if it works
select 
	age_group from Meridian
where age_group is null;

select * from Meridian;

---change nvarchar data type column to decimal
alter table meridian
alter column years_of_service decimal(10, 2);

---change nvarchar data type column(salary) to money
alter table meridian
alter column Monthly_salary_NGN MONEY;

--- round up avg salary to the nearest 7 digits 
select 
	ROUND (avg(monthly_salary_NGN), 7)
from Meridian

--fill missing values with mean/avg(expected monthly salary)
update Meridian
set monthly_salary_ngn = '357005.64'
where monthly_salary_ngn is null;

--check if it work
select * from Meridian
WHERE monthly_salary_ngn IS NULL;

---convert nvarchar data type to decimal 
alter table meridian
alter column performance_score decimal(10, 2);

--check avg performance
select avg(performance_score)
from Meridian

---performance has unexpected va(negative values)
SELECT
Employee_ID,
Department,
Performance_Score,
Turnover_Status
FROM Meridian
WHERE Performance_Score < 0
ORDER BY Performance_Score;

--fill missing values with mean/avg(performace)
update Meridian
set performance_score = '3.43'
where performance_score is null;

--convert nvarchar data type to integers
alter table meridian
alter column absenteeism_days int;

--- check avg absenteeism 
select avg(absenteeism_days)
from Meridian

--fill missing values with mean/avg(expected absenteeism)
update Meridian
set absenteeism_days = '10'
where absenteeism_days is null;

select * from Meridian;

select Job_Level from Meridian
where Employee_Id is NULL;

-- change all nulls values to unknown 
update Meridian
set Job_Level = 'Unknown'
where Job_Level is null;

update Meridian
set Department = 'Unknown'
where Department is null;

update Meridian
set Employment_Type = 'Unknown'
where Employment_Type is null;

update Meridian
set Location = 'Unknown'
where Location is null;

update Meridian
set Education_Level = 'Unknown'
where Education_Level is null;

update Meridian
set Hire_Date = 'Unknown'
where Hire_Date is null;

update Meridian
set Exit_Date = 'Unknown'
where Exit_Date is null;

select *  from Meridian;

select Years_of_Service from meridian
where Years_of_Service > 10