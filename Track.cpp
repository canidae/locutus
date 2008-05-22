#include "Track.h"

/* constructors */
Track::Track(Locutus *locutus, Album *album, Artist *artist) {
	this->locutus = locutus;
	this->album = album;
	this->artist = artist;
	duration = 0;
	mbid = "";
	puid = "";
	title = "";
	tracknumber = "";
}

/* destructors */
Track::~Track() {
}

/* methods */
bool Track::saveToCache() {
	if (mbid.size() != 36)
		return false;
	string e_album_mbid = locutus->database->escapeString(album->mbid);
	ostringstream query;
	//query << "INSERT INTO track(album_id, artist_id, mbid, title, duration, tracknumber) SELECT (SELECT album_id FROM album WHERE mbid = '" << ambide << "'), (SELECT artist_id FROM artist WHERE mbid = '" << tambide << "'), '" << tmbide << "', '" << ttitlee << "', " << track.duration << ", " << a + 1 << " WHERE NOT EXISTS (SELECT true FROM track WHERE mbid = '" << tmbide << "')";
	return true;
}
