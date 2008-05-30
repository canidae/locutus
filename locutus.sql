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
    released character varying NOT NULL
);


ALTER TABLE public.file OWNER TO canidae;

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
    album_title character varying NOT NULL
);


ALTER TABLE public.metatrack OWNER TO canidae;

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

SELECT pg_catalog.setval('album_album_id_seq', 1437, true);


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

SELECT pg_catalog.setval('artist_artist_id_seq', 1287, true);


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
-- Name: metatrack_metatrack_id_seq; Type: SEQUENCE; Schema: public; Owner: canidae
--

CREATE SEQUENCE metatrack_metatrack_id_seq
    START WITH 1
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

SELECT pg_catalog.setval('metatrack_metatrack_id_seq', 1, false);


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

SELECT pg_catalog.setval('track_track_id_seq', 2825, true);


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

COPY album (album_id, artist_id, mbid, type, title, released, custom_artist_sortname, loaded, updated) FROM stdin;
1114	977	711633d2-5ccc-44e1-9d32-4b401bca2716	Album Official	*NSYNC	1998-03-24	\N	t	2008-05-21 23:04:06.739697
1115	977	f6010e25-d302-4848-9b07-53f715c363bb	Album Official	*NSync	1998-03-24	\N	t	2008-05-21 23:04:08.223706
1116	978	79024eb2-513b-484b-9301-bb3884cd047d	Compilation Official	Absolute Music 27	\N	\N	t	2008-05-21 23:04:09.338158
1117	977	5f68e32a-ccc1-4b01-a4de-daa880bf3864	Album 	No Strings Attached	2001-01-01	\N	t	2008-05-21 23:04:10.853327
1118	977	631c7d7a-fca8-4891-bf02-47462cff37a5	Album Official	No Strings Attached	2000-01-01	\N	t	2008-05-21 23:04:11.920143
1119	977	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	Album 	No Strings Attached	\N	\N	t	2008-05-21 23:04:12.940181
1120	977	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	Album Official	No Strings Attached	2000-03-21	\N	t	2008-05-21 23:04:25.002103
1121	978	70666922-6d32-41fc-b208-0b91c42c35a1	Compilation Official	Now That's What I Call Music! 5	2000-11-14	\N	t	2008-05-21 23:04:26.385476
1122	978	130dde16-0fee-428f-820e-7ce449ed50e1	Compilation Official	Smash Hits: The Reunion (disc 2)	2003-01-01	\N	t	2008-05-21 23:04:44.360547
1157	1057	24705481-d635-4fea-955c-b4e19385c5be	\N	Live Fast, Die Young... And Leave a Flesh Eating Corpse!	\N	\N	f	2008-05-21 23:04:59.214239
1158	1061	70fc4df9-1a86-4357-aac7-0694d4248aed	\N	Hot	\N	\N	f	2008-05-21 23:05:05.048835
1159	1061	6cde22f9-e946-4e96-beb0-40817ee65a06	\N	The Inevitable	\N	\N	f	2008-05-21 23:05:05.132755
1123	1027	451c8dd6-b728-4232-a580-965e3ed0d345	\N	Cha-Cha Slide	\N	\N	f	2008-05-21 23:04:49.329625
1127	1031	7f548f1e-0022-4bbc-ba20-7d3446c7c67c	\N	Slide	\N	\N	f	2008-05-21 23:04:50.213793
1128	1032	6187a2be-1ea5-4251-890d-59e82770231a	\N	Slide	\N	\N	f	2008-05-21 23:04:50.293855
1129	1033	5e1c1803-0320-46b2-994d-9caba2cc732d	\N	Slide	\N	\N	f	2008-05-21 23:04:50.464064
1130	1034	4ca8fbb3-4de5-4871-953e-8c13e50398a1	\N	Closure	\N	\N	f	2008-05-21 23:04:50.537966
1131	1035	c50ec5c0-7c76-419b-b76b-48b19c610033	\N	Slide EP	\N	\N	f	2008-05-21 23:04:50.622154
1132	1036	281c3de3-82a7-4a9d-94fe-520b74f90c01	\N	Slide, T.S. Slide	\N	\N	f	2008-05-21 23:04:50.717982
1133	1037	77b63c06-0058-447b-a49f-ae0fb325d3da	\N	Backbone Slide	\N	\N	f	2008-05-21 23:04:50.844083
1124	1028	0714eb82-a14b-41cd-84ab-3e0352e9e317	\N	Slide	\N	\N	f	2008-05-21 23:04:49.913084
1135	1039	d96510d8-eac6-4be2-b227-a2cff6e4102f	\N	The Sax Pack	\N	\N	f	2008-05-21 23:04:54.993691
1136	1040	e76affb8-36df-4131-a148-b128c5e1c246	\N	Not Dancing for Chicken	\N	\N	f	2008-05-21 23:04:55.053914
1141	1045	799f9c69-11f2-41d6-b65f-718839dcbcf6	\N	Gobble, Gobble Song from Xaseni	\N	\N	f	2008-05-21 23:04:58.146123
1142	1046	bb7d2268-2f9c-4b97-9f6e-a04096a20e78	\N	Birdwatch	\N	\N	f	2008-05-21 23:04:58.209808
1143	1047	c6276525-bd66-4383-a870-17fb3898de8a	\N	Beatmania IIDX 5th Style Original Soundtrack	\N	\N	f	2008-05-21 23:04:58.262363
1144	1048	2853c1b1-f80a-469d-ad1a-0cd6fd850a44	\N	Mastering the Mouth Call	\N	\N	f	2008-05-21 23:04:58.321787
1138	1042	5b0caf18-d049-4275-8238-6516a4929299	\N	Sax Maniac	\N	\N	f	2008-05-21 23:04:55.161899
1139	1043	09ab6677-f2bf-4272-a6ed-dbd2815e7167	\N	 Senseless Violins	\N	\N	f	2008-05-21 23:04:55.237917
1134	1038	386991d8-e834-457b-a622-2c268fc92d68	\N	Sax As Sax Can	\N	\N	f	2008-05-21 23:04:54.941668
1125	1029	643e3857-6ae3-49a0-92ef-afaf237537bd	\N	Slide	\N	\N	f	2008-05-21 23:04:50.013831
1145	1049	dc4dec12-9e8c-471e-a00c-5e0fb545bc7a	\N	Children's Songs and Fingerplays	\N	\N	f	2008-05-21 23:04:58.402028
1146	1050	d88c8619-defc-4d0f-8adf-8ff24265494a	\N	Twisted Tunes Lost Holiday Classics	\N	\N	f	2008-05-21 23:04:58.454078
1147	1051	14baecf2-3d44-49e3-8136-f03982524776	\N	Cuntree	\N	\N	f	2008-05-21 23:04:58.545978
1148	1052	7fdf274f-1554-46d5-b0ff-93ffd7b17b14	\N	Forever	\N	\N	f	2008-05-21 23:04:58.601759
1140	1044	6f45aabb-cbcb-4cd1-913c-95c5ccb14b6e	\N	Live at the Sax Blast	\N	\N	f	2008-05-21 23:04:55.541948
1137	1041	0a13efa0-ab86-401f-8e43-d5211216be3c	\N	Tribalismo, Volume 5 (disc 2)	\N	\N	f	2008-05-21 23:04:55.110117
1149	1053	47c69012-fda7-49b5-bb47-8435648e049f	\N	Over 100! Hollywood Sound Effects	\N	\N	f	2008-05-21 23:04:58.653968
1160	1062	edbdbbf6-8022-4f98-a93f-9d58a7b32692	\N	Version 2.0	\N	\N	f	2008-05-21 23:05:05.256217
1150	1054	b416d651-46ed-4002-be15-255680dc567e	\N	Itchy Tingles	\N	\N	f	2008-05-21 23:04:58.721629
1151	1055	380a407d-80ab-4763-b3a9-ecbbd3a2b950	\N	Turdy Point Buck II (Da Sequel)	\N	\N	f	2008-05-21 23:04:58.80676
1152	1056	a47d0444-ffad-4e0f-8f31-50aff6815447	\N	Not Just a Pretty Face	\N	\N	f	2008-05-21 23:04:58.86596
1153	1057	9f73487b-83e8-4a71-8fc5-803f3938dbda	\N	Sleaze Merchants	\N	\N	f	2008-05-21 23:04:58.917856
1154	1058	164d763f-cf55-4ad5-a699-a4de0cdfbc68	\N	Rocks	\N	\N	f	2008-05-21 23:04:59.009714
1155	1059	6c027ce6-4fcd-4ca4-8eca-8dd962406d03	\N	Groovy Feeling	\N	\N	f	2008-05-21 23:04:59.069873
1156	1060	2660be83-5b98-4760-ac55-47a7fd0fce5f	\N	Trance Nation 3 (disc 2)	\N	\N	f	2008-05-21 23:04:59.126061
1161	1063	24e5b7f5-14cd-4a65-b87f-91b5389a4e3a	\N	To Bring You My Love	\N	\N	f	2008-05-21 23:05:05.333023
1162	1064	1999f959-00cb-4483-80d3-899097db1675	\N	Universal Madness (Live in Los Angeles)	\N	\N	f	2008-05-21 23:05:05.397906
1163	1065	6b932568-c30a-4801-a636-cdd6f2e76511	\N	Chris Isaak	\N	\N	f	2008-05-21 23:05:05.449628
1171	1073	ebf87923-0be7-4920-9846-5e95b7789f13	\N	Miles From Our Home	\N	\N	f	2008-05-21 23:05:06.457931
1164	1065	e1e74e44-e4c5-4960-865e-823bc0cc95d9	\N	San Francisco Days	\N	\N	f	2008-05-21 23:05:05.549776
1165	1065	e4c47222-08a4-4bc4-9733-9be16b2adf94	\N	Silvertone	\N	\N	f	2008-05-21 23:05:05.697714
1167	1069	a9455a7f-ae05-4454-90bb-84f4460b0296	\N	Emusic: Awesome 80's	\N	\N	f	2008-05-21 23:05:05.877922
1166	1066	6422fda7-c012-4d27-afed-57d7e2acdcd5	\N	Big White Lies	\N	\N	f	2008-05-21 23:05:05.749777
1168	1070	c1957083-3013-4329-8d2e-b90bb0ab09a6	\N	À Paris	\N	\N	f	2008-05-21 23:05:06.049749
1169	1071	0a5349d8-6c53-4814-9340-289df0643049	\N	Ill Communication	\N	\N	f	2008-05-21 23:05:06.109954
1172	1074	abac7c05-5a5c-4336-9c2f-18ffd175dc3a	\N	Dead Can Dance	\N	\N	f	2008-05-21 23:05:06.513596
1173	1075	55d9dcfd-fad4-403c-acba-2f1ea77f9f44	\N	Reverse	\N	\N	f	2008-05-21 23:05:08.565792
1170	1072	70eabfa6-e06a-4dbb-8e51-c84fc6e77dae	\N	Rafi's Revenge	\N	\N	f	2008-05-21 23:05:06.218022
1175	1077	a664af6d-ed52-4160-a575-faa5e8adadfc	\N	Halo in Reverse	\N	\N	f	2008-05-21 23:05:08.713637
1174	1076	23df104a-9a40-42ab-8bc6-b180620e8a81	\N	Reverse Cowgirl	\N	\N	f	2008-05-21 23:05:08.627416
1176	1078	8aaa9eff-a870-4444-9220-5385db3393b0	\N	Reverse	\N	\N	f	2008-05-21 23:05:08.817469
1177	1079	944b28b5-9675-4703-b5c6-5291b32c8b39	\N	Reverse	\N	\N	f	2008-05-21 23:05:08.86954
1178	1080	4bfb4b4c-cc12-41c5-83b4-e510546a5a17	\N	Nature in Reverse	\N	\N	f	2008-05-21 23:05:08.925678
1179	1081	d20c6f41-6969-4fab-950b-af109927589a	\N	Super Extra Bonus Party	\N	\N	f	2008-05-21 23:05:12.337692
1180	1082	063ec1e4-19a2-4c6a-8ceb-1c666a124038	\N	Autogen / Bonus	\N	\N	f	2008-05-21 23:05:15.245795
1181	1083	8d34989e-210c-4e33-8b7d-981ca74ece77	\N	Poesia Urbana, Volume 1	\N	\N	f	2008-05-21 23:05:15.341848
1182	1084	c506ca7b-babe-4d32-8195-84b1be21bb00	\N	On Earth	\N	\N	f	2008-05-21 23:05:15.397908
1183	1084	e13d7601-84d2-4156-8d10-4c00976ba89d	\N	[untitled]	\N	\N	f	2008-05-21 23:05:15.585666
1184	1085	6f3d6541-bbec-43d2-921a-1d810345b461	\N	Bonus Beats EP	\N	\N	f	2008-05-21 23:05:15.769997
1185	1086	f2b1f9f7-cd57-41d9-af6a-f15e0fa6dc60	\N	Machtlos + Bonus	\N	\N	f	2008-05-21 23:05:15.821854
1126	1030	ab3df3fa-84f1-4d9f-8730-e830a4c77c3b	\N	Slide	\N	\N	f	2008-05-21 23:04:50.113852
1186	1087	daa2d60b-b8a1-4d69-9d3d-0a8e0d6aa9f9	\N	Crash and Burn	\N	\N	f	2008-05-21 23:05:18.474002
1210	1111	4872de2d-540f-4a6a-bae2-95cd2413a414	\N	Click EP	\N	\N	f	2008-05-21 23:05:24.799255
1211	1112	c4b9168b-c46e-42fa-90de-11dd9242ea9f	\N	Never Click	\N	\N	f	2008-05-21 23:05:24.86175
1212	1113	6f226ad6-5bd2-4487-b6ac-c341e84acf8d	\N	Click Clack	\N	\N	f	2008-05-21 23:05:24.917814
1225	1124	7bb48a35-b6e5-4763-9dbf-d37bf98373c9	\N	Bad Religion	\N	\N	f	2008-05-21 23:05:28.377675
1187	1088	c5c25d93-73c6-445f-b1c0-faf670f8046c	\N	Crash Crash	\N	\N	f	2008-05-21 23:05:18.525856
1188	1089	9236b13a-d4d8-4bd8-81fd-841a4fca13ed	\N	Crash	\N	\N	f	2008-05-21 23:05:19.16292
1189	1090	ecb0cec0-a4fd-43aa-aae1-34d90e14fc1b	\N	Crash	\N	\N	f	2008-05-21 23:05:19.217475
1190	1091	bca68eef-abdc-4470-8e55-580bb3e254c3	\N	Crash	\N	\N	f	2008-05-21 23:05:19.269478
1191	1092	0e30fe7f-9a9e-4d12-90c0-f91173988dc4	\N	Crash	\N	\N	f	2008-05-21 23:05:19.321578
1192	1093	d2cbf3c2-3669-4464-9e62-cc97f239aeb1	\N	Crash	\N	\N	f	2008-05-21 23:05:19.373561
1193	1094	95ca11ae-43a1-428d-bc4a-333ea30d7da2	\N	CRASH	\N	\N	f	2008-05-21 23:05:19.429826
1194	1095	fc78a2e8-ed51-444c-894c-a19c273dcf0f	\N	Crash	\N	\N	f	2008-05-21 23:05:19.485696
1195	1096	8ca0c3f3-7a51-4418-8512-aef94d3a80d6	\N	Crash	\N	\N	f	2008-05-21 23:05:19.537673
1196	1097	97385060-8d28-4179-9873-05eeb6417089	\N	Crash	\N	\N	f	2008-05-21 23:05:19.589591
1197	1098	95d16d50-82c9-4381-babe-d8f36f2b8ab7	\N	Crash Crash	\N	\N	f	2008-05-21 23:05:19.641555
1198	1099	7e7ef5df-81b5-4127-85fa-3903aad28623	\N	Crash	\N	\N	f	2008-05-21 23:05:19.697576
1199	1100	51917f3d-7033-49aa-8c89-a9aee4f5ad49	\N	Crash	\N	\N	f	2008-05-21 23:05:19.753464
1200	1101	b0e91b50-ea4c-43a1-bc7f-91b867382543	\N	Crash!	\N	\N	f	2008-05-21 23:05:19.805818
1226	1125	f17007db-6ae1-4b86-a559-50423af6d816	\N	Bad Power	\N	\N	f	2008-05-21 23:05:28.477889
1202	1103	03d6f632-4174-4686-8869-dc08f5d95c72	\N	Sentenced / Orphaned Land	\N	\N	f	2008-05-21 23:05:21.729893
1203	1104	5127e87d-3fab-4e35-8e80-e9e4cbef2db8	\N	Dronning Mauds Land	\N	\N	f	2008-05-21 23:05:21.786562
1239	1132	4983d5b3-6715-4ec0-8e26-b8f8c1f66076	\N	Laughter, Tears and Rage	\N	\N	f	2008-05-21 23:05:32.349396
1228	1120	d43a2a42-0867-491f-a95b-71a64e0e71ef	\N	The Original Bad Co. Anthology (disc 2)	\N	\N	f	2008-05-21 23:05:28.617547
1227	1120	191f7ef5-d208-4959-8422-1159844bebb3	\N	The Original Bad Co. Anthology (disc 1)	\N	\N	f	2008-05-21 23:05:28.570131
1229	1126	2929543b-3ad7-4c4a-bd02-b1bf9796e6f2	\N	Booth and the Bad Angel	\N	\N	f	2008-05-21 23:05:28.717903
1204	1105	63ab3563-e6d6-4c64-b1ce-32832a7b432b	\N	Land	\N	\N	f	2008-05-21 23:05:21.845796
1205	1106	674302e9-bc9c-45da-933c-33fa0eca90c5	\N	Reality Channel: An Introduction to the Land of Nod	\N	\N	f	2008-05-21 23:05:22.226365
1206	1107	8fea7beb-a288-4609-acf7-07f31d1a413e	\N	Land	\N	\N	f	2008-05-21 23:05:22.281583
1207	1108	9100632c-2fcf-4bbf-8936-a67ef581d366	\N	Land	\N	\N	f	2008-05-21 23:05:22.333605
1214	1115	527d3180-8b23-4307-affb-d14a3c1d4d5c	\N	Click-B	\N	\N	f	2008-05-21 23:05:25.041841
1215	1116	00593e9c-13b8-4dfc-9561-bea603f28f82	\N	Down And Dirty [1995]	\N	\N	f	2008-05-21 23:05:25.618149
1216	1117	8b4d5ac2-e344-475a-8bbc-fd9ad256cacf	\N	Ali Click	\N	\N	f	2008-05-21 23:05:25.674917
1213	1114	f8d6c257-aad9-4456-a9a4-26ee0f1ec6cc	\N	Double Click	\N	\N	f	2008-05-21 23:05:24.969961
1201	1102	d8060ab4-6069-4647-8dde-28b7cee24da3	\N	Colors of the Land	\N	\N	f	2008-05-21 23:05:21.675006
1217	1117	0a993218-0d52-4ad2-8218-ec6c7858076b	\N	Ali Click	\N	\N	f	2008-05-21 23:05:25.777568
1208	1109	679ee404-acf1-4bff-a2c5-eca99c9e8df0	\N	Promised Land	\N	\N	f	2008-05-21 23:05:22.817837
1209	1110	3b436248-9c4c-4057-829f-c4e0b7e335d6	\N	Click	\N	\N	f	2008-05-21 23:05:24.741846
1218	1118	2e6809d8-1f76-498f-be89-cdd58506f143	\N	Double Click Vinyl	\N	\N	f	2008-05-21 23:05:25.83401
1230	1127	76b1e838-2033-4982-a331-d29e5bcac941	\N	 the Queen	\N	\N	f	2008-05-21 23:05:28.778007
1219	1119	2fd6a0ff-7fe4-4158-ab9e-bc94896a5c75	\N	Le Click (feat. Kayo)	\N	\N	f	2008-05-21 23:05:25.885913
1220	1120	72aa1327-36c7-446f-8816-c46593138d83	\N	Bad Company	\N	\N	f	2008-05-21 23:05:27.909934
1221	1121	510df351-a3ab-4334-9a6d-915fb4fe6eb1	\N	Bad Ronald	\N	\N	f	2008-05-21 23:05:27.973214
1231	1128	51be96ae-ed6e-43fe-bc2a-7081d65dc42e	\N	Hot Girls, Bad Boys	\N	\N	f	2008-05-21 23:05:28.830223
1223	1123	aeb528bf-5594-4ac5-99f1-574e17a2c617	\N	Bad Times	\N	\N	f	2008-05-21 23:05:28.085643
1222	1122	615cc01c-ca28-4b62-b80e-8a25fb1d75d0	\N	Bad News	\N	\N	f	2008-05-21 23:05:28.033648
1224	1122	b2feb7c1-8668-4052-a7db-20e547d31190	\N	Bad News	\N	\N	f	2008-05-21 23:05:28.133321
1240	1132	b12019f5-3d66-41c5-a79c-f27f85026ff3	\N	Laughter, Tears and Rage: The Anthology (disc 1: (More) Laughter, Tears and Rage)	\N	\N	f	2008-05-21 23:05:32.397949
1233	1128	fc04d1b7-1c03-48a1-b032-2abd7ca2911e	\N	Super 20 - Bad Boys Blue	\N	\N	f	2008-05-21 23:05:28.934086
1232	1128	b0c08032-a0e9-4e64-a90a-93a52b59096f	\N	Bad Boys Best	\N	\N	f	2008-05-21 23:05:28.881688
1234	1129	5aee618e-8f79-4b6c-bbdb-5eeb86326ed8	\N	 The Big Bad Blues	\N	\N	f	2008-05-21 23:05:29.045954
1235	1130	aa06acce-1cd8-4082-9550-630e2b1c5300	\N	Bad	\N	\N	f	2008-05-21 23:05:29.109864
1236	1130	be5e01b0-904e-4c9d-8a8d-25d096960abd	\N	Bad	\N	\N	f	2008-05-21 23:05:29.16135
1237	1131	6f342ac1-09bc-44c5-bff0-250d5f521e8b	\N	Jewelled Antler Library Vol. 1 - Green Laughter	\N	\N	f	2008-05-21 23:05:32.242407
1238	1132	13703d99-c89e-47d0-b2c3-adeca74d65a0	\N	Laughter, Tears and Rage	\N	\N	f	2008-05-21 23:05:32.297833
1241	1133	7aba2beb-d007-4aa9-adb4-98d354d50e3d	\N	God of Laughter	\N	\N	f	2008-05-21 23:05:32.449829
1245	1137	6cfc2f87-6336-4e1e-8031-803349e24cf7	\N	Where No Life Dwells / And the Laughter Has Died...	\N	\N	f	2008-05-21 23:05:33.322362
1242	1134	9693fc72-89ab-4938-9f76-46b1d0a70bbb	\N	May you always live with laughter	\N	\N	f	2008-05-21 23:05:32.506225
1243	1135	8c1e7d5c-cc5d-45a6-8ebd-f4a02e3ab0be	\N	Two Kinds of Laughter	\N	\N	f	2008-05-21 23:05:32.71387
1246	1138	7838da76-a0a4-4144-a496-857b5552fe16	\N	Laughter at Dawn	\N	\N	f	2008-05-21 23:05:33.37834
1247	1139	0d801be1-65a8-4432-8a48-7bd4292e1712	\N	 Laughter	\N	\N	f	2008-05-21 23:05:33.429791
1248	1140	445038b7-854c-4f5d-a6be-cef7b7ca410b	\N	Private Laughter	\N	\N	f	2008-05-21 23:05:33.481865
1249	1141	e1b0fe48-67e3-4cfc-9aec-ed5753cfa993	\N	Teleport	\N	\N	f	2008-05-21 23:05:35.269939
1244	1136	6b6c34ee-da29-480a-a8a1-9bd5edf26d0b	\N	Laughter's Fifth	\N	\N	f	2008-05-21 23:05:32.769903
1252	1143	d332e882-a1c5-4ec4-a7c3-6d9d705bee48	\N	Forest of the Saints	\N	\N	f	2008-05-21 23:05:36.05811
1250	1141	81eec326-d712-44fa-9582-9ea83d9146f3	\N	Teleport	\N	\N	f	2008-05-21 23:05:35.325246
1251	1142	bcaecfb9-334b-4811-82bd-360ba41824ce	\N	Teleport	\N	\N	f	2008-05-21 23:05:35.56571
1253	1141	63677dab-e665-4893-92de-16750c31776a	\N	Perfecto Fluoro (disc 1)	\N	\N	f	2008-05-21 23:05:36.11463
1254	1141	e82cb9cb-fac9-4a5e-bfc5-040c5fd85744	\N	A Voyage Into Trance, Volume 2: Dragonfly (disc 1)	\N	\N	f	2008-05-21 23:05:36.166023
1255	1141	d20bbafc-a309-4501-9029-2679974afd86	\N	A Taste of Dragonfly, Volume 2	\N	\N	f	2008-05-21 23:05:36.213858
1256	1144	1dedb025-b3ef-4159-b49d-183d1efaebb6	\N	Sweep	\N	\N	f	2008-05-21 23:05:36.26569
1257	1141	77487c22-3d7f-4ea9-a755-b354f03d16d6	\N	Dragonfly Classix (disc 1)	\N	\N	f	2008-05-21 23:05:36.317733
1258	1145	6702069e-6c79-4c17-9169-5b1f8e77ad48	\N	Practice Changes	\N	\N	f	2008-05-21 23:05:36.36993
1259	1141	417a29a7-9d72-4190-aedd-975d654b1634	\N	Top Of The Tips 2	\N	\N	f	2008-05-21 23:05:36.417812
1260	1141	52450bbc-94d0-4158-ac9c-354940ab51ec	\N	A Voyage Into Trance	\N	\N	f	2008-05-21 23:05:36.466216
1261	1146	35f9cb16-12bb-4f40-bde6-971741cb18a9	\N	Plastic Soundations EP	\N	\N	f	2008-05-21 23:05:38.74206
1293	1170	38cd3bea-6aa4-4af0-8d5e-e0adc35c33ad	\N	Chris Sheppard: Pirate Radio Sessions, Volume 3	\N	\N	f	2008-05-21 23:05:42.57857
1262	1147	165db060-d0e8-4601-8d9d-d46b3356a438	\N	Splat!	\N	\N	f	2008-05-21 23:05:38.80183
1263	1148	cd5afc35-eaa6-4d7b-ab7b-320f7f783694	\N	Message From the Godfather	\N	\N	f	2008-05-21 23:05:38.953947
1264	1149	bdc3f275-4b29-4a5c-9238-5d3624cf0c69	\N	What's Up Matador (disc 1)	\N	\N	f	2008-05-21 23:05:39.006046
1265	1149	f427e5e3-2684-4729-b3ae-b3ed25623f5a	\N	Extra Cheese: A Matador Records Sampler	\N	\N	f	2008-05-21 23:05:39.062054
1266	1149	5eaaa02d-438f-41ea-b427-7d3ff811233f	\N	Wammo	\N	\N	f	2008-05-21 23:05:39.109636
1267	1150	34ebb028-4879-4ab0-aa7b-f66e945b073d	\N	We Score	\N	\N	f	2008-05-21 23:05:39.16181
1268	1150	1a14946f-3a34-429c-b2cb-58012ae244f3	\N	Sonic Seducer: Cold Hands Seduction, Volume XII	\N	\N	f	2008-05-21 23:05:39.214174
1269	1149	f31bb30d-46e4-45bb-bd1c-cf36c48f6c41	\N	bailterspace	\N	\N	f	2008-05-21 23:05:39.265798
1270	1149	761a8934-53f9-40c1-a72c-97a30299d32d	\N	Pop Eyed: A Flying Nun Compilation	\N	\N	f	2008-05-21 23:05:39.314114
1271	1151	4db2cf43-8ee0-49a5-9d78-989565d070a4	\N	The Floor's Too Far Away	\N	\N	f	2008-05-21 23:05:39.3816
1272	1152	d557e94c-b2c5-4ec3-add0-9b2a7ca43a41	\N	Restarter	\N	\N	f	2008-05-21 23:05:39.437832
1273	1153	2d187371-de14-4f2a-99d6-eba245628177	\N	Off Centre	\N	\N	f	2008-05-21 23:05:39.489737
1274	1146	6700925a-49cd-43ae-9054-0718e33aa1a1	\N	Rave Mission, Volume VI (disc 2)	\N	\N	f	2008-05-21 23:05:39.537833
1275	1154	058f70d2-d11f-48d4-acdd-663e9b3a23ba	\N	I'm a Wreck	\N	\N	f	2008-05-21 23:05:39.593974
1276	1155	71309cde-b19e-443c-9eb6-7cffefb0f6ac	\N	You Don't Hear Jack	\N	\N	f	2008-05-21 23:05:39.653914
1277	1156	206d8302-c74e-43be-9f28-6d2dc9dca83b	\N	Those Were Different Times: Cleveland 1972-1976	\N	\N	f	2008-05-21 23:05:39.710441
1278	1157	060a7caf-0389-4703-9be0-362444ab601f	\N	Folktronic	\N	\N	f	2008-05-21 23:05:39.770227
1279	1158	ae147f6c-8a98-4d3a-8cd5-6b014d9d6276	\N	Jimmy Eat World	\N	\N	f	2008-05-21 23:05:39.825949
1280	1159	0b2e8c21-7bb9-4238-9348-312cc1419e89	\N	The Vagrant	\N	\N	f	2008-05-21 23:05:39.881983
1281	1160	cb6022fd-f974-48c6-bf29-b7cd4180d72e	\N	The Carl Stalling Project, Volume 2: More Music From Warner Bros. Cartoons 1939-1957	\N	\N	f	2008-05-21 23:05:39.938442
1282	1161	cb5bfe93-c123-449c-8302-3e6bfad11aaf	\N	25 Ways to Pick Up a Chick	\N	\N	f	2008-05-21 23:05:39.997913
1283	1162	bdc38381-8c0e-4e56-b42b-fb49f4e37803	\N	The Blood Splat Rating System	\N	\N	f	2008-05-21 23:05:40.146083
1284	1163	d84b73c1-2257-4f67-9c97-784309471660	\N	The Innocents	\N	\N	f	2008-05-21 23:05:42.085903
1285	1164	3345c1ef-6602-46e4-b78c-63656116e3a1	\N	Murphy's Law	\N	\N	f	2008-05-21 23:05:42.141674
1286	1165	17cbd86a-7435-4d81-8621-fa28321ff7ff	\N	Rhythm and Rave	\N	\N	f	2008-05-21 23:05:42.197816
1287	1166	25838421-8c01-42d3-9ee1-c697301e97ea	\N	Dirty Money, Dirty Tricks	\N	\N	f	2008-05-21 23:05:42.253944
1288	1167	94197c96-3899-4991-b38d-2a5c02a73da8	\N	Body Head Bangerz, Volume 1	\N	\N	f	2008-05-21 23:05:42.309887
1289	1168	7da712db-de00-4159-8c30-618ba7870046	\N	Katram savu Atlantīdu	\N	\N	f	2008-05-21 23:05:42.366075
1290	1167	0d502875-781c-4b34-8bf9-64910a926948	\N	Body Head Bangerz, Volume One	\N	\N	f	2008-05-21 23:05:42.413531
1291	1164	018dee79-5c40-4332-9d0f-5d4969c7a9bd	\N	Back With a Bong	\N	\N	f	2008-05-21 23:05:42.461895
1292	1169	4d6b8847-3db9-4aab-b950-b883c33902db	\N	24 Hour Party People	\N	\N	f	2008-05-21 23:05:42.513998
1306	1181	480451a0-3d3c-4663-a804-a46f1a171b3b	\N	Elements of Life	\N	\N	f	2008-05-21 23:05:47.68979
1315	1189	46f5ae31-cde7-4e9f-af2b-032f67b18b6b	\N	Die Lollipops	\N	\N	f	2008-05-21 23:05:52.213793
1308	1179	f54ffc44-1500-417d-aeee-dc39a9351d7c	\N	Scienz of Life (Metaphysic)	\N	\N	f	2008-05-21 23:05:47.809645
1295	1171	34cf087f-b87a-48c0-b61c-3b394bf25342	\N	Reckless Kelly	\N	\N	f	2008-05-21 23:05:42.833624
1296	1172	be86d574-9303-4404-be55-7d6719c4ea77	\N	Tiny Murders	\N	\N	f	2008-05-21 23:05:42.989988
1297	1173	35cc1c4b-bef0-401e-9e23-f1c8db8964a1	\N	Café de Luna	\N	\N	f	2008-05-21 23:05:43.053995
1298	1174	3acd3387-6379-42db-9bbe-21082cb17e6a	\N	Oral Hygiene	\N	\N	f	2008-05-21 23:05:43.105756
1299	1175	b497663d-eae3-480d-a52a-34547d370106	\N	 Politics	\N	\N	f	2008-05-21 23:05:43.161976
1300	1173	3e27becf-f034-4147-9219-e523a35f89b4	\N	Eurosonic Experiences	\N	\N	f	2008-05-21 23:05:43.213886
1301	1176	ba25d907-aff5-4d1c-90df-8d7e8d440ace	\N	Supaman (feat. DJ Scream)	\N	\N	f	2008-05-21 23:05:43.270002
1302	1173	14400ee5-7f7f-418b-8b8f-12609f5a323a	\N	Café de Luna	\N	\N	f	2008-05-21 23:05:43.321419
1294	1177	8b14f377-af30-41b1-a3e9-37cc75a0cdc6	\N	Young Einstein	\N	\N	f	2008-05-21 23:05:42.638021
1303	1178	04543ac0-9182-4f1c-8ad0-f93b38247402	\N	Second Life	\N	\N	f	2008-05-21 23:05:47.477833
1316	1190	11fc9ec7-96b7-4875-be8f-b7796e6f73f9	\N	Die Originalmusik	\N	\N	f	2008-05-21 23:05:52.270115
1304	1179	6a48ee3b-aa5f-49d4-9c24-9744917c26fb	\N	Scienz of Life (Metaphysics 2030)	\N	\N	f	2008-05-21 23:05:47.533969
1305	1180	51d335fe-37f6-4ce0-be6c-e701995171c6	\N	Natural Life	\N	\N	f	2008-05-21 23:05:47.585747
1317	1191	b1012fba-afaf-4732-8e48-76a76361fa8b	\N	 Die Dicken	\N	\N	f	2008-05-21 23:05:52.326026
1310	1184	e2a87748-0cbc-438c-9eda-8c38fb355b1e	\N	Look!! There Is Life On Earth	\N	\N	f	2008-05-21 23:05:48.078458
1307	1182	9d5681f8-93f4-415f-baec-3be027d0cff0	\N	Inner Life II	\N	\N	f	2008-05-21 23:05:47.757724
1309	1183	2567587c-9b85-405f-b930-21cf46c9294f	\N	Life After Death	\N	\N	f	2008-05-21 23:05:48.021709
1311	1185	49d8714f-f754-442d-a831-476888f31715	\N	Everyday Life	\N	\N	f	2008-05-21 23:05:48.277848
1312	1186	21a4a0a8-1236-4da6-bab2-24d886f57667	\N	Die Trying	\N	\N	f	2008-05-21 23:05:52.041767
1313	1187	cfe5f5e5-4a92-45b8-8468-170abbad54c8	\N	Die Bestie in Menschengestalt	\N	\N	f	2008-05-21 23:05:52.094046
1319	1190	22d4c39a-663f-4e5a-af33-42748365ac69	\N	Die drei ??? und die silberne Spinne	\N	\N	f	2008-05-21 23:05:52.433983
1320	1193	3d82dc59-45be-4955-b20d-2ebdf3c2b7d6	\N	Die! Die! Die!	\N	\N	f	2008-05-21 23:05:52.552261
1321	1194	0e2eb022-e3d3-4a4f-9311-7f02129e54eb	\N	Die Randgruppencombo spielt Gundermann ... live in Ostberlin	\N	\N	f	2008-05-21 23:05:52.634925
1314	1188	4dfc6ef6-310d-4ddc-8d93-8816790bc74f	\N	Die Interessanten: Singles 1992-2004	\N	\N	f	2008-05-21 23:05:52.15813
1322	1195	b60aff1a-dd3c-49b8-b3e3-e2061f2cd0a4	\N	Die Eine 2005	\N	\N	f	2008-05-21 23:05:52.887362
1324	1197	dcc57b33-acd9-4c53-b5bc-f691b565efad	\N	Die Fette 13	\N	\N	f	2008-05-21 23:05:53.146429
1318	1192	9e9eb634-4163-4a5b-bce6-16b5e39843e8	\N	Die Nullnummer	\N	\N	f	2008-05-21 23:05:52.381916
1325	1198	bef2a1a5-d970-4895-8c24-2c2632671b8a	\N	Die da!?!	\N	\N	f	2008-05-21 23:05:53.304606
1326	1188	9e9ce7e1-a7f6-4feb-a4ae-d734514dfdab	\N	Der Traum ist aus oder Die Erben der Scherben	\N	\N	f	2008-05-21 23:05:53.400964
1327	1188	66d0331b-8b53-4af2-997e-0922904be04d	\N	Von allen Gedanken schätze ich doch am meisten die interessanten	\N	\N	f	2008-05-21 23:05:53.478293
1328	1192	581b4e52-8abf-4c9f-8b23-a2321fa7fc78	\N	Säue vor die Perlen	\N	\N	f	2008-05-21 23:05:53.570193
1323	1196	aa1f3771-1652-4687-b193-e987fb562828	\N	Die Zeit ist reif	\N	\N	f	2008-05-21 23:05:53.057342
1329	1187	f992dc22-4fd6-4c90-9d27-303c52b57491	\N	Doktorspiele uner(ge)hört (Die nackte Wahrheit)	\N	\N	f	2008-05-21 23:05:53.798506
1330	1190	95cfbb0b-cedb-4b32-8c99-6a10bc8f176a	\N	Die drei ??? und das düstere Vermächtnis	\N	\N	f	2008-05-21 23:05:53.880042
1331	1195	3cdfd752-9fd3-436f-9f28-3f87b0a860ab	\N	Scheiß auf die Hookline	\N	\N	f	2008-05-21 23:05:53.987941
1332	1199	a7f36ac4-faf7-499c-918c-ae2e65ac601c	\N	Die Rückkehr des Unbegreiflichen	\N	\N	f	2008-05-21 23:05:54.075906
1333	1200	2c85a6e7-d28d-48c1-8a50-73b83fa65ff4	\N	Turn	\N	\N	f	2008-05-21 23:05:55.857987
1334	1200	9e559780-b97e-4a0e-946f-55d7693cfb1a	\N	Turn	\N	\N	f	2008-05-21 23:05:55.909524
1335	1201	fb11346f-e6d4-4380-840b-e12e2686d08f	\N	Turn	\N	\N	f	2008-05-21 23:05:55.99765
1336	1200	ed3fa535-ddda-4e5b-81f5-bb2710fa3efa	\N	Turn	\N	\N	f	2008-05-21 23:05:56.053514
1337	1202	57e8a05d-3b0b-48dd-b3fc-d45a94580ef7	\N	Turn	\N	\N	f	2008-05-21 23:05:56.109664
1362	1210	8a16395a-7d72-4c56-ba8c-fa75c4ea805d	\N	Komm Küssen Kompilation #3	\N	\N	f	2008-05-21 23:06:00.565518
1363	1223	1524655e-fda8-4356-9d62-747b3cc41dfb	\N	POPlastik 1985-2005	\N	\N	f	2008-05-21 23:06:00.622413
1378	1237	04b50f9f-f854-4f15-ae90-51f79b203e30	\N	Alpha Lemur Echo Two	\N	\N	f	2008-05-21 23:06:02.585982
1364	977	49951cc4-dfcc-43d6-9ab4-0cf195089e22	\N	Pop	\N	\N	f	2008-05-21 23:06:00.677688
1365	1224	f91a1093-2312-4bc8-8e38-5e52114bcaf6	\N	Future Electro Star	\N	\N	f	2008-05-21 23:06:00.833931
1338	1203	53362439-8c3e-4b3a-95c6-a67ba5fcc85f	\N	Turn On	\N	\N	f	2008-05-21 23:05:56.165888
1339	1204	8fe103fe-b7d5-455b-b617-0f5aad8bf73f	\N	Catch Your Breath	\N	\N	f	2008-05-21 23:05:56.718169
1340	1205	a1b86f66-c41c-4a56-a195-560a90545273	\N	Turn	\N	\N	f	2008-05-21 23:05:56.78182
1341	1206	f52695e8-b4d8-4a1a-9ce5-af9971aa1d3d	\N	Just Turn	\N	\N	f	2008-05-21 23:05:56.83887
1342	1207	9a86e7f1-3ddb-4265-ae5f-2a80bdc11f6b	\N	Turn	\N	\N	f	2008-05-21 23:05:56.897673
1343	1208	7b8b9dcc-1ecc-48ea-9c25-9a1a85528964	\N	Turn	\N	\N	f	2008-05-21 23:05:56.965664
1344	1208	0553f48d-58e0-4fce-8b35-fc266a14d890	\N	Turn	\N	\N	f	2008-05-21 23:05:57.02674
1345	1200	a638833b-b231-4810-9113-3467007e23cc	\N	Turn	\N	\N	f	2008-05-21 23:05:57.081691
1346	1200	8c9974af-f2f5-412c-ada7-903c8a0e2255	\N	Turn	\N	\N	f	2008-05-21 23:05:57.13365
1347	1209	3c8c5887-61c7-4168-88ad-661b367babe0	\N	Electric Turn to Me	\N	\N	f	2008-05-21 23:05:57.197977
1348	1210	99a73a2b-bcba-4238-8aba-c296fd829e5a	\N	Pop Tics	\N	\N	f	2008-05-21 23:05:59.63376
1349	1211	e2ede547-920d-43bf-aeec-68ff3c3c81a8	\N	Nacha Pop	\N	\N	f	2008-05-21 23:05:59.689638
1350	1212	8451eb37-ef89-413b-9193-626bc98e5d9d	\N	PSIHOMODO POP - 20 tekucih 1	\N	\N	f	2008-05-21 23:05:59.745903
1351	1213	dea30888-d8be-453e-9a8b-539804ecf481	\N	Rapid Pop Thrills	\N	\N	f	2008-05-21 23:05:59.8019
1352	1214	239385ae-8f1a-4f70-b07b-4423370236d8	\N	This Is Pop	\N	\N	f	2008-05-21 23:05:59.854655
1353	1215	06866bc5-63bd-465e-a256-52007036ea73	\N	 The Pop Riviera Group	\N	\N	f	2008-05-21 23:05:59.913744
1354	1216	52e9664a-85a1-4f3a-84ca-6a14b85ca48c	\N	Pop	\N	\N	f	2008-05-21 23:06:00.013632
1355	1217	29f7b13b-1457-4a31-b23e-b6440c608e9d	\N	6 to 7	\N	\N	f	2008-05-21 23:06:00.077724
1356	1218	2b564f11-b960-4361-aff3-2a04c93353d3	\N	Pop Pop Pop	\N	\N	f	2008-05-21 23:06:00.133803
1357	1219	d7836f80-9174-4bec-a598-a75f0f1b2ebc	\N	Pop Ambient 2005	\N	\N	f	2008-05-21 23:06:00.189941
1366	1225	fcac2901-585d-4964-a1ae-be82b73c65f5	\N	The History of the House Sound of Chicago, Volume 13	\N	\N	f	2008-05-21 23:06:00.890427
1358	1220	9700b5b9-cdf4-4fe7-8182-2c21b9124774	\N	Pop-Pop	\N	\N	f	2008-05-21 23:06:00.245596
1359	1210	24310244-8e7b-43a5-8f38-68560727f9d9	\N	Woman is the Fuehrer of the World	\N	\N	f	2008-05-21 23:06:00.394014
1360	1221	7011fd33-d20e-4b1f-b447-025f44f7b8ca	\N	 Shuvit	\N	\N	f	2008-05-21 23:06:00.449693
1361	1222	28b14920-6805-4e06-8e33-0cd959fba6b9	\N	Volume 1	\N	\N	f	2008-05-21 23:06:00.505689
1367	1226	6288dd5f-23ed-4416-b8de-86e41083e51d	\N	[non-album tracks]	\N	\N	f	2008-05-21 23:06:00.950304
1368	1227	4209f1f5-9412-422b-a87d-508611fa517f	\N	A Punk Tribute to Green Day	\N	\N	f	2008-05-21 23:06:01.010083
1369	1228	1f95f169-d087-4e8d-9840-9a6bf2698c1d	\N	Yerida	\N	\N	f	2008-05-21 23:06:02.061753
1370	1229	4f2c4f74-d00c-4c6b-9886-9365bd41a126	\N	Copland: The Populist (San Francisco Symphony feat. conductor: Michael Tilson Thomas)	\N	\N	f	2008-05-21 23:06:02.118868
1371	1230	0405347a-97ab-455f-b367-ce2dd7ae367d	\N	The Music Of Harry Partch	\N	\N	f	2008-05-21 23:06:02.178121
1372	1231	f24c7689-ec38-40b9-a58f-a51331c27f2b	\N	Personal Power II (disc 22: The Driving Force!)	\N	\N	f	2008-05-21 23:06:02.234372
1373	1232	5544db65-930f-4d2e-b23f-a5f3f5bd34fc	\N	1993-08-01: Mansfield, MA, USA (disc 2) (feat. Zakk Wylde)	\N	\N	f	2008-05-21 23:06:02.294632
1374	1233	a3bb6be6-7668-4e7e-89b4-202a5e282a30	\N	 Piano (violin: Marc Sabat, piano: Stephen Clarke)	\N	\N	f	2008-05-21 23:06:02.354193
1375	1234	3bf432f1-9f1e-4c60-a31b-bd5c66435a7e	\N	Baraka	\N	\N	f	2008-05-21 23:06:02.413662
1376	1235	984e99cc-cfe9-4600-ba0e-1e6212731d2d	\N	Sonic Continuum	\N	\N	f	2008-05-21 23:06:02.469926
1377	1236	708d6304-cf3a-4b84-abac-c15ea7d3b762	\N	The Gateway Experience Series: Wave IV: Adventure	\N	\N	f	2008-05-21 23:06:02.526398
1379	1238	7d0d4dc3-7daf-49e9-bdfc-4fb741b4a29c	\N	The Million-dollar Tattoo	\N	\N	f	2008-05-21 23:06:02.641875
1380	1239	cd130027-1b95-4b4a-9162-2b4e614e933c	\N	mov'on 8 LIVE FANTOM 091303 EASY BAZOOKA 日比谷野音	\N	\N	f	2008-05-21 23:06:02.698806
1381	978	b540abd2-04a7-4f9f-a03e-b77964cf7535	\N	 Iain 'Boney' Clark	\N	\N	f	2008-05-21 23:06:02.753968
1382	1240	a453d023-2e6c-4955-87e5-5d6b4f47b973	\N	Objects Appear	\N	\N	f	2008-05-21 23:06:04.705978
1383	1241	04c313a2-1f8f-459b-9342-e110230193a5	\N	The Electric Boogie EP	\N	\N	f	2008-05-21 23:06:04.761861
1384	1241	5fee07b3-8c0b-47a0-8d0f-dcd910317fd0	\N	Riddim CD #09	\N	\N	f	2008-05-21 23:06:04.813894
1385	1242	92e35b21-65be-4c2c-a912-ca5ff02f7893	\N	Objects in the Rear View Mirror May Appear Closer Than They Are	\N	\N	f	2008-05-21 23:06:04.870305
1386	1242	c0231ff8-c5ba-4f2d-9506-d265e1499ac6	\N	Objects in the Rear View Mirror May Appear Closer Than They Are	\N	\N	f	2008-05-21 23:06:04.925491
1387	1243	39ef5b9b-a4c4-4a86-826e-35b79746dfa5	\N	Beautiful	\N	\N	f	2008-05-21 23:06:04.981937
1388	1244	cb406cd0-17ce-4c9e-b250-3f375a68efcb	\N	dearly	\N	\N	f	2008-05-21 23:06:05.0457
1390	1246	d37bb1e1-c83b-4728-9429-06a4c120c500	\N	Without Ghosts	\N	\N	f	2008-05-21 23:06:05.59798
1391	1247	e1129df3-7979-4776-a8d4-9f7464d54215	\N	The Gothic Compilation, Part XXIV	\N	\N	f	2008-05-21 23:06:05.654354
1392	1248	c332d607-e48e-427b-af55-1e73ee54f13d	\N	Dragon Quest VIII Original Soundtrack (disc 2)	\N	\N	f	2008-05-21 23:06:05.718519
1389	1245	4ee4d5fe-fce4-47b7-a932-3b4f295fe6f3	\N	appear	\N	\N	f	2008-05-21 23:06:05.101577
1393	1249	8342e937-d6f2-4c23-adb5-4eb932474c6e	\N	Dust and Glass	\N	\N	f	2008-05-21 23:06:05.778063
1394	1250	f282cbe9-95cc-42da-966d-c83e0ab79767	\N	L.A.F.M.S.: The Lowest Form of Music (disc 8: Rick Potts Solo)	\N	\N	f	2008-05-21 23:06:05.846445
1395	1251	d510f9ec-5265-4eaa-9fd4-57c8dfc55628	\N	Radios Appear	\N	\N	f	2008-05-21 23:06:05.905976
1396	1252	703ec4f1-6a9c-414e-8361-26c1b7302705	\N	Victory or Valhalla!	\N	\N	f	2008-05-21 23:06:08.886004
1397	1252	cf4111d9-bdec-4d66-8206-736f72549bc1	\N	Victory Or Valhalla!	\N	\N	f	2008-05-21 23:06:08.937499
1398	1253	6807621d-8f83-4b11-bb61-0416f5c3f593	\N	Victory / Goodbye Losers	\N	\N	f	2008-05-21 23:06:08.993837
1399	1254	247a07c5-7532-4bf0-84f0-463158dd2e34	\N	Victory Gin	\N	\N	f	2008-05-21 23:06:09.057957
1400	1255	d377c8e3-4666-45bc-9c29-60b741434c53	\N	Victory	\N	\N	f	2008-05-21 23:06:09.205845
1435	1286	2f5b27b9-bafa-4d28-9e5f-30319957dc67	\N	虫姫さま オリジナルサウンドトラック	\N	\N	f	2008-05-21 23:06:13.214582
1401	1256	e148cbb7-f544-4983-b30e-915a9ea47cb4	\N	Victory Sings at Sea	\N	\N	f	2008-05-21 23:06:09.261856
1402	1257	e24edd0d-3f8b-48ca-8e01-a6d3315feec6	\N	Victory	\N	\N	f	2008-05-21 23:06:09.809611
1403	1258	1fe84789-3b60-4db0-8df6-ae0e582a909e	\N	Victory	\N	\N	f	2008-05-21 23:06:09.865644
1404	1259	9a66a218-027e-4e30-be94-9afbbe67cc4f	\N	Victory	\N	\N	f	2008-05-21 23:06:09.921999
1405	1260	15745c97-aa70-4ad4-864c-8b2be3416c6a	\N	Victory	\N	\N	f	2008-05-21 23:06:09.977557
1406	1261	469cc119-bd9f-462c-afab-ddcdeebf7180	\N	Victory	\N	\N	f	2008-05-21 23:06:10.041552
1407	1262	afa3bf61-6b16-48a6-82b3-59e0495db759	\N	Victory	\N	\N	f	2008-05-21 23:06:10.097549
1408	1263	d99f65a2-e0ac-48c0-b372-c8917c88480d	\N	Victory!	\N	\N	f	2008-05-21 23:06:10.157748
1409	1264	0938eb42-cd1b-4e02-b85c-4b242c3470a1	\N	Victory	\N	\N	f	2008-05-21 23:06:10.221757
1410	1265	0cad5a6a-ee8a-4565-8df0-1e3525ea6ac5	\N	Victory	\N	\N	f	2008-05-21 23:06:10.277647
1411	1266	bc5c30bd-d148-4f29-8aa6-edfe8129a29c	\N	Victory	\N	\N	f	2008-05-21 23:06:10.333612
1412	1267	add288bb-930f-4ab7-8e3f-a5994083ff98	\N	Victory	\N	\N	f	2008-05-21 23:06:10.389546
1413	1268	23ebc70b-2882-4e5b-b2c1-c7ed747a7116	\N	Victory or Valhalla	\N	\N	f	2008-05-21 23:06:10.446485
1414	1269	2b08ab45-fc49-4d53-8a5a-28b08a357121	\N	Victory Day	\N	\N	f	2008-05-21 23:06:10.505774
1415	1270	717d68c1-10aa-4894-b964-0df9f19a64d0	\N	Victory Gardens	\N	\N	f	2008-05-21 23:06:10.561836
1416	1271	9173230f-44d2-4d55-9811-c06f3cb4766d	\N	Punk Ass Generosity (disc 1)	\N	\N	f	2008-05-21 23:06:12.062077
1417	1272	4558e9fd-0948-414d-be4a-4a2a8061dfd8	\N	Violated	\N	\N	f	2008-05-21 23:06:12.12191
1418	1272	5975f869-cc9c-4596-96ab-07152767f2e4	\N	Check This Out III	\N	\N	f	2008-05-21 23:06:12.173942
1419	1272	f93fe221-d9e0-46f9-8328-1f80f2043f0e	\N	Vinyl Force Presents Bastard Breaks	\N	\N	f	2008-05-21 23:06:12.273874
1420	1273	87f3f7ad-b4a1-4c39-99cd-63ab56733649	\N	Men Are Monkeys. Robots Win.	\N	\N	f	2008-05-21 23:06:12.330052
1421	1274	97e82cf1-97ae-47a4-8175-50bb45b00ebb	\N	Spending Time On The Borderline	\N	\N	f	2008-05-21 23:06:12.390107
1422	1274	65ccf0cc-fcd1-47fb-9078-2b99e257cc9f	\N	Spending Time on the Borderline	\N	\N	f	2008-05-21 23:06:12.445477
1423	1275	9ec335a4-f227-4abf-9010-4afffd9906f8	\N	Terminal	\N	\N	f	2008-05-21 23:06:12.501805
1424	1275	4f1cf575-0300-418a-948f-41277d7e33bd	\N	Ultimatum	\N	\N	f	2008-05-21 23:06:12.554464
1425	1276	56076387-31b2-46a4-abf9-45ebcbb1b28d	\N	Diverse vs. Capcom	\N	\N	f	2008-05-21 23:06:12.614533
1426	1277	f4b2b59a-10b6-416f-8a5d-6458b3fe7fcd	\N	55	\N	\N	f	2008-05-21 23:06:12.673974
1427	1278	1982ef3f-3b31-4501-ae32-4455243ff8b6	\N	Lotus Turbo Challenge 2	\N	\N	f	2008-05-21 23:06:12.730116
1428	1279	851cf6bb-a1ef-4860-9f09-a38421fa44b6	\N	Lotus III: The Ultimate Challenge	\N	\N	f	2008-05-21 23:06:12.789868
1429	1280	9a20ee07-8e60-49e0-9826-552d20ebed73	\N	Compact Disco	\N	\N	f	2008-05-21 23:06:12.857908
1430	1281	cc74e297-94cd-4948-9e6c-ae6bb8482f92	\N	Technictix	\N	\N	f	2008-05-21 23:06:12.913909
1431	1282	21e0210e-f7bb-4d86-85a1-12f970c7b40b	\N	 Bass Arena Presents DJ Hype! (disc 2)	\N	\N	f	2008-05-21 23:06:12.970044
1432	1283	e1da9abb-6368-4b31-a5f6-dda5b070e38d	\N	Parkspliced (disc 1)	\N	\N	f	2008-05-21 23:06:13.041927
1433	1284	9af449ef-83ea-4b8e-b1ba-d2a5da9624a4	\N	I Sold Gold	\N	\N	f	2008-05-21 23:06:13.097989
1434	1285	208930f8-942d-42e1-9b03-4cc5bd312e5a	\N	House of Zombie Ninja EP	\N	\N	f	2008-05-21 23:06:13.154544
1436	1281	a8754332-a206-4561-b0db-b18e828836e7	\N	怒首領蜂大往生＆エスプガルーダ -Perfect Remix-	\N	\N	f	2008-05-21 23:06:13.270771
1437	1287	bf19421e-c56c-4866-b472-d66ae0ac20df	\N	Screamixadelica: Primal Scream Remixed	\N	\N	f	2008-05-21 23:06:13.330053
\.


--
-- Data for Name: artist; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY artist (artist_id, mbid, name, sortname, loaded) FROM stdin;
1012	24d2505b-388c-46cc-8a64-48223ea6d78d	Take That	Take That	t
1013	9bd94498-68cc-4b1e-b9cf-b3ba95cffccf	 Jason Donovan	 Donovan, Jason	t
1014	ee20d564-25ca-4ef5-aba7-93a39f78ed60	East 17	East 17	t
1015	090dafe5-818c-4bba-9ebf-7e3a651a5c43	New Kids on the Block	New Kids on the Block	t
1016	7343056e-041e-4b28-a85a-58e8fb975136	Eternal	Eternal	t
1017	fc63d806-ca89-4ea3-a404-ee6de695743f	Shaggy	Shaggy	t
1018	bf0caafc-2b20-4e07-ab85-87e14ff430ce	Spice Girls	Spice Girls	t
1019	a371601f-c184-4683-806d-2eb35e88f0d7	All Saints	All Saints	t
1020	19659aa7-cd3a-4bfe-bca0-6943e9e5c6e0	Steps	Steps	t
1021	bd5cf3e9-cb6c-41f3-8c7d-e9bda3c4e721	S Club 7	S Club 7	t
1022	2fddb92d-24b2-46a5-bf28-3aed46f4684c	Kylie Minogue	Minogue, Kylie	t
1023	db4624cf-0e44-481e-a9dc-2142b833ec2f	Robbie Williams	Williams, Robbie	t
1024	02db9e84-a750-4d22-b5b1-c769e698dc6c	Liberty X	Liberty X	t
1025	9c79224c-70cd-4367-8d90-35ca99401b75	Blue	Blue	t
1026	6fda00c2-449a-4bf4-838f-038d41a07c73	Atomic Kitten	Atomic Kitten	t
1058	b6f3bebb-a7f0-4b5a-8daa-d603531beb7f	My Penis	\N	f
1059	3c3d3ad8-3935-4c00-affb-768563916f36	Fluke	\N	f
1027	89f47757-c070-4820-a3ad-6524b13dbb5a	Mr. C The Slide Man	\N	f
1031	4bd477e1-0144-4e2f-910a-829aa539b6b8	Plastic Tree	\N	f
1032	e2c00c56-8365-4160-9f40-a64682917633	Goo Goo Dolls	\N	f
1033	5da2666c-d14d-46ee-8bd1-77904f55b6bc	超飛行少年	\N	f
1034	7b21057d-f504-4a3e-be7f-6c1e4528320a	Slide	\N	f
1035	897022a8-5436-48c7-b7b4-d86b40c387d9	Scala	\N	f
1036	344cde7a-cff3-4721-a8bf-d31ded9bb147	Tony (T.S.) McPhee	\N	f
1037	7d622d47-c76e-4e2f-892e-18fe318be037	Backbone Slide	\N	f
1028	b4cadc83-7307-4196-9f2f-29ebf1650045	Lisa Germano	\N	f
1039	26a0c0f5-b37d-4a16-af6a-feabeaf473a9	The Sax Pack	\N	f
1060	e0d63978-8944-4a34-870a-f91c952f5d90	C+J Project	\N	f
1057	1b53eb94-ee7a-4689-ad4a-f2909d201bea	Blood Freak	\N	f
1044	27d9ef77-40c5-4245-82af-147e3d910316	Gordon "Sax" Beadle	\N	f
1041	59ab00f9-b3da-46d4-8b94-5e7dbb832527	Tribal Sax	\N	f
1061	31810c40-932a-4f2d-8cfd-17849844e2a6	Squirrel Nut Zippers	\N	f
1062	f9ef7a22-4262-4596-a2a8-1d19345b8e50	Garbage	\N	f
1063	e795e03d-b5d5-4a5f-834d-162cfb308a2c	PJ Harvey	\N	f
1042	4e303fcf-0f7e-42f4-b84e-454a7922e725	James White and The Blacks	\N	f
1043	f319b57a-a494-40f6-a467-3d196d3484e6	Sparks	\N	f
1038	69a56528-7c5f-48b5-b270-e1f2b1bf11eb	Sax As Sax Can	\N	f
1029	dda04604-b50a-4bd1-8780-77564c659dc0	Luna	\N	f
1064	5f58803e-8c4c-478e-8b51-477f38483ede	Madness	\N	f
1071	9beb62b2-88db-4cea-801e-162cd344ee53	Beastie Boys	\N	f
1040	fa8c0b9f-6bcb-4bbc-9ce0-7e25d72ab862	Steve Lawson	\N	f
1045	125ec42a-7229-4250-afc5-e057484327fe	[unknown]	\N	f
1046	f8cf9ab7-3c05-4c47-8f8a-c21e539a5a17	Vulva	\N	f
1047	eb9f459b-c5e9-4c21-8391-098becc23620	Kimitaka Matsumae	\N	f
1048	d8377ddc-05e7-4307-b879-cc7c3b5ba32c	Primos Game Calls	\N	f
1049	8c459110-8b2d-4a64-aa14-22af64fb5ab4	Pamela Conn Beall and Susan Hagen Nipp	\N	f
1050	a9591a2d-9317-4674-8ab5-9de8b770fcab	Bob Rivers	\N	f
1051	7a412268-1f96-4cdc-9b19-1b79c7f3bfaa	SHAT	\N	f
1052	177df2b2-a96d-4093-9970-57cda814de26	Jack O' Fire	\N	f
1053	eec63d3c-3b81-4ad4-b1e4-7c147d4d2b61	[no artist]	\N	f
1054	e2c3124c-7e90-4708-ad8c-4f3559246922	Not Breathing	\N	f
1055	81e341ac-1b9f-41fe-a851-fca0cccd4b43	Bananas at Large	\N	f
1056	92aadaca-d153-40d7-a219-b1c30d84e20d	Rowan Atkinson	\N	f
1079	c5fe606b-04d3-473e-8e32-67c4b469b80f	The Dagons	\N	f
1080	b87d230d-7f96-4d2c-b6df-810c47b9c4f3	Frames A Second	\N	f
1072	db612997-f11e-424d-8b41-cf410a433656	Asian Dub Foundation	\N	f
1065	479497d4-e7c2-4e78-972e-56e78fac3995	Chris Isaak	\N	f
1066	703c7062-cc25-47e0-919e-ef740b88c725	Chris von Sneidern	\N	f
1067	f5e31fda-bbf5-4ab6-8194-bcc9209b53f8	The Romantics	\N	f
1068	13631801-97c1-47ba-81a8-536a2522578c	Special Beat	\N	f
1069	6cb79cb2-9087-44d4-828b-5c6fdff2c957	Gary Numan	\N	f
1070	edd6a7c3-d174-4e5b-9134-0f0cc6e2b0a5	Yves Montand	\N	f
1073	b52211f1-49a2-4cd2-8535-dd1ba37ea90b	Cowboy Junkies	\N	f
1074	ccda046a-2674-4f7d-97e6-f23d6c156432	Dead Can Dance	\N	f
1075	490db27e-d941-425a-abbd-2c2b3e03f5d1	Morandi	\N	f
1077	e1914450-1e21-4073-8c8c-dcdff615f4b0	Halo in Reverse	\N	f
1086	f8653ae9-b729-4f36-99a5-e05eae90b640	Andrea Berg	\N	f
1078	57662556-5321-4f46-b375-b86174f27158	Eldritch	\N	f
1081	fc98417a-180f-464d-ac3f-534311c78eba	Super Extra Bonus Party	\N	f
1082	7df17bd2-2235-456f-bddc-ec5ba2c4f8cc	M:I:5	\N	f
1083	6ee6293b-b2d8-4b41-9c77-c216e80ddf2f	Bónus	\N	f
1076	30a72ea8-9c29-4084-9d4f-79ec29585fe0	Reverse Cowgirl	\N	f
1084	6812e5a9-3c45-4c9e-8516-4925123fbe94	Bonus	\N	f
1085	3617825d-9e4c-409a-b824-7ad1bfc5c7ed	Brassy	\N	f
1087	11f6d265-a614-49ae-b50a-838954aab9ba	Crash and Burn	\N	f
1088	a5cf65b5-3a71-47ad-8992-371b5266c450	Crash	\N	f
1089	9b58672a-e68e-4972-956e-a8985a165a1f	Howard Shore	\N	f
1090	3fc5dc30-e567-4afa-859d-24e455b2898b	Pogo Pops	\N	f
1091	56d6a50f-4be2-4796-9709-7eb88c45b63b	Mark Isham	\N	f
1092	7fe9c065-9007-430a-8554-8aba8d257c4c	Bellatrix	\N	f
1093	9aec0d9a-c5b3-45ab-839c-d60f18534437	Mesh	\N	f
1094	43342b83-fdd4-4b69-a6bc-b91e93768861	デンジャー☆ギャング	\N	f
1095	0e40e594-d217-4cf8-a130-2888119ed6c6	Ether Aura	\N	f
1096	fff4cb7d-55af-4f9a-9a18-3b2f8089efac	Rymes With Orange	\N	f
1097	9b952ee8-d45d-4a26-8066-57849d871e06	Government Issue	\N	f
1098	d7a2ea77-0850-4480-8964-246c0a3d6efe	Snog	\N	f
1099	ad5b541b-2669-4db4-a3d2-0eae9bac5c0e	Shebang	\N	f
1100	2e41ae9c-afd2-4f20-8f1e-17281ce9b472	Gwen Stefani	\N	f
1030	ed56ac0d-8879-400d-981e-4c0f404810f3	Marco Menichelli	\N	f
1101	cbaafb20-eb74-421a-85f1-2bb6341aad23	Propellerheads	\N	f
1124	149e6720-4e4a-41a4-afca-6d29083fc091	Bad Religion	\N	f
1103	3877a6a1-093c-4478-b5a6-58a99a1338db	Orphaned Land	\N	f
1104	5b1b1e09-6f08-4c80-a598-36e7593c1936	Dronning Mauds Land	\N	f
1125	3bd04950-a8f4-45bc-bcdf-df4ca3f4afcd	Bad Street Boy	\N	f
1120	0053dbd9-bfbc-4e38-9f08-66a27d914c38	Bad Company	\N	f
1105	26afb633-b3a6-4bf0-87a1-7c58251134b5	Land	\N	f
1106	154a696f-302c-46cb-844c-35084821ce78	The Land of Nod	\N	f
1107	b80f5bff-9061-4635-9a23-c9042084ac4d	Ro-robot	\N	f
1108	50fc4742-1389-45a0-8c6f-6a5159ae20c2	ᛏᛣᚱ	\N	f
1126	19172a4e-a7cb-4c96-ab5e-6058156a7481	Booth and the Bad Angel	\N	f
1127	0f211bfc-8c69-4cb7-9165-acbe4353cb0a	 the Queen	\N	f
1128	ae32393f-b7db-479b-8728-8ea28c1edb16	Bad Boys Blue	\N	f
1102	e0a2bfb3-5f89-44d0-8cca-f6fe0e5f0381	Colors of the Land	\N	f
1109	2c337062-3175-4dd0-a29b-e1936fd71812	Promised Land	\N	f
1110	3d8db5c3-36b6-4100-b62c-694b7ff50c4c	Aphelion	\N	f
1111	705221a0-1a19-4d76-b340-495137392f7e	Degrees.K	\N	f
1112	0f24bcb0-8d37-409d-aed1-92bd4e5337ed	Medicine	\N	f
1113	74023430-99ac-4517-b7a6-f0cf0120a47d	Chris Spedding	\N	f
1129	f2a9b3f1-381b-4d91-8e5b-048626baed4d	 The Big Bad Blues	\N	f
1130	f27ec8db-af05-4f36-916e-3d57f91ecf5e	Michael Jackson	\N	f
1131	12d69bd1-08e0-4bb6-9d95-0a33a2477c9b	Green Laughter	\N	f
1132	4e744284-0282-4505-9fd8-afaaa3893bc8	Act	\N	f
1133	848ae96d-0a38-47d3-a6b0-7ee8509caf60	Sonja Kandels	\N	f
1115	7857f27d-45fe-44d2-85da-92732062c45a	Click-B	\N	f
1116	6f39bb73-b44d-4f46-887e-0b2d9671fe5a	The Click	\N	f
1114	873bd840-c107-4025-8492-667faa9f501b	Infected Mushroom vs. Liranran	\N	f
1117	ff95eb47-41c4-4f7f-a104-cdc30f02e872	Brian Eno	\N	f
1118	eab76c9f-ff91-4431-b6dd-3b976c598020	Infected Mushroom	\N	f
1119	175be76f-52cc-4411-957a-9c2b0fbae0b9	Le Click	\N	f
1121	9be05c26-d8de-4bb4-b790-c627c4d3b602	Bad Ronald	\N	f
1123	05f97d2e-650e-430f-b238-fa186a7c74c4	Bad Times	\N	f
1134	cec504d4-5330-4eb4-833d-31f022001c10	Liquid Laughter Lounge Quartet	\N	f
1135	5c9bd7ed-ede8-49e2-a693-2b6b59d06f65	Sara Hickman	\N	f
1122	9dec8cb1-0b16-43d5-b7f1-b9e24997a240	Bad News	\N	f
1142	ea65e66b-c6ba-465a-ba18-380423b173b4	Kemopetrol	\N	f
1143	22cd1b33-903c-494a-81d1-d53a5c26cde3	Section X	\N	f
1144	ad2282ed-ada3-46c7-a5d6-09fb45fd3bbc	Vapourspace	\N	f
1136	8f5c6093-27ba-402d-b092-4157c93a4104	Love as Laughter	\N	f
1137	4dffdaf8-8fb8-4b3d-8088-427b1e9d1af3	Unleashed	\N	f
1138	7d4624c6-5e71-49f9-a3aa-fc9951953cbb	Jim Chappell	\N	f
1139	7b68b1b6-856a-4697-85b4-6b0851ba7c2b	Jack Radics	\N	f
1140	ffa25bb8-a082-4b47-aa4c-9ef48df98dc6	BONNIE PINK	\N	f
1145	7fb8bd7f-249f-4f14-9df8-2d91aea4afc7	Tripmaster Monkey	\N	f
1141	df369da2-c88e-473e-ab6a-d0f5ab8007c5	Man With No Name	\N	f
1286	5ae9128d-5557-48ad-a135-8f72d0fc35ee	 岩田匡治	\N	f
1287	55704c38-224f-4b75-b29f-d43653f8bc9a	Primal Scream	\N	f
995	2f569e60-0a1b-4fb9-95a4-3dc1525d1aad	Backstreet Boys	Backstreet Boys	t
978	89ad4ac3-39f7-470e-963a-56509c546377	Various Artists	Various Artists	t
994	f1cd545b-f17b-4d3a-98de-68b695bfe211	Ronan Keating	Keating, Ronan	t
991	5f000e69-3cfd-4871-8f1b-faa7f0d4bcbc	Westlife	Westlife	t
979	2b353828-6748-4ba4-bddd-493d728372c5	Christian	Christian	t
1164	4a9fae02-7de0-4cb8-97d7-1fd790d9675e	Murphy's Law	\N	f
980	7d48da7e-5eee-45df-8e89-dfaee2af82c4	Dante Thomas	Thomas, Dante	t
1169	01f4fb92-6bf0-4de5-83dc-3fe194e763bf	Happy Mondays	\N	f
1147	fcecd312-6ed9-4d16-99ce-66c16981f6d9	Jacob London	\N	f
1148	95495d6a-c1f2-4a62-b0e3-b9c5f2e9dea6	The James Taylor Quartet	\N	f
981	8a44a6c6-a5ef-4e36-8ce0-3fd1d762e563	Daddy DJ	Daddy DJ	t
982	f42fa1c3-7e90-402b-9930-3a5eccceecb7	Karen Busck	Busck, Karen	t
983	2d6a30a0-3925-4fad-84ed-a568872b081c	Safri Duo	Safri Duo	t
984	01e60eba-52df-4694-8f09-39f43abe54e9	Brandy	Brandy	t
1170	820a303d-5a80-4b82-b271-74c93ba5094b	Yahoo Boyz	\N	f
985	4f29ecd7-21a5-4c03-b9ba-d0cfe9488f8c	Wyclef Jean	Jean, Wyclef	t
986	1b4bee4d-3239-4a65-8239-b62b43c23f48	Titiyo	Titiyo	t
1186	6e39b2e4-d569-4224-8890-8b167a02609f	Die Trying	\N	f
1150	f7ab0a4c-23fc-426e-8848-fd39199c87a0	Plastic Assault	\N	f
1149	74e750a2-e662-464c-b657-120f74e17fe6	Bailterspace	\N	f
1151	5629ca87-9086-48c4-8dc4-b4a966c45067	Ozric Tentacles	\N	f
988	23207c32-6743-4982-9f46-e297b2e4eb14	Geri Halliwell	Halliwell, Geri	t
1152	33aad546-bcab-4600-b896-6455127dac3d	Tranan	\N	f
989	8d6a4455-1ae8-4e51-a481-08a85cb0141a	DJ Ötzi	Ötzi, DJ	t
1153	9a068bb8-298f-4972-ae69-d1454dfc6d0e	The John Cameron Quartet	\N	f
1146	f3d27f07-ffd2-4d14-a53e-6969bad36e77	Splat Graphix	\N	f
990	28cbf94d-0700-4095-a188-37e373b069a7	Basement Jaxx	Basement Jaxx	t
1154	a9812f7d-016e-4a55-890a-d45f544a10bd	Morsel	\N	f
1199	87cc1504-6a4d-43c4-8c2e-dbcc90b71c71	Die Lunikoff Verschwörung	\N	f
1155	498695be-0f95-4fea-9e76-4858cab4c835	Berkeley Systems	\N	f
992	8538e728-ca0b-4321-b7e5-cff6565dd4c0	Depeche Mode	Depeche Mode	t
993	1ec4c3eb-dfab-49cd-86bf-1fea72f653b7	Blå Øjne	Blå Øjne	t
1156	b5905195-a456-454a-b32d-cdeafd9bea51	The Electric Eels	\N	f
1179	d799a3d7-a232-436b-8f99-9629def8f9bd	Scienz of Life	\N	f
1157	bc4978cc-e889-436b-8a24-f2416811df85	Monsdrum	\N	f
1158	bbc5b66b-d037-4f26-aecf-0b129e7f876a	Jimmy Eat World	\N	f
1159	53d8a593-c5e9-4af8-9657-d3bf19b1bb89	Christopher Young	\N	f
1160	c85ebfaf-4bdb-47b9-9194-d1fa16c05eb2	Carl Stalling	\N	f
1161	83443f35-4617-4c1c-b75f-d535b66614f9	A Beautiful Lotus	\N	f
1162	0a41f86c-ced1-44e0-95a2-5c8b2368ab1d	Powerman 5000	\N	f
1180	d930e557-d7d6-4f84-84f2-1ca53cf85c57	Natural Life	\N	f
1163	43b58c98-3779-4b04-9a23-1c95cca3a145	Erasure	\N	f
987	a796b92e-c137-4895-9c89-10f900617a4f	Destiny's Child	Destiny's Child	t
1171	99e29d99-50d7-4acb-95fa-cd4edc2c3d08	Yahoo Serious	\N	f
1165	c8911ad7-9288-4c1b-8e19-5c4ee95ee9fa	Radioactive Goldfish	\N	f
1166	3e103047-217b-496b-b54e-1e2db4dd58b3	Acid Drinkers	\N	f
1168	e4ca6ce4-d945-40f6-8d69-6ac88d31344d	Tumsa	\N	f
1167	ab6ac71b-1a93-44ae-9cca-c732b4bbe119	Body Head Bangerz	\N	f
1172	3fa7dc7e-6aa2-4e73-9a07-a3cb34a7f5be	Real Cool Traders	\N	f
1174	3ae30c53-f401-45e0-946b-70c704078e3c	Mr. Elk and Mr. Seal	\N	f
1175	32eacb5b-4e88-495a-ad38-330b4b0da58e	Alix Dobkin	\N	f
1176	29eead4d-3793-4625-8727-c03edbb38b8b	Soulja Boy	\N	f
1173	6167114d-d6f2-4a10-8626-5878691fa4f4	Eroc and Urs Fuchs	\N	f
1177	eb53a36d-3e00-4d9f-a2b7-a9ba658966b7	Yahoo Serious and Lulu	\N	f
1178	a7064df1-dc2e-4ba5-9883-8b07b7a87cc3	Second Life	\N	f
1184	8c90827b-71a9-4766-8f1c-8eb4fb7d9603	Life on Earth!	\N	f
1189	c8ee7528-df2b-44e3-9dc5-20a67bedb1af	Die Lollipops	\N	f
1181	5c3a5cad-d6bc-46b7-9754-99feb9137a22	Elements of Life	\N	f
1182	5a1b05f4-493f-4f32-939c-e1556e2069fe	Inner Life	\N	f
1183	c5509111-6336-412a-9c1f-709f54ad6ce2	Life After Death	\N	f
1191	1b5a00e3-914a-4da5-9962-b4b364e8351e	Die Hinichen	\N	f
1192	395be6d8-3144-4f20-ae51-0edeaf7f4e13	Die Nullnummer	\N	f
1200	22a40b75-affc-4e69-8884-266d087e4751	Travis	\N	f
1193	f9b3d5a8-11eb-4f4e-a59a-1e8f30135921	Die! Die! Die!	\N	f
1185	f2e99aa1-4861-4b8f-b55e-bd088c0715ea	Life	\N	f
1194	a3cf4407-59c9-4cf6-af9d-da3908d1868c	Die Randgruppencombo	\N	f
1196	2a0b0702-6518-47f0-a1dc-5362467f12b3	Die Crackers	\N	f
1203	cf253a2e-70b0-4af6-bbe3-442bba396bf5	Turn On	\N	f
1201	5ec08a60-401c-4e61-8b86-025ff64e7204	Paul Colman Trio	\N	f
1198	7928481f-848e-4551-b658-472c0aaf0c85	Die Fantastischen Vier	\N	f
1197	619a1d9e-f323-4935-9956-896658a52af6	Die Schlümpfe	\N	f
1188	52f2c49e-43c4-4716-bf4a-0eac1c651d3a	Die Sterne	\N	f
1187	f2fb0ff0-5679-42ec-a55c-15109ce6e320	Die Ärzte	\N	f
1190	e028fab5-39ae-4ed9-b8c2-c4344d88b171	Die drei ???	\N	f
1195	59167929-4f18-49d3-b62d-45ff782249ee	Die Firma	\N	f
1202	8a5fc756-4d6e-4f47-b016-43b41901ff02	Buckfast	\N	f
1204	e0b49123-fc1a-4294-ac9e-9d067053e43e	Our Turn	\N	f
1205	a4be63a6-3240-4577-86d5-44b0e19576d9	Fredo Viola	\N	f
1206	bcc02f71-8cf4-4b9c-8b66-59809b545448	Socratic	\N	f
1207	41a52c92-753f-4da4-bd9d-a01186cbbf6a	Great Big Sea	\N	f
1208	88a4cd4e-5dee-4153-8462-0d5e43c75f47	Feeder	\N	f
1209	d9d9e10b-2150-46bf-b10a-2a77ec8b813d	Electric Turn to Me	\N	f
1210	deb9c9ba-85df-4281-9dfc-a8c55879cc3a	Pop Tarts	\N	f
1211	c3fd37fe-2f09-47a7-bae2-4b86f6d70f59	Nacha Pop	\N	f
1212	68e38dca-0ae0-4b2e-a5fa-62e39d6e89db	PSIHOMODO POP	\N	f
1213	12287703-f9d6-4f30-8c0a-297807bc9ad6	Anthemic Pop Wonder	\N	f
977	603ba565-3967-4be1-931e-9cb945394e86	*NSync	NSYNC	t
1003	45a663b5-b1cb-4a91-bff6-2bef7bbfdd76	Britney Spears	Spears, Britney	t
1214	59c0c7b0-81a0-408e-9341-a0a7403dcac4	This Is Pop	\N	f
1215	528d4671-7d6e-4dcf-9b98-c01deb62f500	 The Pop Riviera Group	\N	f
1216	6ab35662-c2bc-4171-8542-a235ec13f411	Handsome Train	\N	f
1217	767bc881-0d33-4a9f-bbe8-bd7cf86a5714	PoP	\N	f
1218	9a8ce609-ea33-4cf3-b006-a76e08311653	MIG 21	\N	f
1219	054b0483-eeb8-48ce-bb72-f1cb57ff44f9	Gas	\N	f
1244	9d9d1d36-1fed-44e2-9069-9398284e9f6c	Lia	\N	f
1220	b961732c-0c70-4bd7-94b4-843317862853	 Jay	\N	f
1221	6277c674-a9c5-4396-a992-6e155d6574ef	Pop Shuvit	\N	f
1222	b133c426-28cc-4568-87eb-cb77d7e3bb74	Fear of Pop	\N	f
1223	49e3fae1-b934-4c1e-8bfa-9197a053955f	Pop Dell'Arte	\N	f
1224	c08b95f0-5c09-439a-9c59-6a72283421b1	Sonic Coaster Pop	\N	f
1225	c57a044c-206f-41a5-8eba-f6695943961e	Pop Stars	\N	f
1226	a1ac90a8-76af-4c56-a5e0-642d4d8a863b	Pop Razors	\N	f
1227	5645a0ec-fcca-45eb-9fb7-1c26cc655ca4	Flux Pop	\N	f
1228	7ff16dfd-f03f-472f-b496-70f2b49a00a0	Ultrasound	\N	f
996	177fde26-5a95-46d9-922f-0933940d97e5	98 Degrees	98 Degrees	t
1229	aad3af83-5b59-4b86-a569-1a8409149b09	Aaron Copland	\N	f
997	888f7e18-2a96-4f2e-8320-08ff4330b442	Kandi	Kandi	t
1230	914360f1-82e2-47ff-943b-1d7b977bd27a	Harry Partch	\N	f
998	fe37acd4-893c-4b2c-8ad2-7fd394280354	Jessica Simpson	Simpson, Jessica	t
1231	131153ae-1455-48fc-9c30-6074ae5f158e	Anthony Robbins	\N	f
999	e01482f5-8865-4d25-b2f5-0ebfdf53d96c	soulDecision	soulDecision	t
1000	1cfe52d7-181a-4b3a-8041-d8bf9ccef57b	Mystikal	Mystikal	t
1232	72359492-22be-4ed9-aaa0-efa434fb2b01	The Allman Brothers Band	\N	f
1001	7c5e39c3-7645-4e37-968d-a4e45cd38c5d	Mya	Mya	t
1233	a952c1da-d7b4-44f9-97c8-27c5f5e5af59	Christian Wolff	\N	f
1002	4c0bb5bc-95ad-47de-99e3-fbb4fbc5f393	Aaron Carter	Carter, Aaron	t
1254	8afaa3ce-6442-4816-be36-f9c6972044c9	Victory Gin	\N	f
1234	03dc7b33-ff4e-45fd-aead-03799db4ae77	DKV Trio	\N	f
1235	46419465-f3d7-4683-9e0a-b80c375c9b01	 Michael Mantra	\N	f
1004	25e0497c-faa4-4765-b232-baa20e5e35a7	Sisqó	Sisqó	t
1236	81e53607-02ca-40ef-ab26-6e472380476d	Hemi-Sync	\N	f
1005	9dc9f4b0-a7b4-43c5-8f6b-fcd43c426a4b	Mandy Moore	Moore, Mandy	t
1237	29004056-4971-4ce4-8bb5-19e11179539c	O'Rourke Prime Prevost	\N	f
1006	6be2828f-6c0d-4059-99d4-fa18acf1a296	Janet Jackson	Jackson, Janet	t
1238	cfe7baf1-18e3-48c0-8caa-d15f3add37b2	Earl Emerson	\N	f
1239	7dbfbb26-7fb9-4b9d-9a76-988c0a1d5b17	黒田倫弘	\N	f
1007	0662fa9d-73b0-4f71-9576-c963a5a14f66	BBMak	BBMak	t
1240	45fc476b-9249-4fae-ace3-740196e6acea	The Shadow Project	\N	f
1241	b1741750-3d1c-438f-b06a-98520a2e11c9	Appear	\N	f
1255	2af8def8-db31-4998-8bd9-18fdd76db088	Billy Joe Shaver	\N	f
1242	b134d1bf-c7c7-4427-93ac-9fdbc2b59ef1	Meat Loaf	\N	f
1243	842360c8-9a1d-4bba-85ba-5bc19e7d8976	Minamo	\N	f
1265	33522868-f75c-4dc4-8f54-2042ce86e989	Trance	\N	f
1256	0e5eca1b-75da-4d9d-946e-85a921bd6e2d	Victory Music	\N	f
1008	c30dfb44-768a-487b-af9c-c942682aa023	Nine Days	Nine Days	t
1009	2386cd66-e923-4e8e-bf14-2eebe2e9b973	3 Doors Down	3 Doors Down	t
1245	ea3f98d1-6c31-4c50-8f34-603d1b28ab24	岩男潤子	\N	f
1010	3604c99d-c146-4276-aa0c-9376d333aeb8	Everclear	Everclear	t
1246	aee3ce7b-1975-43fd-a347-c1c1ecbde0ff	Bridge and Tunnel	\N	f
1011	5dcdb5eb-cb72-4e6e-9e63-b7bace604965	Bon Jovi	Bon Jovi	t
1247	9e679e4a-cded-4190-8bed-a48ef02cf6f4	Pronoian Made	\N	f
1248	33eef1b3-e23b-4643-ac1b-b970ad510dc5	すぎやまこういち	\N	f
1249	aa477215-ac39-4d6e-9ce3-d28877db46ac	Farfield	\N	f
1250	70d9dbbf-a712-4e09-a99a-99f82faa9027	Rick Potts	\N	f
1257	caa8844b-6a16-4100-b2ae-622b2edf5055	Half Pint	\N	f
1251	c2e2144d-d6c5-47d0-a4b4-aa859de5e0b4	Radio Birdman	\N	f
1258	ad73761f-c66d-4149-899d-21f56d1969a1	Running Wild	\N	f
1252	804a7e24-c0ae-451f-8a66-d66315bb3640	Skullhead	\N	f
1253	72c9d2f5-fd02-49b5-a496-3604d870dc72	Lourds Lane	\N	f
1266	0d3737b6-dc26-4eef-bb79-38bbe81f0cd6	Test Dept.	\N	f
1259	e10cbaee-3952-4935-b915-5957511891df	Papa San	\N	f
1260	1d3362bc-65fe-4106-b009-6f1cead58081	Steve Haun	\N	f
1261	e32e0c8a-694f-49f4-844b-8ff5336f1b82	Do or Die	\N	f
1262	38a9dd50-aafd-491f-a7ea-29a07ea9ecfa	Daan	\N	f
1263	c460939e-3b0f-4356-8566-fdf26869b9c4	Word of Life Church	\N	f
1264	2072f699-049a-4b78-b039-317a1c7cff94	 The Family	\N	f
1267	b6e7f5aa-f48e-44bd-999d-c91e985fbbcb	Gaia Epicus	\N	f
1268	3f8c37a3-2903-41ab-80ac-60a41d1e694d	Fortress	\N	f
1269	4f6654b3-0ae3-44bc-9bed-e9477446beab	Академический ансамбль песни и пляски Российской армии	\N	f
1270	c7aca277-97fa-448a-b899-0901c3bf7bcc	The People's Victory Orchestra and Chorus	\N	f
1271	5d2f8739-be62-4915-bbc7-11c1ce5bd66d	Gameover	\N	f
1272	1f6fd5b5-5013-4619-8536-422dd183c530	Gameover	\N	f
1273	94079d14-02bd-4721-bb3e-91ba24373434	Season to Risk	\N	f
1274	c0e03a06-f8b9-47ac-a50f-8ae1dbb5bd52	Ozma	\N	f
1275	f757d05a-0dd8-43bb-bda6-4bfa6a955e4b	SMP	\N	f
1276	b46a96fa-6e79-4fb7-ba91-7778e79d7ff0	k-shi	\N	f
1277	de4df0ee-a25b-48a9-a1c3-7ec06bb5f6d5	Supermarket	\N	f
1278	7e9ad754-55ac-4e82-a671-2bc77db90b23	Barry Leitch	\N	f
1279	10f89329-c3a4-40c5-81db-af17ef6af902	Patrick Phelan	\N	f
1280	01f6afbe-dce6-4012-ab59-a257e62ce29d	Tigrics	\N	f
1282	32a509d0-6c4c-43c9-b169-03b601367dbd	TC	\N	f
1283	ba853904-ae25-4ebb-89d6-c44cfbd71bd2	Blur	\N	f
1284	3f06695e-5308-48ef-b3eb-e1f8ac6ef299	Aqueduct	\N	f
1285	e64ed067-056a-4fca-9b18-3c986c2ef24c	Logicbomb	\N	f
1281	442c35ef-4bc2-40f5-8998-67c77504a693	細江慎治	\N	f
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
-- Data for Name: metatrack; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY metatrack (metatrack_id, track_mbid, track_title, duration, tracknumber, artist_mbid, artist_name, album_mbid, album_title) FROM stdin;
\.


--
-- Data for Name: possible_match; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY possible_match (file_id, track_id, meta_score, mbid_match, puid_match) FROM stdin;
194	2161	0.80000000000000004	t	f
197	2164	0.80000000000000004	t	f
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
2157	1114	977	e8918777-b1ca-499e-b168-3649f0e2ea13	Tearin' Up My Heart	211000	1
2158	1114	977	76cce4e7-c9d1-413e-a066-ff08e130dbff	I Just Wanna Be With You	243400	2
2159	1114	977	144b3f0c-2dae-4a4c-902e-b122346cfb31	Here We Go	215866	3
2160	1114	977	ad843218-b22f-45b6-8664-98c9539dca50	For the Girl Who Has Everything	226200	4
2161	1114	977	e77b5548-66d5-42d7-829b-86657a6cb596	God Must Have Spent a Little More Time on You	282960	5
2162	1114	977	fb5d01e0-2091-4fa0-bd06-20cf0f17134e	You Got It	213640	6
2163	1114	977	e2cc2bec-29bf-4158-81bf-4e1307b83bbf	I Need Love	194960	7
2164	1114	977	9020d8e7-aebd-4ade-95dc-f39649031034	I Want You Back	202106	8
2165	1114	977	6d4f2747-2658-482b-ab76-8482b60d3e51	Everything I Own	238693	9
2166	1114	977	5a22e684-b543-462c-a177-2235b7a5c36e	I Drive Myself Crazy	239733	10
2167	1114	977	6f462501-111b-4e43-9574-7d12cb14ae5f	Crazy for You	221666	11
2168	1114	977	8e3faaa9-e2b9-4c26-9bc8-748fd657bf61	Sailing	277640	12
2169	1114	977	45a89256-b895-4d07-808b-ac05608429c1	Giddy Up	249960	13
2170	1115	977	65776b8f-21cf-47bb-99e8-3660504b473c	Tearin' Up My Heart	287360	1
2171	1115	977	681e75eb-efb6-4cc0-816f-73816a354bc9	You Got It	213066	2
2172	1115	977	709e6196-3e0f-4726-82f1-4c6496a027ca	Sailing	276973	3
2173	1115	977	ede6e302-5d5e-429b-ac6a-63c573574764	Crazy for You	222000	4
2174	1115	977	1d660a11-648a-4caf-9735-bfb5b66608c9	Riddle	221133	5
2175	1115	977	fd6d87c8-c4da-4e65-822d-596a49130066	For the Girl Who Has Everything	231360	6
2176	1115	977	bfaf96a8-c954-4060-80ce-50c44c0f07b3	I Need Love	194866	7
2177	1115	977	3ad4f1c0-ca53-4eca-8bad-86edb79a7012	Giddy Up	249666	8
2178	1115	977	9ecf0a4c-9b2e-4242-9bd6-255dfbcb2005	Here We Go	216240	9
2179	1115	977	dfea1c55-805d-4acf-aa44-ad7ce0f16fd3	Best of My Life	286493	10
2180	1115	977	b4b8550f-4ccc-42ad-8410-87cfab8d98f3	More Than a Feeling	222706	11
2181	1115	977	52a12817-0dc8-4488-a1df-ec2fd576b017	I Want You Back	264693	12
2182	1115	977	d9c56e24-d37b-47bc-9d8f-bd5819c80467	Together Again	251840	13
2183	1115	977	63e8c7c8-80f3-4b0c-957c-e248542f83b0	Forever Young	247400	14
2184	1116	979	8c3185c1-43ce-466e-814e-4041d4f14107	Du kan gøre hvad du vil	220133	1
2185	1116	980	ba72eb70-03c0-45bd-ae3c-2b9d5f5f851c	Miss California	206773	2
2186	1116	981	d7095af3-7e76-4bab-9265-d8a69f6a6e5d	Daddy DJ	222666	3
2187	1116	982	69bfe9a0-a2c2-40a5-8ab6-49fbcde9edd0	Hjertet ser (feat. Erann DD)	208720	4
2188	1116	983	3b515287-a569-4a15-bfd6-863b9c65acb7	Samb-Adagio	185586	5
2189	1116	984	f97f9a4b-8367-4f33-bac9-7a747e8be659	Another Day in Paradise (feat. Ray J)	274053	6
2190	1116	985	fa799c32-a1e4-4180-becb-cd7c8c69337f	Perfect Gentleman	198133	7
2191	1116	986	0513f9d3-bffd-4f7d-b3bc-024d92a03367	Come Along	224053	8
2192	1116	987	36452fbe-4357-4890-9f53-4989c3989c50	Bootylicious	209466	9
2193	1116	988	ffcdeef9-0826-4ad0-9e8f-7fe001d6c53d	It's Raining Men	226826	10
2194	1116	977	b6cfb931-fe77-4cc1-8870-89d816b1a5f6	Pop	176160	11
2195	1116	989	05d68ab6-7406-40ef-9efe-6108fdf7f8c6	Hey Baby	218066	12
2196	1116	990	0a583eee-72bd-435c-93ec-9a9836f5f2fd	Romeo	205760	13
2197	1116	991	210b959e-564d-46b9-9595-ad39813b5239	Uptown Girl	187080	14
2198	1116	992	7783d48d-414f-4fc3-b4f2-5796a138c56f	Dream On	221186	15
2199	1116	993	f4767b55-69a3-46e5-ba4c-c360176c26f4	Fiskene I havet	216066	16
2200	1116	994	dbe0adba-6a99-4fbe-9330-853fbe33bcfc	Lovin' Each Day	213386	17
2201	1116	995	2d1ebc52-ae17-4b32-83fc-b513c5089285	More Than That	222253	18
2202	1117	977	a46bb9f8-1436-4ea7-b3fb-d997ec3f2ad5	Bye Bye Bye	201373	1
2203	1117	977	8e158c90-bc55-4a7e-8999-52d191ffe177	It's Gonna Be Me	192426	2
2204	1117	977	1e35ce07-7632-40e9-a2ac-ee6f87e6a314	Space Cowboy (Yippie-Yi-Yay)	263440	3
2205	1117	977	866c09e7-d5f3-4c32-a029-d56686fc3b54	Just Got Paid	250000	4
2206	1117	977	88428b42-3b55-4b7d-9e54-f41fa063279f	It Makes Me Ill	207893	5
2207	1117	977	9a76541c-6219-4716-aab7-9bbb45c925b6	This I Promise You	284733	6
2208	1117	977	5d847153-0b7f-48da-890b-4a122f12d62d	No Strings Attached	228466	7
2209	1117	977	2724dcfc-3217-448e-9c6f-6a03750079b4	Digital Get Down	261466	8
2210	1117	977	04e1f9a4-0a6b-4a35-874e-9fd8436da7d8	I Will Never Stop	201133	9
2211	1117	977	efc47178-9652-41f3-949a-9955db026178	Bringin' Da Noise	213240	10
2212	1117	977	5ad4dffe-f9d1-4705-8c87-a2df3f0b398a	That's When I'll Stop Loving You	291666	11
2213	1117	977	c0f3862f-8e07-4d79-b29e-63639a65e556	I'll Be Good For You	235293	12
2214	1117	977	d3107b60-5c69-4337-a468-6a8f7ed3d553	If I'm Not The One	202106	13
2215	1117	977	2935c5a1-41fe-4a1d-96b4-f79f03f34579	I Thought She Knew	201733	14
2216	1118	977	14f07a28-8c8f-4c2a-8a43-a19e27f40099	Bye Bye Bye	200400	1
2217	1118	977	c2580264-8e00-41e4-acf1-aa52a5f5decb	It's Gonna Be Me	192426	2
2218	1118	977	d1ac2dcf-28b5-4bcd-9c7f-959d701f0754	Space Cowboy	263466	3
2219	1118	977	714b2916-7915-4fee-9e15-a50a96a82cfc	Just Got Paid	250000	4
2220	1118	977	2cc7cb79-22a8-48fe-bd62-6f122ca7b1a2	It Makes Me Ill	207906	5
2221	1118	977	3c0a5b36-5e34-43b6-aba4-998a6f242a8c	This I Promise You	284760	6
2222	1118	977	a0320f1b-7e5f-41ae-b16e-ff5611b9184b	No Strings Attached	228906	7
2223	1118	977	ef70aaa1-efe9-4558-ae0c-83727b8dfbbb	Digital Get Down	263200	8
2224	1118	977	9b92c3b9-8e0e-47af-a91c-0086ec6d32c1	Bringin' da Noise	212066	9
2225	1118	977	dc56a3ef-3e3f-4b57-b3f8-a46116b7142f	That's When I'll Stop Loving You	291760	10
2226	1118	977	6a2858ae-030c-4bb9-a60d-027b2976ff77	I'll Be Good for You	236373	11
2227	1118	977	eb1a198c-10b3-4286-b8ed-e8542e59d9ef	I Thought She Knew	202666	12
2228	1118	977	0c06b996-1890-445a-9561-1dfd37ac5852	I'll Never Stop	206426	13
2229	1118	977	99257296-d8f2-4c65-a946-4743a5f42cd4	If Only in Heaven's Eyes	278840	14
2230	1118	977	f2a00a4f-dc45-4871-a0d3-f9a0e8a82d32	Could It Be You	219800	15
2231	1119	977	64580be4-9eda-4ca1-89b7-3365c43d2122	Bye Bye Bye	200560	1
2232	1119	977	d979f2c8-90c1-4670-a417-a31eea9b477f	It's Gonna Be Me	192373	2
2233	1119	977	a7dd8dbb-5439-443c-9f38-a758bd7dc9c9	Space Cowboy	263400	3
2234	1119	977	2374bcad-335d-444d-b098-0a760e08f9c4	Just Got Paid	250133	4
2235	1119	977	2c614148-f591-44e5-a314-64ae5549efe5	It Makes Me Ill	207800	5
2236	1119	977	73638768-0b5c-4791-8a4e-5a192217a019	This I Promise You	284760	6
2237	1119	977	cbc6d7ca-2c59-450e-881f-00e7c45a28da	No Strings Attached	228640	7
2238	1119	977	4f361aa3-1339-4bce-a944-dcd55e104b34	Digital Get Down	261333	8
2239	1119	977	09a9f27b-01c2-44f7-9948-f9378ee60b8f	I'll Never Stop	203000	9
2240	1119	977	769f1cdb-8d02-48d6-9153-4357338bf336	Bringin' da Noise	211333	10
2241	1119	977	868fa25c-5348-4161-a812-b316f463a182	That's When I'll Stop Loving You	291760	11
2242	1119	977	86345be3-79f8-4ddf-9d3f-7f4deaf6a0f3	I'll Be Good for You	235266	12
2243	1119	977	d57ee379-ad62-404c-a36e-3e43945e608e	If I'm Not the One	202106	13
2244	1119	977	a5bc287c-d688-44a7-986f-090e653fbb71	I Thought She Knew	202960	14
2245	1119	977	c64591a0-60ae-491a-9266-fae134403c17	Could It Be You	222000	15
2246	1119	977	5b59ff98-9683-40c2-a93e-ce024bd43ca6	This Is Where the Party's At	372213	16
2247	1120	977	d4b4a809-0ec3-404b-b87f-ed117674ba0b	Bye Bye Bye	200400	1
2248	1120	977	671fbe8f-1b41-48fb-868d-21de0508186c	It's Gonna Be Me	192426	2
2249	1120	977	d8af185e-1a2f-45d1-b5bd-dd73005b3be7	Space Cowboy	263466	3
2250	1120	977	e6f4ee7d-2141-4896-b708-3438613ec64f	Just Got Paid	250000	4
2251	1120	977	f2629c73-164d-46a8-9243-b15d25f4da66	It Makes Me Ill	207906	5
2252	1120	977	d2c36a97-6596-439e-9018-3d9ff08278c1	This I Promise You	284760	6
2253	1120	977	62f92d66-ec85-43fc-b633-8d8d7ba0910e	No Strings Attached	228906	7
2254	1120	977	eb55ad9e-0070-472c-bb04-a2127b179f27	Digital Get Down	263200	8
2255	1120	977	819002e9-1fbc-402f-b6e1-b1246c2a2853	Bringin' da Noise	212066	9
2256	1120	977	dc1a30d8-dab6-4960-a3ec-a8d85c996f5b	That's When I'll Stop Loving You	291760	10
2257	1120	977	7d3acea0-1ce7-4dd5-97d0-359453bbca40	I'll Be Good for You	236373	11
2258	1120	977	cfe6c921-bfa6-47d1-bd32-fab242f9eac5	I Thought She Knew	202333	12
2259	1121	977	236c4951-f779-4ae1-ab61-741cf0a2133c	It's Gonna Be Me	190826	1
2260	1121	996	99d6c5fe-9a66-4a65-a634-f56ef2227c91	Give Me Just One Night (Una Noche)	204333	2
2261	1121	987	d03d4fe1-d7d2-49d5-ba88-2ea4a11d36cf	Jumpin' Jumpin'	227373	3
2262	1121	997	485efb74-9534-4573-804c-a01b27a0e141	Don't Think I'm Not	230066	4
2263	1121	998	e420971d-e576-487d-87bd-13957736933d	I Think I'm in Love With You	216226	5
2264	1121	999	736fc502-7873-4448-ae7f-5af3df13730a	Faded	204666	6
2265	1121	1000	3442b217-01fb-4f38-98f3-decb29763c96	Shake It Fast	254173	7
2266	1121	1001	c190f780-f6e8-47f9-a888-ee74ee466bfe	Case of the Ex	231426	8
2267	1121	1002	c9c2aa11-f9f0-4caf-b413-e0e89019efeb	Aaron's Party (Come Get It)	205533	9
2268	1121	1003	fac15488-7391-496c-b167-8d5de710236b	Lucky	204640	10
2269	1121	995	ae4cc4b8-4755-4134-b110-4a8d6e831d97	Show Me the Meaning of Being Lonely	233693	11
2270	1121	1004	fcaa5621-bff3-4349-b4e5-7104d97af3d2	Incomplete	232266	12
2271	1121	1005	dffac2bc-2580-4497-9b6c-495c320540f2	I Wanna Be With You	252866	13
2272	1121	1006	d7bbbc25-8764-437e-b2f7-629c86a71980	Doesn't Really Matter	256773	14
2273	1121	1007	1ad2b064-3a1f-4c31-aef0-568d5b1a3d5b	Back Here	217826	15
2274	1121	1008	015ce306-7941-4dec-a56f-fe1ddbcd5f8b	Absolutely (Story of a Girl)	191866	16
2275	1121	1009	c3c264b9-2b4f-4565-946e-504bb48ee930	Kryptonite	233840	17
2276	1121	1010	ab608a3e-66c6-4d22-9f74-947f20aa18ae	Wonderful	272426	18
2277	1121	1011	f68f4f52-4218-457f-9eba-0b56e6d602b8	It's My Life	223600	19
2278	1122	1012	a2f0df72-0611-4cae-97ba-d4630eedcd67	Back for Good	242293	1
2279	1122	1013	878573f5-e191-4e14-9e24-78ae2d7d7532	Especially for You	236773	2
2280	1122	1014	f31f3d58-e71a-44a8-975c-9a816cf6c45f	Stay Another Day	266626	3
2281	1122	1015	227c6350-7d1d-4978-b5b3-1487ed7c67cb	You Got It (The Right Stuff)	249200	4
2282	1122	1016	6a9326d5-8d58-476f-992a-09a15167d26c	Stay	238133	5
2283	1122	1017	3281fc15-b9e6-481c-8c57-0f49a4c692c6	Boombastic	247640	6
2284	1122	1018	3496dc0a-359f-4bf6-8e5c-8fc91e749014	Wannabe	172160	7
2285	1122	995	1636a361-0364-4a57-b1b8-9bac1f34b086	As Long as You Love Me	211000	8
2286	1122	1019	0440546b-798a-4836-b352-6f2bdcbdfcca	Never Ever	312733	9
2287	1122	1003	cdb9ad5e-7a49-4ae2-9c63-63471bd45ffa	...Baby One More Time	210866	10
2288	1122	977	84a7c3b4-5c8f-4895-af1c-292bcf80480a	Bye Bye Bye	199666	11
2289	1122	1020	fe5b88ec-e46e-4fbd-a6d9-7076e4cb811c	Tragedy	271266	12
2290	1122	1021	33549783-ab46-40e0-8941-c979f9422eeb	Don't Stop Movin'	231426	13
2291	1122	1022	e16b5ed6-6d4f-4aac-851b-b803851ca57d	Can't Get You Out of My Head	230266	14
2292	1122	1023	b35e1bdb-67d3-420c-888d-47772497d71a	Rock DJ	255733	15
2293	1122	994	deee0d04-5c5a-416e-9559-8e2ade6f1612	Life Is a Rollercoaster	235333	16
2294	1122	1024	2b1e84b6-ef4c-4390-97ca-004c478cb0ba	Just a Little	233866	17
2295	1122	1025	11169207-495b-4899-9642-276d12332c6d	All Rise	224000	18
2296	1122	1026	d509a288-3166-4c0c-abaa-8eabd807fa02	Whole Again	184733	19
2297	1122	991	cb7a1065-979c-423f-a957-2f3428ae8c37	Flying Without Wings	216400	20
2302	1123	1027	ecd6a8be-a46e-4faa-a3e3-594b83802aa6	Mr. C's Cha-Cha Slide	387506	4
2303	1123	1027	7728bd32-8885-4f4b-b071-90a0b95397ac	Bus Stop / Electric Slide (Original)	476040	8
2304	1124	1028	7581c53c-5bab-4424-8f81-70fb7e79a883	Slide	141906	5
2298	1123	1027	8be0d36d-a4ce-451c-8bc1-36e5df1af2d0	Cha-Cha Slide (Club)	464506	2
2299	1123	1027	9e6713ed-0f85-4a48-a52f-c3bf3fbca1f2	Cha-Cha Slide (Radio)	226293	1
2300	1123	1027	2b4512d7-b5b2-4308-8426-bdca43303700	DJ Eric-B Slide	585226	9
2309	1129	1033	9e82c2b4-d244-4555-8c2e-59f0f6b3eca4	Slide	0	1
2311	1131	1035	3e4ce7da-6016-43d3-8f7e-98446ad8d5a5	Slide	182000	1
2312	1132	1036	645a6cac-91b6-45e0-9c84-3a7181292ab2	Slide to Slide	260000	3
2313	1133	1037	e44e6890-58d5-4bad-9fdc-de291940f758	House Of Thunder	276440	1
2314	1133	1037	9ad88603-7b84-4bbc-92e9-fe3d8dc23921	Rosi Lust	248360	2
2315	1133	1037	df161acb-902b-442d-9aa0-ede7e4a5ed9e	Cold Hearted	265000	3
2316	1133	1037	58cfcf73-bdc1-4d2d-b4b6-4382c623a958	Come Home	275000	4
2317	1133	1037	04f4f00c-57a0-44eb-9427-d6d509e05821	Shout It Out	200973	5
2318	1133	1037	44543bbb-1d8d-4955-9912-f5cd96401d56	The Only One	266533	6
2319	1133	1037	c981442f-170b-4fdf-8c8d-fe358a1ce997	Live Love Rock	169093	7
2320	1133	1037	e5b362da-fdf4-403a-ba84-68678a4cef9a	That's What Dreams Are For	309306	8
2321	1133	1037	c39ca4fa-8b1c-4856-b609-69a3b86fc11b	Ya Do Ya	359426	9
2322	1133	1037	d600259c-7805-4c77-9bc1-914c6bd03ab2	No Matter The Faith	281200	10
2323	1134	1038	7096530a-c3ab-46f0-afde-414caef27775	Sax As Sax Can	167467	12
2324	1135	1039	697c7578-1f92-4f04-a98e-3e1b9c6cd47e	Sax Pack	218000	2
2325	1136	1040	563cc527-e57a-419f-a52c-916428797d12	Ubuntu	439200	4
2326	1137	1041	3a96bb21-cf62-49c6-849c-e99bf8d6b870	Tribal Sax	536734	12
2327	1138	1042	c029a1be-7286-4883-9a45-4e3675af9fe1	Sax Maniac	455440	5
2328	1139	1043	0dacc864-af11-41c5-9d15-4ffc32684d84	Gratuitous Sax	31106	1
2329	1140	1044	edebb9e1-cb03-42d8-bca7-68e1d8eac7d4	For Whom the Horn Honks	364000	3
2330	1140	1044	702fb9d8-cf39-44ab-91d8-47c06ed56250	Melancholy Serenade	390000	5
2331	1140	1044	beb364fc-c91b-439b-bba6-cf27a032787a	That Little Town Rocks	378000	7
2332	1140	1044	8ab96d1b-8eb2-4532-9664-e78a3355e80e	Have Horn Will Travel	330000	10
2333	1135	1039	ade095ff-735a-4532-869b-0de74b5988ac	Tequila	377000	5
2334	1140	1044	9f4ca2b7-22a9-4b36-b14d-c6b5f9e83fe7	DD Rider	402000	2
2335	1140	1044	8ee42e06-a8db-4c9f-bade-f23d3b00a2e7	Rock On	338000	4
2336	1140	1044	e299d31d-ba7d-4dbc-9ec1-61dbb5e520eb	Banana Oil	320000	6
2337	1140	1044	ad90af77-5720-4ecb-b992-4fe2392bf37b	Tino's Dream	379000	9
2338	1135	1039	ba91209d-6cc6-405d-8b3b-48e3d4ca6125	World Is a Ghetto	328000	4
2339	1134	1038	9c2ace0c-90b5-4a58-bcd8-822a36dff1cd	Crystal Beat	188626	1
2306	1126	1030	433e05ce-d9c7-4d2d-b1ad-9342ed45097e	Slide	487120	1
2307	1127	1031	4bfab69f-e9d3-46c2-a55a-0f7cd70a43d5	Slide	261000	1
2340	1134	1038	ca6c6b64-4c85-4d80-af70-fbc088e5fcb1	Cuckoo's Egg	230200	2
2341	1134	1038	82ebab00-b8ce-4d89-aba5-058a6d08f451	Summertime	221866	3
2342	1134	1038	03f3b518-8b48-4c6f-b36c-0e0a409cf9ed	Orpheo Negro	283666	4
2343	1134	1038	0505a2d6-c961-4487-8a63-079bc2db163a	No Contract	151200	5
2344	1134	1038	5553f7a8-923e-422d-b9f9-bb9a557721cf	First Take	223800	6
2345	1134	1038	2ccbc0bd-8798-43e7-8f33-33a933d6569f	Mental Surf	217640	7
2346	1134	1038	dd281319-7b35-4b43-8328-04d6ddd33dee	Karatschan	215026	8
2347	1134	1038	46f3cade-20f4-4d77-b2a1-4d617ad7d52e	Autumn Leaves	182533	9
2305	1125	1029	22502343-8f2a-432c-8693-b2de6bf2b2b0	Slide	262293	1
2348	1141	1045	2b3b42a3-3ca1-4503-ac0f-d70881eee69b	Gobble, Gobble Song from Xaseni	0	1
2349	1142	1046	dc2d7fc9-fa42-4c8f-975d-88f646dfc27a	Gobble	0	7
2350	1143	1047	fa15903e-3e20-4eea-b40d-93eaa790fc98	Gobble	91426	37
2351	1144	1048	1b863215-602b-42b0-9c09-99a5a60802cc	Gobble	150120	11
2352	1145	1049	d9b908a5-90f1-4001-ab6a-1a9ee6d7e175	Gobble Gobble	16346	68
2353	1146	1050	80160b7a-8a87-4b87-bc3e-622937b628b5	Gobble Gobble	118333	2
2354	1147	1051	75ecf7cf-60de-496e-8b37-abb8981de5aa	Gobble, Gobble Goo	0	36
2355	1148	1052	ce33798d-3361-4a86-9c37-d228df70dcdd	Gibble Gobble	122000	7
2356	1149	1053	b6dfa2c8-3d3c-41ea-87cd-678467222d09	Turkey Gobble	11666	93
2357	1150	1054	1e339a04-14ba-4cfe-967f-e1c4cad4dfa2	Gobble Lockdown	508813	13
2358	1151	1055	5b576b73-0bfe-4db9-8802-3024076a9cab	Sound Clip - gobble, squeek	21960	26
2359	1152	1056	0f22e6f2-722d-4ca5-a2df-460f0320fdc5	Gobble D. Gook	57333	1
2360	1153	1057	e5681e53-68e4-41ff-a92e-fd199daec2bc	Gobble Up Your Flesh	129266	11
2361	1154	1058	07b12418-ad81-4a4c-ad09-0196bea8d618	Gobble De Goo	60000	10
2362	1155	1059	51b19295-2c41-4dd7-beb7-a25d11fc13b9	Groovy Feeling (Lolly Gobble Choc Bomb)	414000	3
2363	1156	1060	f0d82c5b-f193-421e-a469-ddd7e345bb34	Goody Gobble (DJ Claudes Original Mix)	327000	6
2364	1157	1057	7cfbc583-7ec4-4b5e-85c0-71347907ab5b	Gobble Up Your Guts, Part 2: Revenge of the Turkey Monster	0	5
2365	1158	1061	40dd862a-2dd8-40cf-94e4-3ecdda092d1c	Twilight	214733	4
2366	1159	1061	0f323349-6125-4c2d-8e89-0056a022503c	Plenty More	207160	12
2367	1160	1062	86730f43-fff7-4f33-a375-6db2b9812ebc	When I Grow Up	206560	3
2368	1161	1063	0706d1e4-cd1b-450b-b9b3-d08a730fbff0	Meet ze Monsta	209266	2
2369	1162	1064	bce4eddc-d4bd-47af-a99e-5ca3bf3ee451	Madness	219746	13
2370	1163	1065	34ad6fa3-58f1-40f5-9227-6c19fa534187	Heart Full of Soul	200400	2
2371	1163	1065	a1ad3516-5bfb-48da-84f5-ce46d9361bc4	Waiting for the Rain to Fall	219533	11
2372	1164	1065	34a90391-4f07-4601-b7a5-9daf95627c65	Two Hearts	214600	4
2373	1164	1065	df0d0593-823c-4fae-9a91-a288af9b3a6f	Can't Do a Thing (To Stop Me)	219573	5
2374	1164	1065	7b7b73ac-e0b3-424d-ac0c-2a926f8a059f	Except the New Girl	201133	6
2375	1165	1065	d78b3113-8ac8-4f61-be00-c69e8399b4bf	Funeral in the Rain	203360	6
2376	1166	1066	5c5c7f8c-711d-4a36-a4e6-32096c9bc999	Without a Prayer	23266	1
2377	1166	1066	75b77b36-c178-4b37-a933-71e98512ac19	On My Hands	212213	3
2378	1167	1067	bca330e9-d829-4a4a-a38d-5d92f5f66ac1	What I Like About You (live)	218000	1
2379	1167	1068	44fc93aa-602e-4d3e-9b40-817fcbd43fb2	Mirror in the Bathroom	200000	3
2380	1167	1069	14705488-8663-4aa0-8808-52fdcc3aa487	Cars (live)	218000	12
2308	1128	1032	9777c3e6-da07-4e42-b922-45e54cb952c3	Slide	212866	1
2381	1168	1070	acc4d1ff-05ab-4538-8d9f-fd917ec99baa	Les Feuilles mortes	207253	11
2382	1169	1071	11f14f34-999b-4562-a387-49c33408875e	Sabrosa	209533	8
2383	1169	1071	135d6b3d-b238-445a-8000-e80c283aa0e7	Root Down	212000	5
2384	1170	1072	a6d70b40-4a00-4f70-9774-4aebdc94a1ba	Black White	214933	3
2385	1170	1072	d5815574-44fe-45b9-ab29-480b430ef212	Charge	217866	6
2386	1170	1072	1cbff13a-63d7-48d0-b352-15a4575480ef	Operation Eagle Lie	201333	10
2387	1170	1072	8e240b66-b498-40a5-9eef-a5d7f9ad32b5	Raf1	209506	13
2388	1171	1073	38a09bdd-6f38-4e7c-b102-92d2b79ed34d	Hollow as a Bone	208666	6
2389	1172	1074	71f032a7-bd3f-492b-a6d1-b718e30b434a	The Fatal Impact	201893	1
2390	1173	1075	c47fb061-24c5-4edb-8f08-b719d8178166	Reverse	207346	1
2391	1174	1076	a85d153a-8789-4458-b6ed-53ab5c46fc01	Fist City	208533	1
2392	1175	1077	c514f716-b81d-4cef-8ac3-7077d7d513c6	Something This Real	204880	9
2393	1174	1076	37b98f89-4f54-454e-a02f-d3133eefd48b	Town for Crying	203653	9
2394	1176	1078	6bff9711-9301-4a2a-9bca-d1238f49a9d3	Reverse	308800	2
2395	1177	1079	3730d5ee-d7f6-47d6-a6fe-0e9d8e7cb063	Reverse	124093	8
2396	1178	1080	0e21187a-6912-459a-b338-a28dc7eac2f1	Nature in Reverse	215666	1
2397	1175	1077	d9197ae2-1857-4416-a65a-5ff21301b3ee	Something's Gone Terribly Wrong	194040	1
2398	1175	1077	2ae42b47-37d3-4eb2-b44b-8e8e4f1e8486	I Machine	231160	2
2399	1175	1077	686b6447-ce83-465e-945c-94b03f1346b2	Falling Apart	269040	3
2400	1175	1077	5d38c4c8-f722-4e81-ac35-795086dad699	Modesty's Failure	301226	4
2401	1175	1077	9104399d-1796-4f85-8803-433b70df4e65	Sweetest Honey	249626	5
2402	1175	1077	dec23459-559f-4c50-b924-e38fa89daf1d	Go All the Way	274573	6
2403	1175	1077	3d894541-a9d3-4f39-8db6-67c4fc68fd25	They've Taken Me Away	197440	7
2404	1175	1077	ace9cbf7-da7d-49b4-86a1-c12e3dfb3e18	Whittled to an Edge	283093	8
2405	1175	1077	3ed74696-dd51-42f6-8dfc-6037f2fdf811	You	324240	10
2406	1175	1077	9d85036a-dc85-4602-8431-2dba988aa495	Withering (Back Into the Dirt)	222680	11
2407	1174	1076	36709bc8-1c01-460a-8d60-aebe7eddbfb9	Hungry Hungry Hungry	138480	2
2408	1174	1076	52158565-a3d6-45c2-9119-effd4d74115b	Last Cigarette	290173	3
2409	1174	1076	28bd4540-2ad7-4ca5-97c6-88431a7485d7	Married to the Nightlife	162706	4
2410	1174	1076	72d4d520-56fe-431c-af49-ec20ec27ce09	Too Gone for Too Long	171520	5
2411	1174	1076	388356f9-fc43-44b1-9f21-8fa7890de647	No Good Lover	174986	6
2412	1174	1076	3468a110-1737-4c4f-a66c-6fb1df934fae	Wish You the Worst	292173	7
2413	1174	1076	5c1c7eed-ff73-43b3-a0d5-e33080c2401f	I Wonder Why	171173	8
2414	1174	1076	e11ebe04-1ca4-4958-a53e-1d8f5f4638ec	Don't Let the Stars Get in Your Eyes	405546	10
2415	1179	1081	86e0c708-d01c-4f06-8bbc-e5cc3ffe8454	Adventures	291000	1
2416	1179	1081	315b4d75-c5a9-4bad-bc03-aa1a279ab9cb	On the Skyline (feat. Nina Hynes)	231000	2
2417	1179	1081	a05d2057-b67f-4084-9067-085112297eaf	Everything Flows (feat. Paul Channel One)	206000	3
2418	1179	1081	4eedb0e1-cf4a-4a05-8c12-831e3824ce60	Softly	378000	4
2419	1179	1081	59600551-01f4-4258-b8a3-3773fb80df6f	Mushie Shake	256000	5
2420	1179	1081	26064c0a-8c6b-41ab-bd72-578899894dc9	Spanik Sabotage	390000	6
2421	1179	1081	e5ceb7e6-c286-42fe-86f9-ce430d1e636a	Super Noise (feat. White Noise)	157000	7
2422	1179	1081	fa05681b-8efa-4fd6-9920-e5dab28008bb	Son Varios	244000	8
2423	1179	1081	42c588e9-3b1e-422d-bbef-cda8a2c43a9c	Dorothy Goes Home (feat. Nina Hynes)	319000	9
2424	1179	1081	d6459561-6f33-4d63-8fc5-0a691b815202	Favourite Things	282000	10
2425	1179	1081	1daee804-87fd-492c-bbfc-2ae87a8bd9c7	Erosion	262000	11
2426	1179	1081	0f330da7-b034-4dfa-8430-d39b30160b1a	Drone Rock	309000	12
2427	1179	1081	edaeee62-5aed-43be-8e8c-d029623c081b	Propeller	369000	13
2428	1180	1082	5c9fc73a-1e37-4636-b629-15b7501ea02d	Bonus	385000	2
2429	1181	1083	2bea9fa3-4cc2-4c76-b9d7-ebfdd61eaddb	Nada Muda	190000	8
2430	1182	1084	30a94e92-dfc7-4c04-96fb-a29f5200b27b	[untitled]	775000	1
2431	1182	1084	7d3ad972-71e2-4211-ab13-3dcb3aa5e3d2	[untitled]	550000	2
2432	1182	1084	2a9f4194-dddc-48fa-b217-cf967c8319e6	[untitled]	917000	3
2433	1183	1084	508feae5-34ba-46dc-bc40-580e756942b1	[untitled]	134000	1
2434	1183	1084	6a8701f7-0346-4194-b1c1-ace86f5ea90e	[untitled]	952000	2
2435	1183	1084	bd47ef2a-ed89-47c5-81f3-c7c0142f0bde	[untitled]	1065000	3
2436	1184	1085	f626becd-cd27-4346-adc4-459ad1e8419c	Bonus Beat	29440	4
2437	1185	1086	33e407d9-4c6e-4ff6-868b-4b13a5551184	BONUS: nah am feuer	0	15
2438	1185	1086	b8653c15-fc0e-4d82-9f51-ede5346d1b92	BONUS: auch heute noch	0	16
2439	1185	1086	9bb83ab9-a3eb-46bb-84b0-5cdd7887c32a	BONUS: tango amore	0	19
2440	1186	1087	b7dfd5b3-c367-4afd-98e4-5cd702033ee0	Crash and Burn	0	3
2441	1187	1088	a33da637-d208-484a-8c9f-e6eb2c7c97a8	Do The (dance dirty)	177733	1
2442	1187	1088	7cf151f3-88e6-4b24-aec1-4e7327b830c3	Close at Hand	262026	2
2443	1187	1088	ed06305c-bf7f-451e-a193-28dcf34e37fb	Eyes Don't Lie	291066	3
2444	1187	1088	92f711f9-f7c7-4ab5-b98f-7797f281f6b0	Save the World	254400	4
2445	1187	1088	6161e951-836a-4499-9462-7a8dbb5a17c6	Angina	270706	5
2446	1187	1088	a97b9970-d39b-454b-9cf4-c11ce44bf49c	Through the Shadows	194160	6
2447	1187	1088	b705c9dd-b70b-4ff7-9585-ba2f96fe635c	Stranger's Kiss	234906	7
2448	1187	1088	4ccd4004-17c0-4405-8a2c-edf137d2b1d3	Six String and a Highway	211960	8
2449	1187	1088	0f7d7a50-d609-4dfc-b783-3454d3e4d1e5	October, 18	175840	9
2450	1187	1088	726b4a49-4d2a-47c8-b4a9-d14e03f1b3e1	Livin' on Lovin'	252960	10
2451	1187	1088	ed79ca3e-6427-4a90-ac0c-70a9215b0c9c	Rock and Roll	210000	11
2452	1188	1089	597bea8d-e23e-4f01-b727-97a82fd374d6	Crash	216760	1
2453	1189	1090	8513271e-46a6-406e-a7e8-9977a3cc11b6	Crash	234400	3
2454	1190	1091	77e0032d-54d4-4bc5-90b6-115927aa8dae	Crash	201066	1
2455	1191	1092	fc64bda2-c05c-4731-a1ae-d01aa86e3512	Crash	276773	1
2456	1192	1093	e3e4c69e-af77-4173-96e2-17745f91bbae	Crash	259000	1
2457	1193	1094	0a775e7f-2fe3-44f1-b085-7c8bf970dd8b	CRASH	0	1
2458	1194	1095	c7df1d7a-7dff-4f78-844a-cc64e5075b7e	Crash	0	5
2459	1195	1096	d2343a97-043c-4903-9413-e612421e276e	Crash	329000	1
2460	1196	1097	a68c1c39-2f13-4020-8f4e-8df355770488	Crash	196266	6
2461	1197	1098	ecc56636-340e-4912-89e2-ddfda5262afb	Crash Crash	232000	1
2462	1198	1099	cdc587e9-319a-4cfa-892d-d41200499a31	Crash (instrumental)	186000	2
2463	1199	1100	dae72048-8105-4e59-a894-3d7870c4e59c	Crash (instrumental)	242000	2
2464	1200	1101	f4b790f6-bcb4-4ecc-94c5-326e59670801	Crash! (edit)	0	1
2465	1201	1102	a60ff333-7b34-4294-b977-f925ccd2a14c	Colors of the Land	268746	4
2466	1202	1103	a843d182-baeb-44fe-bebf-48779c47d998	Ocean Land (The Revelation)	285000	3
2467	1203	1104	6b92b67c-26e5-42b5-962e-a36989da6017	Dronning Mauds Land	292960	1
2468	1204	1105	9c1a06b3-e2cd-4190-a8c4-7bb4e8888b89	Caravan	475000	1
2469	1204	1105	35870351-7ff1-4b62-8285-9445b0b23c72	Bustle	320000	2
2470	1204	1105	a4de28df-cab9-455f-8324-5be7fadf6056	Nightnoise	573000	3
2471	1204	1105	65ab0d94-62b2-4d05-8c75-0c4756c2b9b5	Ku	485000	4
2472	1204	1105	1ad21b90-fc2d-48ce-b282-0ca865fc90a5	Shu	441000	5
2473	1204	1105	9e0f430a-5077-4503-bb53-7f5d5e199203	Limba	446000	6
2474	1204	1105	a0b96e2a-dba0-4ffe-971e-d9683c15e6ff	Jacks	439000	7
2475	1204	1105	048f5689-38fc-4163-ac82-52819c969066	India	570000	8
2476	1205	1106	f2c447ab-0fc1-4a1d-9cb1-d8fa2f95059c	The Land of Nod (Sunrise)	0	8
2477	1206	1107	49a2d063-d17f-43e2-9639-b5f2c5de35f3	Land	220786	3
2478	1207	1108	df93c98d-815c-4818-9654-daf59e478560	Land	977000	9
2479	1201	1102	cbdc066f-3474-43e0-8f02-b84a2d36cfa2	Longing for the Green	237426	1
2480	1201	1102	60981620-9fed-485e-835b-d1b7427ffaf1	Wings in the Canyon	258653	2
2481	1201	1102	a53636db-6b3d-4a2c-be7e-c143841ebe8d	Mountain Flight	275453	3
2482	1201	1102	385df4e9-3bdd-4362-98ee-46dd18473994	American Harvest	208653	5
2483	1201	1102	053fb60c-86f5-4a12-bbc2-0b8f11786ee1	Beautiful Morning	284280	6
2484	1201	1102	1e42b405-9e46-4eba-bcb2-ca2421325ff6	Night Ride of the Magi	402586	7
2485	1201	1102	de3fa0ce-df38-4954-9027-43fcc2dd3a3a	Indian Summer	294213	8
2486	1201	1102	cfb7c406-1ad2-46bc-8e22-ed8ae37c3acb	Rain in Cat Harbor	330880	9
2487	1201	1102	39091767-bcd4-4af7-81d7-514143c51ac0	Sequoia Mist	278107	10
2488	1208	1109	4c39b75e-760c-4b5b-8355-14b6bf89e02a	Circle in the Square	334693	1
2489	1208	1109	5c411e3b-9c84-4776-bff7-30b8f246bebb	You You Monkey	277106	2
2490	1209	1110	6a5b904b-eb2d-41d1-abb1-2c1e0106dba3	Click	363000	1
2491	1210	1111	3faafee3-9685-4b1e-a4ff-a9709179ca68	Click	316746	3
2492	1211	1112	1ab5039f-5ead-435f-a3b2-7cc76c823b41	Never Click	298306	1
2493	1212	1113	de093cd1-5f65-46e9-83c2-452ef4f8d26a	Click Clack	171333	11
2494	1213	1114	1783b473-91e3-4dee-a739-d86cb545ad32	Double Click	385000	1
2495	1214	1115	7b324384-0cde-4ee0-9215-1424e3a3bf16	One	237000	1
2496	1214	1115	505445ca-78bd-4597-9ca8-69415e704115	행운 (Good Luck)	252000	2
2497	1214	1115	2d114d68-da4b-487d-bca8-99f2b8470f0a	Dreamming	235000	3
2498	1214	1115	3b4fc026-92e5-4efb-a592-097cddeeb112	잊혀진 사랑	241000	4
2499	1214	1115	7d16ea97-4ee3-4781-93c4-c2f1ae24440b	지금까지만	251000	5
2500	1214	1115	b4c307f0-5b43-4097-bb3d-04b9a78ae01c	배려	222000	6
2501	1214	1115	529c1e93-3adc-4ed9-8e69-fd84773af632	Promise	226000	7
2502	1214	1115	8585b698-ec9d-4075-8802-f4700fefc37f	You	227000	8
2503	1214	1115	66f8d2fd-3191-4c74-8782-1e6aaaf5295c	마지막 선물	250000	9
2504	1214	1115	fa560d7f-5d0b-4c22-9a66-5608ae7a6baf	마치 영화처럼	232000	10
2505	1214	1115	9b348431-fa81-41e3-93ee-734feb179421	Good bye	251000	11
2506	1214	1115	3732845b-aca0-42c3-a4a9-3ad4149e55e4	마지막 선물 (Club Ver.)	185000	12
2507	1215	1116	49068012-0c5a-4a18-8a3f-2217249664d4	Click's Concert	24000	11
2508	1216	1117	f14487b0-dded-4f4f-a55e-3c8dd43bde72	Ali Click (album edit)	222306	2
2509	1213	1114	f37fea79-7534-487d-8a7f-61e5bd481a9e	Double Click (Piano version)	480000	2
2510	1217	1117	604a928d-db9d-420d-b330-ce50720d56fb	Ali Click (Album mix)	258560	1
2511	1218	1118	a2603b31-b9a9-4458-bbd5-5e1b37bb21ab	Double Click	385453	1
2512	1219	1119	6faa7710-4488-43ae-85c5-3047ff260865	Don't Go	238000	1
2513	1219	1119	4be925a1-0d9c-4c7e-9c20-06b0f8498507	I'm in Trouble	231000	2
2514	1219	1119	11737c53-b69e-46a1-b862-f79cd8717127	Call Me	225000	3
2515	1220	1120	5224aea7-3a8b-4e4d-9a14-4f36a22aed7b	Bad Company	290573	5
2516	1221	1121	00b70ab6-b4e1-4c62-8862-87bdb01bbfa8	Bad Idea	219360	2
2517	1222	1122	53f89b14-69eb-4159-978d-76f7cac4f13b	Bad News	191800	4
2518	1223	1123	f7e75614-f5df-494f-a6f6-3a26fda88675	Bad Time	86266	10
2519	1224	1122	3fdc3370-0090-4518-af58-3d38a31687bb	Bad News	215853	9
2520	1224	1122	ef90e79c-07a7-47bd-b5dc-bcffb1e0e229	Bad Dreams	255360	17
2521	1222	1122	86769182-7bef-4d62-96d9-6e0e63ea9a63	Bad Dreams Rehearsal	313840	1
2522	1222	1122	39898298-846c-4f28-9aa1-b3fd8661af87	Hey Hey Bad News	321640	11
2523	1224	1122	c21a0053-eca8-41e1-b4d7-57f44d24612b	Hey Hey Bad News	316520	1
2524	1225	1124	1d6fcfeb-52bd-4aba-8da4-9777afb03faf	Bad Religion (First Version)	109000	1
2525	1225	1124	2a76a4ca-1e75-40fa-b67a-ba9c56b41fb0	Bad Religion (Third Version)	108000	7
2526	1226	1125	70177190-8376-4284-a4f6-1fa7b76aeb75	Bad Power	267080	2
2527	1226	1125	50d924fe-e3ea-470d-80fe-f5307d0a1a35	Bad Street's Intro	70693	1
2528	1227	1120	7bd0def4-b6f7-44c2-b020-be5de11a2350	Bad Company	287600	4
2529	1228	1120	37504a6b-90c5-49d5-9f57-03889979e334	Too Bad	233040	7
2530	1227	1120	6477525a-cf0c-4dd6-8e18-f49946f6a176	Good Lovin' Gone Bad	216640	9
2531	1229	1126	f1cc5763-533f-4f56-a377-50d1031c8464	Dance of the Bad Angels	273933	2
2532	1230	1127	c01c7655-4d44-46c0-807b-e21a27176f78	 the Queen	420293	12
2533	1231	1128	faa390d6-1c98-46b1-996c-863259b0eecc	Hot Girls - Bad Boys	250000	6
2534	1232	1128	9082fd62-dd4e-41c0-8801-461a6851d8bf	Bad Boys Blue / You're a Woman	240000	1
2535	1233	1128	745a5b84-aa12-43f3-8b73-e2f0e6b2ff2a	Hot Girls - Bad Boys	248066	15
2536	1232	1128	eb9a75ae-e2d5-4d7a-8656-31e36e06e09b	Bad Boys Blue / Don't Wall Away Suzanne	230000	11
2537	1234	1129	19de2d7b-b809-4ad0-bd82-85421cf58215	Big Bad Blues	226000	1
2538	1235	1130	47eaab1a-667b-490d-8094-168e7d0d9ad1	Bad	247733	1
2539	1236	1130	592b934d-3404-48b0-b910-973f9d994487	Bad	247093	1
2540	1237	1131	82b321b9-51e7-4e0a-9713-f004c4a9ead3	Green Laughter	0	1
2541	1238	1132	6ebbd908-1a1c-4e51-bab3-705fd3cad8c5	Laughter	237733	3
2542	1239	1132	b33dd0fe-0aba-4dcb-8d52-739371ace4da	Laughter	238000	3
2543	1240	1132	264000f6-4212-4132-a2a3-d7a7d112f15c	Laughter	238200	3
2544	1241	1133	8f48a82a-a6a2-42c7-9263-469f7cfe0832	God of Laughter / Solingobu	219160	10
2545	1242	1134	577a910e-6843-4fdc-9fe6-794f23dde6ce	Ein Wort	230000	4
2546	1242	1134	bf414dda-e827-4e5a-a754-4672ffe36629	Black pool	233000	3
2547	1242	1134	37e59f42-1da9-4017-be04-98d29d5a9a64	Allnighter	236000	8
2548	1242	1134	6fb87ba1-d032-43b4-84a6-796bc0ca9ab8	Maldivion, va a ser un nuevo dia	239000	11
2549	1243	1135	d0f60d32-f323-46a7-8022-835e5f368579	Two Kinds of Laughter	234626	1
2550	1244	1136	6342bb29-5ab3-4b49-b1ed-0a504df3c0d4	In Amber	243000	1
2551	1244	1136	cfb30fb2-4cc9-4051-87d4-c39cdd1af4b9	I Won't Hurt You	175000	2
2552	1244	1136	96a1ac18-1399-4c45-801d-2286342f9a83	Idol Worship! Idol Worship!	171000	3
2553	1244	1136	484e2fcc-b9ed-450d-a84a-4db6f28574ce	Survivors	263000	4
2554	1244	1136	d0a41afd-d06c-40f7-9ba3-dc509538207c	Every Midnight Song	299000	5
2555	1244	1136	cfc94dff-bd2d-429a-b87a-5ccdbcafcf3f	Dirty Lives	186000	6
2556	1244	1136	5c4856d2-d877-4da8-967e-76402cf9ec7e	I'm a Ghost	248000	7
2557	1244	1136	2a61c3ed-fcde-40be-983d-926a7ae1ce7f	Canal Street	267000	8
2558	1244	1136	b68ae191-3917-430c-8f1c-8daeb25d97b1	Pulsar Radio	412000	9
2559	1244	1136	a95e3f98-044c-4767-a347-fc30ee4ecf10	Corona Extra	250000	10
2560	1244	1136	0fef9c4b-8f47-4f25-a251-5d5f88b9a447	Makeshift Heart	380000	11
2561	1245	1137	fd1ac1df-1e4f-4348-97d3-383043619efc	...And the Laughter Has Died	202226	8
2562	1246	1138	7cbf6f7d-766a-4a3c-9e5a-faa22e41db8d	Laughter at Dawn	537240	14
2563	1247	1139	b6e1888a-df5c-4aeb-b61c-6e494c0ca9a3	 Laughter	358933	4
2564	1248	1140	13db4db5-b5ba-4c67-8073-0544dd9cf2eb	Private Laughter	182760	1
2565	1249	1141	486ceea3-b70a-4c2a-8f75-3ec59f01196e	Teleport	421693	1
2566	1250	1141	0f61ba1e-e843-42a7-a2fc-593973af0606	Teleport (remix)	0	1
2567	1249	1141	df1b2962-8f53-4e67-bed4-82d561d56da6	Teleport (Acceleration mix)	310800	2
2568	1250	1141	bdd166a8-6271-4495-a882-ee1ca9db6bb6	Teleport (Stripped remix)	0	2
2569	1249	1141	439047c3-57b4-45fd-bdd2-d508613b1334	Sugar Rush (Refined mix)	367506	3
2570	1249	1141	cb0589b7-cbb6-4352-a46f-6fdcb8f1c2c8	Sugar Rush (Raw Cane mix)	388133	4
2571	1251	1142	9b716cd8-dbe3-4360-83fb-ac1ae94c72a3	Already Home	210440	1
2572	1251	1142	f8e872ad-2d58-432a-b6e5-29a8d682755d	Planet	212346	2
2573	1251	1142	e69765a0-254a-4c0f-bcb2-bf9b60c9ac92	 Underage	254400	3
2574	1251	1142	bf35c7da-e13f-49da-8ef8-4e5849bf9498	Any Day's Ok	264173	4
2575	1251	1142	39aef1f9-1a82-4e6d-80ff-b39bb64c20fe	Facing Yourself	260133	5
2576	1251	1142	8fb1e2a2-ab33-4dd2-8d66-1fd3736715bb	You Don't Feel the Same	265666	6
2577	1251	1142	b7a613ef-9df1-4d09-b6da-788e11290192	Turn Immortal	226480	7
2578	1251	1142	0c96c8c7-e925-4ab0-82c3-f5a8707b2991	Am I Going to Heaven	242466	8
2579	1251	1142	9a9af35b-fdd8-4a61-81e1-b12c4fb8aa60	You Heal	272693	9
2580	1251	1142	2453efd7-1da9-4557-bdb0-8fa59652c480	Private Encore	331013	10
2581	1252	1143	b00f64c3-335c-4f85-9911-b902a34d6a83	Teleport	248413	7
2582	1253	1141	75b6ba9f-168b-4ecb-867b-f9b550bca202	Teleport	367626	6
2583	1254	1141	b816d91d-668c-46fb-8de8-62def705a5a0	Teleport	425266	7
2584	1255	1141	8dd8666e-aa25-4d26-af79-f63896be559e	Teleport	420733	2
2585	1256	1144	be1e7543-1f9a-4208-9aab-7e07de5a1493	Teleport	125133	1
2586	1257	1141	dadfd521-3428-44e3-b98e-7abf0f9626dc	Teleport	425266	7
2587	1258	1145	54dff526-91fe-4c2a-9492-62f73bb8c9d4	Teleport	231133	18
2588	1259	1141	7cea9b35-e531-4152-b740-5f644eca9149	Teleport	420973	6
2589	1260	1141	e30ecf56-a4e8-471f-8e8e-fc1c89a86792	Teleport	353440	4
2590	1261	1146	2aa9d6e2-fff0-4619-ad81-86e8a58a607e	Splat Graphix	0	2
2591	1262	1147	775eb891-926e-47c0-9889-bcbedebef53f	I Love Pressure Washing	379000	1
2592	1262	1147	049f6fc9-3660-4adf-ba62-5bebf1177cbe	When I Blew Up	314000	2
2593	1262	1147	c0829193-d06e-4311-83ea-6ae282610e7d	When I Blew Up (Carola Pisaturo remix)	369000	3
2594	1263	1148	92b26884-f285-445d-97a1-d11fb86db63c	Splat	215528	5
2595	1264	1149	34bd99f9-ec8c-49bc-8595-a4948f3a01d9	Splat	229866	6
2596	1265	1149	070c9cec-9d0a-429b-bd34-b3b5c23f7581	Splat	230800	5
2597	1266	1149	79ca4c1b-0ca3-4043-b0bc-752528585d62	Splat	230000	2
2598	1267	1150	c4ecb890-cb10-4a72-8f27-02f7075cb043	!Splat!	384480	4
2599	1268	1150	2f0aab49-4b79-4212-8423-5f9aa29cb938	!Splat!	384866	4
2600	1269	1149	2bb0dbbe-982b-48d0-8753-d9f8c8286ae9	Splat	229333	3
2601	1270	1149	66d87bad-ce1c-471e-8a1f-d273735c3985	Splat	230000	3
2602	1271	1151	94831178-2660-4f5b-8ae3-1a74ba93a9dc	Splat!	539000	8
2603	1272	1152	3a111f99-0261-4639-9312-994a8eb2898d	Splat	465000	4
2604	1273	1153	aaa3ff1c-2db8-4bf1-966a-dc3fbeaf9bfd	Splat	309666	6
2605	1274	1146	f425d73c-4624-479a-8ed1-1d936da8c0d8	E.B.L.	428106	4
2606	1275	1154	3cb06ab6-7ad1-4954-b7c1-8678627d4320	Splat Mi Splat	273000	6
2607	1276	1155	b1dca6e8-92c3-4c65-b31e-229a67cc4bb5	Newsbreak/Splat	80493	35
2608	1277	1156	7caf8cd8-6b3c-4d45-abce-25dc47de99a4	Splitterty Splat	139000	13
2609	1278	1157	919083ba-107b-4cf8-8fa5-f4e48ba39b48	Splat kat	335920	7
2610	1279	1158	89530c93-110a-4b02-86e4-ac643b3a8495	Splat Out of Luck	144426	4
2611	1280	1159	58f1500e-eb3e-4017-8017-87282610ec0f	Jumbo Children Splat Fat	119533	11
2612	1281	1160	a392ec45-7fce-481d-92b5-9bc4bca0a89b	Fall and Splat - SFX	3826	13
2613	1282	1161	1f65d613-2b98-4ae1-8ed6-e0f6f3bb5416	Process of Yome Splat	82000	22
2614	1283	1162	28b2d6f7-8971-4e6e-9d71-23c270517607	Public Menace, Freak, Human Fly	218400	1
2615	1284	1163	b9ec97f5-38d2-4f42-8879-52a9803735da	Yahoo!	228426	8
2616	1285	1164	3c54e5b5-5393-4286-aeae-fbcee702a6dc	Yahoo!	106200	15
2617	1286	1165	afbce25a-495c-40b8-a007-087b93420d12	Yahoo	245466	13
2618	1287	1166	b078b6bf-9c26-48e4-a3b2-b7ca82c0b8cb	Yahoo	69373	5
2619	1288	1167	c9055941-6fed-45e6-83e3-4ff3362d3800	Yahoo	262080	14
2620	1289	1168	78816a14-d7e0-437b-9b3e-75b552dd7026	Yahoo	257279	3
2621	1290	1167	aeb84d67-573c-42ba-839c-d79bc4410e16	Yahoo	260800	14
2622	1291	1164	d1b634d0-33cc-4e0c-8b12-406cbd3a3c79	Yahoo	106066	3
2623	1292	1169	781da2c4-95a9-4c3d-b9eb-b5d260ef90f8	Yahoo	169000	2
2624	1293	1170	346757b5-dc18-4f17-9019-e250ed64fdf2	Pipe Dreamz (Original Up Your Kilt mix)	251973	7
2625	1294	1171	c234ddd9-c9e0-4d09-828e-8d6efd40a6e2	Rock and Roll Music	29093	1
2626	1294	1171	d65ef8d4-9ad5-41e4-960b-08d000794943	The Tasmanian	7026	9
2627	1294	1171	69fb1929-0f71-4e3d-811f-32675c99489b	Theory of Relativity	74240	11
2628	1294	1171	2d5f8d30-7638-464a-ac5a-16e67ca40e2f	Young Einstein Pacifist	129600	15
2629	1295	1171	b35e4194-02bc-4149-bf98-dcc1ea820d60	Awabakelly (feat. Alan Dargin)	78026	4
2630	1295	1171	b0ebf6f1-3334-4f96-b3ac-76035aea8002	Reckless Angels	39760	9
2631	1295	1171	7ae7d0be-f8bf-4a8f-901d-167de4b94751	Such Is Life (feat. Victorian Phil. Orchestra)	57000	16
2632	1296	1172	616a272b-224e-43c6-8ddc-c930ce24406b	Yahoo Cowboy	184000	12
2633	1297	1173	3abbe9b2-603a-479f-820e-32703c14b6d6	Yahoo City	323600	11
2634	1298	1174	78879652-3804-4466-a54a-c66b9763ff05	Yahoo Resort	141426	5
2635	1299	1175	1446e584-3bdb-4c70-bf33-75dc000bf0b3	Yahoo Australia	244493	17
2636	1300	1173	150d3d20-e8a6-40f3-aea6-64075bef5ae5	Yahoo City	345000	6
2637	1301	1176	1302542f-b8cf-46aa-b71a-6ee632260c4f	Yahoo Hoez	77000	8
2638	1302	1173	b93c5738-ce3b-478f-a264-1bd4ead40c6b	Yahoo City	342946	12
2639	1294	1177	67f9ecdd-6cd2-4fa9-aabe-6c173ef8fdc0	Who Can You Trust?	29760	4
2640	1303	1178	6cc8813c-72ac-44c5-a14e-d985d051c92d	Second Life	1255000	1
2641	1304	1179	29678718-749f-4e3f-bfad-ff04b81501fd	Scienz of Life	238000	1
2642	1305	1180	fcef51c7-2d93-4df5-a26b-f14dda6ee393	Natural Life (radio edit)	230773	1
2643	1305	1180	28a71f86-d5bb-4e9c-817c-4cb60da92d0c	Natural Life (Good Vibes mix)	375493	3
2644	1306	1181	15843a70-5805-41f9-885e-ea482654ffa9	Spend My Life With You	332000	12
2645	1307	1182	a0604209-b660-4ff0-9a8b-e4156931b757	Moment Of My Life	393533	2
2646	1308	1179	80b81df4-cfc8-4952-96ab-327ecabd2381	Scienz of Life (Metaphysic) (clean)	0	1
2647	1308	1179	fe9a734f-2fff-49ee-a0db-f4f619c2f5d4	Scienz of Life (Metaphysic) (instrumental)	0	2
2648	1304	1179	6d5238c0-4e6a-4cd5-ba2a-10b757130676	Scienz of Life (instrumental)	238000	2
2649	1305	1180	6428c4d1-51e9-49ca-928e-bacfb2c16122	Natural Life (Living Killer Whale mix)	371307	4
2650	1309	1183	1f00fd50-e942-4dea-b8d5-364a20aec920	My Life	233600	4
2651	1310	1184	f22ab9e7-eb0f-4daf-a311-e0a2392f7119	Life On Earth	369000	1
2652	1310	1184	4ddc326f-a2f1-46ec-bc9e-d64fb3cf66b7	Life Turns Fast	297000	4
2653	1307	1182	cf89fecc-8fea-4bec-8a9c-4b2a54da9e76	Moment Of My Life ( Shep Pettibone Extented Version )	463960	7
2654	1309	1183	6ff8dd3d-2185-4a2d-8885-68c210cb35d4	Life After Death	154333	6
2655	1311	1185	bb4682aa-b684-4924-ab42-072e27463f29	Alpha	75066	1
2656	1311	1185	dcc975f0-6210-4809-bc3e-10371c0beb53	Rock It Right (feat. Skit Slam)	243666	2
2657	1311	1185	2a37edb1-99db-41d3-93d3-a38b2990f62c	Never Be a Crackhead	229173	3
2658	1311	1185	c182abf0-70f3-4807-944e-c309d6a73403	Kung Fu	234813	4
2659	1311	1185	97666d73-7ea3-4b46-98f4-1bfa2f8498f6	Babylonians	178333	5
2660	1311	1185	ef8b11e9-e38a-46c4-b397-f9c3bb2e938a	Always Living	192493	6
2661	1311	1185	c985729a-5e53-4d32-b35a-9f0b9c6890c5	Tomorrow	234733	7
2662	1311	1185	9dc52a04-3f4c-484f-84ac-42d1f51ca282	Moviedrome	394186	8
2663	1311	1185	de44dd77-b386-4655-a5a1-111f2dc01afe	The Pound for Pound	299306	9
2664	1311	1185	72bd1a0b-6bcb-43ec-8b7a-4e71582eded6	In Memory	295960	10
2665	1312	1186	167e0e2e-c86a-4a1c-85f6-dea05277bd4d	Die Trying	201000	11
2666	1313	1187	ec5d740c-dba2-4b77-b6c4-15d135a208b1	Die Allerschürfste	204600	12
2667	1314	1188	d9b6ed09-b925-46cb-9e14-894d00709912	Die Interessanten	212400	21
2668	1315	1189	11cea57c-70b4-4077-99ee-9319da31d55c	Pack die Badehose ein	211386	11
2669	1316	1190	ad53f6c4-2d90-44d2-bfa5-771e1c9617f7	Die verschwundene Seglerin	202000	11
2670	1317	1191	a29b4198-b245-4ecf-8f7b-689f3c15f0d9	Wir san die Hinichen aus Wien	205000	3
2671	1318	1192	69020273-3e67-4211-82c8-374ec03193bb	Die Original Deutschmacher: Vati Kühl	202000	13
2672	1319	1190	0a52a88e-1539-4f85-bd04-4fed7a75e9d3	Die Magnus-Glocke	204000	8
2673	1320	1193	b6cf5ac5-c5ed-420a-981b-79a49dcbb102	Franz (17 Die! Die! Die! Fans Can't Be Wrong)	99320	3
2674	1321	1194	d8c14521-e614-4464-a7cf-682a9e58ebde	Die Zukunft	215880	12
2675	1314	1188	aaccb13a-9930-424d-a934-b770523a5114	Hier kommt die Kaltfront	203813	16
2676	1322	1195	bffc2178-e62f-40f9-b4da-05ff025cd2c4	Die Eine 2005 (Original)	206040	1
2677	1323	1196	50bf900a-c470-44ef-8370-8b6dd9c6b7b3	Die Zeit ist reif	205920	1
2678	1324	1197	9e5914b9-821e-4e29-a8bb-702df5a22597	Die Schlumpf-Band	204000	16
2679	1318	1192	7d1a1ba6-bcea-41fe-8570-1820f457759a	Hermine und die Stars: Kerstin Graf	202000	15
2680	1325	1198	42a7320b-19b3-4067-bce2-a098fa52d58e	Die da!?! (radio mix)	219333	1
2681	1326	1188	5d5f09bf-6c35-41ad-b0de-f1aa4af9d46b	Die Interressanten	203906	12
2682	1327	1188	1f82d14c-23d5-461c-9c3f-2d1d24dc3fab	Die Interessanten	212160	1
2683	1328	1192	a0f20bff-cc1d-4db5-b33c-96ec8a8989fd	Die Original Deutschmacher: Einfach (Easy)	206786	11
2684	1323	1196	24b31d8d-0288-47eb-bfa3-15c69f9b2f69	Die Zeit ist reif (unplugged)	204226	2
2685	1324	1197	2da9b939-ad57-4b70-9d98-c1a931646b1f	Die Sängerin der Schlumpf-Band	205000	18
2686	1329	1187	a11f0ac0-d0f4-40ef-8a73-17a48177b4b8	Die Karate Schule	21026	2
2687	1330	1190	c8039cc2-d145-484b-8d1d-75560c95df92	"Fly" - die Fliege	217946	6
2688	1331	1195	2b1c3f7c-bda8-4265-99a6-4a6594d159c7	Scheiß auf die Hookline (radio mix)	215280	1
2689	1332	1199	285a8ecd-4fca-4fc3-8a2c-9f64aca1ae20	Die Jungs fürs Grobe	207973	10
2690	1333	1200	64e6ad7d-b198-48e5-b351-5ca1087a6c67	Turn	264160	1
2691	1334	1200	d8f64321-17f6-4ff7-8168-c52a9931921f	Turn	0	1
2692	1335	1201	1e524311-2a8e-4849-8113-a14903d91be3	Turn	197666	1
2693	1336	1200	18423d11-b572-48b1-9548-ddac4268eaa1	Turn	201626	1
2694	1337	1202	30e22154-e46d-40b5-92ac-2e8cfbcb95e3	Turn	249040	8
2695	1338	1203	0d08ce76-35ac-4913-9bbe-02ab8151eb6f	Electrocation of Fire Ants	295906	1
2696	1338	1203	2c51dafb-82b5-412f-9046-8dda2d680803	Plasmids	82666	2
2697	1338	1203	2b328902-c82e-48f9-8cdc-98db8fbb0419	Ru Tenone	166226	3
2698	1338	1203	d1731565-1f2c-487f-88c7-f70b4333a449	United States of Surrealism	82533	4
2699	1338	1203	eaf08703-b94b-4c84-9a2b-4147af906597	Young Cherry Trees Secured	214906	5
2700	1338	1203	cd9a25ed-4713-4701-815a-229e879d21f7	Triple Cause of Poetry	226426	6
2701	1338	1203	7888a7a2-7b06-4e53-92d4-63b4abacbe78	Delimiting	132640	7
2702	1338	1203	d25357e2-cd98-428b-9023-14b3df181687	Glangorous	61693	8
2703	1338	1203	a347e6ea-9dac-4357-968e-23d2bb65d59a	Jumbleo Palipsest	185706	9
2704	1338	1203	fec740a3-728d-4c60-b0e5-f28d8a35eac7	Gimmickry Sensational Hoax	92466	10
2705	1338	1203	9f264fbb-abbc-415f-bf6d-904240ad2595	Gimmickry Hoax Sensation	211426	11
2706	1339	1204	73aae10a-67f5-4e20-9cdb-2fc1736a9c76	Whose Turn	168000	11
2707	1340	1205	d75ce52d-6730-42a7-93f3-b9e8842af807	The Turn	0	1
2708	1341	1206	1a95944e-2247-42ce-9cf2-f5da528a227b	Turn	199000	1
2709	1342	1207	3d2361c2-d434-453e-8cba-2a7ba3f4758e	Feel It Turn	182573	3
2710	1343	1208	544c8649-1a0d-4f7a-8650-ae0d73e59bf0	Turn (full length)	272426	1
2711	1344	1208	d86f2089-4a9a-42c4-8d87-bb5055d67bcd	Turn (radio edit)	242000	1
2712	1345	1200	0b0a146c-8621-459a-a4d7-423cba87e39b	Turn (radio edit)	198093	1
2713	1346	1200	d351f02b-7be9-4e5c-85d1-d54e82bded82	Turn (radio edit)	201960	1
2714	1347	1209	b9506c0e-63a6-4098-9c6d-f86157f779e7	First Crimes	0	1
2715	1348	1210	912ecb61-c9b9-4a17-939f-6c586a213ea0	Girlie Pop	126053	10
2716	1349	1211	87bb463f-ffee-4cc2-8676-1a68778619ad	50 Pop	62933	6
2717	1350	1212	c72864c4-8e48-4af6-b62e-c9a8814ea78b	Boze cuvaj Psihomodo pop	169666	15
2718	1351	1213	9a351921-b513-4a44-ba66-866861ecb8cc	Rapid Pop Thrills	0	9
2719	1352	1214	735e788e-8f05-444e-9c3e-73c4d73e950d	This Is Pop	214586	6
2720	1353	1215	eecec46e-845b-4f54-a936-5eceab2122bf	Pop Riviera	253000	12
2721	1354	1216	8e7ea370-7a0d-4cd7-927b-1b1a679c11bd	Pop	0	1
2722	1355	1217	235a239c-b3c8-4e94-b523-bec7fc07361c	Pop 6 to 7	0	5
2723	1356	1218	4953267c-a5b7-405d-8454-c2a4ddf88d64	Pop Pop Pop	180360	4
2724	1357	1219	754c16a9-affc-4d56-b0a4-15b68b7a3fca	Pop	512506	3
2725	1358	1220	0fd54e5f-4220-4c08-870b-e0e8150b47ab	Pop-Pop (Main version)	195693	1
2726	1358	1220	f48a99af-69e7-4771-8d68-1b2c3b0f9bb9	Pop-Pop (instrumental)	196160	2
2727	1358	1220	7e193650-bc7c-4a29-bcce-fa6c7b1c9a71	Pop-Pop (a cappella)	185147	3
2728	1359	1210	a40af08e-2600-440d-bc93-66d9a4ae1153	Pop Starts	107973	7
2729	1360	1221	95fa347f-6178-4c1d-a73e-a2698ef88cde	Pop Shuvit	201826	1
2730	1361	1222	c8702517-2a88-4cc0-aa67-f09b20822a84	Fear of Pop	206266	1
2731	1362	1210	120159de-348b-4eaf-99c2-c9c334132f8a	Girlie Pop	123026	1
2732	1363	1223	e694c6bb-051e-4ab9-aebc-f576212c3dcf	Sonhos Pop	206146	2
2733	1364	977	41955415-e2cf-4559-856a-42d6cf0ea619	Pop (album version)	240266	1
2734	1364	977	cefd2472-7fa0-4cd7-82eb-19fb14e78423	Pop (radio version)	178093	2
2735	1364	977	faced4cf-d4f1-4dcd-a425-899200c3dd0e	Pop (Terminalhead vocal remix)	322734	4
2736	1365	1224	12c89305-2944-454e-b74d-f9e84ea64e6e	Attraction Pop	158466	3
2737	1366	1225	ad1d837a-c65b-4d8a-bd8e-0dd12abe4769	Pop Goes the House	375974	10
2738	1367	1226	706ffa8f-f358-4574-89ef-75ec97b9fb96	Pop Might Eat Itself	0	3
2739	1368	1227	89bd79e9-56cd-4945-a447-25d768bb5378	Pop Rocks and Coke	0	2
2740	1369	1228	6417ae40-1c82-4bf5-af63-c4e60e0e6381	Yerida	2156866	1
2741	1370	1229	a399260c-3005-440f-ae9f-220389dca087	Appalachian Spring	2156000	2
2742	1371	1230	57a89e61-fda9-4ad9-8229-380bc6eff4f2	And On The Seventh Day Petals Fell In Petaluma	2156666	5
2743	1372	1231	d947ec56-d9d9-4100-9dc4-52670723f358	Getting Into Action!	2154574	2
2744	1373	1232	0e4eefb6-756c-40d5-b9ef-78c57c36607e	In Memory of Elizabeth Reed	2154226	2
2745	1374	1233	be1d5a1f-0fda-40aa-af7a-015329adfcb9	Pebbles	2156000	1
2746	1375	1234	60b14915-ffd5-40cb-b46b-c4d4112c2041	Baraka	2157000	3
2747	1376	1235	9467a486-55dd-4e41-91a3-e7d3ae107a97	Vitamin M	2154000	1
2748	1377	1236	dd0f3fa9-424d-4943-953d-1f4d85e78b84	Nonverbal Communication I	2156000	4
2749	1378	1237	9b713f2c-a474-4e3e-a6a1-3e4f0c27ea5a	Le mur	2154000	1
2750	1379	1238	f8382f2f-5a71-4c47-9f6f-78dcb9b8a767	Tape 6, Side B	2154000	12
2751	1380	1239	031e2da2-03e1-428d-97c6-8b4ae0c2f7f5	THE DOCUMENT 091303 KRDLADS	2155000	22
2752	1381	978	7414d449-811c-4ef0-92f7-7f84634fa4f3	Right Schuh	2155893	1
2753	1382	1240	da7764e1-836c-423d-a926-0ecbd8563e8d	Objects Appear	373000	2
2754	1383	1241	d145e6fb-6485-46d3-b8dd-01a9d342146c	Masssive	213387	6
2755	1384	1241	c81820f6-b0ea-4197-931d-46614d145640	Oddshot	150000	12
2756	1385	1242	c83bb6e3-d7c8-46aa-9adb-0c14de5088ef	Objects in the Rear View Mirror May Appear Closer Than They Are	357693	1
2757	1386	1242	80a8156e-3f34-42ca-9de4-4d6cb20c32ba	Objects in the Rear View Mirror May Appear Closer Than They Are (edit)	356693	1
2758	1387	1243	aeb93dfc-0600-416d-a589-926b444a604e	Appear	618000	4
2759	1388	1244	77a0e35f-e68d-4191-9f62-9b2d94e7920d	appear	261000	7
2760	1389	1245	18281280-d9d5-4ca6-a42a-f2dff613ffa8	私に帰ろう	301000	1
2761	1389	1245	b4f90861-622c-471a-8070-4a0cd92cd814	I'm gonna make it	263000	2
2762	1389	1245	ecc8b167-d1bd-41f9-a09d-bcd05950db65	粉雪のプロローグ	262000	3
2763	1389	1245	eaa6297f-70f7-4642-aac9-3d7cd39c04ca	fairly garden	218000	4
2764	1389	1245	59152a7d-599a-44ed-b597-da9c7bdeee23	おもちゃ	284000	5
2765	1389	1245	7c49e0c3-7d89-4b55-ad5f-c0a7b4a7001b	しあわせの向こう側	252000	6
2766	1389	1245	ab4a69ca-b047-483e-aa86-ec0afe113938	雨	256000	7
2767	1389	1245	c79d83d4-8e95-446c-a529-77cca2ebbc7d	hurt	290000	8
2768	1389	1245	436621e3-d438-45a6-b8d3-b13bc9f0f07d	Forever dream	318000	9
2769	1389	1245	21602029-abb0-43bc-a29b-455ec8fd6798	那由多の夢	438000	10
2770	1390	1246	8831ee73-624f-4463-b098-b1ebaf93cf9c	As they appear	351400	6
2771	1391	1247	a0ff9627-9281-4f9e-8828-94becfe41584	Appear and Laugh	302000	14
2772	1392	1248	402c1df7-b827-44ff-b344-2cba4c4b0393	Monsters Appear!!	6773	29
2773	1393	1249	8815ab0c-f816-4428-8190-f052285d00e8	Forget to Appear...	244000	9
2774	1394	1250	9519519f-3b11-4659-a094-b3ab69781147	Yet to Appear	169000	17
2775	1395	1251	6c8fd6d9-d1b1-477a-960c-f5f8ef1980b1	 Danno	237506	1
2776	1395	1251	a34fa7e4-4066-4c28-9d82-1d2c19b243d1	Non Stop Girls	161573	2
2777	1395	1251	d6375443-3f93-4c89-a5a6-2d3103db4c35	Anglo Girl Desire	187706	3
2778	1396	1252	c40dfc64-ec22-44d5-9a70-00e7848c87d8	Victory	215280	1
2779	1397	1252	898dd944-8a5f-43ee-9893-41da21cb9587	Victory	215826	1
2780	1398	1253	81a2c251-686a-4ccd-96ea-8e190c4e02e0	Victory	206000	1
2781	1399	1254	04dd867c-b8fd-4d29-ac22-d1b9ea34357d	[untitled]	205000	4
2782	1399	1254	4f55b31f-4d2b-4f57-ae15-a25307926a06	[untitled]	21000	17
2783	1399	1254	a21fa19a-fdc8-4c52-bf1c-bdb15b809410	[untitled]	209000	9
2784	1400	1255	a6f3d5b7-8519-440a-a4d5-819390f54b6c	My Mother's Name Is Victory	231000	9
2785	1401	1256	170005d6-6093-49ce-8c69-6bc7e0b9aefa	Santy Anno	204106	1
2786	1401	1256	c0f92108-d193-46e1-86ee-dbb347c40b60	Rollin Down to Old Maui	236360	7
2787	1401	1256	a478d8b5-9133-4f5d-939c-6855603eb2d2	Leaving of Liverpool	212066	11
2788	1401	1256	0c9d5cfa-52db-4ef2-961b-9b2efdc2e863	Across the Western Ocean	225173	19
2789	1402	1257	65c16dbc-b389-4847-ac5b-6dea25463480	Victory	263000	2
2790	1403	1258	3bb9696a-6c86-4015-a6b4-c2e9113e2db6	Victory	288680	12
2791	1404	1259	bd177d63-5bcb-4346-810d-0d2a0f55429e	Victory	244666	10
2792	1405	1260	5a459fa9-f594-4757-b508-8c1fb6a45715	Victory	343973	11
2793	1406	1261	16b7a880-06ae-4ef1-b526-df15559a78ee	Victory	185000	1
2794	1407	1262	6a43aad2-6bcb-411d-9b35-0922fa05d0d1	Victory	253333	1
2795	1408	1263	0ddb3f3e-c1a7-47f9-b615-cac7418a2d1b	Victory!	348293	1
2796	1409	1264	f22e3bfa-ec56-4f35-92f0-dbf0a6dfc10c	Victory	284466	1
2797	1410	1265	8ca07fbf-042b-4788-8d3e-6462d6593bac	Victory	319000	8
2798	1411	1266	f1f9b658-1dab-461d-836d-c8a183849326	Victory	247000	1
2799	1412	1267	0d8f233c-6845-45d3-8f5d-0461cadc1f0b	Victory	271000	11
2800	1413	1268	a039b97b-5a23-41d3-b43f-d5edb65e976e	Victory or Valhalla	229906	1
2801	1414	1269	8e6d6fce-69f6-488a-84fe-5ef8c474f34f	Victory Day	211734	16
2802	1415	1270	888809e0-4956-45ad-8744-9e2b7dd931d3	Am I Mad?	210000	5
2803	1416	1271	c47241ff-98ec-45dd-babd-3250faab5c44	Worst Best Friend	169600	15
2804	1417	1272	a0e1c1d0-6267-4fe0-906f-2cc40909f8fe	World in My Eyes (feat. Holestar)	244000	1
2805	1418	1272	586b238a-5e5a-43c7-828b-77c03e536848	Don't Write Me Off	107466	15
2806	1418	1272	acaa079c-f329-4df9-9571-c149d6052844	Filter	172626	23
2807	1419	1272	62dde082-1cc0-4395-a5f4-5db683d1f814	My Sharona (remix)	266000	1
2808	1420	1273	cef838fa-055e-47b5-9d98-fbea506c041b	Gameover	161000	2
2809	1421	1274	fd39b3ba-bb13-43e1-81d0-a45919d8fa04	Gameover	252640	7
2810	1422	1274	38980201-f6c6-4201-b4ff-2a145c3e007b	Gameover	252640	7
2811	1423	1275	9e771d60-0d59-4b9b-acf4-e12bd8641a4d	Gameover	149334	17
2812	1424	1275	d97c20a7-d171-4721-9f8c-81cd52ac0849	Gameover	146307	17
2813	1425	1276	a2022344-f16e-4a77-a622-089a388091c2	Gameover	6853	15
2814	1426	1277	27a2d715-d8ee-4fdc-9629-ff30b934d7cd	Gameover	0	6
2815	1427	1278	ead2ad02-806f-4f4a-9ef4-e66243757006	Gameover	17000	11
2816	1428	1279	19b5b940-eff2-4b2c-b6f4-a3ae089e9a04	Gameover	122000	17
2817	1429	1280	30d0657b-7176-4693-abc1-526eadf0166c	Public Gameover	242000	2
2818	1430	1281	9c752495-dab8-4398-9e41-ead2ce96cb87	GameOver! men	4774	41
2819	1431	1282	db352a3f-1274-48a2-af2d-832a8f5c7dc0	Gameover V.I.P	104120	20
2820	1432	1283	5215b8b1-e552-4a56-b0ec-da4bd326e69b	End of a Century (Gameover remix)	0	3
2821	1433	1284	37665711-cbd3-4dff-92c4-4b2d01ec606f	Gameover: Thanks for Playing	149000	10
2822	1434	1285	85a86a0b-9cfe-452b-96eb-66e541f7e112	Space for Another (Gameover)	0	5
2823	1435	1286	81e186cd-2243-4da0-b7e9-ff2cf0129568	贄のなれ果て ～GameOver～	11480	11
2824	1436	1281	6b597671-6fe5-419d-8316-350b7bf60fc2	怒首領蜂大往生 - GameOver	12000	13
2825	1437	1287	5788d5cc-b626-46dd-a30a-d5662719a9bd	Don't Fight It Feel It (Gameover's Don't Fight It Steal It mix)	262000	3
2310	1130	1034	f73b2503-205e-4ede-b9d6-c2186c252320	Closure (Slide's Fat Channel mix)	518000	2
2301	1123	1027	e6bef4a6-09f4-4221-a80f-cec8a794eccd	Bus Stop / Electric Slide (Radio)	285360	3
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
-- Name: metatrack_album_mbid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY metatrack
    ADD CONSTRAINT metatrack_album_mbid_key UNIQUE (album_mbid, track_mbid);


--
-- Name: metatrack_artist_mbid_key; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY metatrack
    ADD CONSTRAINT metatrack_artist_mbid_key UNIQUE (artist_mbid, album_mbid);


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
-- Name: metatrack; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE metatrack FROM PUBLIC;
REVOKE ALL ON TABLE metatrack FROM canidae;
GRANT ALL ON TABLE metatrack TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE metatrack TO locutus;


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

