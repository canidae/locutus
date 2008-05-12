#include "WebFetcher.h"

/* constructors */
WebFetcher::WebFetcher(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
WebFetcher::~WebFetcher() {
}

/* methods */
void WebFetcher::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEREADER_CLASS, FILEREADER_CLASS_DESCRIPTION);
}

void WebFetcher::lookup() {
	if (locutus->lookup_puid_queue.size() > 0) {
		/* lookup puid for this file */
		/* FIXME
		 * far from finished, blabla */
		int file = locutus->lookup_puid_queue[0];
		locutus->lookup_puid_queue.erase(locutus->lookup_puid_queue.begin());
		FileMetadata fm = locutus->files[file];
		if (fm.getValue(MUSICIP_PUID) != "") {
			vector<Metadata> tracks = locutus->webservice->searchPUID(fm.getValue(MUSICIP_PUID));
		}
	}
	if (!locutus->filereader->ready) {
		usleep(10000000);
	}
	if (locutus->gen_puid_queue.size() > 0) {
	}
}
