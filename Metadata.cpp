#include "Metadata.h"

/* constructors */
Metadata::Metadata() {
}

/* destructors */
Metadata::~Metadata() {
}

/* methods */
string Metadata::getValue(string key) {
	for (list<Entry>::iterator e = entries.begin(); e != entries.end(); ) {
		if (e->key == key)
			return e->value;
		++e;
	}
	return NULL;
}

void Metadata::setValue(string key, string value) {
	bool found = false;
	for (list<Entry>::iterator e = entries.begin(); e != entries.end(); ) {
		if (e->key != key) {
			++e;
			continue;
		}
		if (found) {
			entries.erase(e);
		} else {
			e->value = value;
			found = true;
		}
		++e;
	}
	if (!found) {
		Entry entry;
		entry.key = key;
		entry.value = value;
		entries.push_back(entry);
	}
}
