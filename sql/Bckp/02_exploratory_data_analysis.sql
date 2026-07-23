SELECT
	*
FROM
	employee;


-- Ok, bring up the employee table. It has info on all of our workers, but note that the email addresses have not been added. 
-- We will have to send them reports and figures, so let's update it. Luckily the emails for our 
-- department are easy: first_name.last_name@ndogowater.gov.

/*
We can determine the email address for each employee by:
- selecting the employee_name column
- replacing the space with a full stop
- make it lowercase
- and stitch it all together
First up, let's remove the space between the first and last names using REPLACE(). You can try this:
*/


SELECT
REPLACE(employee_name, ' ','.') -- Replace the space with a full stop
FROM
employee;


-- Then we can use LOWER() with the result we just got. Now the name part is correct.


SELECT
LOWER(REPLACE(employee_name, ' ','.')) -- Make it all lower case
FROM
employee;


-- We then use CONCAT() to add the rest of the email address:


SELECT
CONCAT(
LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email -- add it all together
FROM
employee;


-- We can now UPDATE the email column this time with the email addresses we created.


UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),

'@ndogowater.gov');


-- Next, if you look at the phone numbers in the phone_number column, the values are stored as strings.
-- The phone numbers should be 12 characters long, consisting of the plus sign, area code (99), and the phone number digits. 
-- However, when we use the LENGTH(column) function, it returns 13 characters, indicating there's an extra character.


SELECT 
    LENGTH(phone_number)
FROM
    employee;


-- So we use TRIM() to write a SELECT query again, make sure we get the string without the space


SELECT 
    TRIM(phone_number)
FROM
    employee;


-- and then UPDATE the record like you just did for the emails.


UPDATE employee 
SET 
    phone_number = TRIM(phone_number)
;


-- Before we dive into the analysis, let's get you warmed up a bit. Let's have a look at where our employees live.
-- Use the employee table to count how many of our employees live in each town.


SELECT 
    town_name, COUNT(employee_name)
FROM
    employee
GROUP BY town_name;


-- Note how many of our workers are living in smaller communities in the rural parts of Maji Ndogo.

-- Next, we are to send out an email or message congratulating the top 3 field surveyors. So let's go to the VISITS table to get the
-- employee_ids and use those to get the names, email and phone numbers of the three field surveyors with the most location visits.


SELECT 
    *
FROM
    visits;


-- So, Let's look at the number of locations each employee collected.


SELECT 
    assigned_employee_id,
    count(visit_count) Total_visit_count
FROM
    visits
    group by assigned_employee_id;
    
    
-- Now Let's look for our top 3
    
    
SELECT 
    assigned_employee_id,
    count(visit_count) Total_visit_count
FROM
    visits
    group by assigned_employee_id
    order by Total_visit_count desc
    limit 3;


-- Make a note of the top 3 assigned_employee_id and use them to create a query that looks up the employee's info.


SELECT 
    *
FROM
    employee
WHERE
    assigned_employee_id IN (1 , 30, 34);
    
    
-- Looking at the location table, let’s focus on the province_name, town_name and location_type 
-- to understand where the water sources are in Maji Ndogo.


SELECT 
    *
FROM
    location;


-- So lets create a query that counts the number of records per town


SELECT 
    COUNT(town_name) records_per_town, town_name
FROM
    location
GROUP BY town_name
ORDER BY records_per_town DESC;


-- Now count the records per province.


SELECT 
    COUNT(province_name) records_per_province, province_name
FROM
    location
GROUP BY province_name
ORDER BY records_per_province DESC;


/*
Lets do the following:
1. Create a result set showing:
• province_name
• town_name
• An aggregated count of records for each town (consider naming this records_per_town).
• Ensure your data is grouped by both province_name and town_name.
2. Order your results primarily by province_name. Within each province, further sort the towns by their record counts in descending order.
*/


SELECT 
    province_name, town_name, COUNT(town_name) records_per_town
FROM
    location
GROUP BY province_name , town_name
ORDER BY province_name , records_per_town DESC; -- This is an insight we can use to communicate data integrity, so let's make a note of that.


-- Finally, look at the number of records for each location type


SELECT 
    COUNT(location_type) num_sources, location_type
FROM
    location
GROUP BY location_type;


/*
we have access to different water source types and the number of people using each source.
These are the questions that I am curious about.
1. How many people did we survey in total?
2. How many wells, taps and rivers are there?
3. How many people share particular types of water sources on average?
4. How many people are getting water from each type of source?
*/


-- How many people did we survey in total?


SELECT 
    SUM(number_of_people_served) Total_people_surveyed
FROM
    water_source;
    
    
-- How many wells, taps and rivers are there?


SELECT 
    type_of_water_source,
    COUNT(type_of_water_source) num_of_water_types
FROM
    water_source
GROUP BY type_of_water_source;


-- How many people share particular types of water sources on average?


SELECT 
    type_of_water_source,
    ROUND(AVG(number_of_people_served)) ave_people_per_source
FROM
    water_source				-- there is an average of 6 people living in a home. So 6 people actually share 1 tap (not 644).
GROUP BY type_of_water_source;	-- This means that 1 tap_in_home actually represents 644 / 6 = +- 100 taps.


-- How many people are getting water from each type of source?


SELECT 
    type_of_water_source,
    SUM(number_of_people_served) population_served
FROM
    water_source
GROUP BY type_of_water_source
ORDER BY population_served DESC;


-- Lets get the percentages of this ditribution for better picture


SELECT 
    type_of_water_source,
    SUM(number_of_people_served) / 27628140 * 100 percentage_people_per_source
FROM
    water_source
GROUP BY type_of_water_source
ORDER BY percentage_people_per_source DESC;


-- Let's round that off to 0 decimals, and order the results.


SELECT 
    type_of_water_source,
    round(sum(number_of_people_served) / 27628140 * 100) percentage_people_per_source
FROM
    water_source
GROUP BY type_of_water_source
ORDER BY percentage_people_per_source DESC;


/*
By adding tap_in_home and tap_in_home_broken together, we see that 31% of people have water infrastructure installed in their homes,
but 45% (14/31) of these taps are not working! This isn't the tap itself that is broken, but rather the infrastructure like treatment plants, 
reservoirs, pipes, and pumps that serve these homes that are broken. 18% of people are using wells. 
But only 4916 out of 17383 are clean = 28% (from last week).
*/

-- So let's write a query that ranks each type of source based on how many people in total use it using WINDOW function.


SELECT 
    type_of_water_source,
    SUM(number_of_people_served) population_served,
    round(sum(number_of_people_served) / 27628140 * 100) percentage_people_per_source,
    rank() over (order by SUM(number_of_people_served) desc) rank_by_population
FROM
    water_source
GROUP BY type_of_water_source
ORDER BY percentage_people_per_source DESC;


-- Ok, so we should fix shared taps first, then wells, and so on. But the next question is, which shared taps or wells should be fixed first? 
-- We can use the same logic; the most used sources should really be fixed first.

/*
So we will create a query to do this, and keep these requirements in mind:
1. The sources within each type should be assigned a rank.
2. Limit the results to only improvable sources.
3. Think about how to partition, filter and order the results set.
4. Order the results to see the top of the list.
*/


SELECT 
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank
FROM 
    water_source
ORDER BY 
    type_of_water_source,
    priority_rank;


-- Lets limit it to shared taps and wells


SELECT 
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank
FROM 
    water_source
WHERE 
    type_of_water_source IN ('Shared Tap', 'Well')
ORDER BY 
    type_of_water_source,
    priority_rank;


-- Ok lets see if DENSE_RANK() makes the work easier


SELECT 
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank,
    DENSE_RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS dense_priority_rank
FROM 
    water_source
WHERE 
    type_of_water_source IN ('Shared Tap', 'Well')
ORDER BY 
    type_of_water_source,
    priority_rank;


-- Lets apply row numbers


SELECT 
	row_number() OVER (ORDER BY number_of_people_served DESC) AS row_numbers,
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_rank,
    DENSE_RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS dense_priority_rank
FROM 
    water_source
WHERE 
    type_of_water_source IN ('Shared Tap', 'Well')
ORDER BY 
    type_of_water_source,
    priority_rank;


-- How long did the survey take?
-- To calculate how long the survey took, we need to get the first and last dates (which functions can find the largest/smallest value), 
-- and subtract them. Remember with DateTime data, we can't just subtract the values. We have to use a function to get the difference in days.


SELECT 
    MIN(time_of_record) record_start,
    MAX(time_of_record) record_end,
    DATEDIFF(MAX(time_of_record), MIN(time_of_record)) survey_duration
FROM
    md_water_services.visits;
    
    
-- What is the average total queue time for water?


SELECT 
    ROUND(AVG(time_in_queue)) avg_time_in_queue
FROM
    md_water_services.visits
WHERE
    time_in_queue != 0;
    
-- OR

SELECT 
    ROUND(AVG(NULLIF(time_in_queue, 0))) avg_time_in_queue
FROM
    visits;


-- What is the average queue time on different days?


SELECT 
    DAYNAME(time_of_record) day_of_week,
    AVG(NULLIF(time_in_queue, 0)) avg_queue_time
FROM
    visits
GROUP BY day_of_week;


-- Lets round it to make it cleaner 


SELECT 
    DAYNAME(time_of_record) day_of_week,
    ROUND(AVG(NULLIF(time_in_queue, 0))) avg_queue_time
FROM
    visits
GROUP BY day_of_week;


-- We can also look at what time during the day people collect water. Try to order the results in a meaningful way.


SELECT 
    HOUR(time_of_record) AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue, 0))) avg_queue_time
FROM
    visits
group by hour_of_day
order by hour_of_day;


-- A format like 06:00 will be easier to read, so let's use that.

/*
To format time into a specific display format, we can use TIME_FORMAT(time, format). It takes a time data field and
converts it into a format like %H:00 which is easy to read. HOUR(time_of_record) gives us an integer value of the hour of the day,
that won't work with TIME_FORMAT(), so we need to use TIME(time_of_record) instead.
*/


SELECT 
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day, -- TIME_FORMAT(..., '%H:00')  
    ROUND(AVG(NULLIF(time_in_queue, 0))) avg_queue_time		   -- This formats the extracted time to just show the hour, 
FROM														   -- with :00 added manually.  
    visits													   -- %H = hour in 24-hour format (00–23) 
group by hour_of_day										   -- :00 = static string to make it look like the top of the hour.
order by hour_of_day;


-- Lets break down the queue times for each hour of each day
-- First, lets do for Sunday


SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
visits
WHERE
time_in_queue != 0; -- this excludes other sources with 0 queue times


-- Lets do it for the whole weekdays


SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- For Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- For Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- For Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
-- For Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
-- For Thursday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
-- For Friday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue 
ELSE NULL
END
),0) AS Friday,
-- For Saturday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue 
ELSE NULL
END
),0) AS Saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;









































































































