#include "Metadata.h"

/* constructors */
Metadata::Metadata() {
	this->duration = 0;
}

Metadata::Metadata(int duration) {
	this->duration = duration;
}

/* destructors */
Metadata::~Metadata() {
}

/* methods */
bool Metadata::equalMBID(Metadata target) {
	string value = getValue(MUSICBRAINZ_ALBUMARTISTID);
	if (value != "" && value != target.getValue(MUSICBRAINZ_ALBUMARTISTID))
		return false;
	value = getValue(MUSICBRAINZ_ALBUMID);
	if (value != "" && value != target.getValue(MUSICBRAINZ_ALBUMID))
		return false;
	value = getValue(MUSICBRAINZ_ARTISTID);
	if (value != "" && value != target.getValue(MUSICBRAINZ_ARTISTID))
		return false;
	value = getValue(MUSICBRAINZ_TRACKID);
	if (value != "" && value != target.getValue(MUSICBRAINZ_TRACKID))
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
	return "";
}

void Metadata::setValue(const string key, const string value) {
	string::size_type p1 = key.find_first_not_of(" ");
	string::size_type p2 = value.find_first_not_of(" ");
	if (p1 == string::npos || p2 == string::npos)
		return;
	string tkey = key.substr(p1, key.find_last_not_of(" ") - p1);
	string tvalue = value.substr(p2, value.find_last_not_of(" ") - p2);
	if (tkey == "" || tvalue == "")
		return;
	bool found = false;
	for (list<Entry>::iterator e = entries.begin(); e != entries.end(); ++e) {
		if (e->key != tkey)
			continue;
		if (found) {
			entries.erase(e);
		} else {
			e->value = tvalue;
			found = true;
		}
	}
	if (!found) {
		Entry entry;
		entry.key = tkey;
		entry.value = tvalue;
		entries.push_back(entry);
	}
}

void Metadata::setValues(Metadata metadata) {
	for (list<Entry>::iterator e = metadata.entries.begin(); e != metadata.entries.end(); ++e)
		setValue(e->key, e->value);
}
