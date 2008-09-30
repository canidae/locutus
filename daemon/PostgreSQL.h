#ifndef POSTGRESQL_H
#define POSTGRESQL_H

extern "C" {
#include <libpq-fe.h>
}
#include <string>
#include "Database.h"

class Locutus; // XXX

class Album;
class Artist;
class Metafile;
class Metatrack;
class Track;

class PostgreSQL : public Database {
	public:
		/* constructors/destructor */
		PostgreSQL(Locutus *locutus, const std::string connection);
		~PostgreSQL();

		/* methods */
		bool load(Album *album);
		bool load(Metafile *metafile);
		virtual double loadSetting(const std::string &key, double default_value, const std::string &description);
		virtual int loadSetting(const std::string &key, int default_value, const std::string &description);
		virtual std::string loadSetting(const std::string &key, const std::string &default_value, const std::string &description);
		bool save(const Album &album);
		bool save(const Artist &artist);
		bool save(const Metafile &metafile);
		bool save(const Metatrack &metatrack);
		bool save(const Track &track);

	private:
		/* variables */
		Locutus *locutus; // XXX
		bool got_result;
		PGconn *pg_connection;
		PGresult *pg_result;

		/* methods */
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
