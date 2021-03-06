--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: allocations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE allocations (
    id integer NOT NULL,
    amount_cents integer DEFAULT 0 NOT NULL,
    payment_id integer,
    order_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: allocations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE allocations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: allocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE allocations_id_seq OWNED BY allocations.id;


--
-- Name: apportions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apportions (
    id integer NOT NULL,
    receipt_id integer,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying(255) DEFAULT 'USD'::character varying NOT NULL,
    account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "desc" character varying(255)
);


--
-- Name: apportions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apportions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: apportions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apportions_id_seq OWNED BY apportions.id;


--
-- Name: banks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE banks (
    id integer NOT NULL,
    name character varying(255),
    sort_code character varying(255),
    account_no character varying(255),
    opening_balance_cents integer DEFAULT 0 NOT NULL,
    opening_balance_currency character varying(255) DEFAULT 'USD'::character varying NOT NULL,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    rank integer,
    reference character varying,
    statement boolean
);


--
-- Name: banks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE banks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: banks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE banks_id_seq OWNED BY banks.id;


--
-- Name: broadcasts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE broadcasts (
    id integer NOT NULL,
    code character varying(255),
    title character varying(255),
    sub character varying(255),
    body text,
    topic_id integer,
    user_id integer,
    credit character varying(255),
    publish boolean,
    release date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    color character varying(255),
    image character varying(255),
    body2 text,
    body3 text,
    link character varying(255),
    link2 character varying(255),
    link3 character varying(255),
    event_date date,
    event_time time without time zone,
    repeat integer,
    frequency character varying(255),
    category character varying(255),
    blog boolean,
    slug character varying(255)
);


--
-- Name: broadcasts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE broadcasts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: broadcasts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE broadcasts_id_seq OWNED BY broadcasts.id;


--
-- Name: dailies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE dailies (
    id integer NOT NULL,
    account_date date,
    take_cents integer DEFAULT 0 NOT NULL,
    take_currency character varying(255) DEFAULT 'GBP'::character varying NOT NULL,
    tips_cents integer DEFAULT 0 NOT NULL,
    tips_currency character varying(255) DEFAULT 'GBP'::character varying NOT NULL,
    credit_card_cents integer DEFAULT 0 NOT NULL,
    credit_card_currency character varying(255) DEFAULT 'GBP'::character varying NOT NULL,
    headcount integer,
    session character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pax integer,
    booked_pax integer,
    walkin_pax integer,
    takeaways integer,
    seated_cents integer DEFAULT 0 NOT NULL,
    takeaway_cents integer DEFAULT 0 NOT NULL,
    discount_cents integer DEFAULT 0 NOT NULL,
    turnover_cents integer DEFAULT 0 NOT NULL,
    tax_cents integer DEFAULT 0 NOT NULL,
    safe_cents integer DEFAULT 0 NOT NULL,
    petty_cents integer DEFAULT 0 NOT NULL,
    bank_cents integer DEFAULT 0 NOT NULL,
    till_cents integer DEFAULT 0 NOT NULL,
    surplus_cents integer DEFAULT 0 NOT NULL,
    petty_reason character varying(255),
    safe_cash_cents integer DEFAULT 0 NOT NULL,
    processed boolean,
    fin_year integer,
    week_no integer
);


--
-- Name: dailies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dailies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dailies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dailies_id_seq OWNED BY dailies.id;


--
-- Name: elements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE elements (
    id integer NOT NULL,
    name character varying(255),
    kind character varying(255),
    "desc" character varying(255),
    rank integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    default_choice boolean,
    properties hstore
);


--
-- Name: elements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE elements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: elements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE elements_id_seq OWNED BY elements.id;


--
-- Name: ingredients; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ingredients (
    id integer NOT NULL,
    name character varying,
    supplier_id integer,
    reference character varying,
    quantity_id integer,
    unit_id integer,
    live boolean DEFAULT true,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    cost_cents integer
);


--
-- Name: ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ingredients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ingredients_id_seq OWNED BY ingredients.id;


--
-- Name: item_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE item_fields (
    id integer NOT NULL,
    name character varying(255),
    field_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    options boolean,
    rank integer
);


--
-- Name: item_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE item_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE item_fields_id_seq OWNED BY item_fields.id;


--
-- Name: item_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE item_types (
    id integer NOT NULL,
    name character varying(255),
    rank integer,
    properties hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    menu_depth integer,
    account_id integer,
    vat_rate character varying(255) DEFAULT 'standard'::character varying
);


--
-- Name: item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE item_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE item_types_id_seq OWNED BY item_types.id;


--
-- Name: line_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE line_items (
    id integer NOT NULL,
    variant_id integer,
    quantity integer,
    state character varying(255),
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    domain character varying(255),
    "desc" character varying(255),
    account_id integer,
    tax_item_cents integer DEFAULT 0 NOT NULL,
    exchange_rate numeric(10,7) DEFAULT 1,
    vat_rate numeric(5,2),
    net_total_item_cents integer DEFAULT 0 NOT NULL,
    tax_total_item_cents integer DEFAULT 0 NOT NULL,
    discount_per_cent numeric(8,2),
    discount_cents integer DEFAULT 0 NOT NULL,
    ownable_id integer,
    ownable_type character varying(255),
    choices hstore,
    ancestry character varying(255),
    ancestry_depth integer DEFAULT 0,
    option_id integer,
    options character varying(255),
    net_item_cents integer DEFAULT 0 NOT NULL,
    net_item_currency character varying(255) DEFAULT 'GBP'::character varying NOT NULL,
    net_home_cents integer DEFAULT 0 NOT NULL,
    tax_home_cents integer DEFAULT 0 NOT NULL,
    contra boolean,
    special character varying(255)
);


--
-- Name: line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE line_items_id_seq OWNED BY line_items.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages (
    id integer NOT NULL,
    message character varying(255),
    user_id integer,
    message_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: monthlies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE monthlies (
    id integer NOT NULL,
    takings_cents integer DEFAULT 0 NOT NULL,
    credit_card_cents integer DEFAULT 0 NOT NULL,
    cash_cents integer DEFAULT 0 NOT NULL,
    tax_cents integer DEFAULT 0 NOT NULL,
    turnover_cents integer DEFAULT 0 NOT NULL,
    cash_used_cents integer DEFAULT 0 NOT NULL
);


--
-- Name: monthlies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE monthlies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monthlies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE monthlies_id_seq OWNED BY monthlies.id;


--
-- Name: offers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE offers (
    id integer NOT NULL,
    days character varying(255)[],
    offer_type character varying(255),
    amount numeric,
    name character varying(255),
    short character varying(255),
    "desc" text,
    notes text,
    live boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    rank integer,
    categories character varying(255)[]
);


--
-- Name: offers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE offers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: offers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE offers_id_seq OWNED BY offers.id;


--
-- Name: openings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE openings (
    id integer NOT NULL,
    start_date date,
    end_date date,
    repeat integer,
    frequency character varying(255),
    status character varying(255),
    message character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: openings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE openings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: openings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE openings_id_seq OWNED BY openings.id;


--
-- Name: options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE options (
    id integer NOT NULL,
    name character varying(255),
    price_cents integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    kind character varying(255),
    vat_rate character varying(255),
    rank integer
);


--
-- Name: options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE options_id_seq OWNED BY options.id;


--
-- Name: pay_rates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pay_rates (
    id integer NOT NULL,
    employee_id integer,
    effective_date date,
    rate_cents integer DEFAULT 0 NOT NULL,
    rate_currency character varying(255) DEFAULT 'USD'::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: pay_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pay_rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pay_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pay_rates_id_seq OWNED BY pay_rates.id;


--
-- Name: receipts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE receipts (
    id integer NOT NULL,
    receipt_date date,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying(255) DEFAULT 'USD'::character varying NOT NULL,
    bank_id integer,
    exchange_rate character varying(255),
    home_amount_cents integer DEFAULT 0 NOT NULL,
    state character varying(255),
    receivable_type character varying(255),
    receivable_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "desc" character varying(255),
    order_id integer
);


--
-- Name: receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE receipts_id_seq OWNED BY receipts.id;


--
-- Name: recipes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE recipes (
    id integer NOT NULL,
    item_id integer,
    ingredient_id integer,
    amount_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: recipes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE recipes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE recipes_id_seq OWNED BY recipes.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    user_id integer,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: stocks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stocks (
    id integer NOT NULL,
    stock_date date,
    item_option character varying,
    stock_level integer,
    stock_unit character varying,
    item_id integer,
    timestamps character varying
);


--
-- Name: stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stocks_id_seq OWNED BY stocks.id;


--
-- Name: tenancies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tenancies (
    id integer NOT NULL,
    name character varying(255),
    domain character varying(255),
    hostname character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    properties hstore,
    default_category character varying(255),
    vat_exempt boolean DEFAULT false,
    home_supplier character varying(255),
    home_currency character varying(255),
    email character varying(255),
    address character varying(255),
    phone character varying(255),
    company character varying(255),
    coho character varying(255),
    vat character varying(255),
    title character varying(255),
    description text,
    keywords text,
    capacity integer,
    supplier_id integer,
    menu character varying(255)
);


--
-- Name: tenancies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tenancies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenancies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tenancies_id_seq OWNED BY tenancies.id;


--
-- Name: timesheets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE timesheets (
    id integer NOT NULL,
    employee_id integer,
    hours numeric,
    work_date date,
    start_time time without time zone,
    end_time time without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    session character varying(255),
    pay_cents integer DEFAULT 0 NOT NULL
);


--
-- Name: timesheets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE timesheets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timesheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE timesheets_id_seq OWNED BY timesheets.id;


--
-- Name: timings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE timings (
    id integer NOT NULL,
    state character varying,
    timeable_type character varying,
    timeable_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: timings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE timings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE timings_id_seq OWNED BY timings.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE topics (
    id integer NOT NULL,
    name character varying(255),
    rank integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE topics_id_seq OWNED BY topics.id;


--
-- Name: transfers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transfers (
    id integer NOT NULL,
    transfer_date date,
    bank_id integer,
    recipient_id integer,
    exchange_rate numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying(255) DEFAULT 'USD'::character varying NOT NULL,
    "desc" character varying(255),
    state character varying(255) DEFAULT 'incomplete'::character varying,
    notes character varying(255)
);


--
-- Name: transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transfers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transfers_id_seq OWNED BY transfers.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255),
    username character varying(255),
    password_digest character varying(255),
    password_reset_token character varying(255),
    password_reset_sent_at timestamp without time zone,
    auth_token character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    first_name character varying(255),
    last_name character varying(255),
    title character varying(255),
    active boolean,
    workforce boolean
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: variant_stocks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE variant_stocks (
    id integer NOT NULL,
    variant_id integer,
    stock integer,
    domain character varying(255),
    options hstore
);


--
-- Name: variant_stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE variant_stocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: variant_stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE variant_stocks_id_seq OWNED BY variant_stocks.id;


--
-- Name: variants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE variants (
    id integer NOT NULL,
    item_id integer,
    domain character varying(255),
    name character varying(255),
    "desc" text,
    item_default boolean,
    stock integer,
    available_on date,
    properties hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    options hstore,
    slug character varying(255),
    price_cents integer DEFAULT 0 NOT NULL,
    rank integer,
    withdrawn boolean,
    remote_order boolean DEFAULT true
);


--
-- Name: variants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE variants_id_seq OWNED BY variants.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY allocations ALTER COLUMN id SET DEFAULT nextval('allocations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY apportions ALTER COLUMN id SET DEFAULT nextval('apportions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY banks ALTER COLUMN id SET DEFAULT nextval('banks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY broadcasts ALTER COLUMN id SET DEFAULT nextval('broadcasts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dailies ALTER COLUMN id SET DEFAULT nextval('dailies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY elements ALTER COLUMN id SET DEFAULT nextval('elements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ingredients ALTER COLUMN id SET DEFAULT nextval('ingredients_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_fields ALTER COLUMN id SET DEFAULT nextval('item_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_types ALTER COLUMN id SET DEFAULT nextval('item_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY line_items ALTER COLUMN id SET DEFAULT nextval('line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY monthlies ALTER COLUMN id SET DEFAULT nextval('monthlies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY offers ALTER COLUMN id SET DEFAULT nextval('offers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY openings ALTER COLUMN id SET DEFAULT nextval('openings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY options ALTER COLUMN id SET DEFAULT nextval('options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pay_rates ALTER COLUMN id SET DEFAULT nextval('pay_rates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY receipts ALTER COLUMN id SET DEFAULT nextval('receipts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY recipes ALTER COLUMN id SET DEFAULT nextval('recipes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stocks ALTER COLUMN id SET DEFAULT nextval('stocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tenancies ALTER COLUMN id SET DEFAULT nextval('tenancies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY timesheets ALTER COLUMN id SET DEFAULT nextval('timesheets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY timings ALTER COLUMN id SET DEFAULT nextval('timings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics ALTER COLUMN id SET DEFAULT nextval('topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transfers ALTER COLUMN id SET DEFAULT nextval('transfers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY variant_stocks ALTER COLUMN id SET DEFAULT nextval('variant_stocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY variants ALTER COLUMN id SET DEFAULT nextval('variants_id_seq'::regclass);


--
-- Name: allocations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY allocations
    ADD CONSTRAINT allocations_pkey PRIMARY KEY (id);


--
-- Name: apportions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apportions
    ADD CONSTRAINT apportions_pkey PRIMARY KEY (id);


--
-- Name: banks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY banks
    ADD CONSTRAINT banks_pkey PRIMARY KEY (id);


--
-- Name: broadcasts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY broadcasts
    ADD CONSTRAINT broadcasts_pkey PRIMARY KEY (id);


--
-- Name: dailies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dailies
    ADD CONSTRAINT dailies_pkey PRIMARY KEY (id);


--
-- Name: elements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY elements
    ADD CONSTRAINT elements_pkey PRIMARY KEY (id);


--
-- Name: ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);


--
-- Name: item_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item_fields
    ADD CONSTRAINT item_fields_pkey PRIMARY KEY (id);


--
-- Name: item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item_types
    ADD CONSTRAINT item_types_pkey PRIMARY KEY (id);


--
-- Name: line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY line_items
    ADD CONSTRAINT line_items_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: monthlies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY monthlies
    ADD CONSTRAINT monthlies_pkey PRIMARY KEY (id);


--
-- Name: offers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY offers
    ADD CONSTRAINT offers_pkey PRIMARY KEY (id);


--
-- Name: openings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY openings
    ADD CONSTRAINT openings_pkey PRIMARY KEY (id);


--
-- Name: options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: pay_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pay_rates
    ADD CONSTRAINT pay_rates_pkey PRIMARY KEY (id);


--
-- Name: receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);


--
-- Name: recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- Name: tenancies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tenancies
    ADD CONSTRAINT tenancies_pkey PRIMARY KEY (id);


--
-- Name: timesheets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY timesheets
    ADD CONSTRAINT timesheets_pkey PRIMARY KEY (id);


--
-- Name: timings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY timings
    ADD CONSTRAINT timings_pkey PRIMARY KEY (id);


--
-- Name: topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transfers
    ADD CONSTRAINT transfers_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: variant_stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY variant_stocks
    ADD CONSTRAINT variant_stocks_pkey PRIMARY KEY (id);


--
-- Name: variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY variants
    ADD CONSTRAINT variants_pkey PRIMARY KEY (id);


--
-- Name: index_allocations_on_order_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_allocations_on_order_id ON allocations USING btree (order_id);


--
-- Name: index_allocations_on_payment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_allocations_on_payment_id ON allocations USING btree (payment_id);


--
-- Name: index_apportions_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apportions_on_account_id ON apportions USING btree (account_id);


--
-- Name: index_apportions_on_receipt_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_apportions_on_receipt_id ON apportions USING btree (receipt_id);


--
-- Name: index_broadcasts_on_topic_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_broadcasts_on_topic_id ON broadcasts USING btree (topic_id);


--
-- Name: index_item_types_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_types_on_account_id ON item_types USING btree (account_id);


--
-- Name: index_messages_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_user_id ON messages USING btree (user_id);


--
-- Name: index_options_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_options_on_name ON options USING btree (name);


--
-- Name: index_pay_rates_on_employee_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pay_rates_on_employee_id ON pay_rates USING btree (employee_id);


--
-- Name: index_receipts_on_bank_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_receipts_on_bank_id ON receipts USING btree (bank_id);


--
-- Name: index_receipts_on_order_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_receipts_on_order_id ON receipts USING btree (order_id);


--
-- Name: index_tenancies_on_supplier_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tenancies_on_supplier_id ON tenancies USING btree (supplier_id);


--
-- Name: index_transfers_on_bank_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transfers_on_bank_id ON transfers USING btree (bank_id);


--
-- Name: index_transfers_on_recipient_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transfers_on_recipient_id ON transfers USING btree (recipient_id);


--
-- Name: index_variants_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_variants_on_slug ON variants USING btree (slug);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO public;

INSERT INTO schema_migrations (version) VALUES ('20130701014230');

INSERT INTO schema_migrations (version) VALUES ('20130701151124');

INSERT INTO schema_migrations (version) VALUES ('20130701152140');

INSERT INTO schema_migrations (version) VALUES ('20130701190841');

INSERT INTO schema_migrations (version) VALUES ('20130702085711');

INSERT INTO schema_migrations (version) VALUES ('20130707204916');

INSERT INTO schema_migrations (version) VALUES ('20130708170118');

INSERT INTO schema_migrations (version) VALUES ('20130710122322');

INSERT INTO schema_migrations (version) VALUES ('20130710125338');

INSERT INTO schema_migrations (version) VALUES ('20130710130947');

INSERT INTO schema_migrations (version) VALUES ('20130710135720');

INSERT INTO schema_migrations (version) VALUES ('20130710152108');

INSERT INTO schema_migrations (version) VALUES ('20130711145709');

INSERT INTO schema_migrations (version) VALUES ('20130711151459');

INSERT INTO schema_migrations (version) VALUES ('20130711161814');

INSERT INTO schema_migrations (version) VALUES ('20130711181420');

INSERT INTO schema_migrations (version) VALUES ('20130712162051');

INSERT INTO schema_migrations (version) VALUES ('20130714144039');

INSERT INTO schema_migrations (version) VALUES ('20130714155255');

INSERT INTO schema_migrations (version) VALUES ('20130715092149');

INSERT INTO schema_migrations (version) VALUES ('20130715154250');

INSERT INTO schema_migrations (version) VALUES ('20130715173319');

INSERT INTO schema_migrations (version) VALUES ('20130715174648');

INSERT INTO schema_migrations (version) VALUES ('20130716115720');

INSERT INTO schema_migrations (version) VALUES ('20130716130544');

INSERT INTO schema_migrations (version) VALUES ('20130716131550');

INSERT INTO schema_migrations (version) VALUES ('20130716163248');

INSERT INTO schema_migrations (version) VALUES ('20130716163433');

INSERT INTO schema_migrations (version) VALUES ('20130717084246');

INSERT INTO schema_migrations (version) VALUES ('20130717085810');

INSERT INTO schema_migrations (version) VALUES ('20130717090033');

INSERT INTO schema_migrations (version) VALUES ('20130718142147');

INSERT INTO schema_migrations (version) VALUES ('20130718163433');

INSERT INTO schema_migrations (version) VALUES ('20130719084441');

INSERT INTO schema_migrations (version) VALUES ('20130719091722');

INSERT INTO schema_migrations (version) VALUES ('20130720183230');

INSERT INTO schema_migrations (version) VALUES ('20130721085503');

INSERT INTO schema_migrations (version) VALUES ('20130722184306');

INSERT INTO schema_migrations (version) VALUES ('20130723104915');

INSERT INTO schema_migrations (version) VALUES ('20130723184451');

INSERT INTO schema_migrations (version) VALUES ('20130724121531');

INSERT INTO schema_migrations (version) VALUES ('20130724132429');

INSERT INTO schema_migrations (version) VALUES ('20130724141531');

INSERT INTO schema_migrations (version) VALUES ('20130725122611');

INSERT INTO schema_migrations (version) VALUES ('20130725122612');

INSERT INTO schema_migrations (version) VALUES ('20130725141742');

INSERT INTO schema_migrations (version) VALUES ('20130728154638');

INSERT INTO schema_migrations (version) VALUES ('20130728192503');

INSERT INTO schema_migrations (version) VALUES ('20130729133633');

INSERT INTO schema_migrations (version) VALUES ('20130804090532');

INSERT INTO schema_migrations (version) VALUES ('20130804091558');

INSERT INTO schema_migrations (version) VALUES ('20130804175215');

INSERT INTO schema_migrations (version) VALUES ('20130804182857');

INSERT INTO schema_migrations (version) VALUES ('20130804184638');

INSERT INTO schema_migrations (version) VALUES ('20130804185443');

INSERT INTO schema_migrations (version) VALUES ('20130804193531');

INSERT INTO schema_migrations (version) VALUES ('20130805080025');

INSERT INTO schema_migrations (version) VALUES ('20130805191105');

INSERT INTO schema_migrations (version) VALUES ('20130807082648');

INSERT INTO schema_migrations (version) VALUES ('20130807100241');

INSERT INTO schema_migrations (version) VALUES ('20130808183346');

INSERT INTO schema_migrations (version) VALUES ('20130808183525');

INSERT INTO schema_migrations (version) VALUES ('20130808183809');

INSERT INTO schema_migrations (version) VALUES ('20130808184843');

INSERT INTO schema_migrations (version) VALUES ('20130808190659');

INSERT INTO schema_migrations (version) VALUES ('20130813183525');

INSERT INTO schema_migrations (version) VALUES ('20130821195508');

INSERT INTO schema_migrations (version) VALUES ('20130823093131');

INSERT INTO schema_migrations (version) VALUES ('20130826151442');

INSERT INTO schema_migrations (version) VALUES ('20130826182631');

INSERT INTO schema_migrations (version) VALUES ('20130826183311');

INSERT INTO schema_migrations (version) VALUES ('20130826191516');

INSERT INTO schema_migrations (version) VALUES ('20130829211529');

INSERT INTO schema_migrations (version) VALUES ('20130829224328');

INSERT INTO schema_migrations (version) VALUES ('20130829224355');

INSERT INTO schema_migrations (version) VALUES ('20130829225211');

INSERT INTO schema_migrations (version) VALUES ('20130830065444');

INSERT INTO schema_migrations (version) VALUES ('20130830143324');

INSERT INTO schema_migrations (version) VALUES ('20130905205906');

INSERT INTO schema_migrations (version) VALUES ('20130908170101');

INSERT INTO schema_migrations (version) VALUES ('20140107163028');

INSERT INTO schema_migrations (version) VALUES ('20140107171640');

INSERT INTO schema_migrations (version) VALUES ('20140108155344');

INSERT INTO schema_migrations (version) VALUES ('20140108155524');

INSERT INTO schema_migrations (version) VALUES ('20140110155715');

INSERT INTO schema_migrations (version) VALUES ('20140111130646');

INSERT INTO schema_migrations (version) VALUES ('20140111134530');

INSERT INTO schema_migrations (version) VALUES ('20140111143039');

INSERT INTO schema_migrations (version) VALUES ('20140113154208');

INSERT INTO schema_migrations (version) VALUES ('20140117170920');

INSERT INTO schema_migrations (version) VALUES ('20140118134215');

INSERT INTO schema_migrations (version) VALUES ('20140119101002');

INSERT INTO schema_migrations (version) VALUES ('20140124161344');

INSERT INTO schema_migrations (version) VALUES ('20140125174409');

INSERT INTO schema_migrations (version) VALUES ('20140126104520');

INSERT INTO schema_migrations (version) VALUES ('20140327111006');

INSERT INTO schema_migrations (version) VALUES ('20140328135627');

INSERT INTO schema_migrations (version) VALUES ('20140402124552');

INSERT INTO schema_migrations (version) VALUES ('20140404081214');

INSERT INTO schema_migrations (version) VALUES ('20140404141219');

INSERT INTO schema_migrations (version) VALUES ('20140404143054');

INSERT INTO schema_migrations (version) VALUES ('20140404155951');

INSERT INTO schema_migrations (version) VALUES ('20140404160025');

INSERT INTO schema_migrations (version) VALUES ('20140406111239');

INSERT INTO schema_migrations (version) VALUES ('20140406113407');

INSERT INTO schema_migrations (version) VALUES ('20140406133802');

INSERT INTO schema_migrations (version) VALUES ('20140409115522');

INSERT INTO schema_migrations (version) VALUES ('20140409115533');

INSERT INTO schema_migrations (version) VALUES ('20140410132027');

INSERT INTO schema_migrations (version) VALUES ('20140414132657');

INSERT INTO schema_migrations (version) VALUES ('20140415132658');

INSERT INTO schema_migrations (version) VALUES ('20140415143356');

INSERT INTO schema_migrations (version) VALUES ('20140418115328');

INSERT INTO schema_migrations (version) VALUES ('20140423093531');

INSERT INTO schema_migrations (version) VALUES ('20140423093532');

INSERT INTO schema_migrations (version) VALUES ('20140424143318');

INSERT INTO schema_migrations (version) VALUES ('20140425142059');

INSERT INTO schema_migrations (version) VALUES ('20140425142943');

INSERT INTO schema_migrations (version) VALUES ('20140426155426');

INSERT INTO schema_migrations (version) VALUES ('20140427102159');

INSERT INTO schema_migrations (version) VALUES ('20140522102323');

INSERT INTO schema_migrations (version) VALUES ('20140617145006');

INSERT INTO schema_migrations (version) VALUES ('20140626095338');

INSERT INTO schema_migrations (version) VALUES ('20140626133108');

INSERT INTO schema_migrations (version) VALUES ('20140707111836');

INSERT INTO schema_migrations (version) VALUES ('20140715104351');

INSERT INTO schema_migrations (version) VALUES ('20140721112054');

INSERT INTO schema_migrations (version) VALUES ('20140724143920');

INSERT INTO schema_migrations (version) VALUES ('20140725145454');

INSERT INTO schema_migrations (version) VALUES ('20140725145847');

INSERT INTO schema_migrations (version) VALUES ('20150729112535');

INSERT INTO schema_migrations (version) VALUES ('20150731133450');

INSERT INTO schema_migrations (version) VALUES ('20150731144144');

INSERT INTO schema_migrations (version) VALUES ('20150731164634');

INSERT INTO schema_migrations (version) VALUES ('20150731165747');

INSERT INTO schema_migrations (version) VALUES ('20150802153321');

INSERT INTO schema_migrations (version) VALUES ('20150802153722');

INSERT INTO schema_migrations (version) VALUES ('20150802161025');

INSERT INTO schema_migrations (version) VALUES ('20150826135718');

INSERT INTO schema_migrations (version) VALUES ('20150827105711');

INSERT INTO schema_migrations (version) VALUES ('20150827115527');

INSERT INTO schema_migrations (version) VALUES ('20150827210844');

INSERT INTO schema_migrations (version) VALUES ('20150909105645');

INSERT INTO schema_migrations (version) VALUES ('20151013082238');

INSERT INTO schema_migrations (version) VALUES ('20151015104804');

INSERT INTO schema_migrations (version) VALUES ('20151015110351');

INSERT INTO schema_migrations (version) VALUES ('20151015143647');

INSERT INTO schema_migrations (version) VALUES ('20151015201125');

