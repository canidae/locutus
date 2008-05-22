#include "Track.h"

/* constructors */
Track::Track(Locutus *locutus, Album *album) {
	this->locutus = locutus;
	this->album = album;
	duration = 0;
	artist = "";
	artistid = "";
	artistsort = "";
	puid = "";
	title = "";
	trackid = "";
	tracknumber = "";
}

/* destructors */
Track::~Track() {
}

/* methods */
bool Track::saveToCache() {
	if (trackid.size() != 36)
		return false;
	ostringstream query;
	//query << "INSERT INTO track(album_id, artist_id, mbid, title, duration, tracknumber) SELECT (SELECT album_id FROM album WHERE mbid = '" << ambide << "'), (SELECT artist_id FROM artist WHERE mbid = '" << tambide << "'), '" << tmbide << "', '" << ttitlee << "', " << track.duration << ", " << a + 1 << " WHERE NOT EXISTS (SELECT true FROM track WHERE mbid = '" << tmbide << "')";
	return true;
}
