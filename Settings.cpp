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
	name = locutus->database->escapeString(name);
	description = locutus->database->escapeString(description);
	ostringstream query;
	query << "SELECT setting_class_id FROM setting_class WHERE name = '" << name << "'";
	if (!locutus->database->query(query.str()))
		return -1;
	if (locutus->database->getRows() <= 0) {
		/* hmm, no entry for this class */
		query.str("");
		query << "INSERT INTO setting_class(name, description) VALUES ('" << name << "', '" << description << "')";
		locutus->database->query(query.str());
		query.str("");
		query << "SELECT setting_class_id FROM setting_class WHERE name = '" << name << "'";
		if (!locutus->database->query(query.str()))
			return -1;
		if (locutus->database->getRows() <= 0)
			return -1;
	}
	int class_id = locutus->database->getInt(0, 0);
	return class_id;
}

double Settings::loadSetting(int class_id, string key, double default_value, string description) {
	ostringstream def_val;
	def_val << default_value;
	return atof(loadSetting(class_id, key, def_val.str(), description).c_str());
}

int Settings::loadSetting(int class_id, string key, int default_value, string description) {
	ostringstream def_val;
	def_val << default_value;
	return atoi(loadSetting(class_id, key, def_val.str(), description).c_str());
}

string Settings::loadSetting(int class_id, string key, string default_value, string description) {
	key = locutus->database->escapeString(key);
	string back = default_value;
	ostringstream query;
	query << "SELECT value, user_changed FROM setting WHERE setting_class_id = " << class_id << " AND key = '" << key << "'";
	if (!locutus->database->query(query.str()))
		return back;
	string escaped_value = locutus->database->escapeString(default_value);
	description = locutus->database->escapeString(description);
	if (locutus->database->getRows() > 0) {
		back = locutus->database->getString(0, 0);
		if (!locutus->database->getBool(0, 1) && back != default_value) {
			/* user has not changed value and default value has changed.
			 * update database */
			back = default_value;
			query.str("");
			query << "UPDATE setting SET value = '" << escaped_value << "', description = '" << description << "' WHERE setting_class_id = " << class_id << " AND key = '" << key << "'";
			if (!locutus->database->query(query.str()))
				return back;
		}
	} else {
		/* this key is missing, add it */
		query.str("");
		query << "INSERT INTO setting(setting_class_id, key, value, description) VALUES (" << class_id << ", '" << key << "', '" << escaped_value << "', '" << description << "')";
		if (!locutus->database->query(query.str()))
			return back;
	}
	return back;
}
