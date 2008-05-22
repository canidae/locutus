#include "Track.h"

/* constructors */
Track::Track(Locutus *locutus) {
	this->locutus = locutus;
	duration = 0;
	album = "";
	albumartist = "";
	albumartistid = "";
	albumartistsort = "";
	albumid = "";
	albumtype = "";
	artist = "";
	artistid = "";
	artistsort = "";
	puid = "";
	released = "";
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
	return true;
}
