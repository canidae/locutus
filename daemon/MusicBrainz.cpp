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

#include <stdlib.h>
#include "Album.h"
#include "Artist.h"
#include "Database.h"
#include "Locutus.h"
#include "Metafile.h"
#include "MusicBrainz.h"
#include "Track.h"

using namespace ost;
using namespace std;

MusicBrainz::MusicBrainz(Database *database) : database(database) {
	metadata_search_url = database->loadSettingString(METADATA_SEARCH_URL_KEY, METADATA_SEARCH_URL_VALUE, METADATA_SEARCH_URL_DESCRIPTION);
	release_lookup_url = database->loadSettingString(RELEASE_LOOKUP_URL_KEY, RELEASE_LOOKUP_URL_VALUE, RELEASE_LOOKUP_URL_DESCRIPTION);
	query_interval = database->loadSettingDouble(MUSICBRAINZ_QUERY_INTERVAL_KEY, MUSICBRAINZ_QUERY_INTERVAL_VALUE, MUSICBRAINZ_QUERY_INTERVAL_DESCRIPTION);
	if (query_interval <= 0.0)
		query_interval = 1.0;
	query_interval *= 1000000.0;
	last_fetch.tv_sec = 0;
	last_fetch.tv_usec = 0;
}

bool MusicBrainz::lookupAlbum(Album *album) {
	if (album == NULL || album->mbid.size() != 36 || album->mbid[8] != '-' || album->mbid[13] != '-' || album->mbid[18] != '-' || album->mbid[23] != '-')
		return false;
	string url = release_lookup_url;
	url.append(album->mbid);
	vector<string> args;
	args.push_back("type=xml");
	args.push_back("inc=tracks+artist+release-events+labels+artist-rels+url-rels");
	XMLNode *root = lookup(url, args);
	if (root == NULL)
		return false;
	/* album data */
	if (root->children["metadata"].size() <= 0 || root->children["metadata"][0]->children["release"].size() <= 0)
		return false;
	XMLNode *tmp = root->children["metadata"][0]->children["release"][0];
	album->mbid = (tmp->children["id"].size() > 0) ? tmp->children["id"][0]->value : "";
	album->type = (tmp->children["type"].size() > 0) ? tmp->children["type"][0]->value : "";
	album->title = (tmp->children["title"].size() > 0) ? tmp->children["title"][0]->value : "";
	if (tmp->children["release-event-list"].size() > 0 && tmp->children["release-event-list"][0]->children["event"].size() > 0 && tmp->children["release-event-list"][0]->children["event"][0]->children["date"].size() > 0) {
		album->released = tmp->children["release-event-list"][0]->children["event"][0]->children["date"][0]->value;
		if (album->released.size() == 10 && album->released[4] == '-' && album->released[7] == '-') {
			/* ok as it is, probably a valid date */
		} else if (album->released.size() == 4) {
			/* only year, make month & day 01 */
			album->released.append("-01-01");
		} else {
			/* possibly not a valid date, ignore it */
			album->released = "";
		}
	}
	/* artist data */
	if (tmp->children["artist"].size() <= 0)
		return false;
	XMLNode *tmp2 = tmp->children["artist"][0];
	album->artist->mbid = (tmp2->children["id"].size() > 0) ? tmp2->children["id"][0]->value : "";
	album->artist->name = (tmp2->children["name"].size() > 0) ? tmp2->children["name"][0]->value : "";
	album->artist->sortname = (tmp2->children["sort-name"].size() > 0) ? tmp2->children["sort-name"][0]->value : "";
	/* track data */
	if (tmp->children["track-list"].size() <= 0 || tmp->children["track-list"][0]->children["track"].size() <= 0)
		return false;
	tmp = tmp->children["track-list"][0];
	album->tracks.resize(tmp->children["track"].size());
	for (vector<XMLNode *>::size_type a = 0; a < tmp->children["track"].size(); ++a) {
		/* track data */
		album->tracks[a] = new Track(album);
		tmp2 = tmp->children["track"][a];
		album->tracks[a]->mbid = (tmp2->children["id"].size() > 0) ? tmp2->children["id"][0]->value : "";
		album->tracks[a]->title = (tmp2->children["title"].size() > 0) ? tmp2->children["title"][0]->value : "";
		album->tracks[a]->duration = (tmp2->children["duration"].size() > 0) ? atoi(tmp2->children["duration"][0]->value.c_str()) : 0;
		album->tracks[a]->tracknumber = a + 1;
		/* track artist data */
		if (tmp2->children["artist"].size() > 0) {
			tmp2 = tmp2->children["artist"][0];
			album->tracks[a]->artist->mbid = (tmp2->children["id"].size() > 0) ? tmp2->children["id"][0]->value : "";
			album->tracks[a]->artist->name = (tmp2->children["name"].size() > 0) ? tmp2->children["name"][0]->value : "";
			album->tracks[a]->artist->sortname = (tmp2->children["sort-name"].size() > 0) ? tmp2->children["sort-name"][0]->value : "";
		} else {
			album->tracks[a]->artist->mbid = album->artist->mbid;
			album->tracks[a]->artist->name = album->artist->name;
			album->tracks[a]->artist->sortname = album->artist->sortname;
		}
	}
	return true;
}

const vector<Metatrack> &MusicBrainz::searchMetadata(const Metafile &metafile) {
	/* do a track search */
	/* first extract useful data from filename */
	string extra = metafile.filename;
	/* we don't want our input/output/duplicate directory, that's just noise */
	if (extra.find(Locutus::input_dir) != string::npos)
		extra.erase(0, Locutus::input_dir.size());
	else if (extra.find(Locutus::output_dir) != string::npos)
		extra.erase(0, Locutus::output_dir.size());
	else if (extra.find(Locutus::duplicate_dir) != string::npos)
		extra.erase(0, Locutus::duplicate_dir.size());
	/* nor do we want the extension, that's also noise */
	string::size_type pos = extra.find_last_of('.');
	if (pos != string::npos)
		extra.erase(pos);
	/* then replace "/" with " " */
	while ((pos = extra.find_first_of('/')) != string::npos)
		extra.replace(pos, 1, " ");
	/* and finally escape the string */
	extra = escapeString(extra);

	/* tracknumber and track title are most likely not in a directory name,
	 * it's more likely that these can be found in the basename */
	string bwe = metafile.getBasenameWithoutExtension();
	string tracknum = "";
	bool last_was_num = false;
	for (int a = 0; a < (int)bwe.size(); ++a) {
		if (bwe[a] >= '0' && bwe[a] <= '9') {
			if (!last_was_num)
				tracknum.append(1, ' ');
			tracknum.append(1, bwe[a]);
			last_was_num = true;
		} else {
			last_was_num = false;
		}
	}
	/* escape bwe */
	bwe = escapeString(bwe);

	/* build the query */
	ostringstream query;
	string tnum = escapeString(metafile.tracknumber);
	tnum.append(tracknum); // no need for " " before tracknum, it already got a space
	if (tnum.size() > 0)
		query << "tnum:(" << tnum << ") ";
	if (metafile.duration > 0) {
		int lower = metafile.duration / 1000 - 10;
		int upper = metafile.duration / 1000 + 10;
		if (lower < 0)
			lower = 0;
		query << "qdur:[" << lower << " TO " << upper << "] ";
	}
	string artist = escapeString(metafile.artist);
	artist.append(1, ' ');
	artist.append(extra);
	if (artist.size() > 0)
		query << "artist:(" << artist << ") ";
	string track = escapeString(metafile.title);
	track.append(1, ' ');
	track.append(bwe);
	if (track.size() > 0)
		query << "track:(" << track << ") ";
	string release = escapeString(metafile.album);
	release.append(1, ' ');
	release.append(extra);
	if (release.size() > 0)
		query << "release:(" << release << ")";

	tracks.clear();
	if (query.str() == "")
		return tracks;
	vector<string> args;
	args.push_back("type=xml");
	args.push_back("limit=25");
	char *c_query = new char[CHAR_BUFFER];
	urlEncode(query.str().c_str(), c_query, CHAR_BUFFER);
	query.str("");
	query << "query=" << c_query;
	delete [] c_query;
	args.push_back(query.str());
	XMLNode *root = lookup(metadata_search_url, args);
	if (root != NULL && root->children["metadata"].size() > 0 && root->children["metadata"][0]->children["track-list"].size() > 0) {
		for (vector<XMLNode *>::size_type a = 0; a < root->children["metadata"][0]->children["track-list"][0]->children["track"].size(); ++a) {
			if (getMetatrack(root->children["metadata"][0]->children["track-list"][0]->children["track"][a]))
				tracks.push_back(metatrack);
		}
	}
	return tracks;
}

string MusicBrainz::escapeString(const string &text) {
	/* escape these characters:
	 * + - || ! ( ) { } [ ] ^ " ~ * : \ */
	/* also change "_", "?", ";", "&" and "#" to " " */
	/* remember these suckers too:
	 * "$": %24
	 * "+": %2b
	 * ",": %2c
	 * "/": %2f
	 * ":": %3a
	 * "=": %3d
	 * "@": %40 */

	ostringstream str;
	for (string::size_type a = 0; a < text.size(); ++a) {
		char c = text[a];
		switch (c) {
			case '$':
				str << "%24";
				break;

			case '+':
				str << "\\%2b";
				break;

			case ',':
				str << "%2c";
				break;

			case '/':
				str << "%2f";
				break;

			case ':':
				str << "\\%3a";
				break;

			case '=':
				str << "%3d";
				break;

			case '@':
				str << "%40";
				break;


			case '-':
			case '!':
			case '(':
			case ')':
			case '{':
			case '}':
			case '[':
			case ']':
			case '^':
			case '"':
			case '~':
			case '*':
			case '\\':
				str << '\\' << c;
				break;

			case '|':
				if (a + 1 < text.size() && text[a + 1] == c)
					str << '\\';
				str << c;
				break;

			case '_':
			case '?':
			case ';':
			case '&':
			case '#':
				str << ' ';
				break;

			default:
				str << c;
				break;
		}
	}
	return str.str();
}

bool MusicBrainz::getMetatrack(XMLNode *track) {
	if (track == NULL)
		return false;
	metatrack.track_mbid = (track->children["id"].size() > 0) ? track->children["id"][0]->value : "";
	metatrack.track_title = (track->children["title"].size() > 0) ? track->children["title"][0]->value : "";
	metatrack.duration = (track->children["duration"].size() > 0) ? atoi(track->children["duration"][0]->value.c_str()) : 0;
	if (track->children["artist"].size() <= 0) {
		metatrack.artist_mbid = "";
		metatrack.artist_name = "";
		metatrack.album_mbid = "";
		metatrack.album_title = "";
		metatrack.tracknumber = 0;
		return false;
	}
	XMLNode *tmp = track->children["artist"][0];
	metatrack.artist_mbid = (tmp->children["id"].size() > 0) ? tmp->children["id"][0]->value : "";
	metatrack.artist_name = (tmp->children["name"].size() > 0) ? tmp->children["name"][0]->value : "";
	if (track->children["release-list"].size() <= 0 || track->children["release-list"][0]->children["release"].size() <= 0) {
		metatrack.album_mbid = "";
		metatrack.album_title = "";
		metatrack.tracknumber = 0;
		return false;
	}
	tmp = track->children["release-list"][0]->children["release"][0];
	metatrack.album_mbid = (tmp->children["id"].size() > 0) ? tmp->children["id"][0]->value : "";
	metatrack.album_title = (tmp->children["title"].size() > 0) ? tmp->children["title"][0]->value : "";
	metatrack.tracknumber = (tmp->children["track-list"].size() > 0 && tmp->children["track-list"][0]->children["offset"].size() > 0) ? atoi(tmp->children["track-list"][0]->children["offset"][0]->value.c_str()) + 1: 0;
	return true;
}

XMLNode *MusicBrainz::lookup(const string &url, const vector<string> args) {
	/* usleep if last fetch was less than a second ago */
	struct timeval tv;
	if (gettimeofday(&tv, NULL) == 0) {
		long msec_since_last = (last_fetch.tv_sec - tv.tv_sec) * 1000000;
		msec_since_last += last_fetch.tv_usec - tv.tv_usec;
		msec_since_last += query_interval;
		if (msec_since_last > 0 && msec_since_last < query_interval)
			usleep(msec_since_last);
		if (gettimeofday(&last_fetch, NULL) != 0) {
			/* whaat? */
			last_fetch.tv_sec = tv.tv_sec + 3;
			last_fetch.tv_usec = tv.tv_usec;
		}
	} else {
		/* gettimeofday() failed?
		 * that was unexpected. let's sleep some seconds instead */
		sleep(3);
	}
	const char *c_args[args.size() + 1];
	for (int a = 0; a < (int) args.size(); ++a)
		c_args[a] = args[a].c_str();
	c_args[args.size()] = NULL;
	return fetch(url.c_str(), c_args);
}
