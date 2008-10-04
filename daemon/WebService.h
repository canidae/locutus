#ifndef WEBSERVICE_H
#define WEBSERVICE_H
/* settings */
#define METADATA_SEARCH_URL_KEY "metadata_search_url"
#define METADATA_SEARCH_URL_VALUE "http://musicbrainz.org/ws/1/track/"
#define METADATA_SEARCH_URL_DESCRIPTION "URL to search after metadata"
#define RELEASE_LOOKUP_URL_KEY "release_url"
#define RELEASE_LOOKUP_URL_VALUE "http://musicbrainz.org/ws/1/release/"
#define RELEASE_LOOKUP_URL_DESCRIPTION "URL to lookup a release"

#include <cc++/common.h>
#include <map>
#include <string>
#include <vector>
#include "Metatrack.h"

struct XMLNode {
	XMLNode *parent;
	std::map<std::string, std::vector<XMLNode *> > children;
	std::string key;
	std::string value;
};

class Album;
class Database;
class Metafile;

class WebService : public ost::URLStream, public ost::XMLStream {
	public:
		explicit WebService(Database *database);
		~WebService();

		bool lookupAlbum(Album *album);
		const std::vector<Metatrack> &searchMetadata(const std::string &group, const Metafile &metafile);
		const std::vector<Metatrack> &searchPUID(const std::string &puid);

	private:
		Database *database;
		Metatrack metatrack;
		URLStream::Error status;
		XMLNode *root;
		XMLNode *curnode;
		std::string metadata_search_url;
		std::string release_lookup_url;
		std::vector<Metatrack> tracks;

		void characters(const unsigned char *text, size_t len);
		void clearXMLNode(XMLNode *node);
		void close();
		void endElement(const unsigned char *name);
		std::string escapeString(const std::string &text);
		bool fetch(const char *url);
		bool getMetatrack(XMLNode *track);
		void printXML(XMLNode *startnode, int indent) const;
		int read(unsigned char *buffer, size_t len);
		const std::vector<Metatrack> &searchMetadata(const std::string &query);
		void startElement(const unsigned char *name, const unsigned char **attr);
};
#endif
