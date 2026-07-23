/*==============================================================
MAJI NDOGO WATER SERVICES
PART 4 – WATER ACCESS ANALYSIS

SECTION 1: BUILD BASE ANALYSIS DATASET

Objective:
Create a unified dataset containing location information,
water source details, queue times, population served,
and well pollution results for subsequent analysis.
==============================================================*/


-- ============================================================
-- Step 1: Join Locations with Visits
-- ============================================================

SELECT
    l.province_name,
    l.town_name,
    v.visit_count,
    v.location_id
FROM location AS l
INNER JOIN visits AS v
    ON l.location_id = v.location_id;


-- ============================================================
-- Step 2: Add Water Source Information
-- ============================================================

SELECT
    l.province_name,
    l.town_name,
    v.visit_count,
    v.location_id,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM location AS l
INNER JOIN visits AS v
    ON l.location_id = v.location_id
INNER JOIN water_source AS ws
    ON v.source_id = ws.source_id;


-- ============================================================
-- Step 3: Inspect Duplicate Visits
-- ============================================================

SELECT
    l.province_name,
    l.town_name,
    v.visit_count,
    v.location_id,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM location AS l
INNER JOIN visits AS v
    ON l.location_id = v.location_id
INNER JOIN water_source AS ws
    ON v.source_id = ws.source_id
WHERE v.location_id = 'AkHa00103';


-- ============================================================
-- Step 4: Keep Only Initial Visits
-- ============================================================

SELECT
    l.province_name,
    l.town_name,
    v.visit_count,
    v.location_id,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM location AS l
INNER JOIN visits AS v
    ON l.location_id = v.location_id
INNER JOIN water_source AS ws
    ON v.source_id = ws.source_id
WHERE v.visit_count = 1;


-- ============================================================
-- Step 5: Prepare Analysis Dataset
-- ============================================================

SELECT
    l.province_name,
    l.town_name,
    ws.type_of_water_source,
    l.location_type,
    ws.number_of_people_served,
    v.time_in_queue
FROM location AS l
INNER JOIN visits AS v
    ON l.location_id = v.location_id
INNER JOIN water_source AS ws
    ON v.source_id = ws.source_id
WHERE v.visit_count = 1;


-- ============================================================
-- Step 6: Include Well Pollution Results
-- ============================================================

SELECT
    ws.type_of_water_source,
    l.province_name,
    l.town_name,
    l.location_type,
    ws.number_of_people_served,
    v.time_in_queue,
    wp.results
FROM visits AS v
LEFT JOIN well_pollution AS wp
    ON wp.source_id = v.source_id
INNER JOIN location AS l
    ON l.location_id = v.location_id
INNER JOIN water_source AS ws
    ON ws.source_id = v.source_id
WHERE v.visit_count = 1;


/*====================================================================
  SECTION 02: CREATE COMBINED ANALYSIS VIEW
  --------------------------------------------------------------------
  Purpose:
  Create a reusable view that consolidates all key datasets required
  for the final water access analysis across Maji Ndogo.
====================================================================*/

DROP VIEW IF EXISTS combined_analysis_table;

CREATE VIEW combined_analysis_table AS

SELECT
    ws.type_of_water_source        AS source_type,
    l.town_name,
    l.province_name,
    l.location_type,
    ws.number_of_people_served     AS people_served,
    v.time_in_queue,
    wp.results

FROM visits AS v

LEFT JOIN well_pollution AS wp
       ON v.source_id = wp.source_id

INNER JOIN location AS l
        ON v.location_id = l.location_id

INNER JOIN water_source AS ws
        ON v.source_id = ws.source_id

WHERE
    v.visit_count = 1;
    
    
    
/*====================================================================
  SECTION 03: PROVINCIAL WATER ACCESS ANALYSIS
  --------------------------------------------------------------------
  Purpose:
  Calculate the percentage of people using each water source type
  within every province.
====================================================================*/

WITH province_totals AS (
    SELECT
        province_name,
        SUM(people_served) AS total_people_served
    FROM combined_analysis_table
    GROUP BY province_name
)

SELECT
    cat.province_name,

    ROUND(
        SUM(CASE
                WHEN source_type = 'river'
                THEN people_served
                ELSE 0
            END) * 100.0 / pt.total_people_served,
        0
    ) AS river,

    ROUND(
        SUM(CASE
                WHEN source_type = 'shared_tap'
                THEN people_served
                ELSE 0
            END) * 100.0 / pt.total_people_served,
        0
    ) AS shared_tap,

    ROUND(
        SUM(CASE
                WHEN source_type = 'tap_in_home'
                THEN people_served
                ELSE 0
            END) * 100.0 / pt.total_people_served,
        0
    ) AS tap_in_home,

    ROUND(
        SUM(CASE
                WHEN source_type = 'tap_in_home_broken'
                THEN people_served
                ELSE 0
            END) * 100.0 / pt.total_people_served,
        0
    ) AS tap_in_home_broken,

    ROUND(
        SUM(CASE
                WHEN source_type = 'well'
                THEN people_served
                ELSE 0
            END) * 100.0 / pt.total_people_served,
        0
    ) AS well

FROM combined_analysis_table AS cat

INNER JOIN province_totals AS pt
        ON cat.province_name = pt.province_name

GROUP BY
    cat.province_name

ORDER BY
    cat.province_name;
    
    
    
/*====================================================================
  SECTION 04: TOWN-LEVEL WATER ACCESS ANALYSIS
  --------------------------------------------------------------------
  Purpose:
  Calculate the percentage of people using each water source type
  within every town, while accounting for duplicate town names
  across different provinces.
====================================================================*/

WITH town_totals AS (
    SELECT
        province_name,
        town_name,
        SUM(people_served) AS total_people_served
    FROM combined_analysis_table
    GROUP BY
        province_name,
        town_name
)

SELECT
    cat.province_name,
    cat.town_name,

    ROUND(
        SUM(CASE
                WHEN source_type = 'river'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS river,

    ROUND(
        SUM(CASE
                WHEN source_type = 'shared_tap'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS shared_tap,

    ROUND(
        SUM(CASE
                WHEN source_type = 'tap_in_home'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS tap_in_home,

    ROUND(
        SUM(CASE
                WHEN source_type = 'tap_in_home_broken'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS tap_in_home_broken,

    ROUND(
        SUM(CASE
                WHEN source_type = 'well'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS well

FROM combined_analysis_table AS cat

INNER JOIN town_totals AS tt
        ON cat.province_name = tt.province_name
       AND cat.town_name = tt.town_name

GROUP BY
    cat.province_name,
    cat.town_name

ORDER BY
    cat.town_name;
    
    
    
/*====================================================================
  SECTION 05: CREATE TEMPORARY TOWN AGGREGATION TABLE
  --------------------------------------------------------------------
  Purpose:
  Store the town-level water access analysis in a temporary table to
  improve performance for subsequent analyses.
====================================================================*/

DROP TEMPORARY TABLE IF EXISTS town_aggregated_water_access;

CREATE TEMPORARY TABLE town_aggregated_water_access AS

WITH town_totals AS (
    SELECT
        province_name,
        town_name,
        SUM(people_served) AS total_people_served
    FROM combined_analysis_table
    GROUP BY
        province_name,
        town_name
)

SELECT
    cat.province_name,
    cat.town_name,

    ROUND(
        SUM(CASE
                WHEN source_type = 'river'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS river,

    ROUND(
        SUM(CASE
                WHEN source_type = 'shared_tap'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS shared_tap,

    ROUND(
        SUM(CASE
                WHEN source_type = 'tap_in_home'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS tap_in_home,

    ROUND(
        SUM(CASE
                WHEN source_type = 'tap_in_home_broken'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS tap_in_home_broken,

    ROUND(
        SUM(CASE
                WHEN source_type = 'well'
                THEN people_served
                ELSE 0
            END) * 100.0 / tt.total_people_served,
        0
    ) AS well

FROM combined_analysis_table AS cat

INNER JOIN town_totals AS tt
        ON cat.province_name = tt.province_name
       AND cat.town_name = tt.town_name

GROUP BY
    cat.province_name,
    cat.town_name

ORDER BY
    cat.town_name;


/*====================================================================
  INFRASTRUCTURE ASSESSMENT
  --------------------------------------------------------------------
  Calculate the percentage of broken household taps for each town.
====================================================================*/

SELECT
    province_name,
    town_name,
    ROUND(
        tap_in_home_broken /
        (tap_in_home_broken + tap_in_home) * 100,
        0
    ) AS pct_broken_taps

FROM town_aggregated_water_access

ORDER BY
    pct_broken_taps DESC,
    province_name,
    town_name;
    
    
    
/*=====================================================================
  06. INFRASTRUCTURE ASSESSMENT & IMPROVEMENT STRATEGY
  ---------------------------------------------------------------------
  Objective:
  Identify infrastructure weaknesses by calculating the percentage of
  broken household tap systems in every town.
=====================================================================*/

SELECT
    province_name,
    town_name,
    ROUND(
        tap_in_home_broken /
        (tap_in_home_broken + tap_in_home) * 100,
        0
    ) AS pct_broken_taps
FROM
    town_aggregated_water_access
ORDER BY
    pct_broken_taps DESC,
    province_name,
    town_name;
    
    
/*=====================================================================
  PROJECT SUMMARY
  ---------------------------------------------------------------------
  Key Findings
=====================================================================*/

-- 1. Most water sources are located in rural communities.

-- 2. Approximately 43% of the population depends on shared taps,
--    with many serving around 2,000 people each.

-- 3. Roughly 31% of citizens have taps installed at home.

-- 4. Nearly 45% of household water infrastructure is non-functional,
--    largely due to damaged pipes, pumps, or reservoirs.

-- 5. About 18% of the population relies on wells,
--    but only around 28% of those wells provide clean water.

-- 6. Average water collection queues exceed two hours,
--    with Saturdays and peak morning/evening periods experiencing
--    the longest waiting times.


/*=====================================================================
  RECOMMENDED IMPROVEMENT STRATEGY
=====================================================================*/

-- Prioritize upgrades that benefit the largest number of people.

-- 1. Expand shared tap infrastructure.

-- 2. Repair and rehabilitate contaminated wells.

-- 3. Restore damaged water infrastructure where possible.

-- 4. Delay large-scale household tap installations where queue times
--    are already acceptable.

-- 5. Prioritize rural communities due to limited infrastructure
--    and difficult access conditions.
    
    
    
/*=====================================================================
  07. PROJECT PROGRESS TRACKING TABLE
  ---------------------------------------------------------------------
  Purpose:
  Store all planned infrastructure improvement projects and allow
  engineering teams to update implementation progress.
=====================================================================*/

DROP TABLE IF EXISTS project_progress;

CREATE TABLE project_progress (

    project_id SERIAL PRIMARY KEY,

    -- Water source to be upgraded
    source_id VARCHAR(20) NOT NULL
        REFERENCES water_source(source_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- Location details
    address VARCHAR(50),
    town VARCHAR(30),
    province VARCHAR(30),

    -- Water source information
    source_type VARCHAR(50),

    -- Planned intervention
    improvement VARCHAR(100),

    -- Project workflow status
    source_status VARCHAR(20)
        DEFAULT 'Backlog'
        CHECK (
            source_status IN (
                'Backlog',
                'In Progress',
                'Complete'
            )
        ),

    -- Completion details
    date_of_completion DATE,

    -- Engineer notes
    comments TEXT
);

/*=====================================================================
  VERIFY TABLE STRUCTURE
=====================================================================*/

DESCRIBE project_progress;

/*=====================================================================
  REVIEW EMPTY TABLE
=====================================================================*/

SELECT *
FROM project_progress;



/*=====================================================================
  08. BUILD PROJECT IMPROVEMENT QUERY
  ---------------------------------------------------------------------
  Purpose:
  Retrieve every water source that requires intervention together with
  its location and pollution information.
=====================================================================*/

SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results
FROM water_source AS ws

LEFT JOIN well_pollution AS wp
       ON ws.source_id = wp.source_id

INNER JOIN visits AS v
        ON ws.source_id = v.source_id

INNER JOIN location AS l
        ON v.location_id = l.location_id;

/*=====================================================================
  FILTER SOURCES THAT REQUIRE IMPROVEMENT

  Include only:
    • First survey visit
    • Contaminated wells
    • Rivers
    • Broken household taps
    • Shared taps with queue time ≥ 30 minutes
=====================================================================*/

SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results
FROM water_source AS ws

LEFT JOIN well_pollution AS wp
       ON ws.source_id = wp.source_id

INNER JOIN visits AS v
        ON ws.source_id = v.source_id

INNER JOIN location AS l
        ON v.location_id = l.location_id

WHERE
    v.visit_count = 1
    AND (
            wp.results <> 'Clean'

         OR ws.type_of_water_source IN (
                'river',
                'tap_in_home_broken'
            )

         OR (
                ws.type_of_water_source = 'shared_tap'
                AND v.time_in_queue >= 30
            )
    );
    
/*=====================================================================
  EXPECTED RESULT

  Approximately 25,398 records should be returned.
=====================================================================*/



/*=====================================================================
  09. DEFINE IMPROVEMENT ACTIONS
  ---------------------------------------------------------------------
  Purpose:
  Assign the appropriate intervention for every water source that
  requires improvement.
=====================================================================*/

SELECT
    l.address,
    l.town_name,
    l.province_name,
    ws.source_id,
    ws.type_of_water_source,
    wp.results,

    CASE

        /* Contaminated Wells */
        WHEN wp.results = 'Contaminated: Biological'
            THEN 'Install UV and RO filter'

        WHEN wp.results = 'Contaminated: Chemical'
            THEN 'Install RO filter'

        /* Rivers */
        WHEN ws.type_of_water_source = 'river'
            THEN 'Drill well'

        /* Shared Taps */
        WHEN ws.type_of_water_source = 'shared_tap'
            THEN CONCAT(
                'Install ',
                FLOOR(v.time_in_queue / 30),
                ' tap(s) nearby'
            )

        /* Broken Household Taps */
        WHEN ws.type_of_water_source = 'tap_in_home_broken'
            THEN 'Diagnose local infrastructure'

        ELSE NULL

    END AS improvement

FROM water_source AS ws

LEFT JOIN well_pollution AS wp
       ON ws.source_id = wp.source_id

INNER JOIN visits AS v
        ON ws.source_id = v.source_id

INNER JOIN location AS l
        ON v.location_id = l.location_id

WHERE
    v.visit_count = 1
    AND (
            wp.results <> 'Clean'

         OR ws.type_of_water_source IN (
                'river',
                'tap_in_home_broken'
            )

         OR (
                ws.type_of_water_source = 'shared_tap'
                AND v.time_in_queue >= 30
            )
    );
    
    
    
/*=====================================================================
  10. POPULATE PROJECT_PROGRESS TABLE
  ---------------------------------------------------------------------
  Purpose:
  Insert all identified infrastructure improvement projects into the
  project_progress table.
=====================================================================*/

INSERT INTO project_progress (
    source_id,
    address,
    town,
    province,
    source_type,
    improvement
)

SELECT
    ws.source_id,
    l.address,
    l.town_name,
    l.province_name,
    ws.type_of_water_source,

    CASE

        /* Contaminated Wells */
        WHEN wp.results = 'Contaminated: Biological'
            THEN 'Install UV and RO filter'

        WHEN wp.results = 'Contaminated: Chemical'
            THEN 'Install RO filter'

        /* Rivers */
        WHEN ws.type_of_water_source = 'river'
            THEN 'Drill well'

        /* Shared Taps */
        WHEN ws.type_of_water_source = 'shared_tap'
            THEN CONCAT(
                'Install ',
                FLOOR(v.time_in_queue / 30),
                ' tap(s) nearby'
            )

        /* Broken Household Taps */
        WHEN ws.type_of_water_source = 'tap_in_home_broken'
            THEN 'Diagnose local infrastructure'

        ELSE NULL

    END AS improvement

FROM water_source AS ws

LEFT JOIN well_pollution AS wp
       ON ws.source_id = wp.source_id

INNER JOIN visits AS v
        ON ws.source_id = v.source_id

INNER JOIN location AS l
        ON v.location_id = l.location_id

WHERE
    v.visit_count = 1
    AND (
            wp.results <> 'Clean'

         OR ws.type_of_water_source IN (
                'river',
                'tap_in_home_broken'
            )

         OR (
                ws.type_of_water_source = 'shared_tap'
                AND v.time_in_queue >= 30
            )
    );
    
/*=====================================================================
  VERIFY INSERTED PROJECTS
=====================================================================*/

SELECT *
FROM project_progress;

/*=====================================================================
  RESET PROJECT_PROGRESS TABLE (OPTIONAL)

  Use this section if you need to recreate the table and reload all
  improvement records.
=====================================================================*/

DROP TABLE IF EXISTS project_progress;

CREATE TABLE project_progress (

    project_id SERIAL PRIMARY KEY,

    source_id VARCHAR(20) NOT NULL
        REFERENCES water_source(source_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    address VARCHAR(50),
    town VARCHAR(30),
    province VARCHAR(30),

    source_type VARCHAR(50),

    improvement VARCHAR(100),

    source_status VARCHAR(20)
        DEFAULT 'Backlog'
        CHECK (
            source_status IN (
                'Backlog',
                'In Progress',
                'Complete'
            )
        ),

    date_of_completion DATE,

    comments TEXT
);

INSERT INTO project_progress (
    source_id,
    address,
    town,
    province,
    source_type,
    improvement
)

SELECT
    ws.source_id,
    l.address,
    l.town_name,
    l.province_name,
    ws.type_of_water_source,

    CASE

        WHEN wp.results = 'Contaminated: Biological'
            THEN 'Install UV and RO filter'

        WHEN wp.results = 'Contaminated: Chemical'
            THEN 'Install RO filter'

        WHEN ws.type_of_water_source = 'river'
            THEN 'Drill well'

        WHEN ws.type_of_water_source = 'shared_tap'
            THEN CONCAT(
                'Install ',
                FLOOR(v.time_in_queue / 30),
                ' tap(s) nearby'
            )

        WHEN ws.type_of_water_source = 'tap_in_home_broken'
            THEN 'Diagnose local infrastructure'

        ELSE NULL

    END AS improvement

FROM water_source AS ws

LEFT JOIN well_pollution AS wp
       ON ws.source_id = wp.source_id

INNER JOIN visits AS v
        ON ws.source_id = v.source_id

INNER JOIN location AS l
        ON v.location_id = l.location_id

WHERE
    v.visit_count = 1
    AND (
            wp.results <> 'Clean'

         OR ws.type_of_water_source IN (
                'river',
                'tap_in_home_broken'
            )

         OR (
                ws.type_of_water_source = 'shared_tap'
                AND v.time_in_queue >= 30
            )
    );
    
-- *THE END*