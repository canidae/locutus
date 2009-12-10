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

#ifndef DATABASE_H
#define DATABASE_H

#include <string>
#include <vector>

#define CACHE_LIFETIME_KEY "cache_lifetime"
#define CACHE_LIFETIME_VALUE 3
#define CACHE_LIFETIME_DESCRIPTION "When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."
#define RUN_INTERVAL_KEY "run_interval"
#define RUN_INTERVAL_VALUE 30
#define RUN_INTERVAL_DESCRIPTION "Interval between Locutus runs. The value is given in days."

class Album;
class Artist;
class Comparison;
class Metafile;
class Metatrack;
class Track;

class Database {
public:
	virtual ~Database() {}

	virtual bool init() = 0;
	virtual bool loadAlbum(Album *album) = 0;
	virtual const std::vector<Metafile *> &loadGroup(const std::string &group) = 0;
	virtual bool loadMetafile(Metafile *metafile) = 0;
	virtual const std::vector<Metafile *> &loadMetafiles(const std::string &filename_pattern) = 0;
	virtual bool loadSettingBool(const std::string &key, bool default_value, const std::string &description) = 0;
	virtual double loadSettingDouble(const std::string &key, double default_value, const std::string &description) = 0;
	virtual int loadSettingInt(const std::string &key, int default_value, const std::string &description) = 0;
	virtual const std::string &loadSettingString(const std::string &key, const std::string &default_value, const std::string &description) = 0;
	virtual bool removeComparisons(const Metafile &metafile) = 0;
	virtual bool removeGoneFiles() = 0;
	virtual bool saveAlbum(const Album &album) = 0;
	virtual bool saveArtist(const Artist &artist) = 0;
	virtual bool saveComparison(const Comparison &comparison) = 0;
	virtual bool saveMetafile(const Metafile &metafile, const std::string &old_filename = "") = 0;
	virtual bool saveTrack(const Track &track) = 0;
	virtual bool shouldRun() = 0;
	virtual bool start() = 0;
	virtual bool stop() = 0;
	virtual bool updateProgress(double progress) = 0;
};
#endif
