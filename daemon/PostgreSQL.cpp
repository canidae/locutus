#include "Album.h"
#include "Artist.h"
#include "Debug.h"
#include "Match.h"
#include "Metafile.h"
#include "Metatrack.h"
#include "PostgreSQL.h"
#include "Track.h"

using namespace std;

/* constructors/destructor */
PostgreSQL::PostgreSQL(const string connection) : Database(), pg_result(NULL), got_result(false) {
	pg_connection = PQconnectdb(connection.c_str());
	if (PQstatus(pg_connection) != CONNECTION_OK) {
		Debug::error("Unable to connect to the database");
		exit(1);
	}
	album_cache_lifetime = loadSetting(ALBUM_CACHE_LIFETIME_KEY, ALBUM_CACHE_LIFETIME_VALUE, ALBUM_CACHE_LIFETIME_DESCRIPTION);
	metatrack_cache_lifetime = loadSetting(METATRACK_CACHE_LIFETIME_KEY, METATRACK_CACHE_LIFETIME_VALUE, METATRACK_CACHE_LIFETIME_DESCRIPTION);
	puid_cache_lifetime = loadSetting(PUID_CACHE_LIFETIME_KEY, PUID_CACHE_LIFETIME_VALUE, PUID_CACHE_LIFETIME_DESCRIPTION);
}

PostgreSQL::~PostgreSQL() {
	clear();
	PQfinish(pg_connection);
}

/* methods */
bool PostgreSQL::load(Album *album) {
	/* fetch album from cache */
	if (album == NULL)
		return false;
	if (album->mbid.size() != 36 || album->mbid[8] != '-' || album->mbid[13] != '-' || album->mbid[18] != '-' || album->mbid[23] != '-') {
		string msg = "Unable to load album from cache. Illegal MusicBrainz ID: ";
		msg.append(album->mbid);
		Debug::notice(msg);
		return false;
	}
	ostringstream query;
	query << "SELECT * FROM v_daemon_load_album WHERE album_mbid = '" << escapeString(album->mbid) << "' AND last_updated + INTERVAL '" << album_cache_lifetime << " months' > now()";
	if (!doQuery(query.str()) || getRows() <= 0) {
		/* album not in cache */
		string msg = "Unable to load album from cache. MusicBrainz ID not found or cache is too old: ";
		msg.append(album->mbid);
		Debug::notice(msg);
		return false;
	}
	/* artist data */
	album->artist->mbid = getString(0, 0);
	album->artist->name = getString(0, 1);
	album->artist->sortname = getString(0, 2);
	/* album data */
	album->mbid = getString(0, 3);
	album->type = getString(0, 4);
	album->title = getString(0, 5);
	album->released = getString(0, 6);
	/* track data */
	int trackcount = getRows();
	album->tracks.resize(trackcount);
	for (int t = 0; t < trackcount; ++t) {
		int trackindex = getInt(t, 10) - 1;
		if (trackindex < 0 || trackindex >= (int) album->tracks.capacity()) {
			/* this really shouldn't happen.
			 * seemingly we're missing entries in the track table */
			string msg = "Tracknumber either exceed album track count or is less than 1. Did you mess with the track table? MusicBrainz Album ID: ";
			msg.append(album->mbid);
			Debug::warning(msg);
			return false;
		}
		album->tracks[trackindex] = new Track(album);
		/* track data */
		album->tracks[trackindex]->mbid = getString(t, 7);
		album->tracks[trackindex]->title = getString(t, 8);
		album->tracks[trackindex]->duration = getInt(t, 9);
		album->tracks[trackindex]->tracknumber = trackindex + 1;
		/* track artist data */
		album->tracks[trackindex]->artist->mbid = getString(t, 11);
		album->tracks[trackindex]->artist->name = getString(t, 12);
		album->tracks[trackindex]->artist->sortname = getString(t, 13);
	}
	return true;
}

bool PostgreSQL::load(Metafile *metafile) {
	if (metafile == NULL)
		return false;
	if (metafile->filename.size() <= 0) {
		Debug::notice("Length of filename is 0 or less? Can't load that from cache");
		return false;
	}
	string e_filename = escapeString(metafile->filename);
	ostringstream query;
	query << "SELECT * FROM v_daemon_load_metafile WHERE filename = '" << e_filename << "'";
	if (!doQuery(query.str()) || getRows() <= 0) {
		string msg = "Didn't find file in database: ";
		msg.append(metafile->filename);
		Debug::notice(msg);
		return false;
	}
	metafile->duration = getInt(0, 2);
	metafile->channels = getInt(0, 3);
	metafile->bitrate = getInt(0, 4);
	metafile->samplerate = getInt(0, 5);
	metafile->puid = getString(0, 6);
	metafile->album = getString(0, 7);
	metafile->albumartist = getString(0, 8);
	metafile->albumartistsort = getString(0, 9);
	metafile->artist = getString(0, 10);
	metafile->artistsort = getString(0, 11);
	metafile->musicbrainz_albumartistid = getString(0, 12);
	metafile->musicbrainz_albumid = getString(0, 13);
	metafile->musicbrainz_artistid = getString(0, 14);
	metafile->musicbrainz_trackid = getString(0, 15);
	metafile->title = getString(0, 16);
	metafile->tracknumber = getString(0, 17);
	metafile->released = getString(0, 18);
	return true;
}

bool PostgreSQL::loadSetting(const string &key, bool default_value, const string &description) {
	string def_val = (default_value ? "true" : "false");
	return (loadSetting(key, def_val, description) == "true");
}

double PostgreSQL::loadSetting(const string &key, double default_value, const string &description) {
	ostringstream def_val;
	def_val << default_value;
	return atof(loadSetting(key, def_val.str(), description).c_str());
}

int PostgreSQL::loadSetting(const string &key, int default_value, const string &description) {
	ostringstream def_val;
	def_val << default_value;
	return atoi(loadSetting(key, def_val.str(), description).c_str());
}

string PostgreSQL::loadSetting(const string &key, const string &default_value, const string &description) {
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
			query << "UPDATE setting SET default_value = '" << e_value << "', value = '" << e_value << "', description = '" << e_description << "' WHERE key = '" << e_key << "'";
			if (!doQuery(query.str()))
				return back;
		}
	} else {
		/* this key is missing, add it */
		query.str("");
		query << "INSERT INTO setting(key, default_value, value, description) VALUES ('" << e_key << "', '" << e_value << "', '" << e_value << "', '" << e_description << "')";  
		if (!doQuery(query.str()))
			return back;                                                                                                                   
	}                                                                                                                                              
	return back;
}

bool PostgreSQL::save(const Album &album) {
	if (album.mbid.size() != 36) {
		string msg = "Unable to save album in cache. Illegal MusicBrainz ID: ";
		msg.append(album.mbid);
		Debug::notice(msg);
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
	if (!save(*album.artist))
		Debug::notice("Failed to save album artist in cache. See errors above");
	/* save album */
	query.str("");
	query << "INSERT INTO album(artist_id, mbid, type, title, released) SELECT (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), '" << e_mbid << "', '" << e_type << "', '" << e_title << "', " << e_released << " WHERE NOT EXISTS (SELECT true FROM album WHERE mbid = '" << e_mbid << "')";
	if (!doQuery(query.str())) {
		Debug::notice("Unable to save album in cache, query failed. See error above");
		return false;
	}
	query.str("");
	query << "UPDATE album SET artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), type = '" << e_type << "', title = '" << e_title << "', released = " << e_released << ", last_updated = now() WHERE mbid = '" << e_mbid << "'";
	if (!doQuery(query.str())) {
		Debug::notice("Unable to save album in cache, query failed. See error above");
		return false;
	}
	/* save tracks */
	bool status = true;
	for (vector<Track *>::const_iterator track = album.tracks.begin(); track != album.tracks.end(); ++track) {
		if (!save(**track))
			status = false;
	}
	if (!status)
		Debug::notice("One or more album tracks couldn't be saved in cache. See errors above");
	return status;
}

bool PostgreSQL::save(const Artist &artist) {
	if (artist.mbid.size() != 36)
		return false;
	string e_mbid = escapeString(artist.mbid);
	string e_name = escapeString(artist.name);
	string e_sortname = escapeString(artist.sortname);
	ostringstream query;
	query << "INSERT INTO artist(mbid, name, sortname) SELECT '" << e_mbid << "', '" << e_name << "', '" << e_sortname << "' WHERE NOT EXISTS (SELECT true FROM artist WHERE mbid = '" << e_mbid << "')";
	if (!doQuery(query.str()))
		Debug::notice("Unable to save artist in cache, query failed. See error above");
	query.str("");
	query << "UPDATE artist SET name = '" << e_name << "', sortname = '" << e_sortname << "' WHERE mbid = '" << e_mbid << "'";
	if (!doQuery(query.str()))
		Debug::notice("Unable to save artist in cache, query failed. See error above");
	return true;
}

bool PostgreSQL::save(const Match &match) {
	string e_filename = escapeString(match.metafile->filename);
	string e_track_mbid = escapeString(match.track->mbid);
	ostringstream query;
	query << "INSERT INTO match(file_id, metatrack_id, mbid_match, puid_match, meta_score) SELECT (SELECT file_id FROM file WHERE filename = '" << e_filename << "'), (SELECT metatrack_id FROM metatrack WHERE track_mbid = '" << e_track_mbid << "'), " << (match.mbid_match ? "true" : "false") << ", " << (match.puid_match ? "true" : "false") << ", " << match.meta_score << " WHERE NOT EXISTS (SELECT true FROM match WHERE file_id = (SELECT file_id FROM file WHERE filename = '" << e_filename << "') AND metatrack_id = (SELECT metatrack_id FROM metatrack WHERE track_mbid = '" << e_track_mbid << "'))";
	if (!doQuery(query.str()))
		Debug::notice("Unable to save metadata match in cache, query failed. See error above");
	query.str("");
	query << "UPDATE match SET mbid_match = " << (match.mbid_match ? "true" : "false") << ", puid_match = "  << (match.puid_match ? "true" : "false") << ", meta_score = " << match.meta_score << " WHERE file_id = (SELECT file_id FROM file WHERE filename = '" << e_filename << "') AND metatrack_id = (SELECT metatrack_id FROM metatrack WHERE track_mbid = '" << e_track_mbid << "')";
	if (!doQuery(query.str()))
		Debug::notice("Unable to save metadata match in cache, query failed. See error above");
	return true;
}

bool PostgreSQL::save(const Metafile &metafile, const string &old_filename) {
	ostringstream query;
	string e_puid = escapeString(metafile.puid);
	if (e_puid != "") {
		query << "INSERT INTO puid(puid) SELECT '" << e_puid << "' WHERE NOT EXISTS (SELECT true FROM puid WHERE puid = '" << e_puid << "')";
		if (!doQuery(query.str()))
			Debug::notice("Unable to store PUID in database. See error above");
	}
	string e_filename = escapeString(metafile.filename);
	string e_old_filename = escapeString(old_filename);
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
	if (old_filename == "") {
		query.str("");
		query << "INSERT INTO file(filename, duration, channels, bitrate, samplerate, puid_id, album, albumartist, albumartistsort, artist, artistsort, musicbrainz_albumartistid, musicbrainz_albumid, musicbrainz_artistid, musicbrainz_trackid, title, tracknumber, released) SELECT '" << e_filename << "', " << metafile.duration << ", " << metafile.channels << ", " << metafile.bitrate << ", " << metafile.samplerate << ", ";
		if (e_puid != "")
			query << "(SELECT puid_id FROM puid WHERE puid = '" << e_puid << "'), ";
		else
			query << "NULL, ";
		query << "'" << e_album << "', '" << e_albumartist << "', '" << e_albumartistsort << "', '" << e_artist << "', '" << e_artistsort << "', '" << e_musicbrainz_albumartistid << "', '" << e_musicbrainz_albumid << "', '" << e_musicbrainz_artistid << "', '" << e_musicbrainz_trackid << "', '" << e_title << "', '" << e_tracknumber << "', '" << e_released << "' WHERE NOT EXISTS (SELECT true FROM file WHERE filename = '" << e_filename << "')";
		if (!doQuery(query.str())) {
			Debug::notice("Unable to store file in database. See error above");
			return false;
		}
	} else {
		query.str("");
		query << "UPDATE file SET filename = '" << e_filename << "', duration = " << metafile.duration << ", channels = " << metafile.channels << ", bitrate = " << metafile.bitrate << ", samplerate = " << metafile.samplerate << ", ";
		if (e_puid != "")
			query << "puid = (SELECT puid_id FROM puid WHERE puid = '" << e_puid << "'), ";
		query << "album = '" << e_album << "', albumartist = '" << e_albumartist << "', albumartistsort = '" << e_albumartistsort << "', artist = '" << e_artist << "', artistsort = '" << e_artistsort << "', musicbrainz_albumartistid = '" << e_musicbrainz_albumartistid << "', musicbrainz_albumid = '" << e_musicbrainz_albumid << "', musicbrainz_artistid = '" << e_musicbrainz_artistid << "', musicbrainz_trackid = '" << e_musicbrainz_trackid << "', title = '" << e_title << "', tracknumber = '" << e_tracknumber << "', released = '" << e_released << "' WHERE filename = '" << e_old_filename << "'";
		if (!doQuery(query.str())) {
			Debug::notice("Unable to store file in database. See error above");
			return false;
		}
	}
	return true;
}

bool PostgreSQL::save(const Metatrack &metatrack) {
	if (metatrack.track_mbid.size() != 36) {
		Debug::notice("Won't save metatrack in cache, missing MBIDs");
		return false;
	}
	string e_track_mbid = escapeString(metatrack.track_mbid);
	string e_track_title = escapeString(metatrack.track_title);
	string e_artist_mbid = escapeString(metatrack.artist_mbid);
	string e_artist_name = escapeString(metatrack.artist_name);
	string e_album_mbid = escapeString(metatrack.album_mbid);
	string e_album_title = escapeString(metatrack.album_title);
	ostringstream query;
	query << "INSERT INTO metatrack(track_mbid, track_title, duration, tracknumber, artist_mbid, artist_name, album_mbid, album_title) SELECT '" << e_track_mbid << "', '" << e_track_title << "', " << metatrack.duration << ", " << metatrack.tracknumber << ", '" << e_artist_mbid << "', '" << e_artist_name << "', '" << e_album_mbid << "', '" << e_album_title << "' WHERE NOT EXISTS (SELECT true FROM metatrack WHERE track_mbid = '" << e_track_mbid << "')";
	if (!doQuery(query.str()))
		Debug::notice("Unable to save metatrack, query failed. See error above");
	query.str("");
	query << "UPDATE metatrack SET track_title = '" << e_track_title << "', duration = " << metatrack.duration << ", tracknumber = " << metatrack.tracknumber << ", artist_mbid = '" << e_artist_mbid << "', artist_name = '" << e_artist_name << "', album_mbid = '" << e_album_mbid << "', album_title = '" << e_album_title << "' WHERE track_mbid = '" << e_track_mbid << "'";
	if (!doQuery(query.str()))
		Debug::notice("Unable to save metatrack, query failed. See error above");
	return true;
}

bool PostgreSQL::save(const Track &track) {
	if (track.mbid.size() != 36) {
		string msg = "Unable to save track in cache. Illegal MusicBrainz ID: ";
		msg.append(track.mbid);
		Debug::notice(msg);
		return false;
	}
	save(*track.artist);
	string e_album_mbid = escapeString(track.album->mbid);
	string e_artist_mbid = escapeString(track.artist->mbid);
	string e_mbid = escapeString(track.mbid);
	string e_title = escapeString(track.title);
	ostringstream query;
	query << "INSERT INTO track(album_id, artist_id, mbid, title, duration, tracknumber) SELECT (SELECT album_id FROM album WHERE mbid = '" << e_album_mbid << "'), (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), '" << e_mbid << "', '" << e_title << "', " << track.duration << ", " << track.tracknumber << " WHERE NOT EXISTS (SELECT true FROM track WHERE mbid = '" << e_mbid << "')";
	if (!doQuery(query.str()))
		Debug::notice("Unable to save track in cache, query failed. See error above");
	query.str("");
	query << "UPDATE track SET album_id = (SELECT album_id FROM album WHERE mbid = '" << e_album_mbid << "'), artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), title = '" << e_title << "', duration = " << track.duration << ", tracknumber = " << track.tracknumber << " WHERE mbid = '" << e_mbid << "'";
	if (!doQuery(query.str()))
		Debug::notice("Unable to save track in cache, query failed. See error above");
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
	string msg = "Query: ";
	msg.append(q);
	Debug::info(msg);
	pg_result = PQexec(pg_connection, q);
	int status = PQresultStatus(pg_result);
	if (status == PGRES_COMMAND_OK || status == PGRES_TUPLES_OK)
		return true;
	msg = "Query failed: ";
	msg.append(q);
	Debug::warning(msg);
	msg = "Query error: ";
	msg.append(PQresultErrorMessage(pg_result));
	Debug::warning(msg);
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
