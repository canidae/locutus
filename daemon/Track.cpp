#include "Album.h"
#include "Artist.h"
#include "Track.h"

using namespace std;

/* constructors/destructor */
Track::Track(Album *album) : album(album), artist(new Artist()), id(-1), duration(0), tracknumber(0), mbid(""), title("") {
}

Track::~Track() {
	delete artist;
}

/* methods */
Metatrack Track::getAsMetatrack() const {
	if (album == NULL || artist == NULL)
		return Metatrack();
	return Metatrack(duration, tracknumber, mbid, title, artist->mbid, artist->name, album->mbid, album->title);
}
