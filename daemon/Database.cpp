#include "Database.h"

using namespace std;

/* constructors/destructor */
Database::Database() {
}

Database::~Database() {
}

/* methods */
bool Database::load(Album *album) {
	return false;
}

bool Database::load(Metafile *metafile) {
	return false;
}

double Database::loadSetting(const string &key, double default_value, const string &description) {
	return default_value;
}

int Database::loadSetting(const string &key, int default_value, const string &description) {
	return default_value;
}

string Database::loadSetting(const string &key, const string &default_value, const string &description) {
	return default_value;
}

bool Database::save(const Album &album) {
	return false;
}

bool Database::save(const Artist &artist) {
	return false;
}

bool Database::save(const Match &match) {
	return false;
}

bool Database::save(const Metafile &metafile) {
	return false;
}

bool Database::save(const Metatrack &metatrack) {
	return false;
}

bool Database::save(const Track &track) {
	return false;
}
