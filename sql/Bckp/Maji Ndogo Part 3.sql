-- Ok, we have a .csv file of the auditor's results. We should get it loaded into SQL. 
-- We will have to think back to the start of our journey on how to do that.

-- To make sure we have the same names, use this query to create the table first, then Import the CSV file:


DROP TABLE IF EXISTS `auditor_report`;; -- Remove one semi-colon ";" in order to run the query
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);


-- After importing the CSV...


SELECT 
    *
FROM
    md_water_services.auditor_report;


/*
Wow! First off, it looks like we have 1620 records, or sites that they re-visited. I see a location_id, 
type of water source at that location, and the quality score of the water source, that is now independently measured. 
Our auditor also investigated each site a bit by speaking to a few locals. Their statements are also captured in his results.
*/

-- We need to tackle a couple of questions here.
-- 1. Is there a difference in the scores?
-- 2. If so, are there patterns?

/*
For the first question, we will have to compare the quality scores in the water_quality table to the auditor's scores. 
The auditor_report table used location_id, but the quality scores table only has a record_id we can use. 
The visits table links location_id and record_id, so we can link the auditor_report table and water_quality using the visits table.
*/

-- So first, grab the location_id and true_water_source_score columns from auditor_report.


SELECT 
    location_id, true_water_source_score
FROM
    auditor_report;


-- Now, we join the visits table to the auditor_report table. Make sure to grab subjective_quality_score, record_id and location_id.


SELECT 
    a.location_id audit_location, 
    a.true_water_source_score,
    v.location_id visit_location,
    v.record_id
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id;


/*
Now that we have the record_id for each location, our next step is to retrieve the corresponding scores from 
the water_quality table. We are particularly interested in the subjective_quality_score. To do this, we'll JOIN 
the visits table and the water_quality table, using the record_id as the connecting key.
*/


SELECT 
    a.location_id audit_location, 
    a.true_water_source_score,
    v.location_id visit_location,
    v.record_id,
    wq.subjective_quality_score subjective_quality_score
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id
INNER JOIN
	water_quality wq
    on v.record_id = wq.record_id;
    

/*we are about to clean this up a bit. Since it is a duplicate, we can drop one of the location_id columns. 
Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scores 
we're looking at in the results set.    
*/


SELECT 
	v.location_id,
    v.record_id,
    a.true_water_source_score audit_sore,
    wq.subjective_quality_score surveyor_score
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id
INNER JOIN
	water_quality wq
    on v.record_id = wq.record_id;


/*
Since were joining 1620 rows of data, we want to keep track of the number of rows we get each time we run a query. 
We can either set the maximum number of rows we want from "Limit to 1000 rows" to a larger number like 10000, 
or we can force SQL to give us all of the results, using LIMIT 10000.

Ok, let's analyse! A good starting point is to check if the auditor's and employees' scores agree. There are many ways to do it. 
We can have a WHERE clause and check if surveyor_score = auditor_score, or we can subtract the two scores and 
check if the result is 0.

NB remember that you can't use aliases in WHERE, so you have to use the same name as in the
SELECT part, like this: auditor_report.true_water_source_score
*/


SELECT 
	v.location_id,
    v.record_id,
    a.true_water_source_score audit_sore,
    wq.subjective_quality_score surveyor_score
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id
INNER JOIN
	water_quality wq
    on v.record_id = wq.record_id
WHERE a.true_water_source_score = wq.subjective_quality_score;


-- We got 2505 rows. Some of the locations were visited multiple times, so these records are duplicated here. To fix it, 
-- we set visits.visit_count = 1 in the WHERE clause. Make sure you reference the alias you used for visits in the join.


SELECT 
	v.location_id,
    v.record_id,
    a.true_water_source_score audit_sore,
    wq.subjective_quality_score surveyor_score
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id
INNER JOIN
	water_quality wq
    on v.record_id = wq.record_id
WHERE a.true_water_source_score = wq.subjective_quality_score
	and v.visit_count = 1;


-- With the duplicates removed, we got 1518. Considering that the auditor visited 1620 sites, 
-- I think that is an excellent result. 1518/1620 = 94% of the records the auditor checked were correct!!

-- But that means that 102 records are incorrect. So let's look at those. We can do it by adding one character "!" in the where query!


SELECT 
	v.location_id,
    v.record_id,
    a.true_water_source_score audit_sore,
    wq.subjective_quality_score surveyor_score
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id
INNER JOIN
	water_quality wq
    on v.record_id = wq.record_id
WHERE a.true_water_source_score != wq.subjective_quality_score -- Notice, we added "!" here
	and v.visit_count = 1;


/*
Since we used some of this data in our previous analyses, we need to make sure those results are still valid, 
now we know some of them are incorrect. We didn't use the scores that much, but we relied a lot on the type_of_water_source, 
so let's check if there are any errors there.

So, to do this, we need to grab the type_of_water_source column from the water_source table and call it survey_source, using the
source_id column to JOIN. Also select the type_of_water_source from the auditor_report table, and call it auditor_source.
*/


SELECT 
	v.location_id,
    a.type_of_water_source auditor_source,
    ws.type_of_water_source survey_source,
    v.record_id,
    a.true_water_source_score audit_score,
    wq.subjective_quality_score surveyor_score
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id
INNER JOIN
	water_quality wq
    on v.record_id = wq.record_id
INNER JOIN
	water_source ws
    on v.source_id = ws.source_id
WHERE a.true_water_source_score != wq.subjective_quality_score
	and v.visit_count = 1;
    

-- So we can see that the types of sources look the same! So even though the scores are wrong, 
-- the integrity of the type_of_water_source data we analysed last time is not affected.

-- Ok, so lets remove the columns and JOIN statement for water_sources again.


SELECT 
	v.location_id,
    v.record_id,
    a.true_water_source_score audit_sore,
    wq.subjective_quality_score surveyor_score
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id
INNER JOIN
	water_quality wq
    on v.record_id = wq.record_id
WHERE a.true_water_source_score != wq.subjective_quality_score
	and v.visit_count = 1;

-- #LINKING RECORDS TO EMPLOYEES#
-- Next up, let's look at where these errors may have come from. At some of the locations, 
-- employees assigned scores incorrectly, and those records ended up in this results set.

/*
I think there are two reasons this can happen.
1. These workers are all humans and make mistakes so this is expected.
2. Unfortunately, the alternative is that someone assigned scores incorrectly on purpose!

In either case, the employees are the source of the errors, so let's JOIN the assigned_employee_id for all the people on 
our list from the visits table to our query. Remember, our query shows the shows the 102 incorrect records, 
so when we join the employee data, we can see which employees made these incorrect records.
*/


SELECT 
	v.location_id,
    v.record_id,
    e.assigned_employee_id,
    a.true_water_source_score audit_sore,
    wq.subjective_quality_score surveyor_score
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id
INNER JOIN
	water_quality wq
    on v.record_id = wq.record_id
INNER JOIN
	employee e
    on v.assigned_employee_id = e. assigned_employee_id
WHERE a.true_water_source_score != wq.subjective_quality_score
	and v.visit_count = 1;


-- So now we can link the incorrect records to the employees who recorded them. The ID's don't help us to identify them. 
-- We have employees' names stored along with their IDs, so let's fetch their names from the employees table instead of the ID's.


SELECT 
	v.location_id,
    v.record_id,
    e.employee_name,
    a.true_water_source_score audit_sore,
    wq.subjective_quality_score surveyor_score
FROM
    auditor_report a
INNER JOIN
	visits v
    on a.location_id = v.location_id
INNER JOIN
	water_quality wq
    on v.record_id = wq.record_id
INNER JOIN
	employee e
    on v.assigned_employee_id = e. assigned_employee_id
WHERE a.true_water_source_score != wq.subjective_quality_score
	and v.visit_count = 1;
    

/*
Well this query is massive and complex, so maybe it is a good idea to save this as a CTE, so when we do more analysis, 
we can just call that CTE like it was a table. Call it something like Incorrect_records. Once you are done, 
check if this query SELECT * FROM Incorrect_records, gets the same table back.
*/


WITH 
Incorrect_records AS (
		SELECT 
			v.location_id,
			v.record_id,
			e.employee_name,
			a.true_water_source_score audit_sore,
			wq.subjective_quality_score surveyor_score
		FROM
			auditor_report a
		INNER JOIN
			visits v
			on a.location_id = v.location_id
		INNER JOIN
			water_quality wq
			on v.record_id = wq.record_id
		INNER JOIN
			employee e
			on v.assigned_employee_id = e. assigned_employee_id
		WHERE a.true_water_source_score != wq.subjective_quality_score
			and v.visit_count = 1
		)
SELECT *
FROM incorrect_records;


-- Let's first get a unique list of employees from this table.


WITH 
Incorrect_records AS (
		SELECT 
			v.location_id,
			v.record_id,
			e.employee_name,
			a.true_water_source_score audit_sore,
			wq.subjective_quality_score surveyor_score
		FROM
			auditor_report a
		INNER JOIN
			visits v
			on a.location_id = v.location_id
		INNER JOIN
			water_quality wq
			on v.record_id = wq.record_id
		INNER JOIN
			employee e
			on v.assigned_employee_id = e. assigned_employee_id
		WHERE a.true_water_source_score != wq.subjective_quality_score
			and v.visit_count = 1
		)
SELECT distinct employee_name
FROM incorrect_records;


-- Next, let's try to calculate how many mistakes each employee made. So basically we want to count how many times their 
-- name is in incorrect_records list, and then group them by name


WITH 
Incorrect_records AS (
		SELECT 
			v.location_id,
			v.record_id,
			e.employee_name,
			a.true_water_source_score audit_sore,
			wq.subjective_quality_score surveyor_score
		FROM
			auditor_report a
		INNER JOIN
			visits v
			on a.location_id = v.location_id
		INNER JOIN
			water_quality wq
			on v.record_id = wq.record_id
		INNER JOIN
			employee e
			on v.assigned_employee_id = e. assigned_employee_id
		WHERE a.true_water_source_score != wq.subjective_quality_score
			and v.visit_count = 1
		)
SELECT employee_name,
	count(employee_name) number_of_mistakes
FROM incorrect_records
GROUP BY employee_name;


-- Lets Order the list to see if there is a pattern


WITH 
Incorrect_records AS (
		SELECT 
			v.location_id,
			v.record_id,
			e.employee_name,
			a.true_water_source_score audit_sore,
			wq.subjective_quality_score surveyor_score
		FROM
			auditor_report a
		INNER JOIN
			visits v
			on a.location_id = v.location_id
		INNER JOIN
			water_quality wq
			on v.record_id = wq.record_id
		INNER JOIN
			employee e
			on v.assigned_employee_id = e. assigned_employee_id
		WHERE a.true_water_source_score != wq.subjective_quality_score
			and v.visit_count = 1
		)
SELECT employee_name,
	count(employee_name) number_of_mistakes
FROM incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes;


-- It looks like some of our surveyors are making a lot of "mistakes" while many of the other surveyors are only making a few.

-- #GATHERING SOME EVIDENCE#
/*
-- How would we go about finding out if any of our employees are corrupt?
-- Let's say all employees make mistakes, if someone is corrupt, they will be making a lot of "mistakes", more than average, 
-- for example. But someone could just be clumsy, so we should try to get more evidence...

-- Our auditor did say some of the things he heard on the streets were quite shady, and he recorded this in the statements column. 
-- Considering both of these sources should give us a pretty reliable answer.
*/


-- So let's try to find all of the employees who have an above-average number of mistakes. Let's break it down into steps first:
-- 1. We have to first calculate the number of times someone's name comes up. (we just did that in the previous query). 
-- Let's call it error_count.
-- 2. Then, we need to calculate the average number of mistakes employees made. We can do that by taking the average of 
-- the previous query's results. Something like this:


WITH 
Incorrect_records AS (
		SELECT 
			v.location_id,
			v.record_id,
			e.employee_name,
			a.true_water_source_score audit_sore,
			wq.subjective_quality_score surveyor_score
		FROM
			auditor_report a
		INNER JOIN
			visits v
			on a.location_id = v.location_id
		INNER JOIN
			water_quality wq
			on v.record_id = wq.record_id
		INNER JOIN
			employee e
			on v.assigned_employee_id = e. assigned_employee_id
		WHERE a.true_water_source_score != wq.subjective_quality_score
			and v.visit_count = 1
),
error_count as (SELECT employee_name,
	count(employee_name) number_of_mistakes
FROM incorrect_records
GROUP BY employee_name)
SELECT
AVG(number_of_mistakes)
FROM
error_count;


-- Let's call this avg_error_count_per_empl, which would be a scalar value.

-- Finaly we have to compare each employee's error_count with avg_error_count_per_empl. We will call this results set 
-- our suspect_list. Remember that we can't use an aggregate result in WHERE, so we have to use avg_error_count_per_empl 
-- as a subquery.


SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (avg_error_count_per_empl);


-- So lets input the subquery

WITH 
Incorrect_records AS (
		SELECT 
			v.location_id,
			v.record_id,
			e.employee_name,
			a.true_water_source_score audit_sore,
			wq.subjective_quality_score surveyor_score
		FROM
			auditor_report a
		INNER JOIN
			visits v
			on a.location_id = v.location_id
		INNER JOIN
			water_quality wq
			on v.record_id = wq.record_id
		INNER JOIN
			employee e
			on v.assigned_employee_id = e. assigned_employee_id
		WHERE a.true_water_source_score != wq.subjective_quality_score
			and v.visit_count = 1
),
error_count as (SELECT employee_name,
	count(employee_name) number_of_mistakes
FROM incorrect_records
GROUP BY employee_name),
avg_error_count_per_empl as (SELECT
AVG(number_of_mistakes)
FROM
error_count
)
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT
AVG(number_of_mistakes)
FROM
error_count); -- We will call this results set our suspect_list.


/*
1. Let's start by cleaning up our code a bit. First, Incorrect_records is a result we'll be using for the rest of the analysis, 
but it makes the query a bit less readable. So, let's convert it to a VIEW. We can then use it as if it was a table. 
It will make our code much simpler to read, but, it comes at a cost. We can add comments to CTEs in our code, 
so if we return to that query a year later, we can read those comments and quickly understand what Incorrect_records represents. 
If we save it as a VIEW, it is not as obvious. So we should add comments in places where we use Incorrect_records.
*/


-- So, replace WITH with CREATE VIEW like this, and note that I added the statements column to this table in line 8 too


CREATE VIEW Incorrect_records AS (
SELECT
auditor_report.location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
auditor_report.statements AS statements
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality AS wq
ON visits.record_id = wq.record_id
JOIN
employee
ON employee.assigned_employee_id = visits.assigned_employee_id  		  -- These are the supposed mistakes the employees did while																			
WHERE														    		  -- conducting the water sources qaulity research in																	
visits.visit_count =1													  -- Maji Ndogo as revealed by the auditor
AND auditor_report.true_water_source_score != wq.subjective_quality_score);


-- Now, calling SELECT * FROM Incorrect_records gives us the same result as the CTE did.


SELECT * FROM Incorrect_records;


/*
Next, we convert the query error_count, we made earlier, into a CTE. Test it to make sure it gives the same result again, 
using SELECT * FROM Incorrect_records. On large queries like this, it is better to build the query, and test each step, 
because fixing errors becomes harder as the query grows.
*/


WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different
*/

GROUP BY
employee_name)
-- Query
SELECT * FROM error_count;


-- 2. Now calculate the average of the number_of_mistakes in error_count. We should get a single value.


WITH error_count AS (
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
GROUP BY
employee_name)
SELECT avg(number_of_mistakes) 
FROM error_count;

-- 3
/*
To find the employees who made more mistakes than the average person, we need the employee's names, the number of mistakes each one
made, and filter the employees with an above-average number of mistakes.
HINT: Use SELECT AVG(mistake_count) FROM error_count as a custom filter in the WHERE part of our query.
*/


WITH error_count AS (
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
GROUP BY
employee_name)
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT
AVG(number_of_mistakes)
FROM
error_count);


/*
-- These are the employees who made more mistakes, on average, than their peers, so let's have a closer look at them.
-- We should look at the Incorrect_records table again, and isolate all of the records these four employees gathered. 
-- We should also look at the statements for these records to look for patterns.

First, convert the suspect_list to a CTE, so we can use it to filter the records from these four employees. 
Make sure you get the names of the four "suspects", and their mistake count as a result, using SELECT employee_name FROM 
suspect_list.
*/

-- Quick Recap
/*
1. We use Incorrect_records to find all of the records where the auditor and employee scores don't match.
2. We then used error_count to aggregate the data, and got the number of mistakes each employee made.
3. Finally, suspect_list retrieves the data of employees who make an above-average number of mistakes.
Now we can filter that Incorrect_records view to identify all of the records associated with the four employees we identified.
*/

-- Firstly, let's add the statements column to the Incorrect_records view. Then pull up all of the records where 
-- the employee_name is in the suspect list. HINT: Use SELECT employee_name FROM suspect_list as a subquery in WHERE.


WITH error_count AS (
SELECT
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM
	Incorrect_records
GROUP BY
	employee_name),
suspect_list as (
SELECT
	employee_name,
	number_of_mistakes
FROM
	error_count
WHERE
	number_of_mistakes > (SELECT
	AVG(number_of_mistakes)
	FROM
	error_count)
)
SELECT
	employee_name,
	location_id,
	statements
FROM 
	incorrect_records
WHERE 
	employee_name
    IN (SELECT employee_name FROM suspect_list);


-- This query is complex, right! But, if we document it well, it is simpler to understand. Oh, and you don't want to 
-- see what this query looks like using only subqueries!
-- So lets document it


WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different
*/

GROUP BY
employee_name),
suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
employee_name,
location_id,
statements
FROM
Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list);


-- If you have a look, you will notice some alarming statements about these four officials (look at these 
-- records: AkRu04508, AkRu07310, KiRu29639, AmAm09607, for example. See how the word "cash" is used a lot in these statements.
-- Filter the records that refer to "cash".


WITH error_count AS (
SELECT
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM
	Incorrect_records
GROUP BY
	employee_name),
suspect_list as (
SELECT
	employee_name,
	number_of_mistakes
FROM
	error_count
WHERE
	number_of_mistakes > (SELECT
	AVG(number_of_mistakes)
	FROM
	error_count)
)
SELECT
	employee_name,
	location_id,
	statements
FROM 
	incorrect_records
WHERE 
	employee_name
    IN (SELECT employee_name FROM suspect_list)
    AND statements LIKE '%cash%';


-- Let's just do one more check to make sure...
-- Check if there are any employees in the Incorrect_records table with statements mentioning "cash" that are not in our 
-- suspect list. This should be as simple as adding one word.


WITH error_count AS (
SELECT
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM
	Incorrect_records
GROUP BY
	employee_name),
suspect_list as (
SELECT
	employee_name,
	number_of_mistakes
FROM
	error_count
WHERE
	number_of_mistakes > (SELECT
	AVG(number_of_mistakes)
	FROM
	error_count)
)
SELECT
	employee_name,
	location_id,
	statements
FROM 
	incorrect_records
WHERE 
	employee_name
    NOT IN (SELECT employee_name FROM suspect_list) -- We just added "NOT" here to exclude our suspects
    AND statements LIKE '%cash%';


-- We got an empty result, so no one, except the four suspects, has these allegations of bribery.
/*
So we can sum up the evidence we have for Zuriel Matembo, Malachi Mavuso, Bello Azibo and Lalitha Kaburi:
1. They all made more mistakes than their peers on average.
2. They all have incriminating statements made against them, and only them.
*/




























