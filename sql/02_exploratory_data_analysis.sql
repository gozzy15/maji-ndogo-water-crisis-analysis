/*
=====================================================================
Project      : Maji Ndogo Water Crisis Analysis
File         : 02_exploratory_data_analysis.sql
Database     : md_water_services
IDE          : MySQL Workbench

Description:
Professional rewrite of the Employee Data Preparation section.
=====================================================================
*/

-- =================================================================
-- SECTION 1: EMPLOYEE DATA PREPARATION
-- =================================================================

-- Review employee records before performing data cleaning.

SELECT
    assigned_employee_id,
    employee_name,
    email,
    phone_number,
    town_name
FROM employee;

-- -----------------------------------------------------------------
-- Generate standardized employee email addresses
-- -----------------------------------------------------------------

SELECT
    employee_name,
    CONCAT(
        LOWER(REPLACE(employee_name,' ','.')),
        '@ndogowater.gov'
    ) AS generated_email
FROM employee;

UPDATE employee
SET email = CONCAT(
    LOWER(REPLACE(employee_name,' ','.')),
    '@ndogowater.gov'
);

-- -----------------------------------------------------------------
-- Standardize employee phone numbers
-- -----------------------------------------------------------------

SELECT
    employee_name,
    phone_number,
    LENGTH(phone_number) AS phone_number_length,
    TRIM(phone_number) AS cleaned_phone_number
FROM employee;

UPDATE employee
SET phone_number = TRIM(phone_number);

-- -----------------------------------------------------------------
-- Verify cleaned employee records
-- -----------------------------------------------------------------

SELECT
    assigned_employee_id,
    employee_name,
    email,
    phone_number,
    town_name
FROM employee;


-- =================================================================
-- SECTION 2: EMPLOYEE & WORKFORCE ANALYSIS
-- =================================================================

-- Employee distribution by town.
SELECT
    town_name,
    COUNT(*) AS employee_count
FROM employee
GROUP BY town_name
ORDER BY employee_count DESC, town_name;

-- Review visit records used for workload analysis.
SELECT
    assigned_employee_id,
    source_id,
    visit_count,
    time_of_record
FROM visits;

-- Total visits completed by each field surveyor.
SELECT
    assigned_employee_id,
    COUNT(visit_count) AS total_visit_count
FROM visits
GROUP BY assigned_employee_id
ORDER BY total_visit_count DESC;

-- Top three field surveyors by completed visits.
SELECT
    assigned_employee_id,
    COUNT(visit_count) AS total_visit_count
FROM visits
GROUP BY assigned_employee_id
ORDER BY total_visit_count DESC
LIMIT 3;

-- Retrieve contact details for the top-performing surveyors.
SELECT
    assigned_employee_id,
    employee_name,
    email,
    phone_number,
    town_name
FROM employee
WHERE assigned_employee_id IN (1,30,34)
ORDER BY assigned_employee_id;


-- =================================================================
-- SECTION 3: GEOGRAPHIC DISTRIBUTION ANALYSIS
-- =================================================================

-- Records collected per town.
SELECT
    town_name,
    COUNT(*) AS records_per_town
FROM location
GROUP BY town_name
ORDER BY records_per_town DESC, town_name;

-- Records collected per province.
SELECT
    province_name,
    COUNT(*) AS records_per_province
FROM location
GROUP BY province_name
ORDER BY records_per_province DESC, province_name;

-- Survey coverage by province and town.
SELECT
    province_name,
    town_name,
    COUNT(*) AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name, records_per_town DESC;

-- Distribution of surveyed location types.
SELECT
    location_type,
    COUNT(*) AS number_of_locations
FROM location
GROUP BY location_type
ORDER BY number_of_locations DESC, location_type;


-- =================================================================
-- SECTION 4: WATER SOURCE STATISTICS
-- =================================================================

-- -----------------------------------------------------------------
-- Total population served
-- -----------------------------------------------------------------

SELECT
    SUM(number_of_people_served) AS total_people_surveyed
FROM water_source;


-- -----------------------------------------------------------------
-- Number of water sources by type
-- -----------------------------------------------------------------

SELECT
    type_of_water_source,
    COUNT(*) AS source_count
FROM water_source
GROUP BY type_of_water_source
ORDER BY source_count DESC;


-- -----------------------------------------------------------------
-- Average number of people served per water source
-- -----------------------------------------------------------------

SELECT
    type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS average_people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY average_people_served DESC;


-- -----------------------------------------------------------------
-- Population served by each water source type
-- -----------------------------------------------------------------

SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS population_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY population_served DESC;


-- -----------------------------------------------------------------
-- Percentage of total population served
-- -----------------------------------------------------------------

SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS population_served,
    ROUND(
        SUM(number_of_people_served) /
        (SELECT SUM(number_of_people_served) FROM water_source) * 100,
        0
    ) AS percentage_population_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY percentage_population_served DESC;


-- -----------------------------------------------------------------
-- Rank water source types by population served
-- -----------------------------------------------------------------

SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS population_served,
    ROUND(
        SUM(number_of_people_served) /
        (SELECT SUM(number_of_people_served) FROM water_source) * 100,
        0
    ) AS percentage_population_served,
    RANK() OVER (
        ORDER BY SUM(number_of_people_served) DESC
    ) AS population_rank
FROM water_source
GROUP BY type_of_water_source
ORDER BY population_rank;


-- =================================================================
-- SECTION 5: INFRASTRUCTURE PRIORITIZATION
-- =================================================================

-- Rank all water sources by demand within each source type.
SELECT
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS priority_rank
FROM water_source
ORDER BY type_of_water_source, priority_rank;

-- Focus on improvable source types.
SELECT
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS priority_rank
FROM water_source
WHERE type_of_water_source IN ('Shared Tap','Well')
ORDER BY type_of_water_source, priority_rank;

-- Compare ranking methods.
SELECT
    ROW_NUMBER() OVER (ORDER BY number_of_people_served DESC) AS row_number,
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS priority_rank,
    DENSE_RANK() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS dense_priority_rank
FROM water_source
WHERE type_of_water_source IN ('Shared Tap','Well')
ORDER BY type_of_water_source, priority_rank;


-- =================================================================
-- SECTION 6: SURVEY DURATION & QUEUE ANALYSIS
-- =================================================================

-- Survey start, end and duration.
SELECT
    MIN(time_of_record) AS survey_start_date,
    MAX(time_of_record) AS survey_end_date,
    DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS survey_duration_days
FROM visits;

-- Overall average queue time (excluding zero-minute queues).
SELECT
    ROUND(AVG(NULLIF(time_in_queue,0))) AS average_queue_time_minutes
FROM visits;

-- Average queue time by day of week.
SELECT
    DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(NULLIF(time_in_queue,0))) AS average_queue_time_minutes
FROM visits
GROUP BY DAYNAME(time_of_record)
ORDER BY FIELD(
    DAYNAME(time_of_record),
    'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'
);

-- Average queue time by hour of day.
SELECT
    TIME_FORMAT(TIME(time_of_record),'%H:00') AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue,0))) AS average_queue_time_minutes
FROM visits
GROUP BY hour_of_day
ORDER BY hour_of_day;


-- =================================================================
-- SECTION 7: QUEUE PATTERN (HEATMAP) ANALYSIS
-- =================================================================

SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,

    ROUND(AVG(CASE WHEN DAYNAME(time_of_record)='Sunday' THEN time_in_queue END),0) AS Sunday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record)='Monday' THEN time_in_queue END),0) AS Monday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record)='Tuesday' THEN time_in_queue END),0) AS Tuesday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record)='Wednesday' THEN time_in_queue END),0) AS Wednesday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record)='Thursday' THEN time_in_queue END),0) AS Thursday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record)='Friday' THEN time_in_queue END),0) AS Friday,
    ROUND(AVG(CASE WHEN DAYNAME(time_of_record)='Saturday' THEN time_in_queue END),0) AS Saturday

FROM visits
WHERE time_in_queue > 0
GROUP BY hour_of_day
ORDER BY hour_of_day;