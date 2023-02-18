######### Analyzing Trending Youtube Video Statistics - SQL Project

###########################  DDL ############################

CREATE DATABASE IF NOT EXISTS trending_yt_stats;

USE trending_yt_stats;

CREATE TABLE IF NOT EXISTS US_categories
          ( id INT NOT NULL UNIQUE, 
            title CHAR(50),
            PRIMARY KEY(id)
          );
          
CREATE TABLE IF NOT EXISTS US_videos
          ( id INT NOT NULL AUTO_INCREMENT,
			video_id TEXT,
            trending_date TEXT, -- ALTER to DATE type later
            title TEXT,
            channel_title TEXT,
            category_id INT, 
            publish_time TEXT, -- ALTER to DATETIME type later
            tags TEXT,
            views INT,
            likes INT,
            dislikes INT,
            comment_count INT,
            comments_disabled CHAR(6),
            ratings_disabled CHAR(6),
            video_error_or_removed CHAR(6),
            description TEXT,
			PRIMARY KEY (id),
             FOREIGN KEY(category_id) 
				REFERENCES US_categories(id)
          );
          
###########################  DML ############################

## Import Data
-- I used the "Table Data Import Wizard" in MySQL Workbench. Or, you can run the following:
-- PREPARE stmt FROM 'INSERT INTO `trending_yt_stats`.`us_videos` (`video_id`,`trending_date`,`title`,`channel_title`,`category_id`,`publish_time`,`tags`,`views`,`likes`,`dislikes`,`comment_count`,`comments_disabled`,`ratings_disabled`,`video_error_or_removed`,`description`) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
-- DEALLOCATE PREPARE stmt

# View the data

SELECT * FROM US_videos;
SELECT * FROM US_categories;

# Update Data 

SET SQL_SAFE_UPDATES = 0;

-- Edit trending_date format (TEXT TO DATE)
UPDATE US_videos 
	SET trending_date = CAST(CONCAT('20', SUBSTR(trending_date, 1, 2),  SUBSTR(trending_date, 6, 3), SUBSTR(trending_date, 3, 3)) AS DATE);

ALTER TABLE US_videos MODIFY trending_date DATE;


-- Edit publish_time format (TEXT TO DATETIME)
UPDATE US_videos 
	SET publish_time = DATE_FORMAT(STR_TO_DATE(publish_time, '%Y-%m-%dT%H:%i:%s.000Z'), '%Y-%m-%d %H:%i:%s');

ALTER TABLE US_videos MODIFY publish_time DATETIME;

SET SQL_SAFE_UPDATES = 1;


# Top 10 Video Categories For Each Day of the Week
WITH category_trending_count AS
(SELECT c.id , c.title , count(*) AS total_amount, v.trending_date, DAYNAME(v.trending_date) AS day
FROM US_videos AS v
INNER JOIN US_categories AS c ON v.category_id = c.id 
GROUP BY id, title, day)

SELECT
day,
category_daily_rank,
title,
total_amount
FROM 
	(SELECT id, title, total_amount, day, 
		DENSE_RANK() OVER(
			PARTITION BY DAYOFWEEK(trending_date)
			ORDER BY total_amount DESC
		) AS category_daily_rank
	FROM category_trending_count) temp
WHERE category_daily_rank <= 10;


# Top Trending Channel for each Category (and their average statistics)
SELECT 
channel_title,
category_id,
title as category_title,
total_trending_videos,
avg_views,
avg_likes,
avg_dislikes,
avg_comment_count
FROM
(SELECT *, DENSE_RANK() OVER(
	PARTITION BY category_id
    ORDER BY total_trending_videos DESC
) AS channel_category_combin_rank
FROM
(SELECT v.channel_title, v.category_id, c.title, COUNT(*) as total_trending_videos,
AVG(views) as avg_views,
AVG(likes) as avg_likes,
AVG(dislikes) as avg_dislikes,
AVG(comment_count) as avg_comment_count
FROM US_videos v
INNER JOIN US_categories AS c ON v.category_id = c.id 
GROUP BY v.category_id
ORDER BY v.category_id, total_trending_videos DESC) temp
) temp2
WHERE channel_category_combin_rank = 1;

# The Top Trending Channel for each category from Mon to Fri

WITH daily_trending_channels AS
(SELECT DAYOFWEEK(v.trending_date) AS day, v.category_id, v.channel_title, c.title, 
COUNT(*) as trending_amount
FROM US_videos v
INNER JOIN US_categories AS c ON v.category_id = c.id 
WHERE DAYOFWEEK(v.trending_date) BETWEEN 1 AND 5
GROUP BY v.category_id, day, v.channel_title
ORDER BY day, v.category_id, trending_amount DESC)

SELECT title as category_title, day_name, channel_title, trending_amount, category_day_rank FROM
(SELECT *,
CASE
    WHEN day = 1 THEN "Monday"
    WHEN day = 2 THEN "Tuesday"
    WHEN day = 3 THEN "Wednesday"
    WHEN day = 4 THEN "Thursday"
    WHEN day = 5 THEN "Friday"
END AS day_name, 
DENSE_RANK() OVER(
PARTITION BY category_id, day
ORDER BY trending_amount DESC
) AS category_day_rank
FROM daily_trending_channels) temp
WHERE category_day_rank = 1;


# Channel with Most Trending Videos - Answer: ESPN

CREATE VIEW top_US_channel AS
SELECT 
  channel_title,
  COUNT(DISTINCT video_id) as trending_videos_count
FROM 
  US_videos
GROUP BY channel_title
ORDER BY trending_videos_count DESC
LIMIT 1;


# Find Average Daily Views for the Channel with Most Trending Videos 
CREATE VIEW daily_avg_views_US AS 
SELECT trending_date, 
AVG(views) OVER (PARTITION BY trending_date) daily_avg_views
FROM US_videos
WHERE 
channel_title IN (SELECT channel_title FROM top_US_channel)
GROUP BY trending_date;


# Compare Average Daily Views with the Previous Day by Calculating % Difference (for Top Channel)

WITH add_prev_avg_views AS 
(SELECT trending_date, daily_avg_views, LAG(daily_avg_views) OVER (ORDER BY trending_date) avg_views_lag
FROM daily_avg_views_US
ORDER BY trending_date)

SELECT 
trending_date, 
daily_avg_views, 
avg_views_lag, 
100.0 * (daily_avg_views - avg_views_lag) / avg_views_lag AS Perecent_diff
FROM add_prev_avg_views;