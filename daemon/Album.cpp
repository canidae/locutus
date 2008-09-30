#include "Album.h"

using namespace std;

/* constructors/destructor */
Album::Album(const string &mbid) {
	artist = Artist();
	this->mbid = mbid;
	title = "";
	released = "";
	type = "";
}

Album::~Album() {
}
