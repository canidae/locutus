#include "WebService.h"

/* constructors */
WebService::WebService(Locutus *locutus) {
	this->locutus = locutus;
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
bool WebService::fetchAlbum(string mbid) {
	string url = release_lookup_url;
	url.append(mbid);
	url.append("?type=xml&inc=tracks+puids+artist+release-events+labels+artist-rels+url-rels");
	return fetch(url.c_str());
}

bool WebService::searchMetadata(string query) {
	string url = metadata_search_url;
	url.append("?type=xml&");
	url.append(query);
	return fetch(url.c_str());
}

bool WebService::searchPUID(string puid) {
	string url = puid_search_url;
	url.append("?type=xml&puid=");
	url.append(puid);
	return fetch(url.c_str());
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

void WebService::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(WEBSERVICE_CLASS, WEBSERVICE_CLASS_DESCRIPTION);
	metadata_search_url = locutus->settings->loadSetting(setting_class_id, METADATA_SEARCH_URL_KEY, METADATA_SEARCH_URL_VALUE, METADATA_SEARCH_URL_DESCRIPTION);
	puid_search_url = locutus->settings->loadSetting(setting_class_id, PUID_SEARCH_URL_KEY, PUID_SEARCH_URL_VALUE, PUID_SEARCH_URL_DESCRIPTION);
	release_lookup_url = locutus->settings->loadSetting(setting_class_id, RELEASE_LOOKUP_URL_KEY, RELEASE_LOOKUP_URL_VALUE, RELEASE_LOOKUP_URL_DESCRIPTION);
}

int WebService::read(unsigned char *buffer, size_t len) {
	URLStream::read((char *)buffer, len);
	return gcount();
}

void WebService::startElement(const unsigned char *name, const unsigned char **attr) {
}
