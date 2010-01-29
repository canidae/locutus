// Copyright © 2010 Vidar Wahlberg <canidae@exent.net>
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

#include "SQLite.h"

#include <stdlib.h>
#include "Config.h"
#include "Debug.h"

using namespace std;

SQLite::SQLite(const Config& config) : Database() {
	string db_file = config.getSettingValue("sqlite_file");
	int rc = sqlite3_open(db_file.c_str(), &db);
	if (rc) {
		Debug::error() << "Unable to connect to the database: " << db_file << endl;
		sqlite3_close(db);
		exit(1);
	}
}

SQLite::~SQLite() {
	sqlite3_close(db);
}

bool SQLite::init() {
	return false;
}

bool SQLite::loadAlbum(Album* album) {
	return false;
}

const std::vector<Metafile*>& SQLite::loadGroup(const std::string& group) {
}

bool SQLite::loadMetafile(Metafile* metafile) {
	return false;
}

const std::vector<Metafile*>& SQLite::loadMetafiles(const std::string& filename_pattern) {
}

bool SQLite::loadSettingBool(const std::string& key, bool default_value, const std::string& description) {
	return false;
}

double SQLite::loadSettingDouble(const std::string& key, double default_value, const std::string& description) {
	return -1.0;
}

int SQLite::loadSettingInt(const std::string& key, int default_value, const std::string& description) {
	return -1;
}

const std::string& SQLite::loadSettingString(const std::string& key, const std::string& default_value, const std::string& description) {
}

bool SQLite::removeComparisons(const Metafile& metafile) {
	return false;
}

bool SQLite::removeGoneFiles() {
	return false;
}

bool SQLite::saveAlbum(const Album& album) {
	return false;
}

bool SQLite::saveArtist(const Artist& artist) {
	return false;
}

bool SQLite::saveComparison(const Comparison& comparison) {
	return false;
}

bool SQLite::saveMetafile(const Metafile& metafile, const std::string& old_filename) {
	return false;
}

bool SQLite::saveTrack(const Track& track) {
	return false;
}

bool SQLite::shouldRun() {
	return false;
}

bool SQLite::start() {
	return false;
}

bool SQLite::stop() {
	return false;
}

bool SQLite::updateProgress(double progress) {
	return false;
}
