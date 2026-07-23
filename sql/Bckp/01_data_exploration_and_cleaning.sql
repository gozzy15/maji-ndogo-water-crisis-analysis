SHOW TABLES;


-- So Lets take a look at the content of each tables


SELECT
	*
FROM
	data_dictionary
LIMIT 5;


SELECT
	*
FROM
	employee
LIMIT 5;


SELECT
	*
FROM
	global_water_access
LIMIT 5;


SELECT
	*
FROM
	location
LIMIT 5;


SELECT
	*
FROM
	visits
LIMIT 5;


SELECT
	*
FROM
	water_quality
LIMIT 5;


SELECT
	*
FROM
	water_source
LIMIT 5;


SELECT
	*
FROM
	well_pollution
LIMIT 5;


-- write a SQL query to find all the unique types of water sources.


SELECT DISTINCT
	type_of_water_source
FROM
	water_source;
    
    
-- Write an SQL query that retrieves all records from this table where the time_in_queue is more than some crazy time, say 500 min.


SELECT
	*
FROM
	visits
WHERE
	time_in_queue > 500;


-- so now back to the water_source table. Let's check the records for 
-- those source_ids which include ones with queue time >500 and = 0


SELECT
	*
FROM
	water_source
WHERE source_id
IN(
'SoRu35083224','KiRu28520224','AkRu05296224','AkRu06938224',
'AkLu01628224','SoRu39205224','AkRu03567224','AkKi01265224','AkKi01222224','AmDa11976224'
);


-- The field surveyors also let us know that they measured sources
-- that had queues a few times to see if the queue time changed.


SELECT
	*
FROM
	visits
WHERE source_id
IN(
'SoRu35083224','KiRu28520224','AkRu05296224','AkRu06938224',
'AkLu01628224','SoRu39205224','AkRu03567224','AkKi01265224', -- NB We can still use the not so cool method of
'AkKi01222224','AmDa11976224' 								 -- using the "OR" operator to input the individual entries
);																						


-- We have a table that contains a quality score for each visit made
-- about a water source that was assigned by a Field surveyor. 
-- They assigned a score to each source from 1, being terrible, to 10 for a
-- good, clean water source in a home. Shared taps are not rated as high, 
-- and the score also depends on how long the queue times are.

-- So please write a query to find records where the subject_quality_score 
-- is 10 -- only looking for home taps -- and where the source was visited a second time.


SELECT * 
FROM 
	water_quality
WHERE
	subjective_quality_score =10
AND
	visit_count = 2;


-- Did you notice that we recorded contamination/pollution data for all of the well sources? 
-- Find the right table and print the first few rows. Find the right table and print the first few rows.


select 
	*
from
	well_pollution
limit 10;


-- So, write a query that checks if the results is Clean but the biological column is > 0.01.


select 
	*
from
	md_water_services.well_pollution
where 
	biological > 0.01
and
	results = 'Clean';


-- We need to identify the records that mistakenly have the word Clean in the description. 


select 
	*
from
	md_water_services.well_pollution
where 
	biological > 0.01
and
	results = 'Clean'
and	
	description like 'Clean%';
    
    
-- Looking at the results we can see two different descriptions that we need to fix:
-- 1. All records that mistakenly have Clean Bacteria: E. coli should updated to Bacteria: E. coli
-- 2. All records that mistakenly have Clean Bacteria: Giardia Lamblia should updated to Bacteria: Giardia Lamblia
-- We need to update the results column from Clean to 
-- Contaminated: Biological where the biological column has a value greater than 0.01.

-- Now, when we change any data on the database, we need to be SURE there are no errors, as this could fill the 
-- database with incorrect values. A safer way to do the UPDATE is by testing the changes on a copy of the table first.


CREATE TABLE
md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
md_water_services.well_pollution
);


UPDATE
	well_pollution_copy
SET
	description ='Bacteria: E. coli'
WHERE
	description = 'Clean Bacteria: E. coli';


UPDATE
	well_pollution_copy
SET
	description ='Bacteria: Giardia Lamblia'
WHERE
	description = 'Clean Bacteria: Giardia Lamblia';


UPDATE
well_pollution_copy
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';


-- We can then check if our errors are fixed using a SELECT query on the well_pollution_copy table:


SELECT
*
FROM
well_pollution_copy
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);


-- Then if we're sure it works as intended, we can change the table 
-- back to the well_pollution and delete the well_pollution_copy table.


UPDATE
	well_pollution
SET
	description ='Bacteria: E. coli'
WHERE
	description = 'Clean Bacteria: E. coli';


UPDATE
	well_pollution
SET
	description ='Bacteria: Giardia Lamblia'
WHERE
	description = 'Clean Bacteria: Giardia Lamblia';


UPDATE
well_pollution
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';


DROP TABLE
md_water_services.well_pollution_copy;   


-- final check


SELECT
*
FROM
well_pollution
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);































































