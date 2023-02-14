-- Analyzing Trending Youtube Video Statistics
-- Dataset: https://www.kaggle.com/datasets/datasnaek/youtube-new

###########################  DDL ############################
CREATE DATABASE IF NOT EXISTS trending_yt_stats;
USE trending_yt_stats;

DROP TABLE CA_categories;
CREATE TABLE IF NOT EXISTS CA_categories
          ( id INT NOT NULL UNIQUE, 
            title CHAR(50),
            PRIMARY KEY(id)
          );

CREATE TABLE IF NOT EXISTS US_categories
          ( id INT NOT NULL UNIQUE, 
            title CHAR(50),
            PRIMARY KEY(id)
          );
          
DROP TABLE CA_videos;
CREATE TABLE IF NOT EXISTS CA_videos
          ( id INT NOT NULL AUTO_INCREMENT,
			video_id TEXT NOT NULL,
            trending_date TEXT NOT NULL, -- ALTER to DATE type later
            title TEXT NOT NULL,
            channel_title TEXT NOT NULL,
            category_id INT NOT NULL, 
            publish_time TEXT NOT NULL, -- ALTER to DATETIME type later
            tags TEXT NOT NULL,
            views INT NOT NULL,
            likes INT NOT NULL,
            dislikes INT NOT NULL,
            comment_count INT NOT NULL,
            comments_disabled CHAR(6) NOT NULL,
            ratings_disabled CHAR(6) NOT NULL,
            video_error_or_removed CHAR(6) NOT NULL,
            description TEXT NOT NULL,
			PRIMARY KEY (id),
             FOREIGN KEY(category_id) 
				REFERENCES CA_categories(id)
          );
          
DROP TABLE US_videos;
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


-- Import Data

-- I used the "Table Data Import Wizard" in MySQL Workbench. Or, you can run the following:
-- PREPARE stmt FROM 'INSERT INTO `trending_yt_stats`.`ca_videos` (`video_id`,`trending_date`,`title`,`channel_title`,`category_id`,`publish_time`,`tags`,`views`,`likes`,`dislikes`,`comment_count`,`comments_disabled`,`ratings_disabled`,`video_error_or_removed`,`description`) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
-- DEALLOCATE PREPARE stmt
-- PREPARE stmt FROM 'INSERT INTO `trending_yt_stats`.`us_videos` (`video_id`,`trending_date`,`title`,`channel_title`,`category_id`,`publish_time`,`tags`,`views`,`likes`,`dislikes`,`comment_count`,`comments_disabled`,`ratings_disabled`,`video_error_or_removed`,`description`) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
-- DEALLOCATE PREPARE stmt


-- Understand the data

SELECT * FROM CA_categories;
SELECT * FROM US_categories;

SELECT * FROM CA_videos;
SELECT COUNT(*) FROM CA_videos; -- 40807 records
SELECT COUNT(DISTINCT video_id) FROM CA_videos; -- 24055 unique video_ids 
SELECT COUNT(DISTINCT channel_title) FROM CA_videos; -- 5040 unique channel titles 
SELECT COUNT(DISTINCT title) FROM CA_videos; -- 24504 unique titles 
SELECT 
  channel_title,
  AVG(likes) as average_likes,
  SUM(likes) as total_likes,
  AVG(views) as average_views,
  SUM(views) as total_views,
  AVG(comment_count) as average_comment_count,
  SUM(comment_count) as total_comment_count,
  COUNT(*) as total_rows
FROM 
  CA_videos
GROUP BY 
  channel_title
ORDER BY average_likes DESC, average_views DESC, average_comment_count DESC;
-- TOP 3: ibighit, DrakeVEVO, ChildishGambinoVEVO

SELECT * FROM US_videos;
SELECT COUNT(*) FROM US_videos; -- 40949 records
SELECT COUNT(DISTINCT video_id) FROM US_videos; -- 6351 unique video_ids
SELECT COUNT(DISTINCT channel_title) FROM US_videos; -- 2202 unique channel titles
SELECT COUNT(DISTINCT title) FROM US_videos; -- 6439 unique titles
SELECT 
  channel_title,
  AVG(likes) as average_likes,
  SUM(likes) as total_likes,
  AVG(views) as average_views,
  SUM(views) as total_views,
  AVG(comment_count) as average_comment_count,
  SUM(comment_count) as total_comment_count,
  COUNT(*) as total_rows
FROM 
  US_videos
GROUP BY 
  channel_title
ORDER BY average_likes DESC, average_views DESC, average_comment_count DESC;
-- TOP 3: ChildishGambinoVEVO, ibighit, David Dobrik

-- Is there overlap between CA and US dataset? Yes, 5794 videos trending in both Canada and US
SELECT COUNT(*) FROM CA_videos
	WHERE video_id IN (SELECT video_id FROM US_videos);


-- Data Preprocessing for Time Series Analysis

-- Canada Dataset:
-- Edit trending_date format (TEXT TO DATE)
SET SQL_SAFE_UPDATES = 0;
UPDATE CA_videos 
	SET trending_date = CAST(CONCAT('20', SUBSTR(trending_date, 1, 2),  SUBSTR(trending_date, 6, 3), SUBSTR(trending_date, 3, 3)) AS DATE);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE CA_videos MODIFY trending_date DATE;
SELECT DISTINCT trending_date FROM CA_videos ORDER BY trending_date desc;

-- Edit publish_time format (TEXT TO DATETIME)
UPDATE CA_videos 
	SET publish_time = DATE_FORMAT(STR_TO_DATE(publish_time,'%Y-%m-%dT%H:%i:%s.000Z'),'%Y-%m-%d %H:%i:%s');
ALTER TABLE CA_videos MODIFY publish_time DATETIME;
SELECT DISTINCT publish_time FROM CA_videos ORDER BY publish_time desc;

-- US Dataset:
-- Edit trending_date format (TEXT TO DATE)
SET SQL_SAFE_UPDATES = 0;
UPDATE US_videos 
	SET trending_date = CAST(CONCAT('20', SUBSTR(trending_date, 1, 2),  SUBSTR(trending_date, 6, 3), SUBSTR(trending_date, 3, 3)) AS DATE);
ALTER TABLE US_videos MODIFY trending_date DATE;
SELECT DISTINCT trending_date FROM US_videos ORDER BY trending_date desc;

-- Edit publish_time format (TEXT TO DATETIME)
UPDATE US_videos 
	SET publish_time = DATE_FORMAT(STR_TO_DATE(publish_time,'%Y-%m-%dT%H:%i:%s.000Z'),'%Y-%m-%d %H:%i:%s');
ALTER TABLE US_videos MODIFY publish_time DATETIME;
SELECT DISTINCT publish_time FROM US_videos ORDER BY publish_time desc;
SET SQL_SAFE_UPDATES = 1;


-- Main Analysis

# Top 10 categories that trend the most
SELECT
c2.id, 
c2.title, 
COUNT(DISTINCT c1.video_id) AS trending_count
FROM CA_videos c1
JOIN CA_categories c2 ON c1.category_id = c2.id
GROUP BY 1, 2
ORDER BY 3 DESC;


# For each month, rank each category based on its amount of trending videos in CA
SELECT *, 
DENSE_RANK() OVER(
	PARTITION BY month
    ORDER BY trending_count DESC
) AS trending_rank
FROM
(SELECT
MONTH(c1.trending_date) as month, 
c2.id, 
c2.title, 
COUNT(DISTINCT c1.video_id) AS trending_count
	FROM CA_videos c1
	JOIN CA_categories c2 ON c1.category_id = c2.id
GROUP BY 1, 2, 3
ORDER BY 1, 4 DESC) temp;

# For each month, rank each category based on its amount of trending videos in US
SELECT *, 
DENSE_RANK() OVER(
	PARTITION BY month
    ORDER BY trending_count DESC
) AS trending_rank
FROM
(SELECT
MONTH(u1.trending_date) as month, 
u2.id, 
u2.title, 
COUNT(DISTINCT u1.video_id) AS trending_count
	FROM US_videos u1
	JOIN US_categories u2 ON u1.category_id = u2.id
GROUP BY 1, 2, 3
ORDER BY 1, 4 DESC) temp;


# Average Daily Views for Most Trending Channels - Use Aggregate Window Function - Visualize in Tableau Later

# Channel with Most Trending Videos - CA - Answer: VikatanTV
WITH top_CA_channel AS
(SELECT 
  channel_title,
  COUNT(DISTINCT video_id) as trending_videos_count
FROM 
  CA_videos
GROUP BY channel_title
ORDER BY trending_videos_count DESC
LIMIT 1)

# Find Average Daily Views for the Channel with Most Trending Videos - CA
SELECT trending_date, 
AVG(views) OVER (PARTITION BY trending_date) daily_avg_views
FROM CA_videos
WHERE 
channel_title IN (SELECT channel_title FROM top_CA_channel)
AND
trending_date BETWEEN (SELECT MIN(trending_date) FROM CA_videos) AND 
                            (SELECT MAX(trending_date) FROM CA_videos)
GROUP BY trending_date;

# Now, compare Average Daily Views with the previous day by calculating % Difference
WITH top_CA_channel AS
(SELECT 
  channel_title,
  COUNT(DISTINCT video_id) as trending_videos_count
FROM 
  CA_videos
GROUP BY channel_title
ORDER BY trending_videos_count DESC
LIMIT 1), 
daily_avg_views_CA AS 
(SELECT trending_date as trending_day,
AVG(views) OVER (PARTITION BY trending_date) daily_avg_views
FROM CA_videos
WHERE 
channel_title IN (SELECT channel_title FROM top_CA_channel)
AND
trending_date BETWEEN (SELECT MIN(trending_date) FROM CA_videos) AND 
                            (SELECT MAX(trending_date) FROM CA_videos)
GROUP BY 1),
daily_and_prev_avg_views_CA AS 
(SELECT trending_day, daily_avg_views, LAG(daily_avg_views) OVER (ORDER BY trending_day) avg_views_lag
    FROM
        daily_avg_views_CA b
    ORDER BY 
        trending_day)

SELECT trending_day, daily_avg_views, avg_views_lag, 
ROUND(100.0 * (daily_avg_views - avg_views_lag) / avg_views_lag, 2) AS Perecent_diff
FROM daily_and_prev_avg_views_CA;

# Repeat Average Daily Views Analysis with US Data

# Channel with Most Trending Videos - US - Answer: ESPN
WITH top_US_channel AS
(SELECT 
  channel_title,
  COUNT(DISTINCT video_id) as trending_videos_count
FROM 
  US_videos
GROUP BY channel_title
ORDER BY trending_videos_count DESC
LIMIT 1)

# Find Average Daily Views for the Channel with Most Trending Videos - US
SELECT trending_date, 
AVG(views) OVER (PARTITION BY trending_date) daily_avg_views
FROM US_videos
WHERE 
channel_title IN (SELECT channel_title FROM top_US_channel)
AND
trending_date BETWEEN (SELECT MIN(trending_date) FROM US_videos) AND 
                            (SELECT MAX(trending_date) FROM US_videos)
GROUP BY trending_date;

# Now, compare Average Daily Views with the previous day by calculating % Difference
WITH top_US_channel AS
(SELECT 
  channel_title,
  COUNT(DISTINCT video_id) as trending_videos_count
FROM 
  US_videos
GROUP BY channel_title
ORDER BY trending_videos_count DESC
LIMIT 1), 
daily_avg_views_US AS 
(SELECT trending_date as trending_day,
AVG(views) OVER (PARTITION BY trending_date) daily_avg_views
FROM US_videos
WHERE 
channel_title IN (SELECT channel_title FROM top_US_channel)
AND
trending_date BETWEEN (SELECT MIN(trending_date) FROM US_videos) AND 
                            (SELECT MAX(trending_date) FROM US_videos)
GROUP BY 1),
daily_and_prev_avg_views_US AS 
(SELECT trending_day, daily_avg_views, LAG(daily_avg_views) OVER (ORDER BY trending_day) avg_views_lag
    FROM
        daily_avg_views_US b
    ORDER BY 
        trending_day)

SELECT trending_day, daily_avg_views, avg_views_lag, 100.0 * (daily_avg_views - avg_views_lag) / avg_views_lag AS Perecent_diff
FROM daily_and_prev_avg_views_US;




# NEXT: partition by day and also by category!

