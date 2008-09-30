#include "Debug.h"

using namespace std;

/* constructors/destructor */
Debug::Debug() {
	debugfile.open("locutus.log", ios::app);
}

Debug::~Debug() {
	debugfile.close();
}

/* methods */
void Debug::error(const string &text) {
	debugfile << "[" << printTime() << "] [ERROR  ] " << text << endl;
}

void Debug::info(const string &text) {
	debugfile << "[" << printTime() << "] [INFO   ] " << text << endl;
}

void Debug::notice(const string &text) {
	debugfile << "[" << printTime() << "] [NOTICE ] " << text << endl;
}

void Debug::warning(const string &text) {
	debugfile << "[" << printTime() << "] [WARNING] " << text << endl;
}

/* private methods */
string &Debug::printTime() {
	time_t rawtime;
	time(&rawtime);
	timestamp = asctime(localtime(&rawtime));
	return timestamp.erase(timestamp.size() - 1);
}
