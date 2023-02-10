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





