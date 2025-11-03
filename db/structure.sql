SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: acao; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA acao;


--
-- Name: ca; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ca;


--
-- Name: core; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA core;


--
-- Name: flarc; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA flarc;


--
-- Name: i18n; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA i18n;


--
-- Name: ml; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ml;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: trailers; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.trailers (
    id_old integer NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    zone character varying(32),
    notes text,
    identifier character varying(32) DEFAULT NULL::character varying,
    country character varying(64) DEFAULT NULL::character varying,
    model character varying(255) DEFAULT NULL::character varying,
    fin_writings character varying(255) DEFAULT NULL::character varying,
    side_writings character varying(255) DEFAULT NULL::character varying,
    aircraft_id uuid,
    person_id uuid,
    payment_id uuid,
    location_id uuid,
    member_id uuid NOT NULL
);


--
-- Name: acao_trailers_id_seq; Type: SEQUENCE; Schema: acao; Owner: -
--

CREATE SEQUENCE acao.acao_trailers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: acao_trailers_id_seq; Type: SEQUENCE OWNED BY; Schema: acao; Owner: -
--

ALTER SEQUENCE acao.acao_trailers_id_seq OWNED BY acao.trailers.id_old;


--
-- Name: access_remotes; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.access_remotes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    symbol character varying(32),
    ch1_code character varying(32),
    ch2_code character varying(32),
    ch3_code character varying(32),
    ch4_code character varying(32),
    descr character varying
);


--
-- Name: aircraft_owners; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.aircraft_owners (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    aircraft_id uuid,
    member_id uuid,
    is_referent boolean DEFAULT false NOT NULL
);


--
-- Name: aircraft_sync_statuses; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.aircraft_sync_statuses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    symbol character varying(16),
    last_update timestamp without time zone,
    status character varying
);


--
-- Name: aircraft_types; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.aircraft_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    manufacturer character varying(64) NOT NULL,
    name character varying(32) NOT NULL,
    seats integer,
    motor integer,
    handicap double precision,
    link_wp character varying,
    handicap_club double precision,
    aircraft_class character varying(16),
    wingspan numeric(4,1) DEFAULT NULL::numeric,
    is_vintage boolean DEFAULT false NOT NULL,
    foldable_wings boolean DEFAULT false NOT NULL
);


--
-- Name: aircrafts; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.aircrafts (
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    fn_owner_name character varying(255),
    fn_home_airport character varying(255),
    fn_type_name character varying(255),
    race_registration character varying(255),
    registration character varying(255),
    fn_common_radio_frequency character varying(255),
    flarm_identifier character varying(16),
    icao_identifier character varying(16),
    mdb_id integer,
    hangar boolean DEFAULT false NOT NULL,
    notes text,
    club_id uuid,
    serial_number character varying(32) DEFAULT NULL::character varying,
    arc_valid_to timestamp without time zone,
    insurance_valid_to timestamp without time zone,
    club_owner_id uuid,
    available boolean DEFAULT true NOT NULL,
    is_towplane boolean DEFAULT false NOT NULL,
    owner_id_old uuid,
    aircraft_type_id uuid,
    owner_id uuid,
    source_id integer
);


--
-- Name: airfield_circuits; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.airfield_circuits (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    airfield_id uuid NOT NULL,
    name character varying(64) NOT NULL,
    data text NOT NULL
);


--
-- Name: airfields; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.airfields (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    radius integer NOT NULL,
    icao_code character(4),
    symbol character varying(16),
    location_id uuid NOT NULL,
    range integer NOT NULL,
    range_alt integer NOT NULL
);


--
-- Name: bar_menu_entries; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.bar_menu_entries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    descr character varying(255) NOT NULL,
    price numeric(14,6) NOT NULL,
    on_sale boolean DEFAULT false NOT NULL
);


--
-- Name: bar_transactions; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.bar_transactions (
    prev_credit numeric(14,6),
    credit numeric(14,6),
    amount numeric(14,6) NOT NULL,
    descr character varying NOT NULL,
    old_id integer,
    recorded_at timestamp with time zone,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    cnt integer DEFAULT 1 NOT NULL,
    unit character varying DEFAULT '€'::character varying NOT NULL,
    old_cassetta_id integer,
    person_id uuid,
    session_id uuid,
    member_id uuid NOT NULL,
    operator_id uuid
);


--
-- Name: camera_events; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.camera_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_type character varying(32) NOT NULL,
    ts timestamp without time zone,
    aircraft_id uuid,
    name character varying,
    flarm_id character varying(32),
    lat double precision,
    lng double precision,
    alt double precision,
    hgt double precision
);


--
-- Name: clubs; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.clubs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    symbol character varying(32) DEFAULT NULL::character varying,
    airfield_id uuid
);


--
-- Name: debt_details; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.debt_details (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    debt_id uuid NOT NULL,
    count integer NOT NULL,
    code character varying,
    descr character varying NOT NULL,
    amount numeric(14,6) NOT NULL,
    vat numeric(14,6) NOT NULL,
    data character varying,
    service_type_id uuid,
    obj_type character varying,
    obj_id uuid,
    row_index integer DEFAULT 1 NOT NULL
);


--
-- Name: debts; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.debts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    member_id uuid NOT NULL,
    identifier character varying(32) NOT NULL,
    state character varying(32) NOT NULL,
    descr character varying NOT NULL,
    completed_at timestamp without time zone,
    expires_at timestamp without time zone,
    notes character varying,
    last_chore timestamp without time zone,
    synced_at timestamp(6) without time zone DEFAULT now() NOT NULL,
    onda_export boolean DEFAULT true NOT NULL,
    onda_export_no_reg boolean DEFAULT false NOT NULL,
    pm_card_enabled boolean DEFAULT true,
    pm_wire_enabled boolean DEFAULT true,
    pm_check_enabled boolean DEFAULT true,
    pm_cash_enabled boolean DEFAULT true,
    pm_satispay_enabled boolean DEFAULT true,
    pm_debt_enabled boolean DEFAULT true
);


--
-- Name: fai_cards; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.fai_cards (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    identifier character varying(32),
    issued_at timestamp without time zone,
    valid_to timestamp without time zone,
    country character varying(255) NOT NULL,
    person_id uuid,
    member_id uuid NOT NULL
);


--
-- Name: flarmnet_entries; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.flarmnet_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    aircraft_id uuid,
    last_update timestamp without time zone,
    device_type character varying(2) NOT NULL,
    device_id character varying(32) NOT NULL,
    registration character varying,
    aircraft_model character varying,
    cn character varying,
    tracked boolean,
    identified boolean
);


--
-- Name: flights; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.flights (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    takeoff_time timestamp with time zone,
    pilot1_role character varying(16),
    pilot2_role character varying(16),
    source character varying(16),
    source_id integer,
    source_expansion character varying(16),
    acao_tipo_volo_club integer,
    acao_tipo_aereo_aliante integer,
    acao_durata_volo_aereo_minuti integer,
    acao_durata_volo_aliante_minuti integer,
    acao_quota integer,
    acao_bollini_volo integer,
    acao_data_att timestamp with time zone,
    aircraft_class character varying(16),
    aircraft_owner character varying,
    instruction_flight boolean DEFAULT false NOT NULL,
    launch_type character varying(16),
    landing_time timestamp with time zone,
    aircraft_reg character varying(16),
    takeoff_location_raw character varying(255),
    landing_location_raw character varying(255),
    aircraft_id uuid,
    pilot1_id_old uuid,
    pilot2_id_old uuid,
    takeoff_airfield_id uuid,
    landing_airfield_id uuid,
    takeoff_location_id uuid,
    landing_location_id uuid,
    towed_by_id uuid,
    tow_release_location_id uuid,
    aircraft_owner_id_old uuid,
    pilot1_id uuid,
    pilot2_id uuid,
    aircraft_owner_id uuid,
    pilot1_name character varying,
    pilot2_name character varying,
    proficiency_check boolean DEFAULT false NOT NULL,
    skill_test boolean DEFAULT false NOT NULL,
    maintenance_flight boolean DEFAULT false NOT NULL,
    purpose character varying(32)
);


--
-- Name: gates; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.gates (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying(64) NOT NULL,
    descr character varying(255) NOT NULL,
    agent_id uuid NOT NULL
);


--
-- Name: invoice_details; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.invoice_details (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    invoice_id uuid NOT NULL,
    count integer,
    untaxed_amount numeric(14,6),
    descr character varying(255) DEFAULT NULL::character varying,
    data text,
    row_type integer,
    row_number integer,
    code character varying(32),
    single_amount numeric(14,6),
    vat_amount numeric(14,6),
    total_amount numeric(14,6)
);


--
-- Name: invoices; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.invoices (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    identifier_full character varying DEFAULT NULL::character varying,
    address character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    notes text,
    payment_method character varying(32) NOT NULL,
    state character varying DEFAULT 'NEW'::character varying NOT NULL,
    payment_state character varying DEFAULT 'UNPAID'::character varying NOT NULL,
    person_id uuid,
    member_id uuid,
    source_id integer,
    recipient character varying NOT NULL,
    codice_fiscale character varying,
    partita_iva character varying,
    email character varying,
    document_date timestamp without time zone,
    registered_at timestamp without time zone,
    amount numeric(14,6) DEFAULT 0.0 NOT NULL,
    identifier character varying,
    year integer,
    document_type character varying
);


--
-- Name: key_fobs; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.key_fobs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    code character varying(32),
    descr character varying(255),
    notes text,
    version integer DEFAULT 0 NOT NULL,
    condemned boolean DEFAULT false NOT NULL,
    person_id uuid,
    media_type character varying(16) NOT NULL,
    src character varying(32),
    src_id integer,
    member_id uuid NOT NULL
);


--
-- Name: license_ratings; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.license_ratings (
    type character varying(32) NOT NULL,
    valid_to timestamp with time zone,
    issued_at timestamp with time zone,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    license_id uuid NOT NULL
);


--
-- Name: licenses; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.licenses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type character varying(32) NOT NULL,
    valid_to timestamp with time zone,
    issued_at timestamp with time zone,
    valid_to2 timestamp with time zone,
    identifier character varying(32),
    pilot_id uuid,
    member_id uuid NOT NULL
);


--
-- Name: medicals; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.medicals (
    type character varying(32) NOT NULL,
    valid_to timestamp with time zone,
    issued_at timestamp with time zone,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    identifier character varying(32),
    pilot_id uuid,
    member_id uuid NOT NULL
);


--
-- Name: member_access_remotes; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.member_access_remotes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    symbol character varying(32),
    person_id uuid,
    remote_id uuid NOT NULL,
    descr character varying,
    member_id uuid NOT NULL
);


--
-- Name: member_roles; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.member_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    member_id uuid,
    symbol character varying(32) NOT NULL,
    name character varying,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone
);


--
-- Name: member_services; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.member_services (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    valid_from timestamp without time zone NOT NULL,
    valid_to timestamp without time zone NOT NULL,
    service_data text,
    invoice_detail_id uuid,
    service_type_id uuid NOT NULL,
    payment_id uuid,
    person_id uuid,
    member_id uuid
);


--
-- Name: members; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    person_id uuid NOT NULL,
    ext_id bigint,
    code integer,
    sleeping boolean DEFAULT false NOT NULL,
    job character varying,
    bar_credit numeric(14,6) DEFAULT 0.0 NOT NULL,
    bollini numeric(14,6) DEFAULT 0.0 NOT NULL,
    roster_chief boolean DEFAULT false NOT NULL,
    roster_allowed boolean DEFAULT false NOT NULL,
    is_student boolean DEFAULT false NOT NULL,
    is_tug_pilot boolean DEFAULT false NOT NULL,
    is_board_member boolean DEFAULT false NOT NULL,
    is_instructor boolean DEFAULT false NOT NULL,
    is_fireman boolean DEFAULT false NOT NULL,
    has_disability boolean DEFAULT false NOT NULL,
    email_allowed boolean DEFAULT false NOT NULL,
    debtor boolean DEFAULT false NOT NULL,
    ml_students boolean DEFAULT false NOT NULL,
    ml_instructors boolean DEFAULT false NOT NULL,
    ml_tug_pilots boolean DEFAULT false NOT NULL,
    ml_blabla boolean DEFAULT false NOT NULL,
    ml_secondoperiodo boolean DEFAULT false NOT NULL,
    lastmod timestamp without time zone,
    visita_lastmod timestamp without time zone,
    licenza_lastmod timestamp without time zone,
    bar_last_summary timestamp without time zone,
    last_notify_run timestamp without time zone,
    visible_to_other_members boolean DEFAULT false,
    email_allowed_at timestamp without time zone,
    privacy_accepted boolean DEFAULT false,
    privacy_accepted_at timestamp without time zone,
    consent_association boolean DEFAULT false,
    consent_surveillance boolean DEFAULT false,
    consent_accessory boolean DEFAULT false,
    consent_profiling boolean DEFAULT false,
    consent_magazine boolean DEFAULT false,
    consent_fai boolean DEFAULT false,
    consent_marketing boolean DEFAULT false,
    consent_members boolean DEFAULT false
);


--
-- Name: memberships; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.memberships (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    status character varying(32),
    email_allowed boolean DEFAULT true NOT NULL,
    tug_pilot boolean DEFAULT false,
    board_member boolean DEFAULT false,
    instructor boolean DEFAULT false,
    fireman boolean DEFAULT false,
    possible_roster_chief boolean DEFAULT false NOT NULL,
    valid_from timestamp with time zone NOT NULL,
    valid_to timestamp with time zone NOT NULL,
    invoice_detail_id uuid,
    student boolean DEFAULT false,
    person_id uuid,
    payment_id uuid,
    reference_year_id uuid NOT NULL,
    member_id uuid NOT NULL
);


--
-- Name: meter_buses; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.meter_buses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    ipv4_address character varying(15) NOT NULL,
    port integer NOT NULL,
    name character varying NOT NULL,
    descr character varying
);


--
-- Name: meter_measures; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.meter_measures (
    at timestamp without time zone NOT NULL,
    voltage double precision,
    current double precision,
    power double precision,
    frequency double precision,
    power_factor double precision,
    exported_energy numeric(10,2),
    imported_energy numeric(10,2),
    total_energy numeric(10,2),
    app_power double precision,
    rea_power double precision,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    meter_id uuid NOT NULL
);


--
-- Name: meters; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.meters (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    bus_address integer NOT NULL,
    name character varying NOT NULL,
    descr character varying NOT NULL,
    notes text NOT NULL,
    last_update timestamp without time zone,
    voltage double precision,
    current double precision,
    power double precision,
    frequency double precision,
    power_factor double precision,
    exported_energy numeric(10,2),
    imported_energy numeric(10,2),
    total_energy numeric(10,2),
    app_power double precision,
    rea_power double precision,
    person_id uuid,
    bus_id uuid,
    member_id uuid
);


--
-- Name: ogn_ddb_entries; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.ogn_ddb_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    aircraft_id uuid,
    last_update timestamp without time zone,
    device_type character varying(2) NOT NULL,
    device_id character varying(32) NOT NULL,
    aircraft_model_id character varying,
    aircraft_registration character varying,
    aircraft_model character varying,
    aircraft_competition_id character varying,
    tracked boolean,
    identified boolean,
    synced_at timestamp(6) without time zone DEFAULT now() NOT NULL
);


--
-- Name: onda_invoice_export_details; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.onda_invoice_export_details (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    onda_invoice_export_id uuid NOT NULL,
    count integer NOT NULL,
    code character varying(32) NOT NULL,
    item_type integer NOT NULL,
    descr character varying NOT NULL,
    amount numeric(14,6) NOT NULL,
    vat numeric(14,6) NOT NULL,
    data character varying
);


--
-- Name: onda_invoice_exports; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.onda_invoice_exports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    member_id uuid NOT NULL,
    identifier character varying(32) NOT NULL,
    state character varying DEFAULT 'PENDING'::character varying,
    descr character varying NOT NULL,
    notes character varying,
    payment_method character varying(32),
    last_chore timestamp without time zone,
    synced_at timestamp(6) without time zone DEFAULT now() NOT NULL,
    reject_cause character varying,
    debt_id uuid
);


--
-- Name: payment_services; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.payment_services (
    price numeric(10,4),
    extra_info character varying,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    payment_id uuid NOT NULL,
    service_type_id uuid NOT NULL
);


--
-- Name: payments; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.payments (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    identifier character varying(8),
    payment_method character varying(32) NOT NULL,
    created_at timestamp with time zone,
    state character varying(32) DEFAULT 'PENDING'::character varying NOT NULL,
    reason_for_payment character varying(140),
    completed_at timestamp with time zone,
    expires_at timestamp with time zone,
    notes text,
    last_chore timestamp with time zone,
    amount numeric(14,6) DEFAULT NULL::numeric,
    wire_value_date timestamp without time zone,
    receipt_code character varying(255) DEFAULT NULL::character varying,
    debt_id uuid,
    amount_paid numeric(14,6),
    sp_idempotency_key character varying,
    sp_id character varying,
    sp_code character varying,
    sp_type character varying,
    sp_status character varying,
    sp_status_ownership boolean,
    sp_expired boolean,
    sp_sender_id uuid,
    sp_receiver_id uuid,
    sp_daily_closure_id character varying,
    sp_daily_closure_date timestamp without time zone,
    sp_insert_date timestamp without time zone,
    sp_expire_date timestamp without time zone,
    sp_description character varying,
    sp_flow character varying,
    sp_external_code character varying,
    obj_id uuid,
    obj_type character varying,
    member_id uuid
);


--
-- Name: pilots; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.pilots (
    id uuid NOT NULL,
    name character varying,
    acao_sleeping boolean DEFAULT false NOT NULL,
    acao_bar_last_summary timestamp with time zone
);


--
-- Name: planes; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.planes (
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id uuid NOT NULL,
    flarm_code character varying(16),
    owner_name character varying(255),
    home_airport character varying(255),
    type_name character varying(255),
    race_registration character varying(255),
    registration character varying(255),
    common_radio_frequency character varying(255)
);


--
-- Name: radar_events; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.radar_events (
    id integer NOT NULL,
    at timestamp with time zone NOT NULL,
    event character varying(32) NOT NULL,
    data text,
    recorded_at timestamp with time zone,
    text text,
    aircraft_id uuid
);


--
-- Name: radar_points; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.radar_points (
    at timestamp with time zone NOT NULL,
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    alt double precision NOT NULL,
    cog double precision,
    sog double precision,
    tr double precision,
    cr double precision,
    recorded_at timestamp without time zone,
    srcs character varying,
    src character varying(16),
    aircraft_id uuid NOT NULL,
    last_rep timestamp with time zone,
    freshness double precision,
    hgt double precision
);


--
-- Name: radar_raw_points; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.radar_raw_points (
    at timestamp with time zone NOT NULL,
    rcv_at timestamp with time zone NOT NULL,
    rec_at timestamp with time zone DEFAULT now() NOT NULL,
    src character varying(16),
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    alt double precision,
    cog double precision,
    sog double precision,
    tr double precision,
    cr double precision,
    aircraft_id uuid NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    symbol character varying,
    descr character varying,
    icon character varying,
    usable boolean DEFAULT true NOT NULL
);


--
-- Name: roster_days; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.roster_days (
    date date,
    high_season boolean DEFAULT false NOT NULL,
    needed_people integer NOT NULL,
    descr character varying,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: roster_entries; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.roster_entries (
    chief boolean DEFAULT false NOT NULL,
    notes text,
    roster_day_id_old integer,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    selected_at timestamp with time zone,
    on_offer_since timestamp with time zone,
    person_id uuid,
    roster_day_id uuid NOT NULL,
    member_id uuid NOT NULL
);


--
-- Name: satispay_entities; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.satispay_entities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    type character varying,
    name character varying
);


--
-- Name: satispay_profile_pictures; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.satispay_profile_pictures (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    entity_id uuid NOT NULL,
    source character varying NOT NULL,
    width integer,
    height integer,
    is_original boolean,
    url character varying
);


--
-- Name: service_types; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.service_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    symbol character varying(32),
    name character varying NOT NULL,
    price numeric(10,4),
    extra_info character varying,
    notes character varying,
    onda_1_code character varying(32),
    descr text,
    available_for_shop boolean DEFAULT false,
    available_for_membership_renewal boolean DEFAULT false,
    onda_2_code character varying(32),
    onda_1_cnt integer,
    onda_2_cnt integer,
    onda_1_type integer,
    onda_2_type integer,
    is_association boolean
);


--
-- Name: skysight_codes; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.skysight_codes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    assigned_at timestamp without time zone,
    assigned_to_id uuid,
    expires_at timestamp without time zone
);


--
-- Name: tickets; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    number integer NOT NULL,
    number_short integer,
    member_id uuid,
    state character varying DEFAULT 'NEW'::character varying NOT NULL,
    aircraft_id uuid,
    takeoff_airfield_id uuid,
    landing_airfield_id uuid,
    pilot1_id uuid,
    pilot1_role character varying,
    pilot2_id uuid,
    pilot2_role character varying,
    tipo_volo_club integer,
    bollini integer,
    height integer,
    launch_type character varying(16),
    aircraft_class character varying(16),
    instruction_flight boolean,
    skill_test boolean,
    proficiency_test boolean,
    maintenance_flight boolean,
    source character varying,
    source_id integer
);


--
-- Name: tickets_number_seq; Type: SEQUENCE; Schema: acao; Owner: -
--

CREATE SEQUENCE acao.tickets_number_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tickets_number_seq; Type: SEQUENCE OWNED BY; Schema: acao; Owner: -
--

ALTER SEQUENCE acao.tickets_number_seq OWNED BY acao.tickets.number;


--
-- Name: timetable_entries; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.timetable_entries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    aircraft_id uuid,
    pilot_id_old uuid,
    takeoff_at timestamp with time zone,
    takeoff_at_detected timestamp with time zone,
    takeoff_location_id uuid,
    takeoff_lat double precision,
    takeoff_lng double precision,
    takeoff_alt double precision,
    takeoff_airfield_id uuid,
    takeoff_runway character varying(32),
    landing_at timestamp with time zone,
    landing_at_detected timestamp with time zone,
    landing_location_id uuid,
    landing_airfield_id uuid,
    landing_lat double precision,
    landing_lng double precision,
    landing_alt double precision,
    landing_runway character varying(32),
    landing_circuit character varying(32),
    towed_by_id uuid,
    tow_release_at timestamp without time zone,
    tow_release_at_detected timestamp without time zone,
    tow_release_location_id uuid,
    tow_release_lat double precision,
    tow_release_lng double precision,
    tow_release_alt double precision,
    tow_height integer,
    tow_duration integer,
    takeoff_method character varying(32),
    landing_method character varying(32),
    pilot_id uuid
);


--
-- Name: token_transactions; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.token_transactions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    prev_credit numeric(14,6),
    credit numeric(14,6),
    amount numeric(14,6) NOT NULL,
    descr character varying NOT NULL,
    old_id integer,
    old_operator character varying,
    old_marche_mezzo character varying,
    aircraft_id uuid,
    person_id uuid,
    session_id uuid,
    member_id uuid NOT NULL,
    flight_id uuid,
    invoice_id uuid,
    operator_id uuid
);


--
-- Name: tow_roster_days; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.tow_roster_days (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    date date NOT NULL,
    needed_people integer DEFAULT 4 NOT NULL,
    descr character varying
);


--
-- Name: tow_roster_entries; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.tow_roster_entries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    selected_at timestamp with time zone NOT NULL,
    day_id uuid NOT NULL,
    person_id uuid,
    member_id uuid
);


--
-- Name: tows; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.tows (
    id uuid NOT NULL,
    height integer NOT NULL,
    towplane_id uuid NOT NULL,
    glider_id uuid NOT NULL
);


--
-- Name: trackers; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.trackers (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type character varying NOT NULL,
    identifier character varying NOT NULL,
    aircraft_id uuid
);


--
-- Name: trk_events_id_seq; Type: SEQUENCE; Schema: acao; Owner: -
--

CREATE SEQUENCE acao.trk_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trk_events_id_seq; Type: SEQUENCE OWNED BY; Schema: acao; Owner: -
--

ALTER SEQUENCE acao.trk_events_id_seq OWNED BY acao.radar_events.id;


--
-- Name: wol_targets; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.wol_targets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    symbol character varying(32),
    name character varying(64) NOT NULL,
    interface character varying(64) NOT NULL,
    mac macaddr NOT NULL
);


--
-- Name: years; Type: TABLE; Schema: acao; Owner: -
--

CREATE TABLE acao.years (
    year integer NOT NULL,
    renew_opening_time timestamp with time zone,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    renew_announce_time timestamp with time zone,
    late_renewal_deadline timestamp without time zone NOT NULL
);


--
-- Name: certificate_altnames; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.certificate_altnames (
    id integer NOT NULL,
    type character varying(32),
    name character varying,
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    certificate_id uuid NOT NULL
);


--
-- Name: ca_certificate_altnames_id_seq; Type: SEQUENCE; Schema: ca; Owner: -
--

CREATE SEQUENCE ca.ca_certificate_altnames_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ca_certificate_altnames_id_seq; Type: SEQUENCE OWNED BY; Schema: ca; Owner: -
--

ALTER SEQUENCE ca.ca_certificate_altnames_id_seq OWNED BY ca.certificate_altnames.id;


--
-- Name: cas; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.cas (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(64) NOT NULL,
    descr character varying(255),
    notes text,
    key_pair_id uuid,
    certificate_id uuid
);


--
-- Name: certificates; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.certificates (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cn character varying(255),
    email character varying(255),
    notes text,
    pem text,
    valid_from timestamp without time zone,
    valid_to timestamp without time zone,
    serial character varying(255),
    issuer_cn character varying(255),
    subject_dn text,
    issuer_dn text,
    le_uri character varying,
    key_pair_id uuid
);


--
-- Name: key_pair_locations; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.key_pair_locations (
    identifier character varying(64),
    path character varying,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    store_id uuid NOT NULL,
    pair_id uuid NOT NULL
);


--
-- Name: key_pairs; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.key_pairs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    key_type character varying(32),
    key_length integer,
    notes text,
    descr text,
    public_key_hash character varying(64) NOT NULL,
    public_key text NOT NULL
);


--
-- Name: key_stores; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.key_stores (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    sti_type character varying,
    symbol character varying(32),
    descr character varying,
    local_directory character varying,
    remote_agent_id uuid
);


--
-- Name: le_accounts; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.le_accounts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email_contact character varying,
    endpoint character varying,
    symbol character varying(32),
    descr character varying,
    account_url character varying,
    key_pair_id uuid NOT NULL
);


--
-- Name: le_order_auth_challenges; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.le_order_auth_challenges (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    status character varying(32),
    type character varying(32),
    url character varying,
    token character varying,
    last_check timestamp with time zone,
    started_at timestamp with time zone,
    error_type character varying,
    error_status character varying,
    error_detail character varying,
    sti_type character varying,
    my_status character varying(32) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    order_auth_id uuid NOT NULL
);


--
-- Name: le_order_auths; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.le_order_auths (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    status character varying(32),
    expires_at timestamp with time zone,
    identifier_type character varying(32),
    identifier_value character varying,
    wildcard boolean,
    url character varying NOT NULL,
    order_id uuid NOT NULL
);


--
-- Name: le_orders; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.le_orders (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    not_before timestamp with time zone,
    not_after timestamp with time zone,
    expires timestamp with time zone,
    finalize_url character varying,
    status character varying(32),
    url character varying,
    csr text,
    certificate_url character varying,
    created_at timestamp with time zone,
    certificate_id uuid,
    account_id uuid NOT NULL,
    slot_id uuid
);


--
-- Name: le_slots; Type: TABLE; Schema: ca; Owner: -
--

CREATE TABLE ca.le_slots (
    csr_attrs json NOT NULL,
    key_store_path character varying NOT NULL,
    wanted_key character varying(64),
    gen_key_type character varying(32),
    gen_key_length integer,
    owner_type character varying,
    enabled boolean DEFAULT true NOT NULL,
    renew_at timestamp with time zone,
    key_store_id uuid NOT NULL,
    certificate_id uuid,
    account_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    owner_id uuid
);


--
-- Name: agents; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.agents (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    exchange character varying NOT NULL,
    descr character varying,
    symbol character varying(32),
    should_be_running boolean DEFAULT false NOT NULL,
    last_register timestamp without time zone,
    version character varying(10) DEFAULT NULL::character varying,
    installed_version character varying(10) DEFAULT NULL::character varying,
    started_on timestamp without time zone,
    hostname character varying(255) DEFAULT NULL::character varying,
    environment character varying(64) DEFAULT NULL::character varying
);


--
-- Name: global_roles; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.global_roles (
    name character varying(32) NOT NULL,
    descr character varying(255),
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: group_members; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.group_members (
    identity_id integer,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    person_id uuid NOT NULL,
    group_id uuid NOT NULL
);


--
-- Name: groups; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.groups (
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(255),
    description text,
    symbol character varying(64),
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: iso_countries; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.iso_countries (
    a2 character(2) NOT NULL,
    a3 character(3) NOT NULL,
    number integer NOT NULL,
    area_code character varying(4),
    currency character varying(40),
    english character varying(64),
    french character varying(64),
    spanish character varying(64),
    italian character varying(64),
    german character varying(64),
    dlv_group character varying(2),
    dlv_days integer,
    have_zip boolean NOT NULL
);


--
-- Name: klass_collection_role_defs; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.klass_collection_role_defs (
    uuid character varying(36) DEFAULT public.gen_random_uuid() NOT NULL,
    interface character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    all_readable boolean DEFAULT false NOT NULL,
    all_writable boolean DEFAULT false NOT NULL,
    all_creatable boolean DEFAULT false NOT NULL,
    allow_all_actions boolean DEFAULT false NOT NULL,
    actions text NOT NULL,
    attrs text NOT NULL,
    klass_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: klass_members_role_defs; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.klass_members_role_defs (
    id character varying(36) DEFAULT public.gen_random_uuid() NOT NULL,
    interface character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    all_readable boolean DEFAULT false NOT NULL,
    all_writable boolean DEFAULT false NOT NULL,
    all_creatable boolean DEFAULT false NOT NULL,
    allow_all_actions boolean DEFAULT false NOT NULL,
    actions text NOT NULL,
    attrs text NOT NULL,
    klass_id uuid NOT NULL
);


--
-- Name: klasses; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.klasses (
    name character varying(128) NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: locations; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.locations (
    street_address text,
    city character varying(64),
    state character varying(64),
    country_code character varying(2),
    zip character varying(12),
    lat double precision,
    lng double precision,
    provider character varying(16),
    accuracy double precision,
    location_type character varying(32),
    region character varying(128),
    alt double precision,
    raw_address character varying,
    province character varying,
    raw_data json,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: log_entries; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.log_entries (
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "timestamp" timestamp without time zone NOT NULL,
    transaction_id uuid,
    description text NOT NULL,
    notes text,
    extra_info text,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    person_id uuid,
    http_session_id uuid
);


--
-- Name: log_entry_details; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.log_entry_details (
    operation character varying(32),
    obj_type character varying(255),
    obj_id uuid,
    obj_key text,
    obj_snapshot text,
    log_entry_id uuid,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: notif_templates; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.notif_templates (
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id uuid NOT NULL,
    symbol character varying(32) NOT NULL,
    subject text NOT NULL,
    body text,
    additional_headers text,
    language_id uuid NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.notifications (
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id character varying(36) NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    obj_type character varying(255),
    importance character varying(32) NOT NULL,
    subject text,
    body text,
    headers text,
    obj_id uuid,
    person_id uuid
);


--
-- Name: organization_people; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.organization_people (
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    adm_level character varying(16),
    organization_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    person_id uuid NOT NULL
);


--
-- Name: organizations; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.organizations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    type character varying(3),
    name character varying(255),
    vat_number character varying(16),
    italian_fiscal_code character varying(16),
    notes text,
    handle character varying(16),
    reseller_id integer,
    invoice_profile_id integer,
    invoice_last timestamp without time zone,
    invoice_months integer DEFAULT 2,
    invoice_ceiling numeric(14,6),
    invoice_floor numeric(14,6),
    old_src_id integer,
    old_first_name text,
    old_last_name text,
    old_gender text,
    old_birth_date date,
    old_birth_location_id integer,
    headquarters_location_id uuid,
    invoicing_location_id uuid,
    registered_office_location_id uuid,
    admin_group_id uuid
);


--
-- Name: people; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.people (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying(16),
    first_name character varying(64) NOT NULL,
    middle_name character varying(64),
    last_name character varying(64) NOT NULL,
    nickname character varying(32),
    gender character varying(1),
    birth_date timestamp without time zone,
    id_document_type character varying(255),
    id_document_number character varying(255),
    vat_number character varying(16),
    italian_fiscal_code character varying(16),
    notes text,
    handle character varying(16),
    reseller_id integer,
    acao_ext_id integer,
    acao_code integer,
    invoice_profile_id integer,
    invoice_last timestamp without time zone,
    invoice_months integer DEFAULT 2,
    invoice_ceiling numeric(14,6),
    invoice_floor numeric(14,6),
    acao_last_notify_run timestamp with time zone,
    acao_sleeping boolean DEFAULT false NOT NULL,
    acao_bar_credit numeric(14,6) DEFAULT 0 NOT NULL,
    acao_bollini numeric(14,6) DEFAULT 0 NOT NULL,
    acao_bar_last_summary timestamp with time zone,
    acao_roster_chief boolean DEFAULT false NOT NULL,
    acao_roster_allowed boolean DEFAULT false NOT NULL,
    acao_is_student boolean DEFAULT false NOT NULL,
    acao_is_tug_pilot boolean DEFAULT false NOT NULL,
    acao_is_board_member boolean DEFAULT false NOT NULL,
    acao_is_instructor boolean DEFAULT false NOT NULL,
    acao_is_fireman boolean DEFAULT false NOT NULL,
    acao_has_disability boolean DEFAULT false NOT NULL,
    acao_email_allowed boolean DEFAULT false NOT NULL,
    acao_job character varying,
    sdi_code character varying(32),
    acao_ml_students boolean DEFAULT false NOT NULL,
    acao_ml_instructors boolean DEFAULT false NOT NULL,
    acao_ml_tug_pilots boolean DEFAULT false NOT NULL,
    acao_ml_blabla boolean DEFAULT false NOT NULL,
    acao_ml_secondoperiodo boolean DEFAULT false NOT NULL,
    acao_lastmod timestamp with time zone,
    acao_debtor boolean DEFAULT false NOT NULL,
    acao_visita_lastmod timestamp with time zone,
    acao_licenza_lastmod timestamp with time zone,
    birth_location_id uuid,
    invoicing_location_id uuid,
    residence_location_id uuid,
    preferred_language_id uuid
);


--
-- Name: person_contacts; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.person_contacts (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type character varying(32) NOT NULL,
    value character varying NOT NULL,
    descr character varying,
    person_id uuid NOT NULL
);


--
-- Name: person_credentials; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.person_credentials (
    sti_type character varying(64) NOT NULL,
    descr text,
    data text NOT NULL,
    x509_m_serial character varying(32),
    x509_i_dn character varying(255),
    x509_s_dn character varying(255),
    x509_s_dn_cn character varying(255),
    x509_s_dn_email character varying(255),
    expires_at timestamp without time zone,
    fqda character varying NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    person_id uuid NOT NULL
);


--
-- Name: person_email_validation_tokens; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.person_email_validation_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    person_email_id uuid NOT NULL,
    code character varying NOT NULL,
    created_at timestamp without time zone,
    expires_at timestamp without time zone
);


--
-- Name: person_emails; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.person_emails (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    person_id uuid NOT NULL,
    email character varying NOT NULL,
    ml_address_id uuid
);


--
-- Name: person_roles; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.person_roles (
    identity_id integer,
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    global_role_id uuid NOT NULL,
    person_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: replica_notifies; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.replica_notifies (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    obj_type character varying NOT NULL,
    version_needed integer NOT NULL,
    notify_obj_type character varying NOT NULL,
    data character varying,
    identifier character varying(32),
    obj_id uuid,
    notify_obj_id uuid
);


--
-- Name: replicas; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.replicas (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    obj_type character varying NOT NULL,
    identifier character varying NOT NULL,
    state character varying(32) DEFAULT 'UNKNOWN'::character varying NOT NULL,
    version_needed integer NOT NULL,
    version_pending integer NOT NULL,
    version_done integer NOT NULL,
    descr character varying,
    data json,
    function character varying(32),
    obj_id uuid NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.sessions (
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    http_remote_addr character varying(42),
    http_remote_port integer,
    http_x_forwarded_for text,
    http_via text,
    http_server_addr character varying(42),
    http_server_port integer,
    http_server_name character varying(64),
    http_referer text,
    http_user_agent text,
    http_request_uri text,
    auth_identity_id integer,
    auth_method character varying(32),
    auth_confidence character varying(16),
    status character varying(32) DEFAULT 'new'::character varying NOT NULL,
    close_reason character varying(32),
    close_time timestamp without time zone,
    sti_type character varying(255) NOT NULL,
    auth_person_id uuid,
    auth_credential_id uuid,
    language_id uuid,
    expires timestamp with time zone
);


--
-- Name: task_notifies; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.task_notifies (
    obj_type character varying NOT NULL,
    task_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    obj_id uuid
);


--
-- Name: tasks; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.tasks (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone,
    expected_completion timestamp without time zone,
    completed_at timestamp without time zone,
    status character varying(32) NOT NULL,
    description character varying(255),
    agent character varying(64),
    operation character varying(32),
    request_data json,
    result_data json,
    log text DEFAULT ''::text NOT NULL,
    deferred_to timestamp without time zone,
    percent double precision,
    deadline timestamp without time zone,
    version integer DEFAULT 1 NOT NULL,
    updated_at timestamp without time zone,
    awaited_event character varying(32),
    scheduler character varying(32),
    obj_type character varying,
    depends_on_id uuid,
    obj_id uuid
);


--
-- Name: alptherm_history_entries; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.alptherm_history_entries (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    taken_at timestamp without time zone NOT NULL,
    source_id integer NOT NULL,
    data text NOT NULL
);


--
-- Name: alptherm_histories_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.alptherm_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alptherm_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.alptherm_histories_id_seq OWNED BY flarc.alptherm_history_entries.id;


--
-- Name: alptherm_sources; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.alptherm_sources (
    id integer NOT NULL,
    name character varying(255),
    lat double precision,
    lon double precision,
    site_param character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid character varying(36)
);


--
-- Name: alptherm_sources_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.alptherm_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alptherm_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.alptherm_sources_id_seq OWNED BY flarc.alptherm_sources.id;


--
-- Name: championship_flights; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.championship_flights (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    championship_id integer,
    flight_id integer,
    sti_type character varying(255),
    status character varying(8),
    data text,
    distance integer,
    speed double precision,
    cid_ranking character varying(32),
    cid_task_type character varying(32),
    cid_task_eval character varying(32)
);


--
-- Name: championship_flights_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.championship_flights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: championship_flights_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.championship_flights_id_seq OWNED BY flarc.championship_flights.id;


--
-- Name: championship_pilots; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.championship_pilots (
    id integer NOT NULL,
    championship_id integer,
    pilot_id integer,
    csvva_pilot_level character varying(16),
    cid_category character varying(32),
    sti_type character varying(255),
    old_pilot_id integer
);


--
-- Name: championship_pilots_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.championship_pilots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: championship_pilots_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.championship_pilots_id_seq OWNED BY flarc.championship_pilots.id;


--
-- Name: championships; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.championships (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(255),
    icon text,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    driver character varying(16),
    sym character varying(32),
    uuid character varying(36)
);


--
-- Name: championships_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.championships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: championships_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.championships_id_seq OWNED BY flarc.championships.id;


--
-- Name: clubs; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.clubs (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    old_club_id integer,
    symbol character varying(32),
    uuid character varying(36)
);


--
-- Name: clubs_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.clubs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clubs_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.clubs_id_seq OWNED BY flarc.clubs.id;


--
-- Name: flight_photos; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.flight_photos (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    flight_id integer NOT NULL,
    farm_id integer NOT NULL,
    server_id integer NOT NULL,
    photo_id character varying(32) NOT NULL,
    secret character varying(32) NOT NULL,
    lat double precision,
    lon double precision,
    url text,
    caption text
);


--
-- Name: flight_photos_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.flight_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flight_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.flight_photos_id_seq OWNED BY flarc.flight_photos.id;


--
-- Name: flight_tags; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.flight_tags (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tag_id integer NOT NULL,
    flight_id integer NOT NULL,
    status character varying(8),
    data text,
    sti_type character varying(64),
    distance integer,
    speed integer
);


--
-- Name: flight_tags_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.flight_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flight_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.flight_tags_id_seq OWNED BY flarc.flight_tags.id;


--
-- Name: flights; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.flights (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pilot_id integer NOT NULL,
    plane_id integer,
    plane_type_configuration_id integer,
    takeoff_time timestamp without time zone NOT NULL,
    landing_time timestamp without time zone NOT NULL,
    distance double precision,
    passenger_id integer,
    private boolean NOT NULL,
    logger_date date,
    passenger_name character varying(64),
    igc_fr_serial character varying(3),
    igc_fr_fotd integer,
    igc_fr_manuf character(3),
    speed double precision,
    notes_flarc text,
    notes_private text,
    uuid character varying(36),
    old_pilot_id integer
);


--
-- Name: flights_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.flights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flights_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.flights_id_seq OWNED BY flarc.flights.id;


--
-- Name: glider_classes; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.glider_classes (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid character varying(36)
);


--
-- Name: glider_classes_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.glider_classes_id_seq
    START WITH 1730176943
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: glider_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.glider_classes_id_seq OWNED BY flarc.glider_classes.id;


--
-- Name: igc_tmp_files; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.igc_tmp_files (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    original_filename character varying(64),
    pilot_id integer,
    club_id integer,
    old_pilot_id integer
);


--
-- Name: igc_tmp_files_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.igc_tmp_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: igc_tmp_files_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.igc_tmp_files_id_seq OWNED BY flarc.igc_tmp_files.id;


--
-- Name: pilot_planes; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.pilot_planes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pilot_id integer,
    plane_id integer,
    old_pilot_id integer
);


--
-- Name: pilot_planes_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.pilot_planes_id_seq
    START WITH 1660807168
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pilot_planes_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.pilot_planes_id_seq OWNED BY flarc.pilot_planes.id;


--
-- Name: pilots; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.pilots (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    person_id integer NOT NULL,
    club_id integer,
    fai_card character varying(10),
    gliding_license character varying(20),
    old_pilot_id integer,
    gliding_license_expiration character varying(20),
    uuid character varying(36)
);


--
-- Name: pilots_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.pilots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pilots_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.pilots_id_seq OWNED BY flarc.pilots.id;


--
-- Name: plane_type_configurations; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.plane_type_configurations (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(32) NOT NULL,
    plane_type_id integer NOT NULL,
    handicap double precision NOT NULL,
    club_handicap double precision
);


--
-- Name: plane_type_configurations_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.plane_type_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plane_type_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.plane_type_configurations_id_seq OWNED BY flarc.plane_type_configurations.id;


--
-- Name: plane_types; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.plane_types (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    manufacturer character varying(64) NOT NULL,
    name character varying(32) NOT NULL,
    seats integer,
    motor integer,
    handicap double precision,
    link_wp character varying(255),
    club_handicap double precision
);


--
-- Name: plane_types_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.plane_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plane_types_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.plane_types_id_seq OWNED BY flarc.plane_types.id;


--
-- Name: planes; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.planes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    registration character varying(8) NOT NULL,
    plane_type_id integer NOT NULL,
    uuid character varying(36)
);


--
-- Name: planes_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.planes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planes_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.planes_id_seq OWNED BY flarc.planes.id;


--
-- Name: ranking_club_standing_history_entries; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.ranking_club_standing_history_entries (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    club_standing_id integer NOT NULL,
    snapshot_time timestamp without time zone,
    "position" integer,
    value double precision,
    data text
);


--
-- Name: ranking_club_standing_history_entries_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.ranking_club_standing_history_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranking_club_standing_history_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.ranking_club_standing_history_entries_id_seq OWNED BY flarc.ranking_club_standing_history_entries.id;


--
-- Name: ranking_club_standings; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.ranking_club_standings (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ranking_id integer NOT NULL,
    club_id integer NOT NULL,
    "position" integer,
    value double precision,
    data text
);


--
-- Name: ranking_club_standings_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.ranking_club_standings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranking_club_standings_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.ranking_club_standings_id_seq OWNED BY flarc.ranking_club_standings.id;


--
-- Name: ranking_flights; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.ranking_flights (
    id integer NOT NULL,
    ranking_id integer,
    flight_id integer,
    status character varying(8)
);


--
-- Name: ranking_flights_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.ranking_flights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranking_flights_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.ranking_flights_id_seq OWNED BY flarc.ranking_flights.id;


--
-- Name: ranking_groups; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.ranking_groups (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: ranking_groups_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.ranking_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranking_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.ranking_groups_id_seq OWNED BY flarc.ranking_groups.id;


--
-- Name: ranking_standing_history_entries; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.ranking_standing_history_entries (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    standing_id integer NOT NULL,
    snapshot_time timestamp without time zone,
    "position" integer,
    value double precision,
    data text
);


--
-- Name: ranking_history_entry_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.ranking_history_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranking_history_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.ranking_history_entry_id_seq OWNED BY flarc.ranking_standing_history_entries.id;


--
-- Name: ranking_standings; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.ranking_standings (
    ranking_id integer,
    pilot_id integer,
    "position" integer,
    value double precision,
    data text,
    id integer NOT NULL,
    flight_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    old_pilot_id integer
);


--
-- Name: ranking_standings_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.ranking_standings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranking_standings_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.ranking_standings_id_seq OWNED BY flarc.ranking_standings.id;


--
-- Name: rankings; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.rankings (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(255),
    official boolean,
    priority integer,
    color character varying(6),
    driver character varying(16),
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    group_id integer,
    sym character varying(32),
    championship_id integer,
    icon text,
    uuid character varying(36),
    sti_type character varying(63)
);


--
-- Name: rankings_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.rankings_id_seq OWNED BY flarc.rankings.id;


--
-- Name: tag_groups; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.tag_groups (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(255)
);


--
-- Name: tag_groups_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.tag_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.tag_groups_id_seq OWNED BY flarc.tag_groups.id;


--
-- Name: tags; Type: TABLE; Schema: flarc; Owner: -
--

CREATE TABLE flarc.tags (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    sym character varying(32),
    name character varying(255),
    group_id integer,
    requires_approval boolean,
    color character varying(6),
    ranking_id integer,
    icon text,
    depends_on_championship_id integer,
    uuid character varying(36)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: flarc; Owner: -
--

CREATE SEQUENCE flarc.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: flarc; Owner: -
--

ALTER SEQUENCE flarc.tags_id_seq OWNED BY flarc.tags.id;


--
-- Name: languages; Type: TABLE; Schema: i18n; Owner: -
--

CREATE TABLE i18n.languages (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    iso_639_3 character(3) NOT NULL,
    descr character varying NOT NULL,
    iso_639_1 character(2)
);


--
-- Name: phrases; Type: TABLE; Schema: i18n; Owner: -
--

CREATE TABLE i18n.phrases (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    phrase character varying NOT NULL
);


--
-- Name: translations; Type: TABLE; Schema: i18n; Owner: -
--

CREATE TABLE i18n.translations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    value text NOT NULL,
    language_id uuid NOT NULL,
    phrase_id uuid NOT NULL
);


--
-- Name: address_validation_tokens; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.address_validation_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address_id uuid NOT NULL,
    code character varying NOT NULL,
    created_at timestamp without time zone,
    expires_at timestamp without time zone,
    used_at timestamp without time zone,
    http_remote_addr character varying(42),
    http_remote_port integer,
    http_x_forwarded_for text,
    http_via text,
    http_server_addr character varying(42),
    http_server_port integer,
    http_server_name character varying(64),
    http_referer text,
    http_user_agent text,
    http_request_uri text
);


--
-- Name: addresses; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.addresses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    addr character varying NOT NULL,
    name character varying,
    addr_type character varying(32) NOT NULL,
    failed_deliveries integer DEFAULT 0 NOT NULL,
    validated boolean DEFAULT false NOT NULL,
    validated_at timestamp without time zone,
    reliable boolean DEFAULT true NOT NULL,
    reliability_score integer DEFAULT 100 NOT NULL
);


--
-- Name: list_members; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.list_members (
    subscribed_on timestamp with time zone NOT NULL,
    consent_session_id integer,
    owner_type character varying(64),
    address_id uuid NOT NULL,
    list_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    owner_id uuid
);


--
-- Name: lists; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.lists (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    descr character varying,
    symbol character varying(32)
);


--
-- Name: msg_rcpts; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.msg_rcpts (
    id integer NOT NULL,
    address_id integer NOT NULL,
    submitted_on timestamp without time zone,
    msg_id integer NOT NULL
);


--
-- Name: ml_msg_rcpts_id_seq; Type: SEQUENCE; Schema: ml; Owner: -
--

CREATE SEQUENCE ml.ml_msg_rcpts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ml_msg_rcpts_id_seq; Type: SEQUENCE OWNED BY; Schema: ml; Owner: -
--

ALTER SEQUENCE ml.ml_msg_rcpts_id_seq OWNED BY ml.msg_rcpts.id;


--
-- Name: msg_bounces; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.msg_bounces (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    body text,
    sender character varying,
    score integer DEFAULT 0 NOT NULL,
    rem_arrival_date timestamp without time zone,
    reporting_mta character varying,
    received_at timestamp with time zone,
    rem_postfix_queue_id character varying,
    rem_postfix_sender character varying,
    action character varying,
    diagnostic_code character varying,
    status character varying,
    original_recipient character varying,
    final_recipient character varying,
    reporting_ua character varying,
    disposition character varying,
    disposition_error character varying,
    type character varying(32),
    original_recipient_type character varying(32),
    final_recipient_type character varying(32),
    status_comment character varying,
    msg_id uuid NOT NULL
);


--
-- Name: msg_events; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.msg_events (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    at timestamp with time zone NOT NULL,
    event character varying(32) NOT NULL,
    descr text,
    msg_id uuid NOT NULL
);


--
-- Name: msg_lists; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.msg_lists (
    list_id uuid NOT NULL,
    msg_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- Name: msg_objects; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.msg_objects (
    object_type character varying NOT NULL,
    msg_id uuid NOT NULL,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    object_id uuid
);


--
-- Name: msgs; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.msgs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    message text NOT NULL,
    abstract character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    delivery_started_at timestamp without time zone,
    email_message_id character varying(32),
    status character varying(32),
    type character varying(64) NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    receipt_code character varying(64),
    delivery_successful_at timestamp with time zone,
    delivery_last_attempt_at timestamp with time zone,
    email_mdn_request boolean DEFAULT false NOT NULL,
    email_data_response character varying,
    skebby_order character varying,
    submitted_at timestamp with time zone,
    status_reason character varying,
    skebby_status character varying(32),
    retry_at timestamp with time zone,
    person_id uuid,
    recipient_id uuid NOT NULL,
    sender_id uuid
);


--
-- Name: senders; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.senders (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    email_address character varying NOT NULL,
    email_signing_key_filename character varying,
    email_signing_cert_filename character varying,
    symbol character varying(32),
    descr text,
    email_bounces_domain character varying,
    email_reply_to character varying,
    email_organization character varying,
    email_smtp_pars text,
    skebby_username character varying(32),
    skebby_password character varying(32),
    skebby_sender_number character varying(32),
    skebby_sender_string character varying(32),
    email_dkim_selector character varying(32),
    skebby_token character varying,
    skebby_user_key character varying,
    email_dkim_key_pair_id uuid
);


--
-- Name: templates; Type: TABLE; Schema: ml; Owner: -
--

CREATE TABLE ml.templates (
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    symbol character varying(32) NOT NULL,
    subject text NOT NULL,
    body text,
    additional_headers text,
    content_type character varying DEFAULT 'text/plain'::character varying NOT NULL,
    language_id uuid
);


--
-- Name: a; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.a (
    a integer
);


--
-- Name: acao_bar_transactions_acl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acao_bar_transactions_acl (
    id bigint NOT NULL,
    obj_id bigint NOT NULL,
    person_id bigint,
    group_id bigint,
    capability character varying(64) NOT NULL,
    owner_type character varying,
    owner_id bigint
);


--
-- Name: acao_bar_transactions_acl_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.acao_bar_transactions_acl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: acao_bar_transactions_acl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.acao_bar_transactions_acl_id_seq OWNED BY public.acao_bar_transactions_acl.id;


--
-- Name: acao_memberships_acl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acao_memberships_acl (
    id bigint NOT NULL,
    obj_id bigint NOT NULL,
    person_id bigint,
    group_id bigint,
    capability character varying(64) NOT NULL,
    owner_type character varying,
    owner_id bigint
);


--
-- Name: acao_memberships_acl_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.acao_memberships_acl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: acao_memberships_acl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.acao_memberships_acl_id_seq OWNED BY public.acao_memberships_acl.id;


--
-- Name: acao_payments_acl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.acao_payments_acl (
    id bigint NOT NULL,
    obj_id bigint NOT NULL,
    person_id bigint,
    group_id bigint,
    capability character varying(64) NOT NULL,
    owner_type character varying,
    owner_id bigint
);


--
-- Name: acao_payments_acl_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.acao_payments_acl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: acao_payments_acl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.acao_payments_acl_id_seq OWNED BY public.acao_payments_acl.id;


--
-- Name: active_planes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_planes (
    id integer NOT NULL,
    plane_id integer NOT NULL,
    flying_state character varying(32),
    towing_state character varying(32),
    towed_plane_id integer
);


--
-- Name: active_planes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_planes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_planes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_planes_id_seq OWNED BY public.active_planes.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: b; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b (
    b integer
);


--
-- Name: core_organizations_acl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_organizations_acl (
    id bigint NOT NULL,
    obj_id bigint NOT NULL,
    person_id bigint,
    group_id bigint,
    role character varying(64) NOT NULL,
    owner_type character varying,
    owner_id bigint
);


--
-- Name: core_organizations_acl_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.core_organizations_acl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: core_organizations_acl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.core_organizations_acl_id_seq OWNED BY public.core_organizations_acl.id;


--
-- Name: core_people_acl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_people_acl (
    id bigint NOT NULL,
    obj_id bigint NOT NULL,
    person_id bigint,
    group_id bigint,
    role character varying(64) NOT NULL,
    owner_type character varying,
    owner_id bigint
);


--
-- Name: core_people_acl_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.core_people_acl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: core_people_acl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.core_people_acl_id_seq OWNED BY public.core_people_acl.id;


--
-- Name: flights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flights (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid character varying(36) NOT NULL,
    acao_ext_id integer NOT NULL,
    plane_pilot1_id integer,
    plane_pilot2_id integer,
    towplane_pilot1_id integer,
    towplane_pilot2_id integer,
    plane_id integer,
    towplane_id integer,
    takeoff_at timestamp without time zone,
    landing_at timestamp without time zone,
    towplane_landing_at timestamp without time zone,
    tipo_volo_club integer,
    tipo_aereo_aliante integer,
    durata_volo_aereo_minuti integer,
    durata_volo_aliante_minuti integer,
    quota integer,
    bollini_volo numeric(14,6),
    check_chiuso boolean,
    dep character varying(64),
    arr character varying(64),
    num_att integer,
    data_att timestamp without time zone
);


--
-- Name: flights_acl; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flights_acl (
    id integer NOT NULL,
    obj_id integer NOT NULL,
    identity_id integer,
    group_id integer,
    capability character varying(64) NOT NULL
);


--
-- Name: flights_acl_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flights_acl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flights_acl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flights_acl_id_seq OWNED BY public.flights_acl.id;


--
-- Name: flights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flights_id_seq OWNED BY public.flights.id;


--
-- Name: idxc_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idxc_entries (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    obj_type character varying(255) NOT NULL,
    obj_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    accessible boolean,
    person_id uuid NOT NULL
);


--
-- Name: idxc_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idxc_statuses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    obj_type character varying(255) NOT NULL,
    updated_at timestamp without time zone DEFAULT now(),
    has_dirty boolean DEFAULT false NOT NULL,
    person_id uuid NOT NULL
);


--
-- Name: maindb_last_update; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maindb_last_update (
    tablename character varying(32) NOT NULL,
    last_update timestamp with time zone,
    id integer NOT NULL
);


--
-- Name: maindb_last_update_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maindb_last_update_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maindb_last_update_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maindb_last_update_id_seq OWNED BY public.maindb_last_update.id;


--
-- Name: met_history_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.met_history_entries (
    id integer NOT NULL,
    ts timestamp with time zone NOT NULL,
    record_ts timestamp with time zone NOT NULL,
    source character varying(32) NOT NULL,
    variable character varying(32) NOT NULL,
    value character varying NOT NULL
);


--
-- Name: met_history_entries2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.met_history_entries2 (
    id integer,
    ts timestamp with time zone,
    record_ts timestamp with time zone,
    source character varying(32),
    variable character varying(32),
    value character varying
);


--
-- Name: met_history_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.met_history_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: met_history_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.met_history_entries_id_seq OWNED BY public.met_history_entries.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pg_search_documents (
    id integer NOT NULL,
    content text,
    searchable_type character varying,
    searchable_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pg_search_documents_id_seq OWNED BY public.pg_search_documents.id;


--
-- Name: radacct; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.radacct (
    radacctid bigint NOT NULL,
    acctsessionid character varying(64) NOT NULL,
    acctuniqueid character varying(32) NOT NULL,
    username character varying(253),
    groupname character varying(253),
    realm character varying(64),
    nasipaddress inet NOT NULL,
    nasportid character varying(15),
    nasporttype character varying(32),
    acctstarttime timestamp with time zone,
    acctstoptime timestamp with time zone,
    acctsessiontime bigint,
    acctauthentic character varying(32),
    connectinfo_start character varying(50),
    connectinfo_stop character varying(50),
    acctinputoctets bigint,
    acctoutputoctets bigint,
    calledstationid character varying(50),
    callingstationid character varying(50),
    acctterminatecause character varying(32),
    servicetype character varying(32),
    xascendsessionsvrkey character varying(10),
    framedprotocol character varying(32),
    framedipaddress inet,
    acctstartdelay integer,
    acctstopdelay integer
);


--
-- Name: radacct_radacctid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.radacct_radacctid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radacct_radacctid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.radacct_radacctid_seq OWNED BY public.radacct.radacctid;


--
-- Name: radcheck; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.radcheck (
    id integer NOT NULL,
    username character varying(64) DEFAULT ''::character varying NOT NULL,
    attribute character varying(64) DEFAULT ''::character varying NOT NULL,
    op character(2) DEFAULT '=='::bpchar NOT NULL,
    value character varying(253) DEFAULT ''::character varying NOT NULL
);


--
-- Name: radcheck_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.radcheck_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radcheck_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.radcheck_id_seq OWNED BY public.radcheck.id;


--
-- Name: radgroupcheck; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.radgroupcheck (
    id integer NOT NULL,
    groupname character varying(64) DEFAULT ''::character varying NOT NULL,
    attribute character varying(64) DEFAULT ''::character varying NOT NULL,
    op character(2) DEFAULT '=='::bpchar NOT NULL,
    value character varying(253) DEFAULT ''::character varying NOT NULL
);


--
-- Name: radgroupcheck_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.radgroupcheck_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radgroupcheck_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.radgroupcheck_id_seq OWNED BY public.radgroupcheck.id;


--
-- Name: radgroupreply; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.radgroupreply (
    id integer NOT NULL,
    groupname character varying(64) DEFAULT ''::character varying NOT NULL,
    attribute character varying(64) DEFAULT ''::character varying NOT NULL,
    op character(2) DEFAULT '='::bpchar NOT NULL,
    value character varying(253) DEFAULT ''::character varying NOT NULL
);


--
-- Name: radgroupreply_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.radgroupreply_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radgroupreply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.radgroupreply_id_seq OWNED BY public.radgroupreply.id;


--
-- Name: radpostauth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.radpostauth (
    id bigint NOT NULL,
    username character varying(253) NOT NULL,
    pass character varying(128),
    reply character varying(32),
    calledstationid character varying(50),
    callingstationid character varying(50),
    authdate timestamp with time zone DEFAULT '2016-02-21 11:29:59.754297+01'::timestamp with time zone NOT NULL
);


--
-- Name: radpostauth_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.radpostauth_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radpostauth_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.radpostauth_id_seq OWNED BY public.radpostauth.id;


--
-- Name: radreply; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.radreply (
    id integer NOT NULL,
    username character varying(64) DEFAULT ''::character varying NOT NULL,
    attribute character varying(64) DEFAULT ''::character varying NOT NULL,
    op character(2) DEFAULT '='::bpchar NOT NULL,
    value character varying(253) DEFAULT ''::character varying NOT NULL
);


--
-- Name: radreply_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.radreply_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radreply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.radreply_id_seq OWNED BY public.radreply.id;


--
-- Name: radusergroup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.radusergroup (
    username character varying(64) DEFAULT ''::character varying NOT NULL,
    groupname character varying(64) DEFAULT ''::character varying NOT NULL,
    priority integer DEFAULT 0 NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: str_channel_variants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.str_channel_variants (
    id integer NOT NULL,
    channel_id integer NOT NULL,
    symbol character varying(32) NOT NULL,
    stream_url character varying NOT NULL,
    width integer,
    height integer,
    bandwidth integer,
    name character varying(32),
    autostart boolean DEFAULT true NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: str_channel_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.str_channel_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: str_channel_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.str_channel_variants_id_seq OWNED BY public.str_channel_variants.id;


--
-- Name: str_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.str_channels (
    id integer NOT NULL,
    uuid uuid DEFAULT public.gen_random_uuid(),
    name character varying,
    descr character varying,
    poster character varying,
    symbol character varying(32) NOT NULL,
    agent_id integer,
    version integer DEFAULT 0 NOT NULL,
    condemned boolean DEFAULT false NOT NULL
);


--
-- Name: str_channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.str_channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: str_channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.str_channels_id_seq OWNED BY public.str_channels.id;


--
-- Name: sync_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sync_status (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    symbol character varying(255) NOT NULL,
    synced_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: trk_contest_days; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trk_contest_days (
    id integer NOT NULL,
    uuid character varying(36) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    contest_id integer NOT NULL,
    date date NOT NULL,
    task boolean NOT NULL,
    valid_day boolean NOT NULL,
    cuc_file text
);


--
-- Name: trk_contest_days_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trk_contest_days_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trk_contest_days_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trk_contest_days_id_seq OWNED BY public.trk_contest_days.id;


--
-- Name: trk_contests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trk_contests (
    id integer NOT NULL,
    uuid character varying(36) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(32) NOT NULL,
    display_name text NOT NULL,
    data_delay integer,
    utc_offset integer NOT NULL,
    country_code character(2) NOT NULL,
    site text NOT NULL,
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    alt double precision NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL
);


--
-- Name: trk_contests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trk_contests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trk_contests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trk_contests_id_seq OWNED BY public.trk_contests.id;


--
-- Name: trk_day_aircrafts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trk_day_aircrafts (
    id integer NOT NULL,
    day date NOT NULL,
    aircraft_id integer NOT NULL
);


--
-- Name: trk_day_planes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trk_day_planes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trk_day_planes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trk_day_planes_id_seq OWNED BY public.trk_day_aircrafts.id;


--
-- Name: radar_events id; Type: DEFAULT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.radar_events ALTER COLUMN id SET DEFAULT nextval('acao.trk_events_id_seq'::regclass);


--
-- Name: tickets number; Type: DEFAULT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tickets ALTER COLUMN number SET DEFAULT nextval('acao.tickets_number_seq'::regclass);


--
-- Name: trailers id_old; Type: DEFAULT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.trailers ALTER COLUMN id_old SET DEFAULT nextval('acao.acao_trailers_id_seq'::regclass);


--
-- Name: certificate_altnames id; Type: DEFAULT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.certificate_altnames ALTER COLUMN id SET DEFAULT nextval('ca.ca_certificate_altnames_id_seq'::regclass);


--
-- Name: alptherm_history_entries id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.alptherm_history_entries ALTER COLUMN id SET DEFAULT nextval('flarc.alptherm_histories_id_seq'::regclass);


--
-- Name: alptherm_sources id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.alptherm_sources ALTER COLUMN id SET DEFAULT nextval('flarc.alptherm_sources_id_seq'::regclass);


--
-- Name: championship_flights id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.championship_flights ALTER COLUMN id SET DEFAULT nextval('flarc.championship_flights_id_seq'::regclass);


--
-- Name: championship_pilots id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.championship_pilots ALTER COLUMN id SET DEFAULT nextval('flarc.championship_pilots_id_seq'::regclass);


--
-- Name: championships id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.championships ALTER COLUMN id SET DEFAULT nextval('flarc.championships_id_seq'::regclass);


--
-- Name: clubs id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.clubs ALTER COLUMN id SET DEFAULT nextval('flarc.clubs_id_seq'::regclass);


--
-- Name: flight_photos id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.flight_photos ALTER COLUMN id SET DEFAULT nextval('flarc.flight_photos_id_seq'::regclass);


--
-- Name: flight_tags id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.flight_tags ALTER COLUMN id SET DEFAULT nextval('flarc.flight_tags_id_seq'::regclass);


--
-- Name: flights id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.flights ALTER COLUMN id SET DEFAULT nextval('flarc.flights_id_seq'::regclass);


--
-- Name: glider_classes id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.glider_classes ALTER COLUMN id SET DEFAULT nextval('flarc.glider_classes_id_seq'::regclass);


--
-- Name: igc_tmp_files id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.igc_tmp_files ALTER COLUMN id SET DEFAULT nextval('flarc.igc_tmp_files_id_seq'::regclass);


--
-- Name: pilot_planes id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.pilot_planes ALTER COLUMN id SET DEFAULT nextval('flarc.pilot_planes_id_seq'::regclass);


--
-- Name: pilots id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.pilots ALTER COLUMN id SET DEFAULT nextval('flarc.pilots_id_seq'::regclass);


--
-- Name: plane_type_configurations id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.plane_type_configurations ALTER COLUMN id SET DEFAULT nextval('flarc.plane_type_configurations_id_seq'::regclass);


--
-- Name: plane_types id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.plane_types ALTER COLUMN id SET DEFAULT nextval('flarc.plane_types_id_seq'::regclass);


--
-- Name: planes id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.planes ALTER COLUMN id SET DEFAULT nextval('flarc.planes_id_seq'::regclass);


--
-- Name: ranking_club_standing_history_entries id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_club_standing_history_entries ALTER COLUMN id SET DEFAULT nextval('flarc.ranking_club_standing_history_entries_id_seq'::regclass);


--
-- Name: ranking_club_standings id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_club_standings ALTER COLUMN id SET DEFAULT nextval('flarc.ranking_club_standings_id_seq'::regclass);


--
-- Name: ranking_flights id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_flights ALTER COLUMN id SET DEFAULT nextval('flarc.ranking_flights_id_seq'::regclass);


--
-- Name: ranking_groups id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_groups ALTER COLUMN id SET DEFAULT nextval('flarc.ranking_groups_id_seq'::regclass);


--
-- Name: ranking_standing_history_entries id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_standing_history_entries ALTER COLUMN id SET DEFAULT nextval('flarc.ranking_history_entry_id_seq'::regclass);


--
-- Name: ranking_standings id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_standings ALTER COLUMN id SET DEFAULT nextval('flarc.ranking_standings_id_seq'::regclass);


--
-- Name: rankings id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.rankings ALTER COLUMN id SET DEFAULT nextval('flarc.rankings_id_seq'::regclass);


--
-- Name: tag_groups id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.tag_groups ALTER COLUMN id SET DEFAULT nextval('flarc.tag_groups_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.tags ALTER COLUMN id SET DEFAULT nextval('flarc.tags_id_seq'::regclass);


--
-- Name: msg_rcpts id; Type: DEFAULT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_rcpts ALTER COLUMN id SET DEFAULT nextval('ml.ml_msg_rcpts_id_seq'::regclass);


--
-- Name: acao_bar_transactions_acl id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acao_bar_transactions_acl ALTER COLUMN id SET DEFAULT nextval('public.acao_bar_transactions_acl_id_seq'::regclass);


--
-- Name: acao_memberships_acl id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acao_memberships_acl ALTER COLUMN id SET DEFAULT nextval('public.acao_memberships_acl_id_seq'::regclass);


--
-- Name: acao_payments_acl id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acao_payments_acl ALTER COLUMN id SET DEFAULT nextval('public.acao_payments_acl_id_seq'::regclass);


--
-- Name: active_planes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_planes ALTER COLUMN id SET DEFAULT nextval('public.active_planes_id_seq'::regclass);


--
-- Name: core_organizations_acl id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_organizations_acl ALTER COLUMN id SET DEFAULT nextval('public.core_organizations_acl_id_seq'::regclass);


--
-- Name: core_people_acl id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_people_acl ALTER COLUMN id SET DEFAULT nextval('public.core_people_acl_id_seq'::regclass);


--
-- Name: flights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights ALTER COLUMN id SET DEFAULT nextval('public.flights_id_seq'::regclass);


--
-- Name: flights_acl id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights_acl ALTER COLUMN id SET DEFAULT nextval('public.flights_acl_id_seq'::regclass);


--
-- Name: maindb_last_update id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maindb_last_update ALTER COLUMN id SET DEFAULT nextval('public.maindb_last_update_id_seq'::regclass);


--
-- Name: met_history_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.met_history_entries ALTER COLUMN id SET DEFAULT nextval('public.met_history_entries_id_seq'::regclass);


--
-- Name: pg_search_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents ALTER COLUMN id SET DEFAULT nextval('public.pg_search_documents_id_seq'::regclass);


--
-- Name: radacct radacctid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radacct ALTER COLUMN radacctid SET DEFAULT nextval('public.radacct_radacctid_seq'::regclass);


--
-- Name: radcheck id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radcheck ALTER COLUMN id SET DEFAULT nextval('public.radcheck_id_seq'::regclass);


--
-- Name: radgroupcheck id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radgroupcheck ALTER COLUMN id SET DEFAULT nextval('public.radgroupcheck_id_seq'::regclass);


--
-- Name: radgroupreply id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radgroupreply ALTER COLUMN id SET DEFAULT nextval('public.radgroupreply_id_seq'::regclass);


--
-- Name: radpostauth id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radpostauth ALTER COLUMN id SET DEFAULT nextval('public.radpostauth_id_seq'::regclass);


--
-- Name: radreply id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radreply ALTER COLUMN id SET DEFAULT nextval('public.radreply_id_seq'::regclass);


--
-- Name: str_channel_variants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.str_channel_variants ALTER COLUMN id SET DEFAULT nextval('public.str_channel_variants_id_seq'::regclass);


--
-- Name: str_channels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.str_channels ALTER COLUMN id SET DEFAULT nextval('public.str_channels_id_seq'::regclass);


--
-- Name: trk_contest_days id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trk_contest_days ALTER COLUMN id SET DEFAULT nextval('public.trk_contest_days_id_seq'::regclass);


--
-- Name: trk_contests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trk_contests ALTER COLUMN id SET DEFAULT nextval('public.trk_contests_id_seq'::regclass);


--
-- Name: trk_day_aircrafts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trk_day_aircrafts ALTER COLUMN id SET DEFAULT nextval('public.trk_day_planes_id_seq'::regclass);


--
-- Name: access_remotes access_remotes_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.access_remotes
    ADD CONSTRAINT access_remotes_pkey PRIMARY KEY (id);


--
-- Name: aircraft_owners aircraft_owners_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.aircraft_owners
    ADD CONSTRAINT aircraft_owners_pkey PRIMARY KEY (id);


--
-- Name: aircraft_sync_statuses aircraft_sync_statuses_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.aircraft_sync_statuses
    ADD CONSTRAINT aircraft_sync_statuses_pkey PRIMARY KEY (id);


--
-- Name: aircraft_types aircraft_types_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.aircraft_types
    ADD CONSTRAINT aircraft_types_pkey PRIMARY KEY (id);


--
-- Name: aircrafts aircrafts_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.aircrafts
    ADD CONSTRAINT aircrafts_pkey PRIMARY KEY (id);


--
-- Name: airfield_circuits airfield_circuits_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.airfield_circuits
    ADD CONSTRAINT airfield_circuits_pkey PRIMARY KEY (id);


--
-- Name: airfields airfields_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.airfields
    ADD CONSTRAINT airfields_pkey PRIMARY KEY (id);


--
-- Name: bar_menu_entries bar_menu_entries_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.bar_menu_entries
    ADD CONSTRAINT bar_menu_entries_pkey PRIMARY KEY (id);


--
-- Name: bar_transactions bar_transactions_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.bar_transactions
    ADD CONSTRAINT bar_transactions_pkey PRIMARY KEY (id);


--
-- Name: camera_events camera_events_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.camera_events
    ADD CONSTRAINT camera_events_pkey PRIMARY KEY (id);


--
-- Name: clubs clubs_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- Name: debt_details debt_details_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.debt_details
    ADD CONSTRAINT debt_details_pkey PRIMARY KEY (id);


--
-- Name: debts debts_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.debts
    ADD CONSTRAINT debts_pkey PRIMARY KEY (id);


--
-- Name: fai_cards fai_cards_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.fai_cards
    ADD CONSTRAINT fai_cards_pkey PRIMARY KEY (id);


--
-- Name: flarmnet_entries flarmnet_entries_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flarmnet_entries
    ADD CONSTRAINT flarmnet_entries_pkey PRIMARY KEY (id);


--
-- Name: flights flights_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (id);


--
-- Name: gates gates_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.gates
    ADD CONSTRAINT gates_pkey PRIMARY KEY (id);


--
-- Name: invoice_details invoice_details_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.invoice_details
    ADD CONSTRAINT invoice_details_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: key_fobs key_fobs_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.key_fobs
    ADD CONSTRAINT key_fobs_pkey PRIMARY KEY (id);


--
-- Name: license_ratings license_ratings_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.license_ratings
    ADD CONSTRAINT license_ratings_pkey PRIMARY KEY (id);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: medicals medicals_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.medicals
    ADD CONSTRAINT medicals_pkey PRIMARY KEY (id);


--
-- Name: member_access_remotes member_access_remotes_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.member_access_remotes
    ADD CONSTRAINT member_access_remotes_pkey PRIMARY KEY (id);


--
-- Name: member_roles member_roles_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.member_roles
    ADD CONSTRAINT member_roles_pkey PRIMARY KEY (id);


--
-- Name: member_services member_services_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.member_services
    ADD CONSTRAINT member_services_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: meter_buses meter_buses_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.meter_buses
    ADD CONSTRAINT meter_buses_pkey PRIMARY KEY (id);


--
-- Name: meter_measures meter_measures_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.meter_measures
    ADD CONSTRAINT meter_measures_pkey PRIMARY KEY (id);


--
-- Name: meters meters_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.meters
    ADD CONSTRAINT meters_pkey PRIMARY KEY (id);


--
-- Name: ogn_ddb_entries ogn_ddb_entries_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.ogn_ddb_entries
    ADD CONSTRAINT ogn_ddb_entries_pkey PRIMARY KEY (id);


--
-- Name: onda_invoice_export_details onda_invoice_export_details_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.onda_invoice_export_details
    ADD CONSTRAINT onda_invoice_export_details_pkey PRIMARY KEY (id);


--
-- Name: onda_invoice_exports onda_invoice_exports_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.onda_invoice_exports
    ADD CONSTRAINT onda_invoice_exports_pkey PRIMARY KEY (id);


--
-- Name: payment_services payment_services_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.payment_services
    ADD CONSTRAINT payment_services_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: pilots pilots_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.pilots
    ADD CONSTRAINT pilots_pkey PRIMARY KEY (id);


--
-- Name: planes planes_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.planes
    ADD CONSTRAINT planes_pkey PRIMARY KEY (id);


--
-- Name: radar_events radar_events_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.radar_events
    ADD CONSTRAINT radar_events_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roster_days roster_days_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.roster_days
    ADD CONSTRAINT roster_days_pkey PRIMARY KEY (id);


--
-- Name: roster_entries roster_entries_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.roster_entries
    ADD CONSTRAINT roster_entries_pkey PRIMARY KEY (id);


--
-- Name: satispay_entities satispay_entities_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.satispay_entities
    ADD CONSTRAINT satispay_entities_pkey PRIMARY KEY (id);


--
-- Name: satispay_profile_pictures satispay_profile_pictures_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.satispay_profile_pictures
    ADD CONSTRAINT satispay_profile_pictures_pkey PRIMARY KEY (id);


--
-- Name: service_types service_types_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.service_types
    ADD CONSTRAINT service_types_pkey PRIMARY KEY (id);


--
-- Name: skysight_codes skysight_codes_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.skysight_codes
    ADD CONSTRAINT skysight_codes_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: timetable_entries timetable_entries_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.timetable_entries
    ADD CONSTRAINT timetable_entries_pkey PRIMARY KEY (id);


--
-- Name: token_transactions token_transactions_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.token_transactions
    ADD CONSTRAINT token_transactions_pkey PRIMARY KEY (id);


--
-- Name: tow_roster_days tow_roster_days_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tow_roster_days
    ADD CONSTRAINT tow_roster_days_pkey PRIMARY KEY (id);


--
-- Name: tow_roster_entries tow_roster_entries_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tow_roster_entries
    ADD CONSTRAINT tow_roster_entries_pkey PRIMARY KEY (id);


--
-- Name: tows tows_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tows
    ADD CONSTRAINT tows_pkey PRIMARY KEY (id);


--
-- Name: trackers trackers_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.trackers
    ADD CONSTRAINT trackers_pkey PRIMARY KEY (id);


--
-- Name: trailers trailers_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.trailers
    ADD CONSTRAINT trailers_pkey PRIMARY KEY (id);


--
-- Name: wol_targets wol_targets_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.wol_targets
    ADD CONSTRAINT wol_targets_pkey PRIMARY KEY (id);


--
-- Name: years years_pkey; Type: CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.years
    ADD CONSTRAINT years_pkey PRIMARY KEY (id);


--
-- Name: certificate_altnames ca_certificate_altnames_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.certificate_altnames
    ADD CONSTRAINT ca_certificate_altnames_pkey PRIMARY KEY (id);


--
-- Name: cas cas_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.cas
    ADD CONSTRAINT cas_pkey PRIMARY KEY (id);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: key_pair_locations key_pair_locations_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.key_pair_locations
    ADD CONSTRAINT key_pair_locations_pkey PRIMARY KEY (id);


--
-- Name: key_pairs key_pairs_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.key_pairs
    ADD CONSTRAINT key_pairs_pkey PRIMARY KEY (id);


--
-- Name: key_stores key_stores_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.key_stores
    ADD CONSTRAINT key_stores_pkey PRIMARY KEY (id);


--
-- Name: le_accounts le_accounts_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_accounts
    ADD CONSTRAINT le_accounts_pkey PRIMARY KEY (id);


--
-- Name: le_order_auth_challenges le_order_auth_challenges_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_order_auth_challenges
    ADD CONSTRAINT le_order_auth_challenges_pkey PRIMARY KEY (id);


--
-- Name: le_order_auths le_order_auths_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_order_auths
    ADD CONSTRAINT le_order_auths_pkey PRIMARY KEY (id);


--
-- Name: le_orders le_orders_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_orders
    ADD CONSTRAINT le_orders_pkey PRIMARY KEY (id);


--
-- Name: le_slots le_slots_pkey; Type: CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_slots
    ADD CONSTRAINT le_slots_pkey PRIMARY KEY (id);


--
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);


--
-- Name: global_roles global_roles_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.global_roles
    ADD CONSTRAINT global_roles_pkey PRIMARY KEY (id);


--
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: iso_countries iso_countries_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.iso_countries
    ADD CONSTRAINT iso_countries_pkey PRIMARY KEY (a2);


--
-- Name: klass_collection_role_defs klass_collection_role_defs_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.klass_collection_role_defs
    ADD CONSTRAINT klass_collection_role_defs_pkey PRIMARY KEY (id);


--
-- Name: klass_members_role_defs klass_members_role_defs_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.klass_members_role_defs
    ADD CONSTRAINT klass_members_role_defs_pkey PRIMARY KEY (id);


--
-- Name: klasses klasses_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.klasses
    ADD CONSTRAINT klasses_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: log_entries log_entries_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.log_entries
    ADD CONSTRAINT log_entries_pkey PRIMARY KEY (id);


--
-- Name: log_entry_details log_entry_details_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.log_entry_details
    ADD CONSTRAINT log_entry_details_pkey PRIMARY KEY (id);


--
-- Name: notif_templates notif_templates_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.notif_templates
    ADD CONSTRAINT notif_templates_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: organization_people organization_people_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_people
    ADD CONSTRAINT organization_people_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: person_contacts person_contacts_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_contacts
    ADD CONSTRAINT person_contacts_pkey PRIMARY KEY (id);


--
-- Name: person_credentials person_credentials_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_credentials
    ADD CONSTRAINT person_credentials_pkey PRIMARY KEY (id);


--
-- Name: person_email_validation_tokens person_email_validation_tokens_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_email_validation_tokens
    ADD CONSTRAINT person_email_validation_tokens_pkey PRIMARY KEY (id);


--
-- Name: person_emails person_emails_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_emails
    ADD CONSTRAINT person_emails_pkey PRIMARY KEY (id);


--
-- Name: person_roles person_roles_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_roles
    ADD CONSTRAINT person_roles_pkey PRIMARY KEY (id);


--
-- Name: replica_notifies replica_notifies_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.replica_notifies
    ADD CONSTRAINT replica_notifies_pkey PRIMARY KEY (id);


--
-- Name: replicas replicas_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.replicas
    ADD CONSTRAINT replicas_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: task_notifies task_notifies_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.task_notifies
    ADD CONSTRAINT task_notifies_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: alptherm_history_entries alptherm_histories_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.alptherm_history_entries
    ADD CONSTRAINT alptherm_histories_pkey PRIMARY KEY (id);


--
-- Name: alptherm_sources alptherm_sources_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.alptherm_sources
    ADD CONSTRAINT alptherm_sources_pkey PRIMARY KEY (id);


--
-- Name: championship_flights championship_flights_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.championship_flights
    ADD CONSTRAINT championship_flights_pkey PRIMARY KEY (id);


--
-- Name: championship_pilots championship_pilots_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.championship_pilots
    ADD CONSTRAINT championship_pilots_pkey PRIMARY KEY (id);


--
-- Name: championships championships_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.championships
    ADD CONSTRAINT championships_pkey PRIMARY KEY (id);


--
-- Name: clubs clubs_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- Name: flight_photos flight_photos_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.flight_photos
    ADD CONSTRAINT flight_photos_pkey PRIMARY KEY (id);


--
-- Name: flight_tags flight_tags_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.flight_tags
    ADD CONSTRAINT flight_tags_pkey PRIMARY KEY (id);


--
-- Name: flights flights_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (id);


--
-- Name: glider_classes glider_classes_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.glider_classes
    ADD CONSTRAINT glider_classes_pkey PRIMARY KEY (id);


--
-- Name: igc_tmp_files igc_tmp_files_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.igc_tmp_files
    ADD CONSTRAINT igc_tmp_files_pkey PRIMARY KEY (id);


--
-- Name: pilot_planes pilot_planes_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.pilot_planes
    ADD CONSTRAINT pilot_planes_pkey PRIMARY KEY (id);


--
-- Name: pilots pilots_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.pilots
    ADD CONSTRAINT pilots_pkey PRIMARY KEY (id);


--
-- Name: plane_type_configurations plane_type_configurations_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.plane_type_configurations
    ADD CONSTRAINT plane_type_configurations_pkey PRIMARY KEY (id);


--
-- Name: plane_types plane_types_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.plane_types
    ADD CONSTRAINT plane_types_pkey PRIMARY KEY (id);


--
-- Name: planes planes_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.planes
    ADD CONSTRAINT planes_pkey PRIMARY KEY (id);


--
-- Name: ranking_club_standing_history_entries ranking_club_standing_history_entries_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_club_standing_history_entries
    ADD CONSTRAINT ranking_club_standing_history_entries_pkey PRIMARY KEY (id);


--
-- Name: ranking_club_standings ranking_club_standings_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_club_standings
    ADD CONSTRAINT ranking_club_standings_pkey PRIMARY KEY (id);


--
-- Name: ranking_flights ranking_flights_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_flights
    ADD CONSTRAINT ranking_flights_pkey PRIMARY KEY (id);


--
-- Name: ranking_groups ranking_groups_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_groups
    ADD CONSTRAINT ranking_groups_pkey PRIMARY KEY (id);


--
-- Name: ranking_standing_history_entries ranking_history_entry_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_standing_history_entries
    ADD CONSTRAINT ranking_history_entry_pkey PRIMARY KEY (id);


--
-- Name: ranking_standings ranking_standings_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.ranking_standings
    ADD CONSTRAINT ranking_standings_pkey PRIMARY KEY (id);


--
-- Name: rankings rankings_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.rankings
    ADD CONSTRAINT rankings_pkey PRIMARY KEY (id);


--
-- Name: tag_groups tag_groups_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.tag_groups
    ADD CONSTRAINT tag_groups_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: flarc; Owner: -
--

ALTER TABLE ONLY flarc.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: i18n; Owner: -
--

ALTER TABLE ONLY i18n.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: phrases phrases_pkey; Type: CONSTRAINT; Schema: i18n; Owner: -
--

ALTER TABLE ONLY i18n.phrases
    ADD CONSTRAINT phrases_pkey PRIMARY KEY (id);


--
-- Name: translations translations_pkey; Type: CONSTRAINT; Schema: i18n; Owner: -
--

ALTER TABLE ONLY i18n.translations
    ADD CONSTRAINT translations_pkey PRIMARY KEY (id);


--
-- Name: address_validation_tokens address_validation_tokens_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.address_validation_tokens
    ADD CONSTRAINT address_validation_tokens_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: list_members list_members_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.list_members
    ADD CONSTRAINT list_members_pkey PRIMARY KEY (id);


--
-- Name: lists lists_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: msg_rcpts ml_msg_rcpts_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_rcpts
    ADD CONSTRAINT ml_msg_rcpts_pkey PRIMARY KEY (id);


--
-- Name: msg_bounces msg_bounces_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_bounces
    ADD CONSTRAINT msg_bounces_pkey PRIMARY KEY (id);


--
-- Name: msg_events msg_events_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_events
    ADD CONSTRAINT msg_events_pkey PRIMARY KEY (id);


--
-- Name: msg_lists msg_lists_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_lists
    ADD CONSTRAINT msg_lists_pkey PRIMARY KEY (id);


--
-- Name: msg_objects msg_objects_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_objects
    ADD CONSTRAINT msg_objects_pkey PRIMARY KEY (id);


--
-- Name: msgs msgs_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msgs
    ADD CONSTRAINT msgs_pkey PRIMARY KEY (id);


--
-- Name: senders senders_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.senders
    ADD CONSTRAINT senders_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: acao_bar_transactions_acl acao_bar_transactions_acl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acao_bar_transactions_acl
    ADD CONSTRAINT acao_bar_transactions_acl_pkey PRIMARY KEY (id);


--
-- Name: acao_memberships_acl acao_memberships_acl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acao_memberships_acl
    ADD CONSTRAINT acao_memberships_acl_pkey PRIMARY KEY (id);


--
-- Name: acao_payments_acl acao_payments_acl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.acao_payments_acl
    ADD CONSTRAINT acao_payments_acl_pkey PRIMARY KEY (id);


--
-- Name: active_planes active_planes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_planes
    ADD CONSTRAINT active_planes_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: core_organizations_acl core_organizations_acl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_organizations_acl
    ADD CONSTRAINT core_organizations_acl_pkey PRIMARY KEY (id);


--
-- Name: core_people_acl core_people_acl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_people_acl
    ADD CONSTRAINT core_people_acl_pkey PRIMARY KEY (id);


--
-- Name: flights_acl flights_acl_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights_acl
    ADD CONSTRAINT flights_acl_pkey PRIMARY KEY (id);


--
-- Name: flights flights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (id);


--
-- Name: idxc_entries idxc_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idxc_entries
    ADD CONSTRAINT idxc_entries_pkey PRIMARY KEY (id);


--
-- Name: idxc_statuses idxc_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idxc_statuses
    ADD CONSTRAINT idxc_statuses_pkey PRIMARY KEY (id);


--
-- Name: maindb_last_update maindb_last_update_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maindb_last_update
    ADD CONSTRAINT maindb_last_update_pkey PRIMARY KEY (id);


--
-- Name: met_history_entries met_history_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.met_history_entries
    ADD CONSTRAINT met_history_entries_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: radacct radacct_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radacct
    ADD CONSTRAINT radacct_pkey PRIMARY KEY (radacctid);


--
-- Name: radcheck radcheck_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radcheck
    ADD CONSTRAINT radcheck_pkey PRIMARY KEY (id);


--
-- Name: radgroupcheck radgroupcheck_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radgroupcheck
    ADD CONSTRAINT radgroupcheck_pkey PRIMARY KEY (id);


--
-- Name: radgroupreply radgroupreply_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radgroupreply
    ADD CONSTRAINT radgroupreply_pkey PRIMARY KEY (id);


--
-- Name: radpostauth radpostauth_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radpostauth
    ADD CONSTRAINT radpostauth_pkey PRIMARY KEY (id);


--
-- Name: radreply radreply_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radreply
    ADD CONSTRAINT radreply_pkey PRIMARY KEY (id);


--
-- Name: str_channel_variants str_channel_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.str_channel_variants
    ADD CONSTRAINT str_channel_variants_pkey PRIMARY KEY (id);


--
-- Name: str_channels str_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.str_channels
    ADD CONSTRAINT str_channels_pkey PRIMARY KEY (id);


--
-- Name: sync_status sync_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_status
    ADD CONSTRAINT sync_status_pkey PRIMARY KEY (id);


--
-- Name: trk_contest_days trk_contest_days_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trk_contest_days
    ADD CONSTRAINT trk_contest_days_pkey PRIMARY KEY (id);


--
-- Name: trk_contests trk_contests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trk_contests
    ADD CONSTRAINT trk_contests_pkey PRIMARY KEY (id);


--
-- Name: trk_day_aircrafts trk_day_planes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trk_day_aircrafts
    ADD CONSTRAINT trk_day_planes_pkey PRIMARY KEY (id);


--
-- Name: acao_aircrafts_flarm_identifier_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX acao_aircrafts_flarm_identifier_idx ON acao.aircrafts USING btree (flarm_identifier);


--
-- Name: acao_aircrafts_icao_identifier_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX acao_aircrafts_icao_identifier_idx ON acao.aircrafts USING btree (icao_identifier);


--
-- Name: acao_airfields_icao_code_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_airfields_icao_code_idx ON acao.airfields USING btree (icao_code);


--
-- Name: acao_airfields_symbol_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_airfields_symbol_idx ON acao.airfields USING btree (symbol);


--
-- Name: acao_bar_transactions_old_cassetta_id_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX acao_bar_transactions_old_cassetta_id_idx ON acao.bar_transactions USING btree (old_cassetta_id);


--
-- Name: acao_bar_transactions_old_id_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX acao_bar_transactions_old_id_idx ON acao.bar_transactions USING btree (old_id);


--
-- Name: acao_bar_transactions_recorded_at_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_bar_transactions_recorded_at_idx ON acao.bar_transactions USING btree (recorded_at);


--
-- Name: acao_flights_aircraft_id_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_flights_aircraft_id_idx ON acao.flights USING btree (aircraft_id);


--
-- Name: acao_flights_landing_time_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_flights_landing_time_idx ON acao.flights USING btree (landing_time);


--
-- Name: acao_flights_source_id_source_expansion_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX acao_flights_source_id_source_expansion_idx ON acao.flights USING btree (source_id, source_expansion);


--
-- Name: acao_flights_takeoff_time_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_flights_takeoff_time_idx ON acao.flights USING btree (takeoff_time);


--
-- Name: acao_licenses_type_identifier_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX acao_licenses_type_identifier_idx ON acao.licenses USING btree (type, identifier);


--
-- Name: acao_roster_days_date_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX acao_roster_days_date_idx ON acao.roster_days USING btree (date);


--
-- Name: acao_service_types_symbol_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX acao_service_types_symbol_idx ON acao.service_types USING btree (symbol);


--
-- Name: acao_timetable_entries_aircraft_id_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_timetable_entries_aircraft_id_idx ON acao.timetable_entries USING btree (aircraft_id);


--
-- Name: acao_token_transactions_aircraft_id_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_token_transactions_aircraft_id_idx ON acao.token_transactions USING btree (aircraft_id);


--
-- Name: acao_token_transactions_old_id_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX acao_token_transactions_old_id_idx ON acao.token_transactions USING btree (old_id);


--
-- Name: acao_token_transactions_recorded_at_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_token_transactions_recorded_at_idx ON acao.token_transactions USING btree (recorded_at);


--
-- Name: acao_trackers_aircraft_id_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_trackers_aircraft_id_idx ON acao.trackers USING btree (aircraft_id);


--
-- Name: acao_trailers_aircraft_id_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX acao_trailers_aircraft_id_idx ON acao.trailers USING btree (aircraft_id);


--
-- Name: index_acao.airfields_on_location_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX "index_acao.airfields_on_location_id" ON acao.airfields USING btree (location_id);


--
-- Name: index_acao_person_services_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_acao_person_services_on_uuid ON acao.member_services USING btree (id);


--
-- Name: index_access_remotes_on_symbol; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_access_remotes_on_symbol ON acao.access_remotes USING btree (symbol);


--
-- Name: index_aircraft_owners_on_aircraft_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_aircraft_owners_on_aircraft_id ON acao.aircraft_owners USING btree (aircraft_id);


--
-- Name: index_aircraft_owners_on_aircraft_id_and_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_aircraft_owners_on_aircraft_id_and_member_id ON acao.aircraft_owners USING btree (aircraft_id, member_id);


--
-- Name: index_aircraft_owners_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_aircraft_owners_on_member_id ON acao.aircraft_owners USING btree (member_id);


--
-- Name: index_aircraft_types_on_name; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_aircraft_types_on_name ON acao.aircraft_types USING btree (name);


--
-- Name: index_aircraft_types_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_aircraft_types_on_uuid ON acao.aircraft_types USING btree (id);


--
-- Name: index_aircrafts_on_aircraft_type_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_aircrafts_on_aircraft_type_id ON acao.aircrafts USING btree (aircraft_type_id);


--
-- Name: index_aircrafts_on_club_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_aircrafts_on_club_id ON acao.aircrafts USING btree (club_id);


--
-- Name: index_aircrafts_on_club_owner_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_aircrafts_on_club_owner_id ON acao.aircrafts USING btree (club_owner_id);


--
-- Name: index_aircrafts_on_owner_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_aircrafts_on_owner_id ON acao.aircrafts USING btree (owner_id);


--
-- Name: index_aircrafts_on_registration; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_aircrafts_on_registration ON acao.aircrafts USING btree (registration);


--
-- Name: index_airfields_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_airfields_on_uuid ON acao.airfields USING btree (id);


--
-- Name: index_bar_transactions_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_bar_transactions_on_member_id ON acao.bar_transactions USING btree (member_id);


--
-- Name: index_bar_transactions_on_operator_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_bar_transactions_on_operator_id ON acao.bar_transactions USING btree (operator_id);


--
-- Name: index_bar_transactions_on_session_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_bar_transactions_on_session_id ON acao.bar_transactions USING btree (session_id);


--
-- Name: index_bar_transactions_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_bar_transactions_on_uuid ON acao.bar_transactions USING btree (id);


--
-- Name: index_clubs_on_airfield_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_clubs_on_airfield_id ON acao.clubs USING btree (airfield_id);


--
-- Name: index_clubs_on_name; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_clubs_on_name ON acao.clubs USING btree (name);


--
-- Name: index_debt_details_on_debt_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_debt_details_on_debt_id ON acao.debt_details USING btree (debt_id);


--
-- Name: index_debt_details_on_obj_type_and_obj_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_debt_details_on_obj_type_and_obj_id ON acao.debt_details USING btree (obj_type, obj_id);


--
-- Name: index_debt_details_on_service_type_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_debt_details_on_service_type_id ON acao.debt_details USING btree (service_type_id);


--
-- Name: index_debts_on_identifier; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_debts_on_identifier ON acao.debts USING btree (identifier);


--
-- Name: index_debts_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_debts_on_member_id ON acao.debts USING btree (member_id);


--
-- Name: index_debts_on_state; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_debts_on_state ON acao.debts USING btree (state);


--
-- Name: index_fai_cards_on_identifier; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_fai_cards_on_identifier ON acao.fai_cards USING btree (identifier);


--
-- Name: index_fai_cards_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_fai_cards_on_member_id ON acao.fai_cards USING btree (member_id);


--
-- Name: index_flarmnet_entries_on_aircraft_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flarmnet_entries_on_aircraft_id ON acao.flarmnet_entries USING btree (aircraft_id);


--
-- Name: index_flarmnet_entries_on_device_type_and_device_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_flarmnet_entries_on_device_type_and_device_id ON acao.flarmnet_entries USING btree (device_type, device_id);


--
-- Name: index_flarmnet_entries_on_registration; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flarmnet_entries_on_registration ON acao.flarmnet_entries USING btree (registration);


--
-- Name: index_flights_on_aircraft_owner_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flights_on_aircraft_owner_id ON acao.flights USING btree (aircraft_owner_id);


--
-- Name: index_flights_on_landing_airfield_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flights_on_landing_airfield_id ON acao.flights USING btree (landing_airfield_id);


--
-- Name: index_flights_on_landing_location_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flights_on_landing_location_id ON acao.flights USING btree (landing_location_id);


--
-- Name: index_flights_on_pilot1_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flights_on_pilot1_id ON acao.flights USING btree (pilot1_id);


--
-- Name: index_flights_on_pilot2_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flights_on_pilot2_id ON acao.flights USING btree (pilot2_id);


--
-- Name: index_flights_on_takeoff_airfield_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flights_on_takeoff_airfield_id ON acao.flights USING btree (takeoff_airfield_id);


--
-- Name: index_flights_on_takeoff_location_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flights_on_takeoff_location_id ON acao.flights USING btree (takeoff_location_id);


--
-- Name: index_flights_on_tow_release_location_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flights_on_tow_release_location_id ON acao.flights USING btree (tow_release_location_id);


--
-- Name: index_flights_on_towed_by_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_flights_on_towed_by_id ON acao.flights USING btree (towed_by_id);


--
-- Name: index_flights_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_flights_on_uuid ON acao.flights USING btree (id);


--
-- Name: index_gates_on_agent_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_gates_on_agent_id ON acao.gates USING btree (agent_id);


--
-- Name: index_invoice_details_on_invoice_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_invoice_details_on_invoice_id ON acao.invoice_details USING btree (invoice_id);


--
-- Name: index_invoices_on_document_type_and_year_and_identifier; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_invoices_on_document_type_and_year_and_identifier ON acao.invoices USING btree (document_type, year, identifier);


--
-- Name: index_invoices_on_identifier; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_invoices_on_identifier ON acao.invoices USING btree (identifier);


--
-- Name: index_invoices_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_invoices_on_member_id ON acao.invoices USING btree (member_id);


--
-- Name: index_invoices_on_person_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_invoices_on_person_id ON acao.invoices USING btree (person_id);


--
-- Name: index_key_fobs_on_code; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_key_fobs_on_code ON acao.key_fobs USING btree (code);


--
-- Name: index_key_fobs_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_key_fobs_on_member_id ON acao.key_fobs USING btree (member_id);


--
-- Name: index_license_ratings_on_license_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_license_ratings_on_license_id ON acao.license_ratings USING btree (license_id);


--
-- Name: index_licenses_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_licenses_on_member_id ON acao.licenses USING btree (member_id);


--
-- Name: index_licenses_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_licenses_on_uuid ON acao.licenses USING btree (id);


--
-- Name: index_medicals_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_medicals_on_member_id ON acao.medicals USING btree (member_id);


--
-- Name: index_medicals_on_type_and_identifier; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_medicals_on_type_and_identifier ON acao.medicals USING btree (type, identifier);


--
-- Name: index_medicals_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_medicals_on_uuid ON acao.medicals USING btree (id);


--
-- Name: index_member_access_remotes_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_member_access_remotes_on_member_id ON acao.member_access_remotes USING btree (member_id);


--
-- Name: index_member_access_remotes_on_remote_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_member_access_remotes_on_remote_id ON acao.member_access_remotes USING btree (remote_id);


--
-- Name: index_member_roles_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_member_roles_on_member_id ON acao.member_roles USING btree (member_id);


--
-- Name: index_member_roles_on_member_id_and_symbol; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_member_roles_on_member_id_and_symbol ON acao.member_roles USING btree (member_id, symbol);


--
-- Name: index_member_services_on_invoice_detail_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_member_services_on_invoice_detail_id ON acao.member_services USING btree (invoice_detail_id);


--
-- Name: index_member_services_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_member_services_on_member_id ON acao.member_services USING btree (member_id);


--
-- Name: index_member_services_on_payment_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_member_services_on_payment_id ON acao.member_services USING btree (payment_id);


--
-- Name: index_member_services_on_service_type_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_member_services_on_service_type_id ON acao.member_services USING btree (service_type_id);


--
-- Name: index_members_on_ext_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_members_on_ext_id ON acao.members USING btree (ext_id);


--
-- Name: index_members_on_person_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_members_on_person_id ON acao.members USING btree (person_id);


--
-- Name: index_memberships_on_invoice_detail_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_memberships_on_invoice_detail_id ON acao.memberships USING btree (invoice_detail_id);


--
-- Name: index_memberships_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_memberships_on_member_id ON acao.memberships USING btree (member_id);


--
-- Name: index_memberships_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_memberships_on_uuid ON acao.memberships USING btree (id);


--
-- Name: index_meter_buses_on_ipv4_address_and_port; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_meter_buses_on_ipv4_address_and_port ON acao.meter_buses USING btree (ipv4_address, port);


--
-- Name: index_meter_buses_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_meter_buses_on_uuid ON acao.meter_buses USING btree (id);


--
-- Name: index_meter_measures_on_meter_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_meter_measures_on_meter_id ON acao.meter_measures USING btree (meter_id);


--
-- Name: index_meters_on_bus_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_meters_on_bus_id ON acao.meters USING btree (bus_id);


--
-- Name: index_meters_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_meters_on_member_id ON acao.meters USING btree (member_id);


--
-- Name: index_meters_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_meters_on_uuid ON acao.meters USING btree (id);


--
-- Name: index_ogn_ddb_entries_on_aircraft_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_ogn_ddb_entries_on_aircraft_id ON acao.ogn_ddb_entries USING btree (aircraft_id);


--
-- Name: index_ogn_ddb_entries_on_aircraft_registration; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_ogn_ddb_entries_on_aircraft_registration ON acao.ogn_ddb_entries USING btree (aircraft_registration);


--
-- Name: index_ogn_ddb_entries_on_device_type_and_device_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_ogn_ddb_entries_on_device_type_and_device_id ON acao.ogn_ddb_entries USING btree (device_type, device_id);


--
-- Name: index_onda_invoice_export_details_on_onda_invoice_export_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_onda_invoice_export_details_on_onda_invoice_export_id ON acao.onda_invoice_export_details USING btree (onda_invoice_export_id);


--
-- Name: index_onda_invoice_exports_on_identifier; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_onda_invoice_exports_on_identifier ON acao.onda_invoice_exports USING btree (identifier);


--
-- Name: index_onda_invoice_exports_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_onda_invoice_exports_on_member_id ON acao.onda_invoice_exports USING btree (member_id);


--
-- Name: index_onda_invoice_exports_on_state; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_onda_invoice_exports_on_state ON acao.onda_invoice_exports USING btree (state);


--
-- Name: index_payment_services_on_payment_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_payment_services_on_payment_id ON acao.payment_services USING btree (payment_id);


--
-- Name: index_payment_services_on_service_type_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_payment_services_on_service_type_id ON acao.payment_services USING btree (service_type_id);


--
-- Name: index_payments_on_debt_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_payments_on_debt_id ON acao.payments USING btree (debt_id);


--
-- Name: index_payments_on_identifier; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_payments_on_identifier ON acao.payments USING btree (identifier);


--
-- Name: index_payments_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_payments_on_member_id ON acao.payments USING btree (member_id);


--
-- Name: index_payments_on_sp_receiver_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_payments_on_sp_receiver_id ON acao.payments USING btree (sp_receiver_id);


--
-- Name: index_payments_on_sp_sender_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_payments_on_sp_sender_id ON acao.payments USING btree (sp_sender_id);


--
-- Name: index_payments_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_payments_on_uuid ON acao.payments USING btree (id);


--
-- Name: index_planes_on_flarm_code; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_planes_on_flarm_code ON acao.planes USING btree (flarm_code);


--
-- Name: index_planes_on_registration; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_planes_on_registration ON acao.planes USING btree (registration);


--
-- Name: index_planes_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_planes_on_uuid ON acao.planes USING btree (id);


--
-- Name: index_roles_on_symbol; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_symbol ON acao.roles USING btree (symbol);


--
-- Name: index_roster_days_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_roster_days_on_uuid ON acao.roster_days USING btree (id);


--
-- Name: index_roster_entries_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_roster_entries_on_member_id ON acao.roster_entries USING btree (member_id);


--
-- Name: index_roster_entries_on_roster_day_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_roster_entries_on_roster_day_id ON acao.roster_entries USING btree (roster_day_id);


--
-- Name: index_roster_entries_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_roster_entries_on_uuid ON acao.roster_entries USING btree (id);


--
-- Name: index_satispay_profile_pictures_on_entity_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_satispay_profile_pictures_on_entity_id ON acao.satispay_profile_pictures USING btree (entity_id);


--
-- Name: index_service_types_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_service_types_on_uuid ON acao.service_types USING btree (id);


--
-- Name: index_skysight_codes_on_code; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_skysight_codes_on_code ON acao.skysight_codes USING btree (code);


--
-- Name: index_tickets_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_tickets_on_member_id ON acao.tickets USING btree (member_id);


--
-- Name: index_tickets_on_number; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_tickets_on_number ON acao.tickets USING btree (number);


--
-- Name: index_timetable_entries_on_landing_airfield_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_timetable_entries_on_landing_airfield_id ON acao.timetable_entries USING btree (landing_airfield_id);


--
-- Name: index_timetable_entries_on_landing_location_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_timetable_entries_on_landing_location_id ON acao.timetable_entries USING btree (landing_location_id);


--
-- Name: index_timetable_entries_on_pilot_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_timetable_entries_on_pilot_id ON acao.timetable_entries USING btree (pilot_id);


--
-- Name: index_timetable_entries_on_takeoff_airfield_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_timetable_entries_on_takeoff_airfield_id ON acao.timetable_entries USING btree (takeoff_airfield_id);


--
-- Name: index_timetable_entries_on_takeoff_location_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_timetable_entries_on_takeoff_location_id ON acao.timetable_entries USING btree (takeoff_location_id);


--
-- Name: index_timetable_entries_on_tow_release_location_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_timetable_entries_on_tow_release_location_id ON acao.timetable_entries USING btree (tow_release_location_id);


--
-- Name: index_timetable_entries_on_towed_by_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_timetable_entries_on_towed_by_id ON acao.timetable_entries USING btree (towed_by_id);


--
-- Name: index_timetable_entries_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_timetable_entries_on_uuid ON acao.timetable_entries USING btree (id);


--
-- Name: index_token_transactions_on_flight_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_token_transactions_on_flight_id ON acao.token_transactions USING btree (flight_id);


--
-- Name: index_token_transactions_on_invoice_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_token_transactions_on_invoice_id ON acao.token_transactions USING btree (invoice_id);


--
-- Name: index_token_transactions_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_token_transactions_on_member_id ON acao.token_transactions USING btree (member_id);


--
-- Name: index_token_transactions_on_operator_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_token_transactions_on_operator_id ON acao.token_transactions USING btree (operator_id);


--
-- Name: index_token_transactions_on_session_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_token_transactions_on_session_id ON acao.token_transactions USING btree (session_id);


--
-- Name: index_token_transactions_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_token_transactions_on_uuid ON acao.token_transactions USING btree (id);


--
-- Name: index_tow_roster_days_on_date; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_tow_roster_days_on_date ON acao.tow_roster_days USING btree (date);


--
-- Name: index_tow_roster_days_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_tow_roster_days_on_uuid ON acao.tow_roster_days USING btree (id);


--
-- Name: index_tow_roster_entries_on_day_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_tow_roster_entries_on_day_id ON acao.tow_roster_entries USING btree (day_id);


--
-- Name: index_tow_roster_entries_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_tow_roster_entries_on_member_id ON acao.tow_roster_entries USING btree (member_id);


--
-- Name: index_tow_roster_entries_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_tow_roster_entries_on_uuid ON acao.tow_roster_entries USING btree (id);


--
-- Name: index_tows_on_glider_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_tows_on_glider_id ON acao.tows USING btree (glider_id);


--
-- Name: index_tows_on_towplane_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_tows_on_towplane_id ON acao.tows USING btree (towplane_id);


--
-- Name: index_trackers_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_trackers_on_uuid ON acao.trackers USING btree (id);


--
-- Name: index_trailers_on_id_old; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_trailers_on_id_old ON acao.trailers USING btree (id_old);


--
-- Name: index_trailers_on_identifier; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_trailers_on_identifier ON acao.trailers USING btree (identifier);


--
-- Name: index_trailers_on_location_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_trailers_on_location_id ON acao.trailers USING btree (location_id);


--
-- Name: index_trailers_on_member_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_trailers_on_member_id ON acao.trailers USING btree (member_id);


--
-- Name: index_trailers_on_payment_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX index_trailers_on_payment_id ON acao.trailers USING btree (payment_id);


--
-- Name: index_trailers_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_trailers_on_uuid ON acao.trailers USING btree (id);


--
-- Name: index_wol_targets_on_symbol; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_wol_targets_on_symbol ON acao.wol_targets USING btree (symbol);


--
-- Name: index_years_on_uuid; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_years_on_uuid ON acao.years USING btree (id);


--
-- Name: index_years_on_year; Type: INDEX; Schema: acao; Owner: -
--

CREATE UNIQUE INDEX index_years_on_year ON acao.years USING btree (year);


--
-- Name: memberships_on_payment_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX memberships_on_payment_id ON acao.memberships USING btree (payment_id);


--
-- Name: memberships_on_reference_year_id; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX memberships_on_reference_year_id ON acao.memberships USING btree (reference_year_id);


--
-- Name: track_entries_at; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX track_entries_at ON acao.radar_points USING btree (at);


--
-- Name: trk_events_at_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX trk_events_at_idx ON acao.radar_events USING btree (at);


--
-- Name: trk_events_event_idx; Type: INDEX; Schema: acao; Owner: -
--

CREATE INDEX trk_events_event_idx ON acao.radar_events USING btree (event);


--
-- Name: ca_certificates_issuer_dn_idx; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX ca_certificates_issuer_dn_idx ON ca.certificates USING btree (issuer_dn);


--
-- Name: ca_certificates_md5_idx; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX ca_certificates_md5_idx ON ca.certificates USING btree (md5(pem));


--
-- Name: ca_certificates_subject_dn_idx; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX ca_certificates_subject_dn_idx ON ca.certificates USING btree (subject_dn);


--
-- Name: index_ca_cas_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_cas_on_uuid ON ca.cas USING btree (id);


--
-- Name: index_ca_certificate_altnames_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_certificate_altnames_on_uuid ON ca.certificate_altnames USING btree (uuid);


--
-- Name: index_ca_certificates_on_cn; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_ca_certificates_on_cn ON ca.certificates USING btree (cn);


--
-- Name: index_ca_certificates_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_certificates_on_uuid ON ca.certificates USING btree (id);


--
-- Name: index_ca_key_pair_locations_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_key_pair_locations_on_uuid ON ca.key_pair_locations USING btree (id);


--
-- Name: index_ca_key_pairs_on_public_key_hash; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_key_pairs_on_public_key_hash ON ca.key_pairs USING btree (public_key_hash);


--
-- Name: index_ca_key_pairs_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_key_pairs_on_uuid ON ca.key_pairs USING btree (id);


--
-- Name: index_ca_key_stores_on_symbol; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_key_stores_on_symbol ON ca.key_stores USING btree (symbol);


--
-- Name: index_ca_key_stores_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_key_stores_on_uuid ON ca.key_stores USING btree (id);


--
-- Name: index_ca_le_accounts_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_le_accounts_on_uuid ON ca.le_accounts USING btree (id);


--
-- Name: index_ca_le_order_auth_challenges_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_le_order_auth_challenges_on_uuid ON ca.le_order_auth_challenges USING btree (id);


--
-- Name: index_ca_le_order_auths_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_le_order_auths_on_uuid ON ca.le_order_auths USING btree (id);


--
-- Name: index_ca_le_orders_on_uuid; Type: INDEX; Schema: ca; Owner: -
--

CREATE UNIQUE INDEX index_ca_le_orders_on_uuid ON ca.le_orders USING btree (id);


--
-- Name: index_cas_on_certificate_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_cas_on_certificate_id ON ca.cas USING btree (certificate_id);


--
-- Name: index_cas_on_key_pair_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_cas_on_key_pair_id ON ca.cas USING btree (key_pair_id);


--
-- Name: index_certificate_altnames_on_certificate_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_certificate_altnames_on_certificate_id ON ca.certificate_altnames USING btree (certificate_id);


--
-- Name: index_certificates_on_key_pair_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_certificates_on_key_pair_id ON ca.certificates USING btree (key_pair_id);


--
-- Name: index_key_pair_locations_on_pair_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_key_pair_locations_on_pair_id ON ca.key_pair_locations USING btree (pair_id);


--
-- Name: index_key_pair_locations_on_store_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_key_pair_locations_on_store_id ON ca.key_pair_locations USING btree (store_id);


--
-- Name: index_key_stores_on_remote_agent_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_key_stores_on_remote_agent_id ON ca.key_stores USING btree (remote_agent_id);


--
-- Name: index_le_accounts_on_key_pair_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_le_accounts_on_key_pair_id ON ca.le_accounts USING btree (key_pair_id);


--
-- Name: index_le_order_auth_challenges_on_order_auth_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_le_order_auth_challenges_on_order_auth_id ON ca.le_order_auth_challenges USING btree (order_auth_id);


--
-- Name: index_le_order_auths_on_order_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_le_order_auths_on_order_id ON ca.le_order_auths USING btree (order_id);


--
-- Name: index_le_orders_on_account_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_le_orders_on_account_id ON ca.le_orders USING btree (account_id);


--
-- Name: index_le_orders_on_certificate_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_le_orders_on_certificate_id ON ca.le_orders USING btree (certificate_id);


--
-- Name: index_le_orders_on_slot_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_le_orders_on_slot_id ON ca.le_orders USING btree (slot_id);


--
-- Name: index_le_slots_on_account_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_le_slots_on_account_id ON ca.le_slots USING btree (account_id);


--
-- Name: index_le_slots_on_certificate_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_le_slots_on_certificate_id ON ca.le_slots USING btree (certificate_id);


--
-- Name: index_le_slots_on_key_store_id; Type: INDEX; Schema: ca; Owner: -
--

CREATE INDEX index_le_slots_on_key_store_id ON ca.le_slots USING btree (key_store_id);


--
-- Name: core_agents_exchange_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX core_agents_exchange_idx ON core.agents USING btree (exchange);


--
-- Name: core_credentials_fqda_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX core_credentials_fqda_idx ON core.person_credentials USING btree (fqda);


--
-- Name: core_iso_countries_a2_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX core_iso_countries_a2_idx ON core.iso_countries USING btree (a2);


--
-- Name: core_iso_countries_a3_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX core_iso_countries_a3_idx ON core.iso_countries USING btree (a3);


--
-- Name: core_provisioning_requests_status; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX core_provisioning_requests_status ON core.tasks USING btree (status);


--
-- Name: core_replica_notifies_notify_obj_type_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX core_replica_notifies_notify_obj_type_idx ON core.replica_notifies USING btree (notify_obj_type);


--
-- Name: core_replica_notifies_obj_type_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX core_replica_notifies_obj_type_idx ON core.replica_notifies USING btree (obj_type);


--
-- Name: index_core_capabilities_on_name; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_core_capabilities_on_name ON core.global_roles USING btree (name);


--
-- Name: index_core_credentials_on_x509_i_dn; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_core_credentials_on_x509_i_dn ON core.person_credentials USING btree (x509_i_dn);


--
-- Name: index_core_credentials_on_x509_i_dn_and_x509_m_serial; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX index_core_credentials_on_x509_i_dn_and_x509_m_serial ON core.person_credentials USING btree (x509_i_dn, x509_m_serial);


--
-- Name: index_core_http_sessions_on_updated_at; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_core_http_sessions_on_updated_at ON core.sessions USING btree (updated_at);


--
-- Name: index_core_http_sessions_on_uuid; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_core_http_sessions_on_uuid ON core.sessions USING btree (id);


--
-- Name: index_core_identity_capabilities_on_identity_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_core_identity_capabilities_on_identity_id ON core.person_roles USING btree (identity_id);


--
-- Name: index_core_provisioning_requests_on_uuid; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX index_core_provisioning_requests_on_uuid ON core.tasks USING btree (id);


--
-- Name: index_group_members_on_group_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_group_members_on_group_id ON core.group_members USING btree (group_id);


--
-- Name: index_group_members_on_person_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_group_members_on_person_id ON core.group_members USING btree (person_id);


--
-- Name: index_klass_collection_role_defs_on_klass_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_klass_collection_role_defs_on_klass_id ON core.klass_collection_role_defs USING btree (klass_id);


--
-- Name: index_klass_members_role_defs_on_klass_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_klass_members_role_defs_on_klass_id ON core.klass_members_role_defs USING btree (klass_id);


--
-- Name: index_klasses_on_name; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX index_klasses_on_name ON core.klasses USING btree (name);


--
-- Name: index_klasses_on_uuid; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX index_klasses_on_uuid ON core.klasses USING btree (id);


--
-- Name: index_log_entries_on_http_session_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_log_entries_on_http_session_id ON core.log_entries USING btree (http_session_id);


--
-- Name: index_log_entries_on_person_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_log_entries_on_person_id ON core.log_entries USING btree (person_id);


--
-- Name: index_log_entries_on_timestamp; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_log_entries_on_timestamp ON core.log_entries USING btree ("timestamp");


--
-- Name: index_log_entry_details_on_log_entry_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_log_entry_details_on_log_entry_id ON core.log_entry_details USING btree (log_entry_id);


--
-- Name: index_log_entry_details_on_obj_type_and_obj_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_log_entry_details_on_obj_type_and_obj_id ON core.log_entry_details USING btree (obj_type, obj_id);


--
-- Name: index_notifications_on_obj_type; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_notifications_on_obj_type ON core.notifications USING btree (obj_type);


--
-- Name: index_notifications_on_person_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_notifications_on_person_id ON core.notifications USING btree (person_id);


--
-- Name: index_notifications_on_timestamp; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_notifications_on_timestamp ON core.notifications USING btree ("timestamp");


--
-- Name: index_organization_people_on_organization_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_organization_people_on_organization_id ON core.organization_people USING btree (organization_id);


--
-- Name: index_organization_people_on_person_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_organization_people_on_person_id ON core.organization_people USING btree (person_id);


--
-- Name: index_organizations_on_admin_group_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_organizations_on_admin_group_id ON core.organizations USING btree (admin_group_id);


--
-- Name: index_organizations_on_headquarters_location_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_organizations_on_headquarters_location_id ON core.organizations USING btree (headquarters_location_id);


--
-- Name: index_organizations_on_invoicing_location_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_organizations_on_invoicing_location_id ON core.organizations USING btree (invoicing_location_id);


--
-- Name: index_organizations_on_registered_office_location_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_organizations_on_registered_office_location_id ON core.organizations USING btree (registered_office_location_id);


--
-- Name: index_organizations_on_uuid; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX index_organizations_on_uuid ON core.organizations USING btree (id);


--
-- Name: index_people_on_acao_code; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX index_people_on_acao_code ON core.people USING btree (acao_code);


--
-- Name: index_people_on_acao_ext_id; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX index_people_on_acao_ext_id ON core.people USING btree (acao_ext_id);


--
-- Name: index_people_on_birth_location_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_people_on_birth_location_id ON core.people USING btree (birth_location_id);


--
-- Name: index_people_on_invoicing_location_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_people_on_invoicing_location_id ON core.people USING btree (invoicing_location_id);


--
-- Name: index_people_on_preferred_language_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_people_on_preferred_language_id ON core.people USING btree (preferred_language_id);


--
-- Name: index_people_on_residence_location_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_people_on_residence_location_id ON core.people USING btree (residence_location_id);


--
-- Name: index_people_on_uuid; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX index_people_on_uuid ON core.people USING btree (id);


--
-- Name: index_person_contacts_on_person_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_person_contacts_on_person_id ON core.person_contacts USING btree (person_id);


--
-- Name: index_person_credentials_on_person_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_person_credentials_on_person_id ON core.person_credentials USING btree (person_id);


--
-- Name: index_person_email_validation_tokens_on_code; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX index_person_email_validation_tokens_on_code ON core.person_email_validation_tokens USING btree (code);


--
-- Name: index_person_email_validation_tokens_on_person_email_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_person_email_validation_tokens_on_person_email_id ON core.person_email_validation_tokens USING btree (person_email_id);


--
-- Name: index_person_emails_on_person_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_person_emails_on_person_id ON core.person_emails USING btree (person_id);


--
-- Name: index_person_emails_on_person_id_and_email; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_person_emails_on_person_id_and_email ON core.person_emails USING btree (person_id, email);


--
-- Name: index_person_roles_on_global_role_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_person_roles_on_global_role_id ON core.person_roles USING btree (global_role_id);


--
-- Name: index_person_roles_on_person_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_person_roles_on_person_id ON core.person_roles USING btree (person_id);


--
-- Name: index_replicas_on_state; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_replicas_on_state ON core.replicas USING btree (state);


--
-- Name: index_sessions_on_auth_credential_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_sessions_on_auth_credential_id ON core.sessions USING btree (auth_credential_id);


--
-- Name: index_sessions_on_auth_person_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_sessions_on_auth_person_id ON core.sessions USING btree (auth_person_id);


--
-- Name: index_sessions_on_language_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_sessions_on_language_id ON core.sessions USING btree (language_id);


--
-- Name: index_task_notifies_on_task_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_task_notifies_on_task_id ON core.task_notifies USING btree (task_id);


--
-- Name: index_tasks_on_depends_on_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_tasks_on_depends_on_id ON core.tasks USING btree (depends_on_id);


--
-- Name: index_tasks_on_status; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX index_tasks_on_status ON core.tasks USING btree (status);


--
-- Name: clubs_symbol; Type: INDEX; Schema: flarc; Owner: -
--

CREATE UNIQUE INDEX clubs_symbol ON flarc.clubs USING btree (symbol);


--
-- Name: flights_takeoff_time; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX flights_takeoff_time ON flarc.flights USING btree (takeoff_time);


--
-- Name: index_championship_flights_on_championship_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_championship_flights_on_championship_id ON flarc.championship_flights USING btree (championship_id);


--
-- Name: index_championship_flights_on_championship_id_and_flight_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE UNIQUE INDEX index_championship_flights_on_championship_id_and_flight_id ON flarc.championship_flights USING btree (championship_id, flight_id);


--
-- Name: index_championship_flights_on_flight_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_championship_flights_on_flight_id ON flarc.championship_flights USING btree (flight_id);


--
-- Name: index_championship_pilots_on_championship_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_championship_pilots_on_championship_id ON flarc.championship_pilots USING btree (championship_id);


--
-- Name: index_championship_pilots_on_championship_id_and_pilot_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE UNIQUE INDEX index_championship_pilots_on_championship_id_and_pilot_id ON flarc.championship_pilots USING btree (championship_id, pilot_id);


--
-- Name: index_championship_pilots_on_pilot_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_championship_pilots_on_pilot_id ON flarc.championship_pilots USING btree (pilot_id);


--
-- Name: index_championships_on_symbol; Type: INDEX; Schema: flarc; Owner: -
--

CREATE UNIQUE INDEX index_championships_on_symbol ON flarc.championships USING btree (sym);


--
-- Name: index_flight_tags_on_flight_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_flight_tags_on_flight_id ON flarc.flight_tags USING btree (flight_id);


--
-- Name: index_flight_tags_on_tag_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_flight_tags_on_tag_id ON flarc.flight_tags USING btree (tag_id);


--
-- Name: index_flight_tags_on_tag_id_and_flight_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE UNIQUE INDEX index_flight_tags_on_tag_id_and_flight_id ON flarc.flight_tags USING btree (tag_id, flight_id);


--
-- Name: index_ranking_club_standing_history_entries_on_standing_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_ranking_club_standing_history_entries_on_standing_id ON flarc.ranking_club_standing_history_entries USING btree (club_standing_id);


--
-- Name: index_ranking_club_standings_on_club_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_ranking_club_standings_on_club_id ON flarc.ranking_club_standings USING btree (club_id);


--
-- Name: index_ranking_club_standings_on_ranking_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_ranking_club_standings_on_ranking_id ON flarc.ranking_club_standings USING btree (ranking_id);


--
-- Name: index_ranking_club_standings_on_ranking_id_and_club_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE UNIQUE INDEX index_ranking_club_standings_on_ranking_id_and_club_id ON flarc.ranking_club_standings USING btree (ranking_id, club_id);


--
-- Name: index_ranking_flights_on_flight_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_ranking_flights_on_flight_id ON flarc.ranking_flights USING btree (flight_id);


--
-- Name: index_ranking_flights_on_ranking_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_ranking_flights_on_ranking_id ON flarc.ranking_flights USING btree (ranking_id);


--
-- Name: index_ranking_flights_on_ranking_id_and_flight_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE UNIQUE INDEX index_ranking_flights_on_ranking_id_and_flight_id ON flarc.ranking_flights USING btree (ranking_id, flight_id);


--
-- Name: index_ranking_history_entries_on_ranking_standing_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_ranking_history_entries_on_ranking_standing_id ON flarc.ranking_standing_history_entries USING btree (standing_id);


--
-- Name: index_ranking_standings_on_flight_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_ranking_standings_on_flight_id ON flarc.ranking_standings USING btree (flight_id);


--
-- Name: index_ranking_standings_on_pilot_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_ranking_standings_on_pilot_id ON flarc.ranking_standings USING btree (pilot_id);


--
-- Name: index_ranking_standings_on_ranking_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_ranking_standings_on_ranking_id ON flarc.ranking_standings USING btree (ranking_id);


--
-- Name: index_ranking_standings_on_ranking_id_and_pilot_id; Type: INDEX; Schema: flarc; Owner: -
--

CREATE UNIQUE INDEX index_ranking_standings_on_ranking_id_and_pilot_id ON flarc.ranking_standings USING btree (ranking_id, pilot_id);


--
-- Name: index_tags_on_symbol; Type: INDEX; Schema: flarc; Owner: -
--

CREATE INDEX index_tags_on_symbol ON flarc.tags USING btree (sym);


--
-- Name: i18n_languages_name_idx; Type: INDEX; Schema: i18n; Owner: -
--

CREATE UNIQUE INDEX i18n_languages_name_idx ON i18n.languages USING btree (iso_639_3);


--
-- Name: index_languages_on_iso_639_1; Type: INDEX; Schema: i18n; Owner: -
--

CREATE INDEX index_languages_on_iso_639_1 ON i18n.languages USING btree (iso_639_1);


--
-- Name: index_languages_on_uuid; Type: INDEX; Schema: i18n; Owner: -
--

CREATE UNIQUE INDEX index_languages_on_uuid ON i18n.languages USING btree (id);


--
-- Name: index_phrases_on_uuid; Type: INDEX; Schema: i18n; Owner: -
--

CREATE UNIQUE INDEX index_phrases_on_uuid ON i18n.phrases USING btree (id);


--
-- Name: index_translations_on_language_id; Type: INDEX; Schema: i18n; Owner: -
--

CREATE INDEX index_translations_on_language_id ON i18n.translations USING btree (language_id);


--
-- Name: index_translations_on_phrase_id; Type: INDEX; Schema: i18n; Owner: -
--

CREATE INDEX index_translations_on_phrase_id ON i18n.translations USING btree (phrase_id);


--
-- Name: index_translations_on_uuid; Type: INDEX; Schema: i18n; Owner: -
--

CREATE UNIQUE INDEX index_translations_on_uuid ON i18n.translations USING btree (id);


--
-- Name: index_address_validation_tokens_on_address_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_address_validation_tokens_on_address_id ON ml.address_validation_tokens USING btree (address_id);


--
-- Name: index_address_validation_tokens_on_code; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX index_address_validation_tokens_on_code ON ml.address_validation_tokens USING btree (code);


--
-- Name: index_list_members_on_address_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_list_members_on_address_id ON ml.list_members USING btree (address_id);


--
-- Name: index_list_members_on_list_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_list_members_on_list_id ON ml.list_members USING btree (list_id);


--
-- Name: index_ml_addresses_on_addr_type_and_addr; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX index_ml_addresses_on_addr_type_and_addr ON ml.addresses USING btree (addr_type, addr);


--
-- Name: index_ml_addresses_on_uuid; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX index_ml_addresses_on_uuid ON ml.addresses USING btree (id);


--
-- Name: index_ml_lists_on_uuid; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX index_ml_lists_on_uuid ON ml.lists USING btree (id);


--
-- Name: index_ml_msg_bounces_on_uuid; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX index_ml_msg_bounces_on_uuid ON ml.msg_bounces USING btree (id);


--
-- Name: index_ml_msgs_on_uuid; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX index_ml_msgs_on_uuid ON ml.msgs USING btree (id);


--
-- Name: index_ml_senders_on_uuid; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX index_ml_senders_on_uuid ON ml.senders USING btree (id);


--
-- Name: index_ml_templates_on_symbol; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX index_ml_templates_on_symbol ON ml.templates USING btree (symbol);


--
-- Name: index_ml_templates_on_uuid; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX index_ml_templates_on_uuid ON ml.templates USING btree (id);


--
-- Name: index_msg_bounces_on_msg_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_msg_bounces_on_msg_id ON ml.msg_bounces USING btree (msg_id);


--
-- Name: index_msg_events_on_msg_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_msg_events_on_msg_id ON ml.msg_events USING btree (msg_id);


--
-- Name: index_msg_lists_on_list_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_msg_lists_on_list_id ON ml.msg_lists USING btree (list_id);


--
-- Name: index_msg_lists_on_msg_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_msg_lists_on_msg_id ON ml.msg_lists USING btree (msg_id);


--
-- Name: index_msg_objects_on_msg_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_msg_objects_on_msg_id ON ml.msg_objects USING btree (msg_id);


--
-- Name: index_msgs_on_person_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_msgs_on_person_id ON ml.msgs USING btree (person_id);


--
-- Name: index_msgs_on_recipient_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_msgs_on_recipient_id ON ml.msgs USING btree (recipient_id);


--
-- Name: index_msgs_on_sender_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_msgs_on_sender_id ON ml.msgs USING btree (sender_id);


--
-- Name: index_senders_on_email_dkim_key_pair_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_senders_on_email_dkim_key_pair_id ON ml.senders USING btree (email_dkim_key_pair_id);


--
-- Name: index_templates_on_language_id; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX index_templates_on_language_id ON ml.templates USING btree (language_id);


--
-- Name: ml_lists_symbol_idx; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX ml_lists_symbol_idx ON ml.lists USING btree (symbol);


--
-- Name: ml_msgs_message_id_header_idx; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX ml_msgs_message_id_header_idx ON ml.msgs USING btree (email_message_id);


--
-- Name: ml_senders_symbol_idx; Type: INDEX; Schema: ml; Owner: -
--

CREATE UNIQUE INDEX ml_senders_symbol_idx ON ml.senders USING btree (symbol);


--
-- Name: msgs_status_idx; Type: INDEX; Schema: ml; Owner: -
--

CREATE INDEX msgs_status_idx ON ml.msgs USING btree (status);


--
-- Name: flights_acl_ogc; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX flights_acl_ogc ON public.flights_acl USING btree (obj_id, group_id, capability);


--
-- Name: flights_acl_oic; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX flights_acl_oic ON public.flights_acl USING btree (obj_id, identity_id, capability);


--
-- Name: index_acao_bar_transactions_acl_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_bar_transactions_acl_on_group_id ON public.acao_bar_transactions_acl USING btree (group_id);


--
-- Name: index_acao_bar_transactions_acl_on_obj_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_bar_transactions_acl_on_obj_id ON public.acao_bar_transactions_acl USING btree (obj_id);


--
-- Name: index_acao_bar_transactions_acl_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_bar_transactions_acl_on_owner_type_and_owner_id ON public.acao_bar_transactions_acl USING btree (owner_type, owner_id);


--
-- Name: index_acao_bar_transactions_acl_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_bar_transactions_acl_on_person_id ON public.acao_bar_transactions_acl USING btree (person_id);


--
-- Name: index_acao_memberships_acl_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_memberships_acl_on_group_id ON public.acao_memberships_acl USING btree (group_id);


--
-- Name: index_acao_memberships_acl_on_obj_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_memberships_acl_on_obj_id ON public.acao_memberships_acl USING btree (obj_id);


--
-- Name: index_acao_memberships_acl_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_memberships_acl_on_owner_type_and_owner_id ON public.acao_memberships_acl USING btree (owner_type, owner_id);


--
-- Name: index_acao_memberships_acl_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_memberships_acl_on_person_id ON public.acao_memberships_acl USING btree (person_id);


--
-- Name: index_acao_payments_acl_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_payments_acl_on_group_id ON public.acao_payments_acl USING btree (group_id);


--
-- Name: index_acao_payments_acl_on_obj_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_payments_acl_on_obj_id ON public.acao_payments_acl USING btree (obj_id);


--
-- Name: index_acao_payments_acl_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_payments_acl_on_owner_type_and_owner_id ON public.acao_payments_acl USING btree (owner_type, owner_id);


--
-- Name: index_acao_payments_acl_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_acao_payments_acl_on_person_id ON public.acao_payments_acl USING btree (person_id);


--
-- Name: index_core_organizations_acl_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_organizations_acl_on_group_id ON public.core_organizations_acl USING btree (group_id);


--
-- Name: index_core_organizations_acl_on_obj_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_organizations_acl_on_obj_id ON public.core_organizations_acl USING btree (obj_id);


--
-- Name: index_core_organizations_acl_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_organizations_acl_on_owner_type_and_owner_id ON public.core_organizations_acl USING btree (owner_type, owner_id);


--
-- Name: index_core_organizations_acl_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_organizations_acl_on_person_id ON public.core_organizations_acl USING btree (person_id);


--
-- Name: index_core_organizations_acl_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_organizations_acl_on_role ON public.core_organizations_acl USING btree (role);


--
-- Name: index_core_people_acl_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_people_acl_on_group_id ON public.core_people_acl USING btree (group_id);


--
-- Name: index_core_people_acl_on_obj_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_people_acl_on_obj_id ON public.core_people_acl USING btree (obj_id);


--
-- Name: index_core_people_acl_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_people_acl_on_owner_type_and_owner_id ON public.core_people_acl USING btree (owner_type, owner_id);


--
-- Name: index_core_people_acl_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_people_acl_on_person_id ON public.core_people_acl USING btree (person_id);


--
-- Name: index_core_people_acl_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_core_people_acl_on_role ON public.core_people_acl USING btree (role);


--
-- Name: index_flights_acl_on_capability; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_acl_on_capability ON public.flights_acl USING btree (capability);


--
-- Name: index_flights_acl_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_acl_on_group_id ON public.flights_acl USING btree (group_id);


--
-- Name: index_flights_acl_on_identity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_acl_on_identity_id ON public.flights_acl USING btree (identity_id);


--
-- Name: index_flights_acl_on_obj_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_acl_on_obj_id ON public.flights_acl USING btree (obj_id);


--
-- Name: index_flights_on_plane_pilot1_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_on_plane_pilot1_id ON public.flights USING btree (plane_pilot1_id);


--
-- Name: index_flights_on_plane_pilot2_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_on_plane_pilot2_id ON public.flights USING btree (plane_pilot2_id);


--
-- Name: index_flights_on_towplane_pilot1_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_on_towplane_pilot1_id ON public.flights USING btree (towplane_pilot1_id);


--
-- Name: index_flights_on_towplane_pilot2_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flights_on_towplane_pilot2_id ON public.flights USING btree (towplane_pilot2_id);


--
-- Name: index_idxc_entries_on_obj_type_and_obj_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_idxc_entries_on_obj_type_and_obj_id ON public.idxc_entries USING btree (obj_type, obj_id);


--
-- Name: index_idxc_entries_on_obj_type_and_obj_id_and_accessible; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_idxc_entries_on_obj_type_and_obj_id_and_accessible ON public.idxc_entries USING btree (obj_type, obj_id, accessible);


--
-- Name: index_idxc_entries_on_obj_type_and_obj_id_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_idxc_entries_on_obj_type_and_obj_id_and_person_id ON public.idxc_entries USING btree (obj_type, obj_id, person_id);


--
-- Name: index_idxc_entries_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_idxc_entries_on_person_id ON public.idxc_entries USING btree (person_id);


--
-- Name: index_idxc_statuses_on_obj_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_idxc_statuses_on_obj_type ON public.idxc_statuses USING btree (obj_type);


--
-- Name: index_idxc_statuses_on_obj_type_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_idxc_statuses_on_obj_type_and_person_id ON public.idxc_statuses USING btree (obj_type, person_id);


--
-- Name: index_idxc_statuses_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_idxc_statuses_on_person_id ON public.idxc_statuses USING btree (person_id);


--
-- Name: index_pg_search_documents_on_searchable_type_and_searchable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pg_search_documents_on_searchable_type_and_searchable_id ON public.pg_search_documents USING btree (searchable_type, searchable_id);


--
-- Name: index_str_channels_on_agent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_str_channels_on_agent_id ON public.str_channels USING btree (agent_id);


--
-- Name: index_str_channels_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_str_channels_on_uuid ON public.str_channels USING btree (uuid);


--
-- Name: met_history_entries_source_variable_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX met_history_entries_source_variable_idx ON public.met_history_entries USING btree (source, variable);


--
-- Name: met_history_entries_ts_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX met_history_entries_ts_idx ON public.met_history_entries USING btree (ts);


--
-- Name: met_history_entries_ts_source_variable_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX met_history_entries_ts_source_variable_idx ON public.met_history_entries USING btree (ts, source, variable);


--
-- Name: radacct_active_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX radacct_active_user_idx ON public.radacct USING btree (username, nasipaddress, acctsessionid) WHERE (acctstoptime IS NULL);


--
-- Name: radacct_start_user_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX radacct_start_user_idx ON public.radacct USING btree (acctstarttime, username);


--
-- Name: radcheck_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX radcheck_username ON public.radcheck USING btree (username, attribute);


--
-- Name: radgroupcheck_groupname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX radgroupcheck_groupname ON public.radgroupcheck USING btree (groupname, attribute);


--
-- Name: radgroupreply_groupname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX radgroupreply_groupname ON public.radgroupreply USING btree (groupname, attribute);


--
-- Name: radreply_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX radreply_username ON public.radreply USING btree (username, attribute);


--
-- Name: radusergroup_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX radusergroup_username ON public.radusergroup USING btree (username);


--
-- Name: trk_contests_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX trk_contests_name_idx ON public.trk_contests USING btree (name);


--
-- Name: trk_contests_uuid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX trk_contests_uuid_idx ON public.trk_contests USING btree (uuid);


--
-- Name: trk_day_planes_day_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trk_day_planes_day_idx ON public.trk_day_aircrafts USING btree (day);


--
-- Name: trk_day_planes_plane_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trk_day_planes_plane_id_idx ON public.trk_day_aircrafts USING btree (aircraft_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: aircrafts fk_rails_046f51b292; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.aircrafts
    ADD CONSTRAINT fk_rails_046f51b292 FOREIGN KEY (owner_id) REFERENCES acao.members(id);


--
-- Name: roster_entries fk_rails_078cdcc4f0; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.roster_entries
    ADD CONSTRAINT fk_rails_078cdcc4f0 FOREIGN KEY (roster_day_id) REFERENCES acao.roster_days(id) ON DELETE CASCADE;


--
-- Name: trailers fk_rails_081665e398; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.trailers
    ADD CONSTRAINT fk_rails_081665e398 FOREIGN KEY (aircraft_id) REFERENCES acao.aircrafts(id);


--
-- Name: member_services fk_rails_0886cc6d1b; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.member_services
    ADD CONSTRAINT fk_rails_0886cc6d1b FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: flights fk_rails_09a414838e; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_09a414838e FOREIGN KEY (pilot2_id) REFERENCES acao.members(id);


--
-- Name: tickets fk_rails_0ac9350a09; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tickets
    ADD CONSTRAINT fk_rails_0ac9350a09 FOREIGN KEY (landing_airfield_id) REFERENCES acao.airfields(id);


--
-- Name: trackers fk_rails_0cb6b830a4; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.trackers
    ADD CONSTRAINT fk_rails_0cb6b830a4 FOREIGN KEY (aircraft_id) REFERENCES acao.aircrafts(id);


--
-- Name: trailers fk_rails_0d0c2077ce; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.trailers
    ADD CONSTRAINT fk_rails_0d0c2077ce FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: token_transactions fk_rails_191dde7206; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.token_transactions
    ADD CONSTRAINT fk_rails_191dde7206 FOREIGN KEY (aircraft_id) REFERENCES acao.aircrafts(id);


--
-- Name: clubs fk_rails_1b7a114b65; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.clubs
    ADD CONSTRAINT fk_rails_1b7a114b65 FOREIGN KEY (airfield_id) REFERENCES acao.airfields(id);


--
-- Name: flights fk_rails_1fe315edf3; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_1fe315edf3 FOREIGN KEY (aircraft_owner_id) REFERENCES acao.members(id);


--
-- Name: flights fk_rails_1fe6e8916f; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_1fe6e8916f FOREIGN KEY (takeoff_location_id) REFERENCES core.locations(id);


--
-- Name: timetable_entries fk_rails_218fd102a3; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.timetable_entries
    ADD CONSTRAINT fk_rails_218fd102a3 FOREIGN KEY (pilot_id) REFERENCES acao.members(id);


--
-- Name: tow_roster_entries fk_rails_2305955a06; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tow_roster_entries
    ADD CONSTRAINT fk_rails_2305955a06 FOREIGN KEY (day_id) REFERENCES acao.tow_roster_days(id);


--
-- Name: aircraft_owners fk_rails_2542121a5d; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.aircraft_owners
    ADD CONSTRAINT fk_rails_2542121a5d FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: payments fk_rails_25fe513812; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.payments
    ADD CONSTRAINT fk_rails_25fe513812 FOREIGN KEY (sp_receiver_id) REFERENCES acao.satispay_entities(id) ON DELETE CASCADE;


--
-- Name: flights fk_rails_27046fa821; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_27046fa821 FOREIGN KEY (landing_location_id) REFERENCES core.locations(id);


--
-- Name: token_transactions fk_rails_280e0cefdf; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.token_transactions
    ADD CONSTRAINT fk_rails_280e0cefdf FOREIGN KEY (session_id) REFERENCES core.sessions(id);


--
-- Name: memberships fk_rails_287365f203; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.memberships
    ADD CONSTRAINT fk_rails_287365f203 FOREIGN KEY (reference_year_id) REFERENCES acao.years(id);


--
-- Name: flarmnet_entries fk_rails_296041249c; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flarmnet_entries
    ADD CONSTRAINT fk_rails_296041249c FOREIGN KEY (aircraft_id) REFERENCES acao.aircrafts(id) ON DELETE SET NULL;


--
-- Name: satispay_profile_pictures fk_rails_29923e07d7; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.satispay_profile_pictures
    ADD CONSTRAINT fk_rails_29923e07d7 FOREIGN KEY (entity_id) REFERENCES acao.satispay_entities(id) ON DELETE CASCADE;


--
-- Name: gates fk_rails_30dd971076; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.gates
    ADD CONSTRAINT fk_rails_30dd971076 FOREIGN KEY (agent_id) REFERENCES core.agents(id);


--
-- Name: timetable_entries fk_rails_31563bc876; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.timetable_entries
    ADD CONSTRAINT fk_rails_31563bc876 FOREIGN KEY (aircraft_id) REFERENCES acao.aircrafts(id);


--
-- Name: trailers fk_rails_3375839e63; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.trailers
    ADD CONSTRAINT fk_rails_3375839e63 FOREIGN KEY (location_id) REFERENCES core.locations(id);


--
-- Name: meters fk_rails_39565ba816; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.meters
    ADD CONSTRAINT fk_rails_39565ba816 FOREIGN KEY (bus_id) REFERENCES acao.meter_buses(id);


--
-- Name: timetable_entries fk_rails_3ac4cff0ef; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.timetable_entries
    ADD CONSTRAINT fk_rails_3ac4cff0ef FOREIGN KEY (takeoff_airfield_id) REFERENCES acao.airfields(id);


--
-- Name: tow_roster_entries fk_rails_3ccca98184; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tow_roster_entries
    ADD CONSTRAINT fk_rails_3ccca98184 FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: tickets fk_rails_3cfc985f6a; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tickets
    ADD CONSTRAINT fk_rails_3cfc985f6a FOREIGN KEY (takeoff_airfield_id) REFERENCES acao.airfields(id);


--
-- Name: payment_services fk_rails_41705eeab7; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.payment_services
    ADD CONSTRAINT fk_rails_41705eeab7 FOREIGN KEY (payment_id) REFERENCES acao.payments(id);


--
-- Name: flights fk_rails_43ac21010d; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_43ac21010d FOREIGN KEY (takeoff_airfield_id) REFERENCES acao.airfields(id);


--
-- Name: member_services fk_rails_52ab95975f; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.member_services
    ADD CONSTRAINT fk_rails_52ab95975f FOREIGN KEY (service_type_id) REFERENCES acao.service_types(id);


--
-- Name: tickets fk_rails_56af1c6c67; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tickets
    ADD CONSTRAINT fk_rails_56af1c6c67 FOREIGN KEY (member_id) REFERENCES acao.members(id) ON DELETE SET NULL;


--
-- Name: roster_entries fk_rails_59678736b3; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.roster_entries
    ADD CONSTRAINT fk_rails_59678736b3 FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: invoices fk_rails_5cf95fcf83; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.invoices
    ADD CONSTRAINT fk_rails_5cf95fcf83 FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: tickets fk_rails_7375842f97; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tickets
    ADD CONSTRAINT fk_rails_7375842f97 FOREIGN KEY (aircraft_id) REFERENCES acao.aircrafts(id);


--
-- Name: flights fk_rails_7827e04cc2; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_7827e04cc2 FOREIGN KEY (pilot1_id) REFERENCES acao.members(id);


--
-- Name: fai_cards fk_rails_7b79a6a52f; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.fai_cards
    ADD CONSTRAINT fk_rails_7b79a6a52f FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: payments fk_rails_82e923f711; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.payments
    ADD CONSTRAINT fk_rails_82e923f711 FOREIGN KEY (sp_sender_id) REFERENCES acao.satispay_entities(id) ON DELETE CASCADE;


--
-- Name: member_services fk_rails_88bbbef30e; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.member_services
    ADD CONSTRAINT fk_rails_88bbbef30e FOREIGN KEY (payment_id) REFERENCES acao.payments(id);


--
-- Name: member_roles fk_rails_8c85e76fea; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.member_roles
    ADD CONSTRAINT fk_rails_8c85e76fea FOREIGN KEY (member_id) REFERENCES acao.members(id) ON DELETE CASCADE;


--
-- Name: flights fk_rails_918c481775; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_918c481775 FOREIGN KEY (aircraft_id) REFERENCES acao.aircrafts(id);


--
-- Name: member_access_remotes fk_rails_9354268f41; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.member_access_remotes
    ADD CONSTRAINT fk_rails_9354268f41 FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: tows fk_rails_94da4ec9ca; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tows
    ADD CONSTRAINT fk_rails_94da4ec9ca FOREIGN KEY (towplane_id) REFERENCES acao.aircrafts(id);


--
-- Name: key_fobs fk_rails_96ad3b77cd; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.key_fobs
    ADD CONSTRAINT fk_rails_96ad3b77cd FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: flights fk_rails_98c45e0307; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_98c45e0307 FOREIGN KEY (landing_airfield_id) REFERENCES acao.airfields(id);


--
-- Name: timetable_entries fk_rails_a5efa5524a; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.timetable_entries
    ADD CONSTRAINT fk_rails_a5efa5524a FOREIGN KEY (towed_by_id) REFERENCES acao.timetable_entries(id) ON DELETE SET NULL;


--
-- Name: invoices fk_rails_a7ffa9f52c; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.invoices
    ADD CONSTRAINT fk_rails_a7ffa9f52c FOREIGN KEY (person_id) REFERENCES core.people(id);


--
-- Name: memberships fk_rails_a81f85748a; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.memberships
    ADD CONSTRAINT fk_rails_a81f85748a FOREIGN KEY (invoice_detail_id) REFERENCES acao.invoice_details(id);


--
-- Name: timetable_entries fk_rails_ac4afa262e; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.timetable_entries
    ADD CONSTRAINT fk_rails_ac4afa262e FOREIGN KEY (landing_airfield_id) REFERENCES acao.airfields(id);


--
-- Name: ogn_ddb_entries fk_rails_ad5f5aefcf; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.ogn_ddb_entries
    ADD CONSTRAINT fk_rails_ad5f5aefcf FOREIGN KEY (aircraft_id) REFERENCES acao.aircrafts(id) ON DELETE SET NULL;


--
-- Name: medicals fk_rails_b4f68e1993; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.medicals
    ADD CONSTRAINT fk_rails_b4f68e1993 FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: bar_transactions fk_rails_b5c7a57039; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.bar_transactions
    ADD CONSTRAINT fk_rails_b5c7a57039 FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: airfields fk_rails_b744cff7d3; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.airfields
    ADD CONSTRAINT fk_rails_b744cff7d3 FOREIGN KEY (location_id) REFERENCES core.locations(id);


--
-- Name: payments fk_rails_b924af1212; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.payments
    ADD CONSTRAINT fk_rails_b924af1212 FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: aircraft_owners fk_rails_baf92d8dce; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.aircraft_owners
    ADD CONSTRAINT fk_rails_baf92d8dce FOREIGN KEY (aircraft_id) REFERENCES acao.aircrafts(id);


--
-- Name: timetable_entries fk_rails_bb5f091f7a; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.timetable_entries
    ADD CONSTRAINT fk_rails_bb5f091f7a FOREIGN KEY (landing_location_id) REFERENCES core.locations(id);


--
-- Name: trailers fk_rails_bb6eb0798c; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.trailers
    ADD CONSTRAINT fk_rails_bb6eb0798c FOREIGN KEY (payment_id) REFERENCES acao.payments(id);


--
-- Name: flights fk_rails_be11b218e4; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_be11b218e4 FOREIGN KEY (towed_by_id) REFERENCES acao.flights(id) ON DELETE SET NULL;


--
-- Name: meter_measures fk_rails_bf04ca9b1b; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.meter_measures
    ADD CONSTRAINT fk_rails_bf04ca9b1b FOREIGN KEY (meter_id) REFERENCES acao.meters(id);


--
-- Name: timetable_entries fk_rails_c231a7ad67; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.timetable_entries
    ADD CONSTRAINT fk_rails_c231a7ad67 FOREIGN KEY (takeoff_location_id) REFERENCES core.locations(id);


--
-- Name: token_transactions fk_rails_c4405dc874; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.token_transactions
    ADD CONSTRAINT fk_rails_c4405dc874 FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: bar_transactions fk_rails_c6b6107ce1; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.bar_transactions
    ADD CONSTRAINT fk_rails_c6b6107ce1 FOREIGN KEY (session_id) REFERENCES core.sessions(id);


--
-- Name: airfield_circuits fk_rails_ccc65d421a; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.airfield_circuits
    ADD CONSTRAINT fk_rails_ccc65d421a FOREIGN KEY (airfield_id) REFERENCES acao.airfields(id);


--
-- Name: tickets fk_rails_ce84b2b39d; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tickets
    ADD CONSTRAINT fk_rails_ce84b2b39d FOREIGN KEY (pilot1_id) REFERENCES acao.members(id) ON DELETE SET NULL;


--
-- Name: payment_services fk_rails_d1da4cc328; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.payment_services
    ADD CONSTRAINT fk_rails_d1da4cc328 FOREIGN KEY (service_type_id) REFERENCES acao.service_types(id);


--
-- Name: flights fk_rails_d4885e4cc3; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.flights
    ADD CONSTRAINT fk_rails_d4885e4cc3 FOREIGN KEY (tow_release_location_id) REFERENCES core.locations(id);


--
-- Name: memberships fk_rails_d50c4f4a6c; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.memberships
    ADD CONSTRAINT fk_rails_d50c4f4a6c FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: aircrafts fk_rails_dafd03fedf; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.aircrafts
    ADD CONSTRAINT fk_rails_dafd03fedf FOREIGN KEY (aircraft_type_id) REFERENCES acao.aircraft_types(id);


--
-- Name: timetable_entries fk_rails_df75379011; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.timetable_entries
    ADD CONSTRAINT fk_rails_df75379011 FOREIGN KEY (tow_release_location_id) REFERENCES core.locations(id);


--
-- Name: memberships fk_rails_e04a443b4d; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.memberships
    ADD CONSTRAINT fk_rails_e04a443b4d FOREIGN KEY (payment_id) REFERENCES acao.payments(id);


--
-- Name: tows fk_rails_e424eb5a3e; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tows
    ADD CONSTRAINT fk_rails_e424eb5a3e FOREIGN KEY (glider_id) REFERENCES acao.aircrafts(id);


--
-- Name: invoice_details fk_rails_e5cda32dbb; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.invoice_details
    ADD CONSTRAINT fk_rails_e5cda32dbb FOREIGN KEY (invoice_id) REFERENCES acao.invoices(id) ON DELETE CASCADE;


--
-- Name: licenses fk_rails_e67293dadf; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.licenses
    ADD CONSTRAINT fk_rails_e67293dadf FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: meters fk_rails_e9e4aa7ceb; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.meters
    ADD CONSTRAINT fk_rails_e9e4aa7ceb FOREIGN KEY (member_id) REFERENCES acao.members(id);


--
-- Name: tickets fk_rails_f0d0f92a56; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.tickets
    ADD CONSTRAINT fk_rails_f0d0f92a56 FOREIGN KEY (pilot2_id) REFERENCES acao.members(id) ON DELETE SET NULL;


--
-- Name: license_ratings fk_rails_f7ed1e1193; Type: FK CONSTRAINT; Schema: acao; Owner: -
--

ALTER TABLE ONLY acao.license_ratings
    ADD CONSTRAINT fk_rails_f7ed1e1193 FOREIGN KEY (license_id) REFERENCES acao.licenses(id);


--
-- Name: le_orders fk_rails_1759662767; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_orders
    ADD CONSTRAINT fk_rails_1759662767 FOREIGN KEY (certificate_id) REFERENCES ca.certificates(id);


--
-- Name: le_slots fk_rails_2d48a085e5; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_slots
    ADD CONSTRAINT fk_rails_2d48a085e5 FOREIGN KEY (account_id) REFERENCES ca.le_accounts(id);


--
-- Name: le_orders fk_rails_46f6fe80e5; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_orders
    ADD CONSTRAINT fk_rails_46f6fe80e5 FOREIGN KEY (account_id) REFERENCES ca.le_accounts(id);


--
-- Name: key_stores fk_rails_69fcf6067c; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.key_stores
    ADD CONSTRAINT fk_rails_69fcf6067c FOREIGN KEY (remote_agent_id) REFERENCES core.agents(id);


--
-- Name: cas fk_rails_75118f9a66; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.cas
    ADD CONSTRAINT fk_rails_75118f9a66 FOREIGN KEY (certificate_id) REFERENCES ca.certificates(id);


--
-- Name: le_accounts fk_rails_8a5a0ffc93; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_accounts
    ADD CONSTRAINT fk_rails_8a5a0ffc93 FOREIGN KEY (key_pair_id) REFERENCES ca.key_pairs(id);


--
-- Name: le_order_auth_challenges fk_rails_9a27c8bb9b; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_order_auth_challenges
    ADD CONSTRAINT fk_rails_9a27c8bb9b FOREIGN KEY (order_auth_id) REFERENCES ca.le_order_auths(id);


--
-- Name: certificates fk_rails_9a8157c661; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.certificates
    ADD CONSTRAINT fk_rails_9a8157c661 FOREIGN KEY (key_pair_id) REFERENCES ca.key_pairs(id);


--
-- Name: certificate_altnames fk_rails_aab5bf2692; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.certificate_altnames
    ADD CONSTRAINT fk_rails_aab5bf2692 FOREIGN KEY (certificate_id) REFERENCES ca.certificates(id);


--
-- Name: le_slots fk_rails_af9cfb8461; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_slots
    ADD CONSTRAINT fk_rails_af9cfb8461 FOREIGN KEY (certificate_id) REFERENCES ca.certificates(id);


--
-- Name: le_orders fk_rails_b1c4814c7e; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_orders
    ADD CONSTRAINT fk_rails_b1c4814c7e FOREIGN KEY (slot_id) REFERENCES ca.le_slots(id);


--
-- Name: le_slots fk_rails_bad4d609c1; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_slots
    ADD CONSTRAINT fk_rails_bad4d609c1 FOREIGN KEY (key_store_id) REFERENCES ca.key_stores(id);


--
-- Name: le_order_auths fk_rails_bd975fde82; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.le_order_auths
    ADD CONSTRAINT fk_rails_bd975fde82 FOREIGN KEY (order_id) REFERENCES ca.le_orders(id);


--
-- Name: key_pair_locations fk_rails_e6b5cc9d1f; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.key_pair_locations
    ADD CONSTRAINT fk_rails_e6b5cc9d1f FOREIGN KEY (pair_id) REFERENCES ca.key_pairs(id);


--
-- Name: key_pair_locations fk_rails_e9c2cf297f; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.key_pair_locations
    ADD CONSTRAINT fk_rails_e9c2cf297f FOREIGN KEY (store_id) REFERENCES ca.key_stores(id);


--
-- Name: cas fk_rails_eeafb41286; Type: FK CONSTRAINT; Schema: ca; Owner: -
--

ALTER TABLE ONLY ca.cas
    ADD CONSTRAINT fk_rails_eeafb41286 FOREIGN KEY (key_pair_id) REFERENCES ca.key_pairs(id);


--
-- Name: klass_collection_role_defs fk_rails_098a1d277c; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.klass_collection_role_defs
    ADD CONSTRAINT fk_rails_098a1d277c FOREIGN KEY (klass_id) REFERENCES core.klasses(id);


--
-- Name: person_roles fk_rails_151929d5f9; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_roles
    ADD CONSTRAINT fk_rails_151929d5f9 FOREIGN KEY (global_role_id) REFERENCES core.global_roles(id);


--
-- Name: organization_people fk_rails_2e2abd5069; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_people
    ADD CONSTRAINT fk_rails_2e2abd5069 FOREIGN KEY (organization_id) REFERENCES core.organizations(id);


--
-- Name: log_entries fk_rails_30b7fff5fe; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.log_entries
    ADD CONSTRAINT fk_rails_30b7fff5fe FOREIGN KEY (http_session_id) REFERENCES core.sessions(id);


--
-- Name: person_emails fk_rails_3a03614bb8; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_emails
    ADD CONSTRAINT fk_rails_3a03614bb8 FOREIGN KEY (person_id) REFERENCES core.people(id) ON DELETE CASCADE;


--
-- Name: klass_members_role_defs fk_rails_3a58f3a83e; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.klass_members_role_defs
    ADD CONSTRAINT fk_rails_3a58f3a83e FOREIGN KEY (klass_id) REFERENCES core.klasses(id);


--
-- Name: people fk_rails_441336acd1; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.people
    ADD CONSTRAINT fk_rails_441336acd1 FOREIGN KEY (preferred_language_id) REFERENCES i18n.languages(id);


--
-- Name: organizations fk_rails_4be04046c2; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organizations
    ADD CONSTRAINT fk_rails_4be04046c2 FOREIGN KEY (invoicing_location_id) REFERENCES core.locations(id);


--
-- Name: tasks fk_rails_545840f30a; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tasks
    ADD CONSTRAINT fk_rails_545840f30a FOREIGN KEY (depends_on_id) REFERENCES core.tasks(id);


--
-- Name: notif_templates fk_rails_589c05e604; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.notif_templates
    ADD CONSTRAINT fk_rails_589c05e604 FOREIGN KEY (language_id) REFERENCES i18n.languages(id);


--
-- Name: log_entry_details fk_rails_5a3fda88cc; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.log_entry_details
    ADD CONSTRAINT fk_rails_5a3fda88cc FOREIGN KEY (log_entry_id) REFERENCES core.log_entries(id);


--
-- Name: task_notifies fk_rails_666d0e3997; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.task_notifies
    ADD CONSTRAINT fk_rails_666d0e3997 FOREIGN KEY (task_id) REFERENCES core.tasks(id);


--
-- Name: people fk_rails_6bfdcb5fe1; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.people
    ADD CONSTRAINT fk_rails_6bfdcb5fe1 FOREIGN KEY (birth_location_id) REFERENCES core.locations(id);


--
-- Name: notifications fk_rails_7a9f1d7ed6; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.notifications
    ADD CONSTRAINT fk_rails_7a9f1d7ed6 FOREIGN KEY (person_id) REFERENCES core.people(id);


--
-- Name: people fk_rails_82624f8f27; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.people
    ADD CONSTRAINT fk_rails_82624f8f27 FOREIGN KEY (residence_location_id) REFERENCES core.locations(id);


--
-- Name: sessions fk_rails_85ef2e4344; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sessions
    ADD CONSTRAINT fk_rails_85ef2e4344 FOREIGN KEY (auth_credential_id) REFERENCES core.person_credentials(id);


--
-- Name: organizations fk_rails_8abc9ce504; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organizations
    ADD CONSTRAINT fk_rails_8abc9ce504 FOREIGN KEY (registered_office_location_id) REFERENCES core.locations(id);


--
-- Name: person_roles fk_rails_8e1e8cf249; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_roles
    ADD CONSTRAINT fk_rails_8e1e8cf249 FOREIGN KEY (person_id) REFERENCES core.people(id);


--
-- Name: organization_people fk_rails_9776cc2001; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_people
    ADD CONSTRAINT fk_rails_9776cc2001 FOREIGN KEY (person_id) REFERENCES core.people(id);


--
-- Name: group_members fk_rails_9d815071b2; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.group_members
    ADD CONSTRAINT fk_rails_9d815071b2 FOREIGN KEY (group_id) REFERENCES core.groups(id);


--
-- Name: person_credentials fk_rails_c4d2798551; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_credentials
    ADD CONSTRAINT fk_rails_c4d2798551 FOREIGN KEY (person_id) REFERENCES core.people(id);


--
-- Name: organizations fk_rails_c65449a0ff; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organizations
    ADD CONSTRAINT fk_rails_c65449a0ff FOREIGN KEY (admin_group_id) REFERENCES core.groups(id);


--
-- Name: group_members fk_rails_d59f1759a6; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.group_members
    ADD CONSTRAINT fk_rails_d59f1759a6 FOREIGN KEY (person_id) REFERENCES core.people(id);


--
-- Name: person_contacts fk_rails_e46ef47d0c; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.person_contacts
    ADD CONSTRAINT fk_rails_e46ef47d0c FOREIGN KEY (person_id) REFERENCES core.people(id);


--
-- Name: organizations fk_rails_eb0e23a6f0; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organizations
    ADD CONSTRAINT fk_rails_eb0e23a6f0 FOREIGN KEY (headquarters_location_id) REFERENCES core.locations(id);


--
-- Name: log_entries fk_rails_f14c964b03; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.log_entries
    ADD CONSTRAINT fk_rails_f14c964b03 FOREIGN KEY (person_id) REFERENCES core.people(id);


--
-- Name: sessions fk_rails_f6fddfe5b6; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sessions
    ADD CONSTRAINT fk_rails_f6fddfe5b6 FOREIGN KEY (language_id) REFERENCES i18n.languages(id);


--
-- Name: sessions fk_rails_fab538a6fa; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.sessions
    ADD CONSTRAINT fk_rails_fab538a6fa FOREIGN KEY (auth_person_id) REFERENCES core.people(id);


--
-- Name: people fk_rails_fc610f9e1c; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.people
    ADD CONSTRAINT fk_rails_fc610f9e1c FOREIGN KEY (invoicing_location_id) REFERENCES core.locations(id);


--
-- Name: translations fk_rails_12a35c2673; Type: FK CONSTRAINT; Schema: i18n; Owner: -
--

ALTER TABLE ONLY i18n.translations
    ADD CONSTRAINT fk_rails_12a35c2673 FOREIGN KEY (phrase_id) REFERENCES i18n.phrases(id);


--
-- Name: translations fk_rails_a5cd8563d9; Type: FK CONSTRAINT; Schema: i18n; Owner: -
--

ALTER TABLE ONLY i18n.translations
    ADD CONSTRAINT fk_rails_a5cd8563d9 FOREIGN KEY (language_id) REFERENCES i18n.languages(id);


--
-- Name: msg_lists fk_rails_09808cf5eb; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_lists
    ADD CONSTRAINT fk_rails_09808cf5eb FOREIGN KEY (msg_id) REFERENCES ml.msgs(id);


--
-- Name: list_members fk_rails_2d2c48b8a7; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.list_members
    ADD CONSTRAINT fk_rails_2d2c48b8a7 FOREIGN KEY (address_id) REFERENCES ml.addresses(id);


--
-- Name: msgs fk_rails_3987712c0e; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msgs
    ADD CONSTRAINT fk_rails_3987712c0e FOREIGN KEY (sender_id) REFERENCES ml.senders(id);


--
-- Name: msg_objects fk_rails_4add5ac8bf; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_objects
    ADD CONSTRAINT fk_rails_4add5ac8bf FOREIGN KEY (msg_id) REFERENCES ml.msgs(id);


--
-- Name: address_validation_tokens fk_rails_5fa823855f; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.address_validation_tokens
    ADD CONSTRAINT fk_rails_5fa823855f FOREIGN KEY (address_id) REFERENCES ml.addresses(id) ON DELETE CASCADE;


--
-- Name: msg_bounces fk_rails_900dcea961; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_bounces
    ADD CONSTRAINT fk_rails_900dcea961 FOREIGN KEY (msg_id) REFERENCES ml.msgs(id);


--
-- Name: msg_lists fk_rails_bde831e29b; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_lists
    ADD CONSTRAINT fk_rails_bde831e29b FOREIGN KEY (list_id) REFERENCES ml.lists(id);


--
-- Name: senders fk_rails_d2ba3b4fbe; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.senders
    ADD CONSTRAINT fk_rails_d2ba3b4fbe FOREIGN KEY (email_dkim_key_pair_id) REFERENCES ca.key_pairs(id);


--
-- Name: msgs fk_rails_db7d8dc6c0; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msgs
    ADD CONSTRAINT fk_rails_db7d8dc6c0 FOREIGN KEY (recipient_id) REFERENCES ml.addresses(id);


--
-- Name: msg_events fk_rails_dcab9deba4; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msg_events
    ADD CONSTRAINT fk_rails_dcab9deba4 FOREIGN KEY (msg_id) REFERENCES ml.msgs(id);


--
-- Name: list_members fk_rails_e86f15a6b0; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.list_members
    ADD CONSTRAINT fk_rails_e86f15a6b0 FOREIGN KEY (list_id) REFERENCES ml.lists(id);


--
-- Name: msgs fk_rails_f224d58e56; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.msgs
    ADD CONSTRAINT fk_rails_f224d58e56 FOREIGN KEY (person_id) REFERENCES core.people(id);


--
-- Name: templates fk_rails_f42a372d9b; Type: FK CONSTRAINT; Schema: ml; Owner: -
--

ALTER TABLE ONLY ml.templates
    ADD CONSTRAINT fk_rails_f42a372d9b FOREIGN KEY (language_id) REFERENCES i18n.languages(id);


--
-- Name: str_channel_variants str_channel_variants_cam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.str_channel_variants
    ADD CONSTRAINT str_channel_variants_cam_id_fkey FOREIGN KEY (channel_id) REFERENCES public.str_channels(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO public;

INSERT INTO "schema_migrations" (version) VALUES
('20251103124817'),
('20251031172144'),
('20251031170811'),
('20251030175317'),
('20251026124251'),
('20251025144510'),
('20251025111127'),
('20251024121004'),
('20251020122322'),
('20251015095856'),
('20251013232750'),
('20251011225621'),
('20251011132904'),
('20251001150720'),
('20250930090714'),
('20250929161248'),
('20250929131033'),
('20250929123504'),
('20250928000213'),
('20250927214108'),
('20250926105900'),
('20250926093614'),
('20250925100306'),
('20250925084811'),
('20250924131802'),
('20250924130350'),
('20250923232423'),
('20250919162236'),
('20250918231753'),
('20250918205536'),
('20250913135029'),
('20250910233732'),
('20250910224218'),
('20250910180325'),
('20250905222507'),
('20250506102139'),
('20241222132719'),
('20241027134506'),
('20241026094125'),
('20240925182027'),
('20240925182020'),
('20240219133727'),
('20240219112218'),
('20240208140120'),
('20231123133007'),
('20231123132257'),
('20231116215432'),
('20230212160016'),
('20230211165223'),
('20221222191301'),
('20220123150235'),
('20210330120030'),
('20210329235808'),
('20210329231036'),
('20210329174846'),
('20210328235158'),
('20210328192304'),
('20210328183142'),
('20201212222909'),
('20201206165302'),
('20201206164609'),
('20201203211423'),
('20201203132939'),
('20201203130801'),
('20201202143343'),
('20201201212910'),
('20201201133519'),
('20201102120000'),
('20201101140010'),
('20201101140008'),
('20201101140007'),
('20201101140006'),
('20201020142318'),
('20161209184846'),
('20140213132169'),
('20140213132168'),
('20140213132167'),
('20140213132166'),
('20140213132165'),
('20140213132164'),
('20140213132163'),
('20140213132162'),
('20140213132161'),
('20140213132160'),
('20140213132159'),
('20140213132158'),
('20140213132157'),
('20140213132156'),
('20140213132155'),
('20140213132154'),
('20140213132153'),
('20140213132152'),
('20140213132151'),
('20140213132150'),
('20140213132149'),
('20140213132148'),
('20140213132147'),
('20140213132146'),
('20140213132145'),
('20140213132144'),
('20140213132143'),
('20140213132142'),
('20140213132141'),
('20140213132140'),
('20140213132139'),
('20140213132138'),
('20140213132137'),
('20140213132136'),
('20140213132135'),
('20140213132134'),
('20140213132133'),
('20140213132132'),
('20140213132131'),
('20140213132130'),
('20140213132129'),
('20140213132128'),
('20140213132127'),
('20140213132126'),
('20140213132125'),
('20140213132124'),
('20140213132123'),
('20140213132122'),
('20140213132121'),
('20140213132120'),
('20140213132119'),
('20140213132118'),
('20140213132117'),
('20140213132116'),
('20140213132115'),
('20140213132114'),
('20140213132113'),
('20140213132112'),
('20140213132111'),
('20140206122900'),
('20140202180845'),
('20140202180844'),
('20140202180843'),
('20140202180842'),
('20140202180841'),
('20140202180840'),
('20140202180839'),
('20140202180838'),
('20140202180835'),
('20140202180834'),
('20140202180833'),
('20140202180832'),
('20140202180831'),
('20140202180830'),
('20140202180829'),
('20140202180828'),
('20140202180827'),
('20140202180826'),
('20140202180825'),
('20140202180824'),
('20140202180823'),
('20140202180822'),
('20140202180821'),
('20140202180820'),
('20140202180819'),
('20140202180818'),
('20140202180817'),
('20140202180816'),
('20140202180815'),
('20140202180814'),
('20140202180813'),
('20140202180812'),
('20140202180811'),
('20140202180810'),
('20140202180809'),
('20140202180808'),
('20140125020700');

