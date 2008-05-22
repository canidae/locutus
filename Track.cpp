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
