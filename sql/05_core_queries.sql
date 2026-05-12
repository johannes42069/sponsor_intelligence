-- =============================================================
-- 05_core_queries.sql
-- Purpose : Five analytical queries powering the Power BI dashboard.
--           Each answers a key question for international students
--           searching for UK Skilled Worker visa sponsors.
-- Depends : clean_sponsors (run 02, 03, 04 first)
-- =============================================================


-- Query 1: Top sponsors in tech, data, and finance sectors
-- Use case: User wants to find named firms in their target industry
SELECT organisation_name, city_clean, uk_region, sector, rating
FROM clean_sponsors
WHERE is_skilled_worker = true
  AND sector IN ('Technology', 'Consulting', 'Finance & Banking')
  AND rating = 'A'
ORDER BY organisation_name;


-- Query 2: Sponsor count by UK region
-- Use case: Map visual and regional filter in Power BI
-- Key insight: London accounts for ~36% of all Skilled Worker sponsors
SELECT uk_region,
       COUNT(DISTINCT organisation_name) AS sponsor_count
FROM clean_sponsors
WHERE is_skilled_worker = true
  AND rating = 'A'
GROUP BY uk_region
ORDER BY sponsor_count DESC;


-- Query 3: Sponsor count by sector
-- Use case: Sector breakdown bar chart in Power BI
-- Note: 'Other' is large due to name-based tagging limits — see README
SELECT sector,
       COUNT(DISTINCT organisation_name) AS sponsor_count
FROM clean_sponsors
WHERE is_skilled_worker = true
  AND rating = 'A'
GROUP BY sector
ORDER BY sponsor_count DESC;


-- Query 4: Top 20 cities by sponsor count
-- Use case: City-level drill-down and city filter slicer
SELECT city_clean,
       COUNT(DISTINCT organisation_name) AS sponsor_count
FROM clean_sponsors
WHERE is_skilled_worker = true
  AND rating = 'A'
GROUP BY city_clean
ORDER BY sponsor_count DESC
LIMIT 20;


-- Query 5: B-rated Skilled Worker sponsors (compliance risk)
-- Use case: Warning callout in dashboard — these firms are under
--           Home Office compliance action and may lose their licence
-- Note: Only 15 B-rated Skilled Worker sponsors as of May 2026
SELECT organisation_name, city_clean, uk_region, sector
FROM clean_sponsors
WHERE is_skilled_worker = true
  AND rating = 'B'
ORDER BY organisation_name;
