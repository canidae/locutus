#ifndef POSTGRESQL_H
#define POSTGRESQL_H
#define ALBUM_CACHE_LIFETIME_KEY "album_cache_lifetime"
#define ALBUM_CACHE_LIFETIME_VALUE 3
#define ALBUM_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since album was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."
#define METATRACK_CACHE_LIFETIME_KEY "metatrack_cache_lifetime"
#define METATRACK_CACHE_LIFETIME_VALUE 3
#define METATRACK_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since metatrack was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."
#define PUID_CACHE_LIFETIME_KEY "puid_cache_lifetime"
#define PUID_CACHE_LIFETIME_VALUE 3
#define PUID_CACHE_LIFETIME_DESCRIPTION "When it's more than this months since puid was fetched from MusicBrainz, it'll be fetched from MusicBrainz again."

extern "C" {
#include <libpq-fe.h>
}
#include <string>
#include "Database.h"

class Album;
class Artist;
class Match;
class Metafile;
class Metatrack;
class Track;

class PostgreSQL : public Database {
	public:
		explicit PostgreSQL(const std::string connection);
		~PostgreSQL();

		bool load(Album *album);
		bool load(Metafile *metafile);
		double loadSetting(const std::string &key, double default_value, const std::string &description);
		int loadSetting(const std::string &key, int default_value, const std::string &description);
		std::string loadSetting(const std::string &key, const std::string &default_value, const std::string &description);
		bool save(const Album &album);
		bool save(const Artist &artist);
		bool save(const Match &match);
		bool save(const Metafile &metafile, const std::string &old_filename = "");
		bool save(const Metatrack &metatrack);
		bool save(const Track &track);

	private:
		PGconn *pg_connection;
		PGresult *pg_result;
		bool got_result;
		int album_cache_lifetime;
		int metatrack_cache_lifetime;
		int puid_cache_lifetime;

		void clear();
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
