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

#ifndef MUSICBRAINZ_H
#define MUSICBRAINZ_H

#include <string>
#include <sys/time.h>
#include <time.h>
#include <vector>
#include "Metatrack.h"
#include "WebService.h"

/* settings */
#define MUSICBRAINZ_SEARCH_URL_KEY "musicbrainz_search_url"
#define MUSICBRAINZ_SEARCH_URL_VALUE "http://musicbrainz.org/ws/1/track/"
#define MUSICBRAINZ_SEARCH_URL_DESCRIPTION "URL to search after metadata."
#define MUSICBRAINZ_QUERY_INTERVAL_KEY "musicbrainz_query_interval"
#define MUSICBRAINZ_QUERY_INTERVAL_VALUE 3.0
#define MUSICBRAINZ_QUERY_INTERVAL_DESCRIPTION "Amount of seconds between each query to MusicBrainz WebService. Value must be 1.0 or above."
#define MUSICBRAINZ_RELEASE_URL_KEY "musicbrainz_release_url"
#define MUSICBRAINZ_RELEASE_URL_VALUE "http://musicbrainz.org/ws/1/release/"
#define MUSICBRAINZ_RELEASE_URL_DESCRIPTION "URL to lookup a release."

class Album;
class Database;
class Metafile;

class MusicBrainz : public WebService {
public:
	explicit MusicBrainz(Database *database);

	bool lookupAlbum(Album *album);
	const std::vector<Metatrack> &searchMetadata(const Metafile &metafile);

private:
	Database *database;
	Metatrack metatrack;
	std::string metadata_search_url;
	std::string release_lookup_url;
	std::vector<Metatrack> tracks;
	double query_interval;
	struct timeval last_fetch;

	std::string escapeString(const std::string &text);
	bool getMetatrack(XMLNode *track);
	XMLNode *lookup(const std::string &url, const std::vector<std::string> args);
};
#endif
