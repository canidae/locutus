#include "Database.h"

/* constructors */
Database::Database() {
	pthread_mutex_init(&mutex, NULL);
	query_sent = false;
	pg_connection = PQconnectdb(CONNECTION_STRING);
	if (!pg_connection) {
		cout << "Unable to connect to the database" << endl;
		exit(1);
	}
}

/* destructors */
Database::~Database() {
	clear();
	PQfinish(pg_connection);
	pthread_mutex_destroy(&mutex);
}

/* methods */
void Database::clear() {
	if (query_sent)
		PQclear(pg_result);
	pthread_mutex_unlock(&mutex);
}

double Database::getDouble(int row, int col) {
	return atof(PQgetvalue(pg_result, row, col));
}

int Database::getInt(int row, int col) {
	return atoi(PQgetvalue(pg_result, row, col));
}

int Database::getRows() {
	return PQntuples(pg_result);
}

string Database::getString(int row, int col) {
	return PQgetvalue(pg_result, row, col);
}

bool Database::query(char *query) {
	pthread_mutex_lock(&mutex);
	query_sent = true;
	pg_result = PQexec(pg_connection, query);
	int resultstatus = PQresultStatus(pg_result);
	if (resultstatus == PGRES_COMMAND_OK || resultstatus == PGRES_TUPLES_OK)
		return true;
	cout << PQresultErrorMessage(pg_result) << "Query: " << query << endl;
	return false;
}
