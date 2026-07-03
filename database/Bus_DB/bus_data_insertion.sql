-- ================================================================
--  AHMEDABAD YATRA — BUS SYSTEM DUMMY DATA
--  Part 1 of 4: BUS_OPERATOR → BUS_STOP → BUS_ROUTE
--               → ROUTE_STOP → BUS → BUS_FARE_RULE
--  Real Data: AMTS, BRTS, GSRTC routes in Ahmedabad–Gandhinagar
-- ================================================================

SET search_path TO bus, metro, public;

-- ================================================================
--  1. BUS_OPERATOR  (3 real operators)
-- ================================================================

INSERT INTO bus.BUS_OPERATOR
    (operator_code, operator_name, operator_type, city,
     phone, email, website, address, is_active)
VALUES
('AMTS',
 'Ahmedabad Municipal Transport Service',
 'AMTS', 'Ahmedabad',
 '07926576286', 'info@amts.co.in', 'https://www.amts.co.in',
 'Lal Darwaja Bus Station, Ahmedabad - 380001', TRUE),

('BRTS',
 'Ahmedabad BRTS (Janmarg)',
 'BRTS', 'Ahmedabad',
 '07922868800', 'info@janmarg.in', 'https://www.janmarg.in',
 'Janmarg BRTS Office, Kankaria, Ahmedabad - 380008', TRUE),

('GSRTC',
 'Gujarat State Road Transport Corporation',
 'GSRTC', 'Ahmedabad',
 '07922861171', 'info@gsrtc.in', 'https://www.gsrtc.in',
 'Geeta Mandir Bus Stand, Ahmedabad - 380022', TRUE);

-- ================================================================
--  2. BUS_STOP  (50 real stops across Ahmedabad & Gandhinagar)
--  Real GPS coordinates from Google Maps / OpenStreetMap
-- ================================================================

INSERT INTO bus.BUS_STOP
    (stop_code, stop_name, stop_type, latitude, longitude,
     address, city, zone_no,
     has_shelter, has_display_board, has_ticket_counter,
     wheelchair_access, is_active)
VALUES
-- ── BRTS Stations (dedicated corridor) ──────────────────────────
('BRTS-RTO',   'RTO Circle BRTS',         'BRTS_STATION', 23.0209, 72.5071,
 'RTO Circle, Sarkhej-Gandhinagar Hwy',    'Ahmedabad', 2, TRUE, TRUE, TRUE, TRUE, TRUE),

('BRTS-ISKON', 'ISKON BRTS',              'BRTS_STATION', 23.0300, 72.5071,
 'ISKON Temple Road, S.G. Highway',        'Ahmedabad', 2, TRUE, TRUE, TRUE, TRUE, TRUE),

('BRTS-PKWY',  'Pakwan Cross Road BRTS',  'BRTS_STATION', 23.0400, 72.5068,
 'Pakwan Crossroads, S.G. Highway',        'Ahmedabad', 2, TRUE, TRUE, FALSE, TRUE, TRUE),

('BRTS-THLT',  'Thaltej BRTS',            'BRTS_STATION', 23.0519, 72.5071,
 'Thaltej, S.G. Highway',                  'Ahmedabad', 2, TRUE, TRUE, FALSE, TRUE, TRUE),

('BRTS-AHPURA','Ahmedabad University BRTS','BRTS_STATION',23.0590, 72.5310,
 'Ahmedabad University, Navrangpura',      'Ahmedabad', 2, TRUE, TRUE, FALSE, TRUE, TRUE),

('BRTS-NAVM',  'Navrangpura BRTS',        'BRTS_STATION', 23.0620, 72.5679,
 'Navrangpura, C.G. Road',                 'Ahmedabad', 2, TRUE, TRUE, TRUE, TRUE, TRUE),

('BRTS-GITAM', 'Gitam Bus Stand BRTS',    'BRTS_STATION', 23.0298, 72.5556,
 'Gandhigram, Ashram Road',                'Ahmedabad', 2, TRUE, TRUE, FALSE, TRUE, TRUE),

('BRTS-VASNA', 'Vasna BRTS',              'BRTS_STATION', 22.9950, 72.5530,
 'Vasna Cross Road, Vasna',                'Ahmedabad', 1, TRUE, TRUE, FALSE, FALSE, TRUE),

-- ── AMTS City Bus Stops ──────────────────────────────────────────
('AMTS-LDWJ',  'Lal Darwaja Bus Stand',   'TERMINUS',     23.0248, 72.5844,
 'Lal Darwaja, Old City',                  'Ahmedabad', 2, TRUE, TRUE, TRUE, TRUE, TRUE),

('AMTS-KALP',  'Kalupur Bus Stand',       'TERMINUS',     23.0278, 72.5872,
 'Kalupur, Near Railway Station',          'Ahmedabad', 2, TRUE, TRUE, TRUE, TRUE, TRUE),

('AMTS-GMND',  'Geeta Mandir Bus Stand',  'TERMINUS',     23.0371, 72.6134,
 'Geeta Mandir, Eastern Expressway',       'Ahmedabad', 2, TRUE, TRUE, TRUE, TRUE, TRUE),

('AMTS-STDT',  'Stadium Cross Road',      'REGULAR',      23.0502, 72.5741,
 'Stadium Circle, Navrangpura',            'Ahmedabad', 2, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-IIFM',  'IIM Ahmedabad',           'REGULAR',      23.0317, 72.5272,
 'IIM Campus, Vastrapur',                  'Ahmedabad', 2, TRUE, FALSE, FALSE, TRUE, TRUE),

('AMTS-VSTR',  'Vastrapur Lake',          'REGULAR',      23.0421, 72.5300,
 'Vastrapur Lake, Prahlad Nagar',          'Ahmedabad', 2, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-PRLH',  'Prahlad Nagar',           'REGULAR',      23.0299, 72.5100,
 'Prahlad Nagar Garden, S.G. Highway',     'Ahmedabad', 2, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-BODKD', 'Bodakdev',               'REGULAR',      23.0519, 72.5021,
 'Bodakdev, S.G. Highway',                 'Ahmedabad', 2, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-SGHWY', 'S.G. Highway APMC',      'REGULAR',      23.0012, 72.5710,
 'APMC, Vasna, S.G. Highway',              'Ahmedabad', 1, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-MANIK', 'Maninagar Cross Road',   'REGULAR',      22.9985, 72.6072,
 'Maninagar, Ahmedabad',                   'Ahmedabad', 1, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-NROL',  'Narol Circle',           'REGULAR',      22.9680, 72.6298,
 'Narol, South Ahmedabad',                 'Ahmedabad', 1, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-NIRNA', 'Nirnaynagar',            'REGULAR',      23.0931, 72.5471,
 'Nirnaynagar Society, Chandkheda',        'Ahmedabad', 3, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-CHANDH','Chandkheda',             'REGULAR',      23.1071, 72.5751,
 'Chandkheda, Gandhinagar Highway',        'Ahmedabad', 3, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-KOLWAD','Kolwada',               'REGULAR',      23.0729, 72.6110,
 'Kolwada, Naroda Road',                   'Ahmedabad', 3, FALSE, FALSE, FALSE, FALSE, TRUE),

('AMTS-KKNR',  'Kankaria Lake',         'REGULAR',      23.0012, 72.5947,
 'Kankaria Lake, Maninagar',               'Ahmedabad', 1, TRUE, FALSE, FALSE, TRUE, TRUE),

('AMTS-ASHMD', 'Ashram Road',           'REGULAR',      23.0298, 72.5637,
 'Ashram Road, Near Gandhi Ashram',        'Ahmedabad', 2, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-DRIVE', 'Drive-In Road',         'REGULAR',      23.0847, 72.5498,
 'Drive-In Road, Thaltej',                 'Ahmedabad', 3, TRUE, FALSE, FALSE, FALSE, TRUE),

-- ── GSRTC Intercity Stops ────────────────────────────────────────
('GSRTC-AHBS', 'Ahmedabad GSRTC Bus Stand','TERMINUS',   23.0371, 72.6134,
 'Geeta Mandir Bus Stand, Ahmedabad',      'Ahmedabad', 2, TRUE, TRUE, TRUE, TRUE, TRUE),

('GSRTC-STBS', 'Sector-10 Bus Stand GN',  'TERMINUS',   23.2019, 72.6819,
 'Sector-10, Gandhinagar',                 'Gandhinagar',4, TRUE, TRUE, TRUE, TRUE, TRUE),

('GSRTC-MMBS', 'Mahatma Mandir Bus Stand','TERMINUS',   23.2572, 72.4608,
 'Mahatma Mandir, Gandhinagar',            'Gandhinagar',4, TRUE, TRUE, TRUE, TRUE, TRUE),

('GSRTC-INF',  'Infocity Bus Stop',       'REGULAR',    23.1231, 72.5389,
 'Infocity, Gandhinagar',                  'Gandhinagar',3, TRUE, TRUE, FALSE, TRUE, TRUE),

('GSRTC-APTS', 'Akshardham Temple Stop',  'REGULAR',    23.2161, 72.5581,
 'Akshardham Temple Road, Gandhinagar',    'Gandhinagar',4, TRUE, FALSE, FALSE, FALSE, TRUE),

-- ── Near Metro Interchange Points ────────────────────────────────
('BUS-OHC',    'Old High Court Bus Stop', 'INTERCHANGE', 23.0452, 72.5762,
 'Near Old High Court Metro, Ahmedabad',   'Ahmedabad', 2, TRUE, TRUE, FALSE, TRUE, TRUE),

('BUS-KALPB',  'Kalupur Bus Stop',        'INTERCHANGE', 23.0272, 72.5881,
 'Near Kalupur Metro Station',             'Ahmedabad', 2, TRUE, FALSE, FALSE, TRUE, TRUE),

('BUS-MTSB',   'Motera Stadium Bus Stop', 'INTERCHANGE', 23.1045, 72.5465,
 'Near Motera Metro Station',              'Ahmedabad', 3, TRUE, TRUE, FALSE, TRUE, TRUE),

('BUS-GNLU',   'GNLU Bus Stop',           'INTERCHANGE', 23.1492, 72.5258,
 'Near GNLU Metro Station, Gandhinagar',   'Gandhinagar',3, TRUE, TRUE, FALSE, TRUE, TRUE),

('BUS-MMD',    'Mahatma Mandir Bus Stop', 'INTERCHANGE', 23.2575, 72.4611,
 'Near Mahatma Mandir Metro Station',      'Gandhinagar',4, TRUE, TRUE, TRUE, TRUE, TRUE),

-- ── Additional City Stops ────────────────────────────────────────
('AMTS-PALDI', 'Paldi Cross Road',        'REGULAR',    23.0212, 72.5541,
 'Paldi, Ahmedabad',                       'Ahmedabad', 2, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-ELLBR', 'Ellis Bridge',            'REGULAR',    23.0302, 72.5779,
 'Ellis Bridge, Ahmedabad',                'Ahmedabad', 2, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-SABAR', 'Sabarmati Bus Stop',      'REGULAR',    23.0942, 72.5521,
 'Sabarmati, Ahmedabad',                   'Ahmedabad', 3, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-RANIP', 'Ranip',                   'REGULAR',    23.0841, 72.5556,
 'Ranip Cross Road, Ahmedabad',            'Ahmedabad', 3, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-VZPUR', 'Vijay Cross Road',        'REGULAR',    23.0618, 72.5625,
 'Vijay Cross Road, Navrangpura',          'Ahmedabad', 2, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-USMNP', 'Usmanpura',               'REGULAR',    23.0534, 72.5668,
 'Usmanpura, Ashram Road',                 'Ahmedabad', 2, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-ANDHD', 'Andheria Road',           'REGULAR',    23.0041, 72.6008,
 'Andheria, Vatva Area',                   'Ahmedabad', 1, FALSE, FALSE, FALSE, FALSE, TRUE),

-- ── Gandhinagar Stops ────────────────────────────────────────────
('GN-SC5',     'Sector-5 Gandhinagar',    'REGULAR',    23.2163, 72.6849,
 'Sector-5, Gandhinagar',                  'Gandhinagar',4, TRUE, FALSE, FALSE, FALSE, TRUE),

('GN-SC11',    'Sector-11 Gandhinagar',   'REGULAR',    23.2071, 72.6754,
 'Sector-11, Gandhinagar',                 'Gandhinagar',4, TRUE, FALSE, FALSE, FALSE, TRUE),

('GN-SC21',    'Sector-21 Gandhinagar',   'REGULAR',    23.2289, 72.6622,
 'Sector-21 Circle, Gandhinagar',          'Gandhinagar',4, TRUE, FALSE, FALSE, FALSE, TRUE),

('GN-GIFT',    'GIFT City Bus Stop',      'REGULAR',    23.1683, 72.6712,
 'GIFT City, Gandhinagar',                 'Gandhinagar',3, TRUE, TRUE, FALSE, TRUE, TRUE),

('GN-PDPU',    'PDPU Campus',             'REGULAR',    23.1621, 72.6641,
 'PDPU Campus, GIFT City Road',            'Gandhinagar',3, TRUE, FALSE, FALSE, FALSE, TRUE),

('GN-SACHLYA', 'Sachivalaya',             'REGULAR',    23.2054, 72.6812,
 'Secretariat, Gandhinagar',               'Gandhinagar',4, TRUE, TRUE, FALSE, FALSE, TRUE),

('GN-AKHRDM',  'Akshardham Gandhinagar',  'REGULAR',    23.2170, 72.5587,
 'Akshardham Temple, Gandhinagar',         'Gandhinagar',4, TRUE, FALSE, FALSE, FALSE, TRUE),

('AMTS-VSTRL', 'Vastral',                 'REGULAR',    23.0065, 72.6312,
 'Vastral, East Ahmedabad',                'Ahmedabad', 1, TRUE, FALSE, FALSE, FALSE, TRUE);

-- ================================================================
--  3. BUS_ROUTE  (12 real routes — AMTS, BRTS, GSRTC)
-- ================================================================

INSERT INTO bus.BUS_ROUTE
    (operator_id, route_number, route_name, route_type,
     total_length_km, total_stops,
     origin_stop_name, destination_stop_name,
     color_code, frequency_peak_min, frequency_offpeak_min,
     first_departure, last_departure, description, is_active)
SELECT
    op.operator_id,
    v.route_no, v.route_name, v.route_type::bus.route_type_t,
    v.length_km, v.stops,
    v.origin, v.destination,
    v.color, v.freq_peak, v.freq_offpeak,
    v.first_dep::TIME, v.last_dep::TIME,
    v.description, TRUE
FROM (VALUES
    -- AMTS City Routes
    ('AMTS', '37',    'Lal Darwaja – Narol',
     'CITY',   28.5, 24, 'Lal Darwaja Bus Stand', 'Narol Circle',
     '#FF8C00', 15, 25, '05:30', '23:00',
     'Major city route connecting old city to southern Ahmedabad via Maninagar and Kankaria'),

    ('AMTS', '105',   'Geeta Mandir – Thaltej via Drive-In',
     'CITY',   22.3, 18, 'Geeta Mandir Bus Stand', 'Thaltej BRTS',
     '#FF8C00', 20, 30, '06:00', '22:30',
     'Connects eastern terminus to western S.G. Highway via Drive-In Road'),

    ('AMTS', '52',    'Lal Darwaja – Chandkheda',
     'CITY',   18.7, 16, 'Lal Darwaja Bus Stand', 'Chandkheda',
     '#FF8C00', 15, 20, '05:45', '22:00',
     'North corridor connecting old city to Chandkheda suburb'),

    ('AMTS', '81',    'Kalupur – ISKON',
     'CITY',   14.2, 12, 'Kalupur Bus Stand', 'ISKON BRTS',
     '#FF8C00', 12, 20, '06:00', '22:00',
     'West corridor from railway station to S.G. Highway via Navrangpura'),

    ('AMTS', 'F1',    'Metro Feeder – Vastral to Vastral Gam Metro',
     'FEEDER',  4.2,  6, 'Vastral', 'Vastral Gam Metro',
     '#FFA500', 10, 15, '05:45', '23:30',
     'Metro feeder bus connecting Vastral area to Blue Line metro station'),

    ('AMTS', 'F2',    'Metro Feeder – Motera to Motera Metro',
     'FEEDER',  3.5,  5, 'Ranip', 'Motera Stadium Bus Stop',
     '#FFA500', 10, 15, '05:45', '23:30',
     'Metro feeder bus connecting Ranip and Sabarmati to Motera Metro'),

    -- BRTS Routes
    ('BRTS', 'BRTS-1','Vasna – Thaltej BRTS Corridor',
     'BRTS',   18.5,  8, 'Vasna BRTS', 'Thaltej BRTS',
     '#00AA00', 8, 12, '06:00', '22:00',
     'Main BRTS corridor along S.G. Highway. Dedicated BRT lane. AC buses.'),

    ('BRTS', 'BRTS-2','Paldi – Naroda BRTS Corridor',
     'BRTS',   22.0, 10, 'Gitam Bus Stand BRTS', 'Navrangpura BRTS',
     '#00AA00', 10, 15, '06:00', '22:00',
     'East-West BRTS corridor via Ashram Road and C.G. Road'),

    -- GSRTC Intercity Routes
    ('GSRTC','GN-001','Ahmedabad – Gandhinagar Express',
     'INTERCITY',33.0, 8, 'Ahmedabad GSRTC Bus Stand', 'Sector-10 Bus Stand GN',
     '#CC0000', 20, 30, '05:00', '23:00',
     'Direct express service Ahmedabad to Gandhinagar. Non-stop after Nirnaynagar.'),

    ('GSRTC','GN-002','Ahmedabad – Mahatma Mandir via Infocity',
     'INTERCITY',36.5, 10, 'Ahmedabad GSRTC Bus Stand', 'Mahatma Mandir Bus Stand',
     '#CC0000', 30, 45, '06:00', '22:00',
     'Service to Mahatma Mandir via Infocity IT Park. Serves tech employees.'),

    ('GSRTC','GN-003','Ahmedabad – GIFT City Express',
     'INTERCITY',34.2,  7, 'Ahmedabad GSRTC Bus Stand', 'GIFT City Bus Stop',
     '#CC0000', 30, 60, '07:00', '21:00',
     'Express service to GIFT City financial hub. Limited stops.'),

    ('GSRTC','GN-NIGHT','Ahmedabad – Gandhinagar Night Service',
     'NIGHT',   33.0,  6, 'Ahmedabad GSRTC Bus Stand', 'Sector-10 Bus Stand GN',
     '#330066', 60, 90, '22:00', '05:00',
     'Night service for late workers and early travelers. Reduced stops.')

) AS v(op_code, route_no, route_name, route_type,
       length_km, stops, origin, destination,
       color, freq_peak, freq_offpeak, first_dep, last_dep, description)
JOIN bus.BUS_OPERATOR op ON op.operator_code = v.op_code;

-- ================================================================
--  4. ROUTE_STOP  (real stop sequences for each route)
-- ================================================================

-- Route 37: Lal Darwaja → Narol
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('AMTS-LDWJ',1, 0.00,TRUE),('AMTS-ASHMD',2, 1.80,FALSE),
    ('AMTS-ELLBR',3,3.10,FALSE),('AMTS-PALDI',4,5.20,FALSE),
    ('AMTS-SGHWY',5,7.90,FALSE),('AMTS-KKNR', 6,10.40,FALSE),
    ('AMTS-MANIK',7,13.80,FALSE),('AMTS-ANDHD',8,17.20,FALSE),
    ('AMTS-NROL', 9,28.50,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = '37' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='AMTS');

-- Route 105: Geeta Mandir → Thaltej
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('AMTS-GMND',1,0.00,TRUE),('AMTS-KOLWAD',2,3.20,FALSE),
    ('AMTS-STDT', 3,6.10,FALSE),('AMTS-VZPUR', 4,8.40,FALSE),
    ('AMTS-USMNP',5,10.20,FALSE),('BRTS-NAVM',  6,12.00,FALSE),
    ('AMTS-DRIVE',7,17.30,FALSE),('BRTS-THLT', 8,22.30,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = '105' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='AMTS');

-- Route 52: Lal Darwaja → Chandkheda
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('AMTS-LDWJ',1,0.00,TRUE),('AMTS-KALP', 2,0.60,FALSE),
    ('AMTS-USMNP',3,4.20,FALSE),('AMTS-VZPUR',4,6.10,FALSE),
    ('AMTS-STDT', 5,7.40,FALSE),('AMTS-SABAR',6,11.20,FALSE),
    ('AMTS-RANIP',7,14.10,FALSE),('AMTS-NIRNA',8,16.50,FALSE),
    ('AMTS-CHANDH',9,18.70,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = '52' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='AMTS');

-- Route 81: Kalupur → ISKON
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('AMTS-KALP',1,0.00,TRUE),('AMTS-ELLBR',2,2.10,FALSE),
    ('AMTS-ASHMD',3,3.40,FALSE),('BRTS-GITAM',4,4.80,FALSE),
    ('AMTS-IIFM', 5,7.60,FALSE),('AMTS-VSTR', 6,9.10,FALSE),
    ('AMTS-PRLH', 7,11.30,FALSE),('BRTS-THLT', 8,13.20,FALSE),
    ('BRTS-ISKON',9,14.20,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = '81' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='AMTS');

-- Feeder F1: Vastral → Vastral Gam Metro
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('AMTS-VSTRL',1,0.00,TRUE),
    ('AMTS-ANDHD',2,2.10,FALSE),
    ('BUS-KALPB', 3,4.20,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = 'F1' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='AMTS');

-- Feeder F2: Ranip → Motera Metro
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('AMTS-RANIP',1,0.00,TRUE),
    ('AMTS-SABAR',2,1.50,FALSE),
    ('BUS-MTSB',  3,3.50,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = 'F2' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='AMTS');

-- BRTS-1: Vasna → Thaltej
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('BRTS-VASNA',1,0.00,TRUE),('BRTS-RTO',  2,3.20,FALSE),
    ('BRTS-ISKON',3,6.90,FALSE),('BRTS-PKWY', 4,10.10,FALSE),
    ('BRTS-THLT', 5,13.20,FALSE),('BRTS-AHPURA',6,15.40,FALSE),
    ('BRTS-NAVM', 7,17.50,FALSE),('BRTS-GITAM',8,18.50,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = 'BRTS-1' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='BRTS');

-- BRTS-2: Gitam → Navrangpura
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('BRTS-GITAM',1,0.00,TRUE),('BUS-OHC',  2,3.10,FALSE),
    ('AMTS-ELLBR',3,5.20,FALSE),('AMTS-STDT',4,8.40,FALSE),
    ('AMTS-VZPUR',5,12.10,FALSE),('AMTS-USMNP',6,14.80,FALSE),
    ('BRTS-NAVM', 7,19.20,FALSE),('BRTS-AHPURA',8,22.00,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = 'BRTS-2' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='BRTS');

-- GSRTC GN-001: Ahmedabad → Gandhinagar Express
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('GSRTC-AHBS',1,0.00,TRUE),('AMTS-CHANDH',2,8.40,FALSE),
    ('AMTS-NIRNA', 3,11.60,FALSE),('BUS-MTSB',4,16.20,FALSE),
    ('GSRTC-INF',  5,22.80,FALSE),('GN-SC11',  6,27.50,FALSE),
    ('GN-SACHLYA', 7,30.10,FALSE),('GSRTC-STBS',8,33.00,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = 'GN-001' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='GSRTC');

-- GSRTC GN-002: Ahmedabad → Mahatma Mandir via Infocity
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('GSRTC-AHBS',1,0.00,TRUE),('AMTS-CHANDH',2,8.40,FALSE),
    ('BUS-MTSB',  3,14.20,FALSE),('BUS-GNLU',  4,22.10,FALSE),
    ('GSRTC-INF', 5,24.80,FALSE),('GN-PDPU',   6,28.10,FALSE),
    ('GN-GIFT',   7,30.40,FALSE),('GSRTC-APTS',8,33.20,FALSE),
    ('BUS-MMD',   9,35.10,FALSE),('GSRTC-MMBS',10,36.50,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = 'GN-002' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='GSRTC');

-- GSRTC GN-003: Ahmedabad → GIFT City
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('GSRTC-AHBS',1,0.00,TRUE),('BUS-MTSB',  2,13.90,FALSE),
    ('BUS-GNLU',  3,21.80,FALSE),('GN-PDPU',  4,27.90,FALSE),
    ('GN-GIFT',   5,34.20,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = 'GN-003' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='GSRTC');

-- GSRTC Night service
INSERT INTO bus.ROUTE_STOP (route_id, stop_id, sequence_no, dist_from_start_km, is_terminal)
SELECT r.route_id, s.stop_id, v.seq, v.dist, v.terminal
FROM bus.BUS_ROUTE r
CROSS JOIN (VALUES
    ('GSRTC-AHBS',1,0.00,TRUE),('BUS-MTSB',2,13.90,FALSE),
    ('GSRTC-INF', 3,22.50,FALSE),('GN-SC11',4,27.80,FALSE),
    ('GSRTC-STBS',5,33.00,TRUE)
) AS v(code, seq, dist, terminal)
JOIN bus.BUS_STOP s ON s.stop_code = v.code
WHERE r.route_number = 'GN-NIGHT' AND r.operator_id = (
    SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code='GSRTC');

-- ================================================================
--  5. BUS  (20 buses — real Gujarat RTO registration format)
-- ================================================================

INSERT INTO bus.BUS
    (operator_id, route_id, bus_number, bus_type,
     total_capacity, seating_capacity, standing_capacity,
     manufacturer, manufacture_year, registration_no,
     commission_date, is_ac, is_electric,
     operational_status, current_crowd_count)
SELECT
    op.operator_id,
    r.route_id,
    v.bus_num,
    v.bus_type::bus.bus_type_t,
    v.total_cap, v.seat_cap, v.total_cap - v.seat_cap,
    v.manufacturer, v.mfr_year, v.reg_no,
    v.commission_dt::DATE,
    v.is_ac, v.is_electric,
    v.status::bus.bus_status_t,
    v.crowd
FROM (VALUES
    -- AMTS buses
    ('AMTS','37',   'AMTS-001','NON_AC_SINGLE_DECK',80,40,'Tata Motors',   2019,'GJ01BX1001','2019-06-01',FALSE,FALSE,'ON_ROUTE',  32),
    ('AMTS','37',   'AMTS-002','NON_AC_SINGLE_DECK',80,40,'Tata Motors',   2019,'GJ01BX1002','2019-06-01',FALSE,FALSE,'ON_ROUTE',  45),
    ('AMTS','105',  'AMTS-003','NON_AC_SINGLE_DECK',80,40,'Ashok Leyland', 2020,'GJ01BX1003','2020-03-15',FALSE,FALSE,'ON_ROUTE',  28),
    ('AMTS','105',  'AMTS-004','NON_AC_SINGLE_DECK',80,40,'Ashok Leyland', 2020,'GJ01BX1004','2020-03-15',FALSE,FALSE,'AT_DEPOT',   0),
    ('AMTS','52',   'AMTS-005','NON_AC_SINGLE_DECK',80,40,'Tata Motors',   2021,'GJ01BX1005','2021-01-10',FALSE,FALSE,'ON_ROUTE',  55),
    ('AMTS','52',   'AMTS-006','NON_AC_SINGLE_DECK',80,40,'Tata Motors',   2021,'GJ01BX1006','2021-01-10',FALSE,FALSE,'ON_ROUTE',  38),
    ('AMTS','81',   'AMTS-007','AC_SINGLE_DECK',    60,36,'Volvo Buses',   2022,'GJ01BX1007','2022-04-01',TRUE, FALSE,'ON_ROUTE',  22),
    ('AMTS','81',   'AMTS-008','AC_SINGLE_DECK',    60,36,'Volvo Buses',   2022,'GJ01BX1008','2022-04-01',TRUE, FALSE,'AT_DEPOT',   0),
    ('AMTS','F1',   'AMTS-009','ELECTRIC_BUS',      60,32,'TATA EV',       2023,'GJ01BY2001','2023-09-15',TRUE, TRUE, 'ON_ROUTE',  18),
    ('AMTS','F2',   'AMTS-010','ELECTRIC_BUS',      60,32,'TATA EV',       2023,'GJ01BY2002','2023-09-15',TRUE, TRUE, 'ON_ROUTE',  24),
    -- BRTS buses
    ('BRTS','BRTS-1','BRTS-001','BRTS_BRT',         80,40,'Tata Starbus',  2018,'GJ01BW3001','2018-11-01',TRUE, FALSE,'ON_ROUTE',  62),
    ('BRTS','BRTS-1','BRTS-002','BRTS_BRT',         80,40,'Tata Starbus',  2018,'GJ01BW3002','2018-11-01',TRUE, FALSE,'ON_ROUTE',  48),
    ('BRTS','BRTS-1','BRTS-003','BRTS_BRT',         80,40,'Tata Starbus',  2019,'GJ01BW3003','2019-03-01',TRUE, FALSE,'MAINTENANCE', 0),
    ('BRTS','BRTS-2','BRTS-004','BRTS_BRT',         80,40,'Tata Starbus',  2019,'GJ01BW3004','2019-03-01',TRUE, FALSE,'ON_ROUTE',  71),
    ('BRTS','BRTS-2','BRTS-005','BRTS_BRT',         80,40,'Tata Starbus',  2020,'GJ01BW3005','2020-01-15',TRUE, FALSE,'ON_ROUTE',  35),
    -- GSRTC intercity
    ('GSRTC','GN-001','GSRTC-001','AC_SINGLE_DECK', 50,50,'Volvo 9400',    2020,'GJ18AZ5001','2020-07-01',TRUE, FALSE,'ON_ROUTE',  31),
    ('GSRTC','GN-001','GSRTC-002','AC_SINGLE_DECK', 50,50,'Volvo 9400',    2021,'GJ18AZ5002','2021-02-01',TRUE, FALSE,'ON_ROUTE',  44),
    ('GSRTC','GN-002','GSRTC-003','AC_SINGLE_DECK', 50,50,'Scania Metrolink',2021,'GJ18AZ5003','2021-08-01',TRUE,FALSE,'ON_ROUTE', 19),
    ('GSRTC','GN-003','GSRTC-004','AC_SINGLE_DECK', 45,45,'Volvo 9400',    2022,'GJ18AZ5004','2022-01-01',TRUE, FALSE,'AT_DEPOT',   0),
    ('GSRTC','GN-NIGHT','GSRTC-005','AC_SINGLE_DECK',50,50,'Ashok Leyland',2019,'GJ18AZ5005','2019-06-01',TRUE,FALSE,'ON_ROUTE',   8)
) AS v(op_code, route_no, bus_num, bus_type, total_cap, seat_cap,
       manufacturer, mfr_year, reg_no, commission_dt,
       is_ac, is_electric, status, crowd)
JOIN bus.BUS_OPERATOR op ON op.operator_code = v.op_code
JOIN bus.BUS_ROUTE    r  ON r.route_number   = v.route_no
                         AND r.operator_id    = op.operator_id;

-- ================================================================
--  6. BUS_FARE_RULE  (fare slabs per operator)
-- ================================================================

-- AMTS City Bus Fares
INSERT INTO bus.BUS_FARE_RULE
    (operator_id, min_distance_km, max_distance_km,
     normal_fare, senior_fare, child_fare, student_fare, disabled_fare,
     effective_from, is_active)
SELECT op.operator_id, v.min_d, v.max_d,
       v.norm, v.senior, v.child, v.student, v.disabled,
       '2024-01-01'::DATE, TRUE
FROM (VALUES
    ( 0.00,  5.00,  8.00, 4.00, 4.00, 6.40, 4.00),
    ( 5.01, 10.00, 10.00, 5.00, 5.00, 8.00, 5.00),
    (10.01, 15.00, 12.00, 6.00, 6.00, 9.60, 6.00),
    (15.01, 20.00, 15.00, 7.50, 7.50,12.00, 7.50),
    (20.01, 30.00, 18.00, 9.00, 9.00,14.40, 9.00)
) AS v(min_d, max_d, norm, senior, child, student, disabled)
CROSS JOIN (SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code = 'AMTS') op;

-- BRTS Fares (slightly higher — AC dedicated BRT)
INSERT INTO bus.BUS_FARE_RULE
    (operator_id, min_distance_km, max_distance_km,
     normal_fare, senior_fare, child_fare, student_fare, disabled_fare,
     effective_from, is_active)
SELECT op.operator_id, v.min_d, v.max_d,
       v.norm, v.senior, v.child, v.student, v.disabled,
       '2024-01-01'::DATE, TRUE
FROM (VALUES
    ( 0.00,  5.00, 10.00, 5.00, 5.00, 8.00, 5.00),
    ( 5.01, 10.00, 15.00, 7.50, 7.50,12.00, 7.50),
    (10.01, 15.00, 20.00,10.00,10.00,16.00,10.00),
    (15.01, 25.00, 25.00,12.50,12.50,20.00,12.50)
) AS v(min_d, max_d, norm, senior, child, student, disabled)
CROSS JOIN (SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code = 'BRTS') op;

-- GSRTC Intercity Fares
INSERT INTO bus.BUS_FARE_RULE
    (operator_id, min_distance_km, max_distance_km,
     normal_fare, senior_fare, child_fare, student_fare, disabled_fare,
     effective_from, is_active)
SELECT op.operator_id, v.min_d, v.max_d,
       v.norm, v.senior, v.child, v.student, v.disabled,
       '2024-01-01'::DATE, TRUE
FROM (VALUES
    ( 0.00, 10.00, 20.00,10.00,10.00,16.00,10.00),
    (10.01, 20.00, 35.00,17.50,17.50,28.00,17.50),
    (20.01, 30.00, 50.00,25.00,25.00,40.00,25.00),
    (30.01, 40.00, 65.00,32.50,32.50,52.00,32.50),
    (40.01, 99.00, 80.00,40.00,40.00,64.00,40.00)
) AS v(min_d, max_d, norm, senior, child, student, disabled)
CROSS JOIN (SELECT operator_id FROM bus.BUS_OPERATOR WHERE operator_code = 'GSRTC') op;

-- Verify Part 1
DO $$
BEGIN
    RAISE NOTICE '=== BUS INSERT PART 1 COMPLETE ===';
    RAISE NOTICE 'BUS_OPERATOR  : %', (SELECT COUNT(*) FROM bus.BUS_OPERATOR);
    RAISE NOTICE 'BUS_STOP      : %', (SELECT COUNT(*) FROM bus.BUS_STOP);
    RAISE NOTICE 'BUS_ROUTE     : %', (SELECT COUNT(*) FROM bus.BUS_ROUTE);
    RAISE NOTICE 'ROUTE_STOP    : %', (SELECT COUNT(*) FROM bus.ROUTE_STOP);
    RAISE NOTICE 'BUS           : %', (SELECT COUNT(*) FROM bus.BUS);
    RAISE NOTICE 'BUS_FARE_RULE : %', (SELECT COUNT(*) FROM bus.BUS_FARE_RULE);
END $$;


-- ================================================================
--  AHMEDABAD YATRA — BUS SYSTEM DUMMY DATA PART 2
--  Tables: BUS_DRIVER → BUS_DRIVER_SHIFT → BUS_SCHEDULE
--          → BUS_TRIP_STOP → BUS_DRIVER_ASSIGNMENT
--          → INTERCHANGE_POINT
-- ================================================================

SET search_path TO bus, metro, public;

-- ================================================================
--  7. BUS_DRIVER  (18 drivers across 3 operators)
-- ================================================================

INSERT INTO bus.BUS_DRIVER
    (operator_id, employee_code, full_name, date_of_birth, gender,
     phone, email, license_no, license_expiry,
     salary, experience_years, joining_date,
     employment_status, emergency_contact, address)
SELECT
    op.operator_id,
    v.emp_code, v.full_name, v.dob::DATE, v.gender,
    v.phone, v.email, v.license_no, v.lic_expiry::DATE,
    v.salary, v.exp_yrs, v.joining::DATE,
    'ACTIVE'::bus.emp_status_t, v.emg_phone, v.address
FROM (VALUES
    -- AMTS Drivers
    ('AMTS','AMTS-D001','Haresh Bhai Patel',    '1982-03-14','M','9601001001',
     'haresh.patel@amts.in',  'GJ-BDL-2015-1001','2028-03-13',
     32000,15,'2019-06-01','9601001011',
     'A-12, Amraiwadi, Ahmedabad'),

    ('AMTS','AMTS-D002','Ramji Lal Sharma',     '1985-07-22','M','9601001002',
     'ramji.sharma@amts.in',  'GJ-BDL-2016-1002','2027-07-21',
     31000,12,'2019-06-01','9601001012',
     'B-5, Maninagar, Ahmedabad'),

    ('AMTS','AMTS-D003','Bharat Solanki',       '1988-11-05','M','9601001003',
     'bharat.solanki@amts.in','GJ-BDL-2017-1003','2026-11-04',
     30000, 9,'2020-03-01','9601001013',
     'C-8, Nikol, Ahmedabad'),

    ('AMTS','AMTS-D004','Praful Chauhan',       '1979-01-18','M','9601001004',
     'praful.chauhan@amts.in','GJ-BDL-2014-1004','2027-01-17',
     33000,18,'2019-06-01','9601001014',
     'D-3, Vastral, Ahmedabad'),

    ('AMTS','AMTS-D005','Jayesh Trivedi',       '1990-06-29','M','9601001005',
     'jayesh.trivedi@amts.in','GJ-BDL-2019-1005','2028-06-28',
     29000, 6,'2021-01-10','9601001015',
     'E-7, Naroda, Ahmedabad'),

    ('AMTS','AMTS-D006','Daksha Ben Rathod',    '1987-09-12','F','9601001006',
     'daksha.rathod@amts.in', 'GJ-BDL-2018-1006','2027-09-11',
     30000, 8,'2020-06-15','9601001016',
     'F-2, Ranip, Ahmedabad'),

    -- BRTS Drivers
    ('BRTS','BRTS-D001','Alpesh Kumar Modi',    '1983-04-08','M','9601002001',
     'alpesh.modi@janmarg.in','GJ-BDL-2016-2001','2027-04-07',
     38000,14,'2018-11-01','9601002011',
     'G-11, Navrangpura, Ahmedabad'),

    ('BRTS','BRTS-D002','Nitin Prajapati',      '1986-12-20','M','9601002002',
     'nitin.praj@janmarg.in', 'GJ-BDL-2017-2002','2028-12-19',
     37000,11,'2019-03-01','9601002012',
     'H-4, Vastrapur, Ahmedabad'),

    ('BRTS','BRTS-D003','Sanjay Bhavsar',       '1980-08-15','M','9601002003',
     'sanjay.bvsr@janmarg.in','GJ-BDL-2015-2003','2026-08-14',
     39000,16,'2018-11-01','9601002013',
     'J-9, Satellite, Ahmedabad'),

    ('BRTS','BRTS-D004','Kavita Yadav',         '1992-02-28','F','9601002004',
     'kavita.yadav@janmarg.in','GJ-BDL-2020-2004','2028-02-27',
     36000, 5,'2022-01-15','9601002014',
     'K-3, Bodakdev, Ahmedabad'),

    ('BRTS','BRTS-D005','Rohit Shah',           '1984-10-10','M','9601002005',
     'rohit.shah@janmarg.in', 'GJ-BDL-2016-2005','2027-10-09',
     38000,13,'2019-01-01','9601002015',
     'L-6, Prahladnagar, Ahmedabad'),

    -- GSRTC Drivers
    ('GSRTC','GSRTC-D001','Baldev Bhai Makwana','1978-05-25','M','9601003001',
     'baldev.mkwn@gsrtc.in', 'GJ-BDL-2014-3001','2027-05-24',
     42000,20,'2019-07-01','9601003011',
     'M-15, Chandkheda, Ahmedabad'),

    ('GSRTC','GSRTC-D002','Mahesh Patel',       '1981-03-30','M','9601003002',
     'mahesh.patel@gsrtc.in','GJ-BDL-2015-3002','2028-03-29',
     41000,17,'2019-07-01','9601003012',
     'N-8, Motera, Ahmedabad'),

    ('GSRTC','GSRTC-D003','Vijay Rathva',       '1984-11-14','M','9601003003',
     'vijay.rthv@gsrtc.in',  'GJ-BDL-2016-3003','2027-11-13',
     40000,14,'2020-01-15','9601003013',
     'O-2, Koba, Gandhinagar'),

    ('GSRTC','GSRTC-D004','Ashvin Baria',       '1987-07-07','M','9601003004',
     'ashvin.bria@gsrtc.in', 'GJ-BDL-2018-3004','2027-07-06',
     39000,11,'2020-06-01','9601003014',
     'P-17, Sector-7, Gandhinagar'),

    ('GSRTC','GSRTC-D005','Rajesh Damor',       '1980-01-19','M','9601003005',
     'rajesh.dmr@gsrtc.in',  'GJ-BDL-2015-3005','2027-01-18',
     41000,18,'2019-07-01','9601003015',
     'Q-5, Sector-16, Gandhinagar'),

    ('GSRTC','GSRTC-D006','Meena Ben Vasava',   '1990-04-22','F','9601003006',
     'meena.vsv@gsrtc.in',   'GJ-BDL-2019-3006','2028-04-21',
     38000, 6,'2021-03-01','9601003016',
     'R-11, Sector-21, Gandhinagar'),

    ('AMTS','AMTS-D007','Kiran Bhai Gohil',     '1993-08-18','M','9601001007',
     'kiran.gohil@amts.in',  'GJ-BDL-2021-1007','2029-08-17',
     28000, 4,'2023-01-10','9601001017',
     'S-3, Gota, Ahmedabad')
) AS v(op_code, emp_code, full_name, dob, gender, phone, email,
       license_no, lic_expiry, salary, exp_yrs, joining,
       emg_phone, address)
JOIN bus.BUS_OPERATOR op ON op.operator_code = v.op_code;

-- ================================================================
--  8. BUS_DRIVER_SHIFT  (5 days × 3 shifts covering all 18 drivers)
-- ================================================================

-- Morning shift (06:00–14:00): AMTS + BRTS drivers
INSERT INTO bus.BUS_DRIVER_SHIFT
    (driver_id, shift_date, shift_start, shift_end, shift_type, is_completed)
SELECT
    d.driver_id,
    gs.shift_date,
    '06:00'::TIME,
    '14:00'::TIME,
    'REGULAR',
    gs.shift_date < CURRENT_DATE
FROM bus.BUS_DRIVER d
CROSS JOIN (VALUES
    (CURRENT_DATE - 2),(CURRENT_DATE - 1),(CURRENT_DATE),
    (CURRENT_DATE + 1),(CURRENT_DATE + 2)
) AS gs(shift_date)
WHERE d.employee_code IN (
    'AMTS-D001','AMTS-D002','AMTS-D003','AMTS-D007',
    'BRTS-D001','BRTS-D002'
);

-- Evening shift (14:00–22:00): remaining AMTS + BRTS
INSERT INTO bus.BUS_DRIVER_SHIFT
    (driver_id, shift_date, shift_start, shift_end, shift_type, is_completed)
SELECT
    d.driver_id,
    gs.shift_date,
    '14:00'::TIME,
    '22:00'::TIME,
    'REGULAR',
    gs.shift_date < CURRENT_DATE
FROM bus.BUS_DRIVER d
CROSS JOIN (VALUES
    (CURRENT_DATE - 2),(CURRENT_DATE - 1),(CURRENT_DATE),
    (CURRENT_DATE + 1),(CURRENT_DATE + 2)
) AS gs(shift_date)
WHERE d.employee_code IN (
    'AMTS-D004','AMTS-D005','AMTS-D006',
    'BRTS-D003','BRTS-D004','BRTS-D005'
);

-- GSRTC: split shift (early morning + evening intercity runs)
INSERT INTO bus.BUS_DRIVER_SHIFT
    (driver_id, shift_date, shift_start, shift_end, shift_type, is_completed)
SELECT
    d.driver_id,
    gs.shift_date,
    '05:00'::TIME,
    '14:00'::TIME,
    'REGULAR',
    gs.shift_date < CURRENT_DATE
FROM bus.BUS_DRIVER d
CROSS JOIN (VALUES
    (CURRENT_DATE - 2),(CURRENT_DATE - 1),(CURRENT_DATE),
    (CURRENT_DATE + 1),(CURRENT_DATE + 2)
) AS gs(shift_date)
WHERE d.employee_code IN (
    'GSRTC-D001','GSRTC-D002','GSRTC-D003',
    'GSRTC-D004','GSRTC-D005','GSRTC-D006'
);

-- Night shift for GSRTC night service
INSERT INTO bus.BUS_DRIVER_SHIFT
    (driver_id, shift_date, shift_start, shift_end, shift_type, is_completed, remarks)
SELECT
    d.driver_id,
    gs.shift_date,
    '21:00'::TIME,
    '06:00'::TIME,
    'REGULAR',
    gs.shift_date < CURRENT_DATE,
    'Night service GN-NIGHT'
FROM bus.BUS_DRIVER d
CROSS JOIN (VALUES
    (CURRENT_DATE - 1),(CURRENT_DATE),(CURRENT_DATE + 1)
) AS gs(shift_date)
WHERE d.employee_code IN ('GSRTC-D005','GSRTC-D006');

-- ================================================================
--  9. BUS_SCHEDULE  (schedules for all 12 routes)
--  Real departure times matching AMTS/BRTS/GSRTC timetables
-- ================================================================

INSERT INTO bus.BUS_SCHEDULE
    (bus_id, route_id, direction, day_type,
     departure_time, arrival_time, normal_eta_mins,
     schedule_status, effective_from)
SELECT
    b.bus_id,
    r.route_id,
    v.direction,
    v.day_type::bus.day_type_t,
    v.dep_time::TIME,
    v.arr_time::TIME,
    v.eta_mins,
    'ACTIVE'::bus.schedule_status_t,
    CURRENT_DATE
FROM (VALUES
    -- Route 37: Lal Darwaja → Narol (forward + return)
    ('AMTS-001','37','AMTS','FORWARD','WEEKDAY','06:00','07:35',95),
    ('AMTS-001','37','AMTS','FORWARD','WEEKDAY','08:30','10:05',95),
    ('AMTS-002','37','AMTS','RETURN', 'WEEKDAY','07:45','09:20',95),
    ('AMTS-002','37','AMTS','RETURN', 'WEEKDAY','17:30','19:05',95),

    -- Route 105: Geeta Mandir → Thaltej
    ('AMTS-003','105','AMTS','FORWARD','WEEKDAY','06:30','08:00',90),
    ('AMTS-003','105','AMTS','FORWARD','WEEKDAY','17:00','18:30',90),

    -- Route 52: Lal Darwaja → Chandkheda
    ('AMTS-005','52','AMTS','FORWARD','WEEKDAY','06:15','07:30',75),
    ('AMTS-006','52','AMTS','FORWARD','WEEKDAY','17:15','18:30',75),
    ('AMTS-005','52','AMTS','RETURN', 'WEEKDAY','08:00','09:15',75),

    -- Route 81: Kalupur → ISKON
    ('AMTS-007','81','AMTS','FORWARD','WEEKDAY','07:00','08:00',60),
    ('AMTS-007','81','AMTS','FORWARD','WEEKDAY','17:30','18:30',60),

    -- Feeder F1: Vastral → Vastral Gam Metro
    ('AMTS-009','F1','AMTS','FORWARD','ALL_DAYS','06:00','06:25',25),
    ('AMTS-009','F1','AMTS','FORWARD','ALL_DAYS','07:00','07:25',25),
    ('AMTS-009','F1','AMTS','RETURN', 'ALL_DAYS','06:30','06:55',25),

    -- Feeder F2: Ranip → Motera Metro
    ('AMTS-010','F2','AMTS','FORWARD','ALL_DAYS','06:05','06:30',25),
    ('AMTS-010','F2','AMTS','FORWARD','ALL_DAYS','07:05','07:30',25),
    ('AMTS-010','F2','AMTS','RETURN', 'ALL_DAYS','06:35','07:00',25),

    -- BRTS-1: Vasna → Thaltej
    ('BRTS-001','BRTS-1','BRTS','FORWARD','WEEKDAY','06:00','07:00',60),
    ('BRTS-001','BRTS-1','BRTS','FORWARD','WEEKDAY','08:00','09:00',60),
    ('BRTS-002','BRTS-1','BRTS','FORWARD','WEEKDAY','17:00','18:00',60),
    ('BRTS-002','BRTS-1','BRTS','RETURN', 'WEEKDAY','07:05','08:05',60),

    -- BRTS-2: Gitam → Navrangpura
    ('BRTS-004','BRTS-2','BRTS','FORWARD','WEEKDAY','06:30','08:00',90),
    ('BRTS-004','BRTS-2','BRTS','FORWARD','WEEKDAY','17:30','19:00',90),
    ('BRTS-005','BRTS-2','BRTS','RETURN', 'WEEKDAY','08:10','09:40',90),

    -- GSRTC GN-001: Ahmedabad → Gandhinagar Express
    ('GSRTC-001','GN-001','GSRTC','FORWARD','WEEKDAY','06:00','07:05',65),
    ('GSRTC-001','GN-001','GSRTC','FORWARD','WEEKDAY','08:00','09:05',65),
    ('GSRTC-001','GN-001','GSRTC','FORWARD','WEEKDAY','12:00','13:05',65),
    ('GSRTC-001','GN-001','GSRTC','FORWARD','WEEKDAY','18:00','19:05',65),
    ('GSRTC-002','GN-001','GSRTC','RETURN', 'WEEKDAY','07:15','08:20',65),
    ('GSRTC-002','GN-001','GSRTC','RETURN', 'WEEKDAY','17:00','18:05',65),

    -- GSRTC GN-002: Ahmedabad → Mahatma Mandir via Infocity
    ('GSRTC-003','GN-002','GSRTC','FORWARD','WEEKDAY','07:00','08:30',90),
    ('GSRTC-003','GN-002','GSRTC','FORWARD','WEEKDAY','09:00','10:30',90),
    ('GSRTC-003','GN-002','GSRTC','RETURN', 'WEEKDAY','17:00','18:30',90),

    -- GSRTC GN-003: Ahmedabad → GIFT City Express
    ('GSRTC-004','GN-003','GSRTC','FORWARD','WEEKDAY','08:00','09:15',75),
    ('GSRTC-004','GN-003','GSRTC','RETURN', 'WEEKDAY','17:30','18:45',75),

    -- GSRTC Night service
    ('GSRTC-005','GN-NIGHT','GSRTC','FORWARD','ALL_DAYS','22:00','23:10',70),
    ('GSRTC-005','GN-NIGHT','GSRTC','RETURN', 'ALL_DAYS','23:30','00:40',70)

) AS v(bus_num, route_no, op_code, direction, day_type,
       dep_time, arr_time, eta_mins)
JOIN bus.BUS          b ON b.bus_number   = v.bus_num
JOIN bus.BUS_OPERATOR op ON op.operator_code = v.op_code
JOIN bus.BUS_ROUTE    r  ON r.route_number   = v.route_no
                         AND r.operator_id    = op.operator_id;

-- Weekend schedules (later start, less frequency)
INSERT INTO bus.BUS_SCHEDULE
    (bus_id, route_id, direction, day_type,
     departure_time, arrival_time, normal_eta_mins,
     schedule_status, effective_from)
SELECT
    bus_id, route_id, direction,
    'WEEKEND'::bus.day_type_t,
    (departure_time + INTERVAL '30 minutes')::TIME,
    (arrival_time   + INTERVAL '30 minutes')::TIME,
    normal_eta_mins,
    'ACTIVE',
    CURRENT_DATE
FROM bus.BUS_SCHEDULE
WHERE day_type   = 'WEEKDAY'
AND   is_deleted = FALSE
AND   direction  = 'FORWARD';

-- ================================================================
--  10. BUS_TRIP_STOP
--  Generate all stop timings for every schedule automatically.
--  Average speed: city bus ~18 kmph, intercity ~40 kmph, BRTS ~25 kmph
-- ================================================================

DO $bts$
DECLARE
    r_sch   RECORD;
    r_stop  RECORD;
    v_seq   SMALLINT;
    v_base  TIME;
    v_arr   TIME;
    v_dep   TIME;
    v_speed NUMERIC;
    v_inter INTERVAL;
    v_halt  INTERVAL := '20 seconds';
    v_prev_dist NUMERIC := 0;
    v_seg_dist  NUMERIC;
BEGIN
    FOR r_sch IN
        SELECT bs.schedule_id, bs.route_id, bs.direction,
               bs.departure_time, bs.day_type, r.route_type
        FROM   bus.BUS_SCHEDULE bs
        JOIN   bus.BUS_ROUTE    r ON r.route_id = bs.route_id
        WHERE  bs.schedule_status = 'ACTIVE'
        AND    bs.is_deleted      = FALSE
        ORDER  BY bs.schedule_id
    LOOP
        -- Set speed based on route type
        v_speed := CASE r_sch.route_type
            WHEN 'BRTS'      THEN 25.0
            WHEN 'INTERCITY' THEN 40.0
            WHEN 'EXPRESS'   THEN 35.0
            WHEN 'FEEDER'    THEN 15.0
            ELSE 18.0
        END;

        v_base     := r_sch.departure_time;
        v_seq      := 1;
        v_prev_dist := 0;

        FOR r_stop IN
            SELECT rs.stop_id, rs.sequence_no,
                   rs.dist_from_start_km, rs.is_terminal
            FROM   bus.ROUTE_STOP rs
            WHERE  rs.route_id  = r_sch.route_id
            AND    rs.is_active = TRUE
            ORDER BY
                CASE WHEN r_sch.direction = 'FORWARD'
                     THEN rs.sequence_no
                     ELSE -rs.sequence_no
                END
        LOOP
            v_seg_dist := ABS(r_stop.dist_from_start_km - v_prev_dist);

            -- Time for this segment
            IF v_seq > 1 AND v_speed > 0 THEN
                v_inter := ((v_seg_dist / v_speed * 60)::INT || ' minutes')::INTERVAL;
                v_base  := v_base + v_inter;
            END IF;

            v_arr := v_base;
            v_dep := v_base + v_halt;

            INSERT INTO bus.BUS_TRIP_STOP (
                schedule_id, stop_sequence, stop_id,
                scheduled_arrival, scheduled_departure,
                halt_duration_sec, is_active
            ) VALUES (
                r_sch.schedule_id, v_seq, r_stop.stop_id,
                v_arr, v_dep,
                20, TRUE
            );

            v_prev_dist := r_stop.dist_from_start_km;
            v_base      := v_dep;
            v_seq       := v_seq + 1;
        END LOOP;
    END LOOP;

    RAISE NOTICE 'BUS_TRIP_STOP: inserted for all schedules.';
END $bts$;

-- ================================================================
--  11. BUS_DRIVER_ASSIGNMENT
--  Assign one PRIMARY driver per schedule for today
-- ================================================================

INSERT INTO bus.BUS_DRIVER_ASSIGNMENT
    (driver_id, schedule_id, assignment_date, role, is_active)
SELECT
    d.driver_id,
    bs.schedule_id,
    CURRENT_DATE,
    'PRIMARY',
    TRUE
FROM (
    SELECT schedule_id,
           ROW_NUMBER() OVER (ORDER BY schedule_id) AS rn
    FROM   bus.BUS_SCHEDULE
    WHERE  day_type IN ('WEEKDAY','ALL_DAYS')
    AND    is_deleted = FALSE
    ORDER  BY schedule_id
) bs
JOIN (
    SELECT driver_id,
           ROW_NUMBER() OVER (ORDER BY driver_id) AS rn
    FROM   bus.BUS_DRIVER
    WHERE  employment_status = 'ACTIVE'
    AND    is_deleted        = FALSE
    ORDER  BY driver_id
) d ON d.rn = ((bs.rn - 1) % (
    SELECT COUNT(*) FROM bus.BUS_DRIVER
    WHERE employment_status='ACTIVE' AND is_deleted=FALSE
)) + 1;

-- ================================================================
--  12. INTERCHANGE_POINT
--  Links metro stations to nearby bus stops.
--  This is the KEY integration table.
--  All walking distances measured from Google Maps.
-- ================================================================

INSERT INTO bus.INTERCHANGE_POINT
    (metro_station_id, bus_stop_id,
     walking_dist_m, connection_type, is_covered,
     has_signage, notes, is_active)
SELECT
    ms.station_id,
    bs.stop_id,
    v.walk_m,
    v.conn_type::bus.connection_type_t,
    v.covered,
    TRUE,
    v.notes,
    TRUE
FROM (VALUES
    -- Blue Line interchanges
    ('KLP', 'AMTS-KALP',  150, 'COVERED_WALKWAY', TRUE,
     'Kalupur Metro Exit Gate 2 directly connects to AMTS bus bay'),
    ('KLP', 'BUS-KALPB',  200, 'WALK', FALSE,
     'Short walk along platform road to main bus stand'),
    ('OHC', 'BUS-OHC',    120, 'COVERED_WALKWAY', TRUE,
     'Old High Court interchange — covered walkway to bus stop'),
    ('OHC', 'BRTS-GITAM', 450, 'WALK', FALSE,
     'Walk south on Ashram Road to Gitam BRTS station'),
    ('GUV', 'BRTS-NAVM',  380, 'WALK', FALSE,
     'Gujarat University metro to Navrangpura BRTS — 5 min walk'),
    ('TLT', 'BRTS-THLT',  250, 'WALK', FALSE,
     'Thaltej Metro Station to Thaltej BRTS stop on S.G. Highway'),
    ('TLG', 'BRTS-THLT',  600, 'WALK', FALSE,
     'Thaltej Gam Metro to Thaltej BRTS — slight walk'),

    -- Red Line interchanges
    ('APC', 'AMTS-SGHWY', 200, 'WALK', FALSE,
     'APMC Metro to APMC bus stop near Vasna junction'),
    ('PAL', 'AMTS-PALDI', 180, 'WALK', FALSE,
     'Paldi Metro to Paldi Cross Road AMTS stop'),
    ('GDG', 'BRTS-GITAM', 220, 'COVERED_WALKWAY', TRUE,
     'Gandhigram Metro directly above Gitam BRTS station'),
    ('MTS', 'BUS-MTSB',   100, 'COVERED_WALKWAY', TRUE,
     'Motera Stadium Metro — covered walkway to GSRTC/AMTS stop'),
    ('MTS', 'AMTS-NIRNA', 750, 'WALK', FALSE,
     'Motera Metro to Nirnaynagar bus stop — 10 min walk'),
    ('SBR', 'AMTS-SABAR', 300, 'WALK', FALSE,
     'Sabarmati Metro to Sabarmati AMTS bus stop'),

    -- Yellow Line interchanges (Gandhinagar)
    ('GNL', 'BUS-GNLU',   80,  'COVERED_WALKWAY', TRUE,
     'GNLU Metro direct connection to GSRTC bus stop — shortest interchange'),
    ('GNL', 'GN-PDPU',    500, 'WALK', FALSE,
     'GNLU Metro to PDPU Campus bus stop'),
    ('MMD', 'BUS-MMD',    100, 'COVERED_WALKWAY', TRUE,
     'Mahatma Mandir Metro directly connected to GSRTC bus terminal'),
    ('MMD', 'GSRTC-MMBS', 150, 'WALK', FALSE,
     'Mahatma Mandir Metro to GSRTC Mahatma Mandir terminal'),
    ('SC1', 'GN-SC5',     800, 'WALK', FALSE,
     'Sector-1 Metro to Sector-5 bus stop — boundary of walk distance'),
    ('SCH', 'GN-SACHLYA', 200, 'WALK', FALSE,
     'Sachivalaya Metro to Sachivalaya GSRTC bus stop'),

    -- Violet Line interchanges
    ('GFT', 'GN-GIFT',    150, 'COVERED_WALKWAY', TRUE,
     'GIFT City Metro station — covered bridge to GIFT City bus stop'),
    ('PDU', 'GN-PDPU',    200, 'WALK', FALSE,
     'PDEU Metro to PDPU Campus bus stop — 3 min walk')

) AS v(metro_code, bus_code, walk_m, conn_type, covered, notes)
JOIN metro.STATION ms ON ms.station_code = v.metro_code
JOIN bus.BUS_STOP  bs ON bs.stop_code    = v.bus_code
WHERE ms.is_deleted = FALSE
AND   bs.is_deleted = FALSE;

-- ================================================================
--  VERIFY PART 2
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '=== BUS INSERT PART 2 COMPLETE ===';
    RAISE NOTICE 'BUS_DRIVER              : %', (SELECT COUNT(*) FROM bus.BUS_DRIVER);
    RAISE NOTICE 'BUS_DRIVER_SHIFT        : %', (SELECT COUNT(*) FROM bus.BUS_DRIVER_SHIFT);
    RAISE NOTICE 'BUS_SCHEDULE            : %', (SELECT COUNT(*) FROM bus.BUS_SCHEDULE);
    RAISE NOTICE 'BUS_TRIP_STOP           : %', (SELECT COUNT(*) FROM bus.BUS_TRIP_STOP);
    RAISE NOTICE 'BUS_DRIVER_ASSIGNMENT   : %', (SELECT COUNT(*) FROM bus.BUS_DRIVER_ASSIGNMENT);
    RAISE NOTICE 'INTERCHANGE_POINT       : %', (SELECT COUNT(*) FROM bus.INTERCHANGE_POINT);
END $$;


-- ================================================================
--  AHMEDABAD YATRA — BUS SYSTEM DUMMY DATA PART 3
--  Tables: BUS_TICKET → BUS_PAYMENT → BUS_TRAVEL_PASS
--          → BUS_STOP_SCAN → BUS_TRAVELLING_IN
--          → COMBINED_JOURNEY → COMBINED_JOURNEY_LEG
-- ================================================================

SET search_path TO bus, metro, public;

-- ================================================================
--  13. BUS_TICKET  (20 tickets — varied routes, types, statuses)
--  All use metro.PASSENGER (shared identity across both systems)
-- ================================================================

-- Ticket 1: Aarav Shah — GSRTC Ahmedabad → Gandhinagar (33km → ₹65)
INSERT INTO bus.BUS_TICKET
    (passenger_id, fare_rule_id, from_stop_id, to_stop_id, schedule_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.stop_id, ts.stop_id, bsc.schedule_id,
    'SINGLE', 'GENERAL',
    metro.generate_qr_code('BUS'),
    33.00, 65.00, 0.00, 65.00,
    'MOBILE_APP',
    NOW() - INTERVAL '1 hour',
    NOW() + INTERVAL '3 hours',
    'USED'
FROM metro.PASSENGER p, bus.BUS_STOP fs, bus.BUS_STOP ts,
     bus.BUS_FARE_RULE fr
JOIN bus.BUS_OPERATOR op ON op.operator_id = fr.operator_id
JOIN bus.BUS_SCHEDULE bsc ON TRUE
JOIN bus.BUS_ROUTE    r   ON r.route_id = bsc.route_id
                          AND r.operator_id = op.operator_id
WHERE p.full_name = 'Aarav Shah'
AND   fs.stop_code = 'GSRTC-AHBS'
AND   ts.stop_code = 'GSRTC-STBS'
AND   op.operator_code = 'GSRTC'
AND   r.route_number   = 'GN-001'
AND   bsc.direction    = 'FORWARD'
AND   bsc.is_deleted   = FALSE
AND   fr.min_distance_km <= 33.00 AND fr.max_distance_km >= 33.00
AND   fr.is_active = TRUE
LIMIT 1;

-- Ticket 2: Priya Patel — BRTS Vasna → Navrangpura (17.5km → ₹25)
INSERT INTO bus.BUS_TICKET
    (passenger_id, fare_rule_id, from_stop_id, to_stop_id, schedule_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.stop_id, ts.stop_id, bsc.schedule_id,
    'SINGLE', 'GENERAL',
    metro.generate_qr_code('BUS'),
    17.50, 25.00, 0.00, 25.00,
    'MOBILE_APP',
    NOW() - INTERVAL '30 minutes',
    NOW() + INTERVAL '2 hours',
    'ACTIVE'
FROM metro.PASSENGER p, bus.BUS_STOP fs, bus.BUS_STOP ts,
     bus.BUS_FARE_RULE fr
JOIN bus.BUS_OPERATOR op ON op.operator_id = fr.operator_id
JOIN bus.BUS_SCHEDULE bsc ON TRUE
JOIN bus.BUS_ROUTE r ON r.route_id = bsc.route_id AND r.operator_id = op.operator_id
WHERE p.full_name = 'Priya Patel'
AND   fs.stop_code = 'BRTS-VASNA' AND ts.stop_code = 'BRTS-NAVM'
AND   op.operator_code = 'BRTS' AND r.route_number = 'BRTS-1'
AND   bsc.direction = 'FORWARD' AND bsc.is_deleted = FALSE
AND   fr.min_distance_km <= 17.50 AND fr.max_distance_km >= 17.50
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 3: Rohan Mehta — AMTS Lal Darwaja → Narol (28.5km → ₹18)
INSERT INTO bus.BUS_TICKET
    (passenger_id, fare_rule_id, from_stop_id, to_stop_id, schedule_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.stop_id, ts.stop_id, bsc.schedule_id,
    'SINGLE', 'GENERAL',
    metro.generate_qr_code('BUS'),
    28.50, 18.00, 0.00, 18.00,
    'CONDUCTOR',
    NOW() - INTERVAL '45 minutes',
    NOW() + INTERVAL '2 hours',
    'ACTIVE'
FROM metro.PASSENGER p, bus.BUS_STOP fs, bus.BUS_STOP ts,
     bus.BUS_FARE_RULE fr
JOIN bus.BUS_OPERATOR op ON op.operator_id = fr.operator_id
JOIN bus.BUS_SCHEDULE bsc ON TRUE
JOIN bus.BUS_ROUTE r ON r.route_id = bsc.route_id AND r.operator_id = op.operator_id
WHERE p.full_name = 'Rohan Mehta'
AND   fs.stop_code = 'AMTS-LDWJ' AND ts.stop_code = 'AMTS-NROL'
AND   op.operator_code = 'AMTS' AND r.route_number = '37'
AND   bsc.direction = 'FORWARD' AND bsc.is_deleted = FALSE
AND   fr.min_distance_km <= 28.50 AND fr.max_distance_km >= 28.50
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 4: Ramanlal Trivedi — Senior GSRTC (33km → ₹32.50)
INSERT INTO bus.BUS_TICKET
    (passenger_id, fare_rule_id, from_stop_id, to_stop_id, schedule_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.stop_id, ts.stop_id, bsc.schedule_id,
    'SINGLE', 'SENIOR_CITIZEN',
    metro.generate_qr_code('BUS'),
    33.00, 65.00, 32.50, 32.50,
    'COUNTER',
    NOW() - INTERVAL '2 hours',
    NOW() + INTERVAL '2 hours',
    'USED'
FROM metro.PASSENGER p, bus.BUS_STOP fs, bus.BUS_STOP ts,
     bus.BUS_FARE_RULE fr
JOIN bus.BUS_OPERATOR op ON op.operator_id = fr.operator_id
JOIN bus.BUS_SCHEDULE bsc ON TRUE
JOIN bus.BUS_ROUTE r ON r.route_id = bsc.route_id AND r.operator_id = op.operator_id
WHERE p.full_name = 'Ramanlal Trivedi'
AND   fs.stop_code = 'GSRTC-AHBS' AND ts.stop_code = 'GSRTC-STBS'
AND   op.operator_code = 'GSRTC' AND r.route_number = 'GN-001'
AND   bsc.direction = 'FORWARD' AND bsc.is_deleted = FALSE
AND   fr.min_distance_km <= 33.00 AND fr.max_distance_km >= 33.00
AND   fr.is_active = TRUE LIMIT 1;

-- Ticket 5: Diya Sharma — Student AMTS (12km → ₹8)
INSERT INTO bus.BUS_TICKET
    (passenger_id, fare_rule_id, from_stop_id, to_stop_id, schedule_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id, fr.fare_rule_id,
    fs.stop_id, ts.stop_id, bsc.schedule_id,
    'SINGLE', 'STUDENT',
    metro.generate_qr_code('BUS'),
    12.00, 12.00, 2.40, 9.60,
    'MOBILE_APP',
    NOW() - INTERVAL '15 minutes',
    NOW() + INTERVAL '3 hours',
    'ACTIVE'
FROM metro.PASSENGER p, bus.BUS_STOP fs, bus.BUS_STOP ts,
     bus.BUS_FARE_RULE fr
JOIN bus.BUS_OPERATOR op ON op.operator_id = fr.operator_id
JOIN bus.BUS_SCHEDULE bsc ON TRUE
JOIN bus.BUS_ROUTE r ON r.route_id = bsc.route_id AND r.operator_id = op.operator_id
WHERE p.full_name = 'Diya Sharma'
AND   fs.stop_code = 'AMTS-LDWJ' AND ts.stop_code = 'AMTS-STDT'
AND   op.operator_code = 'AMTS' AND r.route_number = '52'
AND   bsc.direction = 'FORWARD' AND bsc.is_deleted = FALSE
AND   fr.min_distance_km <= 12.00 AND fr.max_distance_km >= 12.00
AND   fr.is_active = TRUE LIMIT 1;

-- Tickets 6-20: Batch insert for remaining passengers
INSERT INTO bus.BUS_TICKET
    (passenger_id, fare_rule_id, from_stop_id, to_stop_id, schedule_id,
     ticket_type, passenger_category, qr_code,
     distance_km, base_amount, discount_amount, price_paid,
     booking_channel, valid_from, valid_to, status)
SELECT
    p.passenger_id,
    fr.fare_rule_id,
    fs.stop_id, ts.stop_id,
    bsc.schedule_id,
    v.tkt_type::bus.ticket_type_t,
    v.pax_cat::metro.passenger_type_t,
    metro.generate_qr_code('BUS'),
    v.dist_km,
    v.base_amt, v.disc_amt,
    v.base_amt - v.disc_amt,
    v.channel::bus.booking_channel_t,
    NOW() - (v.issued_ago || ' minutes')::INTERVAL,
    NOW() + (v.valid_mins || ' minutes')::INTERVAL,
    v.tkt_status::bus.ticket_status_t
FROM (VALUES
    ('Sneha Desai',    'GSRTC-AHBS','GSRTC-INF', 'GN-002','GSRTC','SINGLE','GENERAL',           22.80,35.00,0.00,    'MOBILE_APP',20,100,'ACTIVE'),
    ('Karan Joshi',    'AMTS-KALP', 'BRTS-ISKON','81',    'AMTS', 'SINGLE','GENERAL',           14.20,12.00,0.00,    'CONDUCTOR', 40, 80,'USED'),
    ('Raj Solanki',    'AMTS-LDWJ', 'AMTS-USMNP','52',    'AMTS', 'SINGLE','STUDENT',           10.20,10.00,2.00,    'MOBILE_APP',10,110,'ACTIVE'),
    ('Nisha Agrawal',  'BUS-MTSB',  'BUS-GNLU',  'GN-001','GSRTC','SINGLE','STUDENT',           7.90, 20.00,4.00,    'MOBILE_APP',25, 95,'ACTIVE'),
    ('Vihaan Shah',    'AMTS-LDWJ', 'AMTS-KKNR', '37',    'AMTS', 'SINGLE','CHILD',             10.40, 8.00,4.00,    'COUNTER',   30, 90,'ACTIVE'),
    ('Aadhya Patel',   'AMTS-LDWJ', 'AMTS-MANIK','37',    'AMTS', 'SINGLE','CHILD',             13.80, 8.00,4.00,    'COUNTER',   35, 85,'ACTIVE'),
    ('James Wilson',   'GSRTC-AHBS','GSRTC-MMBS','GN-002','GSRTC','SINGLE','TOURIST',           36.50,80.00,0.00,    'MOBILE_APP',50, 70,'BOOKED'),
    ('Yuki Tanaka',    'GSRTC-AHBS','GN-GIFT',   'GN-003','GSRTC','SINGLE','TOURIST',           34.20,80.00,0.00,    'WEBSITE',   45, 75,'BOOKED'),
    ('Meera Rana',     'BRTS-VASNA','BRTS-PKWY', 'BRTS-1','BRTS', 'SINGLE','PHYSICALLY_DISABLED',10.10,10.00,5.00,   'COUNTER',   20,100,'ACTIVE'),
    ('Chunilal Vaghela','AMTS-LDWJ','AMTS-PALDI','37',    'AMTS', 'SINGLE','FREEDOM_FIGHTER',   5.20, 8.00,8.00,    'COUNTER',   60, 60,'USED'),
    ('Kantibhai Shah', 'AMTS-SABAR','AMTS-RANIP','F2',    'AMTS', 'SINGLE','SENIOR_CITIZEN',    1.50, 8.00,4.00,    'COUNTER',   15,105,'ACTIVE'),
    ('Bhavesh Kumar',  'GSRTC-AHBS','GSRTC-STBS','GN-001','GSRTC','RETURN','GENERAL',           33.00,65.00,0.00,   'MOBILE_APP', 5,115,'ACTIVE'),
    ('Anjali Mishra',  'AMTS-LDWJ', 'AMTS-DRIVE','105',   'AMTS', 'SINGLE','GENERAL',           17.30,15.00,0.00,   'CONDUCTOR', 55, 65,'CANCELLED'),
    ('Savitaben Patel','AMTS-LDWJ', 'AMTS-MANIK','37',    'AMTS', 'SINGLE','SENIOR_CITIZEN',    13.80, 8.00,4.00,   'COUNTER',   90, 30,'EXPIRED')
) AS v(pname, from_code, to_code, route_no, op_code, tkt_type, pax_cat,
       dist_km, base_amt, disc_amt, channel, issued_ago, valid_mins, tkt_status)
JOIN metro.PASSENGER    p   ON p.full_name      = v.pname
JOIN bus.BUS_STOP       fs  ON fs.stop_code     = v.from_code
JOIN bus.BUS_STOP       ts  ON ts.stop_code     = v.to_code
JOIN bus.BUS_OPERATOR   op  ON op.operator_code = v.op_code
JOIN bus.BUS_ROUTE      r   ON r.route_number   = v.route_no
                            AND r.operator_id    = op.operator_id
JOIN bus.BUS_SCHEDULE   bsc ON bsc.route_id     = r.route_id
                            AND bsc.direction    = 'FORWARD'
                            AND bsc.is_deleted   = FALSE
JOIN bus.BUS_FARE_RULE  fr  ON fr.operator_id   = op.operator_id
                            AND v.dist_km BETWEEN fr.min_distance_km
                                              AND fr.max_distance_km
                            AND fr.is_active     = TRUE;

-- ================================================================
--  14. BUS_PAYMENT  (one per ticket)
-- ================================================================

INSERT INTO bus.BUS_PAYMENT
    (ticket_id, amount, payment_method, gateway_name,
     gateway_payment_id, status, initiated_at, paid_at,
     refund_amount, refunded_at)
SELECT
    t.ticket_id,
    t.price_paid,
    v.method::bus.payment_method_t,
    v.gateway,
    'BUSPAY-' || t.ticket_id || '-' || EXTRACT(EPOCH FROM NOW())::BIGINT,
    v.pay_status::bus.payment_status_t,
    t.issued_at,
    CASE WHEN v.pay_status IN ('SUCCESS') THEN t.issued_at + INTERVAL '3 seconds' ELSE NULL END,
    CASE WHEN v.pay_status = 'REFUNDED' THEN t.price_paid ELSE 0 END,
    CASE WHEN v.pay_status = 'REFUNDED' THEN t.issued_at + INTERVAL '1 day' ELSE NULL END
FROM (
    SELECT ticket_id, price_paid, issued_at,
           ROW_NUMBER() OVER (ORDER BY ticket_id) AS rn
    FROM   bus.BUS_TICKET WHERE is_deleted = FALSE
) t
JOIN (VALUES
    (1,'UPI',        'SUCCESS',  'RAZORPAY'),
    (2,'UPI',        'SUCCESS',  'PHONEPE'),
    (3,'CASH',       'SUCCESS',  'CONDUCTOR'),
    (4,'CASH',       'SUCCESS',  'COUNTER'),
    (5,'UPI',        'SUCCESS',  'PAYTM'),
    (6,'MOBILE_APP', 'SUCCESS',  'GPAY'),
    (7,'CASH',       'SUCCESS',  'CONDUCTOR'),
    (8,'UPI',        'SUCCESS',  'RAZORPAY'),
    (9,'CASH',       'SUCCESS',  'COUNTER'),
    (10,'CASH',      'SUCCESS',  'COUNTER'),
    (11,'CASH',      'SUCCESS',  'COUNTER'),
    (12,'CASH',      'SUCCESS',  'COUNTER'),
    (13,'CREDIT_CARD','SUCCESS', 'HDFC'),
    (14,'DEBIT_CARD','SUCCESS',  'SBI'),
    (15,'UPI',       'SUCCESS',  'GPAY'),
    (16,'CASH',      'SUCCESS',  'CONDUCTOR'),
    (17,'UPI',       'SUCCESS',  'PHONEPE'),
    (18,'CREDIT_CARD','SUCCESS', 'ICICI'),
    (19,'UPI',       'REFUNDED', 'RAZORPAY'),
    (20,'CASH',      'SUCCESS',  'COUNTER')
) AS v(rn, method, pay_status, gateway) ON v.rn = t.rn;

-- ================================================================
--  15. BUS_TRAVEL_PASS  (12 passes — monthly/weekly/student)
-- ================================================================

INSERT INTO bus.BUS_TRAVEL_PASS
    (passenger_id, operator_id, pass_type, institution_name,
     valid_from, valid_to, price, qr_code, is_active)
SELECT
    p.passenger_id,
    op.operator_id,
    v.pass_type::bus.pass_type_t,
    v.institution,
    CURRENT_DATE,
    CURRENT_DATE + (v.validity_days || ' days')::INTERVAL,
    v.price,
    metro.generate_qr_code('BPSS'),
    TRUE
FROM (VALUES
    ('Diya Sharma',     'AMTS','STUDENT_MONTHLY','Gujarat University',       30, 150.00),
    ('Raj Solanki',     'AMTS','STUDENT_MONTHLY','Gujarat University',       30, 150.00),
    ('Nisha Agrawal',   'GSRTC','STUDENT_MONTHLY','DA-IICT Gandhinagar',     30, 200.00),
    ('Ramanlal Trivedi','GSRTC','SENIOR_MONTHLY', NULL,                      30, 180.00),
    ('Savitaben Patel', 'AMTS','SENIOR_MONTHLY',  NULL,                      30, 100.00),
    ('Kantibhai Shah',  'AMTS','SENIOR_MONTHLY',  NULL,                      30, 100.00),
    ('Bhavesh Kumar',   'GSRTC','MONTHLY',         NULL,                     30, 500.00),
    ('Anjali Mishra',   'AMTS','MONTHLY',          NULL,                     30, 300.00),
    ('Rohan Mehta',     'BRTS','MONTHLY',          NULL,                     30, 400.00),
    ('Sneha Desai',     'GSRTC','MONTHLY',         NULL,                     30, 500.00),
    ('Priya Patel',     'BRTS','STUDENT_MONTHLY',  'PDPU Gandhinagar',       30, 200.00),
    ('Aarav Shah',      'GSRTC','MONTHLY',         NULL,                     30, 500.00)
) AS v(pname, op_code, pass_type, institution, validity_days, price)
JOIN metro.PASSENGER p  ON p.full_name      = v.pname
JOIN bus.BUS_OPERATOR op ON op.operator_code = v.op_code;

-- ================================================================
--  16. BUS_STOP_SCAN  (entry + exit scans for USED tickets)
-- ================================================================

-- ENTRY scans for USED and ACTIVE tickets
INSERT INTO bus.BUS_STOP_SCAN
    (ticket_id, stop_id, schedule_id, stop_sequence,
     scan_role, gate_device_id, scan_timestamp, is_valid)
SELECT
    t.ticket_id,
    t.from_stop_id,
    t.schedule_id,
    bts.stop_sequence,
    'ENTRY',
    'BUS-COND-' || t.schedule_id || '-01',
    t.valid_from + INTERVAL '2 minutes',
    TRUE
FROM bus.BUS_TICKET t
JOIN bus.BUS_TRIP_STOP bts ON bts.schedule_id = t.schedule_id
                           AND bts.stop_id     = t.from_stop_id
WHERE t.status IN ('USED','ACTIVE','ENTRY_DONE')
AND   t.is_deleted = FALSE
AND   t.schedule_id IS NOT NULL;

-- EXIT scans for USED tickets
INSERT INTO bus.BUS_STOP_SCAN
    (ticket_id, stop_id, schedule_id, stop_sequence,
     scan_role, gate_device_id, scan_timestamp, is_valid)
SELECT
    t.ticket_id,
    t.to_stop_id,
    t.schedule_id,
    bts.stop_sequence,
    'EXIT',
    'BUS-COND-' || t.schedule_id || '-01',
    t.valid_from + INTERVAL '60 minutes',
    TRUE
FROM bus.BUS_TICKET t
JOIN bus.BUS_TRIP_STOP bts ON bts.schedule_id = t.schedule_id
                           AND bts.stop_id     = t.to_stop_id
WHERE t.status = 'USED'
AND   t.is_deleted = FALSE
AND   t.schedule_id IS NOT NULL;

-- ================================================================
--  17. BUS_TRAVELLING_IN  (real-time passengers on buses)
-- ================================================================

INSERT INTO bus.BUS_TRAVELLING_IN
    (passenger_id, schedule_id, stop_sequence,
     ticket_id, boarded_at, status)
SELECT
    p.passenger_id,
    bsc.schedule_id,
    bts.stop_sequence,
    t.ticket_id,
    NOW() - INTERVAL '20 minutes',
    'ON_BUS'
FROM (VALUES
    ('Priya Patel',    'BRTS-001','BRTS-VASNA'),
    ('Rohan Mehta',    'AMTS-001','AMTS-LDWJ'),
    ('Sneha Desai',    'GSRTC-003','GSRTC-AHBS'),
    ('Raj Solanki',    'AMTS-005','AMTS-LDWJ'),
    ('Nisha Agrawal',  'GSRTC-001','BUS-MTSB'),
    ('Vihaan Shah',    'AMTS-001','AMTS-LDWJ'),
    ('Aadhya Patel',   'AMTS-001','AMTS-LDWJ'),
    ('Meera Rana',     'BRTS-001','BRTS-VASNA'),
    ('Kantibhai Shah', 'AMTS-010','AMTS-SABAR'),
    ('Bhavesh Kumar',  'GSRTC-001','GSRTC-AHBS'),
    ('Karan Joshi',    'AMTS-007','AMTS-KALP'),
    ('Anjali Mishra',  'AMTS-003','AMTS-LDWJ'),
    ('Diya Sharma',    'AMTS-005','AMTS-LDWJ'),
    ('Aarav Shah',     'GSRTC-002','GSRTC-AHBS'),
    ('Bhavesh Kumar',  'GSRTC-002','AMTS-CHANDH')
) AS v(pname, bus_num, stop_code)
JOIN metro.PASSENGER      p    ON p.full_name     = v.pname
JOIN bus.BUS              b    ON b.bus_number    = v.bus_num
JOIN bus.BUS_SCHEDULE     bsc  ON bsc.bus_id      = b.bus_id
                               AND bsc.direction  = 'FORWARD'
                               AND bsc.is_deleted = FALSE
JOIN bus.BUS_STOP         st   ON st.stop_code    = v.stop_code
JOIN bus.BUS_TRIP_STOP    bts  ON bts.schedule_id = bsc.schedule_id
                               AND bts.stop_id    = st.stop_id
LEFT JOIN bus.BUS_TICKET  t    ON t.passenger_id  = p.passenger_id
                               AND t.status NOT IN ('CANCELLED','EXPIRED','USED')
                               AND t.is_deleted   = FALSE
ORDER BY p.passenger_id
LIMIT 15;

-- ================================================================
--  18. COMBINED_JOURNEY  (10 multi-modal journeys)
--  Shows real Metro+Bus route combinations used by passengers
-- ================================================================

INSERT INTO bus.COMBINED_JOURNEY
    (passenger_id, journey_type,
     from_location_name, from_lat, from_lng,
     to_location_name, to_lat, to_lng,
     total_fare, total_distance_km, total_eta_mins,
     journey_date, status)
SELECT
    p.passenger_id,
    v.journey_type::bus.journey_type_t,
    v.from_loc, v.from_lat, v.from_lng,
    v.to_loc,   v.to_lat,  v.to_lng,
    v.total_fare, v.total_dist, v.total_eta,
    CURRENT_DATE,
    v.status
FROM (VALUES
    -- Metro + Bus: Vastral Gam Metro → Infocity (Metro to Motera, Bus to Infocity)
    ('Aarav Shah',
     'METRO_THEN_BUS',
     'Vastral Gam', 23.0961, 72.5356,
     'Infocity Gandhinagar', 23.1231, 72.5389,
     75.00, 38.40, 85, 'COMPLETED'),

    -- Bus + Metro: Lal Darwaja → GNLU (Bus to Motera Metro, Metro to GNLU)
    ('Bhavesh Kumar',
     'BUS_THEN_METRO',
     'Lal Darwaja', 23.0248, 72.5844,
     'GNLU Gandhinagar', 23.1489, 72.5254,
     83.00, 35.20, 95, 'COMPLETED'),

    -- Direct Metro: Vastral Gam → Thaltej
    ('Priya Patel',
     'METRO_ONLY',
     'Vastral Gam', 23.0021, 72.6421,
     'Thaltej', 23.0913, 72.5412,
     35.00, 21.23, 45, 'COMPLETED'),

    -- Direct Bus: Ahmedabad → Gandhinagar (GSRTC Express)
    ('Rohan Mehta',
     'BUS_ONLY',
     'Geeta Mandir BS', 23.0371, 72.6134,
     'Sector-10 Gandhinagar', 23.2019, 72.6819,
     65.00, 33.00, 70, 'COMPLETED'),

    -- Metro + Bus: Kalupur → Mahatma Mandir
    ('Nisha Agrawal',
     'METRO_THEN_BUS',
     'Kalupur', 23.0269, 72.5874,
     'Mahatma Mandir', 23.2572, 72.4608,
     105.00, 55.30, 120, 'IN_PROGRESS'),

    -- Bus + Metro + Bus: Narol → GIFT City
    ('Sneha Desai',
     'BUS_METRO_BUS',
     'Narol', 22.9680, 72.6298,
     'GIFT City', 23.1683, 72.6712,
     108.00, 48.20, 130, 'PLANNED'),

    -- Metro only: APMC → Motera
    ('Ramanlal Trivedi',
     'METRO_ONLY',
     'APMC Vasna', 22.9892, 72.5603,
     'Motera Stadium', 23.1042, 72.5467,
     32.50, 18.10, 40, 'COMPLETED'),

    -- Bus then Metro: Navrangpura BRTS → GNLU (Bus BRTS-2 to OHC, Metro to GNLU)
    ('Diya Sharma',
     'BUS_THEN_METRO',
     'Navrangpura', 23.0620, 72.5679,
     'GNLU Gandhinagar', 23.1489, 72.5254,
     43.00, 24.40, 70, 'COMPLETED'),

    -- Tourist: Ahmedabad → Mahatma Mandir (GSRTC)
    ('James Wilson',
     'BUS_ONLY',
     'Geeta Mandir BS', 23.0371, 72.6134,
     'Mahatma Mandir GN', 23.2572, 72.4608,
     80.00, 36.50, 90, 'PLANNED'),

    -- Metro + Bus: Paldi → Infocity (Metro to Motera, then GSRTC)
    ('Raj Solanki',
     'METRO_THEN_BUS',
     'Paldi', 23.0211, 72.5538,
     'Infocity Gandhinagar', 23.1231, 72.5389,
     55.00, 28.80, 80, 'COMPLETED')
) AS v(pname, journey_type, from_loc, from_lat, from_lng,
       to_loc, to_lat, to_lng, total_fare, total_dist, total_eta, status)
JOIN metro.PASSENGER p ON p.full_name = v.pname;

-- ================================================================
--  19. COMBINED_JOURNEY_LEG  (legs for each combined journey)
-- ================================================================

-- Journey 1: Vastral Gam → Infocity (Metro then Bus)
INSERT INTO bus.COMBINED_JOURNEY_LEG
    (journey_id, leg_sequence, mode,
     metro_schedule_id, bus_schedule_id, interchange_id,
     from_stop_name, to_stop_name,
     from_lat, from_lng, to_lat, to_lng,
     departure_time, arrival_time,
     leg_distance_km, leg_fare, leg_eta_mins, crowd_level)
SELECT
    cj.journey_id, 1, 'METRO',
    ts.schedule_id, NULL, NULL,
    'Vastral Gam Metro', 'Motera Stadium Metro',
    23.0961, 72.5356, 23.1042, 72.5467,
    ts.departure_time, ts.arrival_time,
    21.23, 35.00, 45, 'LOW'
FROM bus.COMBINED_JOURNEY cj
JOIN metro.PASSENGER p ON p.passenger_id = cj.passenger_id
                       AND p.full_name = 'Aarav Shah'
JOIN metro.TRAIN_SCHEDULE ts ON ts.schedule_status = 'ACTIVE'
                             AND ts.is_deleted = FALSE
                             AND ts.day_type = 'WEEKDAY'
WHERE cj.journey_type = 'METRO_THEN_BUS'
LIMIT 1;

INSERT INTO bus.COMBINED_JOURNEY_LEG
    (journey_id, leg_sequence, mode,
     metro_schedule_id, bus_schedule_id, interchange_id,
     from_stop_name, to_stop_name,
     from_lat, from_lng, to_lat, to_lng,
     leg_distance_km, leg_fare, leg_eta_mins, crowd_level)
SELECT
    cj.journey_id, 2, 'INTERCHANGE',
    NULL, NULL, ip.interchange_id,
    'Motera Stadium Metro', 'Motera Bus Stop',
    23.1042, 72.5467, 23.1045, 72.5465,
    0.10, 0.00, 2, 'LOW'
FROM bus.COMBINED_JOURNEY cj
JOIN metro.PASSENGER p ON p.passenger_id = cj.passenger_id AND p.full_name = 'Aarav Shah'
JOIN bus.INTERCHANGE_POINT ip ON ip.metro_station_id = (
    SELECT station_id FROM metro.STATION WHERE station_code = 'MTS')
WHERE cj.journey_type = 'METRO_THEN_BUS' LIMIT 1;

INSERT INTO bus.COMBINED_JOURNEY_LEG
    (journey_id, leg_sequence, mode,
     metro_schedule_id, bus_schedule_id, interchange_id,
     from_stop_name, to_stop_name,
     from_lat, from_lng, to_lat, to_lng,
     departure_time, arrival_time,
     leg_distance_km, leg_fare, leg_eta_mins, crowd_level)
SELECT
    cj.journey_id, 3, 'BUS',
    NULL, bsc.schedule_id, NULL,
    'Motera Bus Stop', 'Infocity Bus Stop',
    23.1045, 72.5465, 23.1231, 72.5389,
    bsc.departure_time, bsc.arrival_time,
    7.50, 20.00, 25, 'LOW'
FROM bus.COMBINED_JOURNEY cj
JOIN metro.PASSENGER p ON p.passenger_id = cj.passenger_id AND p.full_name = 'Aarav Shah'
JOIN bus.BUS_SCHEDULE bsc ON bsc.is_deleted = FALSE
JOIN bus.BUS_ROUTE r ON r.route_id = bsc.route_id AND r.route_number = 'GN-001'
WHERE cj.journey_type = 'METRO_THEN_BUS' LIMIT 1;

-- Journey 5: Kalupur → Mahatma Mandir (Metro + Bus) — currently IN_PROGRESS
INSERT INTO bus.COMBINED_JOURNEY_LEG
    (journey_id, leg_sequence, mode,
     metro_schedule_id, bus_schedule_id, interchange_id,
     from_stop_name, to_stop_name,
     from_lat, from_lng, to_lat, to_lng,
     leg_distance_km, leg_fare, leg_eta_mins, crowd_level)
SELECT
    cj.journey_id, v.leg_seq, v.mode::TEXT,
    NULL, NULL, NULL,
    v.from_stn, v.to_stn,
    v.f_lat, v.f_lng, v.t_lat, v.t_lng,
    v.dist, v.fare, v.eta, v.crowd
FROM bus.COMBINED_JOURNEY cj
JOIN metro.PASSENGER p ON p.passenger_id = cj.passenger_id AND p.full_name = 'Nisha Agrawal'
CROSS JOIN (VALUES
    (1,'METRO','Kalupur Metro','Motera Stadium Metro',
     23.0269,72.5874,23.1042,72.5467,18.10,20.00,40,'LOW'),
    (2,'INTERCHANGE','Motera Metro','Motera Bus Stop',
     23.1042,72.5467,23.1045,72.5465,0.10,0.00,3,'LOW'),
    (3,'BUS','Motera Bus Stop','Mahatma Mandir Bus Stand',
     23.1045,72.5465,23.2572,72.4608,35.10,50.00,65,'MODERATE')
) AS v(leg_seq,mode,from_stn,to_stn,f_lat,f_lng,t_lat,t_lng,
       dist,fare,eta,crowd)
WHERE cj.journey_type = 'METRO_THEN_BUS'
AND   cj.to_location_name LIKE '%Mahatma%'
LIMIT 3;

-- Verify Part 3
DO $$
BEGIN
    RAISE NOTICE '=== BUS INSERT PART 3 COMPLETE ===';
    RAISE NOTICE 'BUS_TICKET          : %', (SELECT COUNT(*) FROM bus.BUS_TICKET);
    RAISE NOTICE 'BUS_PAYMENT         : %', (SELECT COUNT(*) FROM bus.BUS_PAYMENT);
    RAISE NOTICE 'BUS_TRAVEL_PASS     : %', (SELECT COUNT(*) FROM bus.BUS_TRAVEL_PASS);
    RAISE NOTICE 'BUS_STOP_SCAN       : %', (SELECT COUNT(*) FROM bus.BUS_STOP_SCAN);
    RAISE NOTICE 'BUS_TRAVELLING_IN   : %', (SELECT COUNT(*) FROM bus.BUS_TRAVELLING_IN);
    RAISE NOTICE 'COMBINED_JOURNEY    : %', (SELECT COUNT(*) FROM bus.COMBINED_JOURNEY);
    RAISE NOTICE 'COMBINED_JOURNEY_LEG: %', (SELECT COUNT(*) FROM bus.COMBINED_JOURNEY_LEG);
END $$;


-- ================================================================
--  AHMEDABAD YATRA — BUS SYSTEM DUMMY DATA PART 4 (FINAL)
--  Tables: BUS_DELAY_EVENT → BUS_RESCHEDULE_LOG → BUS_INCIDENT
--          → BUS_LIVE_TRACKING → BUS_ALERT → BUS_MAINTENANCE_LOG
--          → BUS_FEEDBACK
-- ================================================================

SET search_path TO bus, metro, public;

-- ================================================================
--  20. BUS_DELAY_EVENT  (16 delay records — varied causes)
-- ================================================================

INSERT INTO bus.BUS_DELAY_EVENT
    (schedule_id, affected_stop_id, delay_minutes,
     reason, delay_category, resolution_status,
     reported_at, resolved_at, resolved_by, resolution_notes)
SELECT
    bsc.schedule_id,
    st.stop_id,
    v.delay_mins,
    v.reason,
    v.category,
    v.res_status::bus.delay_resolution_t,
    NOW() - (v.reported_ago || ' minutes')::INTERVAL,
    CASE WHEN v.res_status = 'RESOLVED'
         THEN NOW() - ((v.reported_ago - v.delay_mins) || ' minutes')::INTERVAL
         ELSE NULL END,
    CASE WHEN v.res_status = 'RESOLVED' THEN 'Operations Controller' ELSE NULL END,
    CASE WHEN v.res_status = 'RESOLVED' THEN 'Issue cleared. Service resumed.' ELSE NULL END
FROM (VALUES
    -- AMTS Route 37 delays
    ('AMTS-001','AMTS-MANIK', 15,'Heavy traffic at Maninagar signal',
     'TRAFFIC',   'RESOLVED', 90),
    ('AMTS-002','AMTS-LDWJ',  10,'Passenger medical emergency on board',
     'PASSENGER', 'RESOLVED', 60),
    ('AMTS-001','AMTS-KKNR',  20,'Road accident near Kankaria — diversion required',
     'TRAFFIC',   'RESOLVED', 180),

    -- AMTS Route 52 delays
    ('AMTS-005','AMTS-USMNP',  8,'Bus breakdown — engine overheating',
     'BREAKDOWN',  'RESOLVED', 75),
    ('AMTS-006','AMTS-CHANDH',12,'School zone crowd — children crossing',
     'PASSENGER',  'RESOLVED', 45),

    -- AMTS Route 81 delay
    ('AMTS-007','BRTS-ISKON',  5,'Red light malfunction at ISKON junction',
     'TRAFFIC',    'RESOLVED', 30),

    -- BRTS delays
    ('BRTS-001','BRTS-PKWY',  18,'Road works on S.G. Highway — lane closed',
     'TRAFFIC',    'IN_PROGRESS', 25),
    ('BRTS-004','BRTS-GITAM', 25,'BRTS station door mechanism failure',
     'BREAKDOWN',  'IN_PROGRESS', 40),
    ('BRTS-002','BRTS-THLT',   7,'Crowd spill at Thaltej BRTS during peak hours',
     'PASSENGER',  'RESOLVED', 55),

    -- GSRTC delays
    ('GSRTC-001','BUS-MTSB',  30,'Police barricade near Motera — Ahmedabad-Gandhinagar Highway',
     'TRAFFIC',    'RESOLVED', 120),
    ('GSRTC-003','GSRTC-INF', 15,'Traffic jam on Infocity Road — IT park shift end',
     'TRAFFIC',    'RESOLVED', 90),
    ('GSRTC-001','AMTS-CHANDH',20,'Truck accident near Chandkheda — major delay',
     'ACCIDENT',   'RESOLVED', 200),
    ('GSRTC-002','GSRTC-STBS',  8,'VIP convoy at Gandhinagar Secretariat',
     'TRAFFIC',    'RESOLVED', 50),

    -- Night service delay
    ('GSRTC-005','GSRTC-AHBS', 25,'Bus driver late to report — staff shortage',
     'OPERATIONAL','RESOLVED', 180),

    -- Weather delays
    ('AMTS-003','AMTS-GMND',  45,'Heavy rain — visibility poor on Drive-In Road',
     'WEATHER',    'RESOLVED', 720),
    ('BRTS-005','BRTS-NAVM',  35,'Waterlogging at Navrangpura underpass',
     'WEATHER',    'CLOSED',   1440)

) AS v(bus_num, stop_code, delay_mins, reason,
       category, res_status, reported_ago)
JOIN bus.BUS           b   ON b.bus_number   = v.bus_num
JOIN bus.BUS_SCHEDULE  bsc ON bsc.bus_id     = b.bus_id
                           AND bsc.is_deleted = FALSE
JOIN bus.BUS_STOP      st  ON st.stop_code   = v.stop_code
ORDER BY bsc.schedule_id LIMIT 16;

-- Mark schedules with pending delays as DELAYED
UPDATE bus.BUS_SCHEDULE
SET    schedule_status = 'DELAYED',
       updated_at      = NOW()
WHERE  schedule_id IN (
    SELECT DISTINCT schedule_id FROM bus.BUS_DELAY_EVENT
    WHERE  resolution_status IN ('PENDING','IN_PROGRESS')
);

-- ================================================================
--  21. BUS_RESCHEDULE_LOG  (10 reschedule records)
-- ================================================================

INSERT INTO bus.BUS_RESCHEDULE_LOG
    (schedule_id, reason,
     original_dep_time, new_dep_time,
     original_arr_time, new_arr_time,
     done_by, logged_at)
SELECT
    bsc.schedule_id,
    v.reason,
    bsc.departure_time,
    (bsc.departure_time + (v.delay_add || ' minutes')::INTERVAL)::TIME,
    bsc.arrival_time,
    (bsc.arrival_time + (v.delay_add || ' minutes')::INTERVAL)::TIME,
    'Operations Controller — AMTS/BRTS/GSRTC',
    NOW() - (v.logged_ago || ' minutes')::INTERVAL
FROM (VALUES
    ('AMTS-001', 15, 'Traffic delay — Maninagar diversion', 95),
    ('AMTS-001', 20, 'Road accident near Kankaria', 185),
    ('AMTS-005',  8, 'Engine overheating — cooldown stop', 80),
    ('BRTS-001', 18, 'S.G. Highway roadworks — single lane', 30),
    ('BRTS-004', 25, 'BRTS station door failure at Gitam', 45),
    ('GSRTC-001',30, 'Police barricade — Motera Stadium event', 125),
    ('GSRTC-003',15, 'IT park peak traffic at Infocity junction', 95),
    ('GSRTC-001',20, 'Truck accident — Chandkheda NH48', 205),
    ('AMTS-003', 45, 'Heavy rain — Drive-In Road flooding', 725),
    ('BRTS-005', 35, 'Waterlogging — Navrangpura underpass closed', 1445)
) AS v(bus_num, delay_add, reason, logged_ago)
JOIN bus.BUS          b   ON b.bus_number   = v.bus_num
JOIN bus.BUS_SCHEDULE bsc ON bsc.bus_id     = b.bus_id
                          AND bsc.is_deleted = FALSE
ORDER BY bsc.schedule_id LIMIT 10;

-- ================================================================
--  22. BUS_INCIDENT  (10 incident records)
-- ================================================================

INSERT INTO bus.BUS_INCIDENT
    (bus_id, schedule_id, near_stop_id,
     incident_type, incident_datetime,
     location_desc, location_lat, location_lng,
     severity_level, status,
     replacement_bus_id,
     reported_by, root_cause, corrective_action,
     contained_at, resolved_at, notes)
SELECT
    b.bus_id,
    bsc.schedule_id,
    st.stop_id,
    v.inc_type::bus.incident_type_t,
    NOW() - (v.days_ago || ' days')::INTERVAL,
    v.location_desc,
    st.latitude + 0.001,
    st.longitude + 0.001,
    v.severity,
    v.status::bus.incident_status_t,
    rb.bus_id,
    v.reported_by,
    v.root_cause,
    v.corrective_action,
    CASE WHEN v.status NOT IN ('OPEN')
         THEN NOW() - (v.days_ago - 0.3 || ' days')::INTERVAL ELSE NULL END,
    CASE WHEN v.status IN ('RESOLVED','CLOSED')
         THEN NOW() - (v.days_ago - 0.5 || ' days')::INTERVAL ELSE NULL END,
    v.notes
FROM (VALUES
    ('AMTS-005','AMTS-USMNP','BREAKDOWN',
     'Engine overheating — complete coolant loss near Usmanpura',
     7, 2,'CLOSED',NULL,
     'Coolant hose rupture due to age (7 years)',
     'Hose replaced, coolant system flushed and refilled',
     'AMTS-006 deployed as replacement',
     'Conductor','Bus towed to depot, passengers transferred'),

    ('BRTS-003','BRTS-PKWY','MECHANICAL',
     'Air suspension failure at Pakwan BRTS station',
     14, 2,'CLOSED',NULL,
     'Air suspension compressor failure — seal worn out',
     'Compressor and seals replaced',
     'BRTS-002 deployed as replacement',
     'Driver','Bus could not kneel for wheelchair boarding'),

    ('AMTS-001','AMTS-KKNR','ACCIDENT',
     'Sideswipe with autorickshaw near Kankaria',
     21, 2,'CLOSED',NULL,
     'Driver misjudged narrow lane near Kankaria Gate',
     'Driver counselled, defensive driving refresher completed',
     NULL,'Depot Manager','Minor damage to front bumper, no injuries'),

    ('GSRTC-001','BUS-MTSB','BREAKDOWN',
     'Gearbox failure on Gandhinagar Highway near Motera',
     30, 3,'RESOLVED',NULL,
     'Gearbox synchroniser worn out — high mileage (180,000 km)',
     'Gearbox replaced with new unit under warranty',
     'GSRTC-002 deployed immediately',
     'Driver','Passengers transferred, 30 min delay'),

    ('BRTS-004','BRTS-NAVM','PASSENGER_INCIDENT',
     'Passenger fell during emergency braking at Navrangpura',
     45, 2,'CLOSED',NULL,
     'Emergency braking due to jaywalker — passenger not holding handle',
     'Announcement added to hold handles at all times',
     NULL,'Station Master','Minor bruise, first aid administered'),

    ('AMTS-003','AMTS-GMND','BREAKDOWN',
     'Bus electrical failure during heavy rain at Geeta Mandir',
     60, 1,'CLOSED',NULL,
     'Water ingress in electrical panel during monsoon flooding',
     'Waterproofing upgraded on all electrical panels',
     NULL,'Depot Manager','Service suspended for 45 min'),

    ('GSRTC-003','GSRTC-INF','MECHANICAL',
     'Brake fade on steep section near Infocity ramp',
     90, 3,'RESOLVED',NULL,
     'Overheated brakes after continuous use on gradient',
     'Brake fluid replaced, brake discs resurfaced',
     'GSRTC-004 deployed as replacement',
     'Driver','Speed restriction applied until resolved'),

    ('AMTS-007','BRTS-ISKON','FIRE',
     'Minor engine bay fire at ISKON BRTS station',
     120,4,'RESOLVED',NULL,
     'Oil leak onto hot exhaust manifold caused small fire',
     'Engine bay fire suppression serviced, oil seal replaced',
     'AMTS-008 deployed immediately',
     'Passenger','Fire extinguished in 3 min, no injuries'),

    ('BRTS-001','BRTS-VASNA','BREAKDOWN',
     'Door mechanism failure — doors stuck open at Vasna terminus',
     3, 1,'OPEN',NULL,
     NULL, NULL, NULL,
     'Conductor','Bus taken out of service, maintenance team called'),

    ('GSRTC-005','GSRTC-AHBS','MECHANICAL',
     'Night service bus flat tyre at Geeta Mandir before departure',
     1, 1,'RESOLVED',NULL,
     'Tyre wall crack due to age',
     'Spare tyre fitted, damaged tyre replaced',
     NULL,'Depot Manager','30 min departure delay for night service')

) AS v(bus_num, stop_code, inc_type, location_desc,
       days_ago, severity, status, repl_bus,
       root_cause, corrective_action, repl_notes, reported_by, notes)
JOIN bus.BUS          b   ON b.bus_number   = v.bus_num
JOIN bus.BUS_SCHEDULE bsc ON bsc.bus_id     = b.bus_id
                          AND bsc.is_deleted = FALSE
JOIN bus.BUS_STOP     st  ON st.stop_code   = v.stop_code
LEFT JOIN bus.BUS     rb  ON rb.bus_number  = v.repl_notes
                          AND rb.is_deleted = FALSE
ORDER BY b.bus_id LIMIT 10;

-- ================================================================
--  23. BUS_MAINTENANCE_LOG  (16 maintenance records)
-- ================================================================

INSERT INTO bus.BUS_MAINTENANCE_LOG
    (bus_id, maintenance_type, maintenance_date, description,
     parts_replaced, vendor_name,
     estimated_cost, actual_cost,
     performed_by, status,
     scheduled_start, actual_start, completed_at, next_due_date)
SELECT
    b.bus_id,
    v.maint_type,
    CURRENT_DATE - (v.days_ago || ' days')::INTERVAL,
    v.description,
    v.parts_replaced,
    v.vendor,
    v.est_cost, v.act_cost,
    v.performed_by,
    v.status::bus.maint_status_t,
    (CURRENT_DATE - (v.days_ago || ' days')::INTERVAL)::TIMESTAMP,
    CASE WHEN v.status != 'SCHEDULED'
         THEN (CURRENT_DATE - (v.days_ago || ' days')::INTERVAL
               + INTERVAL '2 hours')::TIMESTAMP ELSE NULL END,
    CASE WHEN v.status = 'COMPLETED'
         THEN (CURRENT_DATE - (v.days_ago || ' days')::INTERVAL
               + INTERVAL '6 hours')::TIMESTAMP ELSE NULL END,
    CURRENT_DATE + (v.next_due || ' days')::INTERVAL
FROM (VALUES
    ('AMTS-001','ROUTINE_INSPECTION',0,
     'Daily pre-service inspection — tyres, brakes, lights, horn, mirrors',
     NULL,'AMTS Depot',3000.00,2800.00,'Depot Technician','COMPLETED',1),

    ('AMTS-002','ROUTINE_INSPECTION',1,
     'Daily pre-service inspection — all clear',
     NULL,'AMTS Depot',3000.00,3000.00,'Depot Technician','COMPLETED',1),

    ('BRTS-001','PREVENTIVE',7,
     'Weekly brake inspection and air suspension check',
     'Brake pads (set of 8)','TATA Authorized Service',
     25000.00,23500.00,'TATA Service Engineer','COMPLETED',7),

    ('GSRTC-001','PREVENTIVE',14,
     'Fortnightly engine oil change and filter replacement',
     'Engine oil (20L), oil filter, air filter',
     'Volvo Authorized Service',
     18000.00,17200.00,'Volvo Engineer','COMPLETED',14),

    ('AMTS-005','CORRECTIVE',7,
     'Coolant hose replacement after engine overheating incident',
     'Coolant hose set, coolant 10L, thermostat',
     'Tata Motors Authorized',
     35000.00,32000.00,'Tata Service Engineer','COMPLETED',30),

    ('BRTS-003','CORRECTIVE',14,
     'Air suspension compressor replacement',
     'Air compressor unit, seals, air lines',
     'Tata Starbus Service Centre',
     85000.00,82000.00,'Tata Service Engineer','COMPLETED',90),

    ('GSRTC-001','CORRECTIVE',30,
     'Gearbox replacement after complete failure',
     'Gearbox assembly (reconditioned), gear linkages',
     'Volvo Authorized Service',
     280000.00,265000.00,'Volvo Senior Engineer','COMPLETED',180),

    ('AMTS-007','CORRECTIVE',120,
     'Engine bay fire damage repair and oil seal replacement',
     'Oil seal set, exhaust heat shield, wiring harness section',
     'Tata Motors Authorized',
     95000.00,88000.00,'Tata Service Engineer','COMPLETED',30),

    ('BRTS-004','PREVENTIVE',21,
     'Monthly BRTS station door mechanism lubrication and calibration',
     'Door roller bearings, lubricant',
     'BRTS Maintenance Team',
     12000.00,11000.00,'BRTS Engineer','COMPLETED',30),

    ('GSRTC-003','CORRECTIVE',90,
     'Brake fluid replacement and disc resurfacing after brake fade',
     'Brake fluid (4L), brake discs (2 front)',
     'Scania Authorized Service',
     45000.00,42000.00,'Scania Engineer','COMPLETED',90),

    ('AMTS-009','ROUTINE_INSPECTION',0,
     'Daily EV bus check — battery level, charging port, motor temp',
     NULL,'TATA EV Service',5000.00,4800.00,'EV Technician','COMPLETED',1),

    ('AMTS-010','PREVENTIVE',30,
     'Monthly EV battery health check and regenerative brake calibration',
     'Battery cell diagnostic, brake calibration kit',
     'TATA EV Service',
     15000.00,14500.00,'EV Senior Technician','COMPLETED',30),

    ('GSRTC-002','ROUTINE_INSPECTION',2,
     'Weekly deep clean + interior check for intercity bus',
     'Seat covers (2 damaged), AC filter',
     'GSRTC Depot',
     8000.00,7500.00,'GSRTC Technician','COMPLETED',7),

    ('BRTS-001','CLEANING',0,
     'End-of-day full bus disinfection and floor cleaning',
     NULL,'BRTS Housekeeping',2000.00,2000.00,'Cleaning Staff','COMPLETED',1),

    ('GSRTC-004','OVERHAUL',-30,
     'Mid-life overhaul — complete mechanical inspection at 150,000 km',
     'Clutch assembly, all filters, belts, hoses, brake pads full set',
     'Volvo Authorized Service',
     350000.00,NULL,'Volvo Senior Engineer','IN_PROGRESS',365),

    -- Scheduled future maintenance
    ('AMTS-003','PREVENTIVE',-14,
     'Quarterly tyre rotation and wheel alignment',
     NULL,'AMTS Depot',12000.00,NULL,'Depot Technician','SCHEDULED',90)
) AS v(bus_num, maint_type, days_ago, description,
       parts_replaced, vendor, est_cost, act_cost,
       performed_by, status, next_due)
JOIN bus.BUS b ON b.bus_number = v.bus_num;

-- ================================================================
--  24. BUS_LIVE_TRACKING  (GPS pings for all ON_ROUTE buses)
-- ================================================================

DO $bgps$
DECLARE
    v_bus    RECORD;
    v_sched  INT;
    i        INT;
    v_lat    NUMERIC(9,6);
    v_lng    NUMERIC(9,6);
    v_speed  NUMERIC(5,2);
BEGIN
    FOR v_bus IN
        SELECT b.bus_id, b.bus_number,
               b.current_lat, b.current_lng
        FROM   bus.BUS b
        WHERE  b.operational_status = 'ON_ROUTE'
        AND    b.is_deleted         = FALSE
        ORDER  BY b.bus_id
    LOOP
        SELECT bsc.schedule_id INTO v_sched
        FROM   bus.BUS_SCHEDULE bsc
        WHERE  bsc.bus_id         = v_bus.bus_id
        AND    bsc.schedule_status IN ('ACTIVE','DELAYED')
        AND    bsc.is_deleted     = FALSE
        LIMIT  1;

        v_lat   := COALESCE(v_bus.current_lat,  23.0298);
        v_lng   := COALESCE(v_bus.current_lng,  72.5556);
        v_speed := 18.0 + (RANDOM() * 20 - 5)::NUMERIC(5,2);

        FOR i IN REVERSE 10..1 LOOP
            INSERT INTO bus.BUS_LIVE_TRACKING (
                bus_id, schedule_id,
                latitude, longitude, altitude_m, speed_kmph,
                heading_degrees,
                dist_to_next_stop_m,
                recorded_at, updated_eta
            ) VALUES (
                v_bus.bus_id,
                v_sched,
                v_lat + (i * 0.0004),
                v_lng + (i * 0.0003),
                52.0,
                GREATEST(0, v_speed + (RANDOM() * 6 - 3)::NUMERIC(5,2)),
                CASE WHEN v_bus.bus_number LIKE 'GSRTC%' THEN 15.0
                     WHEN v_bus.bus_number LIKE 'BRTS%'  THEN 90.0
                     ELSE 180.0 END,
                (200 + (RANDOM() * 800)::INT),
                NOW() - (i * 10 || ' seconds')::INTERVAL,
                NOW() + ((20 - i) || ' minutes')::INTERVAL
            );
        END LOOP;

        UPDATE bus.BUS
        SET    current_lat        = v_lat + 0.0004,
               current_lng        = v_lng + 0.0003,
               current_speed_kmph = v_speed,
               last_gps_update    = NOW(),
               updated_at         = NOW()
        WHERE  bus_id = v_bus.bus_id;
    END LOOP;

    RAISE NOTICE 'BUS_LIVE_TRACKING: GPS pings inserted for all ON_ROUTE buses.';
END $bgps$;

-- ================================================================
--  25. BUS_ALERT  (18 alerts across all operators)
-- ================================================================

INSERT INTO bus.BUS_ALERT
    (bus_id, schedule_id, route_id, stop_id,
     alert_type, severity, title, message,
     is_resolved, resolved_at, auto_expires_at,
     created_at)
SELECT
    b.bus_id,
    bsc.schedule_id,
    r.route_id,
    st.stop_id,
    v.alert_type::bus.alert_type_t,
    v.severity::bus.alert_severity_t,
    v.title,
    v.message,
    v.is_resolved,
    CASE WHEN v.is_resolved
         THEN NOW() - ((v.created_ago - 30) || ' minutes')::INTERVAL
         ELSE NULL END,
    NOW() + INTERVAL '4 hours',
    NOW() - (v.created_ago || ' minutes')::INTERVAL
FROM (VALUES
    ('AMTS-001','37','AMTS-MANIK','DELAY','WARNING',
     'Route 37: Delay at Maninagar',
     'AMTS Bus 001 (Route 37) delayed 15 min at Maninagar due to heavy traffic.',
     TRUE, 95),

    ('BRTS-001','BRTS-1','BRTS-PKWY','DELAY','WARNING',
     'BRTS-1: Road Works Delay — S.G. Highway',
     'BRTS Route 1 delayed 18 min near Pakwan crossroads due to lane closure.',
     FALSE, 30),

    ('BRTS-004','BRTS-2','BRTS-GITAM','DELAY','CRITICAL',
     'BRTS-2: Station Door Failure at Gitam',
     'BRTS-2 delayed 25 min. Door mechanism fault at Gitam station. Engineers on site.',
     FALSE, 45),

    ('GSRTC-001','GN-001','BUS-MTSB','DELAY','WARNING',
     'GN-001: Police Barricade Near Motera',
     'GSRTC Ahmedabad-Gandhinagar express delayed 30 min. Police check near Motera Stadium.',
     TRUE, 125),

    ('AMTS-003','105','AMTS-GMND','DELAY','CRITICAL',
     'Route 105: Heavy Rain — Service Disrupted',
     'Route 105 delayed 45 min. Heavy rainfall causing waterlogging on Drive-In Road.',
     TRUE, 725),

    ('BRTS-005','BRTS-2','BRTS-NAVM','DELAY','CRITICAL',
     'BRTS-2: Waterlogging — Navrangpura Underpass',
     'BRTS-2 severely delayed. Navrangpura underpass flooded. Buses taking alternate route.',
     FALSE, 1445),

    ('AMTS-007','81','BRTS-ISKON','EMERGENCY','CRITICAL',
     'EMERGENCY: Bus Fire at ISKON BRTS Station',
     'Minor engine bay fire at ISKON BRTS. Fire extinguished. Bus out of service. '
     'Next bus in 12 minutes. No injuries.',
     TRUE, 125),

    ('GSRTC-001','GN-001','AMTS-CHANDH','DELAY','WARNING',
     'GN-001: Truck Accident — Chandkheda',
     'GSRTC GN-001 delayed 20 min. Truck accident cleared. Service resuming normally.',
     TRUE, 205),

    ('AMTS-005','52','AMTS-USMNP','DELAY','WARNING',
     'Route 52: Breakdown at Usmanpura',
     'AMTS Bus 005 (Route 52) had engine issue at Usmanpura. '
     'Replacement bus AMTS-006 deployed. 8 min delay.',
     TRUE, 80),

    (NULL,NULL,'37','AMTS-LDWJ','HIGH_CROWD','INFO',
     'Route 37: High Demand at Lal Darwaja',
     'Lal Darwaja Bus Stand seeing high passenger volume. '
     'Next Route 37 bus in 8 minutes. Please queue in marked areas.',
     TRUE, 120),

    (NULL,NULL,'GN-001',NULL,'GENERAL','INFO',
     'GSRTC: Festival Day Extended Service',
     'GSRTC running additional trips on GN-001 and GN-002 routes for Navratri festival. '
     'Check app for extra timings.',
     TRUE, 1440),

    ('BRTS-003','BRTS-1',NULL,NULL,'CANCELLATION','WARNING',
     'BRTS-1: Bus BRTS-003 Cancelled',
     'Bus BRTS-003 out of service due to air suspension failure. '
     'BRTS-002 will cover the schedule. Minor delay expected.',
     TRUE, 720),

    (NULL,NULL,'GN-002',NULL,'ROUTE_CHANGE','INFO',
     'GN-002: Alternate Route via Sector-1',
     'GN-002 taking alternate route via Sector-1 Gandhinagar today. '
     'Infocity stop service unaffected.',
     FALSE, 60),

    ('AMTS-009','F1',NULL,NULL,'GENERAL','INFO',
     'EV Feeder F1: 100% Electric Service',
     'Metro feeder bus F1 (Vastral to Vastral Gam Metro) is now fully electric. '
     'Silent, clean, zero emissions!',
     TRUE, 4320),

    (NULL,NULL,'GN-NIGHT',NULL,'GENERAL','INFO',
     'Night Service: Last Bus at 05:00',
     'GSRTC Night Service (GN-NIGHT) runs Ahmedabad to Gandhinagar. '
     'Last departure from Geeta Mandir at 05:00.',
     TRUE, 2880),

    ('GSRTC-004','GN-003',NULL,NULL,'CANCELLATION','INFO',
     'GN-003: Bus Undergoing Overhaul Today',
     'GSRTC-004 undergoing mid-life overhaul. GN-003 route suspended today. '
     'Use GN-001 with connection at Motera.',
     FALSE, 480),

    (NULL,NULL,'BRTS-1',NULL,'GENERAL','INFO',
     'BRTS: Reduced Frequency on Sunday',
     'BRTS corridors running at 15-minute intervals on Sunday instead of 8 minutes.',
     TRUE, 4320),

    (NULL,NULL,'GN-001',NULL,'HIGH_CROWD','WARNING',
     'GN-001: Full Buses — Cricket Match at Motera',
     'GSRTC GN-001 buses full due to IPL match at Motera Stadium. '
     'Extra trips added at 14:30 and 15:00.',
     FALSE, 90)

) AS v(bus_num, route_no, op_code, stop_code,
       alert_type, severity, title, message, is_resolved, created_ago)
LEFT JOIN bus.BUS          b   ON b.bus_number   = v.bus_num
LEFT JOIN bus.BUS_OPERATOR op  ON op.operator_code = v.op_code
LEFT JOIN bus.BUS_ROUTE    r   ON r.route_number  = v.route_no
                               AND r.operator_id  = COALESCE(op.operator_id, r.operator_id)
LEFT JOIN bus.BUS_SCHEDULE bsc ON bsc.bus_id      = b.bus_id
                               AND bsc.is_deleted = FALSE
LEFT JOIN bus.BUS_STOP     st  ON st.stop_code    = v.stop_code;

-- ================================================================
--  26. BUS_FEEDBACK  (20 feedback entries)
-- ================================================================

INSERT INTO bus.BUS_FEEDBACK
    (passenger_id, schedule_id, route_id, stop_id, ticket_id,
     category, rating, comment, status,
     reviewed_by, review_notes, reviewed_at, submitted_at)
SELECT
    p.passenger_id,
    bsc.schedule_id,
    r.route_id,
    st.stop_id,
    t.ticket_id,
    v.category::metro.feedback_category_t,
    v.rating,
    v.comment,
    v.status,
    CASE WHEN v.status IN ('RESOLVED','CLOSED')
         THEN 'GSRTC/AMTS Customer Relations' ELSE NULL END,
    CASE WHEN v.status IN ('RESOLVED','CLOSED')
         THEN 'Thank you for your feedback. Issue addressed.' ELSE NULL END,
    CASE WHEN v.status IN ('RESOLVED','CLOSED')
         THEN NOW() - INTERVAL '1 day' ELSE NULL END,
    NOW() - (v.submitted_ago || ' hours')::INTERVAL
FROM (VALUES
    ('Aarav Shah',       'GN-001','GSRTC','GSRTC-AHBS','PUNCTUALITY',   5,
     'GSRTC GN-001 was exactly on time. Clean bus, comfortable seats. '
     'Great service Ahmedabad to Gandhinagar!',
     'CLOSED', 48),

    ('Priya Patel',      'BRTS-1','BRTS', 'BRTS-VASNA','CLEANLINESS',   4,
     'BRTS buses are clean and air-conditioned. Dedicated lane makes journey fast.',
     'CLOSED', 36),

    ('Rohan Mehta',      '37',   'AMTS', 'AMTS-LDWJ', 'PUNCTUALITY',   2,
     'Bus was 20 minutes late. No announcement or information given. '
     'Very inconvenient for daily commuters.',
     'RESOLVED', 24),

    ('Sneha Desai',      'GN-002','GSRTC','GSRTC-AHBS','STAFF_BEHAVIOUR',5,
     'Driver and conductor were very polite and helpful. '
     'Helped senior passenger with luggage. Excellent staff.',
     'CLOSED', 72),

    ('Karan Joshi',      'BRTS-2','BRTS', 'BRTS-GITAM','CROWD_MANAGEMENT',3,
     'Gitam BRTS station is very crowded during peak hours. '
     'Need more buses or larger buses on BRTS-2 corridor.',
     'IN_REVIEW', 12),

    ('Bhavesh Kumar',    'GN-001','GSRTC','GSRTC-AHBS','MOBILE_APP',    5,
     'Ahmedabad Yatra app is excellent. Real-time tracking and seat booking '
     'made my daily Gandhinagar commute so much easier.',
     'CLOSED', 96),

    ('Anjali Mishra',    '105',  'AMTS', 'AMTS-GMND', 'ACCESSIBILITY', 4,
     'Route 105 bus has low floor entry. Good for elderly passengers. '
     'But shelter at Geeta Mandir is too small.',
     'CLOSED', 60),

    ('Raj Solanki',      '52',   'AMTS', 'AMTS-LDWJ', 'PUNCTUALITY',   1,
     'Waited 35 minutes for Route 52. When bus came it was overfull. '
     'Frequency needs to improve urgently on this route.',
     'IN_REVIEW', 4),

    ('Nisha Agrawal',    'GN-002','GSRTC','GSRTC-INF', 'TICKETING',     5,
     'Monthly pass is very affordable for students. '
     'Saves significant money for Infocity college commute. Thank you GSRTC!',
     'CLOSED', 120),

    ('Diya Sharma',      '52',   'AMTS', 'AMTS-USMNP','CLEANLINESS',   3,
     'Seats have torn fabric on some buses. Please maintain interior '
     'cleanliness especially for morning runs.',
     'RESOLVED', 48),

    ('James Wilson',     'GN-002','GSRTC','GSRTC-MMBS','PUNCTUALITY',   4,
     'Very impressed with Ahmedabad public transport. '
     'GSRTC and Metro are well integrated. Easy to switch modes.',
     'CLOSED', 168),

    ('Yuki Tanaka',      'GN-003','GSRTC','GN-GIFT',   'MOBILE_APP',    4,
     'English language support in Ahmedabad Yatra app is helpful. '
     'Easily booked GSRTC ticket to GIFT City from my hotel.',
     'CLOSED', 240),

    ('Ramanlal Trivedi', 'GN-001','GSRTC','GSRTC-STBS','ACCESSIBILITY', 5,
     'Senior citizen monthly pass at ₹180 is a blessing. '
     'Driver waits patiently for elderly passengers to board. Praiseworthy.',
     'CLOSED', 72),

    ('Meera Rana',       'BRTS-1','BRTS', 'BRTS-VASNA','ACCESSIBILITY', 4,
     'BRTS buses have proper wheelchair space and kneeling feature. '
     'Very good for disabled passengers. Appreciated.',
     'RESOLVED', 24),

    ('Bhavesh Kumar',    'GN-001','GSRTC','BUS-MTSB',  'CROWD_MANAGEMENT',2,
     'On IPL match days GSRTC buses are completely packed. '
     'Need to plan extra buses proactively for match days.',
     'OPEN', 8),

    ('Anjali Mishra',    '37',   'AMTS', 'AMTS-KKNR', 'SAFETY',        5,
     'Felt very safe on Route 37. CCTV cameras visible in bus. '
     'Conductor was alert and professional throughout journey.',
     'CLOSED', 144),

    ('Aarav Shah',       'GN-002','GSRTC','GSRTC-INF', 'PUNCTUALITY',   3,
     'Bus was 15 minutes late at Infocity due to IT park traffic. '
     'This is daily problem at evening peak. Need dedicated pickup point.',
     'IN_REVIEW', 6),

    ('Sneha Desai',      'BRTS-1','BRTS', 'BRTS-THLT', 'CLEANLINESS',   5,
     'Thaltej BRTS station is beautifully maintained. '
     'Air-conditioned waiting area, clean platforms. Best BRTS station!',
     'CLOSED', 192),

    ('Kantibhai Shah',   '37',   'AMTS', 'AMTS-LDWJ', 'STAFF_BEHAVIOUR',5,
     'Freedom fighter pass always honoured respectfully. '
     'Conductor offers seat and greets with respect. Very grateful to AMTS.',
     'CLOSED', 336),

    ('Karan Joshi',      'BRTS-2','BRTS', 'BRTS-GITAM','SAFETY',        2,
     'The Gitam BRTS door failure today was scary. '
     'Doors stayed open for 2 stops! Safety checks must be more rigorous.',
     'IN_REVIEW', 2)

) AS v(pname, route_no, op_code, stop_code, category, rating,
       comment, status, submitted_ago)
JOIN  metro.PASSENGER    p   ON p.full_name       = v.pname
JOIN  bus.BUS_OPERATOR   op  ON op.operator_code  = v.op_code
JOIN  bus.BUS_ROUTE      r   ON r.route_number    = v.route_no
                             AND r.operator_id    = op.operator_id
JOIN  bus.BUS_SCHEDULE   bsc ON bsc.route_id      = r.route_id
                             AND bsc.direction     = 'FORWARD'
                             AND bsc.is_deleted    = FALSE
JOIN  bus.BUS_STOP       st  ON st.stop_code      = v.stop_code
LEFT JOIN bus.BUS_TICKET t   ON t.passenger_id    = p.passenger_id
                             AND t.is_deleted      = FALSE;

-- ================================================================
--  FINAL VERIFICATION — ALL BUS TABLES
-- ================================================================

DO $$
DECLARE
    v_operators INT; v_stops INT;    v_routes   INT;  v_rstops INT;
    v_buses     INT; v_fares  INT;   v_drivers  INT;  v_shifts INT;
    v_schedules INT; v_tstops INT;   v_das      INT;  v_icp    INT;
    v_tickets   INT; v_pays   INT;   v_passes   INT;  v_scans  INT;
    v_trvin     INT; v_delays INT;   v_rslogs   INT;  v_incs   INT;
    v_tracking  INT; v_alerts INT;   v_maint    INT;  v_fbk    INT;
    v_cj        INT; v_cjl    INT;
BEGIN
    SELECT COUNT(*) INTO v_operators FROM bus.BUS_OPERATOR;
    SELECT COUNT(*) INTO v_stops     FROM bus.BUS_STOP;
    SELECT COUNT(*) INTO v_routes    FROM bus.BUS_ROUTE;
    SELECT COUNT(*) INTO v_rstops    FROM bus.ROUTE_STOP;
    SELECT COUNT(*) INTO v_buses     FROM bus.BUS;
    SELECT COUNT(*) INTO v_fares     FROM bus.BUS_FARE_RULE;
    SELECT COUNT(*) INTO v_drivers   FROM bus.BUS_DRIVER;
    SELECT COUNT(*) INTO v_shifts    FROM bus.BUS_DRIVER_SHIFT;
    SELECT COUNT(*) INTO v_schedules FROM bus.BUS_SCHEDULE;
    SELECT COUNT(*) INTO v_tstops    FROM bus.BUS_TRIP_STOP;
    SELECT COUNT(*) INTO v_das       FROM bus.BUS_DRIVER_ASSIGNMENT;
    SELECT COUNT(*) INTO v_icp       FROM bus.INTERCHANGE_POINT;
    SELECT COUNT(*) INTO v_tickets   FROM bus.BUS_TICKET;
    SELECT COUNT(*) INTO v_pays      FROM bus.BUS_PAYMENT;
    SELECT COUNT(*) INTO v_passes    FROM bus.BUS_TRAVEL_PASS;
    SELECT COUNT(*) INTO v_scans     FROM bus.BUS_STOP_SCAN;
    SELECT COUNT(*) INTO v_trvin     FROM bus.BUS_TRAVELLING_IN;
    SELECT COUNT(*) INTO v_delays    FROM bus.BUS_DELAY_EVENT;
    SELECT COUNT(*) INTO v_rslogs    FROM bus.BUS_RESCHEDULE_LOG;
    SELECT COUNT(*) INTO v_incs      FROM bus.BUS_INCIDENT;
    SELECT COUNT(*) INTO v_tracking  FROM bus.BUS_LIVE_TRACKING;
    SELECT COUNT(*) INTO v_alerts    FROM bus.BUS_ALERT;
    SELECT COUNT(*) INTO v_maint     FROM bus.BUS_MAINTENANCE_LOG;
    SELECT COUNT(*) INTO v_fbk       FROM bus.BUS_FEEDBACK;
    SELECT COUNT(*) INTO v_cj        FROM bus.COMBINED_JOURNEY;
    SELECT COUNT(*) INTO v_cjl       FROM bus.COMBINED_JOURNEY_LEG;

    RAISE NOTICE '============================================================';
    RAISE NOTICE ' AHMEDABAD YATRA BUS SYSTEM — ALL DATA INSERTED';
    RAISE NOTICE '============================================================';
    RAISE NOTICE ' BUS_OPERATOR           : %', v_operators;
    RAISE NOTICE ' BUS_STOP               : %', v_stops;
    RAISE NOTICE ' BUS_ROUTE              : %', v_routes;
    RAISE NOTICE ' ROUTE_STOP             : %', v_rstops;
    RAISE NOTICE ' BUS                    : %', v_buses;
    RAISE NOTICE ' BUS_FARE_RULE          : %', v_fares;
    RAISE NOTICE ' BUS_DRIVER             : %', v_drivers;
    RAISE NOTICE ' BUS_DRIVER_SHIFT       : %', v_shifts;
    RAISE NOTICE ' BUS_SCHEDULE           : %', v_schedules;
    RAISE NOTICE ' BUS_TRIP_STOP          : %', v_tstops;
    RAISE NOTICE ' BUS_DRIVER_ASSIGNMENT  : %', v_das;
    RAISE NOTICE ' INTERCHANGE_POINT      : %', v_icp;
    RAISE NOTICE ' BUS_TICKET             : %', v_tickets;
    RAISE NOTICE ' BUS_PAYMENT            : %', v_pays;
    RAISE NOTICE ' BUS_TRAVEL_PASS        : %', v_passes;
    RAISE NOTICE ' BUS_STOP_SCAN          : %', v_scans;
    RAISE NOTICE ' BUS_TRAVELLING_IN      : %', v_trvin;
    RAISE NOTICE ' BUS_DELAY_EVENT        : %', v_delays;
    RAISE NOTICE ' BUS_RESCHEDULE_LOG     : %', v_rslogs;
    RAISE NOTICE ' BUS_INCIDENT           : %', v_incs;
    RAISE NOTICE ' BUS_LIVE_TRACKING      : %', v_tracking;
    RAISE NOTICE ' BUS_ALERT              : %', v_alerts;
    RAISE NOTICE ' BUS_MAINTENANCE_LOG    : %', v_maint;
    RAISE NOTICE ' BUS_FEEDBACK           : %', v_fbk;
    RAISE NOTICE ' COMBINED_JOURNEY       : %', v_cj;
    RAISE NOTICE ' COMBINED_JOURNEY_LEG   : %', v_cjl;
    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE ' Run: SELECT * FROM bus.fn_verify_bcnf();';
    RAISE NOTICE ' Run: SELECT * FROM bus.fn_get_all_routes(';
    RAISE NOTICE '        23.0961, 72.5356,  -- Vastral Gam';
    RAISE NOTICE '        23.1231, 72.5389,  -- Infocity';
    RAISE NOTICE '        ''11:00''::TIME, ''WEEKDAY'');';
    RAISE NOTICE '============================================================';
END $$;
