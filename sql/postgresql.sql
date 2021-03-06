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
-- Name: artist; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE artist (
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    name character varying NOT NULL,
    sortname character varying NOT NULL
);


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
-- Name: comparison; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comparison (
    file_id integer NOT NULL,
    track_id integer NOT NULL,
    mbid_match boolean NOT NULL,
    score double precision NOT NULL,
    CONSTRAINT comparison_score_check CHECK (((score >= (0.0)::double precision) AND (score <= (1.0)::double precision)))
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
    user_changed boolean DEFAULT false NOT NULL,
    track_id integer,
    checked boolean DEFAULT true NOT NULL,
    CONSTRAINT file_musicbrainz_albumartistid_check CHECK (((length((musicbrainz_albumartistid)::text) = 0) OR (length((musicbrainz_albumartistid)::text) = 36))),
    CONSTRAINT file_musicbrainz_albumid_check CHECK (((length((musicbrainz_albumid)::text) = 0) OR (length((musicbrainz_albumid)::text) = 36))),
    CONSTRAINT file_musicbrainz_artistid_check CHECK (((length((musicbrainz_artistid)::text) = 0) OR (length((musicbrainz_artistid)::text) = 36))),
    CONSTRAINT file_musicbrainz_trackid_check CHECK (((length((musicbrainz_trackid)::text) = 0) OR (length((musicbrainz_trackid)::text) = 36)))
);


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
-- Name: locutus; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE locutus (
    active boolean DEFAULT false NOT NULL,
    start timestamp without time zone DEFAULT now() NOT NULL,
    stop timestamp without time zone DEFAULT now() NOT NULL,
    progress real DEFAULT 0.0 NOT NULL
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
-- Name: track; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE track (
    track_id integer NOT NULL,
    album_id integer NOT NULL,
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    title character varying NOT NULL,
    tracknumber integer NOT NULL,
    duration integer DEFAULT 0 NOT NULL,
    CONSTRAINT track_tracknumber_check CHECK ((tracknumber > 0))
);


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
-- Name: v_daemon_load_album; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_daemon_load_album AS
    SELECT album.album_id AS album_album_id, album.mbid AS album_mbid, album.type AS album_type, album.title AS album_title, album.released AS album_released, album.last_updated AS album_last_updated, albumartist.artist_id AS albumartist_artist_id, albumartist.mbid AS albumartist_mbid, albumartist.name AS albumartist_name, albumartist.sortname AS albumartist_sortname, track.track_id AS track_track_id, track.mbid AS track_mbid, track.title AS track_title, track.tracknumber AS track_tracknumber, track.duration AS track_duration, trackartist.artist_id AS trackartist_artist_id, trackartist.mbid AS trackartist_mbid, trackartist.name AS trackartist_name, trackartist.sortname AS trackartist_sortname FROM (((album JOIN artist albumartist USING (artist_id)) JOIN track USING (album_id)) JOIN artist trackartist ON ((track.artist_id = trackartist.artist_id)));


--
-- Name: v_daemon_load_metafile; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_daemon_load_metafile AS
    SELECT f.filename, f.duration, f.channels, f.bitrate, f.samplerate, COALESCE(al.title, f.album) AS album, COALESCE(aa.name, f.albumartist) AS albumartist, COALESCE(aa.sortname, f.albumartistsort) AS albumartistsort, COALESCE(ar.name, f.artist) AS artist, COALESCE(ar.sortname, f.artistsort) AS artistsort, COALESCE(aa.mbid, (f.musicbrainz_albumartistid)::bpchar) AS musicbrainz_albumartistid, COALESCE(al.mbid, (f.musicbrainz_albumid)::bpchar) AS musicbrainz_albumid, COALESCE(ar.mbid, (f.musicbrainz_artistid)::bpchar) AS musicbrainz_artistid, COALESCE(t.mbid, (f.musicbrainz_trackid)::bpchar) AS musicbrainz_trackid, COALESCE(t.title, f.title) AS title, COALESCE((t.tracknumber)::character varying, f.tracknumber) AS tracknumber, COALESCE((al.released)::character varying, f.released) AS released, f.genre, f.pinned, f.groupname, (f.track_id IS NOT NULL) AS matched FROM ((((file f LEFT JOIN track t ON ((t.track_id = f.track_id))) LEFT JOIN artist ar ON ((ar.artist_id = t.artist_id))) LEFT JOIN album al ON ((al.album_id = t.album_id))) LEFT JOIN artist aa ON ((aa.artist_id = al.artist_id)));


--
-- Name: v_ui_matching_details; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_ui_matching_details AS
    SELECT album.album_id AS album_album_id, album.mbid AS album_mbid, album.type AS album_type, album.title AS album_title, album.released AS album_released, album.last_updated AS album_last_updated, albumartist.artist_id AS albumartist_artist_id, albumartist.mbid AS albumartist_mbid, albumartist.name AS albumartist_name, albumartist.sortname AS albumartist_sortname, track.track_id AS track_track_id, track.mbid AS track_mbid, track.title AS track_title, track.tracknumber AS track_tracknumber, track.duration AS track_duration, trackartist.artist_id AS trackartist_artist_id, trackartist.mbid AS trackartist_mbid, trackartist.name AS trackartist_name, trackartist.sortname AS trackartist_sortname, cft.comparison_mbid_match, cft.comparison_score, cft.file_file_id, cft.file_filename, cft.file_last_updated, cft.file_duration, cft.file_channels, cft.file_bitrate, cft.file_samplerate, cft.file_album, cft.file_albumartist, cft.file_albumartistsort, cft.file_artist, cft.file_artistsort, cft.file_musicbrainz_albumartistid, cft.file_musicbrainz_albumid, cft.file_musicbrainz_artistid, cft.file_musicbrainz_trackid, cft.file_title, cft.file_tracknumber, cft.file_released, cft.file_genre, cft.file_pinned, cft.file_groupname, cft.file_duplicate, cft.file_user_changed, cft.file_track_id, cft.file_checked FROM ((((album JOIN artist albumartist USING (artist_id)) JOIN track USING (album_id)) JOIN artist trackartist ON ((track.artist_id = trackartist.artist_id))) LEFT JOIN (SELECT DISTINCT ON (comparisontrack.album_id, file.file_id) comparison.mbid_match AS comparison_mbid_match, comparison.score AS comparison_score, file.file_id AS file_file_id, file.filename AS file_filename, file.last_updated AS file_last_updated, file.duration AS file_duration, file.channels AS file_channels, file.bitrate AS file_bitrate, file.samplerate AS file_samplerate, file.album AS file_album, file.albumartist AS file_albumartist, file.albumartistsort AS file_albumartistsort, file.artist AS file_artist, file.artistsort AS file_artistsort, file.musicbrainz_albumartistid AS file_musicbrainz_albumartistid, file.musicbrainz_albumid AS file_musicbrainz_albumid, file.musicbrainz_artistid AS file_musicbrainz_artistid, file.musicbrainz_trackid AS file_musicbrainz_trackid, file.title AS file_title, file.tracknumber AS file_tracknumber, file.released AS file_released, file.genre AS file_genre, file.pinned AS file_pinned, file.groupname AS file_groupname, file.duplicate AS file_duplicate, file.user_changed AS file_user_changed, file.track_id AS file_track_id, file.checked AS file_checked, comparisontrack.album_id AS comparisontrack_album_id, comparisontrack.track_id AS comparisontrack_track_id FROM ((comparison JOIN file USING (file_id)) JOIN track comparisontrack ON ((comparison.track_id = comparisontrack.track_id))) ORDER BY comparisontrack.album_id, file.file_id, comparison.mbid_match DESC, comparison.score DESC) cft ON (((track.album_id = cft.comparisontrack_album_id) AND (track.track_id = cft.comparisontrack_track_id))));


--
-- Name: v_ui_matching_list; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_ui_matching_list AS
    SELECT album.album_id, album.title AS album, (SELECT count(*) AS count FROM track WHERE (track.album_id = album.album_id)) AS tracks, count(DISTINCT ctf.file_id) AS files_compared, count(DISTINCT ctf.track_id) AS tracks_compared, sum((ctf.mbid_match)::integer) AS mbids_matched, max(ctf.score) AS max_score, avg(ctf.score) AS avg_score, min(ctf.score) AS min_score FROM ((SELECT DISTINCT ON (track.album_id, comparison.file_id) track.album_id, comparison.file_id, comparison.track_id, comparison.mbid_match, comparison.score FROM ((comparison JOIN track USING (track_id)) JOIN file USING (file_id)) WHERE (file.track_id IS NULL) ORDER BY track.album_id, comparison.file_id, comparison.mbid_match DESC, comparison.score DESC) ctf JOIN album USING (album_id)) GROUP BY album.album_id, album.title, (SELECT count(*) AS count FROM track WHERE (track.album_id = album.album_id));


--
-- Name: v_ui_uncompared_list; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_ui_uncompared_list AS
    SELECT file.file_id, file.filename, file.last_updated, file.duration, file.channels, file.bitrate, file.samplerate, file.album, file.albumartist, file.albumartistsort, file.artist, file.artistsort, file.musicbrainz_albumartistid, file.musicbrainz_albumid, file.musicbrainz_artistid, file.musicbrainz_trackid, file.title, file.tracknumber, file.released, file.genre, file.pinned, file.groupname, file.duplicate, file.user_changed, file.track_id, file.checked FROM file WHERE ((file.track_id IS NULL) AND (NOT (file.file_id IN (SELECT comparison.file_id FROM comparison))));


--
-- Name: v_web_album_list_tracks_and_matching_files; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_album_list_tracks_and_matching_files AS
    SELECT al.album_id, al.title AS album, ar.name AS artist, ar.artist_id, t.track_id, t.title, t.tracknumber, t.duration, ta.name AS track_artist, ta.artist_id AS track_artist_id, tmp.mbid_match, tmp.score, tmp.file_id, tmp.filename, tmp.file_duration, tmp.file_album, tmp.file_albumartist, tmp.file_artist, tmp.file_title, tmp.file_tracknumber, tmp.pinned, tmp.groupname, tmp.file_track_id, tmp.duplicate, tmp.user_changed FROM ((((album al JOIN artist ar ON ((al.artist_id = ar.artist_id))) JOIN track t ON ((al.album_id = t.album_id))) JOIN artist ta ON ((t.artist_id = ta.artist_id))) LEFT JOIN (SELECT DISTINCT ON (t.album_id, f.file_id) t.album_id, t.track_id, c.mbid_match, c.score, f.file_id, f.filename, f.duration AS file_duration, f.album AS file_album, f.albumartist AS file_albumartist, f.artist AS file_artist, f.title AS file_title, f.tracknumber AS file_tracknumber, f.pinned, f.groupname, f.track_id AS file_track_id, f.duplicate, f.user_changed FROM ((comparison c JOIN file f USING (file_id)) JOIN track t ON ((c.track_id = t.track_id))) ORDER BY t.album_id, f.file_id, c.mbid_match DESC, c.score DESC) tmp ON (((t.album_id = tmp.album_id) AND (t.track_id = tmp.track_id))));


--
-- Name: v_web_file_list_matching_tracks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_file_list_matching_tracks AS
    SELECT f.file_id, ar.artist_id AS albumartist_id, ar.name AS albumartist, al.album_id, al.title AS album, ta.artist_id, ta.name AS artist, tr.track_id, tr.title, tr.tracknumber, tr.duration, m.mbid_match, m.score FROM (((((file f JOIN comparison m ON ((m.file_id = f.file_id))) JOIN track tr ON ((tr.track_id = m.track_id))) JOIN album al ON ((al.album_id = tr.album_id))) JOIN artist ar ON ((ar.artist_id = al.artist_id))) JOIN artist ta ON ((ta.artist_id = tr.artist_id)));


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
    SELECT file.file_id, file.filename, file.last_updated, file.duration, file.channels, file.bitrate, file.samplerate, file.album, file.albumartist, file.albumartistsort, file.artist, file.artistsort, file.musicbrainz_albumartistid, file.musicbrainz_albumid, file.musicbrainz_artistid, file.musicbrainz_trackid, file.title, file.tracknumber, file.released FROM file;


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
    SELECT file.file_id, file.filename, file.last_updated, file.duration, file.channels, file.bitrate, file.samplerate, file.album, file.albumartist, file.albumartistsort, file.artist, file.artistsort, file.musicbrainz_albumartistid, file.musicbrainz_albumid, file.musicbrainz_artistid, file.musicbrainz_trackid, file.title, file.tracknumber, file.released FROM file;


--
-- Name: v_web_list_tracks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_list_tracks AS
    SELECT tr.track_id, tr.album_id, tr.artist_id, tr.mbid, tr.title, tr.duration, tr.tracknumber, ar.name AS artist_name, al.title AS album_title FROM ((track tr LEFT JOIN artist ar ON ((tr.artist_id = ar.artist_id))) LEFT JOIN album al ON ((tr.album_id = al.album_id)));


--
-- Name: v_web_matching_list_albums; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_matching_list_albums AS
    SELECT tmp.album_id, a.title AS album, (SELECT count(*) AS count FROM track t WHERE (t.album_id = a.album_id)) AS tracks, count(DISTINCT tmp.file_id) AS files_compared, count(DISTINCT tmp.track_id) AS tracks_compared, sum((tmp.mbid_match)::integer) AS mbids_matched, max(tmp.score) AS max_score, avg(tmp.score) AS avg_score, min(tmp.score) AS min_score FROM ((SELECT DISTINCT ON (t.album_id, c.file_id) t.album_id, c.file_id, c.track_id, c.mbid_match, c.score FROM ((file f JOIN comparison c USING (file_id)) JOIN track t ON ((c.track_id = t.track_id))) WHERE (f.track_id IS NULL) ORDER BY t.album_id, c.file_id, c.mbid_match DESC, c.score DESC) tmp JOIN album a USING (album_id)) GROUP BY tmp.album_id, a.title, (SELECT count(*) AS count FROM track t WHERE (t.album_id = a.album_id));


--
-- Name: v_web_mislength_files; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_mislength_files AS
    SELECT f.file_id, f.filename, abs((f.duration - t.duration)) AS duration_diff FROM (file f JOIN track t USING (track_id));


--
-- Name: v_web_track_list_matching_files; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_track_list_matching_files AS
    SELECT f.file_id, f.filename, f.last_updated, f.duration, f.channels, f.bitrate, f.samplerate, f.album, f.albumartist, f.albumartistsort, f.artist, f.artistsort, f.musicbrainz_albumartistid, f.musicbrainz_albumid, f.musicbrainz_artistid, f.musicbrainz_trackid, f.title, f.tracknumber, f.released, f.genre, f.pinned, f.groupname, f.track_id AS file_track_id, f.duplicate, f.user_changed, m.track_id, m.mbid_match, m.score FROM (file f JOIN comparison m ON ((f.file_id = m.file_id)));


--
-- Name: v_web_uncompared_list_files; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_uncompared_list_files AS
    SELECT file.file_id, file.filename, file.last_updated, file.duration, file.channels, file.bitrate, file.samplerate, file.album, file.albumartist, file.albumartistsort, file.artist, file.artistsort, file.musicbrainz_albumartistid, file.musicbrainz_albumid, file.musicbrainz_artistid, file.musicbrainz_trackid, file.title, file.tracknumber, file.released, file.genre, file.pinned, file.groupname, file.duplicate, file.user_changed, file.track_id, file.checked FROM file WHERE (NOT (file.file_id IN (SELECT comparison.file_id FROM comparison)));


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
-- Name: comparison_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comparison
    ADD CONSTRAINT comparison_pkey PRIMARY KEY (file_id, track_id);


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
-- Name: comparison_score_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX comparison_score_idx ON comparison USING btree (score);


--
-- Name: comparison_track_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX comparison_track_id_idx ON comparison USING btree (track_id);


--
-- Name: file_groupname_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX file_groupname_idx ON file USING btree (groupname);


--
-- Name: file_track_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX file_track_id_idx ON file USING btree (track_id);


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
-- Name: comparison_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comparison
    ADD CONSTRAINT comparison_file_id_fkey FOREIGN KEY (file_id) REFERENCES file(file_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comparison_track_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comparison
    ADD CONSTRAINT comparison_track_id_fkey FOREIGN KEY (track_id) REFERENCES track(track_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: file_user_track_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file
    ADD CONSTRAINT file_user_track_id_fkey FOREIGN KEY (track_id) REFERENCES track(track_id) ON UPDATE CASCADE ON DELETE SET NULL;


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

