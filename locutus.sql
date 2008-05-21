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
    mbid character(36) NOT NULL,
    type character varying,
    title character varying NOT NULL,
    released date,
    custom_artist_sortname character varying,
    loaded boolean DEFAULT false NOT NULL,
    updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.album OWNER TO canidae;

--
-- Name: artist; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE artist (
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    name character varying NOT NULL,
    sortname character varying,
    loaded boolean DEFAULT false NOT NULL
);


ALTER TABLE public.artist OWNER TO canidae;

--
-- Name: file; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE file (
    file_id integer NOT NULL,
    track_id integer,
    filename character varying NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL,
    duration integer NOT NULL,
    channels integer NOT NULL,
    bitrate integer NOT NULL,
    samplerate integer NOT NULL,
    puid_id integer,
    album character varying NOT NULL,
    albumartist character varying NOT NULL,
    albumartistsort character varying NOT NULL,
    artist character varying NOT NULL,
    artistsort character varying NOT NULL,
    musicbrainz_albumartistid character(36) NOT NULL,
    musicbrainz_albumid character(36) NOT NULL,
    musicbrainz_artistid character(36) NOT NULL,
    musicbrainz_trackid character(36) NOT NULL,
    title character varying NOT NULL,
    tracknumber character varying NOT NULL,
    year character varying NOT NULL
);


ALTER TABLE public.file OWNER TO canidae;

--
-- Name: possible_match; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE possible_match (
    file_id integer NOT NULL,
    track_id integer NOT NULL,
    meta_score double precision NOT NULL,
    mbid_match boolean NOT NULL,
    puid_match boolean NOT NULL
);


ALTER TABLE public.possible_match OWNER TO canidae;

--
-- Name: puid; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE puid (
    puid_id integer NOT NULL,
    puid character(36) NOT NULL
);


ALTER TABLE public.puid OWNER TO canidae;

--
-- Name: puid_track; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE puid_track (
    puid_id integer NOT NULL,
    track_id integer NOT NULL,
    updated date DEFAULT now() NOT NULL
);


ALTER TABLE public.puid_track OWNER TO canidae;

--
-- Name: setting; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE setting (
    setting_id integer NOT NULL,
    setting_class_id integer NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL,
    user_changed boolean DEFAULT false NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.setting OWNER TO canidae;

--
-- Name: setting_class; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE setting_class (
    setting_class_id integer NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.setting_class OWNER TO canidae;

--
-- Name: track; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE track (
    track_id integer NOT NULL,
    album_id integer NOT NULL,
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    title character varying NOT NULL,
    duration integer,
    tracknumber integer NOT NULL
);


ALTER TABLE public.track OWNER TO canidae;

--
-- Name: v_album_lookup; Type: VIEW; Schema: public; Owner: canidae
--

CREATE VIEW v_album_lookup AS
    SELECT aa.mbid AS albumartist_mbid, aa.name AS albumartist_name, COALESCE(al.custom_artist_sortname, aa.sortname) AS albumartist_sortname, al.mbid AS album_mbid, al.type AS album_type, al.title AS album_title, al.released AS album_released, tr.mbid AS track_mbid, tr.title AS track_title, tr.duration AS track_duration, tr.tracknumber AS track_tracknumber, ar.mbid AS artist_mbid, ar.name AS artist_name, ar.sortname AS artist_sortname FROM (((artist aa JOIN album al ON ((aa.artist_id = al.artist_id))) JOIN track tr ON ((al.album_id = tr.album_id))) LEFT JOIN artist ar ON ((tr.artist_id = ar.artist_id)));


ALTER TABLE public.v_album_lookup OWNER TO canidae;

--
-- Name: v_file_lookup; Type: VIEW; Schema: public; Owner: canidae
--

CREATE VIEW v_file_lookup AS
    SELECT f.filename, f.duration, f.channels, f.bitrate, f.samplerate, p.puid, f.album, f.albumartist, f.albumartistsort, f.artist, f.artistsort, f.musicbrainz_albumartistid, f.musicbrainz_albumid, f.musicbrainz_artistid, f.musicbrainz_trackid, f.title, f.tracknumber, f.year FROM (file f LEFT JOIN puid p ON ((f.puid_id = p.puid_id)));


ALTER TABLE public.v_file_lookup OWNER TO canidae;

--
-- Name: album_album_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE album_album_id_seq
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

SELECT pg_catalog.setval('album_album_id_seq', 724, true);


--
-- Name: artist_artist_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE artist_artist_id_seq
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

SELECT pg_catalog.setval('artist_artist_id_seq', 658, true);


--
-- Name: file_file_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE file_file_id_seq
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

SELECT pg_catalog.setval('file_file_id_seq', 37, true);


--
-- Name: puid_puid_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE puid_puid_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.puid_puid_id_seq OWNER TO canidae;

--
-- Name: puid_puid_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE puid_puid_id_seq OWNED BY puid.puid_id;


--
-- Name: puid_puid_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('puid_puid_id_seq', 1, false);


--
-- Name: setting_class_setting_class_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE setting_class_setting_class_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.setting_class_setting_class_id_seq OWNER TO canidae;

--
-- Name: setting_class_setting_class_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE setting_class_setting_class_id_seq OWNED BY setting_class.setting_class_id;


--
-- Name: setting_class_setting_class_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('setting_class_setting_class_id_seq', 3, true);


--
-- Name: setting_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE setting_setting_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.setting_setting_id_seq OWNER TO canidae;

--
-- Name: setting_setting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE setting_setting_id_seq OWNED BY setting.setting_id;


--
-- Name: setting_setting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('setting_setting_id_seq', 18, true);


--
-- Name: track_track_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE track_track_id_seq
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

SELECT pg_catalog.setval('track_track_id_seq', 1429, true);


--
-- Name: album_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE album ALTER COLUMN album_id SET DEFAULT nextval('album_album_id_seq'::regclass);


--
-- Name: artist_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE artist ALTER COLUMN artist_id SET DEFAULT nextval('artist_artist_id_seq'::regclass);


--
-- Name: file_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE file ALTER COLUMN file_id SET DEFAULT nextval('file_file_id_seq'::regclass);


--
-- Name: puid_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE puid ALTER COLUMN puid_id SET DEFAULT nextval('puid_puid_id_seq'::regclass);


--
-- Name: setting_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE setting ALTER COLUMN setting_id SET DEFAULT nextval('setting_setting_id_seq'::regclass);


--
-- Name: setting_class_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE setting_class ALTER COLUMN setting_class_id SET DEFAULT nextval('setting_class_setting_class_id_seq'::regclass);


--
-- Name: track_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE track ALTER COLUMN track_id SET DEFAULT nextval('track_track_id_seq'::regclass);


--
-- Data for Name: album; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY album (album_id, artist_id, mbid, type, title, released, custom_artist_sortname, loaded, updated) FROM stdin;
450	458	d43a2a42-0867-491f-a95b-71a64e0e71ef	\N	The Original Bad Co. Anthology (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
451	464	2929543b-3ad7-4c4a-bd02-b1bf9796e6f2	\N	Booth and the Bad Angel	\N	\N	f	2008-05-21 20:51:47.759954
453	466	51be96ae-ed6e-43fe-bc2a-7081d65dc42e	\N	Hot Girls, Bad Boys	\N	\N	f	2008-05-21 20:51:47.759954
484	485	165db060-d0e8-4601-8d9d-d46b3356a438	\N	Splat!	\N	\N	f	2008-05-21 20:51:47.759954
485	486	cd5afc35-eaa6-4d7b-ab7b-320f7f783694	\N	Message From the Godfather	\N	\N	f	2008-05-21 20:51:47.759954
452	465	76b1e838-2033-4982-a331-d29e5bcac941	\N	 the Queen	\N	\N	f	2008-05-21 20:51:47.759954
456	467	5aee618e-8f79-4b6c-bbdb-5eeb86326ed8	\N	 The Big Bad Blues	\N	\N	f	2008-05-21 20:51:47.759954
472	479	81eec326-d712-44fa-9582-9ea83d9146f3	\N	Teleport	\N	\N	f	2008-05-21 20:51:47.759954
447	462	7bb48a35-b6e5-4763-9dbf-d37bf98373c9	\N	Bad Religion	\N	\N	f	2008-05-21 20:51:47.759954
448	463	f17007db-6ae1-4b86-a559-50423af6d816	\N	Bad Power	\N	\N	f	2008-05-21 20:51:47.759954
471	479	e1b0fe48-67e3-4cfc-9aec-ed5753cfa993	\N	Teleport	\N	\N	f	2008-05-21 20:51:47.759954
457	468	aa06acce-1cd8-4082-9550-630e2b1c5300	\N	Bad	\N	\N	f	2008-05-21 20:51:47.759954
458	468	be5e01b0-904e-4c9d-8a8d-25d096960abd	\N	Bad	\N	\N	f	2008-05-21 20:51:47.759954
459	469	6f342ac1-09bc-44c5-bff0-250d5f521e8b	\N	Jewelled Antler Library Vol. 1 - Green Laughter	\N	\N	f	2008-05-21 20:51:47.759954
461	470	13703d99-c89e-47d0-b2c3-adeca74d65a0	\N	Laughter, Tears and Rage	\N	\N	f	2008-05-21 20:51:47.759954
455	466	fc04d1b7-1c03-48a1-b032-2abd7ca2911e	\N	Super 20 - Bad Boys Blue	\N	\N	f	2008-05-21 20:51:47.759954
454	466	b0c08032-a0e9-4e64-a90a-93a52b59096f	\N	Bad Boys Best	\N	\N	f	2008-05-21 20:51:47.759954
462	470	b12019f5-3d66-41c5-a79c-f27f85026ff3	\N	Laughter, Tears and Rage: The Anthology (disc 1: (More) Laughter, Tears and Rage)	\N	\N	f	2008-05-21 20:51:47.759954
460	470	4983d5b3-6715-4ec0-8e26-b8f8c1f66076	\N	Laughter, Tears and Rage	\N	\N	f	2008-05-21 20:51:47.759954
463	471	7aba2beb-d007-4aa9-adb4-98d354d50e3d	\N	God of Laughter	\N	\N	f	2008-05-21 20:51:47.759954
465	473	8c1e7d5c-cc5d-45a6-8ebd-f4a02e3ab0be	\N	Two Kinds of Laughter	\N	\N	f	2008-05-21 20:51:47.759954
466	474	6b6c34ee-da29-480a-a8a1-9bd5edf26d0b	\N	Laughter's Fifth	\N	\N	f	2008-05-21 20:51:47.759954
467	475	6cfc2f87-6336-4e1e-8031-803349e24cf7	\N	Where No Life Dwells / And the Laughter Has Died...	\N	\N	f	2008-05-21 20:51:47.759954
468	476	7838da76-a0a4-4144-a496-857b5552fe16	\N	Laughter at Dawn	\N	\N	f	2008-05-21 20:51:47.759954
469	477	0d801be1-65a8-4432-8a48-7bd4292e1712	\N	 Laughter	\N	\N	f	2008-05-21 20:51:47.759954
464	472	9693fc72-89ab-4938-9f76-46b1d0a70bbb	\N	May you always live with laughter	\N	\N	f	2008-05-21 20:51:47.759954
474	481	d332e882-a1c5-4ec4-a7c3-6d9d705bee48	\N	Forest of the Saints	\N	\N	f	2008-05-21 20:51:47.759954
475	479	63677dab-e665-4893-92de-16750c31776a	\N	Perfecto Fluoro (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
470	478	445038b7-854c-4f5d-a6be-cef7b7ca410b	\N	Private Laughter	\N	\N	f	2008-05-21 20:51:47.759954
476	479	e82cb9cb-fac9-4a5e-bfc5-040c5fd85744	\N	A Voyage Into Trance, Volume 2: Dragonfly (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
478	482	1dedb025-b3ef-4159-b49d-183d1efaebb6	\N	Sweep	\N	\N	f	2008-05-21 20:51:47.759954
486	487	bdc3f275-4b29-4a5c-9238-5d3624cf0c69	\N	What's Up Matador (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
487	487	f427e5e3-2684-4729-b3ae-b3ed25623f5a	\N	Extra Cheese: A Matador Records Sampler	\N	\N	f	2008-05-21 20:51:47.759954
477	479	d20bbafc-a309-4501-9029-2679974afd86	\N	A Taste of Dragonfly, Volume 2	\N	\N	f	2008-05-21 20:51:47.759954
473	480	bcaecfb9-334b-4811-82bd-360ba41824ce	\N	Teleport	\N	\N	f	2008-05-21 20:51:47.759954
488	487	5eaaa02d-438f-41ea-b427-7d3ff811233f	\N	Wammo	\N	\N	f	2008-05-21 20:51:47.759954
497	492	058f70d2-d11f-48d4-acdd-663e9b3a23ba	\N	I'm a Wreck	\N	\N	f	2008-05-21 20:51:47.759954
489	488	34ebb028-4879-4ab0-aa7b-f66e945b073d	\N	We Score	\N	\N	f	2008-05-21 20:51:47.759954
490	488	1a14946f-3a34-429c-b2cb-58012ae244f3	\N	Sonic Seducer: Cold Hands Seduction, Volume XII	\N	\N	f	2008-05-21 20:51:47.759954
491	487	f31bb30d-46e4-45bb-bd1c-cf36c48f6c41	\N	bailterspace	\N	\N	f	2008-05-21 20:51:47.759954
479	479	77487c22-3d7f-4ea9-a755-b354f03d16d6	\N	Dragonfly Classix (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
480	483	6702069e-6c79-4c17-9169-5b1f8e77ad48	\N	Practice Changes	\N	\N	f	2008-05-21 20:51:47.759954
481	479	417a29a7-9d72-4190-aedd-975d654b1634	\N	Top Of The Tips 2	\N	\N	f	2008-05-21 20:51:47.759954
482	479	52450bbc-94d0-4158-ac9c-354940ab51ec	\N	A Voyage Into Trance	\N	\N	f	2008-05-21 20:51:47.759954
483	484	35f9cb16-12bb-4f40-bde6-971741cb18a9	\N	Plastic Soundations EP	\N	\N	f	2008-05-21 20:51:47.759954
492	487	761a8934-53f9-40c1-a72c-97a30299d32d	\N	Pop Eyed: A Flying Nun Compilation	\N	\N	f	2008-05-21 20:51:47.759954
493	489	4db2cf43-8ee0-49a5-9d78-989565d070a4	\N	The Floor's Too Far Away	\N	\N	f	2008-05-21 20:51:47.759954
494	490	d557e94c-b2c5-4ec3-add0-9b2a7ca43a41	\N	Restarter	\N	\N	f	2008-05-21 20:51:47.759954
495	491	2d187371-de14-4f2a-99d6-eba245628177	\N	Off Centre	\N	\N	f	2008-05-21 20:51:47.759954
496	484	6700925a-49cd-43ae-9054-0718e33aa1a1	\N	Rave Mission, Volume VI (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
498	493	71309cde-b19e-443c-9eb6-7cffefb0f6ac	\N	You Don't Hear Jack	\N	\N	f	2008-05-21 20:51:47.759954
499	494	206d8302-c74e-43be-9f28-6d2dc9dca83b	\N	Those Were Different Times: Cleveland 1972-1976	\N	\N	f	2008-05-21 20:51:47.759954
500	495	060a7caf-0389-4703-9be0-362444ab601f	\N	Folktronic	\N	\N	f	2008-05-21 20:51:47.759954
501	496	ae147f6c-8a98-4d3a-8cd5-6b014d9d6276	\N	Jimmy Eat World	\N	\N	f	2008-05-21 20:51:47.759954
502	497	0b2e8c21-7bb9-4238-9348-312cc1419e89	\N	The Vagrant	\N	\N	f	2008-05-21 20:51:47.759954
503	498	cb6022fd-f974-48c6-bf29-b7cd4180d72e	\N	The Carl Stalling Project, Volume 2: More Music From Warner Bros. Cartoons 1939-1957	\N	\N	f	2008-05-21 20:51:47.759954
504	499	cb5bfe93-c123-449c-8302-3e6bfad11aaf	\N	25 Ways to Pick Up a Chick	\N	\N	f	2008-05-21 20:51:47.759954
505	500	bdc38381-8c0e-4e56-b42b-fb49f4e37803	\N	The Blood Splat Rating System	\N	\N	f	2008-05-21 20:51:47.759954
506	501	d84b73c1-2257-4f67-9c97-784309471660	\N	The Innocents	\N	\N	f	2008-05-21 20:51:47.759954
507	502	3345c1ef-6602-46e4-b78c-63656116e3a1	\N	Murphy's Law	\N	\N	f	2008-05-21 20:51:47.759954
508	503	17cbd86a-7435-4d81-8621-fa28321ff7ff	\N	Rhythm and Rave	\N	\N	f	2008-05-21 20:51:47.759954
509	504	25838421-8c01-42d3-9ee1-c697301e97ea	\N	Dirty Money, Dirty Tricks	\N	\N	f	2008-05-21 20:51:47.759954
510	505	94197c96-3899-4991-b38d-2a5c02a73da8	\N	Body Head Bangerz, Volume 1	\N	\N	f	2008-05-21 20:51:47.759954
511	506	7da712db-de00-4159-8c30-618ba7870046	\N	Katram savu Atlantīdu	\N	\N	f	2008-05-21 20:51:47.759954
512	505	0d502875-781c-4b34-8bf9-64910a926948	\N	Body Head Bangerz, Volume One	\N	\N	f	2008-05-21 20:51:47.759954
442	458	72aa1327-36c7-446f-8816-c46593138d83	\N	Bad Company	\N	\N	f	2008-05-21 20:51:47.759954
443	459	510df351-a3ab-4334-9a6d-915fb4fe6eb1	\N	Bad Ronald	\N	\N	f	2008-05-21 20:51:47.759954
444	460	615cc01c-ca28-4b62-b80e-8a25fb1d75d0	\N	Bad News	\N	\N	f	2008-05-21 20:51:47.759954
445	461	aeb528bf-5594-4ac5-99f1-574e17a2c617	\N	Bad Times	\N	\N	f	2008-05-21 20:51:47.759954
446	460	b2feb7c1-8668-4052-a7db-20e547d31190	\N	Bad News	\N	\N	f	2008-05-21 20:51:47.759954
520	512	3acd3387-6379-42db-9bbe-21082cb17e6a	\N	Oral Hygiene	\N	\N	f	2008-05-21 20:51:47.759954
521	513	b497663d-eae3-480d-a52a-34547d370106	\N	 Politics	\N	\N	f	2008-05-21 20:51:47.759954
550	530	581b4e52-8abf-4c9f-8b23-a2321fa7fc78	\N	Säue vor die Perlen	\N	\N	f	2008-05-21 20:51:47.759954
548	526	66d0331b-8b53-4af2-997e-0922904be04d	\N	Von allen Gedanken schätze ich doch am meisten die interessanten	\N	\N	f	2008-05-21 20:51:47.759954
522	511	3e27becf-f034-4147-9219-e523a35f89b4	\N	Eurosonic Experiences	\N	\N	f	2008-05-21 20:51:47.759954
523	514	ba25d907-aff5-4d1c-90df-8d7e8d440ace	\N	Supaman (feat. DJ Scream)	\N	\N	f	2008-05-21 20:51:47.759954
524	511	14400ee5-7f7f-418b-8b8f-12609f5a323a	\N	Café de Luna	\N	\N	f	2008-05-21 20:51:47.759954
516	515	8b14f377-af30-41b1-a3e9-37cc75a0cdc6	\N	Young Einstein	\N	\N	f	2008-05-21 20:51:47.759954
525	516	04543ac0-9182-4f1c-8ad0-f93b38247402	\N	Second Life	\N	\N	f	2008-05-21 20:51:47.759954
527	518	51d335fe-37f6-4ce0-be6c-e701995171c6	\N	Natural Life	\N	\N	f	2008-05-21 20:51:47.759954
534	524	21a4a0a8-1236-4da6-bab2-24d886f57667	\N	Die Trying	\N	\N	f	2008-05-21 20:51:47.759954
535	525	cfe5f5e5-4a92-45b8-8468-170abbad54c8	\N	Die Bestie in Menschengestalt	\N	\N	f	2008-05-21 20:51:47.759954
544	533	b60aff1a-dd3c-49b8-b3e3-e2061f2cd0a4	\N	Die Eine 2005	\N	\N	f	2008-05-21 20:51:47.759954
546	535	dcc57b33-acd9-4c53-b5bc-f691b565efad	\N	Die Fette 13	\N	\N	f	2008-05-21 20:51:47.759954
545	534	aa1f3771-1652-4687-b193-e987fb562828	\N	Die Zeit ist reif	\N	\N	f	2008-05-21 20:51:47.759954
531	521	2567587c-9b85-405f-b930-21cf46c9294f	\N	Life After Death	\N	\N	f	2008-05-21 20:51:47.759954
559	540	57e8a05d-3b0b-48dd-b3fc-d45a94580ef7	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
530	517	f54ffc44-1500-417d-aeee-dc39a9351d7c	\N	Scienz of Life (Metaphysic)	\N	\N	f	2008-05-21 20:51:47.759954
528	519	480451a0-3d3c-4663-a804-a46f1a171b3b	\N	Elements of Life	\N	\N	f	2008-05-21 20:51:47.759954
540	530	9e9eb634-4163-4a5b-bce6-16b5e39843e8	\N	Die Nullnummer	\N	\N	f	2008-05-21 20:51:47.759954
538	528	11fc9ec7-96b7-4875-be8f-b7796e6f73f9	\N	Die Originalmusik	\N	\N	f	2008-05-21 20:51:47.759954
532	522	e2a87748-0cbc-438c-9eda-8c38fb355b1e	\N	Look!! There Is Life On Earth	\N	\N	f	2008-05-21 20:51:47.759954
526	517	6a48ee3b-aa5f-49d4-9c24-9744917c26fb	\N	Scienz of Life (Metaphysics 2030)	\N	\N	f	2008-05-21 20:51:47.759954
529	520	9d5681f8-93f4-415f-baec-3be027d0cff0	\N	Inner Life II	\N	\N	f	2008-05-21 20:51:47.759954
539	529	b1012fba-afaf-4732-8e48-76a76361fa8b	\N	 Die Dicken	\N	\N	f	2008-05-21 20:51:47.759954
547	536	bef2a1a5-d970-4895-8c24-2c2632671b8a	\N	Die da!?!	\N	\N	f	2008-05-21 20:51:47.759954
549	526	9e9ce7e1-a7f6-4feb-a4ae-d734514dfdab	\N	Der Traum ist aus oder Die Erben der Scherben	\N	\N	f	2008-05-21 20:51:47.759954
543	532	0e2eb022-e3d3-4a4f-9311-7f02129e54eb	\N	Die Randgruppencombo spielt Gundermann ... live in Ostberlin	\N	\N	f	2008-05-21 20:51:47.759954
533	523	49d8714f-f754-442d-a831-476888f31715	\N	Everyday Life	\N	\N	f	2008-05-21 20:51:47.759954
541	528	22d4c39a-663f-4e5a-af33-42748365ac69	\N	Die drei ??? und die silberne Spinne	\N	\N	f	2008-05-21 20:51:47.759954
542	531	3d82dc59-45be-4955-b20d-2ebdf3c2b7d6	\N	Die! Die! Die!	\N	\N	f	2008-05-21 20:51:47.759954
560	541	53362439-8c3e-4b3a-95c6-a67ba5fcc85f	\N	Turn On	\N	\N	f	2008-05-21 20:51:47.759954
537	527	46f5ae31-cde7-4e9f-af2b-032f67b18b6b	\N	Die Lollipops	\N	\N	f	2008-05-21 20:51:47.759954
551	525	f992dc22-4fd6-4c90-9d27-303c52b57491	\N	Doktorspiele uner(ge)hört (Die nackte Wahrheit)	\N	\N	f	2008-05-21 20:51:47.759954
552	528	95cfbb0b-cedb-4b32-8c99-6a10bc8f176a	\N	Die drei ??? und das düstere Vermächtnis	\N	\N	f	2008-05-21 20:51:47.759954
553	533	3cdfd752-9fd3-436f-9f28-3f87b0a860ab	\N	Scheiß auf die Hookline	\N	\N	f	2008-05-21 20:51:47.759954
554	537	a7f36ac4-faf7-499c-918c-ae2e65ac601c	\N	Die Rückkehr des Unbegreiflichen	\N	\N	f	2008-05-21 20:51:47.759954
555	538	2c85a6e7-d28d-48c1-8a50-73b83fa65ff4	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
536	526	4dfc6ef6-310d-4ddc-8d93-8816790bc74f	\N	Die Interessanten: Singles 1992-2004	\N	\N	f	2008-05-21 20:51:47.759954
556	538	9e559780-b97e-4a0e-946f-55d7693cfb1a	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
557	539	fb11346f-e6d4-4380-840b-e12e2686d08f	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
558	538	ed3fa535-ddda-4e5b-81f5-bb2710fa3efa	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
561	542	8fe103fe-b7d5-455b-b617-0f5aad8bf73f	\N	Catch Your Breath	\N	\N	f	2008-05-21 20:51:47.759954
562	543	a1b86f66-c41c-4a56-a195-560a90545273	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
563	544	f52695e8-b4d8-4a1a-9ce5-af9971aa1d3d	\N	Just Turn	\N	\N	f	2008-05-21 20:51:47.759954
564	545	9a86e7f1-3ddb-4265-ae5f-2a80bdc11f6b	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
567	538	a638833b-b231-4810-9113-3467007e23cc	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
568	538	8c9974af-f2f5-412c-ada7-903c8a0e2255	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
569	547	3c8c5887-61c7-4168-88ad-661b367babe0	\N	Electric Turn to Me	\N	\N	f	2008-05-21 20:51:47.759954
571	549	99a73a2b-bcba-4238-8aba-c296fd829e5a	\N	Pop Tics	\N	\N	f	2008-05-21 20:51:47.759954
572	550	8451eb37-ef89-413b-9193-626bc98e5d9d	\N	PSIHOMODO POP - 20 tekucih 1	\N	\N	f	2008-05-21 20:51:47.759954
565	546	7b8b9dcc-1ecc-48ea-9c25-9a1a85528964	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
566	546	0553f48d-58e0-4fce-8b35-fc266a14d890	\N	Turn	\N	\N	f	2008-05-21 20:51:47.759954
570	548	e2ede547-920d-43bf-aeec-68ff3c3c81a8	\N	Nacha Pop	\N	\N	f	2008-05-21 20:51:47.759954
573	551	dea30888-d8be-453e-9a8b-539804ecf481	\N	Rapid Pop Thrills	\N	\N	f	2008-05-21 20:51:47.759954
574	552	239385ae-8f1a-4f70-b07b-4423370236d8	\N	This Is Pop	\N	\N	f	2008-05-21 20:51:47.759954
575	553	06866bc5-63bd-465e-a256-52007036ea73	\N	 The Pop Riviera Group	\N	\N	f	2008-05-21 20:51:47.759954
576	554	52e9664a-85a1-4f3a-84ca-6a14b85ca48c	\N	Pop	\N	\N	f	2008-05-21 20:51:47.759954
577	555	29f7b13b-1457-4a31-b23e-b6440c608e9d	\N	6 to 7	\N	\N	f	2008-05-21 20:51:47.759954
578	556	2b564f11-b960-4361-aff3-2a04c93353d3	\N	Pop Pop Pop	\N	\N	f	2008-05-21 20:51:47.759954
579	557	d7836f80-9174-4bec-a598-a75f0f1b2ebc	\N	Pop Ambient 2005	\N	\N	f	2008-05-21 20:51:47.759954
580	558	9700b5b9-cdf4-4fe7-8182-2c21b9124774	\N	Pop-Pop	\N	\N	f	2008-05-21 20:51:47.759954
581	549	24310244-8e7b-43a5-8f38-68560727f9d9	\N	Woman is the Fuehrer of the World	\N	\N	f	2008-05-21 20:51:47.759954
582	559	7011fd33-d20e-4b1f-b447-025f44f7b8ca	\N	 Shuvit	\N	\N	f	2008-05-21 20:51:47.759954
583	560	28b14920-6805-4e06-8e33-0cd959fba6b9	\N	Volume 1	\N	\N	f	2008-05-21 20:51:47.759954
584	549	8a16395a-7d72-4c56-ba8c-fa75c4ea805d	\N	Komm Küssen Kompilation #3	\N	\N	f	2008-05-21 20:51:47.759954
585	561	1524655e-fda8-4356-9d62-747b3cc41dfb	\N	POPlastik 1985-2005	\N	\N	f	2008-05-21 20:51:47.759954
586	315	49951cc4-dfcc-43d6-9ab4-0cf195089e22	\N	Pop	\N	\N	f	2008-05-21 20:51:47.759954
514	507	4d6b8847-3db9-4aab-b950-b883c33902db	\N	24 Hour Party People	\N	\N	f	2008-05-21 20:51:47.759954
515	508	38cd3bea-6aa4-4af0-8d5e-e0adc35c33ad	\N	Chris Sheppard: Pirate Radio Sessions, Volume 3	\N	\N	f	2008-05-21 20:51:47.759954
517	509	34cf087f-b87a-48c0-b61c-3b394bf25342	\N	Reckless Kelly	\N	\N	f	2008-05-21 20:51:47.759954
518	510	be86d574-9303-4404-be55-7d6719c4ea77	\N	Tiny Murders	\N	\N	f	2008-05-21 20:51:47.759954
519	511	35cc1c4b-bef0-401e-9e23-f1c8db8964a1	\N	Café de Luna	\N	\N	f	2008-05-21 20:51:47.759954
592	567	4f2c4f74-d00c-4c6b-9886-9365bd41a126	\N	Copland: The Populist (San Francisco Symphony feat. conductor: Michael Tilson Thomas)	\N	\N	f	2008-05-21 20:51:47.759954
593	568	0405347a-97ab-455f-b367-ce2dd7ae367d	\N	The Music Of Harry Partch	\N	\N	f	2008-05-21 20:51:47.759954
594	569	f24c7689-ec38-40b9-a58f-a51331c27f2b	\N	Personal Power II (disc 22: The Driving Force!)	\N	\N	f	2008-05-21 20:51:47.759954
595	570	5544db65-930f-4d2e-b23f-a5f3f5bd34fc	\N	1993-08-01: Mansfield, MA, USA (disc 2) (feat. Zakk Wylde)	\N	\N	f	2008-05-21 20:51:47.759954
596	571	a3bb6be6-7668-4e7e-89b4-202a5e282a30	\N	 Piano (violin: Marc Sabat, piano: Stephen Clarke)	\N	\N	f	2008-05-21 20:51:47.759954
597	572	3bf432f1-9f1e-4c60-a31b-bd5c66435a7e	\N	Baraka	\N	\N	f	2008-05-21 20:51:47.759954
598	573	984e99cc-cfe9-4600-ba0e-1e6212731d2d	\N	Sonic Continuum	\N	\N	f	2008-05-21 20:51:47.759954
599	574	708d6304-cf3a-4b84-abac-c15ea7d3b762	\N	The Gateway Experience Series: Wave IV: Adventure	\N	\N	f	2008-05-21 20:51:47.759954
600	575	04b50f9f-f854-4f15-ae90-51f79b203e30	\N	Alpha Lemur Echo Two	\N	\N	f	2008-05-21 20:51:47.759954
601	576	7d0d4dc3-7daf-49e9-bdfc-4fb741b4a29c	\N	The Million-dollar Tattoo	\N	\N	f	2008-05-21 20:51:47.759954
602	577	cd130027-1b95-4b4a-9162-2b4e614e933c	\N	mov'on 8 LIVE FANTOM 091303 EASY BAZOOKA 日比谷野音	\N	\N	f	2008-05-21 20:51:47.759954
603	316	b540abd2-04a7-4f9f-a03e-b77964cf7535	\N	 Iain 'Boney' Clark	\N	\N	f	2008-05-21 20:51:47.759954
604	578	a453d023-2e6c-4955-87e5-5d6b4f47b973	\N	Objects Appear	\N	\N	f	2008-05-21 20:51:47.759954
605	579	04c313a2-1f8f-459b-9342-e110230193a5	\N	The Electric Boogie EP	\N	\N	f	2008-05-21 20:51:47.759954
606	579	5fee07b3-8c0b-47a0-8d0f-dcd910317fd0	\N	Riddim CD #09	\N	\N	f	2008-05-21 20:51:47.759954
607	580	92e35b21-65be-4c2c-a912-ca5ff02f7893	\N	Objects in the Rear View Mirror May Appear Closer Than They Are	\N	\N	f	2008-05-21 20:51:47.759954
608	580	c0231ff8-c5ba-4f2d-9506-d265e1499ac6	\N	Objects in the Rear View Mirror May Appear Closer Than They Are	\N	\N	f	2008-05-21 20:51:47.759954
609	581	39ef5b9b-a4c4-4a86-826e-35b79746dfa5	\N	Beautiful	\N	\N	f	2008-05-21 20:51:47.759954
610	582	cb406cd0-17ce-4c9e-b250-3f375a68efcb	\N	dearly	\N	\N	f	2008-05-21 20:51:47.759954
612	584	d37bb1e1-c83b-4728-9429-06a4c120c500	\N	Without Ghosts	\N	\N	f	2008-05-21 20:51:47.759954
613	585	e1129df3-7979-4776-a8d4-9f7464d54215	\N	The Gothic Compilation, Part XXIV	\N	\N	f	2008-05-21 20:51:47.759954
614	586	c332d607-e48e-427b-af55-1e73ee54f13d	\N	Dragon Quest VIII Original Soundtrack (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
615	587	8342e937-d6f2-4c23-adb5-4eb932474c6e	\N	Dust and Glass	\N	\N	f	2008-05-21 20:51:47.759954
616	588	f282cbe9-95cc-42da-966d-c83e0ab79767	\N	L.A.F.M.S.: The Lowest Form of Music (disc 8: Rick Potts Solo)	\N	\N	f	2008-05-21 20:51:47.759954
618	590	703ec4f1-6a9c-414e-8361-26c1b7302705	\N	Victory or Valhalla!	\N	\N	f	2008-05-21 20:51:47.759954
619	590	cf4111d9-bdec-4d66-8206-736f72549bc1	\N	Victory Or Valhalla!	\N	\N	f	2008-05-21 20:51:47.759954
620	591	6807621d-8f83-4b11-bb61-0416f5c3f593	\N	Victory / Goodbye Losers	\N	\N	f	2008-05-21 20:51:47.759954
621	592	247a07c5-7532-4bf0-84f0-463158dd2e34	\N	Victory Gin	\N	\N	f	2008-05-21 20:51:47.759954
633	604	bc5c30bd-d148-4f29-8aa6-edfe8129a29c	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
611	583	4ee4d5fe-fce4-47b7-a932-3b4f295fe6f3	\N	appear	\N	\N	f	2008-05-21 20:51:47.759954
617	589	d510f9ec-5265-4eaa-9fd4-57c8dfc55628	\N	Radios Appear	\N	\N	f	2008-05-21 20:51:47.759954
622	593	d377c8e3-4666-45bc-9c29-60b741434c53	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
624	595	e24edd0d-3f8b-48ca-8e01-a6d3315feec6	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
625	596	1fe84789-3b60-4db0-8df6-ae0e582a909e	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
626	597	9a66a218-027e-4e30-be94-9afbbe67cc4f	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
634	605	add288bb-930f-4ab7-8e3f-a5994083ff98	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
627	598	15745c97-aa70-4ad4-864c-8b2be3416c6a	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
628	599	469cc119-bd9f-462c-afab-ddcdeebf7180	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
635	606	23ebc70b-2882-4e5b-b2c1-c7ed747a7116	\N	Victory or Valhalla	\N	\N	f	2008-05-21 20:51:47.759954
636	607	2b08ab45-fc49-4d53-8a5a-28b08a357121	\N	Victory Day	\N	\N	f	2008-05-21 20:51:47.759954
623	594	e148cbb7-f544-4983-b30e-915a9ea47cb4	\N	Victory Sings at Sea	\N	\N	f	2008-05-21 20:51:47.759954
629	600	afa3bf61-6b16-48a6-82b3-59e0495db759	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
630	601	d99f65a2-e0ac-48c0-b372-c8917c88480d	\N	Victory!	\N	\N	f	2008-05-21 20:51:47.759954
631	602	0938eb42-cd1b-4e02-b85c-4b242c3470a1	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
632	603	0cad5a6a-ee8a-4565-8df0-1e3525ea6ac5	\N	Victory	\N	\N	f	2008-05-21 20:51:47.759954
637	608	717d68c1-10aa-4894-b964-0df9f19a64d0	\N	Victory Gardens	\N	\N	f	2008-05-21 20:51:47.759954
638	609	9173230f-44d2-4d55-9811-c06f3cb4766d	\N	Punk Ass Generosity (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
639	610	4558e9fd-0948-414d-be4a-4a2a8061dfd8	\N	Violated	\N	\N	f	2008-05-21 20:51:47.759954
641	610	f93fe221-d9e0-46f9-8328-1f80f2043f0e	\N	Vinyl Force Presents Bastard Breaks	\N	\N	f	2008-05-21 20:51:47.759954
642	611	87f3f7ad-b4a1-4c39-99cd-63ab56733649	\N	Men Are Monkeys. Robots Win.	\N	\N	f	2008-05-21 20:51:47.759954
643	612	97e82cf1-97ae-47a4-8175-50bb45b00ebb	\N	Spending Time On The Borderline	\N	\N	f	2008-05-21 20:51:47.759954
644	612	65ccf0cc-fcd1-47fb-9078-2b99e257cc9f	\N	Spending Time on the Borderline	\N	\N	f	2008-05-21 20:51:47.759954
645	613	9ec335a4-f227-4abf-9010-4afffd9906f8	\N	Terminal	\N	\N	f	2008-05-21 20:51:47.759954
640	610	5975f869-cc9c-4596-96ab-07152767f2e4	\N	Check This Out III	\N	\N	f	2008-05-21 20:51:47.759954
646	613	4f1cf575-0300-418a-948f-41277d7e33bd	\N	Ultimatum	\N	\N	f	2008-05-21 20:51:47.759954
647	614	56076387-31b2-46a4-abf9-45ebcbb1b28d	\N	Diverse vs. Capcom	\N	\N	f	2008-05-21 20:51:47.759954
648	615	f4b2b59a-10b6-416f-8a5d-6458b3fe7fcd	\N	55	\N	\N	f	2008-05-21 20:51:47.759954
649	616	1982ef3f-3b31-4501-ae32-4455243ff8b6	\N	Lotus Turbo Challenge 2	\N	\N	f	2008-05-21 20:51:47.759954
650	617	851cf6bb-a1ef-4860-9f09-a38421fa44b6	\N	Lotus III: The Ultimate Challenge	\N	\N	f	2008-05-21 20:51:47.759954
651	618	9a20ee07-8e60-49e0-9826-552d20ebed73	\N	Compact Disco	\N	\N	f	2008-05-21 20:51:47.759954
652	619	cc74e297-94cd-4948-9e6c-ae6bb8482f92	\N	Technictix	\N	\N	f	2008-05-21 20:51:47.759954
653	620	21e0210e-f7bb-4d86-85a1-12f970c7b40b	\N	 Bass Arena Presents DJ Hype! (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
654	621	e1da9abb-6368-4b31-a5f6-dda5b070e38d	\N	Parkspliced (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
655	622	9af449ef-83ea-4b8e-b1ba-d2a5da9624a4	\N	I Sold Gold	\N	\N	f	2008-05-21 20:51:47.759954
656	623	208930f8-942d-42e1-9b03-4cc5bd312e5a	\N	House of Zombie Ninja EP	\N	\N	f	2008-05-21 20:51:47.759954
587	562	f91a1093-2312-4bc8-8e38-5e52114bcaf6	\N	Future Electro Star	\N	\N	f	2008-05-21 20:51:47.759954
588	563	fcac2901-585d-4964-a1ae-be82b73c65f5	\N	The History of the House Sound of Chicago, Volume 13	\N	\N	f	2008-05-21 20:51:47.759954
589	564	6288dd5f-23ed-4416-b8de-86e41083e51d	\N	[non-album tracks]	\N	\N	f	2008-05-21 20:51:47.759954
590	565	4209f1f5-9412-422b-a87d-508611fa517f	\N	A Punk Tribute to Green Day	\N	\N	f	2008-05-21 20:51:47.759954
591	566	1f95f169-d087-4e8d-9840-9a6bf2698c1d	\N	Yerida	\N	\N	f	2008-05-21 20:51:47.759954
673	632	31bc651e-0364-48a0-b4a8-2e5a7da32ed8	\N	Now That's What I Call Music! 9	\N	\N	f	2008-05-21 20:51:47.759954
674	633	43d35c3e-d51c-4212-a314-33f82269433a	\N	Now That's What I Call Music! 16	\N	\N	f	2008-05-21 20:51:47.759954
675	409	05c7e334-f95e-40b9-9238-f29737c3680d	\N	Now That's What I Call Music! 17	\N	\N	f	2008-05-21 20:51:47.759954
676	344	68012214-a808-48e5-9428-72aeba3b4806	\N	Now That's What I Call Music	\N	\N	f	2008-05-21 20:51:47.759954
677	634	44921081-f40a-4ecf-9d74-238d42002616	\N	Now That's What I Call Music! 22	\N	\N	f	2008-05-21 20:51:47.759954
678	350	cd05d3ea-b1a9-4037-9d0c-6f710ccd06ac	\N	Now That's What I Call Music! 1992 (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
679	350	a44986a7-9b56-4eb8-8c20-92f102ffc807	\N	Now That's What I Call Music! 24 (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
680	360	9655c164-dcac-4b6e-bc96-7e33671e3467	\N	Now That's What I Call Music! 11	\N	\N	f	2008-05-21 20:51:47.759954
681	635	318b037e-8749-4074-a23a-28200eace2f3	\N	Now That's What I Call Music! 1983	\N	\N	f	2008-05-21 20:51:47.759954
449	458	191f7ef5-d208-4959-8422-1159844bebb3	\N	The Original Bad Co. Anthology (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
658	619	a8754332-a206-4561-b0db-b18e828836e7	\N	怒首領蜂大往生＆エスプガルーダ -Perfect Remix-	\N	\N	f	2008-05-21 20:51:47.759954
659	625	bf19421e-c56c-4866-b472-d66ae0ac20df	\N	Screamixadelica: Primal Scream Remixed	\N	\N	f	2008-05-21 20:51:47.759954
660	315	a70d517d-c6c6-4ff7-acf9-78f6f103dff4	\N	Now That's What I Call Music! 47 (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
661	626	430d5a99-1d61-4167-af17-3d4260b17db0	\N	Now That's What I Call Music! 5	\N	\N	f	2008-05-21 20:51:47.759954
662	627	627934ab-310a-43fa-a44d-767507e8b0b3	\N	Now That's What I Call Music! 19 (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
664	315	414e735b-74db-4ef3-9a49-1529522a1ccf	\N	Now That's What I Call Music! 10	\N	\N	f	2008-05-21 20:51:47.759954
665	315	70b27af5-0bff-4a1a-b80c-809f810d6a07	\N	Now That's What I Call Music! 7	\N	\N	f	2008-05-21 20:51:47.759954
663	315	f9350585-9778-44ef-9d5a-e8e4e0545b7c	\N	It's Gonna Be Me	\N	\N	f	2008-05-21 20:51:47.759954
666	628	aa57a079-dbb0-49dd-9adc-0ddff26e1996	\N	Now That's What I Call Music! 5 (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
667	629	c7383197-1b49-41f7-a1a4-eb26c971871e	\N	Now That's What I Call Music! 10	\N	\N	f	2008-05-21 20:51:47.759954
669	315	4a242187-1f79-4230-95df-87eaa3b6d582	\N	Now That's What I Call Music! 52 (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
670	630	f2bdb3de-2225-42c2-849e-8f3eef47cb88	\N	Now That's What I Call Music 3	\N	\N	f	2008-05-21 20:51:47.759954
671	631	43d4bd92-dde3-4a01-a9bb-77712a345c56	\N	Now That's What I Call Music! 1982	\N	\N	f	2008-05-21 20:51:47.759954
672	356	67297836-2904-457f-a67b-447fbe000851	\N	Now That's What I Call Music!	\N	\N	f	2008-05-21 20:51:47.759954
692	644	fa11cc7a-0ca2-42d1-a874-d2a0652f69da	\N	Bye Bye Blackbird	\N	\N	f	2008-05-21 20:51:47.759954
682	315	ae498204-50f7-42f0-bac5-ef97cbe03f13	\N	Bye Bye Bye	\N	\N	f	2008-05-21 20:51:47.759954
693	645	72f9ccec-04a2-4f04-bff9-53653644956f	\N	Bye Bye Baby	\N	\N	f	2008-05-21 20:51:47.759954
684	636	ecaf9050-d17f-4794-9b45-de895651cc41	\N	Lulla bye	\N	\N	f	2008-05-21 20:51:47.759954
685	637	d43c4456-f9a3-4e82-bdfc-c3df95e895ca	\N	Sammy Dead / Say Bye Bye	\N	\N	f	2008-05-21 20:51:47.759954
694	646	5c81d5ad-9290-4ab7-8168-b9725c69979f	\N	Boom Bye Bye	\N	\N	f	2008-05-21 20:51:47.759954
719	656	0849a881-2002-484f-bb57-b26c3a3b1a08	\N	No Strings Attached	\N	\N	f	2008-05-21 20:51:47.759954
686	638	04369e82-25b9-4ed4-b7e2-2912648a5f6b	\N	Bye-Bye	\N	\N	f	2008-05-21 20:51:47.759954
688	640	d7e41536-1924-46d5-b354-c5742a6b93f0	\N	 Bye	\N	\N	f	2008-05-21 20:51:47.759954
689	641	080639a6-91da-413e-92c5-93f568712f53	\N	Bye Bye Gridlock Traffic	\N	\N	f	2008-05-21 20:51:47.759954
690	642	42a1305e-9e90-4b12-b31a-5ad7f6e6fd20	\N	Bye bye beauté	\N	\N	f	2008-05-21 20:51:47.759954
691	643	ca4ec5a2-24d7-496e-b4ad-673b441f188b	\N	Bye Bye Birdie	\N	\N	f	2008-05-21 20:51:47.759954
695	647	328de397-2418-4bc8-9c94-083a5b81471f	\N	Bye Bye Love	\N	\N	f	2008-05-21 20:51:47.759954
696	648	42e209bd-19be-4f4e-8f85-5847b621d056	\N	Bye Bye Baby	\N	\N	f	2008-05-21 20:51:47.759954
697	649	9ebfd671-522b-4d89-abd3-c8f83d3f0236	\N	Bye Bye Baby Goodbye	\N	\N	f	2008-05-21 20:51:47.759954
698	650	c6d4de6d-f980-487e-8457-f8826bdbd785	\N	Bye Bye, Love	\N	\N	f	2008-05-21 20:51:47.759954
699	651	23176bc6-ae94-44ed-81d1-abcf8b226d43	\N	Bye Bye Love	\N	\N	f	2008-05-21 20:51:47.759954
704	315	34841d4a-3252-4f4e-9b03-1bcf4948151b	\N	New Hits 1999	\N	\N	f	2008-05-21 20:51:47.759954
700	315	4e11b46f-e850-4f94-8c59-6e1f9b723c6e	\N	(God Must Have Spent) A Little More Time on You	\N	\N	f	2008-05-21 20:51:47.759954
702	315	25beaad8-89f2-4992-88a0-e856113b92c7	\N	Totally Hits	\N	\N	f	2008-05-21 20:51:47.759954
703	315	9165f4a8-5ad6-4c65-a5a8-edd15bfa4e9e	\N	Maxi5	\N	\N	f	2008-05-21 20:51:47.759954
705	315	65fb1b24-f321-4d6b-aaa5-0fd66d311c15	\N	Greatest Hits	\N	\N	f	2008-05-21 20:51:47.759954
706	315	d1be546e-0445-4ec6-bab0-08d4d1ec77e6	\N	Greatest Hits	\N	\N	f	2008-05-21 20:51:47.759954
707	315	ff479fe9-55d9-48cb-9ba4-4f0a04b26b6a	\N	Winter Album	\N	\N	f	2008-05-21 20:51:47.759954
708	315	fb5e3a2d-4d99-4f92-a5f0-2c07d8f13add	\N	Promo Only: Mainstream Radio, November 1998	\N	\N	f	2008-05-21 20:51:47.759954
709	652	01499609-ace6-4d1e-8295-dcbfe88e9b8a	\N	Livin' Lovin' Rockin' Rollin': The 25th Anniversary Collection (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
712	654	036f62a5-9eb8-4c5d-acd8-d2a267aa7f2e	\N	Elevator Music, Volume 1A	\N	\N	f	2008-05-21 20:51:47.759954
668	315	1059242b-6964-4e1c-9447-2ab231b0dede	\N	Now That's What I Call Music! 8	\N	\N	f	2008-05-21 20:51:47.759954
710	315	b85a8745-d541-4acd-911e-1720e89b11f4	\N	Music of the Heart	\N	\N	f	2008-05-21 20:51:47.759954
711	653	1a831f33-0279-44ed-8204-40df3aab6bcc	\N	Absolute Reggae Classics (disc 1)	\N	\N	f	2008-05-21 20:51:47.759954
713	655	7ebb9f35-01ce-4243-a500-5191dcb229d9	\N	Pop Electronique	\N	\N	f	2008-05-21 20:51:47.759954
714	315	745670b0-0521-4aa8-886b-c1adeec77c94	\N	I Want You Back	\N	\N	f	2008-05-21 20:51:47.759954
715	315	0f632186-c1b1-4b25-af03-53d19b830a3a	\N	I Want You Back	\N	\N	f	2008-05-21 20:51:47.759954
716	315	2ac79824-9670-4045-9d33-7d96a33b298e	\N	I Want You Back	\N	\N	f	2008-05-21 20:51:47.759954
717	315	d2744d01-3f35-4928-bc24-e8fe4392c2c9	\N	This I Promise You	\N	\N	f	2008-05-21 20:51:47.759954
513	502	018dee79-5c40-4332-9d0f-5d4969c7a9bd	\N	Back With a Bong	\N	\N	f	2008-05-21 20:51:47.759954
701	315	4882c497-c476-4c96-9f1d-f00f54148df3	\N	*NSync Remixes, Volume 1	\N	\N	f	2008-05-21 20:51:47.759954
683	315	805b78d4-ddc9-44ea-aa8b-f1ecf8355002	\N	Bye Bye Bye: The Remixes	\N	\N	f	2008-05-21 20:51:47.759954
720	315	de43dab1-5575-48e2-9a5a-df2209c0635f	\N	I'll Never Stop	\N	\N	f	2008-05-21 20:51:47.759954
657	624	2f5b27b9-bafa-4d28-9e5f-30319957dc67	\N	虫姫さま オリジナルサウンドトラック	\N	\N	f	2008-05-21 20:51:47.759954
687	639	bdc524db-49f4-46ac-91f4-d3f33e355bf6	\N	Bye Bye Blackbird	\N	\N	f	2008-05-21 20:51:47.759954
722	658	b1f1d0dc-bdec-4ea1-9adb-e46feb869764	\N	Bye Bye Boy	\N	\N	f	2008-05-21 20:51:47.759954
721	657	930b76a7-ebc2-44ab-8c25-bcc820aced09	\N	Bye bye Superman	\N	\N	f	2008-05-21 20:51:47.759954
723	315	c12682f1-7f19-4d82-a1ee-e34b9e48d66a	\N	Cool Traxx! 2	\N	\N	f	2008-05-21 20:51:47.759954
366	386	2853c1b1-f80a-469d-ad1a-0cd6fd850a44	\N	Mastering the Mouth Call	\N	\N	f	2008-05-21 20:51:47.759954
346	366	0714eb82-a14b-41cd-84ab-3e0352e9e317	\N	Slide	\N	\N	f	2008-05-21 20:51:47.759954
365	385	c6276525-bd66-4383-a870-17fb3898de8a	\N	Beatmania IIDX 5th Style Original Soundtrack	\N	\N	f	2008-05-21 20:51:47.759954
359	379	0a13efa0-ab86-401f-8e43-d5211216be3c	\N	Tribalismo, Volume 5 (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
352	372	4ca8fbb3-4de5-4871-953e-8c13e50398a1	\N	Closure	\N	\N	f	2008-05-21 20:51:47.759954
355	375	77b63c06-0058-447b-a49f-ae0fb325d3da	\N	Backbone Slide	\N	\N	f	2008-05-21 20:51:47.759954
384	402	1999f959-00cb-4483-80d3-899097db1675	\N	Universal Madness (Live in Los Angeles)	\N	\N	f	2008-05-21 20:51:47.759954
351	371	5e1c1803-0320-46b2-994d-9caba2cc732d	\N	Slide	\N	\N	f	2008-05-21 20:51:47.759954
361	381	09ab6677-f2bf-4272-a6ed-dbd2815e7167	\N	 Senseless Violins	\N	\N	f	2008-05-21 20:51:47.759954
386	403	e1e74e44-e4c5-4960-865e-823bc0cc95d9	\N	San Francisco Days	\N	\N	f	2008-05-21 20:51:47.759954
356	376	386991d8-e834-457b-a622-2c268fc92d68	\N	Sax As Sax Can	\N	\N	f	2008-05-21 20:51:47.759954
362	382	6f45aabb-cbcb-4cd1-913c-95c5ccb14b6e	\N	Live at the Sax Blast	\N	\N	f	2008-05-21 20:51:47.759954
387	403	e4c47222-08a4-4bc4-9733-9be16b2adf94	\N	Silvertone	\N	\N	f	2008-05-21 20:51:47.759954
368	388	d88c8619-defc-4d0f-8adf-8ff24265494a	\N	Twisted Tunes Lost Holiday Classics	\N	\N	f	2008-05-21 20:51:47.759954
357	377	d96510d8-eac6-4be2-b227-a2cff6e4102f	\N	The Sax Pack	\N	\N	f	2008-05-21 20:51:47.759954
367	387	dc4dec12-9e8c-471e-a00c-5e0fb545bc7a	\N	Children's Songs and Fingerplays	\N	\N	f	2008-05-21 20:51:47.759954
350	370	6187a2be-1ea5-4251-890d-59e82770231a	\N	Slide	\N	\N	f	2008-05-21 20:51:47.759954
349	369	7f548f1e-0022-4bbc-ba20-7d3446c7c67c	\N	Slide	\N	\N	f	2008-05-21 20:51:47.759954
353	373	c50ec5c0-7c76-419b-b76b-48b19c610033	\N	Slide EP	\N	\N	f	2008-05-21 20:51:47.759954
363	383	799f9c69-11f2-41d6-b65f-718839dcbcf6	\N	Gobble, Gobble Song from Xaseni	\N	\N	f	2008-05-21 20:51:47.759954
360	380	5b0caf18-d049-4275-8238-6516a4929299	\N	Sax Maniac	\N	\N	f	2008-05-21 20:51:47.759954
369	389	14baecf2-3d44-49e3-8136-f03982524776	\N	Cuntree	\N	\N	f	2008-05-21 20:51:47.759954
370	390	7fdf274f-1554-46d5-b0ff-93ffd7b17b14	\N	Forever	\N	\N	f	2008-05-21 20:51:47.759954
371	391	47c69012-fda7-49b5-bb47-8435648e049f	\N	Over 100! Hollywood Sound Effects	\N	\N	f	2008-05-21 20:51:47.759954
372	392	b416d651-46ed-4002-be15-255680dc567e	\N	Itchy Tingles	\N	\N	f	2008-05-21 20:51:47.759954
373	393	380a407d-80ab-4763-b3a9-ecbbd3a2b950	\N	Turdy Point Buck II (Da Sequel)	\N	\N	f	2008-05-21 20:51:47.759954
364	384	bb7d2268-2f9c-4b97-9f6e-a04096a20e78	\N	Birdwatch	\N	\N	f	2008-05-21 20:51:47.759954
374	394	a47d0444-ffad-4e0f-8f31-50aff6815447	\N	Not Just a Pretty Face	\N	\N	f	2008-05-21 20:51:47.759954
375	395	9f73487b-83e8-4a71-8fc5-803f3938dbda	\N	Sleaze Merchants	\N	\N	f	2008-05-21 20:51:47.759954
376	396	164d763f-cf55-4ad5-a699-a4de0cdfbc68	\N	Rocks	\N	\N	f	2008-05-21 20:51:47.759954
377	397	6c027ce6-4fcd-4ca4-8eca-8dd962406d03	\N	Groovy Feeling	\N	\N	f	2008-05-21 20:51:47.759954
378	398	2660be83-5b98-4760-ac55-47a7fd0fce5f	\N	Trance Nation 3 (disc 2)	\N	\N	f	2008-05-21 20:51:47.759954
379	395	24705481-d635-4fea-955c-b4e19385c5be	\N	Live Fast, Die Young... And Leave a Flesh Eating Corpse!	\N	\N	f	2008-05-21 20:51:47.759954
380	399	70fc4df9-1a86-4357-aac7-0694d4248aed	\N	Hot	\N	\N	f	2008-05-21 20:51:47.759954
381	399	6cde22f9-e946-4e96-beb0-40817ee65a06	\N	The Inevitable	\N	\N	f	2008-05-21 20:51:47.759954
382	400	edbdbbf6-8022-4f98-a93f-9d58a7b32692	\N	Version 2.0	\N	\N	f	2008-05-21 20:51:47.759954
383	401	24e5b7f5-14cd-4a65-b87f-91b5389a4e3a	\N	To Bring You My Love	\N	\N	f	2008-05-21 20:51:47.759954
389	407	a9455a7f-ae05-4454-90bb-84f4460b0296	\N	Emusic: Awesome 80's	\N	\N	f	2008-05-21 20:51:47.759954
390	408	c1957083-3013-4329-8d2e-b90bb0ab09a6	\N	À Paris	\N	\N	f	2008-05-21 20:51:47.759954
393	411	ebf87923-0be7-4920-9846-5e95b7789f13	\N	Miles From Our Home	\N	\N	f	2008-05-21 20:51:47.759954
385	403	6b932568-c30a-4801-a636-cdd6f2e76511	\N	Chris Isaak	\N	\N	f	2008-05-21 20:51:47.759954
394	412	abac7c05-5a5c-4336-9c2f-18ffd175dc3a	\N	Dead Can Dance	\N	\N	f	2008-05-21 20:51:47.759954
344	315	130dde16-0fee-428f-820e-7ce449ed50e1	Compilation Official	Smash Hits: The Reunion (disc 2)	2003-01-01	\N	t	2008-05-21 20:51:47.759954
388	404	6422fda7-c012-4d27-afed-57d7e2acdcd5	\N	Big White Lies	\N	\N	f	2008-05-21 20:51:47.759954
398	416	8aaa9eff-a870-4444-9220-5385db3393b0	\N	Reverse	\N	\N	f	2008-05-21 20:51:47.759954
397	415	23df104a-9a40-42ab-8bc6-b180620e8a81	\N	Reverse Cowgirl	\N	\N	f	2008-05-21 20:51:47.759954
391	409	0a5349d8-6c53-4814-9340-289df0643049	\N	Ill Communication	\N	\N	f	2008-05-21 20:51:47.759954
392	410	70eabfa6-e06a-4dbb-8e51-c84fc6e77dae	\N	Rafi's Revenge	\N	\N	f	2008-05-21 20:51:47.759954
399	417	944b28b5-9675-4703-b5c6-5291b32c8b39	\N	Reverse	\N	\N	f	2008-05-21 20:51:47.759954
400	418	4bfb4b4c-cc12-41c5-83b4-e510546a5a17	\N	Nature in Reverse	\N	\N	f	2008-05-21 20:51:47.759954
336	315	711633d2-5ccc-44e1-9d32-4b401bca2716	Album Official	*NSYNC	1998-03-24	\N	t	2008-05-21 20:51:47.759954
402	420	063ec1e4-19a2-4c6a-8ceb-1c666a124038	\N	Autogen / Bonus	\N	\N	f	2008-05-21 20:51:47.759954
396	414	a664af6d-ed52-4160-a575-faa5e8adadfc	\N	Halo in Reverse	\N	\N	f	2008-05-21 20:51:47.759954
403	421	8d34989e-210c-4e33-8b7d-981ca74ece77	\N	Poesia Urbana, Volume 1	\N	\N	f	2008-05-21 20:51:47.759954
404	422	c506ca7b-babe-4d32-8195-84b1be21bb00	\N	On Earth	\N	\N	f	2008-05-21 20:51:47.759954
405	422	e13d7601-84d2-4156-8d10-4c00976ba89d	\N	[untitled]	\N	\N	f	2008-05-21 20:51:47.759954
406	423	6f3d6541-bbec-43d2-921a-1d810345b461	\N	Bonus Beats EP	\N	\N	f	2008-05-21 20:51:47.759954
407	424	f2b1f9f7-cd57-41d9-af6a-f15e0fa6dc60	\N	Machtlos + Bonus	\N	\N	f	2008-05-21 20:51:47.759954
338	315	79024eb2-513b-484b-9301-bb3884cd047d	Compilation Official	Absolute Music 27	\N	\N	t	2008-05-21 20:51:47.759954
345	365	451c8dd6-b728-4232-a580-965e3ed0d345	\N	Cha-Cha Slide	\N	\N	f	2008-05-21 20:51:47.759954
347	367	643e3857-6ae3-49a0-92ef-afaf237537bd	\N	Slide	\N	\N	f	2008-05-21 20:51:47.759954
348	368	ab3df3fa-84f1-4d9f-8730-e830a4c77c3b	\N	Slide	\N	\N	f	2008-05-21 20:51:47.759954
354	374	281c3de3-82a7-4a9d-94fe-520b74f90c01	\N	Slide, T.S. Slide	\N	\N	f	2008-05-21 20:51:47.759954
343	336	70666922-6d32-41fc-b208-0b91c42c35a1	Compilation Official	Now That's What I Call Music! 5	2000-11-14	\N	t	2008-05-21 20:51:47.759954
395	413	55d9dcfd-fad4-403c-acba-2f1ea77f9f44	\N	Reverse	\N	\N	f	2008-05-21 20:51:47.759954
342	315	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	Album Official	No Strings Attached	2000-03-21	\N	t	2008-05-21 20:51:47.759954
401	419	d20c6f41-6969-4fab-950b-af109927589a	\N	Super Extra Bonus Party	\N	\N	f	2008-05-21 20:51:47.759954
339	315	5f68e32a-ccc1-4b01-a4de-daa880bf3864	Album 	No Strings Attached	2001-01-01	\N	t	2008-05-21 20:51:47.759954
341	315	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	Album 	No Strings Attached	\N	\N	t	2008-05-21 20:51:47.759954
340	315	631c7d7a-fca8-4891-bf02-47462cff37a5	Album Official	No Strings Attached	2000-01-01	\N	t	2008-05-21 20:51:47.759954
337	315	f6010e25-d302-4848-9b07-53f715c363bb	Album Official	*NSync	1998-03-24	\N	t	2008-05-21 20:51:47.759954
426	443	63ab3563-e6d6-4c64-b1ce-32832a7b432b	\N	Land	\N	\N	f	2008-05-21 20:51:47.759954
427	444	674302e9-bc9c-45da-933c-33fa0eca90c5	\N	Reality Channel: An Introduction to the Land of Nod	\N	\N	f	2008-05-21 20:51:47.759954
428	445	8fea7beb-a288-4609-acf7-07f31d1a413e	\N	Land	\N	\N	f	2008-05-21 20:51:47.759954
441	457	2fd6a0ff-7fe4-4158-ab9e-bc94896a5c75	\N	Le Click (feat. Kayo)	\N	\N	f	2008-05-21 20:51:47.759954
358	378	e76affb8-36df-4131-a148-b128c5e1c246	\N	Not Dancing for Chicken	\N	\N	f	2008-05-21 20:51:47.759954
724	315	a0ce9bd6-8dec-4727-a60c-63b68026b2ca	\N	Nickelodeon Kids' Choice Awards 2003, Volume 1	\N	\N	f	2008-05-21 20:51:47.759954
408	425	daa2d60b-b8a1-4d69-9d3d-0a8e0d6aa9f9	\N	Crash and Burn	\N	\N	f	2008-05-21 20:51:47.759954
429	446	9100632c-2fcf-4bbf-8936-a67ef581d366	\N	Land	\N	\N	f	2008-05-21 20:51:47.759954
718	315	ae94ea26-b263-407d-a9f9-bfeec05111c8	\N	No Strings Attached	\N	\N	f	2008-05-21 20:51:47.759954
423	440	d8060ab4-6069-4647-8dde-28b7cee24da3	\N	Colors of the Land	\N	\N	f	2008-05-21 20:51:47.759954
430	447	679ee404-acf1-4bff-a2c5-eca99c9e8df0	\N	Promised Land	\N	\N	f	2008-05-21 20:51:47.759954
431	448	3b436248-9c4c-4057-829f-c4e0b7e335d6	\N	Click	\N	\N	f	2008-05-21 20:51:47.759954
432	449	4872de2d-540f-4a6a-bae2-95cd2413a414	\N	Click EP	\N	\N	f	2008-05-21 20:51:47.759954
409	426	c5c25d93-73c6-445f-b1c0-faf670f8046c	\N	Crash Crash	\N	\N	f	2008-05-21 20:51:47.759954
410	427	9236b13a-d4d8-4bd8-81fd-841a4fca13ed	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
411	428	ecb0cec0-a4fd-43aa-aae1-34d90e14fc1b	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
412	429	bca68eef-abdc-4470-8e55-580bb3e254c3	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
413	430	0e30fe7f-9a9e-4d12-90c0-f91173988dc4	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
414	431	d2cbf3c2-3669-4464-9e62-cc97f239aeb1	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
415	432	95ca11ae-43a1-428d-bc4a-333ea30d7da2	\N	CRASH	\N	\N	f	2008-05-21 20:51:47.759954
433	450	c4b9168b-c46e-42fa-90de-11dd9242ea9f	\N	Never Click	\N	\N	f	2008-05-21 20:51:47.759954
434	451	6f226ad6-5bd2-4487-b6ac-c341e84acf8d	\N	Click Clack	\N	\N	f	2008-05-21 20:51:47.759954
416	433	fc78a2e8-ed51-444c-894c-a19c273dcf0f	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
417	434	8ca0c3f3-7a51-4418-8512-aef94d3a80d6	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
436	453	527d3180-8b23-4307-affb-d14a3c1d4d5c	\N	Click-B	\N	\N	f	2008-05-21 20:51:47.759954
418	435	97385060-8d28-4179-9873-05eeb6417089	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
419	436	95d16d50-82c9-4381-babe-d8f36f2b8ab7	\N	Crash Crash	\N	\N	f	2008-05-21 20:51:47.759954
420	437	7e7ef5df-81b5-4127-85fa-3903aad28623	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
421	438	51917f3d-7033-49aa-8c89-a9aee4f5ad49	\N	Crash	\N	\N	f	2008-05-21 20:51:47.759954
422	439	b0e91b50-ea4c-43a1-bc7f-91b867382543	\N	Crash!	\N	\N	f	2008-05-21 20:51:47.759954
424	441	03d6f632-4174-4686-8869-dc08f5d95c72	\N	Sentenced / Orphaned Land	\N	\N	f	2008-05-21 20:51:47.759954
425	442	5127e87d-3fab-4e35-8e80-e9e4cbef2db8	\N	Dronning Mauds Land	\N	\N	f	2008-05-21 20:51:47.759954
437	454	00593e9c-13b8-4dfc-9561-bea603f28f82	\N	Down And Dirty [1995]	\N	\N	f	2008-05-21 20:51:47.759954
438	455	8b4d5ac2-e344-475a-8bbc-fd9ad256cacf	\N	Ali Click	\N	\N	f	2008-05-21 20:51:47.759954
435	452	f8d6c257-aad9-4456-a9a4-26ee0f1ec6cc	\N	Double Click	\N	\N	f	2008-05-21 20:51:47.759954
439	455	0a993218-0d52-4ad2-8218-ec6c7858076b	\N	Ali Click	\N	\N	f	2008-05-21 20:51:47.759954
440	456	2e6809d8-1f76-498f-be89-cdd58506f143	\N	Double Click Vinyl	\N	\N	f	2008-05-21 20:51:47.759954
\.


--
-- Data for Name: artist; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY artist (artist_id, mbid, name, sortname, loaded) FROM stdin;
509	99e29d99-50d7-4acb-95fa-cd4edc2c3d08	Yahoo Serious	\N	f
458	0053dbd9-bfbc-4e38-9f08-66a27d914c38	Bad Company	\N	f
460	9dec8cb1-0b16-43d5-b7f1-b9e24997a240	Bad News	\N	f
510	3fa7dc7e-6aa2-4e73-9a07-a3cb34a7f5be	Real Cool Traders	\N	f
514	29eead4d-3793-4625-8727-c03edbb38b8b	Soulja Boy	\N	f
461	05f97d2e-650e-430f-b238-fa186a7c74c4	Bad Times	\N	f
518	d930e557-d7d6-4f84-84f2-1ca53cf85c57	Natural Life	\N	f
462	149e6720-4e4a-41a4-afca-6d29083fc091	Bad Religion	\N	f
480	ea65e66b-c6ba-465a-ba18-380423b173b4	Kemopetrol	\N	f
463	3bd04950-a8f4-45bc-bcdf-df4ca3f4afcd	Bad Street Boy	\N	f
495	bc4978cc-e889-436b-8a24-f2416811df85	Monsdrum	\N	f
459	9be05c26-d8de-4bb4-b790-c627c4d3b602	Bad Ronald	\N	f
471	848ae96d-0a38-47d3-a6b0-7ee8509caf60	Sonja Kandels	\N	f
473	5c9bd7ed-ede8-49e2-a693-2b6b59d06f65	Sara Hickman	\N	f
502	4a9fae02-7de0-4cb8-97d7-1fd790d9675e	Murphy's Law	\N	f
466	ae32393f-b7db-479b-8728-8ea28c1edb16	Bad Boys Blue	\N	f
474	8f5c6093-27ba-402d-b092-4157c93a4104	Love as Laughter	\N	f
468	f27ec8db-af05-4f36-916e-3d57f91ecf5e	Michael Jackson	\N	f
475	4dffdaf8-8fb8-4b3d-8088-427b1e9d1af3	Unleashed	\N	f
479	df369da2-c88e-473e-ab6a-d0f5ab8007c5	Man With No Name	\N	f
503	c8911ad7-9288-4c1b-8e19-5c4ee95ee9fa	Radioactive Goldfish	\N	f
476	7d4624c6-5e71-49f9-a3aa-fc9951953cbb	Jim Chappell	\N	f
477	7b68b1b6-856a-4697-85b4-6b0851ba7c2b	Jack Radics	\N	f
496	bbc5b66b-d037-4f26-aecf-0b129e7f876a	Jimmy Eat World	\N	f
472	cec504d4-5330-4eb4-833d-31f022001c10	Liquid Laughter Lounge Quartet	\N	f
478	ffa25bb8-a082-4b47-aa4c-9ef48df98dc6	BONNIE PINK	\N	f
482	ad2282ed-ada3-46c7-a5d6-09fb45fd3bbc	Vapourspace	\N	f
505	ab6ac71b-1a93-44ae-9cca-c732b4bbe119	Body Head Bangerz	\N	f
491	9a068bb8-298f-4972-ae69-d1454dfc6d0e	The John Cameron Quartet	\N	f
484	f3d27f07-ffd2-4d14-a53e-6969bad36e77	Splat Graphix	\N	f
481	22cd1b33-903c-494a-81d1-d53a5c26cde3	Section X	\N	f
483	7fb8bd7f-249f-4f14-9df8-2d91aea4afc7	Tripmaster Monkey	\N	f
492	a9812f7d-016e-4a55-890a-d45f544a10bd	Morsel	\N	f
493	498695be-0f95-4fea-9e76-4858cab4c835	Berkeley Systems	\N	f
494	b5905195-a456-454a-b32d-cdeafd9bea51	The Electric Eels	\N	f
506	e4ca6ce4-d945-40f6-8d69-6ac88d31344d	Tumsa	\N	f
504	3e103047-217b-496b-b54e-1e2db4dd58b3	Acid Drinkers	\N	f
511	6167114d-d6f2-4a10-8626-5878691fa4f4	Eroc and Urs Fuchs	\N	f
488	f7ab0a4c-23fc-426e-8848-fd39199c87a0	Plastic Assault	\N	f
512	3ae30c53-f401-45e0-946b-70c704078e3c	Mr. Elk and Mr. Seal	\N	f
485	fcecd312-6ed9-4d16-99ce-66c16981f6d9	Jacob London	\N	f
486	95495d6a-c1f2-4a62-b0e3-b9c5f2e9dea6	The James Taylor Quartet	\N	f
487	74e750a2-e662-464c-b657-120f74e17fe6	Bailterspace	\N	f
489	5629ca87-9086-48c4-8dc4-b4a966c45067	Ozric Tentacles	\N	f
490	33aad546-bcab-4600-b896-6455127dac3d	Tranan	\N	f
497	53d8a593-c5e9-4af8-9657-d3bf19b1bb89	Christopher Young	\N	f
498	c85ebfaf-4bdb-47b9-9194-d1fa16c05eb2	Carl Stalling	\N	f
499	83443f35-4617-4c1c-b75f-d535b66614f9	A Beautiful Lotus	\N	f
500	0a41f86c-ced1-44e0-95a2-5c8b2368ab1d	Powerman 5000	\N	f
501	43b58c98-3779-4b04-9a23-1c95cca3a145	Erasure	\N	f
507	01f4fb92-6bf0-4de5-83dc-3fe194e763bf	Happy Mondays	\N	f
508	820a303d-5a80-4b82-b271-74c93ba5094b	Yahoo Boyz	\N	f
529	1b5a00e3-914a-4da5-9962-b4b364e8351e	Die Hinichen	\N	f
536	7928481f-848e-4551-b658-472c0aaf0c85	Die Fantastischen Vier	\N	f
520	5a1b05f4-493f-4f32-939c-e1556e2069fe	Inner Life	\N	f
513	32eacb5b-4e88-495a-ad38-330b4b0da58e	Alix Dobkin	\N	f
515	eb53a36d-3e00-4d9f-a2b7-a9ba658966b7	Yahoo Serious and Lulu	\N	f
524	6e39b2e4-d569-4224-8890-8b167a02609f	Die Trying	\N	f
528	e028fab5-39ae-4ed9-b8c2-c4344d88b171	Die drei ???	\N	f
516	a7064df1-dc2e-4ba5-9883-8b07b7a87cc3	Second Life	\N	f
531	f9b3d5a8-11eb-4f4e-a59a-1e8f30135921	Die! Die! Die!	\N	f
521	c5509111-6336-412a-9c1f-709f54ad6ce2	Life After Death	\N	f
526	52f2c49e-43c4-4716-bf4a-0eac1c651d3a	Die Sterne	\N	f
519	5c3a5cad-d6bc-46b7-9754-99feb9137a22	Elements of Life	\N	f
530	395be6d8-3144-4f20-ae51-0edeaf7f4e13	Die Nullnummer	\N	f
534	2a0b0702-6518-47f0-a1dc-5362467f12b3	Die Crackers	\N	f
522	8c90827b-71a9-4766-8f1c-8eb4fb7d9603	Life on Earth!	\N	f
517	d799a3d7-a232-436b-8f99-9629def8f9bd	Scienz of Life	\N	f
525	f2fb0ff0-5679-42ec-a55c-15109ce6e320	Die Ärzte	\N	f
539	5ec08a60-401c-4e61-8b86-025ff64e7204	Paul Colman Trio	\N	f
523	f2e99aa1-4861-4b8f-b55e-bd088c0715ea	Life	\N	f
533	59167929-4f18-49d3-b62d-45ff782249ee	Die Firma	\N	f
541	cf253a2e-70b0-4af6-bbe3-442bba396bf5	Turn On	\N	f
532	a3cf4407-59c9-4cf6-af9d-da3908d1868c	Die Randgruppencombo	\N	f
527	c8ee7528-df2b-44e3-9dc5-20a67bedb1af	Die Lollipops	\N	f
542	e0b49123-fc1a-4294-ac9e-9d067053e43e	Our Turn	\N	f
535	619a1d9e-f323-4935-9956-896658a52af6	Die Schlümpfe	\N	f
540	8a5fc756-4d6e-4f47-b016-43b41901ff02	Buckfast	\N	f
538	22a40b75-affc-4e69-8884-266d087e4751	Travis	\N	f
537	87cc1504-6a4d-43c4-8c2e-dbcc90b71c71	Die Lunikoff Verschwörung	\N	f
543	a4be63a6-3240-4577-86d5-44b0e19576d9	Fredo Viola	\N	f
544	bcc02f71-8cf4-4b9c-8b66-59809b545448	Socratic	\N	f
545	41a52c92-753f-4da4-bd9d-a01186cbbf6a	Great Big Sea	\N	f
547	d9d9e10b-2150-46bf-b10a-2a77ec8b813d	Electric Turn to Me	\N	f
465	0f211bfc-8c69-4cb7-9165-acbe4353cb0a	 the Queen	\N	f
467	f2a9b3f1-381b-4d91-8e5b-048626baed4d	 The Big Bad Blues	\N	f
469	12d69bd1-08e0-4bb6-9d95-0a33a2477c9b	Green Laughter	\N	f
546	88a4cd4e-5dee-4153-8462-0d5e43c75f47	Feeder	\N	f
470	4e744284-0282-4505-9fd8-afaaa3893bc8	Act	\N	f
558	b961732c-0c70-4bd7-94b4-843317862853	 Jay	\N	f
560	b133c426-28cc-4568-87eb-cb77d7e3bb74	Fear of Pop	\N	f
563	c57a044c-206f-41a5-8eba-f6695943961e	Pop Stars	\N	f
567	aad3af83-5b59-4b86-a569-1a8409149b09	Aaron Copland	\N	f
554	6ab35662-c2bc-4171-8542-a235ec13f411	Handsome Train	\N	f
568	914360f1-82e2-47ff-943b-1d7b977bd27a	Harry Partch	\N	f
571	a952c1da-d7b4-44f9-97c8-27c5f5e5af59	Christian Wolff	\N	f
572	03dc7b33-ff4e-45fd-aead-03799db4ae77	DKV Trio	\N	f
609	5d2f8739-be62-4915-bbc7-11c1ce5bd66d	Gameover	\N	f
589	c2e2144d-d6c5-47d0-a4b4-aa859de5e0b4	Radio Birdman	\N	f
549	deb9c9ba-85df-4281-9dfc-a8c55879cc3a	Pop Tarts	\N	f
573	46419465-f3d7-4683-9e0a-b80c375c9b01	 Michael Mantra	\N	f
575	29004056-4971-4ce4-8bb5-19e11179539c	O'Rourke Prime Prevost	\N	f
569	131153ae-1455-48fc-9c30-6074ae5f158e	Anthony Robbins	\N	f
576	cfe7baf1-18e3-48c0-8caa-d15f3add37b2	Earl Emerson	\N	f
577	7dbfbb26-7fb9-4b9d-9a76-988c0a1d5b17	黒田倫弘	\N	f
581	842360c8-9a1d-4bba-85ba-5bc19e7d8976	Minamo	\N	f
580	b134d1bf-c7c7-4427-93ac-9fdbc2b59ef1	Meat Loaf	\N	f
579	b1741750-3d1c-438f-b06a-98520a2e11c9	Appear	\N	f
582	9d9d1d36-1fed-44e2-9069-9398284e9f6c	Lia	\N	f
585	9e679e4a-cded-4190-8bed-a48ef02cf6f4	Pronoian Made	\N	f
584	aee3ce7b-1975-43fd-a347-c1c1ecbde0ff	Bridge and Tunnel	\N	f
586	33eef1b3-e23b-4643-ac1b-b970ad510dc5	すぎやまこういち	\N	f
587	aa477215-ac39-4d6e-9ce3-d28877db46ac	Farfield	\N	f
597	e10cbaee-3952-4935-b915-5957511891df	Papa San	\N	f
588	70d9dbbf-a712-4e09-a99a-99f82faa9027	Rick Potts	\N	f
590	804a7e24-c0ae-451f-8a66-d66315bb3640	Skullhead	\N	f
592	8afaa3ce-6442-4816-be36-f9c6972044c9	Victory Gin	\N	f
598	1d3362bc-65fe-4106-b009-6f1cead58081	Steve Haun	\N	f
591	72c9d2f5-fd02-49b5-a496-3604d870dc72	Lourds Lane	\N	f
599	e32e0c8a-694f-49f4-844b-8ff5336f1b82	Do or Die	\N	f
593	2af8def8-db31-4998-8bd9-18fdd76db088	Billy Joe Shaver	\N	f
601	c460939e-3b0f-4356-8566-fdf26869b9c4	Word of Life Church	\N	f
602	2072f699-049a-4b78-b039-317a1c7cff94	 The Family	\N	f
595	caa8844b-6a16-4100-b2ae-622b2edf5055	Half Pint	\N	f
600	38a9dd50-aafd-491f-a7ea-29a07ea9ecfa	Daan	\N	f
594	0e5eca1b-75da-4d9d-946e-85a921bd6e2d	Victory Music	\N	f
605	b6e7f5aa-f48e-44bd-999d-c91e985fbbcb	Gaia Epicus	\N	f
606	3f8c37a3-2903-41ab-80ac-60a41d1e694d	Fortress	\N	f
608	c7aca277-97fa-448a-b899-0901c3bf7bcc	The People's Victory Orchestra and Chorus	\N	f
603	33522868-f75c-4dc4-8f54-2042ce86e989	Trance	\N	f
618	01f6afbe-dce6-4012-ab59-a257e62ce29d	Tigrics	\N	f
596	ad73761f-c66d-4149-899d-21f56d1969a1	Running Wild	\N	f
548	c3fd37fe-2f09-47a7-bae2-4b86f6d70f59	Nacha Pop	\N	f
611	94079d14-02bd-4721-bb3e-91ba24373434	Season to Risk	\N	f
604	0d3737b6-dc26-4eef-bb79-38bbe81f0cd6	Test Dept.	\N	f
625	55704c38-224f-4b75-b29f-d43653f8bc9a	Primal Scream	\N	f
613	f757d05a-0dd8-43bb-bda6-4bfa6a955e4b	SMP	\N	f
610	1f6fd5b5-5013-4619-8536-422dd183c530	Gameover	\N	f
622	3f06695e-5308-48ef-b3eb-e1f8ac6ef299	Aqueduct	\N	f
615	de4df0ee-a25b-48a9-a1c3-7ec06bb5f6d5	Supermarket	\N	f
614	b46a96fa-6e79-4fb7-ba91-7778e79d7ff0	k-shi	\N	f
612	c0e03a06-f8b9-47ac-a50f-8ae1dbb5bd52	Ozma	\N	f
621	ba853904-ae25-4ebb-89d6-c44cfbd71bd2	Blur	\N	f
616	7e9ad754-55ac-4e82-a671-2bc77db90b23	Barry Leitch	\N	f
623	e64ed067-056a-4fca-9b18-3c986c2ef24c	Logicbomb	\N	f
624	5ae9128d-5557-48ad-a135-8f72d0fc35ee	 岩田匡治	\N	f
619	442c35ef-4bc2-40f5-8998-67c77504a693	細江慎治	\N	f
552	59c0c7b0-81a0-408e-9341-a0a7403dcac4	This Is Pop	\N	f
553	528d4671-7d6e-4dcf-9b98-c01deb62f500	 The Pop Riviera Group	\N	f
626	991295f7-d40f-47ff-be26-ad6359de1509	Christine Milton	\N	f
620	32a509d0-6c4c-43c9-b169-03b601367dbd	TC	\N	f
627	c9d4f63d-6c2c-47ae-84fe-819001e3d3ea	C+C Music Factory	\N	f
550	68e38dca-0ae0-4b2e-a5fa-62e39d6e89db	PSIHOMODO POP	\N	f
574	81e53607-02ca-40ef-ab26-6e472380476d	Hemi-Sync	\N	f
555	767bc881-0d33-4a9f-bbe8-bd7cf86a5714	PoP	\N	f
570	72359492-22be-4ed9-aaa0-efa434fb2b01	The Allman Brothers Band	\N	f
556	9a8ce609-ea33-4cf3-b006-a76e08311653	MIG 21	\N	f
557	054b0483-eeb8-48ce-bb72-f1cb57ff44f9	Gas	\N	f
562	c08b95f0-5c09-439a-9c59-6a72283421b1	Sonic Coaster Pop	\N	f
561	49e3fae1-b934-4c1e-8bfa-9197a053955f	Pop Dell'Arte	\N	f
559	6277c674-a9c5-4396-a992-6e155d6574ef	Pop Shuvit	\N	f
564	a1ac90a8-76af-4c56-a5e0-642d4d8a863b	Pop Razors	\N	f
565	5645a0ec-fcca-45eb-9fb7-1c26cc655ca4	Flux Pop	\N	f
578	45fc476b-9249-4fae-ace3-740196e6acea	The Shadow Project	\N	f
566	7ff16dfd-f03f-472f-b496-70f2b49a00a0	Ultrasound	\N	f
583	ea3f98d1-6c31-4c50-8f34-603d1b28ab24	岩男潤子	\N	f
617	10f89329-c3a4-40c5-81db-af17ef6af902	Patrick Phelan	\N	f
628	54c29bb0-6cc3-457a-98be-857e0c66716f	Conway Brothers	\N	f
629	0ab49580-c84f-44d4-875f-d83760ea2cfe	Maroon 5	\N	f
630	d4a1404d-e00c-4bac-b3ba-e3557f6468d6	Ace of Base	\N	f
631	7fb50287-029d-47cc-825a-235ca28024b2	Soft Cell	\N	f
632	f0602f55-1770-483d-89bd-4bae0d0ac086	Jennifer Lopez	\N	f
633	78e98e0e-f873-4e5e-b4b7-88b7293fd713	Christina Milian	\N	f
634	c234fa42-e6a6-443e-937e-2f4b073538a3	Chris Brown	\N	f
635	d69ee229-2f36-494c-b104-9ae0d8be506b	Level 42	\N	f
636	ab7eb62c-82bb-409e-b097-b8bea4be866d	Lulla Bye	\N	f
637	ed78d5cd-4467-49c6-8c48-ea84161cb880	 The Dragonaires	\N	f
638	53731da5-20be-4fc5-8b79-97f730d57dd2	Lucilectric	\N	f
641	8c0e714c-f10f-40f1-a684-81b31c003a58	Secede	\N	f
642	ce028650-d901-4bc5-ac15-d05a66efddfe	Coralie Clément	\N	f
643	52eb3f6f-9601-4690-a336-536688082652	Charles Strouse	\N	f
644	68057aab-5f54-4a2f-ab9a-af0cbcbb09b9	Kevyn Lettau	\N	f
645	6e60deeb-a666-42c5-95cb-a5eada6bbbe5	Marilyn Monroe	\N	f
646	9f525d0b-3911-4c83-b0d1-e90aa1fd2d14	Buju Banton	\N	f
647	69421e11-e4c3-4854-951b-ceab4972e38e	Alkaline Trio	\N	f
648	96fe5b46-2ac8-411c-96df-2acba8ec4f1f	 Blues	\N	f
649	1e76d891-8634-4b08-999e-69042304b89c	Rainbow	\N	f
650	1303b976-b862-4f04-94fd-a8d444e06714	The Proclaimers	\N	f
651	091ec508-877f-4e3c-92a3-10903bbbc7ad	The Everly Brothers	\N	f
652	7ac055fa-e357-4890-9098-010b8094a900	Alabama	\N	f
653	79842ea5-307b-46b8-b506-ffa73e546432	Denniz PoP	\N	f
654	904cc1c8-021e-45ac-bbe9-95c01a1f8099	Jah Wobble	\N	f
655	36ef9b72-0346-4238-9335-25c55f3d2ad3	Cecil Leuter	\N	f
464	19172a4e-a7cb-4c96-ab5e-6058156a7481	Booth and the Bad Angel	\N	f
639	561d854a-6a28-4aa7-8c99-323e6ce46c2a	Miles Davis	\N	f
640	1a9b4e0d-05e2-4491-83f0-a4a676283f99	Preservation Hall Jazz Band	\N	f
658	250c6910-3d75-4de2-a547-83f321814717	Jennifer Ellison	\N	f
657	f49071de-43ff-49c0-9229-6238c91b1044	Geyster	\N	f
656	a9229736-b3ca-4986-ab1e-354880664618	Lou Gare	\N	f
551	12287703-f9d6-4f30-8c0a-297807bc9ad6	Anthemic Pop Wonder	\N	f
607	4f6654b3-0ae3-44bc-9bed-e9477446beab	Академический ансамбль песни и пляски Российской армии	\N	f
368	ed56ac0d-8879-400d-981e-4c0f404810f3	Marco Menichelli	\N	f
374	344cde7a-cff3-4721-a8bf-d31ded9bb147	Tony (T.S.) McPhee	\N	f
386	d8377ddc-05e7-4307-b879-cc7c3b5ba32c	Primos Game Calls	\N	f
327	8d6a4455-1ae8-4e51-a481-08a85cb0141a	DJ Ötzi	Ötzi, DJ	t
366	b4cadc83-7307-4196-9f2f-29ebf1650045	Lisa Germano	\N	f
379	59ab00f9-b3da-46d4-8b94-5e7dbb832527	Tribal Sax	\N	f
328	28cbf94d-0700-4095-a188-37e373b069a7	Basement Jaxx	Basement Jaxx	t
377	26a0c0f5-b37d-4a16-af6a-feabeaf473a9	The Sax Pack	\N	f
372	7b21057d-f504-4a3e-be7f-6c1e4528320a	Slide	\N	f
375	7d622d47-c76e-4e2f-892e-18fe318be037	Backbone Slide	\N	f
371	5da2666c-d14d-46ee-8bd1-77904f55b6bc	超飛行少年	\N	f
380	4e303fcf-0f7e-42f4-b84e-454a7922e725	James White and The Blacks	\N	f
330	8538e728-ca0b-4321-b7e5-cff6565dd4c0	Depeche Mode	Depeche Mode	t
381	f319b57a-a494-40f6-a467-3d196d3484e6	Sparks	\N	f
385	eb9f459b-c5e9-4c21-8391-098becc23620	Kimitaka Matsumae	\N	f
331	1ec4c3eb-dfab-49cd-86bf-1fea72f653b7	Blå Øjne	Blå Øjne	t
388	a9591a2d-9317-4674-8ab5-9de8b770fcab	Bob Rivers	\N	f
376	69a56528-7c5f-48b5-b270-e1f2b1bf11eb	Sax As Sax Can	\N	f
355	fc63d806-ca89-4ea3-a404-ee6de695743f	Shaggy	Shaggy	t
336	fe37acd4-893c-4b2c-8ad2-7fd394280354	Jessica Simpson	Simpson, Jessica	t
387	8c459110-8b2d-4a64-aa14-22af64fb5ab4	Pamela Conn Beall and Susan Hagen Nipp	\N	f
344	6be2828f-6c0d-4059-99d4-fa18acf1a296	Janet Jackson	Jackson, Janet	t
333	2f569e60-0a1b-4fb9-95a4-3dc1525d1aad	Backstreet Boys	Backstreet Boys	t
370	e2c00c56-8365-4160-9f40-a64682917633	Goo Goo Dolls	\N	f
369	4bd477e1-0144-4e2f-910a-829aa539b6b8	Plastic Tree	\N	f
373	897022a8-5436-48c7-b7b4-d86b40c387d9	Scala	\N	f
382	27d9ef77-40c5-4245-82af-147e3d910316	Gordon "Sax" Beadle	\N	f
334	177fde26-5a95-46d9-922f-0933940d97e5	98 Degrees	98 Degrees	t
378	fa8c0b9f-6bcb-4bbc-9ce0-7e25d72ab862	Steve Lawson	\N	f
325	a796b92e-c137-4895-9c89-10f900617a4f	Destiny's Child	Destiny's Child	t
389	7a412268-1f96-4cdc-9b19-1b79c7f3bfaa	SHAT	\N	f
390	177df2b2-a96d-4093-9970-57cda814de26	Jack O' Fire	\N	f
335	888f7e18-2a96-4f2e-8320-08ff4330b442	Kandi	Kandi	t
391	eec63d3c-3b81-4ad4-b1e4-7c147d4d2b61	[no artist]	\N	f
392	e2c3124c-7e90-4708-ad8c-4f3559246922	Not Breathing	\N	f
360	2fddb92d-24b2-46a5-bf28-3aed46f4684c	Kylie Minogue	Minogue, Kylie	t
393	81e341ac-1b9f-41fe-a851-fca0cccd4b43	Bananas at Large	\N	f
384	f8cf9ab7-3c05-4c47-8f8a-c21e539a5a17	Vulva	\N	f
337	e01482f5-8865-4d25-b2f5-0ebfdf53d96c	soulDecision	soulDecision	t
394	92aadaca-d153-40d7-a219-b1c30d84e20d	Rowan Atkinson	\N	f
315	603ba565-3967-4be1-931e-9cb945394e86	*NSync	NSYNC	t
338	1cfe52d7-181a-4b3a-8041-d8bf9ccef57b	Mystikal	Mystikal	t
356	bf0caafc-2b20-4e07-ab85-87e14ff430ce	Spice Girls	Spice Girls	t
365	89f47757-c070-4820-a3ad-6524b13dbb5a	Mr. C The Slide Man	\N	f
357	a371601f-c184-4683-806d-2eb35e88f0d7	All Saints	All Saints	t
317	2b353828-6748-4ba4-bddd-493d728372c5	Christian	Christian	t
318	7d48da7e-5eee-45df-8e89-dfaee2af82c4	Dante Thomas	Thomas, Dante	t
319	8a44a6c6-a5ef-4e36-8ce0-3fd1d762e563	Daddy DJ	Daddy DJ	t
320	f42fa1c3-7e90-402b-9930-3a5eccceecb7	Karen Busck	Busck, Karen	t
321	2d6a30a0-3925-4fad-84ed-a568872b081c	Safri Duo	Safri Duo	t
322	01e60eba-52df-4694-8f09-39f43abe54e9	Brandy	Brandy	t
323	4f29ecd7-21a5-4c03-b9ba-d0cfe9488f8c	Wyclef Jean	Jean, Wyclef	t
324	1b4bee4d-3239-4a65-8239-b62b43c23f48	Titiyo	Titiyo	t
339	7c5e39c3-7645-4e37-968d-a4e45cd38c5d	Mya	Mya	t
341	45a663b5-b1cb-4a91-bff6-2bef7bbfdd76	Britney Spears	Spears, Britney	t
326	23207c32-6743-4982-9f46-e297b2e4eb14	Geri Halliwell	Halliwell, Geri	t
367	dda04604-b50a-4bd1-8780-77564c659dc0	Luna	\N	f
340	4c0bb5bc-95ad-47de-99e3-fbb4fbc5f393	Aaron Carter	Carter, Aaron	t
396	b6f3bebb-a7f0-4b5a-8daa-d603531beb7f	My Penis	\N	f
342	25e0497c-faa4-4765-b232-baa20e5e35a7	Sisqó	Sisqó	t
343	9dc9f4b0-a7b4-43c5-8f6b-fcd43c426a4b	Mandy Moore	Moore, Mandy	t
316	89ad4ac3-39f7-470e-963a-56509c546377	Various Artists	Various Artists	t
345	0662fa9d-73b0-4f71-9576-c963a5a14f66	BBMak	BBMak	t
346	c30dfb44-768a-487b-af9c-c942682aa023	Nine Days	Nine Days	t
347	2386cd66-e923-4e8e-bf14-2eebe2e9b973	3 Doors Down	3 Doors Down	t
348	3604c99d-c146-4276-aa0c-9376d333aeb8	Everclear	Everclear	t
349	5dcdb5eb-cb72-4e6e-9e63-b7bace604965	Bon Jovi	Bon Jovi	t
397	3c3d3ad8-3935-4c00-affb-768563916f36	Fluke	\N	f
350	24d2505b-388c-46cc-8a64-48223ea6d78d	Take That	Take That	t
351	9bd94498-68cc-4b1e-b9cf-b3ba95cffccf	 Jason Donovan	 Donovan, Jason	t
352	ee20d564-25ca-4ef5-aba7-93a39f78ed60	East 17	East 17	t
353	090dafe5-818c-4bba-9ebf-7e3a651a5c43	New Kids on the Block	New Kids on the Block	t
354	7343056e-041e-4b28-a85a-58e8fb975136	Eternal	Eternal	t
358	19659aa7-cd3a-4bfe-bca0-6943e9e5c6e0	Steps	Steps	t
359	bd5cf3e9-cb6c-41f3-8c7d-e9bda3c4e721	S Club 7	S Club 7	t
383	125ec42a-7229-4250-afc5-e057484327fe	[unknown]	\N	f
361	db4624cf-0e44-481e-a9dc-2142b833ec2f	Robbie Williams	Williams, Robbie	t
332	f1cd545b-f17b-4d3a-98de-68b695bfe211	Ronan Keating	Keating, Ronan	t
362	02db9e84-a750-4d22-b5b1-c769e698dc6c	Liberty X	Liberty X	t
363	9c79224c-70cd-4367-8d90-35ca99401b75	Blue	Blue	t
364	6fda00c2-449a-4bf4-838f-038d41a07c73	Atomic Kitten	Atomic Kitten	t
329	5f000e69-3cfd-4871-8f1b-faa7f0d4bcbc	Westlife	Westlife	t
398	e0d63978-8944-4a34-870a-f91c952f5d90	C+J Project	\N	f
395	1b53eb94-ee7a-4689-ad4a-f2909d201bea	Blood Freak	\N	f
454	6f39bb73-b44d-4f46-887e-0b2d9671fe5a	The Click	\N	f
405	f5e31fda-bbf5-4ab6-8194-bcc9209b53f8	The Romantics	\N	f
406	13631801-97c1-47ba-81a8-536a2522578c	Special Beat	\N	f
430	7fe9c065-9007-430a-8554-8aba8d257c4c	Bellatrix	\N	f
431	9aec0d9a-c5b3-45ab-839c-d60f18534437	Mesh	\N	f
407	6cb79cb2-9087-44d4-828b-5c6fdff2c957	Gary Numan	\N	f
432	43342b83-fdd4-4b69-a6bc-b91e93768861	デンジャー☆ギャング	\N	f
419	fc98417a-180f-464d-ac3f-534311c78eba	Super Extra Bonus Party	\N	f
408	edd6a7c3-d174-4e5b-9134-0f0cc6e2b0a5	Yves Montand	\N	f
420	7df17bd2-2235-456f-bddc-ec5ba2c4f8cc	M:I:5	\N	f
421	6ee6293b-b2d8-4b41-9c77-c216e80ddf2f	Bónus	\N	f
433	0e40e594-d217-4cf8-a130-2888119ed6c6	Ether Aura	\N	f
434	fff4cb7d-55af-4f9a-9a18-3b2f8089efac	Rymes With Orange	\N	f
435	9b952ee8-d45d-4a26-8066-57849d871e06	Government Issue	\N	f
452	873bd840-c107-4025-8492-667faa9f501b	Infected Mushroom vs. Liranran	\N	f
455	ff95eb47-41c4-4f7f-a104-cdc30f02e872	Brian Eno	\N	f
414	e1914450-1e21-4073-8c8c-dcdff615f4b0	Halo in Reverse	\N	f
436	d7a2ea77-0850-4480-8964-246c0a3d6efe	Snog	\N	f
456	eab76c9f-ff91-4431-b6dd-3b976c598020	Infected Mushroom	\N	f
437	ad5b541b-2669-4db4-a3d2-0eae9bac5c0e	Shebang	\N	f
409	9beb62b2-88db-4cea-801e-162cd344ee53	Beastie Boys	\N	f
438	2e41ae9c-afd2-4f20-8f1e-17281ce9b472	Gwen Stefani	\N	f
440	e0a2bfb3-5f89-44d0-8cca-f6fe0e5f0381	Colors of the Land	\N	f
457	175be76f-52cc-4411-957a-9c2b0fbae0b9	Le Click	\N	f
439	cbaafb20-eb74-421a-85f1-2bb6341aad23	Propellerheads	\N	f
422	6812e5a9-3c45-4c9e-8516-4925123fbe94	Bonus	\N	f
447	2c337062-3175-4dd0-a29b-e1936fd71812	Promised Land	\N	f
448	3d8db5c3-36b6-4100-b62c-694b7ff50c4c	Aphelion	\N	f
449	705221a0-1a19-4d76-b340-495137392f7e	Degrees.K	\N	f
441	3877a6a1-093c-4478-b5a6-58a99a1338db	Orphaned Land	\N	f
410	db612997-f11e-424d-8b41-cf410a433656	Asian Dub Foundation	\N	f
411	b52211f1-49a2-4cd2-8535-dd1ba37ea90b	Cowboy Junkies	\N	f
450	0f24bcb0-8d37-409d-aed1-92bd4e5337ed	Medicine	\N	f
451	74023430-99ac-4517-b7a6-f0cf0120a47d	Chris Spedding	\N	f
423	3617825d-9e4c-409a-b824-7ad1bfc5c7ed	Brassy	\N	f
442	5b1b1e09-6f08-4c80-a598-36e7593c1936	Dronning Mauds Land	\N	f
415	30a72ea8-9c29-4084-9d4f-79ec29585fe0	Reverse Cowgirl	\N	f
424	f8653ae9-b729-4f36-99a5-e05eae90b640	Andrea Berg	\N	f
425	11f6d265-a614-49ae-b50a-838954aab9ba	Crash and Burn	\N	f
412	ccda046a-2674-4f7d-97e6-f23d6c156432	Dead Can Dance	\N	f
413	490db27e-d941-425a-abbd-2c2b3e03f5d1	Morandi	\N	f
399	31810c40-932a-4f2d-8cfd-17849844e2a6	Squirrel Nut Zippers	\N	f
400	f9ef7a22-4262-4596-a2a8-1d19345b8e50	Garbage	\N	f
401	e795e03d-b5d5-4a5f-834d-162cfb308a2c	PJ Harvey	\N	f
402	5f58803e-8c4c-478e-8b51-477f38483ede	Madness	\N	f
416	57662556-5321-4f46-b375-b86174f27158	Eldritch	\N	f
417	c5fe606b-04d3-473e-8e32-67c4b469b80f	The Dagons	\N	f
418	b87d230d-7f96-4d2c-b6df-810c47b9c4f3	Frames A Second	\N	f
443	26afb633-b3a6-4bf0-87a1-7c58251134b5	Land	\N	f
403	479497d4-e7c2-4e78-972e-56e78fac3995	Chris Isaak	\N	f
444	154a696f-302c-46cb-844c-35084821ce78	The Land of Nod	\N	f
445	b80f5bff-9061-4635-9a23-c9042084ac4d	Ro-robot	\N	f
446	50fc4742-1389-45a0-8c6f-6a5159ae20c2	ᛏᛣᚱ	\N	f
426	a5cf65b5-3a71-47ad-8992-371b5266c450	Crash	\N	f
404	703c7062-cc25-47e0-919e-ef740b88c725	Chris von Sneidern	\N	f
453	7857f27d-45fe-44d2-85da-92732062c45a	Click-B	\N	f
427	9b58672a-e68e-4972-956e-a8985a165a1f	Howard Shore	\N	f
428	3fc5dc30-e567-4afa-859d-24e455b2898b	Pogo Pops	\N	f
429	56d6a50f-4be2-4796-9709-7eb88c45b63b	Mark Isham	\N	f
\.


--
-- Data for Name: file; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY file (file_id, track_id, filename, last_updated, duration, channels, bitrate, samplerate, puid_id, album, albumartist, albumartistsort, artist, artistsort, musicbrainz_albumartistid, musicbrainz_albumid, musicbrainz_artistid, musicbrainz_trackid, title, tracknumber, year) FROM stdin;
1	\N	/media/music/sortert/slide.ogg	2008-05-21 20:41:05.716997	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
2	\N	/media/music/sortert/ubuntu Sax.ogg	2008-05-21 20:41:05.914525	25000	2	160	44100	\N						                                    	                                    	                                    	                                    			
3	\N	/media/music/sortert/Now That's What I Call Music! 5 - 01 - *NSync - It's Gonna Be Me.mp3	2008-05-21 20:41:06.588127	192000	2	192	44100	\N						                                    	                                    	                                    	                                    			
4	\N	/media/music/sortert/gobble.ogg	2008-05-21 20:41:06.725626	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
5	\N	/media/music/sortert/flip-piece.ogg	2008-05-21 20:41:06.83066	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
6	\N	/media/music/sortert/gnometris.ogg	2008-05-21 20:41:06.918773	1000	1	80	44100	\N						                                    	                                    	                                    	                                    			
7	\N	/media/music/sortert/Smash Hits: The Reunion (disc 2) - 11 - *NSync - Bye Bye Bye.mp3	2008-05-21 20:41:07.166551	199000	2	160	44100	\N						                                    	                                    	                                    	                                    			
8	\N	/media/music/sortert/reverse.ogg	2008-05-21 20:41:07.275987	1000	1	22	8000	\N						                                    	                                    	                                    	                                    			
9	\N	/media/music/sortert/*NSYNC - 05 - *NSync - God Must Have Spent a Little More Time on You.mp3	2008-05-21 20:41:07.520683	285000	2	128	44100	\N						                                    	                                    	                                    	                                    			
10	\N	/media/music/sortert/bonus.ogg	2008-05-21 20:41:07.620494	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
11	\N	/media/music/sortert/Absolute Music 27 - 11 - *NSync - Pop.mp3	2008-05-21 20:41:07.827556	176000	2	128	44100	\N						                                    	                                    	                                    	                                    			
12	\N	/media/music/sortert/*NSYNC - 08 - *NSync - I Want You Back.mp3	2008-05-21 20:41:08.062014	203000	2	128	44100	\N						                                    	                                    	                                    	                                    			
13	\N	/media/music/sortert/crash.ogg	2008-05-21 20:41:08.161653	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
14	\N	/media/music/sortert/No Strings Attached - 06 - *NSync - This I Promise You.mp3	2008-05-21 20:41:08.401474	285000	2	128	44100	\N						                                    	                                    	                                    	                                    			
15	\N	/media/music/sortert/land.ogg	2008-05-21 20:41:08.505039	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
16	\N	/media/music/sortert/click.ogg	2008-05-21 20:41:08.583114	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
17	\N	/media/music/sortert/bad.ogg	2008-05-21 20:41:08.663645	0	1	29	11025	\N						                                    	                                    	                                    	                                    			
18	\N	/media/music/sortert/*NSync - 14 - *NSync - Forever Young.mp3	2008-05-21 20:41:08.897442	244000	2	128	44100	\N						                                    	                                    	                                    	                                    			
19	\N	/media/music/sortert/laughter.ogg	2008-05-21 20:41:09.010633	2000	1	22	8000	\N						                                    	                                    	                                    	                                    			
20	\N	/media/music/sortert/teleport.ogg	2008-05-21 20:41:09.098614	0	1	29	11025	\N						                                    	                                    	                                    	                                    			
21	\N	/media/music/sortert/splat.ogg	2008-05-21 20:41:09.183915	0	1	29	11025	\N						                                    	                                    	                                    	                                    			
22	\N	/media/music/sortert/yahoo.ogg	2008-05-21 20:41:09.290867	0	1	29	11025	\N						                                    	                                    	                                    	                                    			
23	\N	/media/music/sortert/lines3.ogg	2008-05-21 20:41:09.37979	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
24	\N	/media/music/sortert/No Strings Attached - 13 - *NSync - I'll Never Stop.mp3	2008-05-21 20:41:09.611614	206000	2	192	44100	\N						                                    	                                    	                                    	                                    			
25	\N	/media/music/sortert/No Strings Attached - 01 - *NSync - Bye Bye Bye.mp3	2008-05-21 20:41:09.808568	201000	2	128	44100	\N						                                    	                                    	                                    	                                    			
26	\N	/media/music/sortert/life.ogg	2008-05-21 20:41:09.902277	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
27	\N	/media/music/sortert/lines1.ogg	2008-05-21 20:41:09.979448	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
28	\N	/media/music/sortert/No Strings Attached - 08 - *NSync - Digital Get Down.mp3	2008-05-21 20:41:10.218184	265000	2	128	44100	\N						                                    	                                    	                                    	                                    			
29	\N	/media/music/sortert/die.ogg	2008-05-21 20:41:10.317358	1000	1	29	11025	\N						                                    	                                    	                                    	                                    			
30	\N	/media/music/sortert/No Strings Attached - 02 - *NSync - It's Gonna Be Me.mp3	2008-05-21 20:41:10.597873	192000	2	192	44100	\N						                                    	                                    	                                    	                                    			
31	\N	/media/music/sortert/turn.ogg	2008-05-21 20:41:10.697572	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
32	\N	/media/music/sortert/pop.ogg	2008-05-21 20:41:10.778829	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
33	\N	/media/music/sortert/mpeg2.mp3	2008-05-21 20:41:10.852755	10774000	1	12	22050	\N						                                    	                                    	                                    	                                    			
34	\N	/media/music/sortert/appear.ogg	2008-05-21 20:41:10.957228	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
35	\N	/media/music/sortert/victory.ogg	2008-05-21 20:41:11.059634	2000	1	22	8000	\N						                                    	                                    	                                    	                                    			
36	\N	/media/music/sortert/gameover.ogg	2008-05-21 20:41:11.146625	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
37	\N	/media/music/sortert/lines2.ogg	2008-05-21 20:41:11.228156	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
\.


--
-- Data for Name: possible_match; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY possible_match (file_id, track_id, meta_score, mbid_match, puid_match) FROM stdin;
\.


--
-- Data for Name: puid; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY puid (puid_id, puid) FROM stdin;
\.


--
-- Data for Name: puid_track; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY puid_track (puid_id, track_id, updated) FROM stdin;
\.


--
-- Data for Name: setting; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY setting (setting_id, setting_class_id, key, value, user_changed, description) FROM stdin;
1	1	sorted_directory	/media/music/sortert/	t	Output directory
2	1	unsorted_directory	/media/music/usortert/	t	Input directory
3	1	duplicate_directory	/media/music/duplikater/	t	Directory for duplicate files
4	2	metadata_search_url	http://musicbrainz.org/ws/1/track/	f	URL to search after metadata
5	2	puid_search_url	http://musicbrainz.org/ws/1/track/	f	URL to search after puid
6	2	release_url	http://musicbrainz.org/ws/1/release/	f	URL to lookup a release
7	3	album_weight	100	f	
8	3	artist_weight	100	f	
9	3	combine_threshold	0.8	f	
10	3	duration_limit	15	f	
11	3	duration_weight	100	f	
12	3	title_weight	100	f	
13	3	tracknumber_weight	100	f	
14	2	album_cache_lifetime	3	f	When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again.
15	1	puid_min_match	0.5	f	Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0
16	2	puid_cache_lifetime	3	f	When it's more than this months since puid was fetched from MusicBrainz, it'll be fetched from MusicBrainz again.
17	1	puid_min_score	0.5	f	Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0
18	1	metadata_min_score	0.75	f	Minimum value for when a metadata lookup is considered a match. Must be between 0.0 and 1.0
\.


--
-- Data for Name: setting_class; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY setting_class (setting_class_id, name, description) FROM stdin;
1	FileReader	TODO
2	WebService	Settings for looking up data on a WebService
3	FileMetadata	TODO
\.


--
-- Data for Name: track; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY track (track_id, album_id, artist_id, mbid, title, duration, tracknumber) FROM stdin;
1020	446	460	ef90e79c-07a7-47bd-b5dc-bcffb1e0e229	Bad Dreams	255360	17
1021	444	460	86769182-7bef-4d62-96d9-6e0e63ea9a63	Bad Dreams Rehearsal	313840	1
1022	444	460	39898298-846c-4f28-9aa1-b3fd8661af87	Hey Hey Bad News	321640	11
1023	446	460	c21a0053-eca8-41e1-b4d7-57f44d24612b	Hey Hey Bad News	316520	1
1024	447	462	1d6fcfeb-52bd-4aba-8da4-9777afb03faf	Bad Religion (First Version)	109000	1
1025	447	462	2a76a4ca-1e75-40fa-b67a-ba9c56b41fb0	Bad Religion (Third Version)	108000	7
1026	448	463	70177190-8376-4284-a4f6-1fa7b76aeb75	Bad Power	267080	2
1027	448	463	50d924fe-e3ea-470d-80fe-f5307d0a1a35	Bad Street's Intro	70693	1
1028	449	458	7bd0def4-b6f7-44c2-b020-be5de11a2350	Bad Company	287600	4
1029	450	458	37504a6b-90c5-49d5-9f57-03889979e334	Too Bad	233040	7
1030	449	458	6477525a-cf0c-4dd6-8e18-f49946f6a176	Good Lovin' Gone Bad	216640	9
1031	451	464	f1cc5763-533f-4f56-a377-50d1031c8464	Dance of the Bad Angels	273933	2
1032	452	465	c01c7655-4d44-46c0-807b-e21a27176f78	 the Queen	420293	12
1033	453	466	faa390d6-1c98-46b1-996c-863259b0eecc	Hot Girls - Bad Boys	250000	6
1034	454	466	9082fd62-dd4e-41c0-8801-461a6851d8bf	Bad Boys Blue / You're a Woman	240000	1
1035	455	466	745a5b84-aa12-43f3-8b73-e2f0e6b2ff2a	Hot Girls - Bad Boys	248066	15
1036	454	466	eb9a75ae-e2d5-4d7a-8656-31e36e06e09b	Bad Boys Blue / Don't Wall Away Suzanne	230000	11
1037	456	467	19de2d7b-b809-4ad0-bd82-85421cf58215	Big Bad Blues	226000	1
1038	457	468	47eaab1a-667b-490d-8094-168e7d0d9ad1	Bad	247733	1
1039	458	468	592b934d-3404-48b0-b910-973f9d994487	Bad	247093	1
1040	459	469	82b321b9-51e7-4e0a-9713-f004c4a9ead3	Green Laughter	0	1
1042	461	470	6ebbd908-1a1c-4e51-bab3-705fd3cad8c5	Laughter	237733	3
1043	462	470	264000f6-4212-4132-a2a3-d7a7d112f15c	Laughter	238200	3
1041	460	470	b33dd0fe-0aba-4dcb-8d52-739371ace4da	Laughter	238000	3
1044	463	471	8f48a82a-a6a2-42c7-9263-469f7cfe0832	God of Laughter / Solingobu	219160	10
1046	464	472	577a910e-6843-4fdc-9fe6-794f23dde6ce	Ein Wort	230000	4
1047	464	472	37e59f42-1da9-4017-be04-98d29d5a9a64	Allnighter	236000	8
1045	464	472	bf414dda-e827-4e5a-a754-4672ffe36629	Black pool	233000	3
1048	464	472	6fb87ba1-d032-43b4-84a6-796bc0ca9ab8	Maldivion, va a ser un nuevo dia	239000	11
1049	465	473	d0f60d32-f323-46a7-8022-835e5f368579	Two Kinds of Laughter	234626	1
1050	466	474	6342bb29-5ab3-4b49-b1ed-0a504df3c0d4	In Amber	243000	1
1051	466	474	cfb30fb2-4cc9-4051-87d4-c39cdd1af4b9	I Won't Hurt You	175000	2
1052	466	474	96a1ac18-1399-4c45-801d-2286342f9a83	Idol Worship! Idol Worship!	171000	3
1053	466	474	484e2fcc-b9ed-450d-a84a-4db6f28574ce	Survivors	263000	4
1054	466	474	d0a41afd-d06c-40f7-9ba3-dc509538207c	Every Midnight Song	299000	5
1055	466	474	cfc94dff-bd2d-429a-b87a-5ccdbcafcf3f	Dirty Lives	186000	6
1056	466	474	5c4856d2-d877-4da8-967e-76402cf9ec7e	I'm a Ghost	248000	7
1057	466	474	2a61c3ed-fcde-40be-983d-926a7ae1ce7f	Canal Street	267000	8
1058	466	474	b68ae191-3917-430c-8f1c-8daeb25d97b1	Pulsar Radio	412000	9
1059	466	474	a95e3f98-044c-4767-a347-fc30ee4ecf10	Corona Extra	250000	10
1060	466	474	0fef9c4b-8f47-4f25-a251-5d5f88b9a447	Makeshift Heart	380000	11
1061	467	475	fd1ac1df-1e4f-4348-97d3-383043619efc	...And the Laughter Has Died	202226	8
1062	468	476	7cbf6f7d-766a-4a3c-9e5a-faa22e41db8d	Laughter at Dawn	537240	14
1063	469	477	b6e1888a-df5c-4aeb-b61c-6e494c0ca9a3	 Laughter	358933	4
1064	470	478	13db4db5-b5ba-4c67-8073-0544dd9cf2eb	Private Laughter	182760	1
1065	471	479	486ceea3-b70a-4c2a-8f75-3ec59f01196e	Teleport	421693	1
1066	472	479	0f61ba1e-e843-42a7-a2fc-593973af0606	Teleport (remix)	0	1
1067	471	479	df1b2962-8f53-4e67-bed4-82d561d56da6	Teleport (Acceleration mix)	310800	2
1068	472	479	bdd166a8-6271-4495-a882-ee1ca9db6bb6	Teleport (Stripped remix)	0	2
1069	471	479	439047c3-57b4-45fd-bdd2-d508613b1334	Sugar Rush (Refined mix)	367506	3
1070	471	479	cb0589b7-cbb6-4352-a46f-6fdcb8f1c2c8	Sugar Rush (Raw Cane mix)	388133	4
1071	473	480	9b716cd8-dbe3-4360-83fb-ac1ae94c72a3	Already Home	210440	1
1072	473	480	f8e872ad-2d58-432a-b6e5-29a8d682755d	Planet	212346	2
1073	473	480	e69765a0-254a-4c0f-bcb2-bf9b60c9ac92	 Underage	254400	3
1074	473	480	bf35c7da-e13f-49da-8ef8-4e5849bf9498	Any Day's Ok	264173	4
1075	473	480	39aef1f9-1a82-4e6d-80ff-b39bb64c20fe	Facing Yourself	260133	5
1076	473	480	8fb1e2a2-ab33-4dd2-8d66-1fd3736715bb	You Don't Feel the Same	265666	6
1077	473	480	b7a613ef-9df1-4d09-b6da-788e11290192	Turn Immortal	226480	7
1078	473	480	0c96c8c7-e925-4ab0-82c3-f5a8707b2991	Am I Going to Heaven	242466	8
1079	473	480	9a9af35b-fdd8-4a61-81e1-b12c4fb8aa60	You Heal	272693	9
1080	473	480	2453efd7-1da9-4557-bdb0-8fa59652c480	Private Encore	331013	10
1081	474	481	b00f64c3-335c-4f85-9911-b902a34d6a83	Teleport	248413	7
1082	475	479	75b6ba9f-168b-4ecb-867b-f9b550bca202	Teleport	367626	6
1083	476	479	b816d91d-668c-46fb-8de8-62def705a5a0	Teleport	425266	7
1084	477	479	8dd8666e-aa25-4d26-af79-f63896be559e	Teleport	420733	2
1085	478	482	be1e7543-1f9a-4208-9aab-7e07de5a1493	Teleport	125133	1
1086	479	479	dadfd521-3428-44e3-b98e-7abf0f9626dc	Teleport	425266	7
1087	480	483	54dff526-91fe-4c2a-9492-62f73bb8c9d4	Teleport	231133	18
1088	481	479	7cea9b35-e531-4152-b740-5f644eca9149	Teleport	420973	6
1089	482	479	e30ecf56-a4e8-471f-8e8e-fc1c89a86792	Teleport	353440	4
1015	442	458	5224aea7-3a8b-4e4d-9a14-4f36a22aed7b	Bad Company	290573	5
1016	443	459	00b70ab6-b4e1-4c62-8862-87bdb01bbfa8	Bad Idea	219360	2
1017	444	460	53f89b14-69eb-4159-978d-76f7cac4f13b	Bad News	191800	4
1018	445	461	f7e75614-f5df-494f-a6f6-3a26fda88675	Bad Time	86266	10
1019	446	460	3fdc3370-0090-4518-af58-3d38a31687bb	Bad News	215853	9
1096	487	487	070c9cec-9d0a-429b-bd34-b3b5c23f7581	Splat	230800	5
1097	488	487	79ca4c1b-0ca3-4043-b0bc-752528585d62	Splat	230000	2
1098	489	488	c4ecb890-cb10-4a72-8f27-02f7075cb043	!Splat!	384480	4
1099	490	488	2f0aab49-4b79-4212-8423-5f9aa29cb938	!Splat!	384866	4
1100	491	487	2bb0dbbe-982b-48d0-8753-d9f8c8286ae9	Splat	229333	3
1101	492	487	66d87bad-ce1c-471e-8a1f-d273735c3985	Splat	230000	3
1102	493	489	94831178-2660-4f5b-8ae3-1a74ba93a9dc	Splat!	539000	8
1103	494	490	3a111f99-0261-4639-9312-994a8eb2898d	Splat	465000	4
1104	495	491	aaa3ff1c-2db8-4bf1-966a-dc3fbeaf9bfd	Splat	309666	6
1105	496	484	f425d73c-4624-479a-8ed1-1d936da8c0d8	E.B.L.	428106	4
1106	497	492	3cb06ab6-7ad1-4954-b7c1-8678627d4320	Splat Mi Splat	273000	6
1107	498	493	b1dca6e8-92c3-4c65-b31e-229a67cc4bb5	Newsbreak/Splat	80493	35
1108	499	494	7caf8cd8-6b3c-4d45-abce-25dc47de99a4	Splitterty Splat	139000	13
1109	500	495	919083ba-107b-4cf8-8fa5-f4e48ba39b48	Splat kat	335920	7
1110	501	496	89530c93-110a-4b02-86e4-ac643b3a8495	Splat Out of Luck	144426	4
1111	502	497	58f1500e-eb3e-4017-8017-87282610ec0f	Jumbo Children Splat Fat	119533	11
1112	503	498	a392ec45-7fce-481d-92b5-9bc4bca0a89b	Fall and Splat - SFX	3826	13
1113	504	499	1f65d613-2b98-4ae1-8ed6-e0f6f3bb5416	Process of Yome Splat	82000	22
1114	505	500	28b2d6f7-8971-4e6e-9d71-23c270517607	Public Menace, Freak, Human Fly	218400	1
1115	506	501	b9ec97f5-38d2-4f42-8879-52a9803735da	Yahoo!	228426	8
1116	507	502	3c54e5b5-5393-4286-aeae-fbcee702a6dc	Yahoo!	106200	15
1117	508	503	afbce25a-495c-40b8-a007-087b93420d12	Yahoo	245466	13
1118	509	504	b078b6bf-9c26-48e4-a3b2-b7ca82c0b8cb	Yahoo	69373	5
1119	510	505	c9055941-6fed-45e6-83e3-4ff3362d3800	Yahoo	262080	14
1120	511	506	78816a14-d7e0-437b-9b3e-75b552dd7026	Yahoo	257279	3
1121	512	505	aeb84d67-573c-42ba-839c-d79bc4410e16	Yahoo	260800	14
1122	513	502	d1b634d0-33cc-4e0c-8b12-406cbd3a3c79	Yahoo	106066	3
1123	514	507	781da2c4-95a9-4c3d-b9eb-b5d260ef90f8	Yahoo	169000	2
1124	515	508	346757b5-dc18-4f17-9019-e250ed64fdf2	Pipe Dreamz (Original Up Your Kilt mix)	251973	7
1125	516	509	c234ddd9-c9e0-4d09-828e-8d6efd40a6e2	Rock and Roll Music	29093	1
1126	516	509	d65ef8d4-9ad5-41e4-960b-08d000794943	The Tasmanian	7026	9
1127	516	509	69fb1929-0f71-4e3d-811f-32675c99489b	Theory of Relativity	74240	11
1128	516	509	2d5f8d30-7638-464a-ac5a-16e67ca40e2f	Young Einstein Pacifist	129600	15
1129	517	509	b35e4194-02bc-4149-bf98-dcc1ea820d60	Awabakelly (feat. Alan Dargin)	78026	4
1130	517	509	b0ebf6f1-3334-4f96-b3ac-76035aea8002	Reckless Angels	39760	9
1131	517	509	7ae7d0be-f8bf-4a8f-901d-167de4b94751	Such Is Life (feat. Victorian Phil. Orchestra)	57000	16
1132	518	510	616a272b-224e-43c6-8ddc-c930ce24406b	Yahoo Cowboy	184000	12
1133	519	511	3abbe9b2-603a-479f-820e-32703c14b6d6	Yahoo City	323600	11
1134	520	512	78879652-3804-4466-a54a-c66b9763ff05	Yahoo Resort	141426	5
1135	521	513	1446e584-3bdb-4c70-bf33-75dc000bf0b3	Yahoo Australia	244493	17
1136	522	511	150d3d20-e8a6-40f3-aea6-64075bef5ae5	Yahoo City	345000	6
1137	523	514	1302542f-b8cf-46aa-b71a-6ee632260c4f	Yahoo Hoez	77000	8
1138	524	511	b93c5738-ce3b-478f-a264-1bd4ead40c6b	Yahoo City	342946	12
1139	516	515	67f9ecdd-6cd2-4fa9-aabe-6c173ef8fdc0	Who Can You Trust?	29760	4
1140	525	516	6cc8813c-72ac-44c5-a14e-d985d051c92d	Second Life	1255000	1
1141	526	517	29678718-749f-4e3f-bfad-ff04b81501fd	Scienz of Life	238000	1
1142	527	518	fcef51c7-2d93-4df5-a26b-f14dda6ee393	Natural Life (radio edit)	230773	1
1143	527	518	28a71f86-d5bb-4e9c-817c-4cb60da92d0c	Natural Life (Good Vibes mix)	375493	3
1144	528	519	15843a70-5805-41f9-885e-ea482654ffa9	Spend My Life With You	332000	12
1145	529	520	a0604209-b660-4ff0-9a8b-e4156931b757	Moment Of My Life	393533	2
1146	530	517	80b81df4-cfc8-4952-96ab-327ecabd2381	Scienz of Life (Metaphysic) (clean)	0	1
1147	530	517	fe9a734f-2fff-49ee-a0db-f4f619c2f5d4	Scienz of Life (Metaphysic) (instrumental)	0	2
1148	526	517	6d5238c0-4e6a-4cd5-ba2a-10b757130676	Scienz of Life (instrumental)	238000	2
1149	527	518	6428c4d1-51e9-49ca-928e-bacfb2c16122	Natural Life (Living Killer Whale mix)	371307	4
1150	531	521	1f00fd50-e942-4dea-b8d5-364a20aec920	My Life	233600	4
1151	532	522	f22ab9e7-eb0f-4daf-a311-e0a2392f7119	Life On Earth	369000	1
1152	532	522	4ddc326f-a2f1-46ec-bc9e-d64fb3cf66b7	Life Turns Fast	297000	4
1153	529	520	cf89fecc-8fea-4bec-8a9c-4b2a54da9e76	Moment Of My Life ( Shep Pettibone Extented Version )	463960	7
1154	531	521	6ff8dd3d-2185-4a2d-8885-68c210cb35d4	Life After Death	154333	6
1155	533	523	bb4682aa-b684-4924-ab42-072e27463f29	Alpha	75066	1
1156	533	523	dcc975f0-6210-4809-bc3e-10371c0beb53	Rock It Right (feat. Skit Slam)	243666	2
1157	533	523	2a37edb1-99db-41d3-93d3-a38b2990f62c	Never Be a Crackhead	229173	3
1158	533	523	c182abf0-70f3-4807-944e-c309d6a73403	Kung Fu	234813	4
1159	533	523	97666d73-7ea3-4b46-98f4-1bfa2f8498f6	Babylonians	178333	5
1160	533	523	ef8b11e9-e38a-46c4-b397-f9c3bb2e938a	Always Living	192493	6
1161	533	523	c985729a-5e53-4d32-b35a-9f0b9c6890c5	Tomorrow	234733	7
1162	533	523	9dc52a04-3f4c-484f-84ac-42d1f51ca282	Moviedrome	394186	8
1163	533	523	de44dd77-b386-4655-a5a1-111f2dc01afe	The Pound for Pound	299306	9
1164	533	523	72bd1a0b-6bcb-43ec-8b7a-4e71582eded6	In Memory	295960	10
1090	483	484	2aa9d6e2-fff0-4619-ad81-86e8a58a607e	Splat Graphix	0	2
1091	484	485	775eb891-926e-47c0-9889-bcbedebef53f	I Love Pressure Washing	379000	1
1092	484	485	049f6fc9-3660-4adf-ba62-5bebf1177cbe	When I Blew Up	314000	2
1093	484	485	c0829193-d06e-4311-83ea-6ae282610e7d	When I Blew Up (Carola Pisaturo remix)	369000	3
1094	485	486	92b26884-f285-445d-97a1-d11fb86db63c	Splat	215528	5
1095	486	487	34bd99f9-ec8c-49bc-8595-a4948f3a01d9	Splat	229866	6
1170	539	529	a29b4198-b245-4ecf-8f7b-689f3c15f0d9	Wir san die Hinichen aus Wien	205000	3
1172	541	528	0a52a88e-1539-4f85-bd04-4fed7a75e9d3	Die Magnus-Glocke	204000	8
1173	542	531	b6cf5ac5-c5ed-420a-981b-79a49dcbb102	Franz (17 Die! Die! Die! Fans Can't Be Wrong)	99320	3
1174	543	532	d8c14521-e614-4464-a7cf-682a9e58ebde	Die Zukunft	215880	12
1175	536	526	aaccb13a-9930-424d-a934-b770523a5114	Hier kommt die Kaltfront	203813	16
1176	544	533	bffc2178-e62f-40f9-b4da-05ff025cd2c4	Die Eine 2005 (Original)	206040	1
1177	545	534	50bf900a-c470-44ef-8370-8b6dd9c6b7b3	Die Zeit ist reif	205920	1
1178	546	535	9e5914b9-821e-4e29-a8bb-702df5a22597	Die Schlumpf-Band	204000	16
1179	540	530	7d1a1ba6-bcea-41fe-8570-1820f457759a	Hermine und die Stars: Kerstin Graf	202000	15
1180	547	536	42a7320b-19b3-4067-bce2-a098fa52d58e	Die da!?! (radio mix)	219333	1
1182	549	526	5d5f09bf-6c35-41ad-b0de-f1aa4af9d46b	Die Interressanten	203906	12
1183	550	530	a0f20bff-cc1d-4db5-b33c-96ec8a8989fd	Die Original Deutschmacher: Einfach (Easy)	206786	11
1181	548	526	1f82d14c-23d5-461c-9c3f-2d1d24dc3fab	Die Interessanten	212160	1
1184	545	534	24b31d8d-0288-47eb-bfa3-15c69f9b2f69	Die Zeit ist reif (unplugged)	204226	2
1185	546	535	2da9b939-ad57-4b70-9d98-c1a931646b1f	Die Sängerin der Schlumpf-Band	205000	18
1186	551	525	a11f0ac0-d0f4-40ef-8a73-17a48177b4b8	Die Karate Schule	21026	2
1187	552	528	c8039cc2-d145-484b-8d1d-75560c95df92	"Fly" - die Fliege	217946	6
1188	553	533	2b1c3f7c-bda8-4265-99a6-4a6594d159c7	Scheiß auf die Hookline (radio mix)	215280	1
1189	554	537	285a8ecd-4fca-4fc3-8a2c-9f64aca1ae20	Die Jungs fürs Grobe	207973	10
1190	555	538	64e6ad7d-b198-48e5-b351-5ca1087a6c67	Turn	264160	1
1191	556	538	d8f64321-17f6-4ff7-8168-c52a9931921f	Turn	0	1
1192	557	539	1e524311-2a8e-4849-8113-a14903d91be3	Turn	197666	1
1193	558	538	18423d11-b572-48b1-9548-ddac4268eaa1	Turn	201626	1
1194	559	540	30e22154-e46d-40b5-92ac-2e8cfbcb95e3	Turn	249040	8
1195	560	541	0d08ce76-35ac-4913-9bbe-02ab8151eb6f	Electrocation of Fire Ants	295906	1
1196	560	541	2c51dafb-82b5-412f-9046-8dda2d680803	Plasmids	82666	2
1197	560	541	2b328902-c82e-48f9-8cdc-98db8fbb0419	Ru Tenone	166226	3
1198	560	541	d1731565-1f2c-487f-88c7-f70b4333a449	United States of Surrealism	82533	4
1199	560	541	eaf08703-b94b-4c84-9a2b-4147af906597	Young Cherry Trees Secured	214906	5
1200	560	541	cd9a25ed-4713-4701-815a-229e879d21f7	Triple Cause of Poetry	226426	6
1201	560	541	7888a7a2-7b06-4e53-92d4-63b4abacbe78	Delimiting	132640	7
1202	560	541	d25357e2-cd98-428b-9023-14b3df181687	Glangorous	61693	8
1203	560	541	a347e6ea-9dac-4357-968e-23d2bb65d59a	Jumbleo Palipsest	185706	9
1204	560	541	fec740a3-728d-4c60-b0e5-f28d8a35eac7	Gimmickry Sensational Hoax	92466	10
1205	560	541	9f264fbb-abbc-415f-bf6d-904240ad2595	Gimmickry Hoax Sensation	211426	11
1206	561	542	73aae10a-67f5-4e20-9cdb-2fc1736a9c76	Whose Turn	168000	11
1207	562	543	d75ce52d-6730-42a7-93f3-b9e8842af807	The Turn	0	1
1208	563	544	1a95944e-2247-42ce-9cf2-f5da528a227b	Turn	199000	1
1209	564	545	3d2361c2-d434-453e-8cba-2a7ba3f4758e	Feel It Turn	182573	3
1210	565	546	544c8649-1a0d-4f7a-8650-ae0d73e59bf0	Turn (full length)	272426	1
1211	566	546	d86f2089-4a9a-42c4-8d87-bb5055d67bcd	Turn (radio edit)	242000	1
1212	567	538	0b0a146c-8621-459a-a4d7-423cba87e39b	Turn (radio edit)	198093	1
1213	568	538	d351f02b-7be9-4e5c-85d1-d54e82bded82	Turn (radio edit)	201960	1
1214	569	547	b9506c0e-63a6-4098-9c6d-f86157f779e7	First Crimes	0	1
1216	571	549	912ecb61-c9b9-4a17-939f-6c586a213ea0	Girlie Pop	126053	10
1217	572	550	c72864c4-8e48-4af6-b62e-c9a8814ea78b	Boze cuvaj Psihomodo pop	169666	15
1215	570	548	87bb463f-ffee-4cc2-8676-1a68778619ad	50 Pop	62933	6
1218	573	551	9a351921-b513-4a44-ba66-866861ecb8cc	Rapid Pop Thrills	0	9
1219	574	552	735e788e-8f05-444e-9c3e-73c4d73e950d	This Is Pop	214586	6
1220	575	553	eecec46e-845b-4f54-a936-5eceab2122bf	Pop Riviera	253000	12
1221	576	554	8e7ea370-7a0d-4cd7-927b-1b1a679c11bd	Pop	0	1
1222	577	555	235a239c-b3c8-4e94-b523-bec7fc07361c	Pop 6 to 7	0	5
1223	578	556	4953267c-a5b7-405d-8454-c2a4ddf88d64	Pop Pop Pop	180360	4
1224	579	557	754c16a9-affc-4d56-b0a4-15b68b7a3fca	Pop	512506	3
1225	580	558	0fd54e5f-4220-4c08-870b-e0e8150b47ab	Pop-Pop (Main version)	195693	1
1226	580	558	f48a99af-69e7-4771-8d68-1b2c3b0f9bb9	Pop-Pop (instrumental)	196160	2
1227	580	558	7e193650-bc7c-4a29-bcce-fa6c7b1c9a71	Pop-Pop (a cappella)	185147	3
1228	581	549	a40af08e-2600-440d-bc93-66d9a4ae1153	Pop Starts	107973	7
1229	582	559	95fa347f-6178-4c1d-a73e-a2698ef88cde	Pop Shuvit	201826	1
1230	583	560	c8702517-2a88-4cc0-aa67-f09b20822a84	Fear of Pop	206266	1
1231	584	549	120159de-348b-4eaf-99c2-c9c334132f8a	Girlie Pop	123026	1
1232	585	561	e694c6bb-051e-4ab9-aebc-f576212c3dcf	Sonhos Pop	206146	2
1233	586	315	41955415-e2cf-4559-856a-42d6cf0ea619	Pop (album version)	240266	1
1235	586	315	faced4cf-d4f1-4dcd-a425-899200c3dd0e	Pop (Terminalhead vocal remix)	322734	4
1236	587	562	12c89305-2944-454e-b74d-f9e84ea64e6e	Attraction Pop	158466	3
1165	534	524	167e0e2e-c86a-4a1c-85f6-dea05277bd4d	Die Trying	201000	11
1237	588	563	ad1d837a-c65b-4d8a-bd8e-0dd12abe4769	Pop Goes the House	375974	10
1238	589	564	706ffa8f-f358-4574-89ef-75ec97b9fb96	Pop Might Eat Itself	0	3
1234	586	315	cefd2472-7fa0-4cd7-82eb-19fb14e78423	Pop (radio version)	178093	2
1166	535	525	ec5d740c-dba2-4b77-b6c4-15d135a208b1	Die Allerschürfste	204600	12
1167	536	526	d9b6ed09-b925-46cb-9e14-894d00709912	Die Interessanten	212400	21
1168	537	527	11cea57c-70b4-4077-99ee-9319da31d55c	Pack die Badehose ein	211386	11
1169	538	528	ad53f6c4-2d90-44d2-bfa5-771e1c9617f7	Die verschwundene Seglerin	202000	11
1244	595	570	0e4eefb6-756c-40d5-b9ef-78c57c36607e	In Memory of Elizabeth Reed	2154226	2
1245	596	571	be1d5a1f-0fda-40aa-af7a-015329adfcb9	Pebbles	2156000	1
1246	597	572	60b14915-ffd5-40cb-b46b-c4d4112c2041	Baraka	2157000	3
1247	598	573	9467a486-55dd-4e41-91a3-e7d3ae107a97	Vitamin M	2154000	1
1248	599	574	dd0f3fa9-424d-4943-953d-1f4d85e78b84	Nonverbal Communication I	2156000	4
1249	600	575	9b713f2c-a474-4e3e-a6a1-3e4f0c27ea5a	Le mur	2154000	1
1250	601	576	f8382f2f-5a71-4c47-9f6f-78dcb9b8a767	Tape 6, Side B	2154000	12
1251	602	577	031e2da2-03e1-428d-97c6-8b4ae0c2f7f5	THE DOCUMENT 091303 KRDLADS	2155000	22
1252	603	316	7414d449-811c-4ef0-92f7-7f84634fa4f3	Right Schuh	2155893	1
1253	604	578	da7764e1-836c-423d-a926-0ecbd8563e8d	Objects Appear	373000	2
1254	605	579	d145e6fb-6485-46d3-b8dd-01a9d342146c	Masssive	213387	6
1255	606	579	c81820f6-b0ea-4197-931d-46614d145640	Oddshot	150000	12
1256	607	580	c83bb6e3-d7c8-46aa-9adb-0c14de5088ef	Objects in the Rear View Mirror May Appear Closer Than They Are	357693	1
1257	608	580	80a8156e-3f34-42ca-9de4-4d6cb20c32ba	Objects in the Rear View Mirror May Appear Closer Than They Are (edit)	356693	1
1258	609	581	aeb93dfc-0600-416d-a589-926b444a604e	Appear	618000	4
1259	610	582	77a0e35f-e68d-4191-9f62-9b2d94e7920d	appear	261000	7
1260	611	583	18281280-d9d5-4ca6-a42a-f2dff613ffa8	私に帰ろう	301000	1
1261	611	583	b4f90861-622c-471a-8070-4a0cd92cd814	I'm gonna make it	263000	2
1262	611	583	ecc8b167-d1bd-41f9-a09d-bcd05950db65	粉雪のプロローグ	262000	3
1263	611	583	eaa6297f-70f7-4642-aac9-3d7cd39c04ca	fairly garden	218000	4
1264	611	583	59152a7d-599a-44ed-b597-da9c7bdeee23	おもちゃ	284000	5
1265	611	583	7c49e0c3-7d89-4b55-ad5f-c0a7b4a7001b	しあわせの向こう側	252000	6
1266	611	583	ab4a69ca-b047-483e-aa86-ec0afe113938	雨	256000	7
1267	611	583	c79d83d4-8e95-446c-a529-77cca2ebbc7d	hurt	290000	8
1268	611	583	436621e3-d438-45a6-b8d3-b13bc9f0f07d	Forever dream	318000	9
1269	611	583	21602029-abb0-43bc-a29b-455ec8fd6798	那由多の夢	438000	10
1270	612	584	8831ee73-624f-4463-b098-b1ebaf93cf9c	As they appear	351400	6
1271	613	585	a0ff9627-9281-4f9e-8828-94becfe41584	Appear and Laugh	302000	14
1272	614	586	402c1df7-b827-44ff-b344-2cba4c4b0393	Monsters Appear!!	6773	29
1273	615	587	8815ab0c-f816-4428-8190-f052285d00e8	Forget to Appear...	244000	9
1274	616	588	9519519f-3b11-4659-a094-b3ab69781147	Yet to Appear	169000	17
1275	617	589	6c8fd6d9-d1b1-477a-960c-f5f8ef1980b1	 Danno	237506	1
1276	617	589	a34fa7e4-4066-4c28-9d82-1d2c19b243d1	Non Stop Girls	161573	2
1277	617	589	d6375443-3f93-4c89-a5a6-2d3103db4c35	Anglo Girl Desire	187706	3
1278	618	590	c40dfc64-ec22-44d5-9a70-00e7848c87d8	Victory	215280	1
1279	619	590	898dd944-8a5f-43ee-9893-41da21cb9587	Victory	215826	1
1280	620	591	81a2c251-686a-4ccd-96ea-8e190c4e02e0	Victory	206000	1
1281	621	592	04dd867c-b8fd-4d29-ac22-d1b9ea34357d	[untitled]	205000	4
1283	621	592	4f55b31f-4d2b-4f57-ae15-a25307926a06	[untitled]	21000	17
1284	622	593	a6f3d5b7-8519-440a-a4d5-819390f54b6c	My Mother's Name Is Victory	231000	9
1282	621	592	a21fa19a-fdc8-4c52-bf1c-bdb15b809410	[untitled]	209000	9
1285	623	594	170005d6-6093-49ce-8c69-6bc7e0b9aefa	Santy Anno	204106	1
1286	623	594	c0f92108-d193-46e1-86ee-dbb347c40b60	Rollin Down to Old Maui	236360	7
1287	623	594	a478d8b5-9133-4f5d-939c-6855603eb2d2	Leaving of Liverpool	212066	11
1288	623	594	0c9d5cfa-52db-4ef2-961b-9b2efdc2e863	Across the Western Ocean	225173	19
1289	624	595	65c16dbc-b389-4847-ac5b-6dea25463480	Victory	263000	2
1290	625	596	3bb9696a-6c86-4015-a6b4-c2e9113e2db6	Victory	288680	12
1291	626	597	bd177d63-5bcb-4346-810d-0d2a0f55429e	Victory	244666	10
1292	627	598	5a459fa9-f594-4757-b508-8c1fb6a45715	Victory	343973	11
1293	628	599	16b7a880-06ae-4ef1-b526-df15559a78ee	Victory	185000	1
1294	629	600	6a43aad2-6bcb-411d-9b35-0922fa05d0d1	Victory	253333	1
1295	630	601	0ddb3f3e-c1a7-47f9-b615-cac7418a2d1b	Victory!	348293	1
1296	631	602	f22e3bfa-ec56-4f35-92f0-dbf0a6dfc10c	Victory	284466	1
1297	632	603	8ca07fbf-042b-4788-8d3e-6462d6593bac	Victory	319000	8
1298	633	604	f1f9b658-1dab-461d-836d-c8a183849326	Victory	247000	1
1299	634	605	0d8f233c-6845-45d3-8f5d-0461cadc1f0b	Victory	271000	11
1300	635	606	a039b97b-5a23-41d3-b43f-d5edb65e976e	Victory or Valhalla	229906	1
1301	636	607	8e6d6fce-69f6-488a-84fe-5ef8c474f34f	Victory Day	211734	16
1302	637	608	888809e0-4956-45ad-8744-9e2b7dd931d3	Am I Mad?	210000	5
1303	638	609	c47241ff-98ec-45dd-babd-3250faab5c44	Worst Best Friend	169600	15
1304	639	610	a0e1c1d0-6267-4fe0-906f-2cc40909f8fe	World in My Eyes (feat. Holestar)	244000	1
1305	640	610	586b238a-5e5a-43c7-828b-77c03e536848	Don't Write Me Off	107466	15
1306	640	610	acaa079c-f329-4df9-9571-c149d6052844	Filter	172626	23
1307	641	610	62dde082-1cc0-4395-a5f4-5db683d1f814	My Sharona (remix)	266000	1
1308	642	611	cef838fa-055e-47b5-9d98-fbea506c041b	Gameover	161000	2
1309	643	612	fd39b3ba-bb13-43e1-81d0-a45919d8fa04	Gameover	252640	7
1310	644	612	38980201-f6c6-4201-b4ff-2a145c3e007b	Gameover	252640	7
1311	645	613	9e771d60-0d59-4b9b-acf4-e12bd8641a4d	Gameover	149334	17
1312	646	613	d97c20a7-d171-4721-9f8c-81cd52ac0849	Gameover	146307	17
1313	647	614	a2022344-f16e-4a77-a622-089a388091c2	Gameover	6853	15
1314	648	615	27a2d715-d8ee-4fdc-9629-ff30b934d7cd	Gameover	0	6
1240	591	566	6417ae40-1c82-4bf5-af63-c4e60e0e6381	Yerida	2156866	1
1241	592	567	a399260c-3005-440f-ae9f-220389dca087	Appalachian Spring	2156000	2
1242	593	568	57a89e61-fda9-4ad9-8229-380bc6eff4f2	And On The Seventh Day Petals Fell In Petaluma	2156666	5
1243	594	569	d947ec56-d9d9-4100-9dc4-52670723f358	Getting Into Action!	2154574	2
1324	658	619	6b597671-6fe5-419d-8316-350b7bf60fc2	怒首領蜂大往生 - GameOver	12000	13
1325	659	625	5788d5cc-b626-46dd-a30a-d5662719a9bd	Don't Fight It Feel It (Gameover's Don't Fight It Steal It mix)	262000	3
1326	660	315	fc9876d3-c9b1-4991-8634-a7b072b7b860	It's Gonna Be Me	190933	16
1327	661	626	88f5b515-dd86-46de-bc82-b5985e7a34fa	Whiketywhack (I Ain't Coming Back)	184653	5
1328	662	627	ecbfb732-89af-4344-907c-a165b2b9b93d	Gonna Make You Sweat	247293	5
1332	663	315	3c942dca-2cf7-43a0-ba8e-826bb544f86f	It's Gonna Be Me (Maurice Joshua remix radio edit)	251107	2
1330	664	315	45a945e1-9398-4e52-b855-ed7107f735e0	Girlfriend (The Neptunes remix) (feat. Nelly)	284666	5
1331	665	315	6b6201d5-1542-459e-9c94-955004094979	This I Promise You	283173	14
1315	649	616	ead2ad02-806f-4f4a-9ef4-e66243757006	Gameover	17000	11
1333	666	628	c447e4bc-93f0-4038-960b-a929b09eadc5	Turn It Up	405373	6
1334	667	629	0eb8495d-fc5e-4c32-8a6e-aea9ce9741cf	She Will Be Loved	243813	3
1335	668	344	5fed24c8-6a5f-4987-9033-1e9519cf99e3	Someone to Call My Lover	272400	5
1336	669	315	e0fe9db5-4b40-420e-811c-eab6eab44bbc	Girlfriend	254133	5
1337	670	630	cfdbb70a-ead8-4c39-ad03-9d43e1cbbde7	All That She Wants	0	5
1338	671	631	bd7df105-be95-4fd7-bc38-5e42dd3cec3f	What? (original 12" edit)	364000	20
1339	672	356	61b98cd0-9b3f-4c3c-88d5-444402d9d10b	Say You'll Be There	237733	5
1340	673	632	6aef4c8c-e270-48a3-bff2-ae9102f8fac1	Ain't It Funny	240373	5
1341	674	633	6b019226-13c6-4862-ad76-e3b882bd7b9f	Dip It Low	194173	5
1342	675	409	7059c8fd-4cae-43f4-a40d-7d3539bdf295	Ch-Check It Out	190733	5
1343	676	344	3ad8adaa-6f9f-4794-af61-35b9b10b2445	Got 'Til It's Gone	219466	5
1344	677	634	0fe2cfc9-59ad-48fa-a16d-160ac77ffdc8	Yo (Excuse Me Miss)	229000	5
1357	683	315	d4783904-c114-4570-a11d-b51c92b30a26	Bye Bye Bye (Sal Dano's Peak Hour dub)	509734	5
1352	682	315	9a822b41-d31c-4669-9d84-3b70b2e8e25b	Bye Bye Bye	202760	1
1316	650	617	19b5b940-eff2-4b2c-b6f4-a3ae089e9a04	Gameover	122000	17
1317	651	618	30d0657b-7176-4693-abc1-526eadf0166c	Public Gameover	242000	2
1318	652	619	9c752495-dab8-4398-9e41-ead2ce96cb87	GameOver! men	4774	41
1319	653	620	db352a3f-1274-48a2-af2d-832a8f5c7dc0	Gameover V.I.P	104120	20
1320	654	621	5215b8b1-e552-4a56-b0ec-da4bd326e69b	End of a Century (Gameover remix)	0	3
1321	655	622	37665711-cbd3-4dff-92c4-4b2d01ec606f	Gameover: Thanks for Playing	149000	10
1322	656	623	85a86a0b-9cfe-452b-96eb-66e541f7e112	Space for Another (Gameover)	0	5
1323	657	624	81e186cd-2243-4da0-b7e9-ff2cf0129568	贄のなれ果て ～GameOver～	11480	11
1345	678	350	8a11f50b-7d42-4317-8555-f5c1278c5576	Could It Be Magic	208333	2
1346	679	350	3c5860fb-e70a-4a16-85fb-18df96a35c6c	Could It Be Magic	213866	2
1347	680	360	66200d37-780c-4191-be75-96804822b5e8	I Believe in You	0	5
1348	681	635	59b03093-2245-4fbc-8595-b6d349b387e0	The Sun Goes Down (Living It Up) (extended version)	366000	19
1353	683	315	348a01d8-d926-4c5c-b8d6-a6ff5c914f04	Bye Bye Bye (Teddy Riley's Funk remix)	293426	1
1349	682	315	a5c479df-a487-4669-af48-0f2a5e25978f	Bye Bye Bye (Instrumental)	203306	2
1350	683	315	3dfe3673-7f81-4cc0-a16e-c1502e9c502c	Bye Bye Bye (Teddy Riley's club mix)	331266	2
1354	684	636	86a3aa69-25e9-4224-80a9-46e21fcd1d5e	New kind of thing	425000	11
1329	663	315	e4877996-43ac-4497-80d4-6e3ecfdf71b9	It's Gonna Be Me (album version)	193893	1
1356	685	637	3252509c-87da-4f7a-a68e-33af3f7d8127	Say Bye Bye	0	2
1358	683	315	90939fd2-db06-4a0a-86d8-f134fa22257d	Bye Bye Bye (Riprock 'n' Alex G club remix radio edit)	296133	3
1360	687	639	c1b4bab5-16ab-4a34-8305-4011a6f83e37	Bye Bye Blackbird, Part 2	410306	5
1359	686	638	b3fa3231-b08e-4294-883a-b2d390d1a520	Bye-Bye (album version)	254866	2
1361	688	640	534b29f2-3630-4ccc-8b2a-781b3a84a96b	 bye	388826	1
1355	684	636	895d7051-5167-43ec-8ae2-d500c32a9931	Making me better	223000	2
1362	689	641	985ac934-3cb3-46ba-956a-0252470a277c	Bye Bye Gridlock Traffic	350893	11
1363	690	642	02515f55-2022-4cf0-b3e9-38dcf7299c28	Bye bye beauté	231640	11
1364	691	643	0a1f73ee-8809-47fd-b4df-82f9406a6973	Rosie / Bye Bye Birdie	218333	11
1365	692	644	41fc6a2e-28e7-4eeb-bedc-d64ab2a577ec	Bye-Bye Blackbird	221000	2
1366	693	645	f425da9b-94c5-4d02-8dca-c11cfe10428b	Bye Bye Baby	206040	2
1367	694	646	bd04f71d-30d3-4a59-ab17-7412ece43d26	Boom Bye Bye (instrumental)	359000	2
1368	695	647	4be7ce73-fb4b-47ec-aea0-43e352c94c6d	Bye Bye Love	239000	2
1369	696	648	0ec2082f-75fc-44fa-8e50-e74144c19c56	Bye Bye Baby	226733	2
1370	697	649	89d5ed20-486b-45b9-aca4-812d1599cdbb	Bye Bye Baby Goodbye	279666	2
1371	698	650	e5716418-21fd-494b-97dc-5bd2bb2e1af6	Bye Bye Love	169533	4
1372	699	651	c98f6d3f-d991-44c5-97ce-a0fae882cb89	Bye Bye Love	140266	1
1373	700	315	b9d679a4-ddbd-4964-aa50-73e14b71fc1e	(God Must Have Spent) A Little More Time on You (remix)	243453	1
1374	700	315	6ae96384-d021-4358-ab98-e199a788b79a	Sailing (live version)	428373	2
1375	701	315	f45cddff-acd7-46a4-ae64-4054d943535f	This I Promise You (Hex Hector club mix)	550040	9
1376	702	315	1ecf8779-5d51-49b0-8131-ba30c1361f00	(God Must Have Spent) A Little More Time on You	280240	5
1377	703	315	a0b14883-8318-4f9f-882b-394917fd1f08	(God Must Have Spent) A Little More Time on You	242106	16
1378	704	315	7c7ce83d-26a6-4ff5-88cb-ff5f200c8d28	God Must Have Spent a Little More Time on You	0	5
1379	705	315	35e2f88b-dc42-406f-baaa-3df42365d0d5	God Must Have Spent a Little More Time on You	244000	5
1380	706	315	e8d3ba7d-2963-4228-a9a3-e74ff458cf41	God Must Have Spent (A Little More Time on You)	244000	5
1381	707	315	c0d8d86d-a687-421f-b94a-036532ffdea7	(God Must Have Spent) A Little More Time on You	284213	2
1351	683	315	72afd253-3397-4675-bf3c-bfd482bd049d	Bye Bye Bye (Riprock 'n' Alex G club remix)	395440	4
1388	710	315	1cf2d29c-53ee-4cba-ac12-5b14a2737e8a	Music of My Heart (feat. Gloria Estefan) (Pablo Flores remix)	263693	11
1389	711	653	22cc5ec2-0149-4896-950e-c0d55460731a	Absolute Reggae Medley (Mixed by Denniz PoP)	405014	17
1390	712	654	98dd5f81-f409-4fab-b755-64a597ebe6a4	Elevator Music 11	368880	11
1391	668	315	41e3fad3-8a2e-4561-8c20-c2df6e380b3e	Pop	174533	2
1392	713	655	00bceef1-ca8f-46f0-8b02-0c58106db1c1	Pop Electronique No. 11	133866	11
1393	714	315	e13eb63f-2ba0-4282-9cb0-76a4113643cf	I Want You Back	203493	1
1394	715	315	7022f4a9-5391-4407-89f2-99a3e62ee6af	I Want You Back (radio edit)	203506	1
1395	715	315	1279ee39-85b7-416c-8b0c-16c08c4a1fce	I Want You Back (long version)	265600	2
1396	715	315	a6d1cbe0-1c9a-4b82-a0a8-6ecaab2f2147	I Want You Back (club version)	326560	3
1397	715	315	f04984d8-38cd-4f4a-85c4-2a7dfb6ecfd1	I Want You Back (Progressive dub mix)	329506	4
1398	716	315	8ed157b7-0577-4967-9936-adf4dfb237b6	I Want You Back (radio edit)	201693	1
1384	701	315	5b6bee05-bce2-4bac-918b-3b2ea966a5f0	I Want You Back (Platinum remix)	269013	10
1399	716	315	80e64a96-943a-464e-a6e8-083901f67639	Everything I Own	235800	2
1400	701	315	abdb2d29-4a26-46ac-8009-5818221a59e7	B remix)	228040	17
1401	717	315	26263bff-f426-41fb-976d-f19efbb11ed4	This I Promise You (Hex Hector Club remix)	551733	2
1413	718	315	b8ee546b-c3b8-4371-aed6-488041c47f12	Yo Te Voy A Amar	267666	13
1403	718	315	aec2ef6c-672b-457e-b17e-06960cc0c214	This I Promise You	285200	6
1404	717	315	ce2ef198-e853-448d-a307-c37cb135abfb	This I Promise You (album version)	284760	1
1405	717	315	de70ba32-e6b3-40fe-9dc5-f6b525412f97	This I Promise You (Hex Hector Radio remix)	238600	3
1427	724	315	6214410c-c148-4e65-98fd-ca21025f1993	No Strings Attached	230133	1
1407	718	315	672b9f77-ecd3-4265-a964-5f5b3e40cf71	I Thought She Knew	201960	12
1387	701	315	4e7b88e5-35ae-41fa-8285-d6113c924e23	Pop (DJ White Mike remix)	209586	14
1402	718	315	66f07e13-9aad-4ca0-b5af-5e395a0ae11f	No Strings Attached	228840	7
801	345	365	e6bef4a6-09f4-4221-a80f-cec8a794eccd	Bus Stop / Electric Slide (Radio)	285360	3
1382	708	315	eaf710f1-8013-4417-a394-be9fafd3da66	(God Must Have Spent) A Little More Time on You	242186	4
1383	709	652	39b093d4-9128-488f-bcad-f0488994f918	God Must Have Spent a Little More Time on You (feat. NSync)	281813	17
1385	701	315	a2bce1d3-9de3-45ce-908b-8b003268e0d5	Pop (Drum Beat remix)	350906	11
1386	701	315	2b519623-3618-4048-b2f1-dc259dc1563d	Pop (Bubbling remix)	175573	16
1408	720	315	54baf4c1-9bbc-4e66-b7d9-992577895961	I'll Never Stop (instrumental)	189640	3
1409	720	315	b29fc48a-baf7-4bb6-804f-fa4a26f771d8	I'll Never Stop (radio edit)	190306	1
1410	720	315	27d181fa-e936-4195-a207-831053d61fff	I'll Never Stop (album version)	209360	2
1411	718	315	d7f4a379-11a9-4878-88f9-411bea3bed84	That's When I'll Stop Loving You	292346	10
1414	718	315	03e1ec9e-7d12-44c3-830f-bdd631fc6cd7	Bye Bye Bye	202786	1
1415	721	657	84aa79d1-be09-4df4-a697-1194e905090c	Bye bye Superman (the sky remix)	392346	3
1416	722	658	233c0c0b-45d0-4911-95ee-43ff9335f75e	Bye Bye Boy (Wise Buddah Club mix)	408533	3
1417	721	657	65f16ee0-51bb-4130-8e4f-e9b1284a59ef	Bye bye Superman (dancefloor killa remix)	388280	1
1418	684	636	d2ac6110-d265-410e-8f25-b80292ec9699	Two Towers	308000	1
1419	684	636	ebcf7bf2-9f6d-4639-8d64-e0283018fd83	Clap it	154000	3
1420	684	636	4820e396-3106-4dff-a7b9-6b1a8b520dff	Hey Sir	276000	4
1421	684	636	075fd4aa-57e9-443f-ada0-e536455e3ce9	Abnomal	207000	5
1422	684	636	9d77cd98-fac6-4439-8270-8440b1f6af01	Fordidance	203000	6
1423	684	636	8eb31875-9358-49b0-b81b-dbb8211a2aa9	Whispering man	241000	7
1424	684	636	dc61b7f5-cb82-41fb-a352-5dd3890ec72f	Rewind (my mind)	206000	8
1425	718	315	fa844934-e783-4d78-9b50-49d2bc5bd357	Digital Get Down	264320	8
1426	723	315	4e04dca4-7c3b-4352-bd7e-76c1f90890a1	No Strings Attached	231760	1
1428	718	315	d0f6da35-48b4-489d-9d19-c0881625e8a6	It's Gonna Be Me	193600	2
1429	718	315	191ef811-05eb-4218-b98e-83063c2d1119	It Makes Me Ill	208026	5
1406	719	656	bfde38a7-dc54-44cd-b3ed-cd9c770864dd	No Strings Attached	1256000	1
1412	718	315	fb467c51-9582-4f9f-b5e7-95c159d6eadf	I'll Be Good For You	236800	11
1171	540	530	69020273-3e67-4211-82c8-374ec03193bb	Die Original Deutschmacher: Vati Kühl	202000	13
1239	590	565	89bd79e9-56cd-4945-a447-25d768bb5378	Pop Rocks and Coke	0	2
672	337	315	709e6196-3e0f-4726-82f1-4c6496a027ca	Sailing	276973	3
664	336	315	9020d8e7-aebd-4ade-95dc-f39649031034	I Want You Back	202106	8
660	336	315	ad843218-b22f-45b6-8664-98c9539dca50	For the Girl Who Has Everything	226200	4
680	337	315	b4b8550f-4ccc-42ad-8410-87cfab8d98f3	More Than a Feeling	222706	11
677	337	315	3ad4f1c0-ca53-4eca-8bad-86edb79a7012	Giddy Up	249666	8
663	336	315	e2cc2bec-29bf-4158-81bf-4e1307b83bbf	I Need Love	194960	7
666	336	315	5a22e684-b543-462c-a177-2235b7a5c36e	I Drive Myself Crazy	239733	10
669	336	315	45a89256-b895-4d07-808b-ac05608429c1	Giddy Up	249960	13
667	336	315	6f462501-111b-4e43-9574-7d12cb14ae5f	Crazy for You	221666	11
659	336	315	144b3f0c-2dae-4a4c-902e-b122346cfb31	Here We Go	215866	3
661	336	315	e77b5548-66d5-42d7-829b-86657a6cb596	God Must Have Spent a Little More Time on You	282960	5
668	336	315	8e3faaa9-e2b9-4c26-9bc8-748fd657bf61	Sailing	277640	12
709	339	315	2724dcfc-3217-448e-9c6f-6a03750079b4	Digital Get Down	261466	8
665	336	315	6d4f2747-2658-482b-ab76-8482b60d3e51	Everything I Own	238693	9
658	336	315	76cce4e7-c9d1-413e-a066-ff08e130dbff	I Just Wanna Be With You	243400	2
681	337	315	52a12817-0dc8-4488-a1df-ec2fd576b017	I Want You Back	264693	12
694	338	315	b6cfb931-fe77-4cc1-8870-89d816b1a5f6	Pop	176160	11
674	337	315	1d660a11-648a-4caf-9735-bfb5b66608c9	Riddle	221133	5
662	336	315	fb5d01e0-2091-4fa0-bd06-20cf0f17134e	You Got It	213640	6
710	339	315	04e1f9a4-0a6b-4a35-874e-9fd8436da7d8	I Will Never Stop	201133	9
707	339	315	9a76541c-6219-4716-aab7-9bbb45c925b6	This I Promise You	284733	6
721	340	315	3c0a5b36-5e34-43b6-aba4-998a6f242a8c	This I Promise You	284760	6
712	339	315	5ad4dffe-f9d1-4705-8c87-a2df3f0b398a	That's When I'll Stop Loving You	291666	11
715	339	315	2935c5a1-41fe-4a1d-96b4-f79f03f34579	I Thought She Knew	201733	14
683	337	315	63e8c7c8-80f3-4b0c-957c-e248542f83b0	Forever Young	247400	14
657	336	315	e8918777-b1ca-499e-b168-3649f0e2ea13	Tearin' Up My Heart	211000	1
670	337	315	65776b8f-21cf-47bb-99e8-3660504b473c	Tearin' Up My Heart	287360	1
671	337	315	681e75eb-efb6-4cc0-816f-73816a354bc9	You Got It	213066	2
673	337	315	ede6e302-5d5e-429b-ac6a-63c573574764	Crazy for You	222000	4
675	337	315	fd6d87c8-c4da-4e65-822d-596a49130066	For the Girl Who Has Everything	231360	6
676	337	315	bfaf96a8-c954-4060-80ce-50c44c0f07b3	I Need Love	194866	7
678	337	315	9ecf0a4c-9b2e-4242-9bd6-255dfbcb2005	Here We Go	216240	9
679	337	315	dfea1c55-805d-4acf-aa44-ad7ce0f16fd3	Best of My Life	286493	10
728	340	315	0c06b996-1890-445a-9561-1dfd37ac5852	I'll Never Stop	206426	13
703	339	315	8e158c90-bc55-4a7e-8999-52d191ffe177	It's Gonna Be Me	192426	2
725	340	315	dc56a3ef-3e3f-4b57-b3f8-a46116b7142f	That's When I'll Stop Loving You	291760	10
713	339	315	c0f3862f-8e07-4d79-b29e-63639a65e556	I'll Be Good For You	235293	12
714	339	315	d3107b60-5c69-4337-a468-6a8f7ed3d553	If I'm Not The One	202106	13
717	340	315	c2580264-8e00-41e4-acf1-aa52a5f5decb	It's Gonna Be Me	192426	2
716	340	315	14f07a28-8c8f-4c2a-8a43-a19e27f40099	Bye Bye Bye	200400	1
722	340	315	a0320f1b-7e5f-41ae-b16e-ff5611b9184b	No Strings Attached	228906	7
723	340	315	ef70aaa1-efe9-4558-ae0c-83727b8dfbbb	Digital Get Down	263200	8
702	339	315	a46bb9f8-1436-4ea7-b3fb-d997ec3f2ad5	Bye Bye Bye	201373	1
708	339	315	5d847153-0b7f-48da-890b-4a122f12d62d	No Strings Attached	228466	7
706	339	315	88428b42-3b55-4b7d-9e54-f41fa063279f	It Makes Me Ill	207893	5
720	340	315	2cc7cb79-22a8-48fe-bd62-6f122ca7b1a2	It Makes Me Ill	207906	5
726	340	315	6a2858ae-030c-4bb9-a60d-027b2976ff77	I'll Be Good for You	236373	11
682	337	315	d9c56e24-d37b-47bc-9d8f-bd5819c80467	Together Again	251840	13
684	338	317	8c3185c1-43ce-466e-814e-4041d4f14107	Du kan gøre hvad du vil	220133	1
685	338	318	ba72eb70-03c0-45bd-ae3c-2b9d5f5f851c	Miss California	206773	2
686	338	319	d7095af3-7e76-4bab-9265-d8a69f6a6e5d	Daddy DJ	222666	3
687	338	320	69bfe9a0-a2c2-40a5-8ab6-49fbcde9edd0	Hjertet ser (feat. Erann DD)	208720	4
688	338	321	3b515287-a569-4a15-bfd6-863b9c65acb7	Samb-Adagio	185586	5
689	338	322	f97f9a4b-8367-4f33-bac9-7a747e8be659	Another Day in Paradise (feat. Ray J)	274053	6
690	338	323	fa799c32-a1e4-4180-becb-cd7c8c69337f	Perfect Gentleman	198133	7
691	338	324	0513f9d3-bffd-4f7d-b3bc-024d92a03367	Come Along	224053	8
692	338	325	36452fbe-4357-4890-9f53-4989c3989c50	Bootylicious	209466	9
693	338	326	ffcdeef9-0826-4ad0-9e8f-7fe001d6c53d	It's Raining Men	226826	10
695	338	327	05d68ab6-7406-40ef-9efe-6108fdf7f8c6	Hey Baby	218066	12
696	338	328	0a583eee-72bd-435c-93ec-9a9836f5f2fd	Romeo	205760	13
697	338	329	210b959e-564d-46b9-9595-ad39813b5239	Uptown Girl	187080	14
698	338	330	7783d48d-414f-4fc3-b4f2-5796a138c56f	Dream On	221186	15
699	338	331	f4767b55-69a3-46e5-ba4c-c360176c26f4	Fiskene I havet	216066	16
700	338	332	dbe0adba-6a99-4fbe-9330-853fbe33bcfc	Lovin' Each Day	213386	17
701	338	333	2d1ebc52-ae17-4b32-83fc-b513c5089285	More Than That	222253	18
704	339	315	1e35ce07-7632-40e9-a2ac-ee6f87e6a314	Space Cowboy (Yippie-Yi-Yay)	263440	3
705	339	315	866c09e7-d5f3-4c32-a029-d56686fc3b54	Just Got Paid	250000	4
711	339	315	efc47178-9652-41f3-949a-9955db026178	Bringin' Da Noise	213240	10
718	340	315	d1ac2dcf-28b5-4bcd-9c7f-959d701f0754	Space Cowboy	263466	3
719	340	315	714b2916-7915-4fee-9e15-a50a96a82cfc	Just Got Paid	250000	4
724	340	315	9b92c3b9-8e0e-47af-a91c-0086ec6d32c1	Bringin' da Noise	212066	9
727	340	315	eb1a198c-10b3-4286-b8ed-e8542e59d9ef	I Thought She Knew	202666	12
729	340	315	99257296-d8f2-4c65-a946-4743a5f42cd4	If Only in Heaven's Eyes	278840	14
753	342	315	62f92d66-ec85-43fc-b633-8d8d7ba0910e	No Strings Attached	228906	7
737	341	315	cbc6d7ca-2c59-450e-881f-00e7c45a28da	No Strings Attached	228640	7
745	341	315	c64591a0-60ae-491a-9266-fae134403c17	Could It Be You	222000	15
733	341	315	a7dd8dbb-5439-443c-9f38-a758bd7dc9c9	Space Cowboy	263400	3
734	341	315	2374bcad-335d-444d-b098-0a760e08f9c4	Just Got Paid	250133	4
757	342	315	7d3acea0-1ce7-4dd5-97d0-359453bbca40	I'll Be Good for You	236373	11
746	341	315	5b59ff98-9683-40c2-a93e-ce024bd43ca6	This Is Where the Party's At	372213	16
755	342	315	819002e9-1fbc-402f-b6e1-b1246c2a2853	Bringin' da Noise	212066	9
747	342	315	d4b4a809-0ec3-404b-b87f-ed117674ba0b	Bye Bye Bye	200400	1
742	341	315	86345be3-79f8-4ddf-9d3f-7f4deaf6a0f3	I'll Be Good for You	235266	12
740	341	315	769f1cdb-8d02-48d6-9153-4357338bf336	Bringin' da Noise	211333	10
758	342	315	cfe6c921-bfa6-47d1-bd32-fab242f9eac5	I Thought She Knew	202333	12
730	340	315	f2a00a4f-dc45-4871-a0d3-f9a0e8a82d32	Could It Be You	219800	15
732	341	315	d979f2c8-90c1-4670-a417-a31eea9b477f	It's Gonna Be Me	192373	2
744	341	315	a5bc287c-d688-44a7-986f-090e653fbb71	I Thought She Knew	202960	14
751	342	315	f2629c73-164d-46a8-9243-b15d25f4da66	It Makes Me Ill	207906	5
731	341	315	64580be4-9eda-4ca1-89b7-3365c43d2122	Bye Bye Bye	200560	1
749	342	315	d8af185e-1a2f-45d1-b5bd-dd73005b3be7	Space Cowboy	263466	3
750	342	315	e6f4ee7d-2141-4896-b708-3438613ec64f	Just Got Paid	250000	4
735	341	315	2c614148-f591-44e5-a314-64ae5549efe5	It Makes Me Ill	207800	5
752	342	315	d2c36a97-6596-439e-9018-3d9ff08278c1	This I Promise You	284760	6
736	341	315	73638768-0b5c-4791-8a4e-5a192217a019	This I Promise You	284760	6
739	341	315	09a9f27b-01c2-44f7-9948-f9378ee60b8f	I'll Never Stop	203000	9
738	341	315	4f361aa3-1339-4bce-a944-dcd55e104b34	Digital Get Down	261333	8
756	342	315	dc1a30d8-dab6-4960-a3ec-a8d85c996f5b	That's When I'll Stop Loving You	291760	10
741	341	315	868fa25c-5348-4161-a812-b316f463a182	That's When I'll Stop Loving You	291760	11
743	341	315	d57ee379-ad62-404c-a36e-3e43945e608e	If I'm Not the One	202106	13
748	342	315	671fbe8f-1b41-48fb-868d-21de0508186c	It's Gonna Be Me	192426	2
763	343	336	e420971d-e576-487d-87bd-13957736933d	I Think I'm in Love With You	216226	5
760	343	334	99d6c5fe-9a66-4a65-a634-f56ef2227c91	Give Me Just One Night (Una Noche)	204333	2
761	343	325	d03d4fe1-d7d2-49d5-ba88-2ea4a11d36cf	Jumpin' Jumpin'	227373	3
762	343	335	485efb74-9534-4573-804c-a01b27a0e141	Don't Think I'm Not	230066	4
788	344	315	84a7c3b4-5c8f-4895-af1c-292bcf80480a	Bye Bye Bye	199666	11
764	343	337	736fc502-7873-4448-ae7f-5af3df13730a	Faded	204666	6
765	343	338	3442b217-01fb-4f38-98f3-decb29763c96	Shake It Fast	254173	7
766	343	339	c190f780-f6e8-47f9-a888-ee74ee466bfe	Case of the Ex	231426	8
767	343	340	c9c2aa11-f9f0-4caf-b413-e0e89019efeb	Aaron's Party (Come Get It)	205533	9
768	343	341	fac15488-7391-496c-b167-8d5de710236b	Lucky	204640	10
769	343	333	ae4cc4b8-4755-4134-b110-4a8d6e831d97	Show Me the Meaning of Being Lonely	233693	11
770	343	342	fcaa5621-bff3-4349-b4e5-7104d97af3d2	Incomplete	232266	12
771	343	343	dffac2bc-2580-4497-9b6c-495c320540f2	I Wanna Be With You	252866	13
772	343	344	d7bbbc25-8764-437e-b2f7-629c86a71980	Doesn't Really Matter	256773	14
773	343	345	1ad2b064-3a1f-4c31-aef0-568d5b1a3d5b	Back Here	217826	15
774	343	346	015ce306-7941-4dec-a56f-fe1ddbcd5f8b	Absolutely (Story of a Girl)	191866	16
775	343	347	c3c264b9-2b4f-4565-946e-504bb48ee930	Kryptonite	233840	17
776	343	348	ab608a3e-66c6-4d22-9f74-947f20aa18ae	Wonderful	272426	18
777	343	349	f68f4f52-4218-457f-9eba-0b56e6d602b8	It's My Life	223600	19
778	344	350	a2f0df72-0611-4cae-97ba-d4630eedcd67	Back for Good	242293	1
779	344	351	878573f5-e191-4e14-9e24-78ae2d7d7532	Especially for You	236773	2
780	344	352	f31f3d58-e71a-44a8-975c-9a816cf6c45f	Stay Another Day	266626	3
781	344	353	227c6350-7d1d-4978-b5b3-1487ed7c67cb	You Got It (The Right Stuff)	249200	4
782	344	354	6a9326d5-8d58-476f-992a-09a15167d26c	Stay	238133	5
783	344	355	3281fc15-b9e6-481c-8c57-0f49a4c692c6	Boombastic	247640	6
784	344	356	3496dc0a-359f-4bf6-8e5c-8fc91e749014	Wannabe	172160	7
785	344	333	1636a361-0364-4a57-b1b8-9bac1f34b086	As Long as You Love Me	211000	8
786	344	357	0440546b-798a-4836-b352-6f2bdcbdfcca	Never Ever	312733	9
787	344	341	cdb9ad5e-7a49-4ae2-9c63-63471bd45ffa	...Baby One More Time	210866	10
754	342	315	eb55ad9e-0070-472c-bb04-a2127b179f27	Digital Get Down	263200	8
789	344	358	fe5b88ec-e46e-4fbd-a6d9-7076e4cb811c	Tragedy	271266	12
790	344	359	33549783-ab46-40e0-8941-c979f9422eeb	Don't Stop Movin'	231426	13
791	344	360	e16b5ed6-6d4f-4aac-851b-b803851ca57d	Can't Get You Out of My Head	230266	14
792	344	361	b35e1bdb-67d3-420c-888d-47772497d71a	Rock DJ	255733	15
793	344	332	deee0d04-5c5a-416e-9559-8e2ade6f1612	Life Is a Rollercoaster	235333	16
794	344	362	2b1e84b6-ef4c-4390-97ca-004c478cb0ba	Just a Little	233866	17
795	344	363	11169207-495b-4899-9642-276d12332c6d	All Rise	224000	18
796	344	364	d509a288-3166-4c0c-abaa-8eabd807fa02	Whole Again	184733	19
797	344	329	cb7a1065-979c-423f-a957-2f3428ae8c37	Flying Without Wings	216400	20
800	345	365	9e6713ed-0f85-4a48-a52f-c3bf3fbca1f2	Cha-Cha Slide (Radio)	226293	1
798	345	365	8be0d36d-a4ce-451c-8bc1-36e5df1af2d0	Cha-Cha Slide (Club)	464506	2
802	345	365	ecd6a8be-a46e-4faa-a3e3-594b83802aa6	Mr. C's Cha-Cha Slide	387506	4
799	345	365	2b4512d7-b5b2-4308-8426-bdca43303700	DJ Eric-B Slide	585226	9
759	343	315	236c4951-f779-4ae1-ab61-741cf0a2133c	It's Gonna Be Me	190826	1
807	349	369	4bfab69f-e9d3-46c2-a55a-0f7cd70a43d5	Slide	261000	1
808	350	370	9777c3e6-da07-4e42-b922-45e54cb952c3	Slide	212866	1
809	351	371	9e82c2b4-d244-4555-8c2e-59f0f6b3eca4	Slide	0	1
820	355	375	e5b362da-fdf4-403a-ba84-68678a4cef9a	That's What Dreams Are For	309306	8
810	352	372	f73b2503-205e-4ede-b9d6-c2186c252320	Closure (Slide's Fat Channel mix)	518000	2
828	361	381	0dacc864-af11-41c5-9d15-4ffc32684d84	Gratuitous Sax	31106	1
827	360	380	c029a1be-7286-4883-9a45-4e3675af9fe1	Sax Maniac	455440	5
813	355	375	e44e6890-58d5-4bad-9fdc-de291940f758	House Of Thunder	276440	1
825	358	378	563cc527-e57a-419f-a52c-916428797d12	Ubuntu	439200	4
824	357	377	697c7578-1f92-4f04-a98e-3e1b9c6cd47e	Sax Pack	218000	2
819	355	375	c981442f-170b-4fdf-8c8d-fe358a1ce997	Live Love Rock	169093	7
818	355	375	44543bbb-1d8d-4955-9912-f5cd96401d56	The Only One	266533	6
815	355	375	df161acb-902b-442d-9aa0-ede7e4a5ed9e	Cold Hearted	265000	3
831	362	382	8ee42e06-a8db-4c9f-bade-f23d3b00a2e7	Rock On	338000	4
821	355	375	c39ca4fa-8b1c-4856-b609-69a3b86fc11b	Ya Do Ya	359426	9
833	362	382	e299d31d-ba7d-4dbc-9ec1-61dbb5e520eb	Banana Oil	320000	6
832	362	382	702fb9d8-cf39-44ab-91d8-47c06ed56250	Melancholy Serenade	390000	5
814	355	375	9ad88603-7b84-4bbc-92e9-fe3d8dc23921	Rosi Lust	248360	2
834	362	382	beb364fc-c91b-439b-bba6-cf27a032787a	That Little Town Rocks	378000	7
835	362	382	ad90af77-5720-4ecb-b992-4fe2392bf37b	Tino's Dream	379000	9
812	354	374	645a6cac-91b6-45e0-9c84-3a7181292ab2	Slide to Slide	260000	3
826	359	379	3a96bb21-cf62-49c6-849c-e99bf8d6b870	Tribal Sax	536734	12
836	362	382	8ab96d1b-8eb2-4532-9664-e78a3355e80e	Have Horn Will Travel	330000	10
816	355	375	58cfcf73-bdc1-4d2d-b4b6-4382c623a958	Come Home	275000	4
837	357	377	ba91209d-6cc6-405d-8b3b-48e3d4ca6125	World Is a Ghetto	328000	4
838	357	377	ade095ff-735a-4532-869b-0de74b5988ac	Tequila	377000	5
830	362	382	edebb9e1-cb03-42d8-bca7-68e1d8eac7d4	For Whom the Horn Honks	364000	3
839	356	376	9c2ace0c-90b5-4a58-bcd8-822a36dff1cd	Crystal Beat	188626	1
829	362	382	9f4ca2b7-22a9-4b36-b14d-c6b5f9e83fe7	DD Rider	402000	2
817	355	375	04f4f00c-57a0-44eb-9427-d6d509e05821	Shout It Out	200973	5
840	356	376	ca6c6b64-4c85-4d80-af70-fbc088e5fcb1	Cuckoo's Egg	230200	2
823	356	376	7096530a-c3ab-46f0-afde-414caef27775	Sax As Sax Can	167467	12
841	356	376	82ebab00-b8ce-4d89-aba5-058a6d08f451	Summertime	221866	3
842	356	376	03f3b518-8b48-4c6f-b36c-0e0a409cf9ed	Orpheo Negro	283666	4
843	356	376	0505a2d6-c961-4487-8a63-079bc2db163a	No Contract	151200	5
844	356	376	5553f7a8-923e-422d-b9f9-bb9a557721cf	First Take	223800	6
845	356	376	2ccbc0bd-8798-43e7-8f33-33a933d6569f	Mental Surf	217640	7
846	356	376	dd281319-7b35-4b43-8328-04d6ddd33dee	Karatschan	215026	8
847	356	376	46f3cade-20f4-4d77-b2a1-4d617ad7d52e	Autumn Leaves	182533	9
848	363	383	2b3b42a3-3ca1-4503-ac0f-d70881eee69b	Gobble, Gobble Song from Xaseni	0	1
849	364	384	dc2d7fc9-fa42-4c8f-975d-88f646dfc27a	Gobble	0	7
850	365	385	fa15903e-3e20-4eea-b40d-93eaa790fc98	Gobble	91426	37
851	366	386	1b863215-602b-42b0-9c09-99a5a60802cc	Gobble	150120	11
852	367	387	d9b908a5-90f1-4001-ab6a-1a9ee6d7e175	Gobble Gobble	16346	68
853	368	388	80160b7a-8a87-4b87-bc3e-622937b628b5	Gobble Gobble	118333	2
854	369	389	75ecf7cf-60de-496e-8b37-abb8981de5aa	Gobble, Gobble Goo	0	36
855	370	390	ce33798d-3361-4a86-9c37-d228df70dcdd	Gibble Gobble	122000	7
856	371	391	b6dfa2c8-3d3c-41ea-87cd-678467222d09	Turkey Gobble	11666	93
857	372	392	1e339a04-14ba-4cfe-967f-e1c4cad4dfa2	Gobble Lockdown	508813	13
858	373	393	5b576b73-0bfe-4db9-8802-3024076a9cab	Sound Clip - gobble, squeek	21960	26
822	355	375	d600259c-7805-4c77-9bc1-914c6bd03ab2	No Matter The Faith	281200	10
859	374	394	0f22e6f2-722d-4ca5-a2df-460f0320fdc5	Gobble D. Gook	57333	1
860	375	395	e5681e53-68e4-41ff-a92e-fd199daec2bc	Gobble Up Your Flesh	129266	11
861	376	396	07b12418-ad81-4a4c-ad09-0196bea8d618	Gobble De Goo	60000	10
862	377	397	51b19295-2c41-4dd7-beb7-a25d11fc13b9	Groovy Feeling (Lolly Gobble Choc Bomb)	414000	3
863	378	398	f0d82c5b-f193-421e-a469-ddd7e345bb34	Goody Gobble (DJ Claudes Original Mix)	327000	6
864	379	395	7cfbc583-7ec4-4b5e-85c0-71347907ab5b	Gobble Up Your Guts, Part 2: Revenge of the Turkey Monster	0	5
865	380	399	40dd862a-2dd8-40cf-94e4-3ecdda092d1c	Twilight	214733	4
866	381	399	0f323349-6125-4c2d-8e89-0056a022503c	Plenty More	207160	12
867	382	400	86730f43-fff7-4f33-a375-6db2b9812ebc	When I Grow Up	206560	3
868	383	401	0706d1e4-cd1b-450b-b9b3-d08a730fbff0	Meet ze Monsta	209266	2
869	384	402	bce4eddc-d4bd-47af-a99e-5ca3bf3ee451	Madness	219746	13
870	385	403	34ad6fa3-58f1-40f5-9227-6c19fa534187	Heart Full of Soul	200400	2
871	385	403	a1ad3516-5bfb-48da-84f5-ce46d9361bc4	Waiting for the Rain to Fall	219533	11
872	386	403	34a90391-4f07-4601-b7a5-9daf95627c65	Two Hearts	214600	4
873	386	403	df0d0593-823c-4fae-9a91-a288af9b3a6f	Can't Do a Thing (To Stop Me)	219573	5
874	386	403	7b7b73ac-e0b3-424d-ac0c-2a926f8a059f	Except the New Girl	201133	6
875	387	403	d78b3113-8ac8-4f61-be00-c69e8399b4bf	Funeral in the Rain	203360	6
876	388	404	5c5c7f8c-711d-4a36-a4e6-32096c9bc999	Without a Prayer	23266	1
877	388	404	75b77b36-c178-4b37-a933-71e98512ac19	On My Hands	212213	3
803	345	365	7728bd32-8885-4f4b-b071-90a0b95397ac	Bus Stop / Electric Slide (Original)	476040	8
804	346	366	7581c53c-5bab-4424-8f81-70fb7e79a883	Slide	141906	5
805	347	367	22502343-8f2a-432c-8693-b2de6bf2b2b0	Slide	262293	1
811	353	373	3e4ce7da-6016-43d3-8f7e-98446ad8d5a5	Slide	182000	1
806	348	368	433e05ce-d9c7-4d2d-b1ad-9342ed45097e	Slide	487120	1
883	391	409	135d6b3d-b238-445a-8000-e80c283aa0e7	Root Down	212000	5
884	392	410	a6d70b40-4a00-4f70-9774-4aebdc94a1ba	Black White	214933	3
885	392	410	d5815574-44fe-45b9-ab29-480b430ef212	Charge	217866	6
886	392	410	1cbff13a-63d7-48d0-b352-15a4575480ef	Operation Eagle Lie	201333	10
887	392	410	8e240b66-b498-40a5-9eef-a5d7f9ad32b5	Raf1	209506	13
888	393	411	38a09bdd-6f38-4e7c-b102-92d2b79ed34d	Hollow as a Bone	208666	6
889	394	412	71f032a7-bd3f-492b-a6d1-b718e30b434a	The Fatal Impact	201893	1
890	395	413	c47fb061-24c5-4edb-8f08-b719d8178166	Reverse	207346	1
892	397	415	a85d153a-8789-4458-b6ed-53ab5c46fc01	Fist City	208533	1
893	397	415	37b98f89-4f54-454e-a02f-d3133eefd48b	Town for Crying	203653	9
891	396	414	c514f716-b81d-4cef-8ac3-7077d7d513c6	Something This Real	204880	9
894	398	416	6bff9711-9301-4a2a-9bca-d1238f49a9d3	Reverse	308800	2
895	399	417	3730d5ee-d7f6-47d6-a6fe-0e9d8e7cb063	Reverse	124093	8
896	400	418	0e21187a-6912-459a-b338-a28dc7eac2f1	Nature in Reverse	215666	1
897	396	414	d9197ae2-1857-4416-a65a-5ff21301b3ee	Something's Gone Terribly Wrong	194040	1
898	396	414	2ae42b47-37d3-4eb2-b44b-8e8e4f1e8486	I Machine	231160	2
899	396	414	686b6447-ce83-465e-945c-94b03f1346b2	Falling Apart	269040	3
900	396	414	5d38c4c8-f722-4e81-ac35-795086dad699	Modesty's Failure	301226	4
901	396	414	9104399d-1796-4f85-8803-433b70df4e65	Sweetest Honey	249626	5
902	396	414	dec23459-559f-4c50-b924-e38fa89daf1d	Go All the Way	274573	6
903	396	414	3d894541-a9d3-4f39-8db6-67c4fc68fd25	They've Taken Me Away	197440	7
904	396	414	ace9cbf7-da7d-49b4-86a1-c12e3dfb3e18	Whittled to an Edge	283093	8
905	396	414	3ed74696-dd51-42f6-8dfc-6037f2fdf811	You	324240	10
906	396	414	9d85036a-dc85-4602-8431-2dba988aa495	Withering (Back Into the Dirt)	222680	11
907	397	415	36709bc8-1c01-460a-8d60-aebe7eddbfb9	Hungry Hungry Hungry	138480	2
908	397	415	52158565-a3d6-45c2-9119-effd4d74115b	Last Cigarette	290173	3
909	397	415	28bd4540-2ad7-4ca5-97c6-88431a7485d7	Married to the Nightlife	162706	4
910	397	415	72d4d520-56fe-431c-af49-ec20ec27ce09	Too Gone for Too Long	171520	5
911	397	415	388356f9-fc43-44b1-9f21-8fa7890de647	No Good Lover	174986	6
912	397	415	3468a110-1737-4c4f-a66c-6fb1df934fae	Wish You the Worst	292173	7
913	397	415	5c1c7eed-ff73-43b3-a0d5-e33080c2401f	I Wonder Why	171173	8
914	397	415	e11ebe04-1ca4-4958-a53e-1d8f5f4638ec	Don't Let the Stars Get in Your Eyes	405546	10
915	401	419	86e0c708-d01c-4f06-8bbc-e5cc3ffe8454	Adventures	291000	1
916	401	419	315b4d75-c5a9-4bad-bc03-aa1a279ab9cb	On the Skyline (feat. Nina Hynes)	231000	2
917	401	419	a05d2057-b67f-4084-9067-085112297eaf	Everything Flows (feat. Paul Channel One)	206000	3
918	401	419	4eedb0e1-cf4a-4a05-8c12-831e3824ce60	Softly	378000	4
919	401	419	59600551-01f4-4258-b8a3-3773fb80df6f	Mushie Shake	256000	5
920	401	419	26064c0a-8c6b-41ab-bd72-578899894dc9	Spanik Sabotage	390000	6
921	401	419	e5ceb7e6-c286-42fe-86f9-ce430d1e636a	Super Noise (feat. White Noise)	157000	7
922	401	419	fa05681b-8efa-4fd6-9920-e5dab28008bb	Son Varios	244000	8
923	401	419	42c588e9-3b1e-422d-bbef-cda8a2c43a9c	Dorothy Goes Home (feat. Nina Hynes)	319000	9
924	401	419	d6459561-6f33-4d63-8fc5-0a691b815202	Favourite Things	282000	10
925	401	419	1daee804-87fd-492c-bbfc-2ae87a8bd9c7	Erosion	262000	11
926	401	419	0f330da7-b034-4dfa-8430-d39b30160b1a	Drone Rock	309000	12
927	401	419	edaeee62-5aed-43be-8e8c-d029623c081b	Propeller	369000	13
928	402	420	5c9fc73a-1e37-4636-b629-15b7501ea02d	Bonus	385000	2
929	403	421	2bea9fa3-4cc2-4c76-b9d7-ebfdd61eaddb	Nada Muda	190000	8
930	404	422	30a94e92-dfc7-4c04-96fb-a29f5200b27b	[untitled]	775000	1
931	404	422	7d3ad972-71e2-4211-ab13-3dcb3aa5e3d2	[untitled]	550000	2
932	404	422	2a9f4194-dddc-48fa-b217-cf967c8319e6	[untitled]	917000	3
933	405	422	508feae5-34ba-46dc-bc40-580e756942b1	[untitled]	134000	1
934	405	422	6a8701f7-0346-4194-b1c1-ace86f5ea90e	[untitled]	952000	2
935	405	422	bd47ef2a-ed89-47c5-81f3-c7c0142f0bde	[untitled]	1065000	3
936	406	423	f626becd-cd27-4346-adc4-459ad1e8419c	Bonus Beat	29440	4
937	407	424	33e407d9-4c6e-4ff6-868b-4b13a5551184	BONUS: nah am feuer	0	15
938	407	424	b8653c15-fc0e-4d82-9f51-ede5346d1b92	BONUS: auch heute noch	0	16
939	407	424	9bb83ab9-a3eb-46bb-84b0-5cdd7887c32a	BONUS: tango amore	0	19
940	408	425	b7dfd5b3-c367-4afd-98e4-5cd702033ee0	Crash and Burn	0	3
941	409	426	a33da637-d208-484a-8c9f-e6eb2c7c97a8	Do The (dance dirty)	177733	1
942	409	426	7cf151f3-88e6-4b24-aec1-4e7327b830c3	Close at Hand	262026	2
943	409	426	ed06305c-bf7f-451e-a193-28dcf34e37fb	Eyes Don't Lie	291066	3
944	409	426	92f711f9-f7c7-4ab5-b98f-7797f281f6b0	Save the World	254400	4
945	409	426	6161e951-836a-4499-9462-7a8dbb5a17c6	Angina	270706	5
946	409	426	a97b9970-d39b-454b-9cf4-c11ce44bf49c	Through the Shadows	194160	6
947	409	426	b705c9dd-b70b-4ff7-9585-ba2f96fe635c	Stranger's Kiss	234906	7
948	409	426	4ccd4004-17c0-4405-8a2c-edf137d2b1d3	Six String and a Highway	211960	8
949	409	426	0f7d7a50-d609-4dfc-b783-3454d3e4d1e5	October, 18	175840	9
950	409	426	726b4a49-4d2a-47c8-b4a9-d14e03f1b3e1	Livin' on Lovin'	252960	10
951	409	426	ed79ca3e-6427-4a90-ac0c-70a9215b0c9c	Rock and Roll	210000	11
952	410	427	597bea8d-e23e-4f01-b727-97a82fd374d6	Crash	216760	1
878	389	405	bca330e9-d829-4a4a-a38d-5d92f5f66ac1	What I Like About You (live)	218000	1
879	389	406	44fc93aa-602e-4d3e-9b40-817fcbd43fb2	Mirror in the Bathroom	200000	3
880	389	407	14705488-8663-4aa0-8808-52fdcc3aa487	Cars (live)	218000	12
881	390	408	acc4d1ff-05ab-4538-8d9f-fd917ec99baa	Les Feuilles mortes	207253	11
882	391	409	11f14f34-999b-4562-a387-49c33408875e	Sabrosa	209533	8
986	423	440	cfb7c406-1ad2-46bc-8e22-ed8ae37c3acb	Rain in Cat Harbor	330880	9
987	423	440	39091767-bcd4-4af7-81d7-514143c51ac0	Sequoia Mist	278107	10
988	430	447	4c39b75e-760c-4b5b-8355-14b6bf89e02a	Circle in the Square	334693	1
989	430	447	5c411e3b-9c84-4776-bff7-30b8f246bebb	You You Monkey	277106	2
990	431	448	6a5b904b-eb2d-41d1-abb1-2c1e0106dba3	Click	363000	1
996	436	453	505445ca-78bd-4597-9ca8-69415e704115	행운 (Good Luck)	252000	2
997	436	453	2d114d68-da4b-487d-bca8-99f2b8470f0a	Dreamming	235000	3
998	436	453	3b4fc026-92e5-4efb-a592-097cddeeb112	잊혀진 사랑	241000	4
999	436	453	7d16ea97-4ee3-4781-93c4-c2f1ae24440b	지금까지만	251000	5
1000	436	453	b4c307f0-5b43-4097-bb3d-04b9a78ae01c	배려	222000	6
1001	436	453	529c1e93-3adc-4ed9-8e69-fd84773af632	Promise	226000	7
1006	436	453	3732845b-aca0-42c3-a4a9-3ad4149e55e4	마지막 선물 (Club Ver.)	185000	12
1007	437	454	49068012-0c5a-4a18-8a3f-2217249664d4	Click's Concert	24000	11
1008	438	455	f14487b0-dded-4f4f-a55e-3c8dd43bde72	Ali Click (album edit)	222306	2
1009	435	452	f37fea79-7534-487d-8a7f-61e5bd481a9e	Double Click (Piano version)	480000	2
1010	439	455	604a928d-db9d-420d-b330-ce50720d56fb	Ali Click (Album mix)	258560	1
1011	440	456	a2603b31-b9a9-4458-bbd5-5e1b37bb21ab	Double Click	385453	1
953	411	428	8513271e-46a6-406e-a7e8-9977a3cc11b6	Crash	234400	3
954	412	429	77e0032d-54d4-4bc5-90b6-115927aa8dae	Crash	201066	1
955	413	430	fc64bda2-c05c-4731-a1ae-d01aa86e3512	Crash	276773	1
957	415	432	0a775e7f-2fe3-44f1-b085-7c8bf970dd8b	CRASH	0	1
958	416	433	c7df1d7a-7dff-4f78-844a-cc64e5075b7e	Crash	0	5
959	417	434	d2343a97-043c-4903-9413-e612421e276e	Crash	329000	1
960	418	435	a68c1c39-2f13-4020-8f4e-8df355770488	Crash	196266	6
961	419	436	ecc56636-340e-4912-89e2-ddfda5262afb	Crash Crash	232000	1
962	420	437	cdc587e9-319a-4cfa-892d-d41200499a31	Crash (instrumental)	186000	2
963	421	438	dae72048-8105-4e59-a894-3d7870c4e59c	Crash (instrumental)	242000	2
964	422	439	f4b790f6-bcb4-4ecc-94c5-326e59670801	Crash! (edit)	0	1
965	423	440	a60ff333-7b34-4294-b977-f925ccd2a14c	Colors of the Land	268746	4
966	424	441	a843d182-baeb-44fe-bebf-48779c47d998	Ocean Land (The Revelation)	285000	3
967	425	442	6b92b67c-26e5-42b5-962e-a36989da6017	Dronning Mauds Land	292960	1
968	426	443	9c1a06b3-e2cd-4190-a8c4-7bb4e8888b89	Caravan	475000	1
969	426	443	35870351-7ff1-4b62-8285-9445b0b23c72	Bustle	320000	2
970	426	443	a4de28df-cab9-455f-8324-5be7fadf6056	Nightnoise	573000	3
971	426	443	65ab0d94-62b2-4d05-8c75-0c4756c2b9b5	Ku	485000	4
972	426	443	1ad21b90-fc2d-48ce-b282-0ca865fc90a5	Shu	441000	5
973	426	443	9e0f430a-5077-4503-bb53-7f5d5e199203	Limba	446000	6
974	426	443	a0b96e2a-dba0-4ffe-971e-d9683c15e6ff	Jacks	439000	7
975	426	443	048f5689-38fc-4163-ac82-52819c969066	India	570000	8
976	427	444	f2c447ab-0fc1-4a1d-9cb1-d8fa2f95059c	The Land of Nod (Sunrise)	0	8
977	428	445	49a2d063-d17f-43e2-9639-b5f2c5de35f3	Land	220786	3
978	429	446	df93c98d-815c-4818-9654-daf59e478560	Land	977000	9
979	423	440	cbdc066f-3474-43e0-8f02-b84a2d36cfa2	Longing for the Green	237426	1
980	423	440	60981620-9fed-485e-835b-d1b7427ffaf1	Wings in the Canyon	258653	2
981	423	440	a53636db-6b3d-4a2c-be7e-c143841ebe8d	Mountain Flight	275453	3
982	423	440	385df4e9-3bdd-4362-98ee-46dd18473994	American Harvest	208653	5
983	423	440	053fb60c-86f5-4a12-bbc2-0b8f11786ee1	Beautiful Morning	284280	6
984	423	440	1e42b405-9e46-4eba-bcb2-ca2421325ff6	Night Ride of the Magi	402586	7
985	423	440	de3fa0ce-df38-4954-9027-43fcc2dd3a3a	Indian Summer	294213	8
991	432	449	3faafee3-9685-4b1e-a4ff-a9709179ca68	Click	316746	3
992	433	450	1ab5039f-5ead-435f-a3b2-7cc76c823b41	Never Click	298306	1
993	434	451	de093cd1-5f65-46e9-83c2-452ef4f8d26a	Click Clack	171333	11
994	435	452	1783b473-91e3-4dee-a739-d86cb545ad32	Double Click	385000	1
995	436	453	7b324384-0cde-4ee0-9215-1424e3a3bf16	One	237000	1
1002	436	453	8585b698-ec9d-4075-8802-f4700fefc37f	You	227000	8
1003	436	453	66f8d2fd-3191-4c74-8782-1e6aaaf5295c	마지막 선물	250000	9
1004	436	453	fa560d7f-5d0b-4c22-9a66-5608ae7a6baf	마치 영화처럼	232000	10
1005	436	453	9b348431-fa81-41e3-93ee-734feb179421	Good bye	251000	11
1012	441	457	6faa7710-4488-43ae-85c5-3047ff260865	Don't Go	238000	1
1013	441	457	4be925a1-0d9c-4c7e-9c20-06b0f8498507	I'm in Trouble	231000	2
1014	441	457	11737c53-b69e-46a1-b862-f79cd8717127	Call Me	225000	3
956	414	431	e3e4c69e-af77-4173-96e2-17745f91bbae	Crash	259000	1
\.


--
-- Name: album_album_mbid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_album_mbid_key UNIQUE (mbid);


--
-- Name: album_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_pkey PRIMARY KEY (album_id);


--
-- Name: artist_artist_mbid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY artist
    ADD CONSTRAINT artist_artist_mbid_key UNIQUE (mbid);


--
-- Name: artist_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY artist
    ADD CONSTRAINT artist_pkey PRIMARY KEY (artist_id);


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
-- Name: possible_match_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY possible_match
    ADD CONSTRAINT possible_match_pkey PRIMARY KEY (file_id, track_id);


--
-- Name: puid_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY puid
    ADD CONSTRAINT puid_pkey PRIMARY KEY (puid_id);


--
-- Name: puid_puid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY puid
    ADD CONSTRAINT puid_puid_key UNIQUE (puid);


--
-- Name: puid_track_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY puid_track
    ADD CONSTRAINT puid_track_pkey PRIMARY KEY (puid_id, track_id);


--
-- Name: setting_class_name_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY setting_class
    ADD CONSTRAINT setting_class_name_key UNIQUE (name);


--
-- Name: setting_class_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY setting_class
    ADD CONSTRAINT setting_class_pkey PRIMARY KEY (setting_class_id);


--
-- Name: setting_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (setting_id);


--
-- Name: setting_setting_class_id_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_setting_class_id_key UNIQUE (setting_class_id, key);


--
-- Name: track_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_pkey PRIMARY KEY (track_id);


--
-- Name: track_track_mbid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_track_mbid_key UNIQUE (mbid);


--
-- Name: album_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: file_puid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_puid_id_fkey FOREIGN KEY (puid_id) REFERENCES puid(puid_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: file_track_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_track_id_fkey FOREIGN KEY (track_id) REFERENCES track(track_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: possible_match_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY possible_match
    ADD CONSTRAINT possible_match_file_id_fkey FOREIGN KEY (file_id) REFERENCES file(file_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: possible_match_track_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY possible_match
    ADD CONSTRAINT possible_match_track_id_fkey FOREIGN KEY (track_id) REFERENCES track(track_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: puid_track_puid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY puid_track
    ADD CONSTRAINT puid_track_puid_id_fkey FOREIGN KEY (puid_id) REFERENCES puid(puid_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: puid_track_track_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY puid_track
    ADD CONSTRAINT puid_track_track_id_fkey FOREIGN KEY (track_id) REFERENCES track(track_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: setting_setting_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_setting_class_id_fkey FOREIGN KEY (setting_class_id) REFERENCES setting_class(setting_class_id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: album; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE album FROM PUBLIC;
REVOKE ALL ON TABLE album FROM canidae;
GRANT ALL ON TABLE album TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE album TO locutus;


--
-- Name: artist; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE artist FROM PUBLIC;
REVOKE ALL ON TABLE artist FROM canidae;
GRANT ALL ON TABLE artist TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE artist TO locutus;


--
-- Name: file; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE file FROM PUBLIC;
REVOKE ALL ON TABLE file FROM canidae;
GRANT ALL ON TABLE file TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE file TO locutus;


--
-- Name: possible_match; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE possible_match FROM PUBLIC;
REVOKE ALL ON TABLE possible_match FROM canidae;
GRANT ALL ON TABLE possible_match TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE possible_match TO locutus;


--
-- Name: puid; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE puid FROM PUBLIC;
REVOKE ALL ON TABLE puid FROM canidae;
GRANT ALL ON TABLE puid TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE puid TO locutus;


--
-- Name: puid_track; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE puid_track FROM PUBLIC;
REVOKE ALL ON TABLE puid_track FROM canidae;
GRANT ALL ON TABLE puid_track TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE puid_track TO locutus;


--
-- Name: setting; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE setting FROM PUBLIC;
REVOKE ALL ON TABLE setting FROM canidae;
GRANT ALL ON TABLE setting TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE setting TO locutus;


--
-- Name: setting_class; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE setting_class FROM PUBLIC;
REVOKE ALL ON TABLE setting_class FROM canidae;
GRANT ALL ON TABLE setting_class TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE setting_class TO locutus;


--
-- Name: track; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE track FROM PUBLIC;
REVOKE ALL ON TABLE track FROM canidae;
GRANT ALL ON TABLE track TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE track TO locutus;


--
-- Name: v_file_lookup; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE v_file_lookup FROM PUBLIC;
REVOKE ALL ON TABLE v_file_lookup FROM canidae;
GRANT ALL ON TABLE v_file_lookup TO canidae;
GRANT SELECT ON TABLE v_file_lookup TO locutus;


--
-- Name: album_album_id_seq; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON SEQUENCE album_album_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE album_album_id_seq FROM canidae;
GRANT ALL ON SEQUENCE album_album_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE album_album_id_seq TO locutus;


--
-- Name: artist_artist_id_seq; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON SEQUENCE artist_artist_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE artist_artist_id_seq FROM canidae;
GRANT ALL ON SEQUENCE artist_artist_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE artist_artist_id_seq TO locutus;


--
-- Name: file_file_id_seq; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON SEQUENCE file_file_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE file_file_id_seq FROM canidae;
GRANT ALL ON SEQUENCE file_file_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE file_file_id_seq TO locutus;


--
-- Name: puid_puid_id_seq; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON SEQUENCE puid_puid_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE puid_puid_id_seq FROM canidae;
GRANT ALL ON SEQUENCE puid_puid_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE puid_puid_id_seq TO locutus;


--
-- Name: setting_class_setting_class_id_seq; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON SEQUENCE setting_class_setting_class_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE setting_class_setting_class_id_seq FROM canidae;
GRANT ALL ON SEQUENCE setting_class_setting_class_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE setting_class_setting_class_id_seq TO locutus;


--
-- Name: setting_setting_id_seq; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON SEQUENCE setting_setting_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE setting_setting_id_seq FROM canidae;
GRANT ALL ON SEQUENCE setting_setting_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE setting_setting_id_seq TO locutus;


--
-- Name: track_track_id_seq; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON SEQUENCE track_track_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE track_track_id_seq FROM canidae;
GRANT ALL ON SEQUENCE track_track_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE track_track_id_seq TO locutus;


--
-- PostgreSQL database dump complete
--

