#include "Metatrack.h"

using namespace std;

/* constructors/destructor */
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

Metatrack::~Metatrack() {
}
