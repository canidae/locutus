#ifndef AUDIOSCROBBLER_H
#define AUDIOSCROBBLER_H
/* settings */
#define AUDIOSCROBBLER_ARTIST_TAG_URL_KEY "audioscrobbler_artist_tag_url"
#define AUDIOSCROBBLER_ARTIST_TAG_URL_VALUE "http://ws.audioscrobbler.com/1.0/artist/" // Metallica/toptags.xml
#define AUDIOSCROBBLER_ARTIST_TAG_URL_DESCRIPTION "URL to lookup tags for an artist (fallback when no tag is found for track)"
#define AUDIOSCROBBLER_QUERY_INTERVAL_KEY "audioscrobbler_query_interval"
#define AUDIOSCROBBLER_QUERY_INTERVAL_VALUE 3.0
#define AUDIOSCROBBLER_QUERY_INTERVAL_DESCRIPTION "Amount of seconds between each query to Audioscrobbler WebService. Value must be 1.0 or above"
#define AUDIOSCROBBLER_TRACK_TAG_URL_KEY "audioscrobbler_track_tag_url"
#define AUDIOSCROBBLER_TRACK_TAG_URL_VALUE "http://ws.audioscrobbler.com/1.0/track/" // Metallica/Enter%20Sandman/toptags.xml
#define AUDIOSCROBBLER_TRACK_TAG_URL_DESCRIPTION "URL to lookup tags for a track"

#include <string>
#include <sys/time.h>
#include <time.h>
#include <vector>
#include "WebService.h"

class Database;
class Track;

class Audioscrobbler : public WebService {
	public:
		explicit Audioscrobbler(Database *database);
		~Audioscrobbler();

		const std::vector<std::string> &getTags(Track *track);

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
