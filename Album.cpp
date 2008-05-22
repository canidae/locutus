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
	int trackcount = locutus->database->getRows();
	tracks.resize(trackcount, NULL);
	for (int t = 0; t < trackcount; ++t) {
		Track *track = new Track(locutus);
		track->albumartistid = locutus->database->getString(t, 0);
		track->albumartist = locutus->database->getString(t, 1);
		track->albumartistsort = locutus->database->getString(t, 2);
		track->albumid = locutus->database->getString(t, 3);
		track->albumtype = locutus->database->getString(t, 4);
		track->album = locutus->database->getString(t, 5);
		track->released = locutus->database->getString(t, 6);
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
	if (tracks.size() <= 0 || tracks[0] == NULL)
		return false;
	string albumartistid = locutus->database->escapeString(tracks[0]->albumartistid);
	string albumid = locutus->database->escapeString(tracks[0]->albumid);
	if (albumartistid.size() != 36 || albumid.size() != 36)
		return false;
	string album = locutus->database->escapeString(tracks[0]->album);
	string albumartist = locutus->database->escapeString(tracks[0]->albumartist);
	string albumartistsort = locutus->database->escapeString(tracks[0]->albumartistsort);
	string albumtype = locutus->database->escapeString(tracks[0]->albumtype);
	string released = locutus->database->escapeString(tracks[0]->released);
	ostringstream query;
	/* save artist */
	query << "INSERT INTO artist(mbid, name, sortname, loaded) SELECT '" << albumartistid << "', '" << albumartist << "', '" << albumartistsort << "', true WHERE NOT EXISTS (SELECT true FROM artist WHERE mbid = '" << albumartistid << "')";
	locutus->database->query(query.str());
	locutus->database->clear();
	query.str("");
	query << "UPDATE artist SET name = '" << albumartist << "', sortname = '" << albumartistsort << "', loaded = true WHERE mbid = '" << albumartistid << "'";
	locutus->database->query(query.str());
	locutus->database->clear();
	/* save album */
	query.str("");
	query << "INSERT INTO album(artist_id, mbid, type, title, released, loaded) SELECT (SELECT artist_id FROM artist WHERE mbid = '" << albumartistid << "'), '" << albumid << "', '" << albumtype << "', '" << album << "', " << released << ", true WHERE NOT EXISTS (SELECT true FROM album WHERE mbid = '" << albumid << "')";
	locutus->database->query(query.str());
	locutus->database->clear();
	query.str("");
	query << "UPDATE album SET artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << albumartistid << "'), type = '" << albumtype << "', title = '" << album << "', released = " << released << ", loaded = true, updated = now() WHERE mbid = '" << albumid << "'";
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
