# Calculating Free-to-Paid conversion rate with SQL

## Project Overview
SQL project showcasing the free to paid conversion rate of students on the 365 Data Science platform. The primary objective of this project is to properly utilize SQL to create a subquery, which will be used as the base data set to uncover three metrics that will provide key insight into the platforms engagement and conversion statistics.

## Exploratory Data Analysis
1. What is the free-to-paid conversion rate of students who have watched a lecture on the 365 platform?
2. What is the average duration between the registration date and when a student has watched a lecture for the first time (date of first-time engagement)?
3. What is the average duration between the date of first-time engagement and when a student purchases a subscription for the first time (date of first-time purchase)?

## Data Analysis
~~~ sql
USE db_course_conversions;

SELECT 
    *
FROM
    student_engagement;
    
SELECT 
    *
FROM
    student_info;
    
SELECT 
    *
FROM
    student_purchases;
    
-- Creating the subquery and selecting columns to retrieve information on students info

SELECT
    i.student_id,
    i.date_registered,
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased,
    DATEDIFF(MIN(e.date_watched), i.date_registered) AS date_diff_reg_watch,
    DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS date_diff_watch_purch
FROM
	student_info i
		LEFT JOIN
	student_engagement e ON i.student_id = e.student_id
		LEFT JOIN
	student_purchases p ON e.student_id = p.student_id
GROUP BY i.student_id, i.date_registered
HAVING MIN(e.date_watched) IS NOT NULL
	AND (MIN(p.date_purchased) IS NULL OR MIN(e.date_Watched) <= COALESCE(MIN(p.date_purchased), '9999-12-31'));
    
-- Creating the main query
-- Calculating the Free-to-Paid Conversion Rate

SELECT 
    COUNT(*) AS first_date_watched,
    SUM(CASE
        WHEN first_date_purchased IS NOT NULL THEN 1
        ELSE 0
    END) AS students_who_purchased,
    (SUM(CASE
        WHEN first_date_purchased IS NOT NULL THEN 1
        ELSE 0
    END) * 100.0 / COUNT(*)) AS conversion_rate
FROM
    (SELECT 
        si.student_id,
            MIN(se.date_watched) AS first_date_watched,
            MIN(sp.date_purchased) AS first_date_purchased
    FROM
        student_info si
    LEFT JOIN student_engagement se ON si.student_id = se.student_id
    LEFT JOIN student_purchases sp ON se.student_id = sp.student_id
    GROUP BY si.student_id
    HAVING MIN(se.date_watched) IS NOT NULL
        AND (MIN(sp.date_purchased) IS NULL
        OR MIN(se.date_watched) <= MIN(sp.date_purchased))) AS subquery;

-- Calculating average duration between registration and first-time engagement

SELECT 
    AVG(date_diff_reg_watch) AS av_reg_watch
FROM
    (SELECT 
        i.student_id,
            i.date_registered,
            MIN(e.date_watched) AS first_date_watched,
            MIN(p.date_purchased) AS first_date_purchased,
            DATEDIFF(MIN(e.date_watched), i.date_registered) AS date_diff_reg_watch,
            DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS date_diff_watch_purch
    FROM
        student_info i
    LEFT JOIN student_engagement e ON i.student_id = e.student_id
    LEFT JOIN student_purchases p ON e.student_id = p.student_id
    GROUP BY i.student_id , i.date_registered
    HAVING MIN(e.date_watched) IS NOT NULL
        AND (MIN(p.date_purchased) IS NULL
        OR MIN(e.date_watched) <= COALESCE(MIN(p.date_purchased), '9999-12-31'))) AS subquery;

-- Calculating average duration between first-time engagement and first-time purchase

SELECT 
    AVG(date_diff_watch_purch) AS av_watch_purch
FROM
    (SELECT 
        i.student_id,
            i.date_registered,
            MIN(e.date_watched) AS first_date_watched,
            MIN(p.date_purchased) AS first_date_purchased,
            DATEDIFF(MIN(e.date_Watched), i.date_registered) AS date_diff_reg_watch,
            DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS date_diff_watch_purch
    FROM
        student_info i
    LEFT JOIN student_engagement e ON i.student_id = e.student_id
    LEFT JOIN student_purchases p ON e.student_id = p.student_id
    GROUP BY i.student_id , i.date_registered
    HAVING MIN(e.date_watched) IS NOT NULL
        AND (MIN(p.date_purchased) IS NULL
        OR MIN(e.date_watched) <= COALESCE(MIN(p.date_purchased), '9999-12-31'))) AS subquery;
~~~

## Interpretation
Conversion Rate:

Upon executing our SQL query to assess conversion rates, the results indicate that the free-to-paid conversion rate for users on the 365 Data Science platform is approximately 11.3%. In other words, for every 100 students who engage with the platform, approximately 11 transition to a paid subscription, providing a clear metric of user conversion and platform monetization effectiveness.

Average Duration Between Registration and First-Time Engagement:

The results of our second SQL query provide insight into the time interval between a student’s registration date and their initial engagement with content on the platform. Upon executing the code, the data reveals that, on average, a period of approximately 3 to 4 days elapses from the point of registration to the moment of first engagement, offering valuable information about user onboarding and interaction patterns.

Average Duration Between First-Time Engagement and First-Time Purchase:

Our third SQL query was crafted to calculate the average duration between a student’s initial engagement with the platform and their first purchase. Upon execution of the code, the data indicates that the average time elapsed between these two events is approximately 26 days, offering valuable insight into the typical timeline of user conversion from engagement to paid commitment.

## Data Source
[Project File](https://learn.365datascience.com/projects/calculating-free-to-paid-conversion-rate-with-sql/)
