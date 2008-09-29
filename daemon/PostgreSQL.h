#ifndef POSTGRESQL_H
/* defines */
#define POSTGRESQL_H

/* forward declare */
class PostgreSQL;

/* includes */
extern "C" {
	#include <libpq-fe.h>
}
#include <string>
#include "Database.h"

/* namespaces */
using namespace std;

/* PostgreSQL */
class PostgreSQL : public Database {
	public:
		/* variables */

		/* constructors */
		PostgreSQL(Locutus *locutus, string connection);

		/* destructor */
		~PostgreSQL();

		/* methods */
		bool load(Album *album);
		bool load(Metafile *metafile);
		virtual double loadSetting(const string &key, double default_value, const string &description);
		virtual int loadSetting(const string &key, int default_value, const string &description);
		virtual string loadSetting(const string &key, const string &default_value, const string &description);
		bool save(const Album &album);
		bool save(const Artist &artist);
		bool save(const Metafile &metafile);
		bool save(const Metatrack &metatrack);
		bool save(const Track &track);

	private:
		/* variables */
		bool got_result;
		PGconn *pg_connection;
		PGresult *pg_result;

		/* methods */
		void clear();
		bool doQuery(const char *q);
		string escapeString(const string &str) const;
		bool getBool(int row, int col) const;
		double getDouble(int row, int col) const;
		int getInt(int row, int col) const;
		int getRows() const;
		string getString(int row, int col) const;
		bool isNull(int row, int col) const;
		bool doQuery(const string &q);
};
#endif
