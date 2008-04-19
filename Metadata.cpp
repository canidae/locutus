#include "Metadata.h"

/* constructors */
Metadata::Metadata(int duration) {
	this->duration = duration;
}

/* destructors */
Metadata::~Metadata() {
}

/* methods */
bool Metadata::equalMBID(Metadata target) {
	if (getValue(MUSICBRAINZ_ALBUMARTISTID) != target.getValue(MUSICBRAINZ_ALBUMARTISTID))
		return false;
	if (getValue(MUSICBRAINZ_ALBUMID) != target.getValue(MUSICBRAINZ_ALBUMID))
		return false;
	if (getValue(MUSICBRAINZ_ARTISTID) != target.getValue(MUSICBRAINZ_ARTISTID))
		return false;
	if (getValue(MUSICBRAINZ_TRACKID) != target.getValue(MUSICBRAINZ_TRACKID))
		return false;
	return true;
}

bool Metadata::equalMetadata(Metadata target) {
	if (getValue(ALBUM) != target.getValue(ALBUM))
		return false;
	if (getValue(ALBUMARTIST) != target.getValue(ALBUMARTIST))
		return false;
	if (getValue(ALBUMARTISTSORT) != target.getValue(ALBUMARTISTSORT))
		return false;
	if (getValue(ARTIST) != target.getValue(ARTIST))
		return false;
	if (getValue(ARTISTSORT) != target.getValue(ARTISTSORT))
		return false;
	if (getValue(TITLE) != target.getValue(TITLE))
		return false;
	if (getValue(TRACKNUMBER) != target.getValue(TRACKNUMBER))
		return false;
	return true;
}

string Metadata::getValue(const string key) {
	for (list<Entry>::iterator e = entries.begin(); e != entries.end(); ++e) {
		if (e->key == key)
			return e->value;
	}
	return NULL;
}

void Metadata::setValue(const string key, const string value) {
	bool found = false;
	for (list<Entry>::iterator e = entries.begin(); e != entries.end(); ++e) {
		if (e->key != key)
			continue;
		if (found) {
			entries.erase(e);
		} else {
			e->value = value;
			found = true;
		}
	}
	if (!found) {
		Entry entry;
		entry.key = key;
		entry.value = value;
		entries.push_back(entry);
	}
}
