#ifndef MUSICBRAINZ_H
#define MUSICBRAINZ_H
/* settings */
#define METADATA_SEARCH_URL_KEY "metadata_search_url"
#define METADATA_SEARCH_URL_VALUE "http://musicbrainz.org/ws/1/track/"
#define METADATA_SEARCH_URL_DESCRIPTION "URL to search after metadata"
#define MUSICBRAINZ_QUERY_INTERVAL_KEY "musicbrainz_query_interval"
#define MUSICBRAINZ_QUERY_INTERVAL_VALUE 3.0
#define MUSICBRAINZ_QUERY_INTERVAL_DESCRIPTION "Amount of seconds between each query to MusicBrainz WebService. Value must be 1.0 or above"
#define RELEASE_LOOKUP_URL_KEY "release_url"
#define RELEASE_LOOKUP_URL_VALUE "http://musicbrainz.org/ws/1/release/"
#define RELEASE_LOOKUP_URL_DESCRIPTION "URL to lookup a release"

#include <string>
#include <sys/time.h>
#include <time.h>
#include <vector>
#include "Metatrack.h"
#include "WebService.h"

class Album;
class Database;
class Metafile;

class MusicBrainz : public WebService {
	public:
		explicit MusicBrainz(Database *database);
		~MusicBrainz();

		bool lookupAlbum(Album *album);
		const std::vector<Metatrack> &searchMetadata(const std::string &group, const Metafile &metafile);
		const std::vector<Metatrack> &searchPUID(const std::string &puid);

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
		XMLNode *lookup(const std::string &url);
		const std::vector<Metatrack> &searchMetadata(const std::string &query);
};
#endif
