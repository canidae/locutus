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
    last_update timestamp without time zone DEFAULT now() NOT NULL
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

SELECT pg_catalog.setval('setting_setting_id_seq', 20, true);


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

COPY album (album_id, artist_id, mbid, type, title, released, custom_artist_sortname, last_updated) FROM stdin;
\.


--
-- Data for Name: artist; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY artist (artist_id, mbid, name, sortname) FROM stdin;
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

COPY metadata_match (file_id, metatrack_id, score) FROM stdin;
\.


--
-- Data for Name: metatrack; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY metatrack (metatrack_id, track_mbid, track_title, duration, tracknumber, artist_mbid, artist_name, album_mbid, album_title, last_updated) FROM stdin;
\.


--
-- Data for Name: puid; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY puid (puid_id, puid) FROM stdin;
\.


--
-- Data for Name: puid_metatrack; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY puid_metatrack (puid_id, metatrack_id, last_update) FROM stdin;
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
19	4	album_cache_lifetime	3	f	When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again.
20	4	puid_cache_lifetime	3	f	When it's more than this months since puid was fetched from MusicBrainz, it'll be fetched from MusicBrainz again.
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
-- Name: metadata_match_pkey; Type: CONSTRAINT; Schema: public; Owner: canidae; Tablespace: 
--

ALTER TABLE ONLY metadata_match
    ADD CONSTRAINT metadata_match_pkey PRIMARY KEY (file_id, metatrack_id);


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
-- Name: metadata_match_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY metadata_match
    ADD CONSTRAINT metadata_match_file_id_fkey FOREIGN KEY (file_id) REFERENCES file(file_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: metadata_match_metatrack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: canidae
--

ALTER TABLE ONLY metadata_match
    ADD CONSTRAINT metadata_match_metatrack_id_fkey FOREIGN KEY (metatrack_id) REFERENCES metatrack(metatrack_id) ON UPDATE CASCADE ON DELETE CASCADE;


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

