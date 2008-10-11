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
-- Name: album; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE album (
    album_id integer NOT NULL,
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    type character varying NOT NULL,
    title character varying NOT NULL,
    released date,
    custom_artist_sortname character varying,
    last_updated timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT album_mbid_check CHECK ((length(mbid) = 36))
);


--
-- Name: artist; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE artist (
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL,
    name character varying NOT NULL,
    sortname character varying NOT NULL,
    CONSTRAINT artist_mbid_check CHECK ((length(mbid) = 36))
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
    musicbrainz_albumartistid character(36) NOT NULL,
    musicbrainz_albumid character(36) NOT NULL,
    musicbrainz_artistid character(36) NOT NULL,
    musicbrainz_trackid character(36) NOT NULL,
    title character varying NOT NULL,
    tracknumber character varying NOT NULL,
    released character varying NOT NULL,
    CONSTRAINT file_musicbrainz_albumartistid_check CHECK (((length(musicbrainz_albumartistid) = 0) OR (length(musicbrainz_albumartistid) = 36))),
    CONSTRAINT file_musicbrainz_albumid_check CHECK (((length(musicbrainz_albumid) = 0) OR (length(musicbrainz_albumid) = 36))),
    CONSTRAINT file_musicbrainz_artistid_check CHECK (((length(musicbrainz_artistid) = 0) OR (length(musicbrainz_artistid) = 36))),
    CONSTRAINT file_musicbrainz_trackid_check CHECK (((length(musicbrainz_trackid) = 0) OR (length(musicbrainz_trackid) = 36)))
);


--
-- Name: match; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE match (
    file_id integer NOT NULL,
    metatrack_id integer NOT NULL,
    mbid_match boolean NOT NULL,
    puid_match boolean NOT NULL,
    meta_score double precision NOT NULL,
    CONSTRAINT match_meta_score_check CHECK (((meta_score >= (0.0)::double precision) AND (meta_score <= (1.0)::double precision)))
);


--
-- Name: metatrack; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    last_updated timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT metatrack_album_mbid_check CHECK ((length(album_mbid) = 36)),
    CONSTRAINT metatrack_artist_mbid_check CHECK ((length(artist_mbid) = 36)),
    CONSTRAINT metatrack_track_mbid_check CHECK ((length(track_mbid) = 36))
);


--
-- Name: puid; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE puid (
    puid_id integer NOT NULL,
    puid character(36) NOT NULL,
    CONSTRAINT puid_puid_check CHECK ((length(puid) = 36))
);


--
-- Name: puid_metatrack; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE puid_metatrack (
    puid_id integer NOT NULL,
    metatrack_id integer NOT NULL,
    last_updated timestamp without time zone DEFAULT now() NOT NULL
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
    CONSTRAINT track_mbid_check CHECK ((length(mbid) = 36)),
    CONSTRAINT track_tracknumber_check CHECK ((tracknumber > 0))
);


--
-- Name: v_daemon_load_album; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_daemon_load_album AS
    SELECT al.album_id, al.mbid AS album_mbid, al.type AS album_type, al.title AS album_title, al.released AS album_released, al.custom_artist_sortname AS album_custom_artist_sortname, al.last_updated AS album_last_updated, ar.artist_id, ar.mbid AS artist_mbid, ar.name AS artist_name, ar.sortname AS artist_sortname FROM (album al JOIN artist ar ON ((al.artist_id = ar.artist_id)));


--
-- Name: v_daemon_load_metafile; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_daemon_load_metafile AS
    SELECT f.filename, f.file_id, f.duration, f.channels, f.bitrate, f.samplerate, p.puid, f.album, f.albumartist, f.albumartistsort, f.artist, f.artistsort, f.musicbrainz_albumartistid, f.musicbrainz_albumid, f.musicbrainz_artistid, f.musicbrainz_trackid, f.title, f.tracknumber, f.released AS year FROM (file f LEFT JOIN puid p ON ((f.puid_id = p.puid_id)));


--
-- Name: v_web_info_album; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_info_album AS
    SELECT al.album_id, al.artist_id, al.mbid, al.type, al.title, al.released, al.custom_artist_sortname, al.last_updated, ar.name AS artist_name FROM (album al JOIN artist ar ON ((al.artist_id = ar.artist_id)));


--
-- Name: v_web_info_artist; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_info_artist AS
    SELECT artist.artist_id, artist.mbid, artist.name, artist.sortname FROM artist;


--
-- Name: v_web_info_track; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_info_track AS
    SELECT tr.track_id, tr.album_id, tr.artist_id, tr.mbid, tr.title, tr.duration, tr.tracknumber, ar.name AS artist_name, al.title AS album_title FROM ((track tr LEFT JOIN artist ar ON ((tr.artist_id = ar.artist_id))) LEFT JOIN album al ON ((tr.album_id = al.album_id)));


--
-- Name: v_web_list_albums; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_list_albums AS
    SELECT al.album_id, al.artist_id, al.mbid, al.type, al.title, al.released, al.custom_artist_sortname, al.last_updated, COALESCE((SELECT count(*) AS count FROM track tr WHERE (tr.album_id = al.album_id)), (0)::bigint) AS tracks, ar.name AS artist_name FROM (album al LEFT JOIN artist ar ON ((al.artist_id = ar.artist_id)));


--
-- Name: v_web_list_artists; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW v_web_list_artists AS
    SELECT ar.artist_id, ar.mbid, ar.name, ar.sortname, COALESCE((SELECT count(*) AS count FROM album al WHERE (al.artist_id = ar.artist_id)), (0)::bigint) AS albums FROM artist ar;


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
-- Name: metatrack_metatrack_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE metatrack_metatrack_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: metatrack_metatrack_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE metatrack_metatrack_id_seq OWNED BY metatrack.metatrack_id;


--
-- Name: puid_puid_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE puid_puid_id_seq
    START WITH 1
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
-- Name: metatrack_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE metatrack ALTER COLUMN metatrack_id SET DEFAULT nextval('metatrack_metatrack_id_seq'::regclass);


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
    ADD CONSTRAINT match_pkey PRIMARY KEY (file_id, metatrack_id);


--
-- Name: metatrack_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metatrack
    ADD CONSTRAINT metatrack_pkey PRIMARY KEY (metatrack_id);


--
-- Name: metatrack_track_mbid_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY metatrack
    ADD CONSTRAINT metatrack_track_mbid_key UNIQUE (track_mbid);


--
-- Name: puid_metatrack_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY puid_metatrack
    ADD CONSTRAINT puid_metatrack_pkey PRIMARY KEY (puid_id, metatrack_id);


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
-- Name: match_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY match
    ADD CONSTRAINT match_file_id_fkey FOREIGN KEY (file_id) REFERENCES file(file_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: match_metatrack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY match
    ADD CONSTRAINT match_metatrack_id_fkey FOREIGN KEY (metatrack_id) REFERENCES metatrack(metatrack_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: puid_metatrack_metatrack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY puid_metatrack
    ADD CONSTRAINT puid_metatrack_metatrack_id_fkey FOREIGN KEY (metatrack_id) REFERENCES metatrack(metatrack_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: puid_metatrack_puid_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY puid_metatrack
    ADD CONSTRAINT puid_metatrack_puid_id_fkey FOREIGN KEY (puid_id) REFERENCES puid(puid_id) ON UPDATE CASCADE ON DELETE CASCADE;


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
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: album; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE album FROM PUBLIC;
REVOKE ALL ON TABLE album FROM canidae;
GRANT ALL ON TABLE album TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE album TO locutus;


--
-- Name: artist; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE artist FROM PUBLIC;
REVOKE ALL ON TABLE artist FROM canidae;
GRANT ALL ON TABLE artist TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE artist TO locutus;


--
-- Name: file; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE file FROM PUBLIC;
REVOKE ALL ON TABLE file FROM canidae;
GRANT ALL ON TABLE file TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE file TO locutus;


--
-- Name: match; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE match FROM PUBLIC;
REVOKE ALL ON TABLE match FROM canidae;
GRANT ALL ON TABLE match TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE match TO locutus;


--
-- Name: metatrack; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE metatrack FROM PUBLIC;
REVOKE ALL ON TABLE metatrack FROM canidae;
GRANT ALL ON TABLE metatrack TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE metatrack TO locutus;


--
-- Name: puid; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE puid FROM PUBLIC;
REVOKE ALL ON TABLE puid FROM canidae;
GRANT ALL ON TABLE puid TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE puid TO locutus;


--
-- Name: puid_metatrack; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE puid_metatrack FROM PUBLIC;
REVOKE ALL ON TABLE puid_metatrack FROM canidae;
GRANT ALL ON TABLE puid_metatrack TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE puid_metatrack TO locutus;


--
-- Name: setting; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE setting FROM PUBLIC;
REVOKE ALL ON TABLE setting FROM canidae;
GRANT ALL ON TABLE setting TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE setting TO locutus;


--
-- Name: track; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE track FROM PUBLIC;
REVOKE ALL ON TABLE track FROM canidae;
GRANT ALL ON TABLE track TO canidae;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE track TO locutus;


--
-- Name: v_daemon_load_album; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE v_daemon_load_album FROM PUBLIC;
REVOKE ALL ON TABLE v_daemon_load_album FROM canidae;
GRANT ALL ON TABLE v_daemon_load_album TO canidae;
GRANT SELECT ON TABLE v_daemon_load_album TO locutus;


--
-- Name: v_daemon_load_metafile; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE v_daemon_load_metafile FROM PUBLIC;
REVOKE ALL ON TABLE v_daemon_load_metafile FROM canidae;
GRANT ALL ON TABLE v_daemon_load_metafile TO canidae;
GRANT SELECT ON TABLE v_daemon_load_metafile TO locutus;


--
-- Name: v_web_info_album; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE v_web_info_album FROM PUBLIC;
REVOKE ALL ON TABLE v_web_info_album FROM canidae;
GRANT ALL ON TABLE v_web_info_album TO canidae;
GRANT SELECT ON TABLE v_web_info_album TO locutus;


--
-- Name: v_web_info_artist; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE v_web_info_artist FROM PUBLIC;
REVOKE ALL ON TABLE v_web_info_artist FROM canidae;
GRANT ALL ON TABLE v_web_info_artist TO canidae;
GRANT SELECT ON TABLE v_web_info_artist TO locutus;


--
-- Name: v_web_info_track; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE v_web_info_track FROM PUBLIC;
REVOKE ALL ON TABLE v_web_info_track FROM canidae;
GRANT ALL ON TABLE v_web_info_track TO canidae;
GRANT SELECT ON TABLE v_web_info_track TO locutus;


--
-- Name: v_web_list_albums; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE v_web_list_albums FROM PUBLIC;
REVOKE ALL ON TABLE v_web_list_albums FROM canidae;
GRANT ALL ON TABLE v_web_list_albums TO canidae;
GRANT SELECT ON TABLE v_web_list_albums TO locutus;


--
-- Name: v_web_list_artists; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE v_web_list_artists FROM PUBLIC;
REVOKE ALL ON TABLE v_web_list_artists FROM canidae;
GRANT ALL ON TABLE v_web_list_artists TO canidae;
GRANT SELECT ON TABLE v_web_list_artists TO locutus;


--
-- Name: v_web_list_files; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE v_web_list_files FROM PUBLIC;
REVOKE ALL ON TABLE v_web_list_files FROM canidae;
GRANT ALL ON TABLE v_web_list_files TO canidae;
GRANT SELECT ON TABLE v_web_list_files TO locutus;


--
-- Name: v_web_list_tracks; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE v_web_list_tracks FROM PUBLIC;
REVOKE ALL ON TABLE v_web_list_tracks FROM canidae;
GRANT ALL ON TABLE v_web_list_tracks TO canidae;
GRANT SELECT ON TABLE v_web_list_tracks TO locutus;


--
-- Name: album_album_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE album_album_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE album_album_id_seq FROM canidae;
GRANT ALL ON SEQUENCE album_album_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE album_album_id_seq TO locutus;


--
-- Name: artist_artist_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE artist_artist_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE artist_artist_id_seq FROM canidae;
GRANT ALL ON SEQUENCE artist_artist_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE artist_artist_id_seq TO locutus;


--
-- Name: file_file_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE file_file_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE file_file_id_seq FROM canidae;
GRANT ALL ON SEQUENCE file_file_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE file_file_id_seq TO locutus;


--
-- Name: metatrack_metatrack_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE metatrack_metatrack_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE metatrack_metatrack_id_seq FROM canidae;
GRANT ALL ON SEQUENCE metatrack_metatrack_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE metatrack_metatrack_id_seq TO locutus;


--
-- Name: puid_puid_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE puid_puid_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE puid_puid_id_seq FROM canidae;
GRANT ALL ON SEQUENCE puid_puid_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE puid_puid_id_seq TO locutus;


--
-- Name: setting_setting_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE setting_setting_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE setting_setting_id_seq FROM canidae;
GRANT ALL ON SEQUENCE setting_setting_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE setting_setting_id_seq TO locutus;


--
-- Name: track_track_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE track_track_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE track_track_id_seq FROM canidae;
GRANT ALL ON SEQUENCE track_track_id_seq TO canidae;
GRANT SELECT,UPDATE ON SEQUENCE track_track_id_seq TO locutus;


--
-- PostgreSQL database dump complete
--

