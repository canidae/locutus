#ifndef DATABASE_H
/* defines */
#define DATABASE_H
/* connection (FIXME: should be config file) */
#define CONNECTION_STRING "host=localhost user=locutus password=locutus dbname=locutus"

/* includes */
#include <iostream>
#include <libpq-fe.h>
#include <string>

/* namespaces */
using namespace std;

/* Database */
class Database {
	public:
		/* variables */

		/* constructors */
		Database();

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
		pthread_mutex_t mutex;
		bool got_result;
		PGconn *pg_connection;
		PGresult *pg_result;

		/* methods */
};
#endif
