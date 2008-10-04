#include "Metatrack.h"

using namespace std;

/* constructors/destructor */
Metatrack::Metatrack() : duration(0), tracknumber(0), album_mbid(""), album_title(""), artist_mbid(""), artist_name(""), puid(""), track_mbid(""), track_title("") {
}

Metatrack::~Metatrack() {
}
