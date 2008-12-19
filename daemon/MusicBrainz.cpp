#include "Album.h"
#include "Database.h"
#include "Debug.h"
#include "Metafile.h"
#include "MusicBrainz.h"

using namespace ost;
using namespace std;

/* constructors/destructor */
MusicBrainz::MusicBrainz(Database *database) : database(database) {
	metadata_search_url = database->loadSettingString(METADATA_SEARCH_URL_KEY, METADATA_SEARCH_URL_VALUE, METADATA_SEARCH_URL_DESCRIPTION);
	release_lookup_url = database->loadSettingString(RELEASE_LOOKUP_URL_KEY, RELEASE_LOOKUP_URL_VALUE, RELEASE_LOOKUP_URL_DESCRIPTION);
	query_interval = database->loadSettingDouble(MUSICBRAINZ_QUERY_INTERVAL_KEY, MUSICBRAINZ_QUERY_INTERVAL_VALUE, MUSICBRAINZ_QUERY_INTERVAL_DESCRIPTION);
	query_interval *= 1000000.0;
	last_fetch.tv_sec = 0;
	last_fetch.tv_usec = 0;
}

MusicBrainz::~MusicBrainz() {
}

/* methods */
bool MusicBrainz::lookupAlbum(Album *album) {
	if (album == NULL || album->mbid.size() != 36 || album->mbid[8] != '-' || album->mbid[13] != '-' || album->mbid[18] != '-' || album->mbid[23] != '-')
		return false;
	string url = release_lookup_url;
	url.append(album->mbid);
	url.append("?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels");
	XMLNode *root = lookup(url);
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
	ostringstream query;
	string bnwe = escapeString(metafile.getBaseNameWithoutExtension());
	query << "limit=25&query=";
	query << "tnum:(" << escapeString(metafile.tracknumber) << " " << bnwe << ") ";
	if (metafile.duration > 0) {
		int lower = metafile.duration / 1000 - 10;
		int upper = metafile.duration / 1000 + 10;
		if (lower < 0)
			lower = 0;
		query << "qdur:[" << lower << " TO " << upper << "] ";
	}
	query << "artist:(" << escapeString(metafile.artist) << " " << bnwe << ") ";
	query << "track:(" << escapeString(metafile.title) << " " << bnwe << " " << ") ";
	query << "release:(" << escapeString(metafile.album) << " " << bnwe << ") ";
	return searchMetadata(query.str());
}

const vector<Metatrack> &MusicBrainz::searchPUID(const string &puid) {
	tracks.clear();
	if (puid.size() != 36)
		return tracks;
	string query = "puid=";
	query.append(puid);
	return searchMetadata(query);
}

/* private methods */
string MusicBrainz::escapeString(const string &text) {
	/* escape these characters:
	 * + - && || ! ( ) { } [ ] ^ " ~ * ? : \ */
	/* also change "_" to " " */
	/* remember these suckers too:
	 * "$": %24
         * "&": %26
         * "+": %2b
         * ",": %2c
         * "/": %2f
         * ":": %3a
         * ";": %3b
         * "=": %3d
         * "?": %3f
         * "@": %40 */

	ostringstream str;
	for (string::size_type a = 0; a < text.size(); ++a) {
		char c = text[a];
		switch (c) {
			case '$':
				str << "%24";
				break;

			case '&':
				if (a + 1 < text.size() && text[a + 1] == c)
					str << "\\%26";
				else
					str << "%26";
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

			case ';':
				str << "%3b";
				break;

			case '=':
				str << "%3d";
				break;

			case '?':
				str << "\\%3f";
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

XMLNode *MusicBrainz::lookup(const std::string &url) {
	/* usleep if last fetch was less than a second ago */
	struct timeval tv;
	if (gettimeofday(&tv, NULL) == 0) {
		long msec_since_last = (last_fetch.tv_sec - tv.tv_sec) * 1000000;
		msec_since_last += last_fetch.tv_usec - tv.tv_usec;
		msec_since_last += query_interval;
		if (msec_since_last > 0 && msec_since_last < query_interval) {
			Debug::info() << "Sleeping " << msec_since_last << "µs to avoid hammering MusicBrainz" << endl;
			usleep(msec_since_last);
		}
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
	return fetch(url.c_str());
}

const vector<Metatrack> &MusicBrainz::searchMetadata(const string &query) {
	tracks.clear();
	if (query == "")
		return tracks;
	string url = metadata_search_url;
	url.append("?type=xml&");
	url.append(query);
	XMLNode *root = lookup(url);
	if (root != NULL && root->children["metadata"].size() > 0 && root->children["metadata"][0]->children["track-list"].size() > 0) {
		for (vector<XMLNode *>::size_type a = 0; a < root->children["metadata"][0]->children["track-list"][0]->children["track"].size(); ++a) {
			if (getMetatrack(root->children["metadata"][0]->children["track-list"][0]->children["track"][a]))
				tracks.push_back(metatrack);
		}
	}
	return tracks;
}
