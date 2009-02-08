// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
// 
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
// more details.
// 
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

#include "Metatrack.h"

using namespace std;

/* constructors/destructor */
Metatrack::Metatrack(int duration, int tracknumber, string album_mbid, string album_title, string artist_mbid, string artist_name, string puid, string track_mbid, string track_title) : duration(duration), tracknumber(tracknumber), album_mbid(album_mbid), album_title(album_title), artist_mbid(artist_mbid), artist_name(artist_name), puid(puid), track_mbid(track_mbid), track_title(track_title) {
}

Metatrack::~Metatrack() {
}
