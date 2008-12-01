--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: album; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE album (
    album_id integer NOT NULL,
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    type character varying NOT NULL,
    title character varying NOT NULL,
    released date,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: artist; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE artist (
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    name character varying NOT NULL,
    sortname character varying NOT NULL
);


--
-- Name: file; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE file (
    file_id integer NOT NULL,
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
    musicbrainz_albumartistid character varying(36) NOT NULL,
    musicbrainz_albumid character varying(36) NOT NULL,
    musicbrainz_artistid character varying(36) NOT NULL,
    musicbrainz_trackid character varying(36) NOT NULL,
    title character varying NOT NULL,
    tracknumber character varying NOT NULL,
    released character varying NOT NULL,
    genre character varying NOT NULL,
    pinned boolean DEFAULT false NOT NULL,
    groupname character varying DEFAULT ''::character varying NOT NULL,
    duplicate boolean DEFAULT false NOT NULL,
    force_save boolean DEFAULT false NOT NULL,
    user_changed boolean DEFAULT false NOT NULL,
    matched integer,
    checked boolean DEFAULT true NOT NULL,
    CONSTRAINT file_musicbrainz_albumartistid_check CHECK (((length((musicbrainz_albumartistid)::text) = 0) OR (length((musicbrainz_albumartistid)::text) = 36))),
    CONSTRAINT file_musicbrainz_albumid_check CHECK (((length((musicbrainz_albumid)::text) = 0) OR (length((musicbrainz_albumid)::text) = 36))),
    CONSTRAINT file_musicbrainz_artistid_check CHECK (((length((musicbrainz_artistid)::text) = 0) OR (length((musicbrainz_artistid)::text) = 36))),
    CONSTRAINT file_musicbrainz_trackid_check CHECK (((length((musicbrainz_trackid)::text) = 0) OR (length((musicbrainz_trackid)::text) = 36)))
);


--
-- Name: locutus; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE locutus (
    active boolean DEFAULT false NOT NULL,
    start timestamp without time zone DEFAULT now() NOT NULL,
    stop timestamp without time zone DEFAULT now() NOT NULL,
    progress real DEFAULT 0.0 NOT NULL
);


--
-- Name: match; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE match (
    file_id integer NOT NULL,
    track_id integer NOT NULL,
    mbid_match boolean NOT NULL,
    puid_match boolean NOT NULL,
    meta_score double precision NOT NULL,
    CONSTRAINT match_meta_score_check CHECK (((meta_score >= (0.0)::double precision) AND (meta_score <= (1.0)::double precision)))
);


--
-- Name: puid; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE puid (
    puid_id integer NOT NULL,
    puid character(36) NOT NULL
);


--
-- Name: setting; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE setting (
    setting_id integer NOT NULL,
    key character varying NOT NULL,
    default_value character varying NOT NULL,
    value character varying NOT NULL,
    description character varying NOT NULL
);


--
-- Name: track; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE track (
    track_id integer NOT NULL,
    album_id integer NOT NULL,
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    title character varying NOT NULL,
    duration integer DEFAULT 0 NOT NULL,
    tracknumber integer NOT NULL,
    CONSTRAINT track_duration_check CHECK ((duration >= 0)),
    CONSTRAINT track_tracknumber_check CHECK ((tracknumber > 0))
);


--
-- Name: test; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW test AS
    SELECT ar.artist_id, ar.name AS artist, al.album_id, al.title AS album, count(DISTINCT t.track_id) AS tracks, count(DISTINCT m.track_id) AS tracks_compared, count(DISTINCT m.file_id) AS unique_files, count(m.file_id) AS files_compared, sum((m.mbid_match)::integer) AS mbids_matched, min(m.meta_score) AS min_score, max(m.meta_score) AS max_score, avg(m.meta_score) AS avg_score FROM (((album al JOIN artist ar ON ((al.artist_id = ar.artist_id))) JOIN track t USING (album_id)) LEFT JOIN match m USING (track_id)) WHERE (al.album_id IN (SELECT t.album_id FROM ((track t JOIN match m USING (track_id)) JOIN (SELECT file.file_id FROM file WHERE (file.matched IS NULL) ORDER BY random() LIMIT 5) tmp USING (file_id)))) GROUP BY ar.artist_id, ar.name, al.album_id, al.title ORDER BY (avg(m.meta_score) * (count(DISTINCT m.track_id))::double precision) DESC;


--
-- Name: v_daemon_load_album; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_daemon_load_album AS
    SELECT al.album_id AS album_album_id, al.mbid AS album_mbid, al.type AS album_type, al.title AS album_title, al.released AS album_released, al.last_updated AS album_last_updated, ar.artist_id AS artist_artist_id, ar.mbid AS artist_mbid, ar.name AS artist_name, ar.sortname AS artist_sortname, tr.track_id AS track_track_id, tr.mbid AS track_mbid, tr.title AS track_title, tr.duration AS track_duration, tr.tracknumber AS track_tracknumber, ta.artist_id AS track_artist_artist_id, ta.mbid AS track_artist_mbid, ta.name AS track_artist_name, ta.sortname AS track_artist_sortname FROM (((album al JOIN artist ar ON ((al.artist_id = ar.artist_id))) JOIN track tr ON ((tr.album_id = al.album_id))) JOIN artist ta ON ((tr.artist_id = ta.artist_id)));


--
-- Name: v_daemon_load_metafile; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_daemon_load_metafile AS
    SELECT f.filename, f.duration, f.channels, f.bitrate, f.samplerate, p.puid, COALESCE(al.title, f.album) AS album, COALESCE(aa.name, f.albumartist) AS albumartist, COALESCE(aa.sortname, f.albumartistsort) AS albumartistsort, COALESCE(ar.name, f.artist) AS artist, COALESCE(ar.sortname, f.artistsort) AS artistsort, COALESCE(aa.mbid, (f.musicbrainz_albumartistid)::bpchar) AS musicbrainz_albumartistid, COALESCE(al.mbid, (f.musicbrainz_albumid)::bpchar) AS musicbrainz_albumid, COALESCE(ar.mbid, (f.musicbrainz_artistid)::bpchar) AS musicbrainz_artistid, COALESCE(t.mbid, (f.musicbrainz_trackid)::bpchar) AS musicbrainz_trackid, COALESCE(t.title, f.title) AS title, COALESCE((t.tracknumber)::character varying, f.tracknumber) AS tracknumber, COALESCE((al.released)::character varying, f.released) AS released, f.genre, f.pinned, f.force_save, (f.matched IS NOT NULL) AS matched FROM (((((file f LEFT JOIN puid p ON ((p.puid_id = f.puid_id))) LEFT JOIN track t ON ((t.track_id = f.matched))) LEFT JOIN artist ar ON ((ar.artist_id = t.artist_id))) LEFT JOIN album al ON ((al.album_id = t.album_id))) LEFT JOIN artist aa ON ((aa.artist_id = al.artist_id)));


--
-- Name: v_web_album_list_tracks_and_matching_files; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_album_list_tracks_and_matching_files AS
    SELECT t.album_id, t.track_id, m.mbid_match, m.meta_score, f.file_id, f.filename, f.last_updated, f.duration, f.channels, f.bitrate, f.samplerate, f.puid_id, f.album, f.albumartist, f.albumartistsort, f.artist, f.artistsort, f.musicbrainz_albumartistid, f.musicbrainz_albumid, f.musicbrainz_artistid, f.musicbrainz_trackid, f.title, f.tracknumber, f.released, f.genre, f.pinned, f.groupname, f.duplicate, f.force_save, f.user_changed, f.matched, f.checked FROM ((track t LEFT JOIN match m USING (track_id)) LEFT JOIN file f USING (file_id)) WHERE ((f.matched IS NULL) OR (f.matched = t.track_id));


--
-- Name: v_web_album_matching_list_albums; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_album_matching_list_albums AS
    SELECT al.album_id, al.title AS album, (SELECT count(*) AS count FROM track t WHERE (t.album_id = al.album_id)) AS tracks, sum(tmp.mbid_matches) AS mbid_matches, (sum(tmp.sum_score) * (sum(tmp.compared_track_count))::double precision) AS score FROM (album al JOIN (SELECT t.album_id, sum((m.mbid_match)::integer) AS mbid_matches, sum(m.meta_score) AS sum_score, count(DISTINCT m.track_id) AS compared_track_count FROM (match m JOIN track t USING (track_id)) WHERE (m.file_id IN (SELECT file.file_id FROM file WHERE (file.matched IS NULL) LIMIT 5000)) GROUP BY t.album_id) tmp USING (album_id)) GROUP BY al.album_id, al.title;


--
-- Name: v_web_file_list_matching_tracks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_file_list_matching_tracks AS
    SELECT f.file_id, ar.artist_id AS albumartist_id, ar.name AS albumartist, al.album_id, al.title AS album, ta.artist_id, ta.name AS artist, tr.track_id, tr.title, tr.tracknumber, tr.duration, m.mbid_match, m.meta_score FROM (((((file f JOIN match m ON ((m.file_id = f.file_id))) JOIN track tr ON ((tr.track_id = m.track_id))) JOIN album al ON ((al.album_id = tr.album_id))) JOIN artist ar ON ((ar.artist_id = al.artist_id))) JOIN artist ta ON ((ta.artist_id = tr.artist_id)));


--
-- Name: v_web_info_album; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_info_album AS
    SELECT al.album_id, al.artist_id, al.mbid, al.type, al.title, al.released, al.last_updated, ar.name AS artist_name FROM (album al JOIN artist ar ON ((al.artist_id = ar.artist_id)));


--
-- Name: v_web_info_artist; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_info_artist AS
    SELECT artist.artist_id, artist.mbid, artist.name, artist.sortname FROM artist;


--
-- Name: v_web_info_file; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_info_file AS
    SELECT file.file_id, file.filename, file.last_updated, file.duration, file.channels, file.bitrate, file.samplerate, file.puid_id, file.album, file.albumartist, file.albumartistsort, file.artist, file.artistsort, file.musicbrainz_albumartistid, file.musicbrainz_albumid, file.musicbrainz_artistid, file.musicbrainz_trackid, file.title, file.tracknumber, file.released FROM file;


--
-- Name: v_web_info_track; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_info_track AS
    SELECT tr.track_id, tr.album_id, tr.artist_id, tr.mbid, tr.title, tr.duration, tr.tracknumber, ar.name AS artist_name, al.title AS album_title FROM ((track tr LEFT JOIN artist ar ON ((tr.artist_id = ar.artist_id))) LEFT JOIN album al ON ((tr.album_id = al.album_id)));


--
-- Name: v_web_list_albums; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_list_albums AS
    SELECT al.album_id, al.artist_id, al.mbid, al.type, al.title, al.released, al.last_updated, COALESCE((SELECT count(*) AS count FROM track tr WHERE (tr.album_id = al.album_id)), (0)::bigint) AS tracks, ar.name AS artist_name FROM (album al LEFT JOIN artist ar ON ((al.artist_id = ar.artist_id)));


--
-- Name: v_web_list_artists; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_list_artists AS
    SELECT ar.artist_id, ar.mbid, ar.name, ar.sortname, count(*) AS albums FROM (artist ar JOIN album al ON ((ar.artist_id = al.artist_id))) GROUP BY ar.artist_id, ar.mbid, ar.name, ar.sortname;


--
-- Name: v_web_list_files; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_list_files AS
    SELECT file.file_id, file.filename, file.last_updated, file.duration, file.channels, file.bitrate, file.samplerate, file.puid_id, file.album, file.albumartist, file.albumartistsort, file.artist, file.artistsort, file.musicbrainz_albumartistid, file.musicbrainz_albumid, file.musicbrainz_artistid, file.musicbrainz_trackid, file.title, file.tracknumber, file.released FROM file;


--
-- Name: v_web_list_tracks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_list_tracks AS
    SELECT tr.track_id, tr.album_id, tr.artist_id, tr.mbid, tr.title, tr.duration, tr.tracknumber, ar.name AS artist_name, al.title AS album_title FROM ((track tr LEFT JOIN artist ar ON ((tr.artist_id = ar.artist_id))) LEFT JOIN album al ON ((tr.album_id = al.album_id)));


--
-- Name: v_web_track_list_matching_files; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_track_list_matching_files AS
    SELECT f.file_id, f.filename, f.last_updated, f.duration, f.channels, f.bitrate, f.samplerate, f.puid_id, f.album, f.albumartist, f.albumartistsort, f.artist, f.artistsort, f.musicbrainz_albumartistid, f.musicbrainz_albumid, f.musicbrainz_artistid, f.musicbrainz_trackid, f.title, f.tracknumber, f.released, f.genre, f.pinned, f.groupname, f.matched, f.duplicate, f.force_save, f.user_changed, m.track_id, m.mbid_match, m.puid_match, m.meta_score FROM (file f JOIN match m ON ((f.file_id = m.file_id)));


--
-- Name: v_web_uncompared_files_list_files; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_uncompared_files_list_files AS
    SELECT file.file_id, file.filename, file.last_updated, file.duration, file.channels, file.bitrate, file.samplerate, file.puid_id, file.album, file.albumartist, file.albumartistsort, file.artist, file.artistsort, file.musicbrainz_albumartistid, file.musicbrainz_albumid, file.musicbrainz_artistid, file.musicbrainz_trackid, file.title, file.tracknumber, file.released, file.genre, file.pinned, file.groupname, file.duplicate, file.force_save, file.user_changed, file.matched, file.checked FROM file WHERE (NOT (file.file_id IN (SELECT match.file_id FROM match)));


--
-- Name: plpgsql_call_handler(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION plpgsql_call_handler() RETURNS language_handler
    AS '$libdir/plpgsql.so', 'plpgsql_call_handler'
    LANGUAGE c;


--
-- Name: album_album_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE album_album_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: album_album_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE album_album_id_seq OWNED BY album.album_id;


--
-- Name: artist_artist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE artist_artist_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: artist_artist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE artist_artist_id_seq OWNED BY artist.artist_id;


--
-- Name: file_file_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_file_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: file_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_file_id_seq OWNED BY file.file_id;


--
-- Name: puid_puid_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE puid_puid_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: puid_puid_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE puid_puid_id_seq OWNED BY puid.puid_id;


--
-- Name: setting_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE setting_setting_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: setting_setting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE setting_setting_id_seq OWNED BY setting.setting_id;


--
-- Name: track_track_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE track_track_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: track_track_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE track_track_id_seq OWNED BY track.track_id;


--
-- Name: album_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE album ALTER COLUMN album_id SET DEFAULT nextval('album_album_id_seq'::regclass);


--
-- Name: artist_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE artist ALTER COLUMN artist_id SET DEFAULT nextval('artist_artist_id_seq'::regclass);


--
-- Name: file_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE file ALTER COLUMN file_id SET DEFAULT nextval('file_file_id_seq'::regclass);


--
-- Name: puid_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE puid ALTER COLUMN puid_id SET DEFAULT nextval('puid_puid_id_seq'::regclass);


--
-- Name: setting_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE setting ALTER COLUMN setting_id SET DEFAULT nextval('setting_setting_id_seq'::regclass);


--
-- Name: track_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE track ALTER COLUMN track_id SET DEFAULT nextval('track_track_id_seq'::regclass);


--
-- Name: album_album_mbid_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_album_mbid_key UNIQUE (mbid);


--
-- Name: album_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_pkey PRIMARY KEY (album_id);


--
-- Name: artist_artist_mbid_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artist
    ADD CONSTRAINT artist_artist_mbid_key UNIQUE (mbid);


--
-- Name: artist_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY artist
    ADD CONSTRAINT artist_pkey PRIMARY KEY (artist_id);


--
-- Name: file_filename_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_filename_key UNIQUE (filename);


--
-- Name: file_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_pkey PRIMARY KEY (file_id);


--
-- Name: match_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY match
    ADD CONSTRAINT match_pkey PRIMARY KEY (file_id, track_id);


--
-- Name: puid_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY puid
    ADD CONSTRAINT puid_pkey PRIMARY KEY (puid_id);


--
-- Name: puid_puid_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY puid
    ADD CONSTRAINT puid_puid_key UNIQUE (puid);


--
-- Name: setting_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (setting_id);


--
-- Name: track_album_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_album_id_key UNIQUE (album_id, tracknumber);


--
-- Name: track_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_pkey PRIMARY KEY (track_id);


--
-- Name: track_track_mbid_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_track_mbid_key UNIQUE (mbid);


--
-- Name: album_artist_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX album_artist_id_idx ON album USING btree (artist_id);


--
-- Name: file_matched_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX file_matched_idx ON file USING btree (matched);


--
-- Name: match_meta_score_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX match_meta_score_idx ON match USING btree (meta_score);


--
-- Name: match_track_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX match_track_id_idx ON match USING btree (track_id);


--
-- Name: track_artist_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX track_artist_id_idx ON track USING btree (artist_id);


--
-- Name: album_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY album
    ADD CONSTRAINT album_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: file_puid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_puid_id_fkey FOREIGN KEY (puid_id) REFERENCES puid(puid_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: file_user_matched_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_user_matched_fkey FOREIGN KEY (matched) REFERENCES track(track_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: match_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY match
    ADD CONSTRAINT match_file_id_fkey FOREIGN KEY (file_id) REFERENCES file(file_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: match_track_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY match
    ADD CONSTRAINT match_track_id_fkey FOREIGN KEY (track_id) REFERENCES track(track_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: track_album_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_album_id_fkey FOREIGN KEY (album_id) REFERENCES album(album_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: track_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY track
    ADD CONSTRAINT track_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES artist(artist_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

