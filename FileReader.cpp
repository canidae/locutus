#include "FileReader.h"

/* constructors */
FileReader::FileReader(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
FileReader::~FileReader() {
}

/* methods */
void FileReader::run() {
	active = true;
	while (active) {
	}
}

void FileReader::stop() {
	active = false;
	join();
}
