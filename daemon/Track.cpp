#include "Album.h"
#include "Artist.h"
#include "Track.h"

using namespace std;

/* constructors/destructor */
Track::Track(Album *album) : album(album), artist(new Artist()), duration(0), tracknumber(0), mbid(""), title("") {
}

Track::~Track() {
	delete artist;
}

/* methods */
Metatrack Track::getAsMetatrack() const {
	if (album == NULL || artist == NULL)
		return Metatrack();
	return Metatrack(duration, tracknumber, album->mbid, album->title, artist->mbid, artist->name, "", mbid, title);
}
