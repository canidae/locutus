#include "Metatrack.h"

using namespace std;

/* constructors/destructor */
Metatrack::Metatrack(int duration, int tracknumber, string album_mbid, string album_title, string artist_mbid, string artist_name, string puid, string track_mbid, string track_title) : duration(duration), tracknumber(tracknumber), album_mbid(album_mbid), album_title(album_title), artist_mbid(artist_mbid), artist_name(artist_name), puid(puid), track_mbid(track_mbid), track_title(track_title) {
}

Metatrack::~Metatrack() {
}
