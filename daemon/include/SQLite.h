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

#ifndef SQLITE_H
#define	SQLITE_H

#include <sqlite3.h>
#include <stdio.h>
#include <string>
#include <vector>
#include "Database.h"

class Album;
class Artist;
class Comparison;
class Config;
class Metafile;
class Metatrack;
class Track;

class SQLite : public Database {
public:
	SQLite(const Config& config);
	~SQLite();

	bool init();
	bool loadAlbum(Album* album);
	const std::vector<Metafile*>& loadGroup(const std::string& group);
	bool loadMetafile(Metafile* metafile);
	const std::vector<Metafile*>& loadMetafiles(const std::string& filename_pattern);
	bool loadSettingBool(const std::string& key, bool default_value, const std::string& description);
	double loadSettingDouble(const std::string& key, double default_value, const std::string& description);
	int loadSettingInt(const std::string& key, int default_value, const std::string& description);
	const std::string& loadSettingString(const std::string& key, const std::string& default_value, const std::string& description);
	bool removeComparisons(const Metafile& metafile);
	bool removeGoneFiles();
	bool saveAlbum(const Album& album);
	bool saveArtist(const Artist& artist);
	bool saveComparison(const Comparison& comparison);
	bool saveMetafile(const Metafile& metafile, const std::string& old_filename = "");
	bool saveTrack(const Track& track);
	bool shouldRun();
	bool start();
	bool stop();
	bool updateProgress(double progress);

private:
	sqlite3 *db;

};
#endif /* SQLITE_H */
