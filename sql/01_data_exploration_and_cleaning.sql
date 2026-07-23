/*
=====================================================================
Project      : Maji Ndogo Water Crisis Analysis
File    : 01_data_exploration_and_cleaning.sql
Database     : md_water_services
IDE          : MySQL Workbench

Description:
This script performs the initial exploration of the Maji Ndogo
database, investigates data quality issues, and cleans incorrect
well pollution records before downstream analysis.
=========================================================
*/

-- =====================================================
-- STEP 1: Explore the Database Structure
-- =====================================================

SHOW TABLES;

SELECT * FROM data_dictionary LIMIT 5;
SELECT * FROM employee LIMIT 5;
SELECT * FROM global_water_access LIMIT 5;
SELECT * FROM location LIMIT 5;
SELECT * FROM visits LIMIT 5;
SELECT * FROM water_quality LIMIT 5;
SELECT * FROM water_source LIMIT 5;
SELECT * FROM well_pollution LIMIT 5;

-- =====================================================
-- STEP 2: Explore Water Source Categories
-- =====================================================

SELECT DISTINCT type_of_water_source
FROM water_source;

-- =====================================================
-- STEP 3: Investigate Long Queue Times
-- =====================================================

SELECT *
FROM visits
WHERE time_in_queue > 500;

SELECT *
FROM water_source
WHERE source_id IN (
    'SoRu35083224','KiRu28520224','AkRu05296224','AkRu06938224',
    'AkLu01628224','SoRu39205224','AkRu03567224','AkKi01265224',
    'AkKi01222224','AmDa11976224'
);

SELECT *
FROM visits
WHERE source_id IN (
    'SoRu35083224','KiRu28520224','AkRu05296224','AkRu06938224',
    'AkLu01628224','SoRu39205224','AkRu03567224','AkKi01265224',
    'AkKi01222224','AmDa11976224'
);

-- =====================================================
-- STEP 4: Review Water Quality Assessments
-- =====================================================

SELECT *
FROM water_quality
WHERE subjective_quality_score = 10
  AND visit_count = 2;

-- =====================================================
-- STEP 5: Inspect Well Pollution Records
-- =====================================================

SELECT *
FROM well_pollution
LIMIT 10;

SELECT *
FROM md_water_services.well_pollution
WHERE biological > 0.01
  AND results = 'Clean';

SELECT *
FROM md_water_services.well_pollution
WHERE biological > 0.01
  AND results = 'Clean'
  AND description LIKE 'Clean%';

-- =====================================================
-- STEP 6: Safely Test Data Cleaning on a Copy
-- =====================================================

CREATE TABLE md_water_services.well_pollution_copy AS
SELECT *
FROM md_water_services.well_pollution;

UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
  AND results = 'Clean';

-- Validate the test updates.

SELECT *
FROM well_pollution_copy
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);

-- =====================================================
-- STEP 7: Apply Data Cleaning to the Production Table
-- =====================================================

UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
  AND results = 'Clean';

DROP TABLE md_water_services.well_pollution_copy;

-- =====================================================
-- STEP 8: Final Validation
-- =====================================================

SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%'
   OR (results = 'Clean' AND biological > 0.01);
