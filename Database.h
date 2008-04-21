#ifndef DATABASE_H
/* defines */
#define DATABASE_H
/* connection (FIXME: should be config file) */
#define CONNECTION_STRING "host=localhost user=locutus password=locutus dbname=locutus"

/* includes */
#include <iostream>
#include <libpq-fe.h>

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
		double getDouble(int row, int col);
		int getInt(int row, int col);
		int getRows();
		string getString(int row, int col);
		bool query(char *query);

	private:
		/* variables */
		pthread_mutex_t mutex;
		bool query_sent;
		PGconn *pg_connection;
		PGresult *pg_result;

		/* methods */
};
#endif
