// Copyright © 2008-2009 Vidar Wahlberg <canidae@exent.net>
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

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
	explicit Audioscrobbler(Database* database);

	const std::vector<std::string>& getTags(const Metafile& metafile);

private:
	Database* database;
	std::string artist_tag_url;
	std::string track_tag_url;
	std::vector<std::string> tags;
	double query_interval;
	struct timeval last_fetch;

	std::string escapeString(const std::string& text);
	XMLNode* lookup(const std::string& url);
	bool parseXML(XMLNode* root);
};
#endif
