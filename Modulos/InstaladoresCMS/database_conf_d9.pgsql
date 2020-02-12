--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.16
-- Dumped by pg_dump version 9.6.16

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: soundex(text); Type: FUNCTION; Schema: public; Owner: temp_user
--

CREATE FUNCTION public.soundex(input text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE STRICT COST 500
    AS $$
DECLARE
  soundex text = '';
  char text;
  symbol text;
  last_symbol text = '';
  pos int = 1;
BEGIN
  WHILE length(soundex) < 4 LOOP
    char = upper(substr(input, pos, 1));
    pos = pos + 1;
    CASE char
    WHEN '' THEN
      -- End of input string
      IF soundex = '' THEN
        RETURN '';
      ELSE
        RETURN rpad(soundex, 4, '0');
      END IF;
    WHEN 'B', 'F', 'P', 'V' THEN
      symbol = '1';
    WHEN 'C', 'G', 'J', 'K', 'Q', 'S', 'X', 'Z' THEN
      symbol = '2';
    WHEN 'D', 'T' THEN
      symbol = '3';
    WHEN 'L' THEN
      symbol = '4';
    WHEN 'M', 'N' THEN
      symbol = '5';
    WHEN 'R' THEN
      symbol = '6';
    ELSE
      -- Not a consonant; no output, but next similar consonant will be re-recorded
      symbol = '';
    END CASE;

    IF soundex = '' THEN
      -- First character; only accept strictly English ASCII characters
      IF char ~>=~ 'A' AND char ~<=~ 'Z' THEN
        soundex = char;
        last_symbol = symbol;
      END IF;
    ELSIF last_symbol != symbol THEN
      soundex = soundex || symbol;
      last_symbol = symbol;
    END IF;
  END LOOP;

  RETURN soundex;
END;
$$;


ALTER FUNCTION public.soundex(input text) OWNER TO temp_user;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: j_action_log_config; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_action_log_config (
    id integer NOT NULL,
    type_title character varying(255) DEFAULT ''::character varying NOT NULL,
    type_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    id_holder character varying(255),
    title_holder character varying(255),
    table_name character varying(255),
    text_prefix character varying(255)
);


ALTER TABLE public.j_action_log_config OWNER TO temp_user;

--
-- Name: j_action_log_config_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_action_log_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_action_log_config_id_seq OWNER TO temp_user;

--
-- Name: j_action_log_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_action_log_config_id_seq OWNED BY public.j_action_log_config.id;


--
-- Name: j_action_logs; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_action_logs (
    id integer NOT NULL,
    message_language_key character varying(255) DEFAULT ''::character varying NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    log_date timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    extension character varying(50) DEFAULT ''::character varying NOT NULL,
    user_id integer DEFAULT 0 NOT NULL,
    item_id integer DEFAULT 0 NOT NULL,
    ip_address character varying(40) DEFAULT '0.0.0.0'::character varying NOT NULL
);


ALTER TABLE public.j_action_logs OWNER TO temp_user;

--
-- Name: j_action_logs_extensions; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_action_logs_extensions (
    id integer NOT NULL,
    extension character varying(50) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.j_action_logs_extensions OWNER TO temp_user;

--
-- Name: j_action_logs_extensions_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_action_logs_extensions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_action_logs_extensions_id_seq OWNER TO temp_user;

--
-- Name: j_action_logs_extensions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_action_logs_extensions_id_seq OWNED BY public.j_action_logs_extensions.id;


--
-- Name: j_action_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_action_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_action_logs_id_seq OWNER TO temp_user;

--
-- Name: j_action_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_action_logs_id_seq OWNED BY public.j_action_logs.id;


--
-- Name: j_action_logs_users; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_action_logs_users (
    user_id integer NOT NULL,
    notify integer NOT NULL,
    extensions text NOT NULL
);


ALTER TABLE public.j_action_logs_users OWNER TO temp_user;

--
-- Name: j_assets; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_assets (
    id integer NOT NULL,
    parent_id bigint DEFAULT 0 NOT NULL,
    lft bigint DEFAULT 0 NOT NULL,
    rgt bigint DEFAULT 0 NOT NULL,
    level integer NOT NULL,
    name character varying(50) NOT NULL,
    title character varying(100) NOT NULL,
    rules character varying(5120) NOT NULL
);


ALTER TABLE public.j_assets OWNER TO temp_user;

--
-- Name: COLUMN j_assets.id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_assets.id IS 'Primary Key';


--
-- Name: COLUMN j_assets.parent_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_assets.parent_id IS 'Nested set parent.';


--
-- Name: COLUMN j_assets.lft; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_assets.lft IS 'Nested set lft.';


--
-- Name: COLUMN j_assets.rgt; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_assets.rgt IS 'Nested set rgt.';


--
-- Name: COLUMN j_assets.level; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_assets.level IS 'The cached level in the nested tree.';


--
-- Name: COLUMN j_assets.name; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_assets.name IS 'The unique name for the asset.';


--
-- Name: COLUMN j_assets.title; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_assets.title IS 'The descriptive title for the asset.';


--
-- Name: COLUMN j_assets.rules; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_assets.rules IS 'JSON encoded access control.';


--
-- Name: j_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_assets_id_seq OWNER TO temp_user;

--
-- Name: j_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_assets_id_seq OWNED BY public.j_assets.id;


--
-- Name: j_associations; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_associations (
    id integer NOT NULL,
    context character varying(50) NOT NULL,
    key character(32) NOT NULL
);


ALTER TABLE public.j_associations OWNER TO temp_user;

--
-- Name: COLUMN j_associations.id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_associations.id IS 'A reference to the associated item.';


--
-- Name: COLUMN j_associations.context; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_associations.context IS 'The context of the associated item.';


--
-- Name: COLUMN j_associations.key; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_associations.key IS 'The key for the association computed from an md5 on associated ids.';


--
-- Name: j_banner_clients; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_banner_clients (
    id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    contact character varying(255) DEFAULT ''::character varying NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    extrainfo text NOT NULL,
    state smallint DEFAULT 0 NOT NULL,
    checked_out bigint DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    metakey text NOT NULL,
    own_prefix smallint DEFAULT 0 NOT NULL,
    metakey_prefix character varying(255) DEFAULT ''::character varying NOT NULL,
    purchase_type smallint DEFAULT '-1'::integer NOT NULL,
    track_clicks smallint DEFAULT '-1'::integer NOT NULL,
    track_impressions smallint DEFAULT '-1'::integer NOT NULL
);


ALTER TABLE public.j_banner_clients OWNER TO temp_user;

--
-- Name: j_banner_clients_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_banner_clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_banner_clients_id_seq OWNER TO temp_user;

--
-- Name: j_banner_clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_banner_clients_id_seq OWNED BY public.j_banner_clients.id;


--
-- Name: j_banner_tracks; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_banner_tracks (
    track_date timestamp without time zone NOT NULL,
    track_type bigint NOT NULL,
    banner_id bigint NOT NULL,
    count bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_banner_tracks OWNER TO temp_user;

--
-- Name: j_banners; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_banners (
    id integer NOT NULL,
    cid bigint DEFAULT 0 NOT NULL,
    type bigint DEFAULT 0 NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    alias character varying(255) DEFAULT ''::character varying NOT NULL,
    imptotal bigint DEFAULT 0 NOT NULL,
    impmade bigint DEFAULT 0 NOT NULL,
    clicks bigint DEFAULT 0 NOT NULL,
    clickurl character varying(200) DEFAULT ''::character varying NOT NULL,
    state smallint DEFAULT 0 NOT NULL,
    catid bigint DEFAULT 0 NOT NULL,
    description text NOT NULL,
    custombannercode character varying(2048) NOT NULL,
    sticky smallint DEFAULT 0 NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL,
    metakey text NOT NULL,
    params text NOT NULL,
    own_prefix smallint DEFAULT 0 NOT NULL,
    metakey_prefix character varying(255) DEFAULT ''::character varying NOT NULL,
    purchase_type smallint DEFAULT '-1'::integer NOT NULL,
    track_clicks smallint DEFAULT '-1'::integer NOT NULL,
    track_impressions smallint DEFAULT '-1'::integer NOT NULL,
    checked_out bigint DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_up timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_down timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    reset timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    language character varying(7) DEFAULT ''::character varying NOT NULL,
    created_by bigint DEFAULT 0 NOT NULL,
    created_by_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    modified timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_by bigint DEFAULT 0 NOT NULL,
    version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.j_banners OWNER TO temp_user;

--
-- Name: j_banners_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_banners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_banners_id_seq OWNER TO temp_user;

--
-- Name: j_banners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_banners_id_seq OWNED BY public.j_banners.id;


--
-- Name: j_categories; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_categories (
    id integer NOT NULL,
    asset_id bigint DEFAULT 0 NOT NULL,
    parent_id integer DEFAULT 0 NOT NULL,
    lft bigint DEFAULT 0 NOT NULL,
    rgt bigint DEFAULT 0 NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    path character varying(255) DEFAULT ''::character varying NOT NULL,
    extension character varying(50) DEFAULT ''::character varying NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    alias character varying(255) DEFAULT ''::character varying NOT NULL,
    note character varying(255) DEFAULT ''::character varying NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    published smallint DEFAULT 0 NOT NULL,
    checked_out bigint DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    access bigint DEFAULT 0 NOT NULL,
    params text DEFAULT ''::text NOT NULL,
    metadesc character varying(1024) DEFAULT ''::character varying NOT NULL,
    metakey character varying(1024) DEFAULT ''::character varying NOT NULL,
    metadata character varying(2048) DEFAULT ''::character varying NOT NULL,
    created_user_id integer DEFAULT 0 NOT NULL,
    created_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_user_id integer DEFAULT 0 NOT NULL,
    modified_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    hits integer DEFAULT 0 NOT NULL,
    language character varying(7) DEFAULT ''::character varying NOT NULL,
    version bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.j_categories OWNER TO temp_user;

--
-- Name: COLUMN j_categories.asset_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_categories.asset_id IS 'FK to the #__assets table.';


--
-- Name: COLUMN j_categories.metadesc; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_categories.metadesc IS 'The meta description for the page.';


--
-- Name: COLUMN j_categories.metakey; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_categories.metakey IS 'The meta keywords for the page.';


--
-- Name: COLUMN j_categories.metadata; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_categories.metadata IS 'JSON encoded metadata properties.';


--
-- Name: j_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_categories_id_seq OWNER TO temp_user;

--
-- Name: j_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_categories_id_seq OWNED BY public.j_categories.id;


--
-- Name: j_contact_details; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_contact_details (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    alias character varying(255) NOT NULL,
    con_position character varying(255),
    address text,
    suburb character varying(100),
    state character varying(100),
    country character varying(100),
    postcode character varying(100),
    telephone character varying(255),
    fax character varying(255),
    misc text,
    image character varying(255),
    email_to character varying(255),
    default_con smallint DEFAULT 0 NOT NULL,
    published smallint DEFAULT 0 NOT NULL,
    checked_out bigint DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL,
    params text NOT NULL,
    user_id bigint DEFAULT 0 NOT NULL,
    catid bigint DEFAULT 0 NOT NULL,
    access bigint DEFAULT 0 NOT NULL,
    mobile character varying(255) DEFAULT ''::character varying NOT NULL,
    webpage character varying(255) DEFAULT ''::character varying NOT NULL,
    sortname1 character varying(255) DEFAULT ''::character varying NOT NULL,
    sortname2 character varying(255) DEFAULT ''::character varying NOT NULL,
    sortname3 character varying(255) DEFAULT ''::character varying NOT NULL,
    language character varying(7) NOT NULL,
    created timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created_by integer DEFAULT 0 NOT NULL,
    created_by_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    modified timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_by integer DEFAULT 0 NOT NULL,
    metakey text NOT NULL,
    metadesc text NOT NULL,
    metadata text NOT NULL,
    featured smallint DEFAULT 0 NOT NULL,
    xreference character varying(50) DEFAULT ''::character varying NOT NULL,
    publish_up timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_down timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    hits bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_contact_details OWNER TO temp_user;

--
-- Name: COLUMN j_contact_details.featured; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_contact_details.featured IS 'Set if contact is featured.';


--
-- Name: COLUMN j_contact_details.xreference; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_contact_details.xreference IS 'A reference to enable linkages to external data sets.';


--
-- Name: j_contact_details_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_contact_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_contact_details_id_seq OWNER TO temp_user;

--
-- Name: j_contact_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_contact_details_id_seq OWNED BY public.j_contact_details.id;


--
-- Name: j_content; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_content (
    id integer NOT NULL,
    asset_id bigint DEFAULT 0 NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    alias character varying(255) DEFAULT ''::character varying NOT NULL,
    introtext text NOT NULL,
    fulltext text NOT NULL,
    state smallint DEFAULT 0 NOT NULL,
    catid bigint DEFAULT 0 NOT NULL,
    created timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created_by bigint DEFAULT 0 NOT NULL,
    created_by_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    modified timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_by bigint DEFAULT 0 NOT NULL,
    checked_out bigint DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_up timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_down timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    images text NOT NULL,
    urls text NOT NULL,
    attribs character varying(5120) NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL,
    metakey text NOT NULL,
    metadesc text NOT NULL,
    access bigint DEFAULT 0 NOT NULL,
    hits bigint DEFAULT 0 NOT NULL,
    metadata text NOT NULL,
    featured smallint DEFAULT 0 NOT NULL,
    language character varying(7) DEFAULT ''::character varying NOT NULL,
    xreference character varying(50) DEFAULT ''::character varying NOT NULL,
    note character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.j_content OWNER TO temp_user;

--
-- Name: COLUMN j_content.asset_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_content.asset_id IS 'FK to the #__assets table.';


--
-- Name: COLUMN j_content.featured; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_content.featured IS 'Set if article is featured.';


--
-- Name: COLUMN j_content.language; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_content.language IS 'The language code for the article.';


--
-- Name: COLUMN j_content.xreference; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_content.xreference IS 'A reference to enable linkages to external data sets.';


--
-- Name: j_content_frontpage; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_content_frontpage (
    content_id bigint DEFAULT 0 NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_content_frontpage OWNER TO temp_user;

--
-- Name: j_content_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_content_id_seq OWNER TO temp_user;

--
-- Name: j_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_content_id_seq OWNED BY public.j_content.id;


--
-- Name: j_content_rating; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_content_rating (
    content_id bigint DEFAULT 0 NOT NULL,
    rating_sum bigint DEFAULT 0 NOT NULL,
    rating_count bigint DEFAULT 0 NOT NULL,
    lastip character varying(50) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.j_content_rating OWNER TO temp_user;

--
-- Name: j_content_types; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_content_types (
    type_id integer NOT NULL,
    type_title character varying(255) DEFAULT ''::character varying NOT NULL,
    type_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    "table" character varying(255) DEFAULT ''::character varying NOT NULL,
    rules text NOT NULL,
    field_mappings text NOT NULL,
    router character varying(255) DEFAULT ''::character varying NOT NULL,
    content_history_options character varying(5120) DEFAULT NULL::character varying
);


ALTER TABLE public.j_content_types OWNER TO temp_user;

--
-- Name: COLUMN j_content_types.content_history_options; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_content_types.content_history_options IS 'JSON string for com_contenthistory options';


--
-- Name: j_content_types_type_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_content_types_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_content_types_type_id_seq OWNER TO temp_user;

--
-- Name: j_content_types_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_content_types_type_id_seq OWNED BY public.j_content_types.type_id;


--
-- Name: j_contentitem_tag_map; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_contentitem_tag_map (
    type_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    core_content_id integer NOT NULL,
    content_item_id integer NOT NULL,
    tag_id integer NOT NULL,
    tag_date timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    type_id integer NOT NULL
);


ALTER TABLE public.j_contentitem_tag_map OWNER TO temp_user;

--
-- Name: COLUMN j_contentitem_tag_map.core_content_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_contentitem_tag_map.core_content_id IS 'PK from the core content table';


--
-- Name: COLUMN j_contentitem_tag_map.content_item_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_contentitem_tag_map.content_item_id IS 'PK from the content type table';


--
-- Name: COLUMN j_contentitem_tag_map.tag_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_contentitem_tag_map.tag_id IS 'PK from the tag table';


--
-- Name: COLUMN j_contentitem_tag_map.tag_date; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_contentitem_tag_map.tag_date IS 'Date of most recent save for this tag-item';


--
-- Name: COLUMN j_contentitem_tag_map.type_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_contentitem_tag_map.type_id IS 'PK from the content_type table';


--
-- Name: j_core_log_searches; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_core_log_searches (
    search_term character varying(128) DEFAULT ''::character varying NOT NULL,
    hits bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_core_log_searches OWNER TO temp_user;

--
-- Name: j_extensions; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_extensions (
    extension_id integer NOT NULL,
    package_id bigint DEFAULT 0 NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(20) NOT NULL,
    element character varying(100) NOT NULL,
    folder character varying(100) NOT NULL,
    client_id smallint NOT NULL,
    enabled smallint DEFAULT 0 NOT NULL,
    access bigint DEFAULT 1 NOT NULL,
    protected smallint DEFAULT 0 NOT NULL,
    manifest_cache text NOT NULL,
    params text NOT NULL,
    custom_data text NOT NULL,
    system_data text NOT NULL,
    checked_out integer DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    ordering bigint DEFAULT 0,
    state bigint DEFAULT 0
);


ALTER TABLE public.j_extensions OWNER TO temp_user;

--
-- Name: COLUMN j_extensions.package_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_extensions.package_id IS 'Parent package ID for extensions installed as a package.';


--
-- Name: j_extensions_extension_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_extensions_extension_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_extensions_extension_id_seq OWNER TO temp_user;

--
-- Name: j_extensions_extension_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_extensions_extension_id_seq OWNED BY public.j_extensions.extension_id;


--
-- Name: j_fields; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_fields (
    id integer NOT NULL,
    asset_id bigint DEFAULT 0 NOT NULL,
    context character varying(255) DEFAULT ''::character varying NOT NULL,
    group_id bigint DEFAULT 0 NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    label character varying(255) DEFAULT ''::character varying NOT NULL,
    default_value text DEFAULT ''::text NOT NULL,
    type character varying(255) DEFAULT 'text'::character varying NOT NULL,
    note character varying(255) DEFAULT ''::character varying NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    state smallint DEFAULT 0 NOT NULL,
    required smallint DEFAULT 0 NOT NULL,
    checked_out integer DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL,
    params text DEFAULT ''::text NOT NULL,
    fieldparams text DEFAULT ''::text NOT NULL,
    language character varying(7) DEFAULT ''::character varying NOT NULL,
    created_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created_user_id bigint DEFAULT 0 NOT NULL,
    modified_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_by bigint DEFAULT 0 NOT NULL,
    access bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_fields OWNER TO temp_user;

--
-- Name: j_fields_categories; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_fields_categories (
    field_id bigint DEFAULT 0 NOT NULL,
    category_id bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_fields_categories OWNER TO temp_user;

--
-- Name: j_fields_groups; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_fields_groups (
    id integer NOT NULL,
    asset_id bigint DEFAULT 0 NOT NULL,
    context character varying(255) DEFAULT ''::character varying NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    note character varying(255) DEFAULT ''::character varying NOT NULL,
    description text NOT NULL,
    state smallint DEFAULT 0 NOT NULL,
    checked_out integer DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    ordering integer DEFAULT 0 NOT NULL,
    params text DEFAULT ''::text NOT NULL,
    language character varying(7) DEFAULT ''::character varying NOT NULL,
    created timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created_by bigint DEFAULT 0 NOT NULL,
    modified timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_by bigint DEFAULT 0 NOT NULL,
    access bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public.j_fields_groups OWNER TO temp_user;

--
-- Name: j_fields_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_fields_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_fields_groups_id_seq OWNER TO temp_user;

--
-- Name: j_fields_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_fields_groups_id_seq OWNED BY public.j_fields_groups.id;


--
-- Name: j_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_fields_id_seq OWNER TO temp_user;

--
-- Name: j_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_fields_id_seq OWNED BY public.j_fields.id;


--
-- Name: j_fields_values; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_fields_values (
    field_id bigint DEFAULT 0 NOT NULL,
    item_id character varying(255) DEFAULT ''::character varying NOT NULL,
    value text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.j_fields_values OWNER TO temp_user;

--
-- Name: j_finder_filters; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_filters (
    filter_id integer NOT NULL,
    title character varying(255) NOT NULL,
    alias character varying(255) NOT NULL,
    state smallint DEFAULT 1 NOT NULL,
    created timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created_by integer NOT NULL,
    created_by_alias character varying(255) NOT NULL,
    modified timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_by integer DEFAULT 0 NOT NULL,
    checked_out integer DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    map_count integer DEFAULT 0 NOT NULL,
    data text NOT NULL,
    params text
);


ALTER TABLE public.j_finder_filters OWNER TO temp_user;

--
-- Name: j_finder_filters_filter_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_finder_filters_filter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_finder_filters_filter_id_seq OWNER TO temp_user;

--
-- Name: j_finder_filters_filter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_finder_filters_filter_id_seq OWNED BY public.j_finder_filters.filter_id;


--
-- Name: j_finder_links; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links (
    link_id integer NOT NULL,
    url character varying(255) NOT NULL,
    route character varying(255) NOT NULL,
    title character varying(400) DEFAULT NULL::character varying,
    description text DEFAULT ''::text NOT NULL,
    indexdate timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    md5sum character varying(32) DEFAULT NULL::character varying,
    published smallint DEFAULT 1 NOT NULL,
    state integer DEFAULT 1,
    access integer DEFAULT 0,
    language character varying(8) DEFAULT ''::character varying NOT NULL,
    publish_start_date timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_end_date timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    start_date timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    end_date timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    list_price numeric(8,2) DEFAULT 0 NOT NULL,
    sale_price numeric(8,2) DEFAULT 0 NOT NULL,
    type_id bigint NOT NULL,
    object bytea NOT NULL
);


ALTER TABLE public.j_finder_links OWNER TO temp_user;

--
-- Name: j_finder_links_link_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_finder_links_link_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_finder_links_link_id_seq OWNER TO temp_user;

--
-- Name: j_finder_links_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_finder_links_link_id_seq OWNED BY public.j_finder_links.link_id;


--
-- Name: j_finder_links_terms0; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms0 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms0 OWNER TO temp_user;

--
-- Name: j_finder_links_terms1; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms1 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms1 OWNER TO temp_user;

--
-- Name: j_finder_links_terms2; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms2 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms2 OWNER TO temp_user;

--
-- Name: j_finder_links_terms3; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms3 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms3 OWNER TO temp_user;

--
-- Name: j_finder_links_terms4; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms4 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms4 OWNER TO temp_user;

--
-- Name: j_finder_links_terms5; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms5 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms5 OWNER TO temp_user;

--
-- Name: j_finder_links_terms6; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms6 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms6 OWNER TO temp_user;

--
-- Name: j_finder_links_terms7; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms7 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms7 OWNER TO temp_user;

--
-- Name: j_finder_links_terms8; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms8 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms8 OWNER TO temp_user;

--
-- Name: j_finder_links_terms9; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_terms9 (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_terms9 OWNER TO temp_user;

--
-- Name: j_finder_links_termsa; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_termsa (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_termsa OWNER TO temp_user;

--
-- Name: j_finder_links_termsb; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_termsb (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_termsb OWNER TO temp_user;

--
-- Name: j_finder_links_termsc; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_termsc (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_termsc OWNER TO temp_user;

--
-- Name: j_finder_links_termsd; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_termsd (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_termsd OWNER TO temp_user;

--
-- Name: j_finder_links_termse; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_termse (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_termse OWNER TO temp_user;

--
-- Name: j_finder_links_termsf; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_links_termsf (
    link_id integer NOT NULL,
    term_id integer NOT NULL,
    weight numeric(8,2) NOT NULL
);


ALTER TABLE public.j_finder_links_termsf OWNER TO temp_user;

--
-- Name: j_finder_taxonomy; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_taxonomy (
    id integer NOT NULL,
    parent_id integer DEFAULT 0 NOT NULL,
    title character varying(255) NOT NULL,
    state smallint DEFAULT 1 NOT NULL,
    access smallint DEFAULT 0 NOT NULL,
    ordering smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_finder_taxonomy OWNER TO temp_user;

--
-- Name: j_finder_taxonomy_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_finder_taxonomy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_finder_taxonomy_id_seq OWNER TO temp_user;

--
-- Name: j_finder_taxonomy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_finder_taxonomy_id_seq OWNED BY public.j_finder_taxonomy.id;


--
-- Name: j_finder_taxonomy_map; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_taxonomy_map (
    link_id integer NOT NULL,
    node_id integer NOT NULL
);


ALTER TABLE public.j_finder_taxonomy_map OWNER TO temp_user;

--
-- Name: j_finder_terms; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_terms (
    term_id integer NOT NULL,
    term character varying(75) NOT NULL,
    stem character varying(75) NOT NULL,
    common smallint DEFAULT 0 NOT NULL,
    phrase smallint DEFAULT 0 NOT NULL,
    weight numeric(8,2) DEFAULT 0 NOT NULL,
    soundex character varying(75) NOT NULL,
    links integer DEFAULT 0 NOT NULL,
    language character varying(3) NOT NULL
);


ALTER TABLE public.j_finder_terms OWNER TO temp_user;

--
-- Name: j_finder_terms_common; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_terms_common (
    term character varying(75) NOT NULL,
    language character varying(3) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.j_finder_terms_common OWNER TO temp_user;

--
-- Name: j_finder_terms_term_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_finder_terms_term_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_finder_terms_term_id_seq OWNER TO temp_user;

--
-- Name: j_finder_terms_term_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_finder_terms_term_id_seq OWNED BY public.j_finder_terms.term_id;


--
-- Name: j_finder_tokens; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_tokens (
    term character varying(75) NOT NULL,
    stem character varying(75) NOT NULL,
    common smallint DEFAULT 0 NOT NULL,
    phrase smallint DEFAULT 0 NOT NULL,
    weight numeric(8,2) DEFAULT 1 NOT NULL,
    context smallint DEFAULT 2 NOT NULL,
    language character varying(3) NOT NULL
);


ALTER TABLE public.j_finder_tokens OWNER TO temp_user;

--
-- Name: j_finder_tokens_aggregate; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_tokens_aggregate (
    term_id integer NOT NULL,
    map_suffix character varying(1) NOT NULL,
    term character varying(75) NOT NULL,
    stem character varying(75) NOT NULL,
    common smallint DEFAULT 0 NOT NULL,
    phrase smallint DEFAULT 0 NOT NULL,
    term_weight numeric(8,2) NOT NULL,
    context smallint DEFAULT 2 NOT NULL,
    context_weight numeric(8,2) NOT NULL,
    total_weight numeric(8,2) NOT NULL,
    language character varying(3) NOT NULL
);


ALTER TABLE public.j_finder_tokens_aggregate OWNER TO temp_user;

--
-- Name: j_finder_types; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_finder_types (
    id integer NOT NULL,
    title character varying(100) NOT NULL,
    mime character varying(100) NOT NULL
);


ALTER TABLE public.j_finder_types OWNER TO temp_user;

--
-- Name: j_finder_types_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_finder_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_finder_types_id_seq OWNER TO temp_user;

--
-- Name: j_finder_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_finder_types_id_seq OWNED BY public.j_finder_types.id;


--
-- Name: j_languages; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_languages (
    lang_id integer NOT NULL,
    asset_id bigint DEFAULT 0 NOT NULL,
    lang_code character varying(7) NOT NULL,
    title character varying(50) NOT NULL,
    title_native character varying(50) NOT NULL,
    sef character varying(50) NOT NULL,
    image character varying(50) NOT NULL,
    description character varying(512) NOT NULL,
    metakey text NOT NULL,
    metadesc text NOT NULL,
    sitename character varying(1024) DEFAULT ''::character varying NOT NULL,
    published bigint DEFAULT 0 NOT NULL,
    access integer DEFAULT 0 NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_languages OWNER TO temp_user;

--
-- Name: j_languages_lang_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_languages_lang_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_languages_lang_id_seq OWNER TO temp_user;

--
-- Name: j_languages_lang_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_languages_lang_id_seq OWNED BY public.j_languages.lang_id;


--
-- Name: j_menu; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_menu (
    id integer NOT NULL,
    menutype character varying(24) NOT NULL,
    title character varying(255) NOT NULL,
    alias character varying(255) NOT NULL,
    note character varying(255) DEFAULT ''::character varying NOT NULL,
    path character varying(1024) DEFAULT ''::character varying NOT NULL,
    link character varying(1024) NOT NULL,
    type character varying(16) NOT NULL,
    published smallint DEFAULT 0 NOT NULL,
    parent_id integer DEFAULT 1 NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    component_id integer DEFAULT 0 NOT NULL,
    checked_out integer DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    "browserNav" smallint DEFAULT 0 NOT NULL,
    access bigint DEFAULT 0 NOT NULL,
    img character varying(255) DEFAULT ''::character varying NOT NULL,
    template_style_id integer DEFAULT 0 NOT NULL,
    params text DEFAULT ''::text NOT NULL,
    lft bigint DEFAULT 0 NOT NULL,
    rgt bigint DEFAULT 0 NOT NULL,
    home smallint DEFAULT 0 NOT NULL,
    language character varying(7) DEFAULT ''::character varying NOT NULL,
    client_id smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_menu OWNER TO temp_user;

--
-- Name: COLUMN j_menu.menutype; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.menutype IS 'The type of menu this item belongs to. FK to #__menu_types.menutype';


--
-- Name: COLUMN j_menu.title; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.title IS 'The display title of the menu item.';


--
-- Name: COLUMN j_menu.alias; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.alias IS 'The SEF alias of the menu item.';


--
-- Name: COLUMN j_menu.path; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.path IS 'The computed path of the menu item based on the alias field.';


--
-- Name: COLUMN j_menu.link; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.link IS 'The actually link the menu item refers to.';


--
-- Name: COLUMN j_menu.type; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.type IS 'The type of link: Component, URL, Alias, Separator';


--
-- Name: COLUMN j_menu.published; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.published IS 'The published state of the menu link.';


--
-- Name: COLUMN j_menu.parent_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.parent_id IS 'The parent menu item in the menu tree.';


--
-- Name: COLUMN j_menu.level; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.level IS 'The relative level in the tree.';


--
-- Name: COLUMN j_menu.component_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.component_id IS 'FK to #__extensions.id';


--
-- Name: COLUMN j_menu.checked_out; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.checked_out IS 'FK to #__users.id';


--
-- Name: COLUMN j_menu.checked_out_time; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.checked_out_time IS 'The time the menu item was checked out.';


--
-- Name: COLUMN j_menu."browserNav"; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu."browserNav" IS 'The click behaviour of the link.';


--
-- Name: COLUMN j_menu.access; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.access IS 'The access level required to view the menu item.';


--
-- Name: COLUMN j_menu.img; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.img IS 'The image of the menu item.';


--
-- Name: COLUMN j_menu.params; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.params IS 'JSON encoded data for the menu item.';


--
-- Name: COLUMN j_menu.lft; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.lft IS 'Nested set lft.';


--
-- Name: COLUMN j_menu.rgt; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.rgt IS 'Nested set rgt.';


--
-- Name: COLUMN j_menu.home; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_menu.home IS 'Indicates if this menu item is the home or default page.';


--
-- Name: j_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_menu_id_seq OWNER TO temp_user;

--
-- Name: j_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_menu_id_seq OWNED BY public.j_menu.id;


--
-- Name: j_menu_types; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_menu_types (
    id integer NOT NULL,
    asset_id bigint DEFAULT 0 NOT NULL,
    menutype character varying(24) NOT NULL,
    title character varying(48) NOT NULL,
    description character varying(255) DEFAULT ''::character varying NOT NULL,
    client_id integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_menu_types OWNER TO temp_user;

--
-- Name: j_menu_types_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_menu_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_menu_types_id_seq OWNER TO temp_user;

--
-- Name: j_menu_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_menu_types_id_seq OWNED BY public.j_menu_types.id;


--
-- Name: j_messages; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_messages (
    message_id integer NOT NULL,
    user_id_from bigint DEFAULT 0 NOT NULL,
    user_id_to bigint DEFAULT 0 NOT NULL,
    folder_id smallint DEFAULT 0 NOT NULL,
    date_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    state smallint DEFAULT 0 NOT NULL,
    priority smallint DEFAULT 0 NOT NULL,
    subject character varying(255) DEFAULT ''::character varying NOT NULL,
    message text NOT NULL
);


ALTER TABLE public.j_messages OWNER TO temp_user;

--
-- Name: j_messages_cfg; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_messages_cfg (
    user_id bigint DEFAULT 0 NOT NULL,
    cfg_name character varying(100) DEFAULT ''::character varying NOT NULL,
    cfg_value character varying(255) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.j_messages_cfg OWNER TO temp_user;

--
-- Name: j_messages_message_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_messages_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_messages_message_id_seq OWNER TO temp_user;

--
-- Name: j_messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_messages_message_id_seq OWNED BY public.j_messages.message_id;


--
-- Name: j_modules; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_modules (
    id integer NOT NULL,
    asset_id bigint DEFAULT 0 NOT NULL,
    title character varying(100) DEFAULT ''::character varying NOT NULL,
    note character varying(255) DEFAULT ''::character varying NOT NULL,
    content text DEFAULT ''::text NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL,
    "position" character varying(50) DEFAULT ''::character varying NOT NULL,
    checked_out integer DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_up timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_down timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    published smallint DEFAULT 0 NOT NULL,
    module character varying(50) DEFAULT NULL::character varying,
    access bigint DEFAULT 0 NOT NULL,
    showtitle smallint DEFAULT 1 NOT NULL,
    params text NOT NULL,
    client_id smallint DEFAULT 0 NOT NULL,
    language character varying(7) NOT NULL
);


ALTER TABLE public.j_modules OWNER TO temp_user;

--
-- Name: j_modules_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_modules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_modules_id_seq OWNER TO temp_user;

--
-- Name: j_modules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_modules_id_seq OWNED BY public.j_modules.id;


--
-- Name: j_modules_menu; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_modules_menu (
    moduleid bigint DEFAULT 0 NOT NULL,
    menuid bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_modules_menu OWNER TO temp_user;

--
-- Name: j_newsfeeds; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_newsfeeds (
    catid bigint DEFAULT 0 NOT NULL,
    id integer NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    alias character varying(100) DEFAULT ''::character varying NOT NULL,
    link character varying(2048) DEFAULT ''::character varying NOT NULL,
    published smallint DEFAULT 0 NOT NULL,
    numarticles bigint DEFAULT 1 NOT NULL,
    cache_time bigint DEFAULT 3600 NOT NULL,
    checked_out integer DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL,
    rtl smallint DEFAULT 0 NOT NULL,
    access bigint DEFAULT 0 NOT NULL,
    language character varying(7) DEFAULT ''::character varying NOT NULL,
    params text NOT NULL,
    created timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created_by integer DEFAULT 0 NOT NULL,
    created_by_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    modified timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_by integer DEFAULT 0 NOT NULL,
    metakey text NOT NULL,
    metadesc text NOT NULL,
    metadata text NOT NULL,
    xreference character varying(50) DEFAULT ''::character varying NOT NULL,
    publish_up timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_down timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    description text NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    hits bigint DEFAULT 0 NOT NULL,
    images text NOT NULL
);


ALTER TABLE public.j_newsfeeds OWNER TO temp_user;

--
-- Name: COLUMN j_newsfeeds.xreference; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_newsfeeds.xreference IS 'A reference to enable linkages to external data sets.';


--
-- Name: j_newsfeeds_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_newsfeeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_newsfeeds_id_seq OWNER TO temp_user;

--
-- Name: j_newsfeeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_newsfeeds_id_seq OWNED BY public.j_newsfeeds.id;


--
-- Name: j_overrider; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_overrider (
    id integer NOT NULL,
    constant character varying(255) NOT NULL,
    string text NOT NULL,
    file character varying(255) NOT NULL
);


ALTER TABLE public.j_overrider OWNER TO temp_user;

--
-- Name: COLUMN j_overrider.id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_overrider.id IS 'Primary Key';


--
-- Name: j_overrider_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_overrider_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_overrider_id_seq OWNER TO temp_user;

--
-- Name: j_overrider_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_overrider_id_seq OWNED BY public.j_overrider.id;


--
-- Name: j_postinstall_messages; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_postinstall_messages (
    postinstall_message_id integer NOT NULL,
    extension_id bigint DEFAULT 700 NOT NULL,
    title_key character varying(255) DEFAULT ''::character varying NOT NULL,
    description_key character varying(255) DEFAULT ''::character varying NOT NULL,
    action_key character varying(255) DEFAULT ''::character varying NOT NULL,
    language_extension character varying(255) DEFAULT 'com_postinstall'::character varying NOT NULL,
    language_client_id smallint DEFAULT 1 NOT NULL,
    type character varying(10) DEFAULT 'link'::character varying NOT NULL,
    action_file character varying(255) DEFAULT ''::character varying,
    action character varying(255) DEFAULT ''::character varying,
    condition_file character varying(255) DEFAULT NULL::character varying,
    condition_method character varying(255) DEFAULT NULL::character varying,
    version_introduced character varying(255) DEFAULT '3.2.0'::character varying NOT NULL,
    enabled smallint DEFAULT 1 NOT NULL
);


ALTER TABLE public.j_postinstall_messages OWNER TO temp_user;

--
-- Name: COLUMN j_postinstall_messages.extension_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.extension_id IS 'FK to jos_extensions';


--
-- Name: COLUMN j_postinstall_messages.title_key; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.title_key IS 'Lang key for the title';


--
-- Name: COLUMN j_postinstall_messages.description_key; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.description_key IS 'Lang key for description';


--
-- Name: COLUMN j_postinstall_messages.language_extension; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.language_extension IS 'Extension holding lang keys';


--
-- Name: COLUMN j_postinstall_messages.type; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.type IS 'Message type - message, link, action';


--
-- Name: COLUMN j_postinstall_messages.action_file; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.action_file IS 'RAD URI to the PHP file containing action method';


--
-- Name: COLUMN j_postinstall_messages.action; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.action IS 'Action method name or URL';


--
-- Name: COLUMN j_postinstall_messages.condition_file; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.condition_file IS 'RAD URI to file holding display condition method';


--
-- Name: COLUMN j_postinstall_messages.condition_method; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.condition_method IS 'Display condition method, must return boolean';


--
-- Name: COLUMN j_postinstall_messages.version_introduced; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_postinstall_messages.version_introduced IS 'Version when this message was introduced';


--
-- Name: j_postinstall_messages_postinstall_message_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_postinstall_messages_postinstall_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_postinstall_messages_postinstall_message_id_seq OWNER TO temp_user;

--
-- Name: j_postinstall_messages_postinstall_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_postinstall_messages_postinstall_message_id_seq OWNED BY public.j_postinstall_messages.postinstall_message_id;


--
-- Name: j_privacy_consents; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_privacy_consents (
    id integer NOT NULL,
    user_id bigint DEFAULT 0 NOT NULL,
    state smallint DEFAULT 1 NOT NULL,
    created timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    subject character varying(255) DEFAULT ''::character varying NOT NULL,
    body text NOT NULL,
    remind smallint DEFAULT 0 NOT NULL,
    token character varying(100) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.j_privacy_consents OWNER TO temp_user;

--
-- Name: j_privacy_consents_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_privacy_consents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_privacy_consents_id_seq OWNER TO temp_user;

--
-- Name: j_privacy_consents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_privacy_consents_id_seq OWNED BY public.j_privacy_consents.id;


--
-- Name: j_privacy_requests; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_privacy_requests (
    id integer NOT NULL,
    email character varying(100) DEFAULT ''::character varying NOT NULL,
    requested_at timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    request_type character varying(25) DEFAULT ''::character varying NOT NULL,
    confirm_token character varying(100) DEFAULT ''::character varying NOT NULL,
    confirm_token_created_at timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL
);


ALTER TABLE public.j_privacy_requests OWNER TO temp_user;

--
-- Name: j_privacy_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_privacy_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_privacy_requests_id_seq OWNER TO temp_user;

--
-- Name: j_privacy_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_privacy_requests_id_seq OWNED BY public.j_privacy_requests.id;


--
-- Name: j_redirect_links; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_redirect_links (
    id integer NOT NULL,
    old_url character varying(2048) NOT NULL,
    new_url character varying(2048),
    referer character varying(2048) NOT NULL,
    comment character varying(255) DEFAULT ''::character varying NOT NULL,
    hits bigint DEFAULT 0 NOT NULL,
    published smallint NOT NULL,
    created_date timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_date timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    header integer DEFAULT 301 NOT NULL
);


ALTER TABLE public.j_redirect_links OWNER TO temp_user;

--
-- Name: j_redirect_links_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_redirect_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_redirect_links_id_seq OWNER TO temp_user;

--
-- Name: j_redirect_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_redirect_links_id_seq OWNED BY public.j_redirect_links.id;


--
-- Name: j_schemas; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_schemas (
    extension_id bigint NOT NULL,
    version_id character varying(20) NOT NULL
);


ALTER TABLE public.j_schemas OWNER TO temp_user;

--
-- Name: j_session; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_session (
    session_id bytea NOT NULL,
    client_id smallint,
    guest smallint DEFAULT 1,
    "time" integer DEFAULT 0 NOT NULL,
    data text,
    userid bigint DEFAULT 0,
    username character varying(150) DEFAULT ''::character varying
);


ALTER TABLE public.j_session OWNER TO temp_user;

--
-- Name: j_tags; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_tags (
    id integer NOT NULL,
    parent_id bigint DEFAULT 0 NOT NULL,
    lft bigint DEFAULT 0 NOT NULL,
    rgt bigint DEFAULT 0 NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    path character varying(255) DEFAULT ''::character varying NOT NULL,
    title character varying(255) NOT NULL,
    alias character varying(255) DEFAULT ''::character varying NOT NULL,
    note character varying(255) DEFAULT ''::character varying NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    published smallint DEFAULT 0 NOT NULL,
    checked_out bigint DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    access bigint DEFAULT 0 NOT NULL,
    params text NOT NULL,
    metadesc character varying(1024) NOT NULL,
    metakey character varying(1024) NOT NULL,
    metadata character varying(2048) NOT NULL,
    created_user_id integer DEFAULT 0 NOT NULL,
    created_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created_by_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    modified_user_id integer DEFAULT 0 NOT NULL,
    modified_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    images text NOT NULL,
    urls text NOT NULL,
    hits integer DEFAULT 0 NOT NULL,
    language character varying(7) DEFAULT ''::character varying NOT NULL,
    version bigint DEFAULT 1 NOT NULL,
    publish_up timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_down timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL
);


ALTER TABLE public.j_tags OWNER TO temp_user;

--
-- Name: j_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_tags_id_seq OWNER TO temp_user;

--
-- Name: j_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_tags_id_seq OWNED BY public.j_tags.id;


--
-- Name: j_template_styles; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_template_styles (
    id integer NOT NULL,
    template character varying(50) DEFAULT ''::character varying NOT NULL,
    client_id smallint DEFAULT 0 NOT NULL,
    home character varying(7) DEFAULT '0'::character varying NOT NULL,
    title character varying(255) DEFAULT ''::character varying NOT NULL,
    params text NOT NULL
);


ALTER TABLE public.j_template_styles OWNER TO temp_user;

--
-- Name: j_template_styles_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_template_styles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_template_styles_id_seq OWNER TO temp_user;

--
-- Name: j_template_styles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_template_styles_id_seq OWNED BY public.j_template_styles.id;


--
-- Name: j_ucm_base; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_ucm_base (
    ucm_id integer NOT NULL,
    ucm_item_id bigint NOT NULL,
    ucm_type_id bigint NOT NULL,
    ucm_language_id bigint NOT NULL
);


ALTER TABLE public.j_ucm_base OWNER TO temp_user;

--
-- Name: j_ucm_base_ucm_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_ucm_base_ucm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_ucm_base_ucm_id_seq OWNER TO temp_user;

--
-- Name: j_ucm_base_ucm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_ucm_base_ucm_id_seq OWNED BY public.j_ucm_base.ucm_id;


--
-- Name: j_ucm_content; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_ucm_content (
    core_content_id integer NOT NULL,
    core_type_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    core_title character varying(255) DEFAULT ''::character varying NOT NULL,
    core_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    core_body text DEFAULT ''::text NOT NULL,
    core_state smallint DEFAULT 0 NOT NULL,
    core_checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    core_checked_out_user_id bigint DEFAULT 0 NOT NULL,
    core_access bigint DEFAULT 0 NOT NULL,
    core_params text DEFAULT ''::text NOT NULL,
    core_featured smallint DEFAULT 0 NOT NULL,
    core_metadata text DEFAULT ''::text NOT NULL,
    core_created_user_id bigint DEFAULT 0 NOT NULL,
    core_created_by_alias character varying(255) DEFAULT ''::character varying NOT NULL,
    core_created_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    core_modified_user_id bigint DEFAULT 0 NOT NULL,
    core_modified_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    core_language character varying(7) DEFAULT ''::character varying NOT NULL,
    core_publish_up timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    core_publish_down timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    core_content_item_id bigint DEFAULT 0 NOT NULL,
    asset_id bigint DEFAULT 0 NOT NULL,
    core_images text DEFAULT ''::text NOT NULL,
    core_urls text DEFAULT ''::text NOT NULL,
    core_hits bigint DEFAULT 0 NOT NULL,
    core_version bigint DEFAULT 1 NOT NULL,
    core_ordering bigint DEFAULT 0 NOT NULL,
    core_metakey text DEFAULT ''::text NOT NULL,
    core_metadesc text DEFAULT ''::text NOT NULL,
    core_catid bigint DEFAULT 0 NOT NULL,
    core_xreference character varying(50) DEFAULT ''::character varying NOT NULL,
    core_type_id bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_ucm_content OWNER TO temp_user;

--
-- Name: j_ucm_content_core_content_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_ucm_content_core_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_ucm_content_core_content_id_seq OWNER TO temp_user;

--
-- Name: j_ucm_content_core_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_ucm_content_core_content_id_seq OWNED BY public.j_ucm_content.core_content_id;


--
-- Name: j_ucm_history; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_ucm_history (
    version_id integer NOT NULL,
    ucm_item_id integer NOT NULL,
    ucm_type_id integer NOT NULL,
    version_note character varying(255) DEFAULT ''::character varying NOT NULL,
    save_date timestamp with time zone DEFAULT '1970-01-01 00:00:00+00'::timestamp with time zone NOT NULL,
    editor_user_id integer DEFAULT 0 NOT NULL,
    character_count integer DEFAULT 0 NOT NULL,
    sha1_hash character varying(50) DEFAULT ''::character varying NOT NULL,
    version_data text NOT NULL,
    keep_forever smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_ucm_history OWNER TO temp_user;

--
-- Name: COLUMN j_ucm_history.version_note; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_ucm_history.version_note IS 'Optional version name';


--
-- Name: COLUMN j_ucm_history.character_count; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_ucm_history.character_count IS 'Number of characters in this version.';


--
-- Name: COLUMN j_ucm_history.sha1_hash; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_ucm_history.sha1_hash IS 'SHA1 hash of the version_data column.';


--
-- Name: COLUMN j_ucm_history.version_data; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_ucm_history.version_data IS 'json-encoded string of version data';


--
-- Name: COLUMN j_ucm_history.keep_forever; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_ucm_history.keep_forever IS '0=auto delete; 1=keep';


--
-- Name: j_ucm_history_version_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_ucm_history_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_ucm_history_version_id_seq OWNER TO temp_user;

--
-- Name: j_ucm_history_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_ucm_history_version_id_seq OWNED BY public.j_ucm_history.version_id;


--
-- Name: j_update_sites; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_update_sites (
    update_site_id integer NOT NULL,
    name character varying(100) DEFAULT ''::character varying,
    type character varying(20) DEFAULT ''::character varying,
    location text NOT NULL,
    enabled bigint DEFAULT 0,
    last_check_timestamp bigint DEFAULT 0,
    extra_query character varying(1000) DEFAULT ''::character varying
);


ALTER TABLE public.j_update_sites OWNER TO temp_user;

--
-- Name: TABLE j_update_sites; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON TABLE public.j_update_sites IS 'Update Sites';


--
-- Name: j_update_sites_extensions; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_update_sites_extensions (
    update_site_id bigint DEFAULT 0 NOT NULL,
    extension_id bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_update_sites_extensions OWNER TO temp_user;

--
-- Name: TABLE j_update_sites_extensions; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON TABLE public.j_update_sites_extensions IS 'Links extensions to update sites';


--
-- Name: j_update_sites_update_site_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_update_sites_update_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_update_sites_update_site_id_seq OWNER TO temp_user;

--
-- Name: j_update_sites_update_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_update_sites_update_site_id_seq OWNED BY public.j_update_sites.update_site_id;


--
-- Name: j_updates; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_updates (
    update_id integer NOT NULL,
    update_site_id bigint DEFAULT 0,
    extension_id bigint DEFAULT 0,
    name character varying(100) DEFAULT ''::character varying,
    description text NOT NULL,
    element character varying(100) DEFAULT ''::character varying,
    type character varying(20) DEFAULT ''::character varying,
    folder character varying(20) DEFAULT ''::character varying,
    client_id smallint DEFAULT 0,
    version character varying(32) DEFAULT ''::character varying,
    data text NOT NULL,
    detailsurl text NOT NULL,
    infourl text NOT NULL,
    extra_query character varying(1000) DEFAULT ''::character varying
);


ALTER TABLE public.j_updates OWNER TO temp_user;

--
-- Name: TABLE j_updates; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON TABLE public.j_updates IS 'Available Updates';


--
-- Name: j_updates_update_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_updates_update_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_updates_update_id_seq OWNER TO temp_user;

--
-- Name: j_updates_update_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_updates_update_id_seq OWNED BY public.j_updates.update_id;


--
-- Name: j_user_keys; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_user_keys (
    id integer NOT NULL,
    user_id character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    series character varying(255) NOT NULL,
    invalid smallint NOT NULL,
    "time" character varying(200) NOT NULL,
    uastring character varying(255) NOT NULL
);


ALTER TABLE public.j_user_keys OWNER TO temp_user;

--
-- Name: j_user_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_user_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_user_keys_id_seq OWNER TO temp_user;

--
-- Name: j_user_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_user_keys_id_seq OWNED BY public.j_user_keys.id;


--
-- Name: j_user_notes; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_user_notes (
    id integer NOT NULL,
    user_id integer DEFAULT 0 NOT NULL,
    catid integer DEFAULT 0 NOT NULL,
    subject character varying(100) DEFAULT ''::character varying NOT NULL,
    body text NOT NULL,
    state smallint DEFAULT 0 NOT NULL,
    checked_out integer DEFAULT 0 NOT NULL,
    checked_out_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    created_user_id integer DEFAULT 0 NOT NULL,
    created_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    modified_user_id integer NOT NULL,
    modified_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    review_time timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_up timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    publish_down timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL
);


ALTER TABLE public.j_user_notes OWNER TO temp_user;

--
-- Name: j_user_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_user_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_user_notes_id_seq OWNER TO temp_user;

--
-- Name: j_user_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_user_notes_id_seq OWNED BY public.j_user_notes.id;


--
-- Name: j_user_profiles; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_user_profiles (
    user_id bigint NOT NULL,
    profile_key character varying(100) NOT NULL,
    profile_value text NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_user_profiles OWNER TO temp_user;

--
-- Name: TABLE j_user_profiles; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON TABLE public.j_user_profiles IS 'Simple user profile storage table';


--
-- Name: j_user_usergroup_map; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_user_usergroup_map (
    user_id bigint DEFAULT 0 NOT NULL,
    group_id bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.j_user_usergroup_map OWNER TO temp_user;

--
-- Name: COLUMN j_user_usergroup_map.user_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_user_usergroup_map.user_id IS 'Foreign Key to #__users.id';


--
-- Name: COLUMN j_user_usergroup_map.group_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_user_usergroup_map.group_id IS 'Foreign Key to #__usergroups.id';


--
-- Name: j_usergroups; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_usergroups (
    id integer NOT NULL,
    parent_id bigint DEFAULT 0 NOT NULL,
    lft bigint DEFAULT 0 NOT NULL,
    rgt bigint DEFAULT 0 NOT NULL,
    title character varying(100) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE public.j_usergroups OWNER TO temp_user;

--
-- Name: COLUMN j_usergroups.id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_usergroups.id IS 'Primary Key';


--
-- Name: COLUMN j_usergroups.parent_id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_usergroups.parent_id IS 'Adjacency List Reference Id';


--
-- Name: COLUMN j_usergroups.lft; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_usergroups.lft IS 'Nested set lft.';


--
-- Name: COLUMN j_usergroups.rgt; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_usergroups.rgt IS 'Nested set rgt.';


--
-- Name: j_usergroups_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_usergroups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_usergroups_id_seq OWNER TO temp_user;

--
-- Name: j_usergroups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_usergroups_id_seq OWNED BY public.j_usergroups.id;


--
-- Name: j_users; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_users (
    id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    username character varying(150) DEFAULT ''::character varying NOT NULL,
    email character varying(100) DEFAULT ''::character varying NOT NULL,
    password character varying(100) DEFAULT ''::character varying NOT NULL,
    block smallint DEFAULT 0 NOT NULL,
    "sendEmail" smallint DEFAULT 0,
    "registerDate" timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    "lastvisitDate" timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    activation character varying(100) DEFAULT ''::character varying NOT NULL,
    params text NOT NULL,
    "lastResetTime" timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    "resetCount" bigint DEFAULT 0 NOT NULL,
    "otpKey" character varying(1000) DEFAULT ''::character varying NOT NULL,
    otep character varying(1000) DEFAULT ''::character varying NOT NULL,
    "requireReset" smallint DEFAULT 0
);


ALTER TABLE public.j_users OWNER TO temp_user;

--
-- Name: COLUMN j_users."lastResetTime"; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_users."lastResetTime" IS 'Date of last password reset';


--
-- Name: COLUMN j_users."resetCount"; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_users."resetCount" IS 'Count of password resets since lastResetTime';


--
-- Name: COLUMN j_users."requireReset"; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_users."requireReset" IS 'Require user to reset password on next login';


--
-- Name: j_users_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_users_id_seq OWNER TO temp_user;

--
-- Name: j_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_users_id_seq OWNED BY public.j_users.id;


--
-- Name: j_viewlevels; Type: TABLE; Schema: public; Owner: temp_user
--

CREATE TABLE public.j_viewlevels (
    id integer NOT NULL,
    title character varying(100) DEFAULT ''::character varying NOT NULL,
    ordering bigint DEFAULT 0 NOT NULL,
    rules character varying(5120) NOT NULL
);


ALTER TABLE public.j_viewlevels OWNER TO temp_user;

--
-- Name: COLUMN j_viewlevels.id; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_viewlevels.id IS 'Primary Key';


--
-- Name: COLUMN j_viewlevels.rules; Type: COMMENT; Schema: public; Owner: temp_user
--

COMMENT ON COLUMN public.j_viewlevels.rules IS 'JSON encoded access control.';


--
-- Name: j_viewlevels_id_seq; Type: SEQUENCE; Schema: public; Owner: temp_user
--

CREATE SEQUENCE public.j_viewlevels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.j_viewlevels_id_seq OWNER TO temp_user;

--
-- Name: j_viewlevels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: temp_user
--

ALTER SEQUENCE public.j_viewlevels_id_seq OWNED BY public.j_viewlevels.id;


--
-- Name: j_action_log_config id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_action_log_config ALTER COLUMN id SET DEFAULT nextval('public.j_action_log_config_id_seq'::regclass);


--
-- Name: j_action_logs id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_action_logs ALTER COLUMN id SET DEFAULT nextval('public.j_action_logs_id_seq'::regclass);


--
-- Name: j_action_logs_extensions id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_action_logs_extensions ALTER COLUMN id SET DEFAULT nextval('public.j_action_logs_extensions_id_seq'::regclass);


--
-- Name: j_assets id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_assets ALTER COLUMN id SET DEFAULT nextval('public.j_assets_id_seq'::regclass);


--
-- Name: j_banner_clients id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_banner_clients ALTER COLUMN id SET DEFAULT nextval('public.j_banner_clients_id_seq'::regclass);


--
-- Name: j_banners id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_banners ALTER COLUMN id SET DEFAULT nextval('public.j_banners_id_seq'::regclass);


--
-- Name: j_categories id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_categories ALTER COLUMN id SET DEFAULT nextval('public.j_categories_id_seq'::regclass);


--
-- Name: j_contact_details id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_contact_details ALTER COLUMN id SET DEFAULT nextval('public.j_contact_details_id_seq'::regclass);


--
-- Name: j_content id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_content ALTER COLUMN id SET DEFAULT nextval('public.j_content_id_seq'::regclass);


--
-- Name: j_content_types type_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_content_types ALTER COLUMN type_id SET DEFAULT nextval('public.j_content_types_type_id_seq'::regclass);


--
-- Name: j_extensions extension_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_extensions ALTER COLUMN extension_id SET DEFAULT nextval('public.j_extensions_extension_id_seq'::regclass);


--
-- Name: j_fields id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_fields ALTER COLUMN id SET DEFAULT nextval('public.j_fields_id_seq'::regclass);


--
-- Name: j_fields_groups id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_fields_groups ALTER COLUMN id SET DEFAULT nextval('public.j_fields_groups_id_seq'::regclass);


--
-- Name: j_finder_filters filter_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_filters ALTER COLUMN filter_id SET DEFAULT nextval('public.j_finder_filters_filter_id_seq'::regclass);


--
-- Name: j_finder_links link_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links ALTER COLUMN link_id SET DEFAULT nextval('public.j_finder_links_link_id_seq'::regclass);


--
-- Name: j_finder_taxonomy id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_taxonomy ALTER COLUMN id SET DEFAULT nextval('public.j_finder_taxonomy_id_seq'::regclass);


--
-- Name: j_finder_terms term_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_terms ALTER COLUMN term_id SET DEFAULT nextval('public.j_finder_terms_term_id_seq'::regclass);


--
-- Name: j_finder_types id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_types ALTER COLUMN id SET DEFAULT nextval('public.j_finder_types_id_seq'::regclass);


--
-- Name: j_languages lang_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_languages ALTER COLUMN lang_id SET DEFAULT nextval('public.j_languages_lang_id_seq'::regclass);


--
-- Name: j_menu id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_menu ALTER COLUMN id SET DEFAULT nextval('public.j_menu_id_seq'::regclass);


--
-- Name: j_menu_types id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_menu_types ALTER COLUMN id SET DEFAULT nextval('public.j_menu_types_id_seq'::regclass);


--
-- Name: j_messages message_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_messages ALTER COLUMN message_id SET DEFAULT nextval('public.j_messages_message_id_seq'::regclass);


--
-- Name: j_modules id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_modules ALTER COLUMN id SET DEFAULT nextval('public.j_modules_id_seq'::regclass);


--
-- Name: j_newsfeeds id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_newsfeeds ALTER COLUMN id SET DEFAULT nextval('public.j_newsfeeds_id_seq'::regclass);


--
-- Name: j_overrider id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_overrider ALTER COLUMN id SET DEFAULT nextval('public.j_overrider_id_seq'::regclass);


--
-- Name: j_postinstall_messages postinstall_message_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_postinstall_messages ALTER COLUMN postinstall_message_id SET DEFAULT nextval('public.j_postinstall_messages_postinstall_message_id_seq'::regclass);


--
-- Name: j_privacy_consents id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_privacy_consents ALTER COLUMN id SET DEFAULT nextval('public.j_privacy_consents_id_seq'::regclass);


--
-- Name: j_privacy_requests id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_privacy_requests ALTER COLUMN id SET DEFAULT nextval('public.j_privacy_requests_id_seq'::regclass);


--
-- Name: j_redirect_links id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_redirect_links ALTER COLUMN id SET DEFAULT nextval('public.j_redirect_links_id_seq'::regclass);


--
-- Name: j_tags id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_tags ALTER COLUMN id SET DEFAULT nextval('public.j_tags_id_seq'::regclass);


--
-- Name: j_template_styles id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_template_styles ALTER COLUMN id SET DEFAULT nextval('public.j_template_styles_id_seq'::regclass);


--
-- Name: j_ucm_base ucm_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_ucm_base ALTER COLUMN ucm_id SET DEFAULT nextval('public.j_ucm_base_ucm_id_seq'::regclass);


--
-- Name: j_ucm_content core_content_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_ucm_content ALTER COLUMN core_content_id SET DEFAULT nextval('public.j_ucm_content_core_content_id_seq'::regclass);


--
-- Name: j_ucm_history version_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_ucm_history ALTER COLUMN version_id SET DEFAULT nextval('public.j_ucm_history_version_id_seq'::regclass);


--
-- Name: j_update_sites update_site_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_update_sites ALTER COLUMN update_site_id SET DEFAULT nextval('public.j_update_sites_update_site_id_seq'::regclass);


--
-- Name: j_updates update_id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_updates ALTER COLUMN update_id SET DEFAULT nextval('public.j_updates_update_id_seq'::regclass);


--
-- Name: j_user_keys id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_user_keys ALTER COLUMN id SET DEFAULT nextval('public.j_user_keys_id_seq'::regclass);


--
-- Name: j_user_notes id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_user_notes ALTER COLUMN id SET DEFAULT nextval('public.j_user_notes_id_seq'::regclass);


--
-- Name: j_usergroups id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_usergroups ALTER COLUMN id SET DEFAULT nextval('public.j_usergroups_id_seq'::regclass);


--
-- Name: j_users id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_users ALTER COLUMN id SET DEFAULT nextval('public.j_users_id_seq'::regclass);


--
-- Name: j_viewlevels id; Type: DEFAULT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_viewlevels ALTER COLUMN id SET DEFAULT nextval('public.j_viewlevels_id_seq'::regclass);


--
-- Data for Name: j_action_log_config; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_action_log_config (id, type_title, type_alias, id_holder, title_holder, table_name, text_prefix) FROM stdin;
1	article	com_content.article	id	title	#__content	PLG_ACTIONLOG_JOOMLA
2	article	com_content.form	id	title	#__content	PLG_ACTIONLOG_JOOMLA
3	banner	com_banners.banner	id	name	#__banners	PLG_ACTIONLOG_JOOMLA
4	user_note	com_users.note	id	subject	#__user_notes	PLG_ACTIONLOG_JOOMLA
5	media	com_media.file		name		PLG_ACTIONLOG_JOOMLA
6	category	com_categories.category	id	title	#__categories	PLG_ACTIONLOG_JOOMLA
7	menu	com_menus.menu	id	title	#__menu_types	PLG_ACTIONLOG_JOOMLA
8	menu_item	com_menus.item	id	title	#__menu	PLG_ACTIONLOG_JOOMLA
9	newsfeed	com_newsfeeds.newsfeed	id	name	#__newsfeeds	PLG_ACTIONLOG_JOOMLA
10	link	com_redirect.link	id	old_url	#__redirect_links	PLG_ACTIONLOG_JOOMLA
11	tag	com_tags.tag	id	title	#__tags	PLG_ACTIONLOG_JOOMLA
12	style	com_templates.style	id	title	#__template_styles	PLG_ACTIONLOG_JOOMLA
13	plugin	com_plugins.plugin	extension_id	name	#__extensions	PLG_ACTIONLOG_JOOMLA
14	component_config	com_config.component	extension_id	name		PLG_ACTIONLOG_JOOMLA
15	contact	com_contact.contact	id	name	#__contact_details	PLG_ACTIONLOG_JOOMLA
16	module	com_modules.module	id	title	#__modules	PLG_ACTIONLOG_JOOMLA
17	access_level	com_users.level	id	title	#__viewlevels	PLG_ACTIONLOG_JOOMLA
18	banner_client	com_banners.client	id	name	#__banner_clients	PLG_ACTIONLOG_JOOMLA
19	application_config	com_config.application		name		PLG_ACTIONLOG_JOOMLA
\.


--
-- Name: j_action_log_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_action_log_config_id_seq', 20, false);


--
-- Data for Name: j_action_logs; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_action_logs (id, message_language_key, message, log_date, extension, user_id, item_id, ip_address) FROM stdin;
\.


--
-- Data for Name: j_action_logs_extensions; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_action_logs_extensions (id, extension) FROM stdin;
1	com_banners
2	com_cache
3	com_categories
4	com_config
5	com_contact
6	com_content
7	com_installer
8	com_media
9	com_menus
10	com_messages
11	com_modules
12	com_newsfeeds
13	com_plugins
14	com_redirect
15	com_tags
16	com_templates
17	com_users
18	com_checkin
\.


--
-- Name: j_action_logs_extensions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_action_logs_extensions_id_seq', 19, false);


--
-- Name: j_action_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_action_logs_id_seq', 1, false);


--
-- Data for Name: j_action_logs_users; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_action_logs_users (user_id, notify, extensions) FROM stdin;
\.


--
-- Data for Name: j_assets; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_assets (id, parent_id, lft, rgt, level, name, title, rules) FROM stdin;
1	0	0	123	0	root.1	Root Asset	{"core.login.site":{"6":1,"2":1},"core.login.admin":{"6":1},"core.login.offline":{"6":1},"core.admin":{"8":1},"core.manage":{"7":1},"core.create":{"6":1,"3":1},"core.delete":{"6":1},"core.edit":{"6":1,"4":1},"core.edit.state":{"6":1,"5":1},"core.edit.own":{"6":1,"3":1}}
2	1	1	2	1	com_admin	com_admin	{}
3	1	3	6	1	com_banners	com_banners	{"core.admin":{"7":1},"core.manage":{"6":1}}
4	1	7	8	1	com_cache	com_cache	{"core.admin":{"7":1},"core.manage":{"7":1}}
5	1	9	10	1	com_checkin	com_checkin	{"core.admin":{"7":1},"core.manage":{"7":1}}
6	1	11	12	1	com_config	com_config	{}
7	1	13	16	1	com_contact	com_contact	{"core.admin":{"7":1},"core.manage":{"6":1}}
8	1	17	22	1	com_content	com_content	{"core.admin":{"7":1},"core.manage":{"6":1},"core.create":{"3":1},"core.edit":{"4":1},"core.edit.state":{"5":1}}
9	1	23	24	1	com_cpanel	com_cpanel	{}
10	1	25	26	1	com_installer	com_installer	{"core.manage":{"7":0},"core.delete":{"7":0},"core.edit.state":{"7":0}}
11	1	27	28	1	com_languages	com_languages	{"core.admin":{"7":1}}
12	1	29	30	1	com_login	com_login	{}
13	1	31	32	1	com_mailto	com_mailto	{}
14	1	33	34	1	com_massmail	com_massmail	{}
15	1	35	36	1	com_media	com_media	{"core.admin":{"7":1},"core.manage":{"6":1},"core.create":{"3":1},"core.delete":{"5":1}}
16	1	37	38	1	com_menus	com_menus	{"core.admin":{"7":1}}
17	1	39	40	1	com_messages	com_messages	{"core.admin":{"7":1},"core.manage":{"7":1}}
18	1	41	86	1	com_modules	com_modules	{"core.admin":{"7":1}}
19	1	87	90	1	com_newsfeeds	com_newsfeeds	{"core.admin":{"7":1},"core.manage":{"6":1}}
20	1	91	92	1	com_plugins	com_plugins	{"core.admin":{"7":1}}
21	1	93	94	1	com_redirect	com_redirect	{"core.admin":{"7":1}}
22	1	95	96	1	com_search	com_search	{"core.admin":{"7":1},"core.manage":{"6":1}}
23	1	97	98	1	com_templates	com_templates	{"core.admin":{"7":1}}
24	1	99	102	1	com_users	com_users	{"core.admin":{"7":1}}
26	1	103	104	1	com_wrapper	com_wrapper	{}
27	8	18	21	2	com_content.category.2	Uncategorised	{}
28	3	4	5	2	com_banners.category.3	Uncategorised	{}
29	7	14	15	2	com_contact.category.4	Uncategorised	{}
30	19	88	89	2	com_newsfeeds.category.5	Uncategorised	{}
32	24	100	101	2	com_users.category.7	Uncategorised	{}
33	1	105	106	1	com_finder	com_finder	{"core.admin":{"7":1},"core.manage":{"6":1}}
34	1	107	108	1	com_joomlaupdate	com_joomlaupdate	{}
35	1	109	110	1	com_tags	com_tags	{}
36	1	111	112	1	com_contenthistory	com_contenthistory	{}
37	1	113	114	1	com_ajax	com_ajax	{}
38	1	115	116	1	com_postinstall	com_postinstall	{}
39	18	42	43	2	com_modules.module.1	Main Menu	{}
40	18	44	45	2	com_modules.module.2	Login	{}
41	18	46	47	2	com_modules.module.3	Popular Articles	{}
42	18	48	49	2	com_modules.module.4	Recently Added Articles	{}
43	18	50	51	2	com_modules.module.8	Toolbar	{}
44	18	52	53	2	com_modules.module.9	Quick Icons	{}
45	18	54	55	2	com_modules.module.10	Logged-in Users	{}
46	18	56	57	2	com_modules.module.12	Admin Menu	{}
47	18	58	59	2	com_modules.module.13	Admin Submenu	{}
48	18	60	61	2	com_modules.module.14	User Status	{}
49	18	62	63	2	com_modules.module.15	Title	{}
50	18	64	65	2	com_modules.module.16	Login Form	{}
51	18	66	67	2	com_modules.module.17	Breadcrumbs	{}
52	18	68	69	2	com_modules.module.79	Multilanguage status	{}
53	18	70	71	2	com_modules.module.86	Joomla Version	{}
54	18	72	73	2	com_modules.module.87	Popular Tags	{"core.delete":{"6":1},"core.edit":{"6":1,"4":1},"core.edit.state":{"6":1,"5":1}}
55	18	74	75	2	com_modules.module.88	Site Information	{"core.delete":{"6":1},"core.edit":{"6":1,"4":1},"core.edit.state":{"6":1,"5":1}}
56	18	76	77	2	com_modules.module.89	Release News	{"core.delete":{"6":1},"core.edit":{"6":1,"4":1},"core.edit.state":{"6":1,"5":1}}
57	18	78	79	2	com_modules.module.90	Latest Articles	{"core.delete":{"6":1},"core.edit":{"6":1,"4":1},"core.edit.state":{"6":1,"5":1}}
58	18	80	81	2	com_modules.module.91	User Menu	{"core.delete":{"6":1},"core.edit":{"6":1,"4":1},"core.edit.state":{"6":1,"5":1}}
59	18	82	83	2	com_modules.module.92	Image Module	{"core.delete":{"6":1},"core.edit":{"6":1,"4":1},"core.edit.state":{"6":1,"5":1}}
60	18	84	85	2	com_modules.module.93	Search	{"core.delete":{"6":1},"core.edit":{"6":1,"4":1},"core.edit.state":{"6":1,"5":1}}
61	27	19	20	3	com_content.article.1	Getting Started	{"core.delete":{"6":1},"core.edit":{"6":1,"4":1},"core.edit.state":{"6":1,"5":1}}
62	1	117	118	1	#__ucm_content.1	#__ucm_content.1	{}
63	1	119	120	1	com_privacy	com_privacy	{"core.admin":{"7":1}}
64	1	121	122	1	com_actionlogs	com_actionlogs	{"core.admin":{"7":1}}
\.


--
-- Name: j_assets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_assets_id_seq', 64, true);


--
-- Data for Name: j_associations; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_associations (id, context, key) FROM stdin;
\.


--
-- Data for Name: j_banner_clients; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_banner_clients (id, name, contact, email, extrainfo, state, checked_out, checked_out_time, metakey, own_prefix, metakey_prefix, purchase_type, track_clicks, track_impressions) FROM stdin;
\.


--
-- Name: j_banner_clients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_banner_clients_id_seq', 1, false);


--
-- Data for Name: j_banner_tracks; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_banner_tracks (track_date, track_type, banner_id, count) FROM stdin;
\.


--
-- Data for Name: j_banners; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_banners (id, cid, type, name, alias, imptotal, impmade, clicks, clickurl, state, catid, description, custombannercode, sticky, ordering, metakey, params, own_prefix, metakey_prefix, purchase_type, track_clicks, track_impressions, checked_out, checked_out_time, publish_up, publish_down, reset, created, language, created_by, created_by_alias, modified, modified_by, version) FROM stdin;
\.


--
-- Name: j_banners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_banners_id_seq', 1, false);


--
-- Data for Name: j_categories; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_categories (id, asset_id, parent_id, lft, rgt, level, path, extension, title, alias, note, description, published, checked_out, checked_out_time, access, params, metadesc, metakey, metadata, created_user_id, created_time, modified_user_id, modified_time, hits, language, version) FROM stdin;
1	0	0	0	11	0		system	ROOT	root			1	0	1970-01-01 00:00:00	1	{}			{}	698	2020-02-12 04:50:57	0	1970-01-01 00:00:00	0	*	1
2	27	1	1	2	1	uncategorised	com_content	Uncategorised	uncategorised			1	0	1970-01-01 00:00:00	1	{"category_layout":"","image":""}			{"author":"","robots":""}	698	2020-02-12 04:50:57	0	1970-01-01 00:00:00	0	*	1
3	28	1	3	4	1	uncategorised	com_banners	Uncategorised	uncategorised			1	0	1970-01-01 00:00:00	1	{"category_layout":"","image":""}			{"author":"","robots":""}	698	2020-02-12 04:50:57	0	1970-01-01 00:00:00	0	*	1
4	29	1	5	6	1	uncategorised	com_contact	Uncategorised	uncategorised			1	0	1970-01-01 00:00:00	1	{"category_layout":"","image":""}			{"author":"","robots":""}	698	2020-02-12 04:50:57	0	1970-01-01 00:00:00	0	*	1
5	30	1	7	8	1	uncategorised	com_newsfeeds	Uncategorised	uncategorised			1	0	1970-01-01 00:00:00	1	{"category_layout":"","image":""}			{"author":"","robots":""}	698	2020-02-12 04:50:57	0	1970-01-01 00:00:00	0	*	1
7	32	1	9	10	1	uncategorised	com_users	Uncategorised	uncategorised			1	0	1970-01-01 00:00:00	1	{"category_layout":"","image":""}			{"author":"","robots":""}	698	2020-02-12 04:50:57	0	1970-01-01 00:00:00	0	*	1
\.


--
-- Name: j_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_categories_id_seq', 8, false);


--
-- Data for Name: j_contact_details; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_contact_details (id, name, alias, con_position, address, suburb, state, country, postcode, telephone, fax, misc, image, email_to, default_con, published, checked_out, checked_out_time, ordering, params, user_id, catid, access, mobile, webpage, sortname1, sortname2, sortname3, language, created, created_by, created_by_alias, modified, modified_by, metakey, metadesc, metadata, featured, xreference, publish_up, publish_down, version, hits) FROM stdin;
\.


--
-- Name: j_contact_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_contact_details_id_seq', 1, false);


--
-- Data for Name: j_content; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_content (id, asset_id, title, alias, introtext, fulltext, state, catid, created, created_by, created_by_alias, modified, modified_by, checked_out, checked_out_time, publish_up, publish_down, images, urls, attribs, version, ordering, metakey, metadesc, access, hits, metadata, featured, language, xreference, note) FROM stdin;
1	61	Getting Started	getting-started	<p>It's easy to get started creating your website. Knowing some of the basics will help.</p><h3>What is a Content Management System?</h3><p>A content management system is software that allows you to create and manage webpages easily by separating the creation of your content from the mechanics required to present it on the web.</p><p>In this site, the content is stored in a <em>database</em>. The look and feel are created by a <em>template</em>. Joomla! brings together the template and your content to create web pages.</p><h3>Logging in</h3><p>To login to your site use the user name and password that were created as part of the installation process. Once logged-in you will be able to create and edit articles and modify some settings.</p><h3>Creating an article</h3><p>Once you are logged-in, a new menu will be visible. To create a new article, click on the "Submit Article" link on that menu.</p><p>The new article interface gives you a lot of options, but all you need to do is add a title and put something in the content area. To make it easy to find, set the state to published.</p><div>You can edit an existing article by clicking on the edit icon (this only displays to users who have the right to edit).</div><h3>Template, site settings, and modules</h3><p>The look and feel of your site is controlled by a template. You can change the site name, background colour, highlights colour and more by editing the template settings. Click the "Template Settings" in the user menu.</p><p>The boxes around the main content of the site are called modules. You can modify modules on the current page by moving your cursor to the module and clicking the edit link. Always be sure to save and close any module you edit.</p><p>You can change some site settings such as the site name and description by clicking on the "Site Settings" link.</p><p>More advanced options for templates, site settings, modules, and more are available in the site administrator.</p><h3>Site and Administrator</h3><p>Your site actually has two separate sites. The site (also called the front end) is what visitors to your site will see. The administrator (also called the back end) is only used by people managing your site. You can access the administrator by clicking the "Site Administrator" link on the "User Menu" menu (visible once you login) or by adding /administrator to the end of your domain name. The same user name and password are used for both sites.</p><h3>Learn more</h3><p>There is much more to learn about how to use Joomla! to create the website you envision. You can learn much more at the <a href="https://docs.joomla.org/" target="_blank">Joomla! documentation site</a> and on the<a href="https://forum.joomla.org/" target="_blank"> Joomla! forums</a>.</p>		1	2	2020-02-12 04:50:57	698		1970-01-01 00:00:00	0	0	1970-01-01 00:00:00	2020-02-12 04:50:57	1970-01-01 00:00:00	{"image_intro":"","float_intro":"","image_intro_alt":"","image_intro_caption":"","image_fulltext":"","float_fulltext":"","image_fulltext_alt":"","image_fulltext_caption":""}	{"urla":false,"urlatext":"","targeta":"","urlb":false,"urlbtext":"","targetb":"","urlc":false,"urlctext":"","targetc":""}	{"show_title":"","link_titles":"","show_tags":"","show_intro":"","info_block_position":"","show_category":"","link_category":"","show_parent_category":"","link_parent_category":"","show_author":"","link_author":"","show_create_date":"","show_modify_date":"","show_publish_date":"","show_item_navigation":"","show_icons":"","show_print_icon":"","show_email_icon":"","show_vote":"","show_hits":"","show_noauth":"","urls_position":"","alternative_readmore":"","article_layout":"","show_publishing_options":"","show_article_options":"","show_urls_images_backend":"","show_urls_images_frontend":""}	1	0			1	0	{"robots":"","author":"","rights":"","xreference":""}	0	*		
\.


--
-- Data for Name: j_content_frontpage; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_content_frontpage (content_id, ordering) FROM stdin;
\.


--
-- Name: j_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_content_id_seq', 1, true);


--
-- Data for Name: j_content_rating; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_content_rating (content_id, rating_sum, rating_count, lastip) FROM stdin;
\.


--
-- Data for Name: j_content_types; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_content_types (type_id, type_title, type_alias, "table", rules, field_mappings, router, content_history_options) FROM stdin;
1	Article	com_content.article	{"special":{"dbtable":"#__content","key":"id","type":"Content","prefix":"JTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"title","core_state":"state","core_alias":"alias","core_created_time":"created","core_modified_time":"modified","core_body":"introtext", "core_hits":"hits","core_publish_up":"publish_up","core_publish_down":"publish_down","core_access":"access", "core_params":"attribs", "core_featured":"featured", "core_metadata":"metadata", "core_language":"language", "core_images":"images", "core_urls":"urls", "core_version":"version", "core_ordering":"ordering", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"catid", "core_xreference":"xreference", "asset_id":"asset_id", "note":"note"}, "special":{"fulltext":"fulltext"}}	ContentHelperRoute::getArticleRoute	{"formFile":"administrator\\/components\\/com_content\\/models\\/forms\\/article.xml", "hideFields":["asset_id","checked_out","checked_out_time","version"],"ignoreChanges":["modified_by", "modified", "checked_out", "checked_out_time", "version", "hits", "ordering"],"convertToInt":["publish_up", "publish_down", "featured", "ordering"],"displayLookup":[{"sourceColumn":"catid","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"created_by","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"access","targetTable":"#__viewlevels","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"modified_by","targetTable":"#__users","targetColumn":"id","displayColumn":"name"} ]}
2	Contact	com_contact.contact	{"special":{"dbtable":"#__contact_details","key":"id","type":"Contact","prefix":"ContactTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"name","core_state":"published","core_alias":"alias","core_created_time":"created","core_modified_time":"modified","core_body":"address", "core_hits":"hits","core_publish_up":"publish_up","core_publish_down":"publish_down","core_access":"access", "core_params":"params", "core_featured":"featured", "core_metadata":"metadata", "core_language":"language", "core_images":"image", "core_urls":"webpage", "core_version":"version", "core_ordering":"ordering", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"catid", "core_xreference":"xreference", "asset_id":"null"}, "special":{"con_position":"con_position","suburb":"suburb","state":"state","country":"country","postcode":"postcode","telephone":"telephone","fax":"fax","misc":"misc","email_to":"email_to","default_con":"default_con","user_id":"user_id","mobile":"mobile","sortname1":"sortname1","sortname2":"sortname2","sortname3":"sortname3"}}	ContactHelperRoute::getContactRoute	{"formFile":"administrator\\/components\\/com_contact\\/models\\/forms\\/contact.xml","hideFields":["default_con","checked_out","checked_out_time","version","xreference"],"ignoreChanges":["modified_by", "modified", "checked_out", "checked_out_time", "version", "hits"],"convertToInt":["publish_up", "publish_down", "featured", "ordering"], "displayLookup":[ {"sourceColumn":"created_by","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"catid","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"modified_by","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"access","targetTable":"#__viewlevels","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"} ] }
3	Newsfeed	com_newsfeeds.newsfeed	{"special":{"dbtable":"#__newsfeeds","key":"id","type":"Newsfeed","prefix":"NewsfeedsTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"name","core_state":"published","core_alias":"alias","core_created_time":"created","core_modified_time":"modified","core_body":"description", "core_hits":"hits","core_publish_up":"publish_up","core_publish_down":"publish_down","core_access":"access", "core_params":"params", "core_featured":"featured", "core_metadata":"metadata", "core_language":"language", "core_images":"images", "core_urls":"link", "core_version":"version", "core_ordering":"ordering", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"catid", "core_xreference":"xreference", "asset_id":"null"}, "special":{"numarticles":"numarticles","cache_time":"cache_time","rtl":"rtl"}}	NewsfeedsHelperRoute::getNewsfeedRoute	{"formFile":"administrator\\/components\\/com_newsfeeds\\/models\\/forms\\/newsfeed.xml","hideFields":["asset_id","checked_out","checked_out_time","version"],"ignoreChanges":["modified_by", "modified", "checked_out", "checked_out_time", "version", "hits"],"convertToInt":["publish_up", "publish_down", "featured", "ordering"],"displayLookup":[{"sourceColumn":"catid","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"created_by","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"access","targetTable":"#__viewlevels","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"modified_by","targetTable":"#__users","targetColumn":"id","displayColumn":"name"} ]}
4	User	com_users.user	{"special":{"dbtable":"#__users","key":"id","type":"User","prefix":"JTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"name","core_state":"null","core_alias":"username","core_created_time":"registerdate","core_modified_time":"lastvisitDate","core_body":"null", "core_hits":"null","core_publish_up":"null","core_publish_down":"null","access":"null", "core_params":"params", "core_featured":"null", "core_metadata":"null", "core_language":"null", "core_images":"null", "core_urls":"null", "core_version":"null", "core_ordering":"null", "core_metakey":"null", "core_metadesc":"null", "core_catid":"null", "core_xreference":"null", "asset_id":"null"}, "special":{}}	UsersHelperRoute::getUserRoute	
5	Article Category	com_content.category	{"special":{"dbtable":"#__categories","key":"id","type":"Category","prefix":"JTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"title","core_state":"published","core_alias":"alias","core_created_time":"created_time","core_modified_time":"modified_time","core_body":"description", "core_hits":"hits","core_publish_up":"null","core_publish_down":"null","core_access":"access", "core_params":"params", "core_featured":"null", "core_metadata":"metadata", "core_language":"language", "core_images":"null", "core_urls":"null", "core_version":"version", "core_ordering":"null", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"parent_id", "core_xreference":"null", "asset_id":"asset_id"}, "special":{"parent_id":"parent_id","lft":"lft","rgt":"rgt","level":"level","path":"path","extension":"extension","note":"note"}}	ContentHelperRoute::getCategoryRoute	{"formFile":"administrator\\/components\\/com_categories\\/models\\/forms\\/category.xml", "hideFields":["asset_id","checked_out","checked_out_time","version","lft","rgt","level","path","extension"], "ignoreChanges":["modified_user_id", "modified_time", "checked_out", "checked_out_time", "version", "hits", "path"],"convertToInt":["publish_up", "publish_down"], "displayLookup":[{"sourceColumn":"created_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"access","targetTable":"#__viewlevels","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"modified_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"parent_id","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"}]}
6	Contact Category	com_contact.category	{"special":{"dbtable":"#__categories","key":"id","type":"Category","prefix":"JTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"title","core_state":"published","core_alias":"alias","core_created_time":"created_time","core_modified_time":"modified_time","core_body":"description", "core_hits":"hits","core_publish_up":"null","core_publish_down":"null","core_access":"access", "core_params":"params", "core_featured":"null", "core_metadata":"metadata", "core_language":"language", "core_images":"null", "core_urls":"null", "core_version":"version", "core_ordering":"null", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"parent_id", "core_xreference":"null", "asset_id":"asset_id"}, "special":{"parent_id":"parent_id","lft":"lft","rgt":"rgt","level":"level","path":"path","extension":"extension","note":"note"}}	ContactHelperRoute::getCategoryRoute	{"formFile":"administrator\\/components\\/com_categories\\/models\\/forms\\/category.xml", "hideFields":["asset_id","checked_out","checked_out_time","version","lft","rgt","level","path","extension"], "ignoreChanges":["modified_user_id", "modified_time", "checked_out", "checked_out_time", "version", "hits", "path"],"convertToInt":["publish_up", "publish_down"], "displayLookup":[{"sourceColumn":"created_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"access","targetTable":"#__viewlevels","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"modified_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"parent_id","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"}]}
7	Newsfeeds Category	com_newsfeeds.category	{"special":{"dbtable":"#__categories","key":"id","type":"Category","prefix":"JTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"title","core_state":"published","core_alias":"alias","core_created_time":"created_time","core_modified_time":"modified_time","core_body":"description", "core_hits":"hits","core_publish_up":"null","core_publish_down":"null","core_access":"access", "core_params":"params", "core_featured":"null", "core_metadata":"metadata", "core_language":"language", "core_images":"null", "core_urls":"null", "core_version":"version", "core_ordering":"null", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"parent_id", "core_xreference":"null", "asset_id":"asset_id"}, "special":{"parent_id":"parent_id","lft":"lft","rgt":"rgt","level":"level","path":"path","extension":"extension","note":"note"}}	NewsfeedsHelperRoute::getCategoryRoute	{"formFile":"administrator\\/components\\/com_categories\\/models\\/forms\\/category.xml", "hideFields":["asset_id","checked_out","checked_out_time","version","lft","rgt","level","path","extension"], "ignoreChanges":["modified_user_id", "modified_time", "checked_out", "checked_out_time", "version", "hits", "path"],"convertToInt":["publish_up", "publish_down"], "displayLookup":[{"sourceColumn":"created_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"access","targetTable":"#__viewlevels","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"modified_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"parent_id","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"}]}
8	Tag	com_tags.tag	{"special":{"dbtable":"#__tags","key":"tag_id","type":"Tag","prefix":"TagsTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"title","core_state":"published","core_alias":"alias","core_created_time":"created_time","core_modified_time":"modified_time","core_body":"description", "core_hits":"hits","core_publish_up":"null","core_publish_down":"null","core_access":"access", "core_params":"params", "core_featured":"featured", "core_metadata":"metadata", "core_language":"language", "core_images":"images", "core_urls":"urls", "core_version":"version", "core_ordering":"null", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"null", "core_xreference":"null", "asset_id":"null"}, "special":{"parent_id":"parent_id","lft":"lft","rgt":"rgt","level":"level","path":"path"}}	TagsHelperRoute::getTagRoute	{"formFile":"administrator\\/components\\/com_tags\\/models\\/forms\\/tag.xml", "hideFields":["checked_out","checked_out_time","version", "lft", "rgt", "level", "path", "urls", "publish_up", "publish_down"],"ignoreChanges":["modified_user_id", "modified_time", "checked_out", "checked_out_time", "version", "hits", "path"],"convertToInt":["publish_up", "publish_down"], "displayLookup":[{"sourceColumn":"created_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"}, {"sourceColumn":"access","targetTable":"#__viewlevels","targetColumn":"id","displayColumn":"title"}, {"sourceColumn":"modified_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"}]}
9	Banner	com_banners.banner	{"special":{"dbtable":"#__banners","key":"id","type":"Banner","prefix":"BannersTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"name","core_state":"published","core_alias":"alias","core_created_time":"created","core_modified_time":"modified","core_body":"description", "core_hits":"null","core_publish_up":"publish_up","core_publish_down":"publish_down","core_access":"access", "core_params":"params", "core_featured":"null", "core_metadata":"metadata", "core_language":"language", "core_images":"images", "core_urls":"link", "core_version":"version", "core_ordering":"ordering", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"catid", "core_xreference":"null", "asset_id":"null"}, "special":{"imptotal":"imptotal", "impmade":"impmade", "clicks":"clicks", "clickurl":"clickurl", "custombannercode":"custombannercode", "cid":"cid", "purchase_type":"purchase_type", "track_impressions":"track_impressions", "track_clicks":"track_clicks"}}		{"formFile":"administrator\\/components\\/com_banners\\/models\\/forms\\/banner.xml", "hideFields":["checked_out","checked_out_time","version", "reset"],"ignoreChanges":["modified_by", "modified", "checked_out", "checked_out_time", "version", "imptotal", "impmade", "reset"], "convertToInt":["publish_up", "publish_down", "ordering"], "displayLookup":[{"sourceColumn":"catid","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"}, {"sourceColumn":"cid","targetTable":"#__banner_clients","targetColumn":"id","displayColumn":"name"}, {"sourceColumn":"created_by","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"modified_by","targetTable":"#__users","targetColumn":"id","displayColumn":"name"} ]}
10	Banners Category	com_banners.category	{"special":{"dbtable":"#__categories","key":"id","type":"Category","prefix":"JTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"title","core_state":"published","core_alias":"alias","core_created_time":"created_time","core_modified_time":"modified_time","core_body":"description", "core_hits":"hits","core_publish_up":"null","core_publish_down":"null","core_access":"access", "core_params":"params", "core_featured":"null", "core_metadata":"metadata", "core_language":"language", "core_images":"null", "core_urls":"null", "core_version":"version", "core_ordering":"null", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"parent_id", "core_xreference":"null", "asset_id":"asset_id"}, "special": {"parent_id":"parent_id","lft":"lft","rgt":"rgt","level":"level","path":"path","extension":"extension","note":"note"}}		{"formFile":"administrator\\/components\\/com_categories\\/models\\/forms\\/category.xml", "hideFields":["asset_id","checked_out","checked_out_time","version","lft","rgt","level","path","extension"], "ignoreChanges":["modified_user_id", "modified_time", "checked_out", "checked_out_time", "version", "hits", "path"], "convertToInt":["publish_up", "publish_down"], "displayLookup":[{"sourceColumn":"created_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"access","targetTable":"#__viewlevels","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"modified_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"parent_id","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"}]}
11	Banner Client	com_banners.client	{"special":{"dbtable":"#__banner_clients","key":"id","type":"Client","prefix":"BannersTable"}}				{"formFile":"administrator\\/components\\/com_banners\\/models\\/forms\\/client.xml", "hideFields":["checked_out","checked_out_time"], "ignoreChanges":["checked_out", "checked_out_time"], "convertToInt":[], "displayLookup":[]}
12	User Notes	com_users.note	{"special":{"dbtable":"#__user_notes","key":"id","type":"Note","prefix":"UsersTable"}}				{"formFile":"administrator\\/components\\/com_users\\/models\\/forms\\/note.xml", "hideFields":["checked_out","checked_out_time", "publish_up", "publish_down"],"ignoreChanges":["modified_user_id", "modified_time", "checked_out", "checked_out_time"], "convertToInt":["publish_up", "publish_down"],"displayLookup":[{"sourceColumn":"catid","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"}, {"sourceColumn":"created_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"}, {"sourceColumn":"user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"}, {"sourceColumn":"modified_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"}]}
13	User Notes Category	com_users.category	{"special":{"dbtable":"#__categories","key":"id","type":"Category","prefix":"JTable","config":"array()"},"common":{"dbtable":"#__ucm_content","key":"ucm_id","type":"Corecontent","prefix":"JTable","config":"array()"}}		{"common":{"core_content_item_id":"id","core_title":"title","core_state":"published","core_alias":"alias","core_created_time":"created_time","core_modified_time":"modified_time","core_body":"description", "core_hits":"hits","core_publish_up":"null","core_publish_down":"null","core_access":"access", "core_params":"params", "core_featured":"null", "core_metadata":"metadata", "core_language":"language", "core_images":"null", "core_urls":"null", "core_version":"version", "core_ordering":"null", "core_metakey":"metakey", "core_metadesc":"metadesc", "core_catid":"parent_id", "core_xreference":"null", "asset_id":"asset_id"}, "special":{"parent_id":"parent_id","lft":"lft","rgt":"rgt","level":"level","path":"path","extension":"extension","note":"note"}}		{"formFile":"administrator\\/components\\/com_categories\\/models\\/forms\\/category.xml", "hideFields":["checked_out","checked_out_time","version","lft","rgt","level","path","extension"], "ignoreChanges":["modified_user_id", "modified_time", "checked_out", "checked_out_time", "version", "hits", "path"], "convertToInt":["publish_up", "publish_down"], "displayLookup":[{"sourceColumn":"created_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"}, {"sourceColumn":"access","targetTable":"#__viewlevels","targetColumn":"id","displayColumn":"title"},{"sourceColumn":"modified_user_id","targetTable":"#__users","targetColumn":"id","displayColumn":"name"},{"sourceColumn":"parent_id","targetTable":"#__categories","targetColumn":"id","displayColumn":"title"}]}
\.


--
-- Name: j_content_types_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_content_types_type_id_seq', 10000, false);


--
-- Data for Name: j_contentitem_tag_map; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_contentitem_tag_map (type_alias, core_content_id, content_item_id, tag_id, tag_date, type_id) FROM stdin;
com_content.article	1	1	2	2020-02-12 04:50:57	1
\.


--
-- Data for Name: j_core_log_searches; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_core_log_searches (search_term, hits) FROM stdin;
\.


--
-- Data for Name: j_extensions; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_extensions (extension_id, package_id, name, type, element, folder, client_id, enabled, access, protected, manifest_cache, params, custom_data, system_data, checked_out, checked_out_time, ordering, state) FROM stdin;
5	0	com_cache	component	com_cache		1	1	1	1	{"name":"com_cache","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_CACHE_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
7	0	com_checkin	component	com_checkin		1	1	1	1	{"name":"com_checkin","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_CHECKIN_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
9	0	com_cpanel	component	com_cpanel		1	1	1	1	{"name":"com_cpanel","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_CPANEL_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
10	0	com_installer	component	com_installer		1	1	1	1	{"name":"com_installer","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_INSTALLER_XML_DESCRIPTION","group":""}	{"show_jed_info":"1","cachetimeout":"6","minimum_stability":"4"}			0	1970-01-01 00:00:00	0	0
11	0	com_languages	component	com_languages		1	1	1	1	{"name":"com_languages","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_LANGUAGES_XML_DESCRIPTION","group":""}	{"administrator":"en-GB","site":"en-GB"}			0	1970-01-01 00:00:00	0	0
12	0	com_login	component	com_login		1	1	1	1	{"name":"com_login","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_LOGIN_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
14	0	com_menus	component	com_menus		1	1	1	1	{"name":"com_menus","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_MENUS_XML_DESCRIPTION","group":""}	{"page_title":"","show_page_heading":0,"page_heading":"","pageclass_sfx":""}			0	1970-01-01 00:00:00	0	0
15	0	com_messages	component	com_messages		1	1	1	1	{"name":"com_messages","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_MESSAGES_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
16	0	com_modules	component	com_modules		1	1	1	1	{"name":"com_modules","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_MODULES_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
18	0	com_plugins	component	com_plugins		1	1	1	1	{"name":"com_plugins","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_PLUGINS_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
19	0	com_search	component	com_search		1	1	1	0	{"name":"com_search","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_SEARCH_XML_DESCRIPTION","group":"","filename":"search"}	{"enabled":"0","search_phrases":"1","search_areas":"1","show_date":"1","opensearch_name":"","opensearch_description":""}			0	1970-01-01 00:00:00	0	0
20	0	com_templates	component	com_templates		1	1	1	1	{"name":"com_templates","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_TEMPLATES_XML_DESCRIPTION","group":""}	{"template_positions_display":"0","upload_limit":"10","image_formats":"gif,bmp,jpg,jpeg,png","source_formats":"txt,less,ini,xml,js,php,css,scss,sass","font_formats":"woff,ttf,otf","compressed_formats":"zip"}			0	1970-01-01 00:00:00	0	0
24	0	com_redirect	component	com_redirect		1	1	0	1	{"name":"com_redirect","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_REDIRECT_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
28	0	com_joomlaupdate	component	com_joomlaupdate		1	1	0	1	{"name":"com_joomlaupdate","type":"component","creationDate":"February 2012","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.6.2","description":"COM_JOOMLAUPDATE_XML_DESCRIPTION","group":""}	{"updatesource":"default","customurl":""}			0	1970-01-01 00:00:00	0	0
30	0	com_contenthistory	component	com_contenthistory		1	1	1	0	{"name":"com_contenthistory","type":"component","creationDate":"May 2013","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.2.0","description":"COM_CONTENTHISTORY_XML_DESCRIPTION","group":"","filename":"contenthistory"}				0	1970-01-01 00:00:00	0	0
31	0	com_ajax	component	com_ajax		1	1	1	1	{"name":"com_ajax","type":"component","creationDate":"August 2013","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.2.0","description":"COM_AJAX_XML_DESCRIPTION","group":"","filename":"ajax"}				0	1970-01-01 00:00:00	0	0
32	0	com_postinstall	component	com_postinstall		1	1	1	1	{"name":"com_postinstall","type":"component","creationDate":"September 2013","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.2.0","description":"COM_POSTINSTALL_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
33	0	com_fields	component	com_fields		1	1	1	0	{"name":"com_fields","type":"component","creationDate":"March 2016","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"COM_FIELDS_XML_DESCRIPTION","group":"","filename":"fields"}				0	1970-01-01 00:00:00	0	0
34	0	com_associations	component	com_associations		1	1	1	0	{"name":"com_associations","type":"component","creationDate":"January 2017","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"COM_ASSOCIATIONS_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
35	0	com_privacy	component	com_privacy		1	1	1	1	{"name":"com_privacy","type":"component","creationDate":"May 2018","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"COM_PRIVACY_XML_DESCRIPTION","group":"","filename":"privacy"}				0	1970-01-01 00:00:00	0	0
102	0	LIB_PHPUTF8	library	phputf8		0	1	1	1	{"name":"LIB_PHPUTF8","type":"library","creationDate":"2006","author":"Harry Fuecks","copyright":"Copyright various authors","authorEmail":"hfuecks@gmail.com","authorUrl":"http:\\/\\/sourceforge.net\\/projects\\/phputf8","version":"0.5","description":"LIB_PHPUTF8_XML_DESCRIPTION","group":"","filename":"phputf8"}				0	1970-01-01 00:00:00	0	0
106	0	LIB_PHPASS	library	phpass		0	1	1	1	{"name":"LIB_PHPASS","type":"library","creationDate":"2004-2006","author":"Solar Designer","copyright":"","authorEmail":"solar@openwall.com","authorUrl":"http:\\/\\/www.openwall.com\\/phpass\\/","version":"0.3","description":"LIB_PHPASS_XML_DESCRIPTION","group":"","filename":"phpass"}				0	1970-01-01 00:00:00	0	0
203	0	mod_banners	module	mod_banners		0	1	1	0	{"name":"mod_banners","type":"module","creationDate":"July 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_BANNERS_XML_DESCRIPTION","group":"","filename":"mod_banners"}				0	1970-01-01 00:00:00	0	0
206	0	mod_feed	module	mod_feed		0	1	1	0	{"name":"mod_feed","type":"module","creationDate":"July 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_FEED_XML_DESCRIPTION","group":"","filename":"mod_feed"}				0	1970-01-01 00:00:00	0	0
209	0	mod_menu	module	mod_menu		0	1	1	1	{"name":"mod_menu","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_MENU_XML_DESCRIPTION","group":"","filename":"mod_menu"}				0	1970-01-01 00:00:00	0	0
213	0	mod_search	module	mod_search		0	1	1	0	{"name":"mod_search","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_SEARCH_XML_DESCRIPTION","group":"","filename":"mod_search"}				0	1970-01-01 00:00:00	0	0
218	0	mod_whosonline	module	mod_whosonline		0	1	1	0	{"name":"mod_whosonline","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_WHOSONLINE_XML_DESCRIPTION","group":"","filename":"mod_whosonline"}				0	1970-01-01 00:00:00	0	0
471	0	plg_fields_sql	plugin	sql	fields	0	1	1	0	{"name":"plg_fields_sql","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_SQL_XML_DESCRIPTION","group":"","filename":"sql"}				0	1970-01-01 00:00:00	0	0
301	0	mod_feed	module	mod_feed		1	1	1	0	{"name":"mod_feed","type":"module","creationDate":"July 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_FEED_XML_DESCRIPTION","group":"","filename":"mod_feed"}				0	1970-01-01 00:00:00	0	0
304	0	mod_login	module	mod_login		1	1	1	1	{"name":"mod_login","type":"module","creationDate":"March 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_LOGIN_XML_DESCRIPTION","group":"","filename":"mod_login"}				0	1970-01-01 00:00:00	0	0
309	0	mod_status	module	mod_status		1	1	1	0	{"name":"mod_status","type":"module","creationDate":"February 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_STATUS_XML_DESCRIPTION","group":"","filename":"mod_status"}				0	1970-01-01 00:00:00	0	0
313	0	mod_multilangstatus	module	mod_multilangstatus		1	1	1	0	{"name":"mod_multilangstatus","type":"module","creationDate":"September 2011","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_MULTILANGSTATUS_XML_DESCRIPTION","group":"","filename":"mod_multilangstatus"}	{"cache":"0"}			0	1970-01-01 00:00:00	0	0
316	0	mod_tags_popular	module	mod_tags_popular		0	1	1	0	{"name":"mod_tags_popular","type":"module","creationDate":"January 2013","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.1.0","description":"MOD_TAGS_POPULAR_XML_DESCRIPTION","group":"","filename":"mod_tags_popular"}	{"maximum":"5","timeframe":"alltime","owncache":"1"}			0	1970-01-01 00:00:00	0	0
319	0	mod_latestactions	module	mod_latestactions		1	1	1	0	{"name":"mod_latestactions","type":"module","creationDate":"May 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"MOD_LATESTACTIONS_XML_DESCRIPTION","group":"","filename":"mod_latestactions"}	{}			0	1970-01-01 00:00:00	0	0
401	0	plg_authentication_joomla	plugin	joomla	authentication	0	1	1	1	{"name":"plg_authentication_joomla","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_AUTH_JOOMLA_XML_DESCRIPTION","group":"","filename":"joomla"}				0	1970-01-01 00:00:00	0	0
403	0	plg_content_contact	plugin	contact	content	0	1	1	0	{"name":"plg_content_contact","type":"plugin","creationDate":"January 2014","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.2.2","description":"PLG_CONTENT_CONTACT_XML_DESCRIPTION","group":"","filename":"contact"}				0	1970-01-01 00:00:00	1	0
407	0	plg_content_pagebreak	plugin	pagebreak	content	0	1	1	0	{"name":"plg_content_pagebreak","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_CONTENT_PAGEBREAK_XML_DESCRIPTION","group":"","filename":"pagebreak"}	{"title":"1","multipage_toc":"1","showall":"1"}			0	1970-01-01 00:00:00	4	0
411	0	plg_editors_none	plugin	none	editors	0	1	1	1	{"name":"plg_editors_none","type":"plugin","creationDate":"September 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_NONE_XML_DESCRIPTION","group":"","filename":"none"}				0	1970-01-01 00:00:00	2	0
413	0	plg_editors-xtd_article	plugin	article	editors-xtd	0	1	1	0	{"name":"plg_editors-xtd_article","type":"plugin","creationDate":"October 2009","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_ARTICLE_XML_DESCRIPTION","group":"","filename":"article"}				0	1970-01-01 00:00:00	1	0
414	0	plg_editors-xtd_image	plugin	image	editors-xtd	0	1	1	0	{"name":"plg_editors-xtd_image","type":"plugin","creationDate":"August 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_IMAGE_XML_DESCRIPTION","group":"","filename":"image"}				0	1970-01-01 00:00:00	2	0
415	0	plg_editors-xtd_pagebreak	plugin	pagebreak	editors-xtd	0	1	1	0	{"name":"plg_editors-xtd_pagebreak","type":"plugin","creationDate":"August 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_EDITORSXTD_PAGEBREAK_XML_DESCRIPTION","group":"","filename":"pagebreak"}				0	1970-01-01 00:00:00	3	0
416	0	plg_editors-xtd_readmore	plugin	readmore	editors-xtd	0	1	1	0	{"name":"plg_editors-xtd_readmore","type":"plugin","creationDate":"March 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_READMORE_XML_DESCRIPTION","group":"","filename":"readmore"}				0	1970-01-01 00:00:00	4	0
419	0	plg_search_content	plugin	content	search	0	1	1	0	{"name":"plg_search_content","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SEARCH_CONTENT_XML_DESCRIPTION","group":"","filename":"content"}	{"search_limit":"50","search_content":"1","search_archived":"1"}			0	1970-01-01 00:00:00	0	0
426	0	plg_system_log	plugin	log	system	0	1	1	1	{"name":"plg_system_log","type":"plugin","creationDate":"April 2007","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_LOG_XML_DESCRIPTION","group":"","filename":"log"}				0	1970-01-01 00:00:00	5	0
428	0	plg_system_remember	plugin	remember	system	0	1	1	1	{"name":"plg_system_remember","type":"plugin","creationDate":"April 2007","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_REMEMBER_XML_DESCRIPTION","group":"","filename":"remember"}				0	1970-01-01 00:00:00	7	0
432	0	plg_user_joomla	plugin	joomla	user	0	1	1	0	{"name":"plg_user_joomla","type":"plugin","creationDate":"December 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_USER_JOOMLA_XML_DESCRIPTION","group":"","filename":"joomla"}	{"autoregister":"1","mail_to_user":"1","forceLogout":"1"}			0	1970-01-01 00:00:00	2	0
434	0	plg_extension_joomla	plugin	joomla	extension	0	1	1	1	{"name":"plg_extension_joomla","type":"plugin","creationDate":"May 2010","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_EXTENSION_JOOMLA_XML_DESCRIPTION","group":"","filename":"joomla"}				0	1970-01-01 00:00:00	1	0
435	0	plg_content_joomla	plugin	joomla	content	0	1	1	0	{"name":"plg_content_joomla","type":"plugin","creationDate":"November 2010","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_CONTENT_JOOMLA_XML_DESCRIPTION","group":"","filename":"joomla"}				0	1970-01-01 00:00:00	0	0
437	0	plg_quickicon_joomlaupdate	plugin	joomlaupdate	quickicon	0	1	1	1	{"name":"plg_quickicon_joomlaupdate","type":"plugin","creationDate":"August 2011","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_QUICKICON_JOOMLAUPDATE_XML_DESCRIPTION","group":"","filename":"joomlaupdate"}				0	1970-01-01 00:00:00	0	0
440	0	plg_system_highlight	plugin	highlight	system	0	1	1	0	{"name":"plg_system_highlight","type":"plugin","creationDate":"August 2011","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SYSTEM_HIGHLIGHT_XML_DESCRIPTION","group":"","filename":"highlight"}				0	1970-01-01 00:00:00	7	0
443	0	plg_finder_contacts	plugin	contacts	finder	0	1	1	0	{"name":"plg_finder_contacts","type":"plugin","creationDate":"August 2011","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_FINDER_CONTACTS_XML_DESCRIPTION","group":"","filename":"contacts"}				0	1970-01-01 00:00:00	2	0
447	0	plg_finder_tags	plugin	tags	finder	0	1	1	0	{"name":"plg_finder_tags","type":"plugin","creationDate":"February 2013","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_FINDER_TAGS_XML_DESCRIPTION","group":"","filename":"tags"}				0	1970-01-01 00:00:00	0	0
451	0	plg_search_tags	plugin	tags	search	0	1	1	0	{"name":"plg_search_tags","type":"plugin","creationDate":"March 2014","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SEARCH_TAGS_XML_DESCRIPTION","group":"","filename":"tags"}	{"search_limit":"50","show_tagged_items":"1"}			0	1970-01-01 00:00:00	0	0
454	0	plg_system_stats	plugin	stats	system	0	1	1	0	{"name":"plg_system_stats","type":"plugin","creationDate":"November 2013","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.5.0","description":"PLG_SYSTEM_STATS_XML_DESCRIPTION","group":"","filename":"stats"}				0	1970-01-01 00:00:00	0	0
457	0	PLG_INSTALLER_URLINSTALLER	plugin	urlinstaller	installer	0	1	1	1	{"name":"PLG_INSTALLER_URLINSTALLER","type":"plugin","creationDate":"May 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.6.0","description":"PLG_INSTALLER_URLINSTALLER_PLUGIN_XML_DESCRIPTION","group":"","filename":"urlinstaller"}				0	1970-01-01 00:00:00	3	0
461	0	plg_system_fields	plugin	fields	system	0	1	1	0	{"name":"plg_system_fields","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_SYSTEM_FIELDS_XML_DESCRIPTION","group":"","filename":"fields"}				0	1970-01-01 00:00:00	0	0
464	0	plg_fields_color	plugin	color	fields	0	1	1	0	{"name":"plg_fields_color","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_COLOR_XML_DESCRIPTION","group":"","filename":"color"}				0	1970-01-01 00:00:00	0	0
468	0	plg_fields_list	plugin	list	fields	0	1	1	0	{"name":"plg_fields_list","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_LIST_XML_DESCRIPTION","group":"","filename":"list"}				0	1970-01-01 00:00:00	0	0
1	0	com_mailto	component	com_mailto		0	1	1	1	{"name":"com_mailto","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_MAILTO_XML_DESCRIPTION","group":"","filename":"mailto"}				0	1970-01-01 00:00:00	0	0
2	0	com_wrapper	component	com_wrapper		0	1	1	1	{"name":"com_wrapper","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.\\n\\t","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_WRAPPER_XML_DESCRIPTION","group":"","filename":"wrapper"}				0	1970-01-01 00:00:00	0	0
3	0	com_admin	component	com_admin		1	1	1	1	{"name":"com_admin","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_ADMIN_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
4	0	com_banners	component	com_banners		1	1	1	0	{"name":"com_banners","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_BANNERS_XML_DESCRIPTION","group":"","filename":"banners"}	{"purchase_type":"3","track_impressions":"0","track_clicks":"0","metakey_prefix":"","save_history":"1","history_limit":10}			0	1970-01-01 00:00:00	0	0
6	0	com_categories	component	com_categories		1	1	1	1	{"name":"com_categories","type":"component","creationDate":"December 2007","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_CATEGORIES_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
211	0	mod_random_image	module	mod_random_image		0	1	1	0	{"name":"mod_random_image","type":"module","creationDate":"July 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_RANDOM_IMAGE_XML_DESCRIPTION","group":"","filename":"mod_random_image"}				0	1970-01-01 00:00:00	0	0
473	0	plg_fields_textarea	plugin	textarea	fields	0	1	1	0	{"name":"plg_fields_textarea","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_TEXTAREA_XML_DESCRIPTION","group":"","filename":"textarea"}				0	1970-01-01 00:00:00	0	0
477	0	plg_content_fields	plugin	fields	content	0	1	1	0	{"name":"plg_content_fields","type":"plugin","creationDate":"February 2017","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_CONTENT_FIELDS_XML_DESCRIPTION","group":"","filename":"fields"}				0	1970-01-01 00:00:00	0	0
480	0	plg_system_sessiongc	plugin	sessiongc	system	0	1	1	0	{"name":"plg_system_sessiongc","type":"plugin","creationDate":"February 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.8.6","description":"PLG_SYSTEM_SESSIONGC_XML_DESCRIPTION","group":"","filename":"sessiongc"}				0	1970-01-01 00:00:00	0	0
484	0	PLG_ACTIONLOG_JOOMLA	plugin	joomla	actionlog	0	1	1	0	{"name":"PLG_ACTIONLOG_JOOMLA","type":"plugin","creationDate":"May 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_ACTIONLOG_JOOMLA_XML_DESCRIPTION","group":"","filename":"joomla"}	{}			0	1970-01-01 00:00:00	0	0
487	0	plg_privacy_user	plugin	user	privacy	0	1	1	0	{"name":"plg_privacy_user","type":"plugin","creationDate":"May 2018","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_PRIVACY_USER_XML_DESCRIPTION","group":"","filename":"user"}	{}			0	1970-01-01 00:00:00	0	0
490	0	plg_privacy_contact	plugin	contact	privacy	0	1	1	0	{"name":"plg_privacy_contact","type":"plugin","creationDate":"July 2018","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_PRIVACY_CONTACT_XML_DESCRIPTION","group":"","filename":"contact"}	{}			0	1970-01-01 00:00:00	0	0
495	0	plg_privacy_consents	plugin	consents	privacy	0	1	1	0	{"name":"plg_privacy_consents","type":"plugin","creationDate":"July 2018","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_PRIVACY_CONSENTS_XML_DESCRIPTION","group":"","filename":"consents"}	{}			0	1970-01-01 00:00:00	0	0
504	0	hathor	template	hathor		1	1	1	0	{"name":"hathor","type":"template","creationDate":"May 2010","author":"Andrea Tarr","copyright":"Copyright (C) 2005 - 2020 Open Source Matters, Inc. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"","version":"3.0.0","description":"TPL_HATHOR_XML_DESCRIPTION","group":"","filename":"templateDetails"}	{"showSiteName":"0","colourChoice":"0","boldText":"0"}			0	1970-01-01 00:00:00	0	0
507	0	isis	template	isis		1	1	1	0	{"name":"isis","type":"template","creationDate":"3\\/30\\/2012","author":"Kyle Ledbetter","copyright":"Copyright (C) 2005 - 2020 Open Source Matters, Inc. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"","version":"1.0","description":"TPL_ISIS_XML_DESCRIPTION","group":"","filename":"templateDetails"}	{"templateColor":"","logoFile":""}			0	1970-01-01 00:00:00	0	0
700	0	files_joomla	file	joomla		0	1	1	1	{"name":"files_joomla","type":"file","creationDate":"January 2020","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.15","description":"FILES_JOOMLA_XML_DESCRIPTION","group":""}				0	1970-01-01 00:00:00	0	0
8	0	com_contact	component	com_contact		1	1	1	0	{"name":"com_contact","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_CONTACT_XML_DESCRIPTION","group":"","filename":"contact"}	{"contact_layout":"_:default","show_contact_category":"hide","save_history":"1","history_limit":10,"show_contact_list":"0","presentation_style":"sliders","show_tags":"1","show_info":"1","show_name":"1","show_position":"1","show_email":"0","show_street_address":"1","show_suburb":"1","show_state":"1","show_postcode":"1","show_country":"1","show_telephone":"1","show_mobile":"1","show_fax":"1","show_webpage":"1","show_image":"1","show_misc":"1","image":"","allow_vcard":"0","show_articles":"0","articles_display_num":"10","show_profile":"0","show_user_custom_fields":["-1"],"show_links":"0","linka_name":"","linkb_name":"","linkc_name":"","linkd_name":"","linke_name":"","contact_icons":"0","icon_address":"","icon_email":"","icon_telephone":"","icon_mobile":"","icon_fax":"","icon_misc":"","category_layout":"_:default","show_category_title":"1","show_description":"1","show_description_image":"0","maxLevel":"-1","show_subcat_desc":"1","show_empty_categories":"0","show_cat_items":"1","show_cat_tags":"1","show_base_description":"1","maxLevelcat":"-1","show_subcat_desc_cat":"1","show_empty_categories_cat":"0","show_cat_items_cat":"1","filter_field":"0","show_pagination_limit":"0","show_headings":"1","show_image_heading":"0","show_position_headings":"1","show_email_headings":"0","show_telephone_headings":"1","show_mobile_headings":"0","show_fax_headings":"0","show_suburb_headings":"1","show_state_headings":"1","show_country_headings":"1","show_pagination":"2","show_pagination_results":"1","initial_sort":"ordering","captcha":"","show_email_form":"1","show_email_copy":"0","banned_email":"","banned_subject":"","banned_text":"","validate_session":"1","custom_reply":"0","redirect":"","show_feed_link":"1","sef_advanced":0,"sef_ids":0,"custom_fields_enable":"1"}			0	1970-01-01 00:00:00	0	0
13	0	com_media	component	com_media		1	1	0	1	{"name":"com_media","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_MEDIA_XML_DESCRIPTION","group":"","filename":"media"}	{"upload_extensions":"bmp,csv,doc,gif,ico,jpg,jpeg,odg,odp,ods,odt,pdf,png,ppt,txt,xcf,xls,BMP,CSV,DOC,GIF,ICO,JPG,JPEG,ODG,ODP,ODS,ODT,PDF,PNG,PPT,TXT,XCF,XLS","upload_maxsize":"10","file_path":"images","image_path":"images","restrict_uploads":"1","allowed_media_usergroup":"3","check_mime":"1","image_extensions":"bmp,gif,jpg,png","ignore_extensions":"","upload_mime":"image\\/jpeg,image\\/gif,image\\/png,image\\/bmp,application\\/msword,application\\/excel,application\\/pdf,application\\/powerpoint,text\\/plain,application\\/x-zip","upload_mime_illegal":"text\\/html"}			0	1970-01-01 00:00:00	0	0
17	0	com_newsfeeds	component	com_newsfeeds		1	1	1	0	{"name":"com_newsfeeds","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_NEWSFEEDS_XML_DESCRIPTION","group":"","filename":"newsfeeds"}	{"newsfeed_layout":"_:default","save_history":"1","history_limit":5,"show_feed_image":"1","show_feed_description":"1","show_item_description":"1","feed_character_count":"0","feed_display_order":"des","float_first":"right","float_second":"right","show_tags":"1","category_layout":"_:default","show_category_title":"1","show_description":"1","show_description_image":"1","maxLevel":"-1","show_empty_categories":"0","show_subcat_desc":"1","show_cat_items":"1","show_cat_tags":"1","show_base_description":"1","maxLevelcat":"-1","show_empty_categories_cat":"0","show_subcat_desc_cat":"1","show_cat_items_cat":"1","filter_field":"1","show_pagination_limit":"1","show_headings":"1","show_articles":"0","show_link":"1","show_pagination":"1","show_pagination_results":"1"}			0	1970-01-01 00:00:00	0	0
22	0	com_content	component	com_content		1	1	0	1	{"name":"com_content","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_CONTENT_XML_DESCRIPTION","group":"","filename":"content"}	{"article_layout":"_:default","show_title":"1","link_titles":"1","show_intro":"1","show_category":"1","link_category":"1","show_parent_category":"0","link_parent_category":"0","show_author":"1","link_author":"0","show_create_date":"0","show_modify_date":"0","show_publish_date":"1","show_item_navigation":"1","show_vote":"0","show_readmore":"1","show_readmore_title":"1","readmore_limit":"100","show_icons":"1","show_print_icon":"1","show_email_icon":"0","show_hits":"1","show_noauth":"0","show_publishing_options":"1","show_article_options":"1","save_history":"1","history_limit":10,"show_urls_images_frontend":"0","show_urls_images_backend":"1","targeta":0,"targetb":0,"targetc":0,"float_intro":"left","float_fulltext":"left","category_layout":"_:blog","show_category_title":"0","show_description":"0","show_description_image":"0","maxLevel":"1","show_empty_categories":"0","show_no_articles":"1","show_subcat_desc":"1","show_cat_num_articles":"0","show_base_description":"1","maxLevelcat":"-1","show_empty_categories_cat":"0","show_subcat_desc_cat":"1","show_cat_num_articles_cat":"1","num_leading_articles":"1","num_intro_articles":"4","num_columns":"2","num_links":"4","multi_column_order":"0","show_subcategory_content":"0","show_pagination_limit":"1","filter_field":"hide","show_headings":"1","list_show_date":"0","date_format":"","list_show_hits":"1","list_show_author":"1","orderby_pri":"order","orderby_sec":"rdate","order_date":"published","show_pagination":"2","show_pagination_results":"1","show_feed_link":"1","feed_summary":"0"}			0	1970-01-01 00:00:00	0	0
23	0	com_config	component	com_config		1	1	0	1	{"name":"com_config","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_CONFIG_XML_DESCRIPTION","group":""}	{"filters":{"1":{"filter_type":"NH","filter_tags":"","filter_attributes":""},"6":{"filter_type":"BL","filter_tags":"","filter_attributes":""},"7":{"filter_type":"BL","filter_tags":"","filter_attributes":""},"2":{"filter_type":"NH","filter_tags":"","filter_attributes":""},"3":{"filter_type":"BL","filter_tags":"","filter_attributes":""},"4":{"filter_type":"BL","filter_tags":"","filter_attributes":""},"5":{"filter_type":"BL","filter_tags":"","filter_attributes":""},"10":{"filter_type":"BL","filter_tags":"","filter_attributes":""},"12":{"filter_type":"BL","filter_tags":"","filter_attributes":""},"8":{"filter_type":"NONE","filter_tags":"","filter_attributes":""}}}			0	1970-01-01 00:00:00	0	0
25	0	com_users	component	com_users		1	1	0	1	{"name":"com_users","type":"component","creationDate":"April 2006","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_USERS_XML_DESCRIPTION","group":"","filename":"users"}	{"allowUserRegistration":"0","new_usertype":"2","guest_usergroup":"9","sendpassword":"0","useractivation":"2","mail_to_admin":"1","captcha":"","frontend_userparams":"1","site_language":"0","change_login_name":"0","reset_count":"10","reset_time":"1","minimum_length":"4","minimum_integers":"0","minimum_symbols":"0","minimum_uppercase":"0","save_history":"1","history_limit":5,"mailSubjectPrefix":"","mailBodySuffix":""}			0	1970-01-01 00:00:00	0	0
212	0	mod_related_items	module	mod_related_items		0	1	1	0	{"name":"mod_related_items","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_RELATED_XML_DESCRIPTION","group":"","filename":"mod_related_items"}				0	1970-01-01 00:00:00	0	0
27	0	com_finder	component	com_finder		1	1	0	0	{"name":"com_finder","type":"component","creationDate":"August 2011","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"COM_FINDER_XML_DESCRIPTION","group":"","filename":"finder"}	{"enabled":"0","show_description":"1","description_length":255,"allow_empty_query":"0","show_url":"1","show_autosuggest":"1","show_suggested_query":"1","show_explained_query":"1","show_advanced":"1","show_advanced_tips":"1","expand_advanced":"0","show_date_filters":"0","sort_order":"relevance","sort_direction":"desc","highlight_terms":"1","opensearch_name":"","opensearch_description":"","batch_size":"50","memory_table_limit":30000,"title_multiplier":"1.7","text_multiplier":"0.7","meta_multiplier":"1.2","path_multiplier":"2.0","misc_multiplier":"0.3","stem":"1","stemmer":"snowball","enable_logging":"0"}			0	1970-01-01 00:00:00	0	0
29	0	com_tags	component	com_tags		1	1	1	1	{"name":"com_tags","type":"component","creationDate":"December 2013","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.1.0","description":"COM_TAGS_XML_DESCRIPTION","group":"","filename":"tags"}	{"tag_layout":"_:default","save_history":"1","history_limit":5,"show_tag_title":"0","tag_list_show_tag_image":"0","tag_list_show_tag_description":"0","tag_list_image":"","tag_list_orderby":"title","tag_list_orderby_direction":"ASC","show_headings":"0","tag_list_show_date":"0","tag_list_show_item_image":"0","tag_list_show_item_description":"0","tag_list_item_maximum_characters":0,"return_any_or_all":"1","include_children":"0","maximum":200,"tag_list_language_filter":"all","tags_layout":"_:default","all_tags_orderby":"title","all_tags_orderby_direction":"ASC","all_tags_show_tag_image":"0","all_tags_show_tag_description":"0","all_tags_tag_maximum_characters":20,"all_tags_show_tag_hits":"0","filter_field":"1","show_pagination_limit":"1","show_pagination":"2","show_pagination_results":"1","tag_field_ajax_mode":"1","show_feed_link":"1"}			0	1970-01-01 00:00:00	0	0
36	0	com_actionlogs	component	com_actionlogs		1	1	1	1	{"name":"com_actionlogs","type":"component","creationDate":"May 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"COM_ACTIONLOGS_XML_DESCRIPTION","group":""}	{"ip_logging":0,"csv_delimiter":",","loggable_extensions":["com_banners","com_cache","com_categories","com_checkin","com_config","com_contact","com_content","com_installer","com_media","com_menus","com_messages","com_modules","com_newsfeeds","com_plugins","com_redirect","com_tags","com_templates","com_users"]}			0	1970-01-01 00:00:00	0	0
104	0	LIB_IDNA	library	idna_convert		0	1	1	1	{"name":"LIB_IDNA","type":"library","creationDate":"2004","author":"phlyLabs","copyright":"2004-2011 phlyLabs Berlin, http:\\/\\/phlylabs.de","authorEmail":"phlymail@phlylabs.de","authorUrl":"http:\\/\\/phlylabs.de","version":"0.8.0","description":"LIB_IDNA_XML_DESCRIPTION","group":"","filename":"idna_convert"}				0	1970-01-01 00:00:00	0	0
105	0	FOF	library	fof		0	1	1	1	{"name":"FOF","type":"library","creationDate":"2015-04-22 13:15:32","author":"Nicholas K. Dionysopoulos \\/ Akeeba Ltd","copyright":"(C)2011-2015 Nicholas K. Dionysopoulos","authorEmail":"nicholas@akeebabackup.com","authorUrl":"https:\\/\\/www.akeebabackup.com","version":"2.4.3","description":"LIB_FOF_XML_DESCRIPTION","group":"","filename":"fof"}				0	1970-01-01 00:00:00	0	0
200	0	mod_articles_archive	module	mod_articles_archive		0	1	1	0	{"name":"mod_articles_archive","type":"module","creationDate":"July 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_ARTICLES_ARCHIVE_XML_DESCRIPTION","group":"","filename":"mod_articles_archive"}				0	1970-01-01 00:00:00	0	0
201	0	mod_articles_latest	module	mod_articles_latest		0	1	1	0	{"name":"mod_articles_latest","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_LATEST_NEWS_XML_DESCRIPTION","group":"","filename":"mod_articles_latest"}				0	1970-01-01 00:00:00	0	0
202	0	mod_articles_popular	module	mod_articles_popular		0	1	1	0	{"name":"mod_articles_popular","type":"module","creationDate":"July 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_POPULAR_XML_DESCRIPTION","group":"","filename":"mod_articles_popular"}				0	1970-01-01 00:00:00	0	0
204	0	mod_breadcrumbs	module	mod_breadcrumbs		0	1	1	1	{"name":"mod_breadcrumbs","type":"module","creationDate":"July 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_BREADCRUMBS_XML_DESCRIPTION","group":"","filename":"mod_breadcrumbs"}				0	1970-01-01 00:00:00	0	0
205	0	mod_custom	module	mod_custom		0	1	1	1	{"name":"mod_custom","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_CUSTOM_XML_DESCRIPTION","group":"","filename":"mod_custom"}				0	1970-01-01 00:00:00	0	0
207	0	mod_footer	module	mod_footer		0	1	1	0	{"name":"mod_footer","type":"module","creationDate":"July 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_FOOTER_XML_DESCRIPTION","group":"","filename":"mod_footer"}				0	1970-01-01 00:00:00	0	0
208	0	mod_login	module	mod_login		0	1	1	1	{"name":"mod_login","type":"module","creationDate":"July 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_LOGIN_XML_DESCRIPTION","group":"","filename":"mod_login"}				0	1970-01-01 00:00:00	0	0
210	0	mod_articles_news	module	mod_articles_news		0	1	1	0	{"name":"mod_articles_news","type":"module","creationDate":"July 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_ARTICLES_NEWS_XML_DESCRIPTION","group":"","filename":"mod_articles_news"}				0	1970-01-01 00:00:00	0	0
214	0	mod_stats	module	mod_stats		0	1	1	0	{"name":"mod_stats","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_STATS_XML_DESCRIPTION","group":"","filename":"mod_stats"}				0	1970-01-01 00:00:00	0	0
215	0	mod_syndicate	module	mod_syndicate		0	1	1	1	{"name":"mod_syndicate","type":"module","creationDate":"May 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_SYNDICATE_XML_DESCRIPTION","group":"","filename":"mod_syndicate"}				0	1970-01-01 00:00:00	0	0
216	0	mod_users_latest	module	mod_users_latest		0	1	1	0	{"name":"mod_users_latest","type":"module","creationDate":"December 2009","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_USERS_LATEST_XML_DESCRIPTION","group":"","filename":"mod_users_latest"}				0	1970-01-01 00:00:00	0	0
219	0	mod_wrapper	module	mod_wrapper		0	1	1	0	{"name":"mod_wrapper","type":"module","creationDate":"October 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_WRAPPER_XML_DESCRIPTION","group":"","filename":"mod_wrapper"}				0	1970-01-01 00:00:00	0	0
220	0	mod_articles_category	module	mod_articles_category		0	1	1	0	{"name":"mod_articles_category","type":"module","creationDate":"February 2010","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_ARTICLES_CATEGORY_XML_DESCRIPTION","group":"","filename":"mod_articles_category"}				0	1970-01-01 00:00:00	0	0
221	0	mod_articles_categories	module	mod_articles_categories		0	1	1	0	{"name":"mod_articles_categories","type":"module","creationDate":"February 2010","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_ARTICLES_CATEGORIES_XML_DESCRIPTION","group":"","filename":"mod_articles_categories"}				0	1970-01-01 00:00:00	0	0
222	0	mod_languages	module	mod_languages		0	1	1	1	{"name":"mod_languages","type":"module","creationDate":"February 2010","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.5.0","description":"MOD_LANGUAGES_XML_DESCRIPTION","group":"","filename":"mod_languages"}				0	1970-01-01 00:00:00	0	0
223	0	mod_finder	module	mod_finder		0	1	0	0	{"name":"mod_finder","type":"module","creationDate":"August 2011","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_FINDER_XML_DESCRIPTION","group":"","filename":"mod_finder"}				0	1970-01-01 00:00:00	0	0
300	0	mod_custom	module	mod_custom		1	1	1	1	{"name":"mod_custom","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_CUSTOM_XML_DESCRIPTION","group":"","filename":"mod_custom"}				0	1970-01-01 00:00:00	0	0
302	0	mod_latest	module	mod_latest		1	1	1	0	{"name":"mod_latest","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_LATEST_XML_DESCRIPTION","group":"","filename":"mod_latest"}				0	1970-01-01 00:00:00	0	0
303	0	mod_logged	module	mod_logged		1	1	1	0	{"name":"mod_logged","type":"module","creationDate":"January 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_LOGGED_XML_DESCRIPTION","group":"","filename":"mod_logged"}				0	1970-01-01 00:00:00	0	0
305	0	mod_menu	module	mod_menu		1	1	1	0	{"name":"mod_menu","type":"module","creationDate":"March 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_MENU_XML_DESCRIPTION","group":"","filename":"mod_menu"}				0	1970-01-01 00:00:00	0	0
307	0	mod_popular	module	mod_popular		1	1	1	0	{"name":"mod_popular","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_POPULAR_XML_DESCRIPTION","group":"","filename":"mod_popular"}				0	1970-01-01 00:00:00	0	0
308	0	mod_quickicon	module	mod_quickicon		1	1	1	1	{"name":"mod_quickicon","type":"module","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_QUICKICON_XML_DESCRIPTION","group":"","filename":"mod_quickicon"}				0	1970-01-01 00:00:00	0	0
310	0	mod_submenu	module	mod_submenu		1	1	1	0	{"name":"mod_submenu","type":"module","creationDate":"February 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_SUBMENU_XML_DESCRIPTION","group":"","filename":"mod_submenu"}				0	1970-01-01 00:00:00	0	0
311	0	mod_title	module	mod_title		1	1	1	0	{"name":"mod_title","type":"module","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_TITLE_XML_DESCRIPTION","group":"","filename":"mod_title"}				0	1970-01-01 00:00:00	0	0
312	0	mod_toolbar	module	mod_toolbar		1	1	1	1	{"name":"mod_toolbar","type":"module","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_TOOLBAR_XML_DESCRIPTION","group":"","filename":"mod_toolbar"}				0	1970-01-01 00:00:00	0	0
314	0	mod_version	module	mod_version		1	1	1	0	{"name":"mod_version","type":"module","creationDate":"January 2012","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_VERSION_XML_DESCRIPTION","group":"","filename":"mod_version"}	{"format":"short","product":"1","cache":"0"}			0	1970-01-01 00:00:00	0	0
315	0	mod_stats_admin	module	mod_stats_admin		1	1	1	0	{"name":"mod_stats_admin","type":"module","creationDate":"July 2004","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"MOD_STATS_XML_DESCRIPTION","group":"","filename":"mod_stats_admin"}	{"serverinfo":"0","siteinfo":"0","counter":"0","increase":"0","cache":"1","cache_time":"900","cachemode":"static"}			0	1970-01-01 00:00:00	0	0
317	0	mod_tags_similar	module	mod_tags_similar		0	1	1	0	{"name":"mod_tags_similar","type":"module","creationDate":"January 2013","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.1.0","description":"MOD_TAGS_SIMILAR_XML_DESCRIPTION","group":"","filename":"mod_tags_similar"}	{"maximum":"5","matchtype":"any","owncache":"1"}			0	1970-01-01 00:00:00	0	0
318	0	mod_sampledata	module	mod_sampledata		1	1	1	0	{"name":"mod_sampledata","type":"module","creationDate":"July 2017","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.8.0","description":"MOD_SAMPLEDATA_XML_DESCRIPTION","group":"","filename":"mod_sampledata"}	{}			0	1970-01-01 00:00:00	0	0
320	0	mod_privacy_dashboard	module	mod_privacy_dashboard		1	1	1	0	{"name":"mod_privacy_dashboard","type":"module","creationDate":"June 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"MOD_PRIVACY_DASHBOARD_XML_DESCRIPTION","group":"","filename":"mod_privacy_dashboard"}	{}			0	1970-01-01 00:00:00	0	0
400	0	plg_authentication_gmail	plugin	gmail	authentication	0	0	1	0	{"name":"plg_authentication_gmail","type":"plugin","creationDate":"February 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_GMAIL_XML_DESCRIPTION","group":"","filename":"gmail"}	{"applysuffix":"0","suffix":"","verifypeer":"1","user_blacklist":""}			0	1970-01-01 00:00:00	1	0
402	0	plg_authentication_ldap	plugin	ldap	authentication	0	0	1	0	{"name":"plg_authentication_ldap","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_LDAP_XML_DESCRIPTION","group":"","filename":"ldap"}	{"host":"","port":"389","use_ldapV3":"0","negotiate_tls":"0","no_referrals":"0","auth_method":"bind","base_dn":"","search_string":"","users_dn":"","username":"admin","password":"bobby7","ldap_fullname":"fullName","ldap_email":"mail","ldap_uid":"uid"}			0	1970-01-01 00:00:00	3	0
404	0	plg_content_emailcloak	plugin	emailcloak	content	0	1	1	0	{"name":"plg_content_emailcloak","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_CONTENT_EMAILCLOAK_XML_DESCRIPTION","group":"","filename":"emailcloak"}	{"mode":"1"}			0	1970-01-01 00:00:00	1	0
406	0	plg_content_loadmodule	plugin	loadmodule	content	0	1	1	0	{"name":"plg_content_loadmodule","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_LOADMODULE_XML_DESCRIPTION","group":"","filename":"loadmodule"}	{"style":"xhtml"}			0	2011-09-18 15:22:50	0	0
408	0	plg_content_pagenavigation	plugin	pagenavigation	content	0	1	1	0	{"name":"plg_content_pagenavigation","type":"plugin","creationDate":"January 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_PAGENAVIGATION_XML_DESCRIPTION","group":"","filename":"pagenavigation"}	{"position":"1"}			0	1970-01-01 00:00:00	5	0
409	0	plg_content_vote	plugin	vote	content	0	0	1	0	{"name":"plg_content_vote","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_VOTE_XML_DESCRIPTION","group":"","filename":"vote"}				0	1970-01-01 00:00:00	6	0
410	0	plg_editors_codemirror	plugin	codemirror	editors	0	1	1	1	{"name":"plg_editors_codemirror","type":"plugin","creationDate":"28 March 2011","author":"Marijn Haverbeke","copyright":"Copyright (C) 2014 - 2017 by Marijn Haverbeke <marijnh@gmail.com> and others","authorEmail":"marijnh@gmail.com","authorUrl":"http:\\/\\/codemirror.net\\/","version":"5.40.0","description":"PLG_CODEMIRROR_XML_DESCRIPTION","group":"","filename":"codemirror"}	{"lineNumbers":"1","lineWrapping":"1","matchTags":"1","matchBrackets":"1","marker-gutter":"1","autoCloseTags":"1","autoCloseBrackets":"1","autoFocus":"1","theme":"default","tabmode":"indent"}			0	1970-01-01 00:00:00	1	0
433	0	plg_user_profile	plugin	profile	user	0	0	1	0	{"name":"plg_user_profile","type":"plugin","creationDate":"January 2008","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_USER_PROFILE_XML_DESCRIPTION","group":"","filename":"profile"}	{"register-require_address1":"1","register-require_address2":"1","register-require_city":"1","register-require_region":"1","register-require_country":"1","register-require_postal_code":"1","register-require_phone":"1","register-require_website":"1","register-require_favoritebook":"1","register-require_aboutme":"1","register-require_tos":"1","register-require_dob":"1","profile-require_address1":"1","profile-require_address2":"1","profile-require_city":"1","profile-require_region":"1","profile-require_country":"1","profile-require_postal_code":"1","profile-require_phone":"1","profile-require_website":"1","profile-require_favoritebook":"1","profile-require_aboutme":"1","profile-require_tos":"1","profile-require_dob":"1"}			0	1970-01-01 00:00:00	0	0
412	0	plg_editors_tinymce	plugin	tinymce	editors	0	1	1	0	{"name":"plg_editors_tinymce","type":"plugin","creationDate":"2005-2019","author":"Tiny Technologies, Inc","copyright":"Tiny Technologies, Inc","authorEmail":"N\\/A","authorUrl":"https:\\/\\/www.tiny.cloud","version":"4.5.11","description":"PLG_TINY_XML_DESCRIPTION","group":"","filename":"tinymce"}	{"configuration":{"toolbars":{"2":{"toolbar1":["bold","underline","strikethrough","|","undo","redo","|","bullist","numlist","|","pastetext"]},"1":{"menu":["edit","insert","view","format","table","tools"],"toolbar1":["bold","italic","underline","strikethrough","|","alignleft","aligncenter","alignright","alignjustify","|","formatselect","|","bullist","numlist","|","outdent","indent","|","undo","redo","|","link","unlink","anchor","code","|","hr","table","|","subscript","superscript","|","charmap","pastetext","preview"]},"0":{"menu":["edit","insert","view","format","table","tools"],"toolbar1":["bold","italic","underline","strikethrough","|","alignleft","aligncenter","alignright","alignjustify","|","styleselect","|","formatselect","fontselect","fontsizeselect","|","searchreplace","|","bullist","numlist","|","outdent","indent","|","undo","redo","|","link","unlink","anchor","image","|","code","|","forecolor","backcolor","|","fullscreen","|","table","|","subscript","superscript","|","charmap","emoticons","media","hr","ltr","rtl","|","cut","copy","paste","pastetext","|","visualchars","visualblocks","nonbreaking","blockquote","template","|","print","preview","codesample","insertdatetime","removeformat"]}},"setoptions":{"2":{"access":["1"],"skin":"0","skin_admin":"0","mobile":"0","drag_drop":"1","path":"","entity_encoding":"raw","lang_mode":"1","text_direction":"ltr","content_css":"1","content_css_custom":"","relative_urls":"1","newlines":"0","use_config_textfilters":"0","invalid_elements":"script,applet,iframe","valid_elements":"","extended_elements":"","resizing":"1","resize_horizontal":"1","element_path":"1","wordcount":"1","image_advtab":"0","advlist":"1","autosave":"1","contextmenu":"1","custom_plugin":"","custom_button":""},"1":{"access":["6","2"],"skin":"0","skin_admin":"0","mobile":"0","drag_drop":"1","path":"","entity_encoding":"raw","lang_mode":"1","text_direction":"ltr","content_css":"1","content_css_custom":"","relative_urls":"1","newlines":"0","use_config_textfilters":"0","invalid_elements":"script,applet,iframe","valid_elements":"","extended_elements":"","resizing":"1","resize_horizontal":"1","element_path":"1","wordcount":"1","image_advtab":"0","advlist":"1","autosave":"1","contextmenu":"1","custom_plugin":"","custom_button":""},"0":{"access":["7","4","8"],"skin":"0","skin_admin":"0","mobile":"0","drag_drop":"1","path":"","entity_encoding":"raw","lang_mode":"1","text_direction":"ltr","content_css":"1","content_css_custom":"","relative_urls":"1","newlines":"0","use_config_textfilters":"0","invalid_elements":"script,applet,iframe","valid_elements":"","extended_elements":"","resizing":"1","resize_horizontal":"1","element_path":"1","wordcount":"1","image_advtab":"1","advlist":"1","autosave":"1","contextmenu":"1","custom_plugin":"","custom_button":""}}},"sets_amount":3,"html_height":"550","html_width":"750"}			0	1970-01-01 00:00:00	3	0
417	0	plg_search_categories	plugin	categories	search	0	1	1	0	{"name":"plg_search_categories","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SEARCH_CATEGORIES_XML_DESCRIPTION","group":"","filename":"categories"}	{"search_limit":"50","search_content":"1","search_archived":"1"}			0	1970-01-01 00:00:00	0	0
418	0	plg_search_contacts	plugin	contacts	search	0	1	1	0	{"name":"plg_search_contacts","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SEARCH_CONTACTS_XML_DESCRIPTION","group":"","filename":"contacts"}	{"search_limit":"50","search_content":"1","search_archived":"1"}			0	1970-01-01 00:00:00	0	0
420	0	plg_search_newsfeeds	plugin	newsfeeds	search	0	1	1	0	{"name":"plg_search_newsfeeds","type":"plugin","creationDate":"November 2005","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SEARCH_NEWSFEEDS_XML_DESCRIPTION","group":"","filename":"newsfeeds"}	{"search_limit":"50","search_content":"1","search_archived":"1"}			0	1970-01-01 00:00:00	0	0
422	0	plg_system_languagefilter	plugin	languagefilter	system	0	0	1	1	{"name":"plg_system_languagefilter","type":"plugin","creationDate":"July 2010","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SYSTEM_LANGUAGEFILTER_XML_DESCRIPTION","group":"","filename":"languagefilter"}				0	1970-01-01 00:00:00	1	0
423	0	plg_system_p3p	plugin	p3p	system	0	0	1	0	{"name":"plg_system_p3p","type":"plugin","creationDate":"September 2010","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_P3P_XML_DESCRIPTION","group":"","filename":"p3p"}	{"headers":"NOI ADM DEV PSAi COM NAV OUR OTRo STP IND DEM"}			0	1970-01-01 00:00:00	2	0
424	0	plg_system_cache	plugin	cache	system	0	0	1	1	{"name":"plg_system_cache","type":"plugin","creationDate":"February 2007","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_CACHE_XML_DESCRIPTION","group":"","filename":"cache"}	{"browsercache":"0","cachetime":"15"}			0	1970-01-01 00:00:00	9	0
425	0	plg_system_debug	plugin	debug	system	0	1	1	0	{"name":"plg_system_debug","type":"plugin","creationDate":"December 2006","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_DEBUG_XML_DESCRIPTION","group":"","filename":"debug"}	{"profile":"1","queries":"1","memory":"1","language_files":"1","language_strings":"1","strip-first":"1","strip-prefix":"","strip-suffix":""}			0	1970-01-01 00:00:00	4	0
427	0	plg_system_redirect	plugin	redirect	system	0	0	1	1	{"name":"plg_system_redirect","type":"plugin","creationDate":"April 2009","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SYSTEM_REDIRECT_XML_DESCRIPTION","group":"","filename":"redirect"}				0	1970-01-01 00:00:00	3	0
429	0	plg_system_sef	plugin	sef	system	0	1	1	0	{"name":"plg_system_sef","type":"plugin","creationDate":"December 2007","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SEF_XML_DESCRIPTION","group":"","filename":"sef"}				0	1970-01-01 00:00:00	8	0
430	0	plg_system_logout	plugin	logout	system	0	1	1	1	{"name":"plg_system_logout","type":"plugin","creationDate":"April 2009","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SYSTEM_LOGOUT_XML_DESCRIPTION","group":"","filename":"logout"}				0	1970-01-01 00:00:00	6	0
431	0	plg_user_contactcreator	plugin	contactcreator	user	0	0	1	0	{"name":"plg_user_contactcreator","type":"plugin","creationDate":"August 2009","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_CONTACTCREATOR_XML_DESCRIPTION","group":"","filename":"contactcreator"}	{"autowebpage":"","category":"34","autopublish":"0"}			0	1970-01-01 00:00:00	1	0
436	0	plg_system_languagecode	plugin	languagecode	system	0	0	1	0	{"name":"plg_system_languagecode","type":"plugin","creationDate":"November 2011","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_SYSTEM_LANGUAGECODE_XML_DESCRIPTION","group":"","filename":"languagecode"}				0	1970-01-01 00:00:00	10	0
438	0	plg_quickicon_extensionupdate	plugin	extensionupdate	quickicon	0	1	1	1	{"name":"plg_quickicon_extensionupdate","type":"plugin","creationDate":"August 2011","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_QUICKICON_EXTENSIONUPDATE_XML_DESCRIPTION","group":"","filename":"extensionupdate"}				0	1970-01-01 00:00:00	0	0
439	0	plg_captcha_recaptcha	plugin	recaptcha	captcha	0	0	1	0	{"name":"plg_captcha_recaptcha","type":"plugin","creationDate":"December 2011","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.4.0","description":"PLG_CAPTCHA_RECAPTCHA_XML_DESCRIPTION","group":"","filename":"recaptcha"}	{"public_key":"","private_key":"","theme":"clean"}			0	1970-01-01 00:00:00	0	0
441	0	plg_content_finder	plugin	finder	content	0	0	1	0	{"name":"plg_content_finder","type":"plugin","creationDate":"December 2011","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_CONTENT_FINDER_XML_DESCRIPTION","group":"","filename":"finder"}				0	1970-01-01 00:00:00	0	0
442	0	plg_finder_categories	plugin	categories	finder	0	1	1	0	{"name":"plg_finder_categories","type":"plugin","creationDate":"August 2011","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_FINDER_CATEGORIES_XML_DESCRIPTION","group":"","filename":"categories"}				0	1970-01-01 00:00:00	1	0
444	0	plg_finder_content	plugin	content	finder	0	1	1	0	{"name":"plg_finder_content","type":"plugin","creationDate":"August 2011","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_FINDER_CONTENT_XML_DESCRIPTION","group":"","filename":"content"}				0	1970-01-01 00:00:00	3	0
445	0	plg_finder_newsfeeds	plugin	newsfeeds	finder	0	1	1	0	{"name":"plg_finder_newsfeeds","type":"plugin","creationDate":"August 2011","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_FINDER_NEWSFEEDS_XML_DESCRIPTION","group":"","filename":"newsfeeds"}				0	1970-01-01 00:00:00	4	0
448	0	plg_twofactorauth_totp	plugin	totp	twofactorauth	0	0	1	0	{"name":"plg_twofactorauth_totp","type":"plugin","creationDate":"August 2013","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.2.0","description":"PLG_TWOFACTORAUTH_TOTP_XML_DESCRIPTION","group":"","filename":"totp"}				0	1970-01-01 00:00:00	0	0
449	0	plg_authentication_cookie	plugin	cookie	authentication	0	1	1	0	{"name":"plg_authentication_cookie","type":"plugin","creationDate":"July 2013","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.0.0","description":"PLG_AUTH_COOKIE_XML_DESCRIPTION","group":"","filename":"cookie"}				0	1970-01-01 00:00:00	0	0
450	0	plg_twofactorauth_yubikey	plugin	yubikey	twofactorauth	0	0	1	0	{"name":"plg_twofactorauth_yubikey","type":"plugin","creationDate":"September 2013","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.2.0","description":"PLG_TWOFACTORAUTH_YUBIKEY_XML_DESCRIPTION","group":"","filename":"yubikey"}				0	1970-01-01 00:00:00	0	0
453	0	plg_editors-xtd_module	plugin	module	editors-xtd	0	1	1	0	{"name":"plg_editors-xtd_module","type":"plugin","creationDate":"October 2015","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.5.0","description":"PLG_MODULE_XML_DESCRIPTION","group":"","filename":"module"}				0	1970-01-01 00:00:00	0	0
455	0	plg_installer_packageinstaller	plugin	packageinstaller	installer	0	1	1	1	{"name":"plg_installer_packageinstaller","type":"plugin","creationDate":"May 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.6.0","description":"PLG_INSTALLER_PACKAGEINSTALLER_PLUGIN_XML_DESCRIPTION","group":"","filename":"packageinstaller"}				0	1970-01-01 00:00:00	1	0
456	0	PLG_INSTALLER_FOLDERINSTALLER	plugin	folderinstaller	installer	0	1	1	1	{"name":"PLG_INSTALLER_FOLDERINSTALLER","type":"plugin","creationDate":"May 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.6.0","description":"PLG_INSTALLER_FOLDERINSTALLER_PLUGIN_XML_DESCRIPTION","group":"","filename":"folderinstaller"}				0	1970-01-01 00:00:00	2	0
458	0	plg_quickicon_phpversioncheck	plugin	phpversioncheck	quickicon	0	1	1	1	{"name":"plg_quickicon_phpversioncheck","type":"plugin","creationDate":"August 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_QUICKICON_PHPVERSIONCHECK_XML_DESCRIPTION","group":"","filename":"phpversioncheck"}				0	1970-01-01 00:00:00	0	0
459	0	plg_editors-xtd_menu	plugin	menu	editors-xtd	0	1	1	0	{"name":"plg_editors-xtd_menu","type":"plugin","creationDate":"August 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_EDITORS-XTD_MENU_XML_DESCRIPTION","group":"","filename":"menu"}				0	1970-01-01 00:00:00	0	0
460	0	plg_editors-xtd_contact	plugin	contact	editors-xtd	0	1	1	0	{"name":"plg_editors-xtd_contact","type":"plugin","creationDate":"October 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_EDITORS-XTD_CONTACT_XML_DESCRIPTION","group":"","filename":"contact"}				0	1970-01-01 00:00:00	0	0
462	0	plg_fields_calendar	plugin	calendar	fields	0	1	1	0	{"name":"plg_fields_calendar","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_CALENDAR_XML_DESCRIPTION","group":"","filename":"calendar"}				0	1970-01-01 00:00:00	0	0
463	0	plg_fields_checkboxes	plugin	checkboxes	fields	0	1	1	0	{"name":"plg_fields_checkboxes","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_CHECKBOXES_XML_DESCRIPTION","group":"","filename":"checkboxes"}				0	1970-01-01 00:00:00	0	0
465	0	plg_fields_editor	plugin	editor	fields	0	1	1	0	{"name":"plg_fields_editor","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_EDITOR_XML_DESCRIPTION","group":"","filename":"editor"}				0	1970-01-01 00:00:00	0	0
466	0	plg_fields_imagelist	plugin	imagelist	fields	0	1	1	0	{"name":"plg_fields_imagelist","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_IMAGELIST_XML_DESCRIPTION","group":"","filename":"imagelist"}				0	1970-01-01 00:00:00	0	0
467	0	plg_fields_integer	plugin	integer	fields	0	1	1	0	{"name":"plg_fields_integer","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_INTEGER_XML_DESCRIPTION","group":"","filename":"integer"}	{"multiple":"0","first":"1","last":"100","step":"1"}			0	1970-01-01 00:00:00	0	0
469	0	plg_fields_media	plugin	media	fields	0	1	1	0	{"name":"plg_fields_media","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_MEDIA_XML_DESCRIPTION","group":"","filename":"media"}				0	1970-01-01 00:00:00	0	0
470	0	plg_fields_radio	plugin	radio	fields	0	1	1	0	{"name":"plg_fields_radio","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_RADIO_XML_DESCRIPTION","group":"","filename":"radio"}				0	1970-01-01 00:00:00	0	0
472	0	plg_fields_text	plugin	text	fields	0	1	1	0	{"name":"plg_fields_text","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_TEXT_XML_DESCRIPTION","group":"","filename":"text"}				0	1970-01-01 00:00:00	0	0
474	0	plg_fields_url	plugin	url	fields	0	1	1	0	{"name":"plg_fields_url","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_URL_XML_DESCRIPTION","group":"","filename":"url"}				0	1970-01-01 00:00:00	0	0
475	0	plg_fields_user	plugin	user	fields	0	1	1	0	{"name":"plg_fields_user","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_USER_XML_DESCRIPTION","group":"","filename":"user"}				0	1970-01-01 00:00:00	0	0
476	0	plg_fields_usergrouplist	plugin	usergrouplist	fields	0	1	1	0	{"name":"plg_fields_usergrouplist","type":"plugin","creationDate":"March 2016","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_FIELDS_USERGROUPLIST_XML_DESCRIPTION","group":"","filename":"usergrouplist"}				0	1970-01-01 00:00:00	0	0
478	0	plg_editors-xtd_fields	plugin	fields	editors-xtd	0	1	1	0	{"name":"plg_editors-xtd_fields","type":"plugin","creationDate":"February 2017","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.7.0","description":"PLG_EDITORS-XTD_FIELDS_XML_DESCRIPTION","group":"","filename":"fields"}				0	1970-01-01 00:00:00	0	0
479	0	plg_sampledata_blog	plugin	blog	sampledata	0	1	1	0	{"name":"plg_sampledata_blog","type":"plugin","creationDate":"July 2017","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.8.0","description":"PLG_SAMPLEDATA_BLOG_XML_DESCRIPTION","group":"","filename":"blog"}				0	1970-01-01 00:00:00	0	0
481	0	plg_fields_repeatable	plugin	repeatable	fields	0	1	1	0	{"name":"plg_fields_repeatable","type":"plugin","creationDate":"April 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_FIELDS_REPEATABLE_XML_DESCRIPTION","group":"","filename":"repeatable"}				0	1970-01-01 00:00:00	0	0
482	0	plg_content_confirmconsent	plugin	confirmconsent	content	0	0	1	0	{"name":"plg_content_confirmconsent","type":"plugin","creationDate":"May 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_CONTENT_CONFIRMCONSENT_XML_DESCRIPTION","group":"","filename":"confirmconsent"}	{}			0	1970-01-01 00:00:00	0	0
483	0	PLG_SYSTEM_ACTIONLOGS	plugin	actionlogs	system	0	1	1	0	{"name":"PLG_SYSTEM_ACTIONLOGS","type":"plugin","creationDate":"May 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_SYSTEM_ACTIONLOGS_XML_DESCRIPTION","group":"","filename":"actionlogs"}	{}			0	1970-01-01 00:00:00	0	0
485	0	plg_system_privacyconsent	plugin	privacyconsent	system	0	0	1	0	{"name":"plg_system_privacyconsent","type":"plugin","creationDate":"April 2018","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_SYSTEM_PRIVACYCONSENT_XML_DESCRIPTION","group":"","filename":"privacyconsent"}	{}			0	1970-01-01 00:00:00	0	0
488	0	plg_quickicon_privacycheck	plugin	privacycheck	quickicon	0	1	1	0	{"name":"plg_quickicon_privacycheck","type":"plugin","creationDate":"June 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_QUICKICON_PRIVACYCHECK_XML_DESCRIPTION","group":"","filename":"privacycheck"}	{}			0	1970-01-01 00:00:00	0	0
489	0	plg_user_terms	plugin	terms	user	0	0	1	0	{"name":"plg_user_terms","type":"plugin","creationDate":"June 2018","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_USER_TERMS_XML_DESCRIPTION","group":"","filename":"terms"}	{}			0	1970-01-01 00:00:00	0	0
491	0	plg_privacy_content	plugin	content	privacy	0	1	1	0	{"name":"plg_privacy_content","type":"plugin","creationDate":"July 2018","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_PRIVACY_CONTENT_XML_DESCRIPTION","group":"","filename":"content"}	{}			0	1970-01-01 00:00:00	0	0
492	0	plg_privacy_message	plugin	message	privacy	0	1	1	0	{"name":"plg_privacy_message","type":"plugin","creationDate":"July 2018","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_PRIVACY_MESSAGE_XML_DESCRIPTION","group":"","filename":"message"}	{}			0	1970-01-01 00:00:00	0	0
493	0	plg_privacy_actionlogs	plugin	actionlogs	privacy	0	1	1	0	{"name":"plg_privacy_actionlogs","type":"plugin","creationDate":"July 2018","author":"Joomla! Project","copyright":"(C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_PRIVACY_ACTIONLOGS_XML_DESCRIPTION","group":"","filename":"actionlogs"}	{}			0	1970-01-01 00:00:00	0	0
494	0	plg_captcha_recaptcha_invisible	plugin	recaptcha_invisible	captcha	0	0	1	0	{"name":"plg_captcha_recaptcha_invisible","type":"plugin","creationDate":"November 2017","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.8","description":"PLG_CAPTCHA_RECAPTCHA_INVISIBLE_XML_DESCRIPTION","group":"","filename":"recaptcha_invisible"}	{"public_key":"","private_key":"","theme":"clean"}			0	1970-01-01 00:00:00	0	0
503	0	beez3	template	beez3		0	1	1	0	{"name":"beez3","type":"template","creationDate":"25 November 2009","author":"Angie Radtke","copyright":"Copyright (C) 2005 - 2020 Open Source Matters, Inc. All rights reserved.","authorEmail":"a.radtke@derauftritt.de","authorUrl":"http:\\/\\/www.der-auftritt.de","version":"3.1.0","description":"TPL_BEEZ3_XML_DESCRIPTION","group":"","filename":"templateDetails"}	{"wrapperSmall":"53","wrapperLarge":"72","sitetitle":"","sitedescription":"","navposition":"center","templatecolor":"nature"}			0	1970-01-01 00:00:00	0	0
506	0	protostar	template	protostar		0	1	1	0	{"name":"protostar","type":"template","creationDate":"4\\/30\\/2012","author":"Kyle Ledbetter","copyright":"Copyright (C) 2005 - 2020 Open Source Matters, Inc. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"","version":"1.0","description":"TPL_PROTOSTAR_XML_DESCRIPTION","group":"","filename":"templateDetails"}	{"templateColor":"","logoFile":"","googleFont":"1","googleFontName":"Open+Sans","fluidContainer":"0"}			0	1970-01-01 00:00:00	0	0
600	802	English (en-GB)	language	en-GB		0	1	1	1	{"name":"English (en-GB)","type":"language","creationDate":"January 2020","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.15","description":"en-GB site language","group":""}				0	1970-01-01 00:00:00	0	0
601	802	English (en-GB)	language	en-GB		1	1	1	1	{"name":"English (en-GB)","type":"language","creationDate":"January 2020","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.15","description":"en-GB administrator language","group":""}				0	1970-01-01 00:00:00	0	0
802	0	English (en-GB) Language Pack	package	pkg_en-GB		0	1	1	1	{"name":"English (en-GB) Language Pack","type":"package","creationDate":"January 2020","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters, Inc. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.15.1","description":"en-GB language pack","group":"","filename":"pkg_en-GB"}				0	1970-01-01 00:00:00	0	0
103	0	LIB_JOOMLA	library	joomla		0	1	1	1	{"name":"LIB_JOOMLA","type":"library","creationDate":"2008","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"https:\\/\\/www.joomla.org","version":"13.1","description":"LIB_JOOMLA_XML_DESCRIPTION","group":"","filename":"joomla"}	{"mediaversion":"abc64734370240e8e76b14d35f91fe7f"}			0	1970-01-01 00:00:00	0	0
486	0	plg_system_logrotation	plugin	logrotation	system	0	1	1	0	{"name":"plg_system_logrotation","type":"plugin","creationDate":"May 2018","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.9.0","description":"PLG_SYSTEM_LOGROTATION_XML_DESCRIPTION","group":"","filename":"logrotation"}	{"lastrun":1581483063}			0	1970-01-01 00:00:00	0	0
452	0	plg_system_updatenotification	plugin	updatenotification	system	0	1	1	0	{"name":"plg_system_updatenotification","type":"plugin","creationDate":"May 2015","author":"Joomla! Project","copyright":"Copyright (C) 2005 - 2020 Open Source Matters. All rights reserved.","authorEmail":"admin@joomla.org","authorUrl":"www.joomla.org","version":"3.5.0","description":"PLG_SYSTEM_UPDATENOTIFICATION_XML_DESCRIPTION","group":"","filename":"updatenotification"}	{"lastrun":1581483063}			0	1970-01-01 00:00:00	0	0
\.


--
-- Name: j_extensions_extension_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_extensions_extension_id_seq', 10000, false);


--
-- Data for Name: j_fields; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_fields (id, asset_id, context, group_id, title, name, label, default_value, type, note, description, state, required, checked_out, checked_out_time, ordering, params, fieldparams, language, created_time, created_user_id, modified_time, modified_by, access) FROM stdin;
\.


--
-- Data for Name: j_fields_categories; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_fields_categories (field_id, category_id) FROM stdin;
\.


--
-- Data for Name: j_fields_groups; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_fields_groups (id, asset_id, context, title, note, description, state, checked_out, checked_out_time, ordering, params, language, created, created_by, modified, modified_by, access) FROM stdin;
\.


--
-- Name: j_fields_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_fields_groups_id_seq', 1, false);


--
-- Name: j_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_fields_id_seq', 1, false);


--
-- Data for Name: j_fields_values; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_fields_values (field_id, item_id, value) FROM stdin;
\.


--
-- Data for Name: j_finder_filters; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_filters (filter_id, title, alias, state, created, created_by, created_by_alias, modified, modified_by, checked_out, checked_out_time, map_count, data, params) FROM stdin;
\.


--
-- Name: j_finder_filters_filter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_finder_filters_filter_id_seq', 1, false);


--
-- Data for Name: j_finder_links; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links (link_id, url, route, title, description, indexdate, md5sum, published, state, access, language, publish_start_date, publish_end_date, start_date, end_date, list_price, sale_price, type_id, object) FROM stdin;
\.


--
-- Name: j_finder_links_link_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_finder_links_link_id_seq', 1, false);


--
-- Data for Name: j_finder_links_terms0; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms0 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_terms1; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms1 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_terms2; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms2 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_terms3; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms3 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_terms4; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms4 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_terms5; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms5 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_terms6; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms6 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_terms7; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms7 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_terms8; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms8 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_terms9; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_terms9 (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_termsa; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_termsa (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_termsb; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_termsb (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_termsc; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_termsc (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_termsd; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_termsd (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_termse; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_termse (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_links_termsf; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_links_termsf (link_id, term_id, weight) FROM stdin;
\.


--
-- Data for Name: j_finder_taxonomy; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_taxonomy (id, parent_id, title, state, access, ordering) FROM stdin;
1	0	ROOT	0	0	0
\.


--
-- Name: j_finder_taxonomy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_finder_taxonomy_id_seq', 2, false);


--
-- Data for Name: j_finder_taxonomy_map; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_taxonomy_map (link_id, node_id) FROM stdin;
\.


--
-- Data for Name: j_finder_terms; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_terms (term_id, term, stem, common, phrase, weight, soundex, links, language) FROM stdin;
\.


--
-- Data for Name: j_finder_terms_common; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_terms_common (term, language) FROM stdin;
a	en
about	en
after	en
ago	en
all	en
am	en
an	en
and	en
any	en
are	en
aren't	en
as	en
at	en
be	en
but	en
by	en
for	en
from	en
get	en
go	en
how	en
if	en
in	en
into	en
is	en
isn't	en
it	en
its	en
me	en
more	en
most	en
must	en
my	en
new	en
no	en
none	en
not	en
nothing	en
of	en
off	en
often	en
old	en
on	en
onc	en
once	en
only	en
or	en
other	en
our	en
ours	en
out	en
over	en
page	en
she	en
should	en
small	en
so	en
some	en
than	en
thank	en
that	en
the	en
their	en
theirs	en
them	en
then	en
there	en
these	en
they	en
this	en
those	en
thus	en
time	en
times	en
to	en
too	en
true	en
under	en
until	en
up	en
upon	en
use	en
user	en
users	en
version	en
very	en
via	en
want	en
was	en
way	en
were	en
what	en
when	en
where	en
which	en
who	en
whom	en
whose	en
why	en
wide	en
will	en
with	en
within	en
without	en
would	en
yes	en
yet	en
you	en
your	en
yours	en
\.


--
-- Name: j_finder_terms_term_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_finder_terms_term_id_seq', 1, false);


--
-- Data for Name: j_finder_tokens; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_tokens (term, stem, common, phrase, weight, context, language) FROM stdin;
\.


--
-- Data for Name: j_finder_tokens_aggregate; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_tokens_aggregate (term_id, map_suffix, term, stem, common, phrase, term_weight, context, context_weight, total_weight, language) FROM stdin;
\.


--
-- Data for Name: j_finder_types; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_finder_types (id, title, mime) FROM stdin;
\.


--
-- Name: j_finder_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_finder_types_id_seq', 1, false);


--
-- Data for Name: j_languages; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_languages (lang_id, asset_id, lang_code, title, title_native, sef, image, description, metakey, metadesc, sitename, published, access, ordering) FROM stdin;
1	0	en-GB	English (en-GB)	English (United Kingdom)	en	en_gb					1	1	1
\.


--
-- Name: j_languages_lang_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_languages_lang_id_seq', 2, false);


--
-- Data for Name: j_menu; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_menu (id, menutype, title, alias, note, path, link, type, published, parent_id, level, component_id, checked_out, checked_out_time, "browserNav", access, img, template_style_id, params, lft, rgt, home, language, client_id) FROM stdin;
1		Menu_Item_Root	root					1	0	0	0	0	1970-01-01 00:00:00	0	0		0		0	53	0	*	0
2	main	com_banners	Banners		Banners	index.php?option=com_banners	component	1	1	1	4	0	1970-01-01 00:00:00	0	0	class:banners	0		1	10	0	*	1
3	main	com_banners	Banners		Banners/Banners	index.php?option=com_banners	component	1	2	2	4	0	1970-01-01 00:00:00	0	0	class:banners	0		2	3	0	*	1
4	main	com_banners_categories	Categories		Banners/Categories	index.php?option=com_categories&extension=com_banners	component	1	2	2	6	0	1970-01-01 00:00:00	0	0	class:banners-cat	0		4	5	0	*	1
5	main	com_banners_clients	Clients		Banners/Clients	index.php?option=com_banners&view=clients	component	1	2	2	4	0	1970-01-01 00:00:00	0	0	class:banners-clients	0		6	7	0	*	1
6	main	com_banners_tracks	Tracks		Banners/Tracks	index.php?option=com_banners&view=tracks	component	1	2	2	4	0	1970-01-01 00:00:00	0	0	class:banners-tracks	0		8	9	0	*	1
7	main	com_contact	Contacts		Contacts	index.php?option=com_contact	component	1	1	1	8	0	1970-01-01 00:00:00	0	0	class:contact	0		11	16	0	*	1
8	main	com_contact_contacts	Contacts		Contacts/Contacts	index.php?option=com_contact	component	1	7	2	8	0	1970-01-01 00:00:00	0	0	class:contact	0		12	13	0	*	1
9	main	com_contact_categories	Categories		Contacts/Categories	index.php?option=com_categories&extension=com_contact	component	1	7	2	6	0	1970-01-01 00:00:00	0	0	class:contact-cat	0		14	15	0	*	1
10	main	com_messages	Messaging		Messaging	index.php?option=com_messages	component	1	1	1	15	0	1970-01-01 00:00:00	0	0	class:messages	0		21	24	0	*	1
11	main	com_messages_add	New Private Message		Messaging/New Private Message	index.php?option=com_messages&task=message.add	component	1	10	2	15	0	1970-01-01 00:00:00	0	0	class:messages-add	0		22	23	0	*	1
13	main	com_newsfeeds	News Feeds		News Feeds	index.php?option=com_newsfeeds	component	1	1	1	17	0	1970-01-01 00:00:00	0	0	class:newsfeeds	0		31	36	0	*	1
14	main	com_newsfeeds_feeds	Feeds		News Feeds/Feeds	index.php?option=com_newsfeeds	component	1	13	2	17	0	1970-01-01 00:00:00	0	0	class:newsfeeds	0		32	33	0	*	1
15	main	com_newsfeeds_categories	Categories		News Feeds/Categories	index.php?option=com_categories&extension=com_newsfeeds	component	1	13	2	6	0	1970-01-01 00:00:00	0	0	class:newsfeeds-cat	0		34	35	0	*	1
16	main	com_redirect	Redirect		Redirect	index.php?option=com_redirect	component	1	1	1	24	0	1970-01-01 00:00:00	0	0	class:redirect	0		37	38	0	*	1
17	main	com_search	Basic Search		Basic Search	index.php?option=com_search	component	1	1	1	19	0	1970-01-01 00:00:00	0	0	class:search	0		39	40	0	*	1
18	main	com_finder	Smart Search		Smart Search	index.php?option=com_finder	component	1	1	1	27	0	1970-01-01 00:00:00	0	0	class:finder	0		41	42	0	*	1
19	main	com_joomlaupdate	Joomla! Update		Joomla! Update	index.php?option=com_joomlaupdate	component	1	1	1	28	0	1970-01-01 00:00:00	0	0	class:joomlaupdate	0		43	44	0	*	1
20	main	com_tags	Tags		Tags	index.php?option=com_tags	component	1	1	1	29	0	1970-01-01 00:00:00	0	1	class:tags	0		45	46	0		1
21	main	com_postinstall	Post-installation messages		Post-installation messages	index.php?option=com_postinstall	component	1	1	1	32	0	1970-01-01 00:00:00	0	1	class:postinstall	0		47	48	0	*	1
22	main	com_associations	Multilingual Associations		Multilingual Associations	index.php?option=com_associations	component	1	1	1	34	0	1970-01-01 00:00:00	0	0	class:associations	0		49	50	0	*	1
101	mainmenu	Home	homepage		homepage	index.php?option=com_content&view=article&id=1	component	1	1	1	22	0	1970-01-01 00:00:00	0	1		0	{"show_title":"1","link_titles":"","show_intro":"","info_block_position":"0","show_category":"0","link_category":"0","show_parent_category":"0","link_parent_category":"0","show_author":"0","link_author":"0","show_create_date":"0","show_modify_date":"0","show_publish_date":"0","show_item_navigation":"0","show_vote":"","show_tags":"","show_icons":"0","show_print_icon":"0","show_email_icon":"0","show_hits":"0","show_noauth":"","urls_position":"","menu-anchor_title":"","menu-anchor_css":"","menu_image":"","menu_text":1,"page_title":"","show_page_heading":0,"page_heading":"","pageclass_sfx":"","menu-meta_description":"","menu-meta_keywords":"","robots":"","secure":0}	51	52	1	*	0
102	usermenu	Your Profile	your-profile		your-profile	index.php?option=com_users&view=profile&layout=edit	component	1	1	1	25	0	1970-01-01 00:00:00	0	2		0	{"menu-anchor_title":"","menu-anchor_css":"","menu_image":"","menu_text":1,"page_title":"","show_page_heading":0,"page_heading":"","pageclass_sfx":"","menu-meta_description":"","menu-meta_keywords":"","robots":"","secure":0}	17	18	0	*	0
103	usermenu	Site Administrator	2013-11-16-23-26-41		2013-11-16-23-26-41	administrator	url	1	1	1	0	0	1970-01-01 00:00:00	0	6		0	{"menu-anchor_title":"","menu-anchor_css":"","menu_image":"","menu_text":1}	25	26	0	*	0
104	usermenu	Submit an Article	submit-an-article		submit-an-article	index.php?option=com_content&view=form&layout=edit	component	1	1	1	22	0	1970-01-01 00:00:00	0	3		0	{"enable_category":"0","catid":"2","menu-anchor_title":"","menu-anchor_css":"","menu_image":"","menu_text":1,"page_title":"","show_page_heading":0,"page_heading":"","pageclass_sfx":"","menu-meta_description":"","menu-meta_keywords":"","robots":"","secure":0}	19	20	0	*	0
106	usermenu	Template Settings	template-settings		template-settings	index.php?option=com_config&view=templates&controller=config.display.templates	component	1	1	1	23	0	1970-01-01 00:00:00	0	6		0	{"menu-anchor_title":"","menu-anchor_css":"","menu_image":"","menu_text":1,"page_title":"","show_page_heading":0,"page_heading":"","pageclass_sfx":"","menu-meta_description":"","menu-meta_keywords":"","robots":"","secure":0}	27	28	0	*	0
107	usermenu	Site Settings	site-settings		site-settings	index.php?option=com_config&view=config&controller=config.display.config	component	1	1	1	23	0	1970-01-01 00:00:00	0	6		0	{"menu-anchor_title":"","menu-anchor_css":"","menu_image":"","menu_text":1,"page_title":"","show_page_heading":0,"page_heading":"","pageclass_sfx":"","menu-meta_description":"","menu-meta_keywords":"","robots":"","secure":0}	29	30	0	*	0
\.


--
-- Name: j_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_menu_id_seq', 107, true);


--
-- Data for Name: j_menu_types; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_menu_types (id, asset_id, menutype, title, description, client_id) FROM stdin;
1	0	mainmenu	Main Menu	The main menu for the site	0
2	0	usermenu	User Menu	A Menu for logged-in Users	0
\.


--
-- Name: j_menu_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_menu_types_id_seq', 2, true);


--
-- Data for Name: j_messages; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_messages (message_id, user_id_from, user_id_to, folder_id, date_time, state, priority, subject, message) FROM stdin;
\.


--
-- Data for Name: j_messages_cfg; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_messages_cfg (user_id, cfg_name, cfg_value) FROM stdin;
\.


--
-- Name: j_messages_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_messages_message_id_seq', 1, false);


--
-- Data for Name: j_modules; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_modules (id, asset_id, title, note, content, ordering, "position", checked_out, checked_out_time, publish_up, publish_down, published, module, access, showtitle, params, client_id, language) FROM stdin;
1	39	Main Menu			1	position-1	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_menu	1	1	{"menutype":"mainmenu","base":"","startLevel":"1","endLevel":"0","showAllChildren":"1","tag_id":"","class_sfx":" nav-pills","window_open":"","layout":"_:default","moduleclass_sfx":"_menu","cache":"1","cache_time":"900","cachemode":"itemid","module_tag":"div","bootstrap_size":"0","header_tag":"h3","header_class":"","style":"0"}	0	*
2	40	Login			1	login	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_login	1	1		1	*
3	41	Popular Articles			3	cpanel	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_popular	3	1	{"count":"5","catid":"","user_id":"0","layout":"_:default","moduleclass_sfx":"","cache":"0"}	1	*
4	42	Recently Added Articles			4	cpanel	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_latest	3	1	{"count":"5","ordering":"c_dsc","catid":"","user_id":"0","layout":"_:default","moduleclass_sfx":"","cache":"0"}	1	*
8	43	Toolbar			1	toolbar	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_toolbar	3	1		1	*
9	44	Quick Icons			1	icon	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_quickicon	3	1		1	*
10	45	Logged-in Users			2	cpanel	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_logged	3	1	{"count":"5","name":"1","layout":"_:default","moduleclass_sfx":"","cache":"0"}	1	*
12	46	Admin Menu			1	menu	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_menu	3	1	{"layout":"","moduleclass_sfx":"","shownew":"1","showhelp":"1","cache":"0"}	1	*
13	47	Admin Submenu			1	submenu	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_submenu	3	1		1	*
14	48	User Status			2	status	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_status	3	1		1	*
15	49	Title			1	title	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_title	3	1		1	*
16	50	Login Form			7	position-7	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_login	1	1	{"greeting":"1","name":"0"}	0	*
17	51	Breadcrumbs			1	position-2	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_breadcrumbs	1	1	{"moduleclass_sfx":"","showHome":"1","homeText":"","showComponent":"1","separator":"","cache":"0","cache_time":"0","cachemode":"itemid"}	0	*
79	52	Multilanguage status			1	status	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	0	mod_multilangstatus	3	1	{"layout":"_:default","moduleclass_sfx":"","cache":"0"}	1	*
86	53	Joomla Version			1	footer	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_version	3	1	{"format":"short","product":"1","layout":"_:default","moduleclass_sfx":"","cache":"0"}	1	*
87	54	Popular Tags			1	position-7	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_tags_popular	1	1	{"maximum":"10","timeframe":"alltime","order_value":"count","order_direction":"1","display_count":0,"no_results_text":"0","minsize":1,"maxsize":2,"layout":"_:default","moduleclass_sfx":"","owncache":"1","module_tag":"div","bootstrap_size":"0","header_tag":"h3","header_class":"","style":"0"}	0	*
88	55	Site Information			3	cpanel	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_stats_admin	3	1	{"serverinfo":"1","siteinfo":"1","counter":"0","increase":"0","layout":"_:default","moduleclass_sfx":"","cache":"1","cache_time":"900","cachemode":"static","module_tag":"div","bootstrap_size":"0","header_tag":"h3","header_class":"","style":"0"}	1	*
89	56	Release News			0	postinstall	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_feed	1	1	{"rssurl":"https:\\/\\/www.joomla.org\\/announcements\\/release-news.feed","rssrtl":"0","rsstitle":"1","rssdesc":"1","rssimage":"1","rssitems":"3","rssitemdesc":"1","word_count":"0","layout":"_:default","moduleclass_sfx":"","cache":"1","cache_time":"900","module_tag":"div","bootstrap_size":"0","header_tag":"h3","header_class":"","style":"0"}	1	*
90	57	Latest Articles			1	position-7	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_articles_latest	1	1	{"catid":[""],"count":"5","show_featured":"","ordering":"c_dsc","user_id":"0","layout":"_:default","moduleclass_sfx":"","cache":"1","cache_time":"900","cachemode":"static","module_tag":"div","bootstrap_size":"0","header_tag":"h3","header_class":"","style":"0"}	0	*
91	58	User Menu			3	position-7	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_menu	1	1	{"menutype":"usermenu","base":"","startLevel":"1","endLevel":"0","showAllChildren":"1","tag_id":"","class_sfx":"","window_open":"","layout":"_:default","moduleclass_sfx":"_menu","cache":"1","cache_time":"900","cachemode":"itemid","module_tag":"div","bootstrap_size":"0","header_tag":"h3","header_class":"","style":"0"}	0	*
92	59	Image Module		<p><img src="images/headers/blue-flower.jpg" alt="Blue Flower" /></p>	0	position-3	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_custom	1	0	{"prepare_content":"1","backgroundimage":"","layout":"_:default","moduleclass_sfx":"","cache":"1","cache_time":"900","cachemode":"static","module_tag":"div","bootstrap_size":"0","header_tag":"h3","header_class":"","style":"0"}	0	*
93	60	Search			0	position-0	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_search	1	1	{"label":"","width":"20","text":"","button":"0","button_pos":"right","imagebutton":"1","button_text":"","opensearch":"1","opensearch_title":"","set_itemid":"0","layout":"_:default","moduleclass_sfx":"","cache":"1","cache_time":"900","cachemode":"itemid","module_tag":"div","bootstrap_size":"0","header_tag":"h3","header_class":"","style":"0"}	0	*
94	61	Latest Actions			0	cpanel	0	1970-01-01 00:00:00	1970-01-01 00:00:00	1970-01-01 00:00:00	1	mod_latestactions	6	1	{}	1	*
\.


--
-- Name: j_modules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_modules_id_seq', 94, true);


--
-- Data for Name: j_modules_menu; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_modules_menu (moduleid, menuid) FROM stdin;
1	0
2	0
3	0
4	0
6	0
7	0
8	0
9	0
10	0
12	0
13	0
14	0
15	0
16	0
17	0
79	0
86	0
87	0
88	0
89	0
90	0
91	0
92	0
93	0
94	0
\.


--
-- Data for Name: j_newsfeeds; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_newsfeeds (catid, id, name, alias, link, published, numarticles, cache_time, checked_out, checked_out_time, ordering, rtl, access, language, params, created, created_by, created_by_alias, modified, modified_by, metakey, metadesc, metadata, xreference, publish_up, publish_down, description, version, hits, images) FROM stdin;
\.


--
-- Name: j_newsfeeds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_newsfeeds_id_seq', 1, false);


--
-- Data for Name: j_overrider; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_overrider (id, constant, string, file) FROM stdin;
\.


--
-- Name: j_overrider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_overrider_id_seq', 1, false);


--
-- Data for Name: j_postinstall_messages; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_postinstall_messages (postinstall_message_id, extension_id, title_key, description_key, action_key, language_extension, language_client_id, type, action_file, action, condition_file, condition_method, version_introduced, enabled) FROM stdin;
1	700	PLG_TWOFACTORAUTH_TOTP_POSTINSTALL_TITLE	PLG_TWOFACTORAUTH_TOTP_POSTINSTALL_BODY	PLG_TWOFACTORAUTH_TOTP_POSTINSTALL_ACTION	plg_twofactorauth_totp	1	action	site://plugins/twofactorauth/totp/postinstall/actions.php	twofactorauth_postinstall_action	site://plugins/twofactorauth/totp/postinstall/actions.php	twofactorauth_postinstall_condition	3.2.0	1
2	700	COM_CPANEL_WELCOME_BEGINNERS_TITLE	COM_CPANEL_WELCOME_BEGINNERS_MESSAGE		com_cpanel	1	message					3.2.0	1
3	700	COM_CPANEL_MSG_STATS_COLLECTION_TITLE	COM_CPANEL_MSG_STATS_COLLECTION_BODY		com_cpanel	1	message			admin://components/com_admin/postinstall/statscollection.php	admin_postinstall_statscollection_condition	3.5.0	1
4	700	PLG_SYSTEM_UPDATENOTIFICATION_POSTINSTALL_UPDATECACHETIME	PLG_SYSTEM_UPDATENOTIFICATION_POSTINSTALL_UPDATECACHETIME_BODY	PLG_SYSTEM_UPDATENOTIFICATION_POSTINSTALL_UPDATECACHETIME_ACTION	plg_system_updatenotification	1	action	site://plugins/system/updatenotification/postinstall/updatecachetime.php	updatecachetime_postinstall_action	site://plugins/system/updatenotification/postinstall/updatecachetime.php	updatecachetime_postinstall_condition	3.6.3	1
5	700	COM_CPANEL_MSG_JOOMLA40_PRE_CHECKS_TITLE	COM_CPANEL_MSG_JOOMLA40_PRE_CHECKS_BODY		com_cpanel	1	message			admin://components/com_admin/postinstall/joomla40checks.php	admin_postinstall_joomla40checks_condition	3.7.0	1
6	700	TPL_HATHOR_MESSAGE_POSTINSTALL_TITLE	TPL_HATHOR_MESSAGE_POSTINSTALL_BODY	TPL_HATHOR_MESSAGE_POSTINSTALL_ACTION	tpl_hathor	1	action	admin://templates/hathor/postinstall/hathormessage.php	hathormessage_postinstall_action	admin://templates/hathor/postinstall/hathormessage.php	hathormessage_postinstall_condition	3.7.0	1
7	700	PLG_PLG_RECAPTCHA_VERSION_1_POSTINSTALL_TITLE	PLG_PLG_RECAPTCHA_VERSION_1_POSTINSTALL_BODY	PLG_PLG_RECAPTCHA_VERSION_1_POSTINSTALL_ACTION	plg_captcha_recaptcha	1	action	site://plugins/captcha/recaptcha/postinstall/actions.php	recaptcha_postinstall_action	site://plugins/captcha/recaptcha/postinstall/actions.php	recaptcha_postinstall_condition	3.8.6	1
8	700	COM_ACTIONLOGS_POSTINSTALL_TITLE	COM_ACTIONLOGS_POSTINSTALL_BODY		com_actionlogs	1	message					3.9.0	1
9	700	COM_PRIVACY_POSTINSTALL_TITLE	COM_PRIVACY_POSTINSTALL_BODY		com_privacy	1	message					3.9.0	1
\.


--
-- Name: j_postinstall_messages_postinstall_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_postinstall_messages_postinstall_message_id_seq', 9, true);


--
-- Data for Name: j_privacy_consents; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_privacy_consents (id, user_id, state, created, subject, body, remind, token) FROM stdin;
\.


--
-- Name: j_privacy_consents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_privacy_consents_id_seq', 1, false);


--
-- Data for Name: j_privacy_requests; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_privacy_requests (id, email, requested_at, status, request_type, confirm_token, confirm_token_created_at) FROM stdin;
\.


--
-- Name: j_privacy_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_privacy_requests_id_seq', 1, false);


--
-- Data for Name: j_redirect_links; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_redirect_links (id, old_url, new_url, referer, comment, hits, published, created_date, modified_date, header) FROM stdin;
\.


--
-- Name: j_redirect_links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_redirect_links_id_seq', 1, false);


--
-- Data for Name: j_schemas; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_schemas (extension_id, version_id) FROM stdin;
700	3.9.15-2020-01-08
\.


--
-- Data for Name: j_session; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_session (session_id, client_id, guest, "time", data, userid, username) FROM stdin;
2g3em72mgi0roq7er0hjc00338	1	1	1581483063	joomla|s:736:"TzoyNDoiSm9vbWxhXFJlZ2lzdHJ5XFJlZ2lzdHJ5IjozOntzOjc6IgAqAGRhdGEiO086ODoic3RkQ2xhc3MiOjE6e3M6OToiX19kZWZhdWx0IjtPOjg6InN0ZENsYXNzIjozOntzOjc6InNlc3Npb24iO086ODoic3RkQ2xhc3MiOjM6e3M6NzoiY291bnRlciI7aToxO3M6NToidGltZXIiO086ODoic3RkQ2xhc3MiOjM6e3M6NToic3RhcnQiO2k6MTU4MTQ4MzA2MztzOjQ6Imxhc3QiO2k6MTU4MTQ4MzA2MztzOjM6Im5vdyI7aToxNTgxNDgzMDYzO31zOjU6InRva2VuIjtzOjMyOiJuOUVudEFCTml5azQwNkVuU0NaMnQzOUdUTHFVMFd3QiI7fXM6ODoicmVnaXN0cnkiO086MjQ6Ikpvb21sYVxSZWdpc3RyeVxSZWdpc3RyeSI6Mzp7czo3OiIAKgBkYXRhIjtPOjg6InN0ZENsYXNzIjowOnt9czoxNDoiACoAaW5pdGlhbGl6ZWQiO2I6MDtzOjk6InNlcGFyYXRvciI7czoxOiIuIjt9czo0OiJ1c2VyIjtPOjIwOiJKb29tbGFcQ01TXFVzZXJcVXNlciI6MTp7czoyOiJpZCI7aTowO319fXM6MTQ6IgAqAGluaXRpYWxpemVkIjtiOjA7czo5OiJzZXBhcmF0b3IiO3M6MToiLiI7fQ==";	0	
\.


--
-- Data for Name: j_tags; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_tags (id, parent_id, lft, rgt, level, path, title, alias, note, description, published, checked_out, checked_out_time, access, params, metadesc, metakey, metadata, created_user_id, created_time, created_by_alias, modified_user_id, modified_time, images, urls, hits, language, version, publish_up, publish_down) FROM stdin;
1	0	0	3	0		ROOT	root			1	0	1970-01-01 00:00:00	1	{}				0	2020-02-12 04:50:57		0	1970-01-01 00:00:00			0	*	1	1970-01-01 00:00:00	1970-01-01 00:00:00
2	1	1	2	1	joomla	Joomla	joomla			1	0	1970-01-01 00:00:00	1	{"tag_layout":"","tag_link_class":"label label-info","image_intro":"","float_intro":"","image_intro_alt":"","image_intro_caption":"","image_fulltext":"","float_fulltext":"","image_fulltext_alt":"","image_fulltext_caption":""}			{"author":"","robots":""}	698	2020-02-12 04:50:57		0	1970-01-01 00:00:00			0	*	1	1970-01-01 00:00:00	1970-01-01 00:00:00
\.


--
-- Name: j_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_tags_id_seq', 2, true);


--
-- Data for Name: j_template_styles; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_template_styles (id, template, client_id, home, title, params) FROM stdin;
4	beez3	0	0	Beez3 - Default	{"wrapperSmall":"53","wrapperLarge":"72","logo":"images\\/joomla_black.png","sitetitle":"Joomla!","sitedescription":"Open Source Content Management","navposition":"left","templatecolor":"personal","html5":"0"}
5	hathor	1	0	Hathor - Default	{"showSiteName":"0","colourChoice":"","boldText":"0"}
7	protostar	0	1	protostar - Default	{"templateColor":"","logoFile":"","googleFont":"1","googleFontName":"Open+Sans","fluidContainer":"0"}
8	isis	1	1	isis - Default	{"templateColor":"","logoFile":""}
\.


--
-- Name: j_template_styles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_template_styles_id_seq', 9, false);


--
-- Data for Name: j_ucm_base; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_ucm_base (ucm_id, ucm_item_id, ucm_type_id, ucm_language_id) FROM stdin;
1	1	1	0
\.


--
-- Name: j_ucm_base_ucm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_ucm_base_ucm_id_seq', 1, true);


--
-- Data for Name: j_ucm_content; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_ucm_content (core_content_id, core_type_alias, core_title, core_alias, core_body, core_state, core_checked_out_time, core_checked_out_user_id, core_access, core_params, core_featured, core_metadata, core_created_user_id, core_created_by_alias, core_created_time, core_modified_user_id, core_modified_time, core_language, core_publish_up, core_publish_down, core_content_item_id, asset_id, core_images, core_urls, core_hits, core_version, core_ordering, core_metakey, core_metadesc, core_catid, core_xreference, core_type_id) FROM stdin;
1	com_content.article	Getting Started	getting-started	<p>It's easy to get started creating your website. Knowing some of the basics will help.</p><h3>What is a Content Management System?</h3><p>A content management system is software that allows you to create and manage webpages easily by separating the creation of your content from the mechanics required to present it on the web.</p><p>In this site, the content is stored in a <em>database</em>. The look and feel are created by a <em>template</em>. Joomla! brings together the template and your content to create web pages.</p><h3>Logging in</h3><p>To login to your site use the user name and password that were created as part of the installation process. Once logged-in you will be able to create and edit articles and modify some settings.</p><h3>Creating an article</h3><p>Once you are logged-in, a new menu will be visible. To create a new article, click on the "Submit Article" link on that menu.</p><p>The new article interface gives you a lot of options, but all you need to do is add a title and put something in the content area. To make it easy to find, set the state to published.</p><div>You can edit an existing article by clicking on the edit icon (this only displays to users who have the right to edit).</div><h3>Template, site settings, and modules</h3><p>The look and feel of your site is controlled by a template. You can change the site name, background colour, highlights colour and more by editing the template settings. Click the "Template Settings" in the user menu.</p><p>The boxes around the main content of the site are called modules. You can modify modules on the current page by moving your cursor to the module and clicking the edit link. Always be sure to save and close any module you edit.</p><p>You can change some site settings such as the site name and description by clicking on the "Site Settings" link.</p><p>More advanced options for templates, site settings, modules, and more are available in the site administrator.</p><h3>Site and Administrator</h3><p>Your site actually has two separate sites. The site (also called the front end) is what visitors to your site will see. The administrator (also called the back end) is only used by people managing your site. You can access the administrator by clicking the "Site Administrator" link on the "User Menu" menu (visible once you login) or by adding /administrator to the end of your domain name. The same user name and password are used for both sites.</p><h3>Learn more</h3><p>There is much more to learn about how to use Joomla! to create the website you envision. You can learn much more at the <a href="https://docs.joomla.org/" target="_blank">Joomla! documentation site</a> and on the<a href="https://forum.joomla.org/" target="_blank"> Joomla! forums</a>.</p>	1	1970-01-01 00:00:00	0	1	{"show_title":"","link_titles":"","show_tags":"","show_intro":"","info_block_position":"","show_category":"","link_category":"","show_parent_category":"","link_parent_category":"","show_author":"","link_author":"","show_create_date":"","show_modify_date":"","show_publish_date":"","show_item_navigation":"","show_icons":"","show_print_icon":"","show_email_icon":"","show_vote":"","show_hits":"","show_noauth":"","urls_position":"","alternative_readmore":"","article_layout":"","show_publishing_options":"","show_article_options":"","show_urls_images_backend":"","show_urls_images_frontend":""}	0	{"robots":"","author":"","rights":"","xreference":""}	698		2020-02-12 04:50:57	0	1970-01-01 00:00:00	*	2020-02-12 04:50:57	1970-01-01 00:00:00	1	62	{"image_intro":"","float_intro":"","image_intro_alt":"","image_intro_caption":"","image_fulltext":"","float_fulltext":"","image_fulltext_alt":"","image_fulltext_caption":""}	{"urla":false,"urlatext":"","targeta":"","urlb":false,"urlbtext":"","targetb":"","urlc":false,"urlctext":"","targetc":""}	0	1	0			2		1
\.


--
-- Name: j_ucm_content_core_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_ucm_content_core_content_id_seq', 1, true);


--
-- Data for Name: j_ucm_history; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_ucm_history (version_id, ucm_item_id, ucm_type_id, version_note, save_date, editor_user_id, character_count, sha1_hash, version_data, keep_forever) FROM stdin;
1	2	10	Initial content	2020-02-12 04:50:57+00	698	558	be28228b479aa67bad3dc1db2975232a033d5f0f	{"id":2,"parent_id":"1","lft":"1","rgt":2,"level":1,"path":"joomla","title":"Joomla","alias":"joomla","note":"","description":null,"published":1,"checked_out":"0","checked_out_time":"1970-01-01 00:00:00","access":1,"params":null,"metadesc":null,"metakey":null,"metadata":null,"created_user_id":"849","created_time":"2013-11-16 00:00:00","created_by_alias":"","modified_user_id":"0","modified_time":"1970-01-01 00:00:00","images":null,"urls":null,"hits":"0","language":"*","version":"1","publish_up":"1970-01-01 00:00:00","publish_down":"1970-01-01 00:00:00"}	0
2	1	1	Initial content	2020-02-12 04:50:57+00	698	4539	4f6bf8f67e89553853c3b6e8ed0a6111daaa7a2f	{"id":1,"asset_id":54,"title":"Getting Started","alias":"getting-started","introtext":"<p>It's easy to get started creating your website. Knowing some of the basics will help.</p>\\r\\n<h3>What is a Content Management System?</h3>\\r\\n<p>A content management system is software that allows you to create and manage webpages easily by separating the creation of your content from the mechanics required to present it on the web.</p>\\r\\n<p>In this site, the content is stored in a <em>database</em>. The look and feel are created by a <em>template</em>. Joomla! brings together the template and your content to create web pages.</p>\\r\\n<h3>Logging in</h3>\\r\\n<p>To login to your site use the user name and password that were created as part of the installation process. Once logged-in you will be able to create and edit articles and modify some settings.</p>\\r\\n<h3>Creating an article</h3>\\r\\n<p>Once you are logged-in, a new menu will be visible. To create a new article, click on the \\"Submit Article\\" link on that menu.</p>\\r\\n<p>The new article interface gives you a lot of options, but all you need to do is add a title and put something in the content area. To make it easy to find, set the state to published.</p>\\r\\n<div>You can edit an existing article by clicking on the edit icon (this only displays to users who have the right to edit).</div>\\r\\n<h3>Template, site settings, and modules</h3>\\r\\n<p>The look and feel of your site is controlled by a template. You can change the site name, background colour, highlights colour and more by editing the template settings. Click the \\"Template Settings\\" in the user menu.\\u00a0</p>\\r\\n<p>The boxes around the main content of the site are called modules. \\u00a0You can modify modules on the current page by moving your cursor to the module and clicking the edit link. Always be sure to save and close any module you edit.</p>\\r\\n<p>You can change some site settings such as the site name and description by clicking on the \\"Site Settings\\" link.</p>\\r\\n<p>More advanced options for templates, site settings, modules, and more are available in the site administrator.</p>\\r\\n<h3>Site and Administrator</h3>\\r\\n<p>Your site actually has two separate sites. The site (also called the front end) is what visitors to your site will see. The administrator (also called the back end) is only used by people managing your site. You can access the administrator by clicking the \\"Site Administrator\\" link on the \\"User Menu\\" menu (visible once you login) or by adding /administrator to the end of your domain name. The same user name and password are used for both sites.</p>\\r\\n<h3>Learn more</h3>\\r\\n<p>There is much more to learn about how to use Joomla! to create the website you envision. You can learn much more at the <a href=\\"https://docs.joomla.org\\" target=\\"_blank\\">Joomla! documentation site</a> and on the<a href=\\"https://forum.joomla.org/\\" target=\\"_blank\\"> Joomla! forums</a>.</p>","fulltext":"","state":1,"catid":"2","created":"2013-11-16 00:00:00","created_by":"849","created_by_alias":"","modified":"","modified_by":null,"checked_out":null,"checked_out_time":null,"publish_up":"2013-11-16 00:00:00","publish_down":"1970-01-01 00:00:00","images":"{\\"image_intro\\":\\"\\",\\"float_intro\\":\\"\\",\\"image_intro_alt\\":\\"\\",\\"image_intro_caption\\":\\"\\",\\"image_fulltext\\":\\"\\",\\"float_fulltext\\":\\"\\",\\"image_fulltext_alt\\":\\"\\",\\"image_fulltext_caption\\":\\"\\"}","urls":"{\\"urla\\":false,\\"urlatext\\":\\"\\",\\"targeta\\":\\"\\",\\"urlb\\":false,\\"urlbtext\\":\\"\\",\\"targetb\\":\\"\\",\\"urlc\\":false,\\"urlctext\\":\\"\\",\\"targetc\\":\\"\\"}","attribs":"{\\"show_title\\":\\"\\",\\"link_titles\\":\\"\\",\\"show_tags\\":\\"\\",\\"show_intro\\":\\"\\",\\"info_block_position\\":\\"\\",\\"show_category\\":\\"\\",\\"link_category\\":\\"\\",\\"show_parent_category\\":\\"\\",\\"link_parent_category\\":\\"\\",\\"show_author\\":\\"\\",\\"link_author\\":\\"\\",\\"show_create_date\\":\\"\\",\\"show_modify_date\\":\\"\\",\\"show_publish_date\\":\\"\\",\\"show_item_navigation\\":\\"\\",\\"show_icons\\":\\"\\",\\"show_print_icon\\":\\"\\",\\"show_email_icon\\":\\"\\",\\"show_vote\\":\\"\\",\\"show_hits\\":\\"\\",\\"show_noauth\\":\\"\\",\\"urls_position\\":\\"\\",\\"alternative_readmore\\":\\"\\",\\"article_layout\\":\\"\\",\\"show_publishing_options\\":\\"\\",\\"show_article_options\\":\\"\\",\\"show_urls_images_backend\\":\\"\\",\\"show_urls_images_frontend\\":\\"\\"}","version":1,"ordering":null,"metakey":"","metadesc":"","access":"1","hits":null,"metadata":"{\\"robots\\":\\"\\",\\"author\\":\\"\\",\\"rights\\":\\"\\",\\"xreference\\":\\"\\"}","featured":"0","language":"*","xreference":""}	0
\.


--
-- Name: j_ucm_history_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_ucm_history_version_id_seq', 2, true);


--
-- Data for Name: j_update_sites; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_update_sites (update_site_id, name, type, location, enabled, last_check_timestamp, extra_query) FROM stdin;
2	Accredited Joomla! Translations	collection	https://update.joomla.org/language/translationlist_3.xml	1	0	
3	Joomla! Update Component Update Site	extension	https://update.joomla.org/core/extensions/com_joomlaupdate.xml	1	0	
1	Joomla! Core	collection	https://update.joomla.org/core/list.xml	1	1581483063	
\.


--
-- Data for Name: j_update_sites_extensions; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_update_sites_extensions (update_site_id, extension_id) FROM stdin;
1	700
2	802
3	28
\.


--
-- Name: j_update_sites_update_site_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_update_sites_update_site_id_seq', 4, false);


--
-- Data for Name: j_updates; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_updates (update_id, update_site_id, extension_id, name, description, element, type, folder, client_id, version, data, detailsurl, infourl, extra_query) FROM stdin;
\.


--
-- Name: j_updates_update_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_updates_update_id_seq', 1, false);


--
-- Data for Name: j_user_keys; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_user_keys (id, user_id, token, series, invalid, "time", uastring) FROM stdin;
\.


--
-- Name: j_user_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_user_keys_id_seq', 1, false);


--
-- Data for Name: j_user_notes; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_user_notes (id, user_id, catid, subject, body, state, checked_out, checked_out_time, created_user_id, created_time, modified_user_id, modified_time, review_time, publish_up, publish_down) FROM stdin;
\.


--
-- Name: j_user_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_user_notes_id_seq', 1, false);


--
-- Data for Name: j_user_profiles; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_user_profiles (user_id, profile_key, profile_value, ordering) FROM stdin;
\.


--
-- Data for Name: j_user_usergroup_map; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_user_usergroup_map (user_id, group_id) FROM stdin;
698	8
\.


--
-- Data for Name: j_usergroups; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_usergroups (id, parent_id, lft, rgt, title) FROM stdin;
1	0	1	18	Public
2	1	8	15	Registered
3	2	9	14	Author
4	3	10	13	Editor
5	4	11	12	Publisher
6	1	4	7	Manager
7	6	5	6	Administrator
8	1	16	17	Super Users
9	1	2	3	Guest
\.


--
-- Name: j_usergroups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_usergroups_id_seq', 10, false);


--
-- Data for Name: j_users; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_users (id, name, username, email, password, block, "sendEmail", "registerDate", "lastvisitDate", activation, params, "lastResetTime", "resetCount", "otpKey", otep, "requireReset") FROM stdin;
698	Super User	joomlapoc	poc@joomla.com	$2y$10$2PDylr96pmPxz14iAnwR2uUtPt8kVwpjv9X/5htPFmpKPjIcUZ8V.	0	1	2020-02-12 04:50:58	1970-01-01 00:00:00	0		1970-01-01 00:00:00	0			0
\.


--
-- Name: j_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_users_id_seq', 1, false);


--
-- Data for Name: j_viewlevels; Type: TABLE DATA; Schema: public; Owner: temp_user
--

COPY public.j_viewlevels (id, title, ordering, rules) FROM stdin;
1	Public	0	[1]
2	Registered	2	[6,2,8]
3	Special	3	[6,3,8]
5	Guest	1	[9]
6	Super Users	4	[8]
\.


--
-- Name: j_viewlevels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: temp_user
--

SELECT pg_catalog.setval('public.j_viewlevels_id_seq', 7, false);


--
-- Name: j_action_log_config j_action_log_config_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_action_log_config
    ADD CONSTRAINT j_action_log_config_pkey PRIMARY KEY (id);


--
-- Name: j_action_logs_extensions j_action_logs_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_action_logs_extensions
    ADD CONSTRAINT j_action_logs_extensions_pkey PRIMARY KEY (id);


--
-- Name: j_action_logs j_action_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_action_logs
    ADD CONSTRAINT j_action_logs_pkey PRIMARY KEY (id);


--
-- Name: j_action_logs_users j_action_logs_users_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_action_logs_users
    ADD CONSTRAINT j_action_logs_users_pkey PRIMARY KEY (user_id);


--
-- Name: j_assets j_assets_idx_asset_name; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_assets
    ADD CONSTRAINT j_assets_idx_asset_name UNIQUE (name);


--
-- Name: j_assets j_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_assets
    ADD CONSTRAINT j_assets_pkey PRIMARY KEY (id);


--
-- Name: j_associations j_associations_idx_context_id; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_associations
    ADD CONSTRAINT j_associations_idx_context_id PRIMARY KEY (context, id);


--
-- Name: j_banner_clients j_banner_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_banner_clients
    ADD CONSTRAINT j_banner_clients_pkey PRIMARY KEY (id);


--
-- Name: j_banner_tracks j_banner_tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_banner_tracks
    ADD CONSTRAINT j_banner_tracks_pkey PRIMARY KEY (track_date, track_type, banner_id);


--
-- Name: j_banners j_banners_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_banners
    ADD CONSTRAINT j_banners_pkey PRIMARY KEY (id);


--
-- Name: j_categories j_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_categories
    ADD CONSTRAINT j_categories_pkey PRIMARY KEY (id);


--
-- Name: j_contact_details j_contact_details_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_contact_details
    ADD CONSTRAINT j_contact_details_pkey PRIMARY KEY (id);


--
-- Name: j_content_frontpage j_content_frontpage_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_content_frontpage
    ADD CONSTRAINT j_content_frontpage_pkey PRIMARY KEY (content_id);


--
-- Name: j_content j_content_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_content
    ADD CONSTRAINT j_content_pkey PRIMARY KEY (id);


--
-- Name: j_content_rating j_content_rating_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_content_rating
    ADD CONSTRAINT j_content_rating_pkey PRIMARY KEY (content_id);


--
-- Name: j_content_types j_content_types_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_content_types
    ADD CONSTRAINT j_content_types_pkey PRIMARY KEY (type_id);


--
-- Name: j_extensions j_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_extensions
    ADD CONSTRAINT j_extensions_pkey PRIMARY KEY (extension_id);


--
-- Name: j_fields_categories j_fields_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_fields_categories
    ADD CONSTRAINT j_fields_categories_pkey PRIMARY KEY (field_id, category_id);


--
-- Name: j_fields_groups j_fields_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_fields_groups
    ADD CONSTRAINT j_fields_groups_pkey PRIMARY KEY (id);


--
-- Name: j_fields j_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_fields
    ADD CONSTRAINT j_fields_pkey PRIMARY KEY (id);


--
-- Name: j_finder_filters j_finder_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_filters
    ADD CONSTRAINT j_finder_filters_pkey PRIMARY KEY (filter_id);


--
-- Name: j_finder_links j_finder_links_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links
    ADD CONSTRAINT j_finder_links_pkey PRIMARY KEY (link_id);


--
-- Name: j_finder_links_terms0 j_finder_links_terms0_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms0
    ADD CONSTRAINT j_finder_links_terms0_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_terms1 j_finder_links_terms1_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms1
    ADD CONSTRAINT j_finder_links_terms1_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_terms2 j_finder_links_terms2_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms2
    ADD CONSTRAINT j_finder_links_terms2_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_terms3 j_finder_links_terms3_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms3
    ADD CONSTRAINT j_finder_links_terms3_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_terms4 j_finder_links_terms4_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms4
    ADD CONSTRAINT j_finder_links_terms4_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_terms5 j_finder_links_terms5_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms5
    ADD CONSTRAINT j_finder_links_terms5_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_terms6 j_finder_links_terms6_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms6
    ADD CONSTRAINT j_finder_links_terms6_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_terms7 j_finder_links_terms7_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms7
    ADD CONSTRAINT j_finder_links_terms7_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_terms8 j_finder_links_terms8_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms8
    ADD CONSTRAINT j_finder_links_terms8_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_terms9 j_finder_links_terms9_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_terms9
    ADD CONSTRAINT j_finder_links_terms9_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_termsa j_finder_links_termsa_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_termsa
    ADD CONSTRAINT j_finder_links_termsa_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_termsb j_finder_links_termsb_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_termsb
    ADD CONSTRAINT j_finder_links_termsb_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_termsc j_finder_links_termsc_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_termsc
    ADD CONSTRAINT j_finder_links_termsc_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_termsd j_finder_links_termsd_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_termsd
    ADD CONSTRAINT j_finder_links_termsd_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_termse j_finder_links_termse_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_termse
    ADD CONSTRAINT j_finder_links_termse_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_links_termsf j_finder_links_termsf_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_links_termsf
    ADD CONSTRAINT j_finder_links_termsf_pkey PRIMARY KEY (link_id, term_id);


--
-- Name: j_finder_taxonomy_map j_finder_taxonomy_map_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_taxonomy_map
    ADD CONSTRAINT j_finder_taxonomy_map_pkey PRIMARY KEY (link_id, node_id);


--
-- Name: j_finder_taxonomy j_finder_taxonomy_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_taxonomy
    ADD CONSTRAINT j_finder_taxonomy_pkey PRIMARY KEY (id);


--
-- Name: j_finder_terms j_finder_terms_idx_term; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_terms
    ADD CONSTRAINT j_finder_terms_idx_term UNIQUE (term);


--
-- Name: j_finder_terms j_finder_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_terms
    ADD CONSTRAINT j_finder_terms_pkey PRIMARY KEY (term_id);


--
-- Name: j_finder_types j_finder_types_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_types
    ADD CONSTRAINT j_finder_types_pkey PRIMARY KEY (id);


--
-- Name: j_finder_types j_finder_types_title; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_finder_types
    ADD CONSTRAINT j_finder_types_title UNIQUE (title);


--
-- Name: j_languages j_languages_idx_langcode; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_languages
    ADD CONSTRAINT j_languages_idx_langcode UNIQUE (lang_code);


--
-- Name: j_languages j_languages_idx_sef; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_languages
    ADD CONSTRAINT j_languages_idx_sef UNIQUE (sef);


--
-- Name: j_languages j_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_languages
    ADD CONSTRAINT j_languages_pkey PRIMARY KEY (lang_id);


--
-- Name: j_menu j_menu_idx_client_id_parent_id_alias_language; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_menu
    ADD CONSTRAINT j_menu_idx_client_id_parent_id_alias_language UNIQUE (client_id, parent_id, alias, language);


--
-- Name: j_menu j_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_menu
    ADD CONSTRAINT j_menu_pkey PRIMARY KEY (id);


--
-- Name: j_menu_types j_menu_types_idx_menutype; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_menu_types
    ADD CONSTRAINT j_menu_types_idx_menutype UNIQUE (menutype);


--
-- Name: j_menu_types j_menu_types_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_menu_types
    ADD CONSTRAINT j_menu_types_pkey PRIMARY KEY (id);


--
-- Name: j_messages_cfg j_messages_cfg_idx_user_var_name; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_messages_cfg
    ADD CONSTRAINT j_messages_cfg_idx_user_var_name UNIQUE (user_id, cfg_name);


--
-- Name: j_messages j_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_messages
    ADD CONSTRAINT j_messages_pkey PRIMARY KEY (message_id);


--
-- Name: j_modules_menu j_modules_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_modules_menu
    ADD CONSTRAINT j_modules_menu_pkey PRIMARY KEY (moduleid, menuid);


--
-- Name: j_modules j_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_modules
    ADD CONSTRAINT j_modules_pkey PRIMARY KEY (id);


--
-- Name: j_newsfeeds j_newsfeeds_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_newsfeeds
    ADD CONSTRAINT j_newsfeeds_pkey PRIMARY KEY (id);


--
-- Name: j_overrider j_overrider_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_overrider
    ADD CONSTRAINT j_overrider_pkey PRIMARY KEY (id);


--
-- Name: j_postinstall_messages j_postinstall_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_postinstall_messages
    ADD CONSTRAINT j_postinstall_messages_pkey PRIMARY KEY (postinstall_message_id);


--
-- Name: j_privacy_consents j_privacy_consents_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_privacy_consents
    ADD CONSTRAINT j_privacy_consents_pkey PRIMARY KEY (id);


--
-- Name: j_privacy_requests j_privacy_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_privacy_requests
    ADD CONSTRAINT j_privacy_requests_pkey PRIMARY KEY (id);


--
-- Name: j_redirect_links j_redirect_links_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_redirect_links
    ADD CONSTRAINT j_redirect_links_pkey PRIMARY KEY (id);


--
-- Name: j_schemas j_schemas_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_schemas
    ADD CONSTRAINT j_schemas_pkey PRIMARY KEY (extension_id, version_id);


--
-- Name: j_session j_session_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_session
    ADD CONSTRAINT j_session_pkey PRIMARY KEY (session_id);


--
-- Name: j_tags j_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_tags
    ADD CONSTRAINT j_tags_pkey PRIMARY KEY (id);


--
-- Name: j_template_styles j_template_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_template_styles
    ADD CONSTRAINT j_template_styles_pkey PRIMARY KEY (id);


--
-- Name: j_contentitem_tag_map j_uc_ItemnameTagid; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_contentitem_tag_map
    ADD CONSTRAINT "j_uc_ItemnameTagid" UNIQUE (type_id, content_item_id, tag_id);


--
-- Name: j_ucm_base j_ucm_base_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_ucm_base
    ADD CONSTRAINT j_ucm_base_pkey PRIMARY KEY (ucm_id);


--
-- Name: j_ucm_content j_ucm_content_idx_type_alias_item_id; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_ucm_content
    ADD CONSTRAINT j_ucm_content_idx_type_alias_item_id UNIQUE (core_type_alias, core_content_item_id);


--
-- Name: j_ucm_content j_ucm_content_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_ucm_content
    ADD CONSTRAINT j_ucm_content_pkey PRIMARY KEY (core_content_id);


--
-- Name: j_ucm_history j_ucm_history_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_ucm_history
    ADD CONSTRAINT j_ucm_history_pkey PRIMARY KEY (version_id);


--
-- Name: j_update_sites_extensions j_update_sites_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_update_sites_extensions
    ADD CONSTRAINT j_update_sites_extensions_pkey PRIMARY KEY (update_site_id, extension_id);


--
-- Name: j_update_sites j_update_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_update_sites
    ADD CONSTRAINT j_update_sites_pkey PRIMARY KEY (update_site_id);


--
-- Name: j_updates j_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_updates
    ADD CONSTRAINT j_updates_pkey PRIMARY KEY (update_id);


--
-- Name: j_user_keys j_user_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_user_keys
    ADD CONSTRAINT j_user_keys_pkey PRIMARY KEY (id);


--
-- Name: j_user_keys j_user_keys_series; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_user_keys
    ADD CONSTRAINT j_user_keys_series UNIQUE (series);


--
-- Name: j_user_notes j_user_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_user_notes
    ADD CONSTRAINT j_user_notes_pkey PRIMARY KEY (id);


--
-- Name: j_user_profiles j_user_profiles_idx_user_id_profile_key; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_user_profiles
    ADD CONSTRAINT j_user_profiles_idx_user_id_profile_key UNIQUE (user_id, profile_key);


--
-- Name: j_user_usergroup_map j_user_usergroup_map_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_user_usergroup_map
    ADD CONSTRAINT j_user_usergroup_map_pkey PRIMARY KEY (user_id, group_id);


--
-- Name: j_usergroups j_usergroups_idx_usergroup_parent_title_lookup; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_usergroups
    ADD CONSTRAINT j_usergroups_idx_usergroup_parent_title_lookup UNIQUE (parent_id, title);


--
-- Name: j_usergroups j_usergroups_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_usergroups
    ADD CONSTRAINT j_usergroups_pkey PRIMARY KEY (id);


--
-- Name: j_users j_users_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_users
    ADD CONSTRAINT j_users_pkey PRIMARY KEY (id);


--
-- Name: j_viewlevels j_viewlevels_idx_assetgroup_title_lookup; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_viewlevels
    ADD CONSTRAINT j_viewlevels_idx_assetgroup_title_lookup UNIQUE (title);


--
-- Name: j_viewlevels j_viewlevels_pkey; Type: CONSTRAINT; Schema: public; Owner: temp_user
--

ALTER TABLE ONLY public.j_viewlevels
    ADD CONSTRAINT j_viewlevels_pkey PRIMARY KEY (id);


--
-- Name: _j_finder_tokens_aggregate_keyword_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX _j_finder_tokens_aggregate_keyword_id ON public.j_finder_tokens_aggregate USING btree (term_id);


--
-- Name: j_action_logs_idx_extension_itemid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_action_logs_idx_extension_itemid ON public.j_action_logs USING btree (extension, item_id);


--
-- Name: j_action_logs_idx_user_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_action_logs_idx_user_id ON public.j_action_logs USING btree (user_id);


--
-- Name: j_action_logs_idx_user_id_extension; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_action_logs_idx_user_id_extension ON public.j_action_logs USING btree (user_id, extension);


--
-- Name: j_action_logs_idx_user_id_logdate; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_action_logs_idx_user_id_logdate ON public.j_action_logs USING btree (user_id, log_date);


--
-- Name: j_action_logs_users_idx_notify; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_action_logs_users_idx_notify ON public.j_action_logs_users USING btree (notify);


--
-- Name: j_assets_idx_lft_rgt; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_assets_idx_lft_rgt ON public.j_assets USING btree (lft, rgt);


--
-- Name: j_assets_idx_parent_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_assets_idx_parent_id ON public.j_assets USING btree (parent_id);


--
-- Name: j_associations_idx_key; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_associations_idx_key ON public.j_associations USING btree (key);


--
-- Name: j_banner_clients_idx_metakey_prefix; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banner_clients_idx_metakey_prefix ON public.j_banner_clients USING btree (metakey_prefix);


--
-- Name: j_banner_clients_idx_own_prefix; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banner_clients_idx_own_prefix ON public.j_banner_clients USING btree (own_prefix);


--
-- Name: j_banner_tracks_idx_banner_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banner_tracks_idx_banner_id ON public.j_banner_tracks USING btree (banner_id);


--
-- Name: j_banner_tracks_idx_track_date; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banner_tracks_idx_track_date ON public.j_banner_tracks USING btree (track_date);


--
-- Name: j_banner_tracks_idx_track_type; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banner_tracks_idx_track_type ON public.j_banner_tracks USING btree (track_type);


--
-- Name: j_banners_idx_banner_catid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banners_idx_banner_catid ON public.j_banners USING btree (catid);


--
-- Name: j_banners_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banners_idx_language ON public.j_banners USING btree (language);


--
-- Name: j_banners_idx_metakey_prefix; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banners_idx_metakey_prefix ON public.j_banners USING btree (metakey_prefix);


--
-- Name: j_banners_idx_own_prefix; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banners_idx_own_prefix ON public.j_banners USING btree (own_prefix);


--
-- Name: j_banners_idx_state; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_banners_idx_state ON public.j_banners USING btree (state);


--
-- Name: j_categories_cat_idx; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_categories_cat_idx ON public.j_categories USING btree (extension, published, access);


--
-- Name: j_categories_idx_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_categories_idx_access ON public.j_categories USING btree (access);


--
-- Name: j_categories_idx_alias; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_categories_idx_alias ON public.j_categories USING btree (alias);


--
-- Name: j_categories_idx_checkout; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_categories_idx_checkout ON public.j_categories USING btree (checked_out);


--
-- Name: j_categories_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_categories_idx_language ON public.j_categories USING btree (language);


--
-- Name: j_categories_idx_left_right; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_categories_idx_left_right ON public.j_categories USING btree (lft, rgt);


--
-- Name: j_categories_idx_path; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_categories_idx_path ON public.j_categories USING btree (path);


--
-- Name: j_contact_details_idx_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contact_details_idx_access ON public.j_contact_details USING btree (access);


--
-- Name: j_contact_details_idx_catid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contact_details_idx_catid ON public.j_contact_details USING btree (catid);


--
-- Name: j_contact_details_idx_checkout; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contact_details_idx_checkout ON public.j_contact_details USING btree (checked_out);


--
-- Name: j_contact_details_idx_createdby; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contact_details_idx_createdby ON public.j_contact_details USING btree (created_by);


--
-- Name: j_contact_details_idx_featured_catid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contact_details_idx_featured_catid ON public.j_contact_details USING btree (featured, catid);


--
-- Name: j_contact_details_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contact_details_idx_language ON public.j_contact_details USING btree (language);


--
-- Name: j_contact_details_idx_state; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contact_details_idx_state ON public.j_contact_details USING btree (published);


--
-- Name: j_contact_details_idx_xreference; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contact_details_idx_xreference ON public.j_contact_details USING btree (xreference);


--
-- Name: j_content_idx_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_idx_access ON public.j_content USING btree (access);


--
-- Name: j_content_idx_alias; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_idx_alias ON public.j_content USING btree (alias);


--
-- Name: j_content_idx_catid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_idx_catid ON public.j_content USING btree (catid);


--
-- Name: j_content_idx_checkout; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_idx_checkout ON public.j_content USING btree (checked_out);


--
-- Name: j_content_idx_createdby; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_idx_createdby ON public.j_content USING btree (created_by);


--
-- Name: j_content_idx_featured_catid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_idx_featured_catid ON public.j_content USING btree (featured, catid);


--
-- Name: j_content_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_idx_language ON public.j_content USING btree (language);


--
-- Name: j_content_idx_state; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_idx_state ON public.j_content USING btree (state);


--
-- Name: j_content_idx_xreference; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_idx_xreference ON public.j_content USING btree (xreference);


--
-- Name: j_content_types_idx_alias; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_content_types_idx_alias ON public.j_content_types USING btree (type_alias);


--
-- Name: j_contentitem_tag_map_idx_core_content_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contentitem_tag_map_idx_core_content_id ON public.j_contentitem_tag_map USING btree (core_content_id);


--
-- Name: j_contentitem_tag_map_idx_date_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contentitem_tag_map_idx_date_id ON public.j_contentitem_tag_map USING btree (tag_date, tag_id);


--
-- Name: j_contentitem_tag_map_idx_tag_type; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_contentitem_tag_map_idx_tag_type ON public.j_contentitem_tag_map USING btree (tag_id, type_id);


--
-- Name: j_extensions_element_clientid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_extensions_element_clientid ON public.j_extensions USING btree (element, client_id);


--
-- Name: j_extensions_element_folder_clientid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_extensions_element_folder_clientid ON public.j_extensions USING btree (element, folder, client_id);


--
-- Name: j_extensions_extension; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_extensions_extension ON public.j_extensions USING btree (type, element, folder, client_id);


--
-- Name: j_fields_groups_idx_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_groups_idx_access ON public.j_fields_groups USING btree (access);


--
-- Name: j_fields_groups_idx_checked_out; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_groups_idx_checked_out ON public.j_fields_groups USING btree (checked_out);


--
-- Name: j_fields_groups_idx_context; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_groups_idx_context ON public.j_fields_groups USING btree (context);


--
-- Name: j_fields_groups_idx_created_by; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_groups_idx_created_by ON public.j_fields_groups USING btree (created_by);


--
-- Name: j_fields_groups_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_groups_idx_language ON public.j_fields_groups USING btree (language);


--
-- Name: j_fields_groups_idx_state; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_groups_idx_state ON public.j_fields_groups USING btree (state);


--
-- Name: j_fields_idx_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_idx_access ON public.j_fields USING btree (access);


--
-- Name: j_fields_idx_checked_out; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_idx_checked_out ON public.j_fields USING btree (checked_out);


--
-- Name: j_fields_idx_context; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_idx_context ON public.j_fields USING btree (context);


--
-- Name: j_fields_idx_created_user_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_idx_created_user_id ON public.j_fields USING btree (created_user_id);


--
-- Name: j_fields_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_idx_language ON public.j_fields USING btree (language);


--
-- Name: j_fields_idx_state; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_idx_state ON public.j_fields USING btree (state);


--
-- Name: j_fields_values_idx_field_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_values_idx_field_id ON public.j_fields_values USING btree (field_id);


--
-- Name: j_fields_values_idx_item_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_fields_values_idx_item_id ON public.j_fields_values USING btree (item_id);


--
-- Name: j_finder_links_idx_md5; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_idx_md5 ON public.j_finder_links USING btree (md5sum);


--
-- Name: j_finder_links_idx_published_list; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_idx_published_list ON public.j_finder_links USING btree (published, state, access, publish_start_date, publish_end_date, list_price);


--
-- Name: j_finder_links_idx_published_sale; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_idx_published_sale ON public.j_finder_links USING btree (published, state, access, publish_start_date, publish_end_date, sale_price);


--
-- Name: j_finder_links_idx_title; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_idx_title ON public.j_finder_links USING btree (title);


--
-- Name: j_finder_links_idx_type; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_idx_type ON public.j_finder_links USING btree (type_id);


--
-- Name: j_finder_links_idx_url; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_idx_url ON public.j_finder_links USING btree (substr((url)::text, 0, 76));


--
-- Name: j_finder_links_terms0_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms0_idx_link_term_weight ON public.j_finder_links_terms0 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms0_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms0_idx_term_weight ON public.j_finder_links_terms0 USING btree (term_id, weight);


--
-- Name: j_finder_links_terms1_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms1_idx_link_term_weight ON public.j_finder_links_terms1 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms1_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms1_idx_term_weight ON public.j_finder_links_terms1 USING btree (term_id, weight);


--
-- Name: j_finder_links_terms2_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms2_idx_link_term_weight ON public.j_finder_links_terms2 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms2_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms2_idx_term_weight ON public.j_finder_links_terms2 USING btree (term_id, weight);


--
-- Name: j_finder_links_terms3_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms3_idx_link_term_weight ON public.j_finder_links_terms3 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms3_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms3_idx_term_weight ON public.j_finder_links_terms3 USING btree (term_id, weight);


--
-- Name: j_finder_links_terms4_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms4_idx_link_term_weight ON public.j_finder_links_terms4 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms4_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms4_idx_term_weight ON public.j_finder_links_terms4 USING btree (term_id, weight);


--
-- Name: j_finder_links_terms5_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms5_idx_link_term_weight ON public.j_finder_links_terms5 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms5_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms5_idx_term_weight ON public.j_finder_links_terms5 USING btree (term_id, weight);


--
-- Name: j_finder_links_terms6_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms6_idx_link_term_weight ON public.j_finder_links_terms6 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms6_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms6_idx_term_weight ON public.j_finder_links_terms6 USING btree (term_id, weight);


--
-- Name: j_finder_links_terms7_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms7_idx_link_term_weight ON public.j_finder_links_terms7 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms7_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms7_idx_term_weight ON public.j_finder_links_terms7 USING btree (term_id, weight);


--
-- Name: j_finder_links_terms8_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms8_idx_link_term_weight ON public.j_finder_links_terms8 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms8_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms8_idx_term_weight ON public.j_finder_links_terms8 USING btree (term_id, weight);


--
-- Name: j_finder_links_terms9_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms9_idx_link_term_weight ON public.j_finder_links_terms9 USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_terms9_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_terms9_idx_term_weight ON public.j_finder_links_terms9 USING btree (term_id, weight);


--
-- Name: j_finder_links_termsa_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsa_idx_link_term_weight ON public.j_finder_links_termsa USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_termsa_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsa_idx_term_weight ON public.j_finder_links_termsa USING btree (term_id, weight);


--
-- Name: j_finder_links_termsb_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsb_idx_link_term_weight ON public.j_finder_links_termsb USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_termsb_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsb_idx_term_weight ON public.j_finder_links_termsb USING btree (term_id, weight);


--
-- Name: j_finder_links_termsc_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsc_idx_link_term_weight ON public.j_finder_links_termsc USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_termsc_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsc_idx_term_weight ON public.j_finder_links_termsc USING btree (term_id, weight);


--
-- Name: j_finder_links_termsd_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsd_idx_link_term_weight ON public.j_finder_links_termsd USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_termsd_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsd_idx_term_weight ON public.j_finder_links_termsd USING btree (term_id, weight);


--
-- Name: j_finder_links_termse_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termse_idx_link_term_weight ON public.j_finder_links_termse USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_termse_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termse_idx_term_weight ON public.j_finder_links_termse USING btree (term_id, weight);


--
-- Name: j_finder_links_termsf_idx_link_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsf_idx_link_term_weight ON public.j_finder_links_termsf USING btree (link_id, term_id, weight);


--
-- Name: j_finder_links_termsf_idx_term_weight; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_links_termsf_idx_term_weight ON public.j_finder_links_termsf USING btree (term_id, weight);


--
-- Name: j_finder_taxonomy_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_taxonomy_access ON public.j_finder_taxonomy USING btree (access);


--
-- Name: j_finder_taxonomy_idx_parent_published; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_taxonomy_idx_parent_published ON public.j_finder_taxonomy USING btree (parent_id, state, access);


--
-- Name: j_finder_taxonomy_map_link_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_taxonomy_map_link_id ON public.j_finder_taxonomy_map USING btree (link_id);


--
-- Name: j_finder_taxonomy_map_node_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_taxonomy_map_node_id ON public.j_finder_taxonomy_map USING btree (node_id);


--
-- Name: j_finder_taxonomy_ordering; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_taxonomy_ordering ON public.j_finder_taxonomy USING btree (ordering);


--
-- Name: j_finder_taxonomy_parent_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_taxonomy_parent_id ON public.j_finder_taxonomy USING btree (parent_id);


--
-- Name: j_finder_taxonomy_state; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_taxonomy_state ON public.j_finder_taxonomy USING btree (state);


--
-- Name: j_finder_terms_common_idx_lang; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_terms_common_idx_lang ON public.j_finder_terms_common USING btree (language);


--
-- Name: j_finder_terms_common_idx_word_lang; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_terms_common_idx_word_lang ON public.j_finder_terms_common USING btree (term, language);


--
-- Name: j_finder_terms_idx_soundex_phrase; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_terms_idx_soundex_phrase ON public.j_finder_terms USING btree (soundex, phrase);


--
-- Name: j_finder_terms_idx_stem_phrase; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_terms_idx_stem_phrase ON public.j_finder_terms USING btree (stem, phrase);


--
-- Name: j_finder_terms_idx_term_phrase; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_terms_idx_term_phrase ON public.j_finder_terms USING btree (term, phrase);


--
-- Name: j_finder_tokens_aggregate_token; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_tokens_aggregate_token ON public.j_finder_tokens_aggregate USING btree (term);


--
-- Name: j_finder_tokens_idx_context; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_tokens_idx_context ON public.j_finder_tokens USING btree (context);


--
-- Name: j_finder_tokens_idx_word; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_finder_tokens_idx_word ON public.j_finder_tokens USING btree (term);


--
-- Name: j_languages_idx_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_languages_idx_access ON public.j_languages USING btree (access);


--
-- Name: j_languages_idx_ordering; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_languages_idx_ordering ON public.j_languages USING btree (ordering);


--
-- Name: j_menu_idx_alias; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_menu_idx_alias ON public.j_menu USING btree (alias);


--
-- Name: j_menu_idx_componentid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_menu_idx_componentid ON public.j_menu USING btree (component_id, menutype, published, access);


--
-- Name: j_menu_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_menu_idx_language ON public.j_menu USING btree (language);


--
-- Name: j_menu_idx_left_right; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_menu_idx_left_right ON public.j_menu USING btree (lft, rgt);


--
-- Name: j_menu_idx_menutype; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_menu_idx_menutype ON public.j_menu USING btree (menutype);


--
-- Name: j_menu_idx_path; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_menu_idx_path ON public.j_menu USING btree (path);


--
-- Name: j_messages_useridto_state; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_messages_useridto_state ON public.j_messages USING btree (user_id_to, state);


--
-- Name: j_modules_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_modules_idx_language ON public.j_modules USING btree (language);


--
-- Name: j_modules_newsfeeds; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_modules_newsfeeds ON public.j_modules USING btree (module, published);


--
-- Name: j_modules_published; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_modules_published ON public.j_modules USING btree (published, access);


--
-- Name: j_newsfeeds_idx_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_newsfeeds_idx_access ON public.j_newsfeeds USING btree (access);


--
-- Name: j_newsfeeds_idx_catid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_newsfeeds_idx_catid ON public.j_newsfeeds USING btree (catid);


--
-- Name: j_newsfeeds_idx_checkout; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_newsfeeds_idx_checkout ON public.j_newsfeeds USING btree (checked_out);


--
-- Name: j_newsfeeds_idx_createdby; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_newsfeeds_idx_createdby ON public.j_newsfeeds USING btree (created_by);


--
-- Name: j_newsfeeds_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_newsfeeds_idx_language ON public.j_newsfeeds USING btree (language);


--
-- Name: j_newsfeeds_idx_state; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_newsfeeds_idx_state ON public.j_newsfeeds USING btree (published);


--
-- Name: j_newsfeeds_idx_xreference; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_newsfeeds_idx_xreference ON public.j_newsfeeds USING btree (xreference);


--
-- Name: j_privacy_consents_idx_user_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_privacy_consents_idx_user_id ON public.j_privacy_consents USING btree (user_id);


--
-- Name: j_redirect_links_idx_link_modifed; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_redirect_links_idx_link_modifed ON public.j_redirect_links USING btree (modified_date);


--
-- Name: j_redirect_links_idx_old_url; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_redirect_links_idx_old_url ON public.j_redirect_links USING btree (old_url);


--
-- Name: j_session_idx_client_id_guest; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_session_idx_client_id_guest ON public.j_session USING btree (client_id, guest);


--
-- Name: j_session_time; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_session_time ON public.j_session USING btree ("time");


--
-- Name: j_session_userid; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_session_userid ON public.j_session USING btree (userid);


--
-- Name: j_tags_cat_idx; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_tags_cat_idx ON public.j_tags USING btree (published, access);


--
-- Name: j_tags_idx_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_tags_idx_access ON public.j_tags USING btree (access);


--
-- Name: j_tags_idx_alias; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_tags_idx_alias ON public.j_tags USING btree (alias);


--
-- Name: j_tags_idx_checkout; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_tags_idx_checkout ON public.j_tags USING btree (checked_out);


--
-- Name: j_tags_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_tags_idx_language ON public.j_tags USING btree (language);


--
-- Name: j_tags_idx_left_right; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_tags_idx_left_right ON public.j_tags USING btree (lft, rgt);


--
-- Name: j_tags_idx_path; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_tags_idx_path ON public.j_tags USING btree (path);


--
-- Name: j_template_styles_idx_client_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_template_styles_idx_client_id ON public.j_template_styles USING btree (client_id);


--
-- Name: j_template_styles_idx_client_id_home; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_template_styles_idx_client_id_home ON public.j_template_styles USING btree (client_id, home);


--
-- Name: j_template_styles_idx_template; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_template_styles_idx_template ON public.j_template_styles USING btree (template);


--
-- Name: j_ucm_base_ucm_item_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_base_ucm_item_id ON public.j_ucm_base USING btree (ucm_item_id);


--
-- Name: j_ucm_base_ucm_language_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_base_ucm_language_id ON public.j_ucm_base USING btree (ucm_language_id);


--
-- Name: j_ucm_base_ucm_type_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_base_ucm_type_id ON public.j_ucm_base USING btree (ucm_type_id);


--
-- Name: j_ucm_content_idx_access; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_access ON public.j_ucm_content USING btree (core_access);


--
-- Name: j_ucm_content_idx_alias; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_alias ON public.j_ucm_content USING btree (core_alias);


--
-- Name: j_ucm_content_idx_content_type; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_content_type ON public.j_ucm_content USING btree (core_type_alias);


--
-- Name: j_ucm_content_idx_core_checked_out_user_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_core_checked_out_user_id ON public.j_ucm_content USING btree (core_checked_out_user_id);


--
-- Name: j_ucm_content_idx_core_created_user_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_core_created_user_id ON public.j_ucm_content USING btree (core_created_user_id);


--
-- Name: j_ucm_content_idx_core_modified_user_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_core_modified_user_id ON public.j_ucm_content USING btree (core_modified_user_id);


--
-- Name: j_ucm_content_idx_core_type_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_core_type_id ON public.j_ucm_content USING btree (core_type_id);


--
-- Name: j_ucm_content_idx_created_time; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_created_time ON public.j_ucm_content USING btree (core_created_time);


--
-- Name: j_ucm_content_idx_language; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_language ON public.j_ucm_content USING btree (core_language);


--
-- Name: j_ucm_content_idx_modified_time; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_modified_time ON public.j_ucm_content USING btree (core_modified_time);


--
-- Name: j_ucm_content_idx_title; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_idx_title ON public.j_ucm_content USING btree (core_title);


--
-- Name: j_ucm_content_tag_idx; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_content_tag_idx ON public.j_ucm_content USING btree (core_state, core_access);


--
-- Name: j_ucm_history_idx_save_date; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_history_idx_save_date ON public.j_ucm_history USING btree (save_date);


--
-- Name: j_ucm_history_idx_ucm_item_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_ucm_history_idx_ucm_item_id ON public.j_ucm_history USING btree (ucm_type_id, ucm_item_id);


--
-- Name: j_user_keys_idx_user_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_user_keys_idx_user_id ON public.j_user_keys USING btree (user_id);


--
-- Name: j_user_notes_idx_category_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_user_notes_idx_category_id ON public.j_user_notes USING btree (catid);


--
-- Name: j_user_notes_idx_user_id; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_user_notes_idx_user_id ON public.j_user_notes USING btree (user_id);


--
-- Name: j_usergroups_idx_usergroup_adjacency_lookup; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_usergroups_idx_usergroup_adjacency_lookup ON public.j_usergroups USING btree (parent_id);


--
-- Name: j_usergroups_idx_usergroup_nested_set_lookup; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_usergroups_idx_usergroup_nested_set_lookup ON public.j_usergroups USING btree (lft, rgt);


--
-- Name: j_usergroups_idx_usergroup_title_lookup; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_usergroups_idx_usergroup_title_lookup ON public.j_usergroups USING btree (title);


--
-- Name: j_users_email; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_users_email ON public.j_users USING btree (email);


--
-- Name: j_users_email_lower; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_users_email_lower ON public.j_users USING btree (lower((email)::text));


--
-- Name: j_users_idx_block; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_users_idx_block ON public.j_users USING btree (block);


--
-- Name: j_users_idx_name; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_users_idx_name ON public.j_users USING btree (name);


--
-- Name: j_users_username; Type: INDEX; Schema: public; Owner: temp_user
--

CREATE INDEX j_users_username ON public.j_users USING btree (username);


--
-- PostgreSQL database dump complete
--

