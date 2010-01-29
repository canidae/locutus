BEGIN TRANSACTION;
CREATE TABLE album (
    album_id integer PRIMARY KEY,
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL UNIQUE,
    type character varying NOT NULL,
    title character varying NOT NULL,
    released date,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE artist (
    artist_id integer PRIMARY KEY,
    mbid character(36) NOT NULL UNIQUE,
    name character varying NOT NULL,
    sortname character varying NOT NULL
);
CREATE TABLE comparison (
    file_id integer NOT NULL,
    track_id integer NOT NULL,
    mbid_match boolean NOT NULL,
    score double precision NOT NULL,
    PRIMARY KEY (file_id, track_id)
);
CREATE TABLE file (
    file_id integer PRIMARY KEY,
    filename character varying NOT NULL UNIQUE,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
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
    groupname character varying DEFAULT "" NOT NULL,
    duplicate boolean DEFAULT false NOT NULL,
    user_changed boolean DEFAULT false NOT NULL,
    track_id integer,
    checked boolean DEFAULT true NOT NULL
);
CREATE TABLE locutus (
    active boolean DEFAULT false NOT NULL,
    start timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stop timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    progress real DEFAULT 0.0 NOT NULL
);
CREATE TABLE setting (
    setting_id integer PRIMARY KEY,
    key character varying NOT NULL,
    default_value character varying NOT NULL,
    value character varying NOT NULL,
    description character varying NOT NULL
);
CREATE TABLE track (
    track_id integer PRIMARY KEY,
    album_id integer NOT NULL,
    artist_id integer NOT NULL,
    mbid character(36) NOT NULL UNIQUE,
    title character varying NOT NULL,
    tracknumber integer NOT NULL,
    duration integer DEFAULT 0 NOT NULL,
    UNIQUE (album_id, tracknumber)
);
CREATE VIEW v_daemon_load_album AS
    SELECT album.album_id AS album_album_id, album.mbid AS album_mbid, album.type AS album_type, album.title AS album_title, album.released AS album_released, album.last_updated AS album_last_updated, albumartist.artist_id AS albumartist_artist_id, albumartist.mbid AS albumartist_mbid, albumartist.name AS albumartist_name, albumartist.sortname AS albumartist_sortname, track.track_id AS track_track_id, track.mbid AS track_mbid, track.title AS track_title, track.tracknumber AS track_tracknumber, track.duration AS track_duration, trackartist.artist_id AS trackartist_artist_id, trackartist.mbid AS trackartist_mbid, trackartist.name AS trackartist_name, trackartist.sortname AS trackartist_sortname FROM (((album JOIN artist albumartist USING (artist_id)) JOIN track USING (album_id)) JOIN artist trackartist ON ((track.artist_id = trackartist.artist_id)));
CREATE VIEW v_daemon_load_metafile AS
    SELECT f.filename, f.duration, f.channels, f.bitrate, f.samplerate, COALESCE(al.title, f.album) AS album, COALESCE(aa.name, f.albumartist) AS albumartist, COALESCE(aa.sortname, f.albumartistsort) AS albumartistsort, COALESCE(ar.name, f.artist) AS artist, COALESCE(ar.sortname, f.artistsort) AS artistsort, COALESCE(aa.mbid, f.musicbrainz_albumartistid) AS musicbrainz_albumartistid, COALESCE(al.mbid, f.musicbrainz_albumid) AS musicbrainz_albumid, COALESCE(ar.mbid, f.musicbrainz_artistid) AS musicbrainz_artistid, COALESCE(t.mbid, f.musicbrainz_trackid) AS musicbrainz_trackid, COALESCE(t.title, f.title) AS title, COALESCE(t.tracknumber, f.tracknumber) AS tracknumber, COALESCE(al.released, f.released) AS released, f.genre, f.pinned, f.groupname, (f.track_id IS NOT NULL) AS matched FROM ((((file f LEFT JOIN track t ON ((t.track_id = f.track_id))) LEFT JOIN artist ar ON ((ar.artist_id = t.artist_id))) LEFT JOIN album al ON ((al.album_id = t.album_id))) LEFT JOIN artist aa ON ((aa.artist_id = al.artist_id)));
CREATE VIEW v_ui_matching_details AS
    SELECT album.album_id AS album_album_id, album.mbid AS album_mbid, album.type AS album_type, album.title AS album_title, album.released AS album_released, album.last_updated AS album_last_updated, albumartist.artist_id AS albumartist_artist_id, albumartist.mbid AS albumartist_mbid, albumartist.name AS albumartist_name, albumartist.sortname AS albumartist_sortname, track.track_id AS track_track_id, track.mbid AS track_mbid, track.title AS track_title, track.tracknumber AS track_tracknumber, track.duration AS track_duration, trackartist.artist_id AS trackartist_artist_id, trackartist.mbid AS trackartist_mbid, trackartist.name AS trackartist_name, trackartist.sortname AS trackartist_sortname, cft.comparison_mbid_match, cft.comparison_score, cft.file_file_id, cft.file_filename, cft.file_last_updated, cft.file_duration, cft.file_channels, cft.file_bitrate, cft.file_samplerate, cft.file_album, cft.file_albumartist, cft.file_albumartistsort, cft.file_artist, cft.file_artistsort, cft.file_musicbrainz_albumartistid, cft.file_musicbrainz_albumid, cft.file_musicbrainz_artistid, cft.file_musicbrainz_trackid, cft.file_title, cft.file_tracknumber, cft.file_released, cft.file_genre, cft.file_pinned, cft.file_groupname, cft.file_duplicate, cft.file_user_changed, cft.file_track_id, cft.file_checked FROM ((((album JOIN artist albumartist USING (artist_id)) JOIN track USING (album_id)) JOIN artist trackartist ON ((track.artist_id = trackartist.artist_id))) LEFT JOIN (SELECT DISTINCT comparison.mbid_match AS comparison_mbid_match, comparison.score AS comparison_score, file.file_id AS file_file_id, file.filename AS file_filename, file.last_updated AS file_last_updated, file.duration AS file_duration, file.channels AS file_channels, file.bitrate AS file_bitrate, file.samplerate AS file_samplerate, file.album AS file_album, file.albumartist AS file_albumartist, file.albumartistsort AS file_albumartistsort, file.artist AS file_artist, file.artistsort AS file_artistsort, file.musicbrainz_albumartistid AS file_musicbrainz_albumartistid, file.musicbrainz_albumid AS file_musicbrainz_albumid, file.musicbrainz_artistid AS file_musicbrainz_artistid, file.musicbrainz_trackid AS file_musicbrainz_trackid, file.title AS file_title, file.tracknumber AS file_tracknumber, file.released AS file_released, file.genre AS file_genre, file.pinned AS file_pinned, file.groupname AS file_groupname, file.duplicate AS file_duplicate, file.user_changed AS file_user_changed, file.track_id AS file_track_id, file.checked AS file_checked, comparisontrack.album_id AS comparisontrack_album_id, comparisontrack.track_id AS comparisontrack_track_id FROM ((comparison JOIN file USING (file_id)) JOIN track comparisontrack ON ((comparison.track_id = comparisontrack.track_id))) ORDER BY comparisontrack.album_id, file.file_id, comparison.mbid_match DESC, comparison.score DESC) cft ON (((track.album_id = cft.comparisontrack_album_id) AND (track.track_id = cft.comparisontrack_track_id))));
CREATE VIEW v_ui_matching_list AS
    SELECT album.album_id, album.title AS album, (SELECT count(*) AS count FROM track WHERE (track.album_id = album.album_id)) AS tracks, count(ctf.file_id) AS files_compared, count(ctf.track_id) AS tracks_compared, sum(ctf.mbid_match) AS mbids_matched, max(ctf.score) AS max_score, avg(ctf.score) AS avg_score, min(ctf.score) AS min_score FROM ((SELECT DISTINCT track.album_id, comparison.file_id, comparison.track_id, comparison.mbid_match, comparison.score FROM ((comparison JOIN track USING (track_id)) JOIN file USING (file_id)) WHERE (file.track_id IS NULL) ORDER BY track.album_id, comparison.file_id, comparison.mbid_match DESC, comparison.score DESC) ctf JOIN album USING (album_id)) GROUP BY album.album_id, album.title, (SELECT count(*) AS count FROM track WHERE (track.album_id = album.album_id));
CREATE VIEW v_ui_uncompared_list AS
    SELECT file.file_id, file.filename, file.last_updated, file.duration, file.channels, file.bitrate, file.samplerate, file.album, file.albumartist, file.albumartistsort, file.artist, file.artistsort, file.musicbrainz_albumartistid, file.musicbrainz_albumid, file.musicbrainz_artistid, file.musicbrainz_trackid, file.title, file.tracknumber, file.released, file.genre, file.pinned, file.groupname, file.duplicate, file.user_changed, file.track_id, file.checked FROM file WHERE ((file.track_id IS NULL) AND (NOT (file.file_id IN (SELECT comparison.file_id FROM comparison))));
CREATE INDEX album_artist_id_idx ON album (artist_id);
CREATE INDEX comparison_score_idx ON comparison (score);
CREATE INDEX comparison_track_id_idx ON comparison (track_id);
CREATE INDEX file_groupname_idx ON file (groupname);
CREATE INDEX file_track_id_idx ON file (track_id);
CREATE INDEX track_artist_id_idx ON track (artist_id);
COMMIT;
