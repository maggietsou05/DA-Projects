CREATE TABLE spotify AS
SELECT * FROM spotify_rawdata; -- Duplicate table

-- Nulls and missing values check
SELECT COUNT(*)
FROM spotify

SELECT 
COUNT(*) AS total_rows,
  SUM(CASE WHEN artist IS NULL THEN 1 ELSE 0 END) AS null_artists,
  SUM(CASE WHEN track IS NULL THEN 1 ELSE 0 END) AS null_tracks,
  SUM(CASE WHEN album IS NULL THEN 1 ELSE 0 END) AS null_albums,
  SUM(CASE WHEN clean_date IS NULL THEN 1 ELSE 0 END) AS null_dates
FROM spotify;

-- Flagging nulls
ALTER TABLE spotify
ADD COLUMN is_valid_track BOOLEAN;

UPDATE spotify
SET is_valid_track =
  CASE
    WHEN album IS NOT NULL AND artist IS NOT NULL AND track IS NOT NULL
	THEN TRUE ELSE FALSE
  END;

-- Outlier & anomaly checks
ALTER TABLE spotify
ALTER COLUMN ms_played TYPE integer -- change datatype
USING ms_played::integer;

SELECT *
FROM spotify
WHERE ms_played <= 0;

SELECT * FROM spotify
WHERE ms_played > 600000 -- 10 minutes
ORDER BY ms_played DESC;

-- Data type & formats checks
SELECT DISTINCT platform FROM spotify; -- needs grouping
SELECT DISTINCT reason_start FROM spotify;
SELECT DISTINCT reason_end FROM spotify;

SELECT * FROM spotify
ALTER TABLE spotify
ALTER COLUMN skipped TYPE boolean
USING skipped::boolean

-- Data cleaning - platform
ALTER TABLE spotify
ADD COLUMN platform_cleaned TEXT;

UPDATE spotify
SET platform_cleaned =
  CASE 
    WHEN platform ILIKE '%iOS%' THEN 'iOS'
    WHEN platform ILIKE '%web%' THEN 'Web Player'
    WHEN platform ILIKE '%windows%' THEN 'Windows'
    WHEN platform ILIKE '%android%' THEN 'Android'
    ELSE 'Other'
  END;

-- Data cleaning - date
SELECT time_stamp, 
       TO_CHAR(TO_DATE(REPLACE(time_stamp, 'Z', ''), 'YYYY-MM-DD"T"HH24:MI:SS'), 'YYYY-MM-DD') AS cleaned_date
FROM spotify;

ALTER TABLE spotify
ADD COLUMN clean_date DATE

UPDATE spotify
SET clean_date = TO_DATE(REPLACE(time_stamp, 'Z', ''), 'YYYY-MM-DD"T"HH24:MI:SS');

ALTER TABLE spotify
DROP COLUMN time_stamp

-- Data cleaning - country
SELECT DISTINCT country FROM spotify;

ALTER TABLE spotify
ADD COLUMN country_cleaned TEXT

UPDATE spotify
  SET country_cleaned =
  CASE 
    WHEN country LIKE 'CA' THEN 'Canada'
	WHEN country LIKE 'IN' THEN 'India'
	WHEN country LIKE 'MY' THEN 'Malaysia'
	WHEN country LIKE 'HK' THEN 'Hong_Kong'
	WHEN country LIKE 'US' THEN 'United_States'
	WHEN country LIKE 'SG' THEN 'Singapore'
	WHEN country LIKE 'MO' THEN 'Macao'
    WHEN country LIKE 'DE' THEN 'Germany'
	WHEN country LIKE 'AE' THEN 'UAE'
    WHEN country LIKE 'TW' THEN 'Taiwan'
	WHEN country LIKE 'ID' THEN 'Indonesia'
  END;

-- Standardize text columns
UPDATE spotify
SET track = TRIM(album)
WHERE is_valid_track = true;

-- Create clean table to use for analysis
CREATE TABLE spotify_cleaned AS
SELECT *
FROM spotify
WHERE is_valid_track = true;







