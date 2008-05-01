#include "WebService.h"

/* constructors */
WebService::WebService(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
WebService::~WebService() {
}

/* methods */
bool WebService::fetchAlbum(string mbid) {
	/* check if it's in database and updated recently first */
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
	/* check if it's in database and updated recently first */
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
