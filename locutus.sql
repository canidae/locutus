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

SELECT pg_catalog.setval('album_album_id_seq', 1449, true);


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

SELECT pg_catalog.setval('artist_artist_id_seq', 1289, true);


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

SELECT pg_catalog.setval('metatrack_metatrack_id_seq', 489, true);


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

SELECT pg_catalog.setval('track_track_id_seq', 7903, true);


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
1438	1289	79024eb2-513b-484b-9301-bb3884cd047d	Compilation Official	Absolute Music 27	\N	\N	2008-06-05 21:49:02.563304
1439	1288	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	Album 	No Strings Attached	\N	\N	2008-06-05 21:49:07.103893
1440	1288	631c7d7a-fca8-4891-bf02-47462cff37a5	Album Official	No Strings Attached	\N	\N	2008-06-05 21:49:07.691082
1441	1288	ae94ea26-b263-407d-a9f9-bfeec05111c8	Album 	No Strings Attached	\N	\N	2008-06-05 21:49:08.939499
1442	1289	f42748d4-8908-4b1d-81b0-4ad918d40d7e	Compilation Promotion	Promo Only: Mainstream Radio, February 2000	\N	\N	2008-06-05 21:49:14.355932
1443	1288	711633d2-5ccc-44e1-9d32-4b401bca2716	Album Official	*NSYNC	1998-03-24	\N	2008-06-05 21:51:33.151891
1444	1288	f6010e25-d302-4848-9b07-53f715c363bb	Album Official	*NSync	1998-03-24	\N	2008-06-05 21:51:39.724041
1445	1288	5f68e32a-ccc1-4b01-a4de-daa880bf3864	Album 	No Strings Attached	2001-01-01	\N	2008-06-05 21:51:46.874656
1446	1288	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	Album Official	No Strings Attached	2000-03-21	\N	2008-06-05 21:51:47.519983
1447	1288	65fb1b24-f321-4d6b-aaa5-0fd66d311c15	Compilation Official	Greatest Hits	2005-10-25	\N	2008-06-05 21:51:52.432554
1448	1289	70666922-6d32-41fc-b208-0b91c42c35a1	Compilation Official	Now That's What I Call Music! 5	2000-11-14	\N	2008-06-05 21:52:01.339921
1449	1289	130dde16-0fee-428f-820e-7ce449ed50e1	Compilation Official	Smash Hits: The Reunion (disc 2)	2003-01-01	\N	2008-06-05 21:52:07.735393
\.


--
-- Data for Name: artist; Type: TABLE DATA; Schema: public; Owner: canidae
--

COPY artist (artist_id, mbid, name, sortname) FROM stdin;
1288	603ba565-3967-4be1-931e-9cb945394e86	*NSync	NSYNC
1289	89ad4ac3-39f7-470e-963a-56509c546377	Various Artists	Various Artists
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
458	e77b5548-66d5-42d7-829b-86657a6cb596	God Must Have Spent a Little More Time on You	282960	5	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-05 21:54:26.996237
459	9020d8e7-aebd-4ade-95dc-f39649031034	I Want You Back	202106	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	711633d2-5ccc-44e1-9d32-4b401bca2716	*NSYNC	2008-06-05 21:54:29.188052
460	63e8c7c8-80f3-4b0c-957c-e248542f83b0	Forever Young	247400	14	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f6010e25-d302-4848-9b07-53f715c363bb	*NSync	2008-06-05 21:54:30.739966
461	b6cfb931-fe77-4cc1-8870-89d816b1a5f6	Pop	176160	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	79024eb2-513b-484b-9301-bb3884cd047d	Absolute Music 27	2008-06-05 21:54:33.056055
462	9a76541c-6219-4716-aab7-9bbb45c925b6	This I Promise You	284733	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-05 21:54:35.452046
463	73638768-0b5c-4791-8a4e-5a192217a019	This I Promise You	284760	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-05 21:54:35.483968
464	3c0a5b36-5e34-43b6-aba4-998a6f242a8c	This I Promise You	284760	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-05 21:54:35.519957
465	d2c36a97-6596-439e-9018-3d9ff08278c1	This I Promise You	284760	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-05 21:54:35.551958
466	aec2ef6c-672b-457e-b17e-06960cc0c214	This I Promise You	285200	6	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-05 21:54:35.579972
467	0c06b996-1890-445a-9561-1dfd37ac5852	I'll Never Stop	206426	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-05 21:54:37.559961
468	09a9f27b-01c2-44f7-9948-f9378ee60b8f	I'll Never Stop	203000	9	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-05 21:54:37.568043
469	d3107b60-5c69-4337-a468-6a8f7ed3d553	If I'm Not The One	202106	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-05 21:54:37.579958
470	d57ee379-ad62-404c-a36e-3e43945e608e	If I'm Not the One	202106	13	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-05 21:54:37.58794
471	a46bb9f8-1436-4ea7-b3fb-d997ec3f2ad5	Bye Bye Bye	201373	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-05 21:54:40.027988
472	14f07a28-8c8f-4c2a-8a43-a19e27f40099	Bye Bye Bye	200400	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-05 21:54:40.035946
473	03e1ec9e-7d12-44c3-830f-bdd631fc6cd7	Bye Bye Bye	202786	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-05 21:54:40.043955
474	d4b4a809-0ec3-404b-b87f-ed117674ba0b	Bye Bye Bye	200400	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-05 21:54:40.051945
475	64580be4-9eda-4ca1-89b7-3365c43d2122	Bye Bye Bye	200560	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-05 21:54:40.05996
476	bc318e9a-fe4f-40a9-ba51-d292e672207d	Bye, Bye, Bye	200000	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	65fb1b24-f321-4d6b-aaa5-0fd66d311c15	Greatest Hits	2008-06-05 21:54:40.070997
477	9ceade08-7170-457c-b0a9-bb951b9bca57	Bye Bye Bye	199320	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	f42748d4-8908-4b1d-81b0-4ad918d40d7e	Promo Only: Mainstream Radio, February 2000	2008-06-05 21:54:40.100019
478	eb55ad9e-0070-472c-bb04-a2127b179f27	Digital Get Down	263200	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-05 21:54:42.259961
479	4f361aa3-1339-4bce-a944-dcd55e104b34	Digital Get Down	261333	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-05 21:54:42.267943
480	2724dcfc-3217-448e-9c6f-6a03750079b4	Digital Get Down	261466	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-05 21:54:42.275942
481	ef70aaa1-efe9-4558-ae0c-83727b8dfbbb	Digital Get Down	263200	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-05 21:54:42.283933
482	fa844934-e783-4d78-9b50-49d2bc5bd357	Digital Get Down	264320	8	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-05 21:54:42.28905
483	671fbe8f-1b41-48fb-868d-21de0508186c	It's Gonna Be Me	192426	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	3f0dcafd-359f-46b9-b2bc-988a5eb8fe02	No Strings Attached	2008-06-05 21:54:45.08401
484	d979f2c8-90c1-4670-a417-a31eea9b477f	It's Gonna Be Me	192373	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	dec22fe3-01f1-43f3-bd91-11b93c35c1e0	No Strings Attached	2008-06-05 21:54:45.091959
485	c2580264-8e00-41e4-acf1-aa52a5f5decb	It's Gonna Be Me	192426	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	631c7d7a-fca8-4891-bf02-47462cff37a5	No Strings Attached	2008-06-05 21:54:45.099951
486	8e158c90-bc55-4a7e-8999-52d191ffe177	It's Gonna Be Me	192426	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	5f68e32a-ccc1-4b01-a4de-daa880bf3864	No Strings Attached	2008-06-05 21:54:45.108016
487	d0f6da35-48b4-489d-9d19-c0881625e8a6	It's Gonna Be Me	193600	2	603ba565-3967-4be1-931e-9cb945394e86	*NSync	ae94ea26-b263-407d-a9f9-bfeec05111c8	No Strings Attached	2008-06-05 21:54:45.115961
488	236c4951-f779-4ae1-ab61-741cf0a2133c	It's Gonna Be Me	190826	1	603ba565-3967-4be1-931e-9cb945394e86	*NSync	70666922-6d32-41fc-b208-0b91c42c35a1	Now That's What I Call Music! 5	2008-06-05 21:54:48.732008
489	84a7c3b4-5c8f-4895-af1c-292bcf80480a	Bye Bye Bye	199666	11	603ba565-3967-4be1-931e-9cb945394e86	*NSync	130dde16-0fee-428f-820e-7ce449ed50e1	Smash Hits: The Reunion (disc 2)	2008-06-05 21:54:54.78805
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
7671	1438	1288	b6cfb931-fe77-4cc1-8870-89d816b1a5f6	Pop	176160	11
7693	1439	1288	64580be4-9eda-4ca1-89b7-3365c43d2122	Bye Bye Bye	200560	1
7694	1439	1288	d979f2c8-90c1-4670-a417-a31eea9b477f	It's Gonna Be Me	192373	2
7695	1439	1288	a7dd8dbb-5439-443c-9f38-a758bd7dc9c9	Space Cowboy	263400	3
7696	1439	1288	2374bcad-335d-444d-b098-0a760e08f9c4	Just Got Paid	250133	4
7697	1439	1288	2c614148-f591-44e5-a314-64ae5549efe5	It Makes Me Ill	207800	5
7698	1439	1288	73638768-0b5c-4791-8a4e-5a192217a019	This I Promise You	284760	6
7699	1439	1288	cbc6d7ca-2c59-450e-881f-00e7c45a28da	No Strings Attached	228640	7
7700	1439	1288	4f361aa3-1339-4bce-a944-dcd55e104b34	Digital Get Down	261333	8
7701	1439	1288	09a9f27b-01c2-44f7-9948-f9378ee60b8f	I'll Never Stop	203000	9
7702	1439	1288	769f1cdb-8d02-48d6-9153-4357338bf336	Bringin' da Noise	211333	10
7703	1439	1288	868fa25c-5348-4161-a812-b316f463a182	That's When I'll Stop Loving You	291760	11
7704	1439	1288	86345be3-79f8-4ddf-9d3f-7f4deaf6a0f3	I'll Be Good for You	235266	12
7705	1439	1288	d57ee379-ad62-404c-a36e-3e43945e608e	If I'm Not the One	202106	13
7706	1439	1288	a5bc287c-d688-44a7-986f-090e653fbb71	I Thought She Knew	202960	14
7707	1439	1288	c64591a0-60ae-491a-9266-fae134403c17	Could It Be You	222000	15
7708	1439	1288	5b59ff98-9683-40c2-a93e-ce024bd43ca6	This Is Where the Party's At	372213	16
7709	1440	1288	14f07a28-8c8f-4c2a-8a43-a19e27f40099	Bye Bye Bye	200400	1
7710	1440	1288	c2580264-8e00-41e4-acf1-aa52a5f5decb	It's Gonna Be Me	192426	2
7711	1440	1288	d1ac2dcf-28b5-4bcd-9c7f-959d701f0754	Space Cowboy	263466	3
7712	1440	1288	714b2916-7915-4fee-9e15-a50a96a82cfc	Just Got Paid	250000	4
7713	1440	1288	2cc7cb79-22a8-48fe-bd62-6f122ca7b1a2	It Makes Me Ill	207906	5
7714	1440	1288	3c0a5b36-5e34-43b6-aba4-998a6f242a8c	This I Promise You	284760	6
7715	1440	1288	a0320f1b-7e5f-41ae-b16e-ff5611b9184b	No Strings Attached	228906	7
7716	1440	1288	ef70aaa1-efe9-4558-ae0c-83727b8dfbbb	Digital Get Down	263200	8
7717	1440	1288	9b92c3b9-8e0e-47af-a91c-0086ec6d32c1	Bringin' da Noise	212066	9
7718	1440	1288	dc56a3ef-3e3f-4b57-b3f8-a46116b7142f	That's When I'll Stop Loving You	291760	10
7719	1440	1288	6a2858ae-030c-4bb9-a60d-027b2976ff77	I'll Be Good for You	236373	11
7720	1440	1288	eb1a198c-10b3-4286-b8ed-e8542e59d9ef	I Thought She Knew	202666	12
7721	1440	1288	0c06b996-1890-445a-9561-1dfd37ac5852	I'll Never Stop	206426	13
7722	1440	1288	99257296-d8f2-4c65-a946-4743a5f42cd4	If Only in Heaven's Eyes	278840	14
7723	1440	1288	f2a00a4f-dc45-4871-a0d3-f9a0e8a82d32	Could It Be You	219800	15
7736	1441	1288	03e1ec9e-7d12-44c3-830f-bdd631fc6cd7	Bye Bye Bye	202786	1
7737	1441	1288	d0f6da35-48b4-489d-9d19-c0881625e8a6	It's Gonna Be Me	193600	2
7738	1441	1288	1fde75bb-9483-4900-86c2-4fe1526afc1d	Space Cowboy	264413	3
7739	1441	1288	793c6c35-25ad-4133-8236-b38f171d1b91	Just Got Paid	250626	4
7740	1441	1288	191ef811-05eb-4218-b98e-83063c2d1119	It Makes Me Ill	208026	5
7741	1441	1288	aec2ef6c-672b-457e-b17e-06960cc0c214	This I Promise You	285200	6
7742	1441	1288	66f07e13-9aad-4ca0-b5af-5e395a0ae11f	No Strings Attached	228840	7
7743	1441	1288	fa844934-e783-4d78-9b50-49d2bc5bd357	Digital Get Down	264320	8
7744	1441	1288	c17995d6-774f-43f6-8155-a92c64f1bb8c	Bringin Da Noise	212506	9
7745	1441	1288	d7f4a379-11a9-4878-88f9-411bea3bed84	That's When I'll Stop Loving You	292346	10
7746	1441	1288	fb467c51-9582-4f9f-b5e7-95c159d6eadf	I'll Be Good For You	236800	11
7747	1441	1288	672b9f77-ecd3-4265-a964-5f5b3e40cf71	I Thought She Knew	201960	12
7748	1441	1288	b8ee546b-c3b8-4371-aed6-488041c47f12	Yo Te Voy A Amar	267666	13
7761	1442	1288	9ceade08-7170-457c-b0a9-bb951b9bca57	Bye Bye Bye	199320	1
7800	1443	1288	e8918777-b1ca-499e-b168-3649f0e2ea13	Tearin' Up My Heart	211000	1
7801	1443	1288	76cce4e7-c9d1-413e-a066-ff08e130dbff	I Just Wanna Be With You	243400	2
7802	1443	1288	144b3f0c-2dae-4a4c-902e-b122346cfb31	Here We Go	215866	3
7803	1443	1288	ad843218-b22f-45b6-8664-98c9539dca50	For the Girl Who Has Everything	226200	4
7804	1443	1288	e77b5548-66d5-42d7-829b-86657a6cb596	God Must Have Spent a Little More Time on You	282960	5
7805	1443	1288	fb5d01e0-2091-4fa0-bd06-20cf0f17134e	You Got It	213640	6
7806	1443	1288	e2cc2bec-29bf-4158-81bf-4e1307b83bbf	I Need Love	194960	7
7807	1443	1288	9020d8e7-aebd-4ade-95dc-f39649031034	I Want You Back	202106	8
7808	1443	1288	6d4f2747-2658-482b-ab76-8482b60d3e51	Everything I Own	238693	9
7809	1443	1288	5a22e684-b543-462c-a177-2235b7a5c36e	I Drive Myself Crazy	239733	10
7810	1443	1288	6f462501-111b-4e43-9574-7d12cb14ae5f	Crazy for You	221666	11
7811	1443	1288	8e3faaa9-e2b9-4c26-9bc8-748fd657bf61	Sailing	277640	12
7812	1443	1288	45a89256-b895-4d07-808b-ac05608429c1	Giddy Up	249960	13
7813	1444	1288	65776b8f-21cf-47bb-99e8-3660504b473c	Tearin' Up My Heart	287360	1
7814	1444	1288	681e75eb-efb6-4cc0-816f-73816a354bc9	You Got It	213066	2
7815	1444	1288	709e6196-3e0f-4726-82f1-4c6496a027ca	Sailing	276973	3
7816	1444	1288	ede6e302-5d5e-429b-ac6a-63c573574764	Crazy for You	222000	4
7817	1444	1288	1d660a11-648a-4caf-9735-bfb5b66608c9	Riddle	221133	5
7818	1444	1288	fd6d87c8-c4da-4e65-822d-596a49130066	For the Girl Who Has Everything	231360	6
7819	1444	1288	bfaf96a8-c954-4060-80ce-50c44c0f07b3	I Need Love	194866	7
7820	1444	1288	3ad4f1c0-ca53-4eca-8bad-86edb79a7012	Giddy Up	249666	8
7821	1444	1288	9ecf0a4c-9b2e-4242-9bd6-255dfbcb2005	Here We Go	216240	9
7822	1444	1288	dfea1c55-805d-4acf-aa44-ad7ce0f16fd3	Best of My Life	286493	10
7823	1444	1288	b4b8550f-4ccc-42ad-8410-87cfab8d98f3	More Than a Feeling	222706	11
7824	1444	1288	52a12817-0dc8-4488-a1df-ec2fd576b017	I Want You Back	264693	12
7825	1444	1288	d9c56e24-d37b-47bc-9d8f-bd5819c80467	Together Again	251840	13
7826	1444	1288	63e8c7c8-80f3-4b0c-957c-e248542f83b0	Forever Young	247400	14
7827	1445	1288	a46bb9f8-1436-4ea7-b3fb-d997ec3f2ad5	Bye Bye Bye	201373	1
7828	1445	1288	8e158c90-bc55-4a7e-8999-52d191ffe177	It's Gonna Be Me	192426	2
7829	1445	1288	1e35ce07-7632-40e9-a2ac-ee6f87e6a314	Space Cowboy (Yippie-Yi-Yay)	263440	3
7830	1445	1288	866c09e7-d5f3-4c32-a029-d56686fc3b54	Just Got Paid	250000	4
7831	1445	1288	88428b42-3b55-4b7d-9e54-f41fa063279f	It Makes Me Ill	207893	5
7832	1445	1288	9a76541c-6219-4716-aab7-9bbb45c925b6	This I Promise You	284733	6
7833	1445	1288	5d847153-0b7f-48da-890b-4a122f12d62d	No Strings Attached	228466	7
7834	1445	1288	2724dcfc-3217-448e-9c6f-6a03750079b4	Digital Get Down	261466	8
7835	1445	1288	04e1f9a4-0a6b-4a35-874e-9fd8436da7d8	I Will Never Stop	201133	9
7836	1445	1288	efc47178-9652-41f3-949a-9955db026178	Bringin' Da Noise	213240	10
7837	1445	1288	5ad4dffe-f9d1-4705-8c87-a2df3f0b398a	That's When I'll Stop Loving You	291666	11
7838	1445	1288	c0f3862f-8e07-4d79-b29e-63639a65e556	I'll Be Good For You	235293	12
7839	1445	1288	d3107b60-5c69-4337-a468-6a8f7ed3d553	If I'm Not The One	202106	13
7840	1445	1288	2935c5a1-41fe-4a1d-96b4-f79f03f34579	I Thought She Knew	201733	14
7841	1446	1288	d4b4a809-0ec3-404b-b87f-ed117674ba0b	Bye Bye Bye	200400	1
7842	1446	1288	671fbe8f-1b41-48fb-868d-21de0508186c	It's Gonna Be Me	192426	2
7843	1446	1288	d8af185e-1a2f-45d1-b5bd-dd73005b3be7	Space Cowboy	263466	3
7844	1446	1288	e6f4ee7d-2141-4896-b708-3438613ec64f	Just Got Paid	250000	4
7845	1446	1288	f2629c73-164d-46a8-9243-b15d25f4da66	It Makes Me Ill	207906	5
7846	1446	1288	d2c36a97-6596-439e-9018-3d9ff08278c1	This I Promise You	284760	6
7847	1446	1288	62f92d66-ec85-43fc-b633-8d8d7ba0910e	No Strings Attached	228906	7
7848	1446	1288	eb55ad9e-0070-472c-bb04-a2127b179f27	Digital Get Down	263200	8
7849	1446	1288	819002e9-1fbc-402f-b6e1-b1246c2a2853	Bringin' da Noise	212066	9
7850	1446	1288	dc1a30d8-dab6-4960-a3ec-a8d85c996f5b	That's When I'll Stop Loving You	291760	10
7851	1446	1288	7d3acea0-1ce7-4dd5-97d0-359453bbca40	I'll Be Good for You	236373	11
7852	1446	1288	cfe6c921-bfa6-47d1-bd32-fab242f9eac5	I Thought She Knew	202333	12
7853	1447	1288	bc318e9a-fe4f-40a9-ba51-d292e672207d	Bye, Bye, Bye	200000	1
7854	1447	1288	c0c6de7f-3282-420e-b64c-4a514f6ddfc8	Girlfriend (feat. Nelly) (remix)	285000	2
7855	1447	1288	b4eb9c9b-01a7-440d-a200-dd06f1df8b57	This I Promise You	267000	3
7856	1447	1288	e7a39e19-dbfd-4eb5-8c37-dc03102d8e6c	It's Gonna Be Me	192000	4
7857	1447	1288	35e2f88b-dc42-406f-baaa-3df42365d0d5	God Must Have Spent a Little More Time on You	244000	5
7858	1447	1288	6ff52679-9504-423d-a2c5-613bf36c3475	I Want You Back	200000	6
7859	1447	1288	e27ce99d-3dd0-4dea-9bf2-1fe9d4f364bc	Pop	176000	7
7860	1447	1288	e45165ef-c16e-4b72-9bc2-81e43a2dc4ec	Gone	293000	8
7861	1447	1288	761566f9-c063-4524-b4fd-d6c2143113e3	Tearin' Up My Heart	210000	9
7862	1447	1288	2d94654e-ae02-4a08-bc4e-d630452b9540	I Drive Myself Crazy	239000	10
7863	1447	1288	8d127905-819e-407b-b46a-a050a0b0a650	I'll Never Stop	188000	11
7864	1447	1288	5a11a41a-b387-4f64-bd39-d6fcfdbc6b8b	Music of My Heart (feat. Gloria Estefan)	271000	12
7865	1448	1288	236c4951-f779-4ae1-ab61-741cf0a2133c	It's Gonna Be Me	190826	1
7894	1449	1288	84a7c3b4-5c8f-4895-af1c-292bcf80480a	Bye Bye Bye	199666	11
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
-- Name: metadata_match; Type: ACL; Schema: public; Owner: canidae
--

REVOKE ALL ON TABLE metadata_match FROM PUBLIC;
REVOKE ALL ON TABLE metadata_match FROM canidae;
GRANT ALL ON TABLE metadata_match TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE metadata_match TO locutus;


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

