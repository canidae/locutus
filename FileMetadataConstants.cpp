#include "FileMetadataConstants.h"

/* constructors */
FileMetadataConstants::FileMetadataConstants(Locutus *locutus) {
	this->locutus = locutus;
	album_weight = ALBUM_WEIGHT_VALUE;
	artist_weight = ARTIST_WEIGHT_VALUE;
	combine_threshold = COMBINE_THRESHOLD_VALUE;
	duration_limit = DURATION_LIMIT_VALUE;
	duration_weight = DURATION_WEIGHT_VALUE;
	title_weight = TITLE_WEIGHT_VALUE;
	tracknumber_weight = TRACKNUMBER_WEIGHT_VALUE;
}

/* destructors */
FileMetadataConstants::~FileMetadataConstants() {
}

/* methods */
bool FileMetadataConstants::loadSettings() {
	if (!locutus->database->query("SELECT setting_class_id FROM setting_class WHERE name = 'FileMetadata'")) {
		locutus->database->clear();
		return false;
	}
	if (locutus->database->getRows() <= 0) {
		/* hmm, no entry for FileMetadata */
		locutus->database->clear();
		locutus->database->query("INSERT INTO setting_class(name, description) VALUES ('FileMetadata', '')");
		locutus->database->clear();
		if (!locutus->database->query("SELECT setting_class_id FROM setting_class WHERE name = 'FileMetadata'")) {
			locutus->database->clear();
			return false;
		}
	}
	if (locutus->database->getRows() <= 0) {
		locutus->database->clear();
		return false;
	}
	setting_class_id = locutus->database->getInt(0, 0);
	locutus->database->clear();
	album_weight = loadSettingsHelper(ALBUM_WEIGHT_KEY, ALBUM_WEIGHT_VALUE, ALBUM_WEIGHT_DESCRIPTION);
	artist_weight = loadSettingsHelper(ARTIST_WEIGHT_KEY, ARTIST_WEIGHT_VALUE, ARTIST_WEIGHT_DESCRIPTION);
	combine_threshold = loadSettingsHelper(COMBINE_THRESHOLD_KEY, COMBINE_THRESHOLD_VALUE, COMBINE_THRESHOLD_DESCRIPTION);
	duration_limit = loadSettingsHelper(DURATION_LIMIT_KEY, DURATION_LIMIT_VALUE, DURATION_LIMIT_DESCRIPTION);
	duration_weight = loadSettingsHelper(DURATION_WEIGHT_KEY, DURATION_WEIGHT_VALUE, DURATION_WEIGHT_DESCRIPTION);
	title_weight = loadSettingsHelper(TITLE_WEIGHT_KEY, TITLE_WEIGHT_VALUE, TITLE_WEIGHT_DESCRIPTION);
	tracknumber_weight = loadSettingsHelper(TRACKNUMBER_WEIGHT_KEY, TRACKNUMBER_WEIGHT_VALUE, TRACKNUMBER_WEIGHT_DESCRIPTION);
	return true;
}

/* private methods */
double FileMetadataConstants::loadSettingsHelper(string key, double default_value, string description) {
	double back = default_value;
	char query[1024];
	sprintf(query, "SELECT value, user_changed FROM setting WHERE setting_class_id = %d AND key = '%s'", setting_class_id, key.c_str());
	if (!locutus->database->query(query)) {
		locutus->database->clear();
		return default_value;
	}
	if (locutus->database->getRows() > 0) {
		back = locutus->database->getDouble(0, 0);
		if (!locutus->database->getBool(0, 1) && back != default_value) {
			/* user has not changed value and default value has changed.
			 *                          * update database */
			locutus->database->clear();
			sprintf(query, "UPDATE setting SET value = '%lf', description = '%s' WHERE setting_class_id = %d AND key = '%s'", default_value, description.c_str(), setting_class_id, key.c_str());
			if (!locutus->database->query(query)) {
				locutus->database->clear();
				return default_value;
			}
		}
	} else {
		/* this key is missing, add it */
		locutus->database->clear();
		sprintf(query, "INSERT INTO setting(setting_class_id, key, value, description) VALUES (%d, '%s', '%lf', '%s')", setting_class_id, key.c_str(), default_value, description.c_str());
		if (!locutus->database->query(query)) {
			locutus->database->clear();
			return default_value;
		}
	}
	locutus->database->clear();
	return back;
}
