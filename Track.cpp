#include "Track.h"

/* constructors */
Track::Track(Locutus *locutus, Album *album, Artist *artist) {
	this->locutus = locutus;
	this->album = album;
	this->artist = artist;
	duration = 0;
	tracknumber = 0;
	mbid = "";
	title = "";
}

/* destructors */
Track::~Track() {
	delete artist;
}

/* methods */
Metatrack Track::getAsMetatrack() const {
	Metatrack mt(locutus);
	mt.duration = duration;
	mt.tracknumber = tracknumber;
	mt.track_mbid = mbid;
	mt.track_title = title;
	mt.artist_mbid = artist->mbid;
	mt.artist_name = artist->name;
	mt.album_mbid = album->mbid;
	mt.album_title = album->title;
	return mt;
}

bool Track::saveToCache() const {
	if (mbid.size() != 36) {
		string msg = "Unable to save track in cache. Illegal MusicBrainz ID: ";
		msg.append(mbid);
		locutus->debug(DEBUG_NOTICE, msg);
		return false;
	}
	artist->saveToCache();
	string e_album_mbid = locutus->database->escapeString(album->mbid);
	string e_artist_mbid = locutus->database->escapeString(artist->mbid);
	string e_mbid = locutus->database->escapeString(mbid);
	string e_title = locutus->database->escapeString(title);
	ostringstream query;
	query << "INSERT INTO track(album_id, artist_id, mbid, title, duration, tracknumber) SELECT (SELECT album_id FROM album WHERE mbid = '" << e_album_mbid << "'), (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), '" << e_mbid << "', '" << e_title << "', " << duration << ", " << tracknumber << " WHERE NOT EXISTS (SELECT true FROM track WHERE mbid = '" << e_mbid << "')";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save track in cache, query failed. See error above");
	query.str("");
	query << "UPDATE track SET album_id = (SELECT album_id FROM album WHERE mbid = '" << e_album_mbid << "'), artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), title = '" << e_title << "', duration = " << duration << ", tracknumber = " << tracknumber << " WHERE mbid = '" << e_mbid << "'";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save track in cache, query failed. See error above");
	return true;
}
