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
    type character varying NOT NULL,
    title character varying NOT NULL,
    released date,
    custom_artist_sortname character varying,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.album OWNER TO canidae;

--
-- Name: artist; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE artist (
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    name character varying NOT NULL,
    sortname character varying NOT NULL
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
    released character varying NOT NULL
);


ALTER TABLE public.file OWNER TO canidae;

--
-- Name: metadata_match; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE metadata_match (
    metadata_match_id integer NOT NULL,
    file_id integer NOT NULL,
    metatrack_id integer NOT NULL,
    score double precision NOT NULL
);


ALTER TABLE public.metadata_match OWNER TO canidae;

--
-- Name: metatrack; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE metatrack (
    metatrack_id integer NOT NULL,
    track_mbid character(36) NOT NULL,
    track_title character varying NOT NULL,
    duration integer DEFAULT 0 NOT NULL,
    tracknumber integer NOT NULL,
    artist_mbid character(36) NOT NULL,
    artist_name character varying NOT NULL,
    album_mbid character(36) NOT NULL,
    album_title character varying NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.metatrack OWNER TO canidae;

--
-- Name: puid; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE puid (
    puid_id integer NOT NULL,
    puid character(36) NOT NULL
);


ALTER TABLE public.puid OWNER TO canidae;

--
-- Name: puid_metatrack; Type: TABLE; Schema: public; Owner: canidae; Tablespace: 
--

CREATE TABLE puid_metatrack (
    puid_id integer NOT NULL,
    metatrack_id integer NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.puid_metatrack OWNER TO canidae;

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
    duration integer DEFAULT 0 NOT NULL,
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
    SELECT f.filename, f.duration, f.channels, f.bitrate, f.samplerate, p.puid, f.album, f.albumartist, f.albumartistsort, f.artist, f.artistsort, f.musicbrainz_albumartistid, f.musicbrainz_albumid, f.musicbrainz_artistid, f.musicbrainz_trackid, f.title, f.tracknumber, f.released AS year FROM (file f LEFT JOIN puid p ON ((f.puid_id = p.puid_id)));


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

SELECT pg_catalog.setval('album_album_id_seq', 1461, true);


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

SELECT pg_catalog.setval('artist_artist_id_seq', 1357, true);


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

SELECT pg_catalog.setval('file_file_id_seq', 222, true);


--
-- Name: metadata_match2_metadata_match_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE metadata_match2_metadata_match_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.metadata_match2_metadata_match_id_seq OWNER TO canidae;

--
-- Name: metadata_match2_metadata_match_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE metadata_match2_metadata_match_id_seq OWNED BY metadata_match.metadata_match_id;


--
-- Name: metadata_match2_metadata_match_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('metadata_match2_metadata_match_id_seq', 1, false);


--
-- Name: metatrack_metatrack_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE metatrack_metatrack_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.metatrack_metatrack_id_seq OWNER TO canidae;

--
-- Name: metatrack_metatrack_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: canidae
--

ALTER SEQUENCE metatrack_metatrack_id_seq OWNED BY metatrack.metatrack_id;


--
-- Name: metatrack_metatrack_id_seq; Type: SEQUENCE SET; Schema: public; Owner: canidae
--

SELECT pg_catalog.setval('metatrack_metatrack_id_seq', 1355, true);


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

SELECT pg_catalog.setval('setting_class_setting_class_id_seq', 4, true);


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

SELECT pg_catalog.setval('setting_setting_id_seq', 21, true);


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

SELECT pg_catalog.setval('track_track_id_seq', 8089, true);


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
-- Name: metadata_match_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE metadata_match ALTER COLUMN metadata_match_id SET DEFAULT nextval('metadata_match2_metadata_match_id_seq'::regclass);


--
-- Name: metatrack_id; Type: DEFAULT; Schema: public; Owner: canidae
--

ALTER TABLE metatrack ALTER COLUMN metatrack_id SET DEFAULT nextval('metatrack_metatrack_id_seq'::regclass);


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

COPY album (album_id, artist_id, mbid, type, title, released, custom_artist_sortname, last_updated) FROM stdin;
1450	1290	711633d2-5ccc-44e1-9d32-4b401bca2716	Album Official	*NSYNC	1998-03-24	\N	2008-06-05 22:35:11.252584
1451	1290	f6010e25-d302-4848-9b07-53f715c363bb	Album Official	*NSync	1998-03-24	\N	2008-06-05 22:35:17.419071
1452	1291	79024eb2-513b-484b-9301-bb3884cd047d	Compilation Official	Absolute Music 27	\N	\N	2008-06-05 22:35:21.164659
1453	1290	5f68e32a-ccc1-4b01-a4de-daa880bf3864	Album 	No Strings Attached	2001-01-01	\N	2008-06-05 22:35:25.931546
1454	1290	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	Album 	No Strings Attached	\N	\N	2008-06-05 22:35:27.802931
1455	1290	631c7d7a-fca8-4891-bf02-47462cff37a5	Album Official	No Strings Attached	\N	\N	2008-06-05 22:35:29.560375
1456	1290	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	Album Official	No Strings Attached	2000-03-21	\N	2008-06-05 22:35:32.566938
1457	1290	ae94ea26-b263-407d-a9f9-bfeec05111c8	Album 	No Strings Attached	\N	\N	2008-06-05 22:35:34.075121
1458	1290	65fb1b24-f321-4d6b-aaa5-0fd66d311c15	Compilation Official	Greatest Hits	2005-10-25	\N	2008-06-05 22:35:40.734067
1459	1291	f42748d4-8908-4b1d-81b0-4ad918d40d7e	Compilation Promotion	Promo Only: Mainstream Radio, February 2000	\N	\N	2008-06-05 22:35:42.508567
1460	1291	70666922-6d32-41fc-b208-0b91c42c35a1	Compilation Official	Now That's What I Call Music! 5	2000-11-14	\N	2008-06-05 22:35:52.745397
1461	1291	130dde16-0fee-428f-820e-7ce449ed50e1	Compilation Official	Smash Hits: The Reunion (disc 2)	2003-01-01	\N	2008-06-05 22:36:01.116361
\.


--
-- Data for Name: artist; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY artist (artist_id, mbid, name, sortname) FROM stdin;
1325	a0b8cb9e-7532-45fe-a74c-30e7c4009a39	Missy Elliott	Elliott, Missy
1326	813f5946-ed57-4169-9449-e0de0ce0b22b	Bob Marley vs. Funkstar De Luxe	Marley, Bob vs. Funkstar De Luxe
1343	24d2505b-388c-46cc-8a64-48223ea6d78d	Take That	Take That
1327	177fde26-5a95-46d9-922f-0933940d97e5	98 Degrees	98 Degrees
1300	a796b92e-c137-4895-9c89-10f900617a4f	Destiny's Child	Destiny's Child
1328	888f7e18-2a96-4f2e-8320-08ff4330b442	Kandi	Kandi
1329	fe37acd4-893c-4b2c-8ad2-7fd394280354	Jessica Simpson	Simpson, Jessica
1330	e01482f5-8865-4d25-b2f5-0ebfdf53d96c	soulDecision	soulDecision
1331	1cfe52d7-181a-4b3a-8041-d8bf9ccef57b	Mystikal	Mystikal
1332	7c5e39c3-7645-4e37-968d-a4e45cd38c5d	Mýa	Mýa
1333	4c0bb5bc-95ad-47de-99e3-fbb4fbc5f393	Aaron Carter	Carter, Aaron
1353	2fddb92d-24b2-46a5-bf28-3aed46f4684c	Kylie Minogue	Minogue, Kylie
1335	25e0497c-faa4-4765-b232-baa20e5e35a7	Sisqó	Sisqó
1344	9bd94498-68cc-4b1e-b9cf-b3ba95cffccf	 Jason Donovan	 Donovan, Jason
1309	25607613-aceb-445a-8519-83a2ee0f8402	Marc Anthony	Anthony, Marc
1310	3af5bf95-b4ea-4b21-b40d-2b9bdab1c2f0	Hoku	Hoku
1311	ad0ecd8b-805e-406e-82cb-5b00c3a3a29e	Kid Rock	Kid Rock
1312	f0602f55-1770-483d-89bd-4bae0d0ac086	Jennifer Lopez	Lopez, Jennifer
1313	d2101821-81ce-4137-bd14-7ed09ecf5531	Alabama 3	Alabama 3
1314	5bae7081-64ef-4473-825a-38d310deb14c	Will Smith	Smith, Will
1315	365b873d-1eed-4a9f-9a15-442f8306679a	Pheonix Stone	Pheonix Stone
1316	8bfac288-ccc5-448d-9573-c33ea2aa5c30	Red Hot Chili Peppers	Red Hot Chili Peppers
1292	2b353828-6748-4ba4-bddd-493d728372c5	Christian	Christian
1293	7d48da7e-5eee-45df-8e89-dfaee2af82c4	Dante Thomas	Thomas, Dante
1294	8a44a6c6-a5ef-4e36-8ce0-3fd1d762e563	Daddy DJ	Daddy DJ
1295	f42fa1c3-7e90-402b-9930-3a5eccceecb7	Karen Busck	Busck, Karen
1296	2d6a30a0-3925-4fad-84ed-a568872b081c	Safri Duo	Safri Duo
1297	01e60eba-52df-4694-8f09-39f43abe54e9	Brandy	Brandy
1298	4f29ecd7-21a5-4c03-b9ba-d0cfe9488f8c	Wyclef Jean	Jean, Wyclef
1299	1b4bee4d-3239-4a65-8239-b62b43c23f48	Titiyo	Titiyo
1336	9dc9f4b0-a7b4-43c5-8f6b-fcd43c426a4b	Mandy Moore	Moore, Mandy
1301	23207c32-6743-4982-9f46-e297b2e4eb14	Geri Halliwell	Halliwell, Geri
1302	8d6a4455-1ae8-4e51-a481-08a85cb0141a	DJ Ötzi	Ötzi, DJ
1303	28cbf94d-0700-4095-a188-37e373b069a7	Basement Jaxx	Basement Jaxx
1305	8538e728-ca0b-4321-b7e5-cff6565dd4c0	Depeche Mode	Depeche Mode
1306	1ec4c3eb-dfab-49cd-86bf-1fea72f653b7	Blå Øjne	Blå Øjne
1317	1129817c-488a-4096-80c1-77fc1b107c93	Tracy Chapman	Chapman, Tracy
1318	cc1f4763-a306-4ae7-8ba7-331872199f9e	Montell Jordan	Jordan, Montell
1319	4c3b1829-f080-4e4d-ac5d-57413bb7b85c	Trian	Trian
1320	0068dd30-5ef0-43f5-bc9c-5030242a552f	Jessica Riddle	Riddle, Jessica
1321	116ac760-e32e-4329-b849-71ec179e56d6	Mytown	Mytown
1322	bd1180c4-4252-461f-94dc-543906c02522	Mr. Big	Mr. Big
1323	b3ae82c2-e60b-4551-a76d-6620f1b456aa	Melissa Etheridge	Etheridge, Melissa
1324	b2dbfc09-b332-408b-a235-1850e41971c5	Bloodhound Gang	Bloodhound Gang
1337	6be2828f-6c0d-4059-99d4-fa18acf1a296	Janet Jackson	Jackson, Janet
1338	0662fa9d-73b0-4f71-9576-c963a5a14f66	BBMak	BBMak
1339	c30dfb44-768a-487b-af9c-c942682aa023	Nine Days	Nine Days
1340	2386cd66-e923-4e8e-bf14-2eebe2e9b973	3 Doors Down	3 Doors Down
1341	3604c99d-c146-4276-aa0c-9376d333aeb8	Everclear	Everclear
1342	5dcdb5eb-cb72-4e6e-9e63-b7bace604965	Bon Jovi	Bon Jovi
1291	89ad4ac3-39f7-470e-963a-56509c546377	Various Artists	Various Artists
1345	ee20d564-25ca-4ef5-aba7-93a39f78ed60	East 17	East 17
1346	090dafe5-818c-4bba-9ebf-7e3a651a5c43	New Kids on the Block	New Kids on the Block
1347	7343056e-041e-4b28-a85a-58e8fb975136	Eternal	Eternal
1348	fc63d806-ca89-4ea3-a404-ee6de695743f	Shaggy	Shaggy
1349	bf0caafc-2b20-4e07-ab85-87e14ff430ce	Spice Girls	Spice Girls
1308	2f569e60-0a1b-4fb9-95a4-3dc1525d1aad	Backstreet Boys	Backstreet Boys
1350	a371601f-c184-4683-806d-2eb35e88f0d7	All Saints	All Saints
1334	45a663b5-b1cb-4a91-bff6-2bef7bbfdd76	Britney Spears	Spears, Britney
1290	603ba565-3967-4be1-931e-9cb945394e86	*NSync	NSYNC
1351	19659aa7-cd3a-4bfe-bca0-6943e9e5c6e0	Steps	Steps
1352	bd5cf3e9-cb6c-41f3-8c7d-e9bda3c4e721	S Club 7	S Club 7
1354	db4624cf-0e44-481e-a9dc-2142b833ec2f	Robbie Williams	Williams, Robbie
1307	f1cd545b-f17b-4d3a-98de-68b695bfe211	Ronan Keating	Keating, Ronan
1355	02db9e84-a750-4d22-b5b1-c769e698dc6c	Liberty X	Liberty X
1356	9c79224c-70cd-4367-8d90-35ca99401b75	Blue	Blue
1357	6fda00c2-449a-4bf4-838f-038d41a07c73	Atomic Kitten	Atomic Kitten
1304	5f000e69-3cfd-4871-8f1b-faa7f0d4bcbc	Westlife	Westlife
\.


--
-- Data for Name: file; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY file (file_id, track_id, filename, last_updated, duration, channels, bitrate, samplerate, puid_id, album, albumartist, albumartistsort, artist, artistsort, musicbrainz_albumartistid, musicbrainz_albumid, musicbrainz_artistid, musicbrainz_trackid, title, tracknumber, released) FROM stdin;
186	\N	/media/music/sortert/slide.ogg	2008-05-21 23:04:03.739594	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
187	\N	/media/music/sortert/ubuntu Sax.ogg	2008-05-21 23:04:03.852752	25000	2	160	44100	\N						                                    	                                    	                                    	                                    			
188	\N	/media/music/sortert/Now That's What I Call Music! 5 - 01 - *NSync - It's Gonna Be Me.mp3	2008-05-21 23:04:04.370861	192000	2	192	44100	\N	Now That's What I Call Music! 5		Various Artists	*NSync	NSYNC	89ad4ac3-39f7-470e-963a-56509c546377	70666922-6d32-41fc-b208-0b91c42c35a1	603ba565-3967-4be1-931e-9cb945394e86	236c4951-f779-4ae1-ab61-741cf0a2133c	It's Gonna Be Me	1	
189	\N	/media/music/sortert/gobble.ogg	2008-05-21 23:04:04.439358	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
190	\N	/media/music/sortert/flip-piece.ogg	2008-05-21 23:04:04.471706	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
191	\N	/media/music/sortert/gnometris.ogg	2008-05-21 23:04:04.499337	1000	1	80	44100	\N						                                    	                                    	                                    	                                    			
192	\N	/media/music/sortert/Smash Hits: The Reunion (disc 2) - 11 - *NSync - Bye Bye Bye.mp3	2008-05-21 23:04:04.560761	199000	2	160	44100	\N	Smash Hits: The Reunion (disc 2)		Various Artists	*NSync	NSYNC	89ad4ac3-39f7-470e-963a-56509c546377	130dde16-0fee-428f-820e-7ce449ed50e1	603ba565-3967-4be1-931e-9cb945394e86	84a7c3b4-5c8f-4895-af1c-292bcf80480a	Bye Bye Bye	11	
193	\N	/media/music/sortert/reverse.ogg	2008-05-21 23:04:04.598274	1000	1	22	8000	\N						                                    	                                    	                                    	                                    			
194	\N	/media/music/sortert/*NSYNC - 05 - *NSync - God Must Have Spent a Little More Time on You.mp3	2008-05-21 23:04:04.6795	285000	2	128	44100	\N	*NSYNC		NSYNC	*NSync	NSYNC	603ba565-3967-4be1-931e-9cb945394e86	711633d2-5ccc-44e1-9d32-4b401bca2716	603ba565-3967-4be1-931e-9cb945394e86	e77b5548-66d5-42d7-829b-86657a6cb596	God Must Have Spent a Little More Time on You	5	
195	\N	/media/music/sortert/bonus.ogg	2008-05-21 23:04:04.711206	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
196	\N	/media/music/sortert/Absolute Music 27 - 11 - *NSync - Pop.mp3	2008-05-21 23:04:04.764153	176000	2	128	44100	\N	Absolute Music 27		Various Artists	*NSync	NSYNC	89ad4ac3-39f7-470e-963a-56509c546377	79024eb2-513b-484b-9301-bb3884cd047d	603ba565-3967-4be1-931e-9cb945394e86	b6cfb931-fe77-4cc1-8870-89d816b1a5f6	Pop	11	
197	\N	/media/music/sortert/*NSYNC - 08 - *NSync - I Want You Back.mp3	2008-05-21 23:04:04.819915	203000	2	128	44100	\N	*NSYNC		NSYNC	*NSync	NSYNC	603ba565-3967-4be1-931e-9cb945394e86	711633d2-5ccc-44e1-9d32-4b401bca2716	603ba565-3967-4be1-931e-9cb945394e86	9020d8e7-aebd-4ade-95dc-f39649031034	I Want You Back	8	
198	\N	/media/music/sortert/crash.ogg	2008-05-21 23:04:04.84799	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
199	\N	/media/music/sortert/No Strings Attached - 06 - *NSync - This I Promise You.mp3	2008-05-21 23:04:04.90595	285000	2	128	44100	\N	No Strings Attached		NSYNC	*NSync	NSYNC	603ba565-3967-4be1-931e-9cb945394e86	5f68e32a-ccc1-4b01-a4de-daa880bf3864	603ba565-3967-4be1-931e-9cb945394e86	9a76541c-6219-4716-aab7-9bbb45c925b6	This I Promise You	6	
200	\N	/media/music/sortert/land.ogg	2008-05-21 23:04:04.933898	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
201	\N	/media/music/sortert/click.ogg	2008-05-21 23:04:04.956726	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
202	\N	/media/music/sortert/bad.ogg	2008-05-21 23:04:04.98073	0	1	29	11025	\N						                                    	                                    	                                    	                                    			
203	\N	/media/music/sortert/*NSync - 14 - *NSync - Forever Young.mp3	2008-05-21 23:04:05.04301	244000	2	128	44100	\N	*NSync		NSYNC	*NSync	NSYNC	603ba565-3967-4be1-931e-9cb945394e86	f6010e25-d302-4848-9b07-53f715c363bb	603ba565-3967-4be1-931e-9cb945394e86	63e8c7c8-80f3-4b0c-957c-e248542f83b0	Forever Young	14	
204	\N	/media/music/sortert/laughter.ogg	2008-05-21 23:04:05.083335	2000	1	22	8000	\N						                                    	                                    	                                    	                                    			
205	\N	/media/music/sortert/teleport.ogg	2008-05-21 23:04:05.109255	0	1	29	11025	\N						                                    	                                    	                                    	                                    			
206	\N	/media/music/sortert/splat.ogg	2008-05-21 23:04:05.134243	0	1	29	11025	\N						                                    	                                    	                                    	                                    			
207	\N	/media/music/sortert/yahoo.ogg	2008-05-21 23:04:05.161345	0	1	29	11025	\N						                                    	                                    	                                    	                                    			
208	\N	/media/music/sortert/lines3.ogg	2008-05-21 23:04:05.187111	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
209	\N	/media/music/sortert/No Strings Attached - 13 - *NSync - I'll Never Stop.mp3	2008-05-21 23:04:05.241457	206000	2	192	44100	\N	No Strings Attached		NSYNC	*NSync	NSYNC	603ba565-3967-4be1-931e-9cb945394e86	631c7d7a-fca8-4891-bf02-47462cff37a5	603ba565-3967-4be1-931e-9cb945394e86	0c06b996-1890-445a-9561-1dfd37ac5852	I'll Never Stop	13	
210	\N	/media/music/sortert/No Strings Attached - 01 - *NSync - Bye Bye Bye.mp3	2008-05-21 23:04:05.288943	201000	2	128	44100	\N	No Strings Attached		NSYNC	*NSync	NSYNC	603ba565-3967-4be1-931e-9cb945394e86	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	603ba565-3967-4be1-931e-9cb945394e86	64580be4-9eda-4ca1-89b7-3365c43d2122	Bye Bye Bye	1	
211	\N	/media/music/sortert/life.ogg	2008-05-21 23:04:05.315958	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
212	\N	/media/music/sortert/lines1.ogg	2008-05-21 23:04:05.340882	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
213	\N	/media/music/sortert/No Strings Attached - 08 - *NSync - Digital Get Down.mp3	2008-05-21 23:04:05.395098	265000	2	128	44100	\N	No Strings Attached		NSYNC	*NSync	NSYNC	603ba565-3967-4be1-931e-9cb945394e86	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	603ba565-3967-4be1-931e-9cb945394e86	eb55ad9e-0070-472c-bb04-a2127b179f27	Digital Get Down	8	
214	\N	/media/music/sortert/die.ogg	2008-05-21 23:04:05.424466	1000	1	29	11025	\N						                                    	                                    	                                    	                                    			
215	\N	/media/music/sortert/No Strings Attached - 02 - *NSync - It's Gonna Be Me.mp3	2008-05-21 23:04:05.479267	192000	2	192	44100	\N	No Strings Attached		NSYNC	*NSync	NSYNC	603ba565-3967-4be1-931e-9cb945394e86	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	603ba565-3967-4be1-931e-9cb945394e86	671fbe8f-1b41-48fb-868d-21de0508186c	It's Gonna Be Me	2	
216	\N	/media/music/sortert/turn.ogg	2008-05-21 23:04:05.50935	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
217	\N	/media/music/sortert/pop.ogg	2008-05-21 23:04:05.533311	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
218	\N	/media/music/sortert/mpeg2.mp3	2008-05-21 23:04:05.564934	10774000	1	12	22050	\N						                                    	                                    	                                    	                                    			
219	\N	/media/music/sortert/appear.ogg	2008-05-21 23:04:05.593821	0	1	22	8000	\N						                                    	                                    	                                    	                                    			
220	\N	/media/music/sortert/victory.ogg	2008-05-21 23:04:05.620417	2000	1	22	8000	\N						                                    	                                    	                                    	                                    			
221	\N	/media/music/sortert/gameover.ogg	2008-05-21 23:04:05.681103	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
222	\N	/media/music/sortert/lines2.ogg	2008-05-21 23:04:05.717679	0	1	80	44100	\N						                                    	                                    	                                    	                                    			
\.


--
-- Data for Name: metadata_match; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY metadata_match (metadata_match_id, file_id, metatrack_id, score) FROM stdin;
\.


--
-- Data for Name: metatrack; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY metatrack (metatrack_id, track_mbid, track_title, duration, tracknumber, artist_mbid, artist_name, album_mbid, album_title, last_updated) FROM stdin;
586	b9d679a4-ddbd-4964-aa50-73e14b71fc1e	(God Must Have Spent) A Little More Time on You (remix)	243453	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4e11b46f-e850-4f94-8c59-6e1f9b723c6e	(God Must Have Spent) A Little More Time on You	2008-06-05 23:25:51.304039
587	1ecf8779-5d51-49b0-8131-ba30c1361f00	(God Must Have Spent) A Little More Time on You	280240	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	25beaad8-89f2-4992-88a0-e856113b92c7	Totally Hits	2008-06-05 23:25:51.354594
588	7c7ce83d-26a6-4ff5-88cb-ff5f200c8d28	God Must Have Spent a Little More Time on You	0	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	34841d4a-3252-4f4e-9b03-1bcf4948151b	New Hits 1999	2008-06-05 23:25:51.402816
589	35e2f88b-dc42-406f-baaa-3df42365d0d5	God Must Have Spent a Little More Time on You	244000	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	65fb1b24-f321-4d6b-aaa5-0fd66d311c15	Greatest Hits	2008-06-05 23:25:51.450962
886	9020d8e7-aebd-4ade-95dc-f39649031034	I Want You Back	202106	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:48.954362
888	76cce4e7-c9d1-413e-a066-ff08e130dbff	I Just Wanna Be With You	243400	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.061255
889	6f462501-111b-4e43-9574-7d12cb14ae5f	Crazy for You	221666	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.101255
891	fb5d01e0-2091-4fa0-bd06-20cf0f17134e	You Got It	213640	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.181239
893	5a22e684-b543-462c-a177-2235b7a5c36e	I Drive Myself Crazy	239733	10	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.261228
894	e2cc2bec-29bf-4158-81bf-4e1307b83bbf	I Need Love	194960	7	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.301315
895	6d4f2747-2658-482b-ab76-8482b60d3e51	Everything I Own	238693	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.341241
897	e77b5548-66d5-42d7-829b-86657a6cb596	God Must Have Spent a Little More Time on You	282960	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.421396
899	5b6bee05-bce2-4bac-918b-3b2ea966a5f0	I Want You Back (Platinum remix)	269013	10	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-06 23:30:49.506745
900	f45cddff-acd7-46a4-ae64-4054d943535f	This I Promise You (Hex Hector club mix)	550040	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-06 23:30:49.550342
901	abdb2d29-4a26-46ac-8009-5818221a59e7	B remix)	228040	17	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-06 23:30:49.589731
902	be1779bc-c0ed-4e82-a7fa-37a8e598a554	It's Gonna Be Me (Jack D Elliot club mix)	230453	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-06 23:30:49.730243
903	e8918777-b1ca-499e-b168-3649f0e2ea13	Tearin' Up My Heart	211000	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.769886
904	144b3f0c-2dae-4a4c-902e-b122346cfb31	Here We Go	215866	3	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.809707
905	ad843218-b22f-45b6-8664-98c9539dca50	For the Girl Who Has Everything	226200	4	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.858076
906	8e3faaa9-e2b9-4c26-9bc8-748fd657bf61	Sailing	277640	12	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.897228
907	45a89256-b895-4d07-808b-ac05608429c1	Giddy Up	249960	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-06 23:30:49.937224
911	65776b8f-21cf-47bb-99e8-3660504b473c	Tearin' Up My Heart	287360	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.173293
912	681e75eb-efb6-4cc0-816f-73816a354bc9	You Got It	213066	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.213202
913	709e6196-3e0f-4726-82f1-4c6496a027ca	Sailing	276973	3	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.253262
914	ede6e302-5d5e-429b-ac6a-63c573574764	Crazy for You	222000	4	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.293315
915	1d660a11-648a-4caf-9735-bfb5b66608c9	Riddle	221133	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.333563
916	fd6d87c8-c4da-4e65-822d-596a49130066	For the Girl Who Has Everything	231360	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.373475
917	bfaf96a8-c954-4060-80ce-50c44c0f07b3	I Need Love	194866	7	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.413254
918	3ad4f1c0-ca53-4eca-8bad-86edb79a7012	Giddy Up	249666	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.453215
919	9ecf0a4c-9b2e-4242-9bd6-255dfbcb2005	Here We Go	216240	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.493417
920	dfea1c55-805d-4acf-aa44-ad7ce0f16fd3	Best of My Life	286493	10	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.533843
921	b4b8550f-4ccc-42ad-8410-87cfab8d98f3	More Than a Feeling	222706	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.573802
922	52a12817-0dc8-4488-a1df-ec2fd576b017	I Want You Back	264693	12	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.61351
923	d9c56e24-d37b-47bc-9d8f-bd5819c80467	Together Again	251840	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.652675
924	63e8c7c8-80f3-4b0c-957c-e248542f83b0	Forever Young	247400	14	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-06 23:30:50.693957
590	e8d3ba7d-2963-4228-a9a3-e74ff458cf41	God Must Have Spent (A Little More Time on You)	244000	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	d1be546e-0445-4ec6-bab0-08d4d1ec77e6	Greatest Hits	2008-06-05 23:25:51.498488
925	8c3185c1-43ce-466e-814e-4041d4f14107	Du kan gøre hvad du vil	220133	1	2b353828-6748-4ba4-bddd-493d728372c5	Christian	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:50.771237
926	ba72eb70-03c0-45bd-ae3c-2b9d5f5f851c	Miss California	206773	2	7d48da7e-5eee-45df-8e89-dfaee2af82c4	Dante Thomas	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:50.813201
927	d7095af3-7e76-4bab-9265-d8a69f6a6e5d	Daddy DJ	222666	3	8a44a6c6-a5ef-4e36-8ce0-3fd1d762e563	Daddy DJ	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:50.859873
928	69bfe9a0-a2c2-40a5-8ab6-49fbcde9edd0	Hjertet ser (feat. Erann DD)	208720	4	f42fa1c3-7e90-402b-9930-3a5eccceecb7	Karen Busck	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:50.90217
929	3b515287-a569-4a15-bfd6-863b9c65acb7	Samb-Adagio	185586	5	2d6a30a0-3925-4fad-84ed-a568872b081c	Safri Duo	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:50.940473
930	f97f9a4b-8367-4f33-bac9-7a747e8be659	Another Day in Paradise (feat. Ray J)	274053	6	01e60eba-52df-4694-8f09-39f43abe54e9	Brandy	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:50.982927
931	fa799c32-a1e4-4180-becb-cd7c8c69337f	Perfect Gentleman	198133	7	4f29ecd7-21a5-4c03-b9ba-d0cfe9488f8c	Wyclef Jean	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.023471
932	0513f9d3-bffd-4f7d-b3bc-024d92a03367	Come Along	224053	8	1b4bee4d-3239-4a65-8239-b62b43c23f48	Titiyo	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.068058
933	36452fbe-4357-4890-9f53-4989c3989c50	Bootylicious	209466	9	a796b92e-c137-4895-9c89-10f900617a4f	Destiny's Child	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.10914
934	ffcdeef9-0826-4ad0-9e8f-7fe001d6c53d	It's Raining Men	226826	10	23207c32-6743-4982-9f46-e297b2e4eb14	Geri Halliwell	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.161754
935	b6cfb931-fe77-4cc1-8870-89d816b1a5f6	Pop	176160	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.201629
602	12eee8af-07a8-42e8-b423-528f272f37c0	It's Gonna Be Me (Azza remix)	223173	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-05 23:25:52.001756
603	a0b14883-8318-4f9f-882b-394917fd1f08	(God Must Have Spent) A Little More Time on You	242106	16	603ba565-3967-4be1-931e-9cb945394e86	*NSync	9165f4a8-5ad6-4c65-a5a8-edd15bfa4e9e	Maxi5	2008-06-05 23:25:52.053433
604	c0d8d86d-a687-421f-b94a-036532ffdea7	(God Must Have Spent) A Little More Time on You	284213	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ff479fe9-55d9-48cb-9ba4-4f0a04b26b6a	Winter Album	2008-06-05 23:25:52.098993
605	eaf710f1-8013-4417-a394-be9fafd3da66	(God Must Have Spent) A Little More Time on You	242186	4	603ba565-3967-4be1-931e-9cb945394e86	*NSync	fb5e3a2d-4d99-4f92-a5f0-2c07d8f13add	Promo Only: Mainstream Radio, November 1998	2008-06-05 23:25:52.153166
936	05d68ab6-7406-40ef-9efe-6108fdf7f8c6	Hey Baby	218066	12	8d6a4455-1ae8-4e51-a481-08a85cb0141a	DJ Ötzi	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.240309
937	0a583eee-72bd-435c-93ec-9a9836f5f2fd	Romeo	205760	13	28cbf94d-0700-4095-a188-37e373b069a7	Basement Jaxx	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.280356
938	210b959e-564d-46b9-9595-ad39813b5239	Uptown Girl	187080	14	5f000e69-3cfd-4871-8f1b-faa7f0d4bcbc	Westlife	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.320205
939	7783d48d-414f-4fc3-b4f2-5796a138c56f	Dream On	221186	15	8538e728-ca0b-4321-b7e5-cff6565dd4c0	Depeche Mode	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.360683
940	f4767b55-69a3-46e5-ba4c-c360176c26f4	Fiskene I havet	216066	16	1ec4c3eb-dfab-49cd-86bf-1fea72f653b7	Blå Øjne	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.401032
941	dbe0adba-6a99-4fbe-9330-853fbe33bcfc	Lovin' Each Day	213386	17	f1cd545b-f17b-4d3a-98de-68b695bfe211	Ronan Keating	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.441274
942	2d1ebc52-ae17-4b32-83fc-b513c5089285	More Than That	222253	18	2f569e60-0a1b-4fb9-95a4-3dc1525d1aad	Backstreet Boys	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-06 23:30:51.481143
636	4e7b88e5-35ae-41fa-8285-d6113c924e23	Pop (DJ White Mike remix)	209586	14	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-05 23:25:57.810554
661	a2bce1d3-9de3-45ce-908b-8b003268e0d5	Pop (Drum Beat remix)	350906	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-05 23:26:01.033228
662	63bac89b-7cbe-42a0-96cf-cfa5760cd770	Brimful of Asha (Norman Cook remix)	241133	11	92046be7-0927-4835-a4ed-a90416747d53	Cornershop	30b3a88b-f53f-40a4-b672-5c1c6cf2e97e	Absolute Music 27	2008-06-05 23:26:01.077518
663	1cf2d29c-53ee-4cba-ac12-5b14a2737e8a	Music of My Heart (feat. Gloria Estefan) (Pablo Flores remix)	263693	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	b85a8745-d541-4acd-911e-1720e89b11f4	Music of the Heart	2008-06-05 23:26:01.119622
664	41e3fad3-8a2e-4561-8c20-c2df6e380b3e	Pop	174533	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	1059242b-6964-4e1c-9447-2ab231b0dede	Now That's What I Call Music! 8	2008-06-05 23:26:01.159851
665	5a1e4376-dfe4-4d27-b604-768fe49721b4	Bye Bye Bye	200000	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	cb3c8ecf-67f7-4a38-b819-5a68947aa313	Absolute Kidz	2008-06-05 23:26:01.199795
666	7f607130-d611-471e-9905-8865ad5f8e88	I Want You Back	201533	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	d92a81d0-60ab-4ed8-a535-37f745b8df6e	Absolute Stars	2008-06-05 23:26:01.238934
667	22cc5ec2-0149-4896-950e-c0d55460731a	Absolute Reggae Medley (Mixed by Denniz PoP)	405014	17	79842ea5-307b-46b8-b506-ffa73e546432	Denniz PoP	1a831f33-0279-44ed-8204-40df3aab6bcc	Absolute Reggae Classics (disc 1)	2008-06-05 23:26:01.284381
668	a92c00ff-c8c0-44f2-9268-ebe9700b3017	We're Having a Party (feat. Lois)	267333	11	6bee9759-e323-43f8-b5a9-3151e6305fd8	Luscious	30f649fe-b09f-4a55-b9ea-a6c777fe0594	Absolute Dance Opus 27	2008-06-05 23:26:01.330036
669	ae82a9f5-bae6-4c11-a2ba-3e73df00c0bf	One Fine Day	266000	11	37f0bf37-1de6-4afa-bc3c-bc409671fd07	Sector 27	88d56c17-0e66-46de-9058-ae59173f8210	Sector 27 Complete	2008-06-05 23:26:01.367951
670	3be6fa88-f39e-4cf8-87d5-f13dc24e51b1	Turn Up the Music	234946	11	720c7b81-b468-4162-b1b5-bd487a92b81b	DJ Aligator Project	2337dabe-8a8f-4748-96e6-cffd7646da2e	Absolute Music 35 (disc 2)	2008-06-05 23:26:01.409823
671	a9183ecf-f5eb-4117-abee-a93522b41b14	Tearin' up my heart	210146	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	312e4bdf-ccdf-4a3a-b229-6465f20e8e22	Absolute Summer Music 99	2008-06-05 23:26:01.448191
672	8ad72b55-599c-4bb4-be6c-30e273198f38	It's Gonna Be Me	192866	17	603ba565-3967-4be1-931e-9cb945394e86	*NSync	cb8ad314-b4ea-4eae-b65c-6bb163791479	Absolute Music 25	2008-06-05 23:26:01.4875
673	561eabd6-ea8a-4554-8984-32c644072374	I Want You Back	201146	3	603ba565-3967-4be1-931e-9cb945394e86	*NSync	db89506b-894c-4f2f-970b-d4192dd82c8f	Absolute Music 30	2008-06-05 23:26:01.527015
674	86892003-351e-43db-8dbe-d2f473a64a22	Bye Bye Bye	198560	7	603ba565-3967-4be1-931e-9cb945394e86	*NSync	2c388aaf-492f-48de-938b-5d296774cffa	Absolute Music 31	2008-06-05 23:26:01.566651
675	d09ef6b3-d24a-475a-9240-fceb0ccd2fb8	Move Your Body	355493	2	6ee7a715-e0c0-46d0-a215-2e17001699fc	Eiffel 65	30f649fe-b09f-4a55-b9ea-a6c777fe0594	Absolute Dance Opus 27	2008-06-05 23:26:01.608049
678	c6337f2b-5ed1-45b0-a5fc-a2da085c77c2	Absolute	333000	2	b9f8e6c5-22fb-44b4-af58-2614eed821a0	 DJ Raf	186b9add-b590-4aa4-af26-730f639a46fb	Shoot Out / Absolute	2008-06-05 23:26:01.727658
679	2b519623-3618-4048-b2f1-dc259dc1563d	Pop (Bubbling remix)	175573	16	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-05 23:26:01.768717
680	b07fe99d-7723-4001-989d-fdf986b48089	0027	338280	5	a885a438-a604-4c87-ac18-47217835a133	27 vs. Twin Zero	e338e78f-40f7-4dc7-ac97-a582f0a8bb22	27:00	2008-06-05 23:26:01.806456
681	eaf79aaf-954c-4f7c-a72f-87ae2a9feaa7	Sonata No. 27 in C minor	359293	11	8600a38e-f776-4543-9071-dfe5db653afe	Sylvius Leopold Weiss	670ad3b0-5363-493d-ac48-4614caf17c78	Sonatas Nos. 2, 27 and 35 for lute	2008-06-05 23:26:01.855533
682	855f30bd-a6d2-4ce2-bdcf-44ca177f65c3	This I Promise You	283373	16	603ba565-3967-4be1-931e-9cb945394e86	*NSync	0da63174-42de-4565-807b-3ce1055362d2	Absolute Music 36 (disc 1)	2008-06-05 23:26:01.896914
683	b2bf79f7-a0e9-4dda-b95a-2824c5412ddc	I'll Never Stop	188480	10	603ba565-3967-4be1-931e-9cb945394e86	*NSync	96588e19-8221-4b91-8c4b-1e231aa47f5d	Absolute Music 34 (disc 2)	2008-06-05 23:26:01.935846
684	83fe72fe-22d9-4aea-b557-0133b68d58ff	It's Gonna Be Me	191586	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	36a243e1-ea66-4492-936a-83abdc03407a	Absolute Music 35 (disc 1)	2008-06-05 23:26:01.987661
999	a46bb9f8-1436-4ea7-b3fb-d997ec3f2ad5	Bye Bye Bye	201373	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.085264
1001	1e35ce07-7632-40e9-a2ac-ee6f87e6a314	Space Cowboy (Yippie-Yi-Yay)	263440	3	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.173383
1002	866c09e7-d5f3-4c32-a029-d56686fc3b54	Just Got Paid	250000	4	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.217322
1004	9a76541c-6219-4716-aab7-9bbb45c925b6	This I Promise You	284733	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.305295
1006	2724dcfc-3217-448e-9c6f-6a03750079b4	Digital Get Down	261466	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.501523
1007	04e1f9a4-0a6b-4a35-874e-9fd8436da7d8	I Will Never Stop	201133	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.584515
1008	efc47178-9652-41f3-949a-9955db026178	Bringin' Da Noise	213240	10	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.654504
1009	5ad4dffe-f9d1-4705-8c87-a2df3f0b398a	That's When I'll Stop Loving You	291666	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.708819
1011	d3107b60-5c69-4337-a468-6a8f7ed3d553	If I'm Not The One	202106	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.797273
1012	2935c5a1-41fe-4a1d-96b4-f79f03f34579	I Thought She Knew	201733	14	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:30:54.844543
1073	14f07a28-8c8f-4c2a-8a43-a19e27f40099	Bye Bye Bye	200400	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:57.669317
1075	d1ac2dcf-28b5-4bcd-9c7f-959d701f0754	Space Cowboy	263466	3	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:57.75732
1076	714b2916-7915-4fee-9e15-a50a96a82cfc	Just Got Paid	250000	4	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:57.801286
1078	3c0a5b36-5e34-43b6-aba4-998a6f242a8c	This I Promise You	284760	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:57.895261
1080	ef70aaa1-efe9-4558-ae0c-83727b8dfbbb	Digital Get Down	263200	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:57.985353
1081	9b92c3b9-8e0e-47af-a91c-0086ec6d32c1	Bringin' da Noise	212066	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:58.037334
1082	dc56a3ef-3e3f-4b57-b3f8-a46116b7142f	That's When I'll Stop Loving You	291760	10	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:58.081302
1084	eb1a198c-10b3-4286-b8ed-e8542e59d9ef	I Thought She Knew	202666	12	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:58.180871
1085	0c06b996-1890-445a-9561-1dfd37ac5852	I'll Never Stop	206426	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:58.252067
1086	99257296-d8f2-4c65-a946-4743a5f42cd4	If Only in Heaven's Eyes	278840	14	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:30:58.297386
749	c894f789-7019-4c23-8532-72c65367ad3a	Bye Bye Bye (NDA mix)	300413	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-05 23:26:13.73377
751	534b29f2-3630-4ccc-8b2a-781b3a84a96b	 bye	388826	1	1a9b4e0d-05e2-4491-83f0-a4a676283f99	Preservation Hall Jazz Band	d7e41536-1924-46d5-b354-c5742a6b93f0	 Bye	2008-06-05 23:26:13.816395
752	aa76edfc-d866-437c-ab0b-e9c897deeeee	Bye Bye	150066	1	1122617c-ad49-4ed7-9046-86606f29680d	Mist	64aa749f-4e17-4690-954c-b05fff8860c2	Bye Bye	2008-06-05 23:26:13.854377
753	ad5b1cf9-f041-4f3e-ac4d-1f5939921887	Bye Bye.	278000	1	e3fc3ee6-bbdc-490d-b916-a498ec6245c6	相川七瀬	7c53dd71-e60a-44d4-abb1-67ee352aa4a2	Bye Bye.	2008-06-05 23:26:13.898919
754	04f66c77-f355-4d2c-b0c8-6bf974d53b9c	Kekkyoku Bye Bye Bye	264000	1	98e3c601-1820-45d6-981c-8af7baaddeb0	平家みちよ	4945cad0-8987-4c3f-993b-9a241b544fdb	Kekkyoku Bye Bye Bye	2008-06-05 23:26:13.942723
755	9b8275c1-3828-4c0d-a774-8c8ee200ba62	Bye Bye	200173	1	3f8ee838-9e81-4a22-975a-bce739631165	Jo Dee Messina	118ca10c-493e-405a-a2df-26f8abb5f435	Bye Bye / I'm Alright	2008-06-05 23:26:13.98525
757	04f69eed-df2e-4690-96ee-3bbd37492d09	Bye Bye Bye	198426	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	c34a80bc-cbe9-4c17-82f9-c6a76fd8cdf9	Mr Music Hits 2000-06	2008-06-05 23:26:14.076299
758	bc318e9a-fe4f-40a9-ba51-d292e672207d	Bye, Bye, Bye	200000	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	65fb1b24-f321-4d6b-aaa5-0fd66d311c15	Greatest Hits	2008-06-05 23:26:14.12927
759	9ceade08-7170-457c-b0a9-bb951b9bca57	Bye Bye Bye	199320	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f42748d4-8908-4b1d-81b0-4ad918d40d7e	Promo Only: Mainstream Radio, February 2000	2008-06-05 23:26:14.521661
1152	64580be4-9eda-4ca1-89b7-3365c43d2122	Bye Bye Bye	200560	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:01.437421
1154	a7dd8dbb-5439-443c-9f38-a758bd7dc9c9	Space Cowboy	263400	3	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:01.525344
1155	2374bcad-335d-444d-b098-0a760e08f9c4	Just Got Paid	250133	4	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:01.569338
1157	73638768-0b5c-4791-8a4e-5a192217a019	This I Promise You	284760	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:01.661384
1159	4f361aa3-1339-4bce-a944-dcd55e104b34	Digital Get Down	261333	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:01.753368
1160	09a9f27b-01c2-44f7-9948-f9378ee60b8f	I'll Never Stop	203000	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:01.809447
1161	769f1cdb-8d02-48d6-9153-4357338bf336	Bringin' da Noise	211333	10	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:01.8573
1162	868fa25c-5348-4161-a812-b316f463a182	That's When I'll Stop Loving You	291760	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:01.901401
1164	d57ee379-ad62-404c-a36e-3e43945e608e	If I'm Not the One	202106	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:02.02119
1165	a5bc287c-d688-44a7-986f-090e653fbb71	I Thought She Knew	202960	14	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:02.065293
811	8ecb5148-f722-4970-87ec-255228166d5b	Here With Me	253973	1	d1353a0c-26fb-4318-a116-defde9c7c9ad	Dido	dc1f9577-a70c-476c-b0a4-3e3a89df862f	Now That's What I Call Music! 5	2008-06-05 23:26:26.06707
812	88f5b515-dd86-46de-bc82-b5985e7a34fa	Whiketywhack (I Ain't Coming Back)	184653	5	991295f7-d40f-47ff-be26-ad6359de1509	Christine Milton	430d5a99-1d61-4167-af17-3d4260b17db0	Now That's What I Call Music! 5	2008-06-05 23:26:26.125795
814	fc9876d3-c9b1-4991-8634-a7b072b7b860	It's Gonna Be Me	190933	16	603ba565-3967-4be1-931e-9cb945394e86	*NSync	a70d517d-c6c6-4ff7-acf9-78f6f103dff4	Now That's What I Call Music! 47 (disc 1)	2008-06-05 23:26:26.217892
815	ecbfb732-89af-4344-907c-a165b2b9b93d	Gonna Make You Sweat	247293	5	c9d4f63d-6c2c-47ae-84fe-819001e3d3ea	C+C Music Factory	627934ab-310a-43fa-a44d-767507e8b0b3	Now That's What I Call Music! 19 (disc 1)	2008-06-05 23:26:26.265466
816	c447e4bc-93f0-4038-960b-a929b09eadc5	Turn It Up	405373	6	54c29bb0-6cc3-457a-98be-857e0c66716f	Conway Brothers	aa57a079-dbb0-49dd-9adc-0ddff26e1996	Now That's What I Call Music! 5 (disc 2)	2008-06-05 23:26:26.312047
817	6b6201d5-1542-459e-9c94-955004094979	This I Promise You	283173	14	603ba565-3967-4be1-931e-9cb945394e86	*NSync	70b27af5-0bff-4a1a-b80c-809f810d6a07	Now That's What I Call Music! 7	2008-06-05 23:26:26.357363
818	45a945e1-9398-4e52-b855-ed7107f735e0	Girlfriend (The Neptunes remix) (feat. Nelly)	284666	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	414e735b-74db-4ef3-9a49-1529522a1ccf	Now That's What I Call Music! 10	2008-06-05 23:26:26.405809
819	0eb8495d-fc5e-4c32-8a6e-aea9ce9741cf	She Will Be Loved	243813	3	0ab49580-c84f-44d4-875f-d83760ea2cfe	Maroon 5	c7383197-1b49-41f7-a1a4-eb26c971871e	Now That's What I Call Music! 10	2008-06-05 23:26:26.449841
820	ac514f7e-16d7-445d-b52f-4c37ff33766a	This Love	208920	1	0ab49580-c84f-44d4-875f-d83760ea2cfe	Maroon 5	6fd6e4c0-6600-4be6-9dc4-ab44c9df3578	Now That's What I Call Music! 9	2008-06-05 23:26:26.491933
821	5fed24c8-6a5f-4987-9033-1e9519cf99e3	Someone to Call My Lover	272400	5	6be2828f-6c0d-4059-99d4-fa18acf1a296	Janet Jackson	1059242b-6964-4e1c-9447-2ab231b0dede	Now That's What I Call Music! 8	2008-06-05 23:26:26.539575
822	029bb7e8-69d0-46d1-ae76-b051a8c3dc51	Don't Stop the Music	263120	1	73e5e69d-3554-40d8-8516-00cb38737a1c	Rihanna	d402b76f-d501-4f41-bbb2-8f04da32f9cf	Now That's What I Call Music! 27	2008-06-05 23:26:26.588831
823	cfdbb70a-ead8-4c39-ad03-9d43e1cbbde7	All That She Wants	0	5	d4a1404d-e00c-4bac-b3ba-e3557f6468d6	Ace of Base	f2bdb3de-2225-42c2-849e-8f3eef47cb88	Now That's What I Call Music 3	2008-06-05 23:26:26.636166
824	bd7df105-be95-4fd7-bc38-5e42dd3cec3f	What? (original 12" edit)	364000	20	7fb50287-029d-47cc-825a-235ca28024b2	Soft Cell	43d4bd92-dde3-4a01-a9bb-77712a345c56	Now That's What I Call Music! 1982	2008-06-05 23:26:26.68409
825	366e879a-64e0-46b7-92ac-fc7b5b3406a7	Crank That (Soulja Boy)	221693	1	29eead4d-3793-4625-8727-c03edbb38b8b	Soulja Boy	c4fe0785-77a6-446f-a36a-48acf14751b4	Now That's What I Call Music! 26	2008-06-05 23:26:26.731216
826	61b98cd0-9b3f-4c3c-88d5-444402d9d10b	Say You'll Be There	237733	5	bf0caafc-2b20-4e07-ab85-87e14ff430ce	Spice Girls	67297836-2904-457f-a67b-447fbe000851	Now That's What I Call Music!	2008-06-05 23:26:26.77908
827	cf313c90-a296-4c12-802d-d4cf43fa3ccf	Real to Me	226000	1	b64575d5-28c2-4e1c-8176-3c2a0a473fda	Brian McFadden	9655c164-dcac-4b6e-bc96-7e33671e3467	Now That's What I Call Music! 11	2008-06-05 23:26:26.825385
828	7059c8fd-4cae-43f4-a40d-7d3539bdf295	Ch-Check It Out	190733	5	9beb62b2-88db-4cea-801e-162cd344ee53	Beastie Boys	05c7e334-f95e-40b9-9238-f29737c3680d	Now That's What I Call Music! 17	2008-06-05 23:26:26.870372
829	6aef4c8c-e270-48a3-bff2-ae9102f8fac1	Ain't It Funny	240373	5	f0602f55-1770-483d-89bd-4bae0d0ac086	Jennifer Lopez	31bc651e-0364-48a0-b4a8-2e5a7da32ed8	Now That's What I Call Music! 9	2008-06-05 23:26:26.918036
830	6b019226-13c6-4862-ad76-e3b882bd7b9f	Dip It Low	194173	5	78e98e0e-f873-4e5e-b4b7-88b7293fd713	Christina Milian	43d35c3e-d51c-4212-a314-33f82269433a	Now That's What I Call Music! 16	2008-06-05 23:26:26.966022
831	3ad8adaa-6f9f-4794-af61-35b9b10b2445	Got 'Til It's Gone	219466	5	6be2828f-6c0d-4059-99d4-fa18acf1a296	Janet Jackson	68012214-a808-48e5-9428-72aeba3b4806	Now That's What I Call Music	2008-06-05 23:26:27.012312
832	1f0b941d-ba60-4b41-9c8a-851f8c8110c8	It's My Life	225826	1	5dcdb5eb-cb72-4e6e-9e63-b7bace604965	Bon Jovi	c2a20074-1f70-43cb-8c89-d064f5d110e5	Now That's What I Call Music! 6	2008-06-05 23:26:27.076427
833	3d3e77bd-13ac-4e21-b56b-edf94ece956b	It's My Life	226226	1	fbd2a255-1d57-4d31-ac11-65b671c19958	No Doubt	e8f4700a-a58f-4f98-ab1c-4ca75fa9b268	Now That's What I Call Music! 15	2008-06-05 23:26:27.121199
834	57914cbc-c39d-4a3e-a028-9bee47f4e162	Let's Get It Started	216786	1	d5be5333-4171-427e-8e12-732087c6b78e	The Black Eyed Peas	05c7e334-f95e-40b9-9238-f29737c3680d	Now That's What I Call Music! 17	2008-06-05 23:26:27.168085
836	a5c479df-a487-4669-af48-0f2a5e25978f	Bye Bye Bye (Instrumental)	203306	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae498204-50f7-42f0-bac5-ef97cbe03f13	Bye Bye Bye	2008-06-05 23:26:33.145482
837	3dfe3673-7f81-4cc0-a16e-c1502e9c502c	Bye Bye Bye (Teddy Riley's club mix)	331266	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	805b78d4-ddc9-44ea-aa8b-f1ecf8355002	Bye Bye Bye: The Remixes	2008-06-05 23:26:33.208975
838	72afd253-3397-4675-bf3c-bfd482bd049d	Bye Bye Bye (Riprock 'n' Alex G club remix)	395440	4	603ba565-3967-4be1-931e-9cb945394e86	*NSync	805b78d4-ddc9-44ea-aa8b-f1ecf8355002	Bye Bye Bye: The Remixes	2008-06-05 23:26:33.274826
839	c4c8bcff-b13f-4413-b002-e52f2c81255f	Bye Bye Bye	199000	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	8cd613b9-1d8b-49c3-8aa7-492700448d48	Smash Hits Summer 2000 (disc 1)	2008-06-05 23:26:33.319322
840	9a822b41-d31c-4669-9d84-3b70b2e8e25b	Bye Bye Bye	202760	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae498204-50f7-42f0-bac5-ef97cbe03f13	Bye Bye Bye	2008-06-05 23:26:33.360616
841	348a01d8-d926-4c5c-b8d6-a6ff5c914f04	Bye Bye Bye (Teddy Riley's Funk remix)	293426	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	805b78d4-ddc9-44ea-aa8b-f1ecf8355002	Bye Bye Bye: The Remixes	2008-06-05 23:26:33.408706
842	b48ae283-870b-46e1-9602-d99f4aa42627	Bye and Bye	189600	2	29c5b1fb-5dcc-4499-b225-4ceeeb8a73d1	The Carter Family	71de959b-217d-4b1c-b7af-12bdb7e5bc2f	 Western Music (disc 5)	2008-06-05 23:26:33.453128
843	cd133a38-b298-4433-bc0a-cac01a9f45c2	Bye and Bye	187000	2	29c5b1fb-5dcc-4499-b225-4ceeeb8a73d1	The Carter Family	bb36e87f-c33e-4971-8f7b-5f31c97de480	 Western: Original Masters (disc 3)	2008-06-05 23:26:33.497761
844	09a0d23d-47ef-44d1-8647-997c592538b5	Bye Bye	416840	12	2eea3b6d-a79d-4c14-8137-148b8886edc7	The Solid Doctor	85b0a6da-b248-4bd5-965b-b67113f7a18a	How About Some Ether: Collected Works 93-95 (disc 1)	2008-06-05 23:26:33.545164
845	3252509c-87da-4f7a-a68e-33af3f7d8127	Say Bye Bye	0	2	ed78d5cd-4467-49c6-8c48-ea84161cb880	 The Dragonaires	d43c4456-f9a3-4e82-bdfc-c3df95e895ca	Sammy Dead / Say Bye Bye	2008-06-05 23:26:33.588634
846	911b9652-3a64-4bf4-91da-a360030d8630	Bye Bye Bye	199693	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	0ae3fc02-55fe-44c6-9825-8b8509c0ad74	Bild Hits 2000: Die Zweite (disc 2)	2008-06-05 23:26:33.632056
847	a0aac664-a83f-4c72-b5b4-5a63767210dd	Bye Bye Bye	201426	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	07afcb45-d08a-4c86-9492-cd62c3ef376a	100% Hits the Best of 2000 (disc 2)	2008-06-05 23:26:33.677185
848	1ef17cf7-4524-4dbd-8da5-cd65e6d64740	Bye Bye Bye	199666	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	b398a1c7-0a66-4600-ae93-f7d74cd4e3f0	The Best Dance Album in the World... Ever Part 11 (disc 2)	2008-06-05 23:26:33.723566
849	d4783904-c114-4570-a11d-b51c92b30a26	Bye Bye Bye (Sal Dano's Peak Hour dub)	509734	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	805b78d4-ddc9-44ea-aa8b-f1ecf8355002	Bye Bye Bye: The Remixes	2008-06-05 23:26:33.771071
850	0c900662-1932-481e-8479-e207f0f905a9	Bye Bye Love	0	1	091ec508-877f-4e3c-92a3-10903bbbc7ad	The Everly Brothers	3dede93a-f30f-4600-b67e-8f8fdaf6b9ca	Reunion Concert (disc 2)	2008-06-05 23:26:33.816792
851	13883352-a43e-4eed-abd1-772416c3c414	Bye Bye Johnnie	131426	11	b071f9fa-14b0-4217-8e97-eb41da73f598	The Rolling Stones	3d6eb5b1-ee97-435a-9cb7-e69c2cde4981	 Fazed Cookies) (disc 2)	2008-06-05 23:26:33.861382
852	38761b26-37e2-436f-8e62-a6a608175ede	Bye Bye Bye	200506	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	1513917c-3a79-447c-a951-f31c41306521	Smash! Volume 9	2008-06-05 23:26:33.904765
853	6bd74e87-3313-4b23-b01f-a05226bcf46a	Bye Bye Bye (Thunderpuss2000 club remix)	433320	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	4882c497-c476-4c96-9f1d-f00f54148df3	*NSync Remixes, Volume 1	2008-06-05 23:26:33.950776
854	4e92cd74-b96f-4924-bbd6-54436933bb0c	Bye Bye Bye	200000	3	603ba565-3967-4be1-931e-9cb945394e86	*NSync	59c85021-34d3-46f5-8b76-451e96927f44	The Best Summer Holiday ...Ever! (disc 2)	2008-06-05 23:26:33.996768
855	4be1a3eb-1d54-4c66-ba7e-2d3301ea358a	Bye Bye Blackbird	419000	2	e2b30f71-a5ce-4f94-8a58-0b83905d29a2	Marc Miralta	ede4ee9c-88e9-49d5-a64f-fd22a74d9d6d	New York Flamenco Reunion	2008-06-05 23:26:34.049232
856	c1b4bab5-16ab-4a34-8305-4011a6f83e37	Bye Bye Blackbird, Part 2	410306	5	561d854a-6a28-4aa7-8c99-323e6ce46c2a	Miles Davis	bdc524db-49f4-46ac-91f4-d3f33e355bf6	Bye Bye Blackbird	2008-06-05 23:26:34.104071
857	80e7b1dc-2ed8-48f7-80b3-779074404144	Bye Bye	201386	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	94fe6bdb-0dd3-4c86-9ab6-c7ccc89f7e32	Festivalbar 2000 Compilation Rossa (disc 2)	2008-06-05 23:26:34.148973
858	02e6315d-fd2e-4e22-b9e1-192a830d1ddc	Bye Bye Bye	198000	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	77aa2170-72b3-4d57-8e23-554f3faeff97	Boom 2000 (disc 2)	2008-06-05 23:26:34.189284
859	6ac5bc00-d8e8-4e46-aa01-1d89eafae24e	Bye Bye Bye	201000	16	603ba565-3967-4be1-931e-9cb945394e86	*NSync	c26e179c-1005-427f-96f5-df35500a7204	Pepsi Chart 2001 (disc 2)	2008-06-05 23:26:34.230331
1218	d8af185e-1a2f-45d1-b5bd-dd73005b3be7	Space Cowboy	263466	3	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:04.469397
1219	e6f4ee7d-2141-4896-b708-3438613ec64f	Just Got Paid	250000	4	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:04.513371
1221	d2c36a97-6596-439e-9018-3d9ff08278c1	This I Promise You	284760	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:04.6014
1223	eb55ad9e-0070-472c-bb04-a2127b179f27	Digital Get Down	263200	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:04.689929
1224	819002e9-1fbc-402f-b6e1-b1246c2a2853	Bringin' da Noise	212066	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:04.733362
1225	dc1a30d8-dab6-4960-a3ec-a8d85c996f5b	That's When I'll Stop Loving You	291760	10	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:04.777468
1227	cfe6c921-bfa6-47d1-bd32-fab242f9eac5	I Thought She Knew	202333	12	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:04.897455
1228	d979f2c8-90c1-4670-a417-a31eea9b477f	It's Gonna Be Me	192373	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:09.481837
1229	671fbe8f-1b41-48fb-868d-21de0508186c	It's Gonna Be Me	192426	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:09.533321
1230	8e158c90-bc55-4a7e-8999-52d191ffe177	It's Gonna Be Me	192426	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:31:09.593795
1231	c2580264-8e00-41e4-acf1-aa52a5f5decb	It's Gonna Be Me	192426	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:31:09.645912
1273	d0f6da35-48b4-489d-9d19-c0881625e8a6	It's Gonna Be Me	193600	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:11.557281
1285	03e1ec9e-7d12-44c3-830f-bdd631fc6cd7	Bye Bye Bye	202786	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.133424
1286	1fde75bb-9483-4900-86c2-4fe1526afc1d	Space Cowboy	264413	3	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.177366
1287	793c6c35-25ad-4133-8236-b38f171d1b91	Just Got Paid	250626	4	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.22141
1289	aec2ef6c-672b-457e-b17e-06960cc0c214	This I Promise You	285200	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.30936
1291	fa844934-e783-4d78-9b50-49d2bc5bd357	Digital Get Down	264320	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.397289
1292	c17995d6-774f-43f6-8155-a92c64f1bb8c	Bringin Da Noise	212506	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.441287
1293	d7f4a379-11a9-4878-88f9-411bea3bed84	That's When I'll Stop Loving You	292346	10	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.485352
1295	672b9f77-ecd3-4265-a964-5f5b3e40cf71	I Thought She Knew	201960	12	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.573306
1296	b8ee546b-c3b8-4371-aed6-488041c47f12	Yo Te Voy A Amar	267666	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.617318
1297	62f92d66-ec85-43fc-b633-8d8d7ba0910e	No Strings Attached	228906	7	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:12.661922
1298	5d847153-0b7f-48da-890b-4a122f12d62d	No Strings Attached	228466	7	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:31:12.706002
1299	cbc6d7ca-2c59-450e-881f-00e7c45a28da	No Strings Attached	228640	7	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:12.75011
1300	a0320f1b-7e5f-41ae-b16e-ff5611b9184b	No Strings Attached	228906	7	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:31:12.793852
1301	66f07e13-9aad-4ca0-b5af-5e395a0ae11f	No Strings Attached	228840	7	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:12.843754
1302	c64591a0-60ae-491a-9266-fae134403c17	Could It Be You	222000	15	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:12.88993
1303	f2a00a4f-dc45-4871-a0d3-f9a0e8a82d32	Could It Be You	219800	15	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:31:12.933468
1304	f2629c73-164d-46a8-9243-b15d25f4da66	It Makes Me Ill	207906	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:12.977565
1305	88428b42-3b55-4b7d-9e54-f41fa063279f	It Makes Me Ill	207893	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:31:13.121354
1306	2cc7cb79-22a8-48fe-bd62-6f122ca7b1a2	It Makes Me Ill	207906	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:31:13.165419
1307	191ef811-05eb-4218-b98e-83063c2d1119	It Makes Me Ill	208026	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:13.205256
1308	2c614148-f591-44e5-a314-64ae5549efe5	It Makes Me Ill	207800	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:13.249415
1309	7d3acea0-1ce7-4dd5-97d0-359453bbca40	I'll Be Good for You	236373	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:13.293658
1310	86345be3-79f8-4ddf-9d3f-7f4deaf6a0f3	I'll Be Good for You	235266	12	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:13.349517
1311	6a2858ae-030c-4bb9-a60d-027b2976ff77	I'll Be Good for You	236373	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-06 23:31:13.393358
1312	c0f3862f-8e07-4d79-b29e-63639a65e556	I'll Be Good For You	235293	12	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-06 23:31:13.437446
1313	fb467c51-9582-4f9f-b5e7-95c159d6eadf	I'll Be Good For You	236800	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-06 23:31:13.481221
1314	5b59ff98-9683-40c2-a93e-ce024bd43ca6	This Is Where the Party's At	372213	16	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-06 23:31:13.52623
1315	bfde38a7-dc54-44cd-b3ed-cd9c770864dd	No Strings Attached	1256000	1	a9229736-b3ca-4986-ab1e-354880664618	Lou Gare	0849a881-2002-484f-bb57-b26c3a3b1a08	No Strings Attached	2008-06-06 23:31:13.570585
1316	d4b4a809-0ec3-404b-b87f-ed117674ba0b	Bye Bye Bye	200400	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-06 23:31:13.613684
1317	236c4951-f779-4ae1-ab61-741cf0a2133c	It's Gonna Be Me	190826	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:13.690351
1318	99d6c5fe-9a66-4a65-a634-f56ef2227c91	Give Me Just One Night (Una Noche)	204333	2	177fde26-5a95-46d9-922f-0933940d97e5	98 Degrees	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:13.737875
1319	d03d4fe1-d7d2-49d5-ba88-2ea4a11d36cf	Jumpin' Jumpin'	227373	3	a796b92e-c137-4895-9c89-10f900617a4f	Destiny's Child	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:13.783356
1320	485efb74-9534-4573-804c-a01b27a0e141	Don't Think I'm Not	230066	4	888f7e18-2a96-4f2e-8320-08ff4330b442	Kandi	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:13.830179
1321	e420971d-e576-487d-87bd-13957736933d	I Think I'm in Love With You	216226	5	fe37acd4-893c-4b2c-8ad2-7fd394280354	Jessica Simpson	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:13.882552
1322	736fc502-7873-4448-ae7f-5af3df13730a	Faded	204666	6	e01482f5-8865-4d25-b2f5-0ebfdf53d96c	soulDecision	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:13.925152
1323	3442b217-01fb-4f38-98f3-decb29763c96	Shake It Fast	254173	7	1cfe52d7-181a-4b3a-8041-d8bf9ccef57b	Mystikal	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:13.971032
1324	c190f780-f6e8-47f9-a888-ee74ee466bfe	Case of the Ex	231426	8	7c5e39c3-7645-4e37-968d-a4e45cd38c5d	Mýa	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.013768
1325	c9c2aa11-f9f0-4caf-b413-e0e89019efeb	Aaron's Party (Come Get It)	205533	9	4c0bb5bc-95ad-47de-99e3-fbb4fbc5f393	Aaron Carter	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.068944
1326	fac15488-7391-496c-b167-8d5de710236b	Lucky	204640	10	45a663b5-b1cb-4a91-bff6-2bef7bbfdd76	Britney Spears	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.113604
1327	ae4cc4b8-4755-4134-b110-4a8d6e831d97	Show Me the Meaning of Being Lonely	233693	11	2f569e60-0a1b-4fb9-95a4-3dc1525d1aad	Backstreet Boys	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.16269
1328	fcaa5621-bff3-4349-b4e5-7104d97af3d2	Incomplete	232266	12	25e0497c-faa4-4765-b232-baa20e5e35a7	Sisqó	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.204682
1329	dffac2bc-2580-4497-9b6c-495c320540f2	I Wanna Be With You	252866	13	9dc9f4b0-a7b4-43c5-8f6b-fcd43c426a4b	Mandy Moore	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.251129
1330	d7bbbc25-8764-437e-b2f7-629c86a71980	Doesn't Really Matter	256773	14	6be2828f-6c0d-4059-99d4-fa18acf1a296	Janet Jackson	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.299883
1331	1ad2b064-3a1f-4c31-aef0-568d5b1a3d5b	Back Here	217826	15	0662fa9d-73b0-4f71-9576-c963a5a14f66	BBMak	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.344824
1332	015ce306-7941-4dec-a56f-fe1ddbcd5f8b	Absolutely (Story of a Girl)	191866	16	c30dfb44-768a-487b-af9c-c942682aa023	Nine Days	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.392481
1333	c3c264b9-2b4f-4565-946e-504bb48ee930	Kryptonite	233840	17	2386cd66-e923-4e8e-bf14-2eebe2e9b973	3 Doors Down	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.438044
1334	ab608a3e-66c6-4d22-9f74-947f20aa18ae	Wonderful	272426	18	3604c99d-c146-4276-aa0c-9376d333aeb8	Everclear	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.493272
1335	f68f4f52-4218-457f-9eba-0b56e6d602b8	It's My Life	223600	19	5dcdb5eb-cb72-4e6e-9e63-b7bace604965	Bon Jovi	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-06 23:31:14.538088
1336	a2f0df72-0611-4cae-97ba-d4630eedcd67	Back for Good	242293	1	24d2505b-388c-46cc-8a64-48223ea6d78d	Take That	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:14.605817
1337	878573f5-e191-4e14-9e24-78ae2d7d7532	Especially for You	236773	2	9bd94498-68cc-4b1e-b9cf-b3ba95cffccf	 Jason Donovan	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:14.652399
1338	f31f3d58-e71a-44a8-975c-9a816cf6c45f	Stay Another Day	266626	3	ee20d564-25ca-4ef5-aba7-93a39f78ed60	East 17	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:14.697835
1339	227c6350-7d1d-4978-b5b3-1487ed7c67cb	You Got It (The Right Stuff)	249200	4	090dafe5-818c-4bba-9ebf-7e3a651a5c43	New Kids on the Block	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:14.746004
1340	6a9326d5-8d58-476f-992a-09a15167d26c	Stay	238133	5	7343056e-041e-4b28-a85a-58e8fb975136	Eternal	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:14.787761
1341	3281fc15-b9e6-481c-8c57-0f49a4c692c6	Boombastic	247640	6	fc63d806-ca89-4ea3-a404-ee6de695743f	Shaggy	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:14.839073
1342	3496dc0a-359f-4bf6-8e5c-8fc91e749014	Wannabe	172160	7	bf0caafc-2b20-4e07-ab85-87e14ff430ce	Spice Girls	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:14.884762
1343	1636a361-0364-4a57-b1b8-9bac1f34b086	As Long as You Love Me	211000	8	2f569e60-0a1b-4fb9-95a4-3dc1525d1aad	Backstreet Boys	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:14.931129
1344	0440546b-798a-4836-b352-6f2bdcbdfcca	Never Ever	312733	9	a371601f-c184-4683-806d-2eb35e88f0d7	All Saints	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:14.977901
1345	cdb9ad5e-7a49-4ae2-9c63-63471bd45ffa	...Baby One More Time	210866	10	45a663b5-b1cb-4a91-bff6-2bef7bbfdd76	Britney Spears	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.025792
1346	84a7c3b4-5c8f-4895-af1c-292bcf80480a	Bye Bye Bye	199666	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.07832
1347	fe5b88ec-e46e-4fbd-a6d9-7076e4cb811c	Tragedy	271266	12	19659aa7-cd3a-4bfe-bca0-6943e9e5c6e0	Steps	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.119978
1348	33549783-ab46-40e0-8941-c979f9422eeb	Don't Stop Movin'	231426	13	bd5cf3e9-cb6c-41f3-8c7d-e9bda3c4e721	S Club 7	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.16598
1349	e16b5ed6-6d4f-4aac-851b-b803851ca57d	Can't Get You Out of My Head	230266	14	2fddb92d-24b2-46a5-bf28-3aed46f4684c	Kylie Minogue	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.212558
1350	b35e1bdb-67d3-420c-888d-47772497d71a	Rock DJ	255733	15	db4624cf-0e44-481e-a9dc-2142b833ec2f	Robbie Williams	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.257654
1351	deee0d04-5c5a-416e-9559-8e2ade6f1612	Life Is a Rollercoaster	235333	16	f1cd545b-f17b-4d3a-98de-68b695bfe211	Ronan Keating	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.303687
1352	2b1e84b6-ef4c-4390-97ca-004c478cb0ba	Just a Little	233866	17	02db9e84-a750-4d22-b5b1-c769e698dc6c	Liberty X	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.349887
1353	11169207-495b-4899-9642-276d12332c6d	All Rise	224000	18	9c79224c-70cd-4367-8d90-35ca99401b75	Blue	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.391651
1354	d509a288-3166-4c0c-abaa-8eabd807fa02	Whole Again	184733	19	6fda00c2-449a-4bf4-838f-038d41a07c73	Atomic Kitten	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.437929
1355	cb7a1065-979c-423f-a957-2f3428ae8c37	Flying Without Wings	216400	20	5f000e69-3cfd-4871-8f1b-faa7f0d4bcbc	Westlife	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-06 23:31:15.482522
\.


--
-- Data for Name: puid; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY puid (puid_id, puid) FROM stdin;
\.


--
-- Data for Name: puid_metatrack; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY puid_metatrack (puid_id, metatrack_id, last_updated) FROM stdin;
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
11	3	duration_weight	100	f	
12	3	title_weight	100	f	
13	3	tracknumber_weight	100	f	
14	2	album_cache_lifetime	3	f	When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again.
15	1	puid_min_match	0.5	f	Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0
16	2	puid_cache_lifetime	3	f	When it's more than this months since puid was fetched from MusicBrainz, it'll be fetched from MusicBrainz again.
17	1	puid_min_score	0.5	f	Minimum value for when a PUID lookup is considered a match. Must be between 0.0 and 1.0
18	1	metadata_min_score	0.75	f	Minimum value for when a metadata lookup is considered a match. Must be between 0.0 and 1.0
19	4	album_cache_lifetime	3	f	When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again.
20	4	puid_cache_lifetime	3	f	When it's more than this months since puid was fetched from MusicBrainz, it'll be fetched from MusicBrainz again.
21	4	metatrack_cache_lifetime	3	f	When it's more than this months since metatrack was fetched from MusicBrainz, it'll be fetched from MusicBrainz again.
10	3	duration_limit	15000	f	
\.


--
-- Data for Name: setting_class; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY setting_class (setting_class_id, name, description) FROM stdin;
1	FileReader	TODO
2	WebService	Settings for looking up data on a WebService
3	FileMetadata	TODO
4	Locutus	General settings for Locutus
\.


--
-- Data for Name: track; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY track (track_id, album_id, artist_id, mbid, title, duration, tracknumber) FROM stdin;
8019	1458	1290	bc318e9a-fe4f-40a9-ba51-d292e672207d	Bye, Bye, Bye	200000	1
8020	1458	1290	c0c6de7f-3282-420e-b64c-4a514f6ddfc8	Girlfriend (feat. Nelly) (remix)	285000	2
8021	1458	1290	b4eb9c9b-01a7-440d-a200-dd06f1df8b57	This I Promise You	267000	3
8022	1458	1290	e7a39e19-dbfd-4eb5-8c37-dc03102d8e6c	It's Gonna Be Me	192000	4
8023	1458	1290	35e2f88b-dc42-406f-baaa-3df42365d0d5	God Must Have Spent a Little More Time on You	244000	5
8024	1458	1290	6ff52679-9504-423d-a2c5-613bf36c3475	I Want You Back	200000	6
8025	1458	1290	e27ce99d-3dd0-4dea-9bf2-1fe9d4f364bc	Pop	176000	7
8026	1458	1290	e45165ef-c16e-4b72-9bc2-81e43a2dc4ec	Gone	293000	8
8027	1458	1290	761566f9-c063-4524-b4fd-d6c2143113e3	Tearin' Up My Heart	210000	9
8028	1458	1290	2d94654e-ae02-4a08-bc4e-d630452b9540	I Drive Myself Crazy	239000	10
8029	1458	1290	8d127905-819e-407b-b46a-a050a0b0a650	I'll Never Stop	188000	11
8030	1458	1290	5a11a41a-b387-4f64-bd39-d6fcfdbc6b8b	Music of My Heart (feat. Gloria Estefan)	271000	12
8031	1459	1290	9ceade08-7170-457c-b0a9-bb951b9bca57	Bye Bye Bye	199320	1
8032	1459	1309	76a6c3ce-d087-45e4-a7f8-4524dba2ef5d	You Sang to Me	230880	2
8033	1459	1310	4b135780-f4a0-4d55-8402-c6f3a18fb5aa	Another Dumb Blonde	230866	3
8034	1459	1311	e884985c-1d0e-4172-baff-7d0b0153d625	Only God Knows Why	255653	4
8035	1459	1312	152e2031-e69b-47bc-9c8b-416140c32cde	Feelin' So Good	174773	5
8036	1459	1313	da30da34-3e28-45aa-b079-9cd01dab9d99	Woke Up This Morning (Theme From the Sopranos)	207333	6
8037	1459	1314	8ba4fe2f-8911-4878-a74c-1349d8d82074	Freakin' It	239400	7
8038	1459	1315	3814dfac-0e82-4f92-af8f-921c932588a4	Nothing Good About Goodbye	228320	8
8039	1459	1316	fd0b1034-61a5-4097-a8fd-4750ac195084	Otherside	255813	9
8040	1459	1317	25699e43-9dca-4a90-8e4f-b851542fae0d	Telling Stories (There Is Fiction in the Space Between)	237746	10
8041	1459	1318	9ed3ee22-d577-4fe0-8c17-4e2830949ff4	Get It on Tonight (Mainstream radio edit)	212453	11
8042	1459	1319	4f4a7b88-853a-4ec7-aa3c-9408d98d14f1	I Am	237546	12
8043	1459	1320	04f6eab8-264c-4341-97ca-80aa17cfb11c	Even Angels Fall	206600	13
8044	1459	1321	ba3e4ca6-1b96-4cc4-be4c-5a7f379aa3cf	Now That I Found You	236760	14
8045	1459	1322	b92d5f76-5f4a-48cb-aeea-220f24c43fb6	Superfantastic	224053	15
8046	1459	1300	29cafcdf-29d5-4c47-ae78-c63ac1830a28	Say My Name	267866	16
8047	1459	1323	72160fad-2db9-4cf7-ab25-d585258638c4	Enough of Me	278693	17
8048	1459	1324	acebaeda-46d6-4f92-989d-96ece68639db	The Bad Touch (The Eiffel 65 mix)	213813	18
8049	1459	1325	d942ac05-354f-44cb-ad05-c26acd9fc488	Hot Boyz	207093	19
8050	1459	1326	b6305b4c-11e2-4d6f-a933-d293a98c803a	Sun Is Shining (radio De Luxe edit)	232014	20
8051	1460	1290	236c4951-f779-4ae1-ab61-741cf0a2133c	It's Gonna Be Me	190826	1
8052	1460	1327	99d6c5fe-9a66-4a65-a634-f56ef2227c91	Give Me Just One Night (Una Noche)	204333	2
8053	1460	1300	d03d4fe1-d7d2-49d5-ba88-2ea4a11d36cf	Jumpin' Jumpin'	227373	3
8054	1460	1328	485efb74-9534-4573-804c-a01b27a0e141	Don't Think I'm Not	230066	4
8055	1460	1329	e420971d-e576-487d-87bd-13957736933d	I Think I'm in Love With You	216226	5
8056	1460	1330	736fc502-7873-4448-ae7f-5af3df13730a	Faded	204666	6
8057	1460	1331	3442b217-01fb-4f38-98f3-decb29763c96	Shake It Fast	254173	7
8058	1460	1332	c190f780-f6e8-47f9-a888-ee74ee466bfe	Case of the Ex	231426	8
8059	1460	1333	c9c2aa11-f9f0-4caf-b413-e0e89019efeb	Aaron's Party (Come Get It)	205533	9
8060	1460	1334	fac15488-7391-496c-b167-8d5de710236b	Lucky	204640	10
8061	1460	1308	ae4cc4b8-4755-4134-b110-4a8d6e831d97	Show Me the Meaning of Being Lonely	233693	11
8062	1460	1335	fcaa5621-bff3-4349-b4e5-7104d97af3d2	Incomplete	232266	12
8063	1460	1336	dffac2bc-2580-4497-9b6c-495c320540f2	I Wanna Be With You	252866	13
8064	1460	1337	d7bbbc25-8764-437e-b2f7-629c86a71980	Doesn't Really Matter	256773	14
8065	1460	1338	1ad2b064-3a1f-4c31-aef0-568d5b1a3d5b	Back Here	217826	15
8066	1460	1339	015ce306-7941-4dec-a56f-fe1ddbcd5f8b	Absolutely (Story of a Girl)	191866	16
8067	1460	1340	c3c264b9-2b4f-4565-946e-504bb48ee930	Kryptonite	233840	17
8068	1460	1341	ab608a3e-66c6-4d22-9f74-947f20aa18ae	Wonderful	272426	18
8069	1460	1342	f68f4f52-4218-457f-9eba-0b56e6d602b8	It's My Life	223600	19
8070	1461	1343	a2f0df72-0611-4cae-97ba-d4630eedcd67	Back for Good	242293	1
8071	1461	1344	878573f5-e191-4e14-9e24-78ae2d7d7532	Especially for You	236773	2
8072	1461	1345	f31f3d58-e71a-44a8-975c-9a816cf6c45f	Stay Another Day	266626	3
8073	1461	1346	227c6350-7d1d-4978-b5b3-1487ed7c67cb	You Got It (The Right Stuff)	249200	4
8074	1461	1347	6a9326d5-8d58-476f-992a-09a15167d26c	Stay	238133	5
8075	1461	1348	3281fc15-b9e6-481c-8c57-0f49a4c692c6	Boombastic	247640	6
8076	1461	1349	3496dc0a-359f-4bf6-8e5c-8fc91e749014	Wannabe	172160	7
8077	1461	1308	1636a361-0364-4a57-b1b8-9bac1f34b086	As Long as You Love Me	211000	8
8078	1461	1350	0440546b-798a-4836-b352-6f2bdcbdfcca	Never Ever	312733	9
8079	1461	1334	cdb9ad5e-7a49-4ae2-9c63-63471bd45ffa	...Baby One More Time	210866	10
8080	1461	1290	84a7c3b4-5c8f-4895-af1c-292bcf80480a	Bye Bye Bye	199666	11
8081	1461	1351	fe5b88ec-e46e-4fbd-a6d9-7076e4cb811c	Tragedy	271266	12
8082	1461	1352	33549783-ab46-40e0-8941-c979f9422eeb	Don't Stop Movin'	231426	13
8083	1461	1353	e16b5ed6-6d4f-4aac-851b-b803851ca57d	Can't Get You Out of My Head	230266	14
8084	1461	1354	b35e1bdb-67d3-420c-888d-47772497d71a	Rock DJ	255733	15
8085	1461	1307	deee0d04-5c5a-416e-9559-8e2ade6f1612	Life Is a Rollercoaster	235333	16
8086	1461	1355	2b1e84b6-ef4c-4390-97ca-004c478cb0ba	Just a Little	233866	17
8087	1461	1356	11169207-495b-4899-9642-276d12332c6d	All Rise	224000	18
8088	1461	1357	d509a288-3166-4c0c-abaa-8eabd807fa02	Whole Again	184733	19
8089	1461	1304	cb7a1065-979c-423f-a957-2f3428ae8c37	Flying Without Wings	216400	20
7916	1450	1290	45a89256-b895-4d07-808b-ac05608429c1	Giddy Up	249960	13
7917	1451	1290	65776b8f-21cf-47bb-99e8-3660504b473c	Tearin' Up My Heart	287360	1
7918	1451	1290	681e75eb-efb6-4cc0-816f-73816a354bc9	You Got It	213066	2
7919	1451	1290	709e6196-3e0f-4726-82f1-4c6496a027ca	Sailing	276973	3
7920	1451	1290	ede6e302-5d5e-429b-ac6a-63c573574764	Crazy for You	222000	4
7921	1451	1290	1d660a11-648a-4caf-9735-bfb5b66608c9	Riddle	221133	5
7922	1451	1290	fd6d87c8-c4da-4e65-822d-596a49130066	For the Girl Who Has Everything	231360	6
7923	1451	1290	bfaf96a8-c954-4060-80ce-50c44c0f07b3	I Need Love	194866	7
7924	1451	1290	3ad4f1c0-ca53-4eca-8bad-86edb79a7012	Giddy Up	249666	8
7925	1451	1290	9ecf0a4c-9b2e-4242-9bd6-255dfbcb2005	Here We Go	216240	9
7926	1451	1290	dfea1c55-805d-4acf-aa44-ad7ce0f16fd3	Best of My Life	286493	10
7927	1451	1290	b4b8550f-4ccc-42ad-8410-87cfab8d98f3	More Than a Feeling	222706	11
7928	1451	1290	52a12817-0dc8-4488-a1df-ec2fd576b017	I Want You Back	264693	12
7929	1451	1290	d9c56e24-d37b-47bc-9d8f-bd5819c80467	Together Again	251840	13
7930	1451	1290	63e8c7c8-80f3-4b0c-957c-e248542f83b0	Forever Young	247400	14
7931	1452	1292	8c3185c1-43ce-466e-814e-4041d4f14107	Du kan gøre hvad du vil	220133	1
7932	1452	1293	ba72eb70-03c0-45bd-ae3c-2b9d5f5f851c	Miss California	206773	2
7933	1452	1294	d7095af3-7e76-4bab-9265-d8a69f6a6e5d	Daddy DJ	222666	3
7934	1452	1295	69bfe9a0-a2c2-40a5-8ab6-49fbcde9edd0	Hjertet ser (feat. Erann DD)	208720	4
7904	1450	1290	e8918777-b1ca-499e-b168-3649f0e2ea13	Tearin' Up My Heart	211000	1
7905	1450	1290	76cce4e7-c9d1-413e-a066-ff08e130dbff	I Just Wanna Be With You	243400	2
7906	1450	1290	144b3f0c-2dae-4a4c-902e-b122346cfb31	Here We Go	215866	3
7907	1450	1290	ad843218-b22f-45b6-8664-98c9539dca50	For the Girl Who Has Everything	226200	4
7908	1450	1290	e77b5548-66d5-42d7-829b-86657a6cb596	God Must Have Spent a Little More Time on You	282960	5
7909	1450	1290	fb5d01e0-2091-4fa0-bd06-20cf0f17134e	You Got It	213640	6
7910	1450	1290	e2cc2bec-29bf-4158-81bf-4e1307b83bbf	I Need Love	194960	7
7911	1450	1290	9020d8e7-aebd-4ade-95dc-f39649031034	I Want You Back	202106	8
7912	1450	1290	6d4f2747-2658-482b-ab76-8482b60d3e51	Everything I Own	238693	9
7913	1450	1290	5a22e684-b543-462c-a177-2235b7a5c36e	I Drive Myself Crazy	239733	10
7914	1450	1290	6f462501-111b-4e43-9574-7d12cb14ae5f	Crazy for You	221666	11
7915	1450	1290	8e3faaa9-e2b9-4c26-9bc8-748fd657bf61	Sailing	277640	12
7935	1452	1296	3b515287-a569-4a15-bfd6-863b9c65acb7	Samb-Adagio	185586	5
7936	1452	1297	f97f9a4b-8367-4f33-bac9-7a747e8be659	Another Day in Paradise (feat. Ray J)	274053	6
7937	1452	1298	fa799c32-a1e4-4180-becb-cd7c8c69337f	Perfect Gentleman	198133	7
7938	1452	1299	0513f9d3-bffd-4f7d-b3bc-024d92a03367	Come Along	224053	8
7939	1452	1300	36452fbe-4357-4890-9f53-4989c3989c50	Bootylicious	209466	9
7940	1452	1301	ffcdeef9-0826-4ad0-9e8f-7fe001d6c53d	It's Raining Men	226826	10
7941	1452	1290	b6cfb931-fe77-4cc1-8870-89d816b1a5f6	Pop	176160	11
7942	1452	1302	05d68ab6-7406-40ef-9efe-6108fdf7f8c6	Hey Baby	218066	12
7943	1452	1303	0a583eee-72bd-435c-93ec-9a9836f5f2fd	Romeo	205760	13
7944	1452	1304	210b959e-564d-46b9-9595-ad39813b5239	Uptown Girl	187080	14
7945	1452	1305	7783d48d-414f-4fc3-b4f2-5796a138c56f	Dream On	221186	15
7946	1452	1306	f4767b55-69a3-46e5-ba4c-c360176c26f4	Fiskene I havet	216066	16
7947	1452	1307	dbe0adba-6a99-4fbe-9330-853fbe33bcfc	Lovin' Each Day	213386	17
7948	1452	1308	2d1ebc52-ae17-4b32-83fc-b513c5089285	More Than That	222253	18
7949	1453	1290	a46bb9f8-1436-4ea7-b3fb-d997ec3f2ad5	Bye Bye Bye	201373	1
7950	1453	1290	8e158c90-bc55-4a7e-8999-52d191ffe177	It's Gonna Be Me	192426	2
7951	1453	1290	1e35ce07-7632-40e9-a2ac-ee6f87e6a314	Space Cowboy (Yippie-Yi-Yay)	263440	3
7952	1453	1290	866c09e7-d5f3-4c32-a029-d56686fc3b54	Just Got Paid	250000	4
7953	1453	1290	88428b42-3b55-4b7d-9e54-f41fa063279f	It Makes Me Ill	207893	5
7954	1453	1290	9a76541c-6219-4716-aab7-9bbb45c925b6	This I Promise You	284733	6
7955	1453	1290	5d847153-0b7f-48da-890b-4a122f12d62d	No Strings Attached	228466	7
7956	1453	1290	2724dcfc-3217-448e-9c6f-6a03750079b4	Digital Get Down	261466	8
7957	1453	1290	04e1f9a4-0a6b-4a35-874e-9fd8436da7d8	I Will Never Stop	201133	9
7958	1453	1290	efc47178-9652-41f3-949a-9955db026178	Bringin' Da Noise	213240	10
7959	1453	1290	5ad4dffe-f9d1-4705-8c87-a2df3f0b398a	That's When I'll Stop Loving You	291666	11
7960	1453	1290	c0f3862f-8e07-4d79-b29e-63639a65e556	I'll Be Good For You	235293	12
7961	1453	1290	d3107b60-5c69-4337-a468-6a8f7ed3d553	If I'm Not The One	202106	13
7962	1453	1290	2935c5a1-41fe-4a1d-96b4-f79f03f34579	I Thought She Knew	201733	14
7963	1454	1290	64580be4-9eda-4ca1-89b7-3365c43d2122	Bye Bye Bye	200560	1
7964	1454	1290	d979f2c8-90c1-4670-a417-a31eea9b477f	It's Gonna Be Me	192373	2
7965	1454	1290	a7dd8dbb-5439-443c-9f38-a758bd7dc9c9	Space Cowboy	263400	3
7966	1454	1290	2374bcad-335d-444d-b098-0a760e08f9c4	Just Got Paid	250133	4
7967	1454	1290	2c614148-f591-44e5-a314-64ae5549efe5	It Makes Me Ill	207800	5
7968	1454	1290	73638768-0b5c-4791-8a4e-5a192217a019	This I Promise You	284760	6
7969	1454	1290	cbc6d7ca-2c59-450e-881f-00e7c45a28da	No Strings Attached	228640	7
7970	1454	1290	4f361aa3-1339-4bce-a944-dcd55e104b34	Digital Get Down	261333	8
7971	1454	1290	09a9f27b-01c2-44f7-9948-f9378ee60b8f	I'll Never Stop	203000	9
7972	1454	1290	769f1cdb-8d02-48d6-9153-4357338bf336	Bringin' da Noise	211333	10
7973	1454	1290	868fa25c-5348-4161-a812-b316f463a182	That's When I'll Stop Loving You	291760	11
7974	1454	1290	86345be3-79f8-4ddf-9d3f-7f4deaf6a0f3	I'll Be Good for You	235266	12
7975	1454	1290	d57ee379-ad62-404c-a36e-3e43945e608e	If I'm Not the One	202106	13
7976	1454	1290	a5bc287c-d688-44a7-986f-090e653fbb71	I Thought She Knew	202960	14
7977	1454	1290	c64591a0-60ae-491a-9266-fae134403c17	Could It Be You	222000	15
7978	1454	1290	5b59ff98-9683-40c2-a93e-ce024bd43ca6	This Is Where the Party's At	372213	16
7979	1455	1290	14f07a28-8c8f-4c2a-8a43-a19e27f40099	Bye Bye Bye	200400	1
7980	1455	1290	c2580264-8e00-41e4-acf1-aa52a5f5decb	It's Gonna Be Me	192426	2
7981	1455	1290	d1ac2dcf-28b5-4bcd-9c7f-959d701f0754	Space Cowboy	263466	3
7982	1455	1290	714b2916-7915-4fee-9e15-a50a96a82cfc	Just Got Paid	250000	4
7983	1455	1290	2cc7cb79-22a8-48fe-bd62-6f122ca7b1a2	It Makes Me Ill	207906	5
7984	1455	1290	3c0a5b36-5e34-43b6-aba4-998a6f242a8c	This I Promise You	284760	6
7985	1455	1290	a0320f1b-7e5f-41ae-b16e-ff5611b9184b	No Strings Attached	228906	7
7986	1455	1290	ef70aaa1-efe9-4558-ae0c-83727b8dfbbb	Digital Get Down	263200	8
7987	1455	1290	9b92c3b9-8e0e-47af-a91c-0086ec6d32c1	Bringin' da Noise	212066	9
7988	1455	1290	dc56a3ef-3e3f-4b57-b3f8-a46116b7142f	That's When I'll Stop Loving You	291760	10
7989	1455	1290	6a2858ae-030c-4bb9-a60d-027b2976ff77	I'll Be Good for You	236373	11
7990	1455	1290	eb1a198c-10b3-4286-b8ed-e8542e59d9ef	I Thought She Knew	202666	12
7991	1455	1290	0c06b996-1890-445a-9561-1dfd37ac5852	I'll Never Stop	206426	13
7992	1455	1290	99257296-d8f2-4c65-a946-4743a5f42cd4	If Only in Heaven's Eyes	278840	14
7993	1455	1290	f2a00a4f-dc45-4871-a0d3-f9a0e8a82d32	Could It Be You	219800	15
7994	1456	1290	d4b4a809-0ec3-404b-b87f-ed117674ba0b	Bye Bye Bye	200400	1
7995	1456	1290	671fbe8f-1b41-48fb-868d-21de0508186c	It's Gonna Be Me	192426	2
7996	1456	1290	d8af185e-1a2f-45d1-b5bd-dd73005b3be7	Space Cowboy	263466	3
7997	1456	1290	e6f4ee7d-2141-4896-b708-3438613ec64f	Just Got Paid	250000	4
7998	1456	1290	f2629c73-164d-46a8-9243-b15d25f4da66	It Makes Me Ill	207906	5
7999	1456	1290	d2c36a97-6596-439e-9018-3d9ff08278c1	This I Promise You	284760	6
8000	1456	1290	62f92d66-ec85-43fc-b633-8d8d7ba0910e	No Strings Attached	228906	7
8001	1456	1290	eb55ad9e-0070-472c-bb04-a2127b179f27	Digital Get Down	263200	8
8002	1456	1290	819002e9-1fbc-402f-b6e1-b1246c2a2853	Bringin' da Noise	212066	9
8003	1456	1290	dc1a30d8-dab6-4960-a3ec-a8d85c996f5b	That's When I'll Stop Loving You	291760	10
8004	1456	1290	7d3acea0-1ce7-4dd5-97d0-359453bbca40	I'll Be Good for You	236373	11
8005	1456	1290	cfe6c921-bfa6-47d1-bd32-fab242f9eac5	I Thought She Knew	202333	12
8006	1457	1290	03e1ec9e-7d12-44c3-830f-bdd631fc6cd7	Bye Bye Bye	202786	1
8007	1457	1290	d0f6da35-48b4-489d-9d19-c0881625e8a6	It's Gonna Be Me	193600	2
8008	1457	1290	1fde75bb-9483-4900-86c2-4fe1526afc1d	Space Cowboy	264413	3
8009	1457	1290	793c6c35-25ad-4133-8236-b38f171d1b91	Just Got Paid	250626	4
8010	1457	1290	191ef811-05eb-4218-b98e-83063c2d1119	It Makes Me Ill	208026	5
8011	1457	1290	aec2ef6c-672b-457e-b17e-06960cc0c214	This I Promise You	285200	6
8012	1457	1290	66f07e13-9aad-4ca0-b5af-5e395a0ae11f	No Strings Attached	228840	7
8013	1457	1290	fa844934-e783-4d78-9b50-49d2bc5bd357	Digital Get Down	264320	8
8014	1457	1290	c17995d6-774f-43f6-8155-a92c64f1bb8c	Bringin Da Noise	212506	9
8015	1457	1290	d7f4a379-11a9-4878-88f9-411bea3bed84	That's When I'll Stop Loving You	292346	10
8016	1457	1290	fb467c51-9582-4f9f-b5e7-95c159d6eadf	I'll Be Good For You	236800	11
8017	1457	1290	672b9f77-ecd3-4265-a964-5f5b3e40cf71	I Thought She Knew	201960	12
8018	1457	1290	b8ee546b-c3b8-4371-aed6-488041c47f12	Yo Te Voy A Amar	267666	13
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
-- Name: metadata_match2_file_id_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY metadata_match
    ADD CONSTRAINT metadata_match2_file_id_key UNIQUE (file_id, metatrack_id);


--
-- Name: metadata_match2_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY metadata_match
    ADD CONSTRAINT metadata_match2_pkey PRIMARY KEY (metadata_match_id);


--
-- Name: metatrack_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY metatrack
    ADD CONSTRAINT metatrack_pkey PRIMARY KEY (metatrack_id);


--
-- Name: metatrack_track_mbid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY metatrack
    ADD CONSTRAINT metatrack_track_mbid_key UNIQUE (track_mbid);


--
-- Name: puid_metatrack_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY puid_metatrack
    ADD CONSTRAINT puid_metatrack_pkey PRIMARY KEY (puid_id, metatrack_id);


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
-- Name: metadata_match2_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY metadata_match
    ADD CONSTRAINT metadata_match2_file_id_fkey FOREIGN KEY (file_id) REFERENCES file(file_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: metadata_match2_metatrack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY metadata_match
    ADD CONSTRAINT metadata_match2_metatrack_id_fkey FOREIGN KEY (metatrack_id) REFERENCES metatrack(metatrack_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: puid_metatrack_metatrack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY puid_metatrack
    ADD CONSTRAINT puid_metatrack_metatrack_id_fkey FOREIGN KEY (metatrack_id) REFERENCES metatrack(metatrack_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: puid_metatrack_puid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY puid_metatrack
    ADD CONSTRAINT puid_metatrack_puid_id_fkey FOREIGN KEY (puid_id) REFERENCES puid(puid_id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: metatrack; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE metatrack FROM PUBLIC;
REVOKE ALL ON TABLE metatrack FROM canidae;
GRANT ALL ON TABLE metatrack TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE metatrack TO locutus;


--
-- Name: puid; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE puid FROM PUBLIC;
REVOKE ALL ON TABLE puid FROM canidae;
GRANT ALL ON TABLE puid TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE puid TO locutus;


--
-- Name: puid_metatrack; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE puid_metatrack FROM PUBLIC;
REVOKE ALL ON TABLE puid_metatrack FROM canidae;
GRANT ALL ON TABLE puid_metatrack TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE puid_metatrack TO locutus;


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
-- Name: v_album_lookup; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE v_album_lookup FROM PUBLIC;
REVOKE ALL ON TABLE v_album_lookup FROM canidae;
GRANT ALL ON TABLE v_album_lookup TO canidae;
GRANT SELECT ON TABLE v_album_lookup TO locutus;


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
-- Name: metatrack_metatrack_id_seq; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON SEQUENCE metatrack_metatrack_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE metatrack_metatrack_id_seq FROM canidae;
GRANT ALL ON SEQUENCE metatrack_metatrack_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE metatrack_metatrack_id_seq TO locutus;


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

