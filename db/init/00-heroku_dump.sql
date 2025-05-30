--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4 (Debian 17.4-1.pgdg120+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: _heroku; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA _heroku;


--
-- Name: heroku_ext; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA heroku_ext;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: create_ext(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.create_ext() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE

  schemaname TEXT;
  databaseowner TEXT;

  r RECORD;

BEGIN

  IF tg_tag = 'CREATE EXTENSION' and current_user != 'rds_superuser' THEN
    FOR r IN SELECT * FROM pg_event_trigger_ddl_commands()
    LOOP
        CONTINUE WHEN r.command_tag != 'CREATE EXTENSION' OR r.object_type != 'extension';

        schemaname = (
            SELECT n.nspname
            FROM pg_catalog.pg_extension AS e
            INNER JOIN pg_catalog.pg_namespace AS n
            ON e.extnamespace = n.oid
            WHERE e.oid = r.objid
        );

        databaseowner = (
            SELECT pg_catalog.pg_get_userbyid(d.datdba)
            FROM pg_catalog.pg_database d
            WHERE d.datname = current_database()
        );
        --RAISE NOTICE 'Record for event trigger %, objid: %,tag: %, current_user: %, schema: %, database_owenr: %', r.object_identity, r.objid, tg_tag, current_user, schemaname, databaseowner;
        IF r.object_identity = 'address_standardizer_data_us' THEN
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'us_gaz');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'us_lex');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'us_rules');
        ELSIF r.object_identity = 'amcheck' THEN
            EXECUTE format('GRANT EXECUTE ON FUNCTION %I.bt_index_check TO %I;', schemaname, databaseowner);
            EXECUTE format('GRANT EXECUTE ON FUNCTION %I.bt_index_parent_check TO %I;', schemaname, databaseowner);
        ELSIF r.object_identity = 'dict_int' THEN
            EXECUTE format('ALTER TEXT SEARCH DICTIONARY %I.intdict OWNER TO %I;', schemaname, databaseowner);
        ELSIF r.object_identity = 'pg_partman' THEN
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'part_config');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'part_config_sub');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT, UPDATE, INSERT, DELETE', databaseowner, 'custom_time_partitions');
        ELSIF r.object_identity = 'pg_stat_statements' THEN
            EXECUTE format('GRANT EXECUTE ON FUNCTION %I.pg_stat_statements_reset TO %I;', schemaname, databaseowner);
        ELSIF r.object_identity = 'postgis' THEN
            PERFORM _heroku.postgis_after_create();
        ELSIF r.object_identity = 'postgis_raster' THEN
            PERFORM _heroku.postgis_after_create();
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT', databaseowner, 'raster_columns');
            PERFORM _heroku.grant_table_if_exists(schemaname, 'SELECT', databaseowner, 'raster_overviews');
        ELSIF r.object_identity = 'postgis_topology' THEN
            PERFORM _heroku.postgis_after_create();
            EXECUTE format('GRANT USAGE ON SCHEMA topology TO %I;', databaseowner);
            EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA topology TO %I;', databaseowner);
            PERFORM _heroku.grant_table_if_exists('topology', 'SELECT, UPDATE, INSERT, DELETE', databaseowner);
            EXECUTE format('GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA topology TO %I;', databaseowner);
        ELSIF r.object_identity = 'postgis_tiger_geocoder' THEN
            PERFORM _heroku.postgis_after_create();
            EXECUTE format('GRANT USAGE ON SCHEMA tiger TO %I;', databaseowner);
            EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA tiger TO %I;', databaseowner);
            PERFORM _heroku.grant_table_if_exists('tiger', 'SELECT, UPDATE, INSERT, DELETE', databaseowner);

            EXECUTE format('GRANT USAGE ON SCHEMA tiger_data TO %I;', databaseowner);
            EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA tiger_data TO %I;', databaseowner);
            PERFORM _heroku.grant_table_if_exists('tiger_data', 'SELECT, UPDATE, INSERT, DELETE', databaseowner);
        END IF;
    END LOOP;
  END IF;
END;
$$;


--
-- Name: drop_ext(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.drop_ext() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE

  schemaname TEXT;
  databaseowner TEXT;

  r RECORD;

BEGIN

  IF tg_tag = 'DROP EXTENSION' and current_user != 'rds_superuser' THEN
    FOR r IN SELECT * FROM pg_event_trigger_dropped_objects()
    LOOP
      CONTINUE WHEN r.object_type != 'extension';

      databaseowner = (
            SELECT pg_catalog.pg_get_userbyid(d.datdba)
            FROM pg_catalog.pg_database d
            WHERE d.datname = current_database()
      );

      --RAISE NOTICE 'Record for event trigger %, objid: %,tag: %, current_user: %, database_owner: %, schemaname: %', r.object_identity, r.objid, tg_tag, current_user, databaseowner, r.schema_name;

      IF r.object_identity = 'postgis_topology' THEN
          EXECUTE format('DROP SCHEMA IF EXISTS topology');
      END IF;
    END LOOP;

  END IF;
END;
$$;


--
-- Name: extension_before_drop(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.extension_before_drop() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE

  query TEXT;

BEGIN
  query = (SELECT current_query());

  -- RAISE NOTICE 'executing extension_before_drop: tg_event: %, tg_tag: %, current_user: %, session_user: %, query: %', tg_event, tg_tag, current_user, session_user, query;
  IF tg_tag = 'DROP EXTENSION' and not pg_has_role(session_user, 'rds_superuser', 'MEMBER') THEN
    -- DROP EXTENSION [ IF EXISTS ] name [, ...] [ CASCADE | RESTRICT ]
    IF (regexp_match(query, 'DROP\s+EXTENSION\s+(IF\s+EXISTS)?.*(plpgsql)', 'i') IS NOT NULL) THEN
      RAISE EXCEPTION 'The plpgsql extension is required for database management and cannot be dropped.';
    END IF;
  END IF;
END;
$$;


--
-- Name: grant_table_if_exists(text, text, text, text); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.grant_table_if_exists(alias_schemaname text, grants text, databaseowner text, alias_tablename text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

BEGIN

  IF alias_tablename IS NULL THEN
    EXECUTE format('GRANT %s ON ALL TABLES IN SCHEMA %I TO %I;', grants, alias_schemaname, databaseowner);
  ELSE
    IF EXISTS (SELECT 1 FROM pg_tables WHERE pg_tables.schemaname = alias_schemaname AND pg_tables.tablename = alias_tablename) THEN
      EXECUTE format('GRANT %s ON TABLE %I.%I TO %I;', grants, alias_schemaname, alias_tablename, databaseowner);
    END IF;
  END IF;
END;
$$;


--
-- Name: postgis_after_create(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.postgis_after_create() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    schemaname TEXT;
    databaseowner TEXT;
BEGIN
    schemaname = (
        SELECT n.nspname
        FROM pg_catalog.pg_extension AS e
        INNER JOIN pg_catalog.pg_namespace AS n ON e.extnamespace = n.oid
        WHERE e.extname = 'postgis'
    );
    databaseowner = (
        SELECT pg_catalog.pg_get_userbyid(d.datdba)
        FROM pg_catalog.pg_database d
        WHERE d.datname = current_database()
    );

    EXECUTE format('GRANT EXECUTE ON FUNCTION %I.st_tileenvelope TO %I;', schemaname, databaseowner);
    EXECUTE format('GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE %I.spatial_ref_sys TO %I;', schemaname, databaseowner);
END;
$$;


--
-- Name: validate_extension(); Type: FUNCTION; Schema: _heroku; Owner: -
--

CREATE FUNCTION _heroku.validate_extension() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$

DECLARE

  schemaname TEXT;
  r RECORD;

BEGIN

  IF tg_tag = 'CREATE EXTENSION' and current_user != 'rds_superuser' THEN
    FOR r IN SELECT * FROM pg_event_trigger_ddl_commands()
    LOOP
      CONTINUE WHEN r.command_tag != 'CREATE EXTENSION' OR r.object_type != 'extension';

      schemaname = (
        SELECT n.nspname
        FROM pg_catalog.pg_extension AS e
        INNER JOIN pg_catalog.pg_namespace AS n
        ON e.extnamespace = n.oid
        WHERE e.oid = r.objid
      );

      IF schemaname = '_heroku' THEN
        RAISE EXCEPTION 'Creating extensions in the _heroku schema is not allowed';
      END IF;
    END LOOP;
  END IF;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_admin_comments (
    id integer NOT NULL,
    namespace character varying,
    body text,
    resource_id character varying NOT NULL,
    resource_type character varying NOT NULL,
    author_id integer,
    author_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_admin_comments_id_seq OWNED BY public.active_admin_comments.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id integer NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: newsletter_signups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_signups (
    id bigint NOT NULL,
    email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: newsletter_signups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletter_signups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletter_signups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletter_signups_id_seq OWNED BY public.newsletter_signups.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    body text,
    title character varying,
    published boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    slug character varying,
    description character varying
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    avatar_url character varying,
    biography text
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: newsletter_signups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_signups ALTER COLUMN id SET DEFAULT nextval('public.newsletter_signups_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: active_admin_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_admin_comments (id, namespace, body, resource_id, resource_type, author_id, author_type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: active_storage_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_storage_attachments (id, name, record_type, record_id, blob_id, created_at) FROM stdin;
1	featured_image	Blog::Post	17	1	2021-12-30 04:12:25.852282
2	featured_image	Blog::Post	20	2	2021-12-30 04:14:37.490083
175	images	Blog::Post	15	175	2022-08-20 07:50:48.797911
4	featured_image	Blog::Post	19	4	2021-12-30 04:16:29.997747
5	featured_image	Blog::Post	18	5	2021-12-30 04:17:38.80751
6	featured_image	Blog::Post	15	6	2021-12-30 04:18:21.048653
176	images	Blog::Post	15	176	2022-08-20 07:50:48.802157
8	images	Blog::Post	19	8	2021-12-30 06:03:48.528084
9	images	Blog::Post	19	9	2021-12-30 06:03:48.533703
177	images	Blog::Post	15	177	2022-08-20 07:50:48.805427
178	images	Blog::Post	15	178	2022-08-20 07:50:48.808652
179	images	Blog::Post	15	179	2022-08-20 07:50:48.811691
180	images	Blog::Post	15	180	2022-08-20 07:50:48.814785
181	images	Blog::Post	15	181	2022-08-20 07:50:48.817759
182	images	Blog::Post	15	182	2022-08-20 07:50:48.820714
183	images	Blog::Post	15	183	2022-08-20 07:50:48.823778
184	images	Blog::Post	15	184	2022-08-20 07:50:48.826767
185	images	Blog::Post	15	185	2022-08-20 07:50:48.829643
186	images	Blog::Post	15	186	2022-08-20 07:50:48.832722
187	images	Blog::Post	15	187	2022-08-20 07:50:48.835818
188	images	Blog::Post	15	188	2022-08-20 07:50:48.838759
22	images	Blog::Post	13	22	2021-12-31 00:57:12.119426
23	images	Blog::Post	13	23	2021-12-31 00:57:12.124391
24	images	Blog::Post	13	24	2021-12-31 00:57:12.129134
25	images	Blog::Post	13	25	2021-12-31 00:57:12.133467
26	images	Blog::Post	13	26	2021-12-31 00:57:12.137798
27	images	Blog::Post	13	27	2021-12-31 00:57:12.142147
28	images	Blog::Post	13	28	2021-12-31 00:57:12.146047
29	images	Blog::Post	9	29	2021-12-31 01:00:22.479399
30	images	Blog::Post	9	30	2021-12-31 01:00:22.493605
31	featured_image	Blog::Post	16	31	2022-01-02 05:20:05.928699
189	images	Blog::Post	15	189	2022-08-20 07:50:48.841714
190	images	Blog::Post	15	190	2022-08-20 07:50:48.844545
34	featured_image	Blog::Post	21	34	2022-02-02 18:22:12.71385
35	image	ActiveStorage::VariantRecord	2	35	2022-02-02 18:22:14.202221
36	image	ActiveStorage::VariantRecord	3	36	2022-07-25 22:41:32.84881
191	images	Blog::Post	15	191	2022-08-20 07:50:48.847423
192	images	Blog::Post	15	192	2022-08-20 07:50:48.850372
193	image	ActiveStorage::VariantRecord	206	193	2022-08-20 07:50:56.869426
194	image	ActiveStorage::VariantRecord	207	194	2022-08-20 07:50:57.560488
195	image	ActiveStorage::VariantRecord	208	195	2022-08-20 07:50:58.459113
196	image	ActiveStorage::VariantRecord	209	196	2022-08-20 07:50:59.918143
197	image	ActiveStorage::VariantRecord	210	197	2022-08-20 07:51:01.178445
198	image	ActiveStorage::VariantRecord	211	198	2022-08-20 07:51:03.264762
199	image	ActiveStorage::VariantRecord	212	199	2022-08-20 07:51:06.797285
200	image	ActiveStorage::VariantRecord	213	200	2022-08-20 07:51:07.719877
201	image	ActiveStorage::VariantRecord	214	201	2022-08-20 07:51:09.897779
202	image	ActiveStorage::VariantRecord	215	202	2022-08-20 07:51:11.005305
203	image	ActiveStorage::VariantRecord	216	203	2022-08-20 07:51:13.121348
204	image	ActiveStorage::VariantRecord	217	204	2022-08-20 07:51:14.966451
205	image	ActiveStorage::VariantRecord	218	205	2022-08-20 07:51:16.21938
206	image	ActiveStorage::VariantRecord	219	206	2022-08-20 07:51:17.790559
207	image	ActiveStorage::VariantRecord	220	207	2022-08-20 07:51:19.14025
208	image	ActiveStorage::VariantRecord	221	208	2022-08-20 07:51:20.365696
209	image	ActiveStorage::VariantRecord	222	209	2022-08-20 07:51:22.396471
210	image	ActiveStorage::VariantRecord	223	210	2022-08-20 07:51:24.730921
211	image	ActiveStorage::VariantRecord	224	211	2022-08-20 07:51:26.537915
212	image	ActiveStorage::VariantRecord	225	212	2022-08-20 07:51:28.065201
213	image	ActiveStorage::VariantRecord	226	213	2022-08-20 07:51:30.370249
214	image	ActiveStorage::VariantRecord	227	214	2022-08-20 07:51:31.098407
215	image	ActiveStorage::VariantRecord	228	215	2022-08-20 07:51:32.438531
216	image	ActiveStorage::VariantRecord	229	216	2022-08-20 07:51:34.251726
217	image	ActiveStorage::VariantRecord	230	217	2022-08-20 07:51:36.269761
218	image	ActiveStorage::VariantRecord	231	218	2022-08-20 07:51:37.406433
219	image	ActiveStorage::VariantRecord	232	219	2022-08-20 07:51:38.67316
220	image	ActiveStorage::VariantRecord	233	220	2022-08-20 07:51:40.399902
221	image	ActiveStorage::VariantRecord	234	221	2022-08-20 07:51:42.132647
222	image	ActiveStorage::VariantRecord	235	222	2022-08-20 07:51:43.304675
223	image	ActiveStorage::VariantRecord	236	223	2022-08-20 07:51:44.522604
224	image	ActiveStorage::VariantRecord	237	224	2022-08-20 07:51:46.254992
225	image	ActiveStorage::VariantRecord	238	225	2022-08-20 07:51:47.084111
226	image	ActiveStorage::VariantRecord	239	226	2022-08-20 07:51:47.732611
227	image	ActiveStorage::VariantRecord	240	227	2022-08-20 07:51:48.534784
228	image	ActiveStorage::VariantRecord	241	228	2022-08-20 07:51:49.201713
229	image	ActiveStorage::VariantRecord	242	229	2022-08-20 07:51:49.943319
230	image	ActiveStorage::VariantRecord	243	230	2022-08-20 07:51:50.615959
231	image	ActiveStorage::VariantRecord	244	231	2022-08-20 07:51:51.256241
232	image	ActiveStorage::VariantRecord	245	232	2022-08-20 07:51:52.023517
233	image	ActiveStorage::VariantRecord	246	233	2022-08-20 07:51:53.817833
234	image	ActiveStorage::VariantRecord	247	234	2022-08-20 07:51:54.984275
235	image	ActiveStorage::VariantRecord	248	235	2022-08-20 07:51:56.521311
236	image	ActiveStorage::VariantRecord	249	236	2022-08-20 07:51:58.21207
237	image	ActiveStorage::VariantRecord	250	237	2022-08-20 07:51:59.905912
238	image	ActiveStorage::VariantRecord	251	238	2022-08-20 07:52:00.725976
239	image	ActiveStorage::VariantRecord	252	239	2022-08-20 07:52:02.283672
240	image	ActiveStorage::VariantRecord	253	240	2022-08-20 07:52:03.854957
241	image	ActiveStorage::VariantRecord	254	241	2022-08-20 07:52:04.94044
242	image	ActiveStorage::VariantRecord	255	242	2022-08-20 07:52:07.101508
243	image	ActiveStorage::VariantRecord	256	243	2022-08-20 07:52:08.697675
244	image	ActiveStorage::VariantRecord	257	244	2022-08-20 07:52:09.660487
245	image	ActiveStorage::VariantRecord	258	245	2022-08-20 07:52:12.124743
246	image	ActiveStorage::VariantRecord	259	246	2022-08-20 07:52:14.094833
247	image	ActiveStorage::VariantRecord	260	247	2022-08-20 07:52:16.156814
248	image	ActiveStorage::VariantRecord	261	248	2022-08-20 07:52:18.048656
249	image	ActiveStorage::VariantRecord	262	249	2022-08-20 07:52:19.030976
250	image	ActiveStorage::VariantRecord	263	250	2022-08-20 07:52:19.789412
251	image	ActiveStorage::VariantRecord	264	251	2022-08-20 07:52:20.499807
252	image	ActiveStorage::VariantRecord	265	252	2022-08-20 07:52:21.62627
253	image	ActiveStorage::VariantRecord	266	253	2022-08-20 07:52:22.925179
254	image	ActiveStorage::VariantRecord	267	254	2022-08-20 07:52:23.99356
255	image	ActiveStorage::VariantRecord	268	255	2022-08-20 07:52:25.737995
256	image	ActiveStorage::VariantRecord	269	256	2022-08-20 07:52:27.093057
257	image	ActiveStorage::VariantRecord	270	257	2022-08-20 07:52:28.298514
258	image	ActiveStorage::VariantRecord	271	258	2022-08-20 07:52:29.173856
259	image	ActiveStorage::VariantRecord	272	259	2022-08-20 07:52:31.673531
260	image	ActiveStorage::VariantRecord	273	260	2022-08-20 07:52:35.409343
261	image	ActiveStorage::VariantRecord	274	261	2022-08-20 07:52:36.831138
262	image	ActiveStorage::VariantRecord	275	262	2022-08-20 07:52:39.090772
263	image	ActiveStorage::VariantRecord	276	263	2022-08-20 07:52:40.07757
264	image	ActiveStorage::VariantRecord	277	264	2022-08-20 07:52:42.101763
265	image	ActiveStorage::VariantRecord	278	265	2023-07-20 01:15:16.070626
268	featured_image	Blog::Post	22	268	2024-02-06 06:44:10.582099
269	image	ActiveStorage::VariantRecord	280	269	2024-02-06 06:44:12.118129
\.


--
-- Data for Name: active_storage_blobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_storage_blobs (id, key, filename, content_type, metadata, service_name, byte_size, checksum, created_at) FROM stdin;
1	ezysjm6k4ao4mmwo9dhy1n9djgbh	6260da36-ce9b-11e3-9e54-3c86cc1f4f47.jpg	image/jpeg	{"identified":true,"width":683,"height":236,"analyzed":true}	amazon	23212	lCp8aEk3dnRih0iWCq1dyg==	2021-12-30 04:12:25.845904
2	0yp6sy1p9cqj32hmt4vu9kcrq6s3	147200663-5c65e87e-7565-41f4-a88a-52ae813df6ef.jpg	image/jpeg	{"identified":true,"width":1443,"height":645,"analyzed":true}	amazon	47687	FZI98wc8uil03KrsEZjYag==	2021-12-30 04:14:37.488024
4	0n6ua90u6xte1ugn5h8obkqo1r30	147200264-668496a0-370a-4d12-9cc9-a78071466c78.jpg	image/jpeg	{"identified":true,"width":1000,"height":420,"analyzed":true}	amazon	39616	u17yegJTjQpysMh8c2qZww==	2021-12-30 04:16:29.984612
5	4hc6y1riu8oaw87nzwez5o7pb77l	49132477-f4b77680-f31f-11e8-8357-ac6491761c6c.png	image/png	{"identified":true,"width":1760,"height":520,"analyzed":true}	amazon	55986	ws6BT/TJGStyyTknlbkoTA==	2021-12-30 04:17:38.805708
6	3q0q8dzyx07te5tid9tbottsbkwn	e129100c-bd35-11e4-8699-138009a03359.jpg	image/jpeg	{"identified":true,"width":2000,"height":400,"analyzed":true}	amazon	42077	OAyvHkCAdwTFg8dg+Kilow==	2021-12-30 04:18:21.046138
9	gj30hawgadcxhtzbjins507spbj5	897db796-3592-11e6-97e4-dcb4c7159ca0.png	image/png	{"identified":true,"width":726,"height":496,"analyzed":true}	amazon	55772	hK9mVhoeLsu03Aw3uX3Sjw==	2021-12-30 06:03:48.531431
8	qfufd4kkukus0vpb5af3vbcun9rg	753cd64a-3592-11e6-8e20-3057cad261af.png	image/png	{"identified":true,"width":1024,"height":501,"analyzed":true}	amazon	107399	2cgSSDYkF5XIHJWlT0s44Q==	2021-12-30 06:03:48.525106
177	ckkohvqyfio19nlk5ap9vylh6xr6	IMG_0318.JPG	image/jpeg	{"identified":true,"width":3264,"height":2448,"analyzed":true}	amazon	2058976	Pk9IGnNhUxEM3gsjMzNG0A==	2022-08-20 07:50:48.803998
181	kbc3p1e7frl3s3s9q2jim5n6odhf	IMG_0336.JPG	image/jpeg	{"identified":true,"width":3264,"height":2448,"analyzed":true}	amazon	2037410	GuuYgN98GI8d5mL3baVPgQ==	2022-08-20 07:50:48.816411
180	puofh65fdq4tvx1hno2w1c8ncf6z	IMG_0325.JPG	image/jpeg	{"identified":true,"width":3264,"height":2448,"analyzed":true}	amazon	2543770	+rYEtbyCVIC7JgB1R9X3rg==	2022-08-20 07:50:48.813335
183	xzejpaeoj7mfjxtebdurmxqc5ckn	IMG_0346.JPG	image/jpeg	{"identified":true,"width":1920,"height":1440,"analyzed":true}	amazon	549518	oEhYaGpCapUCh6VizwZh/Q==	2022-08-20 07:50:48.822376
182	3gg33hqk4tmolzvgsgji3hjngoja	IMG_0344.JPG	image/jpeg	{"identified":true,"width":2448,"height":3264,"analyzed":true}	amazon	1783869	TiWilTb/jKI9/DI5DofJgA==	2022-08-20 07:50:48.819379
178	u758c8gd3hj08ln6dlgaf5we8qvz	IMG_0320.JPG	image/jpeg	{"identified":true,"width":2448,"height":3264,"analyzed":true}	amazon	1420062	lA32pgjYbDPwJhKjZ4iA+g==	2022-08-20 07:50:48.807276
184	hfnzxshama5n9jxg5pwlpadqhwzq	IMG_0417.JPG	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	272666	MEDqy2dj1iUbS3E1WNLB4A==	2022-08-20 07:50:48.8254
185	4z7ws32ticgrk5158zpwk1yuqnn7	IMG_0429.JPG	image/jpeg	{"identified":true,"width":3264,"height":2448,"analyzed":true}	amazon	2166291	kB5AKeWpcV0iMk4Xjjgu9Q==	2022-08-20 07:50:48.828331
186	vqe68shgbtz7biuaeqcirm06maqd	IMG_0447.JPG	image/jpeg	{"identified":true,"width":3264,"height":2448,"analyzed":true}	amazon	2304592	hqu/y7f/jwhM9XO41IG3Lw==	2022-08-20 07:50:48.831321
22	c1hbul998p9h0h6q2wioeq165ewz	e25f855c-b306-11e4-8401-f1dab2c41deb.jpg	image/jpeg	{"identified":true,"width":683,"height":1024,"analyzed":true}	amazon	96772	7/pqR9kSoVH6kIUkdmoqlg==	2021-12-31 00:57:12.116946
23	mv98o59iex6yt2p512f75824s35j	e25f4dc6-b306-11e4-8912-bbf5ff50d2dd.jpg	image/jpeg	{"identified":true,"width":1024,"height":683,"analyzed":true}	amazon	321034	pNwOeg/RleaGc4rJGZwyIQ==	2021-12-31 00:57:12.122191
24	11yct2it3ryvso0ekhqxxbquo9tc	59dbe932-b306-11e4-9cc5-ffff8c22dd03.jpg	image/jpeg	{"identified":true,"width":1024,"height":683,"analyzed":true}	amazon	130827	XZKT301AjB7IvlRd0nWaAA==	2021-12-31 00:57:12.127128
25	58k31xmxr2iglyepur8a1af4usut	5ab1c908-b306-11e4-8749-f6d5df479136.jpg	image/jpeg	{"identified":true,"width":1024,"height":683,"analyzed":true}	amazon	152551	CSGiq5kIEWUCv6Mf4LDUTg==	2021-12-31 00:57:12.131528
26	5e5ia6u4ayqch953i7w994axaowl	5b4b1ea0-b306-11e4-8a9b-7b9024e27da1.jpg	image/jpeg	{"identified":true,"width":1024,"height":683,"analyzed":true}	amazon	313714	5SWsKPF1BjuY0TrFQcwt7g==	2021-12-31 00:57:12.135652
27	t9wasy0mj2x6a67bjr71joxpbkz1	5c31f924-b306-11e4-82a6-7c4cc3dd112f.jpg	image/jpeg	{"identified":true,"width":1024,"height":683,"analyzed":true}	amazon	383549	3WMH78x1GLtWt/F+JPRnRw==	2021-12-31 00:57:12.140152
28	eo1ns49ctgv3a59u4qo50x0ajt06	576e5874-b306-11e4-8eda-fa4e49299f42.jpg	image/jpeg	{"identified":true,"width":1024,"height":683,"analyzed":true}	amazon	114623	kxpmeBIWY/PpLiT7pv4FsA==	2021-12-31 00:57:12.144195
30	547g2uzh6xizooqtls7il15myfjx	da6dbf1e-cd13-11e3-86c8-63dc135ff63b.png	image/png	{"identified":true,"width":513,"height":214,"analyzed":true}	amazon	36352	Q57VYpq5byFHbibrOoufwA==	2021-12-31 01:00:22.486152
29	8ku9vt1bmp635ba9hxc2bqtea6wm	24a7d830-cd14-11e3-8065-7b4c6fdf8f13.png	image/png	{"identified":true,"width":604,"height":502,"analyzed":true}	amazon	42187	gnRuw5hNa6Ok9fG86woTpQ==	2021-12-31 01:00:22.476493
31	zlcx8b9zs9pa4keai2xqpkwucr0g	838e3536-d1ac-11e4-8766-04ec04c0b199.png	image/png	{"identified":true,"width":1536,"height":400,"analyzed":true}	amazon	18152	yQHS8uG+WFo7GKBb65UDMw==	2022-01-02 05:20:05.922984
34	yclewhl68774xes1a4hoqhg4x90z	data.jpg	image/jpeg	{"identified":true,"width":1500,"height":860,"analyzed":true}	amazon	96388	TBNEO9teQkfP3Klybo5aNw==	2022-02-02 18:22:12.708376
189	4tedzwpm2bp6lq8trt9co7winuo9	IMG_0541.JPG	image/jpeg	{"identified":true,"width":1280,"height":2276,"analyzed":true}	amazon	467651	jSAovdjDoU5Rl5tj6L202w==	2022-08-20 07:50:48.840323
35	pu242kfbrxbwedoogc4jh9amn2ke	data.jpg	image/jpeg	{"identified":true,"width":300,"height":172,"analyzed":true}	amazon	24407	ppXzuU+fvzoExIy86WB/TQ==	2022-02-02 18:22:14.197223
36	tbde0hdj47ew5g9en0a7nopuy4fh	e129100c-bd35-11e4-8699-138009a03359.jpg	image/jpeg	{"identified":true,"width":300,"height":60,"analyzed":true}	amazon	2735	/A3PKk6NciurvCRlFq7MGg==	2022-07-25 22:41:32.844657
190	0blz9ragvty41vl6qfk6dffkgoyx	IMG_1576.JPG	image/jpeg	{"identified":true,"width":2448,"height":3264,"analyzed":true}	amazon	2939145	B3tlMzq5kRjo6wgjdm2xKw==	2022-08-20 07:50:48.843265
192	casdteotd8xfiu2ozx7sgsz1k8iw	Screen Shot 2015-02-09 at 11.26.35 PM.png	image/png	{"identified":true,"width":2880,"height":1746,"analyzed":true}	amazon	5197570	0lrv/U6CYwkgUtWdcZckxg==	2022-08-20 07:50:48.849017
179	84l04jd53nye1r47u1gof4zjdq3u	IMG_0323.JPG	image/jpeg	{"identified":true,"width":2448,"height":3264,"analyzed":true}	amazon	2037928	Ii9/rhEwuKmMSwpPt07XUQ==	2022-08-20 07:50:48.810372
188	m73mxjg5maur35eo8n2sgwqzwp1i	IMG_0492.JPG	image/jpeg	{"identified":true,"width":3264,"height":2448,"analyzed":true}	amazon	2735961	Ij7AHktRf1DRr35YnwTlwQ==	2022-08-20 07:50:48.837438
176	vdav4lnjchs34vdtciul66fhxk74	IMG_0317.JPG	image/jpeg	{"identified":true,"width":3264,"height":2448,"analyzed":true}	amazon	1988585	rQChAuG7yjWEvrVPm8CQlQ==	2022-08-20 07:50:48.800488
175	92fssyw6ix5svb6ej6imrcogz7di	FullSizeRender 2.jpg	image/jpeg	{"identified":true,"width":3264,"height":2448,"analyzed":true}	amazon	1959587	rJnLwhEMp1T9a9F7/8H2iQ==	2022-08-20 07:50:48.795333
187	mhmblvzde4ulmgetajnlh19w94uo	IMG_0452.JPG	image/jpeg	{"identified":true,"width":2448,"height":3264,"analyzed":true}	amazon	2020402	86Rfrz8gHYv2eeGcgZbc8A==	2022-08-20 07:50:48.834403
193	b5kfrek186ontzv91cv36g90e7ee	FullSizeRender 2.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	34468	DCQnWVZTCh4OByFW5R8Ylg==	2022-08-20 07:50:56.866658
194	4c2w3ejmpemk12moxlyrvom88rth	FullSizeRender 2.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	37384	KKiA6PjsXqjKhOgMF4E8xQ==	2022-08-20 07:50:57.558903
195	87hyy2fxvwt7qesjla9ujhfrgzxw	FullSizeRender 2.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	121372	eZALg60OZwjDrxOcDoog9Q==	2022-08-20 07:50:58.457369
191	sodt8l1wdlp4u438ypm6z6cp9hfo	IMG_0399.PNG	image/png	{"identified":true,"width":2208,"height":1242,"analyzed":true}	amazon	5374236	n2TxTy62Nu6G1+z/JA9GRg==	2022-08-20 07:50:48.846094
196	gh0tcjmbkam4z35dvagva16o4cru	FullSizeRender 2.jpg	image/jpeg	{"identified":true,"width":1280,"height":960,"analyzed":true}	amazon	427538	I7oLKm6r4TkSggLEPOLfvQ==	2022-08-20 07:50:59.914749
197	qs65xksl6lr5omunpnogxv16ewsj	IMG_0317.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	53393	96XETQhUgmxtqNN1CRdNXA==	2022-08-20 07:51:01.176679
198	0xyqn3nz78j343awzmnvtk8gl6ry	IMG_0317.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	56674	b6CqMQ8cnR7+/tdaCdH8Ug==	2022-08-20 07:51:03.262844
199	eow3burcqjlwqgznjbf8ni7orasq	IMG_0317.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	147964	NCsI3AICGlLX0ceyn2qLpA==	2022-08-20 07:51:06.795479
200	eazjerc8dt76ib4vdl33jt7xdpk0	IMG_0317.jpg	image/jpeg	{"identified":true,"width":1280,"height":960,"analyzed":true}	amazon	457504	faDig8+kPtggFINeMAzXfA==	2022-08-20 07:51:07.717904
201	enu2rbo5w3962oadxpy04rjmbbho	IMG_0318.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	48240	R4ZLeZ3Nd+K+l0tYCp6KQA==	2022-08-20 07:51:09.896115
202	iaiht9hixqhrm35a6fqq56rxf6el	IMG_0318.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	51414	SBO7o5OQ8q1qbHXmHsPQMg==	2022-08-20 07:51:11.003245
203	ylqgmw0sw5eatz05e58w9h8dis2h	IMG_0318.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	139990	D9HwWkMZAcXs7G3VfttEEA==	2022-08-20 07:51:13.119649
204	n01rpp275qgu8b34ogedq131vavv	IMG_0318.jpg	image/jpeg	{"identified":true,"width":1280,"height":960,"analyzed":true}	amazon	458754	2xuhAiQZl9TrJHgru7nPwA==	2022-08-20 07:51:14.964712
205	3hjgc74cwhtfo8gw66c1uolljdzz	IMG_0320.jpg	image/jpeg	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	52574	ofFVKiADNOvxPVEczXkCrw==	2022-08-20 07:51:16.217664
206	ikp2x26bj9p78itj7agdlw3nig8m	IMG_0320.jpg	image/jpeg	{"identified":true,"width":320,"height":427,"analyzed":true}	amazon	57043	RuIxfW48mSCjDRhgS1hrkw==	2022-08-20 07:51:17.788256
207	ux3m3gswswyw1itrzcgjgql3n1qo	IMG_0320.jpg	image/jpeg	{"identified":true,"width":640,"height":853,"analyzed":true}	amazon	156989	KUlFx0paDkErLiD20gmQ4Q==	2022-08-20 07:51:19.138662
208	uukpufnwy48bk7rx71bxsnbeq597	IMG_0320.jpg	image/jpeg	{"identified":true,"width":1280,"height":1707,"analyzed":true}	amazon	524009	ILZLmvdZigujTx/fp2ZoZg==	2022-08-20 07:51:20.363675
209	xanzzwkr2ct7phx5odoxngkhmfkl	IMG_0323.jpg	image/jpeg	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	64055	Jw709nhJDNg3AdOgFd+Ayw==	2022-08-20 07:51:22.394829
210	s9aum0hn6i3dac7h26ydeemkkifw	IMG_0323.jpg	image/jpeg	{"identified":true,"width":320,"height":427,"analyzed":true}	amazon	70854	LJZDLlja4/Nn6/hOTXpFWA==	2022-08-20 07:51:24.729172
211	pac8syqe5967aqpfxd1iyg8hbtrs	IMG_0323.jpg	image/jpeg	{"identified":true,"width":640,"height":853,"analyzed":true}	amazon	209475	spR7tFPrx/XbK5vQh73z6A==	2022-08-20 07:51:26.536196
212	jaaku4uvzkr1mgc2clik1bafq037	IMG_0323.jpg	image/jpeg	{"identified":true,"width":1280,"height":1707,"analyzed":true}	amazon	719632	zXezQ3Ewn1gMpnb2IAiutw==	2022-08-20 07:51:28.063568
213	w9upayla5yth3snoe1m142pfw6u3	IMG_0325.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	38845	WFqV0b7RTy6ChbIZktN4Ig==	2022-08-20 07:51:30.368536
214	4zy831gbhk4kwcrptjlz1onn4r11	IMG_0325.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	41546	QvzzuFibCOFmziOVROnw7w==	2022-08-20 07:51:31.096747
215	6cqmk6qb0kigttczejecmq4wrw7l	IMG_0325.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	122934	Gd2zx3VJhJLLQBeOodGOiw==	2022-08-20 07:51:32.431225
216	yty8ca36wc266iqycuvbttpjgk6z	IMG_0325.jpg	image/jpeg	{"identified":true,"width":1280,"height":960,"analyzed":true}	amazon	475366	bQlHAQM1WSqGJAqyweEN4Q==	2022-08-20 07:51:34.250018
217	yihti18ka5poo33c4hgaiz3zli80	IMG_0336.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	50182	KH2AVuC7s6mCLu1yNzGetg==	2022-08-20 07:51:36.267727
218	083t0tgzk61jhv9t3tyayver2cep	IMG_0336.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	53512	preTOCc1W/7BN26y+myHjg==	2022-08-20 07:51:37.404599
219	hbguxuu77g848hap1ppm9a6827vk	IMG_0336.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	141142	YIjDjRs4dyFJRw3xr1WxWg==	2022-08-20 07:51:38.671477
220	j532z428r380uw1t3eaakfdpcbru	IMG_0336.jpg	image/jpeg	{"identified":true,"width":1280,"height":960,"analyzed":true}	amazon	442249	YVoWcU9c4X/+9x14Xzym1Q==	2022-08-20 07:51:40.398057
221	of95tszzvi3ejhe8iynms1n7j4ij	IMG_0344.jpg	image/jpeg	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	53458	UoNSL8qnl7jMS4BfDvKBZA==	2022-08-20 07:51:42.130858
222	1hqo73y6sxb7qg46rhmsw11r0i59	IMG_0344.jpg	image/jpeg	{"identified":true,"width":320,"height":427,"analyzed":true}	amazon	57977	6y3zRc2agVTEnJMMDp99IQ==	2022-08-20 07:51:43.302909
223	80a9z7x149crk7itca0h4nnzuv7j	IMG_0344.jpg	image/jpeg	{"identified":true,"width":640,"height":853,"analyzed":true}	amazon	170979	f25y4DesRToGc6Tyt7BHFA==	2022-08-20 07:51:44.52083
224	vgg3hodvkad4je02xvfjml0na8l8	IMG_0344.jpg	image/jpeg	{"identified":true,"width":1280,"height":1707,"analyzed":true}	amazon	620218	tvgnFii2xIiETLzHVQeypw==	2022-08-20 07:51:46.252974
225	26otk8hivn43cyxzdb3jfa4ucpqg	IMG_0346.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	41074	/nCST1PuqAL4BXwlvvSIEQ==	2022-08-20 07:51:47.082464
226	lk9y7ln6y34beq2joy9w43x35ac6	IMG_0346.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	43516	ARfUkG1aB7R31Pi3jTD6Sg==	2022-08-20 07:51:47.730922
227	7x35n3jqya4g2yzv80bw4bdgwp7e	IMG_0346.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	107518	VfWAaCgBHgsNvO/fKCKSJA==	2022-08-20 07:51:48.533169
228	hfrurtjx1ln3ie2polbnguv9sd07	IMG_0346.jpg	image/jpeg	{"identified":true,"width":1280,"height":960,"analyzed":true}	amazon	318008	DautI848gg1tEicUNRfBhw==	2022-08-20 07:51:49.199982
229	hwqgyuvhvicsp9ncle1yz4bidhzd	IMG_0417.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	115445	hSr0lnErw2dMHghDyx8/wg==	2022-08-20 07:51:49.941219
230	kpidkthhb3mc1khq033bkjqvai7x	IMG_0417.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	120616	uFXT3bcbfnJWs87yLqa9WA==	2022-08-20 07:51:50.614257
231	d1ov2k0jk0uzp1cyfgrqb4sdn8f0	IMG_0417.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	285530	00qtAammTDHZmqX/v8aW+g==	2022-08-20 07:51:51.254476
232	9g197za1xrk99ng8aoonsxv9xk1m	IMG_0417.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	285530	00qtAammTDHZmqX/v8aW+g==	2022-08-20 07:51:52.021727
233	muu55wyh3c3wh9qzuujdn9dxvdv8	IMG_0429.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	51964	VQrWsJgs9MeZfk0XJO5LGg==	2022-08-20 07:51:53.816047
234	snr0g0p4hsabwo6ylklwyg7c3pgu	IMG_0429.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	55126	gQVhFx+Arm74oZZrMXKtAA==	2022-08-20 07:51:54.982487
235	vunj7ttdfcb6u6z58bkk3pi8dt26	IMG_0429.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	145547	bRQoa2tvpUW2368nvjEy8Q==	2022-08-20 07:51:56.519235
236	2ozsfxjzxhrzpn90oe4k9kl2f766	IMG_0429.jpg	image/jpeg	{"identified":true,"width":1280,"height":960,"analyzed":true}	amazon	471322	te+gcVpft4C4DxsMNU/CWg==	2022-08-20 07:51:58.210432
237	lbo6d4mapuxet3dznkblo6e1n3jg	IMG_0447.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	50559	jNDaq50BPNOEFADtlgazTQ==	2022-08-20 07:51:59.904082
238	t2kgw4039czq26zkbss2v9n0p0uj	IMG_0447.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	53962	Aoa13T0Mzef85HWs18O33A==	2022-08-20 07:52:00.723781
239	xuv4zzfia05blx7k1foeky5ymmdc	IMG_0447.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	155267	l2ElFTZBHdxQenjXdPZaZg==	2022-08-20 07:52:02.281556
240	blqhz1sjycg698vdhubn4sb7ycjq	IMG_0447.jpg	image/jpeg	{"identified":true,"width":1280,"height":960,"analyzed":true}	amazon	511571	Zdo3dPcYSsfUIujTMknkog==	2022-08-20 07:52:03.853109
241	et0k1evagq45xnzhj1ytgbrc6xp2	IMG_0452.jpg	image/jpeg	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	49197	CwhegHSH39cz1gZs5zz4iA==	2022-08-20 07:52:04.938747
242	uhao9c4ew8bzfl5km0bn80igkw90	IMG_0452.jpg	image/jpeg	{"identified":true,"width":320,"height":427,"analyzed":true}	amazon	53359	zOXucdWb9260R03DCZaFPQ==	2022-08-20 07:52:07.099422
243	ce2rlygcw6rw2a18h3rh9jef3pkq	IMG_0452.jpg	image/jpeg	{"identified":true,"width":640,"height":853,"analyzed":true}	amazon	163292	Fu3coD+7upIrRglZgTTABg==	2022-08-20 07:52:08.69577
244	hah4yk7q3csgekat7pe666sm1qh3	IMG_0452.jpg	image/jpeg	{"identified":true,"width":1280,"height":1707,"analyzed":true}	amazon	669578	cupHlByeZXeAvxO/BWrbTQ==	2022-08-20 07:52:09.658822
245	6gvfcy6fvnuh8rq011r2xj8mm3z6	IMG_0492.jpg	image/jpeg	{"identified":true,"width":300,"height":225,"analyzed":true}	amazon	53380	DX8domHi2TKYF5FN0Ocidw==	2022-08-20 07:52:12.123137
246	x2c6fwldnqf2s069djdsh6s2qmor	IMG_0492.jpg	image/jpeg	{"identified":true,"width":320,"height":240,"analyzed":true}	amazon	57140	FG1nx+aRYRNSYrDtBjjOkQ==	2022-08-20 07:52:14.093157
247	60fseoya8ohbrek2fhl61l0ihapy	IMG_0492.jpg	image/jpeg	{"identified":true,"width":640,"height":480,"analyzed":true}	amazon	172556	vrXa02hpBWGhgK9tjG+VpQ==	2022-08-20 07:52:16.155183
248	e14bhxlebx57wmor6384jacz8jsk	IMG_0492.jpg	image/jpeg	{"identified":true,"width":1280,"height":960,"analyzed":true}	amazon	574584	qtzDi93hmW+2ucnkwEZ3uQ==	2022-08-20 07:52:18.047
249	kqrrc4lm0ta9mvscywawdrqzrgfh	IMG_0541.jpg	image/jpeg	{"identified":true,"width":300,"height":533,"analyzed":true}	amazon	38775	W2jLt5BEGOd7hvg7vZjuUg==	2022-08-20 07:52:19.029387
250	svqb2hyr7w304xbgifu7lrnbt0m9	IMG_0541.jpg	image/jpeg	{"identified":true,"width":320,"height":569,"analyzed":true}	amazon	42498	W3v4lNi9bEGcjudlMb2rHQ==	2022-08-20 07:52:19.787631
251	c4rsfhw0end7ek3cxk8vq93gkt8b	IMG_0541.jpg	image/jpeg	{"identified":true,"width":640,"height":1138,"analyzed":true}	amazon	151550	d5/ceLWV/P+U+BFd3ogP9w==	2022-08-20 07:52:20.497148
252	b543lucna29ackijv2xr01jdqkp1	IMG_0541.jpg	image/jpeg	{"identified":true,"width":1280,"height":2276,"analyzed":true}	amazon	494498	ISzfsmpGCey/QSvYh+503Q==	2022-08-20 07:52:21.624268
253	uvy457wxblk3pcqztq986zkjx2rl	IMG_1576.jpg	image/jpeg	{"identified":true,"width":300,"height":400,"analyzed":true}	amazon	71231	UfexXPiuLzBGkXPWn6C2Bg==	2022-08-20 07:52:22.922779
254	auwr2n8ib3rodbm4nd3ohol793i9	IMG_1576.jpg	image/jpeg	{"identified":true,"width":320,"height":427,"analyzed":true}	amazon	79712	peCMU5l6c/8/LqLgZeOb8w==	2022-08-20 07:52:23.991257
255	pb7n65qoaawqcwpnay38wi94g8p0	IMG_1576.jpg	image/jpeg	{"identified":true,"width":640,"height":853,"analyzed":true}	amazon	268043	IXokyIhhTHWD30W23nwtkw==	2022-08-20 07:52:25.736211
256	xr6s7vhz9uskv9ji1uk6y40y3jtj	IMG_1576.jpg	image/jpeg	{"identified":true,"width":1280,"height":1707,"analyzed":true}	amazon	946712	Z8zzETNB7a3KX9LpJJZO7A==	2022-08-20 07:52:27.090755
257	qphby3n9rzvxmbabs7514p4sf2zo	IMG_0399.png	image/png	{"identified":true,"width":300,"height":169,"analyzed":true}	amazon	84583	bZqsi8CoImN+SWgFZn1iLw==	2022-08-20 07:52:28.296341
258	tdza0e62tg2592spmam3rc4d8px0	IMG_0399.png	image/png	{"identified":true,"width":320,"height":180,"analyzed":true}	amazon	94986	Y4tV8WLJvbJrMQZSqmfDEQ==	2022-08-20 07:52:29.172199
259	gcmn5703tw11qfwj4jsmbzkhv2wm	IMG_0399.png	image/png	{"identified":true,"width":640,"height":360,"analyzed":true}	amazon	332279	o4/lv+lj/PyTx6EAkia3Tg==	2022-08-20 07:52:31.671907
260	grg5ib3wif1wpb536zbztiypagfu	IMG_0399.png	image/png	{"identified":true,"width":1280,"height":720,"analyzed":true}	amazon	1127323	yV67EG89Cj4SZzR3JeH1tQ==	2022-08-20 07:52:35.407592
261	ojukkunuxu1a9ke07lvgdyz6air5	Screen Shot 2015-02-09 at 11.26.35 PM.png	image/png	{"identified":true,"width":300,"height":182,"analyzed":true}	amazon	53044	xSVbfdYDFP+Ue8vRGHbpkg==	2022-08-20 07:52:36.828921
262	3prgduaj5sudttub9w01buuo79wi	Screen Shot 2015-02-09 at 11.26.35 PM.png	image/png	{"identified":true,"width":320,"height":194,"analyzed":true}	amazon	59124	qsn0iELZ8J6Gz35qvZXEvQ==	2022-08-20 07:52:39.089081
263	hheny4qiy1u3yhqswsg1b1f5dv8d	Screen Shot 2015-02-09 at 11.26.35 PM.png	image/png	{"identified":true,"width":640,"height":388,"analyzed":true}	amazon	208781	dXzx9MMmc3CLEWg/yqswDA==	2022-08-20 07:52:40.075572
264	pfbcdyi6hvsavg4oghynuyxq5d7i	Screen Shot 2015-02-09 at 11.26.35 PM.png	image/png	{"identified":true,"width":1280,"height":776,"analyzed":true}	amazon	805942	FwWoEFkcBh/C3ZYUYBrQSQ==	2022-08-20 07:52:42.099722
265	8aa0fdbwxyd4bm8y52umhjk354v6	147200663-5c65e87e-7565-41f4-a88a-52ae813df6ef.jpg	image/jpeg	{"identified":true,"width":300,"height":134,"analyzed":true}	amazon	13885	ex03Kr3bwhTctHuSsyzp2g==	2023-07-20 01:15:16.062121
268	vd9w36zcihv6jwje8bwkgtz8o1cc	9759-load_testing-small.png	image/png	{"identified":true,"width":1200,"height":675,"analyzed":true}	amazon	213897	d8Q58jfYPF7/a86p/ZRLvA==	2024-02-06 06:44:10.580343
269	8c5r341lseskm0aw8gst3sszuj1c	9759-load_testing-small.png	image/png	{"identified":true,"width":300,"height":169,"analyzed":true}	amazon	49459	PG6OaOLX25iuJ7bTS7z6TA==	2024-02-06 06:44:12.116441
\.


--
-- Data for Name: active_storage_variant_records; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.active_storage_variant_records (id, blob_id, variation_digest) FROM stdin;
206	175	i4WL57cw7+CsV3FLZ2mJdLpduYs=
2	34	i4WL57cw7+CsV3FLZ2mJdLpduYs=
3	6	i4WL57cw7+CsV3FLZ2mJdLpduYs=
207	175	TNIjo5I+cE7SFCneUe9PMvU5Ppk=
208	175	u/zaRnjKIYcJn2B7nXh0J+/1PSY=
209	175	floSJy6xWcyY7Prt8Bxqe4zotBE=
210	176	EHjpj1Ks9vcHHxlCwEVFBryJseE=
211	176	eGTfc08TAAOEnFSndWo/d+S9x24=
212	176	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
213	176	xxumLYDi7uYhKCOb9NnPFWGptqQ=
214	177	EHjpj1Ks9vcHHxlCwEVFBryJseE=
215	177	eGTfc08TAAOEnFSndWo/d+S9x24=
216	177	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
217	177	xxumLYDi7uYhKCOb9NnPFWGptqQ=
218	178	EHjpj1Ks9vcHHxlCwEVFBryJseE=
219	178	eGTfc08TAAOEnFSndWo/d+S9x24=
220	178	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
221	178	xxumLYDi7uYhKCOb9NnPFWGptqQ=
222	179	EHjpj1Ks9vcHHxlCwEVFBryJseE=
223	179	eGTfc08TAAOEnFSndWo/d+S9x24=
224	179	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
225	179	xxumLYDi7uYhKCOb9NnPFWGptqQ=
226	180	EHjpj1Ks9vcHHxlCwEVFBryJseE=
227	180	eGTfc08TAAOEnFSndWo/d+S9x24=
228	180	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
229	180	xxumLYDi7uYhKCOb9NnPFWGptqQ=
230	181	EHjpj1Ks9vcHHxlCwEVFBryJseE=
231	181	eGTfc08TAAOEnFSndWo/d+S9x24=
232	181	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
233	181	xxumLYDi7uYhKCOb9NnPFWGptqQ=
234	182	EHjpj1Ks9vcHHxlCwEVFBryJseE=
235	182	eGTfc08TAAOEnFSndWo/d+S9x24=
236	182	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
237	182	xxumLYDi7uYhKCOb9NnPFWGptqQ=
238	183	EHjpj1Ks9vcHHxlCwEVFBryJseE=
239	183	eGTfc08TAAOEnFSndWo/d+S9x24=
240	183	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
241	183	xxumLYDi7uYhKCOb9NnPFWGptqQ=
242	184	EHjpj1Ks9vcHHxlCwEVFBryJseE=
243	184	eGTfc08TAAOEnFSndWo/d+S9x24=
244	184	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
245	184	xxumLYDi7uYhKCOb9NnPFWGptqQ=
246	185	EHjpj1Ks9vcHHxlCwEVFBryJseE=
247	185	eGTfc08TAAOEnFSndWo/d+S9x24=
248	185	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
249	185	xxumLYDi7uYhKCOb9NnPFWGptqQ=
250	186	EHjpj1Ks9vcHHxlCwEVFBryJseE=
251	186	eGTfc08TAAOEnFSndWo/d+S9x24=
252	186	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
253	186	xxumLYDi7uYhKCOb9NnPFWGptqQ=
254	187	EHjpj1Ks9vcHHxlCwEVFBryJseE=
255	187	eGTfc08TAAOEnFSndWo/d+S9x24=
256	187	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
257	187	xxumLYDi7uYhKCOb9NnPFWGptqQ=
258	188	EHjpj1Ks9vcHHxlCwEVFBryJseE=
259	188	eGTfc08TAAOEnFSndWo/d+S9x24=
260	188	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
261	188	xxumLYDi7uYhKCOb9NnPFWGptqQ=
262	189	EHjpj1Ks9vcHHxlCwEVFBryJseE=
263	189	eGTfc08TAAOEnFSndWo/d+S9x24=
264	189	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
265	189	xxumLYDi7uYhKCOb9NnPFWGptqQ=
266	190	EHjpj1Ks9vcHHxlCwEVFBryJseE=
267	190	eGTfc08TAAOEnFSndWo/d+S9x24=
268	190	y5pjk36jVPCR5Rs4SWlyCHL2AMI=
269	190	xxumLYDi7uYhKCOb9NnPFWGptqQ=
270	191	1QklXc62OI/PhYVgrAXPApvZwfM=
271	191	QPn6kTDxB8I9HYJjy2u/e9tLLA0=
272	191	Rer0ZHETaMkPUxbOciFH1TQUoGU=
273	191	Y7isqd2kXp6AWAfmgF1VYqztCok=
274	192	SddQy7MtP5tRaCZn0MdARdfn0f4=
275	192	FbmPDGva/JbxfI7qYHEcs2B7nO4=
276	192	DJ4adpD0bJ8AqStUHxDYLpioGis=
277	192	iQGWE3JqOuiz9rT8i1GV722GcRE=
278	2	i4WL57cw7+CsV3FLZ2mJdLpduYs=
280	268	SddQy7MtP5tRaCZn0MdARdfn0f4=
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	production	2021-12-23 06:38:51.549403	2021-12-23 06:38:51.549403
\.


--
-- Data for Name: friendly_id_slugs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.friendly_id_slugs (id, slug, sluggable_id, sluggable_type, scope, created_at) FROM stdin;
\.


--
-- Data for Name: newsletter_signups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.newsletter_signups (id, email, created_at, updated_at) FROM stdin;
1	robertradler@gmail.com	2021-12-26 01:16:48.43186	2021-12-26 01:16:48.43186
2	michae97223@gmail.com	2021-12-26 07:03:04.99092	2021-12-26 07:03:04.99092
3	benradler@me.com	2021-12-26 18:40:48.639353	2021-12-26 18:40:48.639353
4	Ntarnek@lyft.com	2021-12-31 18:13:40.728118	2021-12-31 18:13:40.728118
5	d1v9_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-01-31 15:20:18.286518	2023-01-31 15:20:18.286518
6	1oz7_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-03-03 00:45:05.586141	2023-03-03 00:45:05.586141
7	gMS3_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-03-08 11:40:54.242634	2023-03-08 11:40:54.242634
8	tOJB_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-04-09 21:36:09.728769	2023-04-09 21:36:09.728769
9	389C_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-05-03 06:12:07.202745	2023-05-03 06:12:07.202745
10	Mpiq_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-05-14 23:35:55.721833	2023-05-14 23:35:55.721833
11	XlP2_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-06-02 12:15:57.127043	2023-06-02 12:15:57.127043
12	f954_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-07-14 14:46:12.28615	2023-07-14 14:46:12.28615
13	thcz_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-07-25 12:56:45.704241	2023-07-25 12:56:45.704241
14	PUsZ_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-07-26 03:34:40.065814	2023-07-26 03:34:40.065814
15	EuiP_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-08-01 05:26:38.933154	2023-08-01 05:26:38.933154
16	LfitBp.pccbhd@chiffon.fun	2023-10-23 01:54:51.296749	2023-10-23 01:54:51.296749
17	JkaUTb.htjtccb@monochord.xyz	2023-11-12 13:39:30.79964	2023-11-12 13:39:30.79964
18	OjnG_generic_9ee2db6f_benradler.com@data-backup-store.com	2023-11-18 04:28:02.002631	2023-11-18 04:28:02.002631
19	SSiuIc.twpctp@flexduck.click	2023-11-19 17:05:04.353596	2023-11-19 17:05:04.353596
20	NVyElC.hqwjmt@chiffon.fun	2023-11-22 09:03:23.030022	2023-11-22 09:03:23.030022
21	18.01hfyjsq8txh456r29n4h5eef6@mail4u.fun	2023-11-24 23:39:08.064404	2023-11-24 23:39:08.064404
22	YSVfDv.qhtdbht@sabletree.foundation	2023-11-25 20:03:22.51417	2023-11-25 20:03:22.51417
23	Mihhym.pqhtcb@chiffon.fun	2023-11-28 08:53:47.643652	2023-11-28 08:53:47.643652
24	qFueMY.qwpcmtt@wheelry.boats	2023-12-07 17:40:35.76265	2023-12-07 17:40:35.76265
25	AiFFPN.hcjwtqb@bakling.click	2023-12-18 13:38:28.846487	2023-12-18 13:38:28.846487
26	aTdfBC.qmhtjwd@carnana.art	2023-12-20 21:55:55.429234	2023-12-20 21:55:55.429234
27	rPUXvB.qchcpp@wisefoot.club	2023-12-24 06:43:05.356848	2023-12-24 06:43:05.356848
28	EJLFFj.dqdbqtj@carnana.art	2023-12-27 18:38:42.713404	2023-12-27 18:38:42.713404
29	jzwqSN.hwpdhjb@sandcress.xyz	2023-12-31 19:27:25.930364	2023-12-31 19:27:25.930364
30	nPyqqe.pqwbjdc@paravane.biz	2024-01-04 18:22:23.63664	2024-01-04 18:22:23.63664
31	dzvMrR.mqtqbww@chiffon.fun	2024-01-06 12:46:32.573031	2024-01-06 12:46:32.573031
32	DWEPwW.qqccbpj@brasswire.me	2024-01-15 16:18:54.78058	2024-01-15 16:18:54.78058
33	29.01hk6f99jdvcg2vh4hvp4x1jzy@mail5u.life	2024-01-19 10:44:24.45868	2024-01-19 10:44:24.45868
34	Vbknko.mtmwmbd@rightbliss.beauty	2024-01-22 03:17:57.235652	2024-01-22 03:17:57.235652
35	AKATDV.tpcjqjh@tonetics.biz	2024-01-24 13:40:17.345508	2024-01-24 13:40:17.345508
36	HxIsEk.qhmqwmbw@paravane.biz	2024-01-25 21:05:16.714592	2024-01-25 21:05:16.714592
37	OAoJYv.tctdmw@pointel.xyz	2024-02-01 19:22:33.965789	2024-02-01 19:22:33.965789
38	FLcTWI.pjpjwq@zetetic.sbs	2024-02-09 02:10:43.845065	2024-02-09 02:10:43.845065
39	ECrJxV.hqqpdph@sabletree.foundation	2024-02-10 23:30:42.076141	2024-02-10 23:30:42.076141
40	eVrfdJ.bdbhpdd@tonetics.biz	2024-02-11 17:44:07.184789	2024-02-11 17:44:07.184789
41	upoqUK.bwtwqth@rushlight.cfd	2024-02-17 04:21:25.66409	2024-02-17 04:21:25.66409
42	ywiMbm.cpwhpdc@rushlight.cfd	2024-02-21 08:16:36.405239	2024-02-21 08:16:36.405239
43	qLqMjj.qjbbcbjh@wheelry.boats	2024-02-24 01:54:15.905393	2024-02-24 01:54:15.905393
44	QvdkuJ.bbctmq@wisefoot.club	2024-02-25 13:01:42.986025	2024-02-25 13:01:42.986025
45	V2w4_generic_9ee2db6f_benradler.com@data-backup-store.com	2024-03-05 22:05:55.040238	2024-03-05 22:05:55.040238
46	uzfzHL.ptptmcm@rightbliss.beauty	2024-03-07 09:38:14.341744	2024-03-07 09:38:14.341744
47	YWvRmI.htchqjh@wheelry.boats	2024-03-09 03:30:25.260812	2024-03-09 03:30:25.260812
48	rLRCJn.wqdqjjq@rightbliss.beauty	2024-03-10 06:13:51.800636	2024-03-10 06:13:51.800636
49	hjbwhbcqm.q@monochord.xyz	2024-03-16 02:02:17.748844	2024-03-16 02:02:17.748844
50	bjhwmtbpp.q@monochord.xyz	2024-03-19 02:44:00.993299	2024-03-19 02:44:00.993299
51	pmmmcqbtb.q@monochord.xyz	2024-03-22 02:59:02.436934	2024-03-22 02:59:02.436934
84	qjmpjhmdmt.q@monochord.xyz	2024-03-24 18:56:39.733647	2024-03-24 18:56:39.733647
85	HYjdJF.pjwcdm@bakling.click	2024-03-30 22:42:57.498378	2024-03-30 22:42:57.498378
86	qpjqbwjhmm.q@rightbliss.beauty	2024-04-08 18:08:28.7896	2024-04-08 18:08:28.7896
87	qpwhqqdqjh.q@rightbliss.beauty	2024-04-10 07:26:09.441119	2024-04-10 07:26:09.441119
88	qwjwmbwpjt.q@rightbliss.beauty	2024-04-14 17:08:10.981983	2024-04-14 17:08:10.981983
89	qwcdmjtdcj.q@rightbliss.beauty	2024-04-24 10:08:17.84548	2024-04-24 10:08:17.84548
90	qwmqpddpqc.q@rightbliss.beauty	2024-04-26 09:49:39.593112	2024-04-26 09:49:39.593112
91	qmqwbwbmph.q@rightbliss.beauty	2024-04-28 05:21:09.732491	2024-04-28 05:21:09.732491
92	qmdbdhphhw.q@rightbliss.beauty	2024-04-29 20:20:46.381279	2024-04-29 20:20:46.381279
93	qmphhcwdwd.q@rightbliss.beauty	2024-05-01 13:57:54.600723	2024-05-01 13:57:54.600723
94	qmmmqjmpdj.q@rightbliss.beauty	2024-05-03 08:33:16.621638	2024-05-03 08:33:16.621638
95	hjhbmbjmmc.q@rightbliss.beauty	2024-05-05 00:29:07.8797	2024-05-05 00:29:07.8797
96	hjbhpmhhbh.q@rightbliss.beauty	2024-05-06 16:34:47.339405	2024-05-06 16:34:47.339405
97	hjpmcttbjw.q@rightbliss.beauty	2024-05-08 11:15:33.851809	2024-05-08 11:15:33.851809
98	hqjcdpdpcd.q@rightbliss.beauty	2024-05-09 18:38:47.585168	2024-05-09 18:38:47.585168
99	hqtttqcjhj.q@rightbliss.beauty	2024-05-10 10:25:55.111802	2024-05-10 10:25:55.111802
100	hhdjcwqjdd.q@rightbliss.beauty	2024-05-13 03:01:35.747399	2024-05-13 03:01:35.747399
101	hhmdtctbbc.q@rightbliss.beauty	2024-05-14 13:40:54.489588	2024-05-14 13:40:54.489588
102	htpdwwpthd.q@rightbliss.beauty	2024-05-16 13:29:35.387664	2024-05-16 13:29:35.387664
103	hdjqphwbwj.q@rightbliss.beauty	2024-05-17 05:44:39.490039	2024-05-17 05:44:39.490039
104	hdhwbcmwtc.q@rightbliss.beauty	2024-05-17 21:10:13.033427	2024-05-17 21:10:13.033427
105	hbjmjmtcjd.q@rightbliss.beauty	2024-05-19 15:38:05.799622	2024-05-19 15:38:05.799622
106	hbchppcqqc.q@rightbliss.beauty	2024-05-20 21:02:51.020802	2024-05-20 21:02:51.020802
107	hbwmcqptph.q@rightbliss.beauty	2024-05-21 14:57:24.538444	2024-05-21 14:57:24.538444
108	hcpjqdqqdj.q@rightbliss.beauty	2024-05-23 11:34:53.687072	2024-05-23 11:34:53.687072
109	hcmcmwhtmc.q@rightbliss.beauty	2024-05-24 19:21:04.458996	2024-05-24 19:21:04.458996
110	hphtwhtcbh.q@rightbliss.beauty	2024-05-26 01:13:25.231488	2024-05-26 01:13:25.231488
111	hpbjccdmjw.q@rightbliss.beauty	2024-05-27 07:39:02.245994	2024-05-27 07:39:02.245994
112	hpppbjcqcd.q@rightbliss.beauty	2024-05-28 16:46:08.732643	2024-05-28 16:46:08.732643
113	hwbwjhmmth.q@rightbliss.beauty	2024-06-01 13:09:44.402197	2024-06-01 13:09:44.402197
114	hwwdwpqqww.q@rightbliss.beauty	2024-06-02 20:04:46.516544	2024-06-02 20:04:46.516544
115	hmqqpqhddd.q@rightbliss.beauty	2024-06-04 05:00:10.017235	2024-06-04 05:00:10.017235
116	hmtwbbtpjj.q@rightbliss.beauty	2024-06-05 15:25:06.192147	2024-06-05 15:25:06.192147
149	hmcbtmdmbc.q@rightbliss.beauty	2024-06-07 01:56:05.494775	2024-06-07 01:56:05.494775
182	hmmhhtchqh.q@rightbliss.beauty	2024-06-08 09:46:16.690734	2024-06-08 09:46:16.690734
183	tjqmjppdcw.q@rightbliss.beauty	2024-06-09 17:25:11.894858	2024-06-09 17:25:11.894858
215	tjdbmqwphd.q@rightbliss.beauty	2024-06-11 01:10:02.903408	2024-06-11 01:10:02.903408
216	tjphpbmmwj.q@rightbliss.beauty	2024-06-12 10:11:01.542204	2024-06-12 10:11:01.542204
217	tjmmcjqhtc.q@rightbliss.beauty	2024-06-13 20:39:45.041547	2024-06-13 20:39:45.041547
248	tqhcddhdmh.q@rightbliss.beauty	2024-06-15 12:19:31.722723	2024-06-15 12:19:31.722723
249	tqbthwtpdw.q@rightbliss.beauty	2024-06-17 03:57:42.957173	2024-06-17 03:57:42.957173
250	medranostarckuzz8n0+23k4bmq7953j@gmail.com	2024-06-17 08:39:17.457664	2024-06-17 08:39:17.457664
251	tqwjqhbjjd.q@rightbliss.beauty	2024-06-18 23:10:48.898026	2024-06-18 23:10:48.898026
252	thttwjpbqc.q@silesia.life	2024-06-21 17:46:06.519431	2024-06-21 17:46:06.519431
253	thcjcdwpph.q@silesia.life	2024-06-22 22:29:34.492193	2024-06-22 22:29:34.492193
254	thwpdmjjhw.q@silesia.life	2024-06-24 03:51:06.228924	2024-06-24 03:51:06.228924
255	ttqdttqhwd.q@silesia.life	2024-06-25 14:16:17.384304	2024-06-25 14:16:17.384304
256	ttdqqphbdj.q@silesia.life	2024-06-27 13:45:34.205424	2024-06-27 13:45:34.205424
257	schermerdusenberycmp5p8+23k4bnr0af62@gmail.com	2024-06-28 01:50:26.369321	2024-06-28 01:50:26.369321
258	ttcwjqtpmc.q@silesia.life	2024-06-29 19:16:12.10471	2024-06-29 19:16:12.10471
259	tdhqcmctjw.q@silesia.life	2024-07-03 13:05:38.02714	2024-07-03 13:05:38.02714
260	GEQ9_generic_9ee2db6f_benradler.com@serviseantilogin.com	2024-07-03 16:51:10.865411	2024-07-03 16:51:10.865411
261	5yvz_generic_9ee2db6f_benradler.com@serviseantilogin.com	2024-07-03 21:36:44.721236	2024-07-03 21:36:44.721236
262	MtNM_generic_9ee2db6f_benradler.com@serviseantilogin.com	2024-07-04 11:42:13.726619	2024-07-04 11:42:13.726619
263	tddwbtpbcd.q@silesia.life	2024-07-05 09:21:55.310696	2024-07-05 09:21:55.310696
264	tdpbtpwwhj.q@silesia.life	2024-07-07 02:03:05.223048	2024-07-07 02:03:05.223048
265	tbjhhhjjpc.q@silesia.life	2024-07-08 16:50:22.043744	2024-07-08 16:50:22.043744
266	tbhmjcqtth.q@silesia.life	2024-07-11 00:10:32.542865	2024-07-11 00:10:32.542865
267	tbbbmjhbww.q@silesia.life	2024-07-12 18:00:40.469058	2024-07-12 18:00:40.469058
268	tbwhpdtwdd.q@silesia.life	2024-07-14 10:54:01.982794	2024-07-14 10:54:01.982794
269	tcjmbwbqjj.q@silesia.life	2024-07-16 04:16:40.609136	2024-07-16 04:16:40.609136
270	tctcdhctbc.q@silesia.life	2024-07-18 03:29:09.00799	2024-07-18 03:29:09.00799
271	tccthcpcqh.q@silesia.life	2024-07-19 23:21:07.678151	2024-07-19 23:21:07.678151
272	tcmjqjwwcw.q@silesia.life	2024-07-21 15:58:04.443842	2024-07-21 15:58:04.443842
273	tpqcmbjqhd.q@silesia.life	2024-07-23 16:32:47.387986	2024-07-23 16:32:47.387986
281	tpdtpmqtwj.q@rightbliss.beauty	2024-07-25 14:06:54.891785	2024-07-25 14:06:54.891785
314	wetzelmhoonjgq1a2+23k4bo100gpt@gmail.com	2024-07-30 07:21:34.310654	2024-07-30 07:21:34.310654
315	tppjcthctc.q@purline.top	2024-08-01 10:40:33.049335	2024-08-01 10:40:33.049335
316	twhdtqbqdw.q@rightbliss.beauty	2024-08-04 23:34:49.314244	2024-08-04 23:34:49.314244
317	djqhhjtmdj.q@rightbliss.beauty	2024-08-07 16:58:53.930435	2024-08-07 16:58:53.930435
318	dqpthbqdpc.q@rightbliss.beauty	2024-08-17 06:08:33.096307	2024-08-17 06:08:33.096307
319	mjaliajbuz@solid-hamster.skin	2024-08-24 04:46:16.44246	2024-08-24 04:46:16.44246
320	mjaliajbub@solid-hamster.skin	2024-08-24 04:46:18.091923	2024-08-24 04:46:18.091923
321	mjaliajbua@solid-hamster.skin	2024-08-24 04:46:20.161423	2024-08-24 04:46:20.161423
322	mjaliajbus@solid-hamster.skin	2024-08-24 04:46:22.184822	2024-08-24 04:46:22.184822
323	mjaliajbum@solid-hamster.skin	2024-08-24 04:46:23.655363	2024-08-24 04:46:23.655363
324	mjaliajbuzz@solid-hamster.skin	2024-08-24 04:46:25.887111	2024-08-24 04:46:25.887111
347	Cszr_generic_9ee2db6f_benradler.com@serviseantilogin.com	2024-09-10 14:45:05.560201	2024-09-10 14:45:05.560201
380	IVnx_generic_9ee2db6f_benradler.com@serviseantilogin.com	2024-09-15 07:17:29.695774	2024-09-15 07:17:29.695774
413	susan_parkr2av@outlook.com	2024-09-17 11:48:06.65129	2024-09-17 11:48:06.65129
414	flyhighaus10@yahoo.com	2024-09-19 19:22:27.232392	2024-09-19 19:22:27.232392
415	judyxq_forddy@outlook.com	2024-09-22 16:57:07.390462	2024-09-22 16:57:07.390462
446	17Up_generic_9ee2db6f_benradler.com@serviseantilogin.com	2024-09-30 16:45:36.862607	2024-09-30 16:45:36.862607
479	bdilloni4600@gmail.com	2024-10-11 09:49:03.802731	2024-10-11 09:49:03.802731
512	dettacampbelll@gmail.com	2024-10-17 17:20:04.125086	2024-10-17 17:20:04.125086
545	sextondjos2907@gmail.com	2024-10-21 02:53:35.588396	2024-10-21 02:53:35.588396
578	dixoneitee9824@gmail.com	2024-10-25 12:03:09.935181	2024-10-25 12:03:09.935181
579	wapcosmumbai@yahoo.com	2024-10-29 02:30:52.800123	2024-10-29 02:30:52.800123
611	lobergeranito@yahoo.com	2024-11-03 23:06:17.550542	2024-11-03 23:06:17.550542
612	aliaoi5033@hotmail.com	2024-11-07 23:52:56.204984	2024-11-07 23:52:56.204984
613	ezelblake1992@gmail.com	2024-11-08 21:27:30.041664	2024-11-08 21:27:30.041664
614	vikiryanin@gmail.com	2024-11-08 21:42:43.407791	2024-11-08 21:42:43.407791
615	hendriksndodnavar@yahoo.com	2024-11-09 16:25:52.809713	2024-11-09 16:25:52.809713
616	aaryjsnbkjfv@yahoo.com	2024-11-10 09:06:06.6296	2024-11-10 09:06:06.6296
617	raashtgbpgce@yahoo.com	2024-11-11 21:43:45.509936	2024-11-11 21:43:45.509936
618	ellchunva3818@gmail.com	2024-11-12 17:51:46.07507	2024-11-12 17:51:46.07507
619	reynaldalaracuente@hotmail.com	2024-11-14 13:05:28.130371	2024-11-14 13:05:28.130371
620	ishajph1989@gmail.com	2024-11-15 09:42:52.542463	2024-11-15 09:42:52.542463
621	mcuinayugn@yahoo.com	2024-11-16 07:25:32.1447	2024-11-16 07:25:32.1447
644	klfddhtxceypwlmu@yahoo.com	2024-11-17 05:52:09.277291	2024-11-17 05:52:09.277291
645	easigwoodjaggi@yahoo.com	2024-11-18 10:55:23.837383	2024-11-18 10:55:23.837383
677	isolacaraibica@yahoo.com	2024-11-21 08:23:06.532825	2024-11-21 08:23:06.532825
710	bagalktarleg@yahoo.com	2024-11-24 16:07:30.911692	2024-11-24 16:07:30.911692
711	djarrodrandolphtc@gmail.com	2024-11-25 13:17:40.261666	2024-11-25 13:17:40.261666
712	gaisantanao3282@gmail.com	2024-11-26 11:56:46.469073	2024-11-26 11:56:46.469073
713	ugtaokpgarmwwix@yahoo.com	2024-11-27 10:15:34.412446	2024-11-27 10:15:34.412446
714	howellkyinsi@gmail.com	2024-11-28 08:18:52.430618	2024-11-28 08:18:52.430618
715	burchdevnetd@gmail.com	2024-11-29 05:01:58.500407	2024-11-29 05:01:58.500407
716	alexanderhyddk23@gmail.com	2024-11-30 00:10:55.237389	2024-11-30 00:10:55.237389
717	cvjwtbuufsutuit@yahoo.com	2024-11-30 18:35:50.776882	2024-11-30 18:35:50.776882
718	khrgoibsx@yahoo.com	2024-12-01 12:53:43.093778	2024-12-01 12:53:43.093778
719	powelllluellins3797@gmail.com	2024-12-02 05:33:14.544431	2024-12-02 05:33:14.544431
720	mesinadanseraeu@yahoo.com	2024-12-02 23:59:21.163053	2024-12-02 23:59:21.163053
721	kazeltensch@yahoo.com	2024-12-03 17:21:24.061595	2024-12-03 17:21:24.061595
722	hcuxvonblkntd@yahoo.com	2024-12-04 09:18:08.576268	2024-12-04 09:18:08.576268
723	bodknaldi@yahoo.com	2024-12-05 03:06:17.877751	2024-12-05 03:06:17.877751
724	kbotrvgtwgajtncpu@yahoo.com	2024-12-05 22:34:40.060666	2024-12-05 22:34:40.060666
725	kaspirekkmlet@yahoo.com	2024-12-06 17:36:01.329716	2024-12-06 17:36:01.329716
726	hldigdn50hlcmb@yahoo.com	2024-12-07 11:46:35.09631	2024-12-07 11:46:35.09631
727	ktgdwlnuukkhakhny@yahoo.com	2024-12-08 05:30:31.607133	2024-12-08 05:30:31.607133
728	stefanieargote@gmail.com	2024-12-08 22:37:10.138837	2024-12-08 22:37:10.138837
729	lhqss7wlviritdtc@yahoo.com	2024-12-10 00:22:16.618321	2024-12-10 00:22:16.618321
743	florimq77@gmail.com	2024-12-11 00:04:00.230282	2024-12-11 00:04:00.230282
776	odomdez72@gmail.com	2024-12-12 04:21:27.236739	2024-12-12 04:21:27.236739
777	abachipippins@yahoo.com	2024-12-13 07:50:10.59779	2024-12-13 07:50:10.59779
778	rikmulzt@yahoo.com	2024-12-14 07:36:53.305935	2024-12-14 07:36:53.305935
779	trichmondyj1998@gmail.com	2024-12-15 03:45:11.273183	2024-12-15 03:45:11.273183
780	hm771ikfn3xgsxm@yahoo.com	2024-12-16 01:59:22.431052	2024-12-16 01:59:22.431052
809	yrgatinkitzl@yahoo.com	2024-12-17 06:22:03.602622	2024-12-17 06:22:03.602622
810	fldeacdpluwblmal@yahoo.com	2024-12-18 10:38:09.971433	2024-12-18 10:38:09.971433
811	mqbkblvaxhm@yahoo.com	2024-12-19 10:38:12.269931	2024-12-19 10:38:12.269931
812	jmnbinejaq@yahoo.com	2024-12-20 10:30:11.372377	2024-12-20 10:30:11.372377
813	puqowukov890@gmail.com	2024-12-21 07:43:59.113824	2024-12-21 07:43:59.113824
814	pununuke38@gmail.com	2024-12-22 02:57:16.111516	2024-12-22 02:57:16.111516
815	atl8b3xnn@yahoo.com	2024-12-22 21:26:36.11598	2024-12-22 21:26:36.11598
816	retibenejid868@gmail.com	2024-12-23 17:16:58.74597	2024-12-23 17:16:58.74597
817	obsidianauwraithe@gmail.com	2024-12-24 19:49:29.575751	2024-12-24 19:49:29.575751
818	tezepewu93@gmail.com	2024-12-25 15:28:53.492838	2024-12-25 15:28:53.492838
819	snmknhqhovyyqmjeq@yahoo.com	2024-12-26 10:46:53.925718	2024-12-26 10:46:53.925718
820	umameyahi91@gmail.com	2024-12-27 11:34:38.420999	2024-12-27 11:34:38.420999
821	etexalutazas54@gmail.com	2024-12-28 10:11:26.746704	2024-12-28 10:11:26.746704
822	fodopenibip38@gmail.com	2024-12-30 05:37:14.511364	2024-12-30 05:37:14.511364
823	bebiyacez980@gmail.com	2024-12-31 02:45:21.369358	2024-12-31 02:45:21.369358
824	mcs2eij2hllaqlp@yahoo.com	2024-12-31 21:13:07.142606	2024-12-31 21:13:07.142606
825	ahuvupoz963@gmail.com	2025-01-01 13:54:25.255864	2025-01-01 13:54:25.255864
826	bxhvmmowl@yahoo.com	2025-01-02 07:06:31.984838	2025-01-02 07:06:31.984838
827	lmylfhxwdleqkr@yahoo.com	2025-01-03 03:50:40.195861	2025-01-03 03:50:40.195861
828	o09iwuy9ii15@yahoo.com	2025-01-04 03:13:24.94678	2025-01-04 03:13:24.94678
829	oripenipodem86@gmail.com	2025-01-05 03:05:05.07684	2025-01-05 03:05:05.07684
830	cstdt8wdohlif@yahoo.com	2025-01-07 10:31:54.779003	2025-01-07 10:31:54.779003
831	usaqdmaahaoh@yahoo.com	2025-01-08 11:00:13.034264	2025-01-08 11:00:13.034264
832	zeduwave882@gmail.com	2025-01-09 15:34:52.33144	2025-01-09 15:34:52.33144
833	agaerosbrow@yahoo.com	2025-01-10 14:03:34.569778	2025-01-10 14:03:34.569778
842	ocngkwioiug@yahoo.com	2025-01-11 11:58:30.304852	2025-01-11 11:58:30.304852
843	kuelusheinzan@yahoo.com	2025-01-12 13:54:16.351534	2025-01-12 13:54:16.351534
844	qqxi4uytdpr@yahoo.com	2025-01-13 18:11:45.261594	2025-01-13 18:11:45.261594
875	zenithoo29umbra89ia@gmail.com	2025-01-15 08:39:20.455794	2025-01-15 08:39:20.455794
876	abelyheilnr@yahoo.com	2025-01-16 20:03:13.633999	2025-01-16 20:03:13.633999
877	iborealay73kaleidoscope28@gmail.com	2025-01-18 04:01:08.342834	2025-01-18 04:01:08.342834
878	pakettzaidis@yahoo.com	2025-01-19 22:04:24.870565	2025-01-19 22:04:24.870565
879	iuthilon@yahoo.com	2025-01-20 22:54:58.711717	2025-01-20 22:54:58.711717
880	kismetia82verge20ay@gmail.com	2025-01-22 09:46:23.3271	2025-01-22 09:46:23.3271
908	huptcliibuphcq@yahoo.com	2025-01-24 04:34:57.40671	2025-01-24 04:34:57.40671
909	pazapz@mailbox.in.ua	2025-01-24 20:21:35.47929	2025-01-24 20:21:35.47929
910	Jimmy9Hall2360@gmail.com	2025-01-25 09:37:59.614042	2025-01-25 09:37:59.614042
911	mlesbhv93u@yahoo.com	2025-01-27 06:19:02.825039	2025-01-27 06:19:02.825039
912	furbermahboobzadeh@yahoo.com	2025-01-29 23:58:45.987493	2025-01-29 23:58:45.987493
913	anfyienaklea@yahoo.com	2025-01-31 05:15:33.844313	2025-01-31 05:15:33.844313
914	kgppryscnyvb@yahoo.com	2025-02-01 10:45:32.933215	2025-02-01 10:45:32.933215
915	lk5s92jyl4urof@yahoo.com	2025-02-03 06:52:08.274046	2025-02-03 06:52:08.274046
916	aegossameria32yarn58@gmail.com	2025-02-04 08:18:25.660874	2025-02-04 08:18:25.660874
917	iozenithuealchemyea@gmail.com	2025-02-05 08:56:44.667893	2025-02-05 08:56:44.667893
941	oyzenithumbra91@gmail.com	2025-02-06 08:29:19.418968	2025-02-06 08:29:19.418968
942	jubileeiu71sylvanoe@gmail.com	2025-02-07 06:56:51.354605	2025-02-07 06:56:51.354605
943	jubileeue26oracle25e@gmail.com	2025-02-09 03:43:09.218766	2025-02-09 03:43:09.218766
944	aunseenaimirage@gmail.com	2025-02-10 10:06:28.674905	2025-02-10 10:06:28.674905
974	badrbaixopt@yahoo.com	2025-02-14 10:56:21.433494	2025-02-14 10:56:21.433494
975	gossamerio96nexus74@gmail.com	2025-02-15 05:27:35.467646	2025-02-15 05:27:35.467646
976	ppihyfed@do-not-respond.me	2025-02-15 16:13:59.083697	2025-02-15 16:13:59.083697
977	rydyardf@gmail.com	2025-02-15 22:18:22.316175	2025-02-15 22:18:22.316175
978	gerbertroy44@gmail.com	2025-02-16 13:56:51.143843	2025-02-16 13:56:51.143843
979	daimondju8@gmail.com	2025-02-17 06:25:04.98074	2025-02-17 06:25:04.98074
980	dalyafbe2004@gmail.com	2025-02-18 10:15:08.954527	2025-02-18 10:15:08.954527
981	milbergaoqm47@gmail.com	2025-02-19 22:42:05.589746	2025-02-19 22:42:05.589746
982	ua32echo66@gmail.com	2025-02-20 20:51:39.034367	2025-02-20 20:51:39.034367
983	megmql25@gmail.com	2025-02-22 15:48:45.217685	2025-02-22 15:48:45.217685
984	qtmiosjx@do-not-respond.me	2025-02-23 05:37:27.345607	2025-02-23 05:37:27.345607
985	graibrock39@gmail.com	2025-02-23 08:52:23.986115	2025-02-23 08:52:23.986115
986	poulouebaace@yahoo.com	2025-02-24 03:14:55.147604	2025-02-24 03:14:55.147604
987	duskoi81iris@gmail.com	2025-02-25 05:02:06.559147	2025-02-25 05:02:06.559147
988	nirvana6rift5ia@gmail.com	2025-02-26 05:01:21.41746	2025-02-26 05:01:21.41746
989	maldonadoaltaird6@gmail.com	2025-02-27 04:05:21.733184	2025-02-27 04:05:21.733184
990	vddhlisumdl@yahoo.com	2025-02-28 04:16:13.609441	2025-02-28 04:16:13.609441
991	brinkhan23@gmail.com	2025-02-28 20:19:23.748608	2025-02-28 20:19:23.748608
1007	teodocarlsaq3@gmail.com	2025-03-01 12:09:23.32364	2025-03-01 12:09:23.32364
1008	ksnowtf34@gmail.com	2025-03-02 06:23:12.8594	2025-03-02 06:23:12.8594
1009	zzterdpz@do-not-respond.me	2025-03-04 01:03:58.20387	2025-03-04 01:03:58.20387
1010	mckeenolanm2006@gmail.com	2025-03-04 23:09:14.664454	2025-03-04 23:09:14.664454
1011	xfqmxnts@do-not-respond.me	2025-03-05 12:11:34.641937	2025-03-05 12:11:34.641937
1040	dominmoogu50@gmail.com	2025-03-06 02:24:58.0265	2025-03-06 02:24:58.0265
1041	ufaksjxb@do-not-respond.me	2025-03-07 04:53:05.596539	2025-03-07 04:53:05.596539
1042	shakyillsb1993@gmail.com	2025-03-07 07:48:07.878666	2025-03-07 07:48:07.878666
1073	schwartzgennaoz5@gmail.com	2025-03-08 05:59:43.611221	2025-03-08 05:59:43.611221
1074	wtmnzwdt@do-not-respond.me	2025-03-08 13:21:44.320086	2025-03-08 13:21:44.320086
1075	djoynic@gmail.com	2025-03-09 02:44:52.669257	2025-03-09 02:44:52.669257
1106	hubbardashtond1986@gmail.com	2025-03-10 05:53:16.191929	2025-03-10 05:53:16.191929
1139	moonmeibellaini5@gmail.com	2025-03-13 18:51:44.113251	2025-03-13 18:51:44.113251
1140	melissa_broadus1992@yahoo.com	2025-03-16 07:38:15.582755	2025-03-16 07:38:15.582755
1141	svanhildsteeleo@gmail.com	2025-03-17 02:07:12.90035	2025-03-17 02:07:12.90035
1142	soniahogue570475@yahoo.com	2025-03-18 09:53:19.604645	2025-03-18 09:53:19.604645
1143	snaaikoi@do-not-respond.me	2025-03-18 09:58:36.650338	2025-03-18 09:58:36.650338
1144	wilkerluks@gmail.com	2025-03-19 12:28:09.211102	2025-03-19 12:28:09.211102
1145	millereldredc1987@gmail.com	2025-03-20 17:15:44.356686	2025-03-20 17:15:44.356686
1146	summersdjelissa4@gmail.com	2025-03-21 04:39:13.084407	2025-03-21 04:39:13.084407
1147	fbrentonke3@gmail.com	2025-03-23 17:08:19.814328	2025-03-23 17:08:19.814328
1148	adelislawrencei25@gmail.com	2025-03-24 09:58:34.671006	2025-03-24 09:58:34.671006
1149	kelleyfrenkipo31@gmail.com	2025-03-28 12:32:03.950695	2025-03-28 12:32:03.950695
1150	matthewjones688914@yahoo.com	2025-03-29 22:49:10.049466	2025-03-29 22:49:10.049466
1151	yorkkonanwi75@gmail.com	2025-04-01 04:42:54.898766	2025-04-01 04:42:54.898766
1172	melaniemazrieva833725@yahoo.com	2025-04-02 11:18:42.976175	2025-04-02 11:18:42.976175
1173	langkrispian8@gmail.com	2025-04-03 07:54:27.736695	2025-04-03 07:54:27.736695
1205	ethnabernw@gmail.com	2025-04-03 20:04:23.661066	2025-04-03 20:04:23.661066
1206	xhpmwwun@form-check.online	2025-04-04 18:43:14.820365	2025-04-04 18:43:14.820365
1207	wsqalkwo@form-check.online	2025-04-04 18:43:14.864005	2025-04-04 18:43:14.864005
1208	milonas_richard136473@yahoo.com	2025-04-05 14:46:39.84333	2025-04-05 14:46:39.84333
1209	mark_hill597115@yahoo.com	2025-04-05 17:21:50.832217	2025-04-05 17:21:50.832217
1210	waltegregoan@gmail.com	2025-04-06 00:06:21.745067	2025-04-06 00:06:21.745067
1211	thompson.kimberly507864@yahoo.com	2025-04-06 02:41:30.550949	2025-04-06 02:41:30.550949
1212	dknightq1998@gmail.com	2025-04-06 14:39:32.716405	2025-04-06 14:39:32.716405
1213	farrellsidns8@gmail.com	2025-04-07 01:10:31.179327	2025-04-07 01:10:31.179327
1214	danielle_collins524191@yahoo.com	2025-04-07 03:14:41.572488	2025-04-07 03:14:41.572488
1215	dyerkendf48@gmail.com	2025-04-08 04:04:30.904099	2025-04-08 04:04:30.904099
1216	nburnsvi65@gmail.com	2025-04-09 22:58:20.306124	2025-04-09 22:58:20.306124
1217	watersteinziv@gmail.com	2025-04-10 06:34:03.228616	2025-04-10 06:34:03.228616
1218	basque_josh844191@yahoo.com	2025-04-11 14:31:24.613507	2025-04-11 14:31:24.613507
1219	klerise1985@gmail.com	2025-04-11 15:39:25.458653	2025-04-11 15:39:25.458653
1220	fwtqqpoj@dont-reply.me	2025-04-11 20:42:15.19156	2025-04-11 20:42:15.19156
1221	gfdokmaw@dont-reply.me	2025-04-11 20:42:15.350311	2025-04-11 20:42:15.350311
1222	richiehossain1994@yahoo.com	2025-04-13 01:56:26.124765	2025-04-13 01:56:26.124765
1223	luis_walsh532316@yahoo.com	2025-04-13 04:36:27.954702	2025-04-13 04:36:27.954702
1224	oxiuimqf@formtest.guru	2025-04-13 06:48:13.634578	2025-04-13 06:48:13.634578
1225	gardndjoettzn3@gmail.com	2025-04-15 11:33:35.428876	2025-04-15 11:33:35.428876
1238	korrirodriguezc2005@gmail.com	2025-04-17 03:41:50.176313	2025-04-17 03:41:50.176313
1239	verbodepar1973@yahoo.com	2025-04-18 17:08:09.031476	2025-04-18 17:08:09.031476
1240	walshamandal36@gmail.com	2025-04-19 01:21:58.97094	2025-04-19 01:21:58.97094
1241	reubirthdestdi1989@yahoo.com	2025-04-19 18:08:59.089295	2025-04-19 18:08:59.089295
1242	grahareddj@gmail.com	2025-04-20 05:23:14.333356	2025-04-20 05:23:14.333356
1243	vercucaljazz1970@yahoo.com	2025-04-20 07:03:37.526025	2025-04-20 07:03:37.526025
1244	kleintentm@gmail.com	2025-04-20 12:21:06.9058	2025-04-20 12:21:06.9058
1245	tstevensin1991@gmail.com	2025-04-21 12:10:34.584771	2025-04-21 12:10:34.584771
1246	lmjptpwh@formtest.guru	2025-04-23 23:52:01.965381	2025-04-23 23:52:01.965381
1247	doloresconway34@gmail.com	2025-04-25 13:53:51.175655	2025-04-25 13:53:51.175655
1248	hesterteri17@gmail.com	2025-04-25 23:38:07.724683	2025-04-25 23:38:07.724683
1249	lendonvne4@gmail.com	2025-04-26 13:00:40.364944	2025-04-26 13:00:40.364944
1250	cgicfbfj@formtest.guru	2025-04-27 12:12:05.376102	2025-04-27 12:12:05.376102
1251	rosscaseb@gmail.com	2025-04-27 12:18:36.224584	2025-04-27 12:18:36.224584
1252	henrdolfb41@gmail.com	2025-04-28 11:08:28.653652	2025-04-28 11:08:28.653652
1253	lszajfgr@dont-reply.me	2025-04-29 01:36:33.017052	2025-04-29 01:36:33.017052
1254	ztqrqtok@dont-reply.me	2025-04-29 01:36:33.163805	2025-04-29 01:36:33.163805
1255	estradrend2001@gmail.com	2025-04-30 17:57:14.473944	2025-04-30 17:57:14.473944
1256	sgrirs3@gmail.com	2025-05-01 08:35:55.446592	2025-05-01 08:35:55.446592
1257	peidwaters1993@gmail.com	2025-05-01 12:28:09.723161	2025-05-01 12:28:09.723161
1271	reynoldsbansh1@gmail.com	2025-05-04 11:29:07.807816	2025-05-04 11:29:07.807816
1272	ketrinc45@gmail.com	2025-05-05 23:06:13.482882	2025-05-05 23:06:13.482882
1273	bridgetlwc68@gmail.com	2025-05-06 01:28:04.509263	2025-05-06 01:28:04.509263
1274	bkristabellavt2@gmail.com	2025-05-07 04:45:00.139168	2025-05-07 04:45:00.139168
1275	stephensonlibbeiy@gmail.com	2025-05-07 05:36:25.145135	2025-05-07 05:36:25.145135
1276	sidjeberhtml16@gmail.com	2025-05-08 12:32:05.846889	2025-05-08 12:32:05.846889
1277	rodgerbrendk45@gmail.com	2025-05-09 06:32:21.814084	2025-05-09 06:32:21.814084
1278	tcameronux23@gmail.com	2025-05-09 11:47:47.737306	2025-05-09 11:47:47.737306
1279	eiliruss22@gmail.com	2025-05-10 06:28:19.451165	2025-05-10 06:28:19.451165
1280	obarreraw@gmail.com	2025-05-11 18:20:51.557277	2025-05-11 18:20:51.557277
1281	lihorasin1982@yahoo.com	2025-05-11 19:13:21.468821	2025-05-11 19:13:21.468821
1282	brytysp5@gmail.com	2025-05-14 03:10:15.632201	2025-05-14 03:10:15.632201
1283	vmosleymh@gmail.com	2025-05-14 08:41:57.830853	2025-05-14 08:41:57.830853
1284	castroshemar660306@yahoo.com	2025-05-15 12:05:37.164605	2025-05-15 12:05:37.164605
1285	ariapatri9@gmail.com	2025-05-15 15:20:27.202472	2025-05-15 15:20:27.202472
1286	andresadams564256@yahoo.com	2025-05-15 15:33:13.421651	2025-05-15 15:33:13.421651
1287	dhaasmh1998@gmail.com	2025-05-15 17:52:01.261618	2025-05-15 17:52:01.261618
1288	whitedjif32@gmail.com	2025-05-16 01:30:48.403789	2025-05-16 01:30:48.403789
1289	dschaefery@gmail.com	2025-05-16 05:36:38.471469	2025-05-16 05:36:38.471469
1290	anabkempu@gmail.com	2025-05-17 04:41:42.722178	2025-05-17 04:41:42.722178
1291	manningylissese2005@gmail.com	2025-05-17 07:27:25.938933	2025-05-17 07:27:25.938933
1292	veidgrantl@gmail.com	2025-05-17 08:58:13.149138	2025-05-17 08:58:13.149138
1293	simmonsamang9@gmail.com	2025-05-18 21:13:37.575731	2025-05-18 21:13:37.575731
1294	scostabk@gmail.com	2025-05-19 15:58:15.814732	2025-05-19 15:58:15.814732
1295	markleyluis898076@yahoo.com	2025-05-20 01:14:21.649179	2025-05-20 01:14:21.649179
1296	sissigardner71@gmail.com	2025-05-20 04:45:49.038768	2025-05-20 04:45:49.038768
1297	russellbeth800396@yahoo.com	2025-05-20 10:32:25.015008	2025-05-20 10:32:25.015008
1298	richmonddjylyan29@gmail.com	2025-05-20 10:52:25.971575	2025-05-20 10:52:25.971575
1299	cheresekwia1987@yahoo.com	2025-05-20 14:30:10.632691	2025-05-20 14:30:10.632691
1300	ortegadenisaf27@gmail.com	2025-05-22 07:48:14.507554	2025-05-22 07:48:14.507554
1301	sdonovanrj26@gmail.com	2025-05-22 10:18:59.990749	2025-05-22 10:18:59.990749
1302	belmathjs1989@gmail.com	2025-05-23 23:42:50.209108	2025-05-23 23:42:50.209108
1303	shepardkendra6@gmail.com	2025-05-24 02:54:11.883722	2025-05-24 02:54:11.883722
1304	eoforvdeckut1990@gmail.com	2025-05-25 03:03:33.034079	2025-05-25 03:03:33.034079
1305	tirodufql2@gmail.com	2025-05-25 03:30:10.109121	2025-05-25 03:30:10.109121
1306	oliviyalunakq1999@gmail.com	2025-05-25 04:58:07.841647	2025-05-25 04:58:07.841647
1307	brittanymitchell758242@yahoo.com	2025-05-25 12:28:14.189546	2025-05-25 12:28:14.189546
1337	fergusonevak48@gmail.com	2025-05-26 16:20:53.651247	2025-05-26 16:20:53.651247
1338	reibarryvl32@gmail.com	2025-05-26 21:44:57.140746	2025-05-26 21:44:57.140746
1339	tironvaughntz3@gmail.com	2025-05-26 23:12:13.353213	2025-05-26 23:12:13.353213
1340	nyorner44@gmail.com	2025-05-28 02:07:36.738572	2025-05-28 02:07:36.738572
1341	elanorb1991@gmail.com	2025-05-28 09:51:29.114426	2025-05-28 09:51:29.114426
1342	korbinb2006@gmail.com	2025-05-28 19:02:50.806144	2025-05-28 19:02:50.806144
1343	unvphwxo@dont-reply.me	2025-05-28 19:08:40.271241	2025-05-28 19:08:40.271241
1344	vscnzswy@dont-reply.me	2025-05-28 19:08:40.29273	2025-05-28 19:08:40.29273
1345	jeremydecoteau1998@yahoo.com	2025-05-28 19:44:51.994622	2025-05-28 19:44:51.994622
1346	inglecarol349003@yahoo.com	2025-05-29 10:25:55.718792	2025-05-29 10:25:55.718792
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.posts (id, body, title, published, created_at, updated_at, user_id, slug, description) FROM stdin;
5	I recently came across a function declaration with a Javascript syntax that I had never seen before.\r\n\r\n```js\r\n!function() {\r\n  // some logic\r\n}\r\n```\r\n\r\nThis `!` bang is called the **unary operator**.\r\n\r\nI immediately started playing around in the Node console to try and understand this syntax.  \r\n\r\n<!--more-->\r\n\r\nWithout the bang, this function declaration will actually throw an error:\r\n\r\n```js\r\nfunction() {\r\n // nothing here\r\n}\r\n\r\n// => SyntaxError: Unexpected token (\r\n```\r\n\r\nWeird right?  The reason for this is that the function defined **with** the `!` converts what would normally be a function declaration to a function expression. As a result, the function can be invoked without wrapping it in a closure (parenthesis).\r\n\r\nIn fact, it turns out that our original example is actually **identical** to the following function declaration:\r\n\r\n```js\r\n// original example\r\n!function() {}\r\n\r\n// identical example\r\n(function() {})\r\n```\r\n\r\nSo you are essentially saving a single character by using the **unary operator** instead of wrapping the function declaration in a closure.\r\n\r\nYou can invoke these functions as follows:\r\n\r\n```js\r\n// original example\r\n!function() {}();\r\n\r\n// identical example\r\n(function() {})();\r\n```\r\n\r\nThanks to [Narciso Guillen](https://github.com/narcisoguillen) for helping decode this syntax.	Bangs (exclamation points) in front of function definitions in Javascript?	t	2014-07-14 22:05:00	2015-02-12 01:33:02.481291	1	bangs-exclamation-points-in-front-of-function-definitions-in-javascript	\N
2	Having trouble getting packages installed in NPM?  Getting an error that looks like this??\r\n\r\n```sh\r\n~ npm install -g nodemon\r\nnpm ERR! Darwin 13.4.0\r\nnpm ERR! argv "node" "/usr/local/bin/npm" "install" "-g" "nodemon"\r\nnpm ERR! node v0.10.32\r\nnpm ERR! npm  v2.0.0\r\nnpm ERR! path /Users/me/.nvm/v0.10.32/lib/node_modules/nodemon/node_modules/update-notifier/node_modules/configstore/node_modules/mkdirp/package.json\r\nnpm ERR! code ENOENT\r\nnpm ERR! errno 34\r\n\r\nnpm ERR! ENOENT, open '/Users/me/.nvm/v0.10.32/lib/node_modules/nodemon/node_modules/update-notifier/node_modules/configstore/node_modules/mkdirp/package.json'\r\nnpm ERR!\r\nnpm ERR! If you need help, you may report this error at:\r\nnpm ERR!     <http://github.com/npm/npm/issues>\r\n~ which npm\r\n/usr/local/bin/npm\r\n~ node -v\r\nv0.10.32\r\n~ which node\r\n/Users/me/.nvm/v0.10.32/bin/node\r\n~ cd ~/Code/onelogin/search\r\n```\r\n\r\nThe solution is simple.\r\n\r\n<!--more-->\r\n\r\n```shell\r\nnpm cache clean\r\n```\r\n\r\nIf this doesn't work, try updating npm itself, via:\r\n\r\n```shell\r\nnpm update npm -g\r\n```\r\n\r\nThen run the above `clean` command again.	NPM and Nodemon install errors	t	2014-09-23 17:56:00	2015-02-12 01:28:20.046524	1	npm-and-nodemon-install-errors	\N
3	## Introduction\r\n\r\nWhen working with Git, and software in general, the most important thing for me is that the act of using the application blends seamlessly into my workflow.  It should feel natural, simple, and shouldn't slow you down.\r\n\r\nI've worked with Git for a few years now, and like all things, I've kept track of my favorite tweaks and configurations.  I'd like to share a few of the most awesome Git shortcuts I use on a daily basis.\r\n\r\n<!--more-->\r\n\r\n## Configuration\r\n\r\nFirst, let's talk about a few configuration options that every engineer should be familiar with.\r\n\r\n### A Damn Good Difftool\r\nWhen invoking Git's `difftool` and `mergetool`, instead of relying on Git's (admittedly simple and awesome) to help you resolve conflicts, I recommend the brilliant [Kaleidoscope OS X App](http://kaleidoscopeapp.com).\r\n\r\nThis app is incredibly useful for comparing differences in files, be it text, image, or even entire directories.\r\n\r\n### rerere\r\nTo enable `rerere`:\r\n\r\n```shell\r\ngit config --global rerere.enabled 1\r\n```\r\n\r\n[`rerere`](http://git-scm.com/docs/git-rerere), short for reuse recorded resolution, is a lesser-known feature of Git which allows a user to replay already-resolved merges.  \r\n\r\nThis is an extremely nice feature that will automatically re-resolve any merge conflicts that you resolved in the past when using `rebase` or `merge`(with your freshly installed Kaleidoscope mergetool).\r\n\r\nAs an aside, if you incorrectly resolve a conflict, you can always use `git rerere forget <pathspec>` to force Git to forget!\r\n\r\n### autosetuprebase\r\nTo enable `autosetuprebase`:\r\n\r\n```shell\r\ngit config --global branch.autosetuprebase always\r\n``` \r\n\r\nThe `autosetuprebase` option will tell Git to automatically `rebase` instead of `merge` in new changes when pulling. Settings this configuration option to `always` has a subtle difference from the default setting of `true`.  `always` will not only change the behavior on remote branches, but on local branches as well.\r\n\r\nI prefer this setting to the default, as it keeps all commit history instead of merging in new changes as a single merge commit.  This fits inline with my general strategy of keeping commit history very succinct and clean.  I'm a big fan of `fixup` and `squash` commits before bringing new features over to a `develop` or `master` branch.\r\n\r\nIt's important to note that any existing branches will retain their current configuration on a branch-by-branch basis.\r\n\r\n### autosetupmerge\r\nTo enable `autosetupmerge`:\r\n\r\n```shell\r\ngit config --global branch.autosetupmerge always\r\n``` \r\n\r\nOften mistaken as the companion setting to `autosetuprebase`, `autosetupmerge` is quite different.\r\n\r\n`autosetupmerge` specifies whether `git branch` and `git checkout -b` should pass the `--track` flag by default. Setting this to always causes both remote and local branches to automatically create new branches which  track their parent.\r\n\r\n## Shortcuts/Aliases\r\n\r\n### `current-branch` or `cb`\r\nTo enable `git current-branch`:\r\n\r\n```shell\r\ngit config --global alias.current-branch 'rev-parse --symbolic-full-name --abbrev-ref HEAD'\r\n```\r\n\r\nThis one is super simple.  It simply outputs the currently checked out branch.  We'll be using it again in a second...\r\n\r\n### `shove`\r\ngit config --global alias.shove '!f() { H=$(git current-branch) && git push -u origin $H; }; f'\r\n\r\nA super useful alias, `git shove` is generally my first command fired off after creating a new branch.\r\n\r\nWhat `shove` does is perform a `git push -u origin <current_branch>`.  You can think of it as a nice first step to tell your origin that you've created a new local branch you want to track remotely as well.\r\n\r\n### `lg`\r\n[`git lg`](https://coderwall.com/p/euwpig) is a brilliant configuration to output the `git log` command in a readable, color-coded format that shows a GUI representation of your branches. Not only does it show where branches begin and end, it shows the commits they contain, and how they replayed onto other branches! Super handy.\r\n\r\n### `git cleanup`\r\n`git cleanup` deletes any branches in your local that have been merged into the `master` or `develop` branches.  This is handy to run from time to time to purge unused local branches.\r\n\r\n```sh\r\ncleanup = "!git branch --merged | grep  -v '\\\\*\\\\|master\\\\|develop' | xargs -n 1 git branch -d"\r\n```\r\n\r\n## Hub\r\nIf you use Github, [hub](https://github.com/github/hub) is the perfect addition.  hub is a command line utility that allows awesome interaction with Github, like creating pull requests, forking, and interacting with remote branches almost as if they were local.\r\n\r\nFor a pro-tip, alias `hub` to the `git` command:\r\n\r\n```shell\r\neval "$(hub alias -s)"\r\n```\r\n\r\nI hope these tips are helpful -- if you learned anything, or have any comments, please post below! I'm happy to add more or follow up.	Awesome Git Configuration, Shortcuts, and Aliases	t	2014-09-16 04:58:00	2015-02-16 18:54:15.814513	1	awesome-git-configuration-shortcuts-and-aliases	\N
4	Here's a quick helpful template that we've refined through our work at Boombotix and OneLogin: [a short pull-request template](https://gist.github.com/Lordnibbler/11002759) that can be used to inform team members of the status and scope of a particular feature branch.\r\n\r\n[Click here for the template](https://gist.github.com/Lordnibbler/11002759)\r\n\r\n<!--more-->\r\n\r\n<script src="https://gist.github.com/Lordnibbler/11002759.js"></script>	Github Pull Request Template for Gitflow	t	2014-07-14 17:45:00	2015-03-03 05:42:00	1	github-pull-request-template-for-gitflow	\N
12	Hey there,\r\n\r\nSo this is a new film I just completed as a final project before graduation.  Please feel free to leave comments here, or on the [YouTube page](http://www.youtube.com/watch?v=f-jIUtDu8Fk).\r\n\r\n<strong><span style="color: #ff0000;">*BE SURE TO WATCH IN HD*</span></strong>\r\n\r\n<iframe width="560" height="315" src="https://www.youtube.com/embed/f-jIUtDu8Fk" frameborder="0" allowfullscreen></iframe>	Sports Car Documentary - Lotus Exige S, Porsche Carrera, Corvette C6	t	2010-07-25 07:00:00	2015-02-13 06:24:05.616244	1	sports-car-documentary-lotus-exige-s-porsche-carrera-corvette-c6	\N
7	## Update!\r\nRead this first, and if you want more I've posted [an update to this blog here](http://benradler.com/blog/2015/08/06/updated-diy-led-lights-with-node-and-backbone).\r\n\r\n\r\n## Video Demo\r\n<iframe width="560" height="315" src="https://www.youtube.com/embed/92aIxuRP2jo" frameborder="0" allowfullscreen></iframe>\r\n\r\n\r\n## Backstory\r\nMy roommate works for Apple, and travels to China for work. He brought back a spool of LED lights, and hacked together a script for an Arduino that played a series of 12 lights on repeat.\r\n\r\n<!--more-->\r\n\r\nWe then installed the lights in the ceiling in the upstairs of our apartment in San Francisco.  It looked like this:\r\n\r\n![LED Lights installed in home ceiling](https://farm6.staticflickr.com/5338/8797261023_30e23e2e53_b_d.jpg)\r\n\r\n## Criteria for Success\r\n\r\nWe decided we wanted to create a simple UI that could be used to pick colors.  Our criteria for success were as follows:\r\n\r\n* set all banks of light a single color \r\n* set colors individually on each bank of lights\r\n* save color choices and be able to bring them back up\r\n* same UI usable on desktop, tablet, and smartphone\r\n\r\n## The UI\r\n\r\nFor the UI, I decided to base the design off of the awesome [Color by hailpixel](http://color.hailpixel.com/). This brilliant colorpicker interface allows you to adjust color on 3 axes: \r\n\r\n* X axis: **hue**\r\n* Y axis: **lightness**\r\n* Z axis (scrolling): **saturation**\r\n\r\nClicking allows the user to save a color into a "bank". The color can also be adjusted after the fact. Each saved color gets added to the URL as its respective hex code.\r\n\r\n## Architecture\r\n\r\nThere are two Node.js applications, a client and a server.\r\n\r\n###[`colorpicker-server`](https://github.com/Lordnibbler/colorpicker-server) \r\nContains the Backbone application, and runs on a simple Node.js web host like Nodejitsu or Heroku.  \r\n\r\n#### Frontend\r\nThe frontend of the app uses [Backbone.js](http://backbonejs.org/) for simple client-side MVC. It connects to the backend [Node.js](http://nodejs.org) server using [socket.io](http://socket.io). I'll cover the details of my changes to the Color by Hailpixel backbone application below:\r\n\r\nThe entry point for the Backbone application is [`main.js`](https://github.com/Lordnibbler/colorpicker-server/blob/master/public/scripts/main.js), and connects to the socket on the Node.js side of the application with a simple `io.connect('http://some-server.com/some-socket-name);`.  It is **critical** that your server string contain a socket name.  For instance, in our app, we chose to have two socket names, `backbone` and `beaglebone`. These socket names make it easy for our Node.js server (the backend of this application) to easily distinguish messages from the `backbone` app or the `beaglebone` client.  \r\n\r\nWe also save the `socket` and `dapp` backbone app under the `window` namespace so we can reference them elsewhere in the application.\r\n\r\nIn our `views/app.js` backbone view, we define a `colorChanged()` function which emits a `'colorChanged'` event over the socket to the `colorpicker-client` application.   The value for the `'colorChanged'` event is an RGB string of the currently selected color.  \r\n\r\n```js\r\ncolorChanged: function(color) {\r\n  window.socket.emit('colorChanged', {\r\n    color: this.colorToRgbString(color)\r\n  });\r\n}\r\n```\r\n\r\nIn the `router.js`, we add define a `colorSet()` function which emits a `'colorSet'` event over the socket to the `colorpicker-client` application.  The value for the `'colorSet'` is a string of RGB color codes for each `color` record in the `app.Colors` collection.\r\n\r\n```js\r\ncolorSet: function() {\r\n  if(window.socket) {\r\n    window.socket.emit('colorSet', {\r\n      color: this.colorsToRgbString()\r\n    });\r\n  }\r\n}\r\n```\r\n\r\nThe `colorsToRgbString()` functions are pretty straightforward, and simply grabs each color's RGB value, and creates a `'r,g,b,a\\n'` formatted string:\r\n\r\n```js\r\n/**\r\n * Converts colors to Halo's `r,g,b,a\\n` format\r\n */\r\ncolorsToRgbString: function() {\r\n  var rgbColors = "";\r\n  app.Colors.each(function(color){\r\n    rgbColors += color.rgb().r + ',' + color.rgb().g + ',' + color.rgb().b + ',' + color.rgb().a + '\\n';\r\n  });\r\n  return rgbColors;\r\n}\r\n```\r\n\r\n\r\n#### Backend\r\n\r\nWe start up a socket.io socket, and an anonymous function is passed as the startup callback.  \r\n\r\nInside this function, we bind to the `connection` event of two sockets, `/backbone` `/beaglebone`.  `/backbone` represents the front end of this application, the backbone app. `/beaglebone` represents a client Node.js application running on our beaglebone computer.  \r\n\r\nAn anonymous callback function is pased to the `connection` event of the `/backbone` socket. This function pushes the connected socket into the `backbones` array so we can keep track of it in the future. \r\n\r\nWe also listen for `colorChanged` and `colorSet` events from the connected backbone applications. If either of these events are fired, we pass the color data along to each of the connected `beagle` socket.io clients.\r\n\r\n```coffee\r\n# when backbone.js Client runs `io.connect('http://localhost:1337/backbone')`\r\nsio.of('/backbone').on('connection', (socket) ->\r\n  logger.info "/backbone CLIENT CONNECTED"\r\n  backbones.push socket\r\n\r\n  ######################################\r\n  # colorChanged and colorSet both\r\n  # writeColorDataToFile in our\r\n  # beaglebone client node app.\r\n  # backbone.js takes care of sending\r\n  # all 4x 1 color, or 1x 4 colors\r\n  ######################################\r\n\r\n  # when Client is live-previewing color\r\n  socket.on 'colorChanged', (data) ->\r\n    # send colorChanged data to all beagles\r\n    # logger.info "emitting colorChanged to #{beagles.length} beagles"\r\n    beagle.emit('colorChanged', { color: data.color }) for beagle in beagles # where beagle is connected\r\n\r\n  # when Client picks a new color\r\n  socket.on 'colorSet', (data) ->\r\n    # send colorSet data to all beagles\r\n    beagle.emit('colorSet', { color: data.color }) for beagle in beagles\r\n)\r\n```\r\n\r\nAn anonymous callback function is pased to the `connection` event of the `/beaglebone` socket as well. This function pushes the connected socket into the `beagles` array so we can keep track of it in the future. \r\n\r\nWe also listen for the `disconnect` event from the connected beaglebone applications. If this event is fired, we remove the appropriate `beagle` socket from the `beagles` array.\r\n\r\n```coffee\r\n# when beaglebone Client runs `io.connect('http://localhost:1337/beaglebone')`\r\n# push them into the beagles array\r\nsio.of('/beaglebone').on('connection', (socket) ->\r\n  logger.info "/beaglebone CLIENT CONNECTED"\r\n  beagles.push socket\r\n\r\n  # remove beaglebone client from beagles array\r\n  # if disconnection event occurs\r\n  socket.on('disconnect', (socket) ->\r\n    logger.info "/beaglebone CLIENT DISCONNECTED"\r\n    beagles.pop socket\r\n  )\r\n)\r\n```\r\n \r\n\r\n###[`colorpicker-client`](https://github.com/Lordnibbler/colorpicker-beaglebone)\r\nA small Node.js client which receives socket.io `colorChanged` events, and writes the results to disk. \r\n\r\nThis application serves one specific purpose: receive `colorChanged` or `colorSet` events sent from our Node.js server, and write them to disk. Our PERL script on the beaglebone will read this file and send it to the Arduino which will ultimately be sent to the lights via UART.\r\n\r\nThe only trickery here is the `w+` mode of our `writeStream`. From the Node.js documentation of `createWriteStream()`, the `w+` mode will:\r\n\r\n>Open file for reading and writing. The file is created (if it does not exist) or truncated (if it exists)\r\n\r\nHere is the important code for this client application:\r\n\r\n```coffee\r\nsocket.on "connect", ->\r\n  console.log "socket connected"\r\n\r\n# write our preformatted backbone.js\r\n# color data to colors.txt\r\nsocket.on "colorChanged", @_write_colors_data_to_file\r\nsocket.on "colorSet",     @_write_colors_data_to_file\r\n\r\n_write_colors_data_to_file: (data) ->\r\nlogger.debug JSON.stringify(data, null, 2)\r\n\r\nws = FS.createWriteStream("#{__dirname}/../colors.txt", {\r\n  flags: "w+"\r\n})\r\nws.write(data.color, (err, written) ->\r\n  if err\r\n    throw err\r\n  ws.end()\r\n)\r\n```\r\n\r\n### [`halo.pl`](https://github.com/Lordnibbler/halo)\r\n**WARNING**: this PERL script is more unpolished than the Node.js applications, and has residual "dead code" from previous prototypes of the lighting system.  *Use at your own risk*\r\n\r\nThe entry point for the `Halo_Master.pl` PERL script is the `while` loop on line `388`.  This ultimately calls the `grabLiveData()` subroutine.\r\n\r\n`grabLiveData()` is in charge of reading the `PREVIEW_DATA` RGB color data in the `colors.txt` file generated by the `colorpicker-client` application. It builds a `$rgb` array based on the `PREVIEW_DATA`, which is ultimately sent to the Arduino via the `sendColor()` subroutine:\r\n\r\n```perl\r\nsub sendColor {\r\n  my($address,$r,$g,$b,$v)= @_;\r\n  $address = $address + 1;\r\n  print SERIAL "4,$address,$r,$g,$b,$v;";\r\n}\r\n```\r\n\r\n### [Arduino Translation Code](https://github.com/Lordnibbler/halo_arduino_translation_code)\r\n\r\nThe Arduino Uno board acts as a UART to I2C interface. \r\nThe two arduino libraries used here are Wire and CmdMessenger.\r\n\r\n[CmdMessenger](http://playground.arduino.cc/Code/CmdMessenger) acts as the UART interpreter. We set up 4 different commands, but for our application, we only use the `change_color` command.\r\n\r\n```c\r\nmessengerCallbackFunction messengerCallbacks[] = \r\n{\r\n  change_color,            // 004 in this example\r\n  read_light_color,\r\n  check_status,\r\n  change_all,\r\n  NULL\r\n};\r\n```\r\n\r\n`change_color()` then parses the remaining parameters which are read as `uint8`: Channel, Red, Green, Blue, Violet.\r\n\r\nThese are then sent out over the I2C bus using the [Wire](http://arduino.cc/en/reference/wire)\r\n\r\n```c\r\nuint8_t setColor(uint8_t address,uint8_t red,uint8_t green, uint8_t blue,uint8_t violet){\r\n  char status;\r\n  \r\n  messageBuf[0] = 0xaf; //Command byte. 0xAF is change color\r\n  messageBuf[1] = red ;             \r\n  messageBuf[2] = green ;    \r\n  messageBuf[3] = blue ;\r\n  messageBuf[4] = violet;\r\n  messageBuf[5] = checksum((unsigned char*)messageBuf,5); //Checksum for checking reliable transmission\r\n  \r\n \r\n  Wire.beginTransmission(address); // transmit to device #4\r\n  Wire.write((uint8_t*)messageBuf,6);\r\n  status = Wire.endTransmission();    // stop transmitting\r\n  if(status != 0){\r\n    return 0; \r\n  }\r\n\r\n  return 1;\r\n}\r\n```\r\n\r\n\r\n### [Light Strip Code](https://github.com/Lordnibbler/halo_slave_strips)\r\n\r\nEach light controller consists of an `ATTiny2113`. I chose this particular uController since it features an I2C capable serial interface, and 3 8-bit PWM blocks. Each PWM output is connected to an N-MOS transistor which pulls each LED String to ground. This way, we're able to control the brightness of each LED color(Red, Green, Blue) by just changing the PWM Duty Cycle. \r\n\r\nIn the current implementation, the I2C address is set by DIP switches on the controller board.\r\n\r\nThe code on each light controller initializes the PWM timers and the I2C driver, then goes into a loop awaiting I2C commands.\r\n\r\nOnly 2 commands are interpreted right now...I chose these command numbers just for ease of reading them on the oscilloscope :-):\r\n\r\n```c\r\n0XAF - Change Color\r\nChanges the PWM value of each LED Color\r\n    \r\n0xAE - Color Status\r\nResponds with current Red,Green,Blue values\r\n```	DIY Philips-Hue-Style LED Lights with Node.js + Backbone!	t	2014-05-10 07:28:00	2022-01-02 03:19:24.345234	1	diy-philips-hue-style-led-lights-with-node-js-backbone	
19	# Toolbox\r\n\r\nAll skilled professionals have a "toolbox", right? An electrician might have a multimeter, screwdrivers, and a hammer. A painter might have brushes, pallets, paints. An engineer is no different, except that their toolbox is often entirely digital.\r\n\r\nIn all cases, _tools_ help you to be more **PRODUCTIVE**, **FASTER**, and **MORE ACCURATE** in your every day work.\r\n\r\nMy developer toolbox is a set of customizations, tools, and applications that augment and improve the operating system and computer I use. I'll specifically cover changes and tools I use that help with developing computer software and websites.\r\n\r\n<!--more-->\r\n\r\n## Iterate and Improve!\r\n\r\nI revisit this set of steps often, sometimes multiple times each week.\r\n\r\n1. Identify a process that is slow, that I find myself repeating often, or can be automated\r\n1. Find or build a tool that might improve this problem (we're coders right? ...a resourceful bunch)\r\n1. MEASURE whether this change actually saves me time\r\n1. This is the important part: *if you don't use it, or it makes you slower, GET RID OF IT*\r\n1. Repeat\r\n\r\n## My Toolbox\r\n\r\nAt a high level, my toolbox consists of the following:\r\n\r\n* Version-controlled Dotfiles\r\n* Customized Terminal\r\n* Customized Text Editor\r\n* Ancillary Applications\r\n\r\nI'll cover them all in some amount of detail here, and would be happy to delve deeper into each of them in a future blog post. So if you find anything particularly interesting, please comment below and let me know what you'd like to know more about!\r\n\r\n## Dotfiles\r\n\r\n[My dotfiles](https://github.com/lordnibbler/dotfiles) are a collection of (often invisible) configuration files that are tracked by git version control on github.\r\n\r\n> If you aren't using git already, I suggested reading [Git From The Bottom Up](https://jwiegley.github.io/git-from-the-bottom-up/) immediately.\r\n\r\nThese dotfiles are a constant WIP (work-in-progress), meaning I tweak and alter them as I follow my iteration process I outlined above. These dotfiles configure `git` itself, my shell, linters for my editor, command line tools like `pry` and `curl`, and more.  They normally live in invisible files or directories in my home directory `~/.*`.\r\n\r\nSince I track these files on github, I am able to quickly and easily sychronize them between my work and home computers, and have them saved in case of disaster. I do the same for my editor configuration, which I will get into in a later section.\r\n\r\n[My dotfiles](https://github.com/lordnibbler/dotfiles) are designed to be forked, and customized with your own dotfile changes so you can synchronize them as well!\r\n\r\nI have a [simple install script](https://github.com/Lordnibbler/dotfiles/blob/master/.install.sh) which symlinks all of my dotfiles and directories into my home directory, prompting to overwrite any existing files. I use  the following simple approach:\r\n\r\n```sh\r\nln -sin "${CWD}/${BASE}" "${HOME}/.${BASE}"\r\n```\r\n\r\nI use the `-sin` flags:\r\n\r\n* `-s` creates symbolic links, meaning my actual git-tracked dotfiles can live elsewhere than my home directory\r\n* `-i` uses interactive mode, prompting whether or not to overwrite files that already exist in the destination (awesome!)\r\n* `-n` so any source file is treated like a "file" rather than a directory\r\n\r\nThe installer script also omits symlinking the install script itself, and the readme (duh).\r\n\r\n## Customized Terminal\r\n\r\nOut of the box, most *nix operating systems, macOS included, ship with Bash, the bourne-again shell. This is a wonderful piece of software and a command-line language written by Brian Fox for GNU, and has been the de-facto standard since around the time I was born.\r\n\r\nHowever, nowadays Bash is starting to show some gray hairs, and after customizing bash and zsh to hell and back, I've settled on using Fish.  [Fish, the "*F*riendly *I*nteractive *Sh*ell"](http://fishshell.com/), is a shell for the modern developer. Not only is it actively maintained, it has a ton of arguably-more-useful features than ZSH, is bash compatible, has developers in mind, and is super easy to customize.\r\n\r\nHere's an example of my customized [Fish](http://fishshell.com/) prompt. It features a ton of at-a-glance information, such as an abbreviated `pwd`, my current git branch and sha, my local versions of Ruby and Node, and more!\r\n\r\n![customized fish prompt](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBEUT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--60c213b81e048268e01072d495739a5597bb5391/753cd64a-3592-11e6-8e20-3057cad261af.png)\r\n\r\nFurthermore, my prompt shows me whether or not I have elevated (`su`) permissions by coloring the `$` differently.\r\n\r\n![customized fish prompt](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBEZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--1f230be5175a36aaa5e64d9fbf10375aa513a93d/897db796-3592-11e6-97e4-dcb4c7159ca0.png)\r\n\r\nI'll cover a few of the notable [Fish](http://fishshell.com/) features, but there are TONS more and I truly suggest you take a look at <https://fishshell.com/> if you have even the slightest amount of interest :)\r\n\r\n1. Works out of the box\r\n\r\n    I mean really, most of the coolest features "just work"\r\n\r\n1. Sane Scripting\r\n    How many times have you had to Google/StackOverflow and hack crazy bash scripts just to customize your prompt? Fish has its own scripting language. I know this sounds super annoying at first...\r\n\r\n    > OH GLOB YET ANOTHER LANGUAGE TO LEARN\r\n\r\n    But think about it -- it's more Ruby-like than Bash-like, and if you have half a brain about your, it'll literally take you less time to make sense of Fish scripting than it took you to read this far into this blog post.\r\n\r\n1. Autosuggestions (automatic interactive history search)\r\n\r\n    I don't know why Fish has branded such a *terribly-difficult-to-memorize* name for this feature (maybe because us developers are not the best marketers), so let's just call it *"Autosuggestions"*. Basically, Fish does two awesome things when it comes to autocompleting your terminal commands:\r\n\r\n    1. Firstly, it automatically generates completions to your typing based on `man` pages! So not only does it know about all of the binaries in your `$PATH`, it can also intelligently suggest complex combinations of flags to pass to each binary!\r\n\r\n    2. Secondly, there is no `^B^R` reverse history search. Fish searches your history *EVERY TIME YOU TYPE*, and intelligently orders its suggestions based on the frequency that you select a result! You can select an entire result by pressing the left arrow key, or select bits and pieces of it by pressing `alt + arrow`.\r\n\r\n1. Web-based configuration tool\r\n\r\n    This is a super helpful tool to quickly see what your Fish  configuration looks like in a GUI. All you have to do is type `fish_config` and it will launch your browser of choice.\r\n\r\nSo, when I give this talk, or talk about Fish to coworkers and friends, they all generally have the same response: **"WHY ON GODS GREEN EARTH WOULD YOU REPLACE BASH!!??!?!1?shift1"**\r\n\r\nWell, I believe that modern developers still spend a large portion of their day in a terminal, so why not use a shell that was designed with the modern developer in mind? The languages and frameworks we use daily have progressed tremendously since their inception, so why shouldn't your shell?\r\n\r\nAdditionally, customization of your shell shouldn't have to be this unapproachable mess that requires installation of massive combinations of scripts like `oh-my-zsh`. Fish's unique scripting language mixes a familiar `bash` and `zsh` experience with powerful new features.\r\n\r\n## Customized Editor\r\nI'll be honest: I've bounced around a lot on this topic. From Sublime Text to Jetbrains IDEs, to VIM. What I've landed on is GitHub's editor, [Atom](https://atom.io/). But, as I'm sure you've guessed by now, I don't just use Atom out-of-the-box.  Oh noooo, I customize it!\r\n\r\nAtom is awesome. It is backed by a huge community, including great debugging help, and most importantly, a MASSIVE library of open-source plugins.  It's written in [Electron](https://github.com/electron/electron), allowing to to be simultaneously developed in the oh-so-familar JavaScript, HTML, and CSS, and deployed cross-platform to Linux, macOS, and Windows. As a result, it is well-maintained and supported, and is infinitely customizable. In fact, if you want to customize any component of the UI, you can just press `cmd + alt + i` and see the familiar webkit developer tools! Literally the entire app is a big web app!\r\n\r\nI find it is the perfect blend of "IDE" power, and speed & customization of a lightweight editor.\r\n\r\nI'll write a future blog post that covers my Atom customization in its entirety. I have one post covering [how to set up ctags](http://benradler.com/blog/2016/06/09/how-to-set-up-ctags-go-to-definition-in-atom-text-editor), allowing you to quickly and accurately "go to definition" -- [read that here](http://benradler.com/blog/2016/06/09/how-to-set-up-ctags-go-to-definition-in-atom-text-editor). Additionally, a few good packages to look into are `autocomplete-plus`, a linter for your commonly used languages, `vim-mode` or `vim-mode-plus`, `Open on GitHub`, `Markdown Preview`, `Beautify`, and most importantly, `Synchronize Settings`.\r\n\r\nThere are two important packages worth talking about in detail here.\r\n\r\n* First, [`Sync Settings`](https://github.com/atom-community/sync-settings), which lets you "back up" and sync your entire Atom configuration between machines. It is a bit primitive in the way it does this: it uses a secret GitHub Gist, although I still question the security behind this as some packages put "secrets" into their settings, which are then stored here.\r\n\r\n* Second, [`vim-mode`](https://github.com/atom/vim-mode). This is an important choice -- I've decided against using plain old VIM, and instead leverage all of the awesome modal control of VIM, with the customization and 21-st-certury-ness of Atom. So think of it like a customized version of Sublime Text, with all the power of VIM!\r\n\r\n## Ancillary Tools\r\n\r\nThese are tools that are not your editor, not your terminal, but are tremendously helpful in cutting down on repetitive tasks, or freeing up your brain for more important information.\r\n\r\nLet's be realistic here, as much as we'd like to, we cannot do EVERYTHING in the terminal. Imagine if we kept browsing the web in there! React.js would seem pretty dumb now wouldn't it?\r\n\r\nI've mentioned a few:\r\n\r\n* [1Password](https://1password.com/)\r\n\r\n    This is the most awesome "memory" manager I've found. I say memory manager because it allows me to store not just passwords to my accounts on web apps, but much more, including credit cards, software licenses, membership information, etc.  Even better, it lets me sync all of this to a cloud service like Dropbox or iCloud, and access it on all of my devices.\r\n\r\n    1Password is rooted in *GOOD CRYPTOGRAPHIC PRACTICES*, and while it's a bit steep in price for the pro version, it offers a ton of functionality for free as well.\r\n\r\n* [Alfred](https://www.alfredapp.com)\r\n\r\n    This might look like Spotlight, but it is NOT. Manage clipboard history, traverse the filesystem, search the web, define your own custom macros, and more! This is a productivity tool like nothing else, and is infinitely customizable.\r\n\r\n    I often use this to quickly look up documentation in Dash, or jump straight to stories I'm working on at work. Imagine, instead of opening your browser, going to Jira, searching for your ticket in the kanban, clicking it and then clicking through to details, you can simply press `^space jira <ticket number>`!\r\n\r\n* [Dash](https://kapeli.com/dash)\r\n\r\n    Dash is a native documentation manager that downloads and keeps up-to-date documentation for programming languages and frameworks alike. Think of it as documentation and man-pages just a keystroke away.\r\n\r\n    I connect this app up with Alfred and Atom, allowing me to quickly jump to documentation pages for a glance -- think `^c -> dash activesupport::inflector` to get taken straight to the Rails docs!\r\n\r\n* [Kaleidoscope](http://www.kaleidoscopeapp.com)\r\n\r\n    I use this as a GUI for Git. It's quick and easy to set up as your `difftool` and `mergetool`, allowing you to visually resolve merge conflicts, and see changes between commits. It also allows "diffing" images, and many other file types.\r\n\r\n* [SizeUp](http://www.irradiatedsoftware.com/sizeup/)\r\n\r\n    Because, well, to hell with mouse-based window management. Quickly split, move, and center windows in any app!\r\n\r\n## Summary\r\n\r\nThanks for hanging on this long! I hope you learned about something new.\r\n\r\nSince I could probably write an entire post this length about each piece of software, please comment below and let me know what you'd like to learn more about. I'm happy to share the way I configure Atom, more about my customizations to Fish, or other software I use day to day.\r\n\r\nThanks for reading!\r\n	Environment Customization: My Developer Toolbox	t	2016-06-23 06:12:00	2021-12-31 00:21:58.412858	1	environment-customization-my-developer-toolbox	All skilled professionals have a "toolbox", right?
13	I wanted to write a post about my good friend's recent experience with [OWC (Other World Computing)](http://www.macsales.com), as they are one of the oldest Mac-authorized resellers, and I've usually heard good things about doing business with them. My most recent experience has significantly swayed my views.\r\n\r\nTheir offers for the 21.5" and 27" iMacs are quite intriguing.  You can either buy from them, or ship an already-purchased system to them, and they offer a whole host of upgrades that Apple does not.  For example, OWC will [add an eSATA port](http://eshop.macsales.com/shop/turnkey/iMac_2010_27/eSATA_SSD) for $169, or [add/replace internal hard drives with Solid State Drives (SSDs)](http://eshop.macsales.com/shop/turnkey/iMac_2010_27/eSATA_SSD).  They'll even add an internal Blu Ray disc player!  And all at costs less than Apple charges (easy to do).  But that's where the fun ended (at least for us).  \r\n\r\n<!--more-->\r\n\r\nThese sort of upgrades are a bit intimidating for normal users, especially considering that in order to add an SSD or another hard drive, [the entire machine has to be disassembled](http://www.ifixit.com/Teardown/iMac-Intel-27-Inch-Teardown/1236/1). The glass cover that sits atop the screen has to be removed with industrial-strength suction cups, and handled with extreme care in order to keep dust and fingerprints off. I've personally performed this procedure on my own iMacs in the past, and it's not particularly fun.\r\n\r\nThese offers from OWC sounded wonderful since I wasn't looking forward to taking apart another iMac any time soon...so my buddy went ahead and purchased a 27" iMac, and had it drop-shipped to OWC to have a larger internal drive and an SSD added, as well as the eSATA port.\r\n\r\nTo make a long story short, the system shipped out DIRECTLY from Apple to OWC on September 16th, arrived at OWC on the 17th, and shipped back from OWC to us in San Francisco on the 17th as well!  WOW!  Unfortunately, even though two-day shipping was requested, the system didn't arrive back in our hands until the 24th.  Brutal, especially considering we were essentially computer-less for a whole week, and had several projects that needed to be completed before the 24th (not necessarily OWC's fault).\r\n\r\nSo the machine arrives and we are initially (semi) delighted with the job, except for the fact that the ESATA port looked like it was poorly cut into place with a dremel or equivalent tool. The quality of the port installation did not impress me, though it functioned as expected.\r\n\r\nAfter a day of using the machine, we noticed a dead pixel in the center of the screen. We immediately notified OWC tech support and spoke with Devin Predmore. He sent me a stuck-pixel repair application that supposedly would fix my problem. Installed the program, ran it several times, and did not fix the stuck pixels. \r\n\r\nDuring start up of my machine, we noticed what looked to be fingerprints on the glass of the screen. I took out the Apple-supplied screen cleaning cloth and tried to clean the "fingerprints" off of the screen. After looking at the display from different angles and in different light, I noticed that they were underneath the screen. There is no way that these fingerprints came from apple direct. Who ever disassembled my machine obviously did not handle my glass screen-cover with proper care, nor did they clean it thoroughly before reinstalling it.\r\n\r\nTo top everything off, I noticed a scratch beneath the surface of the screen in the bottom left corner, not obstructing the LCD but below. I also noticed a white dot stuck under the LCD on the top of the screen.\r\n\r\nTo be honest, we are still quite astonished that after spending over $1000 in upgrades, we received such sloppy and sub-par workmanship.  It seems that the OWC technicians were either in a huge hurry on this system, or do not take the proper precautions when performing iMac surgery.\r\n\r\nThe problems still exist, though the machine is going back to OWC (free shipping overnight both ways), and they are compensating us with a (minimal) $50 gift card.  Still not impressed.  Guess if you want something done right you have to it yourself...\r\n\r\nPics for clicks.\r\n\r\nThose are UNDER the glass!!!:\r\n![imac-owc-defects-007](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBHdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--c5c9547abda251ca49500052c0ed0c7e5d5b85de/e25f855c-b306-11e4-8401-f1dab2c41deb.jpg)\r\n\r\nStuck Pixels\r\n![imac-owc-defects-006](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBIQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--099a934695a642a4b11cc33c9e39f5c13d499bed/e25f4dc6-b306-11e4-8912-bbf5ff50d2dd.jpg)\r\n\r\nScratch on the Glass\r\n![imac-owc-defects-002](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBIUT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--9bf66ebdbe47d3624993adb369456918051d8462/59dbe932-b306-11e4-9cc5-ffff8c22dd03.jpg)\r\n\r\nScratch on the Glass\r\n![imac-owc-defects-003](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBIZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--84e7265ae6664f5d6e039956b439a74768776d29/5ab1c908-b306-11e4-8749-f6d5df479136.jpg)\r\n\r\n\r\nStuck Pixels\r\n![imac-owc-defects-004](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBIdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--bf674ef6f6d97bd6cf2ca2232c81db23349f5d15/5b4b1ea0-b306-11e4-8a9b-7b9024e27da1.jpg)\r\n\r\n![imac-owc-defects-005](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBJQT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--e73be96f242f98ed86e37b494b2590fa6972de4e/5c31f924-b306-11e4-82a6-7c4cc3dd112f.jpg)\r\n\r\n\r\nChip in the Glass\r\n![imac-owc-defects-001](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBJUT09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--1fbbf3b7905103c813eabd67131437b66337ac2e/576e5874-b306-11e4-8eda-fa4e49299f42.jpg)	Macsales.com 27" iMac SSD & eSATA Upgrade Nightmare - OWC (Other World Computing)	t	2010-10-19 07:00:00	2022-01-02 03:18:17.076036	1	macsales-com-27-imac-ssd-esata-upgrade-nightmare-owc-other-world-computing	
8	Recently at [OneLogin](http://onelogin.com) we decided to prune and purge all merged branches in one of our large Git repos.  Having never had to do this with more then a handful of branches, I had relied on the GitHub branches UI.\r\n\r\nThis UI is less than ideal when working with over about a dozen branches, so I started looking into scripts to help automate the process.\r\n\r\n<!--more-->\r\n\r\nThe best information I found was in this [StackOverflow question](http://stackoverflow.com/questions/6127328/how-can-i-delete-all-git-branches-which-are-already-merged).\r\n\r\nI'll cut right to it:\r\n\r\n### Delete branches not merged into currently checked out branch on LOCAL\r\n```sh\r\ngit branch --merged | grep -v "\\*" | xargs -n 1 git branch -d\r\n```\r\n\r\n\r\n### Prune your origin\r\n\r\n```sh\r\ngit remote prune origin\r\n```\r\n\r\n\r\n### Delete branches not merged into currently checked out branch on ORIGIN\r\n```sh\r\ngit branch -r --merged | grep -v master | sed 's/origin\\//:/' | xargs -n 1 git push origin\r\n```\r\n	How to delete merged branches on Git and GitHub	t	2014-04-26 07:04:00	2015-02-12 01:40:00	1	how-to-delete-merged-branches-on-git-and-github	
14	I still can't believe how many big-name websites neglect to use this wonderful bit of markup! Read this, and make it a habit. It's so easy!\r\n\r\nLet's say we're marking up a contact form where visitors enter a bit of personal information, such as their name, sex, and which products they're interested in. I'll keep this stupid simple: when you're creating this form, there is a proper place to put the `label` for each input element. It's called the **label element**. Be sure to use the `label` element's `for` property, that way the `label` knows which `input` element it refers to.\r\n\r\nThe reason for going through this trouble rather than just using a `<div>` or a `<span>` element, is because the browser knows that if a `<label>` element with a `for` property is clicked that the corresponding `input` element should receive focus. Having the label AND the input element clickable makes for a much larger target to click on, making the human/computer interaction target more usable.\r\n\r\n<!--more-->\r\n\r\nHere's an example, try clicking on the "Your Name" label and notice that the `<input>` will receive focus:\r\n<input id="name" type="text"/><label for="name">Your Name</label>\r\n\r\nSource HTML:\r\n```html\r\n<input id="name" type="text"/><label for="name">Your Name</label>\r\n```\r\n\r\nIn this example, try clicking on the text label next to any of the checkboxes, radio buttons, or text fields. You will see that the appropriate input element is focused!\r\n\r\n<fieldset style="border: 1px dashed #888; padding: 10px;">\r\n  <legend>Our Example Form</legend>\r\n  <form>\r\n    <div><input style="float:none;" id="name_1" type="text"><label for="name_1">Your Name </label></input></div>\r\n    <div><input style="float:none;" id="gender-male" type="radio" name="gender"><label style="display:inline;" for="gender-male">&nbsp;Male</label></input></div>\r\n    <div><input style="float:none;" id="gender-female" type="radio" name="gender"><label style="display:inline;" for="gender-female">&nbsp;Female</label></input></div>\r\n    <div><input style="float:none;" id="web-development" type="checkbox" name="services"><label style="display:inline;" for="web-development">&nbsp;Web Development</label></input></div>\r\n    <div><input style="float:none;" id="graphic-design" type="checkbox" name="services"><label style="display:inline;" for="graphic-design">&nbsp;Graphic Design</label></input></div>\r\n    <div><input style="float:none;" id="video-editing" type="checkbox" name="services"><label style="display:inline;" for="video-editing">&nbsp;Video Editing</label></input></div>\r\n    <div><input style="float:none;" id="logo-design" type="checkbox" name="services"><label style="display:inline;" for="logo-design">&nbsp;Logo Design</label></input></div>\r\n  </form>\r\n</fieldset>\r\nSource HTML:\r\n\r\n```html\r\n<fieldset style="border: 1px dashed #888; padding: 10px;">\r\n  <legend>Our Example Form</legend>\r\n  <form>\r\n    <input id="name" type="text"/>\r\n    <label for="name">Your Name </label>\r\n    <input id="gender-male" type="radio" name="gender" />\r\n    <label for="gender-male">&nbsp;Male</label>\r\n    <input id="gender-female" type="radio" name="gender" />\r\n    <label for="gender-female">&nbsp;Female</label>\r\n    <input id="web-development" type="checkbox" name="products" />\r\n    <label for="web-development">&nbsp;Web Development</label>\r\n    <input id="graphic-design" type="checkbox" name="products" />\r\n    <label for="graphic-design">&nbsp;Graphic Design</label>\r\n    <input id="video-editing" type="checkbox" name="products" />\r\n    <label for="video-editing">&nbsp;Video Editing</label>\r\n    <input id="logo-design" type="checkbox" name="products" />\r\n    <label for="logo-design">&nbsp;Logo Design</label>\r\n  </form>\r\n</fieldset>\r\n```\r\n\r\nHave you used this technique, or something similar to help improve usability on your websites?  Tell me about it in the comments!	How to Properly Use HTML Input Elements with Label Elements in Forms	t	2011-03-08 08:00:00	2015-02-13 06:56:00	1	how-to-properly-use-html-input-elements-with-label-elements-in-forms	\N
1	# This is a header!\r\n\r\nthis is some markdown\r\n\r\n* this is a list\r\n* and so is this\r\n  * and a sub list item\r\n  * and another\r\n    * even deeper! omg\r\n* and more list items\r\n\r\n**this is bold**\r\n\r\n*this is italics*\r\n\r\n> This is a blockquote\r\n\r\n```ruby\r\n# this is some ruby code\r\ndef foo(bar = 'baz')\r\n  puts bar\r\nend\r\n```\r\n[a fucking link](http://google.com)\r\n\r\n<!--more-->\r\ncontent after the excerpt\r\n\r\n![](https://cloud.githubusercontent.com/assets/199422/2813893/6260da36-ce9b-11e3-9e54-3c86cc1f4f47.jpg)	Example Post	f	2015-02-09 00:51:00	2015-02-10 02:25:00	1	example-post	\N
10	I recently relocated to San Francisco, and with the never-ending supply of [networking events](http://www.meetup.com/cities/us/94116/) I inevitably ran out of business cards and decided it was time for a new design.\r\n\r\nRather than writing a complex tutorial for how to create a print-ready wireframe for your cards, I thought I'd be nice and just give you the files. So, without further adieu, here's the Adobe Illustrator version of the wireframe I used:\r\n\r\n[Download Business Card Wireframe Templates](https://www.dropbox.com/s/nu4fojo10cjqjh5/business-card-wireframes.zip?dl=1)\r\n\r\nIf you use these templates, or they help you in any way, please comment below and let me know what you used them for!  Sharing is caring!	Adobe Illustrator Business Card Wireframe Template for Printing	t	2011-07-11 07:01:00	2015-02-13 06:15:00	1	business-cards-wireframe-template-for-printing	\N
6	In a recent set of Rails services I built, my team wanted to quickly deploy to Heroku for testing. We also keep a YARD documentation server running and up to date for every deploy.\r\n\r\nTurn out there is not a simple way to do this on Heroku, as you can only run one public-facing HTTP server per application.\r\n\r\n<!--more-->\r\n\r\nMy solution was to create a second heroku application\r\n\r\n```shell\r\ncd /path/to/your/repo\r\nheroku create repo-name-doc\r\ngit remote add docs git@heroku.com:repo-name-doc.git\r\n```\r\n\r\nI created a `Procfile.docs` placed it in the root of the project, and commited it to git:\r\n\r\n```sh\r\necho "web: yard server -p \\$PORT" > Procfile.docs\r\n```\r\n\r\nI then wrote a simple shell script, called `deploy.sh` (be sure to `chmod +x` it).\r\n\r\n```shell\r\n#! /bin/sh\r\n\r\n# copy documentation server Procfile to root\r\ncp Procfile.docs Procfile\r\n\r\n# add Procfile to Git\r\ngit add Procfile\r\ngit commit -m "Deploy documentation"\r\n\r\n# deploy documentation server\r\ngit push docs $(git rev-parse --abbrev-ref HEAD):master -f\r\n\r\n# roll back documentation commit\r\ngit reset head~1 --hard\r\n\r\n# push main app to heroku\r\ngit push heroku $(git rev-parse --abbrev-ref HEAD):master -f\r\n```\r\n\r\nWhat this does is simple: \r\n\r\n1. It copies the `Procfile.docs` to `Procfile`, as Heroku expects.  \r\n2. It commits this change with the message "Deploy documentation". \r\n3. It then deploys the YARD server to the `docs` remote.\r\n4. It then rolls back this commit, and pushes to the production remote, `heroku`.   \r\n\r\nTo invoke this script, simply run `sh deploy.sh`.  It runs on whatever your current branch is, so be careful!\r\n\r\nEnjoy.	Deploy Yard documentation server to Heroku	t	2014-05-27 18:40:00	2015-02-12 01:34:00	1	deploy-yard-documentation-server-to-heroku	\N
15	## The Accident\r\n\r\nOn November 17, 2014 at around 9:30AM, I was involved in a bicycle accident at the intersection of 3rd Street and Market Street in San Francisco. I was traveling northbound on Market Street at around 10 miles per hour as I entered the intersection on a solid green light.  \r\n\r\nThere was a man standing in the middle of market street, and at the very last moment, he stepped directly in front me.  I collided with him handlebars-to-chest, and immediately fell to my right side.  Despite over 20 years of bicycling, I went against my instinct and stiffened up and put my hand down to my side.  My hand and wrist broke much of my fall, and I put a hairline fracture in the scaphoid bone in my right wrist.  \r\n\r\n<!--more-->\r\n\r\nWithin a second or so, the man who I hit also fell on top of me. My leg was pressed up against the curb on the side of Market Street, and the full weight of the man fell against my femur.\r\n\r\nThe man stood up almost immediately, and mumbled something about "the cars man...", and then began to walk away at high speed. I could now recognize what had happened...a junkie had been walking around in the middle of Market Street, stepped in front of me in a daze, and caused me to crash.  As I stood up to chase the man, I first realized something was terribly wrong.  My leg felt somewhat numb, and I couldn't move it, much less put weight on it.\r\n\r\nLike a high school physics problem, I had concocted the perfect storm of leverage -- with my leg against the curb, and the man's weight striking the top edge of my leg, I received a very nasty proximal femur fracture to my right leg.\r\n\r\nWithin seconds passers by stopped to check on me.  "Are you ok?" they asked.  "Um, no", I replied. "I can't move my leg".  \r\n\r\nNext thing I knew, I was on a stretcher with brace around my neck, cops asking me a million questions.  The EMTs attempted to give me a morphine drip, but botched the needle insertion, causing me 3 days of ballooning in my arm.  I was then placed on a stretcher, wheeled into an ambulance, headed to San Francisco General Hospital.\r\n\r\n## The ER\r\nIn the emergency room, I was taken to see some doctors.  They assessed the situation:\r\n\r\n> Broken femur. Hematoma. You done fucked. Why were you biking on Market Street, that's so dangerous.  Time for X-Rays.\r\n\r\nI was then taken to a cold, metal table, and asked to flip over into all sorts of weird positions to get every image possible of my leg.  After many X-Rays, I was given the opportunity to make some calls.  I called my parents, my girlfriend Karen, and my neighbor/coworker Jake.  Jake was extremely stoked to hear that I'd be joining him in his quest to become a titanium monster.\r\n\r\nMy girlfriend Karen arrived, and stayed with me for the rest of the day. The nurses started giving me drugs: morphine, oxycodone, hydromorphone, percocet.  Little doses via an IV line, to see how I responded.  I became very nauseous as the reality of the situation began to set in, and the narcotics took effect.\r\n\r\nAfter a while, I started being introduced to orthopedic surgeons, who explained they will follow me throughout my stay at the ER and potentially the hospital.\r\n\r\nAfter assessing the break, they came back and explain that I will need to be admitted to the hospital, and that they will be installing an external fixator to stabilize the break overnight, and provide me with some pain relief. I have a bad break -- not a clean break, but a shard of bone has completely separated from the femur. I'll likely be in the hospital for a couple of days.\r\n\r\n![broken femur xray](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYjA9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--0563c64d175b8d8470697946ba5acc5d12e7ce55/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--17569ea42c0c12027706f87839aa6e60da59aae5/IMG_0541.JPG)\r\n\r\nHaving the fixator installed involved me being taken to a small operating room, having some anaesthetic injected into my lower leg, and using what appeared to be a craftsman power drill to literally drill a bolt through my leg WHILE I WAS AWAKE. I only barfed a little bit.\r\n\r\n![fixator installed into right leg](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYkU9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--78e90c8b1f4717a3d7d42da422a1a84eafd8b68a/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--17569ea42c0c12027706f87839aa6e60da59aae5/IMG_0318.JPG)\r\n\r\nI was checked on constantly, ensuring that I still had sensation in my limbs, and that my strength was good in the non-injured parts of my body.\r\n\r\n## The Hospital\r\nA few hours later I was admitted into San Francisco General Hospital.  My first roommate Danny was amusing.  He had many stories to tell about how much he sweats when he and his girlfriend do meth, and had many nutritional questions about microwaving hotdogs.\r\n\r\nI tried my best to sleep with the fixator in my leg, with a water-weight hanging off of it.  You know, it's really hard to sleep in hospitals -- lights are always on, machines are always beeping, there are needles in both of your arms, and nurses come in and out every 30 minutes to check on you or your roommate.\r\n\r\nThe view from my room:\r\n\r\n![view from san francisco general hospital bedroom](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYlE9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--e56347996d9d548797785e1f95a1079f6416080a/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--17569ea42c0c12027706f87839aa6e60da59aae5/IMG_0325.JPG)\r\n\r\n## Surgery #1: November 18\r\nThe next day I was taken in for my initial surgery.  I was informed that they would be using an intramedullary nail to repair the break.  This is essentially a long titanium rod that is drilled into the cavity in the center of the femur, and is fixed in place with a larger bolt into the neck of the femur, and two smaller screws just above the knee.\r\n\r\n![femur ap proximal xray](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYnM9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--f47c6f1c6a7e07c3644221a870441444a9924b25/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--17569ea42c0c12027706f87839aa6e60da59aae5/IMG_0452.JPG)\r\n\r\n![femur lateral distal xray]()\r\n\r\n![wrist xray]()\r\n\r\n\r\nI was told there would be three small cuts made.  One on my lower back, one on my inner thigh, and one on the right side of my leg near the knee.  Each of these would facilitate installation a piece of hardware.\r\n\r\nI signed my life away, permitting surgeons to use general anesthesia, and any means necessary to repair my injuries and keep me alive.  I remember talking briefly to the anesthesiologists and agreeing to a nerve block.  Next thing I knew, I was being escorted back up to my room as they were unable to secure an operating room for me.\r\n\r\nA few hours later, I was back downstairs at the operating room level of the hospital, ready to go.  I don't remember much, other than waking up in the recovery room.\r\n\r\n## Surgery #2 & Compartment Syndrome: November 18\r\nAs I was coming to from anesthesia, I remember surgeon Jeff MacLean coming to my side, and checking for sensation in my leg.  Despite still being only semi-conscious, I clearly remember being unable to feel my right leg from the waist down.  The surgeons explained to me that I have developed a somewhat rare complication known as "[**compartment syndrome**](http://en.wikipedia.org/wiki/Compartment_syndrome)", and that I will need emergency surgey immediately now to restore sensation to my leg.\r\n\r\nWhat likely happened was, due to the severity and location of the break, the shard of bone had inadvertently pinched the sciatic nerve, rendering my leg numb.\r\n\r\nI was rushed back into surgery, and a large cut was placed from my knee to my hip to alleviate swelling and unpinch the nerve. Many blood transfusions were needed, and the surgery took several hours.\r\n\r\nI'm very fortunate to have had such careful surgeons -- if compartment syndrome is not identified and dealt with immediately, often the only solution is to amputate the limb.\r\n\r\n## Waiting: November 19 - November 21\r\nIn order to keep the cut in my leg open, a [negative pressure wound vac](http://en.wikipedia.org/wiki/Negative-pressure_wound_therapy) was installed in my leg, and was wrapped in sterile material.  The wound vac is like a big surgical sponge that pumps fluid out from the wound, and increases blood flow.  My entire circulation system was damaged in the fall.\r\n\r\n![negative pressure wound vac](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYlU9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--1a3e717e71e22a697f75f646d96e70bf8f9d93a5/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--17569ea42c0c12027706f87839aa6e60da59aae5/IMG_0336.JPG)\r\n\r\nI spent several days waiting for a followup surgery where the surgeons would attempt to close the cut in my leg. This involved being completely bedridden, and receiving many additional blood transfusions, antibiotic IVs, and tons of painkillers.  Not fun.\r\n\r\nEach day, some sensation was restored in my leg.  At the present, I still have minor numbness on the top of my big toe.\r\n\r\nMy mother flew up from Los Angeles to take care of me as well.  I've got to say, having family around really gives you an edge in the hospital -- many of the nurses were wonderful, but some were abysmal and seemed to want to do as little work as possible.  I can understand this mentality in certain industries, but when peoples' lives are at risk its just shameful.  I was lucky to have a wonderful girlfriend and caring mother to prod some of the less-than-motivated hospital staff to do a better job, both with myself and my roommate.\r\n\r\n![me and my girlfriend karen](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYmc9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a18351a26883d6d061bb51dc166d1d9a92facb77/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--17569ea42c0c12027706f87839aa6e60da59aae5/IMG_0417.JPG)\r\n\r\n## Surgery #3: November 21\r\nOn November 21, I was taken for a wound cleaning and flush.  The surgeons were unable to close the wound, so I had to continue to wait.  They suggested that if the wound could not be closed next time around, the best option would be a skin graft.\r\n\r\n![me entering surgery number three](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYmM9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--56445035c2d354c05b5230d94552e050388cc708/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--17569ea42c0c12027706f87839aa6e60da59aae5/IMG_0346.JPG)\r\n![more surgery](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYkk9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--b1cab983832bba9cd4710f72f74b221e4adc1cfb/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--17569ea42c0c12027706f87839aa6e60da59aae5/IMG_0320.JPG)\r\n\r\n## Surgery #4: November 24\r\nThankfully, on November 24, the compartment wound was closed, and sewed shut with around 50 souchers.  \r\n\r\n![my leg stitched up](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYjg9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--1a242f279fb57d7c835e2594803eab994b7b6db7/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJVUU1SEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--066b60b05e6c14a723a5b2be51b04b594dbf38d3/IMG_0399.PNG)\r\n\r\n## Physical Therapy: November 24 - 25\r\nPhysical therapists at San Francisco General Hospital helped me to begin standing again.  The first few sessions I spent the entire time just trying to stand.  It's incredible how your body gets used to laying down all the time -- when trying to stand, I felt a huge rush of blood to my head, and was unable to maintain consciousness.  As a result, I had to ease into standing by simply sitting up a few minutes at a time.\r\n\r\nAfter a little while, I was able to sit and eat food, and gradually work my way to standing again.\r\n\r\nThe physical therapists informed me that I would not be discharged from the hospital until I was able to stand and walk on my own (with a walker), as well as maneuver up and down the stairs in the back of the hospital.  To make matters worse, my apartment was approximately 50 stairs to traverse, as I live on the fourth floor of the building, and there is no elevator.\r\n\r\n## Recovering at Home: November 29, 2014 - February 9, 2015\r\nFinally, on November 29, I was discharged and sent home. I made the treacherous journey up my stairs, and laid in my bed for several days.\r\n\r\nRecovering was a tedious process.  From convincing my insurance that I needed at-home care from a nurse, occupational therapist, and a physical therapist, to simply being able to get from my bedroom to the bathroom was challenging.\r\n\r\nMy physical therapist Joyce Glick was wonderful, and I cannot thank her enough for helping me to be religious about my exercises and regain my range of motion.\r\n\r\nI received an itemized invoice from the hospital, which is an amusing read:\r\n\r\n![my bill from san francisco general hospital](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBYnc9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a7913bd69860ecd5f7dfdfcd6a347df05fa665d1/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJU2xCSEJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--17569ea42c0c12027706f87839aa6e60da59aae5/IMG_0492.JPG)\r\n\r\nAt $5000/day, this is even more expensive than the $4000/month bus stop for rent on Craigslist, and is far and beyond the most expensive rent I've ever seen in the city.  Makes me wonder if a few years from now we'll be remarking on what a good deal it was :)  \r\n\r\n## Walking Again\r\nAs of February 9, 2015, I was given the OK to begin putting weight on my leg again.  Its a long process, but my outlook is good -- the surgeons say I will walk without a limp, and should recover fully.\r\n\r\nThe shard of bone that broke off will slowly make its way back towards the femur, and the gap will fill with blood and turn into new bone.  You can actually see the process happening if you look at the progression of X-Rays:\r\n\r\n![newer x rays of femur](https://d1846l7k3ov4bn.cloudfront.net/files/representations/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBY0E9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--3a87649272926ad7c6b2efbff2bb12f2336f74d5/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaDdCem9MWm05eWJXRjBTU0lJY0c1bkJqb0dSVlE2RkhKbGMybDZaVjkwYjE5c2FXMXBkRnNIYVFJQUJUQT0iLCJleHAiOm51bGwsInB1ciI6InZhcmlhdGlvbiJ9fQ==--e6c6c3c4524599978cc06e5b4fda76a7493ddb75/Screen%20Shot%202015-02-09%20at%2011.26.35%20PM.png)\r\n\r\nI've learned many things from this ordeal.  For one, I have a new apppreciation for walking, and for the sound of ambulance and fire truck sirens in the city.  For another, you are reminded who your good friends are -- the ones who go out of their way to come see you at your worst.  But most importantly, don't break your femur.\r\n	Where I've Been Since November 2014 (aka Breaking Your Femur 101)	t	2015-02-26 05:29:00	2022-08-20 08:34:00	1	where-i-ve-been-since-november-2014-aka-breaking-your-femur-101	
17	## Update!\r\n\r\nWhen I originally open sourced [Colorpicker](https://github.com/Lordnibbler/colorpicker-server), it was a beautiful MVP based on some really nasty legacy code.\r\n\r\nI haven't had the time to focus on this project extensively, but over the last year I've made [a lot of important improvements](https://github.com/Lordnibbler/colorpicker-server/pulls?q=is%3Apr+is%3Aclosed) and wanted to discuss them briefly in this forum.\r\n\r\nI still have several longer term goals for this project, such as eliminating the need for the Arduino entirely so that anyone can run the client on any computer (with an emphasis on low-memory and disk space cases for usage with a Raspberry Pi, Beaglebone, or other cheap computer).\r\n\r\nI'm going to cover six new features added, but there are many more improvements I've made that you can see more about [on Github](https://github.com/Lordnibbler/colorpicker-server/pulls?q=is%3Apr+is%3Aclosed).\r\n\r\n## Gratuitous Video Demo\r\n<iframe width="560" height="315" src="https://www.youtube.com/embed/92aIxuRP2jo" frameborder="0" allowfullscreen></iframe>\r\n\r\n&nbsp;\r\n\r\n<!--more-->\r\n\r\n## [Overhall Client](https://github.com/Lordnibbler/colorpicker-client/pull/2) and [Elimination of the `halo.pl` PERL script](https://github.com/Lordnibbler/colorpicker-server/pull/36)\r\n\r\nTo frame why this script existed in the first place, I want to explain a bit about the evolution of this project.  My roommate has skills more suited to hardware, and had built an initial implementation using just Arduino code.  In order to address the lights on the fly, he began building a web-based UI. This web-based UI worked in conjunction with a PERL script that converted color input in the browser into UART instructions.\r\n\r\nWhen I started building this colorpicker server/client, I inherited all of the source code, and tapping into the already-functional PERL script seemed to be the quickest approach to communicate with the Arduino via UART.\r\n\r\nAs I have developed the app more, I've desired more and more to eliminate the PERL artifact and move all business logic into pure Javascript. These pull requests demonstrate moving the entire application stack to Javascript, meaning that even my instructions to virtual devices in linux are now called via Node.  Cool.\r\n\r\nIf you want to see the gorey details, the two pull requests linked in the header of this subsection represent the work to move to full-stack Javascript.  The [meat of the change](https://github.com/Lordnibbler/colorpicker-client/pull/2/files#diff-af5bc8ffc766db934873618fe4c339deR54) here is actually quite simple. Instead of writing our color data to a text file, as the previous PERL script did, we now write our color instructions via UART at the `/dev/tty01` device on the client linux box.\r\n\r\n## Color Generators\r\n\r\nThese are two "nice to have" features, but are useful and cool nonetheless.  [The first](* https://github.com/Lordnibbler/colorpicker-server/pull/17) is a "Hue Complement" button.  This button requires you have saved at least 1 color into a bank.  It generate the bitwise complement to that color, and generate a "hue ramp" between the two colors. Make rainbows, yo!\r\n\r\n[The second](https://github.com/Lordnibbler/colorpicker-server/pull/18) is simple.  It turns all the lights white.  Epic `#fff` ambient lighting, yo!\r\n\r\n## [Saved Colors](https://github.com/Lordnibbler/colorpicker-server/pull/30)\r\n\r\nThis feature introduces the ability to save sets of colors into a Redis cache, and bring them up again in the future with a single click.  It required a lot of work across the stack, including building a UI to hide saved colors "behind" the main application window, as well as implementing APIs that wrap the server's interaction with Redis. You can see these APIs in the `/api/v1/colors` routes.\r\n\r\n## [Basic HTTP Authentication](https://github.com/Lordnibbler/colorpicker-server/pull/15)\r\n\r\nWith [this change](https://github.com/Lordnibbler/colorpicker-server/pull/15/files#diff-af5bc8ffc766db934873618fe4c339deR18), you can set environment variables containing a username and password, thusly protecting your precious colorpicker from joker neighbors who like to control your lights from the street below your apartment!\r\n\r\n## Test Suite + CI\r\n\r\nThis is self explanatory for the most part, but by god we've tested it! The server and client-side tests both use mocha + chai; the client-side tests use PhantomJS and Karma as a headless browser to test the Backbone.js app.\r\n\r\n* https://github.com/Lordnibbler/colorpicker-server/pull/16\r\n* https://github.com/Lordnibbler/colorpicker-server/pull/19\r\n\r\n## [Scheduler](https://github.com/Lordnibbler/colorpicker-server/pull/44)\r\n\r\nThis feature introduces a binary `/bin/scheduler` which can be executed by a background worker. It reads from [two environment variables](https://github.com/Lordnibbler/colorpicker-server/pull/44/files#diff-c2e5fa8016de7c1224d43730a5eb4ad1R42) to determine what time to turn the colorpicker on or off, if at all! This can be useful if, for instance, you want to have the colorpicker turn off at midnight and turn back on to a random saved color combination around sunset the next day.\r\n\r\n\r\n## More\r\nWant to know more about how to set up a colorpicker of your own? Have questions about the source code? Comment below and I'll answer!\r\n	Updated DIY LED Lights with Node.js and Backbone.js!	t	2015-08-06 07:41:00	2021-12-30 04:12:25.856438	1	updated-diy-led-lights-with-node-and-backbone	
20	I recently launched a new Rails app on Digital Ocean using Dokku. I wanted to pipe out my Rails log data to Loggly, and found the documentation on this to be pretty sparse.\r\n\r\nThis should capture the steps I took to set it up. These steps assume you have a working Digital Ocean droplet with Dokku 0.7.1 or newer, and Rails 5 (though it should work fine with other frameworks that can log to syslog).\r\n\r\n<!--more-->\r\n\r\n```sh\r\n# SSH into your dokku box\r\ndokku ssh\r\n\r\n# install the logspout dokku plugin\r\ndokku plugin:install https://github.com/michaelshobbs/dokku-logspout.git\r\n\r\n# For TLS:\r\ndokku logspout:server syslog+tls://logs-01.loggly.com:6514\r\n\r\n# For non-encrypted:\r\ndokku logspout:server syslog://logs-01.loggly.com:514\r\n\r\n# optionally install dokku-hostname\r\n# this sets the app name in loggly to your app, instead of docker container guids\r\ndokku plugin:install https://github.com/michaelshobbs/dokku-hostname.git dokku-hostname\r\n\r\n# start logspout\r\ndokku logspout:start\r\n\r\n# if you have any errors starting, check the docker logs for hints\r\ndocker logs logspout\r\n\r\n# rebuild your dokku containers\r\ndokku ps:rebuildall\r\n\r\n# see if the stream is working (hit a page in your rails app)\r\ndokku logspout:info\r\ndokku logspout:stream\r\n```\r\n\r\nGrab your customer token from Loggly at https://www.loggly.com/docs/customer-token-authentication-token/\r\n\r\nor \r\nhttps://MYUSERNAME.loggly.com/tokens\r\n\r\n```sh\r\n# edit your logspout environment variables\r\nvi /home/dokku/.logspout/ENV\r\n\r\n# add your loggly customer token, replacing the < ... > \r\nSYSLOG_STRUCTURED_DATA=<loggly customer token>@41058\r\n\r\n# restart logspout\r\ndokku logspout:stop; dokku logspout:start\r\n```\r\n\r\nIf all goes well, you should be able to hit a page in your Rails app and see the log data in Loggly live tail or dashboard.\r\n\r\nComment below if you have questions, comments, or problems setting it up yourself!	Set up Loggly and Dokku with Rails, Logspout, and Syslog	t	2017-03-21 02:39:00	2021-12-30 04:14:37.491804	1	set-up-loggly-and-dokku-with-rails-logspout-and-syslog	Let's explore an easy way to collect logs from a Rails app!
18	Have you ever wished github's awesome Atom text editor had better support for jumping straight to a class or method definition like Rubymine or Sublime Text? Me too! So, here's a short set of instructions how to get this functionality working on OS X!\r\n\r\n<!--more-->\r\n\r\nTo summarize what we're going to do:\r\n\r\n* Install exuberant ctags from homebrew\r\n* Install an `rbenv` plugin and a gem that automatically generates ctags for rubygems\r\n* Let `git` know that you want to include the `ctags` binary and your new hooks in all git tracked repos\r\n* Create a `ctags binary` that generates a tags file for each project, and a few `git` hooks to keep our tags files up to date\r\n* Ensure your git-tracked repos have the newly created hooks and `ctags` binary\r\n* Install a helper package in Atom called `autocomplete-ctags`\r\n* Profit!\r\n\r\n## Quick & Dirty\r\n\r\nMy good friend [Tyler Davis](https://github.com/tyguy) turned this entire post into an [awesome setup script](https://github.com/TyGuy/setup_ctags) if you'd like to avoid doing these steps manually!\r\n\r\n\r\n> note: if you’ve ever installed atom-ctags, remove it, and delete any `tags` or `.tags` files from your project repos, or you’re gonna have a bad time\r\n\r\n## Steps\r\n\r\n1. Install exuberant ctags\r\n\r\n    Open your terminal and type:\r\n\r\n    ```sh\r\n    brew install ctags\r\n    ```\r\n\r\n1. Install the `rbenv` plugin and `ctags` gem\r\n  * Visit https://github.com/tpope/rbenv-ctags and follow the installation instructions\r\n  * Visit https://github.com/tpope/gem-ctags and follow the installation instructions\r\n\r\n1. Configure your git template directory\r\n\r\n    ```sh\r\n    # create a git template directory in your home directory\r\n    mkdir -p ~/.git_template\r\n\r\n    # tell git you want to use this directory to copy "template" files into all new git repos\r\n    git config --global init.templatedir '~/.git_template'\r\n\r\n    # tell git you want to alias a command `git ctags`\r\n    git config --global alias.ctags '!.git/hooks/ctags'\r\n    ```\r\n\r\n1. Copy my `ctags` binary and `hooks` files\r\n\r\n    Download all of the hooks files and the `ctags` binary from here:\r\n\r\n    https://github.com/Lordnibbler/dotfiles/tree/master/git_template/hooks\r\n\r\n    And copy them into your git template directory (probably at `~/.git_template`). These hooks trigger a run of `git ctags` whenever you move between branches, commit, etc., so your tags file is always up to date!\r\n\r\n1. Add `git ctags` command to your `.gitconfig`\r\n\r\n    ```sh\r\n    # tell git you want to alias a command `git ctags`\r\n    git config --global alias.ctags '!.git/hooks/ctags'\r\n    ```\r\n\r\n1. Install the atom package\r\n\r\n    ```sh\r\n    apm install autocomplete-ctags\r\n    ```\r\n\r\n1. cd to a git-tracked project directory\r\n\r\n    ```sh\r\n    # run this command to copy your hooks and ctags binary to the repo\r\n    # don't worry, it won't blow away your commit history or do anything destructive!\r\n    git init\r\n\r\n    # to seed it once, just to prove it works\r\n    run `git ctags`\r\n    ```\r\n\r\n1. Ensure `symbols-view` package is enabled in Atom!\r\n1. Relaunch Atom once\r\n1. Profit by using the `go to definition` feature in Atom!\r\n\r\nQuestions? Comments? Problems? Improvements? Anything??? Comment below and tell me, and I'll do my best to help!\r\n	How to set up ctags (go to definition) in Atom text editor	t	2016-06-10 06:28:00	2021-12-30 04:17:38.809119	1	how-to-set-up-ctags-go-to-definition-in-atom-text-editor	Github's Atom text editor can have great support for jumping straight to definitions!
9	Ever gotten this pestering error when trying to throw something away in Mac OS X?  I even see this behavior persistent in OS X 10.9 Mavericks, the newest release.  I believe it has something to do with Finder's quicklook function.  While relaunching the Finder is always a solution, I wanted to present this terminal based solution as a faster alternative.\r\n\r\nSo, see this error?\r\n![rmrf-tutorial](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBJdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--43ad8cfb531cdfa9348e583b8268e2523b5dccbe/da6dbf1e-cd13-11e3-86c8-63dc135ff63b.png)\r\n\r\n<!--more-->\r\n\r\n\r\nAll you've gotta do is open up Terminal.app (click Spotlight menu at the top right of your screen and type in terminal: `sudo rm -rf /Path/to/the/thing`.\r\n\r\nBe warned that this will delete everything in the directory you specify, so make sure you really want to delete it!\r\n\r\n![rmrf-tutorial-2](https://d1846l7k3ov4bn.cloudfront.net/files/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBJZz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--963396020f2cc539e330c38fdb8e7787d082f6fc/24a7d830-cd14-11e3-8065-7b4c6fdf8f13.png)\r\n	Mac OS X Tutorial - How To Fix "The operation can’t be completed because the item “***” is in use." error	t	2014-04-24 07:27:00	2021-12-31 01:00:00	1	mac-os-x-tutorial-how-to-fix-the-operation-can-t-be-completed-because-the-item-is-in-use-error	
16	My [Dotfiles repo](https://github.com/Lordnibbler/dotfiles) contains a sensible set of vim, fish, zsh, git, and tmux configuration files that work well for my development workflow (thanks [mdp](https://github.com/mdp)!). \r\n\r\nThese are a wonderful way to keep track of the plethora of configuration files that you'll undoubtedly set up while working as a developer, and quickly install them on another machine.  Nothing like having your environments on your home and work boxes be the same!\r\n\r\n<!--more-->\r\n\r\nIf you want a nice baseline of configuration for your .zshrc, .vimrc, .gitconfig, .aliasrc, .tmux.conf, and many others, my dotfiles repo is a very quick setup that allows you to granularly pick exactly the files you want.\r\n\r\nI recommend forking my repo to your Github account, cloning to your home directory, and then running the install script.  \r\n\r\n```sh\r\ngit clone git@github.com:Lordnibbler/dotfiles.git ~/.dotfiles\r\n\r\n# follow the prompts\r\n~/.install.sh\r\n```\r\n\r\nFrom here, you can adjust the dotfiles to your liking, keep them up to date, and safely backed up on Github!	Sensible Development Dotfiles	t	2015-03-24 05:30:00	2022-01-02 05:20:00	1	development-dotfiles	
21	I just published a new blog post on the Lyft Engineering Blog. It is the final post in a series discussing how our engineering team scaled developer productivity through several tactical changes to our development workflow.\r\n\r\nMy post is the final post in the series, and discusses how my team, Test Platforms, built high value, rapid **Acceptance Tests**, which exercise critical business flows from various parts of the Lyft lines of business.\r\n\r\n[**Read my post here!**](https://eng.lyft.com/scaling-productivity-on-microservices-at-lyft-part-4-gating-deploys-with-automated-acceptance-4417e0ebc274)\r\n\r\nRead the entire series of posts here:\r\n\r\n* Part 1 [Scaling productivity on microservices at Lyft](https://eng.lyft.com/scaling-productivity-on-microservices-at-lyft-part-1-a2f5d9a77813)\r\n* Part 2: [Optimizing for fast local development](https://eng.lyft.com/scaling-productivity-on-microservices-at-lyft-part-2-optimizing-for-fast-local-development-9f27a98b47ee)\r\n* Part 3: [Extending our envoy mesh with staging overrides](https://eng.lyft.com/scaling-productivity-on-microservices-at-lyft-part-3-extending-our-envoy-mesh-with-staging-fdaafafca82f)\r\n* **Part 4: [Gating deploys with automated acceptance tests](https://eng.lyft.com/scaling-productivity-on-microservices-at-lyft-part-4-gating-deploys-with-automated-acceptance-4417e0ebc274) (my post)**	Lyft Engineering Blog Post - Scaling Productivity on Microservices	t	2022-02-02 18:21:00	2022-02-02 18:30:00	1	lyft-engineering-blog-post-scaling-productivity-on-microservices	Read about how my team at Lyft built rapid, high-value acceptance tests!
22	I published a new blog post on the Lyft Engineering Blog. It covers how and why our engineering team built an in-house load testing platform that runs in production! \r\n\r\nIt's called SimulatedRides, and it generates synthetic load to help Lyft scale to its busiest days of the year.\r\n\r\n\r\n[**Read my post here!**](https://eng.lyft.com/simulatedrides-how-lyft-uses-load-testing-to-ensure-reliable-service-during-peak-events-644dcb654454)\r\n	Lyft Engineering Blog Post - Lyft Load Testing	t	2024-02-06 06:40:00	2024-02-06 06:44:11.889075	1	lyft-engineering-blog-post-lyft-load-testing	SimulatedRides: How Lyft uses load testing to ensure reliable service during peak events
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (version) FROM stdin;
20150205045335
20150205045336
20150205052312
20150207060050
20150207060210
20150210021847
20201230034339
20211216013358
20211216013943
20211218231223
20211221032346
20211224235053
20211231010225
20220116051443
20220116051444
20220116051445
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, name, created_at, updated_at, avatar_url, biography) FROM stdin;
1	benradler@me.com	$2a$10$W9f8pTFfoH6SZfBh2eKcDute3JR6ysYlXoF1O53HuXjuJzoM7Pp9q	\N	\N	\N	30	2025-04-30 21:24:06.658371	2023-07-20 20:03:12.972358	172.69.23.57	172.69.33.139	Ben Radler	2015-02-09 00:49:02.038891	2025-04-30 21:24:06.658725	http://1.gravatar.com/avatar/91250146d344dff9714afd00050f6bfd	Ben is a Software Engineer. He works on autonomous vehicle dispatch at Cruise.
\.


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.active_admin_comments_id_seq', 1, false);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.active_storage_attachments_id_seq', 269, true);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.active_storage_blobs_id_seq', 269, true);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.active_storage_variant_records_id_seq', 280, true);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.friendly_id_slugs_id_seq', 1, false);


--
-- Name: newsletter_signups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.newsletter_signups_id_seq', 1378, true);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.posts_id_seq', 22, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: newsletter_signups newsletter_signups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_signups
    ADD CONSTRAINT newsletter_signups_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON public.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON public.active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON public.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON public.friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_newsletter_signups_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_newsletter_signups_on_email ON public.newsletter_signups USING btree (email);


--
-- Name: index_posts_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_posts_on_slug ON public.posts USING btree (slug);


--
-- Name: index_posts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_user_id ON public.posts USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: extension_before_drop; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER extension_before_drop ON ddl_command_start
   EXECUTE FUNCTION _heroku.extension_before_drop();


--
-- Name: log_create_ext; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER log_create_ext ON ddl_command_end
   EXECUTE FUNCTION _heroku.create_ext();


--
-- Name: log_drop_ext; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER log_drop_ext ON sql_drop
   EXECUTE FUNCTION _heroku.drop_ext();


--
-- Name: validate_extension; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER validate_extension ON ddl_command_end
   EXECUTE FUNCTION _heroku.validate_extension();


--
-- PostgreSQL database dump complete
--

