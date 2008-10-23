#include "Artist.h"
#include "Audioscrobbler.h"
#include "Database.h"
#include "Debug.h"
#include "Metafile.h"

using namespace ost;
using namespace std;

/* constructors/destructor */
Audioscrobbler::Audioscrobbler(Database *database) : database(database) {
	artist_tag_url = database->loadSettingString(AUDIOSCROBBLER_ARTIST_TAG_URL_KEY, AUDIOSCROBBLER_ARTIST_TAG_URL_VALUE, AUDIOSCROBBLER_ARTIST_TAG_URL_DESCRIPTION);
	track_tag_url = database->loadSettingString(AUDIOSCROBBLER_TRACK_TAG_URL_KEY, AUDIOSCROBBLER_TRACK_TAG_URL_VALUE, AUDIOSCROBBLER_TRACK_TAG_URL_DESCRIPTION);
	query_interval = database->loadSettingDouble(AUDIOSCROBBLER_QUERY_INTERVAL_KEY, AUDIOSCROBBLER_QUERY_INTERVAL_VALUE, AUDIOSCROBBLER_QUERY_INTERVAL_DESCRIPTION);
	query_interval *= 1000000.0;
	last_fetch.tv_sec = 0;
	last_fetch.tv_usec = 0;
}

Audioscrobbler::~Audioscrobbler() {
}

/* methods */
const vector<string> &Audioscrobbler::getTags(Metafile *metafile) {
	tags.clear();
	if (metafile == NULL)
		return tags;
	string artist = escapeString(metafile->artist);
	if (artist == "")
		return tags;
	string title = escapeString(metafile->title);
	string url;
	if (title != "") {
		url = track_tag_url;
		url.append(artist);
		url.push_back('/');
		url.append(title);
		url.append("/toptags.xml");
		if (parseXML(lookup(url)))
			return tags;
	}
	/* we didn't find any tags with given artist & track.
	 * let's try artist only */
	url = artist_tag_url;
	url.append(artist);
	url.append("/toptags.xml");
	parseXML(lookup(url));
	return tags;
}

/* private methods */
string Audioscrobbler::escapeString(const string &text) {
	/* escape certain characters that mess up the url:
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
				str << "%26";
				break;

			case '+':
				str << "%2b";
				break;

			case ',':
				str << "%2c";
				break;

			case '/':
				str << "%2f";
				break;

			case ':':
				str << "%3a";
				break;

			case ';':
				str << "%3b";
				break;

			case '=':
				str << "%3d";
				break;

			case '?':
				str << "%3f";
				break;

			case '@':
				str << "%40";
				break;

			default:
				str << c;
				break;
		}
	}
	return str.str();
}

XMLNode *Audioscrobbler::lookup(const std::string &url) {
	/* usleep if last fetch was less than a second ago */
	struct timeval tv;
	if (gettimeofday(&tv, NULL) == 0) {
		long msec_since_last = (last_fetch.tv_sec - tv.tv_sec) * 1000000;
		msec_since_last += last_fetch.tv_usec - tv.tv_usec;
		msec_since_last += query_interval;
		if (msec_since_last > 0 && msec_since_last < query_interval) {
			ostringstream tmp;
			tmp << "Sleeping " << msec_since_last << "µs to avoid hammering Audioscrobbler";
			Debug::info(tmp.str());
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

bool Audioscrobbler::parseXML(XMLNode *root) {
	if (root == NULL || root->children["toptags"].size() <= 0)
		return false;
	XMLNode *cur = root->children["toptags"][0];
	if (cur->children["tag"].size() <= 0)
		return false;
	for (vector<XMLNode *>::size_type a = 0; a < cur->children["tag"].size(); ++a) {
		if (cur->children["tag"][a]->children["name"].size() > 0)
			tags.push_back(cur->children["tag"][a]->children["name"][0]->value);
	}
	return true;
}
