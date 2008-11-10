#include "Album.h"
#include "Artist.h"
#include "Debug.h"
#include "Match.h"
#include "Metatrack.h"
#include "PostgreSQL.h"
#include "Track.h"

using namespace std;

/* constructors/destructor */
PostgreSQL::PostgreSQL(const string connection) : Database(), pg_result(NULL), got_result(false) {
	pg_connection = PQconnectdb(connection.c_str());
	if (PQstatus(pg_connection) != CONNECTION_OK) {
		Debug::error() << "Unable to connect to the database" << endl;
		exit(1);
	}
	album_cache_lifetime = loadSettingInt(ALBUM_CACHE_LIFETIME_KEY, ALBUM_CACHE_LIFETIME_VALUE, ALBUM_CACHE_LIFETIME_DESCRIPTION);
	metatrack_cache_lifetime = loadSettingInt(METATRACK_CACHE_LIFETIME_KEY, METATRACK_CACHE_LIFETIME_VALUE, METATRACK_CACHE_LIFETIME_DESCRIPTION);
	puid_cache_lifetime = loadSettingInt(PUID_CACHE_LIFETIME_KEY, PUID_CACHE_LIFETIME_VALUE, PUID_CACHE_LIFETIME_DESCRIPTION);
}

PostgreSQL::~PostgreSQL() {
	clear();
	PQfinish(pg_connection);
}

/* methods */
bool PostgreSQL::loadAlbum(Album *album) {
	/* fetch album from cache */
	if (album == NULL)
		return false;
	if (album->mbid.size() != 36 || album->mbid[8] != '-' || album->mbid[13] != '-' || album->mbid[18] != '-' || album->mbid[23] != '-') {
		Debug::notice() << "Unable to load album from cache. Illegal MusicBrainz ID: " << album->mbid << endl;
		return false;
	}
	ostringstream query;
	query << "SELECT * FROM v_daemon_load_album WHERE album_mbid = '" << escapeString(album->mbid) << "' AND album_last_updated + INTERVAL '" << album_cache_lifetime << " months' > now()";
	if (!doQuery(query.str()) || getRows() <= 0) {
		/* album not in cache */
		Debug::notice() << "Unable to load album from cache. MusicBrainz ID not found or cache is too old: " << album->mbid << endl;
		return false;
	}
	/* album data */
	album->mbid = getString(0, 1);
	album->type = getString(0, 2);
	album->title = getString(0, 3);
	album->released = getString(0, 4);
	/* artist data */
	album->artist->mbid = getString(0, 7);
	album->artist->name = getString(0,8);
	album->artist->sortname = getString(0, 9);
	/* track data */
	int trackcount = getRows();
	album->tracks.resize(trackcount);
	for (int t = 0; t < trackcount; ++t) {
		int trackindex = getInt(t, 14) - 1;
		if (trackindex < 0 || trackindex >= (int) album->tracks.capacity()) {
			/* this really shouldn't happen.
			 * seemingly we're missing entries in the track table */
			Debug::warning() << "Tracknumber either exceed album track count or is less than 1. Did you mess with the track table? MusicBrainz Album ID: " << album->mbid << endl;
			return false;
		}
		album->tracks[trackindex] = new Track(album);
		/* track data */
		album->tracks[trackindex]->mbid = getString(t, 11);
		album->tracks[trackindex]->title = getString(t, 12);
		album->tracks[trackindex]->duration = getInt(t, 13);
		album->tracks[trackindex]->tracknumber = trackindex + 1;
		/* track artist data */
		album->tracks[trackindex]->artist->mbid = getString(t, 16);
		album->tracks[trackindex]->artist->name = getString(t, 17);
		album->tracks[trackindex]->artist->sortname = getString(t, 18);
	}
	return true;
}

bool PostgreSQL::loadMetafile(Metafile *metafile) {
	if (metafile == NULL)
		return false;
	if (metafile->filename.size() <= 0) {
		Debug::notice() << "Length of filename is 0 or less? Can't load that from cache" << endl;
		return false;
	}
	string e_filename = escapeString(metafile->filename);
	ostringstream query;
	query << "SELECT * FROM v_daemon_load_metafile WHERE filename = '" << e_filename << "'";
	if (!doQuery(query.str()) || getRows() <= 0) {
		Debug::notice() << "Didn't find file in database: " << metafile->filename << endl;
		return false;
	}
	metafile->duration = getInt(0, 1);
	metafile->channels = getInt(0, 2);
	metafile->bitrate = getInt(0, 3);
	metafile->samplerate = getInt(0, 4);
	metafile->puid = getString(0, 5);
	metafile->album = getString(0, 6);
	metafile->albumartist = getString(0, 7);
	metafile->albumartistsort = getString(0, 8);
	metafile->artist = getString(0, 9);
	metafile->artistsort = getString(0, 10);
	metafile->musicbrainz_albumartistid = getString(0, 11);
	metafile->musicbrainz_albumid = getString(0, 12);
	metafile->musicbrainz_artistid = getString(0, 13);
	metafile->musicbrainz_trackid = getString(0, 14);
	metafile->title = getString(0, 15);
	metafile->tracknumber = getString(0, 16);
	metafile->released = getString(0, 17);
	metafile->genre = getString(0, 18);
	metafile->pinned = getBool(0, 19);
	metafile->force_save = getBool(0, 20);
	metafile->matched = getBool(0, 21);
	return true;
}

vector<Metafile> PostgreSQL::loadMetafiles(const string &filename_pattern) {
	string e_filename_pattern = escapeString(filename_pattern);
	vector<Metafile> files;
	files.clear();
	ostringstream query;
	query << "SELECT * FROM v_daemon_load_metafile WHERE filename LIKE '" << e_filename_pattern << "%'";
	if (!doQuery(query.str()) || getRows() <= 0)
		return files;
	for (int r = 0; r < getRows(); ++r) {
		Metafile metafile(getString(r, 0));
		metafile.duration = getInt(r, 1);
		metafile.channels = getInt(r, 2);
		metafile.bitrate = getInt(r, 3);
		metafile.samplerate = getInt(r, 4);
		metafile.puid = getString(r, 5);
		metafile.album = getString(r, 6);
		metafile.albumartist = getString(r, 7);
		metafile.albumartistsort = getString(r, 8);
		metafile.artist = getString(r, 9);
		metafile.artistsort = getString(r, 10);
		metafile.musicbrainz_albumartistid = getString(r, 11);
		metafile.musicbrainz_albumid = getString(r, 12);
		metafile.musicbrainz_artistid = getString(r, 13);
		metafile.musicbrainz_trackid = getString(r, 14);
		metafile.title = getString(r, 15);
		metafile.tracknumber = getString(r, 16);
		metafile.released = getString(r, 17);
		metafile.genre = getString(r, 18);
		metafile.pinned = getBool(r, 19);
		metafile.force_save = getBool(r, 20);
		metafile.matched = getBool(r, 21);
		files.push_back(metafile);
	}
	return files;
}

bool PostgreSQL::loadSettingBool(const string &key, bool default_value, const string &description) {
	string def_val = (default_value ? "true" : "false");
	return (loadSettingString(key, def_val, description) == "true");
}

double PostgreSQL::loadSettingDouble(const string &key, double default_value, const string &description) {
	ostringstream def_val;
	def_val << default_value;
	return atof(loadSettingString(key, def_val.str(), description).c_str());
}

int PostgreSQL::loadSettingInt(const string &key, int default_value, const string &description) {
	ostringstream def_val;
	def_val << default_value;
	return atoi(loadSettingString(key, def_val.str(), description).c_str());
}

string PostgreSQL::loadSettingString(const string &key, const string &default_value, const string &description) {
	string e_key = escapeString(key);
	string back = default_value;
	ostringstream query;
	query << "SELECT value, (default_value = value) FROM setting WHERE key = '" << e_key << "'";
	if (!doQuery(query.str()))
		return back;
	string e_value = escapeString(default_value);
	string e_description = escapeString(description);
	if (getRows() > 0) {
		back = getString(0, 0);
		if (getBool(0, 1) && back != default_value) {
			/* user has not changed value and default value has changed.
			 * update database */
			back = default_value;
			query.str("");
			query << "UPDATE setting SET";
			query << " default_value = '" << e_value << "'";
			query << ", value = '" << e_value << "'";
			query << ", description = '" << e_description << "'";
			query << " WHERE key = '" << e_key << "'";
			if (!doQuery(query.str()))
				return back;
		}
	} else {
		/* this key is missing, add it */
		query.str("");
		query << "INSERT INTO setting(key, default_value, value, description) VALUES";
		query << " ('" << e_key << "'";
		query << ", '" << e_value << "'";
		query << ", '" << e_value << "'";
		query << ", '" << e_description << "')";  
		if (!doQuery(query.str()))
			return back;                                                                                                                   
	}                                                                                                                                              
	return back;
}

bool PostgreSQL::removeMetafiles(const vector<Metafile> &files) {
	ostringstream query;
	query.str("");
	for (vector<Metafile>::const_iterator f = files.begin(); f != files.end(); ++f) {
		if (query.str() == "")
			query << "DELETE FROM file WHERE filename IN ('" << escapeString(f->filename) << "'";
		else
			query << ", '" << escapeString(f->filename) << "'";
	}
	if (query.str() == "")
		return true;
	query << ")";
	return doQuery(query.str());
}

bool PostgreSQL::saveAlbum(const Album &album) {
	if (album.mbid.size() != 36) {
		Debug::notice() << "Unable to save album in cache. Illegal MusicBrainz ID: " << album.mbid << endl;
		return false;
	}
	string e_artist_mbid = escapeString(album.artist->mbid);
	string e_mbid = escapeString(album.mbid);
	string e_title = escapeString(album.title);
	string e_type = escapeString(album.type);
	string e_released = escapeString(album.released);
	if (e_released == "" || album.released.size() != 10) {
		e_released = "NULL";
	} else {
		string tmp_e_released = e_released;
		e_released = "'";
		e_released.append(tmp_e_released);
		e_released.append("'");
	}
	ostringstream query;
	/* save artist */
	if (!saveArtist(*album.artist))
		Debug::notice() << "Failed to save album artist in cache. See errors above" << endl;
	/* save album */
	query.str("");
	query << "INSERT INTO album(artist_id, mbid, type, title, released) SELECT";
	query << " (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "')";
	query << ", '" << e_mbid << "'";
	query << ", '" << e_type << "'";
	query << ", '" << e_title << "'";
	query << ", " << e_released;
	query << " WHERE NOT EXISTS";
	query << " (SELECT true FROM album WHERE mbid = '" << e_mbid << "')";
	if (!doQuery(query.str())) {
		Debug::notice() << "Unable to save album in cache, query failed. See error above" << endl;
		return false;
	}
	query.str("");
	query << "UPDATE album SET";
	query << " artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "')";
	query << ", type = '" << e_type << "'";
	query << ", title = '" << e_title << "'";
	query << ", released = " << e_released;
	query << ", last_updated = now()";
	query << " WHERE mbid = '" << e_mbid << "'";
	if (!doQuery(query.str())) {
		Debug::notice() << "Unable to save album in cache, query failed. See error above" << endl;
		return false;
	}
	/* save tracks */
	bool status = true;
	for (vector<Track *>::const_iterator track = album.tracks.begin(); track != album.tracks.end(); ++track) {
		if (!saveTrack(**track))
			status = false;
	}
	if (!status)
		Debug::notice() << "One or more album tracks couldn't be saved in cache. See errors above" << endl;
	return status;
}

bool PostgreSQL::saveArtist(const Artist &artist) {
	if (artist.mbid.size() != 36)
		return false;
	string e_mbid = escapeString(artist.mbid);
	string e_name = escapeString(artist.name);
	string e_sortname = escapeString(artist.sortname);
	ostringstream query;
	query << "INSERT INTO artist(mbid, name, sortname) SELECT";
	query << " '" << e_mbid << "'";
	query << ", '" << e_name << "'";
	query << ", '" << e_sortname << "'";
	query << " WHERE NOT EXISTS";
	query << " (SELECT true FROM artist WHERE mbid = '" << e_mbid << "')";
	if (!doQuery(query.str()))
		Debug::notice() << "Unable to save artist in cache, query failed. See error above" << endl;
	query.str("");
	query << "UPDATE artist SET";
	query << " name = '" << e_name << "'";
	query << ", sortname = '" << e_sortname << "'";
	query << " WHERE mbid = '" << e_mbid << "'";
	if (!doQuery(query.str()))
		Debug::notice() << "Unable to save artist in cache, query failed. See error above" << endl;
	return true;
}

bool PostgreSQL::saveMatch(const Match &match) {
	if (match.track == NULL)
		return false;
	string e_filename = escapeString(match.metafile->filename);
	string e_track_mbid = escapeString(match.track->mbid);
	ostringstream query;
	query << "INSERT INTO match(file_id, track_id, mbid_match, puid_match, meta_score) SELECT";
	query << " (SELECT file_id FROM file WHERE filename = '" << e_filename << "')";
	query << ", (SELECT track_id FROM track WHERE mbid = '" << e_track_mbid << "')";
	query << ", " << (match.mbid_match ? "true" : "false");
	query << ", " << (match.puid_match ? "true" : "false");
	query << ", " << match.meta_score;
	query << " WHERE NOT EXISTS";
	query << " (SELECT true FROM match WHERE file_id = (SELECT file_id FROM file WHERE filename = '" << e_filename << "') AND track_id = (SELECT track_id FROM track WHERE mbid = '" << e_track_mbid << "'))";
	if (!doQuery(query.str()))
		Debug::notice() << "Unable to save metadata match in cache, query failed. See error above" << endl;
	query.str("");
	query << "UPDATE match SET";
	query << " mbid_match = " << (match.mbid_match ? "true" : "false");
	query << ", puid_match = "  << (match.puid_match ? "true" : "false");
	query << ", meta_score = " << match.meta_score;
	query << " WHERE file_id = (SELECT file_id FROM file WHERE filename = '" << e_filename << "') AND track_id = (SELECT track_id FROM track WHERE mbid = '" << e_track_mbid << "')";
	if (!doQuery(query.str()))
		Debug::notice() << "Unable to save metadata match in cache, query failed. See error above" << endl;
	return true;
}

bool PostgreSQL::saveMetafile(const Metafile &metafile, const string &old_filename) {
	ostringstream query;
	string e_puid = escapeString(metafile.puid);
	if (e_puid != "") {
		query << "INSERT INTO puid(puid) SELECT";
		query << " '" << e_puid << "'";
		query << " WHERE NOT EXISTS";
		query << " (SELECT true FROM puid WHERE puid = '" << e_puid << "')";
		if (!doQuery(query.str()))
			Debug::notice() << "Unable to store PUID in database. See error above" << endl;
	}
	string e_filename = escapeString(metafile.filename);
	string e_album = escapeString(metafile.album);
	string e_albumartist = escapeString(metafile.albumartist);
	string e_albumartistsort = escapeString(metafile.albumartistsort);
	string e_artist = escapeString(metafile.artist);
	string e_artistsort = escapeString(metafile.artistsort);
	string e_musicbrainz_albumartistid = escapeString(metafile.musicbrainz_albumartistid);
	string e_musicbrainz_albumid = escapeString(metafile.musicbrainz_albumid);
	string e_musicbrainz_artistid = escapeString(metafile.musicbrainz_artistid);
	string e_musicbrainz_trackid = escapeString(metafile.musicbrainz_trackid);
	string e_title = escapeString(metafile.title);
	string e_tracknumber = escapeString(metafile.tracknumber);
	string e_released = escapeString(metafile.released);
	string e_genre = escapeString(metafile.genre);
	string e_group = escapeString(metafile.getGroup());
	if (e_puid == "") {
		e_puid = "NULL";
	} else {
		string tmp = e_puid;
		e_puid = "(SELECT puid_id FROM puid WHERE puid = '";
		e_puid.append(tmp);
		e_puid.append("')");
	}
	string e_matched;
	if (metafile.matched) {
		e_matched = "(SELECT track_id FROM track WHERE mbid = '";
		e_matched.append(e_musicbrainz_trackid);
		e_matched.append("')");
	} else {
		e_matched = "NULL";
	}
	if (old_filename == "") {
		query.str("");
		query << "INSERT INTO file(filename, duration, channels, bitrate, samplerate, puid_id, album, albumartist, albumartistsort, artist, artistsort, musicbrainz_albumartistid, musicbrainz_albumid, musicbrainz_artistid, musicbrainz_trackid, title, tracknumber, released, genre, pinned, groupname, duplicate, force_save, user_changed, matched) SELECT";
		query << " '" << e_filename << "'";
		query << ", " << metafile.duration;
		query << ", " << metafile.channels;
		query << ", " << metafile.bitrate;
		query << ", " << metafile.samplerate;
		query << ", " << e_puid;
		query << ", '" << e_album << "'";
		query << ", '" << e_albumartist << "'";
		query << ", '" << e_albumartistsort << "'";
		query << ", '" << e_artist << "'";
		query << ", '" << e_artistsort << "'";
		query << ", '" << e_musicbrainz_albumartistid << "'";
		query << ", '" << e_musicbrainz_albumid << "'";
		query << ", '" << e_musicbrainz_artistid << "'";
		query << ", '" << e_musicbrainz_trackid << "'";
		query << ", '" << e_title << "'";
		query << ", '" << e_tracknumber << "'";
		query << ", '" << e_released << "'";
		query << ", '" << e_genre << "'";
		query << ", " << (metafile.pinned ? "true" : "false");
		query << ", '" << e_group << "'";
		query << ", " << (metafile.duplicate ? "true" : "false");
		query << ", " << (metafile.force_save ? "true" : "false");
		query << ", false";
		query << ", " << e_matched;
		query << " WHERE NOT EXISTS";
		query << " (SELECT true FROM file WHERE filename = '" << e_filename << "')";
		if (!doQuery(query.str())) {
			Debug::notice() << "Unable to store file in database. See error above" << endl;
			return false;
		}
	} else {
		string e_old_filename = escapeString(old_filename);
		query.str("");
		query << "UPDATE file SET";
		query << " filename = '" << e_filename << "'";
		query << ", duration = " << metafile.duration;
		query << ", channels = " << metafile.channels;
		query << ", bitrate = " << metafile.bitrate;
		query << ", samplerate = " << metafile.samplerate;
		query << ", puid_id = " << e_puid;
		query << ", album = '" << e_album << "'";
		query << ", albumartist = '" << e_albumartist << "'";
		query << ", albumartistsort = '" << e_albumartistsort << "'";
		query << ", artist = '" << e_artist << "'";
		query << ", artistsort = '" << e_artistsort << "'";
		query << ", musicbrainz_albumartistid = '" << e_musicbrainz_albumartistid << "'";
		query << ", musicbrainz_albumid = '" << e_musicbrainz_albumid << "'";
		query << ", musicbrainz_artistid = '" << e_musicbrainz_artistid << "'";
		query << ", musicbrainz_trackid = '" << e_musicbrainz_trackid << "'";
		query << ", title = '" << e_title << "'";
		query << ", tracknumber = '" << e_tracknumber << "'";
		query << ", released = '" << e_released << "'";
		query << ", genre = '" << e_genre << "'";
		query << ", pinned = " << (metafile.pinned ? "true" : "false");
		query << ", groupname = '" << e_group << "'";
		query << ", duplicate = " << (metafile.duplicate ? "true" : "false");
		query << ", force_save = " << (metafile.force_save ? "true" : "false");
		query << ", user_changed = false";
		query << ", matched = " << e_matched;
		query << " WHERE filename = '" << e_old_filename << "'";
		if (!doQuery(query.str())) {
			Debug::notice() << "Unable to store file in database. See error above" << endl;
			return false;
		}
	}
	return true;
}

bool PostgreSQL::saveTrack(const Track &track) {
	if (track.mbid.size() != 36) {
		Debug::notice() << "Unable to save track in cache. Illegal MusicBrainz ID: " << track.mbid << endl;
		return false;
	}
	saveArtist(*track.artist);
	string e_album_mbid = escapeString(track.album->mbid);
	string e_artist_mbid = escapeString(track.artist->mbid);
	string e_mbid = escapeString(track.mbid);
	string e_title = escapeString(track.title);
	ostringstream query;
	query << "INSERT INTO track(album_id, artist_id, mbid, title, duration, tracknumber) SELECT";
	query << " (SELECT album_id FROM album WHERE mbid = '" << e_album_mbid << "')";
	query << ", (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "')";
	query << ", '" << e_mbid << "'";
	query << ", '" << e_title << "'";
	query << ", " << track.duration;
	query << ", " << track.tracknumber;
	query << " WHERE NOT EXISTS";
	query << " (SELECT true FROM track WHERE mbid = '" << e_mbid << "')";
	if (!doQuery(query.str()))
		Debug::notice() << "Unable to save track in cache, query failed. See error above" << endl;
	query.str("");
	query << "UPDATE track SET";
	query << " album_id = (SELECT album_id FROM album WHERE mbid = '" << e_album_mbid << "')";
	query << ", artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "')";
	query << ", title = '" << e_title << "'";
	query << ", duration = " << track.duration;
	query << ", tracknumber = " << track.tracknumber;
	query << " WHERE mbid = '" << e_mbid << "'";
	if (!doQuery(query.str()))
		Debug::notice() << "Unable to save track in cache, query failed. See error above" << endl;
	return true;
}

/* private methods */
void PostgreSQL::clear() {
	if (got_result)
		PQclear(pg_result);
	got_result = false;
}

bool PostgreSQL::doQuery(const char *q) {
	clear();
	got_result = true;
	Debug::info() << "Query: " << q << endl;
	pg_result = PQexec(pg_connection, q);
	int status = PQresultStatus(pg_result);
	if (status == PGRES_COMMAND_OK || status == PGRES_TUPLES_OK)
		return true;
	Debug::warning() << "Query failed: " << q << endl;
	Debug::warning() << "Query error: " << PQresultErrorMessage(pg_result) << endl;
	return false;
}

string PostgreSQL::escapeString(const string &str) const {
	char *to = new char[str.size() * 2 + 1];
	int error = 0;
	size_t len = PQescapeStringConn(pg_connection, to, str.c_str(), str.size(), &error);
	string back(to, len);
	delete [] to;
	return back;
}

bool PostgreSQL::getBool(int row, int col) const {
	return PQgetvalue(pg_result, row, col)[0] == 't';
}

double PostgreSQL::getDouble(int row, int col) const {
	return atof(PQgetvalue(pg_result, row, col));
}

int PostgreSQL::getInt(int row, int col) const {
	return atoi(PQgetvalue(pg_result, row, col));
}

int PostgreSQL::getRows() const {
	return PQntuples(pg_result);
}

string PostgreSQL::getString(int row, int col) const {
	return PQgetvalue(pg_result, row, col);
}

bool PostgreSQL::isNull(int row, int col) const {
	return (PQgetisnull(pg_result, row, col) != 0);
}

bool PostgreSQL::doQuery(const string &query) {
	return doQuery(query.c_str());
}
