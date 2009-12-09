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

#ifndef AUDIOSCROBBLER_H
#define AUDIOSCROBBLER_H

#include <string>
#include <sys/time.h>
#include <time.h>
#include <vector>
#include "WebService.h"

/* settings */
#define AUDIOSCROBBLER_ARTIST_TAG_URL_KEY "audioscrobbler_artist_tag_url"
#define AUDIOSCROBBLER_ARTIST_TAG_URL_VALUE "http://ws.audioscrobbler.com/1.0/artist/" // Metallica/toptags.xml
#define AUDIOSCROBBLER_ARTIST_TAG_URL_DESCRIPTION "URL to lookup tags for an artist (fallback when no tag is found for track)."
#define AUDIOSCROBBLER_QUERY_INTERVAL_KEY "audioscrobbler_query_interval"
#define AUDIOSCROBBLER_QUERY_INTERVAL_VALUE 3.0
#define AUDIOSCROBBLER_QUERY_INTERVAL_DESCRIPTION "Amount of seconds between each query to Audioscrobbler WebService. Value must be 1.0 or above."
#define AUDIOSCROBBLER_TRACK_TAG_URL_KEY "audioscrobbler_track_tag_url"
#define AUDIOSCROBBLER_TRACK_TAG_URL_VALUE "http://ws.audioscrobbler.com/1.0/track/" // Metallica/Enter%20Sandman/toptags.xml
#define AUDIOSCROBBLER_TRACK_TAG_URL_DESCRIPTION "URL to lookup tags for a track."

class Database;
class Metafile;

class Audioscrobbler : public WebService {
public:
	explicit Audioscrobbler(Database *database);

	const std::vector<std::string> &getTags(const Metafile &metafile);

private:
	Database *database;
	std::string artist_tag_url;
	std::string track_tag_url;
	std::vector<std::string> tags;
	double query_interval;
	struct timeval last_fetch;

	std::string escapeString(const std::string &text);
	XMLNode *lookup(const std::string &url);
	bool parseXML(XMLNode *root);
};
#endif
