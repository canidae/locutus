#include "Track.h"

/* constructors */
Track::Track(Locutus *locutus, Album *album, Artist *artist) {
	this->locutus = locutus;
	this->album = album;
	this->artist = artist;
	duration = 0;
	mbid = "";
	title = "";
	tracknumber = "";
}

/* destructors */
Track::~Track() {
	delete artist;
}

/* methods */
bool Track::saveToCache() {
	if (mbid.size() != 36) {
		string msg = "Unable to save track in cache. Illegal MusicBrainz ID: ";
		msg.append(mbid);
		locutus->debug(DEBUG_NOTICE, msg);
		return false;
	}
	string e_album_mbid = locutus->database->escapeString(album->mbid);
	string e_artist_mbid = locutus->database->escapeString(artist->mbid);
	string e_mbid = locutus->database->escapeString(mbid);
	string e_title = locutus->database->escapeString(title);
	int tracknum = atoi(tracknumber.c_str());
	ostringstream query;
	query << "INSERT INTO track(album_id, artist_id, mbid, title, duration, tracknumber) SELECT (SELECT album_id FROM album WHERE mbid = '" << e_album_mbid << "'), (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), '" << e_mbid << "', '" << e_title << "', " << duration << ", " << tracknum << " WHERE NOT EXISTS (SELECT true FROM track WHERE mbid = '" << e_mbid << "')";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save track in cache, query failed. See error above");
	query.str("");
	query << "UPDATE track SET album_id = (SELECT album_id FROM album WHERE mbid = '" << e_album_mbid << "'), artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), title = '" << e_title << "', duration = " << duration << ", tracknumber = " << tracknum << " WHERE mbid = '" << e_mbid << "'";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save track in cache, query failed. See error above");
	return true;
}
