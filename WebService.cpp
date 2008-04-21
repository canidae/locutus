#include "WebService.h"

/* constructors */
WebService::WebService() {
}

/* destructors */
WebService::~WebService() {
}

/* TODO
 * metadata search: http://musicbrainz.org/ws/1/track/?type=xml&limit=25&query=tnum%3A(7 07. angels) qdur%3A[110 TO 130] artist%3A(within temptation desktop within temptation \- the silent force \(limited premium edition\) 07. angels) track%3A(angels 07. angels) release%3A(the silent force desktop within temptation \- the silent force \(limited premium edition\) 07. angels)
 * puid search: http://musicbrainz.org/ws/1/track/?type=xml&puid=87cd2d44-d774-d0fc-d507-ef8005051c10
 * release lookup: http://musicbrainz.org/ws/1/release/4e0d7112-28cc-429f-ab55-6a495ce30192?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels
 */

/* methods */
void WebService::fetchAlbum(const char *mbid) {
}

void WebService::searchMetadata(const char *query) {
}

void WebService::searchPUID(const char *puid) {
}

/* private methods */
void WebService::characters(const unsigned char *text, size_t len) {
	char *t = new char[len];
	int a = len;
	while (a-- > 0)
		t[a] = text[a];
	string test(t, len);
	cout << test << endl;
	delete [] t;
}

void WebService::close() {
	URLStream::close();
}

void WebService::endElement(const unsigned char *name) {
}

bool WebService::fetch(const char *url) {
	status = get(url);
	if (status) {
		cout << "failed; reason=" << status << endl;
		close();
		return false;
	}
	cout << "Parsing..." << endl;
	if (!parse())
		cout << "not well formed..." << endl;
	close();
	cout << ends;
	return true;
}

int WebService::read(unsigned char *buffer, size_t len) {
	URLStream::read((char *)buffer, len);
	return gcount();
}

void WebService::startElement(const unsigned char *name, const unsigned char **attr) {
}
