#ifndef DATABASE_H
/* defines */
#define DATABASE_H
/* connection (FIXME: should be config file) */
#define CONNECTION_STRING "host=localhost user=locutus password=locutus dbname=locutus"

/* forward declare */
class Database;

/* includes */
#include <iostream>
#include <libpq-fe.h>
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
		void clear();
		string escapeString(string str);
		bool getBool(const int row, const int col);
		double getDouble(const int row, const int col);
		int getInt(const int row, const int col);
		int getRows();
		string getString(const int row, const int col);
		bool isNull(const int row, const int col);
		bool query(const string q);
		bool query(const char *q);

	private:
		/* variables */
		Locutus *locutus;
		pthread_mutex_t mutex;
		bool got_result;
		PGconn *pg_connection;
		PGresult *pg_result;
};
#endif
