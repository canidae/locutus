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
	Metatrack mt;
	if (album == NULL)
		return mt;
	mt.duration = duration;
	mt.tracknumber = tracknumber;
	mt.track_mbid = mbid;
	mt.track_title = title;
	mt.artist_mbid = artist->mbid;
	mt.artist_name = artist->name;
	mt.album_mbid = album->mbid;
	mt.album_title = album->title;
	return mt;
}
