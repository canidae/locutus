#ifndef WEBSERVICE_H
/* defines */
#define WEBSERVICE_H
/* settings */
#define WEBSERVICE_CLASS "WebService"
#define WEBSERVICE_CLASS_DESCRIPTION "Settings for looking up data on a WebService"
#define METADATA_SEARCH_URL_KEY "metadata_search_url"
#define METADATA_SEARCH_URL_VALUE "http://musicbrainz.org/ws/1/track/"
#define METADATA_SEARCH_URL_DESCRIPTION "URL to search after metadata"
#define PUID_SEARCH_URL_KEY "puid_search_url"
#define PUID_SEARCH_URL_VALUE "http://musicbrainz.org/ws/1/track/"
#define PUID_SEARCH_URL_DESCRIPTION "URL to search after puid"
#define RELEASE_LOOKUP_URL_KEY "release_url"
#define RELEASE_LOOKUP_URL_VALUE "http://musicbrainz.org/ws/1/release/"
#define RELEASE_LOOKUP_URL_DESCRIPTION "URL to lookup a release"

/* forward declare */
class WebService;

/* includes */
#include <cc++/common.h>
#include "Locutus.h"

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
		bool fetchAlbum(string mbid);
		bool searchMetadata(string query);
		bool searchPUID(string puid);

	private:
		/* variables */
		Locutus *locutus;
		URLStream::Error status;
		int setting_class_id;
		string metadata_search_url;
		string puid_search_url;
		string release_lookup_url;

		/* methods */
		void characters(const unsigned char *text, size_t len);
		void close();
		void endElement(const unsigned char *name);
		bool fetch(const char *url);
		void loadSettings();
		int read(unsigned char *buffer, size_t len);
		void startElement(const unsigned char *name, const unsigned char **attr);
};
#endif
