--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: album; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE album (
    album_id integer NOT NULL,
    artist_id integer NOT NULL,
    album_mbid character(36) NOT NULL,
    type character varying NOT NULL,
    title character varying NOT NULL,
    released date,
    asin character varying
);


ALTER TABLE public.album OWNER TO canidae;

--
-- Name: artist; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE artist (
    artist_id integer NOT NULL,
    artist_mbid character(36) NOT NULL,
    type character varying NOT NULL,
    name character varying NOT NULL,
    sortname character varying NOT NULL
);


ALTER TABLE public.artist OWNER TO canidae;

--
-- Name: client; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE client (
    client_id integer NOT NULL,
    name character varying NOT NULL,
    password character(32) NOT NULL
);


ALTER TABLE public.client OWNER TO canidae;

--
-- Name: client_settings; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE client_settings (
    client_id integer NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL
);


ALTER TABLE public.client_settings OWNER TO canidae;

--
-- Name: file; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE file (
    file_id integer NOT NULL,
    client_id integer NOT NULL,
    track_id integer,
    filename character varying NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL,
    duration integer,
    channels integer,
    bitrate integer,
    sample_rate integer,
    puid character(36)
);


ALTER TABLE public.file OWNER TO canidae;

--
-- Name: metadata; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE metadata (
    metadata_id integer NOT NULL,
    file_id integer NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL
);


ALTER TABLE public.metadata OWNER TO canidae;

--
-- Name: track; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE track (
    track_id integer NOT NULL,
    album_id integer NOT NULL,
    artist_id integer,
    track_mbid character(36) NOT NULL,
    title character varying NOT NULL,
    duration integer
);


ALTER TABLE public.track OWNER TO canidae;

--
-- Name: album_album_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE album_album_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.album_album_id_seq OWNER TO canidae;

--
-- Name: album_album_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE album_album_id_seq OWNED BY album.album_id;


--
-- Name: album_album_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('album_album_id_seq', 1, false);


--
-- Name: artist_artist_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE artist_artist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.artist_artist_id_seq OWNER TO canidae;

--
-- Name: artist_artist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE artist_artist_id_seq OWNED BY artist.artist_id;


--
-- Name: artist_artist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('artist_artist_id_seq', 1, false);


--
-- Name: client_client_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE client_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.client_client_id_seq OWNER TO canidae;

--
-- Name: client_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE client_client_id_seq OWNED BY client.client_id;


--
-- Name: client_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('client_client_id_seq', 1, false);


--
-- Name: file_file_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE file_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.file_file_id_seq OWNER TO canidae;

--
-- Name: file_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE file_file_id_seq OWNED BY file.file_id;


--
-- Name: file_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('file_file_id_seq', 1, false);


--
-- Name: metadata_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE metadata_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.metadata_metadata_id_seq OWNER TO canidae;

--
-- Name: metadata_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE metadata_metadata_id_seq OWNED BY metadata.metadata_id;


--
-- Name: metadata_metadata_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('metadata_metadata_id_seq', 1, false);


--
-- Name: track_track_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE track_track_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.track_track_id_seq OWNER TO canidae;

--
-- Name: track_track_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE track_track_id_seq OWNED BY track.track_id;


--
-- Name: track_track_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('track_track_id_seq', 1, false);


--
-- Name: album_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE album ALTER COLUMN album_id SET DEFAULT nextval('album_album_id_seq'::regclass);


--
-- Name: artist_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE artist ALTER COLUMN artist_id SET DEFAULT nextval('artist_artist_id_seq'::regclass);


--
-- Name: client_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE client ALTER COLUMN client_id SET DEFAULT nextval('client_client_id_seq'::regclass);


--
-- Name: file_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE file ALTER COLUMN file_id SET DEFAULT nextval('file_file_id_seq'::regclass);


--
-- Name: metadata_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE metadata ALTER COLUMN metadata_id SET DEFAULT nextval('metadata_metadata_id_seq'::regclass);


--
-- Name: track_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE track ALTER COLUMN track_id SET DEFAULT nextval('track_track_id_seq'::regclass);


--
-- Data for Name: album; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY album (album_id, artist_id, album_mbid, type, title, released, asin) FROM stdin;
\.


--
-- Data for Name: artist; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY artist (artist_id, artist_mbid, type, name, sortname) FROM stdin;
\.


--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY client (client_id, name, password) FROM stdin;
\.


--
-- Data for Name: client_settings; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY client_settings (client_id, key, value) FROM stdin;
\.


--
-- Data for Name: file; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY file (file_id, client_id, track_id, filename, last_updated, duration, channels, bitrate, sample_rate, puid) FROM stdin;
\.


--
-- Data for Name: metadata; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY metadata (metadata_id, file_id, key, value) FROM stdin;
\.


--
-- Data for Name: track; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY track (track_id, album_id, artist_id, track_mbid, title, duration) FROM stdin;
\.


--
-- Name: album_album_mbid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_album_mbid_key UNIQUE (album_mbid);


--
-- Name: album_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_pkey PRIMARY KEY (album_id);


--
-- Name: artist_artist_mbid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY artist
    ADD CONSTRAINT artist_artist_mbid_key UNIQUE (artist_mbid);


--
-- Name: artist_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY artist
    ADD CONSTRAINT artist_pkey PRIMARY KEY (artist_id);


--
-- Name: client_name_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY client
    ADD CONSTRAINT client_name_key UNIQUE (name, password);


--
-- Name: client_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- Name: client_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY client_settings
    ADD CONSTRAINT client_settings_pkey PRIMARY KEY (client_id, key);


--
-- Name: file_filename_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_filename_key UNIQUE (filename);


--
-- Name: file_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_pkey PRIMARY KEY (file_id);


--
-- Name: metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY metadata
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (metadata_id);


--
-- Name: track_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_pkey PRIMARY KEY (track_id);


--
-- Name: track_track_mbid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_track_mbid_key UNIQUE (track_mbid);


--
-- Name: album_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: client_settings_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY client_settings
    ADD CONSTRAINT client_settings_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(client_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: file_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(client_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: file_track_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_track_id_fkey FOREIGN KEY (track_id) REFERENCES track(track_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: metadata_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY metadata
    ADD CONSTRAINT metadata_file_id_fkey FOREIGN KEY (file_id) REFERENCES file(file_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: track_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_album_id_fkey FOREIGN KEY (album_id) REFERENCES album(album_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: track_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

