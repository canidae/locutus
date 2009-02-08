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

#include "Comparison.h"

using namespace std;

/* constructors/destructor */
Comparison::Comparison(Metafile *metafile, Track *track, bool mbid_match, bool puid_match, double score) : metafile(metafile), track(track), mbid_match(mbid_match), puid_match(puid_match), score(score), total_score(score * (mbid_match ? 3 : (puid_match ? 2 : 1))) {
}

Comparison::~Comparison() {
}
