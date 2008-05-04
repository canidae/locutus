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
		if (lookup())
			continue;
		usleep(10000000);
	}
}

/* private methods */
bool WebFetcher::lookup() {
	if (locutus->puid_files.size() <= 0)
		return false;
	FileMetadata fm = locutus->files[locutus->puid_files[0]];
	if (fm.getValue(MUSICIP_PUID) != "") {
		vector<Metadata> tracks = locutus->webservice->searchPUID(fm.getValue(MUSICIP_PUID));
	}
	return true;
}
