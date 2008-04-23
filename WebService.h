#ifndef WEBSERVICE_H
/* defines */
#define WEBSERVICE_H

/* includes */
#include <cc++/common.h>

/* namespaces */
using namespace ost;
using namespace std;

/* WebService */
class WebService : public URLStream, public XMLStream {
	public:
		/* variables */

		/* constructors */
		WebService();

		/* destructors */
		~WebService();

		/* methods */
		void fetchAlbum(const char *mbid);
		void searchMetadata(const char *query);
		void searchPUID(const char *puid);

	private:
		/* variables */
		URLStream::Error status;

		/* methods */
		void characters(const unsigned char *text, size_t len);
		void close();
		void endElement(const unsigned char *name);
		bool fetch(const char *url);
		int read(unsigned char *buffer, size_t len);
		void startElement(const unsigned char *name, const unsigned char **attr);
};
#endif
