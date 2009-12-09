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

#ifndef COMPARISON_H
#define COMPARISON_H

class Metafile;
class Track;

class Comparison {
public:
	Metafile *metafile;
	Track *track;
	bool mbid_match;
	double score;
	double total_score;

	Comparison(Metafile *metafile, Track *track, bool mbid_match, double score);
};
#endif
