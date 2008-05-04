#include "PUIDGenerator.h"

/* constructors */
PUIDGenerator::PUIDGenerator(Locutus *locutus) {
	this->locutus = locutus;
	active = false;
}

/* destructors */
PUIDGenerator::~PUIDGenerator() {
}

/* methods */
void PUIDGenerator::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEREADER_CLASS, FILEREADER_CLASS_DESCRIPTION);
}

void PUIDGenerator::quit() {
	if (active) {
		active = false;
		join();
	}
}

void PUIDGenerator::run() {
	active = true;
	while (active) {
		usleep(60000000);
	}
}

/* private methods */
