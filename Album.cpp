#include "Album.h"

/* constructors */
Album::Album(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
Album::~Album() {
	for (vector<Track *>::size_type t = 0; t < tracks.size(); ++t)
		delete tracks[t];
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
	/* album data */
	albumartistid = locutus->database->getString(0, 0);
	albumartist = locutus->database->getString(0, 1);
	albumartistsort = locutus->database->getString(0, 2);
	albumid = locutus->database->getString(0, 3);
	albumtype = locutus->database->getString(0, 4);
	album = locutus->database->getString(0, 5);
	released = locutus->database->getString(0, 6);
	/* track data */
	int trackcount = locutus->database->getRows();
	tracks.resize(trackcount, NULL);
	for (int t = 0; t < trackcount; ++t) {
		Track *track = new Track(locutus, this);
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

bool Album::saveToCache() {
	/* save album to cache */
	if (albumartistid.size() != 36 || albumid.size() != 36)
		return false;
	string e_albumartistid = locutus->database->escapeString(albumartistid);
	string e_albumid = locutus->database->escapeString(albumid);
	string e_album = locutus->database->escapeString(album);
	string e_albumartist = locutus->database->escapeString(albumartist);
	string e_albumartistsort = locutus->database->escapeString(albumartistsort);
	string e_albumtype = locutus->database->escapeString(albumtype);
	string e_released = locutus->database->escapeString(released);
	ostringstream query;
	/* save artist */
	query << "INSERT INTO artist(mbid, name, sortname, loaded) SELECT '" << e_albumartistid << "', '" << e_albumartist << "', '" << e_albumartistsort << "', true WHERE NOT EXISTS (SELECT true FROM artist WHERE mbid = '" << e_albumartistid << "')";
	locutus->database->query(query.str());
	locutus->database->clear();
	query.str("");
	query << "UPDATE artist SET name = '" << e_albumartist << "', sortname = '" << e_albumartistsort << "', loaded = true WHERE mbid = '" << e_albumartistid << "'";
	locutus->database->query(query.str());
	locutus->database->clear();
	/* save album */
	query.str("");
	query << "INSERT INTO album(artist_id, mbid, type, title, released, loaded) SELECT (SELECT artist_id FROM artist WHERE mbid = '" << e_albumartistid << "'), '" << e_albumid << "', '" << e_albumtype << "', '" << e_album << "', " << released << ", true WHERE NOT EXISTS (SELECT true FROM album WHERE mbid = '" << e_albumid << "')";
	locutus->database->query(query.str());
	locutus->database->clear();
	query.str("");
	query << "UPDATE album SET artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << e_albumartistid << "'), type = '" << e_albumtype << "', title = '" << e_album << "', released = " << e_released << ", loaded = true, updated = now() WHERE mbid = '" << e_albumid << "'";
	locutus->database->query(query.str());
	locutus->database->clear();
	/* save tracks */
	bool status = true;
	for (vector<Track *>::iterator track = tracks.begin(); track != tracks.end(); ++track) {
		if (!(*track)->saveToCache())
			status = false;
	}
	return status;
}
