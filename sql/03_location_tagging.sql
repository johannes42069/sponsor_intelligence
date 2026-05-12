-- =============================================================
-- 03_location_tagging.sql
-- Purpose : Adds city_clean and uk_region columns to clean_sponsors.
--           city_clean normalises case and strips sub-area prefixes.
--           uk_region maps to ONS regions for Power BI filtering.
-- Coverage: ~80% of rows mapped to named regions.
--           Remaining ~20% tagged 'Other UK' — genuinely dispersed
--           small towns requiring a postcode lookup to map further.
-- Depends : clean_sponsors (run 02_clean_sponsors.sql first)
-- =============================================================

ALTER TABLE clean_sponsors
ADD COLUMN IF NOT EXISTS city_clean TEXT,
ADD COLUMN IF NOT EXISTS uk_region  TEXT;

-- city_clean: normalise case, take part before first comma
-- Special case: if original contains 'london', always return 'London'
UPDATE clean_sponsors
SET city_clean = CASE
    WHEN town_city ILIKE '%london%'
        THEN 'London'
    ELSE INITCAP(TRIM(SPLIT_PART(town_city, ',', 1)))
END;

-- uk_region pass 1: major cities and London keyword match
UPDATE clean_sponsors
SET uk_region = CASE
    WHEN town_city ILIKE '%london%'
        THEN 'London'
    WHEN city_clean IN (
        'Glasgow','Edinburgh','Aberdeen','Dundee','Inverness',
        'Stirling','Perth','Paisley','Livingston','Falkirk')
        THEN 'Scotland'
    WHEN city_clean IN (
        'Cardiff','Swansea','Newport','Wrexham','Bridgend','Barry')
        THEN 'Wales'
    WHEN city_clean IN (
        'Belfast','Derry','Londonderry','Lisburn','Newry')
        THEN 'Northern Ireland'
    WHEN city_clean IN (
        'Manchester','Liverpool','Salford','Preston','Bolton',
        'Oldham','Rochdale','Blackpool','Warrington','Wigan',
        'Altrincham','Chester','Stockport','Bury','Burnley','Blackburn')
        THEN 'North West'
    WHEN city_clean IN (
        'Leeds','Sheffield','Bradford','Hull','York','Huddersfield',
        'Halifax','Wakefield','Barnsley','Rotherham','Doncaster',
        'Harrogate','Morley')
        THEN 'Yorkshire and The Humber'
    WHEN city_clean IN (
        'Newcastle','Sunderland','Middlesbrough','Durham','Gateshead',
        'Hartlepool','Stockton','Darlington','Newcastle Upon Tyne')
        THEN 'North East'
    WHEN city_clean IN (
        'Birmingham','Coventry','Wolverhampton','Walsall','Dudley',
        'Stoke-On-Trent','Stoke On Trent','Worcester','Hereford','Solihull')
        THEN 'West Midlands'
    WHEN city_clean IN (
        'Leicester','Nottingham','Derby','Lincoln','Northampton','Loughborough')
        THEN 'East Midlands'
    WHEN city_clean IN (
        'Cambridge','Norwich','Ipswich','Luton','Colchester',
        'Chelmsford','Stevenage','Hertford','Watford','St Albans')
        THEN 'East of England'
    WHEN city_clean IN (
        'Bristol','Bath','Exeter','Plymouth','Swindon','Gloucester',
        'Cheltenham','Bournemouth','Poole','Taunton','Salisbury','Truro')
        THEN 'South West'
    WHEN city_clean IN (
        'Brighton','Oxford','Reading','Southampton','Portsmouth',
        'Guildford','Milton Keynes','Slough','Crawley','Maidstone',
        'Canterbury','Winchester','Basingstoke','Woking','Fareham',
        'Worthing','Eastbourne')
        THEN 'South East'
    ELSE 'Other / Unknown'
END;

-- uk_region pass 2: London boroughs and additional cities
UPDATE clean_sponsors
SET uk_region = CASE
    WHEN city_clean IN (
        'Ilford','Harrow','Croydon','Hounslow','Romford','Southall','Hayes',
        'Wembley','Enfield','Barnet','Tottenham','Stratford','Dagenham',
        'Lewisham','Woolwich','Wimbledon','Sutton','Twickenham','Ealing',
        'Acton','Battersea','Brixton','Hackney','Islington','Camberwell',
        'Peckham','Bromley','Bexleyheath','Bexley','Sidcup','Greenford',
        'Northolt','Edgware','Stanmore','Ruislip','Feltham','Mitcham',
        'Thornton Heath','Streatham','Tooting','Putney','Fulham','Chiswick',
        'Brentford','Greenwich','Eltham','Kingston Upon Thames','New Malden',
        'Surbiton','Richmond','Hammersmith','Finchley','Hendon',
        'Walthamstow','Leyton','Leytonstone','Woodford','Chingford',
        'Edmonton','Palmers Green','Holloway','Stoke Newington','Dalston',
        'Bethnal Green','Bow','Whitechapel','Bermondsey','Rotherhithe',
        'Deptford','Catford','Beckenham','Orpington','Barking','Rainham',
        'Shepherd''S Bush')
        THEN 'London'
    WHEN city_clean IN ('Essex','Middlesex') THEN 'East of England'
    WHEN city_clean IN ('Surrey','Kent','Hampshire','Berkshire',
        'Buckinghamshire','Oxfordshire') THEN 'South East'
    WHEN city_clean IN ('Suffolk','Norfolk','Cambridgeshire',
        'Bedfordshire','Hertfordshire') THEN 'East of England'
    WHEN city_clean IN (
        'High Wycombe','Maidenhead','Bracknell','Aylesbury','Dartford',
        'Gravesend','Sevenoaks','Tonbridge','Sittingbourne','Newbury',
        'Andover','Eastleigh','Havant','Gosport','Farnham','Fleet',
        'Camberley','Staines','Egham','Leatherhead','Dorking','Banstead',
        'Caterham','Weybridge','Walton-On-Thames','Esher','Cobham',
        'Windsor','Eton','Marlow','Amersham','Chesham','Beaconsfield')
        THEN 'South East'
    WHEN city_clean IN (
        'Bedford','Hemel Hempstead','Welwyn','Hatfield','Potters Bar',
        'Borehamwood','Bishops Stortford','Harlow','Braintree','Basildon',
        'Thurrock','Grays','Dunstable','Leighton Buzzard','St Neots',
        'Huntingdon','Wisbech','Ely','Kings Lynn','Peterborough')
        THEN 'East of England'
    WHEN city_clean IN (
        'Warwick','Leamington Spa','Rugby','Nuneaton','Redditch',
        'Kidderminster','Cannock','Lichfield','Tamworth','Burton Upon Trent',
        'Telford','Shrewsbury','Stafford','Newcastle-Under-Lyme','Crewe')
        THEN 'West Midlands'
    WHEN city_clean IN (
        'Mansfield','Chesterfield','Grantham','Melton Mowbray',
        'Hinckley','Kettering','Wellingborough','Corby')
        THEN 'East Midlands'
    WHEN city_clean IN (
        'Torquay','Paignton','Barnstaple','Bideford','Newquay',
        'Falmouth','Penzance','St Austell','Yeovil','Bridgwater',
        'Weston-Super-Mare','Minehead')
        THEN 'South West'
    WHEN city_clean IN (
        'Dewsbury','Keighley','Skipton','Selby','Pontefract',
        'Castleford','Wakefield')
        THEN 'Yorkshire and The Humber'
    WHEN city_clean IN (
        'Kendal','Lancaster','Morecambe','Accrington','Colne',
        'Skelmersdale','Ormskirk','Southport','St Helens','Runcorn',
        'Widnes','Ellesmere Port','Macclesfield','Wilmslow','Knutsford')
        THEN 'North West'
    WHEN city_clean IN (
        'Hexham','Morpeth','Ashington','Blyth','Peterlee',
        'Newton Aycliffe','Bishop Auckland','Consett')
        THEN 'North East'
    WHEN city_clean IN (
        'Rhyl','Colwyn Bay','Bangor','Caernarfon','Llandudno',
        'Merthyr Tydfil','Aberdare','Pontypridd','Penarth',
        'Cwmbran','Pontypool','Abergavenny')
        THEN 'Wales'
    WHEN city_clean IN (
        'Ayr','Kilmarnock','Motherwell','Hamilton','Coatbridge',
        'Airdrie','Dumfries','Kirkcaldy','Dunfermline','Glenrothes',
        'Alloa','Bathgate','Cumbernauld')
        THEN 'Scotland'
    ELSE uk_region
END
WHERE uk_region = 'Other / Unknown';

-- Rename for dashboard presentation
UPDATE clean_sponsors
SET uk_region = 'Other UK'
WHERE uk_region = 'Other / Unknown';

-- =============================================================
-- Verification query
-- Expected: London ~53k, Other UK ~20%, all named regions present
-- =============================================================
-- SELECT uk_region, COUNT(*) AS count
-- FROM clean_sponsors
-- GROUP BY uk_region
-- ORDER BY count DESC;
