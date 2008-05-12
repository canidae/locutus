#include "Album.h"

/* constructors */
Album::Album() {
	clear();
}

/* destructors */
Album::~Album() {
}

/* methods */
void Album::clear() {
	tracks.clear();
	artist_mbid = "";
	artist_name = "";
	artist_sortname = "";
	mbid = "";
	released = "";
	title = "";
	type = "";
}
