#ifndef DATABASE_H
#define DATABASE_H

#include <string>

class Album;
class Artist;
class Match;
class Metafile;
class Metatrack;
class Track;

class Database {
	public:
		Database();
		virtual ~Database();

		virtual bool load(Album *album);
		virtual bool load(Metafile *metafile);
		virtual bool loadSetting(const std::string &key, bool default_value, const std::string &description);
		virtual double loadSetting(const std::string &key, double default_value, const std::string &description);
		virtual int loadSetting(const std::string &key, int default_value, const std::string &description);
		virtual std::string loadSetting(const std::string &key, const std::string &default_value, const std::string &description);
		virtual bool save(const Album &album);
		virtual bool save(const Artist &artist);
		virtual bool save(const Match &match);
		virtual bool save(const Metafile &metafile, const std::string &old_filename = "");
		virtual bool save(const Metatrack &metatrack);
		virtual bool save(const Track &track);
};
#endif
