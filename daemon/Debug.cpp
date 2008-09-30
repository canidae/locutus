#include "Debug.h"

using namespace std;

/* static variables */
bool Debug::initialized = false;
string Debug::timestamp;
ofstream Debug::debugfile;

/* static methods */
void Debug::error(const string &text) {
	if (!initialized)
		return;
	debugfile << "[" << printTime() << "] [ERROR  ] " << text << endl;
}

void Debug::info(const string &text) {
	if (!initialized)
		return;
	debugfile << "[" << printTime() << "] [INFO   ] " << text << endl;
}

void Debug::notice(const string &text) {
	if (!initialized)
		return;
	debugfile << "[" << printTime() << "] [NOTICE ] " << text << endl;
}

void Debug::warning(const string &text) {
	if (!initialized)
		return;
	debugfile << "[" << printTime() << "] [WARNING] " << text << endl;
}

bool Debug::close() {
	if (!initialized)
		return true;
	debugfile.close();
	initialized = false;
	return true;
}

bool Debug::open(const string &file) {
	if (initialized)
		close();
	initialized = true;
	debugfile.open(file.c_str(), ios::app);
	return true;
}

/* private static methods */
string &Debug::printTime() {
	time_t rawtime;
	time(&rawtime);
	timestamp = asctime(localtime(&rawtime));
	return timestamp.erase(timestamp.size() - 1);
}
