#include "Metatrack.h"

/* constructors */
Metatrack::Metatrack() {
	duration = 0;
	tracknumber = 0;
	track_mbid = "";
	track_title = "";
	artist_mbid = "";
	artist_name = "";
	album_mbid = "";
	album_title = "";
	puid = "";
}

/* destructors */
Metatrack::~Metatrack() {
}

/* methods */
bool Metatrack::readFromXML(XMLNode *track) {
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
