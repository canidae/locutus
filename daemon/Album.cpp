#include "Album.h"

using namespace std;

/* constructors/destructor */
Album::Album(const string &mbid) : mbid(mbid) {
	artist = Artist();
	title = "";
	released = "";
	type = "";
}

Album::~Album() {
}
