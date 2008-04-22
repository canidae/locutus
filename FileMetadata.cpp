#include "FileMetadata.h"

/* constructors */
FileMetadata::FileMetadata(Locutus *locutus, string filename, int duration) : Metadata(duration) {
	this->locutus = locutus;
	this->filename = filename;
}

/* destructors */
FileMetadata::~FileMetadata() {
}

/* methods */
double FileMetadata::compareWithMetadata(Metadata target) {
	/* compare this metadata with target */
	double score = 0.0;
	list<string> source = createMetadataList();
	double match[4][source.size()];
	int pos = 0;
	for (list<string>::iterator s = source.begin(); s != source.end(); ++s) {
		match[0][pos] = locutus->levenshtein->similarity(target.getValue(ALBUM), *s);
		match[1][pos] = locutus->levenshtein->similarity(target.getValue(ARTIST), *s);
		match[2][pos] = locutus->levenshtein->similarity(target.getValue(TITLE), *s);
		match[3][pos] = (target.getValue(TRACKNUMBER) == *s) ? 1.0 : 0.0;
		++pos;
	}
	/* find the combination that gives the best score
	 * don't like this code, it's messy */
	double best = 0.0;
	int p[4];
	int c1 = 0;
	for (list<string>::iterator s1 = source.begin(); s1 != source.end(); ++s1) {
		int c2 = 0;
		for (list<string>::iterator s2 = source.begin(); s2 != source.end(); ++s2) {
			if (c1 == c2) {
				++c2;
				continue;
			}
			int c3 = 0;
			for (list<string>::iterator s3 = source.begin(); s3 != source.end(); ++s3) {
				if (c1 == c3 || c2 == c3) {
					++c3;
					continue;
				}
				int c4 = 0;
				for (list<string>::iterator s4 = source.begin(); s4 != source.end(); ++s4) {
					if (c1 == c4 || c2 == c4 || c3 == c4) {
						++c4;
						continue;
					}
					double value = match[0][c1] + match[1][c2] + match[2][c3] + match[3][c4];
					if (value > best) {
						best = value;
						p[0] = c1;
						p[1] = c2;
						p[2] = c3;
						p[3] = c4;
					}
					++c4;
				}
				++c3;
			}
			++c2;
		}
		++c1;
	}
	if (best > 0.0) {
		score += match[0][p[0]] * ALBUM_WEIGHT_VALUE;
		score += match[1][p[1]] * ARTIST_WEIGHT_VALUE;
		score += match[2][p[2]] * TITLE_WEIGHT_VALUE;
		score += match[3][p[3]] * TRACKNUMBER_WEIGHT_VALUE;
	}
	int durationdiff = abs(target.duration - duration);
	if (durationdiff < DURATION_LIMIT_VALUE) {
		score += (1.0 - durationdiff / DURATION_LIMIT_VALUE) * DURATION_WEIGHT_VALUE;
	}
	score /= ALBUM_WEIGHT_VALUE + ARTIST_WEIGHT_VALUE + TITLE_WEIGHT_VALUE + TRACKNUMBER_WEIGHT_VALUE + DURATION_WEIGHT_VALUE;
	return score;
}

/* private methods */
list<string> FileMetadata::createMetadataList() {
	/* create a list of the values we wish to compare with */
	list<string> data;
	/* filename */
	/* metadata */
	data.push_back(getValue(ALBUM));
	data.push_back(getValue(ALBUMARTIST));
	data.push_back(getValue(ARTIST));
	data.push_back(getValue(TITLE)); // might have to be tokenized (" - ", etc)
	data.push_back(getValue(TRACKNUMBER));
	return data;
}

void FileMetadata::loadSettings() {
	if (!locutus->database->query("SELECT setting_class_id FROM setting_class WHERE name = 'FileMetadata'"))
		exit(1);
	if (locutus->database->getRows() <= 0) {
		/* hmm, no entry for FileMetadata */
		locutus->database->clear();
		locutus->database->query("INSERT INTO setting_class(name, description) VALUES ('FileMetadata', '')");
		locutus->database->clear();
		if (!locutus->database->query("SELECT setting_class_id FROM setting_class WHERE name = 'FileMetadata'"))
			exit(1);
	}
	if (locutus->database->getRows() <= 0)
		exit(1);
	int setting_class_id = locutus->database->getInt(0, 0);
	locutus->database->clear();
	album_weight = loadSettingsHelper(setting_class_id, ALBUM_WEIGHT_KEY, ALBUM_WEIGHT_VALUE, ALBUM_WEIGHT_DESCRIPTION);
	artist_weight = loadSettingsHelper(setting_class_id, ARTIST_WEIGHT_KEY, ARTIST_WEIGHT_VALUE, ARTIST_WEIGHT_DESCRIPTION);
	combine_threshold = loadSettingsHelper(setting_class_id, COMBINE_THRESHOLD_KEY, COMBINE_THRESHOLD_VALUE, COMBINE_THRESHOLD_DESCRIPTION);
	duration_limit = loadSettingsHelper(setting_class_id, DURATION_LIMIT_KEY, DURATION_LIMIT_VALUE, DURATION_LIMIT_DESCRIPTION);
	duration_weight = loadSettingsHelper(setting_class_id, DURATION_WEIGHT_KEY, DURATION_WEIGHT_VALUE, DURATION_WEIGHT_DESCRIPTION);
	title_weight = loadSettingsHelper(setting_class_id, TITLE_WEIGHT_KEY, TITLE_WEIGHT_VALUE, TITLE_WEIGHT_DESCRIPTION);
	tracknumber_weight = loadSettingsHelper(setting_class_id, TRACKNUMBER_WEIGHT_KEY, TRACKNUMBER_WEIGHT_VALUE, TRACKNUMBER_WEIGHT_DESCRIPTION);
}

double FileMetadata::loadSettingsHelper(int setting_class_id, string key, double default_value, string description) {
	double back = default_value;
	char query[1024];
	sprintf(query, "SELECT value, user_changed FROM setting WHERE setting_class_id = %d AND key = '%s'", setting_class_id, key.c_str());
	if (!locutus->database->query(query))
		exit(1);
	if (locutus->database->getRows() > 0) {
		back = locutus->database->getDouble(0, 0);
		if (!locutus->database->getBool(0, 1) && back != default_value) {
			/* user has not changed value and default value has changed.
			 * update database */
			locutus->database->clear();
			sprintf(query, "UPDATE setting SET value = '%lf', description = '%s' WHERE setting_class_id = %d AND key = '%s'", default_value, description.c_str(), setting_class_id, key.c_str());
			if (!locutus->database->query(query))
				exit(1);
		}
	} else {
		/* this key is missing, add it */
		locutus->database->clear();
		sprintf(query, "INSERT INTO setting(setting_class_id, key, value, description) VALUES (%d, '%s', '%lf', '%s')", setting_class_id, key.c_str(), default_value, description.c_str());
		if (!locutus->database->query(query))
			exit(1);
	}
	locutus->database->clear();
	return back;
}
