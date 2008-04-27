#include "Settings.h"

/* constructors */
Settings::Settings(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
Settings::~Settings() {
}

/* methods */
int Settings::loadClassID(string name, string description) {
	if (name.size() + description.size() > 3900)
		return -1;
	char query[4096];
	sprintf(query, "SELECT setting_class_id FROM setting_class WHERE name = '%s'", name.c_str());
	if (!locutus->database->query(query)) {
		locutus->database->clear();
		return -1;
	}
	if (locutus->database->getRows() <= 0) {
		/* hmm, no entry for this class */
		locutus->database->clear();
		sprintf(query, "INSERT INTO setting_class(name, description) VALUES ('%s', '%s')", name.c_str(), description.c_str());
		locutus->database->query(query);
		locutus->database->clear();
		sprintf(query, "SELECT setting_class_id FROM setting_class WHERE name = '%s'", name.c_str());
		if (!locutus->database->query(query)) {
			locutus->database->clear();
			return -1;
		}
		if (locutus->database->getRows() <= 0) {
			locutus->database->clear();
			return -1;
		}
	}
	int class_id = locutus->database->getInt(0, 0);
	locutus->database->clear();
	return class_id;
}

double Settings::loadSetting(int class_id, string key, double default_value, string description) {
	char def_val[32];
	sprintf(def_val, "%lf", default_value);
	return atof(loadSetting(class_id, key, def_val, description).c_str());
}

int Settings::loadSetting(int class_id, string key, int default_value, string description) {
	char def_val[32];
	sprintf(def_val, "%d", default_value);
	return atoi(loadSetting(class_id, key, def_val, description).c_str());
}

string Settings::loadSetting(int class_id, string key, string default_value, string description) {
	if (key.size() + default_value.size() + description.size() > 3900)
		return default_value;
	string back = default_value;
	char query[4096];
	sprintf(query, "SELECT value, user_changed FROM setting WHERE setting_class_id = %d AND key = '%s'", class_id, key.c_str());
	if (!locutus->database->query(query)) {
		locutus->database->clear();
		return back;
	}
	if (locutus->database->getRows() > 0) {
		back = locutus->database->getString(0, 0);
		if (!locutus->database->getBool(0, 1) && back != default_value) {
			/* user has not changed value and default value has changed.
			 * update database */
			locutus->database->clear();
			back = default_value;
			sprintf(query, "UPDATE setting SET value = '%s', description = '%s' WHERE setting_class_id = %d AND key = '%s'", default_value.c_str(), description.c_str(), class_id, key.c_str());
			if (!locutus->database->query(query)) {
				locutus->database->clear();
				return back;
			}
		}
	} else {
		/* this key is missing, add it */
		locutus->database->clear();
		sprintf(query, "INSERT INTO setting(setting_class_id, key, value, description) VALUES (%d, '%s', '%s', '%s')", class_id, key.c_str(), default_value.c_str(), description.c_str());
		if (!locutus->database->query(query)) {
			locutus->database->clear();
			return back;
		}
	}
	locutus->database->clear();
	return back;
}
