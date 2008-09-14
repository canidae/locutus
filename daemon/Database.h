#ifndef DATABASE_H
/* defines */
#define DATABASE_H
/* connection (FIXME: should be config file) */
#define CONNECTION_STRING "host=localhost user=locutus password=locutus dbname=locutus"
//#define CONNECTION_STRING "host=sql.samfundet.no user=locutus password=locutus dbname=locutus"

/* forward declare */
class Database;

/* includes */
#include <iostream>
extern "C" {
	#include <libpq-fe.h>
}
#include <string>
#include "Locutus.h"

/* namespaces */
using namespace std;

/* Database */
class Database {
	public:
		/* constructors */
		Database(Locutus *locutus);

		/* destructors */
		~Database();

		/* methods */
		string escapeString(const string &str) const;
		bool getBool(int row, int col) const;
		double getDouble(int row, int col) const;
		int getInt(int row, int col) const;
		int getRows() const;
		string getString(int row, int col) const;
		bool isNull(int row, int col) const;
		bool query(const string &q);

	private:
		/* variables */
		Locutus *locutus;
		bool got_result;
		PGconn *pg_connection;
		PGresult *pg_result;

		/* methods */
		void clear();
		bool doQuery(const char *q);
};
#endif
