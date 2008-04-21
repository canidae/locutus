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

bool Database::getBool(const int row, const int col) {
	return PQgetvalue(pg_result, row, col)[0] == 't';
}

double Database::getDouble(const int row, const int col) {
	return atof(PQgetvalue(pg_result, row, col));
}

int Database::getInt(const int row, const int col) {
	return atoi(PQgetvalue(pg_result, row, col));
}

int Database::getRows() {
	return PQntuples(pg_result);
}

string Database::getString(const int row, const int col) {
	return PQgetvalue(pg_result, row, col);
}

bool Database::query(const string q) {
	return query(q.c_str());
}

bool Database::query(const char *q) {
	pthread_mutex_lock(&mutex);
	query_sent = true;
	pg_result = PQexec(pg_connection, q);
	int resultstatus = PQresultStatus(pg_result);
	if (resultstatus == PGRES_COMMAND_OK || resultstatus == PGRES_TUPLES_OK)
		return true;
	cerr << PQresultErrorMessage(pg_result) << "Query: " << q << endl;
	return false;
}
