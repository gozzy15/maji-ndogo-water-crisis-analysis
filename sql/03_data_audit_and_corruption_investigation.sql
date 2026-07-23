/*
===============================================================================
Project      : Maji Ndogo Water Crisis Analysis
File         : 03_data_audit_and_corruption_investigation.sql
Database     : md_water_services
SQL Dialect  : MySQL
===============================================================================

DESCRIPTION
-----------
This script imports the independent auditor's assessment into the
database and verifies that the data was successfully loaded.

OBJECTIVES
----------
1. Create the auditor_report table.
2. Import the auditor CSV file.
3. Verify that the imported data is complete.
4. Perform an initial inspection of the dataset.
===============================================================================
*/

USE md_water_services;

-- ============================================================================
-- SECTION 1: Create Auditor Report Table
-- ============================================================================

DROP TABLE IF EXISTS auditor_report;

CREATE TABLE auditor_report (
    location_id VARCHAR(32),
    type_of_water_source VARCHAR(64),
    true_water_source_score INT DEFAULT NULL,
    statements VARCHAR(255)
);

/*
Import the supplied CSV file using MySQL Workbench:

Server
    → Table Data Import Wizard

Source File:
    auditor_report.csv

Destination Table:
    auditor_report
*/

SELECT
    *
FROM auditor_report;

/*
The imported audit dataset contains:

• Location ID
• Water Source Type
• Independent Water Quality Score
• Community Statements

These records serve as the independent benchmark used to validate
the original field survey conducted by Maji Ndogo surveyors.
*/

-- ============================================================================
-- SECTION 2: audit_score_validation
-- ============================================================================
SELECT
    location_id,
    true_water_source_score
FROM auditor_report;

SELECT
    v.location_id,
    v.record_id,
    a.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score
FROM auditor_report AS a
JOIN visits AS v
    ON a.location_id = v.location_id
JOIN water_quality AS wq
    ON v.record_id = wq.record_id;

SELECT
    v.location_id,
    v.record_id,
    a.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score
FROM auditor_report a
JOIN visits v ON a.location_id=v.location_id
JOIN water_quality wq ON v.record_id=wq.record_id
WHERE v.visit_count=1
AND a.true_water_source_score=wq.subjective_quality_score;

SELECT
    v.location_id,
    v.record_id,
    a.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score
FROM auditor_report a
JOIN visits v ON a.location_id=v.location_id
JOIN water_quality wq ON v.record_id=wq.record_id
WHERE v.visit_count=1
AND a.true_water_source_score<>wq.subjective_quality_score;

SELECT
    v.location_id,
    a.type_of_water_source AS auditor_source,
    ws.type_of_water_source AS survey_source,
    a.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score
FROM auditor_report a
JOIN visits v ON a.location_id=v.location_id
JOIN water_quality wq ON v.record_id=wq.record_id
JOIN water_source ws ON v.source_id=ws.source_id
WHERE v.visit_count=1
AND a.true_water_source_score<>wq.subjective_quality_score;

-- ============================================================================
-- SECTION 3: employee_error_analysis
-- ============================================================================

SELECT
    v.location_id,
    v.record_id,
    e.employee_name,
    a.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score
FROM auditor_report AS a
JOIN visits AS v
    ON a.location_id = v.location_id
JOIN water_quality AS wq
    ON v.record_id = wq.record_id
JOIN employee AS e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE
    v.visit_count = 1
    AND a.true_water_source_score <> wq.subjective_quality_score;

WITH incorrect_records AS (
    SELECT
        v.location_id,
        v.record_id,
        e.employee_name,
        a.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS surveyor_score
    FROM auditor_report a
    JOIN visits v
        ON a.location_id = v.location_id
    JOIN water_quality wq
        ON v.record_id = wq.record_id
    JOIN employee e
        ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        v.visit_count = 1
        AND a.true_water_source_score <> wq.subjective_quality_score
)

SELECT *
FROM incorrect_records;

WITH incorrect_records AS (
    SELECT
        v.location_id,
        v.record_id,
        e.employee_name,
        a.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS surveyor_score
    FROM auditor_report a
    JOIN visits v
        ON a.location_id = v.location_id
    JOIN water_quality wq
        ON v.record_id = wq.record_id
    JOIN employee e
        ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        v.visit_count = 1
        AND a.true_water_source_score <> wq.subjective_quality_score
)

SELECT DISTINCT
    employee_name
FROM incorrect_records
ORDER BY employee_name;

WITH incorrect_records AS (
    SELECT
        v.location_id,
        v.record_id,
        e.employee_name,
        a.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS surveyor_score
    FROM auditor_report a
    JOIN visits v
        ON a.location_id = v.location_id
    JOIN water_quality wq
        ON v.record_id = wq.record_id
    JOIN employee e
        ON v.assigned_employee_id = e.assigned_employee_id
    WHERE
        v.visit_count = 1
        AND a.true_water_source_score <> wq.subjective_quality_score
)

SELECT
    employee_name,
    COUNT(*) AS number_of_mistakes
FROM incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes DESC;

-- ============================================================================
-- SECTION 4: Create Incorrect Records View
-- ============================================================================

DROP VIEW IF EXISTS Incorrect_records;

CREATE VIEW Incorrect_records AS
SELECT
    a.location_id,
    v.record_id,
    e.employee_name,
    a.true_water_source_score AS auditor_score,
    wq.subjective_quality_score AS surveyor_score,
    a.statements
FROM auditor_report AS a
JOIN visits AS v
    ON a.location_id = v.location_id
JOIN water_quality AS wq
    ON v.record_id = wq.record_id
JOIN employee AS e
    ON v.assigned_employee_id = e.assigned_employee_id
WHERE
    v.visit_count = 1
    AND a.true_water_source_score <> wq.subjective_quality_score;

SELECT
    *
FROM Incorrect_records;

SELECT
    employee_name,
    COUNT(*) AS number_of_mistakes
FROM Incorrect_records
GROUP BY employee_name
ORDER BY number_of_mistakes DESC;

-- ============================================================================
-- SECTION 5: suspect_identification
-- ============================================================================

WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
)
SELECT *
FROM error_count
ORDER BY number_of_mistakes DESC;

WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
)
SELECT
    AVG(number_of_mistakes) AS average_mistakes_per_employee
FROM error_count;

WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
)
SELECT
    employee_name,
    number_of_mistakes
FROM error_count
WHERE number_of_mistakes >
(
    SELECT AVG(number_of_mistakes)
    FROM error_count
)
ORDER BY number_of_mistakes DESC;

-- ============================================================================
-- SECTION 6: Corruption Investigation
-- ============================================================================
-- Count mistakes per employee
WITH error_count AS (
    SELECT
        employee_name,
        COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
),

-- Employees with above-average mistakes
suspect_list AS (
    SELECT
        employee_name,
        number_of_mistakes
    FROM error_count
    WHERE number_of_mistakes >
        (SELECT AVG(number_of_mistakes) FROM error_count)
)

-- Review records for suspected employees
SELECT
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name IN (
    SELECT employee_name FROM suspect_list
);

-- Review bribery-related statements
WITH error_count AS (
    SELECT employee_name, COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT employee_name, number_of_mistakes
    FROM error_count
    WHERE number_of_mistakes >
        (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name IN (
    SELECT employee_name FROM suspect_list
)
AND statements LIKE '%cash%';

-- Confirm no non-suspects have bribery allegations
WITH error_count AS (
    SELECT employee_name, COUNT(*) AS number_of_mistakes
    FROM Incorrect_records
    GROUP BY employee_name
),
suspect_list AS (
    SELECT employee_name, number_of_mistakes
    FROM error_count
    WHERE number_of_mistakes >
        (SELECT AVG(number_of_mistakes) FROM error_count)
)
SELECT
    employee_name,
    location_id,
    statements
FROM Incorrect_records
WHERE employee_name NOT IN (
    SELECT employee_name FROM suspect_list
)
AND statements LIKE '%cash%';

/*
Conclusion:
- Four employees exhibited above-average error rates.
- Only these employees had statements mentioning cash/bribery.
- Evidence supports further investigation.
*/