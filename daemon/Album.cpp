#include "Album.h"
#include "Artist.h"

using namespace std;

/* constructors/destructor */
Album::Album(const string &mbid) : artist(new Artist()), mbid(mbid), released(""), title(""), type("") {
}

Album::~Album() {
	delete artist;
	for (vector<Track *>::iterator t = tracks.begin(); t != tracks.end(); ++t)
		delete *t;
}
