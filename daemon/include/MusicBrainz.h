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
