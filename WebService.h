#ifndef WEBSERVICE_H
/* defines */
#define WEBSERVICE_H

/* includes */
#include <cc++/common.h>

/* namespaces */
using namespace std;
using namespace ost;

/* WebService */
class WebService : public URLStream, public XMLStream {
	public:
		/* variables */

		/* constructors */
		WebService();

		/* destructors */
		~WebService();

		/* methods */
		void fetchRelease(const char *mbid);

	private:
		/* variables */
		URLStream::Error status;

		/* methods */
		int read(unsigned char *buffer, size_t len);
		void startDocument();
		void endDocument();
		void characters(const unsigned char *text, size_t len);
		void startElement(const unsigned char *name, const unsigned char **attr);
		void endElement(const unsigned char *name);
		void close();
};
#endif
