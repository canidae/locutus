#include "Album.h"

/* constructors */
Album::Album(Locutus *locutus) {
	this->locutus = locutus;
	artist = new Artist(locutus);
	mbid = "";
	title = "";
	released = "";
	type = "";
}

/* destructors */
Album::~Album() {
	for (vector<Track *>::size_type t = 0; t < tracks.size(); ++t)
		delete tracks[t];
	delete artist;
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
	/* artist data */
	artist->mbid = locutus->database->getString(0, 0);
	artist->name = locutus->database->getString(0, 1);
	artist->sortname = locutus->database->getString(0, 2);
	/* album data */
	mbid = locutus->database->getString(0, 3);
	type = locutus->database->getString(0, 4);
	title = locutus->database->getString(0, 5);
	released = locutus->database->getString(0, 6);
	/* track data */
	int trackcount = locutus->database->getRows();
	tracks.resize(trackcount, NULL);
	for (int t = 0; t < trackcount; ++t) {
		Track *track = new Track(locutus, this, NULL);
		track->mbid = locutus->database->getString(t, 7);
		track->title = locutus->database->getString(t, 8);
		track->duration = locutus->database->getInt(t, 9);
		track->tracknumber = locutus->database->getString(t, 10);
		/*
		track->artistid = locutus->database->getString(t, 11);
		track->artist = locutus->database->getString(t, 12);
		track->artistsort = locutus->database->getString(t, 13);
		*/
		tracks[locutus->database->getInt(t, 10) - 1] = track;
	}
	locutus->database->clear();
	return true;
}

bool Album::saveToCache() {
	/* save album to cache */
	if (mbid.size() != 36)
		return false;
	string e_artist_mbid = locutus->database->escapeString(artist->mbid);
	string e_mbid = locutus->database->escapeString(mbid);
	string e_title = locutus->database->escapeString(title);
	string e_type = locutus->database->escapeString(type);
	string e_released = locutus->database->escapeString(released);
	ostringstream query;
	/* save artist */
	artist->saveToCache();
	/* save album */
	query.str("");
	query << "INSERT INTO album(artist_id, mbid, type, title, released, loaded) SELECT (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), '" << e_mbid << "', '" << e_type << "', '" << e_title << "', " << e_released << ", true WHERE NOT EXISTS (SELECT true FROM album WHERE mbid = '" << e_mbid << "')";
	locutus->database->query(query.str());
	locutus->database->clear();
	query.str("");
	query << "UPDATE album SET artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), type = '" << e_type << "', title = '" << e_title << "', released = " << e_released << ", loaded = true, updated = now() WHERE mbid = '" << e_mbid << "'";
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
