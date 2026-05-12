-- =============================================================
-- 04_sector_tagging.sql
-- Purpose : Adds a sector column to clean_sponsors using keyword
--           pattern matching on organisation_name.
-- Coverage: ~20% of rows classified by name alone.
--           The remaining ~80% ('Other') will be reclassified in
--           05_companies_house_enrichment.sql using SIC codes.
-- Note    : Order of CASE conditions matters — more specific
--           patterns must appear before broader ones.
-- Depends : clean_sponsors (run 02 and 03 first)
-- =============================================================

ALTER TABLE clean_sponsors
ADD COLUMN IF NOT EXISTS sector TEXT;

UPDATE clean_sponsors
SET sector = CASE

    -- NHS: single largest sponsor group in the UK
    WHEN organisation_name ILIKE '%nhs%'
      OR organisation_name ILIKE '%national health service%'
      OR organisation_name ILIKE '%foundation trust%'
      OR organisation_name ILIKE '%integrated care%'
        THEN 'NHS & Public Health'

    -- Healthcare (non-NHS): hospitals, clinics, dental, pharmacy
    WHEN organisation_name ILIKE '%hospital%'
      OR organisation_name ILIKE '%clinic%'
      OR organisation_name ILIKE '%medical%'
      OR organisation_name ILIKE '%healthcare%'
      OR organisation_name ILIKE '%health care%'
      OR organisation_name ILIKE '%pharmacy%'
      OR organisation_name ILIKE '%dental%'
      OR organisation_name ILIKE '%dentist%'
      OR organisation_name ILIKE '%hospice%'
      OR organisation_name ILIKE '%physiother%'
      OR organisation_name ILIKE '%radiology%'
      OR organisation_name ILIKE '%oncology%'
      OR organisation_name ILIKE '%optician%'
      OR organisation_name ILIKE '%health%'
      OR organisation_name ILIKE '%therapeutics%'
      OR organisation_name ILIKE '%diagnostics%'
      OR organisation_name ILIKE '%surgery%'
      OR organisation_name ILIKE '%gp %'
        THEN 'Healthcare'

    -- Social care: care homes, domiciliary, residential
    WHEN organisation_name ILIKE '%care home%'
      OR organisation_name ILIKE '%nursing home%'
      OR organisation_name ILIKE '%residential care%'
      OR organisation_name ILIKE '%domiciliary%'
      OR organisation_name ILIKE '%home care%'
      OR organisation_name ILIKE '%supported living%'
        THEN 'Social Care'

    -- Education: universities, colleges, schools
    WHEN organisation_name ILIKE '%university%'
      OR organisation_name ILIKE '%college%'
      OR organisation_name ILIKE '%school%'
      OR organisation_name ILIKE '%academy%'
      OR organisation_name ILIKE '%education%'
        THEN 'Education'

    -- Technology: software, digital, cyber, telecoms
    WHEN organisation_name ILIKE '%technology%'
      OR organisation_name ILIKE '%software%'
      OR organisation_name ILIKE '%digital%'
      OR organisation_name ILIKE '%cyber%'
      OR organisation_name ILIKE '%artificial intelligence%'
      OR organisation_name ILIKE '%machine learning%'
      OR organisation_name ILIKE '%data science%'
      OR organisation_name ILIKE '%telecom%'
      OR organisation_name ILIKE '%telecommunications%'
      OR organisation_name ILIKE '% tech %'
      OR organisation_name ILIKE '% tech'
      OR organisation_name ILIKE 'tech %'
      OR organisation_name ILIKE '%information technology%'
      OR organisation_name ILIKE '%it services%'
      OR organisation_name ILIKE '%cloud%'
      OR organisation_name ILIKE '%semiconductor%'
        THEN 'Technology'

    -- Finance: banks, insurance, investment, fintech
    WHEN organisation_name ILIKE '%bank%'
      OR organisation_name ILIKE '%finance%'
      OR organisation_name ILIKE '%financial%'
      OR organisation_name ILIKE '%insurance%'
      OR organisation_name ILIKE '%investment%'
      OR organisation_name ILIKE '%capital%'
      OR organisation_name ILIKE '%asset management%'
      OR organisation_name ILIKE '%wealth%'
      OR organisation_name ILIKE '%fintech%'
      OR organisation_name ILIKE '%mortgage%'
        THEN 'Finance & Banking'

    -- Legal: law firms, solicitors, barristers
    WHEN organisation_name ILIKE '%solicitor%'
      OR organisation_name ILIKE '%barrister%'
      OR organisation_name ILIKE '%chambers%'
      OR organisation_name ILIKE '%law firm%'
      OR organisation_name ILIKE '% law %'
      OR organisation_name ILIKE '%legal%'
        THEN 'Legal'

    -- Consulting: management consulting, advisory
    WHEN organisation_name ILIKE '%consulting%'
      OR organisation_name ILIKE '%consultancy%'
      OR organisation_name ILIKE '%advisory%'
      OR organisation_name ILIKE '%advisors%'
      OR organisation_name ILIKE '%advisers%'
        THEN 'Consulting'

    -- Engineering & Construction
    WHEN organisation_name ILIKE '%engineering%'
      OR organisation_name ILIKE '%construction%'
      OR organisation_name ILIKE '%infrastructure%'
      OR organisation_name ILIKE '%architect%'
      OR organisation_name ILIKE '%surveyor%'
        THEN 'Engineering & Construction'

    -- Hospitality & Food
    WHEN organisation_name ILIKE '%hotel%'
      OR organisation_name ILIKE '%restaurant%'
      OR organisation_name ILIKE '%catering%'
      OR organisation_name ILIKE '%hospitality%'
      OR organisation_name ILIKE '%takeaway%'
      OR organisation_name ILIKE '%cuisine%'
        THEN 'Hospitality & Food'

    -- Recruitment & Staffing
    WHEN organisation_name ILIKE '%recruitment%'
      OR organisation_name ILIKE '%staffing%'
      OR organisation_name ILIKE '%manpower%'
        THEN 'Recruitment & Staffing'

    -- Transport & Logistics
    WHEN organisation_name ILIKE '%transport%'
      OR organisation_name ILIKE '%logistics%'
      OR organisation_name ILIKE '%shipping%'
      OR organisation_name ILIKE '%freight%'
      OR organisation_name ILIKE '%aviation%'
      OR organisation_name ILIKE '%airline%'
        THEN 'Transport & Logistics'

    -- Manufacturing
    WHEN organisation_name ILIKE '%manufacturing%'
      OR organisation_name ILIKE '%industrial%'
        THEN 'Manufacturing'

    ELSE 'Other'
END;

-- =============================================================
-- Verification query
-- ~80% 'Other' is expected at this stage — SIC codes from
-- Companies House (05_companies_house_enrichment.sql) will
-- reclassify the majority of the 'Other' bucket.
-- =============================================================
-- SELECT sector, COUNT(*) AS count
-- FROM clean_sponsors
-- WHERE is_skilled_worker = true
-- GROUP BY sector
-- ORDER BY count DESC;
