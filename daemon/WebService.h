#ifndef WEBSERVICE_H
/* defines */
#define WEBSERVICE_H
/* settings */
#define METADATA_SEARCH_URL_KEY "metadata_search_url"
#define METADATA_SEARCH_URL_VALUE "http://musicbrainz.org/ws/1/track/"
#define METADATA_SEARCH_URL_DESCRIPTION "URL to search after metadata"
#define RELEASE_LOOKUP_URL_KEY "release_url"
#define RELEASE_LOOKUP_URL_VALUE "http://musicbrainz.org/ws/1/release/"
#define RELEASE_LOOKUP_URL_DESCRIPTION "URL to lookup a release"

/* forward declare */
class WebService;

/* includes */
#include <cc++/common.h>
#include <map>
#include <string>
#include <vector>
#include "Album.h"
#include "Locutus.h"
#include "Metatrack.h"
#include "XMLNode.h"

/* namespaces */
using namespace ost;
using namespace std;

/* WebService */
class WebService : public URLStream, public XMLStream {
	public:
		/* variables */

		/* constructors */
		WebService(Locutus *locutus);

		/* destructors */
		~WebService();

		/* methods */
		void loadSettings();
		XMLNode *lookupAlbum(const string &mbid);
		vector<Metatrack> *searchMetadata(const string &wsquery);
		vector<Metatrack> *searchPUID(const string &puid);

	private:
		/* variables */
		Locutus *locutus;
		vector<Metatrack> *tracks;
		URLStream::Error status;
		string metadata_search_url;
		string release_lookup_url;
		XMLNode *root;
		XMLNode *curnode;

		/* methods */
		void characters(const unsigned char *text, size_t len);
		void close();
		void endElement(const unsigned char *name);
		bool fetch(const char *url);
		void printXML(XMLNode *startnode, int indent) const;
		int read(unsigned char *buffer, size_t len);
		void startElement(const unsigned char *name, const unsigned char **attr);
};
#endif
