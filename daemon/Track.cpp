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

#include "Album.h"
#include "Artist.h"
#include "Track.h"

using namespace std;

Track::Track(Album *album) : album(album), artist(new Artist()), duration(0), tracknumber(0), mbid(""), title("") {
}

Track::~Track() {
	delete artist;
}

Metatrack Track::getAsMetatrack() const {
	if (album == NULL || artist == NULL)
		return Metatrack();
	return Metatrack(duration, tracknumber, album->mbid, album->title, artist->mbid, artist->name, mbid, title);
}
