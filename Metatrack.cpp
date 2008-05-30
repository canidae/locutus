#include "Metatrack.h"

/* constructors */
Metatrack::Metatrack(Locutus *locutus) {
	this->locutus = locutus;
	duration = 0;
	tracknumber = 0;
	track_mbid = "";
	track_title = "";
	artist_mbid = "";
	artist_name = "";
	album_mbid = "";
	album_title = "";
}

/* destructors */
Metatrack::~Metatrack() {
}

/* methods */
bool Metatrack::loadFromXML(XMLNode *track) {
	track_mbid = track->children["id"][0]->value;
	track_title = track->children["title"][0]->value;
	if (track->children["duration"].size() > 0)
		duration = atoi(track->children["duration"][0]->value.c_str());
	artist_mbid = track->children["artist"][0]->children["id"][0]->value;
	artist_name = track->children["artist"][0]->children["name"][0]->value;
	album_mbid = track->children["release-list"][0]->children["release"][0]->children["id"][0]->value;
	album_title = track->children["release-list"][0]->children["release"][0]->children["title"][0]->value;
	string offset = track->children["release-list"][0]->children["release"][0]->children["track-list"][0]->children["offset"][0]->value;
	tracknumber = atoi(offset.c_str()) + 1;
	return true;
}

bool Metatrack::saveToCache() {
	if (track_mbid.size() != 36) {
		locutus->debug(DEBUG_NOTICE, "Won't save metatrack in cache, missing MBIDs");
		return false;
	}
	string e_track_mbid = locutus->database->escapeString(track_mbid);
	string e_track_title = locutus->database->escapeString(track_title);
	string e_artist_mbid = locutus->database->escapeString(artist_mbid);
	string e_artist_name = locutus->database->escapeString(artist_name);
	string e_album_mbid = locutus->database->escapeString(album_mbid);
	string e_album_title = locutus->database->escapeString(album_title);
	ostringstream query;
	query << "DELETE FROM metatrack WHERE track_mbid = '" << e_track_mbid << "'";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to delete from metatrack, query failed. See error above");
	query.str("");
	query << "INSERT INTO metatrack(track_mbid, track_title, duration, tracknumber, artist_mbid, artist_name, album_mbid, album_title) VALUES ('" << e_track_mbid << "', '" << e_track_title << "', " << duration << ", " << tracknumber << ", '" << e_artist_mbid << "', '" << e_artist_name << "', '" << e_album_mbid << "', '" << e_album_title << "')";
	if (!locutus->database->query(query.str()))
		locutus->debug(DEBUG_NOTICE, "Unable to save metatrack, query failed. See error above");
	return true;
}
