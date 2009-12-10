// Copyright © 2008-2009 Vidar Wahlberg <canidae@exent.net>
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

#ifndef POSTGRESQL_H
#define POSTGRESQL_H

extern "C" {
#include <postgresql/libpq-fe.h>
}
#include <string>
#include <vector>
#include "Database.h"

class Album;
class Artist;
class Comparison;
class Metafile;
class Metatrack;
class Track;

class PostgreSQL : public Database {
public:
	PostgreSQL(const std::string &host, const std::string &user, const std::string &pass, const std::string &name);
	~PostgreSQL();

	bool init();
	bool loadAlbum(Album *album);
	std::vector<Metafile *> &loadGroup(const std::string &group);
	bool loadMetafile(Metafile *metafile);
	std::vector<Metafile *> &loadMetafiles(const std::string &filename_pattern);
	bool loadSettingBool(const std::string &key, bool default_value, const std::string &description);
	double loadSettingDouble(const std::string &key, double default_value, const std::string &description);
	int loadSettingInt(const std::string &key, int default_value, const std::string &description);
	std::string &loadSettingString(const std::string &key, const std::string &default_value, const std::string &description);
	bool removeComparisons(const Metafile &metafile);
	bool removeGoneFiles();
	bool saveAlbum(const Album &album);
	bool saveArtist(const Artist &artist);
	bool saveComparison(const Comparison &comparison);
	bool saveMetafile(const Metafile &metafile, const std::string &old_filename = "");
	bool saveTrack(const Track &track);
	bool shouldRun();
	bool start();
	bool stop();
	bool updateProgress(double progress);

private:
	PGconn *pg_connection;
	PGresult *pg_result;
	bool got_result;
	int album_cache_lifetime;
	int run_interval;
	std::string setting_string;
	std::vector<Metafile *> groupfiles;
	std::vector<Metafile *> metafiles;

	void clear();
	void deleteFiles(std::vector<Metafile *> *files);
	bool doQuery(const char *q);
	std::string escapeString(const std::string &str) const;
	bool getBool(int row, int col) const;
	double getDouble(int row, int col) const;
	int getInt(int row, int col) const;
	int getRows() const;
	std::string getString(int row, int col) const;
	bool isNull(int row, int col) const;
	bool doQuery(const std::string &q);
};
#endif
