#include "Album.h"

/* constructors */
Album::Album(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
Album::~Album() {
}

/* methods */
bool Album::loadFromCache(string mbid) {
	/* fetch album from cache */
	if (mbid.size() != 36)
		return false;
	ostringstream query;
	query << "SELECT * FROM v_album_lookup WHERE album_mbid = '" << mbid << "'";
	if (!locutus->database->query(query.str()) || locutus->database->getRows() <= 0) {
		/* album not in cache */
		locutus->database->clear();
		return false;
	}
	int trackcount = locutus->database->getRows();
	tracks.resize(trackcount, NULL);
	for (int t = 0; t < trackcount; ++t) {
		Track *track = new Track(locutus);
		track->albumartistid = locutus->database->getString(t, 0);
		track->albumartist = locutus->database->getString(t, 1);
		track->albumartistsort = locutus->database->getString(t, 2);
		track->albumid = locutus->database->getString(t, 3);
		//album.type = locutus->database->getString(t, 4);
		track->album = locutus->database->getString(t, 5);
		//album.released = locutus->database->getString(t, 6);
		track->trackid = locutus->database->getString(t, 7);
		track->title = locutus->database->getString(t, 8);
		track->duration = locutus->database->getInt(t, 9);
		track->tracknumber = locutus->database->getString(t, 10);
		track->artistid = locutus->database->getString(t, 11);
		track->artist = locutus->database->getString(t, 12);
		track->artistsort = locutus->database->getString(t, 13);
		tracks[locutus->database->getInt(t, 10) - 1] = track;
	}
	locutus->database->clear();
	return true;
}
