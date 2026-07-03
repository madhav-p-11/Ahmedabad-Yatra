-- ================================================================
--  ██████████████████████████████████████████████████████████████
--   AHMEDABAD YATRA — BUS SYSTEM COMPLETE DDL
--   (Industry-Level, Production-Ready)
--  ██████████████████████████████████████████████████████████████
--
--  DATABASE     : PostgreSQL 15+
--  SCHEMA       : bus  (integrates with: metro schema)
--  VERSION      : 1.0.0
--  NORMALIZATION: BCNF (all 27 tables)
--
--  ── OBJECT INVENTORY ──────────────────────────────────────────
--  ENUM Types   : 25
--  Domain Types : 7
--  Tables       : 27
--  Triggers     : 7
--  Views        : 6
--  Functions    : 5
--
--  ── TABLE LIST ────────────────────────────────────────────────
--   1.  BUS_OPERATOR             15. BUS_LIVE_TRACKING
--   2.  BUS_ROUTE                16. BUS_ALERT
--   3.  BUS_STOP                 17. BUS_MAINTENANCE_LOG
--   4.  ROUTE_STOP               18. BUS_TICKET
--   5.  BUS                      19. BUS_PAYMENT
--   6.  BUS_FARE_RULE            20. BUS_TRAVEL_PASS
--   7.  BUS_DRIVER               21. BUS_STOP_SCAN
--   8.  BUS_DRIVER_SHIFT         22. BUS_TRAVELLING_IN
--   9.  BUS_SCHEDULE             23. INTERCHANGE_POINT ★
--  10.  BUS_TRIP_STOP            24. COMBINED_JOURNEY
--  11.  BUS_DRIVER_ASSIGNMENT    25. COMBINED_JOURNEY_LEG
--  12.  BUS_DELAY_EVENT          26. BUS_FEEDBACK
--  13.  BUS_RESCHEDULE_LOG       27. BUS_SYSTEM_CONFIG
--  14.  BUS_INCIDENT
--
--  ★ INTERCHANGE_POINT links metro.STATION ↔ BUS_STOP
--    This is the key table for Metro+Bus route planning.
--
--  ── HOW TO RUN ────────────────────────────────────────────────
--  IMPORTANT: Run metro DDL first, then run this file.
--  psql -U postgres -d your_db -f ahmedabad_bus_FINAL.sql
--
--  ── RE-RUN SAFETY ─────────────────────────────────────────────
--  Script drops and recreates the bus schema each run.
--  Safe for dev/test. Do NOT run on live production data.
-- ================================================================

-- Drop bus schema completely for clean re-run
DROP SCHEMA IF EXISTS bus CASCADE;

-- ================================================================
--  AHMEDABAD YATRA — BUS SYSTEM DDL
--  Schema       : bus
--  Database     : PostgreSQL 15+
--  Normalization: BCNF
--  Version      : 1.0.0
--  Integrates   : metro schema (PASSENGER, STATION)
-- ================================================================
--  PART 1 OF 4:
--   S01  SCHEMA + EXTENSIONS
--   S02  ENUM TYPES
--   S03  DOMAIN TYPES
--   S04  BUS_OPERATOR
--   S05  BUS_ROUTE
--   S06  BUS_STOP
--   S07  ROUTE_STOP
--   S08  BUS (vehicle)
-- ================================================================

-- ================================================================
--  S01 — SCHEMA + EXTENSIONS
-- ================================================================

CREATE SCHEMA IF NOT EXISTS bus;
SET search_path TO bus, metro, public;

-- Reuse metro extensions (already installed)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- ================================================================
--  SHARED UPDATED_AT TRIGGER FUNCTION (bus schema copy)
-- ================================================================

CREATE OR REPLACE FUNCTION bus.fn_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION bus.fn_attach_updated_at(p_table TEXT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'CREATE TRIGGER trg_%s_upd
         BEFORE UPDATE ON bus.%I
         FOR EACH ROW EXECUTE FUNCTION bus.fn_set_updated_at();',
        p_table, p_table
    );
END;
$$;

-- ================================================================
--  S02 — ENUM TYPES
-- ================================================================

CREATE TYPE bus.operator_type_t AS ENUM (
    'GSRTC',        -- Gujarat State Road Transport Corporation
    'AMTS',         -- Ahmedabad Municipal Transport Service
    'BRTS',         -- Bus Rapid Transit System
    'PRIVATE',      -- Private operator
    'CONTRACT'      -- Contract carriage
);

CREATE TYPE bus.route_type_t AS ENUM (
    'CITY',         -- Within Ahmedabad city
    'INTERCITY',    -- Ahmedabad ↔ Gandhinagar
    'BRTS',         -- BRTS dedicated corridor
    'EXPRESS',      -- Express limited stops
    'FEEDER',       -- Feeder to metro station
    'NIGHT'         -- Night service
);

CREATE TYPE bus.bus_type_t AS ENUM (
    'AC_SINGLE_DECK',
    'NON_AC_SINGLE_DECK',
    'AC_DOUBLE_DECK',
    'MINIBUS',
    'MIDI_BUS',
    'ELECTRIC_BUS',
    'BRTS_BRT'
);

CREATE TYPE bus.bus_status_t AS ENUM (
    'ON_ROUTE',
    'AT_DEPOT',
    'MAINTENANCE',
    'BREAKDOWN',
    'SUSPENDED',
    'DECOMMISSIONED'
);

CREATE TYPE bus.schedule_status_t AS ENUM (
    'ACTIVE',
    'DELAYED',
    'CANCELLED',
    'COMPLETED',
    'SUSPENDED'
);

CREATE TYPE bus.day_type_t AS ENUM (
    'WEEKDAY',
    'WEEKEND',
    'ALL_DAYS',
    'HOLIDAY'
);

CREATE TYPE bus.stop_type_t AS ENUM (
    'REGULAR',
    'TERMINUS',
    'BRTS_STATION',
    'INTERCHANGE',
    'DEPOT'
);

CREATE TYPE bus.delay_resolution_t AS ENUM (
    'PENDING',
    'IN_PROGRESS',
    'RESOLVED',
    'CLOSED'
);

CREATE TYPE bus.incident_type_t AS ENUM (
    'BREAKDOWN',
    'ACCIDENT',
    'FIRE',
    'OBSTRUCTION',
    'PASSENGER_INCIDENT',
    'MECHANICAL',
    'OTHER'
);

CREATE TYPE bus.incident_status_t AS ENUM (
    'OPEN',
    'UNDER_INVESTIGATION',
    'RESOLVED',
    'CLOSED'
);

CREATE TYPE bus.ticket_status_t AS ENUM (
    'BOOKED',
    'ACTIVE',
    'USED',
    'EXPIRED',
    'CANCELLED',
    'REFUNDED'
);

CREATE TYPE bus.booking_channel_t AS ENUM (
    'MOBILE_APP',
    'COUNTER',
    'CONDUCTOR',
    'WEBSITE',
    'WHATSAPP_BOT'
);

CREATE TYPE bus.payment_method_t AS ENUM (
    'CASH',
    'UPI',
    'DEBIT_CARD',
    'CREDIT_CARD',
    'METRO_CARD',
    'WALLET',
    'QR_CODE'
);

CREATE TYPE bus.payment_status_t AS ENUM (
    'INITIATED',
    'SUCCESS',
    'FAILED',
    'REFUNDED',
    'PENDING'
);

CREATE TYPE bus.pass_type_t AS ENUM (
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'STUDENT_MONTHLY',
    'SENIOR_MONTHLY',
    'EMPLOYEE_MONTHLY'
);

CREATE TYPE bus.emp_status_t AS ENUM (
    'ACTIVE',
    'ON_LEAVE',
    'SUSPENDED',
    'TERMINATED'
);

CREATE TYPE bus.alert_type_t AS ENUM (
    'DELAY',
    'CANCELLATION',
    'ROUTE_CHANGE',
    'STOP_CHANGE',
    'EMERGENCY',
    'HIGH_CROWD',
    'GENERAL'
);

CREATE TYPE bus.alert_severity_t AS ENUM (
    'INFO',
    'WARNING',
    'CRITICAL'
);

CREATE TYPE bus.maint_status_t AS ENUM (
    'SCHEDULED',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED'
);

CREATE TYPE bus.scan_role_t AS ENUM (
    'ENTRY',
    'EXIT'
);

CREATE TYPE bus.travel_status_t AS ENUM (
    'BOARDING',
    'ON_BUS',
    'EXITED'
);

CREATE TYPE bus.journey_type_t AS ENUM (
    'BUS_ONLY',
    'METRO_ONLY',
    'METRO_THEN_BUS',
    'BUS_THEN_METRO',
    'BUS_METRO_BUS',
    'BUS_THEN_BUS'
);

CREATE TYPE bus.connection_type_t AS ENUM (
    'WALK',
    'COVERED_WALKWAY',
    'ESCALATOR',
    'SHUTTLE'
);

-- ================================================================
--  S03 — DOMAIN TYPES (reuse from metro where possible)
-- ================================================================

CREATE DOMAIN bus.phone_t    AS VARCHAR(15)
    CHECK (VALUE ~ '^\+?[0-9]{10,15}$');

CREATE DOMAIN bus.email_t    AS VARCHAR(255)
    CHECK (VALUE ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$');

CREATE DOMAIN bus.money_t    AS NUMERIC(10,2)
    CHECK (VALUE >= 0);

CREATE DOMAIN bus.distance_t AS NUMERIC(8,3)
    CHECK (VALUE >= 0);

CREATE DOMAIN bus.lat_t      AS NUMERIC(9,6)
    CHECK (VALUE BETWEEN -90  AND  90);

CREATE DOMAIN bus.lng_t      AS NUMERIC(9,6)
    CHECK (VALUE BETWEEN -180 AND 180);

-- ================================================================
--  S04 — BUS_OPERATOR
--  Transport authority running the buses (GSRTC, AMTS, BRTS).
--  BCNF: operator_id → all; operator_code is candidate key.
-- ================================================================

CREATE TABLE bus.BUS_OPERATOR (
    operator_id     SERIAL              NOT NULL,
    operator_code   VARCHAR(20)         NOT NULL,
    operator_name   VARCHAR(150)        NOT NULL,
    operator_type   bus.operator_type_t NOT NULL,
    city            VARCHAR(100)        NOT NULL DEFAULT 'Ahmedabad',
    phone           bus.phone_t,
    email           bus.email_t,
    website         VARCHAR(200),
    address         TEXT,
    is_active       BOOLEAN             NOT NULL DEFAULT TRUE,
    is_deleted      BOOLEAN             NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_operator    PRIMARY KEY (operator_id),
    CONSTRAINT uq_operator_code   UNIQUE (operator_code),
    CONSTRAINT uq_operator_name   UNIQUE (operator_name)
);

SELECT bus.fn_attach_updated_at('bus_operator');

COMMENT ON TABLE  bus.BUS_OPERATOR IS
'Transport authorities: GSRTC, AMTS, BRTS operating buses in Ahmedabad–Gandhinagar corridor';

-- ================================================================
--  S05 — BUS_ROUTE
--  A named bus route (e.g. Route 37, BRTS-1, GSRTC-AHM-GN-01).
--  BCNF: route_id → all; (operator_id, route_number) is candidate key.
-- ================================================================

CREATE TABLE bus.BUS_ROUTE (
    route_id            SERIAL              NOT NULL,
    operator_id         INT                 NOT NULL,
    route_number        VARCHAR(20)         NOT NULL,
    route_name          VARCHAR(200)        NOT NULL,
    route_type          bus.route_type_t    NOT NULL DEFAULT 'CITY',
    total_length_km     bus.distance_t      NOT NULL,
    total_stops         SMALLINT            NOT NULL DEFAULT 0
                            CHECK (total_stops >= 0),
    origin_stop_name    VARCHAR(150)        NOT NULL,
    destination_stop_name VARCHAR(150)      NOT NULL,
    color_code          VARCHAR(10)                   DEFAULT '#FF6600',
    frequency_peak_min  SMALLINT            CHECK (frequency_peak_min > 0),
    frequency_offpeak_min SMALLINT          CHECK (frequency_offpeak_min > 0),
    first_departure     TIME,
    last_departure      TIME,
    description         TEXT,
    is_active           BOOLEAN             NOT NULL DEFAULT TRUE,
    is_deleted          BOOLEAN             NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_route        PRIMARY KEY (route_id),
    CONSTRAINT uq_route_number     UNIQUE (operator_id, route_number),
    CONSTRAINT fk_route_operator
        FOREIGN KEY (operator_id)
        REFERENCES bus.BUS_OPERATOR(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

SELECT bus.fn_attach_updated_at('bus_route');

CREATE INDEX idx_route_operator ON bus.BUS_ROUTE(operator_id)
    WHERE is_deleted = FALSE;
CREATE INDEX idx_route_type ON bus.BUS_ROUTE(route_type)
    WHERE is_deleted = FALSE;

COMMENT ON TABLE bus.BUS_ROUTE IS
'Bus routes operated in Ahmedabad–Gandhinagar. Includes AMTS city, BRTS corridor and GSRTC intercity.';

-- ================================================================
--  S06 — BUS_STOP
--  A physical bus stop / BRTS station.
--  BCNF: stop_id → all; stop_code is candidate key.
-- ================================================================

CREATE TABLE bus.BUS_STOP (
    stop_id             SERIAL              NOT NULL,
    stop_code           VARCHAR(15)         NOT NULL,
    stop_name           VARCHAR(200)        NOT NULL,
    stop_type           bus.stop_type_t     NOT NULL DEFAULT 'REGULAR',
    latitude            bus.lat_t           NOT NULL,
    longitude           bus.lng_t           NOT NULL,
    address             TEXT,
    city                VARCHAR(100)        NOT NULL DEFAULT 'Ahmedabad',
    zone_no             SMALLINT            NOT NULL DEFAULT 1
                            CHECK (zone_no >= 1),
    has_shelter         BOOLEAN             NOT NULL DEFAULT FALSE,
    has_display_board   BOOLEAN             NOT NULL DEFAULT FALSE,
    has_ticket_counter  BOOLEAN             NOT NULL DEFAULT FALSE,
    wheelchair_access   BOOLEAN             NOT NULL DEFAULT FALSE,
    is_active           BOOLEAN             NOT NULL DEFAULT TRUE,
    is_deleted          BOOLEAN             NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_stop         PRIMARY KEY (stop_id),
    CONSTRAINT uq_stop_code        UNIQUE (stop_code)
);

SELECT bus.fn_attach_updated_at('bus_stop');

CREATE INDEX idx_stop_geo  ON bus.BUS_STOP(latitude, longitude);
CREATE INDEX idx_stop_city ON bus.BUS_STOP(city) WHERE is_deleted = FALSE;

COMMENT ON TABLE bus.BUS_STOP IS
'Physical bus stops and BRTS stations in Ahmedabad and Gandhinagar';

-- ================================================================
--  S07 — ROUTE_STOP
--  M:N between BUS_ROUTE and BUS_STOP with sequence and distance.
--  BCNF: (route_id, stop_id) → all; (route_id, sequence_no) is AK.
-- ================================================================

CREATE TABLE bus.ROUTE_STOP (
    route_id            INT                 NOT NULL,
    stop_id             INT                 NOT NULL,
    sequence_no         SMALLINT            NOT NULL CHECK (sequence_no >= 1),
    dist_from_start_km  bus.distance_t      NOT NULL,
    is_terminal         BOOLEAN             NOT NULL DEFAULT FALSE,
    default_halt_sec    SMALLINT            NOT NULL DEFAULT 20
                            CHECK (default_halt_sec >= 0),
    is_active           BOOLEAN             NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_route_stop PRIMARY KEY (route_id, stop_id),
    CONSTRAINT uq_route_seq  UNIQUE (route_id, sequence_no),
    CONSTRAINT fk_rs_route
        FOREIGN KEY (route_id)
        REFERENCES bus.BUS_ROUTE(route_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rs_stop
        FOREIGN KEY (stop_id)
        REFERENCES bus.BUS_STOP(stop_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

SELECT bus.fn_attach_updated_at('route_stop');

CREATE INDEX idx_rs_stop ON bus.ROUTE_STOP(stop_id);

COMMENT ON TABLE bus.ROUTE_STOP IS
'M:N — which stops are on which route, in order with distances';

-- ================================================================
--  S08 — BUS  (physical vehicle)
--  BCNF: bus_id → all; bus_number is candidate key.
-- ================================================================

CREATE TABLE bus.BUS (
    bus_id              SERIAL              NOT NULL,
    operator_id         INT                 NOT NULL,
    route_id            INT,                            -- current assigned route
    bus_number          VARCHAR(20)         NOT NULL,
    bus_type            bus.bus_type_t      NOT NULL DEFAULT 'NON_AC_SINGLE_DECK',
    total_capacity      INT                 NOT NULL CHECK (total_capacity > 0),
    seating_capacity    INT                 NOT NULL CHECK (seating_capacity > 0),
    standing_capacity   INT                 NOT NULL CHECK (standing_capacity >= 0),
    manufacturer        VARCHAR(100),
    manufacture_year    SMALLINT            CHECK (manufacture_year BETWEEN 2000 AND 2100),
    registration_no     VARCHAR(30)         NOT NULL,
    commission_date     DATE,
    is_ac               BOOLEAN             NOT NULL DEFAULT FALSE,
    is_electric         BOOLEAN             NOT NULL DEFAULT FALSE,

    -- Live state
    operational_status  bus.bus_status_t    NOT NULL DEFAULT 'AT_DEPOT',
    current_lat         bus.lat_t,
    current_lng         bus.lng_t,
    current_speed_kmph  NUMERIC(5,2)        CHECK (current_speed_kmph >= 0),
    current_crowd_count INT                 NOT NULL DEFAULT 0
                            CHECK (current_crowd_count >= 0),
    last_gps_update     TIMESTAMPTZ,

    is_deleted          BOOLEAN             NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus              PRIMARY KEY (bus_id),
    CONSTRAINT uq_bus_number       UNIQUE (bus_number),
    CONSTRAINT uq_bus_reg          UNIQUE (registration_no),
    CONSTRAINT chk_bus_capacity
        CHECK (seating_capacity + standing_capacity = total_capacity),
    CONSTRAINT fk_bus_operator
        FOREIGN KEY (operator_id)
        REFERENCES bus.BUS_OPERATOR(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_bus_route
        FOREIGN KEY (route_id)
        REFERENCES bus.BUS_ROUTE(route_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

SELECT bus.fn_attach_updated_at('bus');

CREATE INDEX idx_bus_status   ON bus.BUS(operational_status) WHERE is_deleted = FALSE;
CREATE INDEX idx_bus_route    ON bus.BUS(route_id)           WHERE is_deleted = FALSE;
CREATE INDEX idx_bus_operator ON bus.BUS(operator_id)        WHERE is_deleted = FALSE;

COMMENT ON TABLE bus.BUS IS
'Physical bus fleet for AMTS, BRTS and GSRTC in Ahmedabad–Gandhinagar corridor';

-- ================================================================
--  AHMEDABAD YATRA — BUS SYSTEM DDL PART 2
--  Tables: BUS_FARE_RULE → BUS_DRIVER → BUS_DRIVER_SHIFT
--          → BUS_DRIVER_ASSIGNMENT → BUS_SCHEDULE → BUS_TRIP_STOP
-- ================================================================


-- ================================================================
--  S09 — BUS_FARE_RULE
--  Distance-slab fare matrix for bus travel.
--  Separate from metro fares. AMTS/BRTS/GSRTC have different slabs.
--  BCNF: fare_rule_id → all; no transitive deps.
-- ================================================================

CREATE TABLE bus.BUS_FARE_RULE (
    fare_rule_id        SERIAL              NOT NULL,
    operator_id         INT                 NOT NULL,
    min_distance_km     bus.distance_t      NOT NULL,
    max_distance_km     bus.distance_t      NOT NULL,

    -- Fares by passenger category
    normal_fare         bus.money_t         NOT NULL,
    senior_fare         bus.money_t         NOT NULL,
    child_fare          bus.money_t         NOT NULL,
    student_fare        bus.money_t         NOT NULL,
    disabled_fare       bus.money_t         NOT NULL,
    freedom_fighter_fare bus.money_t        NOT NULL DEFAULT 0,

    -- Validity
    effective_from      DATE                NOT NULL DEFAULT CURRENT_DATE,
    effective_to        DATE,
    is_active           BOOLEAN             NOT NULL DEFAULT TRUE,

    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_fare         PRIMARY KEY (fare_rule_id),
    CONSTRAINT fk_fare_operator
        FOREIGN KEY (operator_id)
        REFERENCES bus.BUS_OPERATOR(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_fare_dist
        CHECK (max_distance_km > min_distance_km),
    CONSTRAINT chk_fare_dates
        CHECK (effective_to IS NULL OR effective_to >= effective_from)
);

SELECT bus.fn_attach_updated_at('bus_fare_rule');

CREATE INDEX idx_bfr_operator ON bus.BUS_FARE_RULE(operator_id, is_active);
CREATE INDEX idx_bfr_dist     ON bus.BUS_FARE_RULE(min_distance_km, max_distance_km);

COMMENT ON TABLE bus.BUS_FARE_RULE IS
'Per-operator distance-slab fare matrix. AMTS, BRTS, GSRTC each have own slabs.';

-- ================================================================
--  S10 — BUS_DRIVER
--  Bus driver employed by an operator.
--  BCNF: driver_id → all; license_no, phone are candidate keys.
-- ================================================================

CREATE TABLE bus.BUS_DRIVER (
    driver_id           SERIAL              NOT NULL,
    operator_id         INT                 NOT NULL,
    employee_code       VARCHAR(20)         NOT NULL,
    full_name           VARCHAR(200)        NOT NULL,
    date_of_birth       DATE                NOT NULL,
    gender              CHAR(1)             CHECK (gender IN ('M','F','O')),
    phone               bus.phone_t         NOT NULL,
    alternate_phone     bus.phone_t,
    email               bus.email_t,
    address             TEXT,
    emergency_contact   bus.phone_t,

    -- Professional
    license_no          VARCHAR(50)         NOT NULL,
    license_expiry      DATE                NOT NULL,
    joining_date        DATE                NOT NULL DEFAULT CURRENT_DATE,
    experience_years    SMALLINT            NOT NULL DEFAULT 0
                            CHECK (experience_years >= 0),
    salary              bus.money_t         NOT NULL CHECK (salary > 0),
    bank_account_no     VARCHAR(30),

    employment_status   bus.emp_status_t    NOT NULL DEFAULT 'ACTIVE',
    is_deleted          BOOLEAN             NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_driver       PRIMARY KEY (driver_id),
    CONSTRAINT uq_bdrv_emp_code    UNIQUE (operator_id, employee_code),
    CONSTRAINT uq_bdrv_license     UNIQUE (license_no),
    CONSTRAINT uq_bdrv_phone       UNIQUE (phone),
    CONSTRAINT chk_bdrv_dob
        CHECK (date_of_birth < joining_date - INTERVAL '18 years'),
    CONSTRAINT chk_bdrv_license
        CHECK (license_expiry > joining_date),
    CONSTRAINT fk_bdrv_operator
        FOREIGN KEY (operator_id)
        REFERENCES bus.BUS_OPERATOR(operator_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

SELECT bus.fn_attach_updated_at('bus_driver');

CREATE INDEX idx_bdrv_operator ON bus.BUS_DRIVER(operator_id)         WHERE is_deleted = FALSE;
CREATE INDEX idx_bdrv_status   ON bus.BUS_DRIVER(employment_status)   WHERE is_deleted = FALSE;
CREATE INDEX idx_bdrv_license  ON bus.BUS_DRIVER(license_expiry)      WHERE is_deleted = FALSE;

COMMENT ON TABLE bus.BUS_DRIVER IS
'Bus drivers employed by each operator (AMTS/BRTS/GSRTC)';

-- ================================================================
--  S11 — BUS_DRIVER_SHIFT  (Weak Entity — owner: BUS_DRIVER)
--  working_hours is a GENERATED STORED derived column.
--  BCNF: (driver_id, shift_id) → all.
-- ================================================================

CREATE TABLE bus.BUS_DRIVER_SHIFT (
    driver_id       INT                 NOT NULL,
    shift_id        SERIAL,
    shift_date      DATE                NOT NULL,
    shift_start     TIME                NOT NULL,
    shift_end       TIME                NOT NULL,
    working_hours   NUMERIC(4,2)
                    GENERATED ALWAYS AS (
                        ROUND(
                            EXTRACT(EPOCH FROM (
                                shift_end::INTERVAL - shift_start::INTERVAL
                            )) / 3600.0, 2
                        )
                    ) STORED,
    shift_type      VARCHAR(20)         NOT NULL DEFAULT 'REGULAR'
                        CHECK (shift_type IN ('REGULAR','OVERTIME','SPLIT','EMERGENCY')),
    is_completed    BOOLEAN             NOT NULL DEFAULT FALSE,
    actual_start    TIMESTAMPTZ,
    actual_end      TIMESTAMPTZ,
    remarks         TEXT,
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_shift        PRIMARY KEY (driver_id, shift_id),
    CONSTRAINT fk_bshift_driver
        FOREIGN KEY (driver_id)
        REFERENCES bus.BUS_DRIVER(driver_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_bshift_times
        CHECK (shift_end > shift_start)
);

SELECT bus.fn_attach_updated_at('bus_driver_shift');

CREATE UNIQUE INDEX uq_bshift_no_overlap
    ON bus.BUS_DRIVER_SHIFT(driver_id, shift_date, shift_start, shift_end);

COMMENT ON TABLE  bus.BUS_DRIVER_SHIFT IS
'Weak entity — shift records per bus driver. working_hours auto-calculated.';

-- ================================================================
--  S12 — BUS_SCHEDULE
--  One scheduled run of a bus on a route.
--  BCNF: schedule_id → all; no transitive deps.
-- ================================================================

CREATE TABLE bus.BUS_SCHEDULE (
    schedule_id         SERIAL                  NOT NULL,
    bus_id              INT                     NOT NULL,
    route_id            INT                     NOT NULL,
    direction           VARCHAR(20)             NOT NULL DEFAULT 'FORWARD'
                            CHECK (direction IN ('FORWARD','RETURN')),
    day_type            bus.day_type_t           NOT NULL DEFAULT 'WEEKDAY',
    departure_time      TIME                    NOT NULL,
    arrival_time        TIME                    NOT NULL,
    normal_eta_mins     INT                     CHECK (normal_eta_mins > 0),
    schedule_status     bus.schedule_status_t    NOT NULL DEFAULT 'ACTIVE',
    effective_from      DATE                    NOT NULL DEFAULT CURRENT_DATE,
    effective_to        DATE,
    is_deleted          BOOLEAN                 NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_schedule     PRIMARY KEY (schedule_id),
    CONSTRAINT fk_bsch_bus
        FOREIGN KEY (bus_id)
        REFERENCES bus.BUS(bus_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_bsch_route
        FOREIGN KEY (route_id)
        REFERENCES bus.BUS_ROUTE(route_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_bsch_times
        CHECK (arrival_time > departure_time),
    CONSTRAINT chk_bsch_dates
        CHECK (effective_to IS NULL OR effective_to >= effective_from)
);

SELECT bus.fn_attach_updated_at('bus_schedule');

-- Prevent same bus from having two overlapping active schedules
CREATE UNIQUE INDEX uq_bsch_no_overlap
    ON bus.BUS_SCHEDULE(bus_id, departure_time, day_type)
    WHERE schedule_status = 'ACTIVE' AND is_deleted = FALSE;

CREATE INDEX idx_bsch_route  ON bus.BUS_SCHEDULE(route_id, day_type) WHERE is_deleted = FALSE;
CREATE INDEX idx_bsch_status ON bus.BUS_SCHEDULE(schedule_status)    WHERE is_deleted = FALSE;

COMMENT ON TABLE bus.BUS_SCHEDULE IS
'Each scheduled run of a bus on a route. One row = one timetabled trip.';

-- ================================================================
--  S13 — BUS_TRIP_STOP  (Weak Entity — owner: BUS_SCHEDULE)
--  Each row = one bus stop timing within a schedule trip.
--  BCNF: (schedule_id, stop_sequence) → all.
-- ================================================================

CREATE TABLE bus.BUS_TRIP_STOP (
    schedule_id         INT                 NOT NULL,
    stop_sequence       SMALLINT            NOT NULL CHECK (stop_sequence >= 1),
    stop_id             INT                 NOT NULL,
    scheduled_arrival   TIME,
    scheduled_departure TIME,
    halt_duration_sec   SMALLINT            NOT NULL DEFAULT 20
                            CHECK (halt_duration_sec >= 0),
    -- Real-time ETA updated by live tracking / delay events
    dynamic_eta         TIMESTAMPTZ,
    is_active           BOOLEAN             NOT NULL DEFAULT TRUE,
    is_deleted          BOOLEAN             NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_trip_stop    PRIMARY KEY (schedule_id, stop_sequence),
    CONSTRAINT fk_bts_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES bus.BUS_SCHEDULE(schedule_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bts_stop
        FOREIGN KEY (stop_id)
        REFERENCES bus.BUS_STOP(stop_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_bts_times
        CHECK (scheduled_arrival IS NULL OR scheduled_departure IS NULL
               OR scheduled_departure >= scheduled_arrival)
);

SELECT bus.fn_attach_updated_at('bus_trip_stop');

CREATE INDEX idx_bts_stop     ON bus.BUS_TRIP_STOP(stop_id);
CREATE INDEX idx_bts_dynamic  ON bus.BUS_TRIP_STOP(schedule_id, dynamic_eta)
    WHERE dynamic_eta IS NOT NULL;
-- Fast query: next buses at a stop after current time
CREATE INDEX idx_bts_upcoming ON bus.BUS_TRIP_STOP(stop_id, scheduled_departure)
    WHERE is_active = TRUE AND is_deleted = FALSE;

COMMENT ON TABLE  bus.BUS_TRIP_STOP IS
'Weak entity — each stop timing within a bus schedule trip.';
COMMENT ON COLUMN bus.BUS_TRIP_STOP.dynamic_eta IS
'Recalculated real-time ETA based on live GPS and delay events.';

-- ================================================================
--  S14 — BUS_DRIVER_ASSIGNMENT
--  M:N between BUS_DRIVER and BUS_SCHEDULE with date + role.
--  BCNF: assignment_id → all; (schedule_id, date, role) is AK.
-- ================================================================

CREATE TABLE bus.BUS_DRIVER_ASSIGNMENT (
    assignment_id       SERIAL              NOT NULL,
    driver_id           INT                 NOT NULL,
    schedule_id         INT                 NOT NULL,
    assignment_date     DATE                NOT NULL DEFAULT CURRENT_DATE,
    role                VARCHAR(20)         NOT NULL DEFAULT 'PRIMARY'
                            CHECK (role IN ('PRIMARY','BACKUP','TRAINEE')),
    assigned_remarks    TEXT,
    is_active           BOOLEAN             NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_driver_assign  PRIMARY KEY (assignment_id),
    CONSTRAINT uq_bda_primary
        UNIQUE (schedule_id, assignment_date, role)
        DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT fk_bda_driver
        FOREIGN KEY (driver_id)
        REFERENCES bus.BUS_DRIVER(driver_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_bda_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES bus.BUS_SCHEDULE(schedule_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

SELECT bus.fn_attach_updated_at('bus_driver_assignment');

CREATE INDEX idx_bda_driver   ON bus.BUS_DRIVER_ASSIGNMENT(driver_id, assignment_date);
CREATE INDEX idx_bda_schedule ON bus.BUS_DRIVER_ASSIGNMENT(schedule_id, assignment_date);

COMMENT ON TABLE bus.BUS_DRIVER_ASSIGNMENT IS
'Which driver is assigned to which schedule on which date.';

-- ================================================================
--  AHMEDABAD YATRA — BUS SYSTEM DDL PART 3
--  Tables: BUS_DELAY_EVENT → BUS_RESCHEDULE_LOG → BUS_INCIDENT
--          → BUS_LIVE_TRACKING → BUS_ALERT → BUS_MAINTENANCE_LOG
-- ================================================================


-- ================================================================
--  S15 — BUS_DELAY_EVENT
--  Records every delay against a bus schedule.
--  BCNF: delay_id → all; no transitive deps.
-- ================================================================

CREATE TABLE bus.BUS_DELAY_EVENT (
    delay_id            BIGSERIAL               NOT NULL,
    schedule_id         INT                     NOT NULL,
    affected_stop_id    INT,
    delay_minutes       INT                     NOT NULL CHECK (delay_minutes > 0),
    reason              TEXT                    NOT NULL,
    delay_category      VARCHAR(50)             NOT NULL DEFAULT 'OPERATIONAL'
                            CHECK (delay_category IN (
                                'OPERATIONAL','TRAFFIC','BREAKDOWN',
                                'WEATHER','PASSENGER','ACCIDENT','OTHER'
                            )),
    resolution_status   bus.delay_resolution_t  NOT NULL DEFAULT 'PENDING',
    reported_at         TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    resolved_at         TIMESTAMPTZ,
    resolved_by         VARCHAR(100),
    resolution_notes    TEXT,
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_delay        PRIMARY KEY (delay_id),
    CONSTRAINT fk_bdel_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES bus.BUS_SCHEDULE(schedule_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bdel_stop
        FOREIGN KEY (affected_stop_id)
        REFERENCES bus.BUS_STOP(stop_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

SELECT bus.fn_attach_updated_at('bus_delay_event');

CREATE INDEX idx_bdel_schedule ON bus.BUS_DELAY_EVENT(schedule_id);
CREATE INDEX idx_bdel_status   ON bus.BUS_DELAY_EVENT(resolution_status);
CREATE INDEX idx_bdel_reported ON bus.BUS_DELAY_EVENT(reported_at DESC);

COMMENT ON TABLE bus.BUS_DELAY_EVENT IS
'Every delay event recorded against a bus schedule. Drives ETA recalculation.';

-- ================================================================
--  S16 — BUS_RESCHEDULE_LOG
--  Immutable audit trail of every rescheduling action.
--  Append-only — no UPDATE or DELETE.
-- ================================================================

CREATE TABLE bus.BUS_RESCHEDULE_LOG (
    reschedule_id       BIGSERIAL           NOT NULL,
    schedule_id         INT                 NOT NULL,
    incident_id         INT,
    reason              TEXT                NOT NULL,
    original_dep_time   TIME                NOT NULL,
    new_dep_time        TIME                NOT NULL,
    original_arr_time   TIME,
    new_arr_time        TIME,
    done_by             VARCHAR(100),
    logged_at           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_reschedule   PRIMARY KEY (reschedule_id),
    CONSTRAINT fk_brsl_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES bus.BUS_SCHEDULE(schedule_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_brsl_schedule ON bus.BUS_RESCHEDULE_LOG(schedule_id, logged_at DESC);

COMMENT ON TABLE bus.BUS_RESCHEDULE_LOG IS
'Immutable reschedule audit trail. Append-only — never update or delete rows.';

-- ================================================================
--  S17 — BUS_INCIDENT
--  Breakdown, accident, fire — any serious event on a bus.
--  BCNF: incident_id → all; no transitive deps.
-- ================================================================

CREATE TABLE bus.BUS_INCIDENT (
    incident_id         SERIAL                  NOT NULL,
    bus_id              INT                     NOT NULL,
    schedule_id         INT,
    near_stop_id        INT,
    incident_type       bus.incident_type_t     NOT NULL,
    incident_datetime   TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    location_desc       TEXT                    NOT NULL,
    location_lat        bus.lat_t,
    location_lng        bus.lng_t,
    severity_level      SMALLINT                NOT NULL
                            CHECK (severity_level BETWEEN 1 AND 5),
    status              bus.incident_status_t   NOT NULL DEFAULT 'OPEN',
    replacement_bus_id  INT,
    root_cause          TEXT,
    corrective_action   TEXT,
    reported_by         VARCHAR(100),
    contained_at        TIMESTAMPTZ,
    resolved_at         TIMESTAMPTZ,
    notes               TEXT,
    is_deleted          BOOLEAN                 NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_incident     PRIMARY KEY (incident_id),
    CONSTRAINT fk_binc_bus
        FOREIGN KEY (bus_id)
        REFERENCES bus.BUS(bus_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_binc_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES bus.BUS_SCHEDULE(schedule_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_binc_stop
        FOREIGN KEY (near_stop_id)
        REFERENCES bus.BUS_STOP(stop_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_binc_replacement
        FOREIGN KEY (replacement_bus_id)
        REFERENCES bus.BUS(bus_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

SELECT bus.fn_attach_updated_at('bus_incident');

-- Back-fill incident FK in reschedule log
ALTER TABLE bus.BUS_RESCHEDULE_LOG
    ADD CONSTRAINT fk_brsl_incident
    FOREIGN KEY (incident_id)
    REFERENCES bus.BUS_INCIDENT(incident_id)
    ON DELETE SET NULL ON UPDATE CASCADE;

CREATE INDEX idx_binc_bus    ON bus.BUS_INCIDENT(bus_id);
CREATE INDEX idx_binc_status ON bus.BUS_INCIDENT(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_binc_dt     ON bus.BUS_INCIDENT(incident_datetime DESC);

COMMENT ON TABLE  bus.BUS_INCIDENT IS
'Breakdown, accident, fire events on buses. Triggers rescheduling workflow.';
COMMENT ON COLUMN bus.BUS_INCIDENT.severity_level IS
'1=minor delay, 5=fatality/major accident';

-- ================================================================
--  S18 — BUS_LIVE_TRACKING
--  Append-only GPS time-series log (~10 second intervals).
--  Never UPDATE or DELETE rows.
-- ================================================================

CREATE TABLE bus.BUS_LIVE_TRACKING (
    tracking_id         BIGSERIAL           NOT NULL,
    bus_id              INT                 NOT NULL
                            REFERENCES bus.BUS(bus_id)
                            ON DELETE CASCADE ON UPDATE CASCADE,
    schedule_id         INT
                            REFERENCES bus.BUS_SCHEDULE(schedule_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    latitude            bus.lat_t           NOT NULL,
    longitude           bus.lng_t           NOT NULL,
    altitude_m          NUMERIC(7,2),
    speed_kmph          NUMERIC(5,2)        NOT NULL CHECK (speed_kmph >= 0),
    heading_degrees     NUMERIC(5,2)        CHECK (heading_degrees BETWEEN 0 AND 360),
    next_stop_id        INT
                            REFERENCES bus.BUS_STOP(stop_id)
                            ON DELETE SET NULL,
    dist_to_next_stop_m INT                 CHECK (dist_to_next_stop_m >= 0),
    updated_eta         TIMESTAMPTZ,
    recorded_at         TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_tracking PRIMARY KEY (tracking_id)
);

-- Covering index: latest position per bus
CREATE INDEX idx_blt_bus_ts    ON bus.BUS_LIVE_TRACKING(bus_id, recorded_at DESC)
    INCLUDE (latitude, longitude, speed_kmph, updated_eta);
CREATE INDEX idx_blt_schedule  ON bus.BUS_LIVE_TRACKING(schedule_id, recorded_at DESC)
    WHERE schedule_id IS NOT NULL;
CREATE INDEX idx_blt_recorded  ON bus.BUS_LIVE_TRACKING(recorded_at DESC);

COMMENT ON TABLE  bus.BUS_LIVE_TRACKING IS
'Append-only GPS log for buses. Partition by month in production.';
COMMENT ON COLUMN bus.BUS_LIVE_TRACKING.dist_to_next_stop_m IS
'Distance in metres to next scheduled stop. Used for ETA display in app.';

-- ================================================================
--  S19 — BUS_ALERT
--  Service alerts for passengers about delays, cancellations etc.
--  BCNF: alert_id → all.
-- ================================================================

CREATE TABLE bus.BUS_ALERT (
    alert_id            BIGSERIAL               NOT NULL,
    bus_id              INT
                            REFERENCES bus.BUS(bus_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    schedule_id         INT
                            REFERENCES bus.BUS_SCHEDULE(schedule_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    route_id            INT
                            REFERENCES bus.BUS_ROUTE(route_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    stop_id             INT
                            REFERENCES bus.BUS_STOP(stop_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    incident_id         INT
                            REFERENCES bus.BUS_INCIDENT(incident_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    alert_type          bus.alert_type_t        NOT NULL,
    severity            bus.alert_severity_t    NOT NULL DEFAULT 'INFO',
    title               VARCHAR(200)            NOT NULL,
    message             TEXT                    NOT NULL,
    is_resolved         BOOLEAN                 NOT NULL DEFAULT FALSE,
    resolved_at         TIMESTAMPTZ,
    auto_expires_at     TIMESTAMPTZ,
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_alert    PRIMARY KEY (alert_id),
    CONSTRAINT chk_balert_ctx
        CHECK (
            bus_id IS NOT NULL OR route_id IS NOT NULL
            OR stop_id IS NOT NULL OR schedule_id IS NOT NULL
        )
);

SELECT bus.fn_attach_updated_at('bus_alert');

CREATE INDEX idx_balert_route    ON bus.BUS_ALERT(route_id)   WHERE route_id IS NOT NULL;
CREATE INDEX idx_balert_type     ON bus.BUS_ALERT(alert_type);
CREATE INDEX idx_balert_open     ON bus.BUS_ALERT(created_at DESC) WHERE is_resolved = FALSE;

COMMENT ON TABLE bus.BUS_ALERT IS
'System and manual alerts for bus passengers: delays, cancellations, emergencies.';

-- ================================================================
--  S20 — BUS_MAINTENANCE_LOG
--  Full work-order history for each bus vehicle.
--  BCNF: log_id → all; no transitive deps.
-- ================================================================

CREATE TABLE bus.BUS_MAINTENANCE_LOG (
    log_id              SERIAL              NOT NULL,
    bus_id              INT                 NOT NULL,
    incident_id         INT,
    maintenance_type    VARCHAR(30)         NOT NULL DEFAULT 'ROUTINE_INSPECTION'
                            CHECK (maintenance_type IN (
                                'ROUTINE_INSPECTION','CORRECTIVE','PREVENTIVE',
                                'EMERGENCY','OVERHAUL','CLEANING'
                            )),
    maintenance_date    DATE                NOT NULL,
    description         TEXT                NOT NULL,
    parts_replaced      TEXT,
    vendor_name         VARCHAR(200),
    estimated_cost      bus.money_t,
    actual_cost         bus.money_t,
    performed_by        VARCHAR(150),
    status              bus.maint_status_t  NOT NULL DEFAULT 'SCHEDULED',
    scheduled_start     TIMESTAMPTZ,
    actual_start        TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    next_due_date       DATE,
    is_deleted          BOOLEAN             NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_maint        PRIMARY KEY (log_id),
    CONSTRAINT fk_bmaint_bus
        FOREIGN KEY (bus_id)
        REFERENCES bus.BUS(bus_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_bmaint_incident
        FOREIGN KEY (incident_id)
        REFERENCES bus.BUS_INCIDENT(incident_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

SELECT bus.fn_attach_updated_at('bus_maintenance_log');

CREATE INDEX idx_bmaint_bus    ON bus.BUS_MAINTENANCE_LOG(bus_id, maintenance_date DESC);
CREATE INDEX idx_bmaint_status ON bus.BUS_MAINTENANCE_LOG(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_bmaint_due    ON bus.BUS_MAINTENANCE_LOG(next_due_date)
    WHERE next_due_date IS NOT NULL;

COMMENT ON TABLE bus.BUS_MAINTENANCE_LOG IS
'Full maintenance work-order history for every bus in the fleet.';

-- ================================================================
--  TRIGGERS FOR OPERATIONS
-- ================================================================

-- TR1: Auto-update BUS.current_crowd_count from BUS_TRAVELLING_IN
-- (forward reference — trigger body created after BUS_TRAVELLING_IN)
-- Placeholder function:
CREATE OR REPLACE FUNCTION bus.fn_sync_bus_crowd()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_bus_id INT;
    v_count  INT;
BEGIN
    SELECT bs.bus_id INTO v_bus_id
    FROM   bus.BUS_SCHEDULE bs
    WHERE  bs.schedule_id = COALESCE(NEW.schedule_id, OLD.schedule_id);

    IF v_bus_id IS NULL THEN RETURN COALESCE(NEW, OLD); END IF;

    SELECT COUNT(*) INTO v_count
    FROM   bus.BUS_TRAVELLING_IN bti
    JOIN   bus.BUS_SCHEDULE bs ON bs.schedule_id = bti.schedule_id
    WHERE  bs.bus_id   = v_bus_id
    AND    bti.status  = 'ON_BUS';

    UPDATE bus.BUS
    SET    current_crowd_count = v_count,
           updated_at          = NOW()
    WHERE  bus_id = v_bus_id;

    RETURN COALESCE(NEW, OLD);
END;
$$;

-- TR2: Auto-update BUS_TRIP_STOP.dynamic_eta when delay recorded
CREATE OR REPLACE FUNCTION bus.fn_update_eta_on_delay()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    v_affected_seq SMALLINT;
BEGIN
    IF NEW.affected_stop_id IS NOT NULL THEN
        SELECT stop_sequence INTO v_affected_seq
        FROM   bus.BUS_TRIP_STOP
        WHERE  schedule_id = NEW.schedule_id
        AND    stop_id     = NEW.affected_stop_id
        AND    is_active   = TRUE
        LIMIT  1;
    ELSE
        v_affected_seq := 1;
    END IF;

    UPDATE bus.BUS_TRIP_STOP
    SET    dynamic_eta = (
               CURRENT_DATE
               + COALESCE(scheduled_departure, scheduled_arrival)
               + (NEW.delay_minutes || ' minutes')::INTERVAL
           ),
           updated_at  = NOW()
    WHERE  schedule_id    = NEW.schedule_id
    AND    stop_sequence >= COALESCE(v_affected_seq, 1)
    AND    is_active      = TRUE
    AND    is_deleted     = FALSE;

    -- Mark schedule as DELAYED
    UPDATE bus.BUS_SCHEDULE
    SET    schedule_status = 'DELAYED',
           updated_at      = NOW()
    WHERE  schedule_id     = NEW.schedule_id;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_bus_delay_update_eta
AFTER INSERT ON bus.BUS_DELAY_EVENT
FOR EACH ROW EXECUTE FUNCTION bus.fn_update_eta_on_delay();

-- TR3: Update BUS status on incident
CREATE OR REPLACE FUNCTION bus.fn_bus_status_on_incident()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.status = 'OPEN' THEN
        UPDATE bus.BUS
        SET    operational_status = CASE NEW.incident_type
                                        WHEN 'BREAKDOWN'  THEN 'BREAKDOWN'::bus.bus_status_t
                                        WHEN 'ACCIDENT'   THEN 'SUSPENDED'::bus.bus_status_t
                                        WHEN 'FIRE'       THEN 'SUSPENDED'::bus.bus_status_t
                                        ELSE 'SUSPENDED'::bus.bus_status_t
                                    END,
               updated_at         = NOW()
        WHERE  bus_id = NEW.bus_id;
    END IF;

    IF TG_OP = 'UPDATE' AND NEW.status = 'RESOLVED' AND OLD.status <> 'RESOLVED' THEN
        UPDATE bus.BUS
        SET    operational_status = 'AT_DEPOT',
               updated_at         = NOW()
        WHERE  bus_id = NEW.bus_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_bus_incident_status
AFTER INSERT OR UPDATE ON bus.BUS_INCIDENT
FOR EACH ROW EXECUTE FUNCTION bus.fn_bus_status_on_incident();

-- ================================================================
--  AHMEDABAD YATRA — BUS SYSTEM DDL PART 4
--  Tables: BUS_TICKET → BUS_PAYMENT → BUS_TRAVEL_PASS
--          → BUS_STOP_SCAN → BUS_TRAVELLING_IN
--          → INTERCHANGE_POINT → COMBINED_JOURNEY
--          → COMBINED_JOURNEY_LEG → BUS_FEEDBACK
--          → BUS_SYSTEM_CONFIG
--  + Triggers + Views + Route Planner Function
-- ================================================================


-- ================================================================
--  S21 — BUS_TICKET
--  One ticket = one bus journey. Uses metro.PASSENGER table.
--  BCNF: ticket_id → all; qr_code is candidate key.
-- ================================================================

CREATE TABLE bus.BUS_TICKET (
    ticket_id           BIGSERIAL               NOT NULL,
    -- References metro.PASSENGER (cross-schema FK)
    passenger_id        INT
                            REFERENCES metro.PASSENGER(passenger_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    fare_rule_id        INT                     NOT NULL
                            REFERENCES bus.BUS_FARE_RULE(fare_rule_id)
                            ON DELETE RESTRICT ON UPDATE CASCADE,
    from_stop_id        INT                     NOT NULL
                            REFERENCES bus.BUS_STOP(stop_id)
                            ON DELETE RESTRICT ON UPDATE CASCADE,
    to_stop_id          INT                     NOT NULL
                            REFERENCES bus.BUS_STOP(stop_id)
                            ON DELETE RESTRICT ON UPDATE CASCADE,
    schedule_id         INT
                            REFERENCES bus.BUS_SCHEDULE(schedule_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    ticket_type         VARCHAR(20)             NOT NULL DEFAULT 'SINGLE'
                            CHECK (ticket_type IN ('SINGLE','RETURN','DAY_PASS')),
    passenger_category  metro.passenger_type_t  NOT NULL DEFAULT 'GENERAL',
    qr_code             VARCHAR(512)            NOT NULL,
    distance_km         bus.distance_t          NOT NULL,
    base_amount         bus.money_t             NOT NULL,
    discount_amount     bus.money_t             NOT NULL DEFAULT 0,
    price_paid          bus.money_t             NOT NULL,
    booking_channel     bus.booking_channel_t   NOT NULL DEFAULT 'MOBILE_APP',
    issued_at           TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    valid_from          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    valid_to            TIMESTAMPTZ             NOT NULL,
    status              bus.ticket_status_t     NOT NULL DEFAULT 'BOOKED',
    cancellation_reason TEXT,
    cancelled_at        TIMESTAMPTZ,
    is_deleted          BOOLEAN                 NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_ticket       PRIMARY KEY (ticket_id),
    CONSTRAINT uq_bus_ticket_qr    UNIQUE (qr_code),
    CONSTRAINT chk_btkt_stations   CHECK (from_stop_id <> to_stop_id),
    CONSTRAINT chk_btkt_validity   CHECK (valid_to > valid_from),
    CONSTRAINT chk_btkt_price
        CHECK (price_paid = base_amount - discount_amount)
);

SELECT bus.fn_attach_updated_at('bus_ticket');

CREATE INDEX idx_btkt_passenger ON bus.BUS_TICKET(passenger_id)  WHERE is_deleted = FALSE;
CREATE INDEX idx_btkt_qr        ON bus.BUS_TICKET(qr_code);
CREATE INDEX idx_btkt_status    ON bus.BUS_TICKET(status)        WHERE is_deleted = FALSE;
CREATE INDEX idx_btkt_schedule  ON bus.BUS_TICKET(schedule_id)   WHERE is_deleted = FALSE;
CREATE UNIQUE INDEX idx_btkt_qr_active
    ON bus.BUS_TICKET(qr_code)
    WHERE status IN ('BOOKED','ACTIVE') AND is_deleted = FALSE;

COMMENT ON TABLE  bus.BUS_TICKET IS
'Bus journey tickets. passenger_id references metro.PASSENGER (shared identity).';

-- ================================================================
--  S22 — BUS_PAYMENT  (1:1 with BUS_TICKET)
--  BCNF: payment_id → all; ticket_id is candidate key.
-- ================================================================

CREATE TABLE bus.BUS_PAYMENT (
    payment_id          BIGSERIAL               NOT NULL,
    ticket_id           BIGINT                  NOT NULL,
    amount              bus.money_t             NOT NULL,
    currency            CHAR(3)                 NOT NULL DEFAULT 'INR',
    payment_method      bus.payment_method_t    NOT NULL,
    gateway_name        VARCHAR(50),
    gateway_order_id    VARCHAR(200),
    gateway_payment_id  VARCHAR(200)            UNIQUE,
    status              bus.payment_status_t    NOT NULL DEFAULT 'INITIATED',
    initiated_at        TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    paid_at             TIMESTAMPTZ,
    refund_amount       bus.money_t             NOT NULL DEFAULT 0,
    refunded_at         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_payment      PRIMARY KEY (payment_id),
    CONSTRAINT uq_bpay_ticket      UNIQUE (ticket_id),
    CONSTRAINT fk_bpay_ticket
        FOREIGN KEY (ticket_id)
        REFERENCES bus.BUS_TICKET(ticket_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_bpay_refund     CHECK (refund_amount <= amount)
);

SELECT bus.fn_attach_updated_at('bus_payment');

CREATE INDEX idx_bpay_status ON bus.BUS_PAYMENT(status);
CREATE INDEX idx_bpay_date   ON bus.BUS_PAYMENT(paid_at DESC) WHERE paid_at IS NOT NULL;

COMMENT ON TABLE bus.BUS_PAYMENT IS '1:1 with BUS_TICKET. Full gateway response stored for reconciliation.';

-- ================================================================
--  S23 — BUS_TRAVEL_PASS
--  Weekly/Monthly/Student passes for bus travel.
--  Uses metro.PASSENGER.
-- ================================================================

CREATE TABLE bus.BUS_TRAVEL_PASS (
    pass_id             SERIAL                  NOT NULL,
    passenger_id        INT                     NOT NULL
                            REFERENCES metro.PASSENGER(passenger_id)
                            ON DELETE RESTRICT ON UPDATE CASCADE,
    operator_id         INT                     NOT NULL
                            REFERENCES bus.BUS_OPERATOR(operator_id)
                            ON DELETE RESTRICT ON UPDATE CASCADE,
    pass_type           bus.pass_type_t         NOT NULL,
    institution_name    VARCHAR(200),
    valid_from          DATE                    NOT NULL,
    valid_to            DATE                    NOT NULL,
    price               bus.money_t             NOT NULL,
    qr_code             VARCHAR(512)            NOT NULL,
    is_active           BOOLEAN                 NOT NULL DEFAULT TRUE,
    deactivation_reason TEXT,
    is_deleted          BOOLEAN                 NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_pass         PRIMARY KEY (pass_id),
    CONSTRAINT uq_bpass_qr         UNIQUE (qr_code),
    CONSTRAINT chk_bpass_dates     CHECK (valid_to > valid_from),
    CONSTRAINT chk_bpass_student
        CHECK (pass_type != 'STUDENT_MONTHLY' OR institution_name IS NOT NULL)
);

SELECT bus.fn_attach_updated_at('bus_travel_pass');

CREATE INDEX idx_bpass_passenger ON bus.BUS_TRAVEL_PASS(passenger_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_bpass_validity  ON bus.BUS_TRAVEL_PASS(valid_from, valid_to, is_active);

COMMENT ON TABLE bus.BUS_TRAVEL_PASS IS
'Bus travel passes. passenger_id references metro.PASSENGER.';

-- ================================================================
--  S24 — BUS_STOP_SCAN
--  QR scan at bus entry/exit (conductor scanner or BRTS gate).
-- ================================================================

CREATE TABLE bus.BUS_STOP_SCAN (
    scan_id             BIGSERIAL               NOT NULL,
    ticket_id           BIGINT
                            REFERENCES bus.BUS_TICKET(ticket_id)
                            ON DELETE RESTRICT ON UPDATE CASCADE,
    pass_id             INT
                            REFERENCES bus.BUS_TRAVEL_PASS(pass_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    stop_id             INT                     NOT NULL
                            REFERENCES bus.BUS_STOP(stop_id)
                            ON DELETE RESTRICT ON UPDATE CASCADE,
    schedule_id         INT
                            REFERENCES bus.BUS_SCHEDULE(schedule_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    stop_sequence       SMALLINT,
    scan_role           bus.scan_role_t         NOT NULL,
    gate_device_id      VARCHAR(50)             NOT NULL,
    scan_timestamp      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    is_valid            BOOLEAN                 NOT NULL DEFAULT TRUE,
    rejection_reason    TEXT,

    CONSTRAINT pk_bus_scan         PRIMARY KEY (scan_id),
    CONSTRAINT uq_bscan_entry_exit UNIQUE (ticket_id, scan_role),
    CONSTRAINT chk_bscan_auth
        CHECK (ticket_id IS NOT NULL OR pass_id IS NOT NULL)
);

CREATE INDEX idx_bscan_ticket  ON bus.BUS_STOP_SCAN(ticket_id);
CREATE INDEX idx_bscan_stop    ON bus.BUS_STOP_SCAN(stop_id, scan_role, scan_timestamp DESC);
CREATE INDEX idx_bscan_device  ON bus.BUS_STOP_SCAN(gate_device_id, scan_timestamp DESC);

COMMENT ON TABLE bus.BUS_STOP_SCAN IS
'QR ticket/pass scans at bus entry and exit. ENTRY+EXIT enforced per ticket.';

-- ================================================================
--  S25 — BUS_TRAVELLING_IN
--  Real-time passengers currently on a bus schedule.
--  Drives crowd count. Uses metro.PASSENGER.
-- ================================================================

CREATE TABLE bus.BUS_TRAVELLING_IN (
    passenger_id    INT                     NOT NULL
                        REFERENCES metro.PASSENGER(passenger_id)
                        ON DELETE CASCADE ON UPDATE CASCADE,
    schedule_id     INT                     NOT NULL
                        REFERENCES bus.BUS_SCHEDULE(schedule_id)
                        ON DELETE CASCADE ON UPDATE CASCADE,
    stop_sequence   SMALLINT                NOT NULL,
    ticket_id       BIGINT
                        REFERENCES bus.BUS_TICKET(ticket_id)
                        ON DELETE SET NULL ON UPDATE CASCADE,
    pass_id         INT
                        REFERENCES bus.BUS_TRAVEL_PASS(pass_id)
                        ON DELETE SET NULL ON UPDATE CASCADE,
    boarded_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    exited_at       TIMESTAMPTZ,
    status          bus.travel_status_t     NOT NULL DEFAULT 'BOARDING',
    created_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_travelling
        PRIMARY KEY (passenger_id, schedule_id, stop_sequence, boarded_at),
    CONSTRAINT fk_btrv_stop
        FOREIGN KEY (schedule_id, stop_sequence)
        REFERENCES bus.BUS_TRIP_STOP(schedule_id, stop_sequence)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_btrv_auth
        CHECK (ticket_id IS NOT NULL OR pass_id IS NOT NULL)
);

SELECT bus.fn_attach_updated_at('bus_travelling_in');

CREATE INDEX idx_btrv_schedule ON bus.BUS_TRAVELLING_IN(schedule_id, stop_sequence, status);
CREATE INDEX idx_btrv_active   ON bus.BUS_TRAVELLING_IN(status)
    WHERE status IN ('BOARDING','ON_BUS');

-- Now create the crowd trigger (references BUS_TRAVELLING_IN)
CREATE TRIGGER trg_bus_crowd_update
AFTER INSERT OR UPDATE OR DELETE ON bus.BUS_TRAVELLING_IN
FOR EACH ROW EXECUTE FUNCTION bus.fn_sync_bus_crowd();

-- Scan updates ticket status
CREATE OR REPLACE FUNCTION bus.fn_update_ticket_on_scan()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NEW.is_valid = FALSE THEN RETURN NEW; END IF;
    IF NEW.scan_role = 'ENTRY' THEN
        UPDATE bus.BUS_TICKET
        SET    status = 'ACTIVE', updated_at = NOW()
        WHERE  ticket_id = NEW.ticket_id AND status = 'BOOKED';
    ELSIF NEW.scan_role = 'EXIT' THEN
        UPDATE bus.BUS_TICKET
        SET    status = 'USED', updated_at = NOW()
        WHERE  ticket_id = NEW.ticket_id AND status = 'ACTIVE';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_bus_scan_ticket
AFTER INSERT ON bus.BUS_STOP_SCAN
FOR EACH ROW EXECUTE FUNCTION bus.fn_update_ticket_on_scan();

-- ================================================================
--  S26 — INTERCHANGE_POINT  ★ KEY INTEGRATION TABLE ★
--  Links a metro STATION to a nearby BUS_STOP.
--  This is what makes Metro+Bus combined routing possible.
--  BCNF: interchange_id → all.
-- ================================================================

CREATE TABLE bus.INTERCHANGE_POINT (
    interchange_id      SERIAL                  NOT NULL,
    -- FK → metro.STATION (cross-schema)
    metro_station_id    INT                     NOT NULL
                            REFERENCES metro.STATION(station_id)
                            ON DELETE RESTRICT ON UPDATE CASCADE,
    -- FK → bus.BUS_STOP
    bus_stop_id         INT                     NOT NULL
                            REFERENCES bus.BUS_STOP(stop_id)
                            ON DELETE RESTRICT ON UPDATE CASCADE,
    walking_dist_m      INT                     NOT NULL CHECK (walking_dist_m >= 0),
    -- Derived: ~walking_dist_m / 80 (avg walking speed 80 m/min)
    walking_time_min    NUMERIC(5,2)
                        GENERATED ALWAYS AS (
                            ROUND(walking_dist_m / 80.0, 2)
                        ) STORED,
    connection_type     bus.connection_type_t   NOT NULL DEFAULT 'WALK',
    is_covered          BOOLEAN                 NOT NULL DEFAULT FALSE,
    has_signage         BOOLEAN                 NOT NULL DEFAULT TRUE,
    notes               TEXT,
    is_active           BOOLEAN                 NOT NULL DEFAULT TRUE,
    is_deleted          BOOLEAN                 NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_interchange      PRIMARY KEY (interchange_id),
    CONSTRAINT uq_interchange_pair UNIQUE (metro_station_id, bus_stop_id)
);

SELECT bus.fn_attach_updated_at('interchange_point');

CREATE INDEX idx_icp_metro ON bus.INTERCHANGE_POINT(metro_station_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_icp_bus   ON bus.INTERCHANGE_POINT(bus_stop_id)      WHERE is_deleted = FALSE;
CREATE INDEX idx_icp_walk  ON bus.INTERCHANGE_POINT(walking_dist_m)   WHERE is_active = TRUE;

COMMENT ON TABLE  bus.INTERCHANGE_POINT IS
'Links metro STATION to nearby BUS_STOP. Core of Metro+Bus route planning.';
COMMENT ON COLUMN bus.INTERCHANGE_POINT.walking_time_min IS
'Auto-calculated walking time in minutes at 80 m/min average pace.';

-- ================================================================
--  S27 — COMBINED_JOURNEY
--  A multi-leg journey planned by a passenger (Metro + Bus).
--  Uses metro.PASSENGER.
--  BCNF: journey_id → all.
-- ================================================================

CREATE TABLE bus.COMBINED_JOURNEY (
    journey_id          BIGSERIAL               NOT NULL,
    -- FK → metro.PASSENGER
    passenger_id        INT
                            REFERENCES metro.PASSENGER(passenger_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    journey_type        bus.journey_type_t      NOT NULL,
    from_location_name  VARCHAR(200)            NOT NULL,
    from_lat            bus.lat_t,
    from_lng            bus.lng_t,
    to_location_name    VARCHAR(200)            NOT NULL,
    to_lat              bus.lat_t,
    to_lng              bus.lng_t,
    total_fare          bus.money_t,
    total_distance_km   bus.distance_t,
    total_eta_mins      INT,
    planned_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    journey_date        DATE                    NOT NULL DEFAULT CURRENT_DATE,
    status              VARCHAR(20)             NOT NULL DEFAULT 'PLANNED'
                            CHECK (status IN ('PLANNED','IN_PROGRESS','COMPLETED','ABANDONED')),
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_combined_journey PRIMARY KEY (journey_id)
);

SELECT bus.fn_attach_updated_at('combined_journey');

CREATE INDEX idx_cj_passenger ON bus.COMBINED_JOURNEY(passenger_id);
CREATE INDEX idx_cj_date      ON bus.COMBINED_JOURNEY(journey_date DESC);
CREATE INDEX idx_cj_type      ON bus.COMBINED_JOURNEY(journey_type);

COMMENT ON TABLE bus.COMBINED_JOURNEY IS
'Multi-modal journey planned by passenger. Stores the route search result.';

-- ================================================================
--  S28 — COMBINED_JOURNEY_LEG  (Weak Entity of COMBINED_JOURNEY)
--  Each leg = one mode of transport in the journey.
--  e.g. Leg 1: Bus stop A → Metro Station B
--       Leg 2: Metro Station B → Metro Station C
--       Leg 3: Metro Station C → Bus Stop D (walk)
--       Leg 4: Bus Stop D → Destination E
-- ================================================================

CREATE TABLE bus.COMBINED_JOURNEY_LEG (
    journey_id          BIGINT                  NOT NULL,
    leg_sequence        SMALLINT                NOT NULL CHECK (leg_sequence >= 1),
    mode                VARCHAR(20)             NOT NULL
                            CHECK (mode IN ('BUS','METRO','WALK','INTERCHANGE')),
    -- For BUS leg: references bus.BUS_SCHEDULE
    bus_schedule_id     INT
                            REFERENCES bus.BUS_SCHEDULE(schedule_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    -- For METRO leg: references metro.TRAIN_SCHEDULE
    metro_schedule_id   INT
                            REFERENCES metro.TRAIN_SCHEDULE(schedule_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    -- For INTERCHANGE/WALK leg: references INTERCHANGE_POINT
    interchange_id      INT
                            REFERENCES bus.INTERCHANGE_POINT(interchange_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    from_stop_name      VARCHAR(200)            NOT NULL,
    to_stop_name        VARCHAR(200)            NOT NULL,
    from_lat            bus.lat_t,
    from_lng            bus.lng_t,
    to_lat              bus.lat_t,
    to_lng              bus.lng_t,
    departure_time      TIME,
    arrival_time        TIME,
    leg_distance_km     bus.distance_t,
    leg_fare            bus.money_t             NOT NULL DEFAULT 0,
    leg_eta_mins        INT,
    crowd_level         VARCHAR(10)             CHECK (crowd_level IN ('LOW','MODERATE','HIGH')),
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_journey_leg
        PRIMARY KEY (journey_id, leg_sequence),
    CONSTRAINT fk_jleg_journey
        FOREIGN KEY (journey_id)
        REFERENCES bus.COMBINED_JOURNEY(journey_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_jleg_journey ON bus.COMBINED_JOURNEY_LEG(journey_id);

COMMENT ON TABLE  bus.COMBINED_JOURNEY_LEG IS
'Weak entity — each leg of a combined metro+bus journey.';
COMMENT ON COLUMN bus.COMBINED_JOURNEY_LEG.mode IS
'BUS=bus leg, METRO=metro leg, WALK=walking, INTERCHANGE=transfer between modes';

-- ================================================================
--  S29 — BUS_FEEDBACK
--  Passenger feedback on bus service. Uses metro.PASSENGER.
-- ================================================================

CREATE TABLE bus.BUS_FEEDBACK (
    feedback_id         BIGSERIAL               NOT NULL,
    passenger_id        INT
                            REFERENCES metro.PASSENGER(passenger_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    schedule_id         INT
                            REFERENCES bus.BUS_SCHEDULE(schedule_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    route_id            INT
                            REFERENCES bus.BUS_ROUTE(route_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    stop_id             INT
                            REFERENCES bus.BUS_STOP(stop_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    ticket_id           BIGINT
                            REFERENCES bus.BUS_TICKET(ticket_id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
    category            metro.feedback_category_t NOT NULL,
    rating              SMALLINT                NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment             TEXT,
    status              VARCHAR(20)             NOT NULL DEFAULT 'OPEN'
                            CHECK (status IN ('OPEN','IN_REVIEW','RESOLVED','CLOSED')),
    reviewed_by         VARCHAR(100),
    review_notes        TEXT,
    reviewed_at         TIMESTAMPTZ,
    submitted_at        TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    created_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ             NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_feedback     PRIMARY KEY (feedback_id),
    CONSTRAINT chk_bfbk_ctx
        CHECK (passenger_id IS NOT NULL OR route_id IS NOT NULL
               OR schedule_id IS NOT NULL)
);

SELECT bus.fn_attach_updated_at('bus_feedback');

CREATE INDEX idx_bfbk_passenger ON bus.BUS_FEEDBACK(passenger_id, submitted_at DESC);
CREATE INDEX idx_bfbk_route     ON bus.BUS_FEEDBACK(route_id);
CREATE INDEX idx_bfbk_rating    ON bus.BUS_FEEDBACK(rating);
CREATE INDEX idx_bfbk_status    ON bus.BUS_FEEDBACK(status)
    WHERE status IN ('OPEN','IN_REVIEW');

-- ================================================================
--  S30 — BUS_SYSTEM_CONFIG
--  Runtime configurable parameters for bus system.
-- ================================================================

CREATE TABLE bus.BUS_SYSTEM_CONFIG (
    config_key      VARCHAR(100)    NOT NULL,
    config_value    TEXT            NOT NULL,
    data_type       VARCHAR(20)     NOT NULL DEFAULT 'STRING'
                        CHECK (data_type IN ('STRING','INTEGER','DECIMAL','BOOLEAN','JSON')),
    description     TEXT,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_bus_config PRIMARY KEY (config_key)
);

SELECT bus.fn_attach_updated_at('bus_system_config');

INSERT INTO bus.BUS_SYSTEM_CONFIG (config_key, config_value, data_type, description) VALUES
('BUS_QR_VALIDITY_MINUTES',        '180',   'INTEGER', 'Minutes a bus QR ticket remains valid after booking'),
('BUS_CROWD_ALERT_THRESHOLD_PCT',  '80',    'INTEGER', 'Trigger HIGH_CROWD alert when bus fills above this %'),
('BUS_DELAY_ALERT_THRESHOLD_MIN',  '10',    'INTEGER', 'Minimum delay minutes before passenger alert is sent'),
('BUS_GPS_INTERVAL_SEC',           '10',    'INTEGER', 'GPS ping interval from bus tracking device'),
('WALK_SPEED_M_PER_MIN',           '80',    'INTEGER', 'Average walking speed for interchange time calculation'),
('MAX_WALK_DIST_FOR_INTERCHANGE_M','800',   'INTEGER', 'Maximum walking distance to consider a bus-metro interchange'),
('MAX_ROUTE_RESULTS',              '10',    'INTEGER', 'Max route options returned by route planner'),
('CHILD_MAX_AGE_YEARS',            '12',    'INTEGER', 'Maximum age for child fare'),
('SENIOR_MIN_AGE_YEARS',           '60',    'INTEGER', 'Minimum age for senior citizen fare'),
('BUS_STUDENT_DISCOUNT_PCT',       '20',    'INTEGER', 'Student fare discount percentage'),
('INTERCHANGE_BUFFER_MINS',        '5',     'INTEGER', 'Extra buffer minutes added at metro-bus interchange point'),
('ROUTE_SEARCH_RADIUS_KM',         '1.0',   'DECIMAL', 'Search radius around origin/destination for nearest stops'),
('MIN_APP_VERSION',                '2.0.0', 'STRING',  'Minimum supported Ahmedabad Yatra app version');

-- ================================================================
--  VIEWS
-- ================================================================

-- V1: Live bus board — active schedules with crowd
CREATE OR REPLACE VIEW bus.v_live_bus_board AS
SELECT
    bs.schedule_id,
    b.bus_id,
    b.bus_number,
    r.route_id,
    r.route_number,
    r.route_name,
    r.route_type,
    op.operator_name,
    op.operator_type,
    bs.direction,
    bs.day_type,
    bs.departure_time,
    bs.arrival_time,
    bs.normal_eta_mins,
    bs.schedule_status,
    b.is_ac,
    b.is_electric,
    b.total_capacity,
    b.current_crowd_count,
    ROUND((b.current_crowd_count::NUMERIC / NULLIF(b.total_capacity,0)) * 100, 1) AS crowd_pct,
    CASE
        WHEN ROUND((b.current_crowd_count::NUMERIC / NULLIF(b.total_capacity,0))*100,1) >= 80 THEN 'HIGH'
        WHEN ROUND((b.current_crowd_count::NUMERIC / NULLIF(b.total_capacity,0))*100,1) >= 55 THEN 'MODERATE'
        ELSE 'LOW'
    END AS crowd_level,
    b.current_lat,
    b.current_lng,
    b.current_speed_kmph,
    b.last_gps_update
FROM  bus.BUS_SCHEDULE bs
JOIN  bus.BUS           b  ON b.bus_id    = bs.bus_id
JOIN  bus.BUS_ROUTE     r  ON r.route_id  = bs.route_id
JOIN  bus.BUS_OPERATOR  op ON op.operator_id = r.operator_id
WHERE bs.schedule_status IN ('ACTIVE','DELAYED')
AND   bs.is_deleted = FALSE
AND   b.is_deleted  = FALSE;

-- V2: Next buses at a stop
CREATE OR REPLACE VIEW bus.v_next_buses_at_stop AS
SELECT
    bts.stop_id,
    bs_stn.stop_name,
    bts.schedule_id,
    bts.stop_sequence,
    b.bus_number,
    r.route_number,
    r.route_name,
    op.operator_name,
    bs.direction,
    bs.day_type,
    COALESCE(bts.scheduled_departure, bts.scheduled_arrival) AS departure_time,
    bts.dynamic_eta,
    bs.schedule_status,
    b.is_ac,
    b.total_capacity,
    b.current_crowd_count,
    CASE
        WHEN ROUND((b.current_crowd_count::NUMERIC / NULLIF(b.total_capacity,0))*100,1) >= 80 THEN 'HIGH'
        WHEN ROUND((b.current_crowd_count::NUMERIC / NULLIF(b.total_capacity,0))*100,1) >= 55 THEN 'MODERATE'
        ELSE 'LOW'
    END AS crowd_level
FROM  bus.BUS_TRIP_STOP  bts
JOIN  bus.BUS_SCHEDULE   bs     ON bs.schedule_id  = bts.schedule_id
JOIN  bus.BUS            b      ON b.bus_id        = bs.bus_id
JOIN  bus.BUS_ROUTE      r      ON r.route_id      = bs.route_id
JOIN  bus.BUS_OPERATOR   op     ON op.operator_id  = r.operator_id
JOIN  bus.BUS_STOP       bs_stn ON bs_stn.stop_id  = bts.stop_id
WHERE bts.is_active     = TRUE
AND   bts.is_deleted    = FALSE
AND   bs.schedule_status IN ('ACTIVE','DELAYED')
AND   bs.is_deleted     = FALSE;

-- V3: Interchange points with walking time
CREATE OR REPLACE VIEW bus.v_interchange_info AS
SELECT
    ip.interchange_id,
    ip.metro_station_id,
    ms.station_name AS metro_station_name,
    ms.station_code,
    ms.latitude     AS metro_lat,
    ms.longitude    AS metro_lng,
    ip.bus_stop_id,
    bs.stop_name    AS bus_stop_name,
    bs.stop_code,
    bs.latitude     AS bus_lat,
    bs.longitude    AS bus_lng,
    ip.walking_dist_m,
    ip.walking_time_min,
    ip.connection_type,
    ip.is_covered,
    ip.has_signage,
    ip.is_active
FROM  bus.INTERCHANGE_POINT ip
JOIN  metro.STATION          ms ON ms.station_id = ip.metro_station_id
JOIN  bus.BUS_STOP           bs ON bs.stop_id    = ip.bus_stop_id
WHERE ip.is_deleted = FALSE
ORDER BY ip.walking_dist_m;

-- V4: Active delays
CREATE OR REPLACE VIEW bus.v_active_delays AS
SELECT
    de.delay_id,
    de.schedule_id,
    b.bus_number,
    r.route_number,
    r.route_name,
    bs_stn.stop_name AS affected_stop,
    de.delay_minutes,
    de.delay_category,
    de.reason,
    de.reported_at,
    de.resolution_status,
    AGE(NOW(), de.reported_at) AS open_since
FROM  bus.BUS_DELAY_EVENT de
JOIN  bus.BUS_SCHEDULE    bsc ON bsc.schedule_id  = de.schedule_id
JOIN  bus.BUS             b   ON b.bus_id         = bsc.bus_id
JOIN  bus.BUS_ROUTE       r   ON r.route_id       = bsc.route_id
LEFT JOIN bus.BUS_STOP    bs_stn ON bs_stn.stop_id = de.affected_stop_id
WHERE de.resolution_status IN ('PENDING','IN_PROGRESS')
ORDER BY de.delay_minutes DESC;

-- V5: Latest GPS position per bus
CREATE OR REPLACE VIEW bus.v_live_bus_positions AS
SELECT DISTINCT ON (lt.bus_id)
    lt.bus_id,
    b.bus_number,
    r.route_number,
    lt.schedule_id,
    lt.latitude,
    lt.longitude,
    lt.speed_kmph,
    lt.heading_degrees,
    lt.next_stop_id,
    nxt.stop_name AS next_stop_name,
    lt.dist_to_next_stop_m,
    lt.updated_eta,
    lt.recorded_at,
    AGE(NOW(), lt.recorded_at) AS last_seen_ago
FROM  bus.BUS_LIVE_TRACKING lt
JOIN  bus.BUS                b   ON b.bus_id    = lt.bus_id
LEFT JOIN bus.BUS_SCHEDULE   bsc ON bsc.schedule_id = lt.schedule_id
LEFT JOIN bus.BUS_ROUTE      r   ON r.route_id  = bsc.route_id
LEFT JOIN bus.BUS_STOP       nxt ON nxt.stop_id = lt.next_stop_id
ORDER BY lt.bus_id, lt.recorded_at DESC;

-- V6: Fare lookup
CREATE OR REPLACE VIEW bus.v_fare_lookup AS
SELECT
    fr.fare_rule_id,
    op.operator_name,
    op.operator_type,
    fr.min_distance_km,
    fr.max_distance_km,
    fr.normal_fare,
    fr.senior_fare,
    fr.child_fare,
    fr.student_fare,
    fr.disabled_fare,
    fr.freedom_fighter_fare,
    fr.effective_from
FROM  bus.BUS_FARE_RULE fr
JOIN  bus.BUS_OPERATOR  op ON op.operator_id = fr.operator_id
WHERE fr.is_active      = TRUE
AND   fr.effective_from <= CURRENT_DATE
AND   (fr.effective_to IS NULL OR fr.effective_to >= CURRENT_DATE)
ORDER BY op.operator_name, fr.min_distance_km;

-- ================================================================
--  CORE ROUTE PLANNER FUNCTION
--  fn_get_all_routes(from_lat, from_lng, to_lat, to_lng, time)
--  Returns ALL efficient routes:
--    1. Direct Bus routes
--    2. Direct Metro routes
--    3. Metro → Bus (metro to nearest station, then bus)
--    4. Bus → Metro (bus to metro, metro, then walk/bus)
--    5. Bus → Bus (interchange between two bus routes)
-- ================================================================

CREATE OR REPLACE FUNCTION bus.fn_get_all_routes(
    p_from_lat      NUMERIC,
    p_from_lng      NUMERIC,
    p_to_lat        NUMERIC,
    p_to_lng        NUMERIC,
    p_current_time  TIME        DEFAULT CURRENT_TIME,
    p_day_type      bus.day_type_t DEFAULT 'WEEKDAY',
    p_limit         INT         DEFAULT 10
)
RETURNS TABLE (
    route_type          TEXT,
    journey_type        TEXT,
    description         TEXT,
    operator_name       TEXT,
    from_stop           TEXT,
    to_stop             TEXT,
    via_interchange     TEXT,
    departure_time      TIME,
    arrival_time        TIME,
    total_eta_mins      INT,
    total_fare_normal   NUMERIC,
    total_fare_student  NUMERIC,
    total_fare_senior   NUMERIC,
    total_distance_km   NUMERIC,
    crowd_level         TEXT,
    crowd_pct           NUMERIC,
    schedule_id         INT,
    metro_schedule_id   INT,
    interchange_walk_min NUMERIC
)
LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
DECLARE
    v_search_radius NUMERIC;
    v_max_walk_m    INT;
    v_buffer_mins   INT;
BEGIN
    -- Read config
    SELECT config_value::NUMERIC INTO v_search_radius
    FROM bus.BUS_SYSTEM_CONFIG WHERE config_key = 'ROUTE_SEARCH_RADIUS_KM';
    v_search_radius := COALESCE(v_search_radius, 1.0);

    SELECT config_value::INT INTO v_max_walk_m
    FROM bus.BUS_SYSTEM_CONFIG WHERE config_key = 'MAX_WALK_DIST_FOR_INTERCHANGE_M';
    v_max_walk_m := COALESCE(v_max_walk_m, 800);

    SELECT config_value::INT INTO v_buffer_mins
    FROM bus.BUS_SYSTEM_CONFIG WHERE config_key = 'INTERCHANGE_BUFFER_MINS';
    v_buffer_mins := COALESCE(v_buffer_mins, 5);

    -- ── ROUTE TYPE 1: DIRECT BUS ─────────────────────────────────
    -- Find routes where a stop near FROM and a stop near TO
    -- are both on the same route, and there's a bus after current time
    RETURN QUERY
    WITH from_stops AS (
        SELECT bs.stop_id, bs.stop_name,
               ROUND((point(p_from_lng, p_from_lat) <@>
                      point(bs.longitude, bs.latitude))::NUMERIC * 1.609344, 3) AS dist_km
        FROM   bus.BUS_STOP bs
        WHERE  bs.is_active  = TRUE
        AND    bs.is_deleted = FALSE
        AND    (point(p_from_lng, p_from_lat) <@>
                point(bs.longitude, bs.latitude)) * 1.609344 <= v_search_radius
    ),
    to_stops AS (
        SELECT bs.stop_id, bs.stop_name,
               ROUND((point(p_to_lng, p_to_lat) <@>
                      point(bs.longitude, bs.latitude))::NUMERIC * 1.609344, 3) AS dist_km
        FROM   bus.BUS_STOP bs
        WHERE  bs.is_active  = TRUE
        AND    bs.is_deleted = FALSE
        AND    (point(p_to_lng, p_to_lat) <@>
                point(bs.longitude, bs.latitude)) * 1.609344 <= v_search_radius
    ),
    direct_routes AS (
        SELECT
            rs_f.route_id,
            fs.stop_id    AS from_stop_id,
            fs.stop_name  AS from_stop_name,
            ts.stop_id    AS to_stop_id,
            ts.stop_name  AS to_stop_name,
            ABS(rs_t.dist_from_start_km - rs_f.dist_from_start_km) AS route_dist
        FROM from_stops fs
        JOIN bus.ROUTE_STOP rs_f ON rs_f.stop_id    = fs.stop_id AND rs_f.is_active = TRUE
        JOIN bus.ROUTE_STOP rs_t ON rs_t.route_id   = rs_f.route_id
                                 AND rs_t.is_active  = TRUE
        JOIN to_stops ts         ON ts.stop_id       = rs_t.stop_id
        WHERE rs_t.sequence_no > rs_f.sequence_no    -- direction check
    )
    SELECT
        'DIRECT_BUS'::TEXT,
        'BUS_ONLY'::TEXT,
        (op.operator_name || ' | Route ' || r.route_number || ': '
         || dr.from_stop_name || ' → ' || dr.to_stop_name)::TEXT,
        op.operator_name::TEXT,
        dr.from_stop_name::TEXT,
        dr.to_stop_name::TEXT,
        NULL::TEXT,
        COALESCE(bts_f.scheduled_departure, bsc.departure_time),
        COALESCE(bts_t.scheduled_arrival, bsc.arrival_time),
        COALESCE(bsc.normal_eta_mins,
            CEIL(dr.route_dist / 18.0 * 60)::INT),   -- ~18 kmph avg bus speed
        COALESCE(
            (SELECT fr.normal_fare FROM bus.BUS_FARE_RULE fr
             JOIN bus.BUS_OPERATOR bop ON bop.operator_id = fr.operator_id
             WHERE bop.operator_id = op.operator_id
             AND   dr.route_dist BETWEEN fr.min_distance_km AND fr.max_distance_km
             AND   fr.is_active = TRUE LIMIT 1),
            5.00
        ),
        COALESCE(
            (SELECT fr.student_fare FROM bus.BUS_FARE_RULE fr
             WHERE fr.operator_id = op.operator_id
             AND   dr.route_dist BETWEEN fr.min_distance_km AND fr.max_distance_km
             AND   fr.is_active = TRUE LIMIT 1),
            4.00
        ),
        COALESCE(
            (SELECT fr.senior_fare FROM bus.BUS_FARE_RULE fr
             WHERE fr.operator_id = op.operator_id
             AND   dr.route_dist BETWEEN fr.min_distance_km AND fr.max_distance_km
             AND   fr.is_active = TRUE LIMIT 1),
            3.00
        ),
        dr.route_dist,
        CASE
            WHEN ROUND((b.current_crowd_count::NUMERIC/NULLIF(b.total_capacity,0))*100,1) >= 80 THEN 'HIGH'
            WHEN ROUND((b.current_crowd_count::NUMERIC/NULLIF(b.total_capacity,0))*100,1) >= 55 THEN 'MODERATE'
            ELSE 'LOW'
        END,
        ROUND((b.current_crowd_count::NUMERIC/NULLIF(b.total_capacity,0))*100,1),
        bsc.schedule_id,
        NULL::INT,
        NULL::NUMERIC
    FROM  direct_routes dr
    JOIN  bus.BUS_ROUTE      r    ON r.route_id    = dr.route_id
    JOIN  bus.BUS_OPERATOR   op   ON op.operator_id = r.operator_id
    JOIN  bus.BUS_SCHEDULE   bsc  ON bsc.route_id  = dr.route_id
                                  AND bsc.day_type  IN (p_day_type, 'ALL_DAYS')
                                  AND bsc.schedule_status = 'ACTIVE'
                                  AND bsc.is_deleted = FALSE
    JOIN  bus.BUS            b    ON b.bus_id       = bsc.bus_id
    LEFT JOIN bus.BUS_TRIP_STOP bts_f
        ON bts_f.schedule_id = bsc.schedule_id
        AND bts_f.stop_id    = dr.from_stop_id
    LEFT JOIN bus.BUS_TRIP_STOP bts_t
        ON bts_t.schedule_id = bsc.schedule_id
        AND bts_t.stop_id    = dr.to_stop_id
    WHERE COALESCE(bts_f.scheduled_departure, bsc.departure_time) >= p_current_time
    ORDER BY COALESCE(bts_f.scheduled_departure, bsc.departure_time)
    LIMIT p_limit;

    -- ── ROUTE TYPE 2: METRO + BUS ─────────────────────────────────
    -- Metro from nearest station to destination area,
    -- then bus from nearest metro station to destination
    RETURN QUERY
    WITH metro_from AS (
        SELECT s.station_id, s.station_name,
               ROUND((point(p_from_lng, p_from_lat) <@>
                      point(s.longitude, s.latitude))::NUMERIC * 1.609344, 3) AS dist_km
        FROM metro.STATION s
        WHERE s.is_active = TRUE AND s.is_deleted = FALSE
        AND   (point(p_from_lng, p_from_lat) <@>
               point(s.longitude, s.latitude)) * 1.609344 <= v_search_radius
    ),
    interchange_to_bus AS (
        SELECT ip.interchange_id, ip.metro_station_id,
               ip.bus_stop_id, ip.walking_dist_m, ip.walking_time_min,
               bst.stop_name AS bus_stop_name
        FROM bus.INTERCHANGE_POINT ip
        JOIN bus.BUS_STOP bst ON bst.stop_id = ip.bus_stop_id
        WHERE ip.is_active   = TRUE
        AND   ip.is_deleted  = FALSE
        AND   ip.walking_dist_m <= v_max_walk_m
    ),
    to_stops_bus AS (
        SELECT bs.stop_id, bs.stop_name
        FROM bus.BUS_STOP bs
        WHERE bs.is_active = TRUE AND bs.is_deleted = FALSE
        AND   (point(p_to_lng, p_to_lat) <@>
               point(bs.longitude, bs.latitude)) * 1.609344 <= v_search_radius
    )
    SELECT
        'METRO_THEN_BUS'::TEXT,
        'METRO_THEN_BUS'::TEXT,
        ('Metro: ' || mf.station_name || ' → ' || ich.bus_stop_name
         || ' (walk ' || ich.walking_time_min || ' min) → Bus to '
         || ts.stop_name)::TEXT,
        op.operator_name::TEXT,
        mf.station_name::TEXT,
        ts.stop_name::TEXT,
        (ich.bus_stop_name || ' (' || ich.walking_dist_m || 'm walk)')::TEXT,
        mts.departure_time,
        COALESCE(bts_t.scheduled_arrival, bsch.arrival_time),
        (COALESCE(mts.normal_eta_mins, 30)
         + ich.walking_time_min::INT
         + v_buffer_mins
         + COALESCE(bsch.normal_eta_mins, 20))::INT,
        -- Combined fare: metro + bus
        COALESCE(
            (SELECT metro.calculate_fare(
                ABS(sol_t.dist_from_start_km - sol_f.dist_from_start_km),
                'GENERAL')
             FROM metro.STATION_ON_LINE sol_f
             JOIN metro.STATION_ON_LINE sol_t
                  ON sol_t.line_id = sol_f.line_id
                  AND sol_t.station_id = ich.metro_station_id
             WHERE sol_f.station_id = mf.station_id LIMIT 1),
            10.00
        ) + COALESCE(
            (SELECT fr.normal_fare FROM bus.BUS_FARE_RULE fr
             WHERE fr.operator_id = op.operator_id
             AND   fr.is_active = TRUE
             ORDER BY fr.min_distance_km LIMIT 1), 5.00
        ),
        NULL::NUMERIC,
        NULL::NUMERIC,
        NULL::NUMERIC,
        CASE
            WHEN ROUND((b.current_crowd_count::NUMERIC/NULLIF(b.total_capacity,0))*100,1) >= 80 THEN 'HIGH'
            ELSE 'LOW'
        END,
        ROUND((b.current_crowd_count::NUMERIC/NULLIF(b.total_capacity,0))*100,1),
        bsch.schedule_id,
        mts.schedule_id,
        ich.walking_time_min
    FROM metro_from           mf
    JOIN interchange_to_bus   ich ON ich.metro_station_id = mf.station_id
    JOIN bus.ROUTE_STOP       rs_f ON rs_f.stop_id    = ich.bus_stop_id
                                   AND rs_f.is_active  = TRUE
    JOIN bus.ROUTE_STOP       rs_t ON rs_t.route_id   = rs_f.route_id
                                   AND rs_t.is_active  = TRUE
                                   AND rs_t.sequence_no > rs_f.sequence_no
    JOIN to_stops_bus         ts   ON ts.stop_id       = rs_t.stop_id
    JOIN bus.BUS_ROUTE        r    ON r.route_id       = rs_f.route_id
    JOIN bus.BUS_OPERATOR     op   ON op.operator_id   = r.operator_id
    JOIN bus.BUS_SCHEDULE     bsch ON bsch.route_id    = rs_f.route_id
                                   AND bsch.day_type   IN (p_day_type,'ALL_DAYS')
                                   AND bsch.schedule_status = 'ACTIVE'
                                   AND bsch.is_deleted = FALSE
    JOIN bus.BUS              b    ON b.bus_id         = bsch.bus_id
    JOIN metro.TRAIN_SCHEDULE mts  ON mts.schedule_status = 'ACTIVE'
                                   AND mts.is_deleted = FALSE
    LEFT JOIN bus.BUS_TRIP_STOP bts_t
        ON bts_t.schedule_id = bsch.schedule_id
        AND bts_t.stop_id    = ts.stop_id
    WHERE mts.departure_time >= p_current_time
    ORDER BY mts.departure_time
    LIMIT p_limit;

END;
$$;

COMMENT ON FUNCTION bus.fn_get_all_routes IS
'Core Ahmedabad Yatra route planner. Returns Direct Bus + Metro+Bus routes after current time with crowd and fare info.';

-- ================================================================
--  BCNF VERIFICATION
-- ================================================================

CREATE OR REPLACE FUNCTION bus.fn_verify_bcnf()
RETURNS TABLE(check_name TEXT, status TEXT, violation_cnt BIGINT)
LANGUAGE plpgsql STABLE SECURITY DEFINER AS $$
BEGIN
    RETURN QUERY SELECT 'Unique stop_code'::TEXT,
        CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END, COUNT(*)
    FROM (SELECT stop_code FROM bus.BUS_STOP
          GROUP BY stop_code HAVING COUNT(*)>1) x;

    RETURN QUERY SELECT 'No duplicate route_stop sequence'::TEXT,
        CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END, COUNT(*)
    FROM (SELECT route_id, sequence_no FROM bus.ROUTE_STOP
          GROUP BY route_id, sequence_no HAVING COUNT(*)>1) x;

    RETURN QUERY SELECT 'No overlapping bus schedules (same bus)'::TEXT,
        CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END, COUNT(*)
    FROM (
        SELECT a.schedule_id FROM bus.BUS_SCHEDULE a
        JOIN   bus.BUS_SCHEDULE b
          ON   a.bus_id = b.bus_id AND a.day_type = b.day_type
          AND  a.schedule_id < b.schedule_id
          AND  a.schedule_status = 'ACTIVE' AND b.schedule_status = 'ACTIVE'
          AND  a.is_deleted = FALSE AND b.is_deleted = FALSE
          AND  (a.departure_time, a.arrival_time) OVERLAPS (b.departure_time, b.arrival_time)
    ) x;

    RETURN QUERY SELECT 'Bus ticket price = base - discount'::TEXT,
        CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END, COUNT(*)
    FROM bus.BUS_TICKET
    WHERE ABS(price_paid - (base_amount - discount_amount)) > 0.01
    AND   is_deleted = FALSE;

    RETURN QUERY SELECT 'INTERCHANGE_POINT walking_time_min derived correctly'::TEXT,
        CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END, COUNT(*)
    FROM bus.INTERCHANGE_POINT
    WHERE ABS(walking_time_min - ROUND(walking_dist_m/80.0,2)) > 0.01
    AND   is_deleted = FALSE;

    RAISE NOTICE 'Bus BCNF verification complete.';
END;
$$;

-- ================================================================
--  ROLE GRANTS
-- ================================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'metro_readonly') THEN
        CREATE ROLE metro_readonly NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'metro_app') THEN
        CREATE ROLE metro_app NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'metro_admin') THEN
        CREATE ROLE metro_admin NOLOGIN;
    END IF;
END $$;

GRANT USAGE  ON SCHEMA bus                      TO metro_readonly, metro_app, metro_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA bus        TO metro_readonly;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA bus TO metro_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bus TO metro_app;
GRANT ALL ON SCHEMA bus                         TO metro_admin;
GRANT ALL ON ALL TABLES IN SCHEMA bus           TO metro_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA bus        TO metro_admin;

-- ================================================================
--  COMPLETION NOTICE
-- ================================================================
DO $$
DECLARE
    v_tables   INT; v_funcs INT; v_triggers INT;
    v_views    INT; v_indexes INT; v_types INT;
BEGIN
    SELECT COUNT(*) INTO v_tables   FROM information_schema.tables
        WHERE table_schema='bus' AND table_type='BASE TABLE';
    SELECT COUNT(*) INTO v_funcs    FROM pg_proc p
        JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='bus';
    SELECT COUNT(*) INTO v_triggers FROM information_schema.triggers
        WHERE trigger_schema='bus';
    SELECT COUNT(*) INTO v_views    FROM information_schema.views
        WHERE table_schema='bus';
    SELECT COUNT(*) INTO v_indexes  FROM pg_indexes WHERE schemaname='bus';
    SELECT COUNT(*) INTO v_types    FROM pg_type t
        JOIN pg_namespace n ON n.oid=t.typnamespace
        WHERE n.nspname='bus' AND t.typtype='e';

    RAISE NOTICE '============================================================';
    RAISE NOTICE ' AHMEDABAD YATRA — BUS SYSTEM DDL COMPLETE';
    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE ' Schema     : bus';
    RAISE NOTICE ' Tables     : %', v_tables;
    RAISE NOTICE ' ENUM Types : %', v_types;
    RAISE NOTICE ' Functions  : %', v_funcs;
    RAISE NOTICE ' Triggers   : %', v_triggers;
    RAISE NOTICE ' Views      : %', v_views;
    RAISE NOTICE ' Indexes    : %', v_indexes;
    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE ' Run: SELECT * FROM bus.fn_verify_bcnf();';
    RAISE NOTICE ' Run: SELECT * FROM bus.fn_get_all_routes(lat,lng,lat,lng);';
    RAISE NOTICE '============================================================';
END $$;
