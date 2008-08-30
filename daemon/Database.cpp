#include "Database.h"

/* constructors */
Database::Database(Locutus *locutus) {
	this->locutus = locutus;
	got_result = false;
	pg_connection = PQconnectdb(CONNECTION_STRING);
	if (PQstatus(pg_connection) != CONNECTION_OK) {
		locutus->debug(DEBUG_ERROR, "Unable to connect to the database");
		exit(1);
	}
}

/* destructors */
Database::~Database() {
	clear();
	PQfinish(pg_connection);
}

/* methods */
string Database::escapeString(const string &str) const {
	char *to = new char[str.size() * 2 + 1];
	int error = 0;
	size_t len = PQescapeStringConn(pg_connection, to, str.c_str(), str.size(), &error);
	string back(to, len);
	delete [] to;
	return back;
}

bool Database::getBool(int row, int col) const {
	return PQgetvalue(pg_result, row, col)[0] == 't';
}

double Database::getDouble(int row, int col) const {
	return atof(PQgetvalue(pg_result, row, col));
}

int Database::getInt(int row, int col) const {
	return atoi(PQgetvalue(pg_result, row, col));
}

int Database::getRows() const {
	return PQntuples(pg_result);
}

string Database::getString(int row, int col) const {
	return PQgetvalue(pg_result, row, col);
}

bool Database::isNull(int row, int col) const {
	return (PQgetisnull(pg_result, row, col) != 0);
}

bool Database::query(const string &q) {
	return doQuery(q.c_str());
}

/* private methods */
void Database::clear() {
	if (got_result)
		PQclear(pg_result);
	got_result = false;
}

bool Database::doQuery(const char *q) {
	clear();
	got_result = true;
	string msg = "Query: ";
	msg.append(q);
	locutus->debug(DEBUG_INFO, msg);
	pg_result = PQexec(pg_connection, q);
	int status = PQresultStatus(pg_result);
	if (status == PGRES_COMMAND_OK || status == PGRES_TUPLES_OK)
		return true;
	msg = "Query failed: ";
	msg.append(q);
	locutus->debug(DEBUG_WARNING, msg);
	msg = "Query error: ";
	msg.append(PQresultErrorMessage(pg_result));
	locutus->debug(DEBUG_WARNING, msg);
	return false;
}