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
