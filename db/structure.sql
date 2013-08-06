--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

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
    default_choice boolean
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
    net_item_cents integer DEFAULT 0 NOT NULL,
    tax_item_cents integer DEFAULT 0 NOT NULL,
    local_net_item_cents integer DEFAULT 0 NOT NULL,
    local_net_item_currency character varying(255) DEFAULT 'USD'::character varying NOT NULL,
    local_tax_item_cents integer DEFAULT 0 NOT NULL,
    exchange_rate numeric(10,7),
    vat_rate numeric(5,2),
    net_total_item_cents integer DEFAULT 0 NOT NULL,
    tax_total_item_cents integer DEFAULT 0 NOT NULL,
    discount_per_cent numeric(8,2),
    discount_cents integer DEFAULT 0 NOT NULL,
    discount_currency character varying(255) DEFAULT 'USD'::character varying NOT NULL,
    ownable_id integer,
    ownable_type character varying(255),
    choices hstore,
    ancestry character varying(255),
    ancestry_depth integer DEFAULT 0,
    option_id integer,
    options character varying(255)
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
-- Name: meals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meals (
    id integer NOT NULL,
    seating_id integer,
    tabel_name character varying(255),
    start_time time without time zone,
    state character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: meals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE meals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE meals_id_seq OWNED BY meals.id;


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
    home_supplier character varying(255)
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
    price_cents integer DEFAULT 0 NOT NULL
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

ALTER TABLE ONLY elements ALTER COLUMN id SET DEFAULT nextval('elements_id_seq'::regclass);


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

ALTER TABLE ONLY meals ALTER COLUMN id SET DEFAULT nextval('meals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY options ALTER COLUMN id SET DEFAULT nextval('options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tenancies ALTER COLUMN id SET DEFAULT nextval('tenancies_id_seq'::regclass);


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
-- Name: elements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY elements
    ADD CONSTRAINT elements_pkey PRIMARY KEY (id);


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
-- Name: meals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meals
    ADD CONSTRAINT meals_pkey PRIMARY KEY (id);


--
-- Name: options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: tenancies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tenancies
    ADD CONSTRAINT tenancies_pkey PRIMARY KEY (id);


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
-- Name: index_item_types_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_types_on_account_id ON item_types USING btree (account_id);


--
-- Name: index_meals_on_seating_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meals_on_seating_id ON meals USING btree (seating_id);


--
-- Name: index_meals_on_start_time; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meals_on_start_time ON meals USING btree (start_time);


--
-- Name: index_meals_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meals_on_state ON meals USING btree (state);


--
-- Name: index_meals_on_tabel_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meals_on_tabel_name ON meals USING btree (tabel_name);


--
-- Name: index_options_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_options_on_name ON options USING btree (name);


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

SET search_path TO vernas;

INSERT INTO schema_migrations (version) VALUES ('20130707204916');

INSERT INTO schema_migrations (version) VALUES ('20130709161628');

INSERT INTO schema_migrations (version) VALUES ('20130710163822');

INSERT INTO schema_migrations (version) VALUES ('20130714144039');

INSERT INTO schema_migrations (version) VALUES ('20130715092149');

INSERT INTO schema_migrations (version) VALUES ('20130715154250');

INSERT INTO schema_migrations (version) VALUES ('20130715173319');

INSERT INTO schema_migrations (version) VALUES ('20130716130544');

INSERT INTO schema_migrations (version) VALUES ('20130716131612');

INSERT INTO schema_migrations (version) VALUES ('20130716163248');

INSERT INTO schema_migrations (version) VALUES ('20130717084246');

INSERT INTO schema_migrations (version) VALUES ('20130717085810');

INSERT INTO schema_migrations (version) VALUES ('20130717090033');

INSERT INTO schema_migrations (version) VALUES ('20130717145651');

INSERT INTO schema_migrations (version) VALUES ('20130718140002');

INSERT INTO schema_migrations (version) VALUES ('20130718142147');

INSERT INTO schema_migrations (version) VALUES ('20130718163433');

INSERT INTO schema_migrations (version) VALUES ('20130719084441');

INSERT INTO schema_migrations (version) VALUES ('20130719091722');

INSERT INTO schema_migrations (version) VALUES ('20130719143415');

INSERT INTO schema_migrations (version) VALUES ('20130719143429');

INSERT INTO schema_migrations (version) VALUES ('20130719170855');

INSERT INTO schema_migrations (version) VALUES ('20130720102928');

INSERT INTO schema_migrations (version) VALUES ('20130720191140');

INSERT INTO schema_migrations (version) VALUES ('20130721141635');

INSERT INTO schema_migrations (version) VALUES ('20130722092506');

INSERT INTO schema_migrations (version) VALUES ('20130723143352');

INSERT INTO schema_migrations (version) VALUES ('20130724141531');

INSERT INTO schema_migrations (version) VALUES ('20130725122611');

INSERT INTO schema_migrations (version) VALUES ('20130725122612');

INSERT INTO schema_migrations (version) VALUES ('20130726172722');

INSERT INTO schema_migrations (version) VALUES ('20130726172723');

INSERT INTO schema_migrations (version) VALUES ('20130726172724');

INSERT INTO schema_migrations (version) VALUES ('20130727203148');

INSERT INTO schema_migrations (version) VALUES ('20130727203150');

INSERT INTO schema_migrations (version) VALUES ('20130727203151');

INSERT INTO schema_migrations (version) VALUES ('20130728154637');

INSERT INTO schema_migrations (version) VALUES ('20130728154638');

INSERT INTO schema_migrations (version) VALUES ('20130804084256');

INSERT INTO schema_migrations (version) VALUES ('20130804175215');

INSERT INTO schema_migrations (version) VALUES ('20130804182857');

INSERT INTO schema_migrations (version) VALUES ('20130804184638');

INSERT INTO schema_migrations (version) VALUES ('20130804185443');

INSERT INTO schema_migrations (version) VALUES ('20130806153507');
