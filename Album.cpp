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
	mbid = "";
	type = "";
	title = "";
	released = "";
	asin = "";
}

/* private methods */
