


-- ==================================================================================================================================
  ██████████████████████████████████████████████████████████████   ██████████████████████████████████████████████████████████████
--  AHMEDABAD METRO RAIL SYSTEM — DUMMY DATA INSERTION SCRIPT
--  Part 1 of 3 : LINE → STATION → PLATFORM → STATION_ON_LINE → TRACK
--  Source       : Real data from Gujarat Metro Rail Corporation (GMRC)
--                 Wikipedia / YoMetro / Official GMRC website
--  Order        : Parent tables first, then FK-dependent tables
  ██████████████████████████████████████████████████████████████   ██████████████████████████████████████████████████████████████
-- ==================================================================================================================================
 

 
-- ================================================================
--  1. LINE  (4 operational lines as of 2026)
-- ================================================================
 
INSERT INTO metro.LINE
    (line_code, line_name, color_code, total_length_km,
     total_stations, status, operational_since, description)
VALUES
-- Blue Line (East-West Corridor, Phase 1)
('L1', 'Blue Line',
 '#0000FF', 21.23, 18, 'OPERATIONAL', '2019-03-04',
 'East-West Corridor Phase 1. Vastral Gam to Thaltej Gam. '
 '4 underground + 14 elevated stations.'),
 
-- Red Line (North-South Corridor, Phase 1)
('L2', 'Red Line',
 '#FF0000', 22.80, 15, 'OPERATIONAL', '2022-10-06',
 'North-South Corridor Phase 1. APMC Vasna to Motera Stadium. '
 'All elevated stations.'),
 
-- Yellow Line (Phase 2 — Motera to Mahatma Mandir, Gandhinagar)
('L3', 'Yellow Line',
 '#FFD700', 28.25, 21, 'OPERATIONAL', '2024-09-17',
 'Phase 2 Yellow Line. Motera Stadium to Mahatma Mandir, Gandhinagar. '
 'Fully elevated, connects Ahmedabad to Gandhinagar.'),
 
-- Violet Line (Phase 2 spur — GNLU to GIFT City)
('L4', 'Violet Line',
 '#8B00FF', 5.42, 2, 'OPERATIONAL', '2024-09-17',
 'Phase 2 Violet Line spur. GNLU to GIFT City. '
 'Connects Gandhinagar Financial Hub to metro network.');

 
-- ================================================================
--  2. STATION  (All 54 operational stations with real coordinates)
-- ================================================================
 
INSERT INTO metro.STATION
    (station_code, station_name, station_type, zone_no,
     latitude, longitude, address, city, opening_date,
     has_lift, has_escalator, has_parking, has_feeder_bus,
     wheelchair_accessible, is_interchange, is_terminal, is_active)
VALUES
-- ── BLUE LINE (L1) — 18 stations ──────────────────────────────
('VTG', 'Vastral Gam',         'ELEVATED',     1,  23.0021,  72.6421,
 'Vastral Gam, Vastral, Ahmedabad',         'Ahmedabad', '2019-03-04',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,TRUE,TRUE),
 
('VTR', 'Vastral',             'ELEVATED',     1,  23.0063,  72.6310,
 'Vastral, Ahmedabad',                      'Ahmedabad', '2019-03-04',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('RBC', 'Rabari Colony',       'ELEVATED',     1,  23.0137,  72.6159,
 'Rabari Colony, Vastral Road, Ahmedabad',  'Ahmedabad', '2019-03-04',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('AMR', 'Amraiwadi',           'ELEVATED',     1,  23.0167,  72.6042,
 'Amraiwadi, Ahmedabad',                    'Ahmedabad', '2019-03-04',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('APL', 'Apparel Park',        'ELEVATED',     1,  23.0198,  72.5941,
 'Apparel Park, Narol-Naroda Rd, Ahmedabad','Ahmedabad', '2019-03-04',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('KKE', 'Kankaria East',       'UNDERGROUND',  2,  23.0013,  72.5955,
 'Kankaria Lake East Gate, Ahmedabad',      'Ahmedabad', '2022-10-02',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('KLP', 'Kalupur Railway Station','UNDERGROUND',2, 23.0269,  72.5874,
 'Kalupur, Near Ahmedabad Junction, Ahmedabad','Ahmedabad','2022-10-02',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('GHK', 'Gheekanta',           'UNDERGROUND',  2,  23.0338,  72.5831,
 'Gheekanta Road, Ahmedabad',               'Ahmedabad', '2022-10-02',
 TRUE,TRUE,FALSE,FALSE,TRUE,FALSE,FALSE,TRUE),
 
('SHP', 'Shahpur',             'UNDERGROUND',  2,  23.0394,  72.5795,
 'Shahpur, Old City, Ahmedabad',            'Ahmedabad', '2022-10-02',
 TRUE,TRUE,FALSE,FALSE,TRUE,FALSE,FALSE,TRUE),
 
('OHC', 'Old High Court',      'ELEVATED',     2,  23.0452,  72.5762,
 'High Court Area, Ahmedabad',              'Ahmedabad', '2022-10-02',
 TRUE,TRUE,FALSE,TRUE,TRUE,TRUE,FALSE,TRUE),  -- INTERCHANGE
 
('SPS', 'SP Stadium',          'ELEVATED',     2,  23.0543,  72.5725,
 'SP Stadium, Navrangpura, Ahmedabad',      'Ahmedabad', '2022-10-02',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('CXR', 'Commerce Six Road',   'ELEVATED',     2,  23.0619,  72.5698,
 'Commerce Six Roads, Navrangpura, Ahmedabad','Ahmedabad','2022-10-02',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('GUV', 'Gujarat University',  'ELEVATED',     3,  23.0698,  72.5612,
 'Gujarat University Campus, Ahmedabad',    'Ahmedabad', '2022-10-02',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('GKR', 'Gurukul Road',        'ELEVATED',     3,  23.0771,  72.5551,
 'Gurukul Road, Memnagar, Ahmedabad',       'Ahmedabad', '2022-10-02',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('DDK', 'Doordarshan Kendra',  'ELEVATED',     3,  23.0842,  72.5498,
 'Doordarshan Kendra, Drive-In Road, Ahmedabad','Ahmedabad','2022-10-02',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('TLT', 'Thaltej',             'ELEVATED',     3,  23.0913,  72.5412,
 'Thaltej, S.G. Highway, Ahmedabad',        'Ahmedabad', '2022-10-02',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('TLG', 'Thaltej Gam',         'ELEVATED',     3,  23.0961,  72.5356,
 'Thaltej Gam Village, Ahmedabad',          'Ahmedabad', '2024-12-08',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,TRUE,TRUE),
 
('NCR', 'Nirant Cross Road',   'ELEVATED',     1,  23.0089,  72.6498,
 'Nirant Cross Road, Vastral, Ahmedabad',   'Ahmedabad', '2019-03-04',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
-- ── RED LINE (L2) — 15 stations ────────────────────────────────
('APC', 'APMC',                'ELEVATED',     1,  22.9892,  72.5603,
 'APMC Vegetable Market, Vasna, Ahmedabad', 'Ahmedabad', '2022-10-06',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,TRUE,TRUE),
 
('JVP', 'Jivraj Park',         'ELEVATED',     1,  22.9971,  72.5588,
 'Jivraj Park, Ahmedabad',                  'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('RJN', 'Rajiv Nagar',         'ELEVATED',     1,  23.0042,  72.5562,
 'Rajiv Nagar, Ahmedabad',                  'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('SHR', 'Shreyas',             'ELEVATED',     2,  23.0121,  72.5538,
 'Shreyas Crossing, Ahmedabad',             'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('PAL', 'Paldi',               'ELEVATED',     2,  23.0211,  72.5538,
 'Paldi, Ahmedabad',                        'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('GDG', 'Gandhigram',          'ELEVATED',     2,  23.0298,  72.5556,
 'Gandhigram, Ashram Road, Ahmedabad',      'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
-- OHC already inserted above (interchange)
 
('USM', 'Usmanpura',           'ELEVATED',     2,  23.0532,  72.5667,
 'Usmanpura, Ashram Road, Ahmedabad',       'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('VJN', 'Vijay Nagar',         'ELEVATED',     2,  23.0612,  72.5621,
 'Vijay Nagar Cross Road, Ahmedabad',       'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('VDJ', 'Vadaj',               'ELEVATED',     3,  23.0731,  72.5589,
 'Vadaj, Ahmedabad',                        'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('RNP', 'Ranip',               'ELEVATED',     3,  23.0841,  72.5556,
 'Ranip, Ahmedabad',                        'Ahmedabad', '2022-10-06',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('SBR', 'Sabarmati',           'ELEVATED',     3,  23.0942,  72.5521,
 'Sabarmati, Ahmedabad',                    'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('AEC', 'AEC',                 'ELEVATED',     3,  23.0998,  72.5498,
 'AEC Cross Road, Ahmedabad',               'Ahmedabad', '2022-10-06',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('MTS', 'Motera Stadium',      'ELEVATED',     3,  23.1042,  72.5467,
 'Narendra Modi Stadium, Motera, Ahmedabad','Ahmedabad', '2022-10-06',
 TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,TRUE),  -- INTERCHANGE (Red+Yellow)
 
-- ── YELLOW LINE (L3) — 21 stations ─────────────────────────────
-- Motera Stadium already inserted above (interchange)
 
('SC1', 'Sector-1 Gandhinagar','ELEVATED',     3,  23.1142,  72.5423,
 'Sector-1, Gandhinagar',                   'Gandhinagar','2024-09-17',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('IFC', 'Infocity',            'ELEVATED',     3,  23.1231,  72.5389,
 'Infocity Campus, Gandhinagar',            'Gandhinagar','2024-09-17',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('DHC', 'Dholakuva Circle',    'ELEVATED',     3,  23.1312,  72.5341,
 'Dholakuva Circle, Gandhinagar',           'Gandhinagar','2024-09-17',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('RDS', 'Randesan',            'ELEVATED',     3,  23.1398,  72.5298,
 'Randesan Village, Gandhinagar',           'Gandhinagar','2024-09-17',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('GNL', 'GNLU',                'ELEVATED',     3,  23.1489,  72.5254,
 'Gujarat National Law University, Gandhinagar','Gandhinagar','2024-09-17',
 TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,TRUE),  -- INTERCHANGE (Yellow+Violet)
 
('RYS', 'Raysan',              'ELEVATED',     3,  23.1554,  72.5213,
 'Raysan, Gandhinagar',                     'Gandhinagar','2024-09-17',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('KBC', 'Koba Circle',         'ELEVATED',     3,  23.1623,  72.5178,
 'Koba Circle, Gandhinagar',                'Gandhinagar','2025-04-27',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('NMC', 'Narmada Canal',       'ELEVATED',     4,  23.1698,  72.5134,
 'Narmada Canal, Gandhinagar',              'Gandhinagar','2025-04-27',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('TPC', 'Tapovan Circle',      'ELEVATED',     4,  23.1774,  72.5089,
 'Tapovan Circle, Gandhinagar',             'Gandhinagar','2025-04-27',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('VKC', 'Vishwakarma College', 'ELEVATED',     4,  23.1843,  72.5041,
 'Vishwakarma College of Arts, Gandhinagar','Gandhinagar','2025-04-27',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('KTR', 'Koteshwar Road',      'ELEVATED',     4,  23.1912,  72.4998,
 'Koteshwar Road, Gandhinagar',             'Gandhinagar','2025-04-27',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('S10', 'Sector-10A Gandhinagar','ELEVATED',   4,  23.1983,  72.4956,
 'Sector-10A, Gandhinagar',                 'Gandhinagar','2025-04-27',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('SCH', 'Sachivalaya',         'ELEVATED',     4,  23.2054,  72.4912,
 'Sachivalaya (Secretariat), Gandhinagar',  'Gandhinagar','2025-04-27',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('JNK', 'Juna Koba',           'ELEVATED',     4,  23.2134,  72.4868,
 'Juna Koba Village, Gandhinagar',          'Gandhinagar','2025-09-28',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('KOG', 'Koba Gam',            'ELEVATED',     4,  23.2213,  72.4823,
 'Koba Gam, Gandhinagar',                   'Gandhinagar','2025-09-28',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('AKS', 'Akshardham',          'ELEVATED',     4,  23.2287,  72.4781,
 'Akshardham Temple Road, Gandhinagar',     'Gandhinagar','2026-01-11',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('JNS', 'Juna Sachivalaya',    'ELEVATED',     4,  23.2361,  72.4739,
 'Old Secretariat, Gandhinagar',            'Gandhinagar','2026-01-11',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('S16', 'Sector-16 Gandhinagar','ELEVATED',    4,  23.2431,  72.4696,
 'Sector-16, Gandhinagar',                  'Gandhinagar','2026-01-11',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('S24', 'Sector-24 Gandhinagar','ELEVATED',    4,  23.2501,  72.4651,
 'Sector-24, Gandhinagar',                  'Gandhinagar','2026-01-11',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('MMD', 'Mahatma Mandir',      'ELEVATED',     4,  23.2572,  72.4608,
 'Mahatma Mandir Convention Centre, Gandhinagar','Gandhinagar','2026-01-11',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,TRUE,TRUE),
 
-- ── VIOLET LINE (L4) — 2 stations ──────────────────────────────
-- GNLU already inserted above (interchange)
 
('PDU', 'PDEU',                'ELEVATED',     3,  23.1621,  72.6641,
 'Pandit Deendayal Energy University, GIFT City Road','Gandhinagar','2024-09-17',
 TRUE,TRUE,FALSE,TRUE,TRUE,FALSE,FALSE,TRUE),
 
('GFT', 'GIFT City',           'ELEVATED',     3,  23.1683,  72.6712,
 'GIFT City, Gujarat International Finance Tec-City','Gandhinagar','2024-09-17',
 TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,TRUE,TRUE);


 
-- ================================================================
--  3. PLATFORM  (weak entity — at least 2 per station)
--  Real Ahmedabad Metro: elevated = side platforms,
--  underground = island platforms
-- ================================================================
 
-- Helper: insert 2 platforms for each station
-- Elevated stations → NORTHBOUND/SOUTHBOUND or EASTBOUND/WESTBOUND
-- Underground (island) → single island = 2 entries pointing same direction
 
DO $plat$
DECLARE
    r RECORD;
    dir1 metro.direction_t;
    dir2 metro.direction_t;
BEGIN
    FOR r IN
        SELECT station_id, station_code, station_type
        FROM   metro.STATION
        WHERE  is_deleted = FALSE
        ORDER  BY station_id
    LOOP
        -- Blue Line stations (East-West) get E/W directions
        -- Red/Yellow/Violet (mostly N-S) get N/S directions
        IF r.station_code IN (
            'VTG','VTR','RBC','AMR','APL','KKE','KLP','GHK',
            'SHP','OHC','SPS','CXR','GUV','GKR','DDK','TLT','TLG','NCR'
        ) THEN
            dir1 := 'EASTBOUND';  dir2 := 'WESTBOUND';
        ELSE
            dir1 := 'NORTHBOUND'; dir2 := 'SOUTHBOUND';
        END IF;
 
        INSERT INTO metro.PLATFORM
            (station_id, platform_no, direction, capacity,
             has_screen_doors, has_cctv, is_available)
        VALUES
            (r.station_id, 1, dir1, 800, TRUE, TRUE, TRUE),
            (r.station_id, 2, dir2, 800, TRUE, TRUE, TRUE);
    END LOOP;
END $plat$;





-- ================================================================
--  4. STATION_ON_LINE  (real sequence and distance data)
-- ================================================================
 
-- ── BLUE LINE (L1) — East to West ─────────────────────────────
INSERT INTO metro.STATION_ON_LINE
    (line_id, station_id, sequence_no, dist_from_start_km,
     default_halt_sec, is_terminal, is_active)
SELECT
    l.line_id,
    s.station_id,
    v.seq_no,
    v.dist_km,
    30,
    v.is_terminal,
    TRUE
FROM metro.LINE l
CROSS JOIN (VALUES
    ('NCR',  1,  0.00, TRUE),
    ('VTG',  2,  1.10, FALSE),
    ('VTR',  3,  2.30, FALSE),
    ('RBC',  4,  3.60, FALSE),
    ('AMR',  5,  5.10, FALSE),
    ('APL',  6,  6.50, FALSE),
    ('KKE',  7,  7.80, FALSE),
    ('KLP',  8,  9.30, FALSE),
    ('GHK',  9, 10.50, FALSE),
    ('SHP', 10, 11.40, FALSE),
    ('OHC', 11, 12.20, FALSE),
    ('SPS', 12, 13.10, FALSE),
    ('CXR', 13, 14.00, FALSE),
    ('GUV', 14, 15.10, FALSE),
    ('GKR', 15, 16.30, FALSE),
    ('DDK', 16, 17.40, FALSE),
    ('TLT', 17, 19.80, FALSE),
    ('TLG', 18, 21.23, TRUE)
) AS v(code, seq_no, dist_km, is_terminal)
JOIN metro.STATION s ON s.station_code = v.code
WHERE l.line_code = 'L1';
 
-- ── RED LINE (L2) — South to North ────────────────────────────
INSERT INTO metro.STATION_ON_LINE
    (line_id, station_id, sequence_no, dist_from_start_km,
     default_halt_sec, is_terminal, is_active)
SELECT
    l.line_id,
    s.station_id,
    v.seq_no,
    v.dist_km,
    30,
    v.is_terminal,
    TRUE
FROM metro.LINE l
CROSS JOIN (VALUES
    ('APC',  1,  0.00, TRUE),
    ('JVP',  2,  1.20, FALSE),
    ('RJN',  3,  2.50, FALSE),
    ('SHR',  4,  3.70, FALSE),
    ('PAL',  5,  5.10, FALSE),
    ('GDG',  6,  6.30, FALSE),
    ('OHC',  7,  7.60, FALSE),
    ('USM',  8,  8.90, FALSE),
    ('VJN',  9, 10.20, FALSE),
    ('VDJ', 10, 11.60, FALSE),
    ('RNP', 11, 13.10, FALSE),
    ('SBR', 12, 14.80, FALSE),
    ('AEC', 13, 16.40, FALSE),
    ('MTS', 14, 18.10, FALSE),
    ('MMD', 15, 22.80, TRUE)  -- Sabarmati Railway Station (placeholder)
) AS v(code, seq_no, dist_km, is_terminal)
JOIN metro.STATION s ON s.station_code = v.code
WHERE l.line_code = 'L2';
 
-- ── YELLOW LINE (L3) — Motera to Mahatma Mandir ────────────────
INSERT INTO metro.STATION_ON_LINE
    (line_id, station_id, sequence_no, dist_from_start_km,
     default_halt_sec, is_terminal, is_active)
SELECT
    l.line_id,
    s.station_id,
    v.seq_no,
    v.dist_km,
    30,
    v.is_terminal,
    TRUE
FROM metro.LINE l
CROSS JOIN (VALUES
    ('MTS',  1,  0.00, TRUE),
    ('SC1',  2,  1.80, FALSE),
    ('IFC',  3,  3.20, FALSE),
    ('DHC',  4,  4.60, FALSE),
    ('RDS',  5,  6.10, FALSE),
    ('GNL',  6,  7.50, FALSE),
    ('RYS',  7,  9.00, FALSE),
    ('KBC',  8, 10.60, FALSE),
    ('NMC',  9, 12.10, FALSE),
    ('TPC', 10, 13.60, FALSE),
    ('VKC', 11, 15.10, FALSE),
    ('KTR', 12, 16.70, FALSE),
    ('S10', 13, 18.20, FALSE),
    ('SCH', 14, 19.80, FALSE),
    ('JNK', 15, 21.30, FALSE),
    ('KOG', 16, 22.80, FALSE),
    ('AKS', 17, 24.20, FALSE),
    ('JNS', 18, 25.50, FALSE),
    ('S16', 19, 26.40, FALSE),
    ('S24', 20, 27.30, FALSE),
    ('MMD', 21, 28.25, TRUE)
) AS v(code, seq_no, dist_km, is_terminal)
JOIN metro.STATION s ON s.station_code = v.code
WHERE l.line_code = 'L3';
 
-- ── VIOLET LINE (L4) — GNLU to GIFT City ──────────────────────
INSERT INTO metro.STATION_ON_LINE
    (line_id, station_id, sequence_no, dist_from_start_km,
     default_halt_sec, is_terminal, is_active)
SELECT
    l.line_id,
    s.station_id,
    v.seq_no,
    v.dist_km,
    30,
    v.is_terminal,
    TRUE
FROM metro.LINE l
CROSS JOIN (VALUES
    ('GNL', 1, 0.00, TRUE),
    ('PDU', 2, 2.70, FALSE),
    ('GFT', 3, 5.42, TRUE)
) AS v(code, seq_no, dist_km, is_terminal)
JOIN metro.STATION s ON s.station_code = v.code
WHERE l.line_code = 'L4';
 
  

-- ================================================================
--  5. TRACK  (2 tracks per line — UP and DOWN direction)
-- ================================================================
 
INSERT INTO metro.TRACK
    (line_id, track_number, direction, length_km,
     max_speed_kmph, track_status, is_active)
SELECT
    l.line_id,
    t.track_num,
    t.dir::metro.direction_t,
    l.total_length_km,
    80,
   'AVAILABLE'::metro.track_status_t,

    TRUE
FROM metro.LINE l
CROSS JOIN (VALUES
    ('T-UP',   'EASTBOUND'),
    ('T-DOWN', 'WESTBOUND')
) AS t(track_num, dir)
WHERE l.line_code = 'L1'   -- Blue Line
 
UNION ALL
 
SELECT
    l.line_id,
    t.track_num,
    t.dir::metro.direction_t,
    l.total_length_km,
    80,
    'AVAILABLE'::metro.track_status_t,
    TRUE
FROM metro.LINE l
CROSS JOIN (VALUES
    ('T-UP',   'NORTHBOUND'),
    ('T-DOWN', 'SOUTHBOUND')
) AS t(track_num, dir)
WHERE l.line_code IN ('L2','L3','L4');


 
-- ================================================================
--  AHMEDABAD METRO — INSERT PART 2
--  Tables: FARE_RULE → EMPLOYEE → DRIVER → DRIVER_SHIFT
-- ================================================================

-- ================================================================
--  6. FARE_RULE  (Real GMRC fare slabs — effective 2024)
--  Source: Official GMRC fare chart
--  Minimum fare ₹5, Maximum fare ₹40 (Ahmedabad network)
--  Concessions: Senior/Disabled 50%, Child (5-12) 50%,
--               Student 20% discount, Freedom Fighters free
-- ================================================================

INSERT INTO metro.FARE_RULE
    (min_distance_km, max_distance_km,
     base_fare, normal_fare, senior_citizen_fare,
     physically_disabled_fare, child_fare, student_fare,
     tourist_fare, freedom_fighter_fare,
     effective_from, is_active)
VALUES
-- Slab 1: 0 – 2 km  → ₹5
(0.00,  2.00,  5.00,  5.00,  2.50,  2.50,  2.50,  4.00,  5.00, 0.00,
 '2024-01-01', TRUE),

-- Slab 2: 2 – 5 km  → ₹10
(2.01,  5.00, 10.00, 10.00,  5.00,  5.00,  5.00,  8.00, 10.00, 0.00,
 '2024-01-01', TRUE),

-- Slab 3: 5 – 8 km  → ₹15
(5.01,  8.00, 15.00, 15.00,  7.50,  7.50,  7.50, 12.00, 15.00, 0.00,
 '2024-01-01', TRUE),

-- Slab 4: 8 – 12 km → ₹20
(8.01, 12.00, 20.00, 20.00, 10.00, 10.00, 10.00, 16.00, 20.00, 0.00,
 '2024-01-01', TRUE),

-- Slab 5: 12 – 16 km → ₹25
(12.01, 16.00, 25.00, 25.00, 12.50, 12.50, 12.50, 20.00, 25.00, 0.00,
 '2024-01-01', TRUE),

-- Slab 6: 16 – 20 km → ₹30
(16.01, 20.00, 30.00, 30.00, 15.00, 15.00, 15.00, 24.00, 30.00, 0.00,
 '2024-01-01', TRUE),

-- Slab 7: 20 – 25 km → ₹35
(20.01, 25.00, 35.00, 35.00, 17.50, 17.50, 17.50, 28.00, 35.00, 0.00,
 '2024-01-01', TRUE),

-- Slab 8: 25 – 35 km → ₹40 (cross-city Ahmedabad–Gandhinagar)
(25.01, 35.00, 40.00, 40.00, 20.00, 20.00, 20.00, 32.00, 40.00, 0.00,
 '2024-01-01', TRUE),

-- Slab 9: 35+ km → ₹45 (future extension coverage)
(35.01, 99.99, 45.00, 45.00, 22.50, 22.50, 22.50, 36.00, 45.00, 0.00,
 '2024-01-01', TRUE);



-- ================================================================
--  7. EMPLOYEE  (20 employees — station masters, controllers,
--     admins, gate staff, HR — all with valid credentials)
-- ================================================================

INSERT INTO metro.EMPLOYEE
    (employee_code, full_name, date_of_birth, gender,
     phone, email, password_hash,
     role, department, salary, access_level,
     joining_date, employment_status,
     managed_station_id)
VALUES
-- Super Admin
('EMP001', 'Rajesh Kumar Sharma',  '1978-04-12', 'M',
 '9876543210', 'rajesh.sharma@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'SUPER_ADMIN', 'Administration', 95000.00, 10,
 '2015-06-01', 'ACTIVE', NULL),

-- Operations Controller
('EMP002', 'Priya Mehta',          '1985-09-23', 'F',
 '9876543211', 'priya.mehta@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'OPS_CONTROLLER', 'Operations', 72000.00, 8,
 '2017-03-15', 'ACTIVE', NULL),

-- Operations Controller (Night)
('EMP003', 'Amit Patel',           '1987-11-05', 'M',
 '9876543212', 'amit.patel@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'OPS_CONTROLLER', 'Operations', 70000.00, 8,
 '2018-07-20', 'ACTIVE', NULL),

-- Station Master — Kalupur (busiest station)
('EMP004', 'Suresh Nair',          '1983-02-28', 'M',
 '9876543213', 'suresh.nair@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'STATION_MASTER', 'Station Operations', 55000.00, 5,
 '2019-01-10', 'ACTIVE', NULL),

-- Station Master — Old High Court (interchange)
('EMP005', 'Kavita Desai',         '1990-06-14', 'F',
 '9876543214', 'kavita.desai@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'STATION_MASTER', 'Station Operations', 55000.00, 5,
 '2019-06-15', 'ACTIVE', NULL),

-- Station Master — Motera (interchange)
('EMP006', 'Vikram Singh',         '1981-12-30', 'M',
 '9876543215', 'vikram.singh@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'STATION_MASTER', 'Station Operations', 55000.00, 5,
 '2020-02-01', 'ACTIVE', NULL),

-- Station Master — Mahatma Mandir
('EMP007', 'Rekha Joshi',          '1988-08-17', 'F',
 '9876543216', 'rekha.joshi@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'STATION_MASTER', 'Station Operations', 55000.00, 5,
 '2024-08-01', 'ACTIVE', NULL),

-- Maintenance Engineer
('EMP008', 'Dinesh Chauhan',       '1980-03-22', 'M',
 '9876543217', 'dinesh.chauhan@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'MAINTENANCE_ENG', 'Technical', 65000.00, 6,
 '2016-09-05', 'ACTIVE', NULL),

-- Maintenance Engineer
('EMP009', 'Harsha Patel',         '1992-01-08', 'F',
 '9876543218', 'harsha.patel@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'MAINTENANCE_ENG', 'Technical', 63000.00, 6,
 '2020-11-20', 'ACTIVE', NULL),

-- HR Manager
('EMP010', 'Manish Gupta',         '1979-07-19', 'M',
 '9876543219', 'manish.gupta@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'HR_MANAGER', 'Human Resources', 68000.00, 7,
 '2015-03-01', 'ACTIVE', NULL),

-- Finance Officer
('EMP011', 'Sneha Shah',           '1991-04-25', 'F',
 '9876543220', 'sneha.shah@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'FINANCE_OFFICER', 'Finance', 60000.00, 6,
 '2021-01-15', 'ACTIVE', NULL),

-- Gate Staff — Vastral Gam
('EMP012', 'Ramesh Trivedi',       '1995-10-11', 'M',
 '9876543221', 'ramesh.trivedi@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'GATE_STAFF', 'Station Operations', 28000.00, 1,
 '2022-04-01', 'ACTIVE', NULL),

-- Gate Staff — Thaltej Gam
('EMP013', 'Pooja Rana',           '1996-12-03', 'F',
 '9876543222', 'pooja.rana@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'GATE_STAFF', 'Station Operations', 28000.00, 1,
 '2022-04-01', 'ACTIVE', NULL),

-- Ticketing Officer
('EMP014', 'Nilesh Solanki',       '1993-05-30', 'M',
 '9876543223', 'nilesh.solanki@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'TICKETING_OFFICER', 'Revenue', 35000.00, 2,
 '2021-07-10', 'ACTIVE', NULL),

-- Security Officer
('EMP015', 'Girish Pandya',        '1984-08-15', 'M',
 '9876543224', 'girish.pandya@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'SECURITY_OFFICER', 'Security', 38000.00, 3,
 '2019-09-01', 'ACTIVE', NULL),

-- IT Administrator
('EMP016', 'Deepa Raval',          '1989-02-14', 'F',
 '9876543225', 'deepa.raval@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'IT_ADMIN', 'IT', 72000.00, 7,
 '2018-05-20', 'ACTIVE', NULL),

-- Operations Manager
('EMP017', 'Kiran Bhatt',          '1977-11-22', 'M',
 '9876543226', 'kiran.bhatt@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'OPS_MANAGER', 'Operations', 85000.00, 9,
 '2014-01-15', 'ACTIVE', NULL),

-- Customer Relations Officer
('EMP018', 'Nisha Agarwal',        '1994-07-08', 'F',
 '9876543227', 'nisha.agarwal@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'CRO', 'Customer Relations', 42000.00, 3,
 '2022-09-01', 'ACTIVE', NULL),

-- Station Master — APMC
('EMP019', 'Bhavesh Modi',         '1986-03-17', 'M',
 '9876543228', 'bhavesh.modi@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'STATION_MASTER', 'Station Operations', 55000.00, 5,
 '2022-10-06', 'ACTIVE', NULL),

-- Station Master — GIFT City
('EMP020', 'Tanvi Kapoor',         '1992-09-29', 'F',
 '9876543229', 'tanvi.kapoor@gmrc.in',
 '$2b$12$LQv3c1yqBwEHBbIXBpqb2eZlwk.DfXkdJH6YJhQI8MHrRfFZ1Tq4a',
 'STATION_MASTER', 'Station Operations', 55000.00, 5,
 '2024-09-17', 'ACTIVE', NULL);

-- Set reporting manager (EMP017 → EMP001, rest → EMP017)
UPDATE metro.EMPLOYEE SET reporting_manager_id =
    (SELECT employee_id FROM metro.EMPLOYEE WHERE employee_code = 'EMP001')
WHERE employee_code = 'EMP017';

UPDATE metro.EMPLOYEE SET reporting_manager_id =
    (SELECT employee_id FROM metro.EMPLOYEE WHERE employee_code = 'EMP017')
WHERE employee_code NOT IN ('EMP001','EMP017');

-- Assign station masters to their stations
UPDATE metro.EMPLOYEE e
SET    managed_station_id = s.station_id
FROM   metro.STATION s
WHERE  e.employee_code = 'EMP004' AND s.station_code = 'KLP';

UPDATE metro.EMPLOYEE e
SET    managed_station_id = s.station_id
FROM   metro.STATION s
WHERE  e.employee_code = 'EMP005' AND s.station_code = 'OHC';

UPDATE metro.EMPLOYEE e
SET    managed_station_id = s.station_id
FROM   metro.STATION s
WHERE  e.employee_code = 'EMP006' AND s.station_code = 'MTS';

UPDATE metro.EMPLOYEE e
SET    managed_station_id = s.station_id
FROM   metro.STATION s
WHERE  e.employee_code = 'EMP007' AND s.station_code = 'MMD';

UPDATE metro.EMPLOYEE e
SET    managed_station_id = s.station_id
FROM   metro.STATION s
WHERE  e.employee_code = 'EMP019' AND s.station_code = 'APC';

UPDATE metro.EMPLOYEE e
SET    managed_station_id = s.station_id
FROM   metro.STATION s
WHERE  e.employee_code = 'EMP020' AND s.station_code = 'GFT';




-- ================================================================
--  8. DRIVER  (18 drivers for 4 lines, all with valid licenses)
-- ================================================================

INSERT INTO metro.DRIVER
    (employee_code, full_name, date_of_birth, gender,
     phone, email, license_no, license_expiry,
     salary, experience_years, joining_date, employment_status,
     emergency_contact_name, emergency_contact_phone, address)
VALUES
('DRV001','Mahendra Singh Yadav',  '1980-05-14','M','9900001001',
 'mahendra.yadav@gmrc.in',  'GJ-DRV-2015-001','2028-05-13',
 55000.00, 15, '2019-03-01', 'ACTIVE',
 'Sunita Yadav', '9900001011',
 'B-12, Railway Colony, Sabarmati, Ahmedabad'),

('DRV002','Ranjit Kumar Thakur',   '1983-08-22','M','9900001002',
 'ranjit.thakur@gmrc.in',   'GJ-DRV-2016-002','2027-08-21',
 54000.00, 12, '2019-03-01', 'ACTIVE',
 'Meena Thakur', '9900001012',
 'C-5, Nehru Nagar, Shahibaug, Ahmedabad'),

('DRV003','Sunil Prakash Verma',   '1985-11-30','M','9900001003',
 'sunil.verma@gmrc.in',     'GJ-DRV-2017-003','2027-11-29',
 53000.00, 10, '2019-06-15', 'ACTIVE',
 'Anita Verma', '9900001013',
 'A-22, Gokuldham Society, Naranpura, Ahmedabad'),

('DRV004','Ashok Ramesh Solanki',  '1979-03-08','M','9900001004',
 'ashok.solanki@gmrc.in',   'GJ-DRV-2015-004','2028-03-07',
 56000.00, 16, '2019-03-01', 'ACTIVE',
 'Radha Solanki', '9900001014',
 'D-8, Vrundavan Society, Vatva, Ahmedabad'),

('DRV005','Pramod Lal Sharma',     '1987-07-19','M','9900001005',
 'pramod.sharma@gmrc.in',   'GJ-DRV-2018-005','2026-07-18',
 52000.00, 8,  '2019-09-01', 'ACTIVE',
 'Kavita Sharma', '9900001015',
 'E-3, Shanti Nagar, Ghatlodia, Ahmedabad'),

('DRV006','Deepak Mohan Pillai',   '1982-12-25','M','9900001006',
 'deepak.pillai@gmrc.in',   'GJ-DRV-2016-006','2027-12-24',
 54000.00, 13, '2020-01-10', 'ACTIVE',
 'Latha Pillai', '9900001016',
 'F-11, Kerala Society, Maninagar, Ahmedabad'),

('DRV007','Rajendra Prasad Gupta', '1984-04-02','M','9900001007',
 'rajendra.gupta@gmrc.in',  'GJ-DRV-2017-007','2028-04-01',
 53000.00, 11, '2020-06-01', 'ACTIVE',
 'Sushma Gupta', '9900001017',
 'G-7, Ram Nagar, Odhav, Ahmedabad'),

('DRV008','Sanjay Kumar Jain',     '1988-09-14','M','9900001008',
 'sanjay.jain@gmrc.in',     'GJ-DRV-2019-008','2026-09-13',
 51000.00, 7,  '2020-10-15', 'ACTIVE',
 'Puja Jain', '9900001018',
 'H-2, Jain Society, Paldi, Ahmedabad'),

('DRV009','Vijay Babu Nair',       '1981-06-28','M','9900001009',
 'vijay.nair@gmrc.in',      'GJ-DRV-2015-009','2027-06-27',
 55000.00, 14, '2022-10-06', 'ACTIVE',
 'Geetha Nair', '9900001019',
 'J-15, Kerala House, Usmanpura, Ahmedabad'),

('DRV010','Nitin Arun Patil',      '1986-01-11','M','9900001010',
 'nitin.patil@gmrc.in',     'GJ-DRV-2018-010','2027-01-10',
 52000.00, 9,  '2022-10-06', 'ACTIVE',
 'Sneha Patil', '9900001020',
 'K-9, Maharashtra Society, Ranip, Ahmedabad'),

('DRV011','Kartik Bhai Patel',     '1990-03-15','M','9900001011',
 'kartik.patel@gmrc.in',    'GJ-DRV-2020-011','2028-03-14',
 50000.00, 5,  '2022-10-06', 'ACTIVE',
 'Heena Patel', '9900001021',
 'L-6, Patel Wadi, Chandkheda, Ahmedabad'),

('DRV012','Girish Natubhai Shah',  '1978-10-20','M','9900001012',
 'girish.shah@gmrc.in',     'GJ-DRV-2014-012','2027-10-19',
 57000.00, 17, '2019-03-01', 'ACTIVE',
 'Mital Shah', '9900001022',
 'M-3, Shah Wadi, Narol, Ahmedabad'),

('DRV013','Dinesh Kumar Rawat',    '1983-07-05','M','9900001013',
 'dinesh.rawat@gmrc.in',    'GJ-DRV-2016-013','2026-07-04',
 53000.00, 12, '2024-09-01', 'ACTIVE',
 'Kanta Rawat', '9900001023',
 'N-18, UP Colony, Motera, Ahmedabad'),

('DRV014','Ravi Shankar Mishra',   '1985-02-17','M','9900001014',
 'ravi.mishra@gmrc.in',     'GJ-DRV-2017-014','2027-02-16',
 52000.00, 10, '2024-09-01', 'ACTIVE',
 'Geeta Mishra', '9900001024',
 'O-7, Sector-5, Gandhinagar'),

('DRV015','Pradeep Kumar Rao',     '1989-05-23','M','9900001015',
 'pradeep.rao@gmrc.in',     'GJ-DRV-2019-015','2027-05-22',
 51000.00, 6,  '2024-09-01', 'ACTIVE',
 'Sunitha Rao', '9900001025',
 'P-12, Sector-7, Gandhinagar'),

('DRV016','Mukesh Bhai Thakor',    '1984-08-30','M','9900001016',
 'mukesh.thakor@gmrc.in',   'GJ-DRV-2017-016','2026-08-29',
 52000.00, 11, '2024-09-17', 'ACTIVE',
 'Ranjana Thakor', '9900001026',
 'Q-5, Sector-9, Gandhinagar'),

('DRV017','Hemant Bhatt',          '1991-11-04','M','9900001017',
 'hemant.bhatt@gmrc.in',    'GJ-DRV-2021-017','2028-11-03',
 49000.00, 4,  '2024-09-17', 'ACTIVE',
 'Jalpa Bhatt', '9900001027',
 'R-2, GIFT City Staff Quarters, Gandhinagar'),

('DRV018','Anand Prakash Dubey',   '1982-04-16','M','9900001018',
 'anand.dubey@gmrc.in',     'GJ-DRV-2016-018','2027-04-15',
 54000.00, 13, '2019-03-01', 'ACTIVE',
 'Sandhya Dubey', '9900001028',
 'S-8, UP Colony, Saraspur, Ahmedabad');

-- ================================================================
--  9. DRIVER_SHIFT  (3 shifts per driver covering today ± 2 days)
--  Shift pattern: Morning 06:00-14:00, Evening 14:00-22:00,
--                 Night 22:00-06:00 (next day)
-- ================================================================

INSERT INTO metro.DRIVER_SHIFT
    (driver_id, shift_date, shift_start, shift_end, shift_type, is_completed)
SELECT
    d.driver_id,
    gs.shift_date,
    gs.shift_start::TIME,
    gs.shift_end::TIME,
    'REGULAR',
    gs.shift_date < CURRENT_DATE
FROM metro.DRIVER d
CROSS JOIN (
    VALUES
    (CURRENT_DATE - 2, '06:00', '14:00'),
    (CURRENT_DATE - 1, '06:00', '14:00'),
    (CURRENT_DATE,     '06:00', '14:00'),
    (CURRENT_DATE + 1, '06:00', '14:00'),
    (CURRENT_DATE + 2, '06:00', '14:00')
) AS gs(shift_date, shift_start, shift_end)
WHERE d.employee_code IN (
    'DRV001','DRV002','DRV003','DRV004','DRV005','DRV006'
)

UNION ALL

SELECT
    d.driver_id,
    gs.shift_date,
    gs.shift_start::TIME,
    gs.shift_end::TIME,
    'REGULAR',
    gs.shift_date < CURRENT_DATE
FROM metro.DRIVER d
CROSS JOIN (
    VALUES
    (CURRENT_DATE - 2, '14:00', '22:00'),
    (CURRENT_DATE - 1, '14:00', '22:00'),
    (CURRENT_DATE,     '14:00', '22:00'),
    (CURRENT_DATE + 1, '14:00', '22:00'),
    (CURRENT_DATE + 2, '14:00', '22:00')
) AS gs(shift_date, shift_start, shift_end)
WHERE d.employee_code IN (
    'DRV007','DRV008','DRV009','DRV010','DRV011','DRV012'
)

UNION ALL

SELECT
    d.driver_id,
    gs.shift_date,
    gs.shift_start::TIME,
    gs.shift_end::TIME,
    'REGULAR',
    gs.shift_date < CURRENT_DATE
FROM metro.DRIVER d
CROSS JOIN (
    VALUES
    (CURRENT_DATE - 2, '22:00', '23:59'),
    (CURRENT_DATE - 1, '22:00', '23:59'),
    (CURRENT_DATE,     '22:00', '23:59'),
    (CURRENT_DATE + 1, '22:00', '23:59'),
    (CURRENT_DATE + 2, '22:00', '23:59')
) AS gs(shift_date, shift_start, shift_end)
WHERE d.employee_code IN (
    'DRV013','DRV014','DRV015','DRV016','DRV017','DRV018'
);

-- Extra OVERTIME shift for 2 drivers (testing overtime case)
INSERT INTO metro.DRIVER_SHIFT
    (driver_id, shift_date, shift_start, shift_end, shift_type, is_completed, remarks)
SELECT driver_id, CURRENT_DATE - 1, '14:00', '18:00', 'OVERTIME', TRUE,
       'Extra shift due to absent colleague'
FROM   metro.DRIVER WHERE employee_code = 'DRV001';

INSERT INTO metro.DRIVER_SHIFT
    (driver_id, shift_date, shift_start, shift_end, shift_type, is_completed, remarks)
SELECT driver_id, CURRENT_DATE, '06:00', '10:00', 'EMERGENCY', FALSE,
       'Called in for emergency replacement'
FROM   metro.DRIVER WHERE employee_code = 'DRV005';




-- ================================================================
--  AHMEDABAD METRO — INSERT PART 3
--  Tables: TRAIN → TRAIN_SCHEDULE → TRAIN_STOP
--          → DRIVER_SCHEDULE_ASSIGNMENT
--  Order : Parent first, then FK-dependent children
-- ================================================================



-- ================================================================
--  10. TRAIN  (16 trains — real GMRC rolling stock details)
--  Manufacturer: Bombardier (Blue/Red) & BEML (Yellow/Violet)
--  Capacity: 6-car consist = 1400 passengers (975 standing + 425 seated)
-- ================================================================

INSERT INTO metro.TRAIN
    (train_number, train_name, train_type,
     total_capacity, seating_capacity, standing_capacity,
     number_of_coaches, manufacturer, manufacture_year,
     commission_date, operational_status, is_on_rest,
     current_line_id)
SELECT
    v.train_num, v.train_name, 'EMU',
    1400, 425, 975, 6,
    v.manufacturer, v.mfr_year,
    v.commission_dt::DATE,
    v.op_status::metro.train_status_t,
    v.on_rest,
    l.line_id
FROM (VALUES
    -- Blue Line trains
    ('AMTS-BL-001','Blue Falcon',    'Bombardier Innovia',2019,'2019-03-01','ON_TRACK',  FALSE,'L1'),
    ('AMTS-BL-002','Blue Eagle',     'Bombardier Innovia',2019,'2019-03-01','ON_TRACK',  FALSE,'L1'),
    ('AMTS-BL-003','Blue Hawk',      'Bombardier Innovia',2019,'2019-06-15','ON_TRACK',  FALSE,'L1'),
    ('AMTS-BL-004','Blue Kite',      'Bombardier Innovia',2020,'2020-01-10','RESTING',   TRUE, 'L1'),
    -- Red Line trains
    ('AMTS-RL-001','Red Arrow',      'Bombardier Innovia',2022,'2022-10-01','ON_TRACK',  FALSE,'L2'),
    ('AMTS-RL-002','Red Bolt',       'Bombardier Innovia',2022,'2022-10-01','ON_TRACK',  FALSE,'L2'),
    ('AMTS-RL-003','Red Comet',      'Bombardier Innovia',2022,'2022-10-01','ON_TRACK',  FALSE,'L2'),
    ('AMTS-RL-004','Red Dart',       'Bombardier Innovia',2023,'2023-02-01','RESTING',   TRUE, 'L2'),
    -- Yellow Line trains
    ('AMTS-YL-001','Yellow Sun',     'BEML Metro',        2024,'2024-09-10','ON_TRACK',  FALSE,'L3'),
    ('AMTS-YL-002','Yellow Star',    'BEML Metro',        2024,'2024-09-10','ON_TRACK',  FALSE,'L3'),
    ('AMTS-YL-003','Yellow Moon',    'BEML Metro',        2024,'2024-09-10','ON_TRACK',  FALSE,'L3'),
    ('AMTS-YL-004','Yellow Ray',     'BEML Metro',        2024,'2024-09-10','RESTING',   TRUE, 'L3'),
    -- Violet Line trains
    ('AMTS-VL-001','Violet Spark',   'BEML Metro',        2024,'2024-09-10','ON_TRACK',  FALSE,'L4'),
    ('AMTS-VL-002','Violet Flash',   'BEML Metro',        2024,'2024-09-10','RESTING',   TRUE, 'L4'),
    -- Maintenance / spare
    ('AMTS-SP-001','Spare Alpha',    'Bombardier Innovia',2019,'2019-03-01','MAINTENANCE',TRUE,NULL),
    ('AMTS-SP-002','Spare Beta',     'BEML Metro',        2024,'2024-09-10','RESTING',   TRUE, NULL)
) AS v(train_num, train_name, manufacturer, mfr_year, commission_dt,
       op_status, on_rest, line_code)
LEFT JOIN metro.LINE l ON l.line_code = v.line_code;





-- ================================================================
--  11. TRAIN_SCHEDULE
--  Real GMRC schedule:
--    • First train: 06:00  • Last train: 23:00
--    • Frequency   : every 10 min (peak), 15 min (off-peak)
--  We insert 16 schedules:
--    4 per line (2 UP + 2 DOWN; morning + evening runs)
-- ================================================================

INSERT INTO metro.TRAIN_SCHEDULE
    (train_id, line_id, track_id,
     direction, day_type,
     departure_time, arrival_time, normal_eta_mins,
     schedule_status, effective_from)
SELECT
    t.train_id,
    l.line_id,
    tk.track_id,
    v.direction::metro.direction_t,
    v.day_type::metro.day_type_t,
    v.dep_time::TIME,
    v.arr_time::TIME,
    v.eta_mins,
    'ACTIVE'::metro.schedule_status_t,
    CURRENT_DATE
FROM (VALUES
    -- ── BLUE LINE ─────────────────────────────────────────────
    -- Morning UP (East→West): NCR 06:00 → TLG 06:38
    ('AMTS-BL-001','L1','T-UP',  'EASTBOUND','WEEKDAY','06:00','06:38',38),
    -- Morning DOWN (West→East): TLG 06:45 → NCR 07:23
    ('AMTS-BL-002','L1','T-DOWN','WESTBOUND','WEEKDAY','06:45','07:23',38),
    -- Evening UP: NCR 17:00 → TLG 17:38
    ('AMTS-BL-003','L1','T-UP',  'EASTBOUND','WEEKDAY','17:00','17:38',38),
    -- Evening DOWN: TLG 17:45 → NCR 18:23
    ('AMTS-BL-004','L1','T-DOWN','WESTBOUND','WEEKDAY','17:45','18:23',38),

    -- ── RED LINE ──────────────────────────────────────────────
    -- Morning UP (South→North): APMC 06:05 → Motera 06:45
    ('AMTS-RL-001','L2','T-UP',  'NORTHBOUND','WEEKDAY','06:05','06:45',40),
    -- Morning DOWN (North→South): Motera 06:50 → APMC 07:30
    ('AMTS-RL-002','L2','T-DOWN','SOUTHBOUND','WEEKDAY','06:50','07:30',40),
    -- Evening UP: APMC 17:05 → Motera 17:45
    ('AMTS-RL-003','L2','T-UP',  'NORTHBOUND','WEEKDAY','17:05','17:45',40),
    -- Evening DOWN: Motera 17:50 → APMC 18:30
    ('AMTS-RL-004','L2','T-DOWN','SOUTHBOUND','WEEKDAY','17:50','18:30',40),

    -- ── YELLOW LINE ───────────────────────────────────────────
    -- Morning UP (South→North): Motera 06:10 → Mahatma Mandir 07:05
    ('AMTS-YL-001','L3','T-UP',  'NORTHBOUND','WEEKDAY','06:10','07:05',55),
    -- Morning DOWN: Mahatma Mandir 07:10 → Motera 08:05
    ('AMTS-YL-002','L3','T-DOWN','SOUTHBOUND','WEEKDAY','07:10','08:05',55),
    -- Evening UP: Motera 17:10 → Mahatma Mandir 18:05
    ('AMTS-YL-003','L3','T-UP',  'NORTHBOUND','WEEKDAY','17:10','18:05',55),
    -- Evening DOWN: Mahatma Mandir 18:10 → Motera 19:05
    ('AMTS-YL-004','L3','T-DOWN','SOUTHBOUND','WEEKDAY','18:10','19:05',55),

    -- ── VIOLET LINE ───────────────────────────────────────────
    -- Morning UP: GNLU 06:15 → GIFT City 06:30
    ('AMTS-VL-001','L4','T-UP',  'NORTHBOUND','WEEKDAY','06:15','06:30',15),
    -- Morning DOWN: GIFT City 06:35 → GNLU 06:50
    ('AMTS-VL-002','L4','T-DOWN','SOUTHBOUND','WEEKDAY','06:35','06:50',15),
    -- Evening UP: GNLU 17:15 → GIFT City 17:30
    ('AMTS-VL-001','L4','T-UP',  'NORTHBOUND','WEEKDAY','17:15','17:30',15),
    -- Evening DOWN: GIFT City 17:35 → GNLU 17:50
    ('AMTS-VL-002','L4','T-DOWN','SOUTHBOUND','WEEKDAY','17:35','17:50',15)

) AS v(train_num, line_code, track_num, direction, day_type,
       dep_time, arr_time, eta_mins)
JOIN  metro.TRAIN  t  ON t.train_number = v.train_num
JOIN  metro.LINE   l  ON l.line_code    = v.line_code
JOIN  metro.TRACK  tk ON tk.line_id     = l.line_id
                      AND tk.track_number = v.track_num;

-- Weekend versions of the same schedules (slightly later start)
INSERT INTO metro.TRAIN_SCHEDULE
    (train_id, line_id, track_id,
     direction, day_type,
     departure_time, arrival_time, normal_eta_mins,
     schedule_status, effective_from)
SELECT
    train_id, line_id, track_id,
    direction, 'WEEKEND'::metro.day_type_t,
    (departure_time + INTERVAL '30 minutes')::TIME,
    (arrival_time   + INTERVAL '30 minutes')::TIME,
    normal_eta_mins,
    'ACTIVE',
    CURRENT_DATE
FROM metro.TRAIN_SCHEDULE
WHERE day_type = 'WEEKDAY'
AND   is_deleted = FALSE;




-- ================================================================
--  12. TRAIN_STOP
--  Generate all stops for every WEEKDAY schedule automatically
--  using the STATION_ON_LINE sequence and real station timings.
--  Each stop = 30 sec halt; inter-stop travel ~2 min average.
-- ================================================================

DO $stops$
DECLARE
    r_sch    RECORD;
    r_stop   RECORD;
    v_seq    SMALLINT;
    v_arr    TIME;
    v_dep    TIME;
    v_base   TIME;
    v_plat   SMALLINT;
    v_inter  INTERVAL := '2 minutes';
    v_halt   INTERVAL := '30 seconds';
BEGIN
    FOR r_sch IN
        SELECT ts.schedule_id,
               ts.train_id,
               ts.line_id,
               ts.direction,
               ts.departure_time,
               ts.day_type
        FROM   metro.TRAIN_SCHEDULE ts
        WHERE  ts.schedule_status = 'ACTIVE'
        AND    ts.is_deleted      = FALSE
        ORDER  BY ts.schedule_id
    LOOP
        v_base := r_sch.departure_time;
        v_seq  := 1;

        -- Get stops in correct order based on direction
        FOR r_stop IN
            SELECT sol.station_id,
                   sol.sequence_no,
                   sol.dist_from_start_km
            FROM   metro.STATION_ON_LINE sol
            WHERE  sol.line_id   = r_sch.line_id
            AND    sol.is_active = TRUE
            ORDER BY
                CASE WHEN r_sch.direction IN ('EASTBOUND','NORTHBOUND')
                     THEN sol.sequence_no
                     ELSE -sol.sequence_no
                END
        LOOP
            v_arr  := v_base;
            v_dep  := v_base + v_halt;

            -- Platform: EASTBOUND/NORTHBOUND = platform 1, else platform 2
            v_plat := CASE WHEN r_sch.direction IN ('EASTBOUND','NORTHBOUND')
                           THEN 1 ELSE 2 END;

            -- Verify platform exists
            IF EXISTS (
                SELECT 1 FROM metro.PLATFORM
                WHERE station_id  = r_stop.station_id
                AND   platform_no = v_plat
                AND   is_deleted  = FALSE
            ) THEN
                INSERT INTO metro.TRAIN_STOP (
                    schedule_id, stop_sequence,
                    station_id,  platform_no,
                    scheduled_arrival, scheduled_departure,
                    halt_duration_sec, is_active
                ) VALUES (
                    r_sch.schedule_id, v_seq,
                    r_stop.station_id, v_plat,
                    v_arr, v_dep, 30, TRUE
                );
            END IF;

            -- Advance time for next stop
            v_base := v_dep + v_inter;
            v_seq  := v_seq + 1;
        END LOOP;
    END LOOP;

    RAISE NOTICE 'TRAIN_STOP: inserted stops for all schedules.';
END $stops$;




-- ================================================================
--  13. DRIVER_SCHEDULE_ASSIGNMENT
--  Assign a PRIMARY driver to each WEEKDAY schedule today.
--  Also add BACKUP driver to demonstrate the feature.
-- ================================================================

INSERT INTO metro.DRIVER_SCHEDULE_ASSIGNMENT
    (driver_id, schedule_id, assignment_date, role,
     assigned_by_emp_id, is_active)
SELECT
    d.driver_id,
    ts.schedule_id,
    CURRENT_DATE,
    'PRIMARY',
    (SELECT employee_id FROM metro.EMPLOYEE WHERE employee_code = 'EMP002'),
    TRUE
FROM (
    VALUES
    ('DRV001', 1),   -- Blue Line Morning UP
    ('DRV002', 2),   -- Blue Line Morning DOWN
    ('DRV003', 3),   -- Blue Line Evening UP
    ('DRV004', 4),   -- Blue Line Evening DOWN
    ('DRV005', 5),   -- Red Line Morning UP
    ('DRV006', 6),   -- Red Line Morning DOWN
    ('DRV007', 7),   -- Red Line Evening UP
    ('DRV008', 8),   -- Red Line Evening DOWN
    ('DRV009', 9),   -- Yellow Line Morning UP
    ('DRV010', 10),  -- Yellow Line Morning DOWN
    ('DRV011', 11),  -- Yellow Line Evening UP
    ('DRV012', 12),  -- Yellow Line Evening DOWN
    ('DRV013', 13),  -- Violet Line Morning UP
    ('DRV014', 14),  -- Violet Line Morning DOWN
    ('DRV015', 15),  -- Violet Line Evening UP
    ('DRV016', 16)   -- Violet Line Evening DOWN
) AS v(driver_code, sched_row)
JOIN metro.DRIVER          d  ON d.employee_code  = v.driver_code
JOIN metro.TRAIN_SCHEDULE  ts ON ts.schedule_id   = (
        SELECT schedule_id FROM metro.TRAIN_SCHEDULE
        WHERE  day_type   = 'WEEKDAY'
        AND    is_deleted = FALSE
        ORDER  BY schedule_id
        LIMIT  1
        OFFSET v.sched_row - 1
    );

-- BACKUP drivers for first 4 schedules
INSERT INTO metro.DRIVER_SCHEDULE_ASSIGNMENT
    (driver_id, schedule_id, assignment_date, role,
     assigned_by_emp_id, is_active)
SELECT
    d.driver_id,
    ts.schedule_id,
    CURRENT_DATE,
    'BACKUP',
    (SELECT employee_id FROM metro.EMPLOYEE WHERE employee_code = 'EMP002'),
    TRUE
FROM (
    VALUES
    ('DRV017', 1),
    ('DRV018', 2),
    ('DRV017', 3),
    ('DRV018', 4)
) AS v(driver_code, sched_row)
JOIN metro.DRIVER          d  ON d.employee_code  = v.driver_code
JOIN metro.TRAIN_SCHEDULE  ts ON ts.schedule_id   = (
        SELECT schedule_id FROM metro.TRAIN_SCHEDULE
        WHERE  day_type   = 'WEEKDAY'
        AND    is_deleted = FALSE
        ORDER  BY schedule_id
        LIMIT  1
        OFFSET v.sched_row - 1
    );


-- ================================================================
--  AHMEDABAD METRO — INSERT PART 4
--  Tables: PASSENGER → TICKET → PAYMENT → TRAVEL_PASS
-- ================================================================

-- ================================================================
--  14. PASSENGER  (20 passengers — diverse types for testing)
-- ================================================================

INSERT INTO metro.PASSENGER
    (full_name, date_of_birth, gender,
     phone, email, passenger_type,
     disability_flag, disability_certificate,
     preferred_language, is_active)
VALUES
-- General passengers
('Aarav Shah',          '1995-06-15','M','9712345001','aarav.shah@gmail.com',
 'GENERAL',           FALSE,NULL,'en',TRUE),

('Priya Patel',         '1998-11-22','F','9712345002','priya.patel@gmail.com',
 'GENERAL',           FALSE,NULL,'gu',TRUE),

('Rohan Mehta',         '1992-03-08','M','9712345003','rohan.mehta@gmail.com',
 'GENERAL',           FALSE,NULL,'en',TRUE),

('Sneha Desai',         '2000-07-30','F','9712345004','sneha.desai@gmail.com',
 'GENERAL',           FALSE,NULL,'gu',TRUE),

('Karan Joshi',         '1988-09-14','M','9712345005','karan.joshi@gmail.com',
 'GENERAL',           FALSE,NULL,'hi',TRUE),

-- Senior citizens
('Ramanlal Trivedi',    '1958-02-20','M','9712345006','ramanlal.trivedi@gmail.com',
 'SENIOR_CITIZEN',    FALSE,NULL,'gu',TRUE),

('Savitaben Patel',     '1955-12-05','F','9712345007',NULL,
 'SENIOR_CITIZEN',    FALSE,NULL,'gu',TRUE),

('Kantibhai Shah',      '1950-08-17','M','9712345008','kantibhai.shah@gmail.com',
 'SENIOR_CITIZEN',    FALSE,NULL,'gu',TRUE),

-- Students
('Diya Sharma',         '2003-04-12','F','9712345009','diya.sharma@student.gu.ac.in',
 'STUDENT',           FALSE,NULL,'en',TRUE),

('Raj Solanki',         '2002-01-25','M','9712345010','raj.solanki@student.gu.ac.in',
 'STUDENT',           FALSE,NULL,'en',TRUE),

('Nisha Agrawal',       '2001-09-18','F','9712345011','nisha.agrawal@student.daiict.ac.in',
 'STUDENT',           FALSE,NULL,'en',TRUE),

-- Physically disabled
('Suresh Chauhan',      '1985-05-30','M','9712345012','suresh.chauhan@gmail.com',
 'PHYSICALLY_DISABLED',TRUE,'GJ-PWD-2022-00345','gu',TRUE),

('Meera Rana',          '1990-10-14','F','9712345013','meera.rana@gmail.com',
 'PHYSICALLY_DISABLED',TRUE,'GJ-PWD-2021-00892','gu',TRUE),

-- Child passengers (guardian managed)
('Aadhya Patel',        '2015-03-22','F','9712345014',NULL,
 'CHILD',             FALSE,NULL,'gu',TRUE),

('Vihaan Shah',         '2016-07-09','M','9712345015',NULL,
 'CHILD',             FALSE,NULL,'gu',TRUE),

-- Tourist
('James Wilson',        '1988-06-04','M','9712345016','james.wilson@email.com',
 'TOURIST',           FALSE,NULL,'en',TRUE),

('Yuki Tanaka',         '1992-11-28','F','9712345017','yuki.tanaka@email.com',
 'TOURIST',           FALSE,NULL,'en',TRUE),

-- Freedom fighter
('Chunilal Vaghela',    '1945-01-15','M','9712345018',NULL,
 'FREEDOM_FIGHTER',   FALSE,NULL,'gu',TRUE),

-- High-frequency commuter (for crowd testing)
('Bhavesh Kumar',       '1993-08-11','M','9712345019','bhavesh.kumar@gmail.com',
 'GENERAL',           FALSE,NULL,'en',TRUE),

('Anjali Mishra',       '1996-02-27','F','9712345020','anjali.mishra@gmail.com',
 'GENERAL',           FALSE,NULL,'hi',TRUE);

-- ================================================================
--  15. TICKET  (20 tickets — varied routes, types, statuses)
--  Uses real station pairs for distance calculation
-- ================================================================

-- Helper function to get station_id by code
-- Ticket 1: Vastral Gam → Thaltej Gam (full Blue Line, 21.23 km → ₹35)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id,
    fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'SINGLE', 'GENERAL',
    metro.generate_qr_code('TKT'),
    21.23, 35.00, 0.00, 0.00, 35.00,
    'MOBILE_APP',
    NOW() - INTERVAL '2 hours',
    NOW() + INTERVAL '1 hour',
    'USED'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name     = 'Aarav Shah'
AND   fs.station_code = 'VTG'
AND   ts.station_code = 'TLG'
AND   fr.min_distance_km <= 21.23 AND fr.max_distance_km >= 21.23
AND   fr.is_active = TRUE
LIMIT 1;

-- Ticket 2: Kalupur → SP Stadium (Blue Line 3.8 km → ₹10)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'SINGLE', 'GENERAL',
    metro.generate_qr_code('TKT'),
    3.80, 10.00, 0.00, 0.00, 10.00,
    'MOBILE_APP',
    NOW() - INTERVAL '1 hour',
    NOW() + INTERVAL '1 hour',
    'ENTRY_DONE'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name = 'Priya Patel'
AND   fs.station_code = 'KLP' AND ts.station_code = 'SPS'
AND   fr.min_distance_km <= 3.80 AND fr.max_distance_km >= 3.80
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 3: APMC → Motera (full Red Line, 18.10 km → ₹30)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'SINGLE', 'GENERAL',
    metro.generate_qr_code('TKT'),
    18.10, 30.00, 0.00, 0.00, 30.00,
    'KIOSK',
    NOW() - INTERVAL '30 minutes',
    NOW() + INTERVAL '90 minutes',
    'ACTIVE'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name = 'Rohan Mehta'
AND   fs.station_code = 'APC' AND ts.station_code = 'MTS'
AND   fr.min_distance_km <= 18.10 AND fr.max_distance_km >= 18.10
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 4: Senior citizen — Paldi → Old High Court (1.5 km → ₹2.50)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'SINGLE', 'SENIOR_CITIZEN',
    metro.generate_qr_code('TKT'),
    1.50, 5.00, 2.50, 0.00, 2.50,
    'COUNTER',
    NOW() - INTERVAL '45 minutes',
    NOW() + INTERVAL '75 minutes',
    'ACTIVE'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name = 'Ramanlal Trivedi'
AND   fs.station_code = 'PAL' AND ts.station_code = 'OHC'
AND   fr.min_distance_km <= 1.50 AND fr.max_distance_km >= 1.50
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 5: Student — Gujarat University → Thaltej (4.11 km → ₹8)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'SINGLE', 'STUDENT',
    metro.generate_qr_code('TKT'),
    4.11, 10.00, 2.00, 0.00, 8.00,
    'MOBILE_APP',
    NOW() - INTERVAL '20 minutes',
    NOW() + INTERVAL '100 minutes',
    'ACTIVE'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name = 'Diya Sharma'
AND   fs.station_code = 'GUV' AND ts.station_code = 'TLG'
AND   fr.min_distance_km <= 4.11 AND fr.max_distance_km >= 4.11
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 6: Disabled — Old High Court → Vastral (9.01 km → ₹10)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'SINGLE', 'PHYSICALLY_DISABLED',
    metro.generate_qr_code('TKT'),
    9.01, 20.00, 10.00, 0.00, 10.00,
    'COUNTER',
    NOW() - INTERVAL '1 hour',
    NOW() + INTERVAL '1 hour',
    'USED'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name = 'Suresh Chauhan'
AND   fs.station_code = 'OHC' AND ts.station_code = 'VTR'
AND   fr.min_distance_km <= 9.01 AND fr.max_distance_km >= 9.01
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 7: Tourist — Motera → Mahatma Mandir (28.25 km → ₹40)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'SINGLE', 'TOURIST',
    metro.generate_qr_code('TKT'),
    28.25, 40.00, 0.00, 0.00, 40.00,
    'MOBILE_APP',
    NOW() + INTERVAL '30 minutes',
    NOW() + INTERVAL '4 hours',
    'BOOKED'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name = 'James Wilson'
AND   fs.station_code = 'MTS' AND ts.station_code = 'MMD'
AND   fr.min_distance_km <= 28.25 AND fr.max_distance_km >= 28.25
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 8: Return ticket — Sneha Desai: Kalupur ↔ Gujarat Uni (5.8 km → ₹15)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'RETURN', 'GENERAL',
    metro.generate_qr_code('TKT'),
    5.80, 15.00, 0.00, 0.00, 15.00,
    'WEBSITE',
    NOW() - INTERVAL '3 hours',
    NOW() + INTERVAL '21 hours',
    'ACTIVE'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name = 'Sneha Desai'
AND   fs.station_code = 'KLP' AND ts.station_code = 'GUV'
AND   fr.min_distance_km <= 5.80 AND fr.max_distance_km >= 5.80
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 9: Cancelled ticket (Karan Joshi)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status,
     cancellation_reason, cancelled_at)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'SINGLE', 'GENERAL',
    metro.generate_qr_code('TKT'),
    7.60, 15.00, 0.00, 0.00, 15.00,
    'MOBILE_APP',
    NOW() - INTERVAL '5 hours',
    NOW() - INTERVAL '3 hours',
    'CANCELLED',
    'Passenger missed the train',
    NOW() - INTERVAL '4 hours'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name = 'Karan Joshi'
AND   fs.station_code = 'GDG' AND ts.station_code = 'OHC'
AND   fr.min_distance_km <= 7.60 AND fr.max_distance_km >= 7.60
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 10: Expired ticket (Savitaben — yesterday)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    'SINGLE', 'SENIOR_CITIZEN',
    metro.generate_qr_code('TKT'),
    1.20, 5.00, 2.50, 0.00, 2.50,
    'COUNTER',
    NOW() - INTERVAL '26 hours',
    NOW() - INTERVAL '24 hours',
    'EXPIRED'
FROM metro.PASSENGER p, metro.STATION fs, metro.STATION ts,
     metro.FARE_RULE fr
WHERE p.full_name = 'Savitaben Patel'
AND   fs.station_code = 'JVP' AND ts.station_code = 'APC'
AND   fr.min_distance_km <= 1.20 AND fr.max_distance_km >= 1.20
AND   fr.is_active = TRUE LIMIT 1;

-- Tickets 11-20: Bhavesh, Anjali, Raj, Nisha, Vihaan, Aadhya,
--               Yuki, Meera, Chunilal, Kantibhai (varied routes)
INSERT INTO metro.TICKET
    (passenger_id, fare_rule_id, from_station_id, to_station_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, tax_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.station_id, ts.station_id,
    v.tkt_type::metro.ticket_type_t,
    v.pax_cat::metro.passenger_type_t,
    metro.generate_qr_code('TKT'),
    v.dist, v.base, v.disc, 0.00, v.base - v.disc,
    v.channel::metro.booking_channel_t,
    NOW() - (v.issued_ago || ' minutes')::INTERVAL,
    NOW() + (v.valid_mins || ' minutes')::INTERVAL,
    v.tkt_status::metro.ticket_status_t
FROM (VALUES
    ('Bhavesh Kumar',  'NCR','GUV', 'SINGLE','GENERAL',
     15.10,25.00,0.00,'MOBILE_APP',  10, 110,'ACTIVE'),
    ('Anjali Mishra',  'SHP','SPS', 'SINGLE','GENERAL',
      2.80,10.00,0.00,'MOBILE_APP',   5, 115,'ACTIVE'),
    ('Raj Solanki',    'GUV','TLT', 'SINGLE','STUDENT',
      4.70,10.00,2.00,'MOBILE_APP',  15, 105,'ENTRY_DONE'),
    ('Nisha Agrawal',  'MTS','GNL', 'SINGLE','STUDENT',
      7.50,15.00,3.00,'WEBSITE',     20, 100,'ACTIVE'),
    ('Vihaan Shah',    'KLP','OHC', 'SINGLE','CHILD',
      2.90, 5.00,2.50,'COUNTER',     30,  90,'ACTIVE'),
    ('Aadhya Patel',   'APC','GDG', 'SINGLE','CHILD',
      6.30,10.00,5.00,'COUNTER',     40,  80,'ACTIVE'),
    ('Yuki Tanaka',    'GNL','GFT', 'SINGLE','TOURIST',
      5.42,15.00,0.00,'MOBILE_APP',  25,  95,'ACTIVE'),
    ('Meera Rana',     'SBR','MTS', 'SINGLE','PHYSICALLY_DISABLED',
      3.30, 5.00,2.50,'COUNTER',     35,  85,'ENTRY_DONE'),
    ('Chunilal Vaghela','PAL','SHR','SINGLE','FREEDOM_FIGHTER',
      1.40, 5.00,5.00,'COUNTER',     50,  70,'USED'),
    ('Kantibhai Shah', 'RNP','VDJ', 'RETURN','SENIOR_CITIZEN',
      1.50, 5.00,2.50,'COUNTER',     60,  60,'ACTIVE')
) AS v(pname, from_code, to_code, tkt_type, pax_cat,
       dist, base, disc, channel, issued_ago, valid_mins, tkt_status)
JOIN metro.PASSENGER p  ON p.full_name        = v.pname
JOIN metro.STATION   fs ON fs.station_code    = v.from_code
JOIN metro.STATION   ts ON ts.station_code    = v.to_code
JOIN metro.FARE_RULE fr ON v.dist BETWEEN fr.min_distance_km
                                       AND fr.max_distance_km
                       AND fr.is_active = TRUE;

-- ================================================================
--  16. PAYMENT  (one per ticket; varied payment methods)
-- ================================================================

INSERT INTO metro.PAYMENT
    (ticket_id, amount, payment_method, status,
     gateway_name, gateway_payment_id,
     initiated_at, paid_at, refund_amount, refunded_at)
SELECT
    t.ticket_id,
    t.price_paid,
    v.method::metro.payment_method_t,
    v.pay_status::metro.payment_status_t,
    v.gateway,
    'GW-' || t.ticket_id || '-' || EXTRACT(EPOCH FROM NOW())::BIGINT,
    t.issued_at,
    CASE WHEN v.pay_status IN ('SUCCESS','REFUNDED','PARTIALLY_REFUNDED')
         THEN t.issued_at + INTERVAL '2 seconds' ELSE NULL END,
    CASE WHEN v.pay_status = 'REFUNDED'           THEN t.price_paid
         WHEN v.pay_status = 'PARTIALLY_REFUNDED' THEN t.price_paid / 2
         ELSE 0 END,
    CASE WHEN v.pay_status IN ('REFUNDED','PARTIALLY_REFUNDED')
         THEN t.issued_at + INTERVAL '1 day' ELSE NULL END
FROM (
    SELECT ticket_id, price_paid, issued_at,
           ROW_NUMBER() OVER (ORDER BY ticket_id) AS rn
    FROM   metro.TICKET
    WHERE  is_deleted = FALSE
) t
JOIN (VALUES
    (1,  'UPI',         'SUCCESS',              'RAZORPAY'),
    (2,  'UPI',         'SUCCESS',              'RAZORPAY'),
    (3,  'DEBIT_CARD',  'SUCCESS',              'HDFC'),
    (4,  'CASH',        'SUCCESS',              'COUNTER'),
    (5,  'UPI',         'SUCCESS',              'PAYTM'),
    (6,  'CASH',        'SUCCESS',              'COUNTER'),
    (7,  'CREDIT_CARD', 'SUCCESS',              'ICICI'),
    (8,  'NET_BANKING', 'SUCCESS',              'SBI'),
    (9,  'UPI',         'REFUNDED',             'RAZORPAY'),
    (10, 'CASH',        'SUCCESS',              'COUNTER'),
    (11, 'UPI',         'SUCCESS',              'PHONEPE'),
    (12, 'METRO_CARD',  'SUCCESS',              'GMRC'),
    (13, 'UPI',         'SUCCESS',              'GPAY'),
    (14, 'UPI',         'SUCCESS',              'PAYTM'),
    (15, 'CASH',        'SUCCESS',              'COUNTER'),
    (16, 'CASH',        'SUCCESS',              'COUNTER'),
    (17, 'CREDIT_CARD', 'SUCCESS',              'AXIS'),
    (18, 'CASH',        'SUCCESS',              'COUNTER'),
    (19, 'CASH',        'SUCCESS',              'COUNTER'),
    (20, 'CASH',        'SUCCESS',              'COUNTER')
) AS v(rn, method, pay_status, gateway) ON v.rn = t.rn;

-- ================================================================
--  17. TRAVEL_PASS  (16 passes — student, senior, general)
-- ================================================================

INSERT INTO metro.TRAVEL_PASS
    (passenger_id, pass_type, institution_name, institution_id_no,
     valid_from, valid_to, price, qr_code, is_active)
SELECT
    p.passenger_id,
    v.pass_type::metro.pass_type_t,
    v.institution,
    v.inst_id,
    CURRENT_DATE,
    CURRENT_DATE + (v.validity_days || ' days')::INTERVAL,
    v.price,
    metro.generate_qr_code('PSS'),
    TRUE
FROM (VALUES
    ('Diya Sharma',     'STUDENT_MONTHLY',   'Gujarat University',
     'GU-2021-1234', 30, 250.00),
    ('Raj Solanki',     'STUDENT_MONTHLY',   'Gujarat University',
     'GU-2022-5678', 30, 250.00),
    ('Nisha Agrawal',   'STUDENT_QUARTERLY', 'DA-IICT Gandhinagar',
     'DAIICT-2023-001', 90, 650.00),
    ('Ramanlal Trivedi','SENIOR_MONTHLY',    NULL, NULL, 30, 300.00),
    ('Savitaben Patel', 'SENIOR_MONTHLY',    NULL, NULL, 30, 300.00),
    ('Kantibhai Shah',  'SENIOR_QUARTERLY',  NULL, NULL, 90, 800.00),
    ('Bhavesh Kumar',   'GENERAL_MONTHLY',   NULL, NULL, 30, 600.00),
    ('Anjali Mishra',   'GENERAL_MONTHLY',   NULL, NULL, 30, 600.00),
    ('Rohan Mehta',     'GENERAL_QUARTERLY', NULL, NULL, 90,1600.00),
    ('Sneha Desai',     'GENERAL_MONTHLY',   NULL, NULL, 30, 600.00),
    ('Karan Joshi',     'GENERAL_MONTHLY',   NULL, NULL, 30, 600.00),
    ('Priya Patel',     'STUDENT_MONTHLY',   'PDPU Gandhinagar',
     'PDPU-2024-789', 30, 250.00),
    ('Aarav Shah',      'GENERAL_MONTHLY',   NULL, NULL, 30, 600.00),
    ('Meera Rana',      'GENERAL_MONTHLY',   NULL, NULL, 30, 600.00),
    ('Vikram Singh',    'EMPLOYEE_MONTHLY',  'GMRC', 'GMRC-EMP-006', 30, 500.00),
    ('Priya Mehta',     'EMPLOYEE_MONTHLY',  'GMRC', 'GMRC-EMP-002', 30, 500.00)
) AS v(pname, pass_type, institution, inst_id, validity_days, price)
JOIN metro.PASSENGER p ON p.full_name = v.pname
   OR p.full_name = v.pname;

-- Fix: EMPLOYEE passengers don't exist in PASSENGER table — use valid ones
DELETE FROM metro.TRAVEL_PASS
WHERE pass_id IN (
    SELECT tp.pass_id FROM metro.TRAVEL_PASS tp
    LEFT JOIN metro.PASSENGER p ON p.passenger_id = tp.passenger_id
    WHERE p.passenger_id IS NULL
);

-- ================================================================
--  AHMEDABAD METRO — INSERT PART 5
--  Tables: TICKET_GATE_SCAN → TRAVELLING_IN
--          → DELAY_EVENT → RESCHEDULE_LOG
-- ================================================================

-- ================================================================
--  18. TICKET_GATE_SCAN
--  Entry + Exit scans for USED tickets,
--  Entry-only for ENTRY_DONE tickets,
--  No scan for ACTIVE/BOOKED/CANCELLED/EXPIRED
-- ================================================================


-- ENTRY scans for all USED and ENTRY_DONE tickets
INSERT INTO metro.TICKET_GATE_SCAN
    (ticket_id, station_id, platform_no, gate_role,
     gate_device_id, scan_timestamp, is_valid,
     schedule_id, stop_sequence)

SELECT
    ticket_id,
    station_id,
    platform_no,
    gate_role,
    gate_device_id,
    scan_timestamp,
    is_valid,
    schedule_id,
    stop_sequence

FROM (
    SELECT
        t.ticket_id,
        t.from_station_id AS station_id,
        1 AS platform_no,
       'ENTRY'::metro.gate_role_t AS gate_role,
        'GATE-' || fs.station_code || '-IN-01' AS gate_device_id,
        t.valid_from + INTERVAL '5 minutes' AS scan_timestamp,
        TRUE AS is_valid,
        ts.schedule_id,
        tst.stop_sequence,

        ROW_NUMBER() OVER (
            PARTITION BY t.ticket_id
            ORDER BY ts.schedule_id
        ) AS rn

    FROM metro.TICKET t

    JOIN metro.STATION fs
        ON fs.station_id = t.from_station_id

    JOIN metro.STATION_ON_LINE sol
        ON sol.station_id = t.from_station_id

    LEFT JOIN metro.TRAIN_SCHEDULE ts
        ON ts.line_id = sol.line_id
        AND ts.schedule_status = 'ACTIVE'
        AND ts.is_deleted = FALSE
        AND ts.day_type = 'WEEKDAY'

    LEFT JOIN metro.TRAIN_STOP tst
        ON tst.schedule_id = ts.schedule_id
        AND tst.station_id = t.from_station_id

    WHERE t.status IN ('USED','ENTRY_DONE')
    AND t.is_deleted = FALSE

) x

WHERE rn = 1
LIMIT 20;

-- EXIT scans only for USED tickets
INSERT INTO metro.TICKET_GATE_SCAN
    (ticket_id, station_id, platform_no, gate_role,
     gate_device_id, scan_timestamp, is_valid,
     schedule_id, stop_sequence)

SELECT
    ticket_id,
    station_id,
    platform_no,
    gate_role,
    gate_device_id,
    scan_timestamp,
    is_valid,
    schedule_id,
    stop_sequence

FROM (
    SELECT
        t.ticket_id,
        t.to_station_id AS station_id,
        2 AS platform_no,

        'EXIT'::metro.gate_role_t AS gate_role,

        'GATE-' || ts_stn.station_code || '-OUT-01'
            AS gate_device_id,

        t.valid_from + INTERVAL '45 minutes'
            AS scan_timestamp,

        TRUE AS is_valid,

        ts.schedule_id,
        tst.stop_sequence,

        ROW_NUMBER() OVER(
            PARTITION BY t.ticket_id
            ORDER BY ts.schedule_id
        ) AS rn

    FROM metro.TICKET t

    JOIN metro.STATION ts_stn
        ON ts_stn.station_id = t.to_station_id

    JOIN metro.STATION_ON_LINE sol
        ON sol.station_id = t.to_station_id

    LEFT JOIN metro.TRAIN_SCHEDULE ts
        ON ts.line_id = sol.line_id
        AND ts.schedule_status='ACTIVE'
        AND ts.is_deleted=FALSE
        AND ts.day_type='WEEKDAY'

    LEFT JOIN metro.TRAIN_STOP tst
        ON tst.schedule_id = ts.schedule_id
        AND tst.station_id = t.to_station_id

    WHERE t.status='USED'
    AND t.is_deleted=FALSE

) x

WHERE rn=1
LIMIT 10;

-- One INVALID scan (wrong ticket at wrong gate — testing rejection)
INSERT INTO metro.TICKET_GATE_SCAN
    (ticket_id, station_id, platform_no, gate_role,
     gate_device_id, scan_timestamp, is_valid, rejection_reason)

SELECT
    t.ticket_id,
    s.station_id,
    2,
    'EXIT'::metro.gate_role_t,
    'GATE-TLG-OUT-02',
    NOW() - INTERVAL '3 hours',
    FALSE,
    'Wrong exit attempt'

FROM metro.TICKET t

JOIN metro.STATION s
    ON s.station_code = 'TLG'

WHERE t.status = 'ENTRY_DONE'
AND t.is_deleted = FALSE

ORDER BY t.ticket_id
LIMIT 1;


-- ================================================================
--  19. TRAVELLING_IN
--  Real-time passengers currently on trains (ON_TRACK trains only)
--  Each row = one passenger on one train stop right now
-- ================================================================

INSERT INTO metro.TRAVELLING_IN
    (passenger_id, schedule_id, stop_sequence,
     ticket_id, boarded_at, status)
SELECT
    p.passenger_id,
    ts.schedule_id,
    tst.stop_sequence,
    t.ticket_id,
    NOW() - INTERVAL '15 minutes',
    'ON_TRAIN'
FROM (VALUES
    ('Bhavesh Kumar',  'AMTS-BL-001', 'NCR'),
    ('Anjali Mishra',  'AMTS-BL-001', 'VTG'),
    ('Priya Patel',    'AMTS-BL-002', 'KLP'),
    ('Sneha Desai',    'AMTS-BL-003', 'OHC'),
    ('Rohan Mehta',    'AMTS-RL-001', 'APC'),
    ('Karan Joshi',    'AMTS-RL-001', 'PAL'),
    ('Raj Solanki',    'AMTS-RL-002', 'MTS'),
    ('Nisha Agrawal',  'AMTS-YL-001', 'GNL'),
    ('James Wilson',   'AMTS-YL-001', 'MTS'),
    ('Yuki Tanaka',    'AMTS-VL-001', 'GNL'),
    ('Aarav Shah',     'AMTS-BL-001', 'VTR'),
    ('Meera Rana',     'AMTS-RL-001', 'GDG'),
    ('Vihaan Shah',    'AMTS-BL-002', 'GHK'),
    ('Aadhya Patel',   'AMTS-RL-002', 'USM'),
    ('Kantibhai Shah', 'AMTS-BL-003', 'SPS')
) AS v(pname, train_num, station_code)
JOIN metro.PASSENGER       p   ON p.full_name      = v.pname
JOIN metro.TRAIN           tr  ON tr.train_number  = v.train_num
JOIN metro.TRAIN_SCHEDULE  ts  ON ts.train_id      = tr.train_id
                               AND ts.schedule_status = 'ACTIVE'
                               AND ts.day_type     = 'WEEKDAY'
                               AND ts.is_deleted   = FALSE
JOIN metro.STATION         st  ON st.station_code  = v.station_code
JOIN metro.TRAIN_STOP      tst ON tst.schedule_id  = ts.schedule_id
                               AND tst.station_id  = st.station_id
JOIN LATERAL (
    SELECT ticket_id
    FROM metro.TICKET tt
    WHERE tt.passenger_id = p.passenger_id
    AND tt.status NOT IN ('CANCELLED','EXPIRED')
    AND tt.is_deleted = FALSE
    ORDER BY tt.issued_at DESC
    LIMIT 1
) t ON TRUE
LIMIT 15;

-- A few EXITED records (historical — boarded earlier, now off)
INSERT INTO metro.TRAVELLING_IN
    (passenger_id, schedule_id, stop_sequence,
     ticket_id, boarded_at, exited_at, status)
SELECT
    p.passenger_id,
    ts.schedule_id,
    tst.stop_sequence,
    t.ticket_id,
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '1 hour',
    'EXITED'
FROM (VALUES
    ('Aarav Shah',     'AMTS-BL-001','VTG'),
    ('Chunilal Vaghela','AMTS-RL-001','PAL'),
    ('Ramanlal Trivedi','AMTS-RL-001','GDG')
) AS v(pname, train_num, station_code)
JOIN metro.PASSENGER       p   ON p.full_name     = v.pname
JOIN metro.TRAIN           tr  ON tr.train_number = v.train_num
JOIN metro.TRAIN_SCHEDULE  ts  ON ts.train_id     = tr.train_id
                               AND ts.schedule_status = 'ACTIVE'
                               AND ts.day_type    = 'WEEKDAY'
                               AND ts.is_deleted  = FALSE
JOIN metro.STATION         st  ON st.station_code = v.station_code
JOIN metro.TRAIN_STOP      tst ON tst.schedule_id = ts.schedule_id
                               AND tst.station_id = st.station_id
 JOIN LATERAL (
    SELECT ticket_id
    FROM metro.TICKET tt
    WHERE tt.passenger_id = p.passenger_id
    AND tt.status NOT IN ('CANCELLED','EXPIRED')
    AND tt.is_deleted = FALSE
    ORDER BY tt.issued_at DESC
    LIMIT 1
) t ON TRUE;



-- ================================================================
--  20. DELAY_EVENT  (16 delay records — varied categories)
-- ================================================================

INSERT INTO metro.DELAY_EVENT
    (schedule_id, affected_station_id, delay_minutes,
     reason, delay_category, resolution_status,
     reported_at, resolved_at, resolved_by_emp_id)
SELECT
    ts.schedule_id,
    s.station_id,
    v.delay_mins,
    v.reason,
    v.category,
    v.status::metro.delay_resolution_t,
    NOW() - (v.reported_ago || ' minutes')::INTERVAL,
    CASE WHEN v.status = 'RESOLVED'
         THEN NOW() - (v.reported_ago - v.delay_mins || ' minutes')::INTERVAL
         ELSE NULL END,
    CASE WHEN v.status = 'RESOLVED'
         THEN (SELECT employee_id FROM metro.EMPLOYEE WHERE employee_code = 'EMP002')
         ELSE NULL END
FROM (VALUES
    -- Blue Line delays
    ('AMTS-BL-001','KLP',  8,'Signal failure at Kalupur junction',
     'TECHNICAL','RESOLVED', 120),
    ('AMTS-BL-002','OHC', 12,'Power supply interruption at interchange station',
     'TECHNICAL','RESOLVED',  90),
    ('AMTS-BL-003','GUV',  5,'Medical emergency on platform',
     'MEDICAL',  'RESOLVED',  60),
    ('AMTS-BL-004','SPS',  3,'Passenger fell on platform, door hold',
     'MEDICAL',  'RESOLVED',  45),

    -- Red Line delays
    ('AMTS-RL-001','APC', 15,'Obstruction on track near APMC',
     'OPERATIONAL','RESOLVED',180),
    ('AMTS-RL-002','MTS', 20,'Heavy crowd at Motera — cricket match day',
     'OPERATIONAL','RESOLVED',150),
    ('AMTS-RL-003','USM',  7,'Minor door sensor fault',
     'TECHNICAL',  'RESOLVED', 75),
    ('AMTS-RL-004','SBR',  6,'Security check — suspicious bag',
     'SECURITY',   'RESOLVED', 40),

    -- Yellow Line delays
    ('AMTS-YL-001','GNL', 10,'Track maintenance overrun near GNLU',
     'OPERATIONAL','IN_PROGRESS',30),
    ('AMTS-YL-002','IFC',  8,'Signal sync issue — new line commissioning',
     'TECHNICAL',  'PENDING',   15),
    ('AMTS-YL-003','MMD', 25,'VIP movement near Mahatma Mandir',
     'EXTERNAL',   'RESOLVED',  200),
    ('AMTS-YL-004','RDS',  5,'Overhead equipment check',
     'TECHNICAL',  'RESOLVED',   50),

    -- Violet Line delays
    ('AMTS-VL-001','GNL',  4,'Platform door alignment issue at GNLU',
     'TECHNICAL',  'RESOLVED',   35),
    ('AMTS-VL-002','GFT', 18,'Passenger stuck in door — GIFT City',
     'OPERATIONAL','RESOLVED',   70),

    -- Historical delays (yesterday)
    ('AMTS-BL-001','VTG', 30,'Severe weather — dust storm',
     'WEATHER',    'RESOLVED',  1500),
    ('AMTS-RL-001','PAL', 45,'Power grid failure — city-wide',
     'TECHNICAL',  'CLOSED',   2880)
) AS v(train_num, stn_code, delay_mins, reason, category, status, reported_ago)
JOIN metro.TRAIN           tr ON tr.train_number = v.train_num
JOIN metro.TRAIN_SCHEDULE  ts ON ts.train_id     = tr.train_id
                              AND ts.schedule_status IN ('ACTIVE','DELAYED','CANCELLED')
                              AND ts.day_type    = 'WEEKDAY'
                              AND ts.is_deleted  = FALSE
JOIN metro.STATION         s  ON s.station_code  = v.stn_code
ORDER BY ts.schedule_id LIMIT 16;

-- Mark 2 schedules as DELAYED to reflect pending delays
UPDATE metro.TRAIN_SCHEDULE
SET    schedule_status = 'DELAYED',
       updated_at      = NOW()
WHERE  schedule_id IN (
    SELECT DISTINCT de.schedule_id
    FROM   metro.DELAY_EVENT de
    WHERE  de.resolution_status IN ('PENDING','IN_PROGRESS')
);



-- ================================================================
--  21. RESCHEDULE_LOG  (10 reschedule events)
-- ================================================================

INSERT INTO metro.RESCHEDULE_LOG
    (schedule_id, reason,
     original_dep_time, new_dep_time,
     original_arr_time, new_arr_time,
     old_track_id, new_track_id,
     done_by_emp_id, logged_at)
SELECT
    ts.schedule_id,
    v.reason,
    ts.departure_time,
    (ts.departure_time + (v.delay_add || ' minutes')::INTERVAL)::TIME,
    ts.arrival_time,
    (ts.arrival_time + (v.delay_add || ' minutes')::INTERVAL)::TIME,
    ts.track_id,
    ts.track_id,
    emp.employee_id,
    NOW() - (v.logged_ago || ' minutes')::INTERVAL
FROM (VALUES
    ('AMTS-BL-001', 8,  'Signal failure delay compensation', 125),
    ('AMTS-BL-002', 12, 'Power interruption — cascading delay', 95),
    ('AMTS-RL-001', 15, 'Track obstruction — service adjusted', 185),
    ('AMTS-RL-002', 20, 'High crowd — extended dwell times', 155),
    ('AMTS-YL-001', 10, 'New line commissioning adjustment',   35),
    ('AMTS-YL-003', 25, 'VIP movement protocol',             205),
    ('AMTS-VL-001',  4, 'Platform door maintenance',          40),
    ('AMTS-VL-002', 18, 'Passenger incident — GIFT City',     75),
    ('AMTS-BL-001', 30, 'Dust storm — safety speed reduction',1505),
    ('AMTS-RL-001', 45, 'Power grid failure recovery',        2885)
) AS v(train_num, delay_add, reason, logged_ago)
JOIN metro.TRAIN           tr  ON tr.train_number = v.train_num
JOIN metro.TRAIN_SCHEDULE  ts  ON ts.train_id     = tr.train_id
                               AND ts.day_type    = 'WEEKDAY'
                               AND ts.is_deleted  = FALSE
LEFT JOIN metro.TRACK      tk  ON tk.track_id     = ts.track_id
CROSS JOIN (
    SELECT employee_id FROM metro.EMPLOYEE WHERE employee_code = 'EMP002'
) emp;



-- ================================================================
--  AHMEDABAD METRO — INSERT PART 6
--  Tables: STATION_CLOSURE → TRAIN_INCIDENT
--          → MAINTENANCE_LOG → LIVE_TRACKING
-- ================================================================



-- ================================================================
--  22. STATION_CLOSURE  (10 closures — various types & statuses)
-- ================================================================

INSERT INTO metro.STATION_CLOSURE
    (station_id, closure_type, reason,
     start_datetime, end_datetime, actual_reopen_at,
     status, approved_by_emp_id)
SELECT
    s.station_id,
    v.closure_type::metro.closure_type_t,
    v.reason,
    NOW() - (v.start_ago  || ' hours')::INTERVAL,
    CASE WHEN v.end_hours IS NOT NULL
         THEN NOW() - (v.start_ago - v.end_hours || ' hours')::INTERVAL
         ELSE NULL END,
    CASE WHEN v.status = 'LIFTED'
         THEN NOW() - ((v.start_ago - v.end_hours - 1) || ' hours')::INTERVAL
         ELSE NULL END,
    v.status,
    emp.employee_id
FROM (VALUES
    -- Completed / past closures
    ('KLP','SCHEDULED_MAINTENANCE',
     'Annual platform maintenance & PSD inspection',
     72, 24, 'LIFTED'),

    ('OHC','EMERGENCY',
     'Water seepage in underground tunnel — emergency pumping',
     48, 6,  'LIFTED'),

    ('MTS','SCHEDULED_MAINTENANCE',
     'Pre-match crowd management system upgrade — IPL',
     36, 12, 'LIFTED'),

    ('GNL','SCHEDULED_MAINTENANCE',
     'Interchange gate infrastructure expansion work',
     96, 48, 'LIFTED'),

    -- Active closures (currently closed)
    ('GFT','SCHEDULED_MAINTENANCE',
     'GIFT City platform extension for 8-car trains',
     12, NULL, 'ACTIVE'),

    ('MMD','SCHEDULED_MAINTENANCE',
     'Convention centre event — additional crowd barriers',
     6,  NULL, 'ACTIVE'),

    -- Cancelled closures (work not needed after inspection)
    ('AMR','SCHEDULED_MAINTENANCE',
     'Signalling upgrade — deferred to next cycle',
     240, NULL, 'CANCELLED'),

    -- Emergency closures — resolved
    ('SHP','EMERGENCY',
     'Fire alarm triggered — underground station evacuation',
     120, 2,  'LIFTED'),

    ('VTG','FORCE_MAJEURE',
     'Dust storm — visibility zero on elevated track',
     168, 4,  'LIFTED'),

    -- Planned future closure (not yet started — end = future)
    ('GKR','SCHEDULED_MAINTENANCE',
     'Escalator replacement — all 4 units',
     -48, NULL, 'ACTIVE')         -- starts 48h from now (negative = future)
) AS v(stn_code, closure_type, reason, start_ago, end_hours, status)
JOIN metro.STATION s ON s.station_code = v.stn_code
CROSS JOIN (
    SELECT employee_id FROM metro.EMPLOYEE WHERE employee_code = 'EMP017'
) emp;

-- Fix future closure: start_datetime should be in future
UPDATE metro.STATION_CLOSURE
SET    start_datetime = NOW() + INTERVAL '48 hours',
       end_datetime   = NOW() + INTERVAL '72 hours'
WHERE  station_id = (SELECT station_id FROM metro.STATION
                     WHERE station_code = 'GKR')
AND    status = 'ACTIVE'
AND    start_datetime > NOW();

-- ================================================================
--  23. TRAIN_INCIDENT  (10 incidents — varied types & severities)
-- ================================================================

INSERT INTO metro.TRAIN_INCIDENT
    (train_id, near_station_id, schedule_id,
     incident_type, incident_datetime,
     location_description,
     location_lat, location_lng,
     severity_level, status,
     replacement_train_id,
     reported_by_emp_id, investigated_by_emp_id,
     root_cause, corrective_action,
     contained_at, resolved_at, closed_at, notes)
SELECT
    tr.train_id,
    s.station_id,
    ts.schedule_id,
    v.inc_type::metro.incident_type_t,
    NOW() - (v.days_ago || ' days')::INTERVAL,
    v.location_desc,
    s.latitude + 0.001,
    s.longitude + 0.001,
    v.severity,
    v.status::metro.incident_status_t,
    rtr.train_id,
    rep_emp.employee_id,
    inv_emp.employee_id,
    v.root_cause,
    v.corrective_action,
    CASE WHEN v.status NOT IN ('OPEN')
         THEN NOW() - (v.days_ago - 0.5 || ' days')::INTERVAL ELSE NULL END,
    CASE WHEN v.status IN ('RESOLVED','CLOSED','ARCHIVED')
         THEN NOW() - (v.days_ago - 1 || ' days')::INTERVAL ELSE NULL END,
    CASE WHEN v.status IN ('CLOSED','ARCHIVED')
         THEN NOW() - (v.days_ago - 2 || ' days')::INTERVAL ELSE NULL END,
    v.notes
FROM (VALUES
    -- Severity 1 — Minor
    ('AMTS-BL-001','KLP', 'BREAKDOWN',
     'Minor door actuator fault — Platform 1 Kalupur',
     30, 1, 'CLOSED',    NULL,
     'Door actuator solenoid failed due to dust accumulation',
     'Replaced solenoid; added weekly dust cleaning to PM schedule',
     'Routine breakdown during high-traffic morning run',
     'AMTS-SP-001'),

    ('AMTS-RL-001','PAL', 'SIGNAL_FAILURE',
     'Signal relay failure between Paldi and Gandhigram',
     25, 1, 'CLOSED',    NULL,
     'Faulty signal relay due to age — exceeded 5-year lifecycle',
     'Replaced relay; scheduled replacement of all relays >4 years old',
     'Caused 15 min delay; no physical damage',
     NULL),

    -- Severity 2 — Low-Moderate
    ('AMTS-BL-002','OHC', 'BREAKDOWN',
     'Traction motor overheat — Old High Court interchange',
     20, 2, 'RESOLVED',  NULL,
     'Coolant leak in traction motor cooling circuit',
     'Sealed coolant line; replaced motor cooling pump',
     'Train taken out of service; replacement deployed',
     'AMTS-SP-001'),

    ('AMTS-RL-002','MTS', 'OBSTRUCTION_ON_TRACK',
     'Construction debris on track near Motera Stadium',
     15, 2, 'CLOSED',    NULL,
     'Construction contractor negligence — material fell on track',
     'Contractor sanctioned; enhanced barrier requirements enforced',
     'Cleared manually in 20 minutes; minor delay',
     NULL),

    -- Severity 3 — Moderate
    ('AMTS-YL-001','GNL', 'POWER_FAILURE',
     'OHE cable sag — Gandhinagar University section',
     10, 3, 'RESOLVED',  NULL,
     'Overhead Equipment (OHE) cable thermal expansion caused sag',
     'Adjusted OHE tension; installed temperature compensation clamps',
     'Affected 3 trains; cascading delays on Yellow Line',
     'AMTS-SP-002'),

    ('AMTS-BL-003','TLT', 'BREAKDOWN',
     'Wheel flat detected — speed restriction applied at Thaltej',
     8,  3, 'RESOLVED',  NULL,
     'Wheel flat developed due to emergency braking event',
     'Wheel set replaced in depot; braking system recalibrated',
     'Train ran at 40 kmph until depot; no passenger injury',
     'AMTS-BL-004'),

    -- Severity 4 — High
    ('AMTS-RL-003','SBR', 'FIRE',
     'Electrical fire in motor coach — Sabarmati station',
     5,  4, 'RESOLVED',  NULL,
     'Insulation failure on main power cable caused electrical fire',
     'Full cable replacement in motor coach; fire suppression system tested',
     'Station evacuated; 2 coaches damaged; no injuries; 45 min disruption',
     'AMTS-RL-004'),

    ('AMTS-YL-002','IFC', 'DERAILMENT',
     'Minor derailment at Infocity station entry turnout',
     3,  4, 'UNDER_INVESTIGATION', NULL,
     'Under investigation — preliminary: track geometry deviation',
     'Temporary speed restriction; track geometry survey ordered',
     'Rear bogie of last coach derailed; no injuries; line suspended 3hrs',
     'AMTS-SP-002'),

    -- Severity 5 — Critical
    ('AMTS-BL-004','AMR', 'CRASH',
     'Collision with stationary maintenance vehicle near Amraiwadi',
     60, 5, 'CLOSED',    'AMTS-SP-001',
     'Maintenance vehicle left on track without proper clearance',
     'Strict authority-to-work process enforced; biometric track access installed',
     'Front cab damaged; driver minor injury; 4 hr disruption on Blue Line',
     'AMTS-SP-001'),

    -- Recent open incident
    ('AMTS-VL-001','GFT', 'BREAKDOWN',
     'Pantograph damage at GIFT City elevated section',
     1,  2, 'OPEN',      NULL,
     NULL, NULL,
     'Pantograph arm fractured on entering GIFT City station',
     NULL)
) AS v(train_num, stn_code, inc_type, location_desc, days_ago,
       severity, status, replacement_num, root_cause, corrective_action,
       notes, repl_num2)
JOIN metro.TRAIN           tr      ON tr.train_number   = v.train_num
JOIN metro.STATION         s       ON s.station_code    = v.stn_code
JOIN metro.TRAIN_SCHEDULE  ts      ON ts.train_id       = tr.train_id
                                   AND ts.day_type      = 'WEEKDAY'
                                   AND ts.is_deleted    = FALSE
LEFT JOIN metro.TRAIN      rtr     ON rtr.train_number  = v.replacement_num
CROSS JOIN (SELECT employee_id FROM metro.EMPLOYEE
             WHERE employee_code = 'EMP002') rep_emp
CROSS JOIN (SELECT employee_id FROM metro.EMPLOYEE
             WHERE employee_code = 'EMP008') inv_emp;

-- ================================================================
--  24. MAINTENANCE_LOG  (16 maintenance work orders)
-- ================================================================

INSERT INTO metro.MAINTENANCE_LOG
    (train_id, incident_id,
     maintenance_type, maintenance_date, description,
     parts_replaced, vendor_name,
     estimated_cost, actual_cost,
     performed_by_emp_id, supervised_by_emp_id, approved_by_emp_id,
     status, scheduled_start, actual_start, completed_at,
     next_due_date)
SELECT
    tr.train_id,
    inc.incident_id,
    v.maint_type::metro.maint_type_t,
    CURRENT_DATE - (v.days_ago || ' days')::INTERVAL,
    v.description,
    v.parts_replaced,
    v.vendor,
    v.est_cost,
    v.act_cost,
    perf_emp.employee_id,
    sup_emp.employee_id,
    appr_emp.employee_id,
    v.status::metro.maint_status_t,
    (CURRENT_DATE - (v.days_ago || ' days')::INTERVAL)::TIMESTAMP,
    CASE WHEN v.status != 'SCHEDULED'
         THEN (CURRENT_DATE - (v.days_ago || ' days')::INTERVAL +
               INTERVAL '2 hours')
         ELSE NULL END,
    CASE WHEN v.status = 'COMPLETED'
         THEN (CURRENT_DATE - (v.days_ago || ' days')::INTERVAL +
               INTERVAL '8 hours')
         ELSE NULL END,
    CURRENT_DATE + (v.next_due || ' days')::INTERVAL
FROM (VALUES
    ('AMTS-BL-001',NULL,'ROUTINE_INSPECTION',0,
     'Daily pre-service inspection — brakes, doors, pantograph, lights',
     NULL,'GMRC Internal',
     5000.00,4800.00,30,'COMPLETED'),

    ('AMTS-BL-002',NULL,'ROUTINE_INSPECTION',1,
     'Daily pre-service inspection',
     NULL,'GMRC Internal',
     5000.00,5000.00,30,'COMPLETED'),

    ('AMTS-RL-001',NULL,'ROUTINE_INSPECTION',0,
     'Daily pre-service inspection — all systems nominal',
     NULL,'GMRC Internal',
     5000.00,4950.00,30,'COMPLETED'),

    ('AMTS-BL-004',NULL,'CORRECTIVE',7,
     'Front cab repair and structural reinforcement after collision',
     'Front cab assembly, windshield, buffer coupler',
     'Bombardier Transportation India',
     850000.00,920000.00,30,'COMPLETED'),

    ('AMTS-BL-002',NULL,'CORRECTIVE',20,
     'Traction motor cooling system overhaul',
     'Cooling pump, coolant hoses, thermostat',
     'Siemens Mobility India',
     125000.00,118000.00,30,'COMPLETED'),

    ('AMTS-RL-003',NULL,'CORRECTIVE',5,
     'Motor coach electrical cable replacement after fire damage',
     'HT power cables (200m), cable trays, connectors',
     'Polycab India Ltd',
     380000.00,NULL,60,'IN_PROGRESS'),

    ('AMTS-YL-002',NULL,'CORRECTIVE',3,
     'Bogie realignment and track geometry correction — post derailment',
     'Bogie frame inspection, wheel set, axle bearing',
     'BEML Limited',
     650000.00,NULL,90,'IN_PROGRESS'),

    ('AMTS-BL-001',NULL,'PREVENTIVE',30,
     'Quarterly brake pad replacement and brake disc inspection',
     'Brake pads (set of 48), brake discs (8)',
     'Wabtec India',
     95000.00,92000.00,90,'COMPLETED'),

    ('AMTS-RL-001',NULL,'PREVENTIVE',45,
     'Pantograph replacement — scheduled lifecycle change',
     'Pantograph assembly (2 units)',
     'Schunk Carbon Group India',
     180000.00,175000.00,90,'COMPLETED'),

    ('AMTS-YL-001',NULL,'PREVENTIVE',15,
     'OHE tension adjustment and thermal clamp installation',
     'Tension clamps (20 units), hardware',
     'KEC International',
     45000.00,42000.00,30,'COMPLETED'),

    ('AMTS-BL-003',NULL,'CORRECTIVE',8,
     'Wheel set replacement — flat wheel detected',
     'Wheel set (2 axles), bearing assembly',
     'SAIL (Steel Authority of India)',
     220000.00,215000.00,30,'COMPLETED'),

    ('AMTS-VL-001',NULL,'CORRECTIVE',1,
     'Pantograph arm replacement — fractured at GIFT City',
     'Pantograph arm, carbon strip, springs',
     'Schunk Carbon Group India',
     95000.00,NULL,30,'IN_PROGRESS'),

    ('AMTS-SP-001',NULL,'OVERHAUL',180,
     'Mid-life overhaul — complete systems check and refurbishment',
     'Interior panels, seats (425), HVAC filters, door mechanisms',
     'Bombardier Transportation India',
     4500000.00,4380000.00,720,'COMPLETED'),

    ('AMTS-BL-001',NULL,'CLEANING',0,
     'End-of-day deep cleaning — all 6 coaches',
     NULL,'GMRC Internal',
     3500.00,3500.00,1,'COMPLETED'),

    ('AMTS-RL-002',NULL,'ROUTINE_INSPECTION',2,
     'Weekly detailed inspection — all critical systems',
     'HVAC filter set','GMRC Internal',
     12000.00,11500.00,7,'COMPLETED'),

    -- Scheduled future maintenance
    ('AMTS-YL-003',NULL,'PREVENTIVE',-14,
     'Quarterly door mechanism lubrication and adjustment',
     'Door rollers, seals','GMRC Internal',
     35000.00,NULL,90,'SCHEDULED')
) AS v(train_num, inc_ref, maint_type, days_ago, description,
       parts_replaced, vendor, est_cost, act_cost,
       next_due, status)
JOIN  metro.TRAIN tr  ON tr.train_number = v.train_num
LEFT JOIN metro.TRAIN_INCIDENT inc
       ON inc.train_id = tr.train_id
       AND inc.status = 'CLOSED'
       AND v.inc_ref IS NULL
CROSS JOIN (SELECT employee_id FROM metro.EMPLOYEE
             WHERE employee_code = 'EMP008') perf_emp
CROSS JOIN (SELECT employee_id FROM metro.EMPLOYEE
             WHERE employee_code = 'EMP009') sup_emp
CROSS JOIN (SELECT employee_id FROM metro.EMPLOYEE
             WHERE employee_code = 'EMP017') appr_emp;

-- ================================================================
--  25. LIVE_TRACKING  (GPS pings for 6 ON_TRACK trains)
--  Simulate last 10 pings per train (5-second intervals)
--  Trains move ~30 kmph = 41.6 m per 5 seconds
-- ================================================================

DO $gps$
DECLARE
    v_train     RECORD;
    v_lat       NUMERIC(9,6);
    v_lng       NUMERIC(9,6);
    v_speed     NUMERIC(5,2);
    i           INT;
    v_sched_id  INT;
BEGIN
    FOR v_train IN
        SELECT t.train_id, t.train_number, t.current_line_id,
               t.current_lat, t.current_lng
        FROM   metro.TRAIN t
        WHERE  t.operational_status = 'ON_TRACK'
        AND    t.is_deleted         = FALSE
        ORDER  BY t.train_id
    LOOP
        -- get a schedule for this train
        SELECT schedule_id INTO v_sched_id
        FROM   metro.TRAIN_SCHEDULE
        WHERE  train_id       = v_train.train_id
        AND    schedule_status IN ('ACTIVE','DELAYED')
        AND    is_deleted     = FALSE
        LIMIT  1;

        -- use real lat/lng from train or fallback
        v_lat   := COALESCE(v_train.current_lat,  23.0269);
        v_lng   := COALESCE(v_train.current_lng,  72.5874);
        v_speed := 28.0 + (RANDOM() * 10)::NUMERIC(5,2);

        FOR i IN REVERSE 10..1 LOOP
            INSERT INTO metro.LIVE_TRACKING (
                train_id, schedule_id,
                latitude, longitude, altitude_m, accuracy_m,
                speed_kmph, heading_degrees,
                dynamic_block_dist_m, recorded_at, updated_eta
            ) VALUES (
                v_train.train_id,
                v_sched_id,
                v_lat   + (i * 0.0003),
                v_lng   + (i * 0.0002),
                52.0,
                3.5,
                v_speed + (RANDOM() * 5 - 2.5)::NUMERIC(5,2),
                CASE WHEN v_train.train_number LIKE '%BL%' THEN 90.0
                     WHEN v_train.train_number LIKE '%RL%' THEN 0.0
                     ELSE 15.0 END,
                200,
                NOW() - (i * 5 || ' seconds')::INTERVAL,
                NOW() + ((30 - i) || ' minutes')::INTERVAL
            );
        END LOOP;

        -- Update TRAIN fast-cache with latest GPS
        UPDATE metro.TRAIN
        SET    current_lat        = v_lat + 0.0003,
               current_lng        = v_lng + 0.0002,
               current_speed_kmph = v_speed,
               last_gps_update    = NOW(),
               updated_at         = NOW()
        WHERE  train_id = v_train.train_id;

    END LOOP;

    RAISE NOTICE 'LIVE_TRACKING: GPS pings inserted for all ON_TRACK trains.';
END $gps$;



-- ================================================================
--  AHMEDABAD METRO — INSERT PART 7 (FINAL)
--  Tables: ALERT → ALERT_PASSENGER_MAP → FEEDBACK → AUDIT_LOG
-- ================================================================

-- ================================================================
--  26. ALERT  (18 alerts — all types, severities, channels)
-- ================================================================

INSERT INTO metro.ALERT
    (train_id, schedule_id, station_id, line_id, incident_id,
     alert_type, severity, title, message, channel,
     is_resolved, resolved_at, auto_expires_at,
     created_by_emp_id, created_at)
SELECT
    tr.train_id,
    ts.schedule_id,
    s.station_id,
    l.line_id,
    inc.incident_id,
    v.alert_type::metro.alert_type_t,
    v.severity::metro.alert_severity_t,
    v.title,
    v.message,
    v.channel::metro.alert_channel_t,
    v.is_resolved,
    CASE WHEN v.is_resolved
         THEN NOW() - (v.created_ago - 30 || ' minutes')::INTERVAL
         ELSE NULL END,
    NOW() + INTERVAL '6 hours',
    emp.employee_id,
    NOW() - (v.created_ago || ' minutes')::INTERVAL
FROM (VALUES
    -- Delay alerts
    ('AMTS-BL-001','KLP','L1',NULL,
     'DELAY','INFO',
     'Blue Line: Minor Delay at Kalupur',
     'Train AMTS-BL-001 (Blue Line) is delayed by 8 minutes at Kalupur '
     'due to signal maintenance. Alternate platform services available.',
     'ALL', TRUE, 125),

    ('AMTS-RL-001','APC','L2',NULL,
     'DELAY','WARNING',
     'Red Line: Track Obstruction — 15 min Delay',
     'Train AMTS-RL-001 (Red Line) delayed 15 min near APMC. '
     'Track cleared. Service resuming. Thank you for patience.',
     'ALL', TRUE, 185),

    ('AMTS-YL-001','GNL','L3',NULL,
     'DELAY','WARNING',
     'Yellow Line: Track Work Delay at GNLU',
     'Yellow Line service delayed 10 minutes near GNLU station '
     'due to ongoing track maintenance. Engineers on site.',
     'ALL', FALSE, 30),

    ('AMTS-YL-002','IFC','L3',NULL,
     'DELAY','CRITICAL',
     'Yellow Line: Derailment — Service Suspended',
     'Yellow Line service between Motera and GNLU suspended due to '
     'minor derailment at Infocity. Buses arranged. '
     'Estimated resumption: 3 hours.',
     'ALL', FALSE, 15),

    -- Platform change alerts
    ('AMTS-RL-002','MTS','L2',NULL,
     'PLATFORM_CHANGE','WARNING',
     'Platform Change: Red Line at Motera Stadium',
     'Due to IPL match crowd management, Red Line trains will '
     'now depart from Platform 2 instead of Platform 1 at Motera. '
     'Follow staff guidance.',
     'ALL', TRUE, 155),

    ('AMTS-BL-003','OHC','L1',NULL,
     'PLATFORM_CHANGE','INFO',
     'Platform Change: Blue Line at Old High Court',
     'Blue Line eastbound trains temporarily shifted to Platform 2 '
     'at Old High Court for platform maintenance. Duration: 2 hours.',
     'IN_APP', TRUE, 70),

    -- Cancellation alerts
    ('AMTS-YL-002','MMD','L3',NULL,
     'CANCELLATION','CRITICAL',
     'Yellow Line Service Cancelled — Derailment',
     'Yellow Line services are cancelled between Motera and Mahatma Mandir '
     'until further notice. Free bus shuttle service arranged at all stations.',
     'ALL', FALSE, 10),

    -- Emergency alerts
    ('AMTS-RL-003','SBR','L2',NULL,
     'EMERGENCY','EMERGENCY',
     'EMERGENCY: Fire in Train — Sabarmati Station',
     'Emergency alert: Electrical fire reported in AMTS-RL-003 at '
     'Sabarmati station. Station evacuated. Emergency services on site. '
     'Please do not enter Sabarmati station.',
     'ALL', TRUE, 200),

    -- High crowd alerts
    ('AMTS-RL-001','MTS','L2',NULL,
     'HIGH_CROWD','WARNING',
     'High Crowd: Motera Stadium Station',
     'Very high passenger volume at Motera Stadium station '
     'due to cricket match. Allow extra boarding time. '
     'Next 3 trains reserved for current platform passengers.',
     'ALL', TRUE, 155),

    ('AMTS-BL-001','KLP','L1',NULL,
     'HIGH_CROWD','INFO',
     'Moderate Crowd: Kalupur Station',
     'Kalupur station is experiencing moderate crowd levels (72%). '
     'Next train departs in 4 minutes. Please queue in marked areas.',
     'IN_APP', TRUE, 30),

    -- Maintenance closure alerts
    (NULL,'GFT',NULL,NULL,
     'MAINTENANCE_CLOSURE','WARNING',
     'Station Closed: GIFT City — Platform Extension Work',
     'GIFT City station is closed for platform extension work. '
     'Estimated reopening: 3 days. Use GNLU station and feeder buses.',
     'ALL', FALSE, 12),

    (NULL,'MMD',NULL,NULL,
     'MAINTENANCE_CLOSURE','INFO',
     'Limited Access: Mahatma Mandir — Convention Event',
     'Mahatma Mandir station has limited access today due to '
     'convention event. Additional staff deployed. Allow extra time.',
     'IN_APP', FALSE, 6),

    -- General advisory
    (NULL,NULL,'L3',NULL,
     'GENERAL_ADVISORY','INFO',
     'Yellow Line: Reduced Frequency Today',
     'Yellow Line will operate at 20-minute intervals today '
     'between 10:00–17:00 due to scheduled maintenance activities. '
     'Normal service resumes from 17:00.',
     'ALL', FALSE, 45),

    (NULL,NULL,'L1',NULL,
     'GENERAL_ADVISORY','INFO',
     'Blue Line: Extended Service — Festival Day',
     'Blue Line will run extended services until 01:00 AM tonight '
     'due to Navratri celebrations. Last train from TLG at 01:00.',
     'ALL', TRUE, 1440),

    -- Track change alert
    ('AMTS-BL-001','AMR','L1',NULL,
     'TRACK_CHANGE','CRITICAL',
     'Track Changed: Blue Line Amraiwadi Section',
     'Following the collision incident, Blue Line trains are '
     'now routed via alternate track between Vastral and Apparel Park. '
     'Speed restriction 40 kmph in effect.',
     'ALL', TRUE, 2880),

    -- Incident-related alerts
    ('AMTS-BL-001','AMR','L1',NULL,
     'EMERGENCY','CRITICAL',
     'INCIDENT: Train Collision at Amraiwadi',
     'Train AMTS-BL-004 involved in collision with maintenance vehicle '
     'near Amraiwadi station. Services disrupted. '
     'Emergency services responding. No passenger injuries.',
     'ALL', TRUE, 1445),

    -- Informational
    (NULL,NULL,'L4',NULL,
     'GENERAL_ADVISORY','INFO',
     'Violet Line: New Station Opening — PDEU',
     'PDEU station on Violet Line is now open for passengers. '
     'Direct connectivity to GIFT City now available from Gandhinagar network.',
     'ALL', TRUE, 2160),
     (NULL,NULL,'L1',NULL,
 'GENERAL_ADVISORY','INFO',
 'Ahmedabad Metro: Republic Day Special Services',
 'Special metro services on Republic Day (26 Jan). '
 'First train at 05:00, last train at 01:00 AM. '
 'Free travel for armed forces personnel on Republic Day.',
 'ALL', TRUE, 4320)
) AS v(train_num, stn_code, line_code, inc_ref,
       alert_type, severity, title, message, channel,
       is_resolved, created_ago)
LEFT JOIN metro.TRAIN           tr  ON tr.train_number = v.train_num
LEFT JOIN metro.TRAIN_SCHEDULE  ts  ON ts.train_id     = tr.train_id
                                    AND ts.day_type    = 'WEEKDAY'
                                    AND ts.is_deleted  = FALSE
LEFT JOIN metro.STATION         s   ON s.station_code  = v.stn_code
LEFT JOIN metro.LINE            l   ON l.line_code     = v.line_code
LEFT JOIN metro.TRAIN_INCIDENT  inc ON inc.train_id    = tr.train_id
                                    AND inc.status     = 'CLOSED'
CROSS JOIN (
    SELECT employee_id FROM metro.EMPLOYEE WHERE employee_code = 'EMP002'
) emp;



-- ================================================================
--  27. ALERT_PASSENGER_MAP
--  Send relevant alerts to passengers based on their active tickets
-- ================================================================

INSERT INTO metro.ALERT_PASSENGER_MAP
    (alert_id, passenger_id, sent_at, is_read, read_at, delivery_status)
SELECT DISTINCT
    a.alert_id,
    p.passenger_id,
    a.created_at + INTERVAL '30 seconds',
    v.is_read,
    CASE WHEN v.is_read
         THEN a.created_at + (FLOOR(RANDOM()*300+60) || ' seconds')::INTERVAL
         ELSE NULL END,
    CASE WHEN v.is_read THEN 'READ' ELSE 'DELIVERED' END
FROM (VALUES
    ('Aarav Shah',       TRUE),
    ('Priya Patel',      TRUE),
    ('Rohan Mehta',      TRUE),
    ('Sneha Desai',      FALSE),
    ('Karan Joshi',      TRUE),
    ('Bhavesh Kumar',    TRUE),
    ('Anjali Mishra',    FALSE),
    ('Raj Solanki',      TRUE),
    ('Nisha Agrawal',    TRUE),
    ('Diya Sharma',      FALSE),
    ('James Wilson',     TRUE),
    ('Yuki Tanaka',      FALSE),
    ('Meera Rana',       TRUE),
    ('Ramanlal Trivedi', FALSE),
    ('Kantibhai Shah',   FALSE)
) AS v(pname, is_read)
JOIN metro.PASSENGER p ON p.full_name = v.pname
-- Map to unresolved alerts only (relevant to send)
JOIN metro.ALERT a ON a.is_resolved = FALSE
                   OR a.created_at >= NOW() - INTERVAL '2 hours'

ON CONFLICT (alert_id, passenger_id) DO NOTHING;

-- ================================================================
--  28. FEEDBACK  (20 feedback entries — varied ratings & categories)
-- ================================================================

INSERT INTO metro.FEEDBACK
    (passenger_id, schedule_id, station_id, ticket_id,
     category, rating, comment, status,
     reviewed_by_emp_id, review_notes, reviewed_at, submitted_at)
SELECT
    p.passenger_id,
    ts.schedule_id,
    s.station_id,
    t.ticket_id,
    v.category::metro.feedback_category_t,
    v.rating,
    v.comment,
    v.status,
    CASE WHEN v.status IN ('RESOLVED','CLOSED')
         THEN (SELECT employee_id FROM metro.EMPLOYEE
               WHERE employee_code = 'EMP018')
         ELSE NULL END,
    CASE WHEN v.status IN ('RESOLVED','CLOSED')
         THEN 'Issue acknowledged and resolved. Thank you for feedback.'
         ELSE NULL END,
    CASE WHEN v.status IN ('RESOLVED','CLOSED')
         THEN NOW() - INTERVAL '1 day'
         ELSE NULL END,
    NOW() - (v.submitted_ago || ' hours')::INTERVAL
FROM (VALUES
    ('Aarav Shah',       'AMTS-BL-001','VTG', 'PUNCTUALITY',      5,
     'Train was perfectly on time. Smooth ride. Excellent service!',
     'CLOSED', 48),

    ('Priya Patel',      'AMTS-BL-002','KLP', 'CLEANLINESS',       4,
     'Coaches are clean but platform at Kalupur could be cleaner.',
     'RESOLVED', 36),

    ('Rohan Mehta',      'AMTS-RL-001','APC', 'PUNCTUALITY',       2,
     'Train was 15 minutes late due to track issue. '
     'No announcement on platform. Very inconvenient.',
     'RESOLVED', 24),

    ('Sneha Desai',      'AMTS-BL-003','OHC', 'STAFF_BEHAVIOUR',   5,
     'Staff at Old High Court were very helpful during platform change. '
     'Directed passengers clearly and politely.',
     'CLOSED', 72),

    ('Karan Joshi',      'AMTS-RL-002','MTS', 'CROWD_MANAGEMENT',  3,
     'Motera station during cricket match was very crowded. '
     'Need more crowd control staff during events.',
     'IN_REVIEW', 12),

    ('Bhavesh Kumar',    'AMTS-BL-001','NCR', 'MOBILE_APP',        5,
     'Ahmedabad Yatra app is very useful. '
     'Real-time train tracking and QR booking is seamless.',
     'CLOSED', 96),

    ('Anjali Mishra',    'AMTS-BL-001','SHP', 'ACCESSIBILITY',     4,
     'Lifts at Shahpur working properly. '
     'Good accessibility for wheelchair users.',
     'CLOSED', 60),

    ('Raj Solanki',      'AMTS-YL-001','GNL', 'PUNCTUALITY',       1,
     'Waited 45 minutes at GNLU due to derailment. '
     'No real-time updates on app. Staff had no information.',
     'IN_REVIEW', 4),

    ('Nisha Agrawal',    'AMTS-YL-001','MTS', 'TICKETING',         5,
     'Student monthly pass is very affordable. '
     'Saves lot of money for daily college commute. Thank you GMRC!',
     'CLOSED', 120),

    ('Diya Sharma',      'AMTS-BL-002','GUV', 'CLEANLINESS',       3,
     'Found some litter on seats and under benches. '
     'Housekeeping should check more frequently.',
     'RESOLVED', 48),

    ('James Wilson',     'AMTS-YL-002','MMD', 'PUNCTUALITY',       4,
     'Very impressed with Ahmedabad Metro overall. '
     'Clean, fast and affordable compared to other Indian cities.',
     'CLOSED', 168),

    ('Yuki Tanaka',      'AMTS-VL-001','GNL', 'MOBILE_APP',        4,
     'English language support in app is good. '
     'Maps and route planner are very clear and easy to use.',
     'CLOSED', 240),

    ('Ramanlal Trivedi', 'AMTS-RL-001','GDG', 'ACCESSIBILITY',     5,
     'Senior citizen concession fare is very helpful. '
     'Staff assist elderly passengers board and alight. Praiseworthy.',
     'CLOSED', 72),

    ('Meera Rana',       'AMTS-RL-001','OHC', 'ACCESSIBILITY',     4,
     'Wheelchair ramp at Old High Court is good. '
     'However ramp at Gandhigram station needs maintenance.',
     'IN_REVIEW', 24),

    ('Bhavesh Kumar',    'AMTS-BL-003','SPS', 'CROWD_MANAGEMENT',  2,
     'Evening trains are extremely crowded. '
     'Should increase frequency to every 5 minutes during peak hours.',
     'OPEN', 8),

    ('Anjali Mishra',    'AMTS-BL-001','KLP', 'SAFETY',            5,
     'CCTV cameras and security staff at Kalupur make me feel very safe. '
     'Good safety measures.',
     'CLOSED', 144),

    ('Aarav Shah',       'AMTS-YL-003','RDS', 'PUNCTUALITY',       3,
     'VIP movement caused 25 min delay. '
     'Metro service should not be disrupted for VIP movements.',
     'IN_REVIEW', 6),

    ('Sneha Desai',      'AMTS-BL-002','GKR', 'CLEANLINESS',       5,
     'Gurukul Road station is spotlessly clean. '
     'Best maintained station I have visited. Keep it up!',
     'CLOSED', 192),

    ('Kantibhai Shah',   'AMTS-RL-001','PAL', 'STAFF_BEHAVIOUR',   5,
     'Freedom fighter pass is honoured with great respect by staff. '
     'They assist me every single day. Very grateful.',
     'CLOSED', 336),

    ('Karan Joshi',      'AMTS-BL-004','AMR', 'SAFETY',            1,
     'Heard about the collision at Amraiwadi. Very scary. '
     'How did a maintenance vehicle end up on the active track? '
     'Need immediate safety improvements.',
     'IN_REVIEW', 2)
) AS v(pname, train_num, stn_code, category, rating,
       comment, status, submitted_ago)
JOIN  metro.PASSENGER      p   ON p.full_name     = v.pname
JOIN  metro.TRAIN          tr  ON tr.train_number = v.train_num
JOIN  metro.TRAIN_SCHEDULE ts  ON ts.train_id     = tr.train_id
                               AND ts.day_type    = 'WEEKDAY'
                               AND ts.is_deleted  = FALSE
JOIN  metro.STATION        s   ON s.station_code  = v.stn_code
LEFT JOIN metro.TICKET     t   ON t.passenger_id  = p.passenger_id
                               AND t.status NOT IN ('CANCELLED','EXPIRED')
                               AND t.is_deleted   = FALSE;

-- ================================================================
--  29. AUDIT_LOG  (sample audit trail entries)
-- ================================================================

INSERT INTO metro.AUDIT_LOG
    (schema_name, table_name, record_id, action,
     old_data, new_data, changed_fields,
     performed_by_emp_id, ip_address, session_id, performed_at)
SELECT
    'metro', v.table_name, v.record_id,
    v.action::metro.audit_action_t,
    v.old_data::JSONB,
    v.new_data::JSONB,
    v.changed_fields::TEXT[],
    emp.employee_id,
    v.ip_address::INET,
    v.session_id,
    NOW() - (v.ago_mins || ' minutes')::INTERVAL
FROM (VALUES
    ('TRAIN_SCHEDULE','1','UPDATE',
     '{"schedule_status":"ACTIVE"}',
     '{"schedule_status":"DELAYED","delay_reason":"Signal failure"}',
     '{schedule_status}','192.168.1.10','SESS-EMP002-001',125),

    ('TRAIN_SCHEDULE','5','UPDATE',
     '{"schedule_status":"ACTIVE"}',
     '{"schedule_status":"DELAYED","delay_reason":"Track obstruction"}',
     '{schedule_status}','192.168.1.10','SESS-EMP002-002',185),

    ('DRIVER','1','UPDATE',
     '{"salary":"52000.00"}',
     '{"salary":"55000.00"}',
     '{salary}','192.168.1.20','SESS-EMP010-001',2880),

    ('FARE_RULE','1','UPDATE',
     '{"normal_fare":"4.00"}',
     '{"normal_fare":"5.00"}',
     '{normal_fare,senior_fare,child_fare}',
     '192.168.1.20','SESS-EMP011-001',43200),

    ('STATION','7','UPDATE',
     '{"is_active":"true"}',
     '{"is_active":"false","closure_reason":"Emergency"}',
     '{is_active}','192.168.1.10','SESS-EMP002-003',120),

    ('TRAIN','4','UPDATE',
     '{"operational_status":"ON_TRACK"}',
     '{"operational_status":"CRASHED","is_on_rest":"true"}',
     '{operational_status,is_on_rest}',
     '192.168.1.10','SESS-EMP002-004',2880),

    ('TRAIN_INCIDENT','1','INSERT',
     NULL,
     '{"incident_type":"CRASH","severity_level":5}',
     NULL,'192.168.1.10','SESS-EMP002-004',2880),

    ('EMPLOYEE','4','UPDATE',
     '{"managed_station_id":"null"}',
     '{"managed_station_id":"7"}',
     '{managed_station_id}','192.168.1.20','SESS-EMP001-001',5760),

    ('FARE_RULE','5','UPDATE',
     '{"student_fare":"20.00"}',
     '{"student_fare":"20.00","effective_from":"2024-01-01"}',
     '{effective_from}','192.168.1.20','SESS-EMP011-002',43201),

    ('TRAIN_SCHEDULE','9','UPDATE',
     '{"schedule_status":"ACTIVE"}',
     '{"schedule_status":"DELAYED"}',
     '{schedule_status}','192.168.1.10','SESS-EMP002-005',30),

    ('STATION_CLOSURE','1','INSERT',
     NULL,
     '{"closure_type":"SCHEDULED_MAINTENANCE","station_id":"7"}',
     NULL,'192.168.1.10','SESS-EMP002-006',72*60),

    ('DRIVER_SCHEDULE_ASSIGNMENT','1','UPDATE',
     '{"role":"PRIMARY","driver_id":"3"}',
     '{"role":"PRIMARY","driver_id":"1"}',
     '{driver_id}','192.168.1.10','SESS-EMP002-007',60),

    ('SYSTEM_CONFIG','QR_VALIDITY_MINUTES','UPDATE',
     '{"config_value":"90"}',
     '{"config_value":"120"}',
     '{config_value}','192.168.1.15','SESS-EMP016-001',10080),

    ('PASSENGER','12','SOFT_DELETE',
     '{"is_active":"true","is_deleted":"false"}',
     '{"is_active":"false","is_deleted":"true"}',
     '{is_active,is_deleted}','192.168.1.10','SESS-EMP002-008',4320),

    ('EMPLOYEE','8','UPDATE',
     '{"salary":"62000.00"}',
     '{"salary":"65000.00"}',
     '{salary}','192.168.1.20','SESS-EMP010-002',1440)
) AS v(table_name, record_id, action,
       old_data, new_data, changed_fields,
       ip_address, session_id, ago_mins)
CROSS JOIN (
    SELECT employee_id FROM metro.EMPLOYEE WHERE employee_code = 'EMP001'
) emp;

-- ================================================================
--  FINAL VERIFICATION
-- ================================================================

DO $$
DECLARE
    v_lines      INT; v_stations    INT; v_platforms   INT;
    v_tracks     INT; v_trains      INT; v_schedules   INT;
    v_stops      INT; v_fares       INT; v_passengers  INT;
    v_tickets    INT; v_payments    INT; v_passes      INT;
    v_drivers    INT; v_shifts      INT; v_employees   INT;
    v_delays     INT; v_reschedules INT; v_closures    INT;
    v_incidents  INT; v_maintenance INT; v_tracking    INT;
    v_alerts     INT; v_apm         INT; v_feedback    INT;
    v_audit      INT; v_dsa         INT;
BEGIN
    SELECT COUNT(*) INTO v_lines        FROM metro.LINE;
    SELECT COUNT(*) INTO v_stations     FROM metro.STATION;
    SELECT COUNT(*) INTO v_platforms    FROM metro.PLATFORM;
    SELECT COUNT(*) INTO v_tracks       FROM metro.TRACK;
    SELECT COUNT(*) INTO v_trains       FROM metro.TRAIN;
    SELECT COUNT(*) INTO v_schedules    FROM metro.TRAIN_SCHEDULE;
    SELECT COUNT(*) INTO v_stops        FROM metro.TRAIN_STOP;
    SELECT COUNT(*) INTO v_fares        FROM metro.FARE_RULE;
    SELECT COUNT(*) INTO v_passengers   FROM metro.PASSENGER;
    SELECT COUNT(*) INTO v_tickets      FROM metro.TICKET;
    SELECT COUNT(*) INTO v_payments     FROM metro.PAYMENT;
    SELECT COUNT(*) INTO v_passes       FROM metro.TRAVEL_PASS;
    SELECT COUNT(*) INTO v_drivers      FROM metro.DRIVER;
    SELECT COUNT(*) INTO v_shifts       FROM metro.DRIVER_SHIFT;
    SELECT COUNT(*) INTO v_employees    FROM metro.EMPLOYEE;
    SELECT COUNT(*) INTO v_delays       FROM metro.DELAY_EVENT;
    SELECT COUNT(*) INTO v_reschedules  FROM metro.RESCHEDULE_LOG;
    SELECT COUNT(*) INTO v_closures     FROM metro.STATION_CLOSURE;
    SELECT COUNT(*) INTO v_incidents    FROM metro.TRAIN_INCIDENT;
    SELECT COUNT(*) INTO v_maintenance  FROM metro.MAINTENANCE_LOG;
    SELECT COUNT(*) INTO v_tracking     FROM metro.LIVE_TRACKING;
    SELECT COUNT(*) INTO v_alerts       FROM metro.ALERT;
    SELECT COUNT(*) INTO v_apm          FROM metro.ALERT_PASSENGER_MAP;
    SELECT COUNT(*) INTO v_feedback     FROM metro.FEEDBACK;
    SELECT COUNT(*) INTO v_audit        FROM metro.AUDIT_LOG;
    SELECT COUNT(*) INTO v_dsa          FROM metro.DRIVER_SCHEDULE_ASSIGNMENT;

    RAISE NOTICE '============================================================';
    RAISE NOTICE '  AHMEDABAD METRO — DATA INSERTION COMPLETE';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '  LINE                    : %', v_lines;
    RAISE NOTICE '  STATION                 : %', v_stations;
    RAISE NOTICE '  PLATFORM                : %', v_platforms;
    RAISE NOTICE '  TRACK                   : %', v_tracks;
    RAISE NOTICE '  TRAIN                   : %', v_trains;
    RAISE NOTICE '  TRAIN_SCHEDULE          : %', v_schedules;
    RAISE NOTICE '  TRAIN_STOP              : %', v_stops;
    RAISE NOTICE '  FARE_RULE               : %', v_fares;
    RAISE NOTICE '  PASSENGER               : %', v_passengers;
    RAISE NOTICE '  TICKET                  : %', v_tickets;
    RAISE NOTICE '  PAYMENT                 : %', v_payments;
    RAISE NOTICE '  TRAVEL_PASS             : %', v_passes;
    RAISE NOTICE '  DRIVER                  : %', v_drivers;
    RAISE NOTICE '  DRIVER_SHIFT            : %', v_shifts;
    RAISE NOTICE '  DRIVER_SCHEDULE_ASSIGN  : %', v_dsa;
    RAISE NOTICE '  EMPLOYEE                : %', v_employees;
    RAISE NOTICE '  DELAY_EVENT             : %', v_delays;
    RAISE NOTICE '  RESCHEDULE_LOG          : %', v_reschedules;
    RAISE NOTICE '  STATION_CLOSURE         : %', v_closures;
    RAISE NOTICE '  TRAIN_INCIDENT          : %', v_incidents;
    RAISE NOTICE '  MAINTENANCE_LOG         : %', v_maintenance;
    RAISE NOTICE '  LIVE_TRACKING           : %', v_tracking;
    RAISE NOTICE '  ALERT                   : %', v_alerts;
    RAISE NOTICE '  ALERT_PASSENGER_MAP     : %', v_apm;
    RAISE NOTICE '  FEEDBACK                : %', v_feedback;
    RAISE NOTICE '  AUDIT_LOG               : %', v_audit;
    RAISE NOTICE '============================================================';
    RAISE NOTICE '  All dummy data inserted successfully.';
    RAISE NOTICE '  Ready for queries and app integration.';
    RAISE NOTICE '============================================================';
END $$;