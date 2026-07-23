# Methodology

---

# Table of Contents

1. [Project Overview](#1-project-overview)
2. [Business Problem](#2-business-problem)
3. [Project Objectives](#3-project-objectives)
   - [3.1 Explore and Understand the Data](#31-explore-and-understand-the-data)
   - [3.2 Validate Data Quality](#32-validate-data-quality)
   - [3.3 Evaluate Employee Performance](#33-evaluate-employee-performance)
   - [3.4 Analyze Water Source Accessibility](#34-analyze-water-source-accessibility)
   - [3.5 Assess Regional Water Infrastructure](#35-assess-regional-water-infrastructure)
   - [3.6 Evaluate Water Quality and Public Health Risks](#36-evaluate-water-quality-and-public-health-risks)
   - [3.7 Prioritize Infrastructure Improvements](#37-prioritize-infrastructure-improvements)
   - [3.8 Support Project Planning and Monitoring](#38-support-project-planning-and-monitoring)
   - [3.9 Deliver Business Intelligence for Decision-Making](#39-deliver-business-intelligence-for-decision-making)
4. [Data Sources](#4-data-sources)
   - [Data Tables](#data-tables)
   - [Central Dataset](#central-dataset)
5. [Database Schema](#5-database-schema)
   - [5.1 water_source](#51-water_source)
   - [5.2 location](#52-location)
   - [5.3 visits](#53-visits)
   - [5.4 employee](#54-employee)
   - [5.5 water_quality](#55-water_quality)
   - [5.6 well_pollution](#56-well_pollution)
   - [5.7 auditor_report](#57-auditor_report)
   - [5.8 project_progress](#58-project_progress)
   - [5.9 data_dictionary](#59-data_dictionary)
   - [Database Relationships](#database-relationships)
   - [Design Highlights](#design-highlights)
6. [Data Cleaning & Preparation](#6-data-cleaning--preparation)
   - [Data Validation](#data-validation)
   - [Duplicate Handling](#duplicate-handling)
   - [Relational Data Integration](#relational-data-integration)
   - [Data Consistency Checks](#data-consistency-checks)
   - [Derived Views and Temporary Tables](#derived-views-and-temporary-tables)
   - [Business Rule Filtering](#business-rule-filtering)
   - [Data Quality Outcome](#data-quality-outcome)
7. [Exploratory Data Analysis (EDA)](#7-exploratory-data-analysis-eda)
   - [7.1 Geographic Distribution Analysis](#71-geographic-distribution-analysis)
   - [7.2 Water Source Distribution](#72-water-source-distribution)
   - [7.3 Queue Time Analysis](#73-queue-time-analysis)
   - [7.4 Infrastructure Assessment](#74-infrastructure-assessment)
   - [7.5 Provincial Water Access Analysis](#75-provincial-water-access-analysis)
   - [7.6 Town-Level Water Access Analysis](#76-town-level-water-access-analysis)
   - [7.7 Water Quality Assessment](#77-water-quality-assessment)
   - [7.8 Preliminary Findings](#78-preliminary-findings)
8. [SQL Analysis & Business Insights](#8-sql-analysis--business-insights)
9. [Audit & Data Validation](#9-audit--data-validation)
10. [Power BI Dashboard](#10-power-bi-dashboard)
    - [Executive Performance Overview](#executive-performance-overview)
    - [Geographic Analysis](#geographic-analysis)
    - [Provincial Cost Distribution](#provincial-cost-distribution)
    - [Water Improvement Analysis](#water-improvement-analysis)
    - [Cost Analysis](#cost-analysis)
    - [Rural versus Urban Comparison](#rural-versus-urban-comparison)
    - [Vendor Performance](#vendor-performance)
    - [Time-Based Monitoring](#time-based-monitoring)
    - [AI-Powered Key Influencers Analysis](#ai-powered-key-influencers-analysis)
11. [Business Recommendations](#11-business-recommendations)
    - [11.1 Prioritize High-Impact Water Source Improvements](#111-prioritize-high-impact-water-source-improvements)
    - [11.2 Accelerate Rehabilitation of Existing Infrastructure](#112-accelerate-rehabilitation-of-existing-infrastructure)
    - [11.3 Improve Water Quality Through Targeted Treatment](#113-improve-water-quality-through-targeted-treatment)
    - [11.4 Strengthen Budget Planning and Cost Control](#114-strengthen-budget-planning-and-cost-control)
    - [11.5 Allocate Resources Based on Geographic Cost Differences](#115-allocate-resources-based-on-geographic-cost-differences)
    - [11.6 Enhance Contractor Performance Monitoring](#116-enhance-contractor-performance-monitoring)
    - [11.7 Adopt Data-Driven Decision Making](#117-adopt-data-driven-decision-making)
    - [11.8 Establish Preventive Maintenance Programs](#118-establish-preventive-maintenance-programs)
    - [11.9 Expand Interactive Business Intelligence Reporting](#119-expand-interactive-business-intelligence-reporting)
    - [11.10 Overall Recommendation](#1110-overall-recommendation)
12. [Conclusion](#12-conclusion)

---

## 1. Project Overview

The **Maji Ndogo Water Services Analysis** project is an end-to-end data analytics case study focused on evaluating water accessibility, infrastructure condition, and service delivery across the fictional country of **Maji Ndogo**. The project demonstrates how SQL and business intelligence techniques can be applied to transform raw operational data into actionable insights that support strategic decision-making.

The analysis began with a relational database containing information on water sources, employee survey records, water quality assessments, geographic locations, infrastructure status, pollution reports, and independent audit findings. Using SQL, the data was explored, validated, cleaned, and analyzed to identify trends, detect inconsistencies, and uncover operational challenges affecting access to safe drinking water.

As the project progressed, multiple analytical views, Common Table Expressions (CTEs), temporary tables, and business rules were developed to simplify complex analyses and support decision-making. The investigation included validating survey accuracy through independent audit comparisons, identifying potential data integrity issues, analyzing regional disparities in water access, and prioritizing infrastructure improvements based on their expected impact.

The final phase of the project extended beyond data analysis into operational planning. A project implementation framework was designed within the database to generate actionable infrastructure improvement plans, allowing engineering teams to track repair activities and monitor implementation progress.

To complement the SQL analysis, an interactive **Power BI dashboard** was developed to visualize more than **200 water source improvement projects** across **five provinces**. The dashboard enabled stakeholders to monitor project status, compare planned budgets with actual expenditures, evaluate regional performance, analyze urban versus rural implementation costs, and identify opportunities for improving operational efficiency.

Together, the SQL analysis and Power BI dashboard provide a comprehensive decision-support solution that enables data-driven planning, resource prioritization, infrastructure management, and long-term improvement of water services across Maji Ndogo.

---

## 2. Business Problem

Access to safe and reliable drinking water remains one of the most critical public service challenges in **Maji Ndogo**. Government agencies and water authorities are responsible for maintaining thousands of water sources across multiple provinces, yet limited resources, aging infrastructure, water contamination, and uneven service distribution have made it difficult to provide consistent access to clean water for every community.

Although large volumes of operational data had been collected by field surveyors, the information had not been fully analyzed to support evidence-based decision-making. Decision-makers lacked clear visibility into questions such as:

* Which provinces and towns have the greatest need for infrastructure improvements?
* Which water source types serve the largest proportion of the population?
* Where are citizens experiencing the longest wait times to access water?
* Which wells are contaminated and require immediate intervention?
* Which existing infrastructure can be repaired instead of replaced?
* Are the field survey data accurate and trustworthy?
* Are there operational issues or potential misconduct affecting data quality?
* How should limited budgets and engineering resources be prioritized to maximize public impact?

Without reliable analysis, infrastructure investments risk being allocated inefficiently, contaminated water sources may remain untreated, and communities with the greatest need could continue to experience poor access to safe drinking water.

This project addresses these challenges by transforming raw operational data into actionable business intelligence. Through SQL-based data validation, regional analysis, audit investigation, infrastructure assessment, and project prioritization, the analysis provides decision-makers with a structured framework for identifying critical issues, allocating resources effectively, and planning sustainable improvements to water services across Maji Ndogo.

The accompanying Power BI dashboard further supports these objectives by providing an interactive platform for monitoring infrastructure projects, tracking budgets and expenditures, evaluating regional performance, and measuring implementation progress over time.

---

## 3. Project Objectives

The primary objective of the **Maji Ndogo Water Services Analysis** project was to leverage SQL and business intelligence techniques to evaluate water accessibility, assess infrastructure conditions, validate operational data, and generate actionable recommendations that support informed decision-making and long-term service improvement.

To achieve this goal, the project focused on the following objectives:

### 3.1 Explore and Understand the Data

* Examine the structure, relationships, and quality of the available datasets.
* Understand how operational data is distributed across multiple related tables.
* Identify the key entities involved in water service delivery.

### 3.2 Validate Data Quality

* Compare field survey results with independent auditor assessments.
* Identify inconsistencies between recorded and audited water quality scores.
* Verify the integrity of water source classifications used in previous analyses.

### 3.3 Evaluate Employee Performance

* Link survey records to individual field employees.
* Measure error rates across surveyors.
* Identify employees with unusually high numbers of reporting discrepancies.
* Investigate potential misconduct using supporting audit statements.

### 3.4 Analyze Water Source Accessibility

* Determine the distribution of different water source types.
* Measure the population served by each source category.
* Assess the dependence of communities on rivers, wells, shared taps, and household taps.

### 3.5 Assess Regional Water Infrastructure

* Compare water access across provinces and towns.
* Identify locations with damaged household water infrastructure.
* Highlight areas where infrastructure improvements would have the greatest impact.

### 3.6 Evaluate Water Quality and Public Health Risks

* Identify contaminated wells requiring immediate intervention.
* Differentiate between biological and chemical contamination.
* Support appropriate treatment recommendations for affected communities.

### 3.7 Prioritize Infrastructure Improvements

* Develop business rules for recommending appropriate interventions.
* Generate actionable improvement plans for each qualifying water source.
* Prioritize projects based on infrastructure condition, contamination status, and service demand.

### 3.8 Support Project Planning and Monitoring

* Design a structured project tracking table for engineering teams.
* Store planned interventions, project status, completion dates, and implementation notes.
* Enable systematic monitoring of infrastructure improvement activities.

### 3.9 Deliver Business Intelligence for Decision-Making

* Develop an interactive Power BI dashboard to visualize project performance.
* Monitor improvement projects, budgets, expenditures, and regional implementation progress.
* Provide stakeholders with data-driven insights that support strategic planning and resource allocation.

By achieving these objectives, the project transforms raw operational data into a comprehensive decision-support system that enables government agencies to improve water accessibility, optimize infrastructure investments, strengthen data integrity, and enhance service delivery across Maji Ndogo.

---

## 4. Data Sources

The Maji Ndogo Water Services database consists of multiple relational tables that collectively capture information about water infrastructure, inspection activities, laboratory testing, workforce operations, and project implementation.

The project integrates these datasets to provide a comprehensive view of water accessibility, quality, and infrastructure across the five provinces of Maji Ndogo.

### Data Tables

| Table | Description |
|--------|-------------|
| **water_source** | Stores every water source together with its type and the estimated population it serves. |
| **location** | Contains geographical information including province, town, address, and whether the location is urban or rural. |
| **visits** | Records every inspection visit carried out by field surveyors and serves as the central table connecting multiple datasets. |
| **employee** | Stores information about field inspectors responsible for conducting site visits. |
| **water_quality** | Contains subjective quality assessments recorded during inspections. |
| **well_pollution** | Stores laboratory test results for wells, including biological and chemical contamination levels. |
| **auditor_report** | Contains independent audit findings used to validate field survey accuracy and identify inconsistencies. |
| **project_progress** | Tracks remediation projects, engineering activities, and implementation status for water source improvements. |
| **data_dictionary** | Documents the database schema by describing every table, column, datatype, and relationship. |

### Central Dataset

The **visits** table serves as the operational hub of the database. It connects inspection records with:

- Geographic locations
- Water sources
- Field employees
- Water quality assessments

This design enables comprehensive analysis while maintaining referential integrity across the database.

---

## 5. Database Schema

The Maji Ndogo database follows a normalized relational schema designed to support operational reporting, quality assurance, infrastructure planning, and project monitoring.

The schema consists of nine interconnected tables that model the complete lifecycle of water service delivery—from inspection and laboratory testing to audit validation and infrastructure improvement.

---

### 5.1 water_source

Stores information about every registered water source.

**Primary Key**
- `source_id`

**Key Attributes**

- Type of water source
- Number of people served

---

### 5.2 location

Stores the geographical details for each inspection location.

**Primary Key**

- `location_id`

**Key Attributes**

- Address
- Province
- Town
- Location type (Urban/Rural)

---

### 5.3 visits

The central operational table that records every inspection visit conducted by field employees.

**Primary Key**

- `record_id`

**Foreign Keys**

- `location_id → location`
- `source_id → water_source`
- `assigned_employee_id → employee`

**Key Attributes**

- Visit count
- Inspection timestamp
- Queue time

Because this table links locations, water sources, employees, and inspection records, it serves as the primary fact table for analytical queries.

---

### 5.4 employee

Stores demographic and organizational information about field survey staff.

**Primary Key**

- `assigned_employee_id`

**Key Attributes**

- Employee name
- Contact information
- Assigned province and town
- Position

---

### 5.5 water_quality

Contains subjective quality assessments assigned during field inspections.

**Primary Key**

- `record_id`

**Relationship**

- Linked directly to the corresponding inspection in the `visits` table.

---

### 5.6 well_pollution

Stores laboratory analysis results for well water sources.

**Relationship**

- Linked to `water_source` through `source_id`.

**Key Attributes**

- Biological contamination
- Chemical contamination
- Pollutant concentration
- Laboratory result classification

---

### 5.7 auditor_report

Contains independent audit findings used to validate inspection accuracy.

The audit data was instrumental in identifying inconsistencies between field surveyors and independent auditors, helping uncover potential reporting errors and suspicious inspection activities.

---

### 5.8 project_progress

Tracks engineering interventions after analytical findings have been translated into actionable improvement projects.

Examples include:

- Drilling new wells
- Installing filtration systems
- Repairing damaged infrastructure
- Installing additional shared taps

The table also records project status, completion dates, and engineering comments.

---

### 5.9 data_dictionary

Provides metadata describing the database itself.

It documents:

- Table names
- Column names
- Data types
- Business definitions
- Relationships

Maintaining a data dictionary improves documentation, consistency, and long-term maintainability.

---

## Database Relationships

The database is centered around the **visits** table, which connects inspections to employees, locations, and water sources.

```text
                    employee
                        │
                        │ assigned_employee_id
                        ▼
                    visits
                  ▲    │    ▲
                  │    │    │
          location    │   water_source
                      │
             water_quality
                      │
              well_pollution
                      │
              auditor_report

water_source
      │
      ▼
project_progress
```

---

## Design Highlights

- Fully normalized relational database
- Clearly defined primary and foreign key relationships
- Centralized inspection records through the `visits` table
- Independent audit validation using `auditor_report`
- Laboratory testing integrated through `well_pollution`
- End-to-end project tracking using `project_progress`
- Self-documenting schema supported by the `data_dictionary`

This architecture supports descriptive analytics, quality assurance, operational reporting, and strategic decision-making for water infrastructure management.

---

## 6. Data Cleaning & Preparation

Before performing any analysis, the Maji Ndogo dataset underwent a structured data preparation process to improve data quality, ensure consistency, and prepare the relational database for reliable reporting and decision-making.

The cleaning process was carried out primarily using SQL and focused on preserving data integrity while minimizing duplicate and inconsistent records.

---

### Data Validation

Initial exploration was performed to understand the structure and completeness of each table. Record counts, data types, and key fields were reviewed to verify that all required datasets had been imported successfully.

---

### Duplicate Handling

Some water sources had multiple inspection records due to repeat visits conducted by survey teams.

To avoid double-counting during analysis, only the first official inspection for each water source was retained using:

- `visit_count = 1`

Subsequent follow-up visits were excluded from analytical queries unless specifically required.

---

### Relational Data Integration

The project relied heavily on SQL JOIN operations to combine information from multiple related tables.

Relationships were established between:

- `location` and `visits`
- `visits` and `water_source`
- `visits` and `employee`
- `visits` and `water_quality`
- `water_source` and `well_pollution`
- `auditor_report` and inspection records
- `project_progress` and `water_source`

This integration produced a unified analytical dataset without introducing redundant data.

---

### Data Consistency Checks

Several validation checks were performed throughout the project, including:

- Comparing auditor quality scores with surveyor assessments.
- Verifying that water source classifications matched across related tables.
- Confirming that key relationships between tables were preserved after joins.
- Ensuring that each inspection record referenced valid employees, locations, and water sources.

These checks helped identify inconsistencies while maintaining referential integrity.

---

### Derived Views and Temporary Tables

To simplify complex analytical queries and improve readability, reusable SQL objects were created during the project.

These included:

- **Incorrect_records** — Identified discrepancies between auditor assessments and field survey results.
- **combined_analysis_table** — Consolidated geographic, operational, and water source information into a single analytical view.
- **town_aggregated_water_access** — Temporary table used to speed up town-level aggregation and infrastructure analysis.

Using views and temporary tables reduced query complexity, improved maintainability, and eliminated unnecessary repetition of lengthy JOIN statements.

---

### Business Rule Filtering

Several business rules were applied to ensure analyses reflected real operational conditions.

Examples included:

- Including only primary inspection visits (`visit_count = 1`).
- Excluding clean wells when prioritizing remediation efforts.
- Flagging only shared taps with queue times of 30 minutes or more for infrastructure expansion.
- Restricting improvement planning to water sources requiring intervention.

These filters ensured that recommendations focused on locations with the greatest operational need.

---

### Data Quality Outcome

After cleaning and preparation, the dataset was suitable for:

- Exploratory data analysis (EDA)
- Water access assessment
- Infrastructure prioritization
- Auditor validation
- Fraud detection
- Project planning
- Power BI dashboard development

The resulting analytical dataset provided a reliable foundation for generating insights and supporting evidence-based recommendations for improving water accessibility across Maji Ndogo.

---

## 7. Exploratory Data Analysis (EDA)

Exploratory Data Analysis (EDA) was conducted to understand the distribution of water sources, identify infrastructure challenges, evaluate service accessibility, and uncover patterns that would guide subsequent SQL analysis and decision-making.

The analysis was performed primarily using SQL aggregation, filtering, grouping, conditional logic, Common Table Expressions (CTEs), Views, and temporary tables.

---

## 7.1 Geographic Distribution Analysis

The first stage examined how water sources were distributed across provinces, towns, and urban/rural locations.

The analysis focused on:

- Distribution of water sources across the five provinces.
- Water access differences between urban and rural communities.
- Geographic concentration of water infrastructure.
- Population served by each region.

This provided an overview of where water infrastructure was concentrated and highlighted underserved areas.

---

## 7.2 Water Source Distribution

The different types of water sources available throughout Maji Ndogo were analysed to understand how citizens accessed water.

The source categories included:

- River
- Well
- Shared Tap
- Tap in Home
- Broken Tap in Home

The analysis measured:

- Number of water sources by type.
- Population served by each source type.
- Percentage contribution of each source category.

These findings established which water sources supported the largest proportion of the population.

---

## 7.3 Queue Time Analysis

Access to water was further evaluated by analysing waiting times at shared water sources.

The analysis investigated:

- Average queue time.
- Maximum and minimum queue duration.
- Queue distribution by day of the week.
- Queue distribution by hour of the day.
- Peak demand periods.

Understanding queue behaviour helped identify communities experiencing the greatest delays in accessing water.

---

## 7.4 Infrastructure Assessment

The condition of existing water infrastructure was evaluated to determine where repairs would have the greatest impact.

Key assessments included:

- Functional vs. broken household taps.
- Contaminated versus clean wells.
- Communities relying on unsafe river water.
- Shared taps experiencing excessive waiting times.

This analysis identified infrastructure requiring immediate intervention.

---

## 7.5 Provincial Water Access Analysis

Water access was aggregated at the provincial level by calculating the proportion of residents served by each water source type.

SQL CASE expressions and aggregate functions were used to produce percentage distributions for:

- River
- Well
- Shared Tap
- Tap in Home
- Broken Tap in Home

This comparison highlighted regional disparities in access to safe water infrastructure.

---

## 7.6 Town-Level Water Access Analysis

A more detailed analysis was performed at the town level.

To avoid ambiguity caused by duplicate town names across provinces, records were grouped using a composite key consisting of:

- Province
- Town

This approach enabled accurate comparisons between communities and identified towns requiring priority investment.

---

## 7.7 Water Quality Assessment

Water quality analysis examined both field inspection results and laboratory testing.

The assessment included:

- Subjective quality scores assigned by surveyors.
- Laboratory contamination results for wells.
- Biological contamination.
- Chemical contamination.
- Safe versus unsafe water sources.

These findings informed recommendations for filtration, rehabilitation, or replacement.

---

## 7.8 Preliminary Findings

The exploratory analysis revealed several important patterns:

- Rural communities relied more heavily on rivers and wells than urban areas.
- Shared taps served the largest proportion of the population but frequently experienced long waiting times.
- A significant number of household tap systems were installed but non-functional.
- Water quality challenges were concentrated in contaminated wells and communities dependent on untreated river water.
- Infrastructure deficiencies varied considerably across provinces and towns, requiring location-specific interventions.

These exploratory findings established the analytical foundation for the more advanced SQL investigations presented in the following sections.

---

## 8. SQL Analysis & Business Insights

Structured SQL analysis was conducted to transform raw inspection data into meaningful business insights that informed infrastructure investment and operational planning across Maji Ndogo. The analysis progressed from descriptive exploration to advanced aggregations, enabling stakeholders to identify priority areas for intervention.

The analytical workflow included:

* Assessing workforce performance by measuring inspector productivity, visit frequency, and survey coverage.
* Evaluating geographic distribution of water sources across provinces, towns, and rural versus urban communities.
* Measuring the population served by each water source category, including rivers, wells, shared taps, household taps, and broken household taps.
* Investigating water quality by combining laboratory pollution results with field inspection records to identify contaminated wells requiring remediation.
* Analyzing queue durations at water collection points to identify locations experiencing excessive waiting times and poor service accessibility.
* Examining temporal patterns in queue lengths by day of the week and hour of the day to determine peak demand periods for shared water infrastructure.
* Comparing provincial and town-level water access percentages using Common Table Expressions (CTEs), conditional aggregation, and pivot-style SQL queries.
* Creating reusable SQL views and temporary tables to simplify complex joins and improve query efficiency during subsequent analyses.
* Designing a comprehensive infrastructure improvement strategy by translating analytical findings into actionable engineering recommendations using SQL CASE expressions.
* Building the `project_progress` implementation table to prioritize repair activities, monitor project execution, and support long-term maintenance tracking.

Several advanced SQL techniques were applied throughout the project, including:

* Multi-table INNER JOIN and LEFT JOIN operations
* Common Table Expressions (CTEs)
* SQL Views
* Temporary Tables
* CASE statements
* Aggregate functions
* Conditional aggregation
* GROUP BY and HAVING clauses
* Window-ready analytical structures
* String manipulation and concatenation
* Mathematical functions such as ROUND() and FLOOR()
* Data filtering using complex WHERE conditions

The SQL analysis revealed several critical findings. Shared taps served the largest proportion of the population, yet many communities experienced queue times well above internationally recommended thresholds. Rural communities depended heavily on rivers and untreated wells, exposing residents to greater health risks. Laboratory testing further identified numerous chemically and biologically contaminated wells that required immediate intervention.

Infrastructure analysis also showed that many household tap systems already existed but were non-functional due to damaged pipes, pumps, and reservoirs. Rather than constructing entirely new infrastructure, repairing these existing systems represented a more cost-effective strategy capable of restoring safe water access to thousands of residents simultaneously.

These SQL-driven insights established a clear, evidence-based roadmap for infrastructure investment and formed the analytical foundation for the subsequent Power BI dashboard, where project costs, implementation progress, provincial performance, and improvement initiatives were monitored interactively.

---

## 9. Audit & Data Validation

Ensuring the accuracy and reliability of the inspection data was a critical component of the Maji Ndogo Water Infrastructure Improvement Project. Before making infrastructure investment recommendations, the dataset was subjected to multiple validation procedures to identify inconsistencies, data quality issues, and potential reporting errors.

An independent `auditor_report` table was used to verify the assessments recorded by field inspectors. By comparing auditor observations with inspection records, discrepancies between reported water source conditions and independently verified findings could be identified and investigated.

The validation process focused on:

* Comparing inspector assessments against independent auditor reports.
* Identifying inconsistencies in recorded water source classifications.
* Detecting mismatches between subjective water quality assessments and laboratory pollution test results.
* Verifying that every inspection record was correctly linked to an existing employee, location, and water source.
* Confirming referential integrity across all related database tables.
* Identifying duplicate inspection records and repeated visits that could distort analytical results.
* Filtering analyses to include only the first inspection visit (`visit_count = 1`) where appropriate, preventing duplicate observations from influencing summary statistics.
* Reviewing missing values and ensuring that NULL values were handled appropriately during analysis.

Additional validation checks were performed throughout the SQL workflow to ensure that joins between tables produced complete and accurate datasets. LEFT JOIN operations were intentionally used where supporting information, such as laboratory pollution results, was unavailable for non-well water sources, preserving the completeness of the primary inspection records.

These quality assurance procedures increased confidence in the analytical outputs and ensured that subsequent recommendations were based on validated, trustworthy data. By incorporating independent audit records into the analysis, the project strengthened the credibility of its findings and reduced the likelihood of prioritizing infrastructure investments based on inaccurate field reports.

---

## 10. Power BI Dashboard

Following the completion of the SQL analysis, an interactive Power BI dashboard was developed to transform analytical findings into actionable business intelligence. The dashboard served as the executive reporting layer of the Maji Ndogo Water Improvement Project, enabling stakeholders to monitor project performance, evaluate financial outcomes, analyze regional implementation, and support data-driven decision-making.

The dashboard integrated engineering, financial, operational, and geographical data into a centralized reporting platform designed to answer four key business questions:

* How much has been spent?
* Where was the money spent?
* Which water improvement initiatives cost the most?
* What impact has the project achieved?

### Executive Performance Overview

The national dashboard provided a high-level overview of the project's overall performance using key performance indicators (KPIs).

Major KPIs included:

* **Population Served:** Approximately **18.36 million** people gained access to improved water infrastructure.
* **Water Accessibility:** Basic water access reached **100%** of the target population.
* **Project Completion:** All planned improvement projects were completed, resulting in **100% project progress** with **zero remaining water sources** awaiting intervention.
* **Financial Performance:** Total project expenditure reached approximately **$154.49 million**, compared to an approved budget of **$146.74 million**, representing a **5.29% budget overrun**.

Although the project exceeded its original budget, the relatively modest cost variance demonstrated effective financial management for a nationwide infrastructure programme while successfully achieving all strategic objectives.

### Geographic Analysis

Interactive maps and geographic visualizations enabled users to evaluate project implementation across the five provinces:

* Sokoto
* Kilimani
* Akatsi
* Hawassa
* Amanzi

Province slicers and drill-through functionality allowed decision-makers to investigate infrastructure investments at both provincial and town levels while comparing regional project performance.

### Provincial Cost Distribution

The dashboard analyzed total expenditure by province to identify where national investment was concentrated.

The analysis showed that:

* Sokoto accounted for the largest share of national expenditure.
* Kilimani and Akatsi represented the next highest levels of investment.
* Hawassa and Amanzi required comparatively lower overall spending.

These findings suggest that infrastructure requirements, population size, and geographical challenges varied considerably across provinces, influencing investment priorities.

### Water Improvement Analysis

Project expenditure was further analyzed according to the type of infrastructure improvement implemented.

Major improvement categories included:

* Drilling new wells
* Installing additional public taps
* Installing Reverse Osmosis (RO) filtration systems
* Installing combined UV and RO filtration systems
* Repairing existing water infrastructure

The dashboard revealed that new infrastructure construction—including well drilling and public tap installation—consumed the largest proportion of the national budget, while infrastructure repair represented only a relatively small share of total expenditure. This indicates that expanding water access was a greater priority than rehabilitating existing facilities.

### Cost Analysis

Average project costs were compared across improvement categories to identify the most resource-intensive interventions.

Key findings included:

* Drilling wells recorded the highest average implementation cost (approximately **$12.2K** per project).
* Public tap installation followed closely (approximately **$12.1K** per project).
* Water filtration projects involving RO and UV systems required moderate investment.
* Infrastructure repairs represented the lowest average cost (approximately **$600** per project).

These findings demonstrate that repairing existing infrastructure can often restore water access at a fraction of the cost required to construct entirely new facilities.

### Rural versus Urban Comparison

The dashboard compared implementation costs between rural and urban communities.

The analysis showed:

* Average rural project cost: approximately **$7.31K**
* Average urban project cost: approximately **$3.97K**

Rural projects consistently required greater investment due to transportation challenges, difficult terrain, limited existing infrastructure, and increased construction complexity. This insight provides valuable guidance for future budgeting and resource allocation.

### Vendor Performance

A dedicated vendor performance dashboard evaluated contractor efficiency using metrics such as:

* Number of completed projects
* Total project expenditure
* Average project cost
* Cost efficiency across vendors

Average vendor costs generally ranged between **$12K and $15K** per completed project, indicating relatively consistent pricing across contractors and suggesting standardized procurement practices.

### Time-Based Monitoring

Completion-date slicers enabled stakeholders to examine:

* Project completion trends
* Spending over time
* Budget utilization
* Infrastructure rollout progress

These interactive features transformed the dashboard from a static reporting tool into a dynamic project monitoring platform.

### AI-Powered Key Influencers Analysis

Power BI's Key Influencers visual was used to identify the primary factors contributing to higher project costs.

The analysis indicated that project cost was most strongly influenced by:

* Installing multiple nearby public taps
* Drilling new wells
* Longer project completion durations
* Rural project locations, particularly within Sokoto Province
* Overall project complexity

These findings provide valuable inputs for future project planning, cost forecasting, and infrastructure prioritization.

Overall, the Power BI dashboard transformed complex SQL outputs into intuitive visualizations that enabled government agencies, engineers, project managers, and decision-makers to monitor implementation progress, evaluate financial performance, optimize resource allocation, and measure the nationwide impact of the Maji Ndogo Water Improvement Project.

---

## 11. Business Recommendations

Based on the SQL analysis, audit findings, and Power BI dashboard insights, the following recommendations are proposed to improve water accessibility, optimize project costs, and support long-term sustainability across Maji Ndogo.

### 11.1 Prioritize High-Impact Water Source Improvements

Project resources should continue to focus on interventions that benefit the largest number of people.

The analysis showed that shared public taps serve the highest proportion of the population. Expanding these facilities in underserved communities will immediately reduce waiting times while increasing access to safe drinking water.

Similarly, communities relying on river water should remain the highest priority for new borehole and well construction, particularly in provinces such as Sokoto where dependence on untreated surface water is greatest.

### 11.2 Accelerate Rehabilitation of Existing Infrastructure

The analysis identified numerous non-functional household tap systems caused by damaged pipelines, pumps, and reservoirs.

Since repairing existing infrastructure is considerably less expensive than constructing entirely new facilities, rehabilitation projects should be prioritized wherever feasible. Restoring these systems provides two major benefits:

- Improves household access to clean water.
- Reduces pressure on nearby public water sources, resulting in shorter queue times.

This strategy offers one of the highest returns on investment identified throughout the project.

### 11.3 Improve Water Quality Through Targeted Treatment

Laboratory analysis revealed that many wells remain contaminated by either biological or chemical pollutants.

Recommended interventions include:

- Installing **UV and Reverse Osmosis (RO) filtration systems** for biologically contaminated wells.
- Installing **RO filtration systems** for chemically contaminated wells.
- Establishing routine water quality monitoring programs to prevent future contamination.

These actions will significantly reduce public health risks while maximizing the usefulness of existing groundwater infrastructure.

### 11.4 Strengthen Budget Planning and Cost Control

Although the project successfully achieved universal basic water access, actual expenditure reached approximately **$154 million**, exceeding the planned budget of roughly **$147 million** by about **5.3%**.

Future infrastructure programs should incorporate:

- More detailed cost forecasting.
- Risk-adjusted contingency budgets.
- Continuous financial monitoring throughout project execution.
- Early identification of cost overruns.

These measures will improve financial accountability while maintaining project performance.

### 11.5 Allocate Resources Based on Geographic Cost Differences

Power BI analysis demonstrated that rural infrastructure projects cost substantially more than urban projects because of transportation challenges, limited infrastructure, and difficult terrain.

Future budgeting should therefore:

- Allocate larger budgets to rural provinces.
- Consider geographic accessibility during project planning.
- Optimize logistics and material distribution to reduce transportation costs.

Province-specific budgeting models will improve financial planning accuracy.

### 11.6 Enhance Contractor Performance Monitoring

Vendor analysis highlighted measurable differences in project costs across contractors.

Future procurement processes should incorporate performance indicators such as:

- Average project cost
- Cost variance
- Project completion rate
- Delivery timelines
- Quality of completed work

Performance-based contractor evaluation can improve procurement efficiency while reducing unnecessary expenditure.

### 11.7 Adopt Data-Driven Decision Making

The integrated SQL database and Power BI dashboard provide a centralized platform for monitoring operational, financial, and engineering performance.

Decision-makers should continue using these analytical tools to:

- Monitor project progress in real time.
- Identify high-priority communities.
- Track expenditure against budgets.
- Evaluate project outcomes across provinces.
- Support evidence-based infrastructure planning.

This analytical framework enables faster, more transparent, and more informed decision-making.

### 11.8 Establish Preventive Maintenance Programs

Rather than waiting for infrastructure failures, local authorities should implement scheduled maintenance programs for pumps, reservoirs, filtration systems, and public taps.

Preventive maintenance will:

- Extend infrastructure lifespan.
- Reduce emergency repair costs.
- Improve service reliability.
- Minimize disruptions to water access.

Long-term maintenance planning is essential for sustaining the gains achieved through the project.

### 11.9 Expand Interactive Business Intelligence Reporting

The Power BI dashboard proved highly effective in communicating project performance to stakeholders.

Future versions should incorporate:

- Predictive maintenance indicators.
- Budget forecasting models.
- Real-time project updates.
- Mobile-friendly dashboards.
- Automated data refresh pipelines.

These enhancements will strengthen monitoring capabilities and support continuous improvement initiatives.

### 11.10 Overall Recommendation

The Maji Ndogo Water Improvement Project demonstrates how SQL, data modeling, and business intelligence can transform operational data into actionable insights. Future investments should prioritize preventive maintenance, cost-efficient infrastructure rehabilitation, targeted water quality improvements, and data-driven resource allocation. By combining engineering expertise with analytical decision-making, stakeholders can maximize the social impact of future water infrastructure programs while ensuring financial sustainability and long-term service delivery.

---

## 12. Conclusion

The Maji Ndogo Water Improvement Project demonstrates how data analytics can support evidence-based decision-making in large-scale public infrastructure initiatives. By integrating SQL, data quality auditing, and Power BI, the project transformed raw operational data into actionable insights that guided both strategic planning and resource allocation.

Using SQL, the analysis explored water source distribution, infrastructure conditions, water quality, queue times, regional disparities, and project prioritization. Comprehensive data validation through independent audit reports improved confidence in the findings by identifying and resolving inconsistencies within field inspection records. These analytical processes ensured that recommendations were built on reliable and accurate data.

The implementation phase translated analytical findings into practical actions through the creation of the `project_progress` table, enabling water improvement initiatives to be tracked from identification through completion. This structured approach connected analysis directly with operational execution, supporting efficient project management and accountability.

Interactive Power BI dashboards further enhanced the project by providing stakeholders with real-time visibility into project performance, financial expenditure, geographical distribution, contractor performance, and overall progress toward national water accessibility goals. The dashboards revealed that more than **18 million people** benefited from the initiative, all planned improvement projects were completed, and universal basic water access was successfully achieved. Although total expenditure exceeded the planned budget by approximately **5.3%**, the project demonstrated strong overall financial performance considering its national scale and impact.

Overall, the project illustrates the value of combining data engineering, SQL analytics, business intelligence, and visualization to address complex development challenges. Beyond solving immediate operational problems, the analytical framework established in this project provides a scalable foundation for future infrastructure planning, performance monitoring, and data-driven policy decisions aimed at improving public service delivery.
