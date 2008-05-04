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
		usleep(60000000);
	}
}

/* private methods */
