-- =============================================================
-- 02_clean_sponsors.sql
-- Purpose : Builds clean_sponsors from raw_sponsors.
--           Trims whitespace, extracts structured fields from
--           the composite "Type & Rating" column, and adds a
--           Skilled Worker flag for Power BI filtering.
-- Depends : raw_sponsors (run 01_create_raw_sponsors.sql first)
-- =============================================================

-- Drop and recreate to allow safe re-runs on monthly data refresh
DROP TABLE IF EXISTS clean_sponsors;

CREATE TABLE clean_sponsors AS
SELECT
    TRIM("Organisation Name")  AS organisation_name,
    TRIM("Town/City")          AS town_city,
    TRIM("County")             AS county,
    TRIM("Route")              AS route,

    -- Whether this is a permanent Worker or Temporary Worker licence
    CASE
        WHEN "Type & Rating" ILIKE 'Temporary Worker%' THEN 'Temporary Worker'
        ELSE 'Worker'
    END AS sponsor_type,

    -- Compliance rating: A = fully licensed, B = under action plan
    CASE
        WHEN "Type & Rating" ILIKE '%B rating%'      THEN 'B'
        WHEN "Type & Rating" ILIKE '%A (Premium)%'   THEN 'A (Premium)'
        WHEN "Type & Rating" ILIKE '%A (SME+)%'      THEN 'A (SME+)'
        WHEN "Type & Rating" ILIKE '%Provisional%'   THEN 'Provisional'
        ELSE 'A'
    END AS rating,

    -- TRUE for rows relevant to standard Skilled Worker visa applicants
    ("Route" = 'Skilled Worker') AS is_skilled_worker

FROM raw_sponsors;

-- =============================================================
-- Verification query — run after creation to confirm counts
-- Expected: ~121,344 Skilled Worker rows, ~141,165 total
-- =============================================================
-- SELECT sponsor_type, rating, is_skilled_worker, COUNT(*) AS count
-- FROM clean_sponsors
-- GROUP BY sponsor_type, rating, is_skilled_worker
-- ORDER BY count DESC;
