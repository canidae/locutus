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
	if (locutus == NULL)
		return false;
	if (mbid.size() != 36) {
		string msg = "Unable to load album from cache. Illegal MusicBrainz ID: ";
		msg.append(mbid);
		locutus->debug(DEBUG_NOTICE, msg);
		return false;
	}
	ostringstream query;
	query << "SELECT * FROM v_album_lookup WHERE album_mbid = '" << locutus->database->escapeString(mbid) << "'";
	if (!locutus->database->query(query.str()) || locutus->database->getRows() <= 0) {
		/* album not in cache */
		string msg = "Unable to load album from cache. MusicBrainz ID not found: ";
		msg.append(mbid);
		locutus->debug(DEBUG_NOTICE, msg);
		return false;
	}
	/* artist data */
	artist->mbid = locutus->database->getString(0, 0);
	artist->name = locutus->database->getString(0, 1);
	artist->sortname = locutus->database->getString(0, 2);
	/* album data */
	this->mbid = locutus->database->getString(0, 3);
	type = locutus->database->getString(0, 4);
	title = locutus->database->getString(0, 5);
	released = locutus->database->getString(0, 6);
	/* track data */
	int trackcount = locutus->database->getRows();
	tracks.resize(trackcount, NULL);
	for (int t = 0; t < trackcount; ++t) {
		/* we could reduce memory usage here.
		 * we'll get the same artist stored <trackcount> times.
		 * since each artist entry usually eats about 64 bytes mem,
		 * it's hardly necessary to improve this, though */
		Artist *track_artist = new Artist(locutus);
		Track *track = new Track(locutus, this, track_artist);
		/* track data */
		track->mbid = locutus->database->getString(t, 7);
		track->title = locutus->database->getString(t, 8);
		track->duration = locutus->database->getInt(t, 9);
		track->tracknumber = locutus->database->getInt(t, 10);
		/* track artist data */
		track_artist->mbid = locutus->database->getString(t, 11);
		track_artist->name = locutus->database->getString(t, 12);
		track_artist->sortname = locutus->database->getString(t, 13);
		tracks[track->tracknumber - 1] = track;
	}
	return true;
}

bool Album::retrieveFromWebService(string mbid) {
	/* album data */
	if (locutus == NULL)
		return false;
	XMLNode *root = locutus->webservice->lookupAlbum(mbid);
	if (root == NULL)
		return false;
	if (root->children["metadata"].size() <= 0)
		return false;
	XMLNode *album = root->children["metadata"][0]->children["release"][0];
	this->mbid = album->children["id"][0]->value;
	type = album->children["type"][0]->value;
	title = album->children["title"][0]->value;
	if (album->children["release-event-list"].size() > 0) {
		released = album->children["release-event-list"][0]->children["event"][0]->children["date"][0]->value;
		if (released.size() == 10 && released[4] == '-' && released[7] == '-') {
			/* ok as it is, probably a valid date */
		} else if (released.size() == 4) {
			/* no month & day, add 1st of january */
			released.append("-01-01");
		} else {
			/* possibly not a valid date, ignore it */
			released = "";
		}
	}
	/* artist data */
	artist->mbid = album->children["artist"][0]->children["id"][0]->value;
	artist->name = album->children["artist"][0]->children["name"][0]->value;
	artist->sortname = album->children["artist"][0]->children["sort-name"][0]->value;
	/* track data */
	tracks.resize(album->children["track-list"][0]->children["track"].size(), NULL);
	for (vector<XMLNode *>::size_type a = 0; a < album->children["track-list"][0]->children["track"].size(); ++a) {
		Artist *track_artist = new Artist(locutus);
		Track *track = new Track(locutus, this, track_artist);
		/* track data */
		track->mbid = album->children["track-list"][0]->children["track"][a]->children["id"][0]->value;
		track->title = album->children["track-list"][0]->children["track"][a]->children["title"][0]->value;
		track->duration = atoi(album->children["track-list"][0]->children["track"][a]->children["duration"][0]->value.c_str());
		track->tracknumber = a + 1;
		/* track artist data */
		if (album->children["track-list"][0]->children["track"][a]->children["artist"].size() > 0) {
			track_artist->mbid = album->children["track-list"][0]->children["track"][a]->children["artist"][0]->children["id"][0]->value;
			track_artist->name = album->children["track-list"][0]->children["track"][a]->children["artist"][0]->children["name"][0]->value;
			track_artist->sortname = album->children["track-list"][0]->children["track"][a]->children["artist"][0]->children["sort-name"][0]->value;
		} else {
			track_artist->mbid = artist->mbid;
			track_artist->name = artist->name;
			track_artist->sortname = artist->sortname;
		}
		tracks[a] = track;
	}
	return true;
}

bool Album::saveToCache() {
	/* save album to cache */
	if (locutus == NULL)
		return false;
	if (mbid.size() != 36) {
		string msg = "Unable to save album in cache. Illegal MusicBrainz ID: ";
		msg.append(mbid);
		locutus->debug(DEBUG_NOTICE, msg);
		return false;
	}
	string e_artist_mbid = locutus->database->escapeString(artist->mbid);
	string e_mbid = locutus->database->escapeString(mbid);
	string e_title = locutus->database->escapeString(title);
	string e_type = locutus->database->escapeString(type);
	string e_released = locutus->database->escapeString(released);
	if (e_released == "" || released.size() != 10) {
		e_released = "NULL";
	} else {
		string tmp_e_released = e_released;
		e_released = "'";
		e_released.append(tmp_e_released);
		e_released.append("'");
	}
	ostringstream query;
	/* save artist */
	if (!artist->saveToCache())
		locutus->debug(DEBUG_NOTICE, "Failed to save album artist in cache. See errors above");
	/* save album */
	query.str("");
	query << "INSERT INTO album(artist_id, mbid, type, title, released) SELECT (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), '" << e_mbid << "', '" << e_type << "', '" << e_title << "', " << e_released << " WHERE NOT EXISTS (SELECT true FROM album WHERE mbid = '" << e_mbid << "')";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save album in cache, query failed. See error above");
	query.str("");
	query << "UPDATE album SET artist_id = (SELECT artist_id FROM artist WHERE mbid = '" << e_artist_mbid << "'), type = '" << e_type << "', title = '" << e_title << "', released = " << e_released << ", last_updated = now() WHERE mbid = '" << e_mbid << "'";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save album in cache, query failed. See error above");
	/* save tracks */
	bool status = true;
	for (vector<Track *>::iterator track = tracks.begin(); track != tracks.end(); ++track) {
		if (!(*track)->saveToCache())
			status = false;
	}
	if (!status)
		locutus->debug(DEBUG_NOTICE, "One or more album tracks couldn't be saved in cache. See errors above");
	return status;
}
