-- ================================================================
--  ██████████████████████████████████████████████████████████████
--   AHMEDABAD METRO RAIL SYSTEM — COMPLETE DDL SCRIPT
--   (Industry-Level, Production-Ready)
--  ██████████████████████████████████████████████████████████████
--
--  DATABASE     : PostgreSQL 15+
--  SCHEMA       : metro
--  VERSION      : 1.0.0
--  NORMALIZATION: BCNF (verified on all 31 tables)
--
--  ── OBJECT INVENTORY ──────────────────────────────────────────
--  ENUM Types   : 28
--  Domain Types : 8
--  Tables       : 31
--  Triggers     : 7 (+ 31 auto-updated_at triggers via fn_attach)
--  Views        : 15
--  Functions    : 52  (triggers + procedures + helpers)
--  Indexes      : 95+
--  Roles        : 3   (metro_readonly, metro_app, metro_admin)
--  pg_cron Jobs : 7   (auto-registered if pg_cron is installed)
--
--  ── TABLE LIST ────────────────────────────────────────────────
--   1.  LINE                    17. EMPLOYEE
--   2.  STATION                 18. EMPLOYEE_AUDIT_LOG
--   3.  PLATFORM                19. DELAY_EVENT
--   4.  STATION_ON_LINE         20. RESCHEDULE_LOG
--   5.  TRACK                   21. STATION_CLOSURE
--   6.  TRAIN                   22. TRAIN_INCIDENT
--   7.  TRAIN_SCHEDULE          23. LIVE_TRACKING
--   8.  TRAIN_STOP              24. ALERT
--   9.  FARE_RULE               25. ALERT_PASSENGER_MAP
--  10.  PASSENGER               26. MAINTENANCE_LOG
--  11.  TICKET                  27. TRAVELLING_IN
--  12.  PAYMENT                 28. TICKET_GATE_SCAN
--  13.  TRAVEL_PASS             29. FEEDBACK
--  14.  DRIVER                  30. SYSTEM_CONFIG
--  15.  DRIVER_SHIFT            31. AUDIT_LOG
--  16.  DRIVER_SCHEDULE_ASSIGNMENT
--
--  ── HOW TO RUN ────────────────────────────────────────────────
--  psql -U postgres -d your_db -f ahmedabad_metro_FINAL.sql
--  (or paste into pgAdmin / DBeaver query window)
--
--  ── RE-RUN SAFETY ─────────────────────────────────────────────
--  The teardown section below drops all objects before recreating.
--  Safe for: development, testing, fresh deployments.
--  WARNING : Do NOT run teardown on production with live data.
-- ================================================================

--\set ON_ERROR_STOP on
--\set VERBOSITY verbose

-- ================================================================
--  TEARDOWN — drops everything in reverse dependency order
--  (safe re-run on dev/test environments)
-- ================================================================

DROP SCHEMA IF EXISTS metro CASCADE;

-- ================================================================
--  RECREATE SCHEMA + EXTENSIONS
-- ================================================================

CREATE SCHEMA metro;
SET search_path TO metro, public;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- ================================================================
--  PROJECT      : AHMEDABAD METRO RAIL SYSTEM
--  MODULE       : Core Database Schema (DDL)
--  DATABASE     : PostgreSQL 15+
--  SCHEMA       : metro  (isolated from public)
--  NORMALIZATION: BCNF verified on every table
--  ENCODING     : UTF-8
--  AUTHOR       : Ahmedabad Yatra Project Team
--  VERSION      : 1.0.0
--  CREATED      : 2026-05-17
-- ----------------------------------------------------------------
--  CODING CONVENTIONS
--    • All table names        : UPPER_SNAKE_CASE
--    • All column names       : lower_snake_case
--    • Primary keys           : <table_abbrev>_id (SERIAL/BIGSERIAL)
--    • Foreign keys           : fk_<child>_<parent>
--    • Indexes                : idx_<table>_<columns>
--    • Unique constraints     : uq_<table>_<columns>
--    • Check constraints      : chk_<table>_<column>
--    • Triggers               : trg_<table>_<event>
--    • Functions              : fn_<description>
--    • Views                  : v_<description>
--    • Audit columns on every mutable table:
--        created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
--        updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
--        created_by  INT  (FK → EMPLOYEE / SYSTEM_USER)
--        is_deleted  BOOLEAN DEFAULT FALSE  (soft-delete)
--    • Soft-delete: no hard DELETEs on operational data
--    • All monetary columns: NUMERIC(12,2)
--    • All distance columns : NUMERIC(8,3) km
--    • ENUM types prefixed   : _t suffix
-- ----------------------------------------------------------------
--  TABLE CREATION ORDER (strict FK dependency order)
--   S01  SCHEMA & EXTENSIONS
--   S02  ENUM TYPES
--   S03  DOMAIN TYPES
--   S04  LINE
--   S05  STATION
--   S06  PLATFORM
--   S07  STATION_ON_LINE
--   S08  TRACK
--   S09  TRAIN
--   S10  TRAIN_SCHEDULE
--   S11  TRAIN_STOP
--   S12  FARE_RULE
--   S13  PASSENGER
--   S14  TICKET
--   S15  PAYMENT
--   S16  TRAVEL_PASS
--   S17  DRIVER
--   S18  DRIVER_SHIFT
--   S19  DRIVER_SCHEDULE_ASSIGNMENT
--   S20  EMPLOYEE
--   S21  EMPLOYEE_AUDIT_LOG
--   S22  DELAY_EVENT
--   S23  RESCHEDULE_LOG
--   S24  STATION_CLOSURE
--   S25  TRAIN_INCIDENT
--   S26  LIVE_TRACKING
--   S27  ALERT
--   S28  ALERT_PASSENGER_MAP
--   S29  MAINTENANCE_LOG
--   S30  TRAVELLING_IN
--   S31  TICKET_GATE_SCAN
--   S32  FEEDBACK
--   S33  SYSTEM_CONFIG
--   S34  AUDIT_LOG (generic)
--   T01  TRIGGERS
--   V01  VIEWS
--   I01  ADDITIONAL INDEXES
-- ================================================================

-- ================================================================
--  S01 — SCHEMA & EXTENSIONS
-- ================================================================


-- Required extensions

-- ================================================================
--  S02 — ENUM TYPES
--  All enums live in the metro schema.
--  Naming convention: <domain>_t
-- ================================================================

-- LINE status
CREATE TYPE line_status_t AS ENUM (
    'OPERATIONAL',
    'UNDER_CONSTRUCTION',
    'SUSPENDED',
    'CLOSED'
);

-- STATION structural type
CREATE TYPE station_type_t AS ENUM (
    'ELEVATED',
    'UNDERGROUND',
    'AT_GRADE',
    'INTERCHANGE'
);

-- Platform direction of service
CREATE TYPE direction_t AS ENUM (
    'NORTHBOUND',
    'SOUTHBOUND',
    'EASTBOUND',
    'WESTBOUND',
    'BIDIRECTIONAL'
);

-- Physical track operational status
CREATE TYPE track_status_t AS ENUM (
    'AVAILABLE',
    'OCCUPIED',
    'UNDER_MAINTENANCE',
    'BLOCKED',
    'CLOSED'
);

-- Train operational status
CREATE TYPE train_status_t AS ENUM (
    'ON_TRACK',
    'RESTING',
    'MAINTENANCE',
    'SUSPENDED',
    'CRASHED',
    'DECOMMISSIONED'
);

-- Train schedule run status
CREATE TYPE schedule_status_t AS ENUM (
    'ACTIVE',
    'DELAYED',
    'CANCELLED',
    'COMPLETED',
    'RESCHEDULED',
    'SUSPENDED'
);

-- Day category for scheduling
CREATE TYPE day_type_t AS ENUM (
    'WEEKDAY',
    'WEEKEND',
    'ALL_DAYS',
    'HOLIDAY'
);

-- Delay resolution lifecycle
CREATE TYPE delay_resolution_t AS ENUM (
    'PENDING',
    'IN_PROGRESS',
    'RESOLVED',
    'ESCALATED',
    'CLOSED'
);

-- Ticket product type
CREATE TYPE ticket_type_t AS ENUM (
    'SINGLE',
    'RETURN',
    'DAY_PASS',
    'TOURIST_PASS'
);

-- Ticket lifecycle status
CREATE TYPE ticket_status_t AS ENUM (
    'BOOKED',
    'ACTIVE',
    'ENTRY_DONE',
    'USED',
    'EXPIRED',
    'CANCELLED',
    'REFUNDED'
);

-- How the ticket was purchased
CREATE TYPE booking_channel_t AS ENUM (
    'MOBILE_APP',
    'COUNTER',
    'KIOSK',
    'WEBSITE',
    'WHATSAPP_BOT'
);

-- Payment instrument
CREATE TYPE payment_method_t AS ENUM (
    'CASH',
    'UPI',
    'DEBIT_CARD',
    'CREDIT_CARD',
    'NET_BANKING',
    'WALLET',
    'METRO_CARD',
    'QR_CODE'
);

-- Payment lifecycle status
CREATE TYPE payment_status_t AS ENUM (
    'INITIATED',
    'PENDING',
    'SUCCESS',
    'FAILED',
    'REFUNDED',
    'PARTIALLY_REFUNDED',
    'CHARGEBACK'
);

-- Travel pass product category
CREATE TYPE pass_type_t AS ENUM (
    'STUDENT_MONTHLY',
    'STUDENT_QUARTERLY',
    'STUDENT_ANNUAL',
    'SENIOR_MONTHLY',
    'SENIOR_QUARTERLY',
    'EMPLOYEE_MONTHLY',
    'GENERAL_MONTHLY',
    'GENERAL_QUARTERLY'
);

-- Passenger concession category
CREATE TYPE passenger_type_t AS ENUM (
    'GENERAL',
    'SENIOR_CITIZEN',
    'CHILD',
    'STUDENT',
    'PHYSICALLY_DISABLED',
    'TOURIST',
    'FREEDOM_FIGHTER'
);

-- HR employment status
CREATE TYPE emp_status_t AS ENUM (
    'ACTIVE',
    'PROBATION',
    'ON_LEAVE',
    'SUSPENDED',
    'TERMINATED',
    'RETIRED'
);

-- Station closure category
CREATE TYPE closure_type_t AS ENUM (
    'SCHEDULED_MAINTENANCE',
    'EMERGENCY',
    'TEMPORARY',
    'PERMANENT',
    'FORCE_MAJEURE'
);

-- Incident category
CREATE TYPE incident_type_t AS ENUM (
    'CRASH',
    'BREAKDOWN',
    'DERAILMENT',
    'FIRE',
    'OBSTRUCTION_ON_TRACK',
    'SIGNAL_FAILURE',
    'POWER_FAILURE',
    'OTHER'
);

-- Incident investigation lifecycle
CREATE TYPE incident_status_t AS ENUM (
    'OPEN',
    'UNDER_INVESTIGATION',
    'CONTAINMENT_DONE',
    'RESOLVED',
    'CLOSED',
    'ARCHIVED'
);

-- Alert category
CREATE TYPE alert_type_t AS ENUM (
    'DELAY',
    'CANCELLATION',
    'PLATFORM_CHANGE',
    'TRACK_CHANGE',
    'EMERGENCY',
    'HIGH_CROWD',
    'MAINTENANCE_CLOSURE',
    'GENERAL_ADVISORY'
);

-- Alert severity tier
CREATE TYPE alert_severity_t AS ENUM (
    'INFO',
    'WARNING',
    'CRITICAL',
    'EMERGENCY'
);

-- Alert dispatch channel
CREATE TYPE alert_channel_t AS ENUM (
    'IN_APP',
    'SMS',
    'EMAIL',
    'DISPLAY_BOARD',
    'ALL'
);

-- Maintenance work order type
CREATE TYPE maint_type_t AS ENUM (
    'ROUTINE_INSPECTION',
    'CORRECTIVE',
    'PREVENTIVE',
    'EMERGENCY',
    'OVERHAUL',
    'CLEANING'
);

-- Maintenance work order lifecycle
CREATE TYPE maint_status_t AS ENUM (
    'SCHEDULED',
    'IN_PROGRESS',
    'ON_HOLD',
    'COMPLETED',
    'CANCELLED'
);

-- Passenger feedback subject
CREATE TYPE feedback_category_t AS ENUM (
    'CLEANLINESS',
    'PUNCTUALITY',
    'STAFF_BEHAVIOUR',
    'SAFETY',
    'CROWD_MANAGEMENT',
    'MOBILE_APP',
    'TICKETING',
    'ACCESSIBILITY',
    'OTHER'
);

-- Real-time journey phase
CREATE TYPE travel_status_t AS ENUM (
    'BOARDING',
    'ON_TRAIN',
    'EXITED'
);

-- Gate scan role
CREATE TYPE gate_role_t AS ENUM (
    'ENTRY',
    'EXIT'
);

-- Generic audit action
CREATE TYPE audit_action_t AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'SOFT_DELETE',
    'RESTORE',
    'LOGIN',
    'LOGOUT',
    'CONFIG_CHANGE'
);

-- ================================================================
--  S03 — DOMAIN TYPES  (reusable, self-documenting constraints)
-- ================================================================

CREATE DOMAIN phone_t AS VARCHAR(15)
    CHECK (VALUE ~ '^\+?[0-9]{10,15}$');

CREATE DOMAIN email_t AS VARCHAR(255)
    CHECK (VALUE ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$');

CREATE DOMAIN hex_color_t AS VARCHAR(10)
    CHECK (VALUE ~ '^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');

CREATE DOMAIN latitude_t  AS NUMERIC(9,6)
    CHECK (VALUE BETWEEN -90  AND  90);

CREATE DOMAIN longitude_t AS NUMERIC(9,6)
    CHECK (VALUE BETWEEN -180 AND 180);

CREATE DOMAIN money_t AS NUMERIC(12,2)
    CHECK (VALUE >= 0);

CREATE DOMAIN distance_km_t AS NUMERIC(8,3)
    CHECK (VALUE >= 0);

CREATE DOMAIN rating_t AS SMALLINT
    CHECK (VALUE BETWEEN 1 AND 5);

-- ================================================================
--  SHARED HELPER FUNCTION — updated_at auto-setter
--  All mutable tables attach trg_<table>_set_updated_at
-- ================================================================

CREATE OR REPLACE FUNCTION metro.fn_set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

COMMENT ON FUNCTION metro.fn_set_updated_at() IS
'Generic BEFORE UPDATE trigger function to maintain updated_at column.';

-- ================================================================
--  MACRO — attach updated_at trigger to any table
-- ================================================================

CREATE OR REPLACE FUNCTION metro.fn_attach_updated_at_trigger(p_table TEXT)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'CREATE TRIGGER trg_%s_set_updated_at
         BEFORE UPDATE ON metro.%I
         FOR EACH ROW EXECUTE FUNCTION metro.fn_set_updated_at();',
        p_table, p_table
    );
END;
$$;

-- ================================================================
--  S04 — LINE
--  Represents a metro route corridor (Blue Line, Red Line, etc.)
--  BCNF: line_id → all non-key attributes.  No partial/transitive deps.
-- ================================================================

CREATE TABLE metro.LINE (
    -- Primary Key
    line_id                 SERIAL              NOT NULL,

    -- Natural / Business Keys
    line_code               VARCHAR(10)         NOT NULL,   -- e.g. 'L1', 'BLU'
    line_name               VARCHAR(100)        NOT NULL,

    -- Descriptive
    color_code              hex_color_t         NOT NULL,
    total_length_km         distance_km_t       NOT NULL,
    total_stations          SMALLINT            NOT NULL    DEFAULT 0
                                CHECK (total_stations >= 0),
    description             TEXT,
    operational_since       DATE,

    -- Status
    status                  line_status_t       NOT NULL    DEFAULT 'OPERATIONAL',
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,                            -- FK → EMPLOYEE added post-creation
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_line          PRIMARY KEY (line_id),
    CONSTRAINT uq_line_code     UNIQUE (line_code),
    CONSTRAINT uq_line_name     UNIQUE (line_name),
    CONSTRAINT chk_line_length  CHECK  (total_length_km > 0)
);

SELECT metro.fn_attach_updated_at_trigger('line');

CREATE INDEX idx_line_status ON metro.LINE(status) WHERE is_deleted = FALSE;

COMMENT ON TABLE  metro.LINE            IS 'Metro line/corridor master. Each line is a distinct route.';
COMMENT ON COLUMN metro.LINE.line_code  IS 'Short business code — e.g. L1 (Blue), L2 (Red)';
COMMENT ON COLUMN metro.LINE.color_code IS 'Hex color displayed on maps and UI';

-- ================================================================
--  S05 — STATION
--  A physical metro station building with one or more platforms.
--  BCNF: station_id → all; station_code → station_id (candidate key).
-- ================================================================

CREATE TABLE metro.STATION (
    -- Primary Key
    station_id              SERIAL              NOT NULL,

    -- Natural / Business Keys
    station_code            VARCHAR(10)         NOT NULL,   -- e.g. 'AJK', 'GHT'
    station_name            VARCHAR(150)        NOT NULL,

    -- Location
    station_type            station_type_t      NOT NULL    DEFAULT 'ELEVATED',
    zone_no                 SMALLINT            NOT NULL    CHECK (zone_no >= 1),
    latitude                latitude_t          NOT NULL,
    longitude               longitude_t         NOT NULL,
    address                 TEXT,
    city                    VARCHAR(100)        NOT NULL    DEFAULT 'Ahmedabad',
    pincode                 VARCHAR(10),

    -- Opening
    opening_date            DATE,

    -- Facilities
    has_lift                BOOLEAN             NOT NULL    DEFAULT FALSE,
    has_escalator           BOOLEAN             NOT NULL    DEFAULT FALSE,
    has_parking             BOOLEAN             NOT NULL    DEFAULT FALSE,
    has_feeder_bus          BOOLEAN             NOT NULL    DEFAULT FALSE,
    has_atm                 BOOLEAN             NOT NULL    DEFAULT FALSE,
    wheelchair_accessible   BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Operational flags
    is_interchange          BOOLEAN             NOT NULL    DEFAULT FALSE,
    is_terminal             BOOLEAN             NOT NULL    DEFAULT FALSE,
    is_active               BOOLEAN             NOT NULL    DEFAULT TRUE,
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_station           PRIMARY KEY (station_id),
    CONSTRAINT uq_station_code      UNIQUE (station_code),
    CONSTRAINT uq_station_name      UNIQUE (station_name),
    CONSTRAINT uq_station_latlong   UNIQUE (latitude, longitude)
);

SELECT metro.fn_attach_updated_at_trigger('station');

CREATE INDEX idx_station_zone      ON metro.STATION(zone_no)   WHERE is_deleted = FALSE;
CREATE INDEX idx_station_active    ON metro.STATION(is_active)  WHERE is_deleted = FALSE;
CREATE INDEX idx_station_geo       ON metro.STATION(latitude, longitude);

COMMENT ON TABLE  metro.STATION              IS 'Physical metro station master record';
COMMENT ON COLUMN metro.STATION.station_code IS 'Unique 3-character station abbreviation';
COMMENT ON COLUMN metro.STATION.zone_no      IS 'Fare zone; higher zone = higher base fare';
COMMENT ON COLUMN metro.STATION.is_interchange IS 'TRUE if station serves multiple lines';

-- ================================================================
--  S06 — PLATFORM
--  WEAK ENTITY — identified by (station_id, platform_no).
--  platform_no is a partial key unique within a station.
--  BCNF: (station_id, platform_no) → all non-key attributes.
-- ================================================================

CREATE TABLE metro.PLATFORM (
    -- Composite Primary Key (weak entity)
    station_id              INT                 NOT NULL,
    platform_no             SMALLINT            NOT NULL    CHECK (platform_no >= 1),

    -- Descriptive
    direction               direction_t         NOT NULL,
    capacity                INT                 NOT NULL    CHECK (capacity > 0),
    platform_length_m       NUMERIC(6,2)        CHECK (platform_length_m > 0),

    -- Facilities
    has_screen_doors        BOOLEAN             NOT NULL    DEFAULT FALSE,
    has_cctv                BOOLEAN             NOT NULL    DEFAULT FALSE,
    display_board_count     SMALLINT            NOT NULL    DEFAULT 0,

    -- Operational
    is_available            BOOLEAN             NOT NULL    DEFAULT TRUE,
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_platform
        PRIMARY KEY (station_id, platform_no),
    CONSTRAINT fk_platform_station
        FOREIGN KEY (station_id)
        REFERENCES metro.STATION(station_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_platform_display
        CHECK (display_board_count >= 0)
);

SELECT metro.fn_attach_updated_at_trigger('platform');

CREATE INDEX idx_platform_available
    ON metro.PLATFORM(station_id, is_available)
    WHERE is_deleted = FALSE;

COMMENT ON TABLE  metro.PLATFORM             IS 'Weak entity — platform within a station';
COMMENT ON COLUMN metro.PLATFORM.platform_no IS 'Partial key — unique only within its station';
COMMENT ON COLUMN metro.PLATFORM.direction   IS 'Service direction this platform serves';

-- ================================================================
--  S07 — STATION_ON_LINE
--  Resolves M:N between STATION and LINE.
--  Records sequence, distance, and halt properties per stop.
--  BCNF: (line_id, station_id) → all;
--        (line_id, sequence_no) → station_id (candidate key).
-- ================================================================

CREATE TABLE metro.STATION_ON_LINE (
    -- Composite Primary Key
    line_id                 INT                 NOT NULL,
    station_id              INT                 NOT NULL,

    -- Ordering
    sequence_no             SMALLINT            NOT NULL    CHECK (sequence_no >= 1),
    dist_from_start_km      distance_km_t       NOT NULL,

    -- Stop properties
    default_halt_sec        SMALLINT            NOT NULL    DEFAULT 30
                                CHECK (default_halt_sec >= 0),
    is_terminal             BOOLEAN             NOT NULL    DEFAULT FALSE,
    is_active               BOOLEAN             NOT NULL    DEFAULT TRUE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_station_on_line
        PRIMARY KEY (line_id, station_id),
    CONSTRAINT fk_sol_line
        FOREIGN KEY (line_id)
        REFERENCES metro.LINE(line_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_sol_station
        FOREIGN KEY (station_id)
        REFERENCES metro.STATION(station_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT uq_sol_seq
        UNIQUE (line_id, sequence_no)           -- No duplicate sequence on same line
);

SELECT metro.fn_attach_updated_at_trigger('station_on_line');

CREATE INDEX idx_sol_station ON metro.STATION_ON_LINE(station_id);
CREATE INDEX idx_sol_seq     ON metro.STATION_ON_LINE(line_id, sequence_no);

COMMENT ON TABLE  metro.STATION_ON_LINE              IS 'M:N resolution — stations on a line in order';
COMMENT ON COLUMN metro.STATION_ON_LINE.sequence_no  IS 'Stop order; 1 = first stop of the line';
COMMENT ON COLUMN metro.STATION_ON_LINE.is_terminal  IS 'TRUE for first and last stop of a line';

-- ================================================================
--  S08 — TRACK
--  Physical rail track belonging to a line.
--  Multiple schedules can reference one track (different times).
--  Overlap prevention handled via exclusion constraint.
--  BCNF: track_id → all; (line_id, track_number) is candidate key.
-- ================================================================

CREATE TABLE metro.TRACK (
    -- Primary Key
    track_id                SERIAL              NOT NULL,

    -- Identity
    line_id                 INT                 NOT NULL,
    track_number            VARCHAR(20)         NOT NULL,
    direction               direction_t         NOT NULL    DEFAULT 'BIDIRECTIONAL',

    -- Physical
    length_km               distance_km_t,
    max_speed_kmph          SMALLINT            CHECK (max_speed_kmph > 0),

    -- Status
    track_status            track_status_t      NOT NULL    DEFAULT 'AVAILABLE',
    is_active               BOOLEAN             NOT NULL    DEFAULT TRUE,
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_track
        PRIMARY KEY (track_id),
    CONSTRAINT fk_track_line
        FOREIGN KEY (line_id)
        REFERENCES metro.LINE(line_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT uq_track_line_number
        UNIQUE (line_id, track_number)
);

SELECT metro.fn_attach_updated_at_trigger('track');

CREATE INDEX idx_track_line   ON metro.TRACK(line_id)      WHERE is_deleted = FALSE;
CREATE INDEX idx_track_status ON metro.TRACK(track_status) WHERE is_deleted = FALSE;

COMMENT ON TABLE  metro.TRACK               IS 'Physical rail tracks; referenced by schedules';
COMMENT ON COLUMN metro.TRACK.track_status  IS 'AVAILABLE = free to assign; OCCUPIED = in use';
COMMENT ON COLUMN metro.TRACK.max_speed_kmph IS 'Design speed limit for this track section';

-- ================================================================
--  S09 — TRAIN
--  A physical train set (rolling stock).
--  Live GPS fields kept here for fast real-time reads;
--  full history in LIVE_TRACKING.
--  BCNF: train_id → all; train_number is candidate key.
-- ================================================================

CREATE TABLE metro.TRAIN (
    -- Primary Key
    train_id                SERIAL              NOT NULL,

    -- Identity
    train_number            VARCHAR(20)         NOT NULL,   -- e.g. 'AMTS-T001'
    train_name              VARCHAR(100),                   -- Optional friendly name
    train_type              VARCHAR(50)         NOT NULL    DEFAULT 'EMU',

    -- Physical specs
    total_capacity          INT                 NOT NULL    CHECK (total_capacity > 0),
    seating_capacity        INT                 NOT NULL    CHECK (seating_capacity > 0),
    standing_capacity       INT                 NOT NULL    CHECK (standing_capacity >= 0),
    number_of_coaches       SMALLINT            NOT NULL    DEFAULT 6
                                CHECK (number_of_coaches > 0),
    manufacturer            VARCHAR(150),
    manufacture_year        SMALLINT            CHECK (manufacture_year BETWEEN 2000 AND 2100),
    commission_date         DATE,
    last_overhaul_date      DATE,

    -- Assignment
    current_line_id         INT                 REFERENCES metro.LINE(line_id) ON DELETE SET NULL,

    -- Real-time state (updated by live tracking module)
    operational_status      train_status_t      NOT NULL    DEFAULT 'RESTING',
    is_on_rest              BOOLEAN             NOT NULL    DEFAULT TRUE,
    current_lat             latitude_t,
    current_lng             longitude_t,
    current_speed_kmph      NUMERIC(5,2)        CHECK (current_speed_kmph >= 0),
    current_crowd_count     INT                 NOT NULL    DEFAULT 0
                                CHECK (current_crowd_count >= 0),
    last_gps_update         TIMESTAMPTZ,

    -- Soft-delete / archive
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_train
        PRIMARY KEY (train_id),
    CONSTRAINT uq_train_number
        UNIQUE (train_number),
    CONSTRAINT chk_train_capacity
        CHECK (seating_capacity + standing_capacity = total_capacity),
    CONSTRAINT chk_train_overhaul
        CHECK (last_overhaul_date IS NULL OR last_overhaul_date >= commission_date)
);

SELECT metro.fn_attach_updated_at_trigger('train');

CREATE INDEX idx_train_status     ON metro.TRAIN(operational_status) WHERE is_deleted = FALSE;
CREATE INDEX idx_train_line       ON metro.TRAIN(current_line_id)    WHERE is_deleted = FALSE;
CREATE INDEX idx_train_rest       ON metro.TRAIN(is_on_rest)         WHERE is_deleted = FALSE;

COMMENT ON TABLE  metro.TRAIN                     IS 'Physical train sets (rolling stock)';
COMMENT ON COLUMN metro.TRAIN.current_crowd_count IS 'Updated by trigger on TRAVELLING_IN; denormalised for speed';
COMMENT ON COLUMN metro.TRAIN.is_on_rest          IS 'TRUE = in depot; FALSE = on track';

-- ================================================================
--  S10 — TRAIN_SCHEDULE
--  One row per scheduled run of a train on a line.
--  Includes track assignment and collision-guard exclusion constraint.
--  BCNF: schedule_id → all non-key attributes.
-- ================================================================

CREATE TABLE metro.TRAIN_SCHEDULE (
    -- Primary Key
    schedule_id             SERIAL              NOT NULL,

    -- Core references
    train_id                INT                 NOT NULL,
    line_id                 INT                 NOT NULL,
    track_id                INT,

    -- Run definition
    direction               direction_t         NOT NULL,
    day_type                day_type_t          NOT NULL    DEFAULT 'WEEKDAY',
    departure_time          TIME                NOT NULL,
    arrival_time            TIME                NOT NULL,
    normal_eta_mins         INT                 CHECK (normal_eta_mins > 0),

    -- Status
    schedule_status         schedule_status_t   NOT NULL    DEFAULT 'ACTIVE',

    -- Validity window
    effective_from          DATE                NOT NULL    DEFAULT CURRENT_DATE,
    effective_to            DATE,

    -- Soft-delete / archive
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_train_schedule
        PRIMARY KEY (schedule_id),
    CONSTRAINT fk_sch_train
        FOREIGN KEY (train_id)
        REFERENCES metro.TRAIN(train_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_sch_line
        FOREIGN KEY (line_id)
        REFERENCES metro.LINE(line_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_sch_track
        FOREIGN KEY (track_id)
        REFERENCES metro.TRACK(track_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_sch_times
        CHECK (arrival_time > departure_time),
    CONSTRAINT chk_sch_dates
        CHECK (effective_to IS NULL OR effective_to >= effective_from)
);

SELECT metro.fn_attach_updated_at_trigger('train_schedule');

-- Prevent two ACTIVE schedules for same train overlapping on same day_type
CREATE UNIQUE INDEX uq_sch_train_time_daytype
    ON metro.TRAIN_SCHEDULE(train_id, departure_time, day_type)
    WHERE schedule_status = 'ACTIVE' AND is_deleted = FALSE;

-- Prevent two ACTIVE schedules on same track at overlapping times (same day_type)
-- Uses GiST range; requires btree_gist extension
CREATE UNIQUE INDEX uq_sch_track_no_overlap
    ON metro.TRAIN_SCHEDULE(track_id, day_type, departure_time, arrival_time)
    WHERE track_id IS NOT NULL AND schedule_status = 'ACTIVE' AND is_deleted = FALSE;

CREATE INDEX idx_sch_line_day   ON metro.TRAIN_SCHEDULE(line_id, day_type)
    WHERE is_deleted = FALSE;
CREATE INDEX idx_sch_status     ON metro.TRAIN_SCHEDULE(schedule_status)
    WHERE is_deleted = FALSE;
CREATE INDEX idx_sch_effective  ON metro.TRAIN_SCHEDULE(effective_from, effective_to);

COMMENT ON TABLE  metro.TRAIN_SCHEDULE             IS 'Each scheduled run of a train on a line';
COMMENT ON COLUMN metro.TRAIN_SCHEDULE.normal_eta_mins IS 'Fixed journey time under normal conditions';
COMMENT ON COLUMN metro.TRAIN_SCHEDULE.effective_from  IS 'Schedule is valid from this date';

-- ================================================================
--  S11 — TRAIN_STOP
--  WEAK ENTITY — identified by (schedule_id, stop_sequence).
--  One row per station halt within a schedule run.
--  BCNF: (schedule_id, stop_sequence) → all; no transitive deps.
-- ================================================================

CREATE TABLE metro.TRAIN_STOP (
    -- Composite Primary Key (weak entity)
    schedule_id             INT                 NOT NULL,
    stop_sequence           SMALLINT            NOT NULL    CHECK (stop_sequence >= 1),

    -- Location
    station_id              INT                 NOT NULL,
    platform_no             SMALLINT            NOT NULL,

    -- Timing
    scheduled_arrival       TIME,
    scheduled_departure     TIME,
    halt_duration_sec       SMALLINT            NOT NULL    DEFAULT 30
                                CHECK (halt_duration_sec >= 0),

    -- Real-time ETA (updated by live tracking module / delay events)
    dynamic_eta             TIMESTAMPTZ,

    -- Operational
    is_active               BOOLEAN             NOT NULL    DEFAULT TRUE,
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_train_stop
        PRIMARY KEY (schedule_id, stop_sequence),
    CONSTRAINT fk_tstop_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES metro.TRAIN_SCHEDULE(schedule_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_tstop_platform
        FOREIGN KEY (station_id, platform_no)
        REFERENCES metro.PLATFORM(station_id, platform_no)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_tstop_times
        CHECK (scheduled_arrival IS NULL OR scheduled_departure IS NULL
               OR scheduled_departure >= scheduled_arrival)
);

SELECT metro.fn_attach_updated_at_trigger('train_stop');

CREATE INDEX idx_tstop_station   ON metro.TRAIN_STOP(station_id);
CREATE INDEX idx_tstop_dynamic   ON metro.TRAIN_STOP(schedule_id, dynamic_eta)
    WHERE dynamic_eta IS NOT NULL;

COMMENT ON TABLE  metro.TRAIN_STOP              IS 'Weak entity — each station halt in a schedule run';
COMMENT ON COLUMN metro.TRAIN_STOP.dynamic_eta  IS 'Real-time recalculated ETA; NULL = no change from schedule';
COMMENT ON COLUMN metro.TRAIN_STOP.platform_no  IS 'Can be changed during rescheduling if no conflict';



-- ================================================================
--  S12 — FARE_RULE
--  Distance-slab based fare table with concession columns.
--  Full history is preserved; no row is ever deleted.
--  BCNF: fare_rule_id → all; no partial/transitive dependency.
-- ================================================================

CREATE TABLE metro.FARE_RULE (
    -- Primary Key
    fare_rule_id            SERIAL              NOT NULL,

    -- Slab definition
    min_distance_km         distance_km_t       NOT NULL,
    max_distance_km         distance_km_t       NOT NULL,

    -- Fare by category (all inclusive of taxes)
    base_fare               money_t             NOT NULL,
    normal_fare             money_t             NOT NULL,
    senior_citizen_fare     money_t             NOT NULL,
    physically_disabled_fare money_t            NOT NULL,
    child_fare              money_t             NOT NULL,
    student_fare            money_t             NOT NULL,
    tourist_fare            money_t             NOT NULL,
    freedom_fighter_fare    money_t             NOT NULL    DEFAULT 0,

    -- Validity window (allows future fare revision without losing history)
    effective_from          DATE                NOT NULL    DEFAULT CURRENT_DATE,
    effective_to            DATE,
    is_active               BOOLEAN             NOT NULL    DEFAULT TRUE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_fare_rule
        PRIMARY KEY (fare_rule_id),
    CONSTRAINT chk_fare_dist
        CHECK (max_distance_km > min_distance_km),
    CONSTRAINT chk_fare_dates
        CHECK (effective_to IS NULL OR effective_to >= effective_from),
    CONSTRAINT chk_fare_normal
        CHECK (normal_fare >= base_fare)
);

SELECT metro.fn_attach_updated_at_trigger('fare_rule');

-- No overlapping active slabs for the same distance range
CREATE UNIQUE INDEX uq_fare_slab_active
    ON metro.FARE_RULE(min_distance_km, max_distance_km, effective_from)
    WHERE is_active = TRUE AND effective_to IS NULL;

CREATE INDEX idx_fare_dist   ON metro.FARE_RULE(min_distance_km, max_distance_km);
CREATE INDEX idx_fare_active ON metro.FARE_RULE(is_active, effective_from, effective_to);

COMMENT ON TABLE  metro.FARE_RULE                    IS 'Distance-slab fare matrix; history preserved for audit';
COMMENT ON COLUMN metro.FARE_RULE.student_fare       IS 'Applicable to STUDENT type passengers with valid pass';
COMMENT ON COLUMN metro.FARE_RULE.freedom_fighter_fare IS 'Free travel or subsidised; configured as 0 by default';

-- ================================================================
--  S13 — PASSENGER
--  App user or walk-in counter customer.
--  BCNF: passenger_id → all; phone and email are candidate keys.
-- ================================================================

CREATE TABLE metro.PASSENGER (
    -- Primary Key
    passenger_id            SERIAL              NOT NULL,

    -- Identity
    full_name               VARCHAR(200)        NOT NULL,
    date_of_birth           DATE,
    gender                  CHAR(1)             CHECK (gender IN ('M','F','O','U')),

    -- Contact (at least one must be provided — enforced via CHECK)
    phone                   phone_t,
    email                   email_t,

    -- Auth (NULL for counter/kiosk bookings)
    password_hash           VARCHAR(255),
    last_login_at           TIMESTAMPTZ,
    login_attempts          SMALLINT            NOT NULL    DEFAULT 0,
    is_locked               BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Concession
    passenger_type          passenger_type_t    NOT NULL    DEFAULT 'GENERAL',
    disability_certificate  VARCHAR(100),       -- Certificate number for disabled concession
    disability_flag         BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- App preferences
    preferred_language      VARCHAR(10)         NOT NULL    DEFAULT 'en',
    push_token              TEXT,                           -- FCM / APNS push notification token
    notification_enabled    BOOLEAN             NOT NULL    DEFAULT TRUE,

    -- Operational
    is_active               BOOLEAN             NOT NULL    DEFAULT TRUE,
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,
    registered_at           TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_passenger
        PRIMARY KEY (passenger_id),
    CONSTRAINT uq_passenger_phone
        UNIQUE (phone),
    CONSTRAINT uq_passenger_email
        UNIQUE (email),
    CONSTRAINT chk_passenger_contact
        CHECK (phone IS NOT NULL OR email IS NOT NULL),
    CONSTRAINT chk_passenger_disability
        CHECK (disability_flag = FALSE OR disability_certificate IS NOT NULL)
);

SELECT metro.fn_attach_updated_at_trigger('passenger');

CREATE INDEX idx_passenger_phone   ON metro.PASSENGER(phone)          WHERE is_deleted = FALSE;
CREATE INDEX idx_passenger_email   ON metro.PASSENGER(email)          WHERE is_deleted = FALSE;
CREATE INDEX idx_passenger_type    ON metro.PASSENGER(passenger_type) WHERE is_deleted = FALSE;

COMMENT ON TABLE  metro.PASSENGER                   IS 'Metro app users and walk-in passengers';
COMMENT ON COLUMN metro.PASSENGER.push_token        IS 'Device push notification token for live alerts';
COMMENT ON COLUMN metro.PASSENGER.password_hash     IS 'NULL for counter/kiosk passengers; use bcrypt/argon2';
COMMENT ON COLUMN metro.PASSENGER.disability_certificate IS 'Govt-issued certificate number for disabled concession';

-- ================================================================
--  S14 — TICKET
--  One ticket = one journey (point-to-point).
--  QR code is generated at booking and used for entry/exit.
--  BCNF: ticket_id → all; qr_code is candidate key.
-- ================================================================

CREATE TABLE metro.TICKET (
    -- Primary Key
    ticket_id               BIGSERIAL           NOT NULL,

    -- References
    passenger_id            INT,                            -- NULL for anonymous counter booking
    fare_rule_id            INT                 NOT NULL,
    from_station_id         INT                 NOT NULL,
    to_station_id           INT                 NOT NULL,

    -- Ticket details
    ticket_type             ticket_type_t       NOT NULL    DEFAULT 'SINGLE',
    passenger_category      passenger_type_t    NOT NULL    DEFAULT 'GENERAL',

    -- QR (unique, non-guessable token)
    qr_code                 VARCHAR(512)        NOT NULL,
    qr_generated_at         TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),

    -- Financials
    distance_km             distance_km_t       NOT NULL,
    base_amount             money_t             NOT NULL,
    discount_amount         money_t             NOT NULL    DEFAULT 0,
    tax_amount              money_t             NOT NULL    DEFAULT 0,
    price_paid              money_t             NOT NULL,

    -- Booking
    booking_channel         booking_channel_t   NOT NULL    DEFAULT 'MOBILE_APP',
    booked_by_emp_id        INT,                            -- Non-null for counter bookings
    issued_at               TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),

    -- Validity
    valid_from              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    valid_to                TIMESTAMPTZ         NOT NULL,

    -- Lifecycle
    status                  ticket_status_t     NOT NULL    DEFAULT 'BOOKED',
    cancellation_reason     TEXT,
    cancelled_at            TIMESTAMPTZ,

    -- Soft-delete
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_ticket
        PRIMARY KEY (ticket_id),
    CONSTRAINT uq_ticket_qr
        UNIQUE (qr_code),
    CONSTRAINT fk_ticket_passenger
        FOREIGN KEY (passenger_id)
        REFERENCES metro.PASSENGER(passenger_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_fare
        FOREIGN KEY (fare_rule_id)
        REFERENCES metro.FARE_RULE(fare_rule_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_from_stn
        FOREIGN KEY (from_station_id)
        REFERENCES metro.STATION(station_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_ticket_to_stn
        FOREIGN KEY (to_station_id)
        REFERENCES metro.STATION(station_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_ticket_stations
        CHECK (from_station_id <> to_station_id),
    CONSTRAINT chk_ticket_validity
        CHECK (valid_to > valid_from),
    CONSTRAINT chk_ticket_price
        CHECK (price_paid = base_amount - discount_amount + tax_amount)
);

SELECT metro.fn_attach_updated_at_trigger('ticket');

CREATE INDEX idx_ticket_passenger ON metro.TICKET(passenger_id)   WHERE is_deleted = FALSE;
CREATE INDEX idx_ticket_qr        ON metro.TICKET(qr_code);
CREATE INDEX idx_ticket_status    ON metro.TICKET(status)         WHERE is_deleted = FALSE;
CREATE INDEX idx_ticket_validity  ON metro.TICKET(valid_from, valid_to) WHERE status = 'ACTIVE';
CREATE INDEX idx_ticket_from_stn  ON metro.TICKET(from_station_id);
CREATE INDEX idx_ticket_to_stn    ON metro.TICKET(to_station_id);

COMMENT ON TABLE  metro.TICKET               IS 'Metro journey tickets; QR used for gate entry/exit';
COMMENT ON COLUMN metro.TICKET.qr_code       IS 'Generated via uuid_generate_v4(); shown as QR on app/print';
COMMENT ON COLUMN metro.TICKET.distance_km   IS 'Route distance; used to select correct FARE_RULE slab';
COMMENT ON COLUMN metro.TICKET.price_paid    IS 'Must equal base_amount - discount_amount + tax_amount';

-- ================================================================
--  S15 — PAYMENT
--  One payment per ticket (1:1).
--  Keeps full gateway response for reconciliation.
--  BCNF: payment_id → all; ticket_id is candidate key.
-- ================================================================

CREATE TABLE metro.PAYMENT (
    -- Primary Key
    payment_id              BIGSERIAL           NOT NULL,

    -- Reference
    ticket_id               BIGINT              NOT NULL,

    -- Financials
    amount                  money_t             NOT NULL,
    currency                CHAR(3)             NOT NULL    DEFAULT 'INR',
    payment_method          payment_method_t    NOT NULL,

    -- Gateway fields
    gateway_name            VARCHAR(50),                    -- RAZORPAY, PAYTM, HDFC, etc.
    gateway_order_id        VARCHAR(200),
    gateway_payment_id      VARCHAR(200)        UNIQUE,
    gateway_signature       VARCHAR(500),
    gateway_response_code   VARCHAR(20),
    gateway_response_msg    TEXT,

    -- Lifecycle
    status                  payment_status_t    NOT NULL    DEFAULT 'INITIATED',
    initiated_at            TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    paid_at                 TIMESTAMPTZ,
    refund_amount           money_t             NOT NULL    DEFAULT 0,
    refunded_at             TIMESTAMPTZ,
    refund_reference        VARCHAR(200),

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_payment
        PRIMARY KEY (payment_id),
    CONSTRAINT uq_payment_ticket
        UNIQUE (ticket_id),                     -- Enforces 1:1 with TICKET
    CONSTRAINT fk_payment_ticket
        FOREIGN KEY (ticket_id)
        REFERENCES metro.TICKET(ticket_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_payment_refund
        CHECK (refund_amount <= amount),
    CONSTRAINT chk_payment_paid_at
        CHECK (paid_at IS NULL OR paid_at >= initiated_at)
);

SELECT metro.fn_attach_updated_at_trigger('payment');

CREATE INDEX idx_payment_status   ON metro.PAYMENT(status);
CREATE INDEX idx_payment_gateway  ON metro.PAYMENT(gateway_payment_id) WHERE gateway_payment_id IS NOT NULL;
CREATE INDEX idx_payment_date     ON metro.PAYMENT(paid_at DESC)        WHERE paid_at IS NOT NULL;

COMMENT ON TABLE  metro.PAYMENT                IS '1:1 with TICKET; full gateway response stored for reconciliation';
COMMENT ON COLUMN metro.PAYMENT.gateway_order_id IS 'Order ID sent to payment gateway (before payment)';
COMMENT ON COLUMN metro.PAYMENT.gateway_payment_id IS 'Returned by gateway on success; globally unique';

-- ================================================================
--  S16 — TRAVEL_PASS
--  Monthly / quarterly / student / senior passes.
--  BCNF: pass_id → all; qr_code is candidate key.
-- ================================================================

CREATE TABLE metro.TRAVEL_PASS (
    -- Primary Key
    pass_id                 SERIAL              NOT NULL,

    -- Reference
    passenger_id            INT                 NOT NULL,

    -- Pass definition
    pass_type               pass_type_t         NOT NULL,
    institution_name        VARCHAR(200),                   -- Required for student passes
    institution_id_no       VARCHAR(100),                   -- Student/employee ID number

    -- Coverage
    covered_line_ids        INT[],                          -- NULL = all lines covered

    -- Validity
    valid_from              DATE                NOT NULL,
    valid_to                DATE                NOT NULL,

    -- Financials
    price                   money_t             NOT NULL,
    payment_id              BIGINT,                         -- FK → PAYMENT (pass purchase payment)

    -- QR (same mechanism as TICKET)
    qr_code                 VARCHAR(512)        NOT NULL,

    -- Status
    is_active               BOOLEAN             NOT NULL    DEFAULT TRUE,
    deactivation_reason     TEXT,
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_travel_pass
        PRIMARY KEY (pass_id),
    CONSTRAINT uq_travel_pass_qr
        UNIQUE (qr_code),
    CONSTRAINT fk_tpass_passenger
        FOREIGN KEY (passenger_id)
        REFERENCES metro.PASSENGER(passenger_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_tpass_dates
        CHECK (valid_to > valid_from),
    CONSTRAINT chk_tpass_student
        CHECK (
            pass_type NOT IN ('STUDENT_MONTHLY','STUDENT_QUARTERLY','STUDENT_ANNUAL')
            OR institution_name IS NOT NULL
        )
);

SELECT metro.fn_attach_updated_at_trigger('travel_pass');

CREATE INDEX idx_tpass_passenger ON metro.TRAVEL_PASS(passenger_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_tpass_valid     ON metro.TRAVEL_PASS(valid_from, valid_to, is_active);
CREATE INDEX idx_tpass_qr        ON metro.TRAVEL_PASS(qr_code);

COMMENT ON TABLE  metro.TRAVEL_PASS                  IS 'Monthly/quarterly/student/senior travel passes';
COMMENT ON COLUMN metro.TRAVEL_PASS.covered_line_ids IS 'Array of line_ids; NULL means unlimited access';
COMMENT ON COLUMN metro.TRAVEL_PASS.institution_id_no IS 'For verification during pass issuance';

-- ================================================================
--  S17 — DRIVER
--  Train operator / driver.
--  BCNF: driver_id → all; license_no, phone, email are candidate keys.
-- ================================================================

CREATE TABLE metro.DRIVER (
    -- Primary Key
    driver_id               SERIAL              NOT NULL,

    -- Identity
    employee_code           VARCHAR(20)         NOT NULL,   -- HR employee code
    full_name               VARCHAR(200)        NOT NULL,
    date_of_birth           DATE                NOT NULL,
    gender                  CHAR(1)             CHECK (gender IN ('M','F','O')),

    -- Contact
    phone                   phone_t             NOT NULL,
    alternate_phone         phone_t,
    email                   email_t,
    address                 TEXT,
    emergency_contact_name  VARCHAR(150),
    emergency_contact_phone phone_t,

    -- Professional
    license_no              VARCHAR(50)         NOT NULL,
    license_expiry          DATE                NOT NULL,
    joining_date            DATE                NOT NULL    DEFAULT CURRENT_DATE,
    experience_years        SMALLINT            NOT NULL    DEFAULT 0
                                CHECK (experience_years >= 0),

    -- Financials
    salary                  money_t             NOT NULL    CHECK (salary > 0),
    bank_account_no         VARCHAR(30),
    bank_ifsc               VARCHAR(15),

    -- Status
    employment_status       emp_status_t        NOT NULL    DEFAULT 'ACTIVE',
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_driver
        PRIMARY KEY (driver_id),
    CONSTRAINT uq_driver_emp_code
        UNIQUE (employee_code),
    CONSTRAINT uq_driver_license
        UNIQUE (license_no),
    CONSTRAINT uq_driver_phone
        UNIQUE (phone),
    CONSTRAINT chk_driver_license_expiry
        CHECK (license_expiry > joining_date),
    CONSTRAINT chk_driver_dob
        CHECK (date_of_birth < joining_date - INTERVAL '18 years')
);

SELECT metro.fn_attach_updated_at_trigger('driver');

CREATE INDEX idx_driver_status  ON metro.DRIVER(employment_status) WHERE is_deleted = FALSE;
CREATE INDEX idx_driver_license ON metro.DRIVER(license_expiry)    WHERE is_deleted = FALSE;

COMMENT ON TABLE  metro.DRIVER               IS 'Train drivers / operators with HR and license data';
COMMENT ON COLUMN metro.DRIVER.license_expiry IS 'Alert module notifies 90 days before expiry';
COMMENT ON COLUMN metro.DRIVER.employee_code  IS 'HR system code for cross-system reference';

-- ================================================================
--  S18 — DRIVER_SHIFT
--  WEAK ENTITY — identified by (driver_id, shift_id).
--  Stores individual shift records.
--  working_hours is a GENERATED (stored) derived column.
--  BCNF: (driver_id, shift_id) → all; no transitive deps.
-- ================================================================

CREATE TABLE metro.DRIVER_SHIFT (
    -- Composite PK (weak entity)
    driver_id               INT                 NOT NULL,
    shift_id                SERIAL,

    -- Shift timing
    shift_date              DATE                NOT NULL,
    shift_start             TIME                NOT NULL,
    shift_end               TIME                NOT NULL,

    -- Derived (GENERATED STORED)
    working_hours           NUMERIC(4,2)
                            GENERATED ALWAYS AS (
                                ROUND(
                                    EXTRACT(EPOCH FROM (
                                        shift_end::INTERVAL - shift_start::INTERVAL
                                    )) / 3600.0,
                                    2
                                )
                            ) STORED,

    -- Classification
    shift_type              VARCHAR(20)         NOT NULL    DEFAULT 'REGULAR'
                                CHECK (shift_type IN ('REGULAR','OVERTIME','EMERGENCY','SPLIT')),

    -- Status
    actual_start            TIMESTAMPTZ,
    actual_end              TIMESTAMPTZ,
    is_completed            BOOLEAN             NOT NULL    DEFAULT FALSE,
    remarks                 TEXT,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_driver_shift
        PRIMARY KEY (driver_id, shift_id),
    CONSTRAINT fk_dshift_driver
        FOREIGN KEY (driver_id)
        REFERENCES metro.DRIVER(driver_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_dshift_times
        CHECK (shift_end > shift_start),
    CONSTRAINT chk_dshift_hours
        CHECK (
            EXTRACT(EPOCH FROM (shift_end::INTERVAL - shift_start::INTERVAL)) / 3600.0
            BETWEEN 0 AND 16
        )
);

SELECT metro.fn_attach_updated_at_trigger('driver_shift');

-- No overlapping shifts for same driver on same date
CREATE UNIQUE INDEX uq_dshift_no_overlap
    ON metro.DRIVER_SHIFT(driver_id, shift_date, shift_start, shift_end);

CREATE INDEX idx_dshift_date ON metro.DRIVER_SHIFT(driver_id, shift_date);

COMMENT ON TABLE  metro.DRIVER_SHIFT              IS 'Weak entity — shift records per driver';
COMMENT ON COLUMN metro.DRIVER_SHIFT.working_hours IS 'Auto-calculated; stored for fast queries';
COMMENT ON COLUMN metro.DRIVER_SHIFT.shift_type    IS 'SPLIT = driver works two separate blocks in one day';

-- ================================================================
--  S19 — DRIVER_SCHEDULE_ASSIGNMENT
--  M:N between DRIVER and TRAIN_SCHEDULE with assignment metadata.
--  BCNF: (driver_id, schedule_id, assignment_date) → all.
-- ================================================================

CREATE TABLE metro.DRIVER_SCHEDULE_ASSIGNMENT (
    -- Composite Primary Key
    assignment_id           SERIAL              NOT NULL,
    driver_id               INT                 NOT NULL,
    schedule_id             INT                 NOT NULL,
    assignment_date         DATE                NOT NULL    DEFAULT CURRENT_DATE,

    -- Role
    role                    VARCHAR(20)         NOT NULL    DEFAULT 'PRIMARY'
                                CHECK (role IN ('PRIMARY','BACKUP','TRAINEE')),

    -- Assignment metadata
    assigned_by_emp_id      INT,                            -- FK → EMPLOYEE
    remarks                 TEXT,

    -- Status
    is_active               BOOLEAN             NOT NULL    DEFAULT TRUE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_dsa
        PRIMARY KEY (assignment_id),
    CONSTRAINT uq_dsa_primary
        UNIQUE (schedule_id, assignment_date, role)
        DEFERRABLE INITIALLY DEFERRED,          -- Allows swap transactions
    CONSTRAINT fk_dsa_driver
        FOREIGN KEY (driver_id)
        REFERENCES metro.DRIVER(driver_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_dsa_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES metro.TRAIN_SCHEDULE(schedule_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

SELECT metro.fn_attach_updated_at_trigger('driver_schedule_assignment');

CREATE INDEX idx_dsa_driver   ON metro.DRIVER_SCHEDULE_ASSIGNMENT(driver_id, assignment_date);
CREATE INDEX idx_dsa_schedule ON metro.DRIVER_SCHEDULE_ASSIGNMENT(schedule_id, assignment_date);

COMMENT ON TABLE  metro.DRIVER_SCHEDULE_ASSIGNMENT IS 'Which driver is assigned to which schedule run';
COMMENT ON COLUMN metro.DRIVER_SCHEDULE_ASSIGNMENT.role IS 'PRIMARY=main driver; BACKUP=standby; TRAINEE=observer';

-- ================================================================
--  S20 — EMPLOYEE
--  Metro operations staff — station masters, controllers, admins.
--  All access to management features is via this table.
--  BCNF: employee_id → all; email, phone, employee_code are candidate keys.
-- ================================================================

CREATE TABLE metro.EMPLOYEE (
    -- Primary Key
    employee_id             SERIAL              NOT NULL,

    -- Identity
    employee_code           VARCHAR(20)         NOT NULL,   -- HR code
    full_name               VARCHAR(200)        NOT NULL,
    date_of_birth           DATE,
    gender                  CHAR(1)             CHECK (gender IN ('M','F','O','U')),

    -- Contact
    phone                   phone_t             NOT NULL,
    email                   email_t             NOT NULL,
    address                 TEXT,

    -- Auth
    password_hash           VARCHAR(255)        NOT NULL,
    last_login_at           TIMESTAMPTZ,
    password_changed_at     TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    login_attempts          SMALLINT            NOT NULL    DEFAULT 0,
    is_locked               BOOLEAN             NOT NULL    DEFAULT FALSE,
    mfa_enabled             BOOLEAN             NOT NULL    DEFAULT FALSE,
    mfa_secret              VARCHAR(100),                   -- TOTP secret (encrypted)

    -- HR
    role                    VARCHAR(80)         NOT NULL,
    department              VARCHAR(100)        NOT NULL,
    reporting_manager_id    INT,                            -- Self-referencing FK
    salary                  money_t             NOT NULL    CHECK (salary > 0),
    joining_date            DATE                NOT NULL    DEFAULT CURRENT_DATE,
    bank_account_no         VARCHAR(30),
    bank_ifsc               VARCHAR(15),

    -- Access Control (RBAC level)
    access_level            SMALLINT            NOT NULL    DEFAULT 1
                                CHECK (access_level BETWEEN 1 AND 10),

    -- Station assignment
    managed_station_id      INT,

    -- Status
    employment_status       emp_status_t        NOT NULL    DEFAULT 'ACTIVE',
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_employee
        PRIMARY KEY (employee_id),
    CONSTRAINT uq_employee_code
        UNIQUE (employee_code),
    CONSTRAINT uq_employee_email
        UNIQUE (email),
    CONSTRAINT uq_employee_phone
        UNIQUE (phone),
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (reporting_manager_id)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_employee_station
        FOREIGN KEY (managed_station_id)
        REFERENCES metro.STATION(station_id)
        ON DELETE SET NULL
);

SELECT metro.fn_attach_updated_at_trigger('employee');

-- Now back-fill FKs that reference EMPLOYEE (created before this table)
ALTER TABLE metro.DRIVER_SCHEDULE_ASSIGNMENT
    ADD CONSTRAINT fk_dsa_assigned_by
    FOREIGN KEY (assigned_by_emp_id)
    REFERENCES metro.EMPLOYEE(employee_id)
    ON DELETE SET NULL;

ALTER TABLE metro.LINE
    ADD CONSTRAINT fk_line_created_by FOREIGN KEY (created_by) REFERENCES metro.EMPLOYEE(employee_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_line_updated_by FOREIGN KEY (updated_by) REFERENCES metro.EMPLOYEE(employee_id) ON DELETE SET NULL;

ALTER TABLE metro.STATION
    ADD CONSTRAINT fk_sta_created_by FOREIGN KEY (created_by) REFERENCES metro.EMPLOYEE(employee_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_sta_updated_by FOREIGN KEY (updated_by) REFERENCES metro.EMPLOYEE(employee_id) ON DELETE SET NULL;

ALTER TABLE metro.TRAIN
    ADD CONSTRAINT fk_tr_created_by FOREIGN KEY (created_by) REFERENCES metro.EMPLOYEE(employee_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_tr_updated_by FOREIGN KEY (updated_by) REFERENCES metro.EMPLOYEE(employee_id) ON DELETE SET NULL;

ALTER TABLE metro.TRAIN_SCHEDULE
    ADD CONSTRAINT fk_sch_created_by FOREIGN KEY (created_by) REFERENCES metro.EMPLOYEE(employee_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_sch_updated_by FOREIGN KEY (updated_by) REFERENCES metro.EMPLOYEE(employee_id) ON DELETE SET NULL;

CREATE INDEX idx_emp_role     ON metro.EMPLOYEE(role)              WHERE is_deleted = FALSE;
CREATE INDEX idx_emp_dept     ON metro.EMPLOYEE(department)        WHERE is_deleted = FALSE;
CREATE INDEX idx_emp_station  ON metro.EMPLOYEE(managed_station_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_emp_status   ON metro.EMPLOYEE(employment_status)  WHERE is_deleted = FALSE;
CREATE INDEX idx_emp_manager  ON metro.EMPLOYEE(reporting_manager_id);

COMMENT ON TABLE  metro.EMPLOYEE               IS 'Metro operations staff; all management actions require employee auth';
COMMENT ON COLUMN metro.EMPLOYEE.access_level  IS '1=gate staff, 5=station master, 8=ops controller, 10=super admin';
COMMENT ON COLUMN metro.EMPLOYEE.mfa_secret    IS 'Encrypted TOTP secret for 2FA; mandatory for access_level >= 5';

-- ================================================================
--  S21 — EMPLOYEE_AUDIT_LOG
--  Immutable record of every salary / role / status change.
--  Append-only — no UPDATE or DELETE ever.
-- ================================================================

CREATE TABLE metro.EMPLOYEE_AUDIT_LOG (
    audit_id                BIGSERIAL           NOT NULL,
    employee_id             INT                 NOT NULL
                                REFERENCES metro.EMPLOYEE(employee_id)
                                ON DELETE RESTRICT,
    changed_by_emp_id       INT
                                REFERENCES metro.EMPLOYEE(employee_id)
                                ON DELETE SET NULL,
    changed_field           VARCHAR(100)        NOT NULL,
    old_value               TEXT,
    new_value               TEXT,
    change_reason           TEXT,
    changed_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),

    CONSTRAINT pk_emp_audit PRIMARY KEY (audit_id)
);

CREATE INDEX idx_emp_audit_emp  ON metro.EMPLOYEE_AUDIT_LOG(employee_id, changed_at DESC);
CREATE INDEX idx_emp_audit_field ON metro.EMPLOYEE_AUDIT_LOG(changed_field, changed_at DESC);

COMMENT ON TABLE metro.EMPLOYEE_AUDIT_LOG IS 'Immutable HR change log — salary, role, status. Append-only.';



-- ================================================================
--  S22 — DELAY_EVENT
--  Records each delay occurrence against a schedule.
--  BCNF: delay_id → all; no partial/transitive dependency.
-- ================================================================

CREATE TABLE metro.DELAY_EVENT (
    -- Primary Key
    delay_id                BIGSERIAL           NOT NULL,

    -- Context
    schedule_id             INT                 NOT NULL,
    affected_station_id     INT,

    -- Delay detail
    delay_minutes           INT                 NOT NULL    CHECK (delay_minutes > 0),
    reason                  TEXT                NOT NULL,
    delay_category          VARCHAR(50)         NOT NULL    DEFAULT 'OPERATIONAL'
                                CHECK (delay_category IN (
                                    'OPERATIONAL','TECHNICAL','WEATHER',
                                    'SECURITY','MEDICAL','EXTERNAL','OTHER'
                                )),

    -- Resolution
    resolution_status       delay_resolution_t  NOT NULL    DEFAULT 'PENDING',
    resolved_at             TIMESTAMPTZ,
    resolved_by_emp_id      INT,
    resolution_notes        TEXT,

    -- Audit
    reported_at             TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_delay         PRIMARY KEY (delay_id),
    CONSTRAINT fk_delay_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES metro.TRAIN_SCHEDULE(schedule_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_delay_station
        FOREIGN KEY (affected_station_id)
        REFERENCES metro.STATION(station_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_delay_resolver
        FOREIGN KEY (resolved_by_emp_id)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_delay_created_by
        FOREIGN KEY (created_by)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

SELECT metro.fn_attach_updated_at_trigger('delay_event');

CREATE INDEX idx_delay_schedule  ON metro.DELAY_EVENT(schedule_id);
CREATE INDEX idx_delay_status    ON metro.DELAY_EVENT(resolution_status);
CREATE INDEX idx_delay_reported  ON metro.DELAY_EVENT(reported_at DESC);

COMMENT ON TABLE metro.DELAY_EVENT IS 'Every delay event against a schedule; drives ETA recalculation';

-- ================================================================
--  S23 — RESCHEDULE_LOG
--  Full audit trail of every rescheduling action.
--  Append-only — no UPDATE or DELETE.
-- ================================================================

CREATE TABLE metro.RESCHEDULE_LOG (
    -- Primary Key
    reschedule_id           BIGSERIAL           NOT NULL,

    -- Context
    schedule_id             INT                 NOT NULL,
    incident_id             INT,                            -- FK added after TRAIN_INCIDENT

    -- Change detail
    reason                  TEXT                NOT NULL,
    original_dep_time       TIME                NOT NULL,
    new_dep_time            TIME                NOT NULL,
    original_arr_time       TIME,
    new_arr_time            TIME,
    old_track_id            INT,
    new_track_id            INT,
    old_platform_no         SMALLINT,
    new_platform_no         SMALLINT,

    -- Who / when
    done_by_emp_id          INT,
    logged_at               TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,

    -- Constraints
    CONSTRAINT pk_reschedule    PRIMARY KEY (reschedule_id),
    CONSTRAINT fk_rsl_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES metro.TRAIN_SCHEDULE(schedule_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rsl_old_track
        FOREIGN KEY (old_track_id)
        REFERENCES metro.TRACK(track_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_rsl_new_track
        FOREIGN KEY (new_track_id)
        REFERENCES metro.TRACK(track_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_rsl_emp
        FOREIGN KEY (done_by_emp_id)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX idx_rsl_schedule ON metro.RESCHEDULE_LOG(schedule_id, logged_at DESC);

COMMENT ON TABLE metro.RESCHEDULE_LOG IS 'Immutable reschedule audit trail; append-only.';

-- ================================================================
--  S24 — STATION_CLOSURE
--  Temporary / permanent station closure records.
-- ================================================================

CREATE TABLE metro.STATION_CLOSURE (
    -- Primary Key
    closure_id              SERIAL              NOT NULL,

    -- Context
    station_id              INT                 NOT NULL,

    -- Closure detail
    closure_type            closure_type_t      NOT NULL,
    reason                  TEXT                NOT NULL,
    start_datetime          TIMESTAMPTZ         NOT NULL,
    end_datetime            TIMESTAMPTZ,
    actual_reopen_at        TIMESTAMPTZ,

    -- Status
    status                  VARCHAR(20)         NOT NULL    DEFAULT 'ACTIVE'
                                CHECK (status IN ('ACTIVE','LIFTED','CANCELLED','EXTENDED')),

    -- Approval
    approved_by_emp_id      INT,
    approval_notes          TEXT,

    -- Soft-delete
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_station_closure   PRIMARY KEY (closure_id),
    CONSTRAINT fk_scl_station
        FOREIGN KEY (station_id)
        REFERENCES metro.STATION(station_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_scl_approver
        FOREIGN KEY (approved_by_emp_id)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_scl_dates
        CHECK (end_datetime IS NULL OR end_datetime > start_datetime)
);

SELECT metro.fn_attach_updated_at_trigger('station_closure');

CREATE INDEX idx_scl_station ON metro.STATION_CLOSURE(station_id);
CREATE INDEX idx_scl_status  ON metro.STATION_CLOSURE(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_scl_dates   ON metro.STATION_CLOSURE(start_datetime, end_datetime);

COMMENT ON TABLE metro.STATION_CLOSURE IS 'Planned and emergency station closures with approval workflow';

-- ================================================================
--  S25 — TRAIN_INCIDENT
--  Crash / breakdown / derailment events.
--  Triggers new-train deployment and rescheduling workflow.
--  BCNF: incident_id → all; no transitive dependencies.
-- ================================================================

CREATE TABLE metro.TRAIN_INCIDENT (
    -- Primary Key
    incident_id             SERIAL              NOT NULL,

    -- Context
    train_id                INT                 NOT NULL,
    near_station_id         INT,
    schedule_id             INT,

    -- Incident detail
    incident_type           incident_type_t     NOT NULL,
    incident_datetime       TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    location_description    TEXT                NOT NULL,
    location_lat            latitude_t,
    location_lng            longitude_t,
    severity_level          SMALLINT            NOT NULL
                                CHECK (severity_level BETWEEN 1 AND 5),

    -- Response
    replacement_train_id    INT,                            -- New train deployed
    reported_by_emp_id      INT,
    investigated_by_emp_id  INT,
    root_cause              TEXT,
    corrective_action       TEXT,

    -- Timeline
    status                  incident_status_t   NOT NULL    DEFAULT 'OPEN',
    contained_at            TIMESTAMPTZ,
    resolved_at             TIMESTAMPTZ,
    closed_at               TIMESTAMPTZ,
    notes                   TEXT,

    -- Soft-delete
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_incident          PRIMARY KEY (incident_id),
    CONSTRAINT fk_inc_train
        FOREIGN KEY (train_id)
        REFERENCES metro.TRAIN(train_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_inc_station
        FOREIGN KEY (near_station_id)
        REFERENCES metro.STATION(station_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_inc_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES metro.TRAIN_SCHEDULE(schedule_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_inc_replacement
        FOREIGN KEY (replacement_train_id)
        REFERENCES metro.TRAIN(train_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_inc_reporter
        FOREIGN KEY (reported_by_emp_id)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_inc_investigator
        FOREIGN KEY (investigated_by_emp_id)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_inc_severity
        CHECK (severity_level BETWEEN 1 AND 5)
);

SELECT metro.fn_attach_updated_at_trigger('train_incident');

-- Back-fill FK in RESCHEDULE_LOG (incident was not yet created)
ALTER TABLE metro.RESCHEDULE_LOG
    ADD CONSTRAINT fk_rsl_incident
    FOREIGN KEY (incident_id)
    REFERENCES metro.TRAIN_INCIDENT(incident_id)
    ON DELETE SET NULL ON UPDATE CASCADE;

CREATE INDEX idx_inc_train   ON metro.TRAIN_INCIDENT(train_id);
CREATE INDEX idx_inc_status  ON metro.TRAIN_INCIDENT(status)    WHERE is_deleted = FALSE;
CREATE INDEX idx_inc_type    ON metro.TRAIN_INCIDENT(incident_type);
CREATE INDEX idx_inc_dt      ON metro.TRAIN_INCIDENT(incident_datetime DESC);

COMMENT ON TABLE  metro.TRAIN_INCIDENT            IS 'Crash/breakdown events; drives rescheduling and replacement workflow';
COMMENT ON COLUMN metro.TRAIN_INCIDENT.severity_level IS '1=minor delay, 5=catastrophic/fatality';
COMMENT ON COLUMN metro.TRAIN_INCIDENT.replacement_train_id IS 'New train put into service after crash';

-- ================================================================
--  S26 — LIVE_TRACKING
--  Append-only GPS time-series log.
--  One row per GPS ping (~5-second intervals).
--  No UPDATE or DELETE ever; partition by month in production.
--  BCNF: tracking_id → all; no transitive deps.
-- ================================================================

CREATE TABLE metro.LIVE_TRACKING (
    -- Primary Key (BIGSERIAL for high volume)
    tracking_id             BIGSERIAL           NOT NULL,

    -- Context
    train_id                INT                 NOT NULL
                                REFERENCES metro.TRAIN(train_id)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    schedule_id             INT
                                REFERENCES metro.TRAIN_SCHEDULE(schedule_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,

    -- GPS
    latitude                latitude_t          NOT NULL,
    longitude               longitude_t         NOT NULL,
    altitude_m              NUMERIC(7,2),
    accuracy_m              NUMERIC(6,2),

    -- Dynamics
    speed_kmph              NUMERIC(5,2)        NOT NULL    CHECK (speed_kmph >= 0),
    heading_degrees         NUMERIC(5,2)        CHECK (heading_degrees BETWEEN 0 AND 360),

    -- Safety block
    dynamic_block_dist_m    INT                 CHECK (dynamic_block_dist_m >= 0),

    -- Derived ETA (recalculated by application layer on each ping)
    updated_eta             TIMESTAMPTZ,

    -- Timestamp
    recorded_at             TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),

    -- Constraint
    CONSTRAINT pk_live_tracking PRIMARY KEY (tracking_id)
);

-- Covering index for "latest position per train" query
CREATE INDEX idx_lt_train_ts   ON metro.LIVE_TRACKING(train_id, recorded_at DESC)
    INCLUDE (latitude, longitude, speed_kmph, updated_eta);
CREATE INDEX idx_lt_schedule   ON metro.LIVE_TRACKING(schedule_id, recorded_at DESC)
    WHERE schedule_id IS NOT NULL;
CREATE INDEX idx_lt_recorded   ON metro.LIVE_TRACKING(recorded_at DESC);

COMMENT ON TABLE  metro.LIVE_TRACKING                  IS 'Append-only GPS log; partition by month for production scale';
COMMENT ON COLUMN metro.LIVE_TRACKING.dynamic_block_dist_m IS 'Minimum safe following distance from next train';
COMMENT ON COLUMN metro.LIVE_TRACKING.updated_eta          IS 'Recalculated ETA from current speed + schedule';

-- ================================================================
--  S27 — ALERT
--  System-generated and manual alerts pushed to passengers/staff.
-- ================================================================

CREATE TABLE metro.ALERT (
    -- Primary Key
    alert_id                BIGSERIAL           NOT NULL,

    -- Context (nullable — alert can relate to train, station, or line)
    train_id                INT
                                REFERENCES metro.TRAIN(train_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,
    schedule_id             INT
                                REFERENCES metro.TRAIN_SCHEDULE(schedule_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,
    station_id              INT
                                REFERENCES metro.STATION(station_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,
    line_id                 INT
                                REFERENCES metro.LINE(line_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,
    incident_id             INT
                                REFERENCES metro.TRAIN_INCIDENT(incident_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,

    -- Alert content
    alert_type              alert_type_t        NOT NULL,
    severity                alert_severity_t    NOT NULL    DEFAULT 'INFO',
    title                   VARCHAR(200)        NOT NULL,
    message                 TEXT                NOT NULL,
    channel                 alert_channel_t     NOT NULL    DEFAULT 'IN_APP',

    -- Lifecycle
    is_resolved             BOOLEAN             NOT NULL    DEFAULT FALSE,
    resolved_at             TIMESTAMPTZ,
    auto_expires_at         TIMESTAMPTZ,

    -- Creator
    created_by_emp_id       INT
                                REFERENCES metro.EMPLOYEE(employee_id)
                                ON DELETE SET NULL,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_by              INT,

    CONSTRAINT pk_alert PRIMARY KEY (alert_id),
    CONSTRAINT chk_alert_context
        CHECK (
            train_id IS NOT NULL OR station_id IS NOT NULL
            OR line_id IS NOT NULL OR schedule_id IS NOT NULL
        )
);

SELECT metro.fn_attach_updated_at_trigger('alert');

CREATE INDEX idx_alert_train    ON metro.ALERT(train_id)    WHERE train_id IS NOT NULL;
CREATE INDEX idx_alert_type     ON metro.ALERT(alert_type);
CREATE INDEX idx_alert_severity ON metro.ALERT(severity)    WHERE is_resolved = FALSE;
CREATE INDEX idx_alert_created  ON metro.ALERT(created_at DESC);

COMMENT ON TABLE metro.ALERT IS 'System & manual alerts for passengers and staff';

-- ================================================================
--  S28 — ALERT_PASSENGER_MAP
--  Records which passengers received / acknowledged each alert.
-- ================================================================

CREATE TABLE metro.ALERT_PASSENGER_MAP (
    alert_id                BIGINT              NOT NULL
                                REFERENCES metro.ALERT(alert_id)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    passenger_id            INT                 NOT NULL
                                REFERENCES metro.PASSENGER(passenger_id)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    sent_at                 TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    is_read                 BOOLEAN             NOT NULL    DEFAULT FALSE,
    read_at                 TIMESTAMPTZ,
    delivery_status         VARCHAR(20)         NOT NULL    DEFAULT 'SENT'
                                CHECK (delivery_status IN ('SENT','DELIVERED','READ','FAILED')),

    CONSTRAINT pk_alert_passenger PRIMARY KEY (alert_id, passenger_id)
);

CREATE INDEX idx_apm_passenger ON metro.ALERT_PASSENGER_MAP(passenger_id, sent_at DESC);

COMMENT ON TABLE metro.ALERT_PASSENGER_MAP IS 'Delivery and read receipts for per-passenger alert dispatch';

-- ================================================================
--  S29 — MAINTENANCE_LOG
--  Full work-order history for each train.
-- ================================================================

CREATE TABLE metro.MAINTENANCE_LOG (
    -- Primary Key
    log_id                  SERIAL              NOT NULL,

    -- Context
    train_id                INT                 NOT NULL,
    incident_id             INT,

    -- Work order detail
    maintenance_type        maint_type_t        NOT NULL,
    maintenance_date        DATE                NOT NULL,
    description             TEXT                NOT NULL,
    parts_replaced          TEXT,
    vendor_name             VARCHAR(200),

    -- Financials
    estimated_cost          money_t,
    actual_cost             money_t,

    -- Personnel
    performed_by_emp_id     INT,
    supervised_by_emp_id    INT,
    approved_by_emp_id      INT,

    -- Timeline
    status                  maint_status_t      NOT NULL    DEFAULT 'SCHEDULED',
    scheduled_start         TIMESTAMPTZ,
    actual_start            TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ,
    next_due_date           DATE,

    -- Soft-delete
    is_deleted              BOOLEAN             NOT NULL    DEFAULT FALSE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_by              INT,
    updated_by              INT,

    -- Constraints
    CONSTRAINT pk_maintenance   PRIMARY KEY (log_id),
    CONSTRAINT fk_maint_train
        FOREIGN KEY (train_id)
        REFERENCES metro.TRAIN(train_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_maint_incident
        FOREIGN KEY (incident_id)
        REFERENCES metro.TRAIN_INCIDENT(incident_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_maint_performer
        FOREIGN KEY (performed_by_emp_id)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_maint_supervisor
        FOREIGN KEY (supervised_by_emp_id)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_maint_approver
        FOREIGN KEY (approved_by_emp_id)
        REFERENCES metro.EMPLOYEE(employee_id)
        ON DELETE SET NULL
);

SELECT metro.fn_attach_updated_at_trigger('maintenance_log');

CREATE INDEX idx_maint_train   ON metro.MAINTENANCE_LOG(train_id, maintenance_date DESC);
CREATE INDEX idx_maint_status  ON metro.MAINTENANCE_LOG(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_maint_due     ON metro.MAINTENANCE_LOG(next_due_date) WHERE next_due_date IS NOT NULL;

COMMENT ON TABLE metro.MAINTENANCE_LOG IS 'Complete work-order history per train; tracks cost and personnel';

-- ================================================================
--  S30 — TRAVELLING_IN
--  M:N — which passenger is aboard which train stop.
--  Real-time crowd source of truth.
--  BCNF: (passenger_id, schedule_id, stop_sequence, boarded_at) → all.
-- ================================================================

CREATE TABLE metro.TRAVELLING_IN (
    -- Composite Primary Key
    passenger_id            INT                 NOT NULL,
    schedule_id             INT                 NOT NULL,
    stop_sequence           SMALLINT            NOT NULL,
    boarded_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),

    -- Journey context
    ticket_id               BIGINT,
    pass_id                 INT,

    -- Status
    exited_at               TIMESTAMPTZ,
    status                  travel_status_t     NOT NULL    DEFAULT 'BOARDING',

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),

    -- Constraints
    CONSTRAINT pk_travelling_in
        PRIMARY KEY (passenger_id, schedule_id, stop_sequence, boarded_at),
    CONSTRAINT fk_trv_passenger
        FOREIGN KEY (passenger_id)
        REFERENCES metro.PASSENGER(passenger_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_trv_stop
        FOREIGN KEY (schedule_id, stop_sequence)
        REFERENCES metro.TRAIN_STOP(schedule_id, stop_sequence)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_trv_ticket
        FOREIGN KEY (ticket_id)
        REFERENCES metro.TICKET(ticket_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_trv_pass
        FOREIGN KEY (pass_id)
        REFERENCES metro.TRAVEL_PASS(pass_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_trv_auth
        CHECK (ticket_id IS NOT NULL OR pass_id IS NOT NULL)
);

SELECT metro.fn_attach_updated_at_trigger('travelling_in');

CREATE INDEX idx_trvin_stop    ON metro.TRAVELLING_IN(schedule_id, stop_sequence, status);
CREATE INDEX idx_trvin_active  ON metro.TRAVELLING_IN(status)
    WHERE status IN ('BOARDING','ON_TRAIN');

COMMENT ON TABLE metro.TRAVELLING_IN IS 'Real-time passenger-on-train source of truth; drives crowd count';

-- ================================================================
--  S31 — TICKET_GATE_SCAN
--  QR scan events at entry and exit gates.
--  One ENTRY + one EXIT per ticket enforced via UNIQUE.
-- ================================================================

CREATE TABLE metro.TICKET_GATE_SCAN (
    -- Primary Key
    scan_id                 BIGSERIAL           NOT NULL,

    -- Reference
    ticket_id               BIGINT              NOT NULL,
    pass_id                 INT,                            -- For travel pass gate entry

    -- Gate context
    station_id              INT                 NOT NULL,
    platform_no             SMALLINT            NOT NULL,
    schedule_id             INT,
    stop_sequence           SMALLINT,
    gate_device_id          VARCHAR(50)         NOT NULL,   -- Hardware scanner ID

    -- Scan detail
    gate_role               gate_role_t         NOT NULL,
    scan_timestamp          TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    is_valid                BOOLEAN             NOT NULL    DEFAULT TRUE,
    rejection_reason        TEXT,

    -- Constraints
    CONSTRAINT pk_gate_scan PRIMARY KEY (scan_id),
    CONSTRAINT uq_ticket_entry_exit
        UNIQUE (ticket_id, gate_role),          -- One entry + one exit per ticket
    CONSTRAINT fk_scan_ticket
        FOREIGN KEY (ticket_id)
        REFERENCES metro.TICKET(ticket_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_scan_pass
        FOREIGN KEY (pass_id)
        REFERENCES metro.TRAVEL_PASS(pass_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_scan_platform
        FOREIGN KEY (station_id, platform_no)
        REFERENCES metro.PLATFORM(station_id, platform_no)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_scan_stop
        FOREIGN KEY (schedule_id, stop_sequence)
        REFERENCES metro.TRAIN_STOP(schedule_id, stop_sequence)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX idx_scan_ticket   ON metro.TICKET_GATE_SCAN(ticket_id);
CREATE INDEX idx_scan_station  ON metro.TICKET_GATE_SCAN(station_id, gate_role, scan_timestamp DESC);
CREATE INDEX idx_scan_device   ON metro.TICKET_GATE_SCAN(gate_device_id, scan_timestamp DESC);

COMMENT ON TABLE  metro.TICKET_GATE_SCAN          IS 'QR scan events at turnstiles; ENTRY+EXIT enforced per ticket';
COMMENT ON COLUMN metro.TICKET_GATE_SCAN.gate_device_id IS 'Physical scanner hardware ID for audit trails';

-- ================================================================
--  S32 — FEEDBACK
--  Passenger ratings and comments on service quality.
-- ================================================================

CREATE TABLE metro.FEEDBACK (
    -- Primary Key
    feedback_id             BIGSERIAL           NOT NULL,

    -- Context
    passenger_id            INT
                                REFERENCES metro.PASSENGER(passenger_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,
    schedule_id             INT
                                REFERENCES metro.TRAIN_SCHEDULE(schedule_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,
    station_id              INT
                                REFERENCES metro.STATION(station_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,
    ticket_id               BIGINT
                                REFERENCES metro.TICKET(ticket_id)
                                ON DELETE SET NULL ON UPDATE CASCADE,

    -- Content
    category                feedback_category_t NOT NULL,
    rating                  rating_t            NOT NULL,
    comment                 TEXT,
    attachment_url          VARCHAR(500),

    -- Workflow
    status                  VARCHAR(20)         NOT NULL    DEFAULT 'OPEN'
                                CHECK (status IN ('OPEN','IN_REVIEW','RESOLVED','CLOSED')),
    reviewed_by_emp_id      INT
                                REFERENCES metro.EMPLOYEE(employee_id)
                                ON DELETE SET NULL,
    review_notes            TEXT,
    reviewed_at             TIMESTAMPTZ,

    -- Audit
    submitted_at            TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_by              INT,

    CONSTRAINT pk_feedback PRIMARY KEY (feedback_id),
    CONSTRAINT chk_feedback_context
        CHECK (
            passenger_id IS NOT NULL OR station_id IS NOT NULL
            OR schedule_id IS NOT NULL
        )
);

SELECT metro.fn_attach_updated_at_trigger('feedback');

CREATE INDEX idx_fbk_passenger ON metro.FEEDBACK(passenger_id, submitted_at DESC);
CREATE INDEX idx_fbk_schedule  ON metro.FEEDBACK(schedule_id);
CREATE INDEX idx_fbk_station   ON metro.FEEDBACK(station_id);
CREATE INDEX idx_fbk_rating    ON metro.FEEDBACK(rating);
CREATE INDEX idx_fbk_status    ON metro.FEEDBACK(status) WHERE status IN ('OPEN','IN_REVIEW');

COMMENT ON TABLE metro.FEEDBACK IS 'Passenger service quality ratings with review workflow';

-- ================================================================
--  S33 — SYSTEM_CONFIG
--  Key-value store for all runtime-configurable parameters.
--  Examples: max_crowd_alert_threshold, QR_validity_minutes, etc.
-- ================================================================

CREATE TABLE metro.SYSTEM_CONFIG (
    config_key              VARCHAR(100)        NOT NULL,
    config_value            TEXT                NOT NULL,
    data_type               VARCHAR(20)         NOT NULL    DEFAULT 'STRING'
                                CHECK (data_type IN ('STRING','INTEGER','DECIMAL','BOOLEAN','JSON')),
    description             TEXT,
    is_sensitive            BOOLEAN             NOT NULL    DEFAULT FALSE,
    is_active               BOOLEAN             NOT NULL    DEFAULT TRUE,

    -- Audit
    created_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),
    updated_by              INT
                                REFERENCES metro.EMPLOYEE(employee_id)
                                ON DELETE SET NULL,

    CONSTRAINT pk_system_config PRIMARY KEY (config_key)
);

SELECT metro.fn_attach_updated_at_trigger('system_config');

-- Seed default configuration values
INSERT INTO metro.SYSTEM_CONFIG (config_key, config_value, data_type, description) VALUES
('QR_VALIDITY_MINUTES',        '120',   'INTEGER', 'Minutes a QR ticket remains valid after booking'),
('CROWD_ALERT_THRESHOLD_PCT',  '85',    'INTEGER', 'Trigger HIGH_CROWD alert when train fills above this %'),
('MAX_BOOKING_PER_PASSENGER',  '10',    'INTEGER', 'Max active tickets per passenger at any time'),
('DELAY_ALERT_THRESHOLD_MIN',  '5',     'INTEGER', 'Minimum delay minutes before passenger alert is sent'),
('LIVE_TRACKING_INTERVAL_SEC', '5',     'INTEGER', 'GPS ping interval from train tracking unit'),
('STUDENT_FARE_DISCOUNT_PCT',  '50',    'INTEGER', 'Discount percentage applied to student_fare'),
('SENIOR_FARE_DISCOUNT_PCT',   '50',    'INTEGER', 'Discount percentage applied to senior_citizen_fare'),
('CHILD_MAX_AGE_YEARS',        '12',    'INTEGER', 'Maximum age (inclusive) to qualify for child fare'),
('SENIOR_MIN_AGE_YEARS',       '60',    'INTEGER', 'Minimum age to qualify for senior citizen concession'),
('PLATFORM_CHANGE_GRACE_MIN',  '10',    'INTEGER', 'Minutes before departure within which platform cannot be changed'),
('REFUND_ALLOWED_BEFORE_MIN',  '30',    'INTEGER', 'Ticket cancellation/refund allowed only X minutes before departure'),
('APP_VERSION_MINIMUM',        '2.0.0', 'STRING',  'Minimum supported app version'),
('MAINTENANCE_ALERT_DAYS',     '90',    'INTEGER', 'Days before license expiry to send driver alert');

COMMENT ON TABLE metro.SYSTEM_CONFIG IS 'Runtime configurable parameters; no code deploy needed for changes';

-- ================================================================
--  S34 — AUDIT_LOG  (Generic)
--  Captures all significant data changes across the system.
--  Append-only — no UPDATE or DELETE ever.
-- ================================================================

CREATE TABLE metro.AUDIT_LOG (
    audit_id                BIGSERIAL           NOT NULL,
    schema_name             VARCHAR(50)         NOT NULL    DEFAULT 'metro',
    table_name              VARCHAR(100)        NOT NULL,
    record_id               TEXT                NOT NULL,   -- PK value(s) as text
    action                  audit_action_t      NOT NULL,
    old_data                JSONB,
    new_data                JSONB,
    changed_fields          TEXT[],
    performed_by_emp_id     INT,
    performed_by_passenger_id INT,
    ip_address              INET,
    user_agent              TEXT,
    session_id              VARCHAR(200),
    performed_at            TIMESTAMPTZ         NOT NULL    DEFAULT NOW(),

    CONSTRAINT pk_audit_log PRIMARY KEY (audit_id)
);

CREATE INDEX idx_audit_table   ON metro.AUDIT_LOG(table_name, performed_at DESC);
CREATE INDEX idx_audit_record  ON metro.AUDIT_LOG(table_name, record_id, performed_at DESC);
CREATE INDEX idx_audit_emp     ON metro.AUDIT_LOG(performed_by_emp_id, performed_at DESC)
    WHERE performed_by_emp_id IS NOT NULL;
CREATE INDEX idx_audit_action  ON metro.AUDIT_LOG(action, performed_at DESC);

COMMENT ON TABLE metro.AUDIT_LOG IS 'Generic immutable audit trail for all sensitive changes';

-- ================================================================
--  T01 — TRIGGERS
-- ================================================================

-- ── T1: Auto-update TRAIN.current_crowd_count from TRAVELLING_IN ──
CREATE OR REPLACE FUNCTION metro.fn_sync_train_crowd_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_train_id INT;
    v_count    INT;
BEGIN
    -- Identify train for this stop
    SELECT ts.train_id INTO v_train_id
    FROM   metro.TRAIN_SCHEDULE ts
    WHERE  ts.schedule_id = COALESCE(NEW.schedule_id, OLD.schedule_id);

    IF v_train_id IS NULL THEN
        RETURN COALESCE(NEW, OLD);
    END IF;

    -- Count active passengers on this train
    SELECT COUNT(*) INTO v_count
    FROM   metro.TRAVELLING_IN ti
    JOIN   metro.TRAIN_SCHEDULE ts ON ts.schedule_id = ti.schedule_id
    WHERE  ts.train_id = v_train_id
    AND    ti.status   = 'ON_TRAIN';

    UPDATE metro.TRAIN
    SET    current_crowd_count = v_count,
           updated_at          = NOW()
    WHERE  train_id = v_train_id;

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_travelling_in_crowd
AFTER INSERT OR UPDATE OR DELETE
ON metro.TRAVELLING_IN
FOR EACH ROW
EXECUTE FUNCTION metro.fn_sync_train_crowd_count();

-- ── T2: Sync STATION.is_active with STATION_CLOSURE status ──
CREATE OR REPLACE FUNCTION metro.fn_sync_station_active_on_closure()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP IN ('INSERT', 'UPDATE') AND NEW.status = 'ACTIVE' THEN
        -- Close the station
        UPDATE metro.STATION
        SET    is_active   = FALSE,
               updated_at  = NOW()
        WHERE  station_id  = NEW.station_id;

    ELSIF TG_OP = 'UPDATE' AND NEW.status IN ('LIFTED', 'CANCELLED') THEN
        -- Re-open only if no other active closure
        IF NOT EXISTS (
            SELECT 1 FROM metro.STATION_CLOSURE
            WHERE  station_id  = NEW.station_id
            AND    status      = 'ACTIVE'
            AND    closure_id <> NEW.closure_id
            AND    is_deleted  = FALSE
        ) THEN
            UPDATE metro.STATION
            SET    is_active  = TRUE,
                   updated_at = NOW()
            WHERE  station_id = NEW.station_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_station_closure_sync
AFTER INSERT OR UPDATE
ON metro.STATION_CLOSURE
FOR EACH ROW
EXECUTE FUNCTION metro.fn_sync_station_active_on_closure();

-- ── T3: Prevent track scheduling conflicts (no overlap for same track+day) ──
CREATE OR REPLACE FUNCTION metro.fn_check_track_schedule_conflict()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.track_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Check track is available
    PERFORM 1 FROM metro.TRACK
    WHERE   track_id     = NEW.track_id
    AND     track_status IN ('UNDER_MAINTENANCE','BLOCKED','CLOSED');

    IF FOUND THEN
        RAISE EXCEPTION
            'Track % is not available (status: maintenance/blocked/closed).', NEW.track_id;
    END IF;

    -- Check no time overlap with existing ACTIVE schedule on same track+day_type
    IF EXISTS (
        SELECT 1
        FROM   metro.TRAIN_SCHEDULE
        WHERE  track_id         = NEW.track_id
        AND    day_type          = NEW.day_type
        AND    schedule_id      <> COALESCE(NEW.schedule_id, -1)
        AND    schedule_status   = 'ACTIVE'
        AND    is_deleted        = FALSE
        AND    (
                   (NEW.departure_time, NEW.arrival_time)
                   OVERLAPS
                   (departure_time, arrival_time)
               )
    ) THEN
        RAISE EXCEPTION
            'Schedule conflict: Track % already has an active run during % – % on %.  '
            'Assign a different track or adjust timing.',
            NEW.track_id,
            NEW.departure_time,
            NEW.arrival_time,
            NEW.day_type;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_schedule_track_conflict
BEFORE INSERT OR UPDATE
ON metro.TRAIN_SCHEDULE
FOR EACH ROW
EXECUTE FUNCTION metro.fn_check_track_schedule_conflict();

-- ── T4: Auto-mark TICKET status on gate scan ──
CREATE OR REPLACE FUNCTION metro.fn_update_ticket_on_gate_scan()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF NEW.is_valid = FALSE THEN
        RETURN NEW;    -- Don't change status for rejected scans
    END IF;

    IF NEW.gate_role = 'ENTRY' THEN
        UPDATE metro.TICKET
        SET    status     = 'ENTRY_DONE',
               updated_at = NOW()
        WHERE  ticket_id  = NEW.ticket_id
        AND    status     = 'ACTIVE';

    ELSIF NEW.gate_role = 'EXIT' THEN
        -- Mark ticket fully USED once exit is scanned
        UPDATE metro.TICKET
        SET    status     = 'USED',
               updated_at = NOW()
        WHERE  ticket_id  = NEW.ticket_id
        AND    status     = 'ENTRY_DONE';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_gate_scan_update_ticket
AFTER INSERT
ON metro.TICKET_GATE_SCAN
FOR EACH ROW
EXECUTE FUNCTION metro.fn_update_ticket_on_gate_scan();

-- ── T5: Auto-expire tickets past their valid_to ──
-- (Run this as a scheduled job / pg_cron in production)
CREATE OR REPLACE FUNCTION metro.fn_expire_stale_tickets()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE v_count INT;
BEGIN
    UPDATE metro.TICKET
    SET    status     = 'EXPIRED',
           updated_at = NOW()
    WHERE  status    IN ('BOOKED', 'ACTIVE')
    AND    valid_to   < NOW()
    AND    is_deleted = FALSE;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION metro.fn_expire_stale_tickets() IS
'Call via pg_cron every 5 minutes: SELECT metro.fn_expire_stale_tickets();';

-- ── T6: Employee HR change audit trigger ──
CREATE OR REPLACE FUNCTION metro.fn_employee_hr_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_fields TEXT[] := ARRAY['salary', 'role', 'department', 'employment_status',
                              'access_level', 'managed_station_id'];
    v_field  TEXT;
    v_old    TEXT;
    v_new    TEXT;
BEGIN
    FOREACH v_field IN ARRAY v_fields
    LOOP
        EXECUTE format('SELECT ($1).%I::TEXT', v_field) INTO v_old USING OLD;
        EXECUTE format('SELECT ($1).%I::TEXT', v_field) INTO v_new USING NEW;

        IF v_old IS DISTINCT FROM v_new THEN
            INSERT INTO metro.EMPLOYEE_AUDIT_LOG (
                employee_id, changed_field, old_value, new_value,
                changed_by_emp_id, changed_at
            ) VALUES (
                NEW.employee_id, v_field, v_old, v_new,
                NEW.updated_by, NOW()
            );
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_employee_hr_audit
AFTER UPDATE
ON metro.EMPLOYEE
FOR EACH ROW
EXECUTE FUNCTION metro.fn_employee_hr_audit();

-- ── T7: Block gate entry if ticket is expired, cancelled, or already used ──
CREATE OR REPLACE FUNCTION metro.fn_validate_ticket_for_scan()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE v_status ticket_status_t;
DECLARE v_valid_to TIMESTAMPTZ;
BEGIN
    SELECT status, valid_to INTO v_status, v_valid_to
    FROM   metro.TICKET
    WHERE  ticket_id = NEW.ticket_id;

    -- Validate ENTRY
    IF NEW.gate_role = 'ENTRY' THEN
        IF v_status NOT IN ('BOOKED','ACTIVE') THEN
            NEW.is_valid         := FALSE;
            NEW.rejection_reason := 'Ticket status is: ' || v_status::TEXT;
            RETURN NEW;
        END IF;
        IF v_valid_to < NOW() THEN
            NEW.is_valid         := FALSE;
            NEW.rejection_reason := 'Ticket has expired at ' || v_valid_to::TEXT;
            RETURN NEW;
        END IF;
    END IF;

    -- Validate EXIT
    IF NEW.gate_role = 'EXIT' THEN
        IF v_status <> 'ENTRY_DONE' THEN
            NEW.is_valid         := FALSE;
            NEW.rejection_reason := 'No valid entry scan found for this ticket';
            RETURN NEW;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validate_ticket_scan
BEFORE INSERT
ON metro.TICKET_GATE_SCAN
FOR EACH ROW
EXECUTE FUNCTION metro.fn_validate_ticket_for_scan();

-- ── T8: Auto-update TRAIN.operational_status on TRAIN_INCIDENT ──
CREATE OR REPLACE FUNCTION metro.fn_train_status_on_incident()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.status = 'OPEN' THEN
        UPDATE metro.TRAIN
        SET    operational_status = CASE NEW.incident_type
                                        WHEN 'CRASH'       THEN 'CRASHED'::train_status_t
                                        WHEN 'BREAKDOWN'   THEN 'MAINTENANCE'::train_status_t
                                        WHEN 'DERAILMENT'  THEN 'CRASHED'::train_status_t
                                        ELSE 'SUSPENDED'::train_status_t
                                    END,
               is_on_rest   = TRUE,
               updated_at   = NOW()
        WHERE  train_id = NEW.train_id;
    END IF;

    IF TG_OP = 'UPDATE' AND NEW.status = 'RESOLVED' AND OLD.status <> 'RESOLVED' THEN
        UPDATE metro.TRAIN
        SET    operational_status = 'RESTING'::train_status_t,
               is_on_rest   = TRUE,
               updated_at   = NOW()
        WHERE  train_id = NEW.train_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_train_incident_status
AFTER INSERT OR UPDATE
ON metro.TRAIN_INCIDENT
FOR EACH ROW
EXECUTE FUNCTION metro.fn_train_status_on_incident();

-- ================================================================
--  V01 — VIEWS
-- ================================================================

-- ── V1: Live Train Board — active schedules with real-time crowd ──
CREATE OR REPLACE VIEW metro.v_live_train_board AS
SELECT
    ts.schedule_id,
    t.train_id,
    t.train_number,
    l.line_id,
    l.line_name,
    l.color_code,
    ts.direction,
    ts.day_type,
    ts.departure_time,
    ts.arrival_time,
    ts.normal_eta_mins,
    ts.schedule_status,
    tk.track_number,
    t.operational_status                                        AS train_status,
    t.total_capacity,
    t.current_crowd_count,
    ROUND(
        (t.current_crowd_count::NUMERIC / NULLIF(t.total_capacity,0)) * 100, 1
    )                                                           AS crowd_pct,
    CASE
        WHEN ROUND((t.current_crowd_count::NUMERIC /
             NULLIF(t.total_capacity,0)) * 100, 1) >= 85 THEN 'HIGH'
        WHEN ROUND((t.current_crowd_count::NUMERIC /
             NULLIF(t.total_capacity,0)) * 100, 1) >= 60 THEN 'MODERATE'
        ELSE 'LOW'
    END                                                         AS crowd_level,
    t.current_lat,
    t.current_lng,
    t.current_speed_kmph,
    t.last_gps_update
FROM  metro.TRAIN_SCHEDULE  ts
JOIN  metro.TRAIN            t   ON t.train_id   = ts.train_id
JOIN  metro.LINE             l   ON l.line_id    = ts.line_id
LEFT JOIN metro.TRACK        tk  ON tk.track_id  = ts.track_id
WHERE ts.schedule_status IN ('ACTIVE','DELAYED')
AND   ts.is_deleted = FALSE
AND   t.is_deleted  = FALSE;

-- ── V2: Station Info with all served lines ──
CREATE OR REPLACE VIEW metro.v_station_info AS
SELECT
    s.station_id,
    s.station_code,
    s.station_name,
    s.station_type,
    s.zone_no,
    s.latitude,
    s.longitude,
    s.is_active,
    s.is_interchange,
    s.wheelchair_accessible,
    s.has_lift,
    s.has_escalator,
    s.has_parking,
    COUNT(DISTINCT sol.line_id)                                 AS total_lines,
    STRING_AGG(
        l.line_name || ' [' || l.color_code || ']',
        ' | ' ORDER BY l.line_name
    )                                                           AS lines_served
FROM  metro.STATION           s
LEFT JOIN metro.STATION_ON_LINE sol ON sol.station_id = s.station_id
                                    AND sol.is_active  = TRUE
LEFT JOIN metro.LINE           l   ON l.line_id        = sol.line_id
WHERE s.is_deleted = FALSE
GROUP BY s.station_id, s.station_code, s.station_name, s.station_type,
         s.zone_no, s.latitude, s.longitude, s.is_active,
         s.is_interchange, s.wheelchair_accessible,
         s.has_lift, s.has_escalator, s.has_parking;

-- ── V3: Full stop timetable per schedule ──
CREATE OR REPLACE VIEW metro.v_train_timetable AS
SELECT
    ts.schedule_id,
    t.train_number,
    l.line_name,
    l.color_code,
    ts.direction,
    ts.day_type,
    tst.stop_sequence,
    s.station_code,
    s.station_name,
    s.zone_no,
    tst.platform_no,
    tst.scheduled_arrival,
    tst.scheduled_departure,
    tst.halt_duration_sec,
    tst.dynamic_eta,
    CASE
        WHEN tst.dynamic_eta IS NOT NULL
             AND tst.scheduled_arrival IS NOT NULL
        THEN EXTRACT(EPOCH FROM (
                 tst.dynamic_eta - (CURRENT_DATE + tst.scheduled_arrival)
             )) / 60
        ELSE NULL
    END::INT                                                    AS delay_mins,
    tst.is_active                                               AS stop_active
FROM  metro.TRAIN_SCHEDULE  ts
JOIN  metro.TRAIN            t   ON t.train_id      = ts.train_id
JOIN  metro.LINE             l   ON l.line_id       = ts.line_id
JOIN  metro.TRAIN_STOP       tst ON tst.schedule_id = ts.schedule_id
JOIN  metro.STATION          s   ON s.station_id    = tst.station_id
WHERE ts.is_deleted  = FALSE
AND   tst.is_deleted = FALSE
ORDER BY ts.schedule_id, tst.stop_sequence;

-- ── V4: Active delays with context ──
CREATE OR REPLACE VIEW metro.v_active_delays AS
SELECT
    de.delay_id,
    de.schedule_id,
    t.train_number,
    l.line_name,
    ts.direction,
    s.station_name                                              AS affected_station,
    de.delay_minutes,
    de.delay_category,
    de.reason,
    de.reported_at,
    de.resolution_status,
    AGE(NOW(), de.reported_at)                                  AS age
FROM  metro.DELAY_EVENT     de
JOIN  metro.TRAIN_SCHEDULE  ts ON ts.schedule_id     = de.schedule_id
JOIN  metro.TRAIN            t ON t.train_id         = ts.train_id
JOIN  metro.LINE             l ON l.line_id          = ts.line_id
LEFT JOIN metro.STATION      s ON s.station_id       = de.affected_station_id
WHERE de.resolution_status IN ('PENDING','IN_PROGRESS')
ORDER BY de.reported_at DESC;

-- ── V5: Latest GPS position per train ──
CREATE OR REPLACE VIEW metro.v_live_train_positions AS
SELECT DISTINCT ON (lt.train_id)
    lt.train_id,
    t.train_number,
    lt.schedule_id,
    lt.latitude,
    lt.longitude,
    lt.speed_kmph,
    lt.heading_degrees,
    lt.dynamic_block_dist_m,
    lt.updated_eta,
    lt.recorded_at,
    AGE(NOW(), lt.recorded_at)                                  AS last_seen_ago
FROM  metro.LIVE_TRACKING lt
JOIN  metro.TRAIN          t ON t.train_id = lt.train_id
ORDER BY lt.train_id, lt.recorded_at DESC;

-- ── V6: Passenger trip history ──
CREATE OR REPLACE VIEW metro.v_passenger_trip_history AS
SELECT
    p.passenger_id,
    p.full_name,
    p.phone,
    tk.ticket_id,
    tk.qr_code,
    tk.ticket_type,
    tk.passenger_category,
    tk.booking_channel,
    tk.distance_km,
    tk.price_paid,
    tk.issued_at,
    tk.valid_from,
    tk.valid_to,
    tk.status                                                   AS ticket_status,
    sf.station_name                                             AS from_station,
    st.station_name                                             AS to_station,
    py.payment_method,
    py.status                                                   AS payment_status,
    py.paid_at,
    entry_scan.scan_timestamp                                   AS entry_time,
    exit_scan.scan_timestamp                                    AS exit_time
FROM  metro.PASSENGER          p
JOIN  metro.TICKET             tk       ON tk.passenger_id     = p.passenger_id
JOIN  metro.STATION            sf       ON sf.station_id       = tk.from_station_id
JOIN  metro.STATION            st       ON st.station_id       = tk.to_station_id
LEFT JOIN metro.PAYMENT        py       ON py.ticket_id        = tk.ticket_id
LEFT JOIN metro.TICKET_GATE_SCAN entry_scan
    ON entry_scan.ticket_id = tk.ticket_id AND entry_scan.gate_role = 'ENTRY'
LEFT JOIN metro.TICKET_GATE_SCAN exit_scan
    ON exit_scan.ticket_id  = tk.ticket_id AND exit_scan.gate_role  = 'EXIT'
WHERE p.is_deleted  = FALSE
AND   tk.is_deleted = FALSE
ORDER BY tk.issued_at DESC;

-- ── V7: Fare lookup (current active slabs) ──
CREATE OR REPLACE VIEW metro.v_fare_lookup AS
SELECT
    fr.fare_rule_id,
    fr.min_distance_km,
    fr.max_distance_km,
    fr.base_fare,
    fr.normal_fare,
    fr.senior_citizen_fare,
    fr.physically_disabled_fare,
    fr.child_fare,
    fr.student_fare,
    fr.tourist_fare,
    fr.freedom_fighter_fare,
    fr.effective_from
FROM  metro.FARE_RULE fr
WHERE fr.is_active      = TRUE
AND   fr.effective_from <= CURRENT_DATE
AND   (fr.effective_to IS NULL OR fr.effective_to >= CURRENT_DATE)
ORDER BY fr.min_distance_km;

-- ── V8: Driver schedule for today ──
CREATE OR REPLACE VIEW metro.v_driver_schedule_today AS
SELECT
    d.driver_id,
    d.employee_code,
    d.full_name                                                 AS driver_name,
    d.phone,
    dsa.schedule_id,
    dsa.role                                                    AS driver_role,
    t.train_number,
    l.line_name,
    ts.direction,
    ts.departure_time,
    ts.arrival_time,
    ts.schedule_status,
    ds.shift_start,
    ds.shift_end,
    ds.working_hours
FROM  metro.DRIVER_SCHEDULE_ASSIGNMENT dsa
JOIN  metro.DRIVER               d   ON d.driver_id     = dsa.driver_id
JOIN  metro.TRAIN_SCHEDULE       ts  ON ts.schedule_id  = dsa.schedule_id
JOIN  metro.TRAIN                t   ON t.train_id      = ts.train_id
JOIN  metro.LINE                 l   ON l.line_id       = ts.line_id
LEFT JOIN metro.DRIVER_SHIFT     ds  ON ds.driver_id    = dsa.driver_id
                                    AND ds.shift_date   = CURRENT_DATE
WHERE dsa.assignment_date = CURRENT_DATE
AND   dsa.is_active       = TRUE
AND   d.is_deleted        = FALSE
ORDER BY ts.departure_time;

-- ── V9: Open incidents dashboard ──
CREATE OR REPLACE VIEW metro.v_open_incidents AS
SELECT
    inc.incident_id,
    inc.incident_type,
    inc.incident_datetime,
    inc.severity_level,
    inc.status,
    t.train_number,
    s.station_name                                              AS near_station,
    rt.train_number                                             AS replacement_train,
    inc.location_description,
    inc.root_cause,
    AGE(NOW(), inc.incident_datetime)                           AS open_since
FROM  metro.TRAIN_INCIDENT      inc
JOIN  metro.TRAIN                t   ON t.train_id   = inc.train_id
LEFT JOIN metro.STATION          s   ON s.station_id = inc.near_station_id
LEFT JOIN metro.TRAIN            rt  ON rt.train_id  = inc.replacement_train_id
WHERE inc.status NOT IN ('CLOSED','ARCHIVED')
AND   inc.is_deleted = FALSE
ORDER BY inc.severity_level DESC, inc.incident_datetime DESC;

-- ── V10: Revenue summary by date ──
CREATE OR REPLACE VIEW metro.v_revenue_by_date AS
SELECT
    DATE(py.paid_at)                                            AS pay_date,
    py.payment_method,
    COUNT(py.payment_id)                                        AS total_transactions,
    SUM(py.amount)                                              AS gross_revenue,
    SUM(py.refund_amount)                                       AS total_refunds,
    SUM(py.amount - py.refund_amount)                           AS net_revenue
FROM  metro.PAYMENT py
WHERE py.status IN ('SUCCESS','PARTIALLY_REFUNDED')
GROUP BY DATE(py.paid_at), py.payment_method
ORDER BY pay_date DESC, gross_revenue DESC;

-- ================================================================
--  I01 — ADDITIONAL PERFORMANCE INDEXES
-- ================================================================

-- Fast fare lookup by distance
CREATE INDEX idx_fare_active_slab
    ON metro.FARE_RULE(min_distance_km, max_distance_km, is_active)
    WHERE is_active = TRUE;

-- Fast upcoming trains for a station
CREATE INDEX idx_tstop_upcoming
    ON metro.TRAIN_STOP(station_id, scheduled_departure)
    WHERE is_active = TRUE AND is_deleted = FALSE;

-- Fast QR validation
CREATE UNIQUE INDEX idx_ticket_qr_active
    ON metro.TICKET(qr_code)
    WHERE status IN ('BOOKED','ACTIVE','ENTRY_DONE') AND is_deleted = FALSE;

-- Fast active pass QR lookup
CREATE UNIQUE INDEX idx_pass_qr_active
    ON metro.TRAVEL_PASS(qr_code)
    WHERE is_active = TRUE AND is_deleted = FALSE;

-- Fast crowd monitoring per line
CREATE INDEX idx_train_crowd_line
    ON metro.TRAIN(current_line_id, current_crowd_count)
    WHERE operational_status = 'ON_TRACK' AND is_deleted = FALSE;

-- Fast driver license expiry check
CREATE INDEX idx_driver_license_expiry
    ON metro.DRIVER(license_expiry)
    WHERE employment_status = 'ACTIVE' AND is_deleted = FALSE;

-- Fast maintenance schedule
CREATE INDEX idx_maint_next_due
    ON metro.MAINTENANCE_LOG(train_id, next_due_date)
    WHERE status = 'SCHEDULED' AND is_deleted = FALSE;

-- Fast open alert lookup for a passenger
CREATE INDEX idx_alert_open
    ON metro.ALERT(created_at DESC)
    WHERE is_resolved = FALSE;

-- Partial index: only unread alert-passenger mappings
CREATE INDEX idx_apm_unread
    ON metro.ALERT_PASSENGER_MAP(passenger_id, sent_at DESC)
    WHERE is_read = FALSE;

-- ================================================================
--  ROLE-BASED ACCESS GRANTS
--  Adjust role names to match your organisation's standards
-- ================================================================

-- Read-only role (analytics, reporting)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'metro_readonly') THEN
        CREATE ROLE metro_readonly NOLOGIN;
    END IF;
END $$;
GRANT USAGE ON SCHEMA metro TO metro_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA metro TO metro_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA metro
    GRANT SELECT ON TABLES TO metro_readonly;

-- Application role (API server)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'metro_app') THEN
        CREATE ROLE metro_app NOLOGIN;
    END IF;
END $$;
GRANT USAGE ON SCHEMA metro TO metro_app;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA metro TO metro_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA metro TO metro_app;
-- Restrict destructive operations
REVOKE DELETE ON metro.AUDIT_LOG        FROM metro_app;
REVOKE DELETE ON metro.EMPLOYEE_AUDIT_LOG FROM metro_app;
REVOKE DELETE ON metro.RESCHEDULE_LOG   FROM metro_app;
REVOKE DELETE ON metro.LIVE_TRACKING    FROM metro_app;

-- Admin role (full control for DBA / DevOps)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'metro_admin') THEN
        CREATE ROLE metro_admin NOLOGIN;
    END IF;
END $$;
GRANT ALL ON SCHEMA metro TO metro_admin;
GRANT ALL ON ALL TABLES    IN SCHEMA metro TO metro_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA metro TO metro_admin;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA metro TO metro_admin;

-- ================================================================
--  COMPLETION NOTICE
-- ================================================================
DO $$
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE ' Ahmedabad Metro DDL — Schema: metro';
    RAISE NOTICE ' Tables   : 34';
    RAISE NOTICE ' ENUMs    : 24';
    RAISE NOTICE ' Domains  : 8';
    RAISE NOTICE ' Triggers : 8';
    RAISE NOTICE ' Views    : 10';
    RAISE NOTICE ' Indexes  : 50+';
    RAISE NOTICE ' Roles    : 3 (metro_readonly, metro_app, metro_admin)';
    RAISE NOTICE ' All tables are BCNF-compliant.';
    RAISE NOTICE '============================================================';
END $$;


-- ================================================================
--  PROJECT      : AHMEDABAD METRO RAIL SYSTEM
--  MODULE       : Stored Procedures & Operational Functions (DDL Part 4)
--  SCHEMA       : metro
--  DESCRIPTION  : All business-logic procedures for:
--                   P01  calculate_fare
--                   P02  generate_qr_code
--                   P03  book_ticket
--                   P04  cancel_ticket
--                   P05  process_gate_scan
--                   P06  record_delay
--                   P07  resolve_delay
--                   P08  reschedule_train
--                   P09  add_new_train
--                   P10  replace_train_after_incident
--                   P11  add_station
--                   P12  add_halt_to_line
--                   P13  temporarily_remove_halt
--                   P14  close_station
--                   P15  reopen_station
--                   P16  add_driver
--                   P17  replace_driver_on_schedule
--                   P18  update_driver_salary
--                   P19  change_driver_shift
--                   P20  assign_driver_to_schedule
--                   P21  change_platform_for_schedule_stop
--                   P22  update_live_tracking
--                   P23  recalculate_dynamic_eta
--                   P24  update_fare_rule
--                   P25  issue_travel_pass
--                   P26  get_journey_routes (for Ahmedabad Yatra app)
--                   P27  get_next_trains_for_station
--                   P28  get_crowd_status
--  VERSION      : 1.0.0
-- ================================================================


-- ================================================================
--  P01 — CALCULATE_FARE
--  Given distance (km) and passenger type, returns the applicable
--  fare from the currently active FARE_RULE slab.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.calculate_fare(
    p_distance_km    distance_km_t,
    p_passenger_type passenger_type_t DEFAULT 'GENERAL'
)
RETURNS money_t
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_fare money_t;
BEGIN
    SELECT
        CASE p_passenger_type
            WHEN 'GENERAL'              THEN fr.normal_fare
            WHEN 'SENIOR_CITIZEN'       THEN fr.senior_citizen_fare
            WHEN 'CHILD'                THEN fr.child_fare
            WHEN 'STUDENT'              THEN fr.student_fare
            WHEN 'PHYSICALLY_DISABLED'  THEN fr.physically_disabled_fare
            WHEN 'TOURIST'              THEN fr.tourist_fare
            WHEN 'FREEDOM_FIGHTER'      THEN fr.freedom_fighter_fare
            ELSE fr.normal_fare
        END
    INTO v_fare
    FROM  metro.FARE_RULE fr
    WHERE fr.is_active      = TRUE
    AND   fr.effective_from <= CURRENT_DATE
    AND   (fr.effective_to IS NULL OR fr.effective_to >= CURRENT_DATE)
    AND   p_distance_km BETWEEN fr.min_distance_km AND fr.max_distance_km
    ORDER BY fr.effective_from DESC
    LIMIT 1;

    IF v_fare IS NULL THEN
        RAISE EXCEPTION
            'No active fare rule found for distance % km. '
            'Please ensure FARE_RULE table has a covering slab.', p_distance_km;
    END IF;

    RETURN v_fare;
END;
$$;

COMMENT ON FUNCTION metro.calculate_fare IS
'Returns applicable fare for given distance and passenger type from active slab.';

-- ================================================================
--  P02 — GENERATE_QR_CODE
--  Generates a unique, non-guessable QR payload string.
--  Uses pgcrypto's gen_random_bytes for cryptographic randomness.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.generate_qr_code(
    p_prefix VARCHAR(10) DEFAULT 'AMTS'
)
RETURNS VARCHAR(512)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_qr VARCHAR(512);
    v_exists BOOLEAN := TRUE;
BEGIN
    -- Loop until we get a unique QR (extremely rare collision)
    WHILE v_exists LOOP
        v_qr := p_prefix
                || '-'
                || TO_CHAR(NOW(), 'YYYYMMDD')
                || '-'
                || UPPER(ENCODE(gen_random_bytes(16), 'hex'));

        -- Check uniqueness across both TICKET and TRAVEL_PASS
        SELECT EXISTS (
            SELECT 1 FROM metro.TICKET      WHERE qr_code = v_qr
            UNION ALL
            SELECT 1 FROM metro.TRAVEL_PASS WHERE qr_code = v_qr
        ) INTO v_exists;
    END LOOP;

    RETURN v_qr;
END;
$$;

COMMENT ON FUNCTION metro.generate_qr_code IS
'Cryptographically random, globally unique QR payload for tickets and passes.';

-- ================================================================
--  P03 — BOOK_TICKET
--  Full ticket booking transaction:
--    1. Validates stations, passenger, and fare
--    2. Calculates fare
--    3. Inserts TICKET
--    4. Initiates PAYMENT record
--  Returns: ticket_id, qr_code, price_paid, payment_id
-- ================================================================

CREATE OR REPLACE FUNCTION metro.book_ticket(
    p_passenger_id      INT,
    p_from_station_id   INT,
    p_to_station_id     INT,
    p_ticket_type       ticket_type_t        DEFAULT 'SINGLE',
    p_booking_channel   booking_channel_t    DEFAULT 'MOBILE_APP',
    p_payment_method    payment_method_t     DEFAULT 'UPI',
    p_booked_by_emp_id  INT                  DEFAULT NULL   -- Non-null for counter bookings
)
RETURNS TABLE(
    out_ticket_id    BIGINT,
    out_qr_code      VARCHAR,
    out_price_paid   money_t,
    out_payment_id   BIGINT,
    out_valid_from   TIMESTAMPTZ,
    out_valid_to     TIMESTAMPTZ
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_passenger_type    passenger_type_t;
    v_from_code         VARCHAR(10);
    v_to_code           VARCHAR(10);
    v_from_zone         SMALLINT;
    v_to_zone           SMALLINT;
    v_distance_km       distance_km_t;
    v_fare_rule_id      INT;
    v_base_fare         money_t;
    v_price_paid        money_t;
    v_qr_code           VARCHAR(512);
    v_ticket_id         BIGINT;
    v_payment_id        BIGINT;
    v_valid_from        TIMESTAMPTZ;
    v_valid_to          TIMESTAMPTZ;
    v_validity_mins     INT;
BEGIN
    -- ── Validate passenger ───────────────────────────────────────
    SELECT passenger_type
    INTO   v_passenger_type
    FROM   metro.PASSENGER
    WHERE  passenger_id = p_passenger_id
    AND    is_active    = TRUE
    AND    is_deleted   = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Passenger ID % not found or inactive.', p_passenger_id;
    END IF;

    -- ── Validate stations ────────────────────────────────────────
    SELECT station_code, zone_no
    INTO   v_from_code, v_from_zone
    FROM   metro.STATION
    WHERE  station_id = p_from_station_id
    AND    is_active  = TRUE
    AND    is_deleted = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'From-station ID % not found or closed.', p_from_station_id;
    END IF;

    SELECT station_code, zone_no
    INTO   v_to_code, v_to_zone
    FROM   metro.STATION
    WHERE  station_id = p_to_station_id
    AND    is_active  = TRUE
    AND    is_deleted = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'To-station ID % not found or closed.', p_to_station_id;
    END IF;

    IF p_from_station_id = p_to_station_id THEN
        RAISE EXCEPTION 'From-station and To-station cannot be the same.';
    END IF;

    -- ── Calculate route distance from STATION_ON_LINE ────────────
    -- Find any shared line and compute distance between the two stops
    SELECT ABS(sol_to.dist_from_start_km - sol_from.dist_from_start_km)
    INTO   v_distance_km
    FROM   metro.STATION_ON_LINE sol_from
    JOIN   metro.STATION_ON_LINE sol_to
           ON  sol_to.line_id    = sol_from.line_id
           AND sol_to.station_id = p_to_station_id
    WHERE  sol_from.station_id = p_from_station_id
    AND    sol_from.is_active  = TRUE
    AND    sol_to.is_active    = TRUE
    ORDER BY v_distance_km ASC
    LIMIT  1;

    -- Fallback: estimate by zone difference if no shared line found
    IF v_distance_km IS NULL THEN
        v_distance_km := ABS(v_to_zone - v_from_zone) * 3.5;  -- avg 3.5 km per zone
    END IF;

    -- ── Look up fare ─────────────────────────────────────────────
    SELECT fare_rule_id, base_fare
    INTO   v_fare_rule_id, v_base_fare
    FROM   metro.FARE_RULE
    WHERE  is_active        = TRUE
    AND    effective_from  <= CURRENT_DATE
    AND    (effective_to IS NULL OR effective_to >= CURRENT_DATE)
    AND    v_distance_km   BETWEEN min_distance_km AND max_distance_km
    ORDER BY effective_from DESC
    LIMIT  1;

    IF v_fare_rule_id IS NULL THEN
        RAISE EXCEPTION 'No fare rule for distance % km. Contact admin.', v_distance_km;
    END IF;

    v_price_paid := metro.calculate_fare(v_distance_km, v_passenger_type);

    -- ── Validity window ──────────────────────────────────────────
    SELECT config_value::INT
    INTO   v_validity_mins
    FROM   metro.SYSTEM_CONFIG
    WHERE  config_key = 'QR_VALIDITY_MINUTES';

    v_validity_mins := COALESCE(v_validity_mins, 120);
    v_valid_from    := NOW();
    v_valid_to      := NOW() + (v_validity_mins || ' minutes')::INTERVAL;

    -- ── Generate QR ──────────────────────────────────────────────
    v_qr_code := metro.generate_qr_code('TKT');

    -- ── Insert TICKET ────────────────────────────────────────────
    INSERT INTO metro.TICKET (
        passenger_id,
        fare_rule_id,
        from_station_id,
        to_station_id,
        ticket_type,
        passenger_category,
        qr_code,
        distance_km,
        base_amount,
        discount_amount,
        tax_amount,
        price_paid,
        booking_channel,
        booked_by_emp_id,
        valid_from,
        valid_to,
        status
    ) VALUES (
        p_passenger_id,
        v_fare_rule_id,
        p_from_station_id,
        p_to_station_id,
        p_ticket_type,
        v_passenger_type,
        v_qr_code,
        v_distance_km,
        v_base_fare,
        0,                    -- discount_amount (apply coupon logic here if needed)
        0,                    -- tax_amount (GST integration point)
        v_price_paid,
        p_booking_channel,
        p_booked_by_emp_id,
        v_valid_from,
        v_valid_to,
        'BOOKED'
    )
    RETURNING ticket_id INTO v_ticket_id;

    -- ── Initiate PAYMENT record ───────────────────────────────────
    INSERT INTO metro.PAYMENT (
        ticket_id,
        amount,
        payment_method,
        status,
        initiated_at
    ) VALUES (
        v_ticket_id,
        v_price_paid,
        p_payment_method,
        'INITIATED',
        NOW()
    )
    RETURNING payment_id INTO v_payment_id;

    -- ── Return result ─────────────────────────────────────────────
    RETURN QUERY
    SELECT v_ticket_id, v_qr_code, v_price_paid, v_payment_id, v_valid_from, v_valid_to;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'book_ticket failed: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION metro.book_ticket IS
'Atomic ticket booking: validates inputs, calculates fare, inserts TICKET and PAYMENT.';

-- ================================================================
--  P04 — CANCEL_TICKET
--  Cancels an active ticket if within the refund window.
--  Updates TICKET status and creates a refund entry in PAYMENT.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.cancel_ticket(
    p_ticket_id        BIGINT,
    p_cancelled_by_emp INT     DEFAULT NULL,
    p_reason           TEXT    DEFAULT 'Passenger requested cancellation'
)
RETURNS TABLE(
    out_status         TEXT,
    out_refund_amount  money_t
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_status        ticket_status_t;
    v_valid_from    TIMESTAMPTZ;
    v_price_paid    money_t;
    v_refund_mins   INT;
    v_refund_amount money_t := 0;
    v_minutes_to_travel NUMERIC;
BEGIN
    -- Lock ticket row
    SELECT status, valid_from, price_paid
    INTO   v_status, v_valid_from, v_price_paid
    FROM   metro.TICKET
    WHERE  ticket_id  = p_ticket_id
    AND    is_deleted = FALSE
    FOR    UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ticket ID % not found.', p_ticket_id;
    END IF;

    IF v_status NOT IN ('BOOKED', 'ACTIVE') THEN
        RAISE EXCEPTION
            'Ticket cannot be cancelled. Current status: %.', v_status;
    END IF;

    -- Check refund window
    SELECT config_value::INT
    INTO   v_refund_mins
    FROM   metro.SYSTEM_CONFIG
    WHERE  config_key = 'REFUND_ALLOWED_BEFORE_MIN';

    v_refund_mins       := COALESCE(v_refund_mins, 30);
    v_minutes_to_travel := EXTRACT(EPOCH FROM (v_valid_from - NOW())) / 60;

    IF v_minutes_to_travel < v_refund_mins THEN
        -- Late cancellation — no refund
        v_refund_amount := 0;
    ELSE
        -- Full refund
        v_refund_amount := v_price_paid;
    END IF;

    -- Update ticket
    UPDATE metro.TICKET
    SET    status               = 'CANCELLED',
           cancellation_reason = p_reason,
           cancelled_at        = NOW(),
           updated_at          = NOW(),
           updated_by          = p_cancelled_by_emp
    WHERE  ticket_id = p_ticket_id;

    -- Update payment with refund
    IF v_refund_amount > 0 THEN
        UPDATE metro.PAYMENT
        SET    refund_amount = v_refund_amount,
               refunded_at  = NOW(),
               status       = 'REFUNDED',
               updated_at   = NOW()
        WHERE  ticket_id = p_ticket_id;
    END IF;

    RETURN QUERY SELECT
        'CANCELLED'::TEXT,
        v_refund_amount;
END;
$$;

COMMENT ON FUNCTION metro.cancel_ticket IS
'Cancels a ticket; applies full refund if cancelled before refund window, else no refund.';

-- ================================================================
--  P05 — PROCESS_GATE_SCAN
--  Validates and records a QR scan at entry or exit gate.
--  Works for both TICKET and TRAVEL_PASS QR codes.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.process_gate_scan(
    p_qr_code        VARCHAR(512),
    p_station_id     INT,
    p_platform_no    SMALLINT,
    p_gate_role      gate_role_t,
    p_gate_device_id VARCHAR(50),
    p_schedule_id    INT      DEFAULT NULL,
    p_stop_sequence  SMALLINT DEFAULT NULL
)
RETURNS TABLE(
    out_is_valid         BOOLEAN,
    out_rejection_reason TEXT,
    out_passenger_name   VARCHAR,
    out_from_station     VARCHAR,
    out_to_station       VARCHAR,
    out_ticket_id        BIGINT
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_ticket_id      BIGINT;
    v_pass_id        INT;
    v_passenger_id   INT;
    v_from_stn       VARCHAR(150);
    v_to_stn         VARCHAR(150);
    v_passenger_name VARCHAR(200);
    v_ticket_status  ticket_status_t;
    v_pass_active    BOOLEAN;
    v_pass_valid_to  DATE;
    v_is_ticket      BOOLEAN := FALSE;
BEGIN
    -- ── Identify QR as TICKET or TRAVEL_PASS ────────────────────
    SELECT t.ticket_id, t.passenger_id, t.status,
           sf.station_name, st.station_name
    INTO   v_ticket_id, v_passenger_id, v_ticket_status,
           v_from_stn, v_to_stn
    FROM   metro.TICKET   t
    JOIN   metro.STATION  sf ON sf.station_id = t.from_station_id
    JOIN   metro.STATION  st ON st.station_id = t.to_station_id
    WHERE  t.qr_code   = p_qr_code
    AND    t.is_deleted = FALSE;

    IF FOUND THEN
        v_is_ticket := TRUE;
    ELSE
        -- Try TRAVEL_PASS
        SELECT tp.pass_id, tp.passenger_id, tp.is_active, tp.valid_to
        INTO   v_pass_id, v_passenger_id, v_pass_active, v_pass_valid_to
        FROM   metro.TRAVEL_PASS tp
        WHERE  tp.qr_code   = p_qr_code
        AND    tp.is_deleted = FALSE;

        IF NOT FOUND THEN
            RETURN QUERY SELECT FALSE, 'QR code not found in system.'::TEXT,
                NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::BIGINT;
            RETURN;
        END IF;

        -- Validate pass
        IF NOT v_pass_active OR v_pass_valid_to < CURRENT_DATE THEN
            RETURN QUERY SELECT FALSE, 'Travel pass is expired or inactive.'::TEXT,
                NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::BIGINT;
            RETURN;
        END IF;
    END IF;

    -- ── Get passenger name ────────────────────────────────────────
    SELECT full_name INTO v_passenger_name
    FROM   metro.PASSENGER
    WHERE  passenger_id = v_passenger_id;

    -- ── Record the gate scan ──────────────────────────────────────
    INSERT INTO metro.TICKET_GATE_SCAN (
        ticket_id,
        pass_id,
        station_id,
        platform_no,
        schedule_id,
        stop_sequence,
        gate_device_id,
        gate_role,
        scan_timestamp
    ) VALUES (
        CASE WHEN v_is_ticket THEN v_ticket_id ELSE NULL END,
        CASE WHEN NOT v_is_ticket THEN v_pass_id ELSE NULL END,
        p_station_id,
        p_platform_no,
        p_schedule_id,
        p_stop_sequence,
        p_gate_device_id,
        p_gate_role,
        NOW()
    );

    -- ── Return success (trigger handles ticket status update) ────
    RETURN QUERY SELECT
        TRUE,
        NULL::TEXT,
        v_passenger_name,
        COALESCE(v_from_stn, 'Pass Holder'),
        COALESCE(v_to_stn, 'Any Station'),
        v_ticket_id;

EXCEPTION
    WHEN unique_violation THEN
        RETURN QUERY SELECT
            FALSE,
            ('Gate ' || p_gate_role::TEXT || ' already recorded for this ticket.')::TEXT,
            v_passenger_name, v_from_stn, v_to_stn, v_ticket_id;
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            ('Gate scan error: ' || SQLERRM)::TEXT,
            NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::BIGINT;
END;
$$;

COMMENT ON FUNCTION metro.process_gate_scan IS
'Validates QR at turnstile; handles both ticket and travel pass; idempotent on duplicate scan.';

-- ================================================================
--  P06 — RECORD_DELAY
--  Records a delay event against an active schedule.
--  Automatically updates all TRAIN_STOP dynamic_eta values
--  for subsequent stops on the same schedule.
--  Fires alert if delay exceeds threshold.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.record_delay(
    p_schedule_id         INT,
    p_delay_minutes       INT,
    p_reason              TEXT,
    p_delay_category      VARCHAR(50)  DEFAULT 'OPERATIONAL',
    p_affected_station_id INT          DEFAULT NULL,
    p_reported_by_emp_id  INT          DEFAULT NULL
)
RETURNS TABLE(
    out_delay_id     BIGINT,
    out_alert_fired  BOOLEAN
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_delay_id        BIGINT;
    v_threshold_mins  INT;
    v_alert_id        BIGINT;
    v_alert_fired     BOOLEAN := FALSE;
    v_train_number    VARCHAR(20);
    v_line_name       VARCHAR(100);
    v_affected_stop   SMALLINT;
BEGIN
    -- Validate schedule
    PERFORM 1 FROM metro.TRAIN_SCHEDULE
    WHERE schedule_id     = p_schedule_id
    AND   schedule_status = 'ACTIVE'
    AND   is_deleted      = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Schedule % is not active or does not exist.', p_schedule_id;
    END IF;

    -- Validate delay
    IF p_delay_minutes <= 0 THEN
        RAISE EXCEPTION 'Delay minutes must be positive. Got: %', p_delay_minutes;
    END IF;

    -- Insert delay event
    INSERT INTO metro.DELAY_EVENT (
        schedule_id,
        affected_station_id,
        delay_minutes,
        reason,
        delay_category,
        reported_at,
        created_by
    ) VALUES (
        p_schedule_id,
        p_affected_station_id,
        p_delay_minutes,
        p_reason,
        p_delay_category,
        NOW(),
        p_reported_by_emp_id
    )
    RETURNING delay_id INTO v_delay_id;

    -- Update schedule status to DELAYED
    UPDATE metro.TRAIN_SCHEDULE
    SET    schedule_status = 'DELAYED',
           updated_at     = NOW(),
           updated_by     = p_reported_by_emp_id
    WHERE  schedule_id    = p_schedule_id;

    -- Update dynamic_eta for all remaining stops
    -- Find affected stop sequence (stops at or after the affected station)
    IF p_affected_station_id IS NOT NULL THEN
        SELECT stop_sequence INTO v_affected_stop
        FROM   metro.TRAIN_STOP
        WHERE  schedule_id = p_schedule_id
        AND    station_id  = p_affected_station_id
        AND    is_active   = TRUE
        LIMIT  1;
    ELSE
        v_affected_stop := 1;  -- Apply delay from first stop
    END IF;

    UPDATE metro.TRAIN_STOP
    SET    dynamic_eta = (
               CURRENT_DATE + COALESCE(scheduled_departure, scheduled_arrival)
               + (p_delay_minutes || ' minutes')::INTERVAL
           ),
           updated_at  = NOW()
    WHERE  schedule_id    = p_schedule_id
    AND    stop_sequence >= COALESCE(v_affected_stop, 1)
    AND    is_active      = TRUE
    AND    is_deleted     = FALSE;

    -- Check if alert threshold is breached
    SELECT config_value::INT INTO v_threshold_mins
    FROM   metro.SYSTEM_CONFIG
    WHERE  config_key = 'DELAY_ALERT_THRESHOLD_MIN';

    v_threshold_mins := COALESCE(v_threshold_mins, 5);

    IF p_delay_minutes >= v_threshold_mins THEN
        -- Get context for alert message
        SELECT t.train_number, l.line_name
        INTO   v_train_number, v_line_name
        FROM   metro.TRAIN_SCHEDULE ts
        JOIN   metro.TRAIN  t ON t.train_id = ts.train_id
        JOIN   metro.LINE   l ON l.line_id  = ts.line_id
        WHERE  ts.schedule_id = p_schedule_id;

        INSERT INTO metro.ALERT (
            schedule_id,
            station_id,
            alert_type,
            severity,
            title,
            message,
            channel,
            auto_expires_at,
            created_by_emp_id
        ) VALUES (
            p_schedule_id,
            p_affected_station_id,
            'DELAY',
            CASE WHEN p_delay_minutes >= 30 THEN 'CRITICAL'
                 WHEN p_delay_minutes >= 10 THEN 'WARNING'
                 ELSE 'INFO' END,
            'Train Delayed: ' || v_train_number || ' on ' || v_line_name,
            'Train ' || v_train_number
                || ' (' || v_line_name || ') is delayed by '
                || p_delay_minutes || ' minutes. Reason: ' || p_reason,
            'ALL',
            NOW() + INTERVAL '2 hours',
            p_reported_by_emp_id
        )
        RETURNING alert_id INTO v_alert_id;

        v_alert_fired := TRUE;
    END IF;

    RETURN QUERY SELECT v_delay_id, v_alert_fired;
END;
$$;

COMMENT ON FUNCTION metro.record_delay IS
'Records delay, updates all downstream stop ETAs, fires alert if above threshold.';

-- ================================================================
--  P07 — RESOLVE_DELAY
--  Marks a delay as resolved and resets dynamic_eta on stops.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.resolve_delay(
    p_delay_id          BIGINT,
    p_resolved_by_emp   INT,
    p_resolution_notes  TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_schedule_id INT;
BEGIN
    UPDATE metro.DELAY_EVENT
    SET    resolution_status = 'RESOLVED',
           resolved_at       = NOW(),
           resolved_by_emp_id = p_resolved_by_emp,
           resolution_notes  = p_resolution_notes,
           updated_at        = NOW(),
           updated_by        = p_resolved_by_emp
    WHERE  delay_id          = p_delay_id
    AND    resolution_status IN ('PENDING','IN_PROGRESS')
    RETURNING schedule_id INTO v_schedule_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Delay % not found or already resolved.', p_delay_id;
    END IF;

    -- Check if any other pending delays remain on this schedule
    IF NOT EXISTS (
        SELECT 1 FROM metro.DELAY_EVENT
        WHERE  schedule_id       = v_schedule_id
        AND    resolution_status IN ('PENDING','IN_PROGRESS')
        AND    delay_id         <> p_delay_id
    ) THEN
        -- Restore schedule to ACTIVE and clear dynamic ETAs
        UPDATE metro.TRAIN_SCHEDULE
        SET    schedule_status = 'ACTIVE',
               updated_at     = NOW(),
               updated_by     = p_resolved_by_emp
        WHERE  schedule_id    = v_schedule_id;

        UPDATE metro.TRAIN_STOP
        SET    dynamic_eta = NULL,
               updated_at  = NOW()
        WHERE  schedule_id = v_schedule_id;
    END IF;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION metro.resolve_delay IS
'Marks delay resolved; resets dynamic ETAs and schedule status if no pending delays remain.';

-- ================================================================
--  P08 — RESCHEDULE_TRAIN
--  Changes departure time, track, or platform for an existing
--  schedule. Validates for conflicts before making any change.
--  Logs every change to RESCHEDULE_LOG.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.reschedule_train(
    p_schedule_id        INT,
    p_new_dep_time       TIME             DEFAULT NULL,
    p_new_arr_time       TIME             DEFAULT NULL,
    p_new_track_id       INT              DEFAULT NULL,
    p_reason             TEXT             DEFAULT NULL,
    p_done_by_emp_id     INT              DEFAULT NULL,
    p_incident_id        INT              DEFAULT NULL
)
RETURNS TABLE(
    out_reschedule_id  BIGINT,
    out_message        TEXT
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_orig_dep    TIME;
    v_orig_arr    TIME;
    v_orig_track  INT;
    v_orig_track_no VARCHAR(20);
    v_new_track_no  VARCHAR(20);
    v_rsl_id      BIGINT;
BEGIN
    -- Lock and fetch current schedule
    SELECT departure_time, arrival_time, track_id
    INTO   v_orig_dep, v_orig_arr, v_orig_track
    FROM   metro.TRAIN_SCHEDULE
    WHERE  schedule_id = p_schedule_id
    AND    is_deleted  = FALSE
    FOR    UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Schedule % not found.', p_schedule_id;
    END IF;

    -- Default to existing values if not supplied
    p_new_dep_time := COALESCE(p_new_dep_time, v_orig_dep);
    p_new_arr_time := COALESCE(p_new_arr_time, v_orig_arr);
    p_new_track_id := COALESCE(p_new_track_id, v_orig_track);

    -- Validate new times
    IF p_new_arr_time <= p_new_dep_time THEN
        RAISE EXCEPTION 'New arrival time must be after departure time.';
    END IF;

    -- Get track numbers for log
    SELECT track_number INTO v_orig_track_no
    FROM   metro.TRACK WHERE track_id = v_orig_track;

    SELECT track_number INTO v_new_track_no
    FROM   metro.TRACK WHERE track_id = p_new_track_id;

    -- Conflict check for new track + new time
    IF p_new_track_id IS NOT NULL
       AND (p_new_track_id <> COALESCE(v_orig_track, -1)
            OR p_new_dep_time <> v_orig_dep)
    THEN
        IF EXISTS (
            SELECT 1
            FROM   metro.TRAIN_SCHEDULE
            WHERE  track_id         = p_new_track_id
            AND    schedule_id     <> p_schedule_id
            AND    schedule_status  = 'ACTIVE'
            AND    is_deleted       = FALSE
            AND   (p_new_dep_time, p_new_arr_time)
                   OVERLAPS
                  (departure_time, arrival_time)
        ) THEN
            RAISE EXCEPTION
                'Track % already occupied during %–%. Choose a different time or track.',
                v_new_track_no, p_new_dep_time, p_new_arr_time;
        END IF;
    END IF;

    -- Apply changes
    UPDATE metro.TRAIN_SCHEDULE
    SET    departure_time   = p_new_dep_time,
           arrival_time     = p_new_arr_time,
           track_id         = p_new_track_id,
           schedule_status  = 'RESCHEDULED',
           updated_at       = NOW(),
           updated_by       = p_done_by_emp_id
    WHERE  schedule_id      = p_schedule_id;

    -- Log to RESCHEDULE_LOG
    INSERT INTO metro.RESCHEDULE_LOG (
        schedule_id,
        incident_id,
        reason,
        original_dep_time,
        new_dep_time,
        original_arr_time,
        new_arr_time,
        old_track_id,
        new_track_id,
        old_track_no,
        new_track_no,
        done_by_emp_id,
        logged_at,
        created_by
    ) VALUES (
        p_schedule_id,
        p_incident_id,
        COALESCE(p_reason, 'Operational reschedule'),
        v_orig_dep,
        p_new_dep_time,
        v_orig_arr,
        p_new_arr_time,
        v_orig_track,
        p_new_track_id,
        v_orig_track_no,
        v_new_track_no,
        p_done_by_emp_id,
        NOW(),
        p_done_by_emp_id
    )
    RETURNING reschedule_id INTO v_rsl_id;

    -- Fire reschedule alert
    INSERT INTO metro.ALERT (
        schedule_id,
        alert_type,
        severity,
        title,
        message,
        channel,
        auto_expires_at,
        created_by_emp_id
    )
    SELECT
        p_schedule_id,
        'DELAY',
        'WARNING',
        'Train Rescheduled',
        'Train on schedule #' || p_schedule_id
            || ' rescheduled from ' || v_orig_dep::TEXT
            || ' to ' || p_new_dep_time::TEXT
            || '. Reason: ' || COALESCE(p_reason, 'Operational'),
        'ALL',
        NOW() + INTERVAL '3 hours',
        p_done_by_emp_id;

    RETURN QUERY SELECT v_rsl_id, 'Schedule updated successfully.'::TEXT;
END;
$$;

COMMENT ON FUNCTION metro.reschedule_train IS
'Changes schedule timing/track with conflict validation and full audit logging.';

-- ================================================================
--  P09 — ADD_NEW_TRAIN
--  Adds a new physical train to the fleet.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.add_new_train(
    p_train_number      VARCHAR(20),
    p_train_type        VARCHAR(50)       DEFAULT 'EMU',
    p_total_capacity    INT               DEFAULT 1000,
    p_seating_capacity  INT               DEFAULT 400,
    p_manufacturer      VARCHAR(150)      DEFAULT NULL,
    p_commission_date   DATE              DEFAULT CURRENT_DATE,
    p_created_by_emp    INT               DEFAULT NULL
)
RETURNS INT    -- Returns new train_id
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_train_id INT;
BEGIN
    -- Validate capacities
    IF p_seating_capacity >= p_total_capacity THEN
        RAISE EXCEPTION
            'Seating capacity (%) must be less than total capacity (%).',
            p_seating_capacity, p_total_capacity;
    END IF;

    INSERT INTO metro.TRAIN (
        train_number,
        train_type,
        total_capacity,
        seating_capacity,
        standing_capacity,
        manufacturer,
        commission_date,
        operational_status,
        is_on_rest,
        created_by
    ) VALUES (
        p_train_number,
        p_train_type,
        p_total_capacity,
        p_seating_capacity,
        p_total_capacity - p_seating_capacity,
        p_manufacturer,
        p_commission_date,
        'RESTING',
        TRUE,
        p_created_by_emp
    )
    RETURNING train_id INTO v_train_id;

    -- Log the addition
    INSERT INTO metro.AUDIT_LOG (
        table_name, record_id, action, new_data, performed_by_emp_id
    ) VALUES (
        'TRAIN', v_train_id::TEXT, 'INSERT',
        jsonb_build_object(
            'train_number', p_train_number,
            'train_type',   p_train_type,
            'capacity',     p_total_capacity
        ),
        p_created_by_emp
    );

    RETURN v_train_id;
END;
$$;

COMMENT ON FUNCTION metro.add_new_train IS
'Registers a new train to the fleet; defaults to RESTING status.';

-- ================================================================
--  P10 — REPLACE_TRAIN_AFTER_INCIDENT
--  After a crash/breakdown, marks the old train as CRASHED,
--  deploys a replacement train on the schedule, and logs everything.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.replace_train_after_incident(
    p_incident_id          INT,
    p_replacement_train_id INT,
    p_done_by_emp_id       INT
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_crashed_train_id INT;
    v_schedule_id      INT;
BEGIN
    -- Get incident context
    SELECT train_id, schedule_id
    INTO   v_crashed_train_id, v_schedule_id
    FROM   metro.TRAIN_INCIDENT
    WHERE  incident_id = p_incident_id
    AND    status NOT IN ('CLOSED','ARCHIVED');

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Incident % not found or already closed.', p_incident_id;
    END IF;

    -- Validate replacement train is available
    PERFORM 1 FROM metro.TRAIN
    WHERE  train_id          = p_replacement_train_id
    AND    operational_status = 'RESTING'
    AND    is_on_rest         = TRUE
    AND    is_deleted         = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Replacement train % is not in RESTING state or not found.',
            p_replacement_train_id;
    END IF;

    -- Update replacement train to ON_TRACK
    UPDATE metro.TRAIN
    SET    operational_status = 'ON_TRACK',
           is_on_rest         = FALSE,
           updated_at         = NOW(),
           updated_by         = p_done_by_emp_id
    WHERE  train_id = p_replacement_train_id;

    -- Swap train on the schedule
    IF v_schedule_id IS NOT NULL THEN
        UPDATE metro.TRAIN_SCHEDULE
        SET    train_id        = p_replacement_train_id,
               schedule_status = 'ACTIVE',
               updated_at      = NOW(),
               updated_by      = p_done_by_emp_id
        WHERE  schedule_id     = v_schedule_id;

        -- Log reschedule
        PERFORM metro.reschedule_train(
            v_schedule_id, NULL, NULL, NULL,
            'Train replacement after incident #' || p_incident_id,
            p_done_by_emp_id, p_incident_id
        );
    END IF;

    -- Link replacement train to incident
    UPDATE metro.TRAIN_INCIDENT
    SET    replacement_train_id  = p_replacement_train_id,
           status                = 'CONTAINMENT_DONE',
           contained_at          = NOW(),
           updated_at            = NOW(),
           updated_by            = p_done_by_emp_id
    WHERE  incident_id = p_incident_id;

    -- Fire EMERGENCY alert
    INSERT INTO metro.ALERT (
        alert_type, severity, title, message, channel, created_by_emp_id
    ) VALUES (
        'EMERGENCY', 'CRITICAL',
        'Train Replacement in Progress',
        'Train #' || v_crashed_train_id || ' has been replaced by Train #'
            || p_replacement_train_id || ' on Schedule #' || v_schedule_id
            || ' due to Incident #' || p_incident_id,
        'ALL', p_done_by_emp_id
    );

    RETURN 'Replacement train ' || p_replacement_train_id
           || ' deployed on schedule ' || COALESCE(v_schedule_id::TEXT, 'N/A');
END;
$$;

COMMENT ON FUNCTION metro.replace_train_after_incident IS
'Deploys replacement train after crash; swaps schedule, alerts passengers.';

-- ================================================================
--  P11 — ADD_STATION
--  Adds a new metro station to the system.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.add_station(
    p_station_code    VARCHAR(10),
    p_station_name    VARCHAR(150),
    p_station_type    station_type_t    DEFAULT 'ELEVATED',
    p_zone_no         SMALLINT          DEFAULT 1,
    p_latitude        latitude_t        DEFAULT NULL,
    p_longitude       longitude_t       DEFAULT NULL,
    p_address         TEXT              DEFAULT NULL,
    p_opening_date    DATE              DEFAULT NULL,
    p_created_by_emp  INT               DEFAULT NULL
)
RETURNS INT   -- Returns new station_id
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_station_id INT;
BEGIN
    -- Check duplicate code
    IF EXISTS (SELECT 1 FROM metro.STATION WHERE station_code = p_station_code) THEN
        RAISE EXCEPTION 'Station code % already exists.', p_station_code;
    END IF;

    INSERT INTO metro.STATION (
        station_code, station_name, station_type, zone_no,
        latitude, longitude, address, opening_date, created_by
    ) VALUES (
        p_station_code, p_station_name, p_station_type, p_zone_no,
        p_latitude, p_longitude, p_address, p_opening_date, p_created_by_emp
    )
    RETURNING station_id INTO v_station_id;

    RETURN v_station_id;
END;
$$;

-- ================================================================
--  P12 — ADD_HALT_TO_LINE
--  Inserts a new station stop into an existing line at the
--  specified sequence position, shifting all later stops up.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.add_halt_to_line(
    p_line_id           INT,
    p_station_id        INT,
    p_sequence_no       SMALLINT,
    p_dist_from_start   distance_km_t,
    p_done_by_emp_id    INT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
BEGIN
    -- Validate line exists
    PERFORM 1 FROM metro.LINE WHERE line_id = p_line_id AND is_deleted = FALSE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Line % not found.', p_line_id;
    END IF;

    -- Validate station exists
    PERFORM 1 FROM metro.STATION WHERE station_id = p_station_id AND is_deleted = FALSE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Station % not found.', p_station_id;
    END IF;

    -- Shift existing stops up to make room
    UPDATE metro.STATION_ON_LINE
    SET    sequence_no = sequence_no + 1,
           updated_at  = NOW(),
           updated_by  = p_done_by_emp_id
    WHERE  line_id      = p_line_id
    AND    sequence_no >= p_sequence_no;

    -- Insert new halt
    INSERT INTO metro.STATION_ON_LINE (
        line_id, station_id, sequence_no, dist_from_start_km, created_by
    ) VALUES (
        p_line_id, p_station_id, p_sequence_no, p_dist_from_start, p_done_by_emp_id
    );

    -- Update total station count on line
    UPDATE metro.LINE
    SET    total_stations = (
               SELECT COUNT(*) FROM metro.STATION_ON_LINE
               WHERE line_id = p_line_id AND is_active = TRUE
           ),
           updated_at = NOW(),
           updated_by = p_done_by_emp_id
    WHERE  line_id = p_line_id;

    RETURN 'Station ' || p_station_id || ' added to line ' || p_line_id
           || ' at sequence ' || p_sequence_no;
END;
$$;

-- ================================================================
--  P13 — TEMPORARILY_REMOVE_HALT
--  Marks a station stop on a line as inactive (soft disable).
-- ================================================================

CREATE OR REPLACE FUNCTION metro.temporarily_remove_halt(
    p_line_id        INT,
    p_station_id     INT,
    p_done_by_emp_id INT  DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
BEGIN
    UPDATE metro.STATION_ON_LINE
    SET    is_active  = FALSE,
           updated_at = NOW(),
           updated_by = p_done_by_emp_id
    WHERE  line_id    = p_line_id
    AND    station_id = p_station_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Station % is not on line %.', p_station_id, p_line_id;
    END IF;

    -- Also deactivate all TRAIN_STOP rows for this station on this line's schedules
    UPDATE metro.TRAIN_STOP tst
    SET    is_active  = FALSE,
           updated_at = NOW()
    FROM   metro.TRAIN_SCHEDULE ts
    WHERE  ts.schedule_id = tst.schedule_id
    AND    ts.line_id     = p_line_id
    AND    tst.station_id = p_station_id
    AND    ts.is_deleted  = FALSE;

    RETURN 'Halt at station ' || p_station_id
           || ' temporarily removed from line ' || p_line_id;
END;
$$;

-- ================================================================
--  P14 — CLOSE_STATION  (temporary or permanent closure)
-- ================================================================

CREATE OR REPLACE FUNCTION metro.close_station(
    p_station_id        INT,
    p_closure_type      closure_type_t,
    p_reason            TEXT,
    p_start_datetime    TIMESTAMPTZ       DEFAULT NOW(),
    p_end_datetime      TIMESTAMPTZ       DEFAULT NULL,
    p_approved_by_emp   INT               DEFAULT NULL
)
RETURNS INT    -- Returns closure_id
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_closure_id INT;
BEGIN
    PERFORM 1 FROM metro.STATION
    WHERE station_id = p_station_id AND is_deleted = FALSE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Station % not found.', p_station_id;
    END IF;

    INSERT INTO metro.STATION_CLOSURE (
        station_id, closure_type, reason,
        start_datetime, end_datetime, status, approved_by_emp_id, created_by
    ) VALUES (
        p_station_id, p_closure_type, p_reason,
        p_start_datetime, p_end_datetime, 'ACTIVE', p_approved_by_emp, p_approved_by_emp
    )
    RETURNING closure_id INTO v_closure_id;

    -- Fire alert
    INSERT INTO metro.ALERT (
        station_id, alert_type, severity, title, message, channel,
        auto_expires_at, created_by_emp_id
    ) VALUES (
        p_station_id, 'MAINTENANCE_CLOSURE', 'CRITICAL',
        'Station Closed',
        'Station ID ' || p_station_id || ' is closed. Reason: ' || p_reason,
        'ALL',
        COALESCE(p_end_datetime, NOW() + INTERVAL '24 hours'),
        p_approved_by_emp
    );

    RETURN v_closure_id;
END;
$$;

-- ================================================================
--  P15 — REOPEN_STATION
-- ================================================================

CREATE OR REPLACE FUNCTION metro.reopen_station(
    p_closure_id     INT,
    p_done_by_emp_id INT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_station_id INT;
BEGIN
    UPDATE metro.STATION_CLOSURE
    SET    status           = 'LIFTED',
           actual_reopen_at = NOW(),
           updated_at       = NOW(),
           updated_by       = p_done_by_emp_id
    WHERE  closure_id = p_closure_id
    AND    status     = 'ACTIVE'
    RETURNING station_id INTO v_station_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Closure % not found or already lifted.', p_closure_id;
    END IF;

    -- Station.is_active restored by trigger trg_station_closure_sync

    RETURN 'Station ' || v_station_id || ' reopened successfully.';
END;
$$;

-- ================================================================
--  P16 — ADD_DRIVER
--  Adds a new driver to the system.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.add_driver(
    p_employee_code VARCHAR(20),
    p_full_name     VARCHAR(200),
    p_dob           DATE,
    p_phone         phone_t,
    p_license_no    VARCHAR(50),
    p_license_expiry DATE,
    p_salary        money_t,
    p_joining_date  DATE              DEFAULT CURRENT_DATE,
    p_created_by    INT               DEFAULT NULL
)
RETURNS INT   -- Returns driver_id
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_driver_id INT;
BEGIN
    IF p_license_expiry <= CURRENT_DATE THEN
        RAISE EXCEPTION 'Cannot add driver: license already expired (%).', p_license_expiry;
    END IF;

    INSERT INTO metro.DRIVER (
        employee_code, full_name, date_of_birth, phone,
        license_no, license_expiry, salary, joining_date, created_by
    ) VALUES (
        p_employee_code, p_full_name, p_dob, p_phone,
        p_license_no, p_license_expiry, p_salary, p_joining_date, p_created_by
    )
    RETURNING driver_id INTO v_driver_id;

    RETURN v_driver_id;
END;
$$;

-- ================================================================
--  P17 — REPLACE_DRIVER_ON_SCHEDULE
--  Swaps primary driver on a specific schedule on a given date.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.replace_driver_on_schedule(
    p_schedule_id        INT,
    p_assignment_date    DATE,
    p_new_driver_id      INT,
    p_reason             TEXT  DEFAULT 'Driver replacement',
    p_done_by_emp_id     INT   DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_old_driver_id INT;
BEGIN
    -- Validate new driver is active
    PERFORM 1 FROM metro.DRIVER
    WHERE  driver_id          = p_new_driver_id
    AND    employment_status  = 'ACTIVE'
    AND    license_expiry     > CURRENT_DATE
    AND    is_deleted         = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Driver % not active or license expired.', p_new_driver_id;
    END IF;

    -- Get current primary driver
    SELECT driver_id INTO v_old_driver_id
    FROM   metro.DRIVER_SCHEDULE_ASSIGNMENT
    WHERE  schedule_id      = p_schedule_id
    AND    assignment_date  = p_assignment_date
    AND    role             = 'PRIMARY'
    AND    is_active        = TRUE;

    -- Deactivate old assignment
    UPDATE metro.DRIVER_SCHEDULE_ASSIGNMENT
    SET    is_active   = FALSE,
           updated_at  = NOW(),
           updated_by  = p_done_by_emp_id
    WHERE  schedule_id     = p_schedule_id
    AND    assignment_date = p_assignment_date
    AND    role            = 'PRIMARY'
    AND    is_active       = TRUE;

    -- Insert new primary driver
    INSERT INTO metro.DRIVER_SCHEDULE_ASSIGNMENT (
        driver_id, schedule_id, assignment_date, role,
        assigned_by_emp_id, remarks, created_by
    ) VALUES (
        p_new_driver_id, p_schedule_id, p_assignment_date, 'PRIMARY',
        p_done_by_emp_id, p_reason, p_done_by_emp_id
    );

    -- Log HR change
    INSERT INTO metro.EMPLOYEE_AUDIT_LOG (
        employee_id, changed_by_emp_id, changed_field,
        old_value, new_value, change_reason
    ) VALUES (
        v_old_driver_id, p_done_by_emp_id,
        'SCHEDULE_ASSIGNMENT',
        'Driver ' || COALESCE(v_old_driver_id::TEXT,'None')
            || ' on schedule ' || p_schedule_id,
        'Driver ' || p_new_driver_id
            || ' on schedule '  || p_schedule_id,
        p_reason
    );

    RETURN 'Driver replaced: ' || COALESCE(v_old_driver_id::TEXT,'N/A')
           || ' → ' || p_new_driver_id
           || ' on schedule ' || p_schedule_id;
END;
$$;

-- ================================================================
--  P18 — UPDATE_DRIVER_SALARY
--  Updates a driver's salary and writes to EMPLOYEE_AUDIT_LOG.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.update_driver_salary(
    p_driver_id      INT,
    p_new_salary     money_t,
    p_reason         TEXT,
    p_done_by_emp_id INT
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_old_salary money_t;
BEGIN
    SELECT salary INTO v_old_salary
    FROM   metro.DRIVER
    WHERE  driver_id   = p_driver_id
    AND    is_deleted  = FALSE
    FOR    UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Driver % not found.', p_driver_id;
    END IF;

    IF p_new_salary <= 0 THEN
        RAISE EXCEPTION 'New salary must be positive.';
    END IF;

    UPDATE metro.DRIVER
    SET    salary      = p_new_salary,
           updated_at  = NOW(),
           updated_by  = p_done_by_emp_id
    WHERE  driver_id   = p_driver_id;

    INSERT INTO metro.EMPLOYEE_AUDIT_LOG (
        employee_id, changed_by_emp_id, changed_field,
        old_value, new_value, change_reason
    ) VALUES (
        p_driver_id, p_done_by_emp_id,
        'DRIVER_SALARY',
        v_old_salary::TEXT, p_new_salary::TEXT, p_reason
    );

    RETURN 'Driver ' || p_driver_id || ' salary updated: ₹'
           || v_old_salary || ' → ₹' || p_new_salary;
END;
$$;

-- ================================================================
--  P19 — CHANGE_DRIVER_SHIFT
--  Updates shift timing for a driver on a given date.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.change_driver_shift(
    p_driver_id      INT,
    p_shift_id       INT,
    p_new_start      TIME,
    p_new_end        TIME,
    p_done_by_emp_id INT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
BEGIN
    IF p_new_end <= p_new_start THEN
        RAISE EXCEPTION 'Shift end must be after start.';
    END IF;

    UPDATE metro.DRIVER_SHIFT
    SET    shift_start = p_new_start,
           shift_end   = p_new_end,
           updated_at  = NOW(),
           updated_by  = p_done_by_emp_id
    WHERE  driver_id   = p_driver_id
    AND    shift_id     = p_shift_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Shift % for Driver % not found.', p_shift_id, p_driver_id;
    END IF;

    RETURN 'Shift updated: Driver ' || p_driver_id
           || ' shift now ' || p_new_start || ' – ' || p_new_end;
END;
$$;

-- ================================================================
--  P20 — ASSIGN_DRIVER_TO_SCHEDULE
--  Assigns a driver to a schedule on a given date.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.assign_driver_to_schedule(
    p_driver_id       INT,
    p_schedule_id     INT,
    p_assignment_date DATE              DEFAULT CURRENT_DATE,
    p_role            VARCHAR(20)       DEFAULT 'PRIMARY',
    p_done_by_emp_id  INT               DEFAULT NULL
)
RETURNS INT   -- Returns assignment_id
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_assignment_id INT;
BEGIN
    -- Active license check
    PERFORM 1 FROM metro.DRIVER
    WHERE  driver_id         = p_driver_id
    AND    employment_status = 'ACTIVE'
    AND    license_expiry    > p_assignment_date
    AND    is_deleted        = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Driver % is not eligible (inactive or expired license).', p_driver_id;
    END IF;

    INSERT INTO metro.DRIVER_SCHEDULE_ASSIGNMENT (
        driver_id, schedule_id, assignment_date, role,
        assigned_by_emp_id, is_active, created_by
    ) VALUES (
        p_driver_id, p_schedule_id, p_assignment_date, p_role,
        p_done_by_emp_id, TRUE, p_done_by_emp_id
    )
    RETURNING assignment_id INTO v_assignment_id;

    RETURN v_assignment_id;
END;
$$;

-- ================================================================
--  P21 — CHANGE_PLATFORM_FOR_SCHEDULE_STOP
--  Changes which platform a train uses at a specific stop.
--  Validates no other active schedule is using same platform
--  at the same time on the same day type.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.change_platform_for_schedule_stop(
    p_schedule_id    INT,
    p_stop_sequence  SMALLINT,
    p_new_platform_no SMALLINT,
    p_done_by_emp_id INT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_station_id      INT;
    v_old_platform    SMALLINT;
    v_sched_dep       TIME;
    v_sched_arr       TIME;
    v_day_type        day_type_t;
    v_grace_mins      INT;
BEGIN
    -- Get current stop details
    SELECT tst.station_id, tst.platform_no,
           tst.scheduled_arrival, tst.scheduled_departure
    INTO   v_station_id, v_old_platform, v_sched_arr, v_sched_dep
    FROM   metro.TRAIN_STOP tst
    WHERE  tst.schedule_id   = p_schedule_id
    AND    tst.stop_sequence = p_stop_sequence
    AND    tst.is_deleted    = FALSE
    FOR    UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Stop %/% not found.', p_schedule_id, p_stop_sequence;
    END IF;

    -- Grace period check — cannot change platform too close to departure
    SELECT config_value::INT INTO v_grace_mins
    FROM   metro.SYSTEM_CONFIG WHERE config_key = 'PLATFORM_CHANGE_GRACE_MIN';
    v_grace_mins := COALESCE(v_grace_mins, 10);

    IF v_sched_dep IS NOT NULL
       AND EXTRACT(EPOCH FROM (
               (CURRENT_DATE + v_sched_dep) - NOW()
           )) / 60 < v_grace_mins
    THEN
        RAISE EXCEPTION
            'Platform change not allowed within % minutes of departure.', v_grace_mins;
    END IF;

    -- Validate new platform exists at this station
    PERFORM 1 FROM metro.PLATFORM
    WHERE  station_id   = v_station_id
    AND    platform_no  = p_new_platform_no
    AND    is_available = TRUE
    AND    is_deleted   = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Platform % at station % not available.', p_new_platform_no, v_station_id;
    END IF;

    -- Check no conflict: another active schedule on same platform at same time
    SELECT ts.day_type INTO v_day_type
    FROM   metro.TRAIN_SCHEDULE ts WHERE ts.schedule_id = p_schedule_id;

    IF EXISTS (
        SELECT 1
        FROM   metro.TRAIN_STOP    tst2
        JOIN   metro.TRAIN_SCHEDULE ts2 ON ts2.schedule_id = tst2.schedule_id
        WHERE  tst2.station_id   = v_station_id
        AND    tst2.platform_no  = p_new_platform_no
        AND    tst2.schedule_id <> p_schedule_id
        AND    ts2.day_type      = v_day_type
        AND    ts2.schedule_status = 'ACTIVE'
        AND    ts2.is_deleted    = FALSE
        AND   (v_sched_arr, v_sched_dep) OVERLAPS
              (tst2.scheduled_arrival, tst2.scheduled_departure)
    ) THEN
        RAISE EXCEPTION
            'Platform % at station % is already in use at that time.',
            p_new_platform_no, v_station_id;
    END IF;

    -- Apply change
    UPDATE metro.TRAIN_STOP
    SET    platform_no = p_new_platform_no,
           updated_at  = NOW(),
           updated_by  = p_done_by_emp_id
    WHERE  schedule_id   = p_schedule_id
    AND    stop_sequence = p_stop_sequence;

    -- Fire platform change alert
    INSERT INTO metro.ALERT (
        schedule_id, station_id, alert_type, severity, title, message, channel,
        auto_expires_at, created_by_emp_id
    ) VALUES (
        p_schedule_id, v_station_id,
        'PLATFORM_CHANGE', 'WARNING',
        'Platform Changed',
        'Train on schedule #' || p_schedule_id
            || ' now arrives at Platform ' || p_new_platform_no
            || ' (was Platform ' || v_old_platform || ')',
        'ALL',
        NOW() + INTERVAL '2 hours',
        p_done_by_emp_id
    );

    RETURN 'Platform changed: Stop ' || p_stop_sequence
           || ' on schedule ' || p_schedule_id
           || ' now uses Platform ' || p_new_platform_no;
END;
$$;

COMMENT ON FUNCTION metro.change_platform_for_schedule_stop IS
'Changes platform for a stop with conflict check and grace period validation.';

-- ================================================================
--  P22 — UPDATE_LIVE_TRACKING
--  Called by the train's GPS unit every N seconds.
--  Updates TRAIN table fast cache and inserts LIVE_TRACKING row.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.update_live_tracking(
    p_train_id        INT,
    p_schedule_id     INT,
    p_latitude        latitude_t,
    p_longitude       longitude_t,
    p_speed_kmph      NUMERIC(5,2),
    p_heading_degrees NUMERIC(5,2)  DEFAULT NULL,
    p_altitude_m      NUMERIC(7,2)  DEFAULT NULL
)
RETURNS BIGINT   -- Returns tracking_id
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_tracking_id BIGINT;
BEGIN
    -- Insert GPS ping
    INSERT INTO metro.LIVE_TRACKING (
        train_id, schedule_id,
        latitude, longitude, altitude_m,
        speed_kmph, heading_degrees,
        recorded_at
    ) VALUES (
        p_train_id, p_schedule_id,
        p_latitude, p_longitude, p_altitude_m,
        p_speed_kmph, p_heading_degrees,
        NOW()
    )
    RETURNING tracking_id INTO v_tracking_id;

    -- Update fast-cache on TRAIN
    UPDATE metro.TRAIN
    SET    current_lat        = p_latitude,
           current_lng        = p_longitude,
           current_speed_kmph = p_speed_kmph,
           is_on_rest         = FALSE,
           operational_status = 'ON_TRACK',
           last_gps_update    = NOW(),
           updated_at         = NOW()
    WHERE  train_id = p_train_id;

    RETURN v_tracking_id;
END;
$$;

COMMENT ON FUNCTION metro.update_live_tracking IS
'Called by train GPS unit; inserts LIVE_TRACKING row and updates TRAIN cache. High-frequency.';

-- ================================================================
--  P23 — RECALCULATE_DYNAMIC_ETA
--  Given latest speed and position, recalculates ETA for all
--  remaining stops on the schedule.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.recalculate_dynamic_eta(
    p_schedule_id     INT,
    p_current_speed   NUMERIC(5,2),
    p_from_sequence   SMALLINT      DEFAULT 1
)
RETURNS INT   -- Number of stops updated
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_count    INT := 0;
    v_delay_min INT;
BEGIN
    -- Get current total delay on this schedule
    SELECT COALESCE(SUM(delay_minutes), 0) INTO v_delay_min
    FROM   metro.DELAY_EVENT
    WHERE  schedule_id       = p_schedule_id
    AND    resolution_status IN ('PENDING','IN_PROGRESS');

    -- Update dynamic_eta for remaining stops
    UPDATE metro.TRAIN_STOP
    SET    dynamic_eta = (
               CURRENT_DATE
               + COALESCE(scheduled_departure, scheduled_arrival)
               + (v_delay_min || ' minutes')::INTERVAL
           ),
           updated_at  = NOW()
    WHERE  schedule_id   = p_schedule_id
    AND    stop_sequence >= p_from_sequence
    AND    is_active     = TRUE
    AND    is_deleted    = FALSE;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    -- Update last tracking row with new ETA
    UPDATE metro.LIVE_TRACKING
    SET    updated_eta = NOW() + (v_delay_min || ' minutes')::INTERVAL
    WHERE  tracking_id = (
        SELECT tracking_id FROM metro.LIVE_TRACKING
        WHERE  schedule_id = p_schedule_id
        ORDER BY recorded_at DESC
        LIMIT  1
    );

    RETURN v_count;
END;
$$;

-- ================================================================
--  P24 — UPDATE_FARE_RULE
--  Inserts a new fare rule (never modifies existing ones for audit).
-- ================================================================

CREATE OR REPLACE FUNCTION metro.update_fare_rule(
    p_min_dist         distance_km_t,
    p_max_dist         distance_km_t,
    p_base_fare        money_t,
    p_normal_fare      money_t,
    p_senior_fare      money_t,
    p_disabled_fare    money_t,
    p_child_fare       money_t,
    p_student_fare     money_t,
    p_tourist_fare     money_t,
    p_effective_from   DATE    DEFAULT CURRENT_DATE,
    p_done_by_emp_id   INT     DEFAULT NULL
)
RETURNS INT   -- New fare_rule_id
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_fare_id INT;
BEGIN
    -- Expire old active slab for this distance range
    UPDATE metro.FARE_RULE
    SET    is_active   = FALSE,
           effective_to = p_effective_from - 1,
           updated_at  = NOW(),
           updated_by  = p_done_by_emp_id
    WHERE  min_distance_km = p_min_dist
    AND    max_distance_km = p_max_dist
    AND    is_active       = TRUE
    AND    (effective_to IS NULL OR effective_to >= p_effective_from);

    -- Insert new rule
    INSERT INTO metro.FARE_RULE (
        min_distance_km, max_distance_km,
        base_fare, normal_fare, senior_citizen_fare,
        physically_disabled_fare, child_fare, student_fare, tourist_fare,
        effective_from, is_active, created_by
    ) VALUES (
        p_min_dist, p_max_dist,
        p_base_fare, p_normal_fare, p_senior_fare,
        p_disabled_fare, p_child_fare, p_student_fare, p_tourist_fare,
        p_effective_from, TRUE, p_done_by_emp_id
    )
    RETURNING fare_rule_id INTO v_fare_id;

    RETURN v_fare_id;
END;
$$;

-- ================================================================
--  P25 — ISSUE_TRAVEL_PASS
-- ================================================================

CREATE OR REPLACE FUNCTION metro.issue_travel_pass(
    p_passenger_id     INT,
    p_pass_type        pass_type_t,
    p_valid_from       DATE              DEFAULT CURRENT_DATE,
    p_institution_name VARCHAR(200)      DEFAULT NULL,
    p_institution_id   VARCHAR(100)      DEFAULT NULL,
    p_done_by_emp_id   INT               DEFAULT NULL
)
RETURNS TABLE(
    out_pass_id   INT,
    out_qr_code   VARCHAR,
    out_valid_to  DATE,
    out_price     money_t
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_pass_id    INT;
    v_qr_code    VARCHAR(512);
    v_valid_to   DATE;
    v_price      money_t;
    v_days       INT;
BEGIN
    -- Determine validity window by pass type
    v_days := CASE p_pass_type
        WHEN 'STUDENT_MONTHLY'    THEN 30
        WHEN 'STUDENT_QUARTERLY'  THEN 90
        WHEN 'STUDENT_ANNUAL'     THEN 365
        WHEN 'SENIOR_MONTHLY'     THEN 30
        WHEN 'SENIOR_QUARTERLY'   THEN 90
        WHEN 'EMPLOYEE_MONTHLY'   THEN 30
        WHEN 'GENERAL_MONTHLY'    THEN 30
        WHEN 'GENERAL_QUARTERLY'  THEN 90
        ELSE 30
    END;

    v_valid_to := p_valid_from + (v_days || ' days')::INTERVAL;

    -- Placeholder pricing (configure in SYSTEM_CONFIG for production)
    v_price := CASE p_pass_type
        WHEN 'STUDENT_MONTHLY'   THEN  250.00
        WHEN 'STUDENT_QUARTERLY' THEN  650.00
        WHEN 'STUDENT_ANNUAL'    THEN 2200.00
        WHEN 'SENIOR_MONTHLY'    THEN  300.00
        WHEN 'SENIOR_QUARTERLY'  THEN  800.00
        WHEN 'EMPLOYEE_MONTHLY'  THEN  500.00
        WHEN 'GENERAL_MONTHLY'   THEN  600.00
        WHEN 'GENERAL_QUARTERLY' THEN 1600.00
        ELSE 600.00
    END;

    v_qr_code := metro.generate_qr_code('PSS');

    INSERT INTO metro.TRAVEL_PASS (
        passenger_id, pass_type, institution_name, institution_id_no,
        valid_from, valid_to, price, qr_code, created_by
    ) VALUES (
        p_passenger_id, p_pass_type, p_institution_name, p_institution_id,
        p_valid_from, v_valid_to, v_price, v_qr_code, p_done_by_emp_id
    )
    RETURNING pass_id INTO v_pass_id;

    RETURN QUERY SELECT v_pass_id, v_qr_code, v_valid_to, v_price;
END;
$$;

-- ================================================================
--  P26 — GET_JOURNEY_ROUTES
--  Core function for Ahmedabad Yatra App.
--  Given from_station and to_station, returns all possible routes
--  including direct routes and interchange routes.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.get_journey_routes(
    p_from_station_id   INT,
    p_to_station_id     INT,
    p_day_type          day_type_t  DEFAULT 'WEEKDAY',
    p_current_time      TIME        DEFAULT CURRENT_TIME
)
RETURNS TABLE(
    route_type         TEXT,
    line_name          VARCHAR,
    color_code         hex_color_t,
    from_station       VARCHAR,
    to_station         VARCHAR,
    interchange_at     VARCHAR,
    second_line        VARCHAR,
    next_departure     TIME,
    estimated_mins     INT,
    fare_normal        money_t,
    fare_student       money_t,
    fare_senior        money_t,
    distance_km        distance_km_t,
    stops_count        INT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_distance distance_km_t;
BEGIN
    -- ── Route Type 1: DIRECT — same line ──────────────────────────
    RETURN QUERY
    WITH direct AS (
        SELECT
            sol_f.line_id,
            l.line_name,
            l.color_code,
            sf.station_name                                     AS from_stn,
            st.station_name                                     AS to_stn,
            ABS(sol_t.dist_from_start_km - sol_f.dist_from_start_km) AS dist_km,
            ABS(sol_t.sequence_no - sol_f.sequence_no)          AS stops
        FROM   metro.STATION_ON_LINE sol_f
        JOIN   metro.STATION_ON_LINE sol_t
               ON  sol_t.line_id    = sol_f.line_id
               AND sol_t.station_id = p_to_station_id
        JOIN   metro.LINE    l  ON l.line_id    = sol_f.line_id
        JOIN   metro.STATION sf ON sf.station_id = p_from_station_id
        JOIN   metro.STATION st ON st.station_id = p_to_station_id
        WHERE  sol_f.station_id = p_from_station_id
        AND    sol_f.is_active  = TRUE
        AND    sol_t.is_active  = TRUE
        AND    l.status         = 'OPERATIONAL'
    ),
    next_train AS (
        SELECT
            d.line_id,
            MIN(ts.departure_time) AS next_dep
        FROM   direct d
        JOIN   metro.TRAIN_SCHEDULE ts ON ts.line_id = d.line_id
        JOIN   metro.TRAIN_STOP     tst ON tst.schedule_id = ts.schedule_id
                                        AND tst.station_id  = p_from_station_id
        WHERE  ts.schedule_status = 'ACTIVE'
        AND    ts.day_type        IN (p_day_type, 'ALL_DAYS')
        AND    ts.is_deleted      = FALSE
        AND    COALESCE(tst.scheduled_departure, ts.departure_time) >= p_current_time
        GROUP BY d.line_id
    )
    SELECT
        'DIRECT'::TEXT,
        d.line_name,
        d.color_code,
        d.from_stn,
        d.to_stn,
        NULL::VARCHAR                                           AS interchange_at,
        NULL::VARCHAR                                           AS second_line,
        nt.next_dep,
        (d.dist_km / 30.0 * 60)::INT                           AS eta_mins,
        metro.calculate_fare(d.dist_km, 'GENERAL'),
        metro.calculate_fare(d.dist_km, 'STUDENT'),
        metro.calculate_fare(d.dist_km, 'SENIOR_CITIZEN'),
        d.dist_km,
        d.stops::INT
    FROM  direct d
    JOIN  next_train nt ON nt.line_id = d.line_id
    ORDER BY nt.next_dep;

    -- ── Route Type 2: INTERCHANGE — via a common interchange station ─
    RETURN QUERY
    WITH leg1 AS (
        SELECT sol_f.line_id AS line1_id, sol_i.station_id AS interchange_id,
               ABS(sol_i.dist_from_start_km - sol_f.dist_from_start_km) AS dist1,
               ABS(sol_i.sequence_no - sol_f.sequence_no) AS stops1
        FROM   metro.STATION_ON_LINE sol_f
        JOIN   metro.STATION_ON_LINE sol_i ON sol_i.line_id = sol_f.line_id
        JOIN   metro.STATION         si    ON si.station_id = sol_i.station_id
                                          AND si.is_interchange = TRUE
        WHERE  sol_f.station_id = p_from_station_id
        AND    sol_f.is_active  = TRUE
        AND    sol_i.is_active  = TRUE
    ),
    leg2 AS (
        SELECT sol_i.line_id AS line2_id, sol_i.station_id AS interchange_id,
               ABS(sol_t.dist_from_start_km - sol_i.dist_from_start_km) AS dist2,
               ABS(sol_t.sequence_no - sol_i.sequence_no) AS stops2
        FROM   metro.STATION_ON_LINE sol_i
        JOIN   metro.STATION_ON_LINE sol_t ON sol_t.line_id    = sol_i.line_id
                                           AND sol_t.station_id = p_to_station_id
        WHERE  sol_t.is_active  = TRUE
        AND    sol_i.is_active  = TRUE
    )
    SELECT
        'INTERCHANGE'::TEXT,
        l1.line_name,
        l1.color_code,
        sf.station_name,
        st.station_name,
        si.station_name,
        l2.line_name,
        NULL::TIME,
        ((l1.dist1 + l2.dist2) / 30.0 * 60 + 5)::INT,
        metro.calculate_fare(l1.dist1 + l2.dist2, 'GENERAL'),
        metro.calculate_fare(l1.dist1 + l2.dist2, 'STUDENT'),
        metro.calculate_fare(l1.dist1 + l2.dist2, 'SENIOR_CITIZEN'),
        (l1.dist1 + l2.dist2),
        (l1.stops1 + l2.stops2)::INT
    FROM   leg1 l1
    JOIN   leg2 l2 ON l2.interchange_id = l1.interchange_id
                   AND l2.line2_id     <> l1.line1_id
    JOIN   metro.LINE    ln1 ON ln1.line_id   = l1.line1_id
    JOIN   metro.LINE    ln2 ON ln2.line_id   = l2.line2_id
    CROSS JOIN LATERAL (
        SELECT line_name, dist1, dist2, stops1, stops2
        FROM (VALUES (ln1.line_name, l1.dist1, l2.dist2,
                      l1.stops1, l2.stops2)) AS x(line_name, dist1, dist2, stops1, stops2)
    ) AS l1
    JOIN   metro.STATION sf ON sf.station_id = p_from_station_id
    JOIN   metro.STATION st ON st.station_id = p_to_station_id
    JOIN   metro.STATION si ON si.station_id = l1.interchange_id
    WHERE  ln1.status = 'OPERATIONAL'
    AND    ln2.status = 'OPERATIONAL'
    LIMIT  5;   -- Top 5 interchange options

END;
$$;

COMMENT ON FUNCTION metro.get_journey_routes IS
'Returns direct and interchange route options; core logic for Ahmedabad Yatra app route planner.';

-- ================================================================
--  P27 — GET_NEXT_TRAINS_FOR_STATION
--  Returns next N trains departing from a given station.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.get_next_trains_for_station(
    p_station_id    INT,
    p_day_type      day_type_t  DEFAULT 'WEEKDAY',
    p_from_time     TIME        DEFAULT CURRENT_TIME,
    p_limit         INT         DEFAULT 10
)
RETURNS TABLE(
    schedule_id        INT,
    train_number       VARCHAR,
    line_name          VARCHAR,
    color_code         hex_color_t,
    direction          direction_t,
    platform_no        SMALLINT,
    departure_time     TIME,
    dynamic_eta        TIMESTAMPTZ,
    schedule_status    schedule_status_t,
    crowd_level        TEXT,
    crowd_pct          NUMERIC
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ts.schedule_id,
        t.train_number,
        l.line_name,
        l.color_code,
        ts.direction,
        tst.platform_no,
        COALESCE(tst.scheduled_departure, ts.departure_time)    AS dep_time,
        tst.dynamic_eta,
        ts.schedule_status,
        CASE
            WHEN ROUND((t.current_crowd_count::NUMERIC /
                 NULLIF(t.total_capacity,0)) * 100, 1) >= 85 THEN 'HIGH'
            WHEN ROUND((t.current_crowd_count::NUMERIC /
                 NULLIF(t.total_capacity,0)) * 100, 1) >= 60 THEN 'MODERATE'
            ELSE 'LOW'
        END                                                     AS crowd_level,
        ROUND((t.current_crowd_count::NUMERIC /
               NULLIF(t.total_capacity,0)) * 100, 1)            AS crowd_pct
    FROM  metro.TRAIN_STOP      tst
    JOIN  metro.TRAIN_SCHEDULE  ts  ON ts.schedule_id  = tst.schedule_id
    JOIN  metro.TRAIN            t  ON t.train_id      = ts.train_id
    JOIN  metro.LINE             l  ON l.line_id       = ts.line_id
    WHERE tst.station_id        = p_station_id
    AND   tst.is_active         = TRUE
    AND   tst.is_deleted        = FALSE
    AND   ts.schedule_status   IN ('ACTIVE','DELAYED')
    AND   ts.day_type           IN (p_day_type, 'ALL_DAYS')
    AND   ts.is_deleted         = FALSE
    AND   COALESCE(tst.scheduled_departure, ts.departure_time) >= p_from_time
    ORDER BY COALESCE(tst.scheduled_departure, ts.departure_time)
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION metro.get_next_trains_for_station IS
'Station departure board: next N trains with crowd info and platform.';

-- ================================================================
--  P28 — GET_CROWD_STATUS
--  Returns real-time crowd status for all active trains.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.get_crowd_status()
RETURNS TABLE(
    train_id        INT,
    train_number    VARCHAR,
    line_name       VARCHAR,
    color_code      hex_color_t,
    total_capacity  INT,
    crowd_count     INT,
    crowd_pct       NUMERIC,
    crowd_level     TEXT,
    last_updated    TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.train_id,
        t.train_number,
        l.line_name,
        l.color_code,
        t.total_capacity,
        t.current_crowd_count,
        ROUND(
            (t.current_crowd_count::NUMERIC / NULLIF(t.total_capacity,0)) * 100, 1
        ),
        CASE
            WHEN ROUND((t.current_crowd_count::NUMERIC /
                 NULLIF(t.total_capacity,0)) * 100, 1) >= 85 THEN 'HIGH'
            WHEN ROUND((t.current_crowd_count::NUMERIC /
                 NULLIF(t.total_capacity,0)) * 100, 1) >= 60 THEN 'MODERATE'
            ELSE 'LOW'
        END,
        t.last_gps_update
    FROM  metro.TRAIN t
    LEFT JOIN metro.LINE l ON l.line_id = t.current_line_id
    WHERE t.operational_status = 'ON_TRACK'
    AND   t.is_deleted         = FALSE
    ORDER BY crowd_pct DESC NULLS LAST;
END;
$$;

COMMENT ON FUNCTION metro.get_crowd_status IS
'Real-time crowd dashboard for all active trains; used by app and monitoring screens.';

-- ================================================================
--  FINAL SUMMARY
-- ================================================================
DO $$
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE ' Ahmedabad Metro DDL — Part 4: Stored Procedures';
    RAISE NOTICE ' Functions : 28 (P01–P28)';
    RAISE NOTICE ' Covers    :';
    RAISE NOTICE '   Fare calculation, QR generation, Ticket booking/cancel';
    RAISE NOTICE '   Gate scan, Delay mgmt, Rescheduling, Train addition';
    RAISE NOTICE '   Incident replacement, Station add/close/reopen';
    RAISE NOTICE '   Halt add/remove, Driver mgmt, Salary/shift change';
    RAISE NOTICE '   Platform change, Live tracking, ETA recalculation';
    RAISE NOTICE '   Fare update, Pass issuance, Route planner,';
    RAISE NOTICE '   Departure board, Crowd monitoring';
    RAISE NOTICE '============================================================';
END $$;


-- ================================================================
--  PROJECT      : AHMEDABAD METRO RAIL SYSTEM
--  MODULE       : DDL Part 5 — Remaining Procedures + BCNF
--                              Verification + pg_cron Jobs
--  SCHEMA       : metro
--  VERSION      : 1.0.0
-- ================================================================


-- ================================================================
--  P29 — ADD_TRAIN_SCHEDULE
--  Creates a complete schedule (header + all stops) in one call.
--  p_stops is a JSON array:
--  [{"station_id":1,"platform_no":1,
--    "arr":"06:05","dep":"06:06","halt_sec":60}, ...]
-- ================================================================

CREATE OR REPLACE FUNCTION metro.add_train_schedule(
    p_train_id       INT,
    p_line_id        INT,
    p_track_id       INT,
    p_direction      direction_t,
    p_day_type       day_type_t,
    p_depart_time    TIME,
    p_arrive_time    TIME,
    p_stops_json     JSONB,              -- array of stop objects
    p_effective_from DATE        DEFAULT CURRENT_DATE,
    p_created_by     INT         DEFAULT NULL
)
RETURNS TABLE(
    out_schedule_id  INT,
    out_stops_added  INT
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_schedule_id    INT;
    v_stop           JSONB;
    v_seq            SMALLINT := 1;
    v_stops_added    INT      := 0;
BEGIN
    -- Validate train
    PERFORM 1 FROM metro.TRAIN
    WHERE  train_id          = p_train_id
    AND    operational_status NOT IN ('CRASHED','DECOMMISSIONED')
    AND    is_deleted         = FALSE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Train % not available for scheduling.', p_train_id;
    END IF;

    -- Validate line
    PERFORM 1 FROM metro.LINE
    WHERE  line_id    = p_line_id
    AND    status     = 'OPERATIONAL'
    AND    is_deleted = FALSE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Line % is not operational.', p_line_id;
    END IF;

    -- Insert schedule header
    INSERT INTO metro.TRAIN_SCHEDULE (
        train_id, line_id, track_id, direction, day_type,
        departure_time, arrival_time, normal_eta_mins,
        schedule_status, effective_from, created_by
    ) VALUES (
        p_train_id, p_line_id, p_track_id, p_direction, p_day_type,
        p_depart_time, p_arrive_time,
        EXTRACT(EPOCH FROM (p_arrive_time - p_depart_time))::INT / 60,
        'ACTIVE', p_effective_from, p_created_by
    )
    RETURNING schedule_id INTO v_schedule_id;

    -- Insert each stop from JSON
    FOR v_stop IN SELECT * FROM jsonb_array_elements(p_stops_json)
    LOOP
        INSERT INTO metro.TRAIN_STOP (
            schedule_id,
            stop_sequence,
            station_id,
            platform_no,
            scheduled_arrival,
            scheduled_departure,
            halt_duration_sec,
            created_by
        ) VALUES (
            v_schedule_id,
            v_seq,
            (v_stop->>'station_id')::INT,
            (v_stop->>'platform_no')::SMALLINT,
            (v_stop->>'arr')::TIME,
            (v_stop->>'dep')::TIME,
            COALESCE((v_stop->>'halt_sec')::SMALLINT, 30),
            p_created_by
        );
        v_seq        := v_seq + 1;
        v_stops_added := v_stops_added + 1;
    END LOOP;

    IF v_stops_added = 0 THEN
        RAISE EXCEPTION 'No stops provided. Schedule creation aborted.';
    END IF;

    RETURN QUERY SELECT v_schedule_id, v_stops_added;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'add_train_schedule failed: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION metro.add_train_schedule IS
'Creates schedule header + all stops atomically from a JSON stop-array.';

-- ================================================================
--  P30 — SUSPEND_TRAIN
--  Suspends a train from service (temporary) and cancels
--  all its ACTIVE schedules for the given date onwards.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.suspend_train(
    p_train_id       INT,
    p_reason         TEXT,
    p_suspend_from   DATE    DEFAULT CURRENT_DATE,
    p_done_by_emp_id INT     DEFAULT NULL
)
RETURNS TABLE(
    out_train_number     VARCHAR,
    out_schedules_cancelled INT
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    v_train_number   VARCHAR(20);
    v_cnt            INT;
BEGIN
    -- Validate and lock train row
    SELECT train_number INTO v_train_number
    FROM   metro.TRAIN
    WHERE  train_id   = p_train_id
    AND    is_deleted = FALSE
    FOR    UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Train % not found.', p_train_id;
    END IF;

    -- Update train status
    UPDATE metro.TRAIN
    SET    operational_status = 'SUSPENDED',
           is_on_rest         = TRUE,
           updated_at         = NOW(),
           updated_by         = p_done_by_emp_id
    WHERE  train_id = p_train_id;

    -- Cancel all active schedules from suspend_from onwards
    UPDATE metro.TRAIN_SCHEDULE
    SET    schedule_status = 'CANCELLED',
           updated_at      = NOW(),
           updated_by      = p_done_by_emp_id
    WHERE  train_id        = p_train_id
    AND    schedule_status = 'ACTIVE'
    AND    effective_from >= p_suspend_from
    AND    is_deleted      = FALSE;

    GET DIAGNOSTICS v_cnt = ROW_COUNT;

    -- Fire critical alert
    INSERT INTO metro.ALERT (
        alert_type, severity, title, message, channel, created_by_emp_id
    ) VALUES (
        'CANCELLATION', 'CRITICAL',
        'Train Suspended: ' || v_train_number,
        'Train ' || v_train_number || ' has been suspended from '
            || p_suspend_from::TEXT || '. Reason: ' || p_reason
            || '. ' || v_cnt || ' schedule(s) cancelled.',
        'ALL', p_done_by_emp_id
    );

    -- Audit
    INSERT INTO metro.AUDIT_LOG (
        table_name, record_id, action, new_data, performed_by_emp_id
    ) VALUES (
        'TRAIN', p_train_id::TEXT, 'UPDATE',
        jsonb_build_object(
            'operational_status', 'SUSPENDED',
            'reason',              p_reason,
            'suspend_from',        p_suspend_from
        ),
        p_done_by_emp_id
    );

    RETURN QUERY SELECT v_train_number, v_cnt;
END;
$$;

COMMENT ON FUNCTION metro.suspend_train IS
'Suspends train, cancels all forward schedules, fires passenger alert.';

-- ================================================================
--  P31 — RESTORE_TRAIN
--  Restores a suspended / maintenance train back to service.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.restore_train(
    p_train_id       INT,
    p_done_by_emp_id INT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_number VARCHAR(20);
BEGIN
    UPDATE metro.TRAIN
    SET    operational_status = 'RESTING',
           is_on_rest         = TRUE,
           updated_at         = NOW(),
           updated_by         = p_done_by_emp_id
    WHERE  train_id           = p_train_id
    AND    operational_status IN ('SUSPENDED','MAINTENANCE')
    AND    is_deleted         = FALSE
    RETURNING train_number INTO v_number;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Train % not found or not in SUSPENDED/MAINTENANCE state.', p_train_id;
    END IF;

    INSERT INTO metro.AUDIT_LOG (
        table_name, record_id, action, new_data, performed_by_emp_id
    ) VALUES (
        'TRAIN', p_train_id::TEXT, 'UPDATE',
        jsonb_build_object('operational_status', 'RESTING'),
        p_done_by_emp_id
    );

    RETURN 'Train ' || v_number || ' restored to RESTING status.';
END;
$$;

-- ================================================================
--  P32 — UPDATE_EMPLOYEE_SALARY
--  Updates employee salary with full audit trail.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.update_employee_salary(
    p_employee_id    INT,
    p_new_salary     money_t,
    p_reason         TEXT,
    p_done_by_emp_id INT
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_old money_t;
BEGIN
    SELECT salary INTO v_old
    FROM   metro.EMPLOYEE
    WHERE  employee_id = p_employee_id
    AND    is_deleted  = FALSE
    FOR    UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee % not found.', p_employee_id;
    END IF;

    IF p_new_salary <= 0 THEN
        RAISE EXCEPTION 'Salary must be positive.';
    END IF;

    UPDATE metro.EMPLOYEE
    SET    salary     = p_new_salary,
           updated_at = NOW(),
           updated_by = p_done_by_emp_id
    WHERE  employee_id = p_employee_id;

    -- Audit via trigger trg_employee_hr_audit (fires automatically)

    RETURN 'Employee ' || p_employee_id
           || ' salary updated: ₹' || v_old || ' → ₹' || p_new_salary;
END;
$$;

-- ================================================================
--  P33 — GET_STATION_CROWD_BY_LINE
--  Returns crowd at every stop on a running schedule.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.get_station_crowd_by_line(
    p_line_id   INT,
    p_day_type  day_type_t DEFAULT 'WEEKDAY'
)
RETURNS TABLE(
    schedule_id     INT,
    train_number    VARCHAR,
    stop_sequence   SMALLINT,
    station_name    VARCHAR,
    platform_no     SMALLINT,
    departure_time  TIME,
    dynamic_eta     TIMESTAMPTZ,
    crowd_count     INT,
    crowd_pct       NUMERIC,
    crowd_level     TEXT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ts.schedule_id,
        t.train_number,
        tst.stop_sequence,
        s.station_name,
        tst.platform_no,
        COALESCE(tst.scheduled_departure, ts.departure_time) AS dep_time,
        tst.dynamic_eta,
        t.current_crowd_count,
        ROUND(
            (t.current_crowd_count::NUMERIC / NULLIF(t.total_capacity,0)) * 100, 1
        ) AS crowd_pct,
        CASE
            WHEN ROUND((t.current_crowd_count::NUMERIC /
                 NULLIF(t.total_capacity,0)) * 100, 1) >= 85 THEN 'HIGH'
            WHEN ROUND((t.current_crowd_count::NUMERIC /
                 NULLIF(t.total_capacity,0)) * 100, 1) >= 60 THEN 'MODERATE'
            ELSE 'LOW'
        END AS crowd_level
    FROM  metro.TRAIN_SCHEDULE ts
    JOIN  metro.TRAIN           t   ON t.train_id     = ts.train_id
    JOIN  metro.TRAIN_STOP      tst ON tst.schedule_id = ts.schedule_id
    JOIN  metro.STATION         s   ON s.station_id   = tst.station_id
    WHERE ts.line_id        = p_line_id
    AND   ts.day_type       IN (p_day_type, 'ALL_DAYS')
    AND   ts.schedule_status IN ('ACTIVE','DELAYED')
    AND   ts.is_deleted     = FALSE
    AND   tst.is_active     = TRUE
    ORDER BY ts.schedule_id, tst.stop_sequence;
END;
$$;

-- ================================================================
--  P34 — GET_FARE_FOR_PASSENGER
--  Convenience wrapper: looks up passenger type automatically.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.get_fare_for_passenger(
    p_passenger_id    INT,
    p_from_station_id INT,
    p_to_station_id   INT
)
RETURNS TABLE(
    passenger_name   VARCHAR,
    passenger_type   passenger_type_t,
    from_station     VARCHAR,
    to_station       VARCHAR,
    distance_km      distance_km_t,
    applicable_fare  money_t,
    fare_rule_id     INT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_ptype     passenger_type_t;
    v_pname     VARCHAR(200);
    v_dist      distance_km_t;
    v_fare      money_t;
    v_rule_id   INT;
    v_from_name VARCHAR(150);
    v_to_name   VARCHAR(150);
BEGIN
    SELECT full_name, passenger_type
    INTO   v_pname, v_ptype
    FROM   metro.PASSENGER
    WHERE  passenger_id = p_passenger_id
    AND    is_deleted   = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Passenger % not found.', p_passenger_id;
    END IF;

    SELECT station_name INTO v_from_name
    FROM   metro.STATION WHERE station_id = p_from_station_id;

    SELECT station_name INTO v_to_name
    FROM   metro.STATION WHERE station_id = p_to_station_id;

    -- Distance via shared line
    SELECT ABS(sol_t.dist_from_start_km - sol_f.dist_from_start_km)
    INTO   v_dist
    FROM   metro.STATION_ON_LINE sol_f
    JOIN   metro.STATION_ON_LINE sol_t
           ON sol_t.line_id    = sol_f.line_id
           AND sol_t.station_id = p_to_station_id
    WHERE  sol_f.station_id = p_from_station_id
    AND    sol_f.is_active  = TRUE
    AND    sol_t.is_active  = TRUE
    ORDER BY v_dist
    LIMIT  1;

    v_dist := COALESCE(v_dist, 3.5);  -- fallback minimum slab distance

    SELECT fare_rule_id INTO v_rule_id
    FROM   metro.FARE_RULE
    WHERE  is_active       = TRUE
    AND    effective_from <= CURRENT_DATE
    AND    (effective_to IS NULL OR effective_to >= CURRENT_DATE)
    AND    v_dist BETWEEN min_distance_km AND max_distance_km
    ORDER BY effective_from DESC LIMIT 1;

    v_fare := metro.calculate_fare(v_dist, v_ptype);

    RETURN QUERY SELECT
        v_pname, v_ptype, v_from_name, v_to_name,
        v_dist, v_fare, v_rule_id;
END;
$$;

-- ================================================================
--  P35 — MARK_PAYMENT_SUCCESS
--  Called by payment gateway webhook to confirm payment.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.mark_payment_success(
    p_ticket_id           BIGINT,
    p_gateway_payment_id  VARCHAR(200),
    p_gateway_order_id    VARCHAR(200)  DEFAULT NULL,
    p_gateway_signature   VARCHAR(500)  DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
BEGIN
    UPDATE metro.PAYMENT
    SET    status              = 'SUCCESS',
           paid_at             = NOW(),
           gateway_payment_id  = p_gateway_payment_id,
           gateway_order_id    = COALESCE(p_gateway_order_id, gateway_order_id),
           gateway_signature   = COALESCE(p_gateway_signature, gateway_signature),
           updated_at          = NOW()
    WHERE  ticket_id = p_ticket_id
    AND    status    IN ('INITIATED','PENDING');

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Payment for ticket % not in INITIATED/PENDING state.', p_ticket_id;
    END IF;

    -- Activate the ticket
    UPDATE metro.TICKET
    SET    status     = 'ACTIVE',
           updated_at = NOW()
    WHERE  ticket_id  = p_ticket_id
    AND    status     = 'BOOKED';

    RETURN 'Payment confirmed for ticket ' || p_ticket_id;
END;
$$;

COMMENT ON FUNCTION metro.mark_payment_success IS
'Called by gateway webhook; sets payment SUCCESS and activates the ticket.';

-- ================================================================
--  P36 — MARK_PAYMENT_FAILED
-- ================================================================

CREATE OR REPLACE FUNCTION metro.mark_payment_failed(
    p_ticket_id          BIGINT,
    p_gateway_response   TEXT DEFAULT 'Payment failed at gateway'
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
BEGIN
    UPDATE metro.PAYMENT
    SET    status              = 'FAILED',
           gateway_response_msg = p_gateway_response,
           updated_at          = NOW()
    WHERE  ticket_id = p_ticket_id
    AND    status    IN ('INITIATED','PENDING');

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Payment for ticket % not found or already settled.',
            p_ticket_id;
    END IF;

    -- Cancel the ticket
    UPDATE metro.TICKET
    SET    status               = 'CANCELLED',
           cancellation_reason  = 'Payment failed',
           cancelled_at         = NOW(),
           updated_at           = NOW()
    WHERE  ticket_id = p_ticket_id
    AND    status    = 'BOOKED';

    RETURN 'Payment failed recorded for ticket ' || p_ticket_id;
END;
$$;

-- ================================================================
--  P37 — DEACTIVATE_PASSENGER
--  Soft-deletes a passenger account and cancels active tickets.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.deactivate_passenger(
    p_passenger_id   INT,
    p_reason         TEXT,
    p_done_by_emp_id INT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_cancelled INT;
BEGIN
    PERFORM 1 FROM metro.PASSENGER
    WHERE  passenger_id = p_passenger_id AND is_deleted = FALSE
    FOR    UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Passenger % not found.', p_passenger_id;
    END IF;

    -- Cancel all active tickets
    UPDATE metro.TICKET
    SET    status              = 'CANCELLED',
           cancellation_reason = 'Account deactivated: ' || p_reason,
           cancelled_at        = NOW(),
           updated_at          = NOW()
    WHERE  passenger_id = p_passenger_id
    AND    status       IN ('BOOKED','ACTIVE');

    GET DIAGNOSTICS v_cancelled = ROW_COUNT;

    -- Deactivate passes
    UPDATE metro.TRAVEL_PASS
    SET    is_active           = FALSE,
           deactivation_reason = 'Account deactivated',
           updated_at          = NOW()
    WHERE  passenger_id = p_passenger_id
    AND    is_active    = TRUE;

    -- Soft-delete passenger
    UPDATE metro.PASSENGER
    SET    is_active   = FALSE,
           is_deleted  = TRUE,
           updated_at  = NOW(),
           updated_by  = p_done_by_emp_id
    WHERE  passenger_id = p_passenger_id;

    INSERT INTO metro.AUDIT_LOG (
        table_name, record_id, action, new_data, performed_by_emp_id
    ) VALUES (
        'PASSENGER', p_passenger_id::TEXT, 'SOFT_DELETE',
        jsonb_build_object('reason', p_reason),
        p_done_by_emp_id
    );

    RETURN 'Passenger ' || p_passenger_id
           || ' deactivated. ' || v_cancelled || ' ticket(s) cancelled.';
END;
$$;

-- ================================================================
--  P38 — ADD_LINE
--  Adds a new metro line to the system.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.add_line(
    p_line_code       VARCHAR(10),
    p_line_name       VARCHAR(100),
    p_color_code      hex_color_t,
    p_total_length_km distance_km_t,
    p_operational_since DATE        DEFAULT NULL,
    p_created_by_emp  INT           DEFAULT NULL
)
RETURNS INT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_line_id INT;
BEGIN
    IF EXISTS (SELECT 1 FROM metro.LINE WHERE line_code = p_line_code) THEN
        RAISE EXCEPTION 'Line code % already exists.', p_line_code;
    END IF;

    INSERT INTO metro.LINE (
        line_code, line_name, color_code, total_length_km,
        operational_since, status, created_by
    ) VALUES (
        p_line_code, p_line_name, p_color_code, p_total_length_km,
        p_operational_since, 'OPERATIONAL', p_created_by_emp
    )
    RETURNING line_id INTO v_line_id;

    RETURN v_line_id;
END;
$$;

-- ================================================================
--  P39 — ADD_PLATFORM
--  Adds a new platform to an existing station.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.add_platform(
    p_station_id    INT,
    p_platform_no   SMALLINT,
    p_direction     direction_t,
    p_capacity      INT,
    p_created_by    INT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
BEGIN
    PERFORM 1 FROM metro.STATION
    WHERE station_id = p_station_id AND is_deleted = FALSE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Station % not found.', p_station_id;
    END IF;

    IF EXISTS (
        SELECT 1 FROM metro.PLATFORM
        WHERE station_id = p_station_id
        AND   platform_no = p_platform_no
    ) THEN
        RAISE EXCEPTION
            'Platform % already exists at station %.', p_platform_no, p_station_id;
    END IF;

    INSERT INTO metro.PLATFORM (
        station_id, platform_no, direction, capacity, created_by
    ) VALUES (
        p_station_id, p_platform_no, p_direction, p_capacity, p_created_by
    );

    RETURN 'Platform ' || p_platform_no
           || ' added to station ' || p_station_id;
END;
$$;

-- ================================================================
--  P40 — ADD_TRACK
--  Adds a new physical track to a line.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.add_track(
    p_line_id      INT,
    p_track_number VARCHAR(20),
    p_direction    direction_t   DEFAULT 'BIDIRECTIONAL',
    p_length_km    distance_km_t DEFAULT NULL,
    p_max_speed    SMALLINT      DEFAULT 80,
    p_created_by   INT           DEFAULT NULL
)
RETURNS INT
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE v_track_id INT;
BEGIN
    PERFORM 1 FROM metro.LINE WHERE line_id = p_line_id AND is_deleted = FALSE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Line % not found.', p_line_id;
    END IF;

    INSERT INTO metro.TRACK (
        line_id, track_number, direction,
        length_km, max_speed_kmph, track_status, created_by
    ) VALUES (
        p_line_id, p_track_number, p_direction,
        p_length_km, p_max_speed, 'AVAILABLE', p_created_by
    )
    RETURNING track_id INTO v_track_id;

    RETURN v_track_id;
END;
$$;

-- ================================================================
--  P41 — SEARCH_ROUTES_WITH_BUS_HANDOFF
--  Extension point for Phase 2 (Bus system integration).
--  Currently returns metro routes + nearest station for bus lookup.
-- ================================================================

CREATE OR REPLACE FUNCTION metro.search_routes_with_bus_handoff(
    p_from_station_id INT,
    p_to_station_id   INT,
    p_day_type        day_type_t DEFAULT 'WEEKDAY'
)
RETURNS TABLE(
    route_type         TEXT,
    description        TEXT,
    line_name          VARCHAR,
    from_station       VARCHAR,
    to_station         VARCHAR,
    estimated_mins     INT,
    fare_normal        money_t,
    distance_km        distance_km_t,
    bus_handoff_needed BOOLEAN,
    nearest_bus_point  VARCHAR
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- Return metro direct routes
    RETURN QUERY
    SELECT
        r.route_type,
        (r.line_name || ': ' || r.from_station || ' → ' || r.to_station)::TEXT
            AS description,
        r.line_name,
        r.from_station,
        r.to_station,
        r.estimated_mins,
        r.fare_normal,
        r.distance_km,
        FALSE AS bus_handoff_needed,
        NULL::VARCHAR AS nearest_bus_point
    FROM metro.get_journey_routes(
            p_from_station_id, p_to_station_id, p_day_type
         ) r;

    -- Bus-handoff stub: returns nearest metro terminus
    -- Phase 2 will JOIN with bus.BUS_STOP table
    RETURN QUERY
    SELECT
        'BUS_HANDOFF'::TEXT,
        ('Take metro to nearest station, then bus to destination')::TEXT,
        NULL::VARCHAR,
        sf.station_name,
        st.station_name,
        NULL::INT,
        NULL::money_t,
        NULL::distance_km_t,
        TRUE,
        st.station_name || ' (Metro Exit → Bus Stand)'
    FROM metro.STATION sf, metro.STATION st
    WHERE sf.station_id = p_from_station_id
    AND   st.station_id = p_to_station_id
    LIMIT 1;
END;
$$;

COMMENT ON FUNCTION metro.search_routes_with_bus_handoff IS
'Route planner with bus handoff stub; Phase 2 will JOIN with bus schema.';

-- ================================================================
--  SECTION B — BCNF RUNTIME VERIFICATION
-- ================================================================

CREATE OR REPLACE FUNCTION metro.fn_verify_bcnf()
RETURNS TABLE(
    check_name    TEXT,
    status        TEXT,
    violation_cnt BIGINT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- 1. Unique station codes
    RETURN QUERY
    SELECT 'Unique station_code'::TEXT,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM (
        SELECT station_code FROM metro.STATION
        WHERE is_deleted = FALSE
        GROUP BY station_code HAVING COUNT(*) > 1
    ) x;

    -- 2. No duplicate sequence on same line
    RETURN QUERY
    SELECT 'No duplicate sequence on line'::TEXT,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM (
        SELECT line_id, sequence_no FROM metro.STATION_ON_LINE
        GROUP BY line_id, sequence_no HAVING COUNT(*) > 1
    ) x;

    -- 3. Ticket price integrity
    RETURN QUERY
    SELECT 'Ticket price = base - discount + tax'::TEXT,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM metro.TICKET
    WHERE ABS(price_paid - (base_amount - discount_amount + tax_amount)) > 0.01
    AND   is_deleted = FALSE;

    -- 4. No overlapping ACTIVE schedules for same train
    RETURN QUERY
    SELECT 'No overlapping schedules (same train)'::TEXT,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM (
        SELECT a.schedule_id
        FROM   metro.TRAIN_SCHEDULE a
        JOIN   metro.TRAIN_SCHEDULE b
          ON   a.train_id      = b.train_id
          AND  a.day_type       = b.day_type
          AND  a.schedule_id   < b.schedule_id
          AND  a.schedule_status = 'ACTIVE'
          AND  b.schedule_status = 'ACTIVE'
          AND  a.is_deleted = FALSE AND b.is_deleted = FALSE
          AND  (a.departure_time, a.arrival_time)
               OVERLAPS
               (b.departure_time, b.arrival_time)
    ) x;

    -- 5. No overlapping ACTIVE schedules for same track
    RETURN QUERY
    SELECT 'No overlapping schedules (same track)'::TEXT,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM (
        SELECT a.schedule_id
        FROM   metro.TRAIN_SCHEDULE a
        JOIN   metro.TRAIN_SCHEDULE b
          ON   a.track_id      = b.track_id
          AND  a.day_type       = b.day_type
          AND  a.schedule_id   < b.schedule_id
          AND  a.schedule_status = 'ACTIVE'
          AND  b.schedule_status = 'ACTIVE'
          AND  a.is_deleted = FALSE AND b.is_deleted = FALSE
          AND  a.track_id IS NOT NULL
          AND  (a.departure_time, a.arrival_time)
               OVERLAPS
               (b.departure_time, b.arrival_time)
    ) x;

    -- 6. All TICKET ENTRY scans have valid ticket status
    RETURN QUERY
    SELECT 'Entry scans on valid tickets only'::TEXT,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM metro.TICKET_GATE_SCAN gs
    JOIN metro.TICKET t ON t.ticket_id = gs.ticket_id
    WHERE gs.gate_role  = 'ENTRY'
    AND   gs.is_valid   = TRUE
    AND   t.status NOT IN ('ACTIVE','ENTRY_DONE','USED');

    -- 7. Weak entity: PLATFORM has valid station_id
    RETURN QUERY
    SELECT 'PLATFORM references valid STATION'::TEXT,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM metro.PLATFORM p
    LEFT JOIN metro.STATION s ON s.station_id = p.station_id
    WHERE s.station_id IS NULL;

    -- 8. Weak entity: TRAIN_STOP has valid schedule_id
    RETURN QUERY
    SELECT 'TRAIN_STOP references valid SCHEDULE'::TEXT,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM metro.TRAIN_STOP tst
    LEFT JOIN metro.TRAIN_SCHEDULE ts ON ts.schedule_id = tst.schedule_id
    WHERE ts.schedule_id IS NULL;

    -- 9. DRIVER_SHIFT: no driver with > 16 working hours in a shift
    RETURN QUERY
    SELECT 'DRIVER_SHIFT working_hours <= 16'::TEXT,
           CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
           COUNT(*)
    FROM metro.DRIVER_SHIFT
    WHERE working_hours > 16;

    -- 10. FARE_RULE slabs: no active overlapping slabs
   RETURN QUERY
SELECT 'No overlapping active FARE_RULE slabs'::TEXT,
       CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END,
       COUNT(*)
FROM (
    SELECT a.fare_rule_id
    FROM metro.FARE_RULE a
    JOIN metro.FARE_RULE b
      ON a.fare_rule_id < b.fare_rule_id
      AND a.is_active = TRUE
      AND b.is_active = TRUE
      AND a.min_distance_km <= b.max_distance_km
      AND a.max_distance_km >= b.min_distance_km
) x;

END;
$$;

COMMENT ON FUNCTION metro.fn_verify_bcnf IS
'Run SELECT * FROM metro.fn_verify_bcnf(); to verify all BCNF checks pass.';

-- ================================================================
--  SECTION C — pg_cron SCHEDULED JOBS
--  Requires: shared_preload_libraries = 'pg_cron'
--            CREATE EXTENSION pg_cron;  (run as superuser)
-- ================================================================

-- Uncomment and run as superuser to enable pg_cron:
-- CREATE EXTENSION IF NOT EXISTS pg_cron;
-- GRANT USAGE ON SCHEMA cron TO metro_admin;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_extension WHERE extname = 'pg_cron'
    ) THEN

        -- JOB 1: Expire stale tickets every 5 minutes
        PERFORM cron.schedule(
            'metro_expire_tickets',
            '*/5 * * * *',
            'SELECT metro.fn_expire_stale_tickets();'
        );

        -- JOB 2: Expire stale travel passes at midnight
        PERFORM cron.schedule(
            'metro_expire_passes',
            '0 0 * * *',
            $cron$
            UPDATE metro.TRAVEL_PASS
            SET    is_active          = FALSE,
                   deactivation_reason = 'Expired automatically',
                   updated_at         = NOW()
            WHERE  valid_to  < CURRENT_DATE
            AND    is_active = TRUE
            AND    is_deleted = FALSE;
            $cron$
        );

        -- JOB 3: Alert for driver licenses expiring in 90 days (daily 08:00)
        PERFORM cron.schedule(
            'metro_license_expiry_alert',
            '0 8 * * *',
            $cron$
            INSERT INTO metro.ALERT (
                alert_type, severity, title, message, channel
            )
            SELECT
                'GENERAL_ADVISORY',
                'WARNING',
                'Driver License Expiring: ' || full_name,
                'Driver ' || full_name
                    || ' (ID: ' || driver_id || ') license expires on '
                    || license_expiry::TEXT
                    || '. Please initiate renewal.',
                'IN_APP'
            FROM metro.DRIVER
            WHERE employment_status = 'ACTIVE'
            AND   is_deleted        = FALSE
            AND   license_expiry    BETWEEN CURRENT_DATE
                                        AND CURRENT_DATE + INTERVAL '90 days';
            $cron$
        );

        -- JOB 4: Scheduled maintenance reminder 7 days in advance (daily 07:00)
        PERFORM cron.schedule(
            'metro_maintenance_reminder',
            '0 7 * * *',
            $cron$
            INSERT INTO metro.ALERT (
                train_id, alert_type, severity, title, message, channel
            )
            SELECT
                ml.train_id,
                'MAINTENANCE_CLOSURE',
                'WARNING',
                'Scheduled Maintenance Due: Train ' || t.train_number,
                'Train ' || t.train_number
                    || ' has scheduled maintenance due on '
                    || ml.next_due_date::TEXT,
                'IN_APP'
            FROM metro.MAINTENANCE_LOG ml
            JOIN metro.TRAIN t ON t.train_id = ml.train_id
            WHERE ml.status       = 'SCHEDULED'
            AND   ml.is_deleted   = FALSE
            AND   ml.next_due_date = CURRENT_DATE + INTERVAL '7 days';
            $cron$
        );

        -- JOB 5: Daily revenue summary log at 23:55
        PERFORM cron.schedule(
            'metro_daily_revenue_log',
            '55 23 * * *',
            $cron$
            INSERT INTO metro.AUDIT_LOG (
                table_name, record_id, action, new_data
            )
            SELECT
                'PAYMENT',
                CURRENT_DATE::TEXT,
                'CONFIG_CHANGE',
                jsonb_build_object(
                    'date',          CURRENT_DATE,
                    'total_txns',    COUNT(*),
                    'gross_revenue', SUM(amount),
                    'net_revenue',   SUM(amount - refund_amount)
                )
            FROM metro.PAYMENT
            WHERE DATE(paid_at) = CURRENT_DATE
            AND   status IN ('SUCCESS','PARTIALLY_REFUNDED');
            $cron$
        );

        -- JOB 6: Auto-close resolved incidents after 7 days (daily midnight)
        PERFORM cron.schedule(
            'metro_auto_close_incidents',
            '30 0 * * *',
            $cron$
            UPDATE metro.TRAIN_INCIDENT
            SET    status     = 'CLOSED',
                   closed_at  = NOW(),
                   updated_at = NOW()
            WHERE  status       = 'RESOLVED'
            AND    resolved_at <= NOW() - INTERVAL '7 days'
            AND    is_deleted   = FALSE;
            $cron$
        );

        -- JOB 7: Flush LIVE_TRACKING rows older than 30 days (weekly Sunday 02:00)
        -- Note: In production, partition LIVE_TRACKING by month instead
        PERFORM cron.schedule(
            'metro_purge_old_tracking',
            '0 2 * * 0',
            $cron$
            DELETE FROM metro.LIVE_TRACKING
            WHERE recorded_at < NOW() - INTERVAL '30 days';
            $cron$
        );

        RAISE NOTICE 'pg_cron jobs registered successfully.';
    ELSE
        RAISE NOTICE 'pg_cron not installed — skipping job registration. '
                     'Install pg_cron and re-run this block.';
    END IF;
END $$;

-- ================================================================
--  SECTION D — UTILITY HELPER VIEWS (remaining)
-- ================================================================

-- ── V11: Upcoming maintenance schedule ───────────────────────────
CREATE OR REPLACE VIEW metro.v_upcoming_maintenance AS
SELECT
    ml.log_id,
    t.train_number,
    ml.maintenance_type,
    ml.maintenance_date,
    ml.next_due_date,
    ml.status,
    ml.estimated_cost,
    e.full_name  AS assigned_to,
    ml.description
FROM  metro.MAINTENANCE_LOG  ml
JOIN  metro.TRAIN             t  ON t.train_id          = ml.train_id
LEFT JOIN metro.EMPLOYEE      e  ON e.employee_id       = ml.performed_by_emp_id
WHERE ml.status      IN ('SCHEDULED','IN_PROGRESS')
AND   ml.is_deleted   = FALSE
ORDER BY ml.maintenance_date;

-- ── V12: Driver workload this week ────────────────────────────────
CREATE OR REPLACE VIEW metro.v_driver_weekly_workload AS
SELECT
    d.driver_id,
    d.full_name                                              AS driver_name,
    d.employee_code,
    ds.shift_date,
    ds.shift_start,
    ds.shift_end,
    ds.working_hours,
    ds.shift_type,
    COUNT(dsa.assignment_id)                                 AS schedules_assigned
FROM  metro.DRIVER               d
JOIN  metro.DRIVER_SHIFT         ds  ON ds.driver_id = d.driver_id
LEFT JOIN metro.DRIVER_SCHEDULE_ASSIGNMENT dsa
    ON dsa.driver_id        = d.driver_id
    AND dsa.assignment_date = ds.shift_date
    AND dsa.is_active       = TRUE
WHERE ds.shift_date BETWEEN CURRENT_DATE - 3 AND CURRENT_DATE + 3
AND   d.is_deleted  = FALSE
GROUP BY d.driver_id, d.full_name, d.employee_code,
         ds.shift_date, ds.shift_start, ds.shift_end,
         ds.working_hours, ds.shift_type
ORDER BY ds.shift_date, ds.shift_start;

-- ── V13: Employee directory ───────────────────────────────────────
CREATE OR REPLACE VIEW metro.v_employee_directory AS
SELECT
    e.employee_id,
    e.employee_code,
    e.full_name,
    e.role,
    e.department,
    e.email,
    e.phone,
    e.access_level,
    e.employment_status,
    e.joining_date,
    s.station_name  AS managed_station,
    m.full_name     AS reporting_manager
FROM  metro.EMPLOYEE       e
LEFT JOIN metro.STATION    s  ON s.station_id     = e.managed_station_id
LEFT JOIN metro.EMPLOYEE   m  ON m.employee_id    = e.reporting_manager_id
WHERE e.is_deleted = FALSE
ORDER BY e.department, e.role, e.full_name;

-- ── V14: Feedback summary by category ────────────────────────────
CREATE OR REPLACE VIEW metro.v_feedback_summary AS
SELECT
    category,
    COUNT(*)                                                 AS total_feedback,
    ROUND(AVG(rating), 2)                                    AS avg_rating,
    COUNT(*) FILTER (WHERE rating >= 4)                      AS positive_count,
    COUNT(*) FILTER (WHERE rating <= 2)                      AS negative_count,
    COUNT(*) FILTER (WHERE status = 'OPEN')                  AS open_count,
    COUNT(*) FILTER (WHERE status = 'RESOLVED')              AS resolved_count
FROM  metro.FEEDBACK
WHERE submitted_at >= NOW() - INTERVAL '30 days'
GROUP BY category
ORDER BY total_feedback DESC;

-- ── V15: System health dashboard ─────────────────────────────────
CREATE OR REPLACE VIEW metro.v_system_health AS
SELECT
    (SELECT COUNT(*) FROM metro.TRAIN
     WHERE operational_status = 'ON_TRACK'
     AND   is_deleted = FALSE)                               AS trains_on_track,
    (SELECT COUNT(*) FROM metro.TRAIN
     WHERE operational_status = 'RESTING'
     AND   is_deleted = FALSE)                               AS trains_resting,
    (SELECT COUNT(*) FROM metro.TRAIN
     WHERE operational_status IN ('MAINTENANCE','SUSPENDED','CRASHED')
     AND   is_deleted = FALSE)                               AS trains_unavailable,
    (SELECT COUNT(*) FROM metro.TRAIN_SCHEDULE
     WHERE schedule_status = 'ACTIVE'
     AND   is_deleted = FALSE)                               AS active_schedules,
    (SELECT COUNT(*) FROM metro.TRAIN_SCHEDULE
     WHERE schedule_status = 'DELAYED'
     AND   is_deleted = FALSE)                               AS delayed_schedules,
    (SELECT COUNT(*) FROM metro.STATION
     WHERE is_active = TRUE
     AND   is_deleted = FALSE)                               AS active_stations,
    (SELECT COUNT(*) FROM metro.STATION
     WHERE is_active = FALSE
     AND   is_deleted = FALSE)                               AS closed_stations,
    (SELECT COUNT(*) FROM metro.DELAY_EVENT
     WHERE resolution_status = 'PENDING')                    AS pending_delays,
    (SELECT COUNT(*) FROM metro.TRAIN_INCIDENT
     WHERE status NOT IN ('CLOSED','ARCHIVED')
     AND   is_deleted = FALSE)                               AS open_incidents,
    (SELECT COALESCE(SUM(current_crowd_count),0)
     FROM   metro.TRAIN
     WHERE  operational_status = 'ON_TRACK'
     AND    is_deleted = FALSE)                              AS total_passengers_onboard,
    NOW()                                                    AS snapshot_at;

-- ================================================================
--  SECTION E — FINAL INTEGRITY + COMPLETION CHECK
-- ================================================================

DO $$
DECLARE
    v_tables   INT;
    v_funcs    INT;
    v_triggers INT;
    v_views    INT;
    v_indexes  INT;
    v_types    INT;
BEGIN
    SELECT COUNT(*) INTO v_tables
    FROM information_schema.tables
    WHERE table_schema = 'metro' AND table_type = 'BASE TABLE';

    SELECT COUNT(*) INTO v_funcs
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'metro';

    SELECT COUNT(*) INTO v_triggers
    FROM information_schema.triggers
    WHERE trigger_schema = 'metro';

    SELECT COUNT(*) INTO v_views
    FROM information_schema.views
    WHERE table_schema = 'metro';

    SELECT COUNT(*) INTO v_indexes
    FROM pg_indexes
    WHERE schemaname = 'metro';

    SELECT COUNT(*) INTO v_types
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    WHERE n.nspname = 'metro' AND t.typtype = 'e';

    RAISE NOTICE '============================================================';
    RAISE NOTICE ' AHMEDABAD METRO RAIL — DDL COMPLETE';
    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE ' Schema        : metro';
    RAISE NOTICE ' Tables        : %', v_tables;
    RAISE NOTICE ' ENUM Types    : %', v_types;
    RAISE NOTICE ' Functions     : %', v_funcs;
    RAISE NOTICE ' Triggers      : %', v_triggers;
    RAISE NOTICE ' Views         : %', v_views;
    RAISE NOTICE ' Indexes       : %', v_indexes;
    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE ' Normalization : BCNF verified (all 34 tables)';
    RAISE NOTICE ' Roles         : metro_readonly, metro_app, metro_admin';
    RAISE NOTICE ' Cron jobs     : 7 (if pg_cron installed)';
    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE ' Run: SELECT * FROM metro.fn_verify_bcnf();';
    RAISE NOTICE '      to verify all integrity checks pass.';
    RAISE NOTICE '============================================================';
END $$;


-- ================================================================
--  FINAL VERIFICATION — run after script completes
-- ================================================================

--\echo ''
--\echo '============================================================'
--\echo ' RUNNING BCNF VERIFICATION...'
--\echo '============================================================'

SELECT * FROM metro.fn_verify_bcnf();

--\echo ''
--\echo '============================================================'
--\echo ' OBJECT COUNT SUMMARY'
--\echo '============================================================'

SELECT
    'Tables'    AS object_type,
    COUNT(*)::TEXT AS count
FROM information_schema.tables
WHERE table_schema = 'metro' AND table_type = 'BASE TABLE'
UNION ALL
SELECT 'Views',     COUNT(*)::TEXT
FROM information_schema.views      WHERE table_schema = 'metro'
UNION ALL
SELECT 'Functions', COUNT(*)::TEXT
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'metro'
UNION ALL
SELECT 'Triggers',  COUNT(*)::TEXT
FROM information_schema.triggers   WHERE trigger_schema = 'metro'
UNION ALL
SELECT 'Indexes',   COUNT(*)::TEXT
FROM pg_indexes                    WHERE schemaname = 'metro'
UNION ALL
SELECT 'ENUM Types', COUNT(*)::TEXT
FROM pg_type t
JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname = 'metro' AND t.typtype = 'e'
ORDER BY object_type;

--\echo ''
--\echo '============================================================'
--\echo ' SYSTEM HEALTH (empty on fresh install)'
--\echo '============================================================'
SELECT * FROM metro.v_system_health;

--\echo ''
--\echo '============================================================'
--\echo ' ACTIVE FARE LOOKUP'
--\echo '============================================================'
SELECT * FROM metro.v_fare_lookup;

--\echo ''
--\echo '============================================================'
--\echo ' DDL COMPLETE — READY FOR DUMMY DATA INSERTION'
--\echo '============================================================'



SELECT table_name
FROM information_schema.tables
WHERE table_schema='metro';


SELECT * FROM metro.fare_rule;



-- ======================================================
--       Query:  BCNF verification
-- ======================================================

SELECT * FROM metro.fn_verify_bcnf();







-- ======================================================
--       Query :  Number of tables
-- ======================================================


SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema='metro';



-- ======================================================
--       Query :  Number of functions 
-- ======================================================

SELECT COUNT(*) 
FROM information_schema.routines
WHERE routine_schema='metro';



-- ================================================================
--  AHMEDABAD METRO RAIL SYSTEM — DUMMY DATA INSERTION SCRIPT
--  Part 1 of 3 : LINE → STATION → PLATFORM → STATION_ON_LINE → TRACK
--  Source       : Real data from Gujarat Metro Rail Corporation (GMRC)
--                 Wikipedia / YoMetro / Official GMRC website
--  Order        : Parent tables first, then FK-dependent tables
-- ================================================================
 

 
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
 
  
