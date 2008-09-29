#include "Album.h"

/* constructors */
Album::Album(const string &mbid) {
	artist = Artist();
	this->mbid = mbid;
	title = "";
	released = "";
	type = "";
}

/* destructors */
Album::~Album() {
}
