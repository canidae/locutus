#include "PUIDGenerator.h"

/* constructors */
PUIDGenerator::PUIDGenerator(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
PUIDGenerator::~PUIDGenerator() {
}

/* methods */
void PUIDGenerator::generatePUIDs() {
	/* TODO */
	/* remember to set filemetadata.puid_lookup = true */
}

void PUIDGenerator::loadSettings() {
	setting_class_id = locutus->settings->loadClassID(FILEREADER_CLASS, FILEREADER_CLASS_DESCRIPTION);
}
