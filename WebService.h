#ifndef WEBSERVICE_H
/* defines */
#define WEBSERVICE_H
/* settings */
#define WEBSERVICE_CLASS "WebService"
#define WEBSERVICE_CLASS_DESCRIPTION "Settings for looking up data on a WebService"
#define METADATA_SEARCH_URL_KEY "metadata_search_url"
#define METADATA_SEARCH_URL_VALUE "http://musicbrainz.org/ws/1/track/"
#define METADATA_SEARCH_URL_DESCRIPTION "URL to search after metadata"
#define RELEASE_LOOKUP_URL_KEY "release_url"
#define RELEASE_LOOKUP_URL_VALUE "http://musicbrainz.org/ws/1/release/"
#define RELEASE_LOOKUP_URL_DESCRIPTION "URL to lookup a release"
#define ALBUM_CACHE_LIFETIME_KEY "album_cache_lifetime"
#define ALBUM_CACHE_LIFETIME_VALUE 3
#define ALBUM_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."
#define PUID_CACHE_LIFETIME_KEY "puid_cache_lifetime"
#define PUID_CACHE_LIFETIME_VALUE 3
#define PUID_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since puid was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."

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
		string metadata_search_url;
		string release_lookup_url;

		/* constructors */
		WebService(Locutus *locutus);

		/* destructors */
		~WebService();

		/* methods */
		void loadSettings();
		XMLNode *lookupAlbum(string mbid);
		vector<Metatrack> *searchMetadata(string wsquery);
		vector<Metatrack> *searchPUID(string puid);
		/* old */
		void cleanCache();

	private:
		/* variables */
		Locutus *locutus;
		vector<Metatrack> *tracks;
		URLStream::Error status;
		int setting_class_id;
		int album_cache_lifetime;
		int puid_cache_lifetime;
		XMLNode *root;
		XMLNode *curnode;

		/* methods */
		void characters(const unsigned char *text, size_t len);
		void close();
		void deleteTree(XMLNode *node);
		void endElement(const unsigned char *name);
		bool fetch(const char *url);
		void printXML(XMLNode *startnode, int indent);
		int read(unsigned char *buffer, size_t len);
		void startElement(const unsigned char *name, const unsigned char **attr);
};
#endif
