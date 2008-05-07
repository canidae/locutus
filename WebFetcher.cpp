#include "WebFetcher.h"

/* constructors */
WebFetcher::WebFetcher(Locutus *locutus) {
	this->locutus = locutus;
	active = false;
}

/* destructors */
WebFetcher::~WebFetcher() {
}

/* methods */
void WebFetcher::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEREADER_CLASS, FILEREADER_CLASS_DESCRIPTION);
}

void WebFetcher::quit() {
	if (active) {
		active = false;
		join();
	}
}

void WebFetcher::run() {
	active = true;
	while (active) {
		if (lookupPUID())
			continue;
		usleep(10000000);
	}
}

/* private methods */
bool WebFetcher::lookupMetadata() {
	if (locutus->gen_puid_queue.size() > 0)
		return false;
	/* try mbid */
	/* finally try metadata */
	return true;
}

bool WebFetcher::lookupPUID() {
	if (locutus->lookup_puid_queue.size() <= 0)
		return false;
	int file = locutus->lookup_puid_queue[0];
	locutus->lookup_puid_queue.erase(locutus->lookup_puid_queue.begin());
	FileMetadata fm = locutus->files[file];
	/* first look up using puid */
	if (fm.getValue(MUSICIP_PUID) != "") {
		vector<Metadata> tracks = locutus->webservice->searchPUID(fm.getValue(MUSICIP_PUID));
	}
	return true;
}
