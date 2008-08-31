#include "Settings.h"

/* constructors */
Settings::Settings(Locutus *locutus) {
	this->locutus = locutus;
}

/* destructors */
Settings::~Settings() {
}

/* methods */
double Settings::loadSetting(const string &key, double default_value, const string &description) const {
	ostringstream def_val;
	def_val << default_value;
	return atof(loadSetting(key, def_val.str(), description).c_str());
}

int Settings::loadSetting(const string &key, int default_value, const string &description) const {
	ostringstream def_val;
	def_val << default_value;
	return atoi(loadSetting(key, def_val.str(), description).c_str());
}

string Settings::loadSetting(const string &key, const string &default_value, const string &description) const {
	string e_key = locutus->database->escapeString(key);
	string back = default_value;
	ostringstream query;
	query << "SELECT value, user_changed FROM setting WHERE key = '" << e_key << "'";
	if (!locutus->database->query(query.str()))
		return back;
	string escaped_value = locutus->database->escapeString(default_value);
	string e_description = locutus->database->escapeString(description);
	if (locutus->database->getRows() > 0) {
		back = locutus->database->getString(0, 0);
		if (!locutus->database->getBool(0, 1) && back != default_value) {
			/* user has not changed value and default value has changed.
			 * update database */
			back = default_value;
			query.str("");
			query << "UPDATE setting SET value = '" << escaped_value << "', description = '" << e_description << "' WHERE key = '" << e_key << "'";
			if (!locutus->database->query(query.str()))
				return back;
		}
	} else {
		/* this key is missing, add it */
		query.str("");
		query << "INSERT INTO setting(key, value, description) VALUES ('" << e_key << "', '" << escaped_value << "', '" << e_description << "')";
		if (!locutus->database->query(query.str()))
			return back;
	}
	return back;
}
