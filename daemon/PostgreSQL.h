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
#include <vector>
#include "Database.h"
#include "Metafile.h"

class Album;
class Artist;
class Match;
class Metatrack;
class Track;

class PostgreSQL : public Database {
	public:
		explicit PostgreSQL(const std::string connection);
		~PostgreSQL();

		bool clean();
		bool init();
		bool loadAlbum(Album *album);
		bool loadMetafile(Metafile *metafile);
		std::vector<Metafile> loadMetafiles(const std::string &filename_pattern);
		bool loadSettingBool(const std::string &key, bool default_value, const std::string &description);
		double loadSettingDouble(const std::string &key, double default_value, const std::string &description);
		int loadSettingInt(const std::string &key, int default_value, const std::string &description);
		std::string loadSettingString(const std::string &key, const std::string &default_value, const std::string &description);
		bool removeMatches(const Metafile &metafile);
		bool saveAlbum(const Album &album);
		bool saveArtist(const Artist &artist);
		bool saveMatch(const Match &match);
		bool saveMetafile(const Metafile &metafile, const std::string &old_filename = "");
		bool saveTrack(const Track &track);
		bool start();
		bool stop();

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
